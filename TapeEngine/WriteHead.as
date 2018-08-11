package TapeEngine
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import flash.geom.Point;
	import TapeEngine.Queue;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class WriteHead extends FlxSprite {
		[Embed(source = "/images/Queue/writehead.png")] private static const png:Class;
		
		protected var index:int;
		protected var destination:Point;
		protected var magic:Point;
		protected var ready:Boolean;
		protected var speed:Number;
		protected var lineswapping:Boolean;
		
		public static const WRITE_TIME:Number = .25;
		public static const WRITE_FRAMES:Array = new Array(1, 2, 1, 0);
		
		public function WriteHead(X:int = 0, Y:int = 0) {
			super( -1, -1);
			loadGraphic(png, true, false, 85, 13);
			addAnimation("stamp", WRITE_FRAMES, 1, false);
			//_curAnim.delay = WRITE_TIME / (WRITE_FRAMES.length );
			
			index = -1;
			magic = new Point(X, Y);
			ready = true;
			destination = new Point();
		}
		
		public function move(index:int, teleport:Boolean = false):void {
			if (index >= Queue.LINES * Queue.SYMBOLS_PER_LINE) index = Queue.LINES * Queue.SYMBOLS_PER_LINE - 1;
			//index += 1;
			if (teleport) {
				x = (index % Queue.SYMBOLS_PER_LINE) * (75 / Queue.SYMBOLS_PER_LINE) + 2 + magic.x;
				y = (Math.floor(index / Queue.SYMBOLS_PER_LINE)) * (200 / Queue.LINES) + 10 + magic.y;
				speed = 0;
				destination.x = x;
				destination.y = y;
				_curAnim = null;
			} else {
				destination.x = (index % Queue.SYMBOLS_PER_LINE) * (75 / Queue.SYMBOLS_PER_LINE) + 2 + magic.x,
				destination.y = (Math.floor(index / Queue.SYMBOLS_PER_LINE)) * (200 / Queue.LINES) + 10 + magic.y;
				lineswapping = destination.y != y
				updateSpeed(Boolean(_curAnim));
				ready = false;
			}
			this.index = index;
		}
		
		public function write():void {
			play("stamp");
			_curAnim.delay = WRITE_TIME / (WRITE_FRAMES.length );
			ready = false;
		}
		
		override public function update():void {
			super.update();
			
			if (_curAnim && finished) {
				move(++index);
				_curAnim = null;
			}
			
			if (speed) {
				var movement:Number = speed * FlxG.elapsed;if (x != destination.x) {
				if (y < destination.y) {
					if (y + movement >= destination.y)
						y = destination.y
					else
						y += movement;
				} 	if (Math.abs(destination.x - x) < movement) {
						x = destination.x;
					} else if (x < destination.x)
						x += movement;
					else
						x -= movement;
				} else if (y > destination.y) {
					if (y - movement <= destination.y)
						y = destination.y
					else
						y -= movement;
				} else {
					speed = 0;
					ready = true;
				}
			}
		}
		
		public function updateSpeed(fromStamp:Boolean):void {
			var time:Number = Queue.transit_time;//competition()
			if (fromStamp) time -= WRITE_TIME / Queue.speed;
			var dist:Number;
			if (!lineswapping)
				dist = 75 / Queue.SYMBOLS_PER_LINE;
			else
				dist = (75 * (Queue.SYMBOLS_PER_LINE - 1) / Queue.SYMBOLS_PER_LINE + (200 / Queue.LINES));
			speed = dist / time;
		}
		
		public function atDestination():Boolean {
			return ready;
		}
		
		protected function competition():Number {
			return Manufactoria.GRID_SIZE / (Robot.SPEED );
		}
	}

}