package com.riaspace.as3term.pms
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.operations.SplitParagraphOperation;
	
	import mx.utils.StringUtil;
	
	import spark.events.TextOperationEvent;
	
	public class EditorPresentationModel
	{
		[Bindable]
		public var outputContent:String;
		
		[Bindable]
		public var errorOutput:Boolean = false;
		
		[Bindable]
		public var inputContent:String = 'var result:String = "hello world!";\n// hit SHIFT + ENTER to execute\nreturn result;';
		
		[Inject(source="applicationModel.javaExecutable", bind="true")]
		public var javaExecutable:File;
		
		[Inject(source="applicationModel.flexSdkDir", bind="true")]
		public var flexSdkDir:File;
		
		[Inject(source="applicationModel.scriptTemplate")]
		public var scriptTemplate:String;
		
		protected var compileStatement:String = 
			"mxmlc -file-specs Script.as -o Script.swf -debug=true " +
			"-static-link-runtime-shared-libraries=true\n";
		
		protected var scriptFile:File = File.applicationStorageDirectory.resolvePath("Script.as");
		
		protected var swfFile:File = File.applicationStorageDirectory.resolvePath("script.swf");
		
		protected var shiftPressed:Boolean = false;
		
		protected var javaProcess:NativeProcess;
		
		[PostConstruct]
		public function init():void
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = javaExecutable;
			info.workingDirectory = File.applicationStorageDirectory;
			
			var args:Vector.<String> = new Vector.<String>();
			args.push(
				"-Dapplication.home=" + flexSdkDir.nativePath,
				"-jar", 
				flexSdkDir.resolvePath("lib/fcsh.jar").nativePath);
			info.arguments = args;
			
			javaProcess = new NativeProcess();
			javaProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
			javaProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorData); 
			javaProcess.start(info);
		}

		private function onStandardOutputData(event:ProgressEvent):void
		{
			var out:String = javaProcess.standardOutput.readUTFBytes(event.bytesLoaded);
			if (out.indexOf("fcsh: Assigned 1 as the compile target id") == 0)
			{
				compileStatement = "compile 1\n";
			}
			else if (out.indexOf("Script.swf") == 0)
			{
				if (swfFile.exists)
				{
					var request:URLRequest = new URLRequest(swfFile.url);
					
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					loader.load(request);
				}
			}
		}
		
		protected function executeScript():void
		{
			if (swfFile.exists)
				swfFile.deleteFile();

			errorOutput = false;
			outputContent = "Compiling...";
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(scriptFile, FileMode.WRITE);
			fileStream.writeUTFBytes(StringUtil.substitute(scriptTemplate, inputContent));
			fileStream.close();
			
			javaProcess.standardInput.writeUTFBytes(compileStatement);
		}
		
		protected function onStandardErrorData(event:ProgressEvent):void
		{
			errorOutput = true;
			outputContent += javaProcess.standardError.readUTFBytes(event.bytesLoaded);
		}
		
		protected function onComplete(event:Event):void
		{
			outputContent = "";
			
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var Script:Class = loaderInfo.applicationDomain.getDefinition("Script") as Class;
			var script:Object = new Script();
			script.traceFunction = appendTrace;
			appendTrace(script.execute());
		}
		
		protected function appendTrace(...parameters):void
		{
			if (parameters.length > 0)
			{
				var str:String = "";
				if (parameters[0] is Array)
					for each (var param:* in parameters[0])
						str += param + " ";
				else
					str = parameters[0];

				outputContent += str + "\n";
			}
		}
		
		public function txtScript_onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SHIFT)
				shiftPressed = true;
		}
		
		public function txtScript_keyUpHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SHIFT)
				shiftPressed = false;
		}
		
		public function txtScript_changeHandler(event:TextOperationEvent):void
		{
			if (event.operation is SplitParagraphOperation && shiftPressed)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				
				executeScript();
			}
		}
		
		[Mediate("EditorEvent.CLEAR_EDITOR")]
		public function clearEditor():void
		{
			inputContent = "\nreturn null;";
		}
	}
}