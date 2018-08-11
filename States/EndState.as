package States {
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class EndState extends FlxState {
		[Embed(source = "/images/Slides/letter_flat.png")] private static const background:Class;
		[Embed(source = "/images/Slides/lettertext0.png")] private static const text0:Class;
		[Embed(source = "/images/Slides/lettertext1.png")] private static const text1:Class;
		
		private var text:FlxSprite;
		private var page:int;
		
		override public function create():void {
			add(new FlxSprite(0, 0, background));
			add(text = new FlxSprite(80, 20, text0));
			
			var helpText:FlxText = new FlxText(10, 225, 300, "Press RIGHT to advance, LEFT to go back, or ESCAPE to skip.");
			helpText.alignment = "center";
			add(helpText);
			
			page = 0;
			
			if (FlxG.music) FlxG.music.fadeOut(1, true);
			FlxG.mouse.hide();
		}
		
		override public function update():void {
			//super.update();
			if (FlxG.keys.ESCAPE)
				exit();
			else if (FlxG.keys.justPressed("RIGHT")) {
				if (page++) //SIDE EFFECT
					exit();
				else 
					text.loadGraphic(text1);
			} else if (FlxG.keys.justPressed("LEFT")) {
				if (page) {
					page--;
					text.loadGraphic(text0);
				}
			}
		}
		
		public static function exit():void {
			if (FlxG.music) FlxG.music.fadeIn(1);
			
			if (!IntroState.viewedScenes[IntroState.LETTER]) {
				IntroState.viewedScenes[IntroState.LETTER] = true;
				Manufactoria.save.write("scenes", IntroState.viewedScenes);
			}
			
			FlxG.state = new ((FlxG.level < 0) ? TabState : MenuState)();
		}
	}
}