package com.moremeyou.utils
{
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	import com.wacom.managers.AirAppConnectionManager; 
	import com.wacom.managers.PressureManager;
	import com.wacom.maxi.flash.BambooFlashMaxiImpl;
	import com.wacom.events.PressureEvent;
	import com.wacom.mini.core.tablet.TabletEvent;
	import com.wacom.mini.core.tablet.TabletGestureEvent;
	
	public class Tablet extends EventDispatcher
	{
		
		public static const MAX_PRESSURE			:int = 1023;
		private static var singleton				:Tablet;
		public static var DOCK						:BambooFlashMaxiImpl;
		public static var PRESSURE_STARTED			:Boolean = false;
		public static var PRESSURE					:Number = 0;
		private var connected						:Boolean = false;
		private var interval						:int;
		private var initTime						:int;
		
		public function Tablet (mainStage:MovieClip):void
		{
			DOCK = new BambooFlashMaxiImpl(mainStage);
			PM.addEventListener(PressureEvent.PRESSURE, onPressureEvent, false, 0, true);
			initGestureEvents(mainStage);
			
			interval = setInterval(initCheck, 100);
			initTime = getTimer();
		}
		
		public static function get PM ():PressureManager {   return DOCK.PM;   }
		public static function get PRESSURE_PERCENT ():Number {   return PRESSURE/MAX_PRESSURE;   }
		
		public static function getInstance (mainStage:MovieClip):Tablet
		{
			var instance:Tablet;
			if (singleton == null) 
			{
				singleton = new Tablet(mainStage);
				instance = singleton;
			}
			else 
			{
				instance = singleton;
			}
			
			return instance;
		}
		
		public static function init (mainStage:MovieClip):Tablet
		{
			return getInstance(mainStage);
		}
		
		private function initCheck ():void
		{
			var _connected:Boolean = AirAppConnectionManager.getInstance().connected(); 
			
			if (!connected && _connected) 
			{
				dispatchEvent(new Event(Event.COMPLETE));
				connected = true;
				clearInterval(interval);
			}
			else if (getTimer() > (initTime+10000) && !_connected)
			{
				trace("Dock not installed"); 
				clearInterval(interval);
			}
		}
		
		private function initGestureEvents (mainStage:MovieClip):void
		{
			var tabletEvents : Array = ["penDown", "penUp", "penMove", "penTap", "penRollOver", "penRollOut" ,"penPressureChange", "penSensorChange"];
			var tabletGestureEvents : Array = ["zoom", "rotate", "vscroll", "hscroll", "swipe"];
			
			var eventName : String;
			for each (eventName in tabletGestureEvents)
			{
				mainStage.addEventListener(eventName, onTabletGesture);
			}
		}
		
		private function onPressureEvent (e:PressureEvent):void
		{
			PRESSURE = e.pressure;
		}
		
		private function onTabletGesture(e:TabletGestureEvent):void
		{
			/*gesture.text = 
				"type: " + e.type + 
				"; direction: " + e.direction +
				"\n" ; //+ console.text;*/
		}
		
		public static function startPressure ():void
		{
			if (!PRESSURE_STARTED) {
				
				//trace("Tablet: startPressure");
				
				PRESSURE_STARTED = true;
				try 
				{ 
					PM.startPressure(); 
				} 
				catch(e:Error) 
				{
					trace("Tablet: error: " + e);
				}
			}
		}
		
		public static function stopPressure ():void
		{
			if (PRESSURE_STARTED) {
				
				//trace("Tablet: stopPressure");
				
				PRESSURE_STARTED = false;
				try 
				{ 
					PM.stopPressure(); 
				} 
				catch(e:Error) 
				{
					trace("Tablet: error: " + e);
				}
			}
		}
		
	}
	
}