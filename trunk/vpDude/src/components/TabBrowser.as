import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import fr.batchass.CacheManager;
import fr.batchass.Util;
import fr.batchass.writeTextFile;

import mx.controls.Alert;
import mx.controls.HTML;

internal var gb:Singleton = Singleton.getInstance();

private var airApp : Object = this;
private var cache:CacheManager;

private function init():void
{
	trace ( "init" );
	
	
}

//inject a reference to "this" into the HTML dom
private function onHTMLComplete() : void
{
	trace ( "onHTMLComplete" );
	htmlBrowser.domWindow.airApp = airApp;
}

// JAVASCRIPT functions
public var launchURL:Function = function( url : String ) : void
{
	navigateToURL( new URLRequest( url ) );
}

public var launchE4X:Function = function( e4xResult : String ) : void
{
	trace( "e4x:" + e4xResult );
	var req:URLRequest = new URLRequest(e4xResult);
	var loader:URLLoader = new URLLoader();
	loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
	loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
	loader.addEventListener( Event.COMPLETE, e4xLoadComplete );
	loader.dataFormat = URLLoaderDataFormat.TEXT;
	loader.load(req);
}
private function e4xLoadComplete( event:Event ):void
{
	var loader:URLLoader = event.target as URLLoader;
	
	trace(loader.data);
	var clipXml:XML = XML( loader.data );
	var clipId:String = clipXml..clipid;
	
	if ( !cache ) cache = new CacheManager( parentDocument.dldFolderPath );
	cache.getThumbnailByURL( clipXml..urlthumb1 );
	cache.getThumbnailByURL( clipXml..urlthumb2 );
	cache.getThumbnailByURL( clipXml..urlthumb3 );
	cache.getClipByURL( clipXml..urldownload );
	clipXml.video.dlddate = new Date();
	writeClipXmlFile( clipId, clipXml );
}
private function writeClipXmlFile( clipId:String, clipXml:XML ):void
{
	var localClipXMLFile:String = parentDocument.dbFolderPath + File.separator + clipId + ".xml" ;
	var clipXmlFile:File = new File( localClipXMLFile );
	
	// write the text file
	writeTextFile( clipXmlFile, clipXml );					
}
private function ioErrorHandler( event:IOErrorEvent ):void
{
	Util.log( 'TabBrowser, An IO Error has occured: ' + event.text );
}    
// only called if a security error detected by flash player such as a sandbox violation
private function securityErrorHandler( event:SecurityErrorEvent ):void
{
	Util.log( "TabBrowser, securityErrorHandler: " + event.text );
}		
//  after a file upload is complete or attemted the server will return an http status code, code 200 means all is good anything else is bad.
private function httpStatusHandler( event:HTTPStatusEvent ):void 
{  
	Util.log( "TabBrowser, httpStatusHandler, status(200 is ok): " + event.status );
}
