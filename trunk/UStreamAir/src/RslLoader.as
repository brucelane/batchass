package  
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;

	public class RslLoader extends MovieClip
	{
		private var context:LoaderContext
		private var path:String = 'http://www.ustream.tv/flash/'
		private var rsls:Array = ['viewer.rsl.swf']

		public function RslLoader() 
		{
			stop()
			if (stage) onAddedToStage()
			else addEventListener('addedToStage',onAddedToStage)
		}

		private function onAddedToStage(...e):void
		{
			context = new LoaderContext(false, ApplicationDomain.currentDomain)
			context.allowLoadBytesCodeExecution = true
			getRsl()
		}
		
		private function getRsl(...e):void
		{
			if ( rsls.length )
			{
				var urlLoader:URLLoader = new URLLoader()
				urlLoader.dataFormat = 'binary'
				urlLoader.addEventListener('complete', onBytesComplete);
				trace('get RSL : '+ path + rsls[ 0 ] )
				urlLoader.load( new URLRequest(path + rsls.shift( ) ) )
			}
			else
			{
				trace('RSL(s) loaded')
				gotoAndStop(2)
				var mainClass:Class = getDefinitionByName('Main') as Class
				addChild(new mainClass() as DisplayObject)
			}
		}
		
		private function onBytesComplete(e:Event):void
		{
			var bytes:ByteArray = (e.target as URLLoader).data
			var loader:Loader = new Loader()
			loader.contentLoaderInfo.addEventListener( "complete", getRsl )
			loader.loadBytes(bytes, context)
		}
	}
}