package com.riaspace.as3term.events
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static const CLEAR_EDITOR:String = "clearEditor";
		
		public function EditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}