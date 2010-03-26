/**
* Logging Flex and Flash projects using Firebug and ThunderBolt AS3
* 
* @version	2.2
* @date		03/06/09
*
* @author	Jens Krause [www.websector.de]
*
* @see		http://www.websector.de/blog/category/thunderbolt/
* @see		http://code.google.com/p/flash-thunderbolt/
* @source	http://flash-thunderbolt.googlecode.com/svn/trunk/as3/
* 
* ***********************
* HAPPY LOGGING ;-)
* ***********************
* 
*/

package org.osflash.thunderbolt {
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.describeType;

	/**
	* Thunderbolts AS3 Logger class
	* 
	*/
	
	public class Logger
	{
		// constants
		// Firebug supports 4 log levels only
		public static const INFO: String = "info";
		public static const WARN: String = "warn";
		public static const ERROR: String = "error";
		public static const LOG: String = "log";

		private static const GROUP_START: String = "group";
		private static const GROUP_END: String = "groupEnd";
		private static const MAX_DEPTH: int = 255;
		private static const VERSION: String = "2.2";
		private static const AUTHOR: String = "Jens Krause [www.websector.de]";

		public static const FIELD_SEPERATOR: String = " :: ";
		//
		// private vars	
		private static var _stopLog: Boolean = false;
		private static var _depth: int;	
		private static var _logLevel: String;
						
		private static var _hide: Boolean = false;
		private static var _firstRun: Boolean = true;
		private static var _firebug: Boolean = false;	
		//
		// public vars
		public static var includeTime: Boolean = true;
		public static var showCaller: Boolean = true;
			
		/**
		 * Information about the current version of ThunderBoltAS3
		 *
		 */		 
		public static function about():void
	    {
	        var message: String = 	"+++ Welcome to ThunderBolt AS3 | VERSION: " 
	        						+ Logger.VERSION 
	        						+ " | AUTHOR: " 
	        						+ Logger.AUTHOR 
	        						+ " | Happy logging +++";
			Logger.info (message);
	    }
	
		/**
		 * Calculates the amount of memory in MB and Kb currently in use by Flash Player
		 * @return 	String		Message about the current value of memory in use
		 *
		 * Tip: For detecting memory leaks in Flash or Flex check out WSMonitor, too.
		 * @see: http://www.websector.de/blog/2007/10/01/detecting-memory-leaks-in-flash-or-flex-applications-using-wsmonitor/ 
		 *
		 */		 
		public static function memorySnapshot():String
	    {
	        var currentMemValue: uint = System.totalMemory;
			var message: String = 	"Memory Snapshot: " 
									+ Math.round(currentMemValue / 1024 / 1024 * 100) / 100 
									+ " MB (" 
									+ Math.round(currentMemValue / 1024) 
									+ " kb)";
			return message;
	    }
				
		/**
		 * Logs info messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */		
		public static function info (msg: String = null, ...logObjects): void
		{
			Logger.log( Logger.INFO, msg, logObjects );			
		}
		
		/**
		 * Logs warn messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */		
		public static function warn (msg: String = null, ...logObjects): void
		{
			Logger.log( Logger.WARN, msg, logObjects );			
		}

		/**
		 * Logs error messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */		
		public static function error (msg: String = null, ...logObjects): void
		{
			Logger.log( Logger.ERROR, msg, logObjects );			
		}
		
		/**
		 * Logs debug messages messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */		
		public static function debug (msg: String = null, ...logObjects): void
		{
			Logger.log( Logger.LOG, msg, logObjects );			
		}		
			
		/**
		 * Hides the logging process calling Firebug
		 * @param 	value	Boolean     Hide or show the logs of ThunderBolt within Firebug. Default value is "false"
		 */		 
		public static function set hide(value: Boolean):void
	    {
	        _hide = value;
	    }

		/**
		 * Flag to use console trace() methods
		 * @param 	value	Boolean     Flag to use Firebug or not. Default value is "true".
		 */		 
		public static function set console(value: Boolean):void
	    {
	    	_firstRun = false;
	        _firebug = !value;
	    }
	    					 
		/**
		 * Calls Firebugs command line API to write log information
		 * 
		 * @param 	level		String			log level 
 		 * @param 	msg			String			log message 
		 * @param 	logObjects	Array			Array of log objects
		 */			 
		public static function log (level: String, msg: String = "", logObjects: Array = null): void
		{
			if(!_hide)
			{
				// at first run check
				// using browser or not and check if firebug is enabled
				if (_firstRun)
				{					
					var isBrowser: Boolean = ( Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn" );
					
					if ( isBrowser && ExternalInterface.available )
					{
						// check if firebug installed and enabled
						if ( ExternalInterface.call( "function(){ return typeof window.console == 'object' && typeof console.firebug == 'string'}" ) )						
							_firebug = true;
					}
					
					_firstRun = false;
				}
				
				_depth = 0;
			 	// get log level
			 	_logLevel = level;
			 	// log message
			 	var logMsg: String = "";
		    	// add time	to log message
	    		if (includeTime) 
	    			logMsg += getCurrentTime();
			 	
			 	// get package and class name + line number
			 	// using getStackTrace(); 
			 	// @see: http://livedocs.adobe.com/flex/3/langref/Error.html#getStackTrace()
			 	// Note: For using it the Flash Debug Player has to be installed on your machine!
				if ( showCaller ) 
					logMsg += logCaller();            
 
			
				// add message text to log message
			 	logMsg += msg;
			 	
			 	// send message	to the logging system
			 	Logger.call( logMsg );
	    			
			 	// log objects	
				if (logObjects != null)
				{
				 	var i: int = 0, l: int = logObjects.length;	 	
					for (i = 0; i < l; i++) 
					{
			        	Logger.logObject(logObjects[i]);
			    	}					
				}				
			}
	 	
		}
				
		/**
		 * Logs nested instances and properties
		 * 
		 * @param 	logObj		Object		log object
		 * @param 	id			String		short description of log object
		 */	
		private static function logObject (logObj:*, id:String = null): void
		{				
			if ( _depth < Logger.MAX_DEPTH )
			{
				++ _depth;
				
				var propID: String = id || "";
				var description:XML = describeType(logObj);				
				var type: String = description.@name;
				
				if (primitiveType(type))
				{					
					var msg: String = (propID.length) 	? 	"[" + type + "] " + propID + " = " + logObj
														: 	"[" + type + "] " + logObj;
															
					Logger.call( msg );
				}
				else if (type == "Object")
				{
				  	Logger.callGroupAction( GROUP_START, "[Object] " + propID);
				  	
				  	for (var element: String in logObj)
				  	{
					  	logObject(logObj[element], element);	
				  	}
					Logger.callGroupAction( GROUP_END );
				}
				else if (type == "Array")
				{
				  	Logger.callGroupAction( GROUP_START, "[Array] " + propID );
				  	
				  	var i: int = 0, max: int = logObj.length;					  					  	
				  	for (i; i < max; i++)
				  	{
				  		logObject(logObj[i]);
				  	}
				  	
				  	Logger.callGroupAction( GROUP_END );
				  				  			
				}
				else
				{
					// log private props as well - thx to Rob Herman [http://www.toolsbydesign.com]
					var list: XMLList = description..accessor;					
					
					if (list.length())
					{
						for each(var item: XML in list)
						{
							var propItem: String = item.@name;
							var typeItem: String = item.@type;							
							var access: String = item.@access;
							
							// log objects && properties accessing "readwrite" and "readonly" only 
							if (access && access != "writeonly") 
							{
								//TODO: filter classes
								// var classReference: Class = getDefinitionByName(typeItem) as Class;
								var valueItem: * = logObj[propItem];
								Logger.logObject(valueItem, propItem);
							}
						}					
					}
					else
					{
						Logger.logObject(logObj, type);					
					}
				}
			}
			else
			{
				// call one stop message only
				if (!_stopLog)
				{
					Logger.call( "STOP LOGGING: More than " + _depth + " nested objects or properties." );
					_stopLog = true;
				}			
			}									
		}
		
		/**
		 * Call wheter to Firebug console or 
		 * use the standard trace method logging by flashlog.txt
		 * 
		 * @param 	msg			 String			log message
		 * 
		 */							
		private static function call (msg: String = ""): void
		{
			if ( _firebug )
				ExternalInterface.call("console." + _logLevel, msg);			
			else
				trace ( _logLevel + " " + msg);	

		}
		
		
		
		/**
		 * Calls an action to open or close a group of log properties
		 * 
		 * @param 	groupAction		String			Defines the action to open or close a group 
		 * @param 	msg			 	String			log message
		 * 
		 */
		private static function callGroupAction (groupAction: String, msg: String = ""): void
		{
			if ( _firebug )
			{
				if (groupAction == GROUP_START) 
					ExternalInterface.call("console.group", msg);		
				else if (groupAction == GROUP_END)
					ExternalInterface.call("console.groupEnd");			
				else
					ExternalInterface.call("console." + Logger.ERROR, "group type has not defined");	
			}
			else
			{
				if (groupAction == GROUP_START) 
					trace( _logLevel + "." + GROUP_START + " " + msg);			
				else if (groupAction == GROUP_END)
					trace( _logLevel + "." + GROUP_END + " " + msg);			
				else
					trace ( ERROR + "group type has not defined");					
			}
		}
		
					
		/**
		 * Checking for primitive types
		 * 
		 * @param 	type				String			type of object
		 * @return 	isPrimitiveType 	Boolean			isPrimitiveType
		 * 
		 */							
		private static function primitiveType (type: String): Boolean
		{
			var isPrimitiveType: Boolean;
			
			switch (type) 
			{
				case "Boolean":
				case "void":
				case "int":
				case "uint":
				case "Number":
				case "String":
				case "undefined":
				case "null":
					isPrimitiveType = true;
					break;			
				default:
					isPrimitiveType = false;
			}

			return isPrimitiveType;
		}

		/**
		 * Creates a String of valid time value
		 * @return 			String 		current time as a String using valid hours, minutes, seconds and milliseconds
		 */
		 
		private static function getCurrentTime ():String
	    {
    		var currentDate: Date = new Date();
    		
			var currentTime: String = 	"time "
										+ timeToValidString(currentDate.getHours()) 
										+ ":" 
										+ timeToValidString(currentDate.getMinutes()) 
										+ ":" 
										+ timeToValidString(currentDate.getSeconds()) 
										+ "." 
										+ timeToValidString(currentDate.getMilliseconds()) + FIELD_SEPERATOR;
			return currentTime;
	    }
	    		
		/**
		 * Creates a valid time value
		 * @param 	timeValue	Number     	Hour, minute or second
		 * @return 				String 		A valid hour, minute or second
		 */
		 
		private static function timeToValidString(timeValue: Number):String
	    {
	        return timeValue > 9 ? timeValue.toString() : "0" + timeValue.toString();
	    }
	    
	    
	    /** 
	    * Get details of a caller of the log message
	    * which based on Jonathan Branams MethodDescription.createFromStackTrace();
	    * 
		* @see: http://github.com/jonathanbranam/360flex08_presocode/
		 * 
	    */
		private static function stackDataFromStackTrace(stackTrace: String): StackData
		{
			// Check stackTrace
			// Note: It seems that there some issues to match it using Flash IDE, so we use an empty Array instead
			var matches:Array = stackTrace.match(/^\tat (?:(.+)::)?(.+)\/(.+)\(\)\[(?:(.+)\:(\d+))?\]$/)
								|| new Array(); 				
				
			var stackData: StackData = new StackData();		
 			stackData.packageName = matches[1] || "";
			stackData.className = matches[2] || "";
			stackData.methodName = matches[3] || "";
			stackData.fileName = matches[4] || "";
			stackData.lineNumber = int( matches[5] ) || 0;	

			return stackData;
	
		}	    
	    /** 
	    * Message about details of a caller who logs anything
	    * @return String	message of details
	    */
		private static function logCaller(): String
		{
 			var debugError: Error;
 			var message: String = '';
			
            try {
				var errorObject: Object;
                errorObject.halli = "galli";
            } 
            catch( error: Error )
            {
            	debugError = new Error();
            }
            finally
            {
            	var stackTrace:String = debugError.getStackTrace();
            	// track all stacks only if we have a stackTrace
				if ( stackTrace != null )
	    		{
 		    		var stacks:Array = stackTrace.split("\n");

		    		if ( stacks != null )
		    		{
		    			var stackData: StackData;
		    			
		    			// stacks data for using Logger 
		    			
/* 		    			trace ("stacks.length " + stacks.length); */

		    			if ( stacks.length >= 5 )
		    				 stackData = Logger.stackDataFromStackTrace( stacks[ 4 ] );
						
						// special stack data for using ThunderBoldTarget which is a subclass of mx.logging.AbstractTarget
						if ( stackData.className == "AbstractTarget" &&  stacks.length >= 9 )
							stackData = Logger.stackDataFromStackTrace( stacks[ 8 ] );

						// show details of stackData only if it available
						if ( stackData != null )
						{
/* 							trace ("stackData " + stackData.toString() );  */
							 			
							message += ( stackData.packageName != "") 
										? stackData.packageName + "."
										: stackData.packageName;
																			
							message += stackData.className;
							
							if ( stackData.lineNumber > 0  )
								message += " [" + stackData.lineNumber + "]" + Logger.FIELD_SEPERATOR;
						}							    		
		    		}  		    			
	    		}               
            }
            
                       
            return message;	
		}	    
	}

}

/**
* Stackdata for storing all data throwing by an error
* 
*/

internal class StackData
{
	public var packageName: String;
	public var className: String;
	public var methodName: String;
	public var fileName: String;
	public var lineNumber: int;
	
	public function toString(): String
	{
		var s: String = "packageName " + packageName
						+ " // className " + className
						+ " // methodName " + methodName
						+ " // fileName " + fileName
						+ "// lineNumber " + lineNumber;
		return s;

	}
}