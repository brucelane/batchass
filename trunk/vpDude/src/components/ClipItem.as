import flash.display.BitmapData;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import fr.batchass.*;
import mx.core.Application;
import mx.core.FlexGlobals;
import spark.components.TextInput;
import videopong.*;

private var currentThumb:uint = 1;
private var timer:Timer;

/*[Bindable]
private var cachedThumbnail:String;*/
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
private var tags:Tags;
// get instance of Clips class
private var clips:Clips;

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
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
	if ( event.keyCode == 27 )
	{
		//remove textInput
		tagTextInput.removeEventListener( KeyboardEvent.KEY_DOWN, checkTagInput );
		this.removeElement( tagTextInput );
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

}
protected function imgUrl_mouseOutHandler( event:MouseEvent ):void
{

}
