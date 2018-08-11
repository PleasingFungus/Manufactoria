package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import States.BuildState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Destination extends TileComponent{
		[Embed(source = "/images/Components/shaft.png")] private static const png:Class;
		protected static const FRAME_ARRAY:Array = new Array(1, 2, 3, 4, 5, 4, 3, 2, 1, 0);
		
		public function Destination() {
			super(12,
				  Manufactoria.GRID_DIM + Manufactoria.inv_offset - 1,//7,
				  grid,
				  LEFT,
				  png, "Destination");
			loadGraphic(png, true, false, 15, 15);
			
			var animationSpeed:Number = FRAME_ARRAY.length / Robot.FLASH_TIME;
			addAnimation("Convey!", FRAME_ARRAY, animationSpeed, false);
		}
		
		/*override public function update():void {
			super.update();
			if (FlxG.state is BuildState && overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) { //also: if FlxG.level == 1?
				//if (something): spawn a little robo above, alpha, set his direction manually
				//when asked for directions: animate, kill the robot (by fading, as ever!)
				//once finished animating: loop!
			}
			//if not moused: kill robot (if robot), reset position
		} */
		
		override public function die():Boolean { return false }
		
		override public function direct(robo:Robot):void {
			robo.die(true);
			play("Convey!", true);
			_curAnim.delay = Robot.FLASH_TIME / (FRAME_ARRAY.length );
		}
		
		override public function unclip():TileComponent { return null; }
		
		public static function get grid():int {
			return Manufactoria.GRID_DIM * (Manufactoria.GRID_DIM - .5);
		}
	}

}