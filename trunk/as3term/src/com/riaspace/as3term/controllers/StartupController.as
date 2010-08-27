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
		
		[PostConstruct]
		public function init():void
		{
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
			var mxmlc:File;
			var flexHome:String = settings.getString("FLEX_HOME");
			
			if (flexHome)
				mxmlc = new File(flexHome)
					.resolvePath("bin")
					.resolvePath((Capabilities.os.toLowerCase().indexOf("Win") > -1 ? "mxmlc.exe" : "mxmlc"));
			
			if (mxmlc && mxmlc.exists)
			{
				applicationModel.flexHome = flexHome;
				applicationModel.mxmlc = mxmlc;
				applicationModel.currentState = ApplicationModel.EDITOR_STATE;
			}
			else
			{
				applicationModel.currentState = ApplicationModel.SETTINGS_STATE;
			}
		}
	}
}