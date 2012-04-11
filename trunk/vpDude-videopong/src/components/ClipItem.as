import com.hillelcoren.components.AdvancedAutoComplete;
import com.hillelcoren.components.AutoComplete;

import components.Config;
import components.Search;
import components.TagEdit;

import flash.desktop.NativeDragManager;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.net.URLRequest;

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
private var cachedThumbnail2:String;
[Bindable]
private var cachedThumbnail3:String;
[Bindable]
private var clipname:String;

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
//private var tagArray:Array = [];
private const minFileSize:int = 10000;
[Embed(source='images/wait.png')]
private var waitImage:Class;
[Embed(source='images/previewwait.png')]
private var previewWaitImage:Class;
[Embed(source='images/nopreview.png')]
private var previewNotAvailableImage:Class;

private var cache:CacheManager;
private var session:Session = Session.getInstance();
private var cnv:Convertion = Convertion.getInstance(); 

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		if ( data.attribute( "urllocal" ).length() > 0 ) 
		{	
			//don't load from cache as it is local files
			if ( data.urlthumb1 ) cachedThumbnail1 = data.urlthumb1;
			if ( data.urlthumb2 ) cachedThumbnail2 = data.urlthumb2;
			if ( data.urlthumb3 ) cachedThumbnail3 = data.urlthumb3;
			if ( session.os == "Mac" )
			{
				cachedThumbnail1 = "file://" + cachedThumbnail1;
				cachedThumbnail2 = "file://" + cachedThumbnail2;
				cachedThumbnail3 = "file://" + cachedThumbnail3;
			}
			// if convertion needed
			var pathToVideo:String = session.ownFolderPath + File.separator + data.@urllocal;
			var VideoFile:File = new File( pathToVideo );
			
			if ( VideoFile.exists )
			{
				var thumb1:File = new File( cachedThumbnail1 );
				if ( !thumb1.exists ) 
				{
					imgUrl.source = waitImage;
					Util.errorLog( cachedThumbnail1 + " does not exist" );
					cnv.createThumb( VideoFile, 1 );	
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
				var thumb2:File = new File( cachedThumbnail2 );
				if ( !thumb2.exists ) 
				{
					Util.errorLog( cachedThumbnail2 + " does not exist" );
					cnv.createThumb( VideoFile, 2 );
					
					var t2:File = File.applicationDirectory.resolvePath( 'images' + File.separator + 'thumbnotavailable.png' );
					if( t2.exists )
					{
						cachedThumbnail2 = t2.nativePath;
					} 				 
				}
				var thumb3:File = new File( cachedThumbnail3 );
				if ( !thumb3.exists ) 
				{
					Util.errorLog( cachedThumbnail3 + " does not exist" );
					cnv.createThumb( VideoFile, 3 );
					
					var t3:File = File.applicationDirectory.resolvePath( 'images' + File.separator + 'thumbnotavailable.png' );
					if( t3.exists )
					{
						cachedThumbnail3 = t3.nativePath;
					} 	
				}			
			}
			else
			{	
				//VideoFile path does not exist
				Util.errorLog( pathToVideo + " path does not exist" );
				imgUrl.source = waitImage;
				var th2:File = File.applicationDirectory.resolvePath( 'images' + File.separator + 'thumbnotavailable.png' );
				if( th2.exists )
				{
					cachedThumbnail2 = th2.nativePath;
				} 				 
				var th3:File = File.applicationDirectory.resolvePath( 'images' + File.separator + 'thumbnotavailable.png' );
				if( th3.exists )
				{
					cachedThumbnail3 = th3.nativePath;
				} 	
				//delete clip
				cnv.deleteXmlClipAsync( XML( data ) );
				
			}
			if ( data.@urllocal ) cachedVideo = session.ownFolderPath + File.separator + data.@urllocal;
		}
		else
		{	
			// get urls from cached files
			if ( data.urlthumb1 ) cachedThumbnail1 = getCachedThumbnail( data.urlthumb1 );
			//test if start with http, means not downloaded
			if (cachedThumbnail1.substr(0,7)=="file://")
			{	
				var cthumb1:File = new File( cachedThumbnail1 );
				if ( !cthumb1.exists ) 
				{
					imgUrl.source = waitImage;
				}
			}
			else
			{
				imgUrl.source = waitImage;
			}
			if ( data.urldownload ) cachedVideo = getCachedVideo( data.urldownload ) else cachedVideo = "";
			if ( data.urlpreview ) cachedSwf = getCachedSwf( data.urlpreview );
			// check if files are cached 
			checkLocalCache( data.urlthumb1, data.urldownload, data.urlpreview );
		}

		data.clip.@name ? clipname = data.clip.@name : "...";
		
		clipXmlTagList = data..tags.tag as XMLList;
		var tagString:String = "";	

		for each ( var oneTag:XML in clipXmlTagList )
		{
			if ( tagString.length > 0 ) tagString += ",";
			tagString += oneTag.@name;
		}
	}
}
private function allFilesDownloaded(evt:Event):void
{
	//load image for drag n drop
	if ( cache ) cache.removeEventListener( Event.COMPLETE, allFilesDownloaded );
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
	if ( !cache ) cache = new CacheManager( session.dldFolderPath );
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
		cache.addEventListener( Event.COMPLETE, allFilesDownloaded );
		cache.downloadClipFiles( t, c, v );
	}
}
private function loadComplete(event:Event):void
{
	image = event.target.loader.content;
}
private function getCachedVideo( videoUrl:String ):String
{
	if ( !cache ) cache = new CacheManager( session.dldFolderPath );
	var cachedVideoUrl:String = cache.getClipByURL( videoUrl );
	return cachedVideoUrl;
}
private function getCachedSwf( swfUrl:String ):String
{
	if ( !cache ) cache = new CacheManager( session.dldFolderPath );
	var cachedSwfUrl:String	= cache.getSwfByURL( swfUrl, (session.os == "Mac") );
	Util.log( "getCachedSwf, cachedSwfUrl: " + cachedSwfUrl );
	return cachedSwfUrl;
}
private function getCachedThumbnail( thumbnailUrl:String ):String
{
	if ( !cache ) cache = new CacheManager( session.dldFolderPath );
	var cachedThumbUrl:String = cache.getThumbnailByURL( thumbnailUrl );
	return cachedThumbUrl;
}
protected function viewOnline_clickHandler(event:MouseEvent):void
{
	session.vpFullUrl = "http://www.videopong.net/clip/detail/" + data.@id;
	if (session.connected) FlexGlobals.topLevelApplication.tabNav.selectedIndex=1;
}
protected function viewFolder_clickHandler(event:MouseEvent):void
{
	var file:File = new File( cachedVideo );
	file.browse();
}

