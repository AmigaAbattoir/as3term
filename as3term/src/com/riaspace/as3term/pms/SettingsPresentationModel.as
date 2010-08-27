package com.riaspace.as3term.pms
{
	import com.riaspace.as3term.models.ApplicationModel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import org.swizframework.storage.SharedObjectBean;

	public class SettingsPresentationModel
	{
		
		[Bindable]
		public var selectedFlexHome:String;
		
		private var selectedMxmlc:File;
		
		[Bindable]
		public var currentState:String;

		[Inject]
		public var applicationModel:ApplicationModel;

		[Inject]
		public var settings:SharedObjectBean;
		
		[PostConstruct]
		public function init():void
		{
			selectedFlexHome = applicationModel.flexHome;
			resolveMxmlc(new File(selectedFlexHome));
		}
		
		protected function resolveMxmlc(flexHomeRef:File):void
		{
			var mxmlc:File;
			
			if (flexHomeRef.exists)
				mxmlc = flexHomeRef.resolvePath("bin").resolvePath(
					(Capabilities.os.toLowerCase().indexOf("Win") > -1 ? "mxmlc.exe" : "mxmlc"));
			
			if (mxmlc && mxmlc.exists)
			{
				currentState = "valid";
				selectedFlexHome = flexHomeRef.nativePath;
				selectedMxmlc = mxmlc;
			}
			else
			{
				currentState = "notvalid";
			}
		}
		
		public function btnSelectFlexHome_clickHandler(event:MouseEvent):void
		{
			var flexHomeRef:File = new File(selectedFlexHome);
			flexHomeRef.addEventListener(Event.SELECT, flexHomeRef_selectHandler);
			flexHomeRef.browseForDirectory("Select bin folder of Flex SDK...");
		}
		
		public function flexHomeRef_selectHandler(event:Event):void
		{
			resolveMxmlc(event.target as File);
		}
		
		public function btnSaveSettings_clickHandler(event:MouseEvent):void
		{
			settings.setString("FLEX_HOME", selectedFlexHome); 
			
			applicationModel.flexHome = selectedFlexHome;
			applicationModel.mxmlc = selectedMxmlc;
			applicationModel.currentState = ApplicationModel.EDITOR_STATE;
		}
	}
}