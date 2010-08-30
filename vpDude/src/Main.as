
import components.Quit;

import flash.display.InteractiveObject;
import flash.events.NativeWindowDisplayStateEvent;
import flash.globalization.CurrencyFormatter;

import fr.batchass.AIRUpdater;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

private var gb:Singleton = Singleton.getInstance();


	
protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{
	//check for update or update if downloaded
	AIRUpdater.checkForUpdate();
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize);
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
//prevent from maximizing
protected function onWindowMaximize(event:NativeWindowDisplayStateEvent):void
{
	if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED) this.nativeWindow.restore();
	
}
//move window
private function moveWindow( evt:MouseEvent ):void
{
	var clickedElement:String = evt.target.name;
	if ( clickedElement.lastIndexOf( "WindowedApplicationSkin" ) > -1 ) nativeWindow.startMove();
	if ( clickedElement.lastIndexOf( "VGroup" ) > -1 ) nativeWindow.startMove();
}
