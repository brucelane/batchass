import flash.display.BitmapData;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import fr.batchass.*;

import mx.core.Application;
import mx.core.FlexGlobals;
import mx.core.UIComponent;

import spark.components.TextInput;

import videopong.*;

[Bindable]
private var cachedThumbnail1:String;
[Bindable]
private var cachedThumbnail2:String;
[Bindable]
private var cachedThumbnail3:String;
[Bindable]
private var clipname:String;
[Bindable]
private var tagList:String;

private var tagTextInput:TextInput = new TextInput();
// get instance of Tags class
[Bindable]
private var tags:Tags;
// get instance of Clips class
[Bindable]
private var clips:Clips;
// drag icon of thumb
private var image:Bitmap;
// url of clip
private var cachedVideo:String;
//image container for drag/drop
private var imageContainer:UIComponent;

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		if ( data.attribute( "urllocal" ) ) 
		{	
			//don't load from cache as it is local files
			if ( data.urlthumb1 ) cachedThumbnail1 = data.urlthumb1;
			if ( data.urlthumb2 ) cachedThumbnail2 = data.urlthumb2;
			if ( data.urlthumb3 ) cachedThumbnail3 = data.urlthumb3;
			if ( data.@urllocal ) cachedVideo = data.@urllocal;
		}
		else
		{
			if ( data.urlthumb1 ) cachedThumbnail1 = getCachedThumbnail( data.urlthumb1 );
			if ( data.urlthumb2 ) cachedThumbnail2 = getCachedThumbnail( data.urlthumb2 );
			if ( data.urlthumb3 ) cachedThumbnail3 = getCachedThumbnail( data.urlthumb3 );
			if ( data.urldownload ) cachedVideo = getCachedVideo( data.urldownload );
		}
		//load image for drag n drop
		var req:URLRequest = new URLRequest( cachedThumbnail1 );
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
		loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
		loader.load( req );
		

		data.clip.@name ? clipname = data.clip.@name : "...";
		
		var clipXmlTagList:XMLList = data..tags.tag as XMLList;
		var tagString:String = "";
		for each ( var oneTag:XML in clipXmlTagList )
		{
			if ( tagString.length > 0 ) tagString += ",";
			tagString += oneTag.@name;
		}
		tagList = tagString;		
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
private function getCachedThumbnail( thumbnailUrl:String ):String
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	var cachedThumbUrl:String = FlexGlobals.topLevelApplication.cache.getThumbnailByURL( thumbnailUrl );
	return cachedThumbUrl;
}
protected function tagClip_mouseOverHandler(event:MouseEvent):void
{
	
	tagClip.toolTip = "Tags: " + tagList + "\nClick to edit tags";
}

protected function moreClip_mouseOverHandler(event:MouseEvent):void
{
	moreClip.toolTip = "Created by " + data.creator.@name;
}


protected function rateClip_mouseOverHandler(event:MouseEvent):void
{
}
protected function tagClip_clickHandler(event:MouseEvent):void
{
	tagTextInput.text = tagList;
	tagTextInput.width = 95;
	tagTextInput.addEventListener( KeyboardEvent.KEY_DOWN, checkTagInput );
	this.addElement( tagTextInput );
}
private function checkTagInput( event:KeyboardEvent ):void 
{
	if ( event.keyCode == Keyboard.ENTER )
	{
		var tagArray:Array = tagTextInput.text.split(",");
		for ( var i:uint; i < tagArray.length; i++ ) 
		{
			var newTag:XML;
			tags = Tags.getInstance();
			// if tag not already in global tags, add it
			tags.addTagIfNew( tagArray[i] );
			
			clips = Clips.getInstance();
			//test if tag is not already in clip
			clips.addTagIfNew( tagArray[i], data.@id  );
			
		}
		//remove textInput
		tagTextInput.removeEventListener( KeyboardEvent.KEY_DOWN, checkTagInput );
		this.removeElement( tagTextInput );
	}
	if ( event.keyCode == Keyboard.ESCAPE )//27
	{
		//remove textInput
		deleteTagTextInput();
	}
}
private function deleteTagTextInput( event:FocusEvent=null ):void 
{
		tagTextInput.removeEventListener( KeyboardEvent.KEY_DOWN, checkTagInput );
		this.removeElement( tagTextInput );
}

protected function rateClip_clickHandler(event:MouseEvent):void
{
}

/*protected function viewClip_clickHandler(event:MouseEvent):void
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	FlexGlobals.topLevelApplication.cache.getClipByURL( data.urldownload, true );
}*/

protected function moreClip_clickHandler(event:MouseEvent):void
{
}
protected function imgUrl_mouseDownHandler(event:MouseEvent):void
{
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
