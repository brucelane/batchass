
import components.Quit;

import flash.display.InteractiveObject;
import flash.globalization.CurrencyFormatter;

import fr.batchass.AIRUpdater;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

public var password:String = "none";
protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{
	//check for update or update if downloaded
	AIRUpdater.checkForUpdate();
	
}

protected function tabNav_changeHandler(event:IndexChangedEvent):void
{
	//quit = tab4
	if ( event.newIndex == 4 )
	{
		for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows) {
			window.close();
		}
		
		NativeApplication.nativeApplication.exit();
	}
	
}
