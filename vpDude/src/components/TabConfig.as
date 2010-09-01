import flash.desktop.NativeApplication;

import spark.events.TextOperationEvent;

private var gb:Singleton = Singleton.getInstance();
[Bindable]
private var lblWidth:int = 150;
[Bindable]
private var tiWidth:int = 250;

protected function applyBtn_clickHandler(event:MouseEvent):void
{
	var isChanged:Boolean = false;
	if ( gb.username != username.text || gb.password != pwd.text ) isChanged = true;
	gb.username = username.text;
	gb.password = pwd.text;
	if ( isChanged ) 
	{
		trace ( "changed" );
		parentDocument.browserTab.setLocation( gb.vpUrl + "?login=" + gb.username + "&password=" + gb.password );
		//parentDocument.browserTab.createComponentsFromDescriptors();
		parentDocument.lblInfo.text = "apply";
		
	}
}