protected function creator_clickHandler(event:MouseEvent):void
{
	session.vpFullUrl = "http://www.videopong.net/user/"+ data.creator.@id + "/" + data.creator.@name;
	if (session.connected) FlexGlobals.topLevelApplication.tabNav.selectedIndex=1;
}
protected function rateClip_clickHandler(event:MouseEvent):void
{
}
protected function updateDetails():void
{
	var tagArray:Array = [];

	if ( FlexGlobals.topLevelApplication.search ) 
	{
		searchComp = FlexGlobals.topLevelApplication.search;
		searchComp.viewClipBtn.label = data.clip.@name;
		if (searchComp.viewClipBtn.hasEventListener( MouseEvent.CLICK ) )
			searchComp.viewClipBtn.removeEventListener( MouseEvent.CLICK, viewOnline_clickHandler );
		if (searchComp.viewCreatorBtn.hasEventListener( MouseEvent.CLICK ) )
			searchComp.viewCreatorBtn.removeEventListener( MouseEvent.CLICK, creator_clickHandler );
		
		if ( session.userName != data.creator.@name)
		{
			searchComp.viewClipBtn.addEventListener( MouseEvent.CLICK, viewOnline_clickHandler );
			searchComp.viewCreatorBtn.label = "created by: " + data.creator.@name;
			searchComp.viewCreatorBtn.visible = true;
			searchComp.viewCreatorBtn.addEventListener( MouseEvent.CLICK, creator_clickHandler );				
		}
		else
		{
			searchComp.viewClipBtn.addEventListener( MouseEvent.CLICK, viewFolder_clickHandler );
			searchComp.viewCreatorBtn.label = "";	
			searchComp.viewCreatorBtn.visible = false;
		}
		
		
		var urlPreview:String = data.urlpreview;
		Util.log( "updateDetails, urlPreview: " + urlPreview );
		if ( urlPreview ) 
		{
			var cachedUrl:String = getCachedSwf( urlPreview );
			Util.log( "updateDetails, cachedUrl: " + cachedUrl );
			var cPrev:File = new File( cachedUrl );
			if ( !cPrev.exists ) 
			{
				Util.log( "updateDetails, cachedUrl does not exist: " + cachedUrl );
				if ( urlPreview.substr( 0, 4 ) == "http" )
				{
					searchComp.swfComp.source = previewWaitImage;
				}
				else
				{
					searchComp.swfComp.source = previewNotAvailableImage;
				}
			}
			else
			{
				Util.log( "updateDetails, cachedUrl exists: " + cachedUrl );
				Util.log( "updateDetails, searchComp: " + searchComp );
				Util.log( "updateDetails, searchComp.swfComp: " + searchComp.swfComp );
				Util.log( "updateDetails, cPrev.size: " + cPrev.size );
				Util.log( "updateDetails, searchComp.swfComp.source before: " + searchComp.swfComp.source );
				if ( cPrev.size < 1 )
				{
					searchComp.swfComp.source = previewNotAvailableImage;
				}
				else
				{
					searchComp.swfComp.source = cachedUrl;
				}
				Util.log( "updateDetails, searchComp.swfComp.source after: " + searchComp.swfComp.source );
			}
		}
		else
		{
			Util.log( "updateDetails, urlPreview null" );
			searchComp.swfComp.source = previewNotAvailableImage;
		}
		searchComp.tagAutoComplete.dataProvider = tags.tagsXMLList;
		searchComp.tagAutoComplete.data = data as XML;//clipXmlTagList;
		//searchComp.tagAutoComplete.data = clipXmlTagList; wrong data id = ""
		
		data..tags.tag.
			(
				tagArray.push( attribute("name") )
			);
		ac = new ArrayCollection( tagArray );
		searchComp.tagAutoComplete.selectedItems = ac;
		
		if ( data.attribute( "urllocal" ).length() > 0 ) 
		{	
			searchComp.localUrl.text = session.ownFolderPath + File.separator + data.attribute( "urllocal" );
		}
		else
		{
			searchComp.localUrl.text = "";
		}
	}
	
}
protected function imgUrl_mouseDownHandler(event:MouseEvent):void
{
	var draggedObject:Clipboard = new Clipboard();
	var fileToDrag:File = new File( cachedVideo );
	var dragOptions : NativeDragOptions = new NativeDragOptions();

	//update details on the right side
	updateDetails();
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
