package TapeEngine
{
	import com.almirun.common.collections.LinkedListNode;
	import flash.geom.Point;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import TapeEngine.Queue;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class StackSymbol extends FlxSprite implements LinkedListNode
	{
		[Embed(source = "/images/Queue/stacksymbol-s.png")] protected static const circle:Class;
		//protected static const IN_ARRAY:Array = new Array(5, 4, 3, 2, 1, 0);
		protected static const IN_ARRAY:Array = new Array(0,1,2,3,4,5);
		
		public var type:int;
		public var distance:Number;
		public var queueOffset:Point;
		private var brains:Queue;
		private var phantoms:FlxGroup;
		private var phantom:Number;
		
		public var _previousNode:StackSymbol;
		public var _nextNode:StackSymbol;
		
		public function StackSymbol(type:int, phantoms:FlxGroup, brains:Queue = null, phantom:StackSymbol = null) {
			super( -99, -99);
			
			loadGraphic(circle, true, false, 9, 9, true);
			
			color = COLORS[type];
			this.type = type;
			
			this.phantoms = phantoms;
			if (brains) {
				queueOffset = brains.offset;
				x = queueOffset.x + OFF_X;
				y = queueOffset.y + OFF_Y;
				distance = 0;
				this.brains = brains;
				//active = false;
			} else if (phantom) {
				x = phantom.x;
				y = phantom.y;
				queueOffset = phantom.queueOffset;
				
				addAnimation("wrapIn", IN_ARRAY, 1, false);
				
				var unplaced:Boolean = true;
				for (var i:int = 0; unplaced; i++)
					if (!phantoms.members[i] || !phantoms.members[i].exists) {
						phantoms.members[i] = this;
						unplaced = false;
					}
				
				this.phantom = calcSpeed();
			}
		}
	
		public function pop(fast:Boolean = false):void {
			if (_nextNode) {
				if (FlxG.timeScale < 20 && !fast)
					_nextNode.distance = GAP_X;
				else
					_nextNode.x = x;
				_nextNode.brains = brains;
				//_nextNode.active = true;
			}
			if (FlxG.timeScale < 20 && !fast)
				spawnPhantom();
			brains.symbols.remove(this);
		}
		
		override public function update():void {
			super.update();
			
			if (brains) {
				if (distance) {
					var movement:Number = calcSpeed() * FlxG.elapsed;
					if (distance < movement)
						movement = distance;
					distance -= movement;
					
					x -= movement;
				} //else
					//active = false;
			} else if (phantom) {
				x -= phantom * FlxG.elapsed;
				if (_curAnim == null && x - queueOffset.x < MIN_X)
					play("wrapIn");
				if (x - queueOffset.x < MIN_X - GAP_X)
					exists = false;
			} else {
				if (!queueOffset)
					queueOffset = _previousNode.queueOffset;
				
				var old_y:Number = y;
				
				x = _previousNode.x + GAP_X;
				y = _previousNode.y;
				if (x - queueOffset.x > MAX_X) {
					x -= 75;
					y += GAP_Y;
				} else if (old_y > -99 && old_y != y) {
					x -= 75;
					y += GAP_Y;
					spawnPhantom();
					x += 75;
					y -= GAP_Y;
				}
			}
		}
		
		protected function spawnPhantom():void {
			new StackSymbol(type, phantoms, null, this);
		}
		
		protected function calcSpeed():int {
			return GAP_X / (Manufactoria.GRID_SIZE / (Robot.SPEED) / Queue.speed);
		}
		
		public function overwrite(newType:int):void {
			type = newType;
			color = COLORS[newType];
		}
		
		
		
		public function get previousNode():LinkedListNode {
			return _previousNode;
		}
		
		public function set previousNode(n:LinkedListNode):void {
			_previousNode = n as StackSymbol;
		}
		
		public function get nextNode():LinkedListNode {
			return _nextNode;
		}
		
		public function set nextNode(n:LinkedListNode):void {
			_nextNode = n as StackSymbol;
		}
		
		override public function toString():String {
			return LETTERS_TO_SYMBOLS[type];
		}
		
		public function equals(o:Object):Boolean {
			return o == this;
		}
		
		
		
		
		public static const GREEN:int = 4;
		public static const YELLOW:int = 3;
		public static const RED:int = 2;
		public static const BLUE:int = 1;
		public static const GREY:int = 0;
		protected static const COLORS:Array = new Array(0xffaaaaaa, 0xff8096ff, 0xffff6060, 0xfffffd80, 0xff60ff60);
		
		public static var LETTERS_TO_SYMBOLS:Array = new Array("-", "b", "r", "y", "g");
		LETTERS_TO_SYMBOLS["b"] = StackSymbol.BLUE;
		LETTERS_TO_SYMBOLS["r"] = StackSymbol.RED;
		LETTERS_TO_SYMBOLS["g"] = StackSymbol.GREEN;
		LETTERS_TO_SYMBOLS["y"] = StackSymbol.YELLOW;
		
		protected static const GAP_X:int = 15;
		protected static const OFF_X:int = 3;
		
		protected static const MAX_X:int = 75; //not accounting for queue-'offset'
		protected static const MIN_X:int = 0;
		
		protected static const GAP_Y:int = 20;
		protected static const OFF_Y:int = 12;
		
	}
}