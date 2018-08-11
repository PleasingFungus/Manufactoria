package
{
	import org.flixel.*;
	import TapeEngine.BinaryHelper;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class PseudoQueue extends FlxGroup
	{
		[Embed(source = "/images/Queue/tape_engine.png")] protected static const bg:Class;
		//[Embed(source = "/images/Queue/shadowmask.png")] protected static const fg:Class;
		
		import TapeEngine.*;
		
		public function PseudoQueue(X:int, Y:int, str:String) {
			super();
			
			add(new FlxSprite(0, 0, bg));
			var i:int;
			for (i = 0; i < Queue.LINES; i++)
				add(new Tape(0, 9 + 200 / Queue.LINES * i));
			if (FlxG.levels[FlxG.level].binary) {
				var binaryHelper:BinaryHelper = new BinaryHelper(x, y, str);
				binaryHelper.updateValue(str);
				add(binaryHelper);
				
			}
			
			var tapeContents:Array = stringToArray(str);
			for (i = 0; i < tapeContents.length; i++) {
				add(new PseudoStackSymbol(i, tapeContents[i]));
			}
			//add(new FlxSprite(0, 0, fg));
			
			x = X;
			y = Y;
		}
		
		public static function stringToArray(input:String):Array {
			var out:Array = new Array(input.length);
			for (var i:int = 0; i < input.length; i++)
				out[i] = StackSymbol.LETTERS_TO_SYMBOLS[input.charAt(i)];
			return out;
		}
		
	}

}