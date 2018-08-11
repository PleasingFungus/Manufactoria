package States 
{
	import Buttons.ColorButton;
	import Buttons.CustomButton;
	import Buttons.DepressingButton;
	import Buttons.Dial;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import Buttons.AudioButton;
	import Buttons.StateTransitionButton;
	import TapeEngine.Queue;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class LevelEditState extends FlxState {
		//[Embed(source = "/images/Backgrounds/leveledit.png")] private static const background:Class;
		[Embed(source = "/images/UI/cog.png")] private static const cog:Class;
		[Embed(source = "/images/UI/run.png")] private static const test:Class;
		[Embed(source = "/images/UI/back.png")] private static const back:Class;
		
		[Embed(source = "/images/UI/plus_up.png")] private static const plus_up:Class;
		[Embed(source = "/images/UI/plus_down.png")] private static const plus_down:Class;
		[Embed(source = "/images/UI/minus_up.png")] private static const minus_up:Class;
		[Embed(source = "/images/UI/minus_down.png")] private static const minus_down:Class;
		
		[Embed(source = "/images/UI/input_tab.png")] private static const input_tab:Class;
		[Embed(source = "/images/UI/output_tab.png")] private static const output_tab:Class;
		
		[Embed(source = "/images/UI/share_button.png")] public static const share_png:Class;
		
		protected var levelName:FlxInputText;
		protected var description:FlxInputText;
		protected var levelSize:FlxText;
		protected var binary:Dial;
		protected var tests:Array;
		protected var testField:SelectField;
		protected var outputMode:Dial;
		protected var acceptance:Dial;
		protected var colorButtons:FlxGroup;
		protected var queue:Queue;
		protected var inputTab:CustomButton;
		protected var outputTab:CustomButton;
		protected var IO:Boolean;
		
		protected var loadingLevel:Boolean;
		
		override public function create():void {
			//add(new FlxSprite(0, 0, background));
			loadingLevel = true;
			
			add(levelName = new FlxInputText(5, 10, 200, 22, "Level Name!", 0xffffff, null, 16, "center"));
			levelName.fixedHeight();//setMaxLength(15);
			//levelName.filterMode = FlxInputText.ONLY_ALPHA;
			add(description = new FlxInputText(5, 40, 70, 75, "Level description!",  0xffffff));
			description.fixedHeight();
			//description.filterMode = FlxInputText.ONLY_ALPHA;
			
			add(new FlxText(5, 125, 70, "LEVEL SIZE:").setFormat(null, 8, 0xffffff, "center"));
			add(levelSize = new FlxText(30, 137, 20, "13").setFormat(null, 8, 0xffffff, "center"));
			var sizeMinus:DepressingButton = new DepressingButton(20, 140, minus_up, minus_down);
			sizeMinus.onRelease = decrementSize;
			add(sizeMinus);
			var sizePlus:DepressingButton = new DepressingButton(55, 140, plus_up, plus_down);
			sizePlus.onRelease = incrementSize;
			add(sizePlus);
			
			add(binary = new Dial(25, 175, "Normal", "Binary"));
			
			
			
			tests = new Array(new TestString('', '*', "Test 1"));
			add(testField = new SelectField(125, 40).configure(60, 100));
			testField.load(tests);
			var testMinus:DepressingButton = new DepressingButton(125, 150, minus_up, minus_down);
			testMinus.onRelease = decrementTests;
			add(testMinus);
			var testPlus:DepressingButton = new DepressingButton(177, 150, plus_up, plus_down);
			testPlus.onRelease = incrementTests;
			add(testPlus);
			testField.onSelect = selectTest;
			
			add(outputMode = new Dial(140, 185, "Filter", "Output"));
			outputMode.onClick = toggleOutputMode;
			
			add(acceptance = new Dial(260, 120, "Reject", "Accept"));
			acceptance.exists = false;
			
			add(queue = new Queue('', 240, 10, 4));
			add(colorButtons = new FlxGroup());
			for (var i:int = 0; i < 5; i++)
				colorButtons.add(new ColorButton(207, 20 + 30 * i, i, queue));
			add(inputTab = new CustomButton(240, 215, input_tab, toggleToInput, "Input!", "Switch to viewing/modifying the input test string for this test!"));
			add(outputTab = new CustomButton(295, 215, output_tab, toggleToOutput, "Output!", "Switch to viewing/modifying the output value for this test!"));
			inputTab.color = 0xff808080;
			
			var level:Level = FlxG.levels[FlxG.level]
			if (level) {
				levelName.text = level.name;
				description.text = level.description;
				levelSize.text = String(level.dimensions);
				if ((level.binary && !binary.on) || (!level.binary && binary.on))
					binary.toggle();
				
				tests = level.IO;
				for (i = 0; i < tests.length; i++)
					tests[i].name = "Test " + (i + 1);
				testField.load(tests);
			}
			testField.selection = 0;
			
			
			
			
			
			var cancel:StateTransitionButton = new StateTransitionButton(5, 215, LevelSelectState);
			cancel.modify(back, "Cancel!", "Return to the level-selection screen without saving!");
			cancel.color = 0xffff8080;
			add(cancel);
			var save:CustomButton = new CustomButton(55, 215, cog, savequit, "Save and exit!", "Save your level, and return to the level-selection screen!");
			save.color = 0xff80ff80;
			add(save);
			add(new CustomButton(30, 215, test, savetest, "Test!", "Test your new level!"));
			if (Manufactoria.KONG)
				add(new CustomButton(80, 215, share_png, saveKongLevel, "Share level!", "Publish your level to the widest depths of the Internets, for all to marvel at!"));
			
			add(new AudioButton());
			add(new Tooltip());
			
			if (FlxG.level != -1 && Manufactoria.overwrite && Manufactoria.components.length) //popped in from a previous level
				Manufactoria.saveLevel();
			
			Manufactoria.levelEntry = LevelEditState;
			FlxG.timeScale = 1;
			FlxG.stage.frameRate = 30;
			FlxG.mouse.show();
			loadingLevel = false;
		}
		
		protected function selectTest(testIndex:int):void {
			//save old test
			if (!loadingLevel)
				updateTest();
			
			var test:TestString = tests[testIndex];
			if (!test) {
				acceptance.exists = colorButtons.exists = queue.exists = false;
				return;
			} else {
				queue.flushBuffer();
			}
			if (test.accepts == '*' || test.accepts == 'x') {
				if (test.accepts == '*' && !acceptance.on)
					acceptance.toggle();
				if (outputMode.on)
					outputMode.toggle();
			} else {
				if (!outputMode.on)
					outputMode.toggle();
			}
			if (IO == IN) {
				queue.loadString(test.string);
				queue.exists = colorButtons.exists = true;
				inputTab.color = 0xffffffff;
				outputTab.color = 0xff808080;
			} else {
				outputTab.color = 0xffffffff;
				inputTab.color = 0xff808080;
				if (outputMode.on) {
					queue.loadString(test.accepts);
					queue.exists = colorButtons.exists = true;
				} else {
					acceptance.exists = true;
				}
			}
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
		
		
		
		
		protected function incrementSize():void {
			var newSize:int = int(levelSize.text) + 2;
			if (newSize > 13) newSize = 13;
			levelSize.text = String(newSize);
		}
		
		protected function decrementSize():void {
			var newSize:int = int(levelSize.text) - 2;
			if (newSize < 5) newSize = 5;
			levelSize.text = String(newSize);
		}
		
		protected function incrementTests():void {
			if (tests.length < 8) {
				tests.push(new TestString('', outputMode.on ? '' : '*', "Test " + (tests.length + 1)));
				testField.load(tests);
				testField.selection = tests.length - 1;
			}
		}
		
		protected function decrementTests():void {
			if (tests.length > 1) {
				tests.pop();
				testField.load(tests);
				if (testField.selection >= tests.length)
					testField.selection = tests.length - 1;
			}
		}
		
		protected function toggleOutputMode():void {
			if (IO == OUT) {
				acceptance.exists = !acceptance.exists;
				queue.exists = colorButtons.exists = !queue.exists;
			}
			updateTest(true);
			if (IO == OUT)
				queue.loadString('');
		}
		
		protected function toggleToInput():void {
			if (IO == OUT) {
				updateTest();
				queue.loadString(tests[testField.selection].string);
				
				acceptance.exists = false
				queue.exists = colorButtons.exists = true;
				
				inputTab.color = 0xffffffff;
				outputTab.color = 0xff808080;
				
				IO = IN;
			}
		}
		
		protected function toggleToOutput():void {
			if (IO == IN) {
				updateTest();
				
				acceptance.exists = !outputMode.on;
				queue.exists = colorButtons.exists = outputMode.on;
				queue.loadString(tests[testField.selection].accepts);
				
				outputTab.color = 0xffffffff;
				inputTab.color = 0xff808080;
				
				IO = OUT;
			}
		}
		
		protected function updateTest(resetOutput:Boolean = false):void {
			if (!tests[testField.selection]) return;
			var input:String, output:String;
			if (IO == IN) {
				input = queue.toString();
			} else {
				input = tests[testField.selection].string;
			}
			
			if (resetOutput) {
				if (outputMode.on == FILTER)
					output = 'x';
				else
					output = '';
			} else {
				if (IO == OUT) {
					if (outputMode.on == FILTER) {
						if (acceptance.on == ACCEPT)
							output = '*';
						else
							output = 'x';
					} else {
						output = queue.toString();
					}
				} else
					output = tests[testField.selection].accepts;
			}
			//= !IO ? tests[testField.selection].string : queue.toString();
			//var output:String = !IO ? (outputMode.on ? queue.toString() : (acceptance.on ? '*' : 'x')) : tests[testField.selection].accepts;
			tests[testField.selection] = new TestString(input, output, "Test " + String(testField.selection + 1));
		}
		
		
		
		protected function savequit():void {
			updateTest();
			FlxG.levels[FlxG.level] = new Level(levelName.text, description.text, '', new UnlockRequirement(false), int(levelSize.text), Manufactoria.FULL_TOOLS,
												-1, Level.translateTests(tests), Level.generateAcceptor(tests), null, null, binary.on, tests);
			Manufactoria.saveCustomLevels();
			FlxG.state = new LevelSelectState();
		}
		
		protected function savetest():void {
			updateTest();
			FlxG.levels[FlxG.level] = new Level(levelName.text, description.text, '', new UnlockRequirement(false), int(levelSize.text), Manufactoria.FULL_TOOLS,
												-1, Level.translateTests(tests), Level.generateAcceptor(tests), null, null, binary.on, tests);
			//Manufactoria.saveCustomLevels();
			Manufactoria.setGrid();
			Manufactoria.components = new Array();
			FlxG.state = new BuildState();
		}
		
		private function saveKongLevel():void {
			updateTest();
			renderForSave();
			FlxG.kong.API.sharedContent.save('Custom Level',
											 new Level(levelName.text, description.text, '', new UnlockRequirement(false), int(levelSize.text), Manufactoria.FULL_TOOLS,
												-1, Level.translateTests(tests), Level.generateAcceptor(tests), null, null, binary.on, tests),
											  onSaveFinished, renderForSave())
			render(); //to prevent messiness
		}
		
		private function onSaveFinished(params:Object):void {
			if (params.success) {
				FlxG.log("Level successfully published!");
			} else {
				FlxG.log("Level failed to publish!");
			}
		}
		
		private function renderForSave():DisplayObject {
			FlxG.buffer.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0xff000000);
			new FlxText(FlxG.width / 4, FlxG.height / 2, FlxG.width / 2, levelName.text).render();
			new FlxText(FlxG.width / 4, FlxG.height / 2 + 15, FlxG.width / 2, description.text).render();
			
			var croppedScreenshot:BitmapData = new BitmapData(FlxG.width / 2, 
															  FlxG.height / 2 , false);
			var croppedRegion:Rectangle = new Rectangle(FlxG.width / 4,
														FlxG.height / 2,
														FlxG.width / 2, FlxG.height / 2);
			croppedScreenshot.copyPixels(FlxG.buffer, croppedRegion, new Point(0, 0));
			return new Bitmap(croppedScreenshot);
		}
		
		protected static const IN:Boolean = false;
		protected static const OUT:Boolean = true;
		protected static const FILTER:Boolean = false;
		protected static const OUTPUT:Boolean = true;
		protected static const ACCEPT:Boolean = true;
		protected static const REJECT:Boolean = false;
	}

}