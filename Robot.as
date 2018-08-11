package  
{
	import org.flixel.*;
	import States.RunState;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Robot extends FlxSprite {
		[Embed(source = "/images/Robots/minirobo.png")] public static const robo:Class;
		[Embed(source = "/images/Robots/toaster.png")] public static const toastbot:Class;
		[Embed(source = "/images/Robots/coffee.png")] public static const coffeebot:Class;
		[Embed(source = "/images/Robots/lava.png")] public static const lavabot:Class;
		[Embed(source = "/images/Robots/fishbot.png")] public static const fishbot:Class;
		[Embed(source = "/images/Robots/flybot.png")] public static const flybot:Class;
		[Embed(source = "/images/Robots/catbot.png")] public static const catbot:Class;
		[Embed(source = "/images/Robots/bearbot.png")] public static const bearbot:Class;
		[Embed(source = "/images/Robots/rcbot.png")] public static const rcbot:Class;
		[Embed(source = "/images/Robots/realcarbot.png")] public static const carbot:Class;
		[Embed(source = "/images/Robots/stiltsbot.png")] public static const stiltsbot:Class;
		[Embed(source = "/images/Robots/dogbot.png")] public static const dogbot:Class;
		[Embed(source = "/images/Robots/and.png")] public static const android:Class;
		[Embed(source = "/images/Robots/police.png")] public static const police:Class;
		[Embed(source = "/images/Robots/teacher.png")] public static const teacher:Class;
		[Embed(source = "/images/Robots/android.png")] public static const politico:Class;
		[Embed(source = "/images/Robots/academician.png")] public static const academician:Class;
		[Embed(source = "/images/Robots/childbot.png")] public static const child:Class;
		[Embed(source = "/images/Robots/soldier.png")] public static const soldier:Class;
		[Embed(source = "/images/Robots/officer.png")] public static const officer:Class;
		[Embed(source = "/images/Robots/general.png")] public static const general:Class;
		[Embed(source = "/images/Robots/tankbot.png")] public static const tankbot:Class;
		[Embed(source = "/images/Robots/spybot.png")] public static const spybot:Class;
		[Embed(source = "/images/Robots/judge.png")] public static const judge:Class;
		[Embed(source = "/images/Robots/engineer.png")] public static const engineer:Class;
		[Embed(source = "/images/Robots/rocket.png")] public static const rocket:Class;
		[Embed(source = "/images/Robots/plane.png")] public static const plane:Class;
		[Embed(source = "/images/Robots/rplane.png")] public static const rplane:Class;
		[Embed(source = "/images/Robots/mech.png")] public static const mech:Class;
		[Embed(source = "/images/Robots/seraphim.png")] public static const seraph:Class;
		[Embed(source = "/images/Robots/ophanim.png")] public static const ophan:Class;
		[Embed(source = "/images/Robots/metatron.png")] public static const metatron:Class;
		public static const ROBOTS:Array = new Array(	toastbot, coffeebot, lavabot, fishbot, flybot,
														catbot, bearbot, rcbot, carbot, stiltsbot,
														dogbot, soldier, officer, general, tankbot,
														spybot, android, child, police, judge,
														teacher, politico, academician, engineer, rocket,
														plane, rplane, mech, seraph, ophan,
														metatron);
		
		protected var distance:Number = 0;
		public var valid:Function;
		private var onMove:Function;
		public var accepted:Boolean;
		protected var flashTimer:Number = FLASH_TIME;
		protected var spinTimer:Number = 0;
		
		public function Robot(valid:Function, onMove:Function = null) {
			super(	191,
					Manufactoria.GRID_SIZE * (Manufactoria.inv_offset)  - 1,
					FlxG.level < Manufactoria.CUSTOM_OFFSET ? ROBOTS[FlxG.level] : ROBOTS[0]);
			offset.x = offset.y = -1;
			scale.x = scale.y = 0;
			facing = DOWN;
			
			this.valid = valid;
			this.onMove = onMove;
		}
		
		override public function update():void {
			if (spinTimer < SPIN_TIME) {
				spinTimer += FlxG.elapsed ;
				if (spinTimer >= SPIN_TIME) {
					spinTimer = SPIN_TIME;
					angle = 0;
					scale.x = scale.y = 1;
				} else {
					recede(spinTimer / SPIN_TIME);
					angle = 720 * spinTimer / SPIN_TIME;
				}
			} else if (dead) {
				if (flashTimer) {
					flashTimer -= FlxG.elapsed  * (accepted ? 2 : 1);
					if (flashTimer <= 0) {
						flashTimer = 0;
						exists = false;
					//} else if (accepted) {
						//recede(flashTimer / FLASH_TIME);
					} else {
						alpha = flashTimer / FLASH_TIME;
					}
				}
			} else {
				if (distance <= 0) {
					askForDirections()
					if (onMove != null)
						onMove();
				}
				
				var movement:Number = FlxG.elapsed * SPEED ;
				if (movement > distance) movement = distance;
				distance -= movement;
				
				switch (facing) {
					case LEFT: 	x -= movement; break;
					case RIGHT: x += movement; break;
					case UP: 	y -= movement; break;
					case DOWN:  y += movement;
				}
			}
			
			super.update();
		}
		
		protected function recede(progressFraction:Number):void {
			scale.x = scale.y = progressFraction;
			var channel:int = progressFraction * 256 - 1;
			color = 0xff000000 | (channel << 16) | (channel << 8) | channel;
		}
		
		protected function askForDirections():void {
			var modifiedOffset:int = Manufactoria.inv_offset * Manufactoria.GRID_SIZE;
			if (x + 2 < 80 + modifiedOffset || x + 2 > 320 - modifiedOffset ||
				y + 2 < modifiedOffset || y + 2 > 240 - modifiedOffset)
				dieHard();
				
			else {
				
				var gridIndex:int = Manufactoria.gridToArray(Manufactoria.realToGrid(x + 2, y + 2));
				//FlxG.log(gridIndex);
				if (Manufactoria.grid[gridIndex]) {
					Manufactoria.grid[gridIndex].direct(this);
					distance = Manufactoria.GRID_SIZE;
				} else
					die();
			}
		}
		
		public function die(accepted:Boolean = false):void {
			this.accepted = accepted;
			color = valid() ? 0xff60ff60 : 0xffff6060;
			dead = true;
		}
		
		protected function dieHard():void {
			accepted = false;
			dead = true;
			flashTimer = 0;
			valid();
		}
		
		public function quiteDone():Boolean {
			return dead;
		}
		
		public function thoroughlyDone():Boolean {
			return !flashTimer;
		}
		
		public static const SPEED:int = 30;
		public static const FLASH_TIME:Number = 2;
		public static const SPIN_TIME:Number = 1;
	}

}