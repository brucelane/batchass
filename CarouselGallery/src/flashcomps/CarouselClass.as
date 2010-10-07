package flashcomps
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	
	import mx.flash.UIMovieClip;
	
	[Event(name="imageSelect", type="flash.events.TextEvent")]

	public class CarouselClass extends UIMovieClip
	{
		private var container:Sprite;
		private var loader:URLLoader;
		private var anglePer:Number;
		private var isRotating:Boolean = true;
		private var lastMouseX:Number;
		private var selectedImage:String;
				
		private var imgTab:Vector.<PhotoDisp>;	//Tableau contenant les Sprites des images
		private var carrousel:Carrousel;		//Carrousel qui va contenir et faire tourner les images
		private var counter:int = 0;			//Compteur servant à charger les images une par une
	
		public function CarouselClass()
		{
			super();
			//trace("CarouselClass");
			init();
		}
		//Fonction déclenchée après le chargement du XML
		private function loadComplete(evt:Event):void {
			imgTab = new Vector.<PhotoDisp>();										//Crée le Vector qui va contenir les images
			for (var i:int=0; i<XMLManager.imgs; i++) {								//Boucle sur toutes les photos présentes
				var photoTmp:PhotoDisp = new PhotoDisp(XMLManager.getURL(i));		//Crée un objet PhotoDisp (voir classe PhotoDisp)
				photoTmp.name = "photo"+i;											//Donne un nom à la photo
				imgTab.push(photoTmp);												//Stoque la photo dans le tableau
				if (i==0) { photoTmp.addEventListener(Event.COMPLETE, imgLoader); }	//Si la photo est la première, écoute si l'image est finie de charger
			}
			carrousel = new Carrousel(imgTab); 				//Crée le carrousel avec les images ainsi crées
			carrousel.x = 450;								//place le carrousel au centre de la scène en X
			carrousel.y = 100;								//place le carrousel au centre de la scène en Y
			carrousel.z = XMLManager.radius;				//éloigne le carrousel de la scène, permettant de mettre les images à la tailel voulue en premier plan
			addChild(carrousel)
		}
		
		//Fonction déclenchée lors de la fin de chaque chargement d'image dans un contener (PhotoDisp)
		private function imgLoader(evt:Event):void {
			counter++;
			evt.currentTarget.addEventListener("MouseThumb", showPhoto);		//Ajoute l'écouteur de clic à la souris
			evt.currentTarget.addEventListener("MouseView", hidePhoto);			//Ajoute l'écouteur de clic à la souris
			evt.currentTarget.removeEventListener(Event.COMPLETE, imgLoader);	//Détruit l'écouteur d'évènement
			if (counter<imgTab.length) {										//S'il reste des images à charger
				imgTab[counter].load();											//Lance le chargement de l'image suivante
				imgTab[counter].addEventListener(Event.COMPLETE, imgLoader);	//ajoute l'écouteur de fin de chargement
			}
		}
		
		//Fonction déclenchée lors du clic sur une Miniature
		private function showPhoto(evt:Event):void {
			selectedImage = (evt.currentTarget as PhotoDisp).urlPhoto();
			//trace(selectedImage);
			var tEvent:TextEvent = new TextEvent("imageSelect");
			tEvent.text = selectedImage;
			dispatchEvent(tEvent);
			var eventObj:TextEvent = new TextEvent( "LINK");
			eventObj.text = selectedImage;
			dispatchEvent(eventObj);
			//Nettoyage
			/* carrousel.nettoieCarrousel();
			var lng:int = carrousel.numChildren;
			trace("numChildren"+numChildren);
			while ( lng-- ) 
			{ 
				carrousel.removeChildAt(lng);
			}
			container = null;  */
		}
		
		//Fonction déclenchée lors du clic sur une Photo plein écran
		private function hidePhoto(evt:Event):void {
			//carrousel.deselectPhoto(evt.currentTarget as PhotoDisp);	//Lance la sélection de la photo dans le carrousel
		}
		public function selection():String
		{
			return selectedImage;
		}

		public function loadXML(urlXml:String):void
		{
			XMLManager.load(urlXml);												//Lance le chargement du XML
			XMLManager.loader.addEventListener(Event.COMPLETE, loadComplete);	//Déclenché la fonction lors de la fin du chargement
		}

		private function init():void
		{
			container = new Sprite();
			container.x = 350;
			container.y = 250;
			container.z = 400;
			container.rotationX = 5;
			addChild(container);
		}
	}
}