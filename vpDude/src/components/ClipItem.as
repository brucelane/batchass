import flash.display.BitmapData;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import fr.batchass.*;

import mx.core.Application;
import mx.core.FlexGlobals;

import spark.components.TextInput;

private var currentThumb:uint = 1;
private var timer:Timer;

[Bindable]
private var cachedThumbnail:String;
[Bindable]
private var cachedThumbnail1:String;
[Bindable]
private var cachedThumbnail2:String;
[Bindable]
private var cachedThumbnail3:String;
[Bindable]
private var clipname:String;
[Bindable]
private var tags:String;
private var NEW_TAGS_XML:XML = <tags />;
private var tagTextInput:TextInput = new TextInput();
private var newTagsXmlPath:String = FlexGlobals.topLevelApplication.dbFolderPath + File.separator + "newtags.xml";

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		//changeThumb();
		if ( data.urlthumb1 )
		{
			cachedThumbnail1 = getCachedThumbnail( data.urlthumb1 );
		};
		if ( data.urlthumb2 )
		{
			cachedThumbnail2 = getCachedThumbnail( data.urlthumb2 );
		};
		if ( data.urlthumb3 )
		{
			cachedThumbnail3 = getCachedThumbnail( data.urlthumb3 );
		};
		data.clipname ? clipname = data.clipname : "...";
		
		var clipXmlTagList:XMLList = data..tags.tag as XMLList;
		var tagString:String = "";
		for each ( var oneTag:XML in clipXmlTagList )
		{
			if ( tagString.length > 0 ) tagString += ",";
			tagString += oneTag.@name;
		}
		tags = tagString;		
	}
}

private function getCachedThumbnail( thumbnailUrl:String ):String
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	var cachedThumbUrl:String = FlexGlobals.topLevelApplication.cache.getThumbnailByURL( thumbnailUrl );
	return cachedThumbUrl;
}
protected function tagClip_mouseOverHandler(event:MouseEvent):void
{
	
	tagClip.toolTip = "Tags: " + tags + "\nClick to edit tags";
}

protected function moreClip_mouseOverHandler(event:MouseEvent):void
{
	moreClip.toolTip = "Created by " + data.creatorname;
}


protected function rateClip_mouseOverHandler(event:MouseEvent):void
{
}
protected function tagClip_clickHandler(event:MouseEvent):void
{
	loadNewTagsFile();
	tagTextInput.text = tags;
	tagTextInput.width = 95;
	tagTextInput.addEventListener( KeyboardEvent.KEY_DOWN, checkTagInput );
	this.addElement( tagTextInput );
}
private function checkTagInput( event:KeyboardEvent ):void 
{
	trace("keyDownHandler: " + event.keyCode);
	if ( event.keyCode == Keyboard.ENTER )
	{
		var newTag:XML;
		if ( NEW_TAGS_XML..tag.(@clipid == data.clipid) )
		{
			NEW_TAGS_XML..tag.(@clipid == data.clipid).@names = tagTextInput.text;
			NEW_TAGS_XML..tag.(@clipid == data.clipid).@creationdate = Util.nowDate;
		}
		else
		{
			newTag = <tag names={tagTextInput.text} creationdate={Util.nowDate} clipid={data.clipid} />;
			NEW_TAGS_XML.appendChild( newTag );
		}
		writeNewTagsFile();
		tagTextInput.removeEventListener( KeyboardEvent.KEY_DOWN, checkTagInput );
		this.removeElement( tagTextInput );
	}
}

public function writeNewTagsFile():void 
{
	var newTagsFile:File = File.applicationStorageDirectory.resolvePath( newTagsXmlPath );
	
	// write the text file
	writeTextFile( newTagsFile, NEW_TAGS_XML );
}
public function loadNewTagsFile():void 
{
	var isConfigured:Boolean = false;
	var newTagsFile:File = File.applicationStorageDirectory.resolvePath( newTagsXmlPath );
	try
	{
		if ( !newTagsFile.exists )
		{
			Util.log( "newtags.xml does not exist" );
		}
		else
		{
			Util.log( "newtags.xml exists, load the file xml" );
			NEW_TAGS_XML = new XML( readTextFile( newTagsFile ) );
			if ( NEW_TAGS_XML..tag.length() )
			{
				isConfigured = true;
			}
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading newtags.xml file: ' + e.message;
		Util.log( msg );
	}
	if ( !isConfigured )
	{
		NEW_TAGS_XML = <tags />;
		writeNewTagsFile();
	}
}
protected function rateClip_clickHandler(event:MouseEvent):void
{
}

protected function viewClip_clickHandler(event:MouseEvent):void
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	FlexGlobals.topLevelApplication.cache.getClipByURL( data.urldownload, true );
}

protected function moreClip_clickHandler(event:MouseEvent):void
{
}
protected function imgUrl_mouseOverHandler( event:MouseEvent ):void
{
	/*if ( !timer )
	{
		timer = new Timer( 500, 30 );
		timer.start();
		timer.addEventListener( TimerEvent.TIMER, onTimer );
		timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComplete );
	}*/
}
protected function imgUrl_mouseOutHandler( event:MouseEvent ):void
{
	//removeTimer();
}
/*
private function onTimer( event:TimerEvent ):void 
{
	if ( data )
	{
		if ( currentThumb++ == 4 ) currentThumb = 1;
		changeThumb(); 
	}
}
private function removeTimer():void 
{
	if ( timer )
	{
		timer.removeEventListener( TimerEvent.TIMER, onTimer );
		timer.stop();
		timer = null;
	}
}

private function onTimerComplete( event:TimerEvent ):void
{
	removeTimer();
}
*/
/*private function changeThumb():void
{
	switch ( currentThumb )
	{
		case 1:
			if ( data.urlthumb1 )
			{
				cachedThumbnail = getCachedThumbnail( data.urlthumb1 );
			};
			break;
		case 2:
			if ( data.urlthumb2 )
			{
				cachedThumbnail = getCachedThumbnail( data.urlthumb2 );
			};
			break;
		default:
			if ( data.urlthumb3 )
			{
				cachedThumbnail = getCachedThumbnail( data.urlthumb3 );
			};
			break;
	}
}*/
