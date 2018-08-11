package  States
{
	import Buttons.AudioButton;
	import org.flixel.*;
	import org.flixel.data.FlxKong;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class IntroState extends FlxState {
		
		[Embed(source = "/images/Backgrounds/intro.png")] public static const background:Class;
		[Embed(source = "/images/Slides/0.png")] private static const a_0:Class;
		[Embed(source = "/images/Slides/1.png")] private static const a_1:Class;
		[Embed(source = "/images/Slides/2.png")] private static const a_2:Class;
		[Embed(source = "/images/Slides/3.png")] private static const a_3:Class;
		[Embed(source = "/images/Slides/4.png")] private static const a_4:Class;
		[Embed(source = "/images/Slides/5.png")] private static const a_5:Class;
		[Embed(source = "/images/Slides/6.png")] private static const a_6:Class;
		public static const intro:Array = new Array(a_0, a_1, a_2, a_3, a_4, a_5, a_6);
		public static const INTRO:int = 0;
		[Embed(source = "/images/Slides/brh_0.png")] private static const brh_0:Class;
		[Embed(source = "/images/Slides/brh_1.png")] private static const brh_1:Class;
		[Embed(source = "/images/Slides/brh_2.png")] private static const brh_2:Class;
		public static const branch:Array = new Array(brh_0, brh_1, brh_2);
		public static const BRANCH:int = 1;
		[Embed(source = "/images/Slides/ot_01.png")] private static const ot_1:Class;
		[Embed(source = "/images/Slides/ot_02.png")] private static const ot_2:Class;
		[Embed(source = "/images/Slides/ot_03.png")] private static const ot_3:Class;
		[Embed(source = "/images/Slides/ot_04.png")] private static const ot_4:Class;
		[Embed(source = "/images/Slides/ot_05.png")] private static const ot_5:Class;
		public static const output:Array = new Array(ot_1, ot_2, ot_3, ot_4, ot_5);
		public static const OUTPUT:int = 2;
		[Embed(source = "/images/Slides/c_0.png")] private static const c_0:Class;
		[Embed(source = "/images/Slides/c_1.png")] private static const c_1:Class;
		[Embed(source = "/images/Slides/c_2.png")] private static const c_2:Class;
		[Embed(source = "/images/Slides/c_3.png")] private static const c_3:Class;
		public static const color:Array = new Array(c_0, c_1, c_2, c_3);
		public static const COLOR:int = 3;
		[Embed(source = "/images/Slides/bin_0.png")] private static const bin_0:Class;
		[Embed(source = "/images/Slides/bin_1.png")] private static const bin_1:Class;
		public static const binary:Array = new Array(bin_0, bin_1);
		public static const BINARY:int = 4;
		public static const LETTER:int = 5;
		
		public static const all_slides:Array = new Array(intro, branch, output, color, binary, null);
		
		
		[Embed(source = "/images/Slides/light.png")] private static const light:Class;
		
		[Embed(source = "/sound/projector-run.mp3")] private static const projectorNoise:Class;
		
		public static var viewedScenes:Array;
		
		protected var wall:FlxSprite;
		protected var lightblock:FlxSprite;
		protected var projector:FlxSprite;
		protected var plate:FlxSprite;
		
		public static var slides:Array = intro;
		protected var slide:int = 0;
		
		//protected var audioButton:AudioButton;
		
		override public function create():void {
			//add(new FlxSprite(0, 0, background));
			wall = new FlxSprite(0, 0, background);
			
			lightblock = new FlxSprite().createGraphic(320, 240, 0xff000000, true);
			projector = new FlxSprite(0, -10).loadGraphic(light,false,false,0,0,true);
			projector.blend = "screen";
			plate = new FlxSprite(0, 0, slides[0]);
			plate.blend = "multiply";
			plate.alpha = .6;
			projector.draw(plate, 80, 10);
			
			lightblock.blend = "multiply";
			//add(lightblock);
			
			//if (FlxG.music) FlxG.music.fadeOut(1, true);
			//new FlxSound().loadEmbedded(projectorNoise, true).fadeIn(1);
			
			var helpText:FlxText = new FlxText(10, 225, 300, "Press RIGHT to advance, LEFT to go back, or ESCAPE to skip.");
			helpText.alignment = "center";
			add(helpText);
			//add(audioButton = new AudioButton());
			//add(new Tooltip());
			
			FlxG.stage.frameRate = 60;
			//FlxG.mouse.show();
			FlxG.mouse.hide();
		}
		
		override public function update():void {
			super.update();
			if (FlxG.keys.LBRACKET) { //DEBUG HAX
				for (var i:int = 0; i < Manufactoria.CUSTOM_OFFSET; i++) {
					Manufactoria.unlocked[i] = Manufactoria.BEATEN;
					Manufactoria.componentRecords[i] = 1000;
					Manufactoria.timeRecords[i] = int.MAX_VALUE;
				}
				for (i = 0; i < 6; i++)
					viewedScenes[i] = true;
				exit();
			} else if (FlxG.keys.ESCAPE)
				exit();
			else if (FlxG.keys.justPressed("RIGHT") || FlxG.keys.justPressed("D") || FlxG.mouse.justPressed())
				nextSlide();
			else if (FlxG.keys.justPressed("LEFT") || FlxG.keys.justPressed("A"))
				lastSlide();
			if (Manufactoria.KONG && !Manufactoria.KONG_INIT) {
				if(!FlxG.kong) (FlxG.kong = parent.addChild(new FlxKong(Manufactoria.onKongLoad)) as FlxKong).init();
				Manufactoria.KONG_INIT = true;
			}
		}
		
		override public function render():void {
			wall.render();
			projector.alpha = .7 + FlxU.random() * .1;
			lightblock.fill(0xff000000);
			lightblock.draw(projector);
			lightblock.render();
			
			super.render();
		}
		
		protected function nextSlide():void {
			slide++;
			if (slide < slides.length)
				renderSlide();
			else
				exit();
		}
		
		protected function lastSlide():void {
			slide--;
			if (slide < 0) slide = 0;
			else
				renderSlide();
		}
		
		protected function renderSlide():void {
			plate = new FlxSprite(0, 0, slides[slide]);
			plate.blend = "multiply";
			plate.alpha = .6;
			projector.loadGraphic(light, false, false, 0, 0, true).draw(plate, 80, 10);
			projector.blend = "screen";
		}
		
		public static function exit():void {
			
			if (FlxG.music) FlxG.music.fadeIn(1);
			
			if (!viewedScenes[all_slides.indexOf(slides)]) {
				viewedScenes[all_slides.indexOf(slides)] = true;
				Manufactoria.save.write("scenes", viewedScenes);
			}
			
			if (FlxG.level < 0) {
				FlxG.state = new TabState();
			} else {
				if (!Manufactoria.unlocked[0]) {
					Manufactoria.updateUnlocked();
					Manufactoria.save.write("unlocked", Manufactoria.unlocked);
				}
				
				Manufactoria.components = new Array();
				Manufactoria.setGrid();
				
				FlxG.state = new BuildState();
			}
		}
	}

}