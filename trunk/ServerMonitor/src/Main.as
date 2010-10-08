import air.net.URLMonitor;

import flash.filesystem.File;

import flashx.textLayout.formats.BackgroundColor;

import fr.batchass.Util;
import fr.batchass.readTextFile;

import mx.collections.XMLListCollection;
import mx.events.FlexEvent;

[Bindable]
public var browserUrl:String = "app://";
public var serverXMLList:XMLListCollection;
public static var CONFIG_XML:XML;
private var defaultConfigXmlPath:String = 'servermonitor/config' + File.separator + 'config.xml';
private var isConfigured:Boolean = false;

protected function windowedapplication1_preinitializeHandler(event:FlexEvent):void
{
	try
	{
		var configFile:File = File.documentsDirectory.resolvePath( defaultConfigXmlPath );
		
		if ( !configFile.exists )
		{
			Util.log( "config.xml does not exist" );
		}
		else
		{
			Util.log( "config.xml exists, load the file xml" );
			CONFIG_XML = new XML( readTextFile( configFile ) );
			
			serverXMLList = new XMLListCollection(CONFIG_XML.server);
			
			isConfigured = true;
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading config.xml file: ' + e.message;
		parentDocument.statusText.text = msg;
		Util.log( msg );
	}
}

protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{
	
}

