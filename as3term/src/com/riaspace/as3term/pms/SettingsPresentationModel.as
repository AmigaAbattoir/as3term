package com.riaspace.as3term.pms
{
	import com.riaspace.as3term.models.ApplicationModel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.validators.Validator;
	
	import org.swizframework.storage.SharedObjectBean;

	public class SettingsPresentationModel
	{
		
		[Bindable]
		public var selectedFlexSdkDirPath:String;
		
		[Bindable]
		public var selectedJavaPath:String;
		
		[Inject]
		public var applicationModel:ApplicationModel;

		[Inject]
		public var settings:SharedObjectBean;
		
		[PostConstruct]
		public function init():void
		{
			if (applicationModel.javaExecutable)
				selectedJavaPath = applicationModel.javaExecutable.nativePath;
			
			if (applicationModel.flexSdkDir)
				selectedFlexSdkDirPath = applicationModel.flexSdkDir.nativePath;
		}

		public function btnSelectJavaPath_clickHandler(event:MouseEvent):void
		{
			var javaPathRef:File = new File(selectedJavaPath);
			javaPathRef.addEventListener(Event.SELECT, 
				function(event:Event):void 
				{
					selectedJavaPath = File(event.target).nativePath;
				});
			javaPathRef.browseForOpen("Select java executable file...");			
		}
		
		public function btnSelectFlexHome_clickHandler(event:MouseEvent):void
		{
			var flexHomeRef:File = new File(selectedFlexSdkDirPath);
			flexHomeRef.addEventListener(Event.SELECT, 
				function(event:Event):void 
				{
					selectedFlexSdkDirPath = File(event.target).nativePath;
				});
			flexHomeRef.browseForDirectory("Select Flex SDK home folder...");
		}
		
		public function btnSaveSettings_clickHandler(validators:Array):void
		{
			if (Validator.validateAll(validators).length == 0)
			{
				applicationModel.flexSdkDir = new File(selectedFlexSdkDirPath);
				applicationModel.javaExecutable = new File(selectedJavaPath);
				
				settings.setString("JAVA_EXECUTABLE_PATH", 
					applicationModel.javaExecutable.nativePath);
				settings.setString("FLEX_HOME",
					applicationModel.flexSdkDir.nativePath);
				
				applicationModel.currentState = ApplicationModel.EDITOR_STATE;
			}
		}
	}
}