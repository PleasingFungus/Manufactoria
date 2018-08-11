package States 
{
	import Buttons.CustomButton;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class ConfirmReset extends FlxState
	{
		[Embed(source = "/images/UI/rreset_button.png")] private static const reset:Class;
		
		override public function create():void
		{
			add(new FlxText(0, 100, 320, "This will reset the entire game. Are you sure?").setFormat(null, 8, 0xffffff, "center"));
			add(new FlxText(93, 165, 40, "RESET"));
			add(new CustomButton(100, 180, reset, resetGame, "RESET GAME!", "Resets the game. Will ERASE all stats and progress!"));
			add(new FlxText(190, 165, 40, "CANCEL"));
			add(new StateTransitionButton(200, 180, MenuState));
			
			add(new AudioButton());
			add(new Tooltip());
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
		
		protected function resetGame():void {
			Manufactoria.reset();
			FlxG.state = new IntroState();
		}
	}

}