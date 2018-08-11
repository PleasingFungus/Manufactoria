package Malevolence 
{
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	import org.flixel.FlxG;
	public class Malevobot extends Robot {
		
		public var testTicks:int;
		public var testLimit:int;
		public var totalTicks:int;
		public var totalLimit:int;
		
		public var slowestTest:String;
		public var slowest:int;
		
		public static const TIMEOUT_TICKS:int = 1000000;
		public static const TEST_TICKS:int = 100000;
		
		public function Malevobot() {
			super(null, null);
			totalTicks = 0;
			totalLimit = TIMEOUT_TICKS;
			slowest = 0;
			resetBot();
		}
		
		public function resetBot():void {
			testTicks = 0;
			testLimit = totalLimit - totalTicks > TEST_TICKS ? TEST_TICKS : totalLimit - totalTicks;
			dead = accepted = false;
			
			x = int(Manufactoria.GRID_DIM / 2); //centerlike
			y = 0;	//toplike
			facing = DOWN;
		}
		
		public function runBot():int {
			while (testTicks <= testLimit) {
				//FlxG.log("Loc: " + x + "," + y + ", occ: " + Manufactoria.grid[y * Manufactoria.GRID_DIM + x]);
				testTicks++;
				totalTicks++;
				
				switch (facing) {
					case LEFT: x -= 1; break;
					case UP: y -= 1; break;
					case RIGHT: x += 1; break;
					case DOWN: y += 1;
				}
				if (x < 0 || x >= Manufactoria.GRID_DIM || y < 0 || y >= Manufactoria.GRID_DIM)
					return REJECT;
				
				var director:TileComponent = Manufactoria.grid[y * Manufactoria.GRID_DIM + x];
				if (!director)
					return REJECT;
				
				director.direct(this);
				if (accepted)
					return ACCEPT;
				else if (dead)
					return REJECT;
			}
			return TIMEOUT; //out of time
		}
		
		override public function die(accepted:Boolean = false):void {
			dead = true;
			this.accepted = accepted;
		}
		
		public static const REJECT:int = 0;
		public static const ACCEPT:int = 1;
		public static const TIMEOUT:int = 2;
	}

}