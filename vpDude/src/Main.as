
import air.net.URLMonitor;

import components.*;

import flash.display.InteractiveObject;
import flash.events.NativeWindowDisplayStateEvent;
import flash.globalization.CurrencyFormatter;

import fr.batchass.*;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

private var gb:Singleton = Singleton.getInstance();

//monitor the website url
private var monitor:URLMonitor;

public var vpUrl:String = "http://www.videopong.net/vpdude/";
public var vpRootUrl:String = "http://www.videopong.net/";


[Bindable]
public var vpFullUrl:String = vpUrl;


protected function vpDude_preinitializeHandler(event:FlexEvent):void
{
	
}

protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{
	//check for update or update if downloaded
	AIRUpdater.checkForUpdate();

	this.validateDisplayList();
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize);
	urlMonitor( vpRootUrl );
}
public function addTabs():void 
{
	if ( tabNav.numChildren == 2 )
	{
		tabNav.removeChildAt( 1 );//Quit
		tabNav.removeChildAt( 0 );
		tabNav.addChild( new Search() );
		tabNav.addChild( new Download() );
		tabNav.addChild( new Config() );	
		tabNav.addChild( new Quit() );	
		//tabNav.addChildAt( new Search(), 0 );
		//tabNav.addChildAt( new Download(), 1 );
		//tabNav.addChildAt( new Upload(), 3 );	
	}
}

protected function tabNav_changeHandler(event:IndexChangedEvent):void
{
	if( event.relatedObject is Quit) 
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
private function urlMonitor(url:String):void 
{
	// URLRequest that the Monitor Will Check
	var urlRequest:URLRequest = new URLRequest( url );
	// Checks Only the Headers - Not the Full Page
	urlRequest.method = "HEAD";
	// Create the URL Monitor and Pass it the URLRequest
	monitor = new URLMonitor( urlRequest );
	// Add Our Event Listener to Respond the a Change in Connection Status
	monitor.addEventListener( StatusEvent.STATUS, onMonitor );
	// Start the URLMonitor
	monitor.start();	
	// Set the Interval (in ms) - 10000 = 10 Seconds
	monitor.pollInterval = 10000;
}
private function onMonitor(event:StatusEvent):void 
{
	if ( monitor )
	{
		statusText.text = vpRootUrl + " is " + ( monitor.available ? "available" : "down" );
		Util.log( statusText.text );
		//monitor.stop();
		//monitor = null;
	}
}
