package Buttons 
{
	import Buttons.ColorButton;
	import TapeEngine.Queue;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class FastColorButton extends ColorButton implements HotkeyButton
	{
		public function FastColorButton(X:int, Y:int, color:int, queue:Queue) {
			super(X, Y, color, queue);
			//FlxG.state.add(new Hotkey(X + 16, Y + 8, color ? color : 5, this));
		}
		
		public function get selected():Boolean {
			return false;
		}
		
		public function select():void {
			onClick();
		}
		
		public function deselect():void { }
		
		override protected function onClick():void 
		{
			if (type)
				queue.push(type, true);
			else {
				queue.pull(true, true);
			}
		}
	}

}