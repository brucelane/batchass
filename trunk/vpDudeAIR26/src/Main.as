
import air.net.URLMonitor;
import air.update.events.DownloadErrorEvent;
import air.update.events.StatusUpdateEvent;
import air.update.events.UpdateEvent;

import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;

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
import mx.controls.Alert;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.managers.DragManager;

import videopong.*;

private var monitor:URLMonitor;
public var connected:Boolean;

public var vpDudeFiles:String = "https://www.videopong.net/vpdudefiles/";
public var vpRootUrl:String = "https://www.videopong.net/";
public var vpUrl:String = vpRootUrl + "vpdude/";
public var vpUpUrl:String = vpRootUrl + "vpdudeup/";
// ffmpeg file name depending on OS
private var vpFFMpeg:String;
public var vpFFMpegExePath:String;

[Bindable]
public var vpFullUrl:String = vpUrl;
[Bindable]
public var vpUploadUrl:String = vpUpUrl;
[Bindable]
protected var downloading:Boolean = false;

public var dldFolderPath:String;
public var dbFolderPath:String;
public var os:String;
public var currentVersion:String;
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

/*<fx:Declarations>
	<updater:NativeApplicationUpdater id="updater" 
									  updateURL="https://www.videopong.net/vpdudefiles/update.xml"
									  isNewerVersionFunction="{isNewerFunction}"										  
									  initialized="updater_initializedHandler(event)"
									  updateStatus="updater_updateStatusHandler(event)"										  
									  error="updater_errorHandler(event)"
									  downloadError="updater_errorHandler(event)"
									  updateError="updater_errorHandler(event)"
									  />
</fx:Declarations>*/
//private var updater:NativeApplicationUpdater;

protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{	
	this.validateDisplayList();
	Util.log( "Start", true );
	// autoupdate from Piotr
	//updater.updateURL = "https://www.videopong.net/vpdudefiles/update.xml";
	updater.initialize();
	Util.log( "Check for new version, current: " + updater.currentVersion );
	currentVersion = updater.currentVersion;
	
	this.addEventListener( MouseEvent.MOUSE_DOWN, moveWindow );
	this.addEventListener( NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMaximize );

	//clear log files
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
	os = Capabilities.os.substr(0, 3);
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
	var FFMpegAppFile:File = File.applicationDirectory.resolvePath( 'ffmpeg' + File.separator + vpFFMpeg );
	if( FFMpegAppFile.exists )
	{
		Util.log( "FFMpegAppFile exists: " + FFMpegAppFile.nativePath );
	} 
	else 
	{
		Util.log( "FFMpegAppFile does not exist: " + FFMpegAppFile.nativePath );
	}
	vpFFMpegExePath = FFMpegAppFile.nativePath;
	
	/*var FFMpegFile:File = File.applicationStorageDirectory.resolvePath( 'config' + File.separator + vpFFMpeg );
	
	vpFFMpegExePath = FFMpegFile.nativePath;
	
	if( FFMpegFile.exists )
	{
		Util.log( "FFMpegFile exists: " + FFMpegFile.nativePath );
	} 
	else 
	{
		Util.log( "FFMpegFile does not exist: " + FFMpegFile.nativePath );
		dlFFMpeg( vpDudeFiles + vpFFMpeg );
	}*/
}
/*private function dlFFMpeg( url:String ):void
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
}*/
    
/*private function FFMpegLoadComplete( event:Event ):void
{
	var loader:URLLoader = event.target as URLLoader;
	
	var FFMpegFile:File = File.applicationStorageDirectory.resolvePath( vpFFMpegExePath );
	var stream:FileStream = new FileStream();
	FFMpegFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	stream.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
	stream.open( FFMpegFile, FileMode.WRITE );
	stream.writeBytes( loader.data );
	stream.close();
	// TODO: if mac do chmod
	
}*/

public function addTabs():void 
{ 
	if ( tabNav.numChildren == 4 )
	{
		tabNav.removeChildAt( 3 );//Quit
		tabNav.removeChildAt( 2 );//Donate
		tabNav.removeChildAt( 1 );//About
		tabNav.removeChildAt( 0 );//Config
		search = new Search();
		tabNav.addChild( search );
		tabNav.addChild( new Download() );
		tabNav.addChild( new Upload() );
		tabNav.addChild( new Config() );	
		tabNav.addChild( new About() );	
		tabNav.addChild( new Donate() );	
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
		quit();
	}
	if( event.relatedObject is Donate) 
	{
		navigateToURL( new URLRequest("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=paypal%40toastbrot%2ech&item_name=videopong&no_shipping=1&no_note=1&cn=Optionale%20Mitteilung&tax=0&currency_code=CHF&lc=CH&bn=PP%2dDonationsBF&charset=UTF%2d8") );
	}
	
}
//quit
private function quit():void
{
	for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows) {
		window.close();
	}
	
	NativeApplication.nativeApplication.exit();
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
	if ( clickedElement.lastIndexOf( "HGroup8" ) > -1 ) nativeWindow.startMove();
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

//UpdateBtn.visible = true;
/*protected function localUpdateFile_clickHandler(event:MouseEvent):void
{
var request:URLRequest = new URLRequest(updateFile.nativePath);
navigateToURL(request);
}*/
protected function isNewerFunction(currentVersion:String, updateVersion:String):Boolean
{
	// Example of custom isNewerFunction function, it can be omitted if one doesn't want
	// to implement it's own version comparison logic. Be default it does simple string
	// comparison.
	return ( currentVersion != updateVersion );
}

protected function updater_errorHandler(event:ErrorEvent):void
{
	Alert.show(event.text);
}

protected function updater_initializedHandler(event:UpdateEvent):void
{
	//check for update
	Util.log( "Check now, current: " + updater.currentVersion );
	updater.checkNow();
}
/*protected function btnCheckNow_clickHandler(event:MouseEvent):void
{
	// First initialize NativeApplicationUpdater
	updater.initialize();
}*/
protected function UpdateBtn_clickHandler(event:MouseEvent):void
{
	// In case user wants to download and install update display download progress bar
	// and invoke downloadUpdate() function.
	UpdateBtn.visible = false;
	currentState = "updaterView";
	downloading = true;
	updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
	updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
	updater.downloadUpdate();
}
protected function updater_updateStatusHandler(event:StatusUpdateEvent):void
{
	if (event.available)
	{
		// In case update is available prevent default behavior of checkNow() function 
		// and switch to the view that gives the user ability to decide if he wants to
		// install new version of the application.
		event.preventDefault();
		UpdateBtn.visible = true;
		//currentState = "updaterView";
	}
	/*else
	{
		Alert.show("Your application is up to date!");
	}*/
}

protected function btnYes_clickHandler(event:MouseEvent):void
{
	
	// In case user wants to download and install update display download progress bar
	// and invoke downloadUpdate() function.
	downloading = true;
	updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
	updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
	updater.downloadUpdate();
}

protected function btnNo_clickHandler(event:MouseEvent):void
{
	if ( updater.hasEventListener(DownloadErrorEvent.DOWNLOAD_ERROR ) ) updater.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
	if ( updater.hasEventListener(UpdateEvent.DOWNLOAD_COMPLETE ) ) updater.removeEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
	currentState = "mainView";
}

private function updater_downloadCompleteHandler(event:UpdateEvent):void
{
	// When update is downloaded install it.
	updater.installUpdate();
}

private function updater_downloadErrorHandler(event:DownloadErrorEvent):void
{
	Alert.show("Error downloading update file, try again later.");
}