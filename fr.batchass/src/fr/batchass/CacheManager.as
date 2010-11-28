package fr.batchass
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class CacheManager
	{
		private var _cacheDir:File;
		private static var instance:CacheManager;
		private var pendingDictionaryByLoader:Dictionary = new Dictionary();
		private var pendingDictionaryByURL:Dictionary = new Dictionary();
		private const THUMBS_PATH:String = "thumbs";
		private const CLIPS_PATH:String = "clips";
		private const SWF_PATH:String = "preview";
		
		public function CacheManager( cacheDir:String )
		{
			_cacheDir = File.documentsDirectory.resolvePath( cacheDir );
		}
		
		public static function getInstance( cacheDir:String ):CacheManager
		{
			if (instance == null)
			{
				instance = new CacheManager( cacheDir );
			}
			
			return instance;
		}
		public function getThumbnailByURL( thumbnailUrl:String ):String
		{
			var localUrl:String = _cacheDir.nativePath + File.separator + THUMBS_PATH + File.separator + Util.getFileNameFromFormerSlash( thumbnailUrl ) ;
			var cacheFile:File = new File( localUrl );
			
			Util.log( "CacheManager, getThumbnailByURL localUrl: " + localUrl );
			if( cacheFile.exists )
			{
				Util.log( "CacheManager, getThumbnailByURL cacheFile exists: " + cacheFile.url );
				return cacheFile.url;
			} 
			else 
			{
				Util.log( "CacheManager, getThumbnailByURL cacheFile does not exist: " + thumbnailUrl );
				addThumbToCache( thumbnailUrl );
				return thumbnailUrl;
			}		
		}
		public function getClipByURL( assetUrl:String, displayInDefaultApp:Boolean = false ):String
		{
			var localUrl:String = _cacheDir.nativePath + File.separator + CLIPS_PATH + File.separator + Util.getFileNameFromFormerSlash( assetUrl ) ;
			var cacheFile:File = new File( localUrl );
			
			Util.log( "CacheManager, getClipByURL localUrl: " + localUrl );
			if( cacheFile.exists )
			{
				Util.log( "CacheManager, getClipByURL cacheFile exists: " + cacheFile.url );
				if ( displayInDefaultApp ) cacheFile.openWithDefaultApplication();
				return cacheFile.url;
			} 
			else 
			{
				Util.log( "CacheManager, getClipByURL cacheFile does not exist: " + assetUrl );
				addAssetToCache( assetUrl, displayInDefaultApp );
				return assetUrl;
			}
		}
		public function getSwfByURL( assetUrl:String ):String
		{
			var localUrl:String = _cacheDir.nativePath + File.separator + SWF_PATH + File.separator + Util.getFileNameFromFormerSlash( assetUrl ) ;
			var cacheFile:File = new File( localUrl );
			
			Util.log( "CacheManager, getSwfByURL localUrl: " + localUrl );
			if( cacheFile.exists )
			{
				Util.log( "CacheManager, getSwfByURL cacheFile exists: " + cacheFile.url );
				return cacheFile.url;
			} 
			else 
			{
				Util.log( "CacheManager, getSwfByURL cacheFile does not exist: " + assetUrl );
				addSwfToCache( assetUrl );
				return assetUrl;
			}
		}
		// download image for gallery
		public function getGalleryImageByURL( url:String, width:int, height:int ):String
		{
			var fileName:String = width.toString() + 'x' + height.toString() + '_' + Util.getFileName( url );
			var localUrl:String = _cacheDir.nativePath + File.separator + THUMBS_PATH + File.separator + fileName;
			var cacheFile:File = new File( localUrl );
			
			Util.log( "CacheManager, getGalleryImageByURL localUrl: " + localUrl );
			if( cacheFile.exists )
			{
				Util.log( "CacheManager, getGalleryImageByURL cacheFile exists: " + cacheFile.url );
			} 
			else 
			{
				Util.log( "CacheManager, getGalleryImageByURL cacheFile does not exist: " + url );
				addGalleryImageToCache( url, width, height );
			}
			return fileName;
		}
		
		private function addThumbToCache( url:String ):void
		{
			if(!pendingDictionaryByURL[url]){
				var req:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				loader.addEventListener( ErrorEvent.ERROR, errorEventErrorHandler );
				loader.addEventListener( Event.COMPLETE, thumbLoadComplete );
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load(req);
				pendingDictionaryByLoader[loader] = url;
				pendingDictionaryByURL[url] = true;
			} 
		}
		private function addAssetToCache( url:String, displayInDefaultApp:Boolean = false ):void
		{
			if(!pendingDictionaryByURL[url]){
				var req:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				loader.addEventListener( ErrorEvent.ERROR, errorEventErrorHandler );
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				if ( displayInDefaultApp )
				{
					loader.addEventListener( Event.COMPLETE, assetLoadCompleteAndShow );
				}
				else
				{
					loader.addEventListener( Event.COMPLETE, assetLoadComplete );
				}
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load(req);
				pendingDictionaryByLoader[loader] = url;
				pendingDictionaryByURL[url] = true;
			} 
		}
		private function addSwfToCache( url:String ):void
		{
			if(!pendingDictionaryByURL[url]){
				var req:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				loader.addEventListener( ErrorEvent.ERROR, errorEventErrorHandler );
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				loader.addEventListener( Event.COMPLETE, swfLoadComplete );
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.load(req);
				pendingDictionaryByLoader[loader] = url;
				pendingDictionaryByURL[url] = true;
			} 
		}
		private function addGalleryImageToCache( url:String, width:Number, height:int ):void
		{
			var localUrlPath:String = width.toString() + 'x' + height.toString() + '_' + url;
			if(!pendingDictionaryByURL[localUrlPath]){
				var req:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				
				loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, galleryImageLoadComplete ) ;
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
				
				loader.load(req);
				pendingDictionaryByLoader[loader.contentLoaderInfo] = localUrlPath;
				pendingDictionaryByURL[localUrlPath] = true;
			} 
		}
		private function thumbLoadComplete( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
			
			var cacheFile:File = new File( _cacheDir.nativePath + File.separator + THUMBS_PATH + File.separator + Util.getFileNameFromFormerSlash( url ) );
			var stream:FileStream = new FileStream();
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open(cacheFile,FileMode.WRITE);
			stream.writeBytes(loader.data);
			stream.close();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		private function swfLoadComplete( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
			
			var cacheFile:File = new File( _cacheDir.nativePath + File.separator + SWF_PATH + File.separator + Util.getFileNameFromFormerSlash( url ) );
			var stream:FileStream = new FileStream();
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open(cacheFile,FileMode.WRITE);
			stream.writeBytes(loader.data);
			stream.close();
			//cacheFile.openWithDefaultApplication();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		private function assetLoadComplete( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
			
			var cacheFile:File = new File( _cacheDir.nativePath + File.separator + CLIPS_PATH + File.separator + Util.getFileNameFromFormerSlash( url ) );
			var stream:FileStream = new FileStream();
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open(cacheFile,FileMode.WRITE);
			stream.writeBytes(loader.data);
			stream.close();
			//cacheFile.openWithDefaultApplication();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		private function assetLoadCompleteAndShow( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var url:String = pendingDictionaryByLoader[loader];
			
			var cacheFile:File = new File( _cacheDir.nativePath + File.separator + CLIPS_PATH + File.separator + Util.getFileNameFromFormerSlash( url ) );
			var stream:FileStream = new FileStream();
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open(cacheFile,FileMode.WRITE);
			stream.writeBytes(loader.data);
			stream.close();
			cacheFile.openWithDefaultApplication();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		//generate resized images
		private function galleryImageLoadComplete( event:Event ):void
		{
			var loader:LoaderInfo = event.target as LoaderInfo;
			var passedUrl:String = pendingDictionaryByLoader[loader];
			var indexOfX:int = passedUrl.indexOf( 'x');
			var indexOfUD:int = passedUrl.indexOf( '_');
			var url:String = passedUrl.substr( indexOfUD + 1 );
			var w:String = passedUrl.substr( 0, indexOfX );
			var h:String = passedUrl.substr( indexOfX + 1, indexOfUD - indexOfX - 1 );
			var fileName:String = w + 'x' + h + '_' + Util.getFileName( url );
			var cacheFile:File = new File( _cacheDir.nativePath + File.separator + THUMBS_PATH + File.separator + fileName );
			var stream:FileStream = new FileStream();
			
			var originalImage:Bitmap = Bitmap(loader.content);
			var scale:Number = int(w) / originalImage.width;
			var newHeight:Number = originalImage.height * scale;
			var pixelsResized:BitmapData = new BitmapData( int(w), Math.min( int(h), newHeight ), true);
			pixelsResized.draw(originalImage.bitmapData, new Matrix(scale, 0, 0, scale));
			
			cacheFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			stream.open( cacheFile, FileMode.WRITE );
			stream.writeBytes( encodeJPG( pixelsResized ) );
			stream.close();
			
			delete pendingDictionaryByLoader[loader]
			delete pendingDictionaryByURL[url];
		}
		
		//jpg encoding
		private function encodeJPG( bd:BitmapData ):ByteArray
		{
			var jpgEncoder:JPGEncoder = new JPGEncoder();
			var bytes:ByteArray = jpgEncoder.encode(bd);
			return bytes;
		} 
				
		public function errorEventErrorHandler(event:ErrorEvent):void
		{
			Util.log( 'An ErrorEvent has occured: ' + event.text );
		}	
		private function ioErrorHandler( event:IOErrorEvent ):void
		{
			Util.log( 'CacheManager, An IO Error has occured: ' + event.text );
		}    
		// only called if a security error detected by flash player such as a sandbox violation
		private function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			Util.log( "CacheManager, securityErrorHandler: " + event.text );
		}		
		//  after a file upload is complete or attemted the server will return an http status code, code 200 means all is good anything else is bad.
		private function httpStatusHandler( event:HTTPStatusEvent ):void 
		{  
			Util.log( "CacheManager, httpStatusHandler, status(200 is ok): " + event.status );
		}
	}
}