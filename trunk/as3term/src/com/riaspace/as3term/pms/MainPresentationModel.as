package com.riaspace.as3term.pms
{
	import com.riaspace.as3term.events.EditorEvent;
	import com.riaspace.as3term.models.ApplicationModel;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

	public class MainPresentationModel
	{
		[Dispatcher]
		public var dispatcher:EventDispatcher;
		
		[Bindable]
		[Inject(source="applicationModel.currentState", twoWay="true", bind="true")]
		public var currentState:String;
		
		public function btnNew_clickHandler(event:MouseEvent):void
		{
			dispatcher.dispatchEvent(new EditorEvent(EditorEvent.CLEAR_EDITOR));
		}

		public function btnSettings_clickHandler(event:MouseEvent):void
		{
			currentState = ApplicationModel.SETTINGS_STATE;
		}

	}
}