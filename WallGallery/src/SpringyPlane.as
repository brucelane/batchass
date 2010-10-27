package
{
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;

	public class SpringyPlane extends Plane
	{
		
		public var targetZ : Number =0; 
		public var zVel : Number = 0; 
		
		public function SpringyPlane(width:Number=0, height:Number=0)
		{
			super(new ColorMaterial(0x770000), width, height);
		}
		
		public function update(mousex:Number, mousey:Number): void
		{
			
			var xdiff : Number = x-mousex; 
			var ydiff : Number = y-mousey; 
			
			var distance : Number = Math.sqrt((xdiff*xdiff)+(ydiff*ydiff)) * 0.4; 
			
			if(distance>150) distance = 150; 
			
			//scale = 1-(distance/450)+(100/450); 
			
			z = distance-100;
			
			//convert the distance value to a number between 0 and 1
			distance/=150; 
			
			// then we want the brightness value to be 1-distance
			// ie it's brighter as the distance is reduced
			var brightness : Number = 1-distance; 
			
			// we are now converting our brightness from a value
			// between 0 and 1 to being a value between the 
			// hex values 0x60 and 0xff
			brightness*=0x60;
			brightness+=0x9f;
			
			// then a binary shift left gives us a RRGGBB colour between
			// 0x600000 ( dark red) to 0xff0000 (bright red)
			brightness = brightness<<16; 

			// and then set the fill colour to that 
			//material.fillColor = brightness; 
			
			//zVel*=0.6; 
			//var diff: Number = (targetZ-z) * 0.3;
			//zVel+=diff;   
			//z+=zVel;

		}
		
	}
}