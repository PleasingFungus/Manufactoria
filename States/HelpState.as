package  States
{
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class HelpState extends FlxState
	{
		[Embed(source = "/images/help_1.png")] private static const pickup:Class;
		[Embed(source = "/images/help_2.png")] private static const wasd:Class;
		[Embed(source = "/images/help_3.png")] private static const click:Class;
		[Embed(source = "/images/help_4b.png")] private static const run:Class;
		
		override public function create():void {
			add(new FlxSprite(5, 5).createGraphic(310, 125, 0xffd83030));
			add(new FlxText(0, 5, 320, "The Only Things You Need To Know!").setFormat(null,8,0x0,"center"));
			add(new FlxText(10, 20, 90, "Click on a component in the sidebar to pick it up!"));
			add(new FlxSprite(10, 65, pickup));
			add(new FlxText(110, 20, 100, "Use WASD to set which way it points..."));
			add(new FlxSprite(110, 65, wasd));
			add(new FlxText(220, 20, 90, "And click (or click and drag!) anywhere on the grid to place it!"));
			add(new FlxSprite(220, 65, click));
			add(new FlxSprite(5, 130).createGraphic(90, 80, 0xffd83030));
			add(new FlxText(10, 130, 90, "Then press the 'run' button to see what your machine does!"));
			add(new FlxSprite(10, 175, run));
			
			add(new FlxText(85, 130, 235, "Other Useful Things!").setFormat(null, 8, 0x0, "center"));
			add(new FlxText(100, 145, 65, "While using the 'select' tool (hotkey '2'!), Shift-C copies, Shift-V pastes, and 'Delete' deletes!"));
			add(new FlxText(164, 145, 68, "1 through 9 select components, and WASD, arrow-keys, mousewheel, and the numpad all rotate!"));
			add(new FlxText(236, 145, 82, "Remember: build to match the description, not the tests! If you build it right, your machine will pass for ANY test!"));
			
			add(new StateTransitionButton(10, 215, BuildState));
			add(new AudioButton());
			add(new Tooltip());
			FlxG.stage.frameRate = 30;
			Manufactoria.saveLevel();
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
	}

}