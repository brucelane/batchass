import components.*;

import flash.desktop.NativeApplication;
import flash.desktop.NativeProcess;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;

import fr.batchass.Util;
import fr.batchass.readTextFile;
import fr.batchass.writeTextFile;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;

import videopong.Clips;

[Bindable]
private var ownFiles:ArrayCollection;

private var defaultConfigXmlPath:String = 'config' + File.separator + '.vpDudeConfig';

[Bindable]
private var lblWidth:int = 150;
[Bindable]
private var tiWidth:int = 350;

private var isConfigured:Boolean = false;

[Bindable]
private var userName:String = "";
[Bindable]
private var password:String = "";

public static var CONFIG_XML:XML;
private var OWN_CLIPS_XML:XML;

private var startFFMpegProcess:NativeProcess;


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
			password = CONFIG_XML..pwd[0].toString();
			parentDocument.vpFolderPath = CONFIG_XML..db[0].toString();
			parentDocument.ownFolderPath = CONFIG_XML..own[0].toString();
			isConfigured = true;
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading config.xml file: ' + e.message;
		parentDocument.statusText.text = msg;
		Util.log( msg );
	}
	parentDocument.vpFullUrl = parentDocument.vpUrl + "?login=" + userName + "&password=" + password;
	parentDocument.vpUploadUrl = parentDocument.vpUpUrl + "?login=" + userName + "&password=" + password;
	
}
protected function config_creationCompleteHandler(event:FlexEvent):void
{
	if ( isConfigured )
	{
		parentDocument.addTabs();
	}
	else
	{
		parentDocument.vpFolderPath = File.documentsDirectory.resolvePath( "vpdude/" ).nativePath;
		parentDocument.ownFolderPath = File.documentsDirectory.resolvePath( "vpdude/own/" ).nativePath;
	}
	
}
protected function applyBtn_clickHandler(event:MouseEvent):void
{
	var isChanged:Boolean = false;
	if ( userName != userTextInput.text || password != pwdTextInput.text || parentDocument.vpFolderPath != dbTextInput.text || parentDocument.ownFolderPath != ownTextInput.text ) 
	{
		isChanged = true;
		userName = userTextInput.text;
		password = pwdTextInput.text;
		parentDocument.vpFolderPath = dbTextInput.text;
		parentDocument.ownFolderPath = ownTextInput.text;
		trace ( "changed" );
		parentDocument.statusText.text = "Configuration saved";

		checkFolder( parentDocument.vpFolderPath );
		checkFolder( parentDocument.ownFolderPath );
	}
	writeFolderXmlFile();

	parentDocument.vpFullUrl = parentDocument.vpUrl + "?login=" + userName + "&password=" + password;
	parentDocument.vpUploadUrl = parentDocument.vpUpUrl + "?login=" + userName + "&password=" + password;
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
					<db>{parentDocument.vpFolderPath}</db>
					<own>{parentDocument.ownFolderPath}</own>
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
		parentDocument.vpFolderPath = file.nativePath;
	}		
}
private function ownFolderSelection(event:Event):void 
{
	var file:File = event.currentTarget as File;
	file.removeEventListener(Event.SELECT, ownFolderSelection);
	file.removeEventListener(Event.CANCEL, ownFolderSelection);
	
	if (event.type === Event.SELECT) 
	{
		parentDocument.ownFolderPath = file.nativePath;
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
		var dldFolder:File = new File( parentDocument.dldFolderPath );
		dldFolder.createDirectory();
		Util.log('Created: ' + parentDocument.dldFolderPath);
		var dbFolder:File = new File( parentDocument.dbFolderPath );
		dbFolder.createDirectory();
		Util.log('Created: ' + parentDocument.dbFolderPath);
		
	}

}

protected function resyncBtn_clickHandler(event:MouseEvent):void
{
	var selectedDirectory:File = new File( parentDocument.ownFolderPath );
	// Get directory listing
	ownFiles = new ArrayCollection( selectedDirectory.getDirectoryListing() );
	// read all files in the folder
	trace ( ProcessAllFiles( selectedDirectory ) );
	
}
// Process all files in a directory structure including subdirectories.
public function ProcessAllFiles( selectedDir:File ):String
{
	var str:String = "";
	var clips:Clips = Clips.getInstance();
	for each( var lstFile:File in selectedDir.getDirectoryListing() )
	{
		if( lstFile.isDirectory )
		{
			//recursively call function
			str += ProcessAllFiles( lstFile );
		}
		else
		{
			if ( clips.newClip( lstFile.nativePath ) )
			{
				var clipId:String = Util.nowDate;
				var thumbsPath:String = parentDocument.dldFolderPath + "/thumbs/" + clipId + "/";
				var thumbsFolder:File = new File( thumbsPath );
				// creates folder if it does not exists
				if (!thumbsFolder.exists) 
				{
					// create the directory
					thumbsFolder.createDirectory();
				}
				startFFMpegProcess = new NativeProcess();
				execute( startFFMpegProcess, lstFile.nativePath, thumbsPath, 1 );
				execute( startFFMpegProcess, lstFile.nativePath, thumbsPath, 2 );
				execute( startFFMpegProcess, lstFile.nativePath, thumbsPath, 3 );
				str+= lstFile.nativePath + "\n";
				OWN_CLIPS_XML = <video id={clipId} urllocal={lstFile.nativePath}> 
									<urlthumb1>{thumbsPath + "thumb1.jpg"}</urlthumb1>
									<urlthumb2>{thumbsPath + "thumb2.jpg"}</urlthumb2>
									<urlthumb3>{thumbsPath + "thumb3.jpg"}</urlthumb3>
									<clip name="very new own clip from the top uploader"/>
									<creator name={userName}/>
									<tags>
										<tag name="own"/>
									</tags>
								</video>;
				clips.addNewClip( clipId, OWN_CLIPS_XML, lstFile.nativePath );
			}
		}
	}	
	return str;
}
private function execute( process:NativeProcess, ownVideoPath:String, thumbsPath:String, thumbNumber:uint ):void
{
	// Start the process
	try
	{
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		nativeProcessStartupInfo.executable = File.applicationStorageDirectory.resolvePath( parentDocument.vpFFMpegExePath );
		//nativeProcessStartupInfo.workingDirectory = thumbsdir;
		var processArgs:Vector.<String> = new Vector.<String>();
		processArgs[0] = "-i";
		processArgs[1] = ownVideoPath;
		processArgs[2] = "-vframes";
		processArgs[3] = "1";
		processArgs[4] = "-f";
		processArgs[5] = "image2";
		processArgs[6] = "-vcodec";
		processArgs[7] = "mjpeg";
		processArgs[8] =  "-s";
		processArgs[9] = "100x74"; //Frame size must be a multiple of 2
		processArgs[10] =  "-ss";
		processArgs[11] = thumbNumber.toString();
		processArgs[12] = thumbsPath + "thumb" + thumbNumber + ".jpg";
		nativeProcessStartupInfo.arguments = processArgs;
		startFFMpegProcess = new NativeProcess();
		startFFMpegProcess.start(nativeProcessStartupInfo);
		startFFMpegProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,
			outputDataHandler);
		startFFMpegProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,
			errorOutputDataHandler);
	}
	catch (e:Error)
	{
		Util.log( "NativeProcess Error: " + e.message );
	}
}
private function outputDataHandler(event:ProgressEvent):void
{
	var process:NativeProcess = event.target as NativeProcess;
	var data:String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
	log.text += data;
}

private function errorOutputDataHandler(event:ProgressEvent):void
{
	var process:NativeProcess = event.target as NativeProcess;
	var data:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
	log.text += data;
}