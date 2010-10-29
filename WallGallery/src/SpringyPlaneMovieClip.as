package
{
	import flash.display.DisplayObject;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.CompositeMaterial;
	import org.papervision3d.objects.primitives.Plane;

	public class SpringyPlaneMovieClip extends Plane
	{
		
		public var targetZ : Number =0; 
		public var zVel : Number = 0;
		
		public var movieMaterial : MaterialObject3D; 
		
		public function SpringyPlaneMovieClip(width:Number, height:Number, fileUrl: String )
		{
			var photoMaterial:BitmapFileMaterial = new BitmapFileMaterial( fileUrl );
			photoMaterial.interactive = true;
			this.addEventListener( InteractiveScene3DEvent.OBJECT_OVER, planeOver );
			this.addEventListener( InteractiveScene3DEvent.OBJECT_OUT, planeOut );
			this.addEventListener( InteractiveScene3DEvent.OBJECT_CLICK, planeClick );
			
			super(photoMaterial, width, height);
		}
		public function planeOver( e:InteractiveScene3DEvent ):void
		{
			trace("mouse over");
		}
		public function planeOut( e:InteractiveScene3DEvent ):void
		{
			trace("mouse out");
		}
		public function planeClick( e:InteractiveScene3DEvent ):void
		{
			trace("mouse click");
			var selectedPlane:Plane = e.displayObject3D as Plane;
			selectedPlane.alpha = .3;
		}
		
		public function update(mousex:Number, mousey:Number): void
		{
			
			var xdiff : Number = x-mousex; 
			var ydiff : Number = y-mousey; 
			
			var distance : Number = Math.sqrt((xdiff*xdiff)+(ydiff*ydiff)) * 0.4; 
			
			if(distance>150) distance = 150; 
			
			scale = 1-(distance/450)+(100/450); 
			
			targetZ = distance-100;
			
			var brightness : Number = distance/=150; 
			
			zVel*=0.6; 
			if(targetZ!=z)
			{
				var diff: Number = (targetZ-z) * 0.3;
				zVel+=diff;   
			}
			z+=zVel;

		}
		
	}
}