package States 
{
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import Buttons.CustomButton;
	import flash.events.Event;
	import org.flixel.*;
	
	FlxG.keys
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class LevelSelectState extends FlxState {
		[Embed(source = "/images/Backgrounds/levelselect.png")] private static const background:Class;
		[Embed(source = "/images/UI/new.png")] private static const _new:Class;
		[Embed(source = "/images/UI/edit.png")] private static const edit:Class;
		[Embed(source = "/images/UI/run.png")] private static const test:Class;
		[Embed(source = "/images/UI/clear.png")] private static const del:Class;
		
		[Embed(source = "/images/UI/share_button.png")] public static const browse_png:Class;
		
		protected var stringField:FlxInputText;
		protected var stringDesc:FlxText;
		
		protected var levelSelect:SelectField;
		protected var editButtons:FlxGroup;
		protected var newButton:StateTransitionButton; 
		
		override public function create():void {
			add(new FlxSprite(0, 0, background));
			
			if (Manufactoria.overwrite && Manufactoria.components.length) //popped in from a previous level
				Manufactoria.saveLevel();
			
			//default to selecting index 0
			if (FlxG.level < Manufactoria.CUSTOM_OFFSET)
				FlxG.level = Manufactoria.CUSTOM_OFFSET;
			
			var stringFieldString:String = SaveLoadState.webString + (FlxG.levels[FlxG.level] ? "?ctm=" + FlxG.levels[FlxG.level] : '');
			add(stringField = new FlxInputText(10, 17, 135, 138, stringFieldString,  0xffffff, null, 8, "left", true, loadLevel)); 
			add(stringDesc = new FlxText(10, 160, 135, FlxG.levels[FlxG.level] ? "Copy this string and send it to others to share your level!" : "Paste level-strings into the box to load them!"));
			
			add(levelSelect = new SelectField(175, 17).configure(135, 138));
			levelSelect.load(FlxG.levels.slice(Manufactoria.CUSTOM_OFFSET));
			levelSelect.selection = FlxG.level - Manufactoria.CUSTOM_OFFSET;
			levelSelect.onSelect = selectLevel;
			
			editButtons = new FlxGroup();
			editButtons.add(new CustomButton(200, 185, test, savetest, "Play!", "Play the selected level!"));
			editButtons.add(new StateTransitionButton(240, 185, LevelEditState).modify(edit, "Edit!", "Edit an existing level! Fill it with delights & splendors!"));
			editButtons.add(new CustomButton(280, 185, del, deleteLevel, "Delete!", "Delete the selected level!"));
			//editButtons.add(new StateTransitionButton(280, 185, ConfirmLevelDelete));
			if (Manufactoria.KONG)
				add(new CustomButton(180, 215, browse_png, browse, "Browse levels!", "Discover riddles set by others - and solve them!"));
			newButton = new StateTransitionButton(240, 185, LevelEditState).modify(_new, "New Level!", "Make a new level! Fill that empty slot in your life!");
			add(newButton);
			add(editButtons);
			
			//if there's a level already there: display build/test-state, edit-state, delete level
				//and text-box description suggests that you can copy the level from it
			if (FlxG.levels[FlxG.level])
				newButton.exists = false;
			//otherwise: only display edit-state
				//and text-box description suggests copying a level into it
			else
				editButtons.exists = false;
			
			
			//custom_offset -> custom_offset + max - 1 hold custom levels - save.data.custom...
			//unlocked stores beaten-state of each level (defaults to 0, beaten = 2) - colors on choice-menu
			//enter save code: overwrite selected slot (!! prompt! or just merge with the below)
			//load custom from save/load or web: don't save? prompt to save (on exit)?
			
			add(new StateTransitionButton(295, 215, MenuState));
			
			add(new AudioButton());
			add(new Tooltip());
			
			Manufactoria.components = new Array();
			
			Manufactoria.levelEntry = LevelSelectState;
			FlxG.timeScale = 1;
			FlxG.stage.frameRate = 30;
			FlxG.mouse.show();
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
			if (FlxG.mouse.justPressed() && FlxG.mouse.x >= 10 && FlxG.mouse.x <= 145 && FlxG.mouse.y >= 17 && FlxG.mouse.y <= 155) {
				stringField.selectAll();
			}
		}
		
		protected function loadLevel(event:Event = null):void {
			var levelCode:String = stringField.text;
			var webStart:int = levelCode.indexOf("ctm=");
			if (webStart > -1) { //BROKEN: FIXME (???)
				var ampInd:int = levelCode.indexOf("&", webStart);
				if (ampInd == -1) ampInd = levelCode.length;
				levelCode = levelCode.substring(webStart + 4, ampInd);
			} else {
				stringField.text = "Invalid custom level code!";
				return;
			}
			var loadedLevel:Level = Level.fromString(levelCode);
			if (loadedLevel) {
				FlxG.levels[levelSelect.selection + Manufactoria.CUSTOM_OFFSET] = loadedLevel;
				//TODO: SAVE HERE
				levelSelect.load(FlxG.levels.slice(Manufactoria.CUSTOM_OFFSET));
				
				newButton.exists = false;
				editButtons.exists = true;
			} else {
				selectLevel(levelSelect.selection); //reset text
			}
		}
		
		protected function selectLevel(level:int):void {
			FlxG.level = level + Manufactoria.CUSTOM_OFFSET;
			stringField.text = SaveLoadState.webString + (FlxG.levels[FlxG.level] ? "?ctm="+ FlxG.levels[FlxG.level] : '');
			stringDesc.text = FlxG.levels[FlxG.level] ? "Copy this string and send it to others to share your level!" : "Paste level-strings into the box to load them!";
			newButton.exists = !(editButtons.exists = FlxG.levels[FlxG.level] != null);
		}
		
		protected function savetest():void {
			Manufactoria.setGrid();
			Manufactoria.components = new Array();
			FlxG.state = new BuildState();
		}
		
		private function deleteLevel():void {
			FlxG.levels[FlxG.level] = null;
			Manufactoria.saveCustomLevels();
			
			levelSelect.exists = false;
			levelSelect = new SelectField(175, 17).configure(135, 138);
			levelSelect.load(FlxG.levels.slice(Manufactoria.CUSTOM_OFFSET));
			levelSelect.selection = FlxG.level - Manufactoria.CUSTOM_OFFSET;
			levelSelect.onSelect = selectLevel;
			add(levelSelect);
			
			Tooltip.tracker.moused = null;
			
			selectLevel(FlxG.level);
		}
		
		private function browse():void {
			FlxG.kong.API.sharedContent.browse('Custom Level',FlxG.kong.API.sharedContent.BY_NEWEST);
		}
		
		public static function onLoadKongCustom(params:Object):void {
			FlxG.log("Loading Kongregate level!\nLevel:\t" + params.content);
			var customIndex:int = loadNewCustom(params.content);
			if (customIndex > -1) {
				FlxG.level = customIndex;
				Manufactoria.setGrid();
				Manufactoria.components = [];
				FlxG.state = new BuildState();
			} else {
				FlxG.log("Kongregate custom level load failed!");
			}
		}
		
		public static function loadNewCustom(levelCode:String, levels:Array = null):int {
			FlxG.log("Loading custom: "+levelCode);
			var newLevel:Level = Level.fromString(levelCode);
			FlxG.log("New level: " + newLevel);
			if (newLevel == null)
				return -1;
			
			if (!levels)
				levels = FlxG.levels;
			
			for (var i:int = Manufactoria.CUSTOM_OFFSET;
				 i < Manufactoria.CUSTOM_OFFSET + Manufactoria.CUSTOM_MAX && levels[i] && levels[i].name != newLevel.name;
				 i++) FlxG.log("Testing: "+i);
			if (i == Manufactoria.CUSTOM_OFFSET + Manufactoria.CUSTOM_MAX)
				i--;
			levels[i] = newLevel;
			Manufactoria.saveCustomLevels(levels);
			return i;
		}
	}

}