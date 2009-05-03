/**
 * FolderServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:FolderService= new FolderService();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addgetassetsEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.getassets(mysessiontoken,myfolderid,myshowsubfolders,myoffset,mymaxrows,myshow);
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="com.razuna.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:FolderService id="myService">
  *   <srv:getassets_request_var>
  *		<srv:Getassets_request sessiontoken=myValue,folderid=myValue,showsubfolders=myValue,offset=myValue,maxrows=myValue,show=myValue/>
  *   </srv:getassets_request_var>
  * </srv:FolderService>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.getassets_send()" />
  */
package com.razuna
{
	import mx.rpc.AsyncToken;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;

    /**
     * Dispatches when a call to the operation getassets completes with success
     * and returns some data
     * @eventType GetassetsResultEvent
     */
    [Event(name="Getassets_result", type="com.razuna.GetassetsResultEvent")]
    
    /**
     * Dispatches when a call to the operation getfolders completes with success
     * and returns some data
     * @eventType GetfoldersResultEvent
     */
    [Event(name="Getfolders_result", type="com.razuna.GetfoldersResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class FolderService extends EventDispatcher implements IfolderService
	{
    	private var _baseService:BasefolderService;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function FolderService(destination:String=null,rootURL:String=null)
        {
        	_baseService = new BasefolderService(destination,rootURL);
        }
        
		//stub functions for the getassets operation
          

        /**
         * @see IFolderService#getassets()
         */
        public function getassets(sessiontoken:String,folderid:Number,showsubfolders:Number,offset:Number,maxrows:Number,show:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getassets(sessiontoken,folderid,showsubfolders,offset,maxrows,show);
            _internal_token.addEventListener("result",_getassets_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IFolderService#getassets_send()
		 */    
        public function getassets_send():AsyncToken
        {
        	return getassets(_getassets_request.sessiontoken,_getassets_request.folderid,_getassets_request.showsubfolders,_getassets_request.offset,_getassets_request.maxrows,_getassets_request.show);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _getassets_request:Getassets_request;
		/**
		 * @see IFolderService#getassets_request_var
		 */
		[Bindable]
		public function get getassets_request_var():Getassets_request
		{
			return _getassets_request;
		}
		
		/**
		 * @private
		 */
		public function set getassets_request_var(request:Getassets_request):void
		{
			_getassets_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _getassets_lastResult:String;
		[Bindable]
		/**
		 * @see IFolderService#getassets_lastResult
		 */	  
		public function get getassets_lastResult():String
		{
			return _getassets_lastResult;
		}
		/**
		 * @private
		 */
		public function set getassets_lastResult(lastResult:String):void
		{
			_getassets_lastResult = lastResult;
		}
		
		/**
		 * @see IFolderService#addgetassets()
		 */
		public function addgetassetsEventListener(listener:Function):void
		{
			addEventListener(GetassetsResultEvent.Getassets_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _getassets_populate_results(event:ResultEvent):void
		{
			var e:GetassetsResultEvent = new GetassetsResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             getassets_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the getfolders operation
          

        /**
         * @see IFolderService#getfolders()
         */
        public function getfolders(sessiontoken:String,folderid:Number):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getfolders(sessiontoken,folderid);
            _internal_token.addEventListener("result",_getfolders_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IFolderService#getfolders_send()
		 */    
        public function getfolders_send():AsyncToken
        {
        	return getfolders(_getfolders_request.sessiontoken,_getfolders_request.folderid);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _getfolders_request:Getfolders_request;
		/**
		 * @see IFolderService#getfolders_request_var
		 */
		[Bindable]
		public function get getfolders_request_var():Getfolders_request
		{
			return _getfolders_request;
		}
		
		/**
		 * @private
		 */
		public function set getfolders_request_var(request:Getfolders_request):void
		{
			_getfolders_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _getfolders_lastResult:String;
		[Bindable]
		/**
		 * @see IFolderService#getfolders_lastResult
		 */	  
		public function get getfolders_lastResult():String
		{
			return _getfolders_lastResult;
		}
		/**
		 * @private
		 */
		public function set getfolders_lastResult(lastResult:String):void
		{
			_getfolders_lastResult = lastResult;
		}
		
		/**
		 * @see IFolderService#addgetfolders()
		 */
		public function addgetfoldersEventListener(listener:Function):void
		{
			addEventListener(GetfoldersResultEvent.Getfolders_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _getfolders_populate_results(event:ResultEvent):void
		{
			var e:GetfoldersResultEvent = new GetfoldersResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             getfolders_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//service-wide functions
		/**
		 * @see IFolderService#getWebService()
		 */
		public function getWebService():BasefolderService
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addFolderServiceFaultEventListener(listener:Function):void
		{
			addEventListener("fault",listener);
		}
		
		/**
		 * Internal function to re-dispatch the fault event passed on by the base service implementation
		 * @private
		 */
		 
		 private function throwFault(event:FaultEvent):void
		 {
		 	dispatchEvent(event);
		 }
    }
}
