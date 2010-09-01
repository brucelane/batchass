import flash.events.Event;
import flash.net.navigateToURL;

import mx.controls.Alert;
import mx.controls.HTML;

internal var gb:Singleton = Singleton.getInstance();

private var airApp : Object = this;
private function init():void
{
	trace ( "init" );
}


//inject a reference to "this" into the HTML dom
private function onHTMLComplete() : void
{
	trace ( "onHTMLComplete" );
	htmlBrowser.domWindow.airApp = airApp;
}

// JAVASCRIPT functions
public var launchURL:Function = function( url : String ) : void
{
	navigateToURL( new URLRequest( url ) );
}

public var launchE4X:Function = function( e4xResult : String ) : void
{
	trace( e4xResult );
}
