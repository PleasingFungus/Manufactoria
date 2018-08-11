package States 
{
	import org.flixel.*;
	import Buttons.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class OverwriteState extends FlxState
	{
		[Embed(source = "/images/UI/floppy.png")] private static const save:Class;
		[Embed(source = "/images/UI/back.png")] private static const back:Class;
		
		override public function create():void
		{
			add(new FlxText(0, 100, 320, "This will permanently overwrite your solution and records.").setFormat(null, 8, 0xffffff, "center"));
			add(new FlxText(0, 110, 320, "Are you sure?").setFormat(null, 8, 0xffffff, "center"));
			add(new FlxText(83, 165, 100, "OVERWRITE"));
			add(new CustomButton(100, 180, save, overwrite, "OVERWRITE!", "Overwrites your save for the level."));
			add(new FlxText(190, 165, 40, "CANCEL"));
			add(new StateTransitionButton(200, 180, SuccessState).modify(back, "Cancel!", "Return to the records screen without overwriting!"));
			
			FlxG.stage.frameRate = 30;
			add(new AudioButton());
			add(new Tooltip());
			
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
		
		protected function overwrite():void {
			Manufactoria.overwrite = true;
			FlxG.state = new SuccessState();
		}
		
	}

}