package videopong
{
	import flash.filesystem.File;
	
	import fr.batchass.*;
	
	import mx.collections.XMLListCollection;

	public class Tags
	{
		private static var instance:Tags = new Tags();
		private static var tagsXmlPath:String;
		public var TAGS_XML:XML = <tags>
									<tag name="none"/>
								  </tags>;
		// Collection of tags
		[Bindable]
		public var tagsXMLList:XMLListCollection = new XMLListCollection(TAGS_XML.tag.@name);
		
		private static var _dbPath:String;
		
		public function Tags( )
		{
			if ( instance == null ) 
			{
				
			}
			else trace( "Tags already instanciated." );
		}

		public static function getInstance():Tags 
		{
			return instance;
		}		
		
		public function loadTagsFile():void 
		{
			tagsXmlPath = _dbPath + File.separator + "tags.xml";
			var isConfigured:Boolean = false;
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
					TAGS_XML = new XML( readTextFile( tagsFile ) );
					if ( TAGS_XML..tag.length() )
					{
						isConfigured = true;
					}
				}
			}
			catch ( e:Error )
			{	
				var msg:String = 'Error loading tags.xml file: ' + e.message;
				Util.log( msg );
			}
			if ( !isConfigured )
			{
				TAGS_XML = <tags />;
				writeTagsFile();
			}
			refreshTagsXMLList();
		}
		public function writeTagsFile():void 
		{
			tagsXmlPath = _dbPath + File.separator + "tags.xml";
			var tagsFile:File = File.applicationStorageDirectory.resolvePath( tagsXmlPath );
			refreshTagsXMLList();
			
			// write the text file
			writeTextFile( tagsFile, TAGS_XML );					
		}
		public function refreshTagsXMLList():void 
		{
			tagsXMLList = new XMLListCollection( TAGS_XML.tag.@name );
		}

		public function addTagIfNew( tagToSearch:String ):void
		{
			
			trace( TAGS_XML..tag.(@name==tagToSearch).length() );
			if ( TAGS_XML..tag.(@name==tagToSearch).length() < 1 )
			{
				TAGS_XML.appendChild( <tag name={tagToSearch} creationdate={Util.nowDate} /> );
				writeTagsFile();
			}
			
		}

		public function get dbPath():String
		{
			return _dbPath;
		}

		public function set dbPath(value:String):void
		{
			_dbPath = value;
		}


	}
}