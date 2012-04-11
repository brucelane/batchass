import components.*;

import flash.events.*;
import flash.filesystem.File;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.Timer;

import flashx.textLayout.events.StatusChangeEvent;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

import videopong.Clips;
import videopong.Tags;

[Bindable]
private var ownFiles:ArrayCollection;

private var defaultConfigXmlPath:String = 'config' + File.separator + '.vpDudeConfig';

[Bindable]
private var lblWidth:int = 180;
[Bindable]
private var tiWidth:int = 350;

private var isConfigured:Boolean = false;

[Bindable]
public var userName:String = "";
[Bindable]
private var hiddenPassword:String = "";
[Bindable]
private var vpDbPath:String = "";
/*[Bindable]
private var showProgress:Boolean = false;*/
[Bindable]
private var status:String = "";
[Bindable]
private var countNew:String = "";
[Bindable]
private var countChanged:String = "";
[Bindable]
private var countDeleted:String = "";
[Bindable]
private var countNoChange:String = "";
[Bindable]
private var countError:String = "";
[Bindable]
private var summary:String = "";
[Bindable]
private var progress:String = "";
[Bindable]
private var frame:String = "";

private var password:String = "";
private var passwordChanged:Boolean = false;


public static var CONFIG_XML:XML;
private var validExtensions:Array = ["avi", "mov", "mp4", "flv", "qt", "swf", "mpeg", "mpg", "h264"];

[Bindable]
private var cnv:Convertion = Convertion.getInstance(); 
[Bindable]
private var session:Session = Session.getInstance();

private var timer:Timer;

