package com.riaspace.as3term.components
{
	import flash.text.StyleSheet;
	
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	
	import mx.events.FlexEvent;
	
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;
	import spark.utils.TextFlowUtil;
	
	[Bindable]
	public class AS3TextArea extends TextArea
	{
		
		public var syntaxStyles:StyleSheet = new StyleSheet();
		
		public var accessModifiers:Array = ["public", "private", "protected", "internal"];
		
		public var classMethodVariableModifiers:Array = ["class", "const", "extends", "final", "function", "get", "dynamic", "implements", "interface", "native", "new", "set", "static"]; 
		
		public var flowControl:Array = ["break", "case", "continue", "default", "do", "else", "for", "for\ each", "if", "is", "label", "typeof", "return", "switch", "while", "in"];
		
		public var errorHandling:Array = ["catch", "finally", "throw", "try"];
		
		public var packageControl:Array = ["import", "package"];
		
		public var variableKeywords:Array = ["super", "this", "var"];
		
		public var returnTypeKeyword:Array = ["void"];
		
		public var namespaces:Array = ["default xml namespace", "namespace", "use namespace"];
		
		public var literals:Array = ["null", "true", "false"];
		
		public var primitives:Array = ["Boolean", "int", "Number", "String", "uint"];
		
		public var strings:Array = ['".*?"', "'.*?'"];
		
		public var comments:Array = ["//.*$", "/\\\*[.\\w\\s]*\\\*/", "/\\\*([^*]|[\\r\\n]|(\\\*+([^*/]|[\\r\\n])))*\\\*/"];

		public var syntaxStyleSheet:String = ".text{color:#dfe0e2;}.default{color:#5d7dfc;} .var{color:#6f9fcf;} .function{color:#45a173;} .strings{color:#a82929;} .comment{color:#0e9e0f;font-style:italic;} .asDocComment{color:#5c77c8;}";
		
		protected var syntax:RegExp;
		
		protected var styleSheet:StyleSheet = new StyleSheet();
		
		public function AS3TextArea()
		{
			super();
			
			initSyntaxRegExp();

			styleSheet.parseCSS(syntaxStyleSheet);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			addEventListener(TextOperationEvent.CHANGE, onChange);
		}

		protected function onChange(event:TextOperationEvent):void
		{
			colorize();
		}

		protected function onCreationComplete(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			colorize();
		}
		 
		protected function initSyntaxRegExp():void 
		{
			var pattern:String = "";
			
			for each(var str:String in strings.concat(comments))
			{
				pattern += str + "|";
			}
			
			var createRegExp:Function = function(keywords:Array):String
			{
				var result:String = "";
				for each(var keyword:String in keywords)
				{
					result += (result != "" ? "|" : "") + "\\b" + keyword + "\\b";
				}
				return result;
			};
			
			pattern += createRegExp(accessModifiers)
				+ "|" 
				+ createRegExp(classMethodVariableModifiers)
				+ "|"
				+ createRegExp(flowControl)
				+ "|"
				+ createRegExp(errorHandling)
				+ "|"
				+ createRegExp(packageControl)
				+ "|"
				+ createRegExp(variableKeywords)
				+ "|"
				+ createRegExp(returnTypeKeyword)
				+ "|"
				+ createRegExp(namespaces)
				+ "|"
				+ createRegExp(literals)
				+ "|"
				+ createRegExp(primitives);
			
			this.syntax = new RegExp(pattern, "gm");
		}
		
		protected function colorize():void
		{
			var pos:int = this.selectionActivePosition;
			
			var script:String = this.text
				.replace(/</g, "&lt;")
				.replace(/>/g, "&gt;")
				.replace(/&/g, "&amp;");
			
			var token:* = syntax.exec(script);
			while(token)
			{
				var tokenValue:String = token[0];
				var tokenType:String = getTokenType(tokenValue);
				
				var tokenStyleName:String = "." + tokenType;
				var tokenStyle:Object = 
					styleSheet.styleNames.indexOf(tokenStyleName) > -1
					?
					styleSheet.getStyle("." + tokenType)
					:
					styleSheet.getStyle(".default");
				
				var spanTemplate:String = "<span" + getStyleAttributes(tokenStyle) + "></span>";
				
				script = 
					script.substring(0, syntax.lastIndex - tokenValue.length) 
					+ spanTemplate.replace(/></, ">" + tokenValue + "<")
					+ script.substring(syntax.lastIndex);
				
				syntax.lastIndex = syntax.lastIndex + spanTemplate.length; 
				token = syntax.exec(script);
			}
			
			var p:String = "<p " + getStyleAttributes(styleSheet.getStyle(".text")) + ">" + script + "</p>";
			trace(p);
			this.textFlow = TextFlowUtil.importFromString(p, WhiteSpaceCollapse.PRESERVE);
			this.selectRange(pos, pos);
		}
		
		protected function getStyleAttributes(style:Object):String
		{
			return (style.color ? " color='" + style.color + "'" : "")
				+ (style.fontFamily ? " fontFamily='" + style.fontFamily + "'" : "")
				+ (style.fontSize ? " fontSize='" + style.fontSize + "'" : "")
				+ (style.fontStyle ? " fontStyle='" + style.fontStyle + "'" : "")
				+ (style.fontWeight ? " fontWeight='" + style.fontWeight + "'" : ""); 
		}
		
		protected function getTokenType(tokenValue:String):String
		{
			var result:String;
			if (tokenValue == "var")
			{
				return "var";
			}
			else if (tokenValue == "function")
			{
				return "function";
			}
			else if (tokenValue.indexOf("\"") == 0 || tokenValue.indexOf("'") == 0)
			{
				return "strings";
			}
			else if (tokenValue.indexOf("/**") == 0)
			{
				return "asDocComment";
			}
			else if (tokenValue.indexOf("//") == 0 || tokenValue.indexOf("/*") == 0)
			{
				return "comment";
			}
			else if (accessModifiers.indexOf(tokenValue) > -1)
			{
				return "accessModifiers";
			}
			else if (classMethodVariableModifiers.indexOf(tokenValue) > -1)
			{
				return "classMethodVariableModifiers";
			}
			else if (flowControl.indexOf(tokenValue) > -1)
			{
				return "flowControl";
			}
			else if (errorHandling.indexOf(tokenValue) > -1)
			{
				return "errorHandling";
			}
			else if (packageControl.indexOf(tokenValue) > -1)
			{
				return "packageControl";
			}
			else if (variableKeywords.indexOf(tokenValue) > -1)
			{
				return "variableKeywords";
			}
			else if (returnTypeKeyword.indexOf(tokenValue) > -1)
			{
				return "returnTypeKeyword";
			}
			else if (namespaces.indexOf(tokenValue) > -1)
			{
				return "namespaces";
			}
			else if (literals.indexOf(tokenValue) > -1)
			{
				return "literals";
			}
			else if (primitives.indexOf(tokenValue) > -1)
			{
				return "primitives";
			}
			return result;
		}
	}
}