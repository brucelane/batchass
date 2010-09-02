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
private var tiWidth:int = 250;

private var isConfigured:Boolean = false;

[Bindable]
private var userName:String = "guest";
[Bindable]
private var password:String = "none";
[Bindable]
private var dbFolderPath:String;
[Bindable]
private var dldFolderPath:String;

public static var CONFIG_XML:XML;
public static const DEFAULT_CONFIG_XML:XML;
/*= <config> 
												<username>{userName}</username>
												<pwd>None</pwd>
												<db>{defaultDbFolder.nativePath}</db>
												<dld>{defaultDldFolder.nativePath}</dld>
											 </config>;*/

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
			dldFolderPath = CONFIG_XML..dld[0].toString();
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
		//var defaultDbFolder:File = File.documentsDirectory.resolvePath( "videopong/db/" );
		//var defaultDldFolder:File = File.documentsDirectory.resolvePath( "videopong/dld/" );
		CONFIG_XML = <config> 
						<username>{userName}</username>
						<pwd>None</pwd>
						<db>{File.documentsDirectory.resolvePath( "videopong/db/" ).nativePath}</db>
						<dld>{File.documentsDirectory.resolvePath( "videopong/dld/" ).nativePath}</dld>
					 </config>;
	}
}
protected function applyBtn_clickHandler(event:MouseEvent):void
{
	var isChanged:Boolean = false;
	if ( userName != userTextInput.text || password != pwdTextInput.text ) 
	{
		isChanged = true;
		userName = userTextInput.text;
		password = pwdTextInput.text;
		trace ( "changed" );
		parentDocument.statusText.text = "Configuration saved";
		CONFIG_XML = <config> 
						<username>{userName}</username>
						<pwd>{password}</pwd>
					 </config>;
	}
	writeFolderXmlFile();

	parentDocument.vpFullUrl = parentDocument.vpUrl + "?login=" + userName + "&password=" + password;
	if ( !isConfigured )
	{
		isConfigured = true;
		parentDocument.addTabs();
	}
	
	
}
private function writeFolderXmlFile():void
{
	var folderFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
	// write the text file
	writeTextFile( folderFile, CONFIG_XML );					
}


