
import air.net.URLMonitor;

import components.*;

import flash.display.InteractiveObject;
import flash.events.NativeWindowBoundsEvent;
import flash.globalization.LastOperationStatus;
import flash.system.Capabilities;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.managers.DragManager;

import videopong.Tags;

private var monitor:URLMonitor;

public var vpDudeFiles:String = "http://www.videopong.net/vpdudefiles/";
public var vpRootUrl:String = "http://www.videopong.net/";
public var vpUrl:String = vpRootUrl + "vpdude/";
public var vpUpUrl:String = vpRootUrl + "vpdudeup/";
// ffmpeg file name depending on OS
private var vpFFMpeg:String;

[Bindable]
public var vpFullUrl:String = vpUrl;
[Bindable]
public var vpUploadUrl:String = vpUpUrl;

public var dldFolderPath:String;
public var dbFolderPath:String;

public var CLIPS_XML:XML = <videos /> ;
// Collection of all the clips
public var clipsXMLList:XMLListCollection = new XMLListCollection(CLIPS_XML.video);

private var clipsXmlPath:String;
public var cache:CacheManager;
private var _acFilter:ArrayCollection;

// path to vpDude folder
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
// path to own videos folder
private var _ownFolderPath:String;
[Bindable]
public function get ownFolderPath():String
{
	return _ownFolderPath;
}

private function set ownFolderPath(value:String):void
{
	_ownFolderPath = value;
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
	this.addEventListener( NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize );

	urlMonitor( vpRootUrl );
	checkFFMpeg();
}

private function checkFFMpeg():void
{
	// determine OS to download right ffmpeg
	var os:String = Capabilities.os.substr(0, 3);
	if (os == "Win") 
	{
		vpFFMpeg = "ffmpeg.exe";
	} 
	else if (os == "Mac") 
	{
		vpFFMpeg = "ffmpeg.dat";
	} 
	else 
	{
		vpFFMpeg = "ffmpeg.lame"; 
	}
	
	var FFMpegFile:File = File.applicationStorageDirectory.resolvePath( 'config' + File.separator + vpFFMpeg );
	
	if( FFMpegFile.exists )
	{
		Util.log( "FFMpegFile exists: " + FFMpegFile.url );
	} 
	else 
	{
		Util.log( "FFMpegFile does not exist: " + FFMpegFile.url );
		dlFFMpeg( vpDudeFiles + vpFFMpeg );
	}
}
private function dlFFMpeg( url:String ):void
{
		var req:URLRequest = new URLRequest(url);
		var loader:URLLoader = new URLLoader();
		loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
		loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
		loader.addEventListener( Event.COMPLETE, FFMpegLoadComplete );
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.load(req);

}
private function FFMpegLoadComplete( event:Event ):void
{
	var loader:URLLoader = event.target as URLLoader;
	//var FFMpegFile:File = File.applicationStorageDirectory.resolvePath( 'config' + File.separator + vpFFMpeg );
	
	var FFMpegFile:File = File.applicationStorageDirectory.resolvePath( 'config' + File.separator + vpFFMpeg );
	var stream:FileStream = new FileStream();
	FFMpegFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	stream.open( FFMpegFile, FileMode.WRITE );
	stream.writeBytes( loader.data );
	stream.close();
}

public function addTabs():void 
{ 
	if ( tabNav.numChildren == 2 )
	{
		tabNav.removeChildAt( 1 );//Quit
		tabNav.removeChildAt( 0 );//Config
		tabNav.addChild( new Search() );
		tabNav.addChild( new Config() );	
		tabNav.addChild( new Download() );
		tabNav.addChild( new Upload() );
		tabNav.addChild( new Quit() );	
		// load tagsFile when config is done
		var tags:Tags = Tags.getInstance();
		tags.dbPath = dbFolderPath;
		tags.loadTagsFile();
		loadClipsFile();
		// this.addEventListener( DragEvent.DRAG_ENTER, onDragEnter );
		// this.addEventListener( DragEvent.DRAG_DROP, onDragDrop );
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
				isConfigured = true;
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
}
// write one clip xml fole in db
public function writeClipXmlFile( clipId:String, clipXml:XML ):void
{
	var localClipXMLFile:String = parentDocument.dbFolderPath + File.separator + clipId + ".xml" ;
	var clipXmlFile:File = new File( localClipXMLFile );
	
	// write the text file
	writeTextFile( clipXmlFile, clipXml );					
}
public function addNewClip( clipId:String, clipXml:XML ):void
{
	CLIPS_XML.appendChild( clipXml );
	writeClipsFile();	
	writeClipXmlFile( clipId, clipXml );
	
}
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
	var clipTags:String = "";// = item..@name;
	
	for each ( var oneTag:XML in item..tag )
	{
		clipTags += oneTag.@name + "|";
	}
	for each ( currentTag in _acFilter ) 
	{
		trace( "cur:" + currentTag );
		if ( clipTags.indexOf( currentTag ) > -1 ) nbFound++;
	}
	if ( nbFound >= _acFilter.length ) isMatch = true;
	trace ( item..@name );
	return isMatch;
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
		statusText.text = vpRootUrl +  ( monitor.available ? " is available" : " could not be reached" );
		Util.log( statusText.text );

		trace( tabNav.numChildren );	
		if ( monitor.available ) 
		{
			if ( tabNav.numChildren == 3 )
			{
				tabNav.removeChildAt( 2 );//Quit
				tabNav.addChild( new Download() );
				tabNav.addChild( new Upload() );
				tabNav.addChild( new Quit() );	
			}
		}
		else
		{
			if ( tabNav.numChildren == 5 )
			{
				tabNav.removeChildAt( 4 );//Quit
				tabNav.removeChildAt( 3 );//Upload
				tabNav.removeChildAt( 2 );//Download
				tabNav.addChild( new Quit() );	
			}
			
		}	
	}
}
public function onDragEnter(event:DragEvent):void
{
	if(event.dragSource.hasFormat("air:file list"))
	{
		DragManager.acceptDragDrop(this);
	}
	else
	{
		statusText.text = 'Format not supported, please drop file(s).';
	}
}
public function onDragDrop(event:DragEvent):void
{
	trace("onDragDrop" );
	var fileToUpload:File;
	var itemsArray:Array = event.dragSource.dataForFormat("air:file list") as Array;
	if(itemsArray != null)
	{
		//TODO
	}
	statusText.text = "Dropped file(s) added."
}
public function ioErrorHandler( event:IOErrorEvent ):void
{
	Util.log( 'An IO Error has occured: ' + event.text );
}    
// only called if a security error detected by flash player such as a sandbox violation
public function securityErrorHandler( event:SecurityErrorEvent ):void
{
	Util.log( "securityErrorHandler: " + event.text );
}		
//  after a file upload is complete or attemted the server will return an http status code, code 200 means all is good anything else is bad.
public function httpStatusHandler( event:HTTPStatusEvent ):void 
{  
	Util.log( "httpStatusHandler, status(200 is ok): " + event.status );
}