package
{	
	import components.*;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.events.StateChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.CursorManager;
	import mx.rpc.events.ResultEvent;
		
	public class Singleton 
	{
		private static var instance:Singleton = new Singleton();

		private static var dateFormatter:DateFormatter;
		private static var _nowDate:String;

		private static var _vpDudeApp:Object;
		private static var _username:String = "guest";
		private static var _password:String = "none";
		[Bindable]
		public var vpUrl:String = "http://www.videopong.net/vpdude/";

		
		public function Singleton()
		{
			
			
			if ( instance == null ) 
			{
				dateFormatter = new DateFormatter();
				dateFormatter.formatString = "YYYYMMDD-HHhNN";
				_nowDate = dateFormatter.format(new Date());
			}
			else trace( "Singleton already instanciated." );
		}
		public static function getInstance():Singleton 
		{
			return instance;
		}
		public function log( text:String, clear:Boolean=false ):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath( _nowDate + ".log" );
			var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, fileMode );
			
			fileStream.writeMultiByte( text + "\n", File.systemCharset );
			fileStream.close();
			trace( text );

		} 

		public function get vpDudeApp():Object
		{
			return _vpDudeApp;
		}

		public function set vpDudeApp(value:Object):void
		{
			_vpDudeApp = value;
		}

		public function get username():String
		{
			return _username;
		}

		public function set username(value:String):void
		{
			_username = value;
		}

		public function get password():String
		{
			return _password;
		}

		public function set password(value:String):void
		{
			_password = value;
		}


	}
}