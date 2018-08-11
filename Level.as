package  
{
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	
	import flash.events.Event;
	import org.flixel.FlxG;
	import TapeEngine.BinaryHelper;
	public class Level
	{
		
		protected var _name:String;
		protected var _desc:String;
		public var fluff:String;
		public var unlock:UnlockRequirement;
		public var dimensions:int;
		public var tools:int;
		
		public var fixedTests:Array;
		public var randomTests:int;
		public var testGenerator:Function;
		public var acceptingTestGenerator:Function;
		public var acceptanceTester:Function;
		public var outputGenerator:Function;
		public var malevoTest:Function;
		
		public var binary:Boolean;
		
		public var IO:Array; //for custom levels
		
		public var stringTestLength:int;
		
		public function Level(name:String, description:String, fluff:String, unlock:UnlockRequirement, dimensions:int, tools:int,
							  malevolenceLength:int, fixedTests:Array, acceptance:Function, outGen:Function = null, malevoTest:Function = null,
							  binary:Boolean = false, IO:Array = null) {
			_name = name;
			_desc = description;
			this.fluff = fluff;
			this.unlock = unlock;
			this.dimensions = dimensions;
			
			this.stringTestLength = malevolenceLength;
			this.fixedTests = fixedTests;
			acceptanceTester = acceptance;
			outputGenerator = outGen;
			
			this.tools = tools;
			this.binary = binary;
			
			this.IO = IO;
			
			this.malevoTest = (malevoTest != null) ? malevoTest : defaultMalevoTest;
		}
		
		public function defaultMalevoTest(testStr:String, actuallyTest:Function, bot:Robot):void {
			actuallyTest(testStr, bot);
		}
		
		public static function binaryMalevoTest(testStr:String, actuallyTest:Function, bot:Robot):void {
			if (testStr != '')
				actuallyTest(testStr, bot);
		}
		
		public static function evenMalevoTest(testStr:String, actuallyTest:Function, bot:Robot):void {
			if (testStr.length % 2 == 0) //odd
				actuallyTest(testStr, bot);
		}
		
		public static function gt0MalevoTest(testStr:String, actuallyTest:Function, bot:Robot):void {
			if (testStr.indexOf('b') >= 0) //greater than 0
				actuallyTest(testStr, bot);
		}
		
		public static function multiMalevoTest(testStr:String, actuallyTest:Function, bot:Robot):void {
			//actuallyTest('g' + testStr, bot);
			for (var i:int = 1; i < testStr.length; i++) 
				actuallyTest(testStr.slice(0,i) + 'g' + testStr.slice(i), bot);
			//actuallyTest(testStr + 'g', bot);
		}
		
		public function set name(newName:String):void {
			_name = newName.replace(';', '');
		}
		
		public function get name():String {
			return _name;
		}
		
		public function set description(newDescription:String):void {
			_desc = newDescription.replace(';', '');
		}
		
		public function get description():String {
			return _desc;
		}
		
		public function generateTest(testNumber:int):String {
			var randomTest:String;
			
			//FlxG.log("Generating test number: " + testNumber + '.');
			
			if (outputGenerator == null) {
				if (testNumber == randomTests - 1) { //final test: accepts!
					//FlxG.log("Gen accepting!");
					do {
						randomTest = acceptingTestGenerator();
					} while (acceptanceTester(randomTest, 'x'))
				} else if (testNumber == 0) { //first test: rejects! (except if final)
					//FlxG.log("Gen rejecting!");
					do {
						randomTest = testGenerator();
					} while (acceptanceTester(randomTest, '*'))
				} else {  //other tests: who cares!
					//FlxG.log("Gen generic!");
					randomTest = testGenerator();
				}
			} else
				randomTest = testGenerator();
			
			return randomTest;
		}
		
		public function toString():String {  //IO: Array of TestStrings
			var tests:String = IO[0].toString(); //assumption: there is at least one test!
			for (var i:int = 1; i < IO.length; i++)
				tests += '|' + IO[i].toString();
			
			var websafeName:String = '';
			for (i = 0; i < _name.length; i++) websafeName += _name.charAt(i) == ' ' ? '_' : _name.charAt(i);
			var websafeDesc:String = '';
			for (i = 0; i < _desc.length; i++) websafeDesc += _desc.charAt(i) == ' ' ? '_' : _desc.charAt(i);
			
			//FlxG.log("Output: "+websafeName + ';' + websafeDesc + ';' + tests + ';' + dimensions + ';' + tools + ';' + (binary ? 1 : 0) + ';');
			return websafeName + ';' + websafeDesc + ';' + tests + ';' + dimensions + ';' + tools + ';' + (binary ? 1 : 0) + ';';
		}
		
		public function kongToString():String {
			var tests:String = IO[0].toString(); //assumption: there is at least one test!
			for (var i:int = 1; i < IO.length; i++)
				tests += '|' + IO[i].toString();
			
			return _name + ';' + _desc + ';' + tests + ';' + dimensions + ';' + tools + ';' + (binary ? 1 : 0) + ';';
		}
		
		public static function fromString(level:String):Level { 
			//format: name;description;tests;dimensions;tools;binary(optional);
			try {
				var levelArguments:Array = level.split(';');
				if (levelArguments.length < 6)
					return null;
				var tests:Array = TestString.fromString(levelArguments[2].split('|'));
				if (tests.length == 0 || tests.length > 8)
					return null;
				
				var name:String = '';
				for (var i:int = 0; i < levelArguments[0].length; i++) name += levelArguments[0].charAt(i) == '_' ? ' ' : levelArguments[0].charAt(i);
				var description:String = '';
				for (i = 0; i < levelArguments[1].length; i++) description += levelArguments[1].charAt(i) == '_' ? ' ' : levelArguments[1].charAt(i);
				
				var fixedTests:Array = translateTests(tests);
				var __acc__:Function = generateAcceptor(tests);
				var __gen__:Function = generateOutputGen(tests);
				
				return new Level(name,
								 description,
								 'Custom level!',
								 new UnlockRequirement(false),
								 levelArguments[3], levelArguments[4],
								 -1, fixedTests, __acc__, __gen__, null, levelArguments[5] == '1', tests);
			} catch (_:Object) { }
			return null;
		}
		
		public static function translateTests(tests:Array):Array {
			var fixedTests:Array = [];
			for (var i:int = 0; i < tests.length; i++)
				fixedTests[i] = tests[i].string;
			return fixedTests;
		}
		
		public static function generateAcceptor(tests:Array):Function {
			return function __acc__(input:String, output:String):Boolean {
					for (var j:int = 0; j < tests.length; j++)
						if (input == tests[j].string)
							return (tests[j].accepts == '*' && output != 'x') ||
								   (tests[j].accepts == output);
					FlxG.log("Failure creating acceptor on test " + j);
					return false; //???
				}
		}
		
		public static function generateOutputGen(tests:Array):Function {
			return function __gen__(input:String):String {
					for (var j:int = 0; j < tests.length; j++)
						if (input == tests[j].string)
							return tests[j].accepts;
					FlxG.log("Failure creating output on test " + j);
					return 'x'; //???
				}
		}
	}

}