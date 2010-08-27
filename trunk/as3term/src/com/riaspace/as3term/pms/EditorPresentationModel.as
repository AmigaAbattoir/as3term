package com.riaspace.as3term.pms
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.KeyboardEvent;
	import flash.events.NativeProcessExitEvent;
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
		public var inputContent:String = 'var result:String = "hello world!";\n// hit SHIFT + ENTER to execute\nreturn result;';
		
		[Inject(source="applicationModel.mxmlc", bind="true")]
		public var mxmlc:File;
		
		protected var scriptFile:File = File.applicationStorageDirectory.resolvePath("Script.as");
		
		protected var swfFile:File = File.applicationStorageDirectory.resolvePath("script.swf");
		
		protected var scriptTemplate:String = "package {import flash.display.Sprite;public class Script extends Sprite{public function execute():String{{0}}}}";
		
		protected var shiftPressed:Boolean = false;
		
		protected function executeScript():void
		{
			if (swfFile.exists)
				swfFile.deleteFile();
			
			outputContent = "Compiling...";
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(scriptFile, FileMode.WRITE);
			fileStream.writeUTFBytes(StringUtil.substitute(scriptTemplate, inputContent));
			fileStream.close();
			
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = mxmlc;
			
			var args:Vector.<String> = new Vector.<String>();
			args.push(
				"-static-link-runtime-shared-libraries=true",
				"-debug=true",
				scriptFile.nativePath, 
				"-source-path", File.applicationStorageDirectory.nativePath, 
				"-output=" + swfFile.nativePath);
			info.arguments = args;
			
			var mxmlcProcess:NativeProcess = new NativeProcess();
			mxmlcProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
			mxmlcProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorData); 
			mxmlcProcess.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			mxmlcProcess.start(info);
		}
		
		protected function onStandardOutputData(event:ProgressEvent):void
		{
			var mxmlcProcess:NativeProcess = event.target as NativeProcess;
			var string:String = mxmlcProcess.standardOutput.readUTFBytes(event.bytesLoaded);
			if (string.indexOf("Loading configuration") != 0 && string != "")
				outputContent = string;
		}

		protected function onStandardErrorData(event:ProgressEvent):void
		{
			var mxmlcProcess:NativeProcess = event.target as NativeProcess;
			outputContent = mxmlcProcess.standardError.readUTFBytes(event.bytesLoaded);
		}
		
		protected function onExit(event:NativeProcessExitEvent):void
		{
			if (swfFile.exists)
			{
				var request:URLRequest = new URLRequest(swfFile.url);
				
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.load(request);
			}
		}

		protected function onComplete(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var LoadedClass:Class = loaderInfo.applicationDomain.getDefinition("Script") as Class;
			var object:Object = new LoadedClass();
			outputContent = object.execute();
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