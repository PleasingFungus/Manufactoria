package States 
{
	import Buttons.AudioButton;
	import Buttons.StateTransitionButton;
	import org.flixel.*;
	import TapeEngine.Queue;
	import TapeEngine.StackSymbol;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class FailureState extends FlxState {
		[Embed(source = "/images/Backgrounds/failure.png")] public static const background:Class;
		[Embed(source = "/images/UI/retry.png")] public static const retry:Class;
		
		public function FailureState(output:String):void {
			var i:int;
			add(new FlxSprite(0, 0, background));
			
			var level:Level = FlxG.levels[FlxG.level];
			var test:String = RunState.test;
			
			var acceptance:Boolean = output.charAt(0) == '*';
			var invalidOutput:String = output.slice(1);
			
			var outputGenerator:Function = level.outputGenerator;
			var validOutput:String = (outputGenerator != null) ? outputGenerator(test) : acceptance ? 'x' : '*';
			
			//FlxG.log("In: " + test + ", out: " + invalidOutput + ", valid: " + validOutput);
			//FlxG.log("Gen: " + String(outputGenerator) + ", " + (outputGenerator == null));
			
			add(new PseudoQueue(17, 13, test)); //input
			
			if (validOutput == 'x') {
				add(new FlxText(107, 100, 105, "ACCEPTED").setFormat(null, 16, 0xffcece, "center"));
				add(new FlxText(212, 120, 100, "REJECT!").setFormat(null, 16, 0xceffce, "center"));
			} else if (validOutput == '*') {
				add(new FlxText(107, 100, 105, "REJECTED").setFormat(null, 16, 0xffcece, "center"));
				add(new FlxText(212, 120, 100, "ACCEPT!").setFormat(null, 16, 0xceffce, "center"));
			} else {
				if (acceptance)
					add(new PseudoQueue(122, -7, invalidOutput));
				else
					add(new FlxText(107, 100, 105, "REJECTED").setFormat(null, 16, 0xffcece, "center"));
				add(new PseudoQueue(227, 13, validOutput));
			}
			
			add(new StateTransitionButton(107, 219, BuildState).modify(null, 'Retry!', 'Retry the level! Fix your mistakes! Win!'));
			if (Manufactoria.unlocked[Manufactoria.PROTO2] == Manufactoria.BEATEN) {
				add(new StateTransitionButton(191, 219, RunState).modify(null, 'Re-run!', 'Run the machine again! See what went wrong!'));
				//add(new StateTransitionButton(191, 219, Manufactoria.levelEntry)); //149?
			}
			
			FlxG.stage.frameRate = 30;
			add(new AudioButton());
			add(new Tooltip());
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
	}

}