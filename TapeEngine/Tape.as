package TapeEngine
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Tape extends FlxSprite{
		[Embed(source = "/images/Queue/tape-s.png")] private static const png:Class;
		
		protected var timer:Number;
		
		public function Tape(X:int, Y:int) {
			super(X, Y);
			loadGraphic(png, true, false, 76, 15);
			addAnimation("scroll", new Array(2, 1, 0), SPEED);
		}
		
		public function scroll():void {
			timer = Queue.transit_time;
			play("scroll");
			_curAnim.delay = 1 / (SPEED );
		}
		
		override public function update():void {
			super.update();
			if (timer) {
				timer -= FlxG.elapsed ;
				if (timer <= 0) {
					timer = 0;
					_curAnim = null;
				}
			}
		}
		
		public function updateSpeed():void {
			if (_curAnim)
				_curAnim.delay = 1 / (SPEED );
		}
		
		public static const SPEED:int = 10;
	}

}