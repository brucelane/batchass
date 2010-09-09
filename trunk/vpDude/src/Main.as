
import air.net.URLMonitor;

import components.*;

import flash.display.InteractiveObject;
import flash.events.NativeWindowDisplayStateEvent;

import fr.batchass.*;

import mx.collections.XMLListCollection;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

//monitor the website url
private var monitor:URLMonitor;

public var vpRootUrl:String = "http://www.videopong.net/";
public var vpUrl:String = vpRootUrl + "vpdude/";

[Bindable]
public var vpFullUrl:String = vpUrl;

public var dldFolderPath:String;
public var dbFolderPath:String;

public var TAGS_XML:XML = <tags> 
							<tag>batchass</tag>
							<tag>cool</tag>
							<tag>videopong</tag>
						 </tags>;
public var CLIPS_XML:XML = <clips> 
							<clip description="batchassclip">
								<tag>batchass</tag>
								<clipname>Batchass</clipname>
								<urlthumb1>http://img.videopong.net/0d96vvdmvfk/thumb1.jpg</urlthumb1>
							</clip>
							<clip description="videopongclip">
								<tag>videopong</tag>
								<clipname>Videopong</clipname>
								<urlthumb1>http://img.videopong.net/0d96vvdmvfk/thumb2.jpg</urlthumb1>
							</clip>
							
						 </clips>;
[Bindable]
public var tagsXMLList:XMLListCollection = new XMLListCollection(TAGS_XML.tag);
[Bindable]
public var clipXMLList:XMLListCollection = new XMLListCollection(CLIPS_XML.clip);

public var cache:CacheManager;

private var _vpFolderPath:String;
[Bindable]
public function get vpFolderPath():String
{
	return _vpFolderPath;
}

private function set vpFolderPath(value:String):void
{
	_vpFolderPath = value;
	dldFolderPath = _vpFolderPath + File.separator + "dld";
	dbFolderPath = _vpFolderPath + File.separator + "db";
}


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
		statusText.text = vpRootUrl + " is " + ( monitor.available ? "available" : "could not be reached" );
		Util.log( statusText.text );
		//monitor.stop();
		//monitor = null;
	}
}
