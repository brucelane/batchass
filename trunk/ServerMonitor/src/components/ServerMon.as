import air.net.URLMonitor;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;

private var monitor:URLMonitor;

[Bindable]
private var httpUrl:String = "app://";

override public function set data( value:Object ) : void {
	super.data = value;
	if ( data )
	{
		if ( data.attribute( "url" ).length() > 0 ) 
		{	
			if ( httpUrl != data.attribute( "url" ) )
			{
				httpUrl = data.attribute( "url" );
				urlMonitor( httpUrl );
				
			}
		}
	}
}

protected function serverBtn_clickHandler(event:MouseEvent):void
{
			FlexGlobals.topLevelApplication.browserUrl = httpUrl;
}
private function urlMonitor(url:String):void 
{
	// URLRequest that the Monitor Will Check
	var urlRequest:URLRequest = new URLRequest( url );
	// Checks Only the Headers - Not the Full Page
	urlRequest.method = "HEAD";
	// Create the URL Monitor and Pass it the URLRequest
	monitor = new URLMonitor( urlRequest );
	// Add Our Event Listener to Respond the a Change in Connection Status
	monitor.addEventListener( StatusEvent.STATUS, onMonitor );
	// Start the URLMonitor
	monitor.start();	
	// Set the Interval (in ms) - 10000 = 10 Seconds
	monitor.pollInterval = 10000;
	
}

private function onMonitor(event:StatusEvent):void 
{
	if ( monitor )
	{
		FlexGlobals.topLevelApplication.console.text = httpUrl +  ( monitor.available ? " est disponible" : " pas joignable" );
		
		if ( monitor.available ) 
		{
			serverBtn.setStyle( "color", "0X55FF55" );
		}
		else
		{
			serverBtn.setStyle( "color", "0XFF0000" );
			
			
		}	
	}
}