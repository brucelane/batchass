import mx.containers.TabNavigator;


internal var gb:Singleton = Singleton.getInstance();

[Bindable]
public var vpUrl:String = gb.vpUrl + "?login=notset&password=notset";

private function init():void
{
	vpUrl = gb.vpUrl + "?login=" + gb.username + "&password=" + gb.password;
}