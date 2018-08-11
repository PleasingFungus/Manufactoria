package Buttons 
{
	import Buttons.Button;
	import Buttons.BuildButton;
	import Buttons.HotkeyButton;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import States.BuildState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class GarbageButton extends Button implements HotkeyButton {
		[Embed(source = "/images/UI/garbage.png")] private static const png:Class;
		
		private var garbage:FlxSprite;
		public static var instance:GarbageButton;
		
		public function GarbageButton(X:int, Y:int) {
			super(X, Y, BuildButton.inactiveBox);
			garbage = new FlxSprite(X + 2, Y + 2, png);
			FlxG.state.add(new Hotkey(X + 3, Y + 21, 3, this));
			instance = this;
		}
		
		override public function render():void {
			super.render();
			if (garbage.visible) garbage.render();
		}
		
		public function get selected():Boolean { return false }
		
		public function select():void {
			//loadGraphic(BuildButton.activeBox);
			//garbage.visible = false;
			BuildState.toolText.text = "Click or drag to delete components!"
		}
		
		public function deselect():void {
			//loadGraphic(BuildButton.inactiveBox);
			//garbage.visible = true;
		}
		
		override public function getDescription(verbose:Boolean):String {
			return verbose ? "Put away the held component, and switch to Destruction Mode!" : "Delete!";
		}
	}

}