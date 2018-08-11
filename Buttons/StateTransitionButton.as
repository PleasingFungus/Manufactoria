package Buttons
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import States.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class StateTransitionButton extends Button
	{
		[Embed(source = "/images/UI/intro_button.png")] private static const intro:Class;
		[Embed(source = "/images/UI/camera_button.png")] private static const camera:Class;
		[Embed(source = "/images/UI/back.png")] private static const menu:Class;
		[Embed(source = "/images/UI/run.png")] private static const run:Class;
		[Embed(source = "/images/UI/floppy.png")] private static const saveload:Class;
		[Embed(source = "/images/UI/credits_button.png")] private static const credits:Class;
		[Embed(source = "/images/UI/huh.png")] private static const help:Class;
		[Embed(source = "/images/UI/cog.png")] private static const cog:Class;
		[Embed(source = "/images/UI/edit.png")] public static const edit:Class;
		[Embed(source = "/images/UI/clear.png")] public static const clear:Class;
		[Embed(source = "/images/UI/reset_up.png")] public static const input:Class;
		[Embed(source = "/images/UI/reset_button.png")] public static const reset:Class;
		private static const pngs:Array = new Array();
		pngs[IntroState] = intro;
		pngs[TabState] = camera;
		pngs[MenuState] = menu;
		pngs[BuildState] = menu;
		pngs[RunState] = run;
		pngs[SaveLoadState] = saveload;
		pngs[CreditsState] = credits;
		pngs[HelpState] = help;
		pngs[LevelSelectState] = cog;
		pngs[LevelEditState] = edit;
		pngs[ConfirmClear] = clear;
		pngs[InputState] = input;
		pngs[OverwriteState] = saveload;
		pngs[ConfirmReset] = reset;
		
		public var state:Class;
		private var shortDescription:String;
		private var longDescription:String;
		
		public function StateTransitionButton(X:int, Y:int, transitionState:Class) {
			super(X, Y, pngs[transitionState]);
			state = transitionState;
		}
		
		public function modify(png:Class = null, shortDesc:String = null, longDesc:String = null):StateTransitionButton {
			if (png) loadGraphic(png);
			if (shortDesc) shortDescription = shortDesc;
			if (longDesc) longDescription = longDesc;
			return this;
		}
		
		override public function update():void {
			super.update();
			if (moused && FlxG.mouse.justPressed()) { //even if a component is held!
				if (Manufactoria.linkCode)	//preserve progress while working with level codes!
					Manufactoria.linkCode = SaveLoadState.levelString;
				FlxG.state = new state();
			}
		}
		
		override public function getDescription(verbose:Boolean):String {
			if (verbose) {
				if (longDescription) return longDescription;
			} else
				if (shortDescription) return shortDescription;
			
			switch (state) {
				case IntroState: return verbose ? "Re-watch the intro! (Gain valuable background!)" : "Intro!";
				case TabState: return verbose ? "Re-watch educational presentations! Don't go blind!" : "Education!";
				case MenuState: return verbose ? "Return to Main Menu! (Choose another level?)" : "Main Menu!";
				case BuildState: return verbose ? "Go back to building your machine!" : "Back!"
				case RunState: return verbose ? "Run your machine! See if it works!" : "Run!";
				case SaveLoadState: return verbose ? "Send levels to your friends! Load levels they sent you!" : "Save / Load!";
				case CreditsState: return verbose ? "WHO IS RESPONSIBLE FOR THIS? Find out!" : "Credits!";
				case HelpState: return verbose ? "Confused about controls? Want advanced techniques? Well..." : "Help!";
				case LevelSelectState: return verbose ? "Choose another level! Edit this one! Or go back to the main game!" : "Back!";
				case LevelEditState: return verbose ? "Return to editing your level! Tweak things, or save it if you're content!" : "Back!";
				case ConfirmClear: return verbose ? "Erase the current machine! Destroy all parts! Permament! Be careful!" : "Clear!";
				case InputState: return verbose ? "Reset the machine! Clear the tape and summon a new robot!" : "Reset!";
				case OverwriteState: return verbose ? "Overwrite your solution with the one you just ran!" : "Overwrite!";
				case ConfirmReset: return verbose ? "Reset your game! Erase all game progress! Permanent!" : "Reset!";
				default: return '<no description>!';
			}
		}
	}

}