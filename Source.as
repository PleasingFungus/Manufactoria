package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import States.BuildState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Source extends TileComponent {
		[Embed(source = "/images/Components/pipe.png")] private static const png:Class;
		protected static const OPEN_ARRAY:Array = new Array(0, 1, 2, 3, 4, 5, 6, 7);
		protected static const CLOSE_ARRAY:Array = new Array(7, 6, 5, 4, 3, 2, 1, 0);
		
		protected var opened:Boolean;
		
		public function Source(startsOpen:Boolean) {
			super(12,
				  Manufactoria.inv_offset,
				  grid,
				  LEFT,
				  png, "Source", true);
			loadGraphic(png, true, false, 15, 15);
			
			var animationSpeed:Number = OPEN_ARRAY.length  / Robot.SPIN_TIME;
			addAnimation("Open!", OPEN_ARRAY, animationSpeed, false);
			addAnimation("Close!", CLOSE_ARRAY, animationSpeed, false);
			
			opened = startsOpen;
			if (startsOpen)
				play("Open!");
		}
		
		/*override public function update():void {
			super.update();
			if (FlxG.state is BuildState && overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) { //also: if FlxG.level == 1?
				//if not opened: open
				//if just opened: spawn a ghost-robo (low alpha, haha! - but then, want to make sure it doesn't wander into a branch/pusher, ask for a queue, and kill everything)
					//and close again
			}
			//if not moused: kill robot (if robot), reset position
		} */
		
		override public function die():Boolean { return false }
		
		override public function direct(str:Robot):void {
			if (opened) {
				str.facing = DOWN;
				
				play("Close!");
				_curAnim.delay = Robot.SPIN_TIME / (CLOSE_ARRAY.length );
				
				opened = false;
			} else {
				str.die();
			}
		}
		
		public function open():void {
			play("Open!");
			_curAnim.delay = Robot.SPIN_TIME / (OPEN_ARRAY.length );
			opened = true;
		}
		
		override public function unclip():TileComponent { return null; }
		
		public static function get grid():int {
			return Manufactoria.grid_offset;
		}
	}
}