package fr.batchass
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.formatters.DateFormatter;

	public class Util
	{
		private static var dateFormatter:DateFormatter;
		private static var millisDateFormatter:DateFormatter;
		private static var _nowDate:String;
		private static var _sessionDate:String;
		
		public static function trim(s:String):String 
		{
			return s ? s.replace(/^\s+|\s+$/gs, '') : "";
		}
		public static function log( text:String, clear:Boolean=false ):void
		{
			
			var file:File = File.applicationStorageDirectory.resolvePath( sessionDate + ".log" );
			var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, fileMode );
			
			fileStream.writeMultiByte( text + "\n", File.systemCharset );
			fileStream.close();
			trace( text );
			
		} 
		public static function errorLog( text:String, clear:Boolean=false ):void
		{
			
			var file:File = File.applicationStorageDirectory.resolvePath( "error-" + sessionDate + ".log" );
			var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, fileMode );
			
			fileStream.writeMultiByte( text + "\n", File.systemCharset );
			fileStream.close();
			trace( text );
			
		} 

		public static function get nowDate():String
		{
			if ( !millisDateFormatter )
			{
				millisDateFormatter = new DateFormatter();
				millisDateFormatter.formatString = "YYYYMMDD-HHhNNmnSSsQQQ";
			}
			_nowDate = millisDateFormatter.format(new Date());	
			return _nowDate;
		}

		public static function get sessionDate():String
		{
			if ( !_sessionDate )
			{
				if ( !dateFormatter )
				{
					dateFormatter = new DateFormatter();
					dateFormatter.formatString = "YYYYMMDD-HHhNN";
				}
				_sessionDate = dateFormatter.format(new Date());	
			}
			return _sessionDate;
		}



	}
}