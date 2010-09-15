import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import fr.batchass.*;

import mx.collections.XMLListCollection;
import mx.controls.HTML;

import videopong.*;

private var airApp : Object = this;

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
	// downloaded one clip xml
	var clipXml:XML = XML( loader.data );
	var clipId:String = clipXml..clip.@id;
	
	// download thumbs and video if not in cache
	if ( !parentDocument.cache ) parentDocument.cache = new CacheManager( parentDocument.dldFolderPath );
	parentDocument.cache.getThumbnailByURL( clipXml..urlthumb1 );
	parentDocument.cache.getThumbnailByURL( clipXml..urlthumb2 );
	parentDocument.cache.getThumbnailByURL( clipXml..urlthumb3 );
	parentDocument.cache.getClipByURL( clipXml..urldownload );
	clipXml.dlddate = Util.nowDate;
	
	// xml list of tags
	var clipXmlTagList:XMLList = clipXml..tags.tag as XMLList;
	var newTag:Boolean = false;
	var foundNewTag:Boolean;
	var foundNewClip:Boolean = true;
	
	var clips:Clips = Clips.getInstance();
	var tags:Tags = Tags.getInstance();

	var clipList:XMLList = clips.CLIPS_XML..video as XMLList;
	for each ( var appClip:XML in clipList )
	{
		if ( appClip.clipid.toString()==clipId )
		{
			foundNewClip = false;
		}
	}
	if ( foundNewClip )
	{
		clips.addNewClip( clipId, clipXml );
	}
	//TODO optimize
	for each ( var oneTag:XML in clipXmlTagList )
	{
		foundNewTag = true;
		var appTagList:XMLList = tags.TAGS_XML..tag as XMLList;
		for each ( var appTag:XML in appTagList )
		{
			if ( appTag.@name==oneTag.@name )
			{
				foundNewTag = false;
			}
		}
		if ( foundNewTag )
		{
			tags.TAGS_XML.appendChild( oneTag );
			newTag = true;	
		}
	}
	if ( newTag )
	{
		tags.writeTagsFile();
	}
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
