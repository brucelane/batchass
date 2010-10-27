// Author : Seb Lee-Delisle
// Blog : sebleedelisle.com

package {
	import flash.display.DisplayObject;
	import flash.events.Event;
	
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
		
		public function WallGallery()
		{	
			
			super(800,480,false,true, CameraType.FREE); 
			
			camera.z = -500; 
			planes = new Array(); 
			
			makePlanes(); 
			
			//reflectionview: surfaceHeight = -400; 
			
			addEventListener(Event.ENTER_FRAME, enterFrame); 
			
			
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
		
	}
	
}
