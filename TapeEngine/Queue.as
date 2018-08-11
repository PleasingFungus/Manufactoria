package TapeEngine
{
	import com.almirun.common.collections.ConcreteLinkedList;
	import com.almirun.common.collections.LinkedList;
	import flash.geom.Point;
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import Components.Puller;
	import Components.Pusher;
	import States.LevelEditState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Queue extends FlxGroup {
		[Embed(source = "/images/Queue/tape_engine.png")] protected static const bg:Class;
		[Embed(source = "/images/Queue/shadowmask.png")] protected static const fg:Class;
		
		protected var mask:FlxSprite;
		protected var writeHead:WriteHead;
		protected var binaryHelper:BinaryHelper;
		protected var tapes:Array;
		protected var buffer:Array;
		protected var phantoms:FlxGroup;
		public var offset:Point;
		public var symbols:LinkedList;
		protected var _length:int = 0;
		
		public static var speed:int;
		
		public function Queue(input:String, X:int = 0, Y:int = 0, speed:int = 1 )  {
			super();
			
			add(new FlxSprite(X, Y, bg));
			mask = new FlxSprite(X - 16, Y + 7, fg);
			
			tapes = new Array();
			for (var i:int = 0; i < LINES; i++) {
				var tape:Tape = new Tape(X, Y + 9 + 200 / LINES * i);
				tapes[i] = tape;
				add(tape);
			}
			
			if (FlxG.level >= 4)
				add(writeHead = new WriteHead(X, Y));
			if (FlxG.levels[FlxG.level] && FlxG.levels[FlxG.level].binary)
				if (FlxG.state is LevelEditState) //ugh
					add(binaryHelper = new BinaryHelper(X - 15, Y - 206, input));
				else
					add(binaryHelper = new BinaryHelper(X, Y, input));
			
			buffer = new Array();
			
			offset = new Point(X, Y);
			Queue.speed = speed;
			
			loadString(input);
		}
		
		public function loadString(input:String):void {
			phantoms = new FlxGroup();
			add(phantoms);
			
			symbols = new ConcreteLinkedList();
			if (input.length) {
				symbols.insertAtBeginning(new StackSymbol(StackSymbol.LETTERS_TO_SYMBOLS[input.charAt(0)], phantoms, this));
				for (var i:int = 1; i < input.length; i++)
					symbols.insertAtEnd(new StackSymbol(StackSymbol.LETTERS_TO_SYMBOLS[input.charAt(i)], phantoms));
			}
			
			_length = input.length;
			if (writeHead) writeHead.move(_length, true);
			if (binaryHelper) binaryHelper.updateValue(input);
		}
		
		override public function render():void {
			super.render();
			for (var symbol:StackSymbol = symbols.firstNode as StackSymbol; symbol && symbol._nextNode != symbols.firstNode; symbol = symbol._nextNode)
				symbol.render();
			if (symbol)
				symbol.render();
			mask.render();
			if(writeHead) writeHead.render(); //so it renders on top, see
		}
		
		override public function update():void {
			super.update();
			
			for (var symbol:StackSymbol = symbols.firstNode as StackSymbol; symbol && symbol._nextNode != symbols.firstNode; symbol = symbol._nextNode)
				symbol.update();
			if (symbol)
				symbol.update();
			
			if (buffer.length && (!writeHead || writeHead.atDestination())) {
				if (buffer[0] == 0) {
					pull(true);
					pull(false);
				} else {
					push(buffer[0]);
				}
				buffer = buffer.slice(1);
			}
		}
		
		public function push(color:int, fast:Boolean = false):void {
			if (_length < LINES * SYMBOLS_PER_LINE) {
				symbols.insertAtEnd(new StackSymbol(color, phantoms, symbols.firstNode ? null : this));
				_length++;
			} else
				(symbols.lastNode as StackSymbol).overwrite(color);
			//writeHead.move(_length, false);
			if (writeHead)
				(fast || FlxG.timeScale > 20) ? writeHead.move(_length, true) : writeHead.write();
			if (binaryHelper)
				binaryHelper.updateValue(toString());
			//FlxG.log("Post-push: "+symbols+'!'); //DEBUG
		}
		
		public function pull(pullerType:Boolean, fast:Boolean = false):int {
			//FlxG.log("Pulling! Currently: "+toString() + "!");
			if (_length == 0)
				return StackSymbol.GREY;
			
			if (fast)
				return fastPull();
			
			var foremost:int = (symbols.firstNode as StackSymbol).type;
			if ((pullerType == Puller.RED_BLUE && (foremost == StackSymbol.GREEN || foremost == StackSymbol.YELLOW))
				|| (pullerType == Puller.GREEN_YELLOW && (foremost == StackSymbol.BLUE || foremost == StackSymbol.RED)))
				return StackSymbol.GREY;
			
			(symbols.firstNode as StackSymbol).pop();
			
			_length -= 1;
			
			//FlxG.log("After pull: " + toString() + "!");
			
			//fancy graphical nonsense
				//notably, moving the write-head
			if(writeHead) writeHead.move(_length, FlxG.timeScale > 20);
				//also tape-scrolling and such
			for (var i:int = 0; FlxG.timeScale <= 20 && i < LINES; i++)
				tapes[i].scroll();
			if (binaryHelper)
				binaryHelper.updateValue(toString());
			
			return foremost;
		}
		
		private function fastPull():int {
			//FlxG.log("Fast!");
			(symbols.firstNode as StackSymbol).pop(true);
			
			_length -= 1;
			
			if (!FlxG.timeScale && _length) {
				for (var symbol:StackSymbol = symbols.firstNode as StackSymbol; symbol && symbol._nextNode != symbols.firstNode; symbol = symbol._nextNode)
					symbol.update();
				if (symbol)
					symbol.update();
			}
			
			if (writeHead) writeHead.move(_length, true);
			if (binaryHelper)
				binaryHelper.updateValue(toString());
			
			return StackSymbol.GREY;
		}
		
		public function bufferColor(color:int):void {
			if (buffer[buffer.length - 1] == 0)
				buffer.pop();
			else
				buffer.push(color);
		}
		
		public function debufferColor():void {
			if (buffer.length && buffer[buffer.length - 1])
				buffer.pop();
			else
				buffer.push(0);
		}
		
		public function flushBuffer():void {
			if (buffer.length) {
				for (var i:int = 0; i < buffer.length; i++)
					if (buffer[0])
						push(buffer[0])
					else {
						pull(true)
						pull(false)
					}
				writeHead.move(_length, true);
				buffer = new Array();
			}
		}
		
		override public function toString():String {
			return symbols.toString();
		}
		
		public function get length():int {
			return _length;
		}
		
		public static function get transit_time():Number {
			return Manufactoria.GRID_SIZE / (Robot.SPEED) / speed;
		}
		
		public static const LINES:int = 10;
		public static const SYMBOLS_PER_LINE:int = 5;
	}

}