package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import Buttons.Button;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Tooltip extends FlxText {
		
		protected var _moused:Button;
		protected var hoverTime:Number;
		protected var backdrop:FlxSprite;
		
		public static var tracker:Tooltip;
		
		public function Tooltip()  {
			super( -1, -1, 120);
			_moused = null;
			hoverTime = 0;
			backdrop = new FlxSprite( -10, -10);
			tracker = this;
		}
		
		override public function update():void {
			super.update();
			if (moused) {
				if (hoverTime < SHORT_TIME) {
					hoverTime += FlxG.elapsed / FlxG.timeScale// ? FlxG.timeScale : 1);
					if (hoverTime >= SHORT_TIME)
						display();
				} else if (hoverTime < LONG_TIME) {
					hoverTime += FlxG.elapsed / FlxG.timeScale //? FlxG.timeScale : 1);
					if (hoverTime >= LONG_TIME)
						elongate();
				}
			}
		}
		
		override public function render():void {
			if (text) {
				backdrop.render();
				super.render();
			}
		}
		
		public function display():void {
			x = FlxG.mouse.x+5;
			y = FlxG.mouse.y+5;
			text = moused.getDescription(false);
			if (!text) {
				trace("tooltip error: " + String(moused));
				text = '';
			}
			format();
		}
		
		protected function elongate():void {
			text = moused.getDescription(true);
			format();
		}
		
		protected function format():void {
			var max:Number = _tf.getLineMetrics(0).width;
			for (var i:int = 1; i < _tf.numLines; i++)
				if (max < _tf.getLineMetrics(i).width) max = _tf.getLineMetrics(i).width
			
			backdrop.createGraphic(max + 2, height -2, 0xff808080);
			
			if (x + backdrop.width > 320)
				x = 320 - backdrop.width;
			backdrop.x = x;
			if (y + backdrop.height > 240) {
				y = 239 - backdrop.height;
			}
			backdrop.y = y + 1;
		}
		
		public function resetTime():void {
			hoverTime = 0;
		}
		
		public function get moused():Button {
			return _moused;
		}
		
		public function set moused(mousedButton:Button):void {
			_moused = mousedButton;
			if (!_moused) {
				text = '';
			}
			hoverTime = 0;
		}
		
		private static const SHORT_TIME:Number = .75;
		private static const LONG_TIME:Number = 2.5;
	}

}