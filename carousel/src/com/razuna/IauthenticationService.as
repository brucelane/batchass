
/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package com.razuna{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IauthenticationService
    {
    	//Stub functions for the login operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param hostid
    	 * @param user
    	 * @param pass
    	 * @return An AsyncToken
    	 */
    	function login(hostid:Number,user:String,pass:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function login_send():AsyncToken;
        
        /**
         * The login operation lastResult property
         */
        function get login_lastResult():String;
		/**
		 * @private
		 */
        function set login_lastResult(lastResult:String):void;
       /**
        * Add a listener for the login operation successful result event
        * @param The listener function
        */
       function addloginEventListener(listener:Function):void;
       
       
        /**
         * The login operation request wrapper
         */
        function get login_request_var():Login_request;
        
        /**
         * @private
         */
        function set login_request_var(request:Login_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BaseauthenticationService;
	}
}