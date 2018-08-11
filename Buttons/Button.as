package Buttons
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Button extends FlxSprite {
		
		public function Button(X:int, Y:int, SimpleGraphic:Class) {
			super(X, Y, SimpleGraphic);
		}
		
		override public function update():void {
			//super.update();
			updateTooltip();
		}
		
		public function get moused():Boolean {
			return overlapsPoint(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		public function get justClicked():Boolean {
			return moused && FlxG.mouse.justPressed();
		}
		
		protected function updateTooltip():void {
			var moused:Boolean = moused;
			if (moused && !Tooltip.tracker.moused)
				Tooltip.tracker.moused = this;
			else if (!moused && Tooltip.tracker.moused == this)
				Tooltip.tracker.moused = null;
		}
		
		public function getDescription(verbose:Boolean):String {
			return verbose ? "Long Placeholder" : "short";
		}
	}

}