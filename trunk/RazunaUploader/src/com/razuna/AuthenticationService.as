/**
 * AuthenticationServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:AuthenticationService= new AuthenticationService();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addloginEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.login(myhostid,myuser,mypass);
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="com.razuna.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:AuthenticationService id="myService">
  *   <srv:login_request_var>
  *		<srv:Login_request hostid=myValue,user=myValue,pass=myValue/>
  *   </srv:login_request_var>
  * </srv:AuthenticationService>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.login_send()" />
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
     * Dispatches when a call to the operation login completes with success
     * and returns some data
     * @eventType LoginResultEvent
     */
    [Event(name="Login_result", type="com.razuna.LoginResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class AuthenticationService extends EventDispatcher implements IauthenticationService
	{
    	private var _baseService:BaseauthenticationService;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function AuthenticationService(destination:String=null,rootURL:String=null)
        {
        	_baseService = new BaseauthenticationService(destination,rootURL);
        }
        
		//stub functions for the login operation
          

        /**
         * @see IAuthenticationService#login()
         */
        public function login(hostid:Number,user:String,pass:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.login(hostid,user,pass);
            _internal_token.addEventListener("result",_login_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IAuthenticationService#login_send()
		 */    
        public function login_send():AsyncToken
        {
        	return login(_login_request.hostid,_login_request.user,_login_request.pass);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _login_request:Login_request;
		/**
		 * @see IAuthenticationService#login_request_var
		 */
		[Bindable]
		public function get login_request_var():Login_request
		{
			return _login_request;
		}
		
		/**
		 * @private
		 */
		public function set login_request_var(request:Login_request):void
		{
			_login_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _login_lastResult:String;
		[Bindable]
		/**
		 * @see IAuthenticationService#login_lastResult
		 */	  
		public function get login_lastResult():String
		{
			return _login_lastResult;
		}
		/**
		 * @private
		 */
		public function set login_lastResult(lastResult:String):void
		{
			_login_lastResult = lastResult;
		}
		
		/**
		 * @see IAuthenticationService#addlogin()
		 */
		public function addloginEventListener(listener:Function):void
		{
			addEventListener(LoginResultEvent.Login_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _login_populate_results(event:ResultEvent):void
		{
			var e:LoginResultEvent = new LoginResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             login_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//service-wide functions
		/**
		 * @see IAuthenticationService#getWebService()
		 */
		public function getWebService():BaseauthenticationService
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addAuthenticationServiceFaultEventListener(listener:Function):void
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
