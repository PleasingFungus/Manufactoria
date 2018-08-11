package Components
{
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class BlueRedPuller extends Puller {
		[Embed(source = "/images/Components/pull_rb_l.png")] public static const png:Class;
		[Embed(source = "/images/Components/pull_rb_r.png")] public static const png_flip:Class;
		[Embed(source = "/images/Components/pull_01_l.png")] public static const png_01:Class;
		[Embed(source = "/images/Components/pull_01_r.png")] public static const png_01_flip:Class;
		
		public static var flipped:Boolean = false;
		
		public function BlueRedPuller(X:int, Y:int, gridIndex:int, facing:int = DOWN)  {
			super(X, Y, gridIndex, facing, png, RED_BLUE, 'p');
			//super(X, Y, gridIndex, facing, (FlxG.level < 8 || FlxG.level > 10) ? png : png_01 , RED_BLUE, 'p');
		}
		
		public static function flip():void {
			if (flipped) {
				FlxG.mouse.cursor.loadRotatedGraphic(BlueRedPuller.png, 4);
			} else {
				FlxG.mouse.cursor.loadRotatedGraphic(BlueRedPuller.png_flip, 4);
			}
			flipped = !flipped;
		}
		
	}

}