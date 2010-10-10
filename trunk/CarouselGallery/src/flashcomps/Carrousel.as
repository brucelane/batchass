/*-- Classe faisant tourner les images en mode carrousel --*/

package flashcomps {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public final class Carrousel extends Sprite {
		
		private var imgTab:Vector.<PhotoDisp>;	//Tableau contenant les Sprites des images
		private var radius:Number;				//Rayon du cercle
		private var selected:PhotoDisp;			//Photo selectionnée (pour tri en Z)
		
		public function Carrousel(data:Vector.<PhotoDisp>):void {
			imgTab = data.slice();									//duplique le Tableau des images
			radius = XMLManager.radius;								//Rayon récupéré du XML
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);	//lors de l'ajout sur la scène
		}
		public function nettoieCarrousel():void
		{
			removeEventListener(Event.ENTER_FRAME, rotate); //Retire l'évènement de rotation général 
			for (var i:int=0; i<imgTab.length; i++) {	
				var targ:PhotoDisp = imgTab[i];	
				targ.addEventListener("ViewEnd", launchRot);	//Evènement de fin, relançant la rotation lors du retour en mode miniature
				targ.addEventListener("SortZ", sortPhoto);		//Evènement de tri en Z lors du retour de la photo
				removeChild(targ);		
				targ.graphics.clear();
				targ = null;							 
			}
			imgTab = null;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}		
		//Fonction déclenchée lors de l'ajout sur la scène
		private function addedToStage(evt:Event):void {
			var angBase:Number = (Math.PI*2)/imgTab.length;	//degrés entre chaques images du carrousel
			for (var i:int=0; i<imgTab.length; i++) {	//Cycle sur chacune des images contenues dans le Tableau
				var targ:PhotoDisp = imgTab[i];			//Cible l'image en cours
				addChild(targ);							//Ajoute l'image au carrousel 
				var mtx:Matrix3D = new Matrix3D;		//Matrice 3D servant au déplacement premier
				mtx.appendRotation(-i*(360/imgTab.length)-90, Vector3D.Y_AXIS);		//oriente la photo dans la direction voulue
				mtx.appendTranslation(Math.cos(i*angBase)*radius, (stage.stageHeight/2+100), Math.sin(i*angBase)*radius);//place la photo sur son point dans le cercle
				//mtx.appendTranslation(Math.cos(i*angBase)*radius, (stage.stageHeight/2-32), Math.sin(i*angBase)*radius);//place la photo sur son point dans le cercle
				targ.transform.matrix3D = mtx;			//application de la matrice sur la photo
			}
			launchRot();								//lance la rotation du carrousel
		}
		
		private function rotate(evt:Event):void {
			//var rotAdd:Number = mouseX/(stage.stageWidth/2);							//Récupère l'emplacment de la souris et ressort un chiffre entre (-1 et 1)
			var rotAdd:Number = mouseX/1000;											//Récupère l'emplacment de la souris et ressort un chiffre entre (-1 et 1)
			var mtx:Matrix3D = new Matrix3D();											//Matrice 3D permettant la rotation de l'ensemble
			mtx.appendRotation(rotAdd, Vector3D.Y_AXIS);								//Applique la rotation à la matrice 3D
			for each(var photo:PhotoDisp in imgTab) {									//Cycle sur toutes les photos présentes
				//Modification de la rotation de la photo
				var photoMtx:Matrix3D = photo.transform.matrix3D						//récupère la matrice 3D actuelle de la photo
				photoMtx.append(mtx);													//applique la matrice 3d de rotation
				photo.transform.matrix3D = photoMtx;									//réapplique la matrice 3D à la photo
				//Modification de la luminosité de la photo
				var lightCoeff:Number = -((photo.z+radius)/(2*radius))*XMLManager.dark;	//définis le coefficient de lumière en fonction du Z de la photo
				photo.transform.colorTransform = new ColorTransform(1,1,1,1,lightCoeff,lightCoeff,lightCoeff,0); //Applique la luminosité à la photo
			}
			sortPhoto();
		}
		
		/*-- Fonctions d'interaction avec les images --*/
		
		//fonction déclenchée lors de l'appuie sur une des Miniature
		public function selectPhoto(targ:PhotoDisp):void {
			selected = targ;								//Stocke la photo selectionné pour comparaison en Z
			removeEventListener(Event.ENTER_FRAME, rotate); //Retire l'évènement de rotation général 
			setChildIndex(targ, imgTab.length-1)			//Place la photo selectionnée en premier plan
			for each (var item:PhotoDisp in imgTab) {		//Cycle sur chaque photo présente
				if (item!=targ) { item.blurIn(); }			//Si ce n'est pas la photo selectionnée, lance le flou
			}
		}
		
		//fonction déclenchée lors de l'appuie sur une des Miniature
		public function deselectPhoto(targ:PhotoDisp):void {
			targ.addEventListener("ViewEnd", launchRot);	//Evènement de fin, relançant la rotation lors du retour en mode miniature
			targ.addEventListener("SortZ", sortPhoto);		//Evènement de tri en Z lors du retour de la photo
			for each (var item:PhotoDisp in imgTab) {		//cycle sur chque photo
				if (item!=targ) { item.blurOut(); }			//Si ce n'est pas la photo selectionnée, enlève le flou
			}
		}
		
		//fonction déclenchée lors du retour de l'image en mode miniature
		private function launchRot(evt:Event=null):void {
			selected = null;												//Efface l'indice de photo selectionnée
			if(evt!=null) {													//Si la fonction est déclenchée par un évènement (retour de la photo en miniature)
				evt.currentTarget.removeEventListener("SortZ", sortPhoto);	//détruit l'évènement de tri en Z des photos
			}
			addEventListener(Event.ENTER_FRAME, rotate);					//lance la rotation des photos
		}
		
		/*-- Fonctions de tri en Z des images lors de la rotation --*/
		
		//fonction lançant le tri des photos en Z
		private function sortPhoto(evt:Event=null):void {
			sortZ(imgTab);
		}
		
		//Fonction de tri en Z
		private function sortZ(tab:Vector.<PhotoDisp>):void {
			tab.sort(depthZ);							//tri de la table des photos en fonction de leur Z
			var i:int = tab.length;						//variable à décrémenter
			while (i--) {								//cycle sur toutes les photos
				setChildIndex(tab[i], tab.length-1);	//place l'image en premier plan
			}
		}
		
		//Fonction de comparaison de Z pour le tri en Z
		private function depthZ( item1:PhotoDisp, item2:PhotoDisp ):Number {
			var result:Number;
			switch(selected) {
				case item1 : result = (item1.z+((item1.z-radius)*2)) - item2.z; break;
				case item2 : result = item1.z - (item2.z+((item2.z-radius)*2)); break; 
				default : result = item1.z - item2.z;
			}
			return result;
		}

		
	}

}