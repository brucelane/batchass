
import air.net.URLMonitor;

import components.*;

import flash.display.InteractiveObject;
import flash.events.NativeWindowDisplayStateEvent;
import flash.globalization.LastOperationStatus;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

private var monitor:URLMonitor;

public var vpRootUrl:String = "http://www.videopong.net/";
public var vpUrl:String = vpRootUrl + "vpdude/";

[Bindable]
public var vpFullUrl:String = vpUrl;

public var dldFolderPath:String;
public var dbFolderPath:String;

public var TAGS_XML:XML = <tags>
							<tag name="none"/>
						  </tags>;
public var CLIPS_XML:XML = <videos /> ;
// Collection of tags
[Bindable]
public var tagsXMLList:XMLListCollection = new XMLListCollection(TAGS_XML.tag.@name);
// Collection of selected videos for search tab
/*[Bindable]
public var selectedClipsXMLList:XMLListCollection = new XMLListCollection(CLIPS_XML.video);*/
// Collection of all the clips
public var clipsXMLList:XMLListCollection = new XMLListCollection(CLIPS_XML.video);

private var tagsXmlPath:String;
private var clipsXmlPath:String;
public var cache:CacheManager;
private var _acFilter:ArrayCollection;

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
		tabNav.removeChildAt( 0 );//Config
		tabNav.addChild( new Search() );
		tabNav.addChild( new Download() );
		tabNav.addChild( new Config() );	
		tabNav.addChild( new Quit() );	
		// load tagsFile when config is done
		loadTagsFile();
		loadClipsFile();
	}
}

public function loadClipsFile():void 
{
	clipsXmlPath = parentDocument.dbFolderPath + File.separator + "clips.xml";
	var isConfigured:Boolean = false;
	var clipsFile:File = File.applicationStorageDirectory.resolvePath( clipsXmlPath );
	try
	{
		
		if ( !clipsFile.exists )
		{
			Util.log( "clips.xml does not exist" );
		}
		else
		{
			Util.log( "clips.xml exists, load the file xml" );
			CLIPS_XML = new XML( readTextFile( clipsFile ) );
			if ( CLIPS_XML..video.length() )
			{
				trace("OK:"+CLIPS_XML.videos);
				isConfigured = true;
			}
			else
			{
				trace("KO:"+CLIPS_XML.videos);
				
			}
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading clips.xml file: ' + e.message;
		statusText.text = msg;
		Util.log( msg );
	}
	if ( !isConfigured )
	{
		CLIPS_XML = <videos />;
		writeClipsFile();
	}
	refreshClipsXMLList();
}
public function writeClipsFile():void 
{
	clipsXmlPath = parentDocument.dbFolderPath + File.separator + "clips.xml";
	var clipsFile:File = File.applicationStorageDirectory.resolvePath( clipsXmlPath );
	refreshClipsXMLList();

	// write the text file
	writeTextFile( clipsFile, CLIPS_XML );					
}
public function refreshClipsXMLList():void 
{
	clipsXMLList = new XMLListCollection( CLIPS_XML.video );
	//selectedClipsXMLList = new XMLListCollection( CLIPS_XML.video );
}
/*private function filterFunc(item:Object):Boolean {
	return item.@name="kultur";
}*/

public function filterTags( acFilter:ArrayCollection ):void 
{
	_acFilter = acFilter;
	if ( acFilter.length == 0 ) {
		clipsXMLList.filterFunction = null;
	} else {
		clipsXMLList.filterFunction = xmlListColl_filterFunc;
	}
	clipsXMLList.refresh();
}

private function xmlListColl_filterFunc(item:Object):Boolean 
{
	var isMatch:Boolean = false;
	var currentTag:String;
	var nbFound:uint = 0;
	var clipTags:String = item..@name;
	for each ( currentTag in _acFilter ) 
	{
		trace( "cur:" + currentTag );
		if ( clipTags.indexOf( currentTag ) > -1 ) nbFound++;
	}
	if ( nbFound >= _acFilter.length ) isMatch = true;
	trace ( item..@name );
	return isMatch;
}

public function loadTagsFile():void 
{
	tagsXmlPath = parentDocument.dbFolderPath + File.separator + "tags.xml";
	var isConfigured:Boolean = false;
	var tagsFile:File = File.applicationStorageDirectory.resolvePath( tagsXmlPath );
	try
	{
		
		if ( !tagsFile.exists )
		{
			Util.log( "tags.xml does not exist" );
		}
		else
		{
			Util.log( "tags.xml exists, load the file xml" );
			TAGS_XML = new XML( readTextFile( tagsFile ) );
			if ( TAGS_XML..tag.length() )
			{
				isConfigured = true;
			}
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading tags.xml file: ' + e.message;
		statusText.text = msg;
		Util.log( msg );
	}
	if ( !isConfigured )
	{
		TAGS_XML = <tags />;
		writeTagsFile();
	}
	refreshTagsXMLList();
}
public function writeTagsFile():void 
{
	tagsXmlPath = parentDocument.dbFolderPath + File.separator + "tags.xml";
	var tagsFile:File = File.applicationStorageDirectory.resolvePath( tagsXmlPath );
	refreshTagsXMLList();

	// write the text file
	writeTextFile( tagsFile, TAGS_XML );					
}
public function refreshTagsXMLList():void 
{
	tagsXMLList = new XMLListCollection( TAGS_XML.tag.@name );
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
	}
}
