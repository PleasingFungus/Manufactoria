package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import States.EndState;
	import States.IntroState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Tab extends FlxSprite
	{
		[Embed(source = "/images/UI/t0.png")] private static const intro_tab:Class;
		[Embed(source = "/images/UI/t1.png")] private static const menu_tab:Class;
		[Embed(source = "/images/UI/t2.png")] private static const write_tab:Class;
		[Embed(source = "/images/UI/t3.png")] private static const color_tab:Class;
		[Embed(source = "/images/UI/t4.png")] private static const binary_tab:Class;
		[Embed(source = "/images/UI/t5.png")] private static const epilog_tab:Class;
		private static const TABS:Array = new Array(intro_tab, menu_tab, write_tab, color_tab, binary_tab, epilog_tab);
		private static const TAB_WIDTH:int = 50;
		
		private var appertainingSlides:int;
		
		public function Tab(type:int) {
			super(type * TAB_WIDTH + 10, 2, TABS[type]);
			this.appertainingSlides = type;
		}
		
		override public function update():void {
			if (FlxG.mouse.justPressed() && overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) {
				if (appertainingSlides < IntroState.LETTER) {
					IntroState.slides = IntroState.all_slides[appertainingSlides];
					FlxG.state = new IntroState();
				} else
					FlxG.state = new EndState();
			} 
		}
	}

}