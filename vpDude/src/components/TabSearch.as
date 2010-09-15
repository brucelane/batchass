import com.hillelcoren.components.AutoComplete;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

import videopong.Tags;

private var isConfigured:Boolean = false;

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
	parentDocument.filterTags( autoComplete.selectedItems );
	//var tag:Object = autoComplete.selectedItem;			
}
protected function search_creationCompleteHandler(event:FlexEvent):void
{
	autoComplete.setStyle( "selectedItemStyleName", AutoComplete.STYLE_FACEBOOK );
	var tags:Tags = Tags.getInstance();
	autoComplete.dataProvider= tags.tagsXMLList;
	autoComplete.labelField="@name";
}
