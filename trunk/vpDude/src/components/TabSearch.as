import fr.batchass.*;

import mx.events.FlexEvent;

import spark.events.TextOperationEvent;

private var isConfigured:Boolean = false;

private function handleButtonClick():void
{
    if (autoComplete.isDropDownVisible())
        {
                autoComplete.hideDropDown();
            }
    else
    {
            autoComplete.search();
            autoComplete.showDropDown();
        }
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
		//use facebook style for tags
		parentDocument.TAGS_XML = <tags> 
							<tag>batchass</tag>
							<tag>cool</tag>
							<tag>videopong</tag>
						 </tags>;
		var folderFile:File = File.applicationStorageDirectory.resolvePath( tagsXmlPath );
		// write the text file
		writeTextFile( tagsFile, parentDocument.TAGS_XML );					
		
	}
}
