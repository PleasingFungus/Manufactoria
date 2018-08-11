package  
{
	import Buttons.CustomButton;
	import flash.display.BitmapData;
	import org.flixel.data.FlxPause;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import States.BuildState;
	import States.RunState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class ManuPause extends FlxPause
	{
		public static var pauseButton:CustomButton = null;
		
		public static function pause():void {
			//None of this works.
			
			FlxG.mouse.hide();
			if (FlxG.state is RunState) {
				//render something over the pause button - unsafeBind?
				pauseButton.loadGraphic(RunState.play_png).render();
			}
			
			FlxState.screen.unsafeBind(FlxG.buffer);
			
			FlxG.mouse.show();
			if (FlxG.state is RunState) {
				pauseButton.loadGraphic(RunState.pause_png);
			}
			
			//Except for this.
			
			FlxG.pause = true;
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() && pauseButton)// && pauseButton.moused)
				FlxG.pause = false;
		}
		
		override public function render():void {
			if (FlxG.state is RunState)
				return;
			
			super.render();
		}
		
	}

}