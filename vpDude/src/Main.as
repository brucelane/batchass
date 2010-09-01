
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

private var defaultConfigXmlPath:String = 'videopong' + File.separator + 'config.xml';
private var vpUrl:String = "http://www.videopong.net/vpdude/";

[Bindable]
public var userName:String = "guest";
[Bindable]
public var password:String = "none";
[Bindable]
public var vpFullUrl:String = vpUrl + "?login=" + userName + "&password=" + password;

private var isConfigured:Boolean = false;

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
			isConfigured = true;
		}
	}
	catch ( e:Error )
	{	
		CONFIG_XML = <config />;
		statusText.text = 'Error loading config.xml file: ' + e.message;
		gb.log( statusText.text );
	}
}
public function addTabs():void 
{
	tabNav.addChild( new Search() );
	tabNav.addChild( new Download() );
	tabNav.addChild( new Config() );
	tabNav.addChild( new Upload() );
	tabNav.addChild( new Quit() );
	parentDocument.tabNav.removeChildAt( 1 );
	parentDocument.tabNav.removeChildAt( 0 );
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
	if ( isConfigured )
	{
		addTabs();
	}
	else
	{
		tabNav.addChild( new Config() );
		//tabNav.removeChildAt( 0 );
		tabNav.addChild( new Quit() );
	}
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize);
	urlMonitor( vpUrl );
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
		statusText.text = vpUrl + " is " + ( monitor.available ? "available" : "down" );
		gb.log( statusText.text );
		//monitor.stop();
		//monitor = null;
	}
}
