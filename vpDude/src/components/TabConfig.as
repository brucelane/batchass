import components.*;

import flash.desktop.NativeApplication;

import fr.batchass.readTextFile;
import fr.batchass.writeTextFile;

import mx.events.FlexEvent;

private var gb:Singleton = Singleton.getInstance();
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
[Bindable]
private var dbFolderPath:String;

public static var CONFIG_XML:XML;
public static const DEFAULT_CONFIG_XML:XML;

protected function config_preinitializeHandler(event:FlexEvent):void
{
	try
	{
		var configFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
		
		if ( !configFile.exists )
		{
			gb.log( "config.xml does not exist" );
		}
		else
		{
			gb.log( "config.xml exists, load the file xml" );
			CONFIG_XML = new XML( readTextFile( configFile ) );
			
			userName = CONFIG_XML..username[0].toString();
			password = CONFIG_XML..pwd[0].toString();
			dbFolderPath = CONFIG_XML..db[0].toString();
			isConfigured = true;
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading config.xml file: ' + e.message;
		parentDocument.statusText.text = msg;
		gb.log( msg );
	}
	parentDocument.vpFullUrl = parentDocument.vpUrl + "?login=" + userName + "&password=" + password;
	
}
protected function config_creationCompleteHandler(event:FlexEvent):void
{
	if ( isConfigured )
	{
		parentDocument.addTabs();
	}
	else
	{
		dbFolderPath = File.documentsDirectory.resolvePath( "videopong/db/" ).nativePath;
	}
}
protected function applyBtn_clickHandler(event:MouseEvent):void
{
	var isChanged:Boolean = false;
	if ( userName != userTextInput.text || password != pwdTextInput.text  || dbFolderPath != dbTextInput.text ) 
	{
		isChanged = true;
		userName = userTextInput.text;
		password = pwdTextInput.text;
		dbFolderPath != dbTextInput.text;
		trace ( "changed" );
		parentDocument.statusText.text = "Configuration saved";

		checkFolder( File.documentsDirectory.resolvePath( dbFolderPath ) );
	}
	writeFolderXmlFile();

	parentDocument.vpFullUrl = parentDocument.vpUrl + "?login=" + userName + "&password=" + password;
	if ( !isConfigured )
	{
		isConfigured = true;
		parentDocument.addTabs();
	}
}
private function updateConfigXml():void
{
}
private function writeFolderXmlFile():void
{
	CONFIG_XML = <config> 
					<username>{userName}</username>
					<pwd>{password}</pwd>
					<db>{dbFolderPath}</db>
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
	parentDocument.statusText.text = "Choose where the database files will be stored";
	
	file.browseForDirectory( "Select a location to store the database files." ); 
}

private function dbFolderSelection(event:Event):void 
{
	var file:File = event.currentTarget as File;
	file.removeEventListener(Event.SELECT, dbFolderSelection);
	file.removeEventListener(Event.CANCEL, dbFolderSelection);
	
	if (event.type === Event.SELECT) 
	{
		dbFolderPath = file.nativePath;
	}		
}

private function checkFolder(folder:File):void 
{
	// creates folder if it does not exists
	if (!folder.exists) 
	{
		parentDocument.statusText.text('Creating: ' + folder.name);
		// create the directory
		folder.createDirectory();
	}
	if (!folder.exists) 
	{
		parentDocument.statusText.text('Could not create: ' + folder.name);
		gb.log('Could not create: ' + folder.name);
	}

}
