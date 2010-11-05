package components
{
	
	import flash.events.Event
	import flash.net.URLLoader
	import flash.net.URLRequest
	
	public final class XMLManager {
		
		public static var dataXML:XML; 
		public static var loader:URLLoader; 
		
		public static function load(url:String):void {
			loader = new URLLoader(new URLRequest(url));			
			loader.addEventListener(Event.COMPLETE, loadComplete);	
		}
		
		private static function loadComplete(evt:Event):void {
			dataXML = new XML(evt.currentTarget.data);				
		}

		public static function get radius():int {
			return dataXML.config.rotate.@rad
		}
		

		public static function get dark():int {
			return dataXML.config.rotate.@dark
		}
		
		public static function get thumbSize():Object {
			return {w:int(dataXML.config.thumb.@wMax), h:int(dataXML.config.thumb.@hMax)}
		}
		
		public static function get viewType():String {
			return dataXML.config.view.@type
		}
		
		public static function get thumbType():String {
			return dataXML.config.view.@thumb
		}

		public static function get imgs():int {
			return dataXML.images.img.length();
		}
		
		public static function get path():String {
			return dataXML.images.@path
		}
		
		public static function getThumbURL(nb:int):String {
			return path + dataXML.images.img[nb].@thumbnail
		}

		public static function getURL(nb:int):String {
			return path + dataXML.images.img[nb].@url
		}
		
	}
}