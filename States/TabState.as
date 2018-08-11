package States 
{
	import org.flixel.*;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class TabState extends FlxState
	{
		[Embed(source = "/images/Backgrounds/folders.png")] public static const bg:Class;
		
		override public function create():void 
		{
			add(new FlxSprite(0, 0, bg));
			if (FlxG.music) FlxG.music.fadeOut(1, true);
			
			for (var i:int = 0; i < IntroState.viewedScenes.length; i++)
				if (IntroState.viewedScenes[i])
					add(new Tab(i));
			
			add(new StateTransitionButton(295, 215, MenuState));
			
			FlxG.stage.frameRate = 30;
			FlxG.mouse.show();
		}
		
	}

}