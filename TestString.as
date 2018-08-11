package  
{
	import TapeEngine.StackSymbol;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class TestString
	{
		protected var _input:String;
		protected var _accepts:String;
		public var name:String;
		
		public function TestString(input:String, acceptor:String, name:String = null) {
			_input = input;
			_accepts = acceptor;
			this.name = name;
		}
		
		public function get string():String {
			return _input;
		}
		
		public function get accepts():String {
			return _accepts;
		}
		
		public function toString():String {
			return _input + ":" + _accepts;
		}
		
		public static function fromString(tests:Array):Array {
			for (var i:int = 0; i < tests.length && i < 8; i++) { //this 8 probably shouldn't be hardcoded; won't load more than 8 tests per level
				var center:int = tests[i].indexOf(':');
				if (center < 0) {
					tests[i] = null;
					FlxG.log("Test " + i + " invalid!");
				} else
					tests[i] = new TestString(tests[i].slice(0, center), tests[i].slice(center + 1));
			}
			var cleanTests:Array = new Array();
			for (i = 0; i < tests.length; i++)
				if (tests[i]) cleanTests.push(tests[i])
			return cleanTests;
		}
		
		public static function generateRandom(minLen:int, maxLen:int, proportion:Number):String {
			var random:String = "";
			var len:int = FlxU.random() * (maxLen - minLen) + minLen;
			for (var i:int = 0; i < len; i++)
				random += (FlxU.random() < proportion) ? 'b' : 'r';
			//FlxG.log(random);
			return random;
		}
	}
}