package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	
	import flashcomps.Carrousel;
	import flashcomps.PhotoDisp;
	import flashcomps.XMLManager;
		
	[SWF(width="600", height="800", backgroundColor="#090909", frameRate='25')]
	public class CarouselGallery extends Sprite
	{
		private var container:Sprite;
		private var imgTab:Vector.<PhotoDisp>;	//Tableau contenant les Sprites des images
		private var carrousel:Carrousel;		//Carrousel qui va contenir et faire tourner les images
		private var counter:int = 0;			//Compteur servant à charger les images une par une
		private var selectedImage:String;
		private var loader:Loader;
		private var spr:Sprite;
		private var xmlFile:String;

		public function CarouselGallery( sourceXmlFile:String = "data.xml")
		{
			xmlFile = sourceXmlFile;
			loader = new Loader ( ) ;
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoaded ) ;
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			container = new Sprite();
			container.x = 0;
			container.y = 0;
			container.z = 500;
			spr = new Sprite();
			addChild(spr);
			addChild( container );
			var xmlParam:String = root.loaderInfo.parameters.xmlfile;
			if ( xmlParam ) xmlFile = xmlParam;
			loadXML( xmlFile ); 
		}
		public function loadXML(urlXml:String):void
		{
			XMLManager.load(urlXml);												//Lance le chargement du XML
			XMLManager.loader.addEventListener( Event.COMPLETE, loadComplete );	//Déclenché la fonction lors de la fin du chargement
			XMLManager.loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			XMLManager.loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		}
		private function loadComplete(evt:Event):void 
		{
			imgTab = new Vector.<PhotoDisp>();										//Crée le Vector qui va contenir les images
			for (var i:int=0; i<XMLManager.imgs; i++) 
			{								//Boucle sur toutes les photos présentes
				var photoTmp:PhotoDisp = new PhotoDisp(XMLManager.getURL(i));		//Crée un objet PhotoDisp (voir classe PhotoDisp)
				photoTmp.name = "photo"+i;											//Donne un nom à la photo
				imgTab.push(photoTmp);												//Stoque la photo dans le tableau
				if (i==0) 
				{ 
					photoTmp.addEventListener(Event.COMPLETE, imgLoader); //Si la photo est la première, écoute si l'image est finie de charger
				}	
			}
			carrousel = new Carrousel(imgTab); 				//Crée le carrousel avec les images ainsi crées
			carrousel.x = stage.stageWidth/2;				//place le carrousel au centre de la scène en X
			carrousel.y = XMLManager.y;				//place le carrousel au centre de la scène en Y
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
		private function onImageLoaded( evt:Event ):void
		{
			if (evt) 
			{
				var _bData:Bitmap = evt.target.content as Bitmap;
				spr.graphics.clear();
				spr.graphics.beginBitmapFill(_bData.bitmapData);
				spr.graphics.drawRect(0, 0, _bData.width, _bData.height);
				spr.graphics.endFill();
				spr.x = stage.stageWidth/2 - _bData.width/2;	
				spr.y = 5;
			}
		}		
		//Fonction déclenchée lors du clic sur une Miniature
		private function showPhoto(evt:Event):void {
			selectedImage = (evt.currentTarget as PhotoDisp).urlPhoto();
			trace(selectedImage);
			//navigateToURL( new URLRequest( selectedImage ), '_new' ); 
			var tEvent:TextEvent = new TextEvent("imageSelect");
			tEvent.text = selectedImage;
			dispatchEvent(tEvent);
			var eventObj:TextEvent = new TextEvent( "LINK");
			eventObj.text = selectedImage;
			dispatchEvent(eventObj);
			
			loader.load( new URLRequest(selectedImage) ) ;

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
			trace("hidePhoto");
			//carrousel.deselectPhoto(evt.currentTarget as PhotoDisp);	//Lance la sélection de la photo dans le carrousel
		}
	
		
		public function ioErrorHandler( event:IOErrorEvent ):void
		{
			trace( "Carousel, an IO Error has occured: " + event.text );
		} 
		public function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			trace( "Carousel, securityErrorHandler: " + event.text );
		}
	}
}