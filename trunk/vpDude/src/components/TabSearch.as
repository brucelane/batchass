import com.hillelcoren.components.AutoComplete;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

import videopong.*;

private var isConfigured:Boolean = false;
[Bindable]
private	var clips:Clips = Clips.getInstance();

private function handleButtonClick():void
{
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
	var tags:Tags = Tags.getInstance();
	autoComplete.dataProvider = tags.tagsXMLList;
	//autoComplete.labelField = "@name";
	//clipList.dataProvider = clips.clipsXMLList;
	clipList.labelField = "@name";
}
