package States 
{
	import org.flixel.*;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class KongLoadFailState extends FlxState
	{
		
		public function KongLoadFailState(level:int)  {
			if (level < Manufactoria.CUSTOM_OFFSET)
				add(new FlxText(0, 100, 320, "Level " + FlxG.levels[level].name + " not unlocked!").setFormat(null, 8, 0xffffff, "center"));
			else
				add(new FlxText(0, 100, 320, "No level in specified custom-level slot!").setFormat(null, 8, 0xffffff, "center"));
			add(new StateTransitionButton(200, 180, MenuState));
			
			add(new AudioButton());
			add(new Tooltip());
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
		
	}

}