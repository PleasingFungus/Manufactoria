package Malevolence 
{
	import TapeEngine.Queue;
	import TapeEngine.StackSymbol;
	import Components.Puller;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Malevoqueue extends Queue {
		
		public var tape:String;
		
		public function Malevoqueue()  {
			super('');
			tape = '';
		}
		
		override public function loadString(str:String):void {
			tape = str;
		}
		
		override public function push(color:int, fast:Boolean = false):void {
			var hue:String = StackSymbol.LETTERS_TO_SYMBOLS[color];
			tape += hue
		}
		
		override public function pull(pullerType:Boolean, fast:Boolean = false):int {
			if (tape.length == 0)
				return StackSymbol.GREY;
			
			var foremost:String = tape.charAt(0);
			if ((pullerType == Puller.RED_BLUE && (foremost == 'r' || foremost == 'b'))
			  || (pullerType == Puller.GREEN_YELLOW && (foremost == 'g' || foremost == 'y'))) {
				tape = tape.substr(1, tape.length);
				return StackSymbol.LETTERS_TO_SYMBOLS[foremost]
			}
			return StackSymbol.GREY;
		}
		
		override public function toString():String {
			return tape;
		}
		
		override public function get length():int {
			return tape.length;
		}
	}

}