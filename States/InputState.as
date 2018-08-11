package States 
{
	import Buttons.FastColorButton;
	import org.flixel.*;
	import TapeEngine.Queue;
	import Buttons.SliderBar;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import Components.Pusher;
	import Components.Puller;
	import Buttons.Hotkey;
	import TapeEngine.BinaryHelper;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class InputState extends FlxState
	{
		
		protected var midground:FlxGroup;
		protected var foreground:FlxGroup;
		
		protected var queue:Queue;
		protected var robot:Robot;
		
		protected var source:Source;
		protected var destination:Destination;
		
		protected var FCBs:FlxGroup;
		protected var test:String;
		
		protected var stoppedForDeath:Boolean;
		protected var slider:SliderBar;
		
		public function InputState(queueString:String = "") {
			add(queue = new Queue(""));
			Pusher.queuePush = queue.push;
			Puller.queuePull = queue.pull;
			
			add(new FlxSprite(76, 0, BuildState.UIBar_png));
			add(midground = new FlxGroup());
			add(foreground = new FlxGroup());
			
			midground.add(source = new Source(true));
			midground.add(destination = new Destination());
			
			add(slider = new SliderBar(3, 215, 0));
			add(new StateTransitionButton(53, 215, BuildState).modify(RunState.stop_png,
																	  "Halt!",
																	  "Halt test run, and return to setup!"));
			
			add(robot = new Robot(null));
			stoppedForDeath = false;
			
			for (i = 0; i < Manufactoria.components.length; i++)
				if (Manufactoria.components[i].exists) {
					Manufactoria.components[i] = TileComponent.regenerate(Manufactoria.components[i]);
					midground.add(Manufactoria.components[i]);
				}
			
			add(new Overlay());
			
			add(FCBs = new FlxGroup());
			var FCB:FastColorButton;
			var colorCount:int = (FlxG.level < Manufactoria.BONUS_OFFSET ? 2 : 4);//FlxG.level < Manufactoria.CUSTOM_OFFSET ? 3 : 4);
			for (var i:int = 0; i < colorCount; i++) {
				/*add(FCB = new FastColorButton(112 + i * 30, 0, i + 1, queue));
				add(new Hotkey(FCB.x + FCB.width, FCB.y + FCB.height / 2 - Hotkey.DIM / 2, i + 1, FCB));
				add(FCB = new FastColorButton(112 + i * 30, 224, i + 1, queue));
				add(new Hotkey(FCB.x + FCB.width, FCB.y + FCB.height / 2 - Hotkey.DIM / 2, i + 1, FCB, false));*/
				FCBs.add(FCB = new FastColorButton(304, 32 + i * 30, i + 1, queue)); 
				FCBs.add(new Hotkey(FCB.x + FCB.width/2 - Hotkey.DIM / 2, FCB.y + FCB.height, i + 1, FCB));
			}
			/*add(FCB = new FastColorButton(112 + i * 30, 0, 0, queue));
			add(new Hotkey(FCB.x + FCB.width, FCB.y + FCB.height / 2 - Hotkey.DIM / 2, i + 1, FCB));
			add(FCB = new FastColorButton(112 + i * 30, 224, 0, queue));
			add(new Hotkey(FCB.x + FCB.width, FCB.y + FCB.height / 2 - Hotkey.DIM / 2, i + 1, FCB, false));*/
			FCBs.add(FCB = new FastColorButton(304, 32 + i * 30, 0, queue)); 
			FCBs.add(new Hotkey(FCB.x + FCB.width/2 - Hotkey.DIM / 2, FCB.y + FCB.height, i + 1, FCB));
			i++
			//add(new StateTransitionButton(112 + i * 30, 0, InputState));
			//add(new StateTransitionButton(112 + i * 30, 224, InputState));
			add(new StateTransitionButton(304, 32 + i * 30, InputState));
			
			add(new AudioButton());
			add(new Tooltip());
			
			Manufactoria.saveLevel();
			
			FlxG.mouse.show();
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
			
			if (FlxG.timeScale && robot.valid == null) {
				test = queue.toString();
				robot.valid = valid;
				//FlxG.log(test +" rejected? "+valid());
				FCBs.exists = false;
			}
			
			if (robot.quiteDone() && !stoppedForDeath) {
				slider.halt();
				stoppedForDeath = true;
			} else if (robot.thoroughlyDone())
				FlxG.state = new InputState(queue.toString());
		}
		
		//private function valid():Boolean { return true }
		
		protected function valid():Boolean {
			var tester:Function = FlxG.levels[FlxG.level].acceptanceTester;
			var adjudgedValid:Boolean;
			
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
	}

}