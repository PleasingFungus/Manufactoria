package States 
{
	import Buttons.CustomButton;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class ConfirmClear extends FlxState
	{
		[Embed(source = "/images/UI/clear.png")] public static const clear:Class;
		
		override public function create():void
		{
			add(new FlxText(0, 100, 320, "This will clear the current level. Are you sure?").setFormat(null, 8, 0xffffff, "center"));
			add(new FlxText(93, 165, 40, "CLEAR"));
			add(new CustomButton(100, 180, clear, clearScreen, "RESET MACHINE!", "Resets the machine. Will ERASE all parts!"));
			add(new FlxText(190, 165, 40, "CANCEL"));
			add(new StateTransitionButton(200, 180, BuildState));
			
			FlxG.stage.frameRate = 30;
			add(new AudioButton());
			add(new Tooltip());
			Manufactoria.saveLevel(); //ironic!
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
		
		protected function clearScreen():void {
			Manufactoria.components = new Array();
			Manufactoria.grid = new Array(Manufactoria.grid.length);
			Manufactoria.saveLevel();
			FlxG.state = new BuildState();
		}
	}

}