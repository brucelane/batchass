
import components.*;

import flash.desktop.NativeApplication;

import mx.containers.VBox;
import mx.states.AddChild;

import spark.events.TextOperationEvent;

//private var gb:Singleton = Singleton.getInstance();
[Bindable]
private var lblWidth:int = 150;
[Bindable]
private var tiWidth:int = 250;
/*[Bindable]
private var userName:String;
[Bindable]
private var password:String;*/

protected function applyBtn_clickHandler(event:MouseEvent):void
{
	//var isChanged:Boolean = false;
	/*if ( userName != username.text || password != pwd.text ) isChanged = true;
	userName = username.text;
	password = pwd.text;*/
	/*if ( isChanged ) 
	{
		trace ( "changed" );
	}*/
	parentDocument.statusText.text = "Configuration saved";
	//parentDocument.vpUrl = gb.vpUrl + "?login=" + parentDocument.userName + "&password=" + parentDocument.password;
	parentDocument.addTabs();
}



