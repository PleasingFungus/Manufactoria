package  States
{
	import adobe.utils.CustomActions;
	import Buttons.CustomButton;
	import Buttons.SliderBar;
	import flash.text.GridFitType;
	import Malevolence.MalevolenceState;
	import org.flixel.*;
	import Components.Puller;
	import Components.Pusher;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import TapeEngine.Queue;
	import TapeEngine.BinaryHelper;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class RunState extends FlxState {
		
		[Embed(source = "/images/UI/play.png")] public static const play_png:Class;
		[Embed(source = "/images/UI/pause.png")] public static const pause_png:Class;
		[Embed(source = "/images/UI/stop.png")] public static const stop_png:Class;
		
		protected var midground:FlxGroup;
		protected var foreground:FlxGroup;
		
		protected var source:Source;
		protected var destination:Destination;
		
		public static var test:String = null;
		protected var testNumber:int;
		public static var times:Array;
		
		protected var queue:Queue;
		protected var robot:Robot;
		protected var adjudgedValid:Boolean;
		
		override public function create():void {
			Manufactoria.saveLevel();
			
			if (!test) { //not just replaying your HUMILIATING FAILURE
				if (!MalevolenceState.MALEVOLENCE_TIME && (FlxG.levels[FlxG.level] as Level).stringTestLength > -1) { //haven't activated the MALEVOLENCE ENGINE yet
					FlxG.state = new MalevolenceState();
					return;
				}
				
				//set the first test (possibly malevolence)
				testNumber = 0;
				test = nextTest();
				
				times = new Array(FlxG.levels[FlxG.level].fixedTests.length);
				times[0] = 0;
			}
			
			add(queue = new Queue(test));
			Pusher.queuePush = queue.push;
			Puller.queuePull = queue.pull;
			
			add(new FlxSprite(76, 0, BuildState.UIBar_png));
			add(midground = new FlxGroup());
			add(foreground = new FlxGroup());
			
			midground.add(source = new Source(true));
			midground.add(destination = new Destination());
			
			add(new SliderBar(3, 215));
			add(new StateTransitionButton(53, 215, BuildState).modify(stop_png, "Halt!", "Halt test run, and return to setup!"));
			
			add(robot = new Robot(valid, incrementTime));
			
			for (var i:int = 0; i < Manufactoria.components.length; i++)
				if (Manufactoria.components[i].exists) {
					Manufactoria.components[i] = TileComponent.regenerate(Manufactoria.components[i]);
					midground.add(Manufactoria.components[i]);
				}
			
			add(new Overlay());
			add(new AudioButton());
			add(new Tooltip());
			
			Manufactoria.saveLevel();
			
			FlxG.mouse.show();
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
			
			if (robot.quiteDone() && adjudgedValid) {
				if (testInBounds(testNumber + 1))	{
					robot.valid = function _():Boolean { return true; };
					
					testNumber++;
					test = nextTest();
					if (test == null) {
						//FlxG.timeScale = 1;
						//FlxG.state = new SuccessState();
						return;
					}
					
					source.open();
					midground.add(robot = new Robot(valid, incrementTime));
					queue.loadString(test);
					//if (testNumber < FlxG.levels[FlxG.level].fixedTests.length)
						times[testNumber] = 0;
				} else if (robot.thoroughlyDone()) {
					FlxG.timeScale = 1;
					
					if (Manufactoria.overwrite) {
						Manufactoria.unlocked[FlxG.level] = Manufactoria.BEATEN;
						Manufactoria.updateUnlocked();
					}
					
					if (FlxG.level == Manufactoria.FINAL_LEVEL && !IntroState.viewedScenes[IntroState.LETTER]) {
						SuccessState.proxySave();
						FlxG.state = new EndState();
					} else
						FlxG.state = new SuccessState();
				}
			} else if (robot.thoroughlyDone()) {
				FlxG.timeScale = 1;
				FlxG.state = new FailureState((robot.accepted ? '*' : 'x') + queue.toString());
			} else {
				//times[testNumber] += FlxG.elapsed;
			}
		}
		
		private function nextTest():String {
			var level:Level = FlxG.levels[FlxG.level];
			var t:int = testNumber;
			var e:String = MalevolenceState.MALEVOLENCE_ENIGMA;
			if (e != null) {
				FlxG.log("Enigma: " + MalevolenceState.MALEVOLENCE_ENIGMA+'!');
				if (t > 0)
					t--;
				else 
					return e;//(e == 'x') ? '' : e;
			}
			if (t < level.fixedTests.length)
				return level.fixedTests[t];
			return null;
		}
		
		private function testInBounds(testNum:int):Boolean {
			var level:Level = FlxG.levels[FlxG.level];
			return testNum < level.fixedTests.length;
		}
		
		protected function valid():Boolean {
			var tester:Function = FlxG.levels[FlxG.level].acceptanceTester;
			if (tester != null)	//accept/reject level
				adjudgedValid = tester(test, robot.accepted ? queue.toString() : 'x');
			else {		//output level
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
		
		protected function incrementTime():void {
			//if (testNumber < FlxG.levels[FlxG.level].fixedTests.length)
				times[testNumber] += Manufactoria.GRID_SIZE / Robot.SPEED; //hm
		}
	}
}