import flash.events.Event;
import flash.net.navigateToURL;

import mx.controls.Alert;
import mx.controls.HTML;

internal var gb:Singleton = Singleton.getInstance();

private var airApp : Object = this;
private function init():void
{
	trace ( "init" );
	//setLocation( gb.vpUrl + "?login=" + gb.username + "&password=" + gb.password );
}
/*public function setLocation( url:String ):void
{
	if ( !htmlBrowser )
	{
		trace( "htmlBrowser null" );
		htmlBrowser = new HTML();
	}
	htmlBrowser.location = url;
}*/

//inject a reference to "this" into the HTML dom
private function onHTMLComplete() : void
{
	trace ( "onHTMLComplete" );
	htmlBrowser.domWindow.airApp = airApp;
}

//THIS HAS TO BE A VAR TO BE RECOGNIZED IN JAVASCRIPT
public var launchURL:Function = function( url : String ) : void
{
	navigateToURL( new URLRequest( url ) );
}
