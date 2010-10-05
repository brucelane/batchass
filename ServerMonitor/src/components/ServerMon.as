import mx.events.FlexEvent;

private var monitor:URLMonitor;

[Bindable]
private var httpUrl:String = "app://";


protected function server_creationCompleteHandler(event:FlexEvent):void
{
	urlMonitor( httpUrl );
}
protected function serverBtn_clickHandler(event:MouseEvent):void
{
	parentDocument.browserUrl = httpUrl;
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
		console.text = httpUrl +  ( monitor.available ? " est disponible" : " pas joignable" );
		
		if ( monitor.available ) 
		{
			casaAgglo.setStyle( "color", "0X00FF00" );
		}
		else
		{
			casaAgglo.setStyle( "color", "0XFF0000" );
			
			
		}	
	}
}