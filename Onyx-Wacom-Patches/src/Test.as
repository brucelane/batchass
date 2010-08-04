package
{
	import com.moremeyou.utils.Tablet;
	import com.wacom.mini.core.tablet.TabletEvent;
	import com.wacom.mini.core.tablet.TabletGestureEvent;
	
	import flash.display.MovieClip;
	
	public class Test extends MovieClip
	{
		public function Test()
		{
			// Initialize the tablet connection to Flash (through Bamboo Dock)
			Tablet.init(this);
			
			// Register listeners. Tablet & Gesture events are dispatched to all display objects.
			//for each (var eventName:String in ["zoom", "rotate", "vscroll", "hscroll", "swipe"])
			//addEventListener(eventName, onGestureEvent);
		}
		// Gesture event listener
		/*public function onGestureEvent (e:TabletGestureEvent):void
		{
			trace(e.type);
			
		}*/
	}
}



