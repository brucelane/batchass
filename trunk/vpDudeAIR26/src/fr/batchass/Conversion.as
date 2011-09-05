package fr.batchass
{
	import components.Config;
	
	import flash.desktop.*;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.utils.Timer;
	
	import fr.batchass.*;
	
	import mx.core.FlexGlobals;
	
	import videopong.Clips;
	import videopong.Tags;
	
	public class Conversion implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		private static var instance:Conversion;
		private var timer:Timer;
		public var moviesToConvert:Array = new Array();
		public var thumbsToConvert:Array = new Array();
		public var newClips:Array = new Array();
		private var startFFMpegProcess:NativeProcess;		
		private var currentFilename:String = "";
		private var currentThumb:int;
		private var thumb1:String;
		private var _status:String;
		public var tPath:String;

		private var _busy:Boolean = false;
		private var _summary:String;
		
		[Bindable]
		public var countNew:int = 0;
		[Bindable]
		public var countDeleted:int = 0;
		[Bindable]
		public var countChanged:int = 0;
		[Bindable]
		public var countDone:int = 0;
		[Bindable]
		public var countError:int = 0;
		[Bindable]
		public var countTotal:int = 0;
		[Bindable]
		public var countNoChange:int = 0;
		public var nochgFiles:String = "";
		public var newFiles:String = "";
		public var delFiles:String = "";
		public var chgFiles:String = "";
		public var errFiles:String = "";
		public var allFiles:String = "";
		[Bindable]
		public var reso:String = "320x240";
		
		public function Conversion()
		{
			Util.log( "Conversion, constructor" );
			//status = "(0/0)";
			dispatcher = new EventDispatcher(this);
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, processConvert);
			timer.start();
		}
		
		[Bindable]
		public function get summary():String
		{
			return _summary;
		}

		public function set summary(value:String):void
		{
			_summary = value;
		}

		[Bindable(event="busyChange")]
		public function get busy():Boolean
		{
			return _busy;
		}

		public function set busy(value:Boolean):void
		{
			if( _busy !== value)
			{
				_busy = value;
				dispatchEvent(new Event(Event.ADDED));
			}
		}

		[Bindable(event="statusChange")]
		public function get status():String
		{
			return _status;
		}

		public function set status(value:String):void
		{
			if( _status !== value)
			{
				_status = value;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		public static function getInstance():Conversion
		{
			if (instance == null)
			{
				instance = new Conversion();
			}
			
			return instance;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
		private function processConvert(event:Event): void 
		{
			dispatchEvent( new Event(Event.CHANGE) );
			status = "(" + countDone + "/" + countTotal + ")";
			
			var freeSpace:Number = File.applicationStorageDirectory.spaceAvailable / 1048576;
			if ( freeSpace < 10 )
			{
				Util.ffMpegOutputLog( "processConvert: disk has less than 10Mb free space(" + freeSpace + "), conversion cannot continue.\n" );
			}
			else
			{
				if ( !busy )
				{
					if ( thumbsToConvert.length > 0 )
					{
						busy = true;
						currentThumb = thumbsToConvert[0].tNumber;
						//configComp.ffout.text += "Converting: " + thumbsToConvert[0].clipLocalPath + "\n";
						Util.ffMpegOutputLog( "processConvert: Converting " + thumbsToConvert[0].clipLocalPath + "\n" );
						execute( thumbsToConvert[0].clipLocalPath, thumbsToConvert[0].tPath, thumbsToConvert[0].tNumber );
						thumbsToConvert.shift();
					}
					else
					{	
						if ( newClips.length > 0 )
						{
							var clips:Clips = Clips.getInstance();
							clips.addNewClip( newClips[0].clipName, newClips[0].ownXml, newClips[0].cPath );
							newClips.shift();
						}
						else
						{	
							if ( moviesToConvert.length > 0 )
							{
								busy = true;
								generatePreview( moviesToConvert[0].clipLocalPath, moviesToConvert[0].swfLocalPathswfPath, moviesToConvert[0].clipGenName, moviesToConvert[0].clipFileName );
								moviesToConvert.shift();
							}
							else
							{
								// all is converted and finished
								summary = "Completed:\n"; // [" + allFiles + "]\n";
								var availSwfs:String = newFiles + chgFiles + nochgFiles;
								var countAvail:int = countNew + countChanged + countNoChange;
								summary += "- newly indexed: " + countNew + " clip(s)";
								if ( countNew > 0 )	summary += " [" + newFiles + "]\n" else summary += "\n";
								summary += "- changed: " + countChanged + " clip(s)";
								if ( countChanged > 0 )	summary += " [" + chgFiles + "]\n" else summary += "\n";
								summary += "- deleted: " + countDeleted + " clip(s)";
								if ( countDeleted > 0 )	summary += " [" + delFiles + "]\n" else summary += "\n";
								summary += "- no change: " + countNoChange + " clip(s)";
								if ( countNoChange > 0 ) summary += " [" + nochgFiles + "]\n" else summary += "\n";
								if ( countError > 0 )
								{
									summary += "- could not convert thumbs and preview: " + countError + " clip(s) [" + errFiles + "]\n";
								}
								summary += "- available as swf: " + countAvail + " clip(s)";
								if ( countAvail > 0 ) summary += " [" + availSwfs + "]\n" else summary += "\n";
	
								dispatchEvent( new Event(Event.COMPLETE) );
							}
						}
					}
				}
				else
				{
					//busy
					if ( !startFFMpegProcess.running ) busy = false;
				}
				
				if ( ( thumbsToConvert.length == 0 ) && ( moviesToConvert.length == 0 ) && ( newClips.length == 0 ) )
				{
					busy = false;
				}				
				
			}
			
		}
		private function generatePreview( ownVideoPath:String, swfPath:String, clipGeneratedName:String, clipFileName:String ):void
		{
			currentFilename = clipFileName;

			FlexGlobals.topLevelApplication.statusText.text = "Converting to swf: " + ownVideoPath;
			// Start the process
			try
			{
				if ( ownVideoPath.indexOf(".swf") > -1 )
				{
					//error no conversion on swf files
					countError++;
					countDone++;
					errFiles += clipFileName + " ";
					copySwf( ownVideoPath, swfPath + clipGeneratedName + ".swf" );
				}
				else
				{
					var ffMpegExecutable:File = File.applicationStorageDirectory.resolvePath( FlexGlobals.topLevelApplication.vpFFMpegExePath );
					if ( !ffMpegExecutable.exists )
					{
						Util.log( "generatePreview, ffMpegExecutable does not exist: " + FlexGlobals.topLevelApplication.vpFFMpegExePath );
					}
					else
					{
						Util.log( "generatePreview, ffMpegExecutable exists: " + FlexGlobals.topLevelApplication.vpFFMpegExePath );
					}
					//configComp.ffout.text += "generatePreview, converting " + clipFileName + " to swf.\n";
					Util.ffMpegOutputLog( "NativeProcess generatePreview: " + "Converting " + clipGeneratedName + " to swf: " + swfPath + clipGeneratedName + ".swf" + "\n" );
					
					var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
					nativeProcessStartupInfo.executable = ffMpegExecutable;
					Util.log("generatePreview,ff path:"+ ffMpegExecutable.nativePath );
					var processArgs:Vector.<String> = new Vector.<String>();
					var i:int = 0;
					processArgs[i++] = "-i";
					processArgs[i++] = ownVideoPath;
					processArgs[i++] = "-b";
					processArgs[i++] = "400k";
					processArgs[i++] = "-an";
					processArgs[i++] = "-f";
					processArgs[i++] = "avm2";
					processArgs[i++] = "-s";
					processArgs[i++] = reso;// default "320x240";
					processArgs[i++] = swfPath + clipGeneratedName + ".swf";
					processArgs[i++] = "-y";
					nativeProcessStartupInfo.arguments = processArgs;
					startFFMpegProcess = new NativeProcess();
					startFFMpegProcess.start(nativeProcessStartupInfo);
					startFFMpegProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,
						outputDataHandler);
					startFFMpegProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,
						errorMovieDataHandler);
					startFFMpegProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE, processClose );
					startFFMpegProcess.addEventListener(NativeProcessExitEvent.EXIT, onExit);
					
				}
			}
			catch (e:Error)
			{
				Util.log( "generatePreview, NativeProcess Error: " + e.message );
				busy = false;
			}
		}
		private function processClose(event:Event):void
		{
			var process:NativeProcess = event.target as NativeProcess;
			Util.ffMpegOutputLog( "NativeProcess processClose" );
		}
		private function errorOutputDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = event.target as NativeProcess;
			var data:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
			//resetConsole();
			//configComp.log.text += data;
			if (data.indexOf("muxing overhead")>-1) 
			{
				if ( thumb1.length > 0 )
				{
					//file: copy
					var sourceFile:File = new File( thumb1 );
					var destFile:File = new File( tPath + "thumb2.jpg" );
					sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					try 
					{
						sourceFile.copyTo( destFile );
						var destFile2:File = new File( tPath + "thumb3.jpg" );
						sourceFile.copyTo( destFile2 );
					}
					catch (error:Error)
					{
						Util.errorLog( "errorOutputDataHandler Error:" + error.message );
					}
				}
				busy = false;
			}
			if (data.indexOf("swf: I/O error occurred")>-1)
			{ 
				busy = false;
				//copySwf();
			}
			if (data.indexOf("Unknown format")>-1)
			{ 
				busy = false;
			}
			Util.ffMpegErrorLog( "NativeProcess errorOutputDataHandler: " + data );
		}
		public function start():void
		{
			countNew = 0;
			countDeleted = 0;
			countChanged = 0;
			countDone = 0;
			countError = 0;
			countNoChange = 0;
			countTotal = 0;
			nochgFiles = "";
			newFiles = "";
			delFiles = "";
			chgFiles = "";
			errFiles = "";
			allFiles = "";
			currentFilename = "";

		}
		public function copySwf( src:String, dest:String ):void
		{
			var sourceFile:File = new File( src );
			var destFile:File = new File( dest );
			sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			try 
			{
				sourceFile.copyTo( destFile );
			}
			catch (error:Error)
			{
				Util.errorLog( "copySwf Error:" + error.message );
			}
			
		}
		private function errorMovieDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = event.target as NativeProcess;
			var data:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
			//resetConsole();
			//configComp.log.text += data;
			if (data.indexOf("muxing overhead")>-1)
			{
				busy = false;
			}
			if (data.indexOf("swf: I/O error occurred")>-1)
			{ 
				countError++;
				errFiles += currentFilename + " ";
				busy = false;
			}
			if (data.indexOf("Unknown format")>-1)
			{ 
				countError++;
				errFiles += currentFilename + " ";
				busy = false;
			}
			if (data.indexOf("already exists. Overwrite")>-1)
			{ 	
				countDone--;
				busy = false;
			}
			if ( !busy ) countDone++;
			Util.ffMpegMovieErrorLog( "NativeProcess errorOutputDataHandler: " + data );
		}
		//thumbs
		private function execute( ownVideoPath:String, thumbsPath:String, thumbNumber:uint ):void
		{
			FlexGlobals.topLevelApplication.statusText.text = "Creating thumb: " + ownVideoPath;
			// Start the process
			try
			{
				tPath = thumbsPath;
				var ffMpegExecutable:File = File.applicationStorageDirectory.resolvePath(  FlexGlobals.topLevelApplication.vpFFMpegExePath );
				if ( !ffMpegExecutable.exists )
				{
					Util.log( "execute, ffMpegExecutable does not exist: " + FlexGlobals.topLevelApplication.vpFFMpegExePath );
				}
				else
				{
					Util.log( "execute, ffMpegExecutable exists: " + FlexGlobals.topLevelApplication.vpFFMpegExePath );
				}
				var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				nativeProcessStartupInfo.executable = ffMpegExecutable;
				
				Util.log( "execute, ffMpegExecutable path: " + File.applicationStorageDirectory.resolvePath(  FlexGlobals.topLevelApplication.vpFFMpegExePath ).nativePath );
				
				if (thumbNumber == 1) 
				{
					thumb1 = thumbsPath + "thumb" + thumbNumber + ".jpg" 
				}
				else thumb1 = "";
				//configComp.ffout.text += "execute, Converting " + ownVideoPath + " to thumb\n";
				Util.ffMpegOutputLog( "NativeProcess execute: " + "Converting " + ownVideoPath + " to thumb " + thumb1 + "\n" );
				
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs[0] = "-i";
				processArgs[1] = ownVideoPath;
				processArgs[2] = "-vframes";
				processArgs[3] = "1";
				processArgs[4] = "-f";
				processArgs[5] = "image2";
				processArgs[6] = "-vcodec";
				processArgs[7] = "mjpeg";
				processArgs[8] =  "-s";
				processArgs[9] = "100x74"; //Frame size must be a multiple of 2
				processArgs[10] =  "-ss";
				processArgs[11] = thumbNumber.toString();
				processArgs[12] = thumbsPath + "thumb" + thumbNumber + ".jpg";
				processArgs[13] = "-y";
				nativeProcessStartupInfo.arguments = processArgs;
				
				startFFMpegProcess = new NativeProcess();
				startFFMpegProcess.start(nativeProcessStartupInfo);
				startFFMpegProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,
					outputDataHandler);
				startFFMpegProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,
					errorOutputDataHandler);
			}
			catch (e:Error)
			{
				Util.log( "execute, NativeProcess Error: " + e.message );
				busy = false;
			}
		}
		private function outputDataHandler(event:ProgressEvent):void
		{
			var process:NativeProcess = event.target as NativeProcess;
			var data:String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
			//resetConsole();
			//configComp.log.text += data;
			Util.ffMpegOutputLog( "NativeProcess outputDataHandler: " + data );
		}
		private function ioErrorHandler( event:IOErrorEvent ):void
		{
			Util.log( 'TabConfig, An IO Error has occured: ' + event.text );
		}    
		// only called if a security error detected by flash player such as a sandbox violation
		private function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			Util.log( "TabConfig, securityErrorHandler: " + event.text );
		}
		private function onExit(evt:NativeProcessExitEvent):void
		{
			Util.ffMpegOutputLog( "Process ended with code: " + evt.exitCode); 
		}
		
	}//class end
}//package end