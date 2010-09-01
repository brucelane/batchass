
import air.net.URLMonitor;

import components.Quit;

import flash.display.InteractiveObject;
import flash.events.NativeWindowDisplayStateEvent;
import flash.globalization.CurrencyFormatter;

import fr.batchass.*;

import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

private var gb:Singleton = Singleton.getInstance();

//monitor the website url
private var monitor:URLMonitor;

private var defaultConfigXmlPath:String = 'videopong' + File.separator + 'config.xml';
[Bindable]
public var vpUrl:String="";

public static var CONFIG_XML:XML;

protected function vpDude_preinitializeHandler(event:FlexEvent):void
{
	try
	{
		var configFile:File = File.documentsDirectory.resolvePath( defaultConfigXmlPath );
		
		if ( !configFile.exists )
		{
			gb.log( "config.xml does not exist" );
			CONFIG_XML = <config />;
		}
		else
		{
			gb.log( "config.xml exists, load the file xml" );
			CONFIG_XML = new XML( readTextFile( configFile ) );
		}
	}
	catch ( e:Error )
	{	
		CONFIG_XML = <config />;
		statusText.text = 'Error loading config.xml file: ' + e.message;
		gb.log( statusText.text );
	}
}
private function writeFolderXmlFile():void
{
	var folderFile:File = File.documentsDirectory.resolvePath( defaultConfigXmlPath );
	// write the text file
	writeTextFile(folderFile, CONFIG_XML);					
}
protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{
	//check for update or update if downloaded
	AIRUpdater.checkForUpdate();
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize);
	urlMonitor( gb.vpUrl );
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
		statusText.text = gb.vpUrl + " is " + ( monitor.available ? "available" : "down" );
		gb.log( statusText.text );
		//monitor.stop();
		//monitor = null;
	}
}
