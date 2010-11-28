
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
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.typography.Font3D;
	import org.papervision3d.typography.Text3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.stats.StatsView;
	
	[SWF (width="850",height="340", backgroundColor="0xFFFFFF", frameRate="30")]	
	public class WallGallery extends BasicView
	{
		
		public var planes : Array; 
		
		public var planeCols : int = 6; 	
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
		private var defZoomedOutCameraZ:int = -500;
		private var targetCameraZ:int = -500;
		private var currentCameraZ:int = -500;
		private var targetCameraX:int = 0;
		private var targetCameraY:int = 0;
		private var currentCameraX:int = 0;
		private var currentCameraY:int = 0;
		private var cameraIncrement:int = 10;
		private var planeId:int = -1;
		private var state:uint = 0;
		private const zoomedOut:uint = 0;
		private const zoomingIn:uint = 1;
		private const zoomedIn:uint = 2;
		private const zoomingOut:uint = 3;
		private var objectInfoTextField:TextField;
		private var txtFormat:TextFormat;

		public function WallGallery( sourceXmlFile:String = "data.xml")
		{
			super( 850, 340, false, true, CameraType.FREE ); 
			
			xmlFile = sourceXmlFile;
			loader = new Loader ( ) ;
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoaded ) ;
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			txtFormat = new TextFormat("Arial", 12, 0xFFFFFF, false, false, false);
			objectInfoTextField = new TextField();
			objectInfoTextField.y = 320;
			objectInfoTextField.autoSize = TextFieldAutoSize.LEFT;
			objectInfoTextField.defaultTextFormat = txtFormat;
			addChild(objectInfoTextField);
			objectInfoTextField.text = "adapted by Bruce LANE ( http://www.batchass.fr )";
			//addChild( new StatsView(renderer));
			
			camera.z = currentCameraZ; 
			planes = new Array(); 
			
			loadXML( xmlFile ); 
		
			addEventListener( Event.ENTER_FRAME, enterFrame ); 
			//addEventListener( MouseEvent.CLICK, mouseClick ); 
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
			//objectInfoTextField.text = "loadComplete:" + XMLManager.imgs;
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
				if ( rows++ >= planeRows - 1 ) 
				{
					rows = 0;
					cols++;
				}
			}
		}
		// when click on a plane
		public function planeClick( e:InteractiveScene3DEvent ):void
		{
			var selectedPlane:SpringyPlaneMovieClip = e.displayObject3D as SpringyPlaneMovieClip;
			trace("planeClick,state:"+state);
			switch ( state )
			{
				case zoomedOut:
				case zoomingOut:
					planeId = selectedPlane.id; trace("planeClick,zoomedOut");
					state = zoomingIn;
					targetCameraX = selectedPlane.x; targetCameraY = selectedPlane.y; targetCameraZ = defZoomedInCameraZ;
					camera.rotationY = 0;
					//updatePlanes(400, -200); 
					break;
				case zoomingIn:
					trace("planeClick,zoomingIn");
					if ( planeId != selectedPlane.id )
					{
						planeId = selectedPlane.id;
						targetCameraX = selectedPlane.x; targetCameraY = selectedPlane.y; 
					}
					break;
				case zoomedIn:
					trace("planeClick,zoomedIn");
					if ( planeId != selectedPlane.id )
					{
						trace("planeClick,planeId"+planeId+" != selectedPlane.id" + selectedPlane.id );
						planeId = selectedPlane.id;
						targetCameraX = selectedPlane.x; targetCameraY = selectedPlane.y; 
					}
					else
					{
						targetCameraZ = defZoomedOutCameraZ;
						targetCameraX = viewport.containerSprite.mouseX*1;
						targetCameraY = 0;
						state = zoomingOut;
					}
					break;
			}

		}		
		public function enterFrame(e:Event) : void
		{
			if ( Math.abs( currentCameraX - targetCameraX ) <= cameraIncrement ) currentCameraX = targetCameraX;
			if ( Math.abs( currentCameraY - targetCameraY ) <= cameraIncrement ) currentCameraY = targetCameraY;
			switch ( state )
			{
				case zoomedOut:
					//trace("planeClick,zoomedOut");
					targetCameraX = viewport.containerSprite.mouseX*1;
					targetCameraY = 0;

					//camera.rotationY = (viewport.containerSprite.mouseX-planeCols*100) * -planeCols/400; 
					camera.rotationY = viewport.containerSprite.mouseX * -planeCols/400; 
					updatePlanes(viewport.containerSprite.mouseX, -viewport.containerSprite.mouseY); 		
					break;
				case zoomingIn:
					if ( currentCameraZ < defZoomedInCameraZ )
					{
						// zoom in on selected plane
						currentCameraZ += cameraIncrement;
						camera.z = currentCameraZ;
					}
					else
					{
						currentCameraZ = defZoomedInCameraZ;
						
					}
					if ( (currentCameraZ == targetCameraZ)&&(currentCameraX == targetCameraX)&&( currentCameraY == targetCameraY) ) state = zoomedIn;
					moveCameraXY();
					
					break;
				case zoomedIn:
					moveCameraXY();
						
					break;
				case zoomingOut:
					moveCameraXY();
					// zoom out off selected plane
					currentCameraZ -= cameraIncrement;
					camera.z = currentCameraZ;
					if ( currentCameraZ < defZoomedOutCameraZ )
					{
						currentCameraZ = defZoomedOutCameraZ;
						state = zoomedOut;
					}
					
					break;
			}
			//trace("currentCameraZ:"+currentCameraZ+" targetCameraZ:"+targetCameraZ);
			singleRender(); 
		}
		private function moveCameraXY():void
		{
			if ( currentCameraX > targetCameraX) currentCameraX -= cameraIncrement else currentCameraX += cameraIncrement;
			if ( currentCameraY > targetCameraY) currentCameraY -= cameraIncrement else currentCameraY += cameraIncrement;
			
			camera.x = currentCameraX;
			camera.y = currentCameraY;
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
			objectInfoTextField.text = "WallGallery, an IO Error has occured: " + event.text;
		} 
		public function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			trace( "WallGallery, securityErrorHandler: " + event.text );
			objectInfoTextField.text = "WallGallery, securityErrorHandler: " + event.text;
		}

	}
	
}
