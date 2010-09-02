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

public static var CONFIG_XML:XML;
public static const DEFAULT_CONFIG_XML:XML = <config> 
												<username>Guest</username>
												<pwd>None</pwd>
											 </config>;

protected function config_preinitializeHandler(event:FlexEvent):void
{
	try
	{
		var configFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
		
		if ( !configFile.exists )
		{
			gb.log( "config.xml does not exist" );
			CONFIG_XML = DEFAULT_CONFIG_XML;
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
		CONFIG_XML = DEFAULT_CONFIG_XML;
		var msg:String = 'Error loading config.xml file: ' + e.message;
		parentDocument.statusText.text = msg;
		gb.log( msg );
	}
}

protected function applyBtn_clickHandler(event:MouseEvent):void
{
	//var isChanged:Boolean = false;
	/*if ( userName != username.text || password != pwd.text ) isChanged = true;
	userName = username.text;
	password = pwd.text;*/
	/*if ( isChanged ) 
	{
		trace ( "changed" );
	}*/
	parentDocument.statusText.text = "Configuration saved";
	//parentDocument.vpUrl = gb.vpUrl + "?login=" + parentDocument.userName + "&password=" + parentDocument.password;
	if ( isConfigured )
	{
		parentDocument.addTabs();
	}
	else
	{
		writeFolderXmlFile();
	}
}
private function writeFolderXmlFile():void
{
	var folderFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
	// write the text file
	writeTextFile(folderFile, CONFIG_XML);					
}


