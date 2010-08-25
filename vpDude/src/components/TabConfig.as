import spark.events.TextOperationEvent;

private var _passwordEntered:String = "";   

private function pwd_changeHandler(event:TextOperationEvent):void
{
	// update _passwordEntered with whatever has been typed
	var newText:String = pwd.text;
	if (newText.length < _passwordEntered.length) 
	{
		_passwordEntered = _passwordEntered.substr(0, newText.length);
	} 
	else if (newText.length > _passwordEntered.length) 
	{
		var diff:int = newText.length - _passwordEntered.length;
		_passwordEntered += newText.substr(newText.length - diff, diff);
	}
	
	// hide the text in the field, apart from the last char
	pwd.text = "";
	for (var x:int = 0; x < _passwordEntered.length-1; x++) 
	{  
		pwd.text += "•";
	}
	pwd.text += _passwordEntered.charAt(_passwordEntered.length-1);
}

public function get passwordEntered():String
{
	return _passwordEntered;
}

public function set passwordEntered(value:String):void
{
	_passwordEntered = value;
}
