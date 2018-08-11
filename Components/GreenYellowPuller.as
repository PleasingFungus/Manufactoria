package Components 
{
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class GreenYellowPuller extends Puller {
		[Embed(source = "/images/Components/pull_gy_l.png")] public static const png:Class;
		[Embed(source = "/images/Components/pull_gy_r.png")] public static const png_flip:Class;
		
		public static var flipped:Boolean = false;
		
		public function GreenYellowPuller(X:int, Y:int, gridIndex:int, facing:int = DOWN)  {
			super(X, Y, gridIndex, facing, png, GREEN_YELLOW, 'q');
		}
		
		public static function flip():void {
			if (flipped) {
				FlxG.mouse.cursor.loadRotatedGraphic(GreenYellowPuller.png, 4);
			} else {
				FlxG.mouse.cursor.loadRotatedGraphic(GreenYellowPuller.png_flip, 4);
			}
			flipped = !flipped;
		}
	}

}