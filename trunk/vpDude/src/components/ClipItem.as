import fr.batchass.*;

import mx.core.Application;
import mx.core.FlexGlobals;
import flash.events.TimerEvent;
import flash.utils.Timer;

private var currentThumb:uint = 1;
private var timer:Timer;

[Bindable]
private var cachedThumbnail:String;
[Bindable]
private var clipname:String;

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		changeThumb();
		
		data.urlthumb1 ? cachedThumbnail = getCachedThumbnail( data.urlthumb1 ) : cachedThumbnail = 'assets/noThumb.png';
		data.clipname ? clipname = data.clipname : "...";
		this.toolTip = clipname;
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
	trace( data.urldownload );
}
protected function imgUrl_mouseOverHandler( event:MouseEvent ):void
{
	if ( !timer )
	{
		timer = new Timer( 500, 30 );
		timer.start();
		timer.addEventListener( TimerEvent.TIMER, onTimer );
		timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComplete );
	}
}
protected function imgUrl_mouseOutHandler( event:MouseEvent ):void
{
	removeTimer();
}
private function onTimer( event:TimerEvent ):void 
{
	if ( data )
	{
		if ( currentThumb++ ==4 ) currentThumb = 1;
		changeThumb(); 
	}
}
private function removeTimer():void 
{
	if ( timer )
	{
		timer.removeEventListener( TimerEvent.TIMER, onTimer );
		timer.stop();
		timer = null;
	}
}

private function onTimerComplete( event:TimerEvent ):void
{
	removeTimer();
}

private function changeThumb():void
{
	switch ( currentThumb )
	{
		case 1:
			if ( data.urlthumb1 )
			{
				cachedThumbnail = getCachedThumbnail( data.urlthumb1 );
			};
			break;
		case 2:
			if ( data.urlthumb2 )
			{
				cachedThumbnail = getCachedThumbnail( data.urlthumb2 );
			};
			break;
		default:
			if ( data.urlthumb3 )
			{
				cachedThumbnail = getCachedThumbnail( data.urlthumb3 );
			};
			break;
	}
	
}
