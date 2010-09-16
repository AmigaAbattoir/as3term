package com.riaspace.as3term.views.validators
{
	import flash.filesystem.File;
	
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	public class PathValidator extends Validator
	{
		[Bindable]
		public var pathNotFoundError:String = "Path not found!";
		
		[Bindable]
		public var isDirectory:Boolean = false;
		
		[Bindable]
		public var directoryShouldContain:String;
		
		public function PathValidator()
		{
			super();
		}
		
		override public function validate(
							value:Object=null, 
							suppressEvents:Boolean=false):ValidationResultEvent
		{

			if (value == null)
				value = getValueFromSource();   

			var resultEvent:ValidationResultEvent;

			if (value != null && value != "")
			{
				var file:File = new File(value as String);
				if (file.exists)
				{
					if (isDirectory)
					{
						if (file.isDirectory)
						{
							if (!directoryShouldContain)
							{
								resultEvent = 
									new ValidationResultEvent(ValidationResultEvent.VALID);
							}
							else
							{
								if (file.resolvePath(directoryShouldContain).exists)
								{
									resultEvent = 
										new ValidationResultEvent(ValidationResultEvent.VALID);
								}
								else
								{
									resultEvent = 
										new ValidationResultEvent(ValidationResultEvent.INVALID);
									resultEvent.results = [new ValidationResult(true, "", 
										"directoryShouldContain", 
										"Selected path doesn't contain required file: " 
										+ directoryShouldContain)];
								}
							}
						}
						else
						{
							resultEvent = 
								new ValidationResultEvent(ValidationResultEvent.INVALID);
							resultEvent.results = [new ValidationResult(true, "", 
								"pathNotDirectory", "Selected path is not a directory!")];
						}
					}
					else 
					{
						resultEvent = 
							new ValidationResultEvent(ValidationResultEvent.VALID);
					}
					
				}
				else
				{
					resultEvent = 
						new ValidationResultEvent(ValidationResultEvent.INVALID);
					resultEvent.results = [new ValidationResult(true, "", 
						"pathNotFound", pathNotFoundError)];
				}
			}
			else
			{
				resultEvent = 
					new ValidationResultEvent(ValidationResultEvent.INVALID);
				resultEvent.results = [new ValidationResult(true, "", 
					"pathRequired", requiredFieldError)];
			}
			
			dispatchEvent(resultEvent);
			return resultEvent; 
		}
	}
}