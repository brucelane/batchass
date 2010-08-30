import flash.desktop.NativeApplication;

import spark.events.TextOperationEvent;

private var _passwordEntered:String = "";   
protected function applyBtn_clickHandler(event:MouseEvent):void
{
	passwordEntered = pwd.text;
}
/*private function pwd_changeHandler(event:TextOperationEvent):void
{
	var typedString:String = event.currentTarget.text;
	var typedStringLength:int = typedString.length;
	var lastChar:String = "";
	if ( typedStringLength > 0 )
	{
		lastChar = typedString.substr( typedStringLength - 1);
	}
	
	if ( lastChar == "•" )
	{
		_passwordEntered = _passwordEntered.substr(0, typedStringLength - 1);
	}
	else
	{
		if ( _passwordEntered.length > 0 )
		{
			for (var x:int = 0; x < _passwordEntered.length-1; x++) 
			{  
				pwd.text += "•";
			}
			pwd.text +=  lastChar;
		}
	}

		
	_passwordEntered += lastChar;

	pwd.selectRange( pwd.selectionActivePosition,-1);*/
	// update _passwordEntered with whatever has been typed
	/*var newText:String = pwd.text;
	if (newText.length < _passwordEntered.length) 
	{
		_passwordEntered = _passwordEntered.substr(0, newText.length);
	} 
	else if (newText.length > _passwordEntered.length) 
	{
		var diff:int = newText.length - _passwordEntered.length;
		_passwordEntered += newText.substr(newText.length - diff, diff);
	}
	trace(newText + " " + pwd.text  + " " + event.currentTarget.text);
	// hide the text in the field, apart from the last char
	pwd.text = "";
	for (var x:int = 0; x < _passwordEntered.length-1; x++) 
	{  
		pwd.text += "•";
	}
	pwd.text += _passwordEntered.charAt(_passwordEntered.length-1);*/
	
//}

public function get passwordEntered():String
{
	return _passwordEntered;
}

public function set passwordEntered(value:String):void
{
	_passwordEntered = value;
}