protected function config_preinitializeHandler(event:FlexEvent):void
{
	try
	{
		var configFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
		
		if ( !configFile.exists )
		{
			Util.log( "config.xml does not exist" );
		}
		else
		{
			Util.log( "config.xml exists, load the file xml" );
			CONFIG_XML = new XML( readTextFile( configFile ) );
			
			userName = CONFIG_XML..username[0].toString();
			session.userName = userName;
			password = CONFIG_XML..pwd[0].toString();
			for ( var i:uint = 0; i < password.length; i++ )
			{
				hiddenPassword += "*";
			}
			cnv.reso = CONFIG_XML..reso[0].toString();
			session.vpFolderPath = File.applicationStorageDirectory.nativePath;
		
			vpDbPath = session.vpFolderPath;
			session.ownFolderPath = CONFIG_XML..own[0].toString();
			isConfigured = true;
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading config.xml file: ' + e.message;
		parentDocument.statusText.text = msg;
		Util.log( msg );
	}
	createEncodedVars();

}
private function createEncodedVars():void
{
	var fullUrlToEncode:String = session.vpUrl + "?login=" + escape(userName) + "&password=" + escape(password);
	var fullUpUrlToEncode:String = session.vpUpUrl + "?login=" + escape(userName) + "&password=" + escape(password);
	session.vpFullUrl = fullUrlToEncode;
	session.vpUploadUrl = fullUpUrlToEncode;

}
protected function config_creationCompleteHandler(event:FlexEvent):void
{
	if ( isConfigured )
	{
		Util.log( "config_creationCompleteHandler, isConfigured is true" );
		Util.log( "config_creationCompleteHandler, parentDocument: " + parentDocument );
		if (parentDocument )
		{	
			parentDocument.addTabs();
		}
		else
		{
			Util.log( "config_creationCompleteHandler, parentDocument is null, when no internet cnx..." );		
		}
	}
	else
	{
		session.vpFolderPath = File.documentsDirectory.resolvePath( "vpdude/" ).nativePath;
		session.ownFolderPath = File.documentsDirectory.resolvePath( "vpdude/own/" ).nativePath;
		vpDbPath = session.vpFolderPath;
	}
	cnv = Convertion.getInstance();
	cnv.addEventListener( Event.COMPLETE, resyncComplete );
	cnv.addEventListener( Event.CHANGE, statusChange );
	cnv.addEventListener( Event.ADDED, frameChange );
	cnv.addEventListener( Event.CONNECT, progressChange );
	timer = new Timer(1000);
	timer.addEventListener(TimerEvent.TIMER, browseAndConvert);

}
protected function pwdTextInput_focusInHandler(event:FocusEvent):void
{
	if ( pwdTextInput.text.indexOf("*") > -1 ) pwdTextInput.text ="";
}
protected function pwdTextInput_changeHandler(event:TextOperationEvent):void
{
	passwordChanged = true;
}
protected function applyBtn_clickHandler(event:MouseEvent):void
{
	var isChanged:Boolean = false;
	if ( userName != userTextInput.text || session.ownFolderPath != ownTextInput.text || cnv.reso != resoTextInput.text ) 
	{
		isChanged = true;
		userName = userTextInput.text;
		session.userName = userName;
		session.ownFolderPath = ownTextInput.text;
		cnv.reso = resoTextInput.text;
		checkFolder( session.ownFolderPath );
	}
	if ( passwordChanged ) 
	{
		isChanged = true;
		password = pwdTextInput.text;
		hiddenPassword = "";
		for ( var i:uint = 0; i < password.length; i++ )
		{
			hiddenPassword += "*";
		}
		pwdTextInput.text = hiddenPassword;
	}
	if ( isChanged ) parentDocument.statusText.text = "Configuration saved";
	checkFolder( session.vpFolderPath );
	writeFolderXmlFile();

	createEncodedVars();
	if ( !isConfigured )
	{
		isConfigured = true;
		parentDocument.addTabs();
	}
}

private function writeFolderXmlFile():void
{
	CONFIG_XML = <config> 
					<username>{userName}</username>
					<pwd>{password}</pwd>
					<db>{session.vpFolderPath}</db>
					<own>{session.ownFolderPath}</own>
					<reso>{cnv.reso}</reso>
				 </config>;
	var folderFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
	// write the text file
	writeTextFile( folderFile, CONFIG_XML );					
}
protected function browseConfigPathBtn_clickHandler(event:MouseEvent):void
{
	var file:File = File.documentsDirectory;
	file.addEventListener(Event.SELECT, dbFolderSelection);
	file.addEventListener(Event.CANCEL, dbFolderSelection);
	parentDocument.statusText.text = "Choose where the database files will be stored.";
	
	file.browseForDirectory( "Select a location to store the database files." ); 
}
protected function browseOwnPathBtn_clickHandler(event:MouseEvent):void
{
	var file:File = File.documentsDirectory;
	file.addEventListener(Event.SELECT, ownFolderSelection);
	file.addEventListener(Event.CANCEL, ownFolderSelection);
	parentDocument.statusText.text = "Choose where your own videos are located.";
	
	file.browseForDirectory( "Select where your own videos are located." ); 
}
private function dbFolderSelection(event:Event):void 
{
	var file:File = event.currentTarget as File;
	file.removeEventListener(Event.SELECT, dbFolderSelection);
	file.removeEventListener(Event.CANCEL, dbFolderSelection);
	
	if (event.type === Event.SELECT) 
	{
		vpDbPath = file.nativePath;
	}		
}
private function ownFolderSelection(event:Event):void 
{
	var file:File = event.currentTarget as File;
	file.removeEventListener(Event.SELECT, ownFolderSelection);
	file.removeEventListener(Event.CANCEL, ownFolderSelection);
	
	if (event.type === Event.SELECT) 
	{
		session.ownFolderPath = file.nativePath;
	}		
}

private function checkFolder( folderPath:String ):void 
{
	var folder:File = new File( folderPath );
	var folderPath:String = folder.nativePath.toString();
	// creates folder if it does not exists
	if (!folder.exists) 
	{
		parentDocument.statusText.text = 'Creating folder: ' + folderPath;
		Util.log('Creating folder: ' + folderPath);
		// create the directory
		folder.createDirectory();
	}
	if (!folder.exists) 
	{
		parentDocument.statusText.text = 'Could not create: ' + folderPath;
		Util.log('Could not create: ' + folderPath);
	}
	else
	{
		//create subfolder structure
		var dldFolder:File = new File( session.dldFolderPath );
		dldFolder.createDirectory();
		Util.log('Created: ' + session.dldFolderPath);
		var dbFolder:File = new File( session.dbFolderPath );
		dbFolder.createDirectory();
		Util.log('Created: ' + session.dbFolderPath);	
	}
}

protected function exploreBtn_clickHandler(event:MouseEvent):void
{
	// added june 2011 for mac: "file://"
	if ( session.os == "Mac" )
	{
		navigateToURL(new URLRequest("file://" + session.ownFolderPath));
	}
	else
	{
		navigateToURL(new URLRequest( session.ownFolderPath));
	}
}

private function resyncComplete(event:Event):void
{
	cnv.removeEventListener( Event.COMPLETE, resyncComplete );
	var tags:Tags = Tags.getInstance();
	tags.resyncTags();
	//setCurrentState("Normal");
	if (resyncBtn)
	{
		resyncBtn.enabled = true;
		resyncBtn.label="Sync my own folder";
		log.text = "";
		cnv.progress = "";
		
	}
	progress = "";
	summary = cnv.summary;
}
private function statusChange(event:Event):void
{
	summary = cnv.summary;
	status = cnv.status + " clips converted";
	countNew = cnv.countNew + " new";
	countChanged = cnv.countChanged + " changed";
	countDeleted = cnv.countDeleted + " deleted";
	countNoChange = cnv.countNoChange + " has no change";
	countError = cnv.countError + " error(s)";
}
private function frameChange(event:Event):void
{
	frame = cnv.frame + " frames converted";
}
private function progressChange(event:Event):void
{
	progress = cnv.progress;
}

protected function browseAndConvert(event:TimerEvent):void
{
	Util.errorLog("browseAndConvert start");
	timer.stop();
	cnv = Convertion.getInstance(); 
	cnv.addEventListener( Event.COMPLETE, resyncComplete );
	cnv.addEventListener( Event.CHANGE, statusChange );
	cnv.addEventListener( Event.ADDED, frameChange );
	cnv.addEventListener( Event.CONNECT, progressChange );
	log.text = "";
	summary = "";
	cnv.progress = "";
	progress = "";
	if ( session.ownFolderPath != ownTextInput.text ) 
	{
		session.ownFolderPath = ownTextInput.text;
	}
	Util.errorLog("calling cnv.start");
	cnv.start();
	
	var selectedDirectory:File = new File( session.ownFolderPath );
	// Get directory listing
	ownFiles = new ArrayCollection( selectedDirectory.getDirectoryListing() );
	
	parentDocument.statusText.text = "Found " + ownFiles.length + " file(s)";
	// delete inexistent files from db
	cnv.checkFilesAsync();
	
	// read all files in the folder
	processAllFiles( selectedDirectory );
}
protected function resyncBtn_clickHandler(event:MouseEvent):void
{
	Util.errorLog("resyncBtn clicked");
	/*setCurrentState("Busy");
	Util.errorLog("resyncBtn set to busy state");*/
	resyncBtn.enabled = false;
	resyncBtn.label="Sync in progress..";

	resyncBtn.invalidateDisplayList();
	Util.errorLog("resyncBtn invalidateDisplayList");
	resyncBtn.validateNow();
	Util.errorLog("resyncBtn validateNow");
	Util.errorLog("resyncBtn.label:" + resyncBtn.label);
	//this.callLater( browseAndConvert );
	timer.start();
}

// Process all files in a directory structure including subdirectories.
public function processAllFiles( selectedDir:File ):void
{
	Util.errorLog("processAllFiles:" + selectedDir.nativePath);
	var clips:Clips = Clips.getInstance();
	for each( var lstFile:File in selectedDir.getDirectoryListing() )
	{
		if( lstFile.isDirectory )
		{
			//recursively call function
			processAllFiles( lstFile );
		}
		else
		{
			//check if it is a video file
			if ( validExtensions.indexOf( lstFile.extension.toLowerCase() ) > -1 )
			{
				cnv.addFileToConvert( lstFile );
			}
		}
	}	
}

protected function log_changeHandler(event:TextOperationEvent):void
{
	if ( log.text.length > 500 ) log.text = "";
	log.validateNow();
	log.scroller.verticalScrollBar.value = log.scroller.verticalScrollBar.maximum;
}

