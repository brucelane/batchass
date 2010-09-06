package fr.batchass
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import spark.components.Application;
	
	public final class AIRUpdater 
	{
		private static var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI(); 
		
		/**
		 * 	checks website for update
		 */
		public static function checkForUpdate():void 
		{ 
			// set the URL for the xml file
			appUpdater.updateURL = "http://www.batchass.fr/update/" + getApplicationName() + ".xml"; // Server-side XML file describing update  
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate);
			appUpdater.addEventListener(ErrorEvent.ERROR, onUpdaterError);
			// Hide the dialog asking for permission for checking for a new update.
			appUpdater.isCheckForUpdateVisible = false;
			appUpdater.initialize();
		} 
		
		// Handler function triggered by the ApplicationUpdater.initialize.
		// The updater was initialized and it is ready to take commands.
		protected static function onUpdate(event:UpdateEvent):void 
		{
			appUpdater.removeEventListener(UpdateEvent.INITIALIZED, onUpdate);
			appUpdater.removeEventListener(ErrorEvent.ERROR, onUpdaterError);
			// start the process of checking for a new update and to install
			appUpdater.checkNow();
		}
		
		// Handler function for error events triggered by the ApplicationUpdater.initialize
		protected static function onUpdaterError(event:ErrorEvent):void
		{
			trace( "appUpdater,onError: " + event.toString() );  		
		}
		
		private static function getApplicationName():String
		{
			var applicationName: String;
			var xmlNS:Namespace = new Namespace("http://www.w3.org/XML/1998/namespace");
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			// filename is mandatory
			var elem:XMLList = appXML.ns::filename;
			// use name is if it exists in the application descriptor
			if ((appXML.ns::name).length() != 0)
			{
				elem = appXML.ns::name;
			}
			// See if element contains simple content
			if (elem.hasSimpleContent())
			{
				applicationName = elem.toString();
			}
			
			return applicationName;
		}		
	}
	
}