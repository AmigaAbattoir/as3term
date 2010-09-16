package com.riaspace.as3term.models
{
	import flash.filesystem.File;

	[Bindable]
	public class ApplicationModel
	{
		
		public static const EDITOR_STATE:String = "editor";
		
		public static const UPDATES_STATE:String = "updates";
		
		public static const SETTINGS_STATE:String = "settings";
		
		public var currentState:String;
		
		public var javaExecutable:File;
		
		public var flexSdkDir:File;
		
		public var scriptTemplate:String;
		
	}
}