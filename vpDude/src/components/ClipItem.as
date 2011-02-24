import com.hillelcoren.components.AdvancedAutoComplete;
import com.hillelcoren.components.AutoComplete;

import components.Search;
import components.TagEdit;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.controls.LinkButton;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.core.windowClasses.TitleBar;

import spark.components.Application;
import spark.components.TextInput;
import spark.components.Window;

import videopong.*;

[Bindable]
private var cachedThumbnail1:String;
[Bindable]
private var clipname:String;
[Bindable]
private var tagList:String;

// get instance of Tags class
[Bindable]
private var tags:Tags = Tags.getInstance();;

// Collection of tags for this clip
[Bindable]
public var clipXmlTagList:XMLList;
// drag icon of thumb
private var image:Bitmap;
// url of clip
private var cachedVideo:String;
// url of swf
private var cachedSwf:String;
// store search component
private var searchComp:Search;
// for tagAutoComplete
private var ac:ArrayCollection;
private var tagArray:Array = [];
private const minFileSize:int = 10000;
[Embed(source='../assets/wait.png')]
private var waitImage:Class;

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		if ( data.attribute( "urllocal" ).length() > 0 ) 
		{	
			//don't load from cache as it is local files
			if ( data.urlthumb1 ) cachedThumbnail1 = data.urlthumb1;
			var thumb1:File = new File( cachedThumbnail1 );
			if ( !thumb1.exists ) 
			{
				imgUrl.source = waitImage;
				Util.errorLog( cachedThumbnail1 + " does not exist" );
			}
			else
			{
				var req:URLRequest = new URLRequest( cachedThumbnail1 );
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				loader.load( req );
				imgUrl.source = cachedThumbnail1;
			}
			
			if ( data.@urllocal ) cachedVideo = data.@urllocal;
		}
		else
		{	
			// get urls from cached files
			if ( data.urlthumb1 ) cachedThumbnail1 = getCachedThumbnail( data.urlthumb1 );
			var cthumb1:File = new File( cachedThumbnail1 );
			if ( !cthumb1.exists ) 
			{
				imgUrl.source = waitImage;
			}
			if ( data.urldownload ) cachedVideo = getCachedVideo( data.urldownload ) else cachedVideo = "";
			if ( data.urlpreview ) cachedSwf = getCachedSwf( data.urlpreview, cachedVideo );
			// check if files are cached 
			checkLocalCache( data.urlthumb1, data.urldownload, data.urlpreview );
		}

		data.clip.@name ? clipname = data.clip.@name : "...";
		
		//tagsXMLList = new XMLListCollection(data..tags.tag.@name);
		clipXmlTagList = data..tags.tag as XMLList;
		var tagString:String = "";
		for each ( var oneTag:XML in clipXmlTagList )
		{
			if ( tagString.length > 0 ) tagString += ",";
			tagString += oneTag.@name;
		}
		tagList = tagString;
		
	}
}
private function allFilesDownloaded(evt:Event):void
{
	//load image for drag n drop
	FlexGlobals.topLevelApplication.cache.removeEventListener( Event.COMPLETE, allFilesDownloaded );
	var req:URLRequest = new URLRequest( cachedThumbnail1 );
	var loader:Loader = new Loader();
	loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
	loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	loader.load( req );
	imgUrl.source = cachedThumbnail1;
	var clips:Clips = Clips.getInstance();
	clips.refreshClipsXMLList();
}
private function checkLocalCache( t:String, c:String, v:String ):void
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( parentDocument.dldFolderPath );
	var sCacheFile:File = new File( cachedSwf );
	Util.cacheLog( "ClipItem, checkLocalCache swf localUrl: " + cachedSwf );
	var allDldOk:Boolean = true;
	if( sCacheFile.exists )
	{
		Util.cacheLog( "ClipItem, checkLocalCache swf size: " + sCacheFile.size );
		// error9 case:
		if ( sCacheFile.size < minFileSize )
		{
			Util.cacheLog( "ClipItem, checkLocalCache swf size < " + minFileSize.toString() );
			allDldOk = false;
		}
	}
	else
	{
		Util.cacheLog( "ClipItem, checkLocalCache swf does not exist: " + cachedSwf );
		allDldOk = false;	
	}	
	if ( !allDldOk )
	{
		FlexGlobals.topLevelApplication.cache.addEventListener( Event.COMPLETE, allFilesDownloaded );
		FlexGlobals.topLevelApplication.cache.downloadClipFiles( t, c, v );
	}
}
private function loadComplete(event:Event):void
{
	image = event.target.loader.content;
}
private function getCachedVideo( videoUrl:String ):String
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	var cachedVideoUrl:String = FlexGlobals.topLevelApplication.cache.getClipByURL( videoUrl );
	return cachedVideoUrl;
}
private function getCachedSwf( swfUrl:String, videoUrl:String ):String
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	var cachedSwfUrl:String = FlexGlobals.topLevelApplication.cache.getSwfByURL( swfUrl );
	Util.log( "getCachedSwf, cachedSwfUrl: " + cachedSwfUrl );
	return cachedSwfUrl;
}
private function getCachedThumbnail( thumbnailUrl:String ):String
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	var cachedThumbUrl:String = FlexGlobals.topLevelApplication.cache.getThumbnailByURL( thumbnailUrl );
	return cachedThumbUrl;
}
protected function viewOnline_clickHandler(event:MouseEvent):void
{
	FlexGlobals.topLevelApplication.vpFullUrl = "http://www.videopong.net/clip/detail/" + data.@id;
	FlexGlobals.topLevelApplication.tabNav.selectedIndex=1;
}
protected function creator_clickHandler(event:MouseEvent):void
{
	FlexGlobals.topLevelApplication.vpFullUrl = "http://www.videopong.net/user/"+ data.creator.@id + "/" + data.creator.@name;
	FlexGlobals.topLevelApplication.tabNav.selectedIndex=1;
}
protected function rateClip_clickHandler(event:MouseEvent):void
{
}

protected function imgUrl_mouseDownHandler(event:MouseEvent):void
{
	if ( FlexGlobals.topLevelApplication.search ) 
	{
		searchComp = FlexGlobals.topLevelApplication.search;
		searchComp.viewClipBtn.label = data.clip.@name;
		searchComp.viewCreatorBtn.label = "created by: " + data.creator.@name;
		if (searchComp.viewClipBtn.hasEventListener( MouseEvent.CLICK ) )
			searchComp.viewClipBtn.removeEventListener( MouseEvent.CLICK, viewOnline_clickHandler );
		if (searchComp.viewCreatorBtn.hasEventListener( MouseEvent.CLICK ) )
			searchComp.viewCreatorBtn.removeEventListener( MouseEvent.CLICK, creator_clickHandler );
		searchComp.viewClipBtn.addEventListener( MouseEvent.CLICK, viewOnline_clickHandler );
		searchComp.viewCreatorBtn.addEventListener( MouseEvent.CLICK, creator_clickHandler );
		var urlPreview:String = data.urlpreview;
		Util.log( "imgUrl_mouseDownHandler, urlPreview: " + urlPreview );
		if ( urlPreview ) 
		{
			var cachedUrl:String = getCachedSwf( urlPreview, "" );
			Util.log( "imgUrl_mouseDownHandler, cachedUrl: " + cachedUrl );
			searchComp.swfComp.source = cachedUrl;
		}
		else
		{
			Util.log( "imgUrl_mouseDownHandler, urlPreview null" );
			searchComp.swfComp.source = null;
		}
		searchComp.tagAutoComplete.dataProvider = tags.tagsXMLList;
		searchComp.tagAutoComplete.data = data as XML;//clipXmlTagList;
		data..tags.tag.
			(
				tagArray.push( attribute("name") )
			);
		ac = new ArrayCollection( tagArray );
		searchComp.tagAutoComplete.selectedItems = ac;

		if ( data.attribute( "urllocal" ).length() > 0 ) 
		{	
			searchComp.localUrl.text = data.attribute( "urllocal" );
		}
		else
		{
			searchComp.localUrl.text = "";
		}
	}

	var draggedObject:Clipboard = new Clipboard();
	var fileToDrag:File = new File( cachedVideo );
	var dragOptions : NativeDragOptions = new NativeDragOptions();
	// we don't want the file to be moved
	dragOptions.allowCopy = true;
	dragOptions.allowLink = true;
	dragOptions.allowMove = false;	
	
	draggedObject.setData( ClipboardFormats.FILE_LIST_FORMAT, new Array( fileToDrag ), false );
	
	if ( image )
	{
		NativeDragManager.doDrag( 	this, 
									draggedObject, 
									image.bitmapData, 
									new Point( -image.width/2, -image.height/2 ),
									dragOptions ); 	
	}
	else
	{   
		//thumb1 could not be loaded
		NativeDragManager.doDrag( 	this, 
									draggedObject, 
									null, 
									null,
									dragOptions ); 
	}
		
}

private function ioErrorHandler( event:IOErrorEvent ):void
{
	Util.log( 'ClipItem, An IO Error has occured: ' + event.text );
} 
