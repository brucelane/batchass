
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
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	
	[SWF (width="850",height="340", backgroundColor="0x000000", frameRate="30")]	
	public class WallGallery extends BasicView
	{
		
		public var planes : Array; 
		
		public var planeCols : int = 5; 	
		public var planeRows : int = 4; 
		public var rows : int = 0;
		public var cols : int = 0;	
		public var gridWidth : Number = 850;
		public var gridHeight : Number = 340; 
		
		private var loader:Loader;
		private var xmlFile:String;
		private var counter:int = 0;			
		private var selectedImage:String;
		private var spr:Sprite;
		private var defZoomedInCameraZ:int = -150;
		private var targetCameraZ:int = -500;
		private var currentCameraZ:int = -500;
		private var targetCameraX:int = 0;
		private var targetCameraY:int = 0;
		private var currentCameraX:int = 0;
		private var currentCameraY:int = 0;
		private var cameraIncrement:int = 10;
		private var zoomedIn:Boolean = false;
		private var planeId:int = -1;

		public function WallGallery( sourceXmlFile:String = "data.xml")
		{
			xmlFile = sourceXmlFile;
			loader = new Loader ( ) ;
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoaded ) ;
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			super(850,340,false,true, CameraType.FREE); 
			
			camera.z = currentCameraZ; 
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
			for (var i:int=0; i<XMLManager.imgs; i++) 
			{	
				var plane : SpringyPlaneMovieClip;
				plane = new SpringyPlaneMovieClip( XMLManager.thumbSize.w * 0.35, XMLManager.thumbSize.h * 0.35,  XMLManager.getURL(i) ); 
					
				plane.x = gridWidth * ( ( cols + 0.5 ) / planeCols) - ( gridWidth / 2 ); 
				plane.y = gridHeight * ( ( rows + 0.5 ) / planeRows) - ( gridHeight / 2 ); 
				plane.z = 4000;
				planes.push(plane);  
				
				scene.addChild(plane); 
				plane.addEventListener( InteractiveScene3DEvent.OBJECT_CLICK, planeClick );
				plane.addEventListener( InteractiveScene3DEvent.OBJECT_OVER, planeOver );
				plane.addEventListener( InteractiveScene3DEvent.OBJECT_OUT, planeOut );				
				if ( rows++ >= planeRows - 1 ) 
				{
					rows = 0;
					cols++;
				}
			}
		}
		public function planeOver( e:InteractiveScene3DEvent ):void
		{
			var selectedPlane:SpringyPlaneMovieClip = e.displayObject3D as SpringyPlaneMovieClip;
			if ( !zoomedIn )
			{
				targetCameraX = viewport.containerSprite.mouseX*1;
				targetCameraY = 0;
			}
		}
		public function planeOut( e:InteractiveScene3DEvent ):void
		{
			trace("mouse out");
		}
		public function planeClick( e:InteractiveScene3DEvent ):void
		{
			var selectedPlane:SpringyPlaneMovieClip = e.displayObject3D as SpringyPlaneMovieClip;
			targetCameraX = selectedPlane.x; 
			targetCameraY = selectedPlane.y; 
			camera.rotationY = 0;
			if ( ( planeId != selectedPlane.id ) && zoomedIn )
			{
				planeId = selectedPlane.id;
				currentCameraZ += -20;
			
				targetCameraZ = defZoomedInCameraZ;
			}
			else
			{
				if ( targetCameraZ == -500 ) targetCameraZ = defZoomedInCameraZ else targetCameraZ = -500;
			}
			
			trace("selectedPlane:"+selectedPlane.id);
		}		
		public function enterFrame(e:Event) : void
		{
			//trace("currentCameraZ:"+currentCameraZ+" targetCameraZ:"+targetCameraZ);
			if ( currentCameraZ < targetCameraZ )
			{
				// zoom in on selected plane
				currentCameraZ += cameraIncrement;
				camera.z = currentCameraZ;
				zoomedIn = true;
			}
			else
			{
				if ( currentCameraZ == targetCameraZ )
				{
				}
				else
				{
					// zoom out off selected plane
					currentCameraZ -= cameraIncrement;
					camera.z = currentCameraZ;
					zoomedIn = false;
				}
			}
			if ( zoomedIn )
			{
				// zoomed in
				if ( currentCameraX - targetCameraX <= cameraIncrement ) currentCameraX = targetCameraX;
				if ( currentCameraY - targetCameraY <= cameraIncrement ) currentCameraY = targetCameraY;
				if ( currentCameraX > targetCameraX) currentCameraX -= cameraIncrement else if ( currentCameraX != targetCameraX) currentCameraX += cameraIncrement;
				if ( currentCameraY > targetCameraY) currentCameraY -= cameraIncrement else if ( currentCameraY != targetCameraY) currentCameraY += cameraIncrement;
				
				camera.x = currentCameraX;
				camera.y = currentCameraY;
			
			}
			else
			{
				// zoomed out
				targetCameraX = viewport.containerSprite.mouseX*1;
				targetCameraY = 0;
				if ( currentCameraX - targetCameraX <= cameraIncrement ) currentCameraX = targetCameraX;
				if ( currentCameraY - targetCameraY <= cameraIncrement ) currentCameraY = targetCameraY;
				if ( currentCameraX > targetCameraX) currentCameraX -= cameraIncrement else if ( currentCameraX != targetCameraX) currentCameraX += cameraIncrement;
				if ( currentCameraY > targetCameraY) currentCameraY -= cameraIncrement else if ( currentCameraY != targetCameraY) currentCameraY += cameraIncrement;
				
				
				camera.x = currentCameraX; 
				camera.y = currentCameraY; 
				camera.rotationY = viewport.containerSprite.mouseX* -0.06; 
				updatePlanes(viewport.containerSprite.mouseX, -viewport.containerSprite.mouseY); 		
			}	
			
			
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
			trace( "WallGallery, an IO Error has occured: " + event.text );
		} 
		public function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			trace( "WallGallery, securityErrorHandler: " + event.text );
		}

	}
	
}
