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

package org.osflash.thunderbolt
{
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.LogEvent;
	import mx.logging.LogEventLevel;	
	
	public class ThunderBoltTarget extends AbstractTarget
	{
		//
		// vars
		[Inspectable(category="General", defaultValue="true")]	   	    	
		public var includeLevel: Boolean = true;
		
		[Inspectable(category="General", defaultValue="false")]	   	    	
		public var includeCategory: Boolean = false;
	
		 
		public function ThunderBoltTarget ()
		{
			super();		
		}

 
	     /**
	     *  Listens to an log event based on Flex Logging Framework
	     * 	and calls ThunderBolt trace method
	     * 
		 * @param 	Event	LogEvent
		 * 
	     */
	    override public function logEvent( event: LogEvent ):void
	    {			    	
	    	//
	    	// log level
	        var level: String;
	        if (includeLevel) 
	        	level = getLogLevel( event.level );	
			//
			// log category
	    	var message: String = "";
			if ( includeCategory ) 
				message += ILogger( event.target ).category + Logger.FIELD_SEPERATOR;
			//
			// log message
			if ( event.message.length ) 
				message += event.message;
			else 
				message += "";
	    	//
	    	// calls ThunderBolt	
	    	Logger.log ( level, message );

	    }   

		/**
		 * Translates Flex log levels to Firebugs log levels
		 * 
		 * @param 	int			log level as integer
		 * @return 	String		level description
		 * 
		 */		
		private static function getLogLevel (logLevel: int): String
		{
			var level: String;
			
			switch (logLevel) 
			{
				case LogEventLevel.INFO:
					level = Logger.INFO;
					break;
				case LogEventLevel.WARN:
					level = Logger.WARN;
					break;				
				case LogEventLevel.ERROR:
					level = Logger.ERROR;
					break;
				// Firebug doesn't support a fatal level
				case LogEventLevel.FATAL:
					level = Logger.ERROR;
					break;
				default:
					// LogLevel.DEBUG && LogLevel.ALL
					level = Logger.LOG;
			}

			return level;
		} 
		    
    		
	     /**
	     *  Setter method to stop logs
	     * 
		 * @param 	value	Boolean - default value is "false"
		 * 
	     */
		[Inspectable(category="General", defaultValue="false")]		
		public function set hide( value: Boolean ):void
		{
			Logger.hide = value;
		}   		

	     /**
	     *  Setter method for using a timestamp
	     * 
		 * @param 	value	Boolean - default value is "true"
		 * 
	     */
		[Inspectable(category="General", defaultValue="true")]		
		public function set includeTime( value: Boolean ):void
		{
			Logger.includeTime = value;
		}   		
    		
	     /**
	     *  Setter method for using ThunderBolt AS3 console or not
	     * 
		 * @param 	value	Boolean for using console or not. Default value is "false"
		 * 
	     */
		[Inspectable(category="General", defaultValue="false")]		
		public function set console( value: Boolean ):void
		{
			Logger.console = value;
		}   		
    		
	     /**
	     *  Setter method for showing caller of a log message
	     * 
		 * @param 	value	Boolean Default value is "true"
		 * 
	     */
		[Inspectable(category="General", defaultValue="true")]		
		public function set showCaller( value: Boolean ):void
		{
			Logger.showCaller = value;
		}   

	     /**
	     *  Setter method for filters
	     * 
		 * @param 	value	Filters of classes
		 * 
	     */		
		override public function set filters( value: Array ):void
    	{
    		super.filters = value;
    		
    		//
    		// includeCategory if we have filters
    		this.includeCategory = ( filters != null && filters.length > 0 );
    		
    	} 	
  		
	}

}