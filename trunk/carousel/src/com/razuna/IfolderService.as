
/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package com.razuna{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IfolderService
    {
    	//Stub functions for the getassets operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sessiontoken
    	 * @param folderid
    	 * @param showsubfolders
    	 * @param offset
    	 * @param maxrows
    	 * @param show
    	 * @return An AsyncToken
    	 */
    	function getassets(sessiontoken:String,folderid:Number,showsubfolders:Number,offset:Number,maxrows:Number,show:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getassets_send():AsyncToken;
        
        /**
         * The getassets operation lastResult property
         */
        function get getassets_lastResult():String;
		/**
		 * @private
		 */
        function set getassets_lastResult(lastResult:String):void;
       /**
        * Add a listener for the getassets operation successful result event
        * @param The listener function
        */
       function addgetassetsEventListener(listener:Function):void;
       
       
        /**
         * The getassets operation request wrapper
         */
        function get getassets_request_var():Getassets_request;
        
        /**
         * @private
         */
        function set getassets_request_var(request:Getassets_request):void;
                   
    	//Stub functions for the getfolders operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param sessiontoken
    	 * @param folderid
    	 * @return An AsyncToken
    	 */
    	function getfolders(sessiontoken:String,folderid:Number):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getfolders_send():AsyncToken;
        
        /**
         * The getfolders operation lastResult property
         */
        function get getfolders_lastResult():String;
		/**
		 * @private
		 */
        function set getfolders_lastResult(lastResult:String):void;
       /**
        * Add a listener for the getfolders operation successful result event
        * @param The listener function
        */
       function addgetfoldersEventListener(listener:Function):void;
       
       
        /**
         * The getfolders operation request wrapper
         */
        function get getfolders_request_var():Getfolders_request;
        
        /**
         * @private
         */
        function set getfolders_request_var(request:Getfolders_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BasefolderService;
	}
}