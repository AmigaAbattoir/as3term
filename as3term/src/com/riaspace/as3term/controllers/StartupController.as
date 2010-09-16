package com.riaspace.as3term.controllers
{
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.riaspace.as3term.models.ApplicationModel;
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	import org.swizframework.storage.SharedObjectBean;

	public class StartupController
	{
		[Inject]
		public var settings:SharedObjectBean;
		
		[Inject]
		public var applicationModel:ApplicationModel;
		
		[Inject]
		public var updater:NativeApplicationUpdater;
		
		protected var os:String = Capabilities.os.toLowerCase();
		
		[PostConstruct]
		public function init():void
		{
//			settings.clear();
			
			initTemplate();
			
			initSettings();
			
			if (applicationModel.currentState == ApplicationModel.EDITOR_STATE)
			{
				updater.addEventListener(UpdateEvent.INITIALIZED, updater_initializedHandler);
				updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, updater_statusUpdateHandler);
				updater.initialize();
			}
		}

		protected function initTemplate():void 
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(File.applicationDirectory.resolvePath("assets/ScriptTemplate.txt"), FileMode.READ);
			applicationModel.scriptTemplate = fileStream.readUTFBytes(fileStream.bytesAvailable);
		}
		
		protected function updater_initializedHandler(event:UpdateEvent):void
		{
			updater.checkNow();
		}

		protected function updater_statusUpdateHandler(event:StatusUpdateEvent):void
		{
			if (event.available)
			{
				event.preventDefault();
				applicationModel.currentState = ApplicationModel.UPDATES_STATE;
			}
		}
		
		protected function initSettings():void 
		{
			var javaExecutable:File;
			var javaExecutablePath:String = 
				settings.getString("JAVA_EXECUTABLE_PATH");
			
			if (javaExecutablePath)
				javaExecutable = new File(javaExecutablePath);
			
			if (!javaExecutable || !javaExecutable.exists)
			{
				if (os.indexOf('win') > -1)
				{
					javaExecutable = new File("c:/windows/system32/javaw.exe");
				}
				else
				{
					javaExecutable = new File("/usr/bin/java");
					if (!javaExecutable.exists)
						javaExecutable = new File(os.indexOf("mac") > -1 ? 
							"/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java" 
							: 
							"/etc/alternatives/java");
				}
			}
			
			var flexSdkDir:File;
			var flexSdkDirPath:String = settings.getString("FLEX_SDK_DIR_PATH");
			
			if (flexSdkDirPath)
				flexSdkDir = new File(flexSdkDirPath);
			
			applicationModel.javaExecutable = javaExecutable;
			applicationModel.flexSdkDir = flexSdkDir;
			
			if (flexSdkDir && flexSdkDir.exists && javaExecutable && javaExecutable.exists)
				applicationModel.currentState = ApplicationModel.EDITOR_STATE;
			else
				applicationModel.currentState = ApplicationModel.SETTINGS_STATE;
		}
	}
}