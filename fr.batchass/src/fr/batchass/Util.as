package fr.batchass
{
	public class Util
	{
		public function Util()
		{
		}
		public function trim(s:String):String 
		{
			return s ? s.replace(/^\s+|\s+$/gs, '') : "";
		}
	}
}