import mx.containers.TabNavigator;

[Bindable]
public var vpUrl:String = "http://www.videopong.net/vpdude/";

internal var gb:Singleton = Singleton.getInstance();

private function init():void
{
	vpUrl = "http://www.videopong.net/vpdude/?login=" + gb.username + "&password=" + gb.password;
}