package TapeEngine 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class BinaryHelper extends FlxGroup
	{
		[Embed(source = "/images/Queue/binaryBox.png")] private static const bg:Class;
		
		public var lowerValue:int;
		public var higherValue:int
		private var text:FlxText;
		private var box:FlxSprite;
		public function BinaryHelper(X:int, Y:int, initialString:String) {
			super();
			
			add(box = new FlxSprite(X + 5, Y + 198, bg));
			
			add(text = new FlxText(X + 5, Y + 198, 70, findValue(initialString)));
			//text.alignment = "center";
			
			active = false;
		}
		
		private function findValue(queueString:String):String {
			var binary:Array = toBinary(queueString);
			lowerValue = binary[0];
			higherValue = binary[1];
			
			if (higherValue == -1)
				return "(?)";
			
			var result:String = String(lowerValue);
			if (higherValue)
				result = String(higherValue) + result;
			if (result.length > MAX_LENGTH) {
				//var delta:int = result.length - (MAX_LENGTH - 2); //periods are very small; three count as two characters, I'd say
				//result = result.slice(0, result.length/2 - delta/2) + '...' + result.slice(result.length/2 - (-delta)/2);
			}
			return result;
		}
		
		public static function toBinary(queueString:String):Array {
			var lowerValue:int = 0;
			var higherValue:int = 0;
			
			for (var i:int = 1; i <= queueString.length && i < 32; i++) {
				var digit:String = queueString.charAt(queueString.length - i);
				if (digit == 'b') //1
					lowerValue += (1 << (i - 1));
				else if (digit != 'r') //non-binary string!
					return [-1,-1];
			}
			for (i = 32; i <= queueString.length; i++) { //ASSUMPTION
				digit = queueString.charAt(queueString.length - i);
				if (digit == 'b') //1
					higherValue += (1 << (i - 32));
				else if (digit != 'r') //non-binary string!
					return [-1,-1];
			}
			
			return [lowerValue, higherValue];
		}
		
		public static function fromBinary(binaryPair:Array):String {
			var binaryString:String = '';
			for (var i:int = 31; i; i--)
				binaryString += (binaryPair[1] & (1 << (i - 1))) ? 'b' : 'r';
			for (i = 31; i; i--)
				binaryString += (binaryPair[0] & (1 << (i - 1))) ? 'b' : 'r';
			//FlxG.log(binaryPair[0] + " -> " + binaryString);
			return trimBinary(binaryString);
		}
		
		public static function trimBinary(binaryString:String):String {
			while (binaryString.charAt(0) == 'r')
				binaryString = binaryString.substr(1);
			return binaryString;
		}
		
		public function updateValue(queueString:String):void {
			var sString:Array = queueString.split(/[g|y]/);
			
			var t:String = findValue(sString[0]);
			for (var i:int = 1; i < sString.length; i++)
				if (sString[i].length)
					t += ':' + findValue(sString[i]);
			
			if (t.length > MAX_LENGTH) {
				var delta:int = t.length - (MAX_LENGTH - 2); //periods are very small; three count as two characters, I'd say
				t = t.slice(0, t.length/2 - delta/2) + '...' + t.slice(t.length/2 - (-delta)/2);
			}
			
			text.text = t;
		}
		
		private static var MAX_LENGTH:int = 11;
	}

}