
// based on code from:
// Author : Seb Lee-Delisle
// Blog : sebleedelisle.com

package 
{
	import components.XMLManager;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	
	[SWF (width="800",height="480", backgroundColor="0x000000", frameRate="30")]
	
	public class WallGallery extends BasicView
	{
		
		public var planes : Array; 
		
		public var planeCols : int = 5; 	
		public var planeRows : int = 4; 
		public var rows : int = 0;
		public var cols : int = 0;	
		public var gridWidth : Number = 1000;
		public var gridHeight : Number = 400; 
		
		private var loader:Loader;
		private var xmlFile:String;
		private var counter:int = 0;			
		private var selectedImage:String;
		private var spr:Sprite;
		private var picPlane:Plane;
		
		public const PLANE_CHANGED:String = "planeChanged";

		public function WallGallery( photoPlane:Plane, sourceXmlFile:String = "data.xml")
		{
			picPlane = photoPlane;
			xmlFile = sourceXmlFile;
			loader = new Loader ( ) ;
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoaded ) ;
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			super(800,480,false,true, CameraType.FREE); 
			
			camera.z = -500; 
			planes = new Array(); 
			
			loadXML( xmlFile ); 
		
			addEventListener(Event.ENTER_FRAME, enterFrame); 
		}
		public function loadXML(urlXml:String):void
		{
			XMLManager.load(urlXml);												
			XMLManager.loader.addEventListener( Event.COMPLETE, loadComplete );	
			XMLManager.loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			XMLManager.loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		}
		private function loadComplete(evt:Event):void 
		{
			//imgTab = new Vector.<PhotoDisp>();							
			for (var i:int=0; i<XMLManager.imgs; i++) 
			{	
				var plane : SpringyPlaneMovieClip;
				//plane = new SpringyPlaneMovieClip(texture.width*0.35, texture.height*0.35,  XMLManager.getURL(i) ); 
				plane = new SpringyPlaneMovieClip( XMLManager.thumbSize.w * 0.35, XMLManager.thumbSize.h * 0.35,  XMLManager.getURL(i), picPlane ); 
					
				plane.x = gridWidth * ( ( cols + 0.5 ) / planeCols) - ( gridWidth / 2 ); 
				plane.y = gridHeight * ( ( rows + 0.5 ) / planeRows) - ( gridHeight / 2 ); 
				plane.z = 4000;
				plane.addEventListener( SpringyPlaneMovieClip.PLANE_CHANGE, planeChanged );
				//plane.useOwnContainer = true;
				
				planes.push(plane);  
				
				scene.addChild(plane); 

				
				if ( rows++ >= planeRows - 1 ) 
				{
					rows = 0;
					cols++;
				}
			}
		}
		private function planeChanged( evt:TextEvent ):void
		{
			trace("gall plane chg" + evt.text);
			//picPlane.
			var tEvent:TextEvent = new TextEvent( PLANE_CHANGED );
			tEvent.text = evt.text;
			dispatchEvent(tEvent);
		}
		/*private function imgLoader(evt:Event):void 
		{
			
			counter++;
			evt.currentTarget.addEventListener("MouseThumb", showPhoto);		//Ajoute l'écouteur de clic à la souris
			evt.currentTarget.addEventListener("MouseView", hidePhoto);			//Ajoute l'écouteur de clic à la souris
			evt.currentTarget.removeEventListener(Event.COMPLETE, imgLoader);	//Détruit l'écouteur d'évènement
			if (counter<imgTab.length) {										//S'il reste des images à charger
				imgTab[counter].load();											//Lance le chargement de l'image suivante
				imgTab[counter].addEventListener(Event.COMPLETE, imgLoader);	//ajoute l'écouteur de fin de chargement
			}
			
		}*/
		//Fonction déclenchée lors du clic sur une Miniature
		private function showPhoto(evt:Event):void {
			//selectedImage = (evt.currentTarget as PhotoDisp).urlPhoto();
			trace(selectedImage);			
			loader.load( new URLRequest(selectedImage) ) ;
		}
		
		//Fonction déclenchée lors du clic sur une Photo plein écran
		private function hidePhoto(evt:Event):void {
			trace("hidePhoto");
			//carrousel.deselectPhoto(evt.currentTarget as PhotoDisp);	//Lance la sélection de la photo dans le carrousel
		}		
		
		public function enterFrame(e:Event) : void
		{
			
			camera.x = viewport.containerSprite.mouseX*1; 
			camera.rotationY = viewport.containerSprite.mouseX* -0.06; 
			
			updatePlanes(viewport.containerSprite.mouseX, -viewport.containerSprite.mouseY); 
			
			singleRender(); 
		}
		
		public function updatePlanes(mousex:Number, mousey:Number) : void
		{
			
			mousex*=1.4; 
			mousey*=1.4; 
			
			for(var i:int = 0; i<planes.length; i++)
			{
				var plane:SpringyPlaneMovieClip = planes[i] as SpringyPlaneMovieClip; 
				plane.update(mousex, mousey); 
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
