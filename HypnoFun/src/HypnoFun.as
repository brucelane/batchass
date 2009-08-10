package {
	import flash.display.Sprite;
	import flash.events.Event;

	public class HypnoFun extends Sprite
	{
		private var w:Number=320;
		private var h:Number=240;
		private var steps:uint=5;
		private var stepAngle:Number=720/steps;
		private var div:Number=2;
		private var inita:Number=0;
		private var acc:Number=0;
		 
		private function render(event:Event):void {
			acc+=1;
			div+=.02;
			inita+=.2;
			this.graphics.clear();
			this.graphics.beginFill(0);
			this.graphics.moveTo(w/2, h/2);
			var r:Number=1;
			var a:Number;
			var arad:Number;
			var i:int=0;
			while (r<1000) {
				if (div!=0) r+=r/div;
				a=inita;
				for (i=0; i<steps; i++) {
					a+=stepAngle;
					arad=a/180*Math.PI;
					this.graphics.lineTo(w/2+Math.cos(arad)*r, h/2+Math.sin(arad)*r);
				}
			}
		}
		public function HypnoFun()
		{
			addEventListener(Event.ENTER_FRAME, render);
		}
	}
}
