package Buttons 
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class SliderBar extends Button {
		[Embed(source = "/images/UI/slider.png")] private static const slider_png:Class;
		[Embed(source = "/images/UI/sliderbar.png")] private static const bar_png:Class;
		
		private var slider:FlxSprite;
		private var pressed:Boolean;
		private var dragged:Boolean;
		private var mouseOff:int;
		private var timescales:Array;
		
		public function SliderBar(X:int, Y:int, sliderPos:int = 4) {
			super(X, Y, bar_png);
			slider = new FlxSprite(X + sliderPos + 1, Y + 9, slider_png);
			initTimescales();
			FlxG.timeScale = timescales[slider.x - x - 1];
		}
		
		private function initTimescales():void {
			var i:int;
			timescales = new Array(37);
			for (i = 0; i <= 4; i++)
				timescales[i] = i / 4.0
			for (i = 5; i <= 18; i++)
				timescales[i] = (i - 5) * 7 / 13.0 + 1;
			for (i = 19; i <= 36; i++)
				timescales[i] = (i - 19) * 42 / 17.0 + 8;
			/*for (i = 5; i <= 36; i++)
				timescales[i] = (i - 5) * 49 / 31.0 + 1; */
			/*for (i = 5; i <= 11; i++)
				timescales[i] = i - 3;
			for (i = 12; i <= 36; i++)
				timescales[i] = (i - 11) * 52 / 25.0 + 8; */
		}
		
		override public function update():void {
			//super.update();
			if (FlxG.mouse.pressed()) {
				if (FlxG.mouse.justPressed() && overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) {
					pressed = true;
					if (slider.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
						mouseOff = slider.x - FlxG.mouse.x;
					else
						mouseOff = slider.width / 2;
				}
				
				if (pressed) {
					slider.x = FlxG.mouse.x + mouseOff;
					if (slider.x <= x)
						slider.x = x + 1;
					else if (slider.x + slider.width >= x + width - 1)
						slider.x = x + width - slider.width - 1;
					//do time stuff here
					//if (FlxG.timeScale != timescales[slider.x - x - 1])
					//	FlxG.log((slider.x - x - 1) + ": " + timescales[slider.x - x - 1]);
					if (timescales[slider.x - x - 1] != FlxG.timeScale)
						dragged = true;
					FlxG.timeScale = timescales[slider.x - x - 1]
				}
			} else {
				if (FlxG.mouse.justReleased() && pressed) {
					dragged = pressed = false;
				}
				updateTooltip();
			}
			
			if (FlxG.timeScale && (FlxG.keys.A || FlxG.keys.LEFT)) {
				slider.x -= FlxG.elapsed * KEYSCROLLSPEED / FlxG.timeScale;
				if (slider.x < x + 1)
					slider.x = x + 1;
				FlxG.timeScale = timescales[int(slider.x) - x - 1]
			} else if (FlxG.keys.D || FlxG.keys.RIGHT) {
				if (FlxG.timeScale)
					slider.x += FlxG.elapsed * KEYSCROLLSPEED / FlxG.timeScale;
				else
					slider.x += (1 / 60) * KEYSCROLLSPEED;
				if (slider.x + slider.width > x + width - 1)
					slider.x = x + width - slider.width - 1;
				FlxG.timeScale = timescales[int(slider.x) - x - 1]
			}
		}
		
		public function halt():void {
			slider.x = x + 1;
			FlxG.timeScale = 0;
		}
		
		override public function render():void {
			super.render();
			slider.render();
		}
		
		private const KEYSCROLLSPEED:Number = 10;
		
		override public function getDescription(verbose:Boolean):String {
			return verbose ? "Change the speed at which the machine runs! Hotkey: A/D!" : "Speed: "+int(FlxG.timeScale)+"x!";
		}
	}

}