package com.riaspace.as3term.pms
{
	import air.update.events.DownloadErrorEvent;
	import air.update.events.UpdateEvent;
	
	import com.riaspace.as3term.models.ApplicationModel;
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;

	public class UpdatePresentationModel
	{
		[Inject]
		[Bindable]
		public var updater:NativeApplicationUpdater;
		
		[Inject]
		public var applicationModel:ApplicationModel;
		
		[Bindable]
		public var downlaoding:Boolean = false;
		
		public function btnNo_clickHandler(event:MouseEvent):void
		{
			applicationModel.currentState = ApplicationModel.EDITOR_STATE;
		}

		public function btnYes_clickHandler(event:MouseEvent):void
		{
			downlaoding = true;
			updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
			updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
			updater.downloadUpdate();
		}
		
		protected function updater_downloadErrorHandler(event:DownloadErrorEvent):void
		{
			Alert.show("Error downloading update file, try again later.");
			applicationModel.currentState = ApplicationModel.EDITOR_STATE;
		}
		
		protected function updater_downloadCompleteHandler(event:UpdateEvent):void
		{
			setTimeout(updater.installUpdate, 10);
		}
	}
}