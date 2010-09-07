import fr.batchass.*;

import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

private var isConfigured:Boolean = false;


protected function searchTerm_changeHandler(event:TextOperationEvent):void
{
	// search arrayCollection of tags, titles, usernames
}
protected function search_creationCompleteHandler(event:FlexEvent):void
{
	var tagsXmlPath:String = parentDocument.dbFolderPath + File.separator + "tags.xml";
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
			parentDocument.TAGS_XML = new XML( readTextFile( tagsFile ) );
			
			isConfigured = true;
		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading tags.xml file: ' + e.message;
		parentDocument.statusText.text = msg;
		Util.log( msg );
	}
	if ( !isConfigured )
	{
		parentDocument.TAGS_XML = <tags />;
		var folderFile:File = File.applicationStorageDirectory.resolvePath( tagsXmlPath );
		// write the text file
		writeTextFile( tagsFile, parentDocument.TAGS_XML );					
		
	}
}
