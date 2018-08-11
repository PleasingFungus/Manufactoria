package  States
{
	import Buttons.CustomButton;
	import flash.events.Event;
	import org.flixel.*;
	import flash.system.System;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import Buttons.Dial;
	
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class SaveLoadState extends FlxState {
		
		[Embed(source = "/images/UI/kongbrowse.png")] public static const browse_png:Class; 
		[Embed(source = "/images/UI/kongshare.png")] public static const share_png:Class; 
		
		protected var inputField:FlxInputText;
		protected var firstTime:Boolean = true;
		protected var overwriteToggle:Dial;
		protected var overwriteToggled:Boolean;
		
		override public function create():void {
			Manufactoria.saveLevel();
			
			normalCreate();
			if (Manufactoria.KONG && Manufactoria.unlocked[FlxG.level] == Manufactoria.BEATEN) {
				add(new CustomButton(10, 110, browse_png, browse, "Browse levels!", "Admire others' solutions - or mock their crudity, and vow to better them!"));
				add(new CustomButton(180, 110, share_png, saveKongLevel, "Share level!", "Publish your level to the widest depths of the Internets, for all to marvel at!"));
			}
			
			add(new StateTransitionButton(5, 215, BuildState));
			
			add(new AudioButton());
			add(new Tooltip());
			FlxG.stage.frameRate = 30;
			FlxG.mouse.show();
		}
		
		private function normalCreate():void {
			
			add(inputField = new FlxInputText(5, 5, 290, 60, outputString, 0xffffff, null, 8, "left", true, loadFrom));
			add(new FlxText(5, 70, 290, "Copy this string and send it to others to share your machine! Use codes by either pasting them into this box, or putting them into your browser's address-bar!"));// \n\nIf you want to OVERWRITE your current machine with a code, TOGGLE overwriting here:"));
			
			var warning:FlxText = new FlxText(25, 200, 215, "IMPORTANT: Save/Load codes will PERMAMENTLY OVERWRITE your solution unless you hit THIS TOGGLE. OVERWRITE?");
			warning.alignment = "right";
			add(warning);
			
			overwriteToggle = new Dial(260, 210, "  NO", " YES")
			overwriteToggle.onClick = toggleOverwrite;
			overwriteToggle.toggle();
			Manufactoria.overwrite = true;
			add(overwriteToggle); 
		}
		
		private function toggleOverwrite():void {
			Manufactoria.overwrite = overwriteToggle.on;
			overwriteToggled = true;
		}
		
		override public function update():void {
			if (FlxG.mouse.justPressed()) {
				if (FlxG.mouse.x >= 10 && FlxG.mouse.x <= 310 && FlxG.mouse.y >= 10 && FlxG.mouse.y <= 210) {
					//inputField.toggleSelect();
					//System.setClipboard(inputField.getText();
					//inputField.text = "Saved to clipboard!";
					inputField.selectAll();
				}
			}
			
			super.update();
			Manufactoria.updateMusic();
		}
		
		public static function get levelString():String {
			var code:String = "";
			for (var i:int = 0; i < Manufactoria.components.length; i++) {
				if (Manufactoria.components[i].exists)
					code += Manufactoria.components[i].toString();
			}
			return code;
		}
		
		public static function get webString():String {
			var fullURL:String = new QueryString()._all;
			if (fullURL) {
				var swfIndex:int = fullURL.indexOf("Manufactoria.swf");
				if (swfIndex > -1) fullURL = fullURL.slice(0, swfIndex) + fullURL.slice(swfIndex + 16);
				var end:int = fullURL.indexOf("?"); 
				var webString:String = (end > -1 ? fullURL.slice(0, end) : fullURL)
			} else
				webString = "";
			return webString;
		}
		
		public static function get outputString():String {
			return webString + "?lvl=" + (FlxG.level + 1) + (Manufactoria.components ? "&code=" : "") + levelString + (FlxG.level >= Manufactoria.CUSTOM_OFFSET ? "&ctm="+FlxG.levels[FlxG.level] : '');
		}
		
		protected function saveTo(event:Event):void {
			if (firstTime) {
				firstTime = false;
			} else {
				System.setClipboard(inputField.getText());//.replace(/\n/g,'xxxx'));//.replace(/(\t|\n|\s{2,})/g, ''));
				inputField.text = "Saved to clipboard!";
			}
		}
		
		protected function loadFrom(event:Event = null):void {
			var code:String = inputField.getText()
			if (code.length < 5)	//minimum valid length for a codestring
				code = outputString;	//trying to avoid annoying enter-wipes-field bug
			
			Manufactoria.overwrite = overwriteToggle.on;//false;
			
			try {
				if(load(code)) //valid!
					FlxG.state = new BuildState();
			} catch (e:Object) {
				inputField.text = "Malformed string!";
				trace(e);
			} 
		}
		
		public static function load(input:String):Boolean {
			Manufactoria.components = new Array();
			
			if (!input)
				return false;
			
			//FlxG.log(FlxG.level +": \t" + input);
			//FlxG.log('\t'+Manufactoria.savedLevels[FlxG.level]);
			input = input.split(/\s+/).join('');
			
			var levelIndex:int = input.lastIndexOf("lvl");
			var start:int = input.lastIndexOf("code");
			if (start > -1) {
				if (levelIndex > -1) {
					var level:int = int(input.slice(levelIndex + 4, start - 1)) - 1;
					if (level >= 0) {
						FlxG.log("Loading level " + level);
						if (level >= Manufactoria.CUSTOM_OFFSET) {
							var levelCode:int = input.indexOf("ctm=");
							if (levelCode == -1) return false;
							FlxG.level = LevelSelectState.loadNewCustom(input.substr(levelCode + "ctm=".length));
						} else if (Manufactoria.unlocked[level])
							FlxG.level = level;
					} else {
						FlxG.log("Load of level " + level + " failed!");
						FlxG.state = new KongLoadFailState(level);
						return false;
					}
				}
				input = input.slice(start + 5);
			}
			
			Manufactoria.setGrid();
			
			if (input.charAt(input.length - 1) != ';')
				input = input + ';'; //be polite; semicolon-terminate your strings!
			
			var segments:Array = input.split(';');
			for (var i:int = 0; i < segments.length - 1; i++) {
				var newComponent:TileComponent = TileComponent.buildFromString(segments[i]);
				if (newComponent) {	//component in-bounds and healthy
					Manufactoria.components.push(newComponent);
				}
			}
			
			//prevent loading more than once component in a grid-index
			var components:Array = [];
			for (i = 0; i < Manufactoria.components.length; i++) {
				newComponent = Manufactoria.components[i]
				if (Manufactoria.grid[newComponent.gridIndex] == newComponent)
					components.push(newComponent);
			}
			Manufactoria.components = components;
			
			Manufactoria.saveLevel();
			
			return true;
		}
		
		private function browse():void {
			FlxG.kong.API.sharedContent.browse('Level',FlxG.kong.API.sharedContent.BY_NEWEST,'Level ' + FlxG.level + ' Solution');
		}
		
		public static function onLoadKongLevel(params:Object):void {
			FlxG.log("Loading Kongregate level!\nLevel:\t"+params.content);
			Manufactoria.overwrite = false;
			if (load(String(params.content)))
				FlxG.state = new BuildState();
			else
				FlxG.log("Kong-level load failed!");
		}
		
		private function saveKongLevel():void {
			FlxG.log("Saving: " + outputString);
			FlxG.kong.API.sharedContent.save('Level', outputString, onSaveFinished, BuildState.renderForSave(), 'Level ' + FlxG.level + ' Solution')
			render(); //to prevent messiness
		}
		
		private function onSaveFinished(params:Object):void {
			if (params.success) {
				inputField.text = "Level successfully published!";
			} else {
				inputField.text = "Level failed to publish!";
			}
		}
	}

}