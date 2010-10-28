// Author : Seb Lee-Delisle
// Blog : sebleedelisle.com

package {
	import components.XMLManager;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.view.BasicView;
	
	[SWF (width="800",height="480", backgroundColor="0x000000", frameRate="30")]
	
	public class WallGallery extends BasicView
	{
		
		public var planes : Array; 
		
		public var planeCols : int = 7; 	
		public var planeRows : int = 4; 
		
		public var gridWidth : Number = 1000;
		public var gridHeight : Number = 400; 
		
		private var loader:Loader;
		private var xmlFile:String;
		
		public function WallGallery( sourceXmlFile:String = "data.xml")
		{
			xmlFile = sourceXmlFile;
			loader = new Loader ( ) ;
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoaded ) ;
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			super(800,480,false,true, CameraType.FREE); 
			
			camera.z = -500; 
			planes = new Array(); 
			
			loadXML( xmlFile ); 
			
			//makePlanes(); 
			
			//reflectionview: surfaceHeight = -400; 
			
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
			imgTab = new Vector.<PhotoDisp>();							
			for (var i:int=0; i<XMLManager.imgs; i++) 
			{								
				var photoTmp:PhotoDisp = new PhotoDisp(XMLManager.getURL(i));		
				photoTmp.name = "photo"+i;											
				imgTab.push(photoTmp);		
				if (i==0) 
				{ 
					photoTmp.addEventListener(Event.COMPLETE, imgLoader); 
				}	
			}
			carrousel = new Carrousel(imgTab); 				
			carrousel.x = stage.stageWidth/2;				
			carrousel.y = 100;				
			carrousel.z = XMLManager.radius;
			addChild(carrousel);
		}
		
		public function makePlanes() : void
		{
			
			var plane : SpringyPlaneMovieClip; 
			
			var counter : int = 0; 
			
			var allPhotos : AllPhotos = new AllPhotos(); 
			
			for(var rows : int = 0; rows<planeRows ; rows++)
			{
				for(var cols : int = 0; cols<planeCols; cols++)
				{
					
					var texture : DisplayObject = allPhotos.getChildAt(counter);
					
					plane = new SpringyPlaneMovieClip(texture.width*0.35, texture.height*0.35, texture); 
					
					counter++; 
					
					plane.x = gridWidth * ((cols+0.5)/planeCols) - (gridWidth/2); 
					plane.y = gridHeight * ((rows+0.5)/planeRows) - (gridHeight/2); 
					
					planes.push(plane);  
					
					scene.addChild(plane); 
				}	
				
			}
			
			
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
				/*var _bData:Bitmap = evt.target.content as Bitmap;
				spr.graphics.clear();
				spr.graphics.beginBitmapFill(_bData.bitmapData);
				spr.graphics.drawRect(0, 0, _bData.width, _bData.height);
				spr.graphics.endFill();
				spr.x = stage.stageWidth/2 - _bData.width/2;	
				spr.y = 5;*/
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
