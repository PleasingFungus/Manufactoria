package Malevolence  {
	import Buttons.AudioButton;
	import org.flixel.*;
	import States.RunState;
	import TapeEngine.Queue;
	import Components.Pusher;
	import Components.Puller;
	import TapeEngine.BinaryHelper;
	 
	public class MalevolenceState extends RunState {
		protected var rendered:Boolean;
		
		public static var MALEVOLENCE_ENIGMA:String;
		public static var MALEVOLENCE_TIME:int;
		public static var MALEVOLENCE_TRIALS:int;
		
		public static var MALEVOLENCE_SLOTH:int;
		public static var MALEVOLENCE_SLOWEST:String;
		
		public static var CHEATED:Boolean;
		
		override public function create():void {
			queue = new Malevoqueue();
			Pusher.queuePush = queue.push;
			Puller.queuePull = queue.pull;
			
			new Destination(); //?
			for (var i:int = 0; i < Manufactoria.components.length; i++)
				if (Manufactoria.components[i].exists)
					Manufactoria.components[i] = TileComponent.regenerate(Manufactoria.components[i]);
			
			add(new FlxText(0, 100, 320, "THE MALEVOLENCE ENGINE BROODS.").setFormat(null, 16, 0x400000, 'center'));
			FlxG.stage.frameRate = 30;
			add(new AudioButton());
			add(new Tooltip());
		}
		
		override public function update():void {
			Manufactoria.updateMusic();
			
			if (MALEVOLENCE_TIME) { //fading out!
				if (FlxG.keys.ESCAPE) 
					transition(); //abort early
				return;
			}
			
			if (rendered) //so the message actually displays
				engineerMalevolence();
			else {
				FlxG.mouse.hide();
				rendered = true;
			}
		}
		
		protected function engineerMalevolence():void {
			CHEATED = false;
			MALEVOLENCE_ENIGMA = null;
			MALEVOLENCE_TRIALS = 0;
			
			//init a malevobot
			var bot:Malevobot = new Malevobot();
			//iter over all possible strings up to length/time-limit
			var oldCache:Array;
			var malevoTest:Function = FlxG.levels[FlxG.level].malevoTest
			try {
				for (var i:int = 0; i <= (FlxG.levels[FlxG.level] as Level).stringTestLength; i++) {
					//FlxG.log("Run for length: " + i);
					var cache:Array = new Array(1 << i);
					//FlxG.log("Cache size: "+cache.length);
					if (oldCache) {
						for (var j:int = 0; j < oldCache.length; j++) {
							var oldStr:String = oldCache[j];
							/*testString(oldStr + 'b', bot);
							cache[(j << 1)] = oldStr + 'b';
							testString(oldStr + 'r', bot);
							cache[(j << 1) + 1] = oldStr + 'r';*/
							
							malevoTest(oldStr + 'b', testString, bot);
							cache[(j << 1)] = oldStr + 'b';
							malevoTest(oldStr + 'r', testString, bot);
							cache[(j << 1) + 1] = oldStr + 'r';
						}
					} else {
						//testString('', bot);
						malevoTest('', testString, bot);
						cache[0] = '';
					}
					oldCache = cache;
				}
			} catch (e:Error) {
				//FlxG.log("I AM ERROR");
				defaultGroup.members[0].text = (e.message == 'Timeout!') ? "THE MALEVOLENCE ENGINE IS OUT OF PATIENCE!" : "THE MALEVOLENCE ENGINE SEES ALL WEAKNESS!";
				FlxG.fade.start(FlxState.bgColor, 1, transition, true);
				MALEVOLENCE_TIME = Malevobot.TIMEOUT_TICKS; //nonzero! That's important.
				MALEVOLENCE_SLOTH = bot.slowest;
				MALEVOLENCE_SLOWEST = bot.slowestTest;
				return;
			}
			
			MALEVOLENCE_TIME = bot.totalTicks;
			MALEVOLENCE_SLOTH = bot.slowest;
			MALEVOLENCE_SLOWEST = bot.slowestTest;
			
			var c:int = Manufactoria.levelsByName["Robo-children!"];
			var d:int = Manufactoria.levelsByName["Androids!"];
			if (FlxG.level == c || FlxG.level == d)
				try {
					bot = new Malevobot();
					testString("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr", bot); //sixty reds
					testString("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr", bot); //sixty reds
				} catch (e:Error) {
					FlxG.log(e.message);
					MALEVOLENCE_ENIGMA = null;
					if (e.message != 'Timeout!')
						CHEATED = true;
				}
			
			if (CHEATED)
				defaultGroup.members[0].text = "THE MALEVOLENCE ENGINE SEES WHAT YOU DID THERE.";
			else
				defaultGroup.members[0].text = "THE MALEVOLENCE ENGINE HAS FOUND NO FLAW!";
			FlxG.fade.start(FlxState.bgColor, 1, transition, true);
		}
		
		private function testString(test:String, bot:Malevobot):void {
			
		//for each str:
			//reset the bot
			bot.resetBot();
			//load up the string
			RunState.test = test;
			queue.loadString(test);
			//tell it to run
			var result:int = bot.runBot();
			MALEVOLENCE_TRIALS++;
			//if it fails:
			if (result == Malevobot.TIMEOUT || !malevoValid(bot)) {
				//set your public static 'MALEVOLENCE STRING' to the input
				MALEVOLENCE_ENIGMA = test;// ? test : 'x';
				//return
				throw new Error(result == Malevobot.TIMEOUT ? "Timeout!" : "Invalid output!");
			} else if (bot.testTicks > bot.slowest) {
				bot.slowest = bot.testTicks;
				bot.slowestTest = test;
			}
		}
		
		protected function malevoValid(robot:Malevobot):Boolean {
			var tester:Function = FlxG.levels[FlxG.level].acceptanceTester;
			if (tester != null) {	//accept/reject level
				//FlxG.log("Input: " + test);
				//FlxG.log("Output: " + (robot.accepted ? queue.toString() : 'x'));
				adjudgedValid = tester(test, robot.accepted ? queue.toString() : 'x');
				//FlxG.log("Valid? " + adjudgedValid);
			} else {		//output level
				var machineOut:String = queue.toString();
				var validOut:String = FlxG.levels[FlxG.level].outputGenerator(test);
				if (FlxG.levels[FlxG.level].binary) {
					machineOut = BinaryHelper.trimBinary(machineOut);
					validOut = BinaryHelper.trimBinary(validOut);
				}
				adjudgedValid = robot.accepted && (machineOut == validOut);
			}
			return adjudgedValid;
		}
		
		protected function transition():void {
			RunState.test = null;
			FlxG.state = new RunState();
		}
	}
}