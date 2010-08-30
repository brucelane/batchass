import flash.desktop.NativeApplication;

import spark.events.TextOperationEvent;

private var gb:Singleton = Singleton.getInstance();


protected function applyBtn_clickHandler(event:MouseEvent):void
{
	gb.username = username.text;
	gb.password = pwd.text;
}
