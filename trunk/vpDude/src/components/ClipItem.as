import fr.batchass.*;

import mx.core.Application;
import mx.core.FlexGlobals;


[Bindable]
private var cachedThumbnail:String;
[Bindable]
private var clipname:String;

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		data.urlthumb1 ? cachedThumbnail = getCachedThumbnail( data.urlthumb1[0] ) : cachedThumbnail = 'assets/noThumb.png';
		data.clipname ? clipname = data.clipname : "...";
		trace("cachedThumbnail:" + cachedThumbnail);
	}
}

private function getCachedThumbnail( thumbnailUrl:String ):String
{
	if ( !FlexGlobals.topLevelApplication.cache ) FlexGlobals.topLevelApplication.cache = new CacheManager( FlexGlobals.topLevelApplication.dldFolderPath );
	var cachedThumbUrl:String = FlexGlobals.topLevelApplication.cache.getThumbnailByURL( thumbnailUrl );
	return cachedThumbUrl;
}

protected function imgUrl_clickHandler(event:MouseEvent):void
{
	trace( event.currentTarget.toString() );
}