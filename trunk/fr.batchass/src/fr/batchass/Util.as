package fr.batchass
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.formatters.DateFormatter;

	public class Util
	{
		private static var dateFormatter:DateFormatter;
		private static var _nowDate:String;
		
		public static function trim(s:String):String 
		{
			return s ? s.replace(/^\s+|\s+$/gs, '') : "";
		}
		public static function log( text:String, clear:Boolean=false ):void
		{
			if ( !_nowDate )
			{
				dateFormatter = new DateFormatter();
				dateFormatter.formatString = "YYYYMMDD-HHhNN";
				_nowDate = dateFormatter.format(new Date());
				
			}
			var file:File = File.applicationStorageDirectory.resolvePath( _nowDate + ".log" );
			var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, fileMode );
			
			fileStream.writeMultiByte( text + "\n", File.systemCharset );
			fileStream.close();
			trace( text );
			
		} 
	}
}