
import air.net.URLMonitor;

import components.*;

import flash.desktop.NativeApplication;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.InteractiveObject;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.utils.ByteArray;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.managers.DragManager;

import videopong.*;

private var monitor:URLMonitor;
public var connected:Boolean;

public var vpDudeFiles:String = "http://www.videopong.net/vpdudefiles/";
public var vpRootUrl:String = "http://www.videopong.net/";
public var vpUrl:String = vpRootUrl + "vpdude/";
public var vpUpUrl:String = vpRootUrl + "vpdudeup/";
// ffmpeg file name depending on OS
private var vpFFMpeg:String;
public var vpFFMpegExePath:String;

[Bindable]
public var vpFullUrl:String = vpUrl;
[Bindable]
public var vpUploadUrl:String = vpUpUrl;

public var dldFolderPath:String;
public var dbFolderPath:String;

public var search:Search;
public var userName:String;

// path to vpDude folder
private var _vpFolderPath:String;

private  var urlStream:URLStream;
private  var fileStream:FileStream;
private  var _updateUrl:String;
private  var updateFile:File;
private  var downloadUrl:String;

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

protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{
	//check for update or update if downloaded
	//AIRUpdater.checkForUpdate( "http://www.videopong.net/vpdudefiles/" );
	//AIR 2.6
	_updateUrl = "http://www.videopong.net/vpdudefiles/vpDude.xml";
	downloadUpdateDescriptor();
	
	this.validateDisplayList();
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener( NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize );

	//clear log files
	Util.log( "Start", true );
	Util.log( "NativeProcess.isSupported:" + NativeProcess.isSupported );
	Util.errorLog( "Start", true );
	Util.ffMpegErrorLog( "Start", true );
	Util.ffMpegMovieErrorLog( "Start", true );
	Util.ffMpegOutputLog( "Start", true );
	Util.cacheLog( "Start", true );
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
	//vpFFMpegExePath = FFMpegFile.url;
	vpFFMpegExePath = FFMpegFile.nativePath;
	
	if( FFMpegFile.exists )
	{
		Util.log( "FFMpegFile exists: " + FFMpegFile.nativePath );
	} 
	else 
	{
		Util.log( "FFMpegFile does not exist: " + FFMpegFile.nativePath );
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
		loader.addEventListener( ErrorEvent.ERROR, errorEventErrorHandler );
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.load(req);
}
    
private function FFMpegLoadComplete( event:Event ):void
{
	var loader:URLLoader = event.target as URLLoader;
	
	var FFMpegFile:File = File.applicationStorageDirectory.resolvePath( vpFFMpegExePath );
	var stream:FileStream = new FileStream();
	FFMpegFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	stream.open( FFMpegFile, FileMode.WRITE );
	stream.writeBytes( loader.data );
	stream.close();
}

public function addTabs():void 
{ 
	if ( tabNav.numChildren == 3 )
	{
		tabNav.removeChildAt( 2 );//Quit
		tabNav.removeChildAt( 1 );//About
		tabNav.removeChildAt( 0 );//Config
		search = new Search();
		tabNav.addChild( search );
		tabNav.addChild( new Download() );
		tabNav.addChild( new Upload() );
		tabNav.addChild( new Config() );	
		tabNav.addChild( new About() );	
		tabNav.addChild( new Quit() );	
		// load tagsFile when config is done
		var tags:Tags = Tags.getInstance();
		tags.dbPath = dbFolderPath;
		tags.loadTagsFile();
		// load clipsFile when config is done
		var clips:Clips = Clips.getInstance();
		clips.dbPath = dbFolderPath;
		clips.loadClipsFile();
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
		connected = monitor.available;
		statusText.text = vpRootUrl +  ( connected ? " is available" : " could not be reached" );
		Util.log( statusText.text );

		trace( tabNav.numChildren );	
		if ( connected ) 
		{
			if ( tabNav.numChildren == 4 )
			{
				tabNav.removeChildAt( 3 );//Quit
				tabNav.removeChildAt( 2 );//About
				tabNav.removeChildAt( 1 );//Config
				tabNav.addChild( new Download() );
				tabNav.addChild( new Upload() );
				tabNav.addChild( new Config() );	
				tabNav.addChild( new About() );	
				tabNav.addChild( new Quit() );	
			}
		}
		else
		{
			if ( tabNav.numChildren == 6 )
			{
				tabNav.removeChildAt( 5 );//Quit
				tabNav.removeChildAt( 4 );//About
				tabNav.removeChildAt( 3 );//Config
				tabNav.removeChildAt( 2 );//Upload
				tabNav.removeChildAt( 1 );//Download
				tabNav.addChild( new Config() );	
				tabNav.addChild( new About() );	
				tabNav.addChild( new Quit() );	
			}
			
		}	
	}
}
//AIR 2.6
protected  function downloadUpdateDescriptor():void
{
	Util.log( "appUpdater,downloadUpdateDescriptor" ); 
	var updateDescLoader:URLLoader = new URLLoader();
	updateDescLoader.addEventListener(Event.COMPLETE, updateDescLoader_completeHandler);
	updateDescLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	updateDescLoader.load(new URLRequest(_updateUrl));
}
protected  function updateDescLoader_completeHandler(event:Event):void
{
	Util.log( "appUpdater,updateDescLoader_completeHandler" ); 
	var loader:URLLoader = URLLoader(event.currentTarget);
	
	// Closing update descriptor loader
	//closeUpdateDescLoader(loader);
	
	// Getting update descriptor XML from loaded data
	var updateDescriptor:XML = XML(loader.data);
	// Getting default namespace of update descriptor
	var udns:Namespace = updateDescriptor.namespace();
	
	// Getting application descriptor XML
	var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
	// Getting default namespace of application descriptor
	var adns:Namespace = applicationDescriptor.namespace();
	
	// Getting versionNumber from update descriptor
	var updateVersion:String = updateDescriptor.udns::versionNumber.toString();
	// Getting versionNumber from application descriptor
	var currentVersion:String = applicationDescriptor.adns::versionNumber.toString();
	Util.log( "appUpdater,updateDescLoader_completeHandler, updateVersion: " + updateVersion ); 
	Util.log( "appUpdater,updateDescLoader_completeHandler, currentVersion: " + currentVersion ); 
	
	// Comparing current version with update version
	if (currentVersion != updateVersion)
	{
		// Getting update url
		var os:String = Capabilities.os.substr(0, 3);
		if (os == "Win") 
		{
			downloadUrl = updateDescriptor.udns::url.toString() + "exe";
		} 
		else if (os == "Mac") 
		{
			downloadUrl = updateDescriptor.udns::url.toString() + "dmg";
		} 
		else 
		{
			downloadUrl = updateDescriptor.udns::url.toString() + "exe"; //KO: linux extension?
		}
		UpdateBtn.visible = true;
		
	}
}
protected function UpdateBtn_clickHandler(event:MouseEvent):void
{
	switch (UpdateBtn.label)
	{
		case "Update available!":
			UpdateBtn.label = "Downloading...";
			UpdateBtn.toolTip = "Please wait...";

			// Downloading update file
			downloadUpdate(downloadUrl);
			break;
		case "Downloading...":
			
			break;
		case "Show setup folder":
			// Installing update
			installUpdate();
			break;
		default:
			Util.log( "appUpdater,UpdateBtn_clickHandler: undefined state: "  + UpdateBtn.label); 
			break;
	}
}
protected  function downloadUpdate(updateUrl:String):void
{
	// Parsing file name out of the download url
	var fileName:String = updateUrl.substr(updateUrl.lastIndexOf("/") + 1);
	Util.log( "appUpdater,downloadUpdate, fileName: " + fileName ); 
	
	// Creating new file ref in temp directory
	updateFile = File.applicationStorageDirectory.resolvePath(fileName);
	Util.log( "appUpdater,downloadUpdate, updateFile: " + updateFile.nativePath ); 
	
	// Using URLStream to download update file
	urlStream = new URLStream;
	urlStream.addEventListener(Event.OPEN, urlStream_openHandler);
	urlStream.addEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
	urlStream.addEventListener(Event.COMPLETE, urlStream_completeHandler);
	//urlStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
	urlStream.load(new URLRequest(updateUrl));
}
protected  function urlStream_openHandler(event:Event):void
{
	Util.log( "appUpdater, urlStream_openHandler" ); 
	// Creating new FileStream to write downloaded bytes into
	fileStream = new FileStream;
	fileStream.open(updateFile, FileMode.WRITE);
}
protected  function urlStream_progressHandler(event:ProgressEvent):void
{
	Util.log( "appUpdater, urlStream_progressHandler" ); 
	// ByteArray with loaded bytes
	var loadedBytes:ByteArray = new ByteArray;
	// Reading loaded bytes
	urlStream.readBytes(loadedBytes);
	// Writing loaded bytes into the FileStream
	fileStream.writeBytes(loadedBytes);
}
protected  function urlStream_completeHandler(event:Event):void
{
	Util.log( "appUpdater, urlStream_completeHandler" ); 
	// Closing URLStream and FileStream
	//closeStreams();
	UpdateBtn.label = "Show setup folder";
	UpdateBtn.toolTip = "Please show folder and then exit vpDude to proceed to setup...";
}
protected  function installUpdate():void
{
	try
	{
		Util.log( "appUpdater, installUpdate" ); 
		Util.log( "appUpdater, installUpdate, updateFile: " + updateFile.nativePath ); 
		var localUrl:String = "file://" + updateFile.nativePath;
		var localExeFolder:String = localUrl.substr(0, localUrl.lastIndexOf("/") );
		
		navigateToURL(new URLRequest(localExeFolder));
		// Running the installer using NativeProcess API
		var info:NativeProcessStartupInfo = new NativeProcessStartupInfo;
		info.executable = updateFile;
		
		//localUpdateFile.label = updateFile.url; 
		//localUpdateFile.visible = true;
		
		var process:NativeProcess = new NativeProcess();
		process.start(info);
		Util.log( "appUpdater, installUpdate, process started" ); 
		
		// Exit application for the installer to be able to proceed
		for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows) 
		{
			window.close();
		}
		Util.log( "appUpdater,installUpdate, exit" ); 
		NativeApplication.nativeApplication.exit();
	}
	catch (e:Error)
	{
		Util.log( "appUpdater, installUpdate Error: " + e.message );
		//NativeApplication.nativeApplication.exit();
	}
}
protected function localUpdateFile_clickHandler(event:MouseEvent):void
{
	var request:URLRequest = new URLRequest(updateFile.nativePath);
	navigateToURL(request);
}
public function errorEventErrorHandler(event:ErrorEvent):void
{
	Util.log( 'An ErrorEvent has occured: ' + event.text );
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