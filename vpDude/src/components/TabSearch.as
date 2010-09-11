import com.hillelcoren.components.AutoComplete;

import fr.batchass.*;

import mx.collections.XMLListCollection;
import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

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
	//var tag:ArrayCollection = autoComplete.selectedItems;
	var tag:Object = autoComplete.selectedItem;
	
	if ( tag )
	{
		trace( "selected tag:", tag );
		//parentDocument.selectedClipsXMLList = new XMLListCollection( parentDocument.CLIPS_XML.video.(@tag==tag) );

	}				
}
protected function search_creationCompleteHandler(event:FlexEvent):void
{
	autoComplete.setStyle( "selectedItemStyleName", AutoComplete.STYLE_FACEBOOK );
}
