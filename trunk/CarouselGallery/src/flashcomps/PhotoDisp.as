/*-- Classe chargeant et affichant une image donn�e --*/

package flashcomps {
	
	import fl.transitions.*;
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public final class PhotoDisp extends Sprite {
		
		private var urlImg:String;		//URL de l'image � charger
		private var loader:Loader;		//Loader de l'image
		private var bmp:Bitmap;			//Bitmap qui va contenir l'image
		private var ref:Bitmap;			//Bitmap de reflet de l'image
		private var photo:Sprite;		//Sprite contener de l'image principale
		private var msk:Shape;			//Masque du reflet
		private var tween:Tween;		//Tween d'animation du contenu
		private var blurTween:Tween;	//Tween de flou
		private var prop:Object = {};	//Object servant au tween
		private var size:Object;		//Object contenant la taille max du carr� de base
		private var mat:Matrix;			//Matrice de d�grad� pour le reflet
		private var depMtx:Matrix3D;	//Matrice3D de d�part lors du d�placement en plein �cran
		private var arrMtx:Matrix3D;	//Matrice3D d'arriv�e lors du d�placement en plein �cran
		private var scaleT:Number;		//Proportion de la miniature
		private var scaleV:Number;		//Proportion de la vue totale
		private const blurT:int = 24;	//force du filtre flou
		
		//Fonction principale, affichant le carr� blanc de base
		public function PhotoDisp(url:String):void {
			urlImg = url;											//stocke l'url de l'image
			size = XMLManager.thumbSize;							//stocke la taille de la miniature
			mat = new Matrix;										//matrice de d�grad� pour le reflet
			arrMtx = new Matrix3D();								//Matrice 3D d'arriv�e de la photo en pleine vue
			arrMtx.appendTranslation(0,0,-XMLManager.radius);		//Translation vers l'avant de la distance du rayon
			prop.blur = 0;											//initialisation du blur
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);	//d�clenche la fonciton lors de l'ajout sur la sc�ne
		}
		public function urlPhoto():String
		{
			return urlImg;
		}
		//Fonction d�clench�e lors de l'ajout au stage
		private function addedToStage(evt:Event):void {
			tween = new Tween(prop, "tween", Regular.easeInOut, 0, 1, .5,true);	//Tween affichant l'arriv�e du carr� blanc, avant le chargement
			tween.addEventListener(TweenEvent.MOTION_CHANGE, showRect);			//anmation du carr� par el Tween
			if (name=="photo0") {												//s'il s'agit de la premi�re photo ...
				tween.addEventListener(TweenEvent.MOTION_FINISH, load);			//...ajoute un �couteur de fin d'animation (pour lancer automatiquement le chargement)
			}
		}
		
		//Fonction de chargement de l'image donn�e
		public function load(evt:TweenEvent=null):void {
			loader = new Loader();														//cr�ation du loader
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );	//ajout de l'�v�nement de fin de chargement)
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			loader.load(new URLRequest(urlImg));										//lance le chargement de l'image
		}
		
		//Fonction d�clench�e lors du chargement complet de l'image
		private function loadComplete(evt:Event):void {
			//gestion et affichage de l'image charg�e
			var bmpDt:BitmapData = evt.currentTarget.content.bitmapData;	//clonage de l'image charg�e
			bmp = new Bitmap(bmpDt);													//cr�ation de l'image miniature
			ref = new Bitmap(bmpDt);													//cr�ation de l'image du reflet
			photo = new Sprite();
			bmp.smoothing = ref.smoothing = true;										//lissage des deux images
			scaleT = Math.min(size.w/bmp.width, size.h/bmp.height);						//d�termination de l'�chelle en fonction des donn�es du XML et de l'image
			scaleT = rectifScaleT(scaleT);												//rectification de l'�chelle en fonction du mode de miniature choisis
			bmp.scaleX = bmp.scaleY = ref.scaleX = -(ref.scaleY = -scaleT);				//mise � l'�chelle des deux images (scaleY n�gatif pour retourner le reflet)
			bmp.x = ref.x = -bmp.width/2;												//placement des images en X ...
			bmp.y = -(ref.y = bmp.height+2);											//... puis en Y
			bmp.alpha = ref.alpha = 0;													//images en transparence compl�te
			//ajout du masque
			msk = new Shape();																	//cr�ation du shape de Masque (pour la transparence du reflet)
			mat.createGradientBox(256, size.h, Math.PI/2,-2);									//modification de la matrice pour le d�grad�
			msk.graphics.beginGradientFill("linear", [0xFFFFFF,0xFFFFFF], [1,0], [0,92], mat);	//cr�ation du d�grad�
			msk.graphics.drawRect(-ref.width/2, 2, ref.width, ref.height);								//dessin du d�grad�
			//affichage et mise en masque du reflet
			ref.cacheAsBitmap = msk.cacheAsBitmap = true;								//indispensable pour l'effet de masque � d�grad� transparent
			addChild(msk);																//affichage du shape de masque
			addChild(ref);																//affichage de l'image de reflet
			photo.addChild(bmp);														//ajout de l'image au Sprite contener
			addChild(photo);															//affichage de l'image principale
			ref.mask = msk;																//masquage du reflet par le shape
			//Animation d'apparition de l'image et de modification de la taille du carr�
			tween = new Tween(prop, "tween", Regular.easeInOut, 1, 0, .5, true);
			tween.addEventListener(TweenEvent.MOTION_CHANGE, resizeRect);
			tween.addEventListener(TweenEvent.MOTION_FINISH, resizeEnd);
			//Suite de l'�v�nement
			dispatchEvent(new Event(Event.COMPLETE));									//renvoie l'�v�nement comme quoi l'image est bien charg�e
			//D�termination de l'�chelle en plein �cran
			//scaleV = Math.min((stage.stageWidth-16)/bmpDt.width, (stage.stageHeight-16)/bmpDt.height);	//Echelle de base
			scaleV = Math.min((900-16)/bmpDt.width, (350-16)/bmpDt.height);	//Echelle de base
			scaleV = rectifScaleV(scaleV);													//Rectification de l'�chelle en fonction du mode d'affichage choisis
		}
		
		//Fonction d�clench�e � la fin de l'apparition de l'image
		private function endImg(evt:TweenEvent):void {
			graphics.clear(); 										//Efface le carr� de fond
			photo.buttonMode = true;								//Affiche la main lors du passage de la souris
			photo.addEventListener(MouseEvent.CLICK, mouseThumb);	//Ajoute l'�couteur de clic � la souris sur la photo
		}
		
		/*-- Fonctions d'interaction � la souris --*/
		
		//Fonction d�clench�e lors du clic sur la miniature
		private function mouseThumb(evt:MouseEvent):void {
			//photo.removeEventListener(MouseEvent.CLICK, mouseThumb);	//Retire l'�v�nement de souris
			//photo.buttonMode = false;									//Retire le comportement de Bouton
			dispatchEvent(new Event("MouseThumb"));						//Lance l'�v�nement vers la base
			depMtx = this.transform.matrix3D;							//stocke les infos de 3D de la photo pour l'y remettre plus tard
			/* tween = new Tween(prop, "tween", Regular.easeInOut, 0, 1, .5, true);	//Tween d'animation pour le passage en plein �cran de la photo
			tween.addEventListener(TweenEvent.MOTION_CHANGE, viewImg);				//Ev�nement en cours d'animation
			tween.addEventListener(TweenEvent.MOTION_FINISH, viewEnd); */				//Ev�nement en fin d'animation
			//photo = null;
			//graphics.clear();
		}
		
		//Fonction d�clench�e lors du clic sur la photo pleine page
		 private function mouseView(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.CLICK, mouseView)					//Enl�ve l'�v�nement de souris pour le retour au mode miniature
			dispatchEvent(new Event("MouseView"));									//Lance l'�v�nement d�clenchant le d�floutage des photos
			tween = new Tween(prop, "tween", Regular.easeInOut, 1, 0, .5, true);	//Tween d'animation pour le retour en miniature de la photo
			tween.addEventListener(TweenEvent.MOTION_CHANGE, viewImg);				//Ev�nement en cours d'animation
			tween.addEventListener(TweenEvent.MOTION_FINISH, thumbEnd);				//Ev�nement en fin d'animation
		} 
		
		//Fonction appliquant graduellement un Blur sur tout l'objet
		public function blurIn():void {
			photo.removeEventListener(MouseEvent.CLICK, mouseThumb);					//Retire l'�v�nement de souris
			photo.buttonMode = false;													//Retire le comportement de Bouton
			blurTween = new Tween(prop, "blur", None.easeNone, prop.blur, blurT, .5, true);//Tween de flou
			blurTween.addEventListener(TweenEvent.MOTION_CHANGE, blurInOut);			//Ev�nement d'animation de flou
		}
		
		//Fonction retirant graduellement le Blur sur tout l'objet
		public function blurOut():void {
			blurTween = new Tween(prop, "blur", None.easeNone, prop.blur, 0, .5, true);	//tween de d�floutage
			blurTween.addEventListener(TweenEvent.MOTION_CHANGE, blurInOut);			//Ev�nement d'animation de d�floutage
			blurTween.addEventListener(TweenEvent.MOTION_FINISH, blurEnd);				//Ev�nement de fin de d�floutage
		}
		
		//Fonction d�clench�e � la fin du "d�floutage"
		private function blurEnd(evt:TweenEvent):void {
			photo.addEventListener(MouseEvent.CLICK, mouseThumb);	//Ajoute l'�v�nement de souris
			photo.buttonMode = true;								//Ajoute le comportement de Bouton
		}
		
		/*-- Fonction d'animations control�es par les Tweens --*/
		
		//fonction dessinant le carr� blanc lors de l'apparition
		private function showRect(evt:TweenEvent):void {
			prop.w = size.w*prop.tween;												//Largeur proportionnelle au tween
			prop.h = size.h*prop.tween;												//Hauteur proportionnelle au tween
			graphics.clear();														//Efface le carr� pr�c�dent
			graphics.beginFill(0xFFFFFF, 1);										//Commence le remplissage
			graphics.drawRect(-prop.w/2, (-(size.h+prop.h)/2)-2, prop.w, prop.h);	//Dessin du carr� de base
			drawRef((size.h-prop.h)/2)												//Reflet sur le sol
		}
		
		//Fonction modifiant la taille du carr� et faisant appara�tre l'image en transparence
		private function resizeRect(evt:TweenEvent):void { 
			prop.w = bmp.width+((size.w-bmp.width)*prop.tween);			//Largeur proportionnelle au tween
			prop.h = bmp.height+((size.h-bmp.height)*prop.tween);		//Hauteur proportionnelle au tween
			graphics.clear();											//Efface le carr� pr�c�dent
			graphics.beginFill(0xFFFFFF, 1);							//Commence le remplissage
			graphics.drawRect(-prop.w/2, -(prop.h+2), prop.w, prop.h);	//Dessin du carr� de base
			drawRef(0,1);												//Reflet sur le sol
		}
		
		//Fonction d�clench�e � la fin du resize
		private function resizeEnd(evt:TweenEvent):void {
			tween = new Tween(prop, "tween", None.easeNone, 0, 1, 1, true);	//Tween qui va modifier l'alpha de l'image et du reflet
			tween.addEventListener(TweenEvent.MOTION_CHANGE, showImg);		//Ev�nement en cours d'animation
			tween.addEventListener(TweenEvent.MOTION_FINISH, endImg);		//Ev�nement en fin d'animation
		}
		
		//Fonction modifiant l'alpha de l'image et de son reflet
		private function showImg(evt:TweenEvent):void {
			bmp.alpha = prop.tween;										//alpha de la photo
			ref.alpha = prop.tween/2;									//alpha du reflet
			// dessin du carr� de base + reflet
			graphics.clear();											//Efface le carr� pr�c�dent
			graphics.beginFill(0xFFFFFF, 1);							//Commence le remplissage
			graphics.drawRect(-prop.w/2, -(prop.h+2), prop.w, prop.h);	//Dessin du carr� de base
			drawRef(0,1-prop.tween);									//Reflet sur le sol
		}
		
		//Fonction dessinant le reflet blanc au sol
		private function drawRef(nb:Number=0, transp:Number=1):void {
			mat.createGradientBox(size.w, size.h, Math.PI/2, 0, -nb);							//Matrice de d�grad�
			graphics.beginGradientFill("linear", [0xFFFFFF,0xFFFFFF], [transp,0], [0,92], mat);	//Demplissage en d�grad�
			graphics.drawRect(-prop.w/2, nb+2, prop.w, prop.h);									//Dessin du d�grad�
		}
		
		//Fonction pilot�e par le Tween et mettant le flou sur les images
		private function blurInOut(evt:TweenEvent):void {
			filters = [new BlurFilter(int(prop.blur),int(prop.blur),1)];
		}
		
		//Fonction d�pla�ant la photo entre miniature et plein �cran
		private function viewImg(evt:TweenEvent):void {
			var mtx:Matrix3D = Matrix3D.interpolate(depMtx, arrMtx, prop.tween);							//Interpolation entre ma Matrice 3D de d�part et d'arriv�e
			this.transform.matrix3D = mtx;																	//application de la matrice sur la photo
			bmp.scaleX = bmp.scaleY = ref.scaleX = -(ref.scaleY = -(scaleT+((scaleV-scaleT)*prop.tween)));	//Modification du scale de la photo et du reflet
			msk.width = ref.width;																			//modification de la largeur du masque
			bmp.x = ref.x = -bmp.width/2;																	//centrage en x de la photo et du reflet
			bmp.y = (-4*(1-prop.tween))-(bmp.height/(1+prop.tween));										//centrage en Y de la Photo
			ref.y = 4+ref.height+(prop.tween*(ref.height*4));												//centrage en y du reflet
			ref.alpha = .5-(prop.tween/2);																	//modification de l'alpha du reflet
			ref.filters = [new BlurFilter(int(blurT*prop.tween), int(blurT*prop.tween), 1)];				//Cr�ation du filtre flou sur le reflet
			//modification de la luminosit� de la photo 
			var lightCoeff:Number = -((this.z+XMLManager.radius)/(2*XMLManager.radius))*XMLManager.dark;	//d�finis le coefficient de lumi�re en fonction du Z de la photo
			this.transform.colorTransform = new ColorTransform(1,1,1,1,lightCoeff,lightCoeff,lightCoeff,0); //Applique la luminosit� � la photo
			dispatchEvent(new Event("SortZ"));
		}
		
		//Fonction d�clench�e lors de la fin du Tween de l'image miniature => �cran
		private function viewEnd(evt:TweenEvent):void {
			stage.addEventListener(MouseEvent.CLICK, mouseView);	//Ajoute l'�v�nement de retour au mode Miniature
		}
		
		///Fonction d�clench�e lors de la fin du Tween de l'image Ecran => miniature
		private function thumbEnd(evt:TweenEvent):void {
			photo.buttonMode = true;								//remise en place du mode Boutton sur la photo
			photo.addEventListener(MouseEvent.CLICK, mouseThumb);	//�v�nement de passage en plein �cran
			dispatchEvent(new Event("ViewEnd"));					//�v�nement de fin relan�ant la rotation
		}
		
		/*-- Fonctions g�n�rales --*/
		
		//Fonction rectifiant l'�chelle des miniatures en fonction du mode de miniatures choisis dans le XML
		private function rectifScaleT(scale:Number):Number {
			switch (XMLManager.thumbType) {
				case "noScale" : scale = 1; break;					//taille exacte de l'image
				case "reScale" : if (scale>1) { scale=1; } break;	//r�duction de l'image si trop grand, garde les images plus petites � l'�chelle 1
				case "fullScale" : 									//agrandissement des petits et r�duction des grands (pas de rectifications)
			}
			return scale
		}
		
		//Fonction renvoyant l'�chelle de l'image en plein �cran
		private function rectifScaleV(scale:Number):Number {
			switch (XMLManager.viewType) {
				case "noResize" : scale = 1; break;					//taille exacte de l'image
				case "reduce" : if (scale>1) { scale=1; } break;	//r�duction de l'image si trop grand, garde les images plus petites � l'�chelle 1
				case "fullView" : 									//agrandissement des petits et r�duction des grands (pas de rectifications)
			}
			return scale
		}
		public function ioErrorHandler( event:IOErrorEvent ):void
		{
			trace(  "PhotoDisp, an IO Error has occured: " + event.text );
		} 
		public function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			trace(  "PhotoDisp, securityErrorHandler: " + event.text );
		}
	
	}
	
}