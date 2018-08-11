package Buttons 
{
	import Buttons.Button;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import States.BuildState;
	import States.IntroState;
	import States.SaveLoadState;
	import States.MenuState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class LevelButton extends Button
	{
		[Embed(source = "/images/UI/levelbutton_border.png")] public static const border:Class;
		[Embed(source = "/images/UI/levelbutton_shadow.png")] public static const _shadow:Class;
		[Embed(source = "/images/UI/levelbutton_cover.png")] public static const cover:Class;
		protected var level:int;
		protected var shadow:FlxSprite;
		protected var depressed:Boolean = false;
		
		public function LevelButton(X:int, Y:int, level:int) 
		{
			super(X, Y, null);
			
			//var lock:int = Manufactoria.unlocked[level] ? Manufactoria.unlocked[level] : 0
			createGraphic(19, 19, LEVEL_COLORS[Manufactoria.unlocked[level]], true);
			draw(new FlxSprite(0, 0, border));
			draw(new FlxSprite(0, 0, Robot.ROBOTS[level]), 2, 2);
			if (!Manufactoria.unlocked[level] && !Manufactoria.ALL_UNLOCKED)//(FlxG.levels[level].hidden)
				draw(new FlxSprite(0, 0, cover));
			else
				shadow = new FlxSprite(x, y, _shadow);
			
			this.level = level;
		}
		
		override public function update():void {
			//super.update();
			
			if (!Manufactoria.unlocked[level] && !Manufactoria.ALL_UNLOCKED) return;
			
			if (moused && MenuState.mousedLevel != level)
				MenuState.mouseLevel(level);
			else if (!moused && MenuState.mousedLevel == level)
				MenuState.mouseLevel(-1);
			
			if (FlxG.mouse.justPressed() && moused)
				depressed = true;
			else if (depressed && FlxG.mouse.justReleased()) {
				if (moused) {
					FlxG.level = level;
					
					Manufactoria.components = new Array();
					Manufactoria.setGrid();
					FlxG.timeScale = 1;
					
					if (FlxG.levels[FlxG.level].tools >= Manufactoria.BASIC_TOOLS && !IntroState.viewedScenes[IntroState.BRANCH]) {
						IntroState.slides = IntroState.branch;
						FlxG.state = new IntroState();
					} else if (FlxG.levels[FlxG.level].tools >= Manufactoria.WRITING_TOOLS && !IntroState.viewedScenes[IntroState.OUTPUT]) {
						IntroState.slides = IntroState.output;
						FlxG.state = new IntroState();
					} else if (FlxG.levels[FlxG.level].tools >= Manufactoria.COLOR_TOOLS && !IntroState.viewedScenes[IntroState.COLOR]) {
						IntroState.slides = IntroState.color;
						FlxG.state = new IntroState();
					} else if (FlxG.levels[FlxG.level].binary && !IntroState.viewedScenes[IntroState.BINARY]) {
						IntroState.slides = IntroState.binary;
						FlxG.state = new IntroState();
					} else 
						FlxG.state = new BuildState();
				} else
					depressed = false;
			}
		}
		
		override public function render():void {
			super.render();
			if (depressed)
				shadow.render();
		}
		
		override public function getDescription(verbose:Boolean):String {
			if (Manufactoria.unlocked[level])
				return verbose ? FlxG.levels[level].fluff : "Test robotic " + FlxG.levels[level].name.toLowerCase(); 
			else
				return verbose ? "These robots are not yet ready for testing." : "Locked!"
		}
		
		public static const LEVEL_COLORS:Array = new Array(0xffd01616, 0xffdfdfdf, 0xff16d016); //0xff30c040
	}

}