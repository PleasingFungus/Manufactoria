package Buttons
{
	import org.flixel.*;
	import States.BuildState;
	import States.SaveLoadState;
	import States.IntroState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class MenuButton extends Button {
		
		[Embed(source = "/images/UI/button.png")] public static const normal:Class;
		[Embed(source = "/images/UI/button_pressed.png")] public static const pressed:Class;
		
		protected var level:int;
		protected var text:FlxText;
		protected var depressed:Boolean = false;
		
		public function MenuButton(i:int) {
			super(5 + 105 * (i % 3), 69 + 34 * Math.floor(i / 3), normal);
			
			var color:int, name:String;
			if (Manufactoria.unlocked[i]) {
				name = FlxG.levels[i].name;
				color = LEVEL_COLORS[Manufactoria.unlocked[i]];
			} else {
				if (FlxG.levels[i].hidden)
					name = "???????????";
				else
					name = FlxG.levels[i].name;
				color = LEVEL_COLORS[0];
			}
			text = new FlxText(x + 3, y + 5, 94, name).setFormat(null, 8, color, "center");
			level = i;
		}
		
		override public function update():void {
			super.update();
			
			if (!Manufactoria.unlocked[level]) return;
			
			if (FlxG.mouse.justPressed() && moused) {
				loadGraphic(pressed);
				depressed = true;
			} else if (depressed && FlxG.mouse.justReleased()) {
				if (moused) {
					FlxG.level = level;
					
					Manufactoria.components = new Array();
					Manufactoria.setGrid();
					FlxG.timeScale = 1;
					
					if (FlxG.levels[FlxG.level].binary && !IntroState.viewedScenes[IntroState.BINARY]) {
						IntroState.slides = IntroState.binary;
						FlxG.state = new IntroState();
					} else {
						SaveLoadState.load(Manufactoria.savedLevels[FlxG.level]);
						FlxG.state = new BuildState();
					}
				} else {
					loadGraphic(normal);
					depressed = false;
				}
			}
			
		}
		
		override public function getDescription(verbose:Boolean):String {
			if (Manufactoria.unlocked[level])
				return "Test robotic " + FlxG.levels[level].name.toLowerCase(); //verbose ? FlxG.levels[level].fluff : 
			else
				return verbose ? "These robots are not yet ready for testing." : "Locked!"
		}
		
		override public function render():void {
			super.render();
			text.render();
		}
		
		
		public static const LEVEL_COLORS:Array = new Array(0xd01616, 0xffffff, 0x16ff16);
	}

}