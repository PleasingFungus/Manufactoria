package Buttons 
{
	import Buttons.Button;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class AudioButton extends Button
	{
		[Embed(source = "/images/UI/audion.png")] private static const on:Class;
		[Embed(source = "/images/UI/audioff.png")] private static const off:Class;
		
		public static var instance:AudioButton;
		private var muted:Boolean;
		
		public function AudioButton() {
			super(307, 3, FlxG.mute ? off : on);
			instance = this;
			muted = FlxG.mute;
		}
		
		override public function update():void {
			super.update();
			if (FlxG.mouse.justPressed() && moused) {
				FlxG.mute = muted = !FlxG.mute;
				loadGraphic(FlxG.mute ? off : on);
				Tooltip.tracker.resetTime();
			} else if (FlxG.mute != muted) {
				loadGraphic(FlxG.mute ? off : on);
				muted = FlxG.mute;
			}
		}
		
		override public function getDescription(verbose:Boolean):String {
			return verbose ? "Toggle the game's sound on and off! (Hotkey: '0'!)" : FlxG.mute ? "Unmute!" : "Mute!";
		}
		
		public function refresh():void {
			loadGraphic(FlxG.mute ? off : on);
		}
		
	}

}