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
[Bindable]
private var tags:Tags = Tags.getInstance();

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
	
	clipList.labelField = "@name";
}
