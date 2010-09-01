
import components.*;

import flash.desktop.NativeApplication;

import mx.containers.VBox;
import mx.states.AddChild;

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
	}
	parentDocument.statusText.text = "Configuration saved";
	parentDocument.vpUrl = gb.vpUrl + "?login=" + gb.username + "&password=" + gb.password;
	addTabs();
	//parentDocument.searchTab.visible = true;
}

public function addTabs():void 
{
	parentDocument.tabNav.addChild( new Search() );
	parentDocument.tabNav.addChild( new Download() );
	parentDocument.tabNav.addChild( new Config() );
	parentDocument.tabNav.addChild( new Upload() );
	parentDocument.tabNav.addChild( new Quit() );
	parentDocument.tabNav.removeChildAt( 1 );
	parentDocument.tabNav.removeChildAt( 0 );
}

