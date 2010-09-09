import fr.batchass.*;

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

protected function search_creationCompleteHandler(event:FlexEvent):void
{

}
