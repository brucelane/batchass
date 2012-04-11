import com.hillelcoren.components.AutoComplete;

import flash.events.*;
import flash.utils.Timer;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

import videopong.*;

private var isConfigured:Boolean = false;
[Bindable]
private	var clips:Clips = Clips.getInstance();
[Bindable]
private var tags:Tags = Tags.getInstance();

private var timer:Timer;

private function timerFct(event:Event):void
{
	applyLabel.text = "";
	timer.stop();
	//tags.resyncTags();
}
private function handleButtonClick():void
{
	autoComplete.dataProvider = tags.tagsXMLList;
    if (autoComplete.isDropDownVisible())
    {
        autoComplete.hideDropDown();
    }
    else
    {
        autoComplete.search();
        autoComplete.showDropDown();
    }
}
private function handleAutoCompleteChange():void
{
	clips.filterTags( autoComplete.selectedItems );		
}
protected function search_creationCompleteHandler(event:FlexEvent):void
{
	autoComplete.setStyle( "selectedItemStyleName", AutoComplete.STYLE_FACEBOOK );
	autoComplete.dataProvider = tags.tagsXMLList;
	tagAutoComplete.setStyle( "selectedItemStyleName", AutoComplete.STYLE_FACEBOOK );
	tagAutoComplete.dataProvider = tags.tagsXMLList;
	
	clipList.labelField = "@name";
	timer = new Timer(2500);
	timer.addEventListener(TimerEvent.TIMER, timerFct);

}
private function handleTagButtonClick():void
{	
	tagAutoComplete.dataProvider = tags.tagsXMLList;
	if ( tagAutoComplete.isDropDownVisible() )
	{
		tagAutoComplete.hideDropDown();
	}
	else
	{
		tagAutoComplete.search();
		tagAutoComplete.showDropDown();
	}
	
}
protected function tabSearchApplyBtn_clickHandler(event:MouseEvent):void
{
	var tagsChanged:Boolean = false;
	if ( tagAutoComplete.data )
	{
		applyLabel.text = "Tags updating...";
		// write tags to clip and tags XML
		clips = Clips.getInstance();
		//get tags of clip
		var clipTagList:XMLList = clips.getTags( tagAutoComplete.data.@id );
		//try to delete tags if removed
		for each ( var clipTagToRemoveIfNotFound:XML in clipTagList )
		{
			var tagHasBeenFound:Boolean = false;
			for each ( var t:String in tagAutoComplete.selectedItems )
			{
				if ( clipTagToRemoveIfNotFound.@name == t )
				{
					tagHasBeenFound = true;	
				}
			}
			if ( !tagHasBeenFound )
			{
				//remove existing tags
				clips.removeTags( tagAutoComplete.data.@id );//resets search view!!!				
			}
		}
		//try to add tags if new
		for each ( var tag:String in tagAutoComplete.selectedItems )
		{
			if ( !tagsChanged )
			{
				var tagFound:Boolean = false;
				tag = tag.toLowerCase();
				for each ( var clipTag:XML in clipTagList )
				{
					//test if own file
					if ( clipTag.@name == tag )
					{
						tagFound = true;	
					}	 	
					else
					{
						
					}
				}
				if ( !tagFound )
				{
					tagsChanged = true;			
					clips.addTagIfNew( tag, tagAutoComplete.data.@id, false );//resets search view!!!
				}
			}
		}
		/*if ( tagsChanged )
		{
			//remove existing tags
			clips.removeTags( tagAutoComplete.data.@id );//resets search view!!!
			//loop in tags and add them to XML db
			for each ( var oneTag:String in tagAutoComplete.selectedItems )
			{
				oneTag = oneTag.toLowerCase();
				// tags = Tags.getInstance();
				// if tag not already in global tags, add it
				// done in clips.addTagIfNew: tags.addTagIfNew( oneTag, false );//no reset:ok
				
				//test if tag is not already in clip
				clips.addTagIfNew( oneTag, tagAutoComplete.data.@id, false );//resets search view!!!
			}
			// remove applyLabel message and resyncTags
		}*/
		timer.start();		
	}
}	
