package

{

	import org.flixel.*;
	import Components.*;
	import org.flixel.data.FlxKong;
	import States.*;
	import Buttons.AudioButton;
	import flash.events.Event;
	import TapeEngine.BinaryHelper;
	//import QueryString;

	[SWF(width="640", height="480", backgroundColor="#000000")]

	[Frame(factoryClass = "Preloader")]
	
	public class Manufactoria extends FlxGame {
		[Embed(source = "/music/TRUNC.mp3")] private static const MUSIC:Class; //Shostakovich_VS
		private static var music_timer:Number;
		
		public static var components:Array;
		public static var grid:Array;
		public static var GRID_DIM:int;
		public static var grid_offset:int;
		public static var inv_offset:int;
		
		public static var buttonLayout:Array;
		public static var levelsByName:Array;
		
		public static var save:FlxSave = new FlxSave();
		public static var unlocked:Array;
		public static var savedLevels:Array;
		public static var linkCode:String = null;
		public static var overwrite:Boolean = true;
		
		public static var timeRecords:Array;
		public static var componentRecords:Array;
		
		public static var OFFLINE:Boolean = false;
		public static const KONG:Boolean = false;
		public static const ALL_UNLOCKED:Boolean = false;
		public static const VERSION:String = "1.30l";
		public static var KONG_INIT:Boolean = false;
		
		public static var _self:Manufactoria;
		
		public static var levelEntry:Class = MenuState; //state to go back to, from the level
		
		public function Manufactoria() {
			var levels:Array = loadLevels();
			
			if (save.bind("Manufactoria")) {
				unlocked = save.data.unlocked ? save.data.unlocked : new Array(CUSTOM_OFFSET);
				
				if (!unlocked[PROTO1]) unlocked[PROTO1] = UNLOCKED;
				if (unlocked[BONUS_OFFSET] == BEATEN && !unlocked[BONUS_OFFSET + 1]) unlocked[BONUS_OFFSET + 1] = UNLOCKED; //TODO: remove?
				if (unlocked[BONUS_OFFSET + 1] == BEATEN && !unlocked[BONUS_OFFSET + 2]) unlocked[BONUS_OFFSET + 2] = UNLOCKED; //TODO: likewise
				
				savedLevels = save.data.levels ? save.data.levels : new Array(levels.length);
				IntroState.viewedScenes = save.data.scenes ? save.data.scenes : new Array(6);
				loadCustomLevels(levels, save.data.custom);  //CUSTOM CUSTOM CUSTOM
				loadRecords(save.data.time, save.data.components);
				compensateForVersion(save.data.version);
			} else {
				unlocked = new Array(CUSTOM_OFFSET);
				savedLevels = new Array(levels.length);
				IntroState.viewedScenes = new Array(6);
				loadRecords(null, null);
			}
			
			components = new Array();
			
			var level:int = loadFromURL(levels)
			var initialState:Class;
			if (level >= 0 && levels[level]) {
				initialState = BuildState;
				setGrid(levels[level].dimensions);
			} else if (unlocked[PROTO2])
				initialState = MenuState;
			else {
				initialState = IntroState;
				level = PROTO1;
			}
			
			super(320, 240, initialState, 2);
			FlxState.bgColor = 0xffa1a1a1;
			useDefaultHotKeys = false;
			//pause = new ManuPause();
			if (save.data.volume != null) FlxG.volume = save.data.volume;
			if (save.data.mute != null) FlxG.mute = save.data.mute// (save.data.mute == 'm');
			_self = this; //hax
			
			FlxG.levels = levels;
			FlxG.level = level;
			updateUnlocked();
			
			//addEventListener(Event.CLOSE, onExit);
		}
		
		private function test(e:Event = null):void {
			FlxG.log('woo');
		}
		
		public static function setGrid(dim:int = 0):void {
			GRID_DIM = dim ? dim : FlxG.levels[FlxG.level].dimensions;
			grid = new Array(GRID_DIM * GRID_DIM);
			grid_offset = GRID_DIM / 2;
			inv_offset = 7 - grid_offset;
		}
		
		protected function loadLevels():Array {
			var i:int;
			
			var levels:Array = new Array();
			levels.push(new Level(  "Robotoast!",
									"ACCEPT: Move robots from the entrance (top) to the exit (bottom)!",
									"You put bread in. With a click, heat begins to build. Then - a sound - motion - fresh toast! ROBO-TOAST. 49.99.",
									new UnlockRequirement(false),
									5, PROTO_TOOLS,
									12, ['brb'],
									function _toast_(input:String, output:String):Boolean { return output != 'x' } ));
			levels.push(new Level(	"Robocoffee!",
									"If a robot's string starts with blue, accept. Otherwise, reject!",
									"Coffee - ambrosia - the 'water of life.' But - so hard to make! WORRY NO MORE. Robo Coffee: Never Sleep Again.",
									new UnlockRequirement(true, 'Robotoast!'),
									5, BASIC_TOOLS,
									12, ['br', 'rb'],
									function _coffee_(input:String, output:String):Boolean {
										return ((input.length && (input.charAt(0) == 'b')) == (output != 'x'))
									} ));
			levels.push(new Level(	"Robolamp!",
									"ACCEPT: if there are three or more blues!",
									"Our hi-tech 'lavalamps' will sense your mood, glowing and moving as you think! 'Creepy'? Try 'incredible!'",
									new UnlockRequirement(true, "Robocoffee!"),
									7, BASIC_TOOLS,
									12, ['rrrrrrrbbb', 'rrrrrrrrbb'],
									function _lampAcc_(input:String, output:String):Boolean {
										var blues:int = 0;
										for (var j:int = 0; blues < 3 && j < input.length; j++)
											blues += input.charAt(j) == 'b';
										return (blues < 3) == (output == 'x');
									} ));
			
			levels.push(new Level(	"Robofish!",
									"ACCEPT: if a robot contains NO red!",
									"Robot fish! Sold with ten amazing pre-programmed swim patterns, and almost always waterproofed!",
									new UnlockRequirement(true, "Robolamp!"),
									5, BASIC_TOOLS,
									12, ['bbbbbbbbbb', 'bbbbbbbbrb'],
									function _fishAcc_(input:String, output:String):Boolean {
										return (input.indexOf('r') == -1) == (output != 'x');
									} ));
			levels.push(new Level(	"Robobugs!",
									"ACCEPT: if the tape has only alternating colors!",
									"Robot flies! Ever thought, 'if I could be a fly on that wall?' Well, YOU can't - but these are the next best thing!",
									new UnlockRequirement(true, "Robofish!"),
									9, BASIC_TOOLS,
									12, ['brbrbrbrbrbr','brbrbrbrbbrr'],
									function _bugAcc_(input:String, output:String):Boolean {
										if (input.length < 2)
											return output != 'x';
										var currentChar:String = input.charAt(0);
										for (var j:int = 1; j < input.length; j++)
											if (input.charAt(j) == currentChar)
												return output == 'x';
											else
												currentChar = input.charAt(j);
										return output != 'x';
									} ));
			levels.push(new Level(	"Robocats!",
									"ACCEPT: if the tape ends with two blues!",
									"Robot kitties! Their lustrous fur is 100% authentic - each strand taken from the back of a real kitten, just for you!",
									new UnlockRequirement(true, "Robobugs!"),
									9, BASIC_TOOLS,
									12, ['brbrrbrrb', 'brbrbrrbb'],
									function _catAcc_(input:String, output:String):Boolean {
										//FlxG.log(input.length +", " + input.charAt(input.length - 1) + ", " + input.charAt(input.length - 2));
										return (input.length >= 2 && input.charAt(input.length - 1) == 'b' && input.charAt(input.length - 2) == 'b') == (output != 'x');
									} ));
			levels.push(new Level(	"Robobears!",
									"ACCEPT: Strings that begin and end with the same color!",	//kinda easy, but still maybe OK
									"Enormous metal polar bears! They like to catch fish, even though they can't eat any. It's disarming! Then they eat you.",
									new UnlockRequirement(true, "Robocats!"),
									9, BASIC_TOOLS,
									12, ['brbrrrbrrrbrb', 'brbrrrbrrrbbr'],
									function _acc_(input:String, output:String):Boolean {
										//FlxG.log(input.length +", " + input.charAt(input.length - 1) + ", " + input.charAt(input.length - 2));
										return (input.length < 2 || input.charAt(input.length - 1) == input.charAt(0)) == (output != 'x');
									} ));
			
			levels.push(new Level(	"RC Cars!",
									"OUTPUT: The input, but with the first symbol at the end!",
									"They go 'vroom'! They're remote controlled! The best and last robo-toy your child will ever want!",
									new UnlockRequirement(true, "Robolamp!"),
									5, WRITING_TOOLS,
									12, ['brbrbbbrb'],
									null,
									function _out_(input:String):String {
										return input.slice(1) + input.charAt(0);
									} ));
			levels.push(new Level(	"Robocars!",
									"OUTPUT: Replace blue with green, and red with yellow!",
									"Robot-driven cars! Now, when you enjoy a glass or two of port on the way to work, you needn't feel guilty about it!",
									new UnlockRequirement(true, "RC Cars!"),
									7, COLOR_TOOLS,
									12, ['rbrbrrrb'],
									null,
									function _out_(input:String):String {
										var output:String = '';
										for (var j:int = 0; j < input.length; j++)
											output += input.charAt(j) == 'b' ? 'g' : 'y';
										return output;
									} ));
			levels.push(new Level(	"Robostilts!",
									"OUTPUT: Put a green at the beginning, and a yellow at the end!",
									"Want to tower above your fellow man? Of course you do! But you're probably afraid of falling. Well - FEAR NO LONGER!",
									new UnlockRequirement(true, "Robocars!"),
									9, FULL_TOOLS,
									10, ['rrbrbrbbr'],
									null,
									function _out_(input:String):String { return 'g' + input + 'y'; } ));
			
			levels.push(new Level( "Milidogs!",
									"ACCEPT: With blue as 1 and red as 0, accept odd binary strings!",
									"Our first defense contract: robot dogs! They sniff out the enemy with their mechani-noses, and then - well!",
									new UnlockRequirement(true, "Robocats!"),
									7, BASIC_TOOLS,
									12, ['brrrrbrb', 'brrrrbbr'],
									function _acc_(input:String, output:String):Boolean {
										return (input.charAt(input.length - 1) == 'b') == (output != 'x');
									},
									null, Level.binaryMalevoTest,
									true));
			
			levels.push(new Level( "Soldiers!",
									"OUTPUT: With blue as 1 and red as 0, multiply by 8!",
									"Robot soldiers! Plated with armor, bristling with weapons, and ready to send the Reds all the way back to Moscow!",
									new UnlockRequirement(true, "Androids!,Milidogs!"), //should really be "RC Cars!,Soldiers!", but that messes with the graph like nothing else
									9, WRITING_TOOLS,
									12, ['rbrbbrbr'],
									null,
									function _out_(input:String):String { return input + 'rrr'; },
									Level.binaryMalevoTest,
									true));
			levels.push(new Level( "Officers!",
									"OUTPUT: With blue as 1 and red as 0, add 1 to the binary string!",
									"Robotic officers serve in the newly formed Metal Regiments, commanding by radio-wave with uncanny speed!",
									new UnlockRequirement(true, "Soldiers!"),
									13, FULL_TOOLS,
									9, ['brrbrbbbb'],
									null,
									function _out_(input:String):String {
										var binary:Array = BinaryHelper.toBinary(input);
										binary[0] += 1;
										return BinaryHelper.fromBinary(binary);
									}, Level.binaryMalevoTest, true));
			levels.push(new Level( "Generals!", //UNTESTED
									"OUTPUT: Subtract 1 from the binary string! (Input >= 1)",
									"Robot generals analyze their goals and optimize, without human limits. They are literally unbeatable.",
									new UnlockRequirement(true, "Officers!"),
									13, FULL_TOOLS,
									9, ['brrbrbbbb'],
									null,
									function _out_(input:String):String {
										var binary:Array = BinaryHelper.toBinary(input);
										binary[0] -= 1;
										return BinaryHelper.fromBinary(binary);
									}, Level.gt0MalevoTest, true));
			
			levels.push(new Level( "Robotanks!",
									"ACCEPT: With blue as 1 and red as 0, accept binary strings > 15!",
									"Robotic armor! Rated 30% cheaper than human-crewed equivalents, and nearly 60% better at crushing foes!",
									//"Robot pilots! Rated for: 30 Gs, up to 5 minutes. No O2, up to 1 hour. Bombing peasants: until the sun goes down!",
									new UnlockRequirement(true, "Milidogs!"),
									11, BASIC_TOOLS,
									9, ['rrrrrbbbb', 'rrrrbbbbr'],
									function _acc_(input:String, output:String):Boolean {
										return (BinaryHelper.toBinary(input)[0] > 15) == (output != 'x');
									}, null, Level.binaryMalevoTest,
									true));
			levels.push(new Level( "Robospies!",
									"ACCEPT: With blue as 1 and red as 0, accept natural powers of four!",
									"Designation: HUM/ELINT primary infiltration/investigation asset. Further details: classified.",
									new UnlockRequirement(true, "Androids!,Robotanks!"),
									9, FULL_TOOLS,
									12, ['brrrrrrrr', 'brrrrrbrr'],
									function _acc_(input:String, output:String):Boolean {
										var significantBlue:int = input.indexOf('b');
										if (significantBlue == -1) return output == 'x';
										
										for (var j:int = significantBlue + 1; j < input.length; j++)
											if (input.charAt(j) != 'r') return output == 'x';
										
										return ((j - (significantBlue + 1)) % 2 == 0) == (output != 'x');
									},
									null, Level.binaryMalevoTest,
									true));
			
			
			levels.push(new Level( "Androids!",
									"ACCEPT: Some number of blue, then the same number of red!",
									"Robots in the shape of men - and with minds to match! A breakthrough like none before!",
									new UnlockRequirement(true, "Robocats!,Robostilts!"),
									9, FULL_TOOLS,
									12, ['bbbbrrrr', 'bbbbrrr'],
									function _acc_(input:String, output:String):Boolean {
										/*if (input == "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"
											|| input == "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
											trace(input, output);*/
										
										if (input.length % 2 == 1) //odd!
											return output == 'x';
										for (var j:int = 0; j < input.length / 2; j++)
											if (input.charAt(j) != 'b')
												return output == 'x';
										for (; j < input.length; j++)
											if (input.charAt(j) != 'r')
												return output == 'x';
										
										return output != 'x';
									} ));
			
			
			levels.push(new Level( "Robo-children!",
									"ACCEPT: An equal number of blue and red, in any order!",
									"These robo-scamps are guaranteed to brighten your life, even without use of their vast, glowing eyes!",
									new UnlockRequirement(true, "Androids!"),
									11, FULL_TOOLS,
									12, ['rrbbbrbr', 'bbrrbrr'],
									function _acc_(input:String, output:String):Boolean {
										var balance:int = 0;
										for (var j:int = 0; j < input.length; j++)
											balance += input.charAt(j) == 'b' ? 1 : -1;
										/*if (input == "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"
											|| input == "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
											trace(input, output);*/
										return (balance == 0) == (output != 'x');
									} ));
			
			levels.push(new Level(	"Police!",
									"OUTPUT: Put a yellow in the middle of the (even-length) string!",
									"Overwhelmed by rampant crime? Upgrade your police force! Robo Cops: They Only Shoot People Who Really Deserve It.",
									new UnlockRequirement(true, "Androids!"),
									13, FULL_TOOLS,
									10, ['rbbbrrbr'],
									null,
									function _out_(input:String):String {
										return input.slice(0,input.length/2) + 'y' + input.slice(input.length/2, input.length);
									}, Level.evenMalevoTest ));
			levels.push(new Level(	"Judiciary!",
									"ACCEPT: (Even-length) strings that repeat midway through!",
									"Robotic judges! Completely incorruptible, and utterly infallible! You'll never need HUMAN justices again!",
									new UnlockRequirement(true, "Police!"),
									13, FULL_TOOLS,
									10, ['bbbrbbbr', 'rbbbrb'],
									function _acc_(input:String, output:String):Boolean {
										return (input.slice(0,input.length/2) == input.slice(input.length/2, input.length)) == (output != 'x');
									}, null, Level.evenMalevoTest ));
			
			levels.push(new Level( "Teachers!",
									"ACCEPT: X blue, then X red, then X more blue, for any X!",
									//"Robots in the shape of women! Suitable for cooking, cleaning, secretarial work, or computer programming.",
									"Classes taught by robot teachers have, on average, 68% higher standardized test scores. They're simply superior!",
									new UnlockRequirement(true, "Androids!"),
									13, FULL_TOOLS,
									12, ['bbrrbb', 'bbbrrrbb'],
									function _acc_(input:String, output:String):Boolean {
										if (input.length % 3) return output == 'x';
										
										for (var j:int = 0; j < input.length / 3; j++)
											if (input.charAt(j) == 'r') return output == 'x';
										for (; j < input.length * 2 / 3; j++)
											if (input.charAt(j) == 'b') return output == 'x';
										for (; j < input.length; j++)
											if (input.charAt(j) == 'r') return output == 'x';
										
										return output != 'x';
									} ));
			levels.push(new Level(	"Politicians!",
									"ACCEPT: If there are exactly twice as many blues as red!",
									"Robo-politicians: built so carefully, test models have replaced their targets with a detection rate below 1%!",
									new UnlockRequirement(true, "Teachers!"),
									13, FULL_TOOLS,
									12, ['rbbrbr', 'bbbrbrb'],
									function _acc_(input:String, output:String):Boolean {
										var red:int = 0;
										var blue:int = 0;
										for (var j:int = 0; j < input.length; j++) {
											var char:String = input.charAt(j);
											if (char == 'b') blue++;
											else red++;
										}
										return ((red << 1) == blue) == (output != 'x');
									} ));
			levels.push(new Level( "Academics!",
									"OUTPUT: Reverse the input string!",
									"Robot professors! The robot race can now debate Derrida, satire Socrates, and control the academic world!",
									new UnlockRequirement(true, "Teachers!"),
									13, FULL_TOOLS,
									9, ['rrrrbbbb'],
									null,
									function _out_(input:String):String { return input.split("").reverse().join(""); } ));
			levels.push(new Level(	"Engineers!",
									"ACCEPT: Perfectly symmetrical strings!",
									"Robot engineers. Designed to build testing machines.\n\nHarmless.",
									new UnlockRequirement(true, "Academics!"),
									13, FULL_TOOLS,
									9, ['brbrb', 'rrbrbrbr'],
									function _acc_(input:String, output:String):Boolean {
										return (input.split("").reverse().join("") == input) == (output != 'x');
									} ));
			
			levels.push(new Level(	"Roborockets!",
									"OUTPUT: Swap blue for red, and red for blue!",
									"Guided by a clever robotic navigation capsule, these rockets can carry nearly thirty tons of cargo into low Earth orbit!",
									new UnlockRequirement(true, "Robostilts!"),
									7, FULL_TOOLS,
									12, ['bbrbrr'],
									null,
									function _out_(input:String):String {
										var output:String = '';
										for (var j:int = 0; j < input.length; j++)
											output += (input.charAt(j) == 'b') ? 'r' : 'b';
										return output;
									} ));
			levels.push(new Level(	"Roboplanes!",
									"OUTPUT: All of the blue, but none of the red!",
									"Using new, advanced 'jet engines', our automated planes will take you from here to there in half the time!",
									new UnlockRequirement(true, "Robostilts!"),
									7, FULL_TOOLS,
									9, ['rrbrrbbbr'],
									null,
									function _out_(input:String):String {
										var output:String = '';
										for (var j:int = 0; j < input.length; j++)
											if (input.charAt(j) == 'b')
												output += 'b';
										return output;
									} ));
			levels.push(new Level( "Rocket Planes!",
									"OUTPUT: The input, but with all blues moved to the front!",
									"'The earth is the cradle of the mind - but one cannot live forever in a cradle.' Man's devices sojourn out to the stars.",
									new UnlockRequirement(true, "Roborockets!,Roboplanes!"),
									9, FULL_TOOLS,
									9, ['rbrbrbrrbr'],
									null,
									function _out_(input:String):String {
										var output:String = '';
										for (var j:int = 0; j < input.length; j++)
											if (input.charAt(j) == 'b')
												output = 'b' + output;
											else
												output += 'r';
										return output;
									} ));
			
			levels.push(new Level(	"Robomecha!",
									"OUTPUT: The input, but with the last symbol moved to the front!",	//also kinda easy
									"Stilts are fine. But what's better - robot STILTS, or a GIANT WALKING ROBOT SUIT? We think you already know!",
									new UnlockRequirement(true, "Robostilts!"),
									11, FULL_TOOLS,
									12, ['rrrbbrb'],
									null,
									function _out_(input:String):String {
										return input.charAt(input.length - 1) + input.slice(0, input.length - 1);
									} ));
			
			BONUS_OFFSET = levels.length;
			
			levels.push(new Level(	"Seraphim",
									"ACCEPT: Two identical strings, separated by a green!",
									" - ",
									new UnlockRequirement(true, "Engineers!"),
									11, FULL_TOOLS,
									9, ['brrgrbr', 'rbbgbrb'],
									function _acc_(input:String, output:String):Boolean {
										var mid:int = input.indexOf('g');
										return (input.slice(0,mid) == input.slice(mid + 1, input.length)) == (output != 'x');
									}, null, Level.multiMalevoTest));
			levels.push(new Level(	"Ophanim",
									"ACCEPT: Read the tape as two numbers, A and B, split by a green: accept if A>B!",
									" -- ",
									new UnlockRequirement(true, "Seraphim"),
									13, FULL_TOOLS,
									6, ['bbrgbrb', 'brrgbrb'],
									function _acc_(input:String, output:String):Boolean {
										var A:int = BinaryHelper.toBinary(input.slice(0,input.indexOf('g')))[0];
										var B:int = BinaryHelper.toBinary(input.slice(input.indexOf('g') + 1))[0];
										return (A > B) == (output != 'x');
									}, null, Level.multiMalevoTest, true));
			levels.push(new Level(	"Metatron",
									"OUTPUT: Read the tape as two numbers, A and B, split by a green: output A + B!",
									" ---- ",
									new UnlockRequirement(true, "Ophanim"),
									13, FULL_TOOLS,
									6, ['bbgbr'],
									null,
									function _out_(input:String):String {
										var mid:int = input.indexOf('g');
										var A:int = BinaryHelper.toBinary(input.slice(0,mid))[0];
										var B:int = BinaryHelper.toBinary(input.slice(mid + 1, input.length))[0];
										return BinaryHelper.fromBinary([A + B, 0]);
									}, Level.multiMalevoTest, true));
			
			CUSTOM_OFFSET = levels.length; //tack new levels on after the end
			levelsByName = new Array();
			for (i = 0; i < levels.length; i++) {
				levelsByName[levels[i].name] = i;
			}
			FINAL_LEVEL = levelsByName["Engineers!"];
			
			buttonLayout = new Array();
			unlocked = new Array(levels.length);
			
			var row:Array;
			var finished:Boolean = false;
			while (!finished) {
				for (i = 0; i < BONUS_OFFSET; i++) {
					if (!unlocked[i] && levels[i].unlock.unlocked())
						unlocked[i] = UNLOCKED;
				}
				
				row = new Array();
				finished = true;
				
				for (i = 0; i < BONUS_OFFSET; i++)
					if (unlocked[i] == UNLOCKED) {
						unlocked[i] = BEATEN;
						row.push(i);
						finished = false;
					}
				if (!finished)
					buttonLayout.push(row);
			}
			
			return levels;
		}
		
		protected function loadCustomLevels(levels:Array, custom:Array):void {  //CUSTOM CUSTOM CUSTOM
			if (custom == null) {
				return;
			}
			
			for (var i:int = 0; i < CUSTOM_MAX; i++) {
				levels[CUSTOM_OFFSET + i] = Level.fromString(custom[i]);
			}
		}
		
		private static function loadRecords(savedTime:Array, savedComponents:Array):void {
			if (savedTime == null || savedTime[0] is Array) {
				timeRecords = new Array(CUSTOM_OFFSET);
				savedComponents = null; //hax
			} else
				timeRecords = savedTime;
			
			if (savedComponents == null)
				componentRecords = new Array(CUSTOM_OFFSET);
			else
				componentRecords = savedComponents;
		}
		
		public static function saveCustomLevels(levels:Array = null):void {
			if (!levels)
				levels = FlxG.levels;
			
			var customs:Array = levels.slice(CUSTOM_OFFSET)
			for (var i:int = 0; i < CUSTOM_MAX; i++) {
				if (customs[i])
					customs[i] = customs[i].toString();
				else
					customs[i] = '';
			}
			save.write("custom", customs);
		}
		
		private function compensateForVersion(oldVersion:String):void {
			if (oldVersion == VERSION || !oldVersion)
				return;
			
			var versionNumber:int = int(oldVersion.substr(2, 2));
			if (versionNumber < 15) {
				loadRecords(null, null); //fresh start!
			}
			
			save.write("version", VERSION); //don't ever repeat!
		}
		
		protected function loadFromURL(levels:Array):int {
			var path:QueryString = new QueryString();
			var level:int = Number(path._params["lvl"]); //1 to LEVEL_COUNT
			if (level > 0 && level <= CUSTOM_OFFSET && unlocked[level-1]) {
				linkCode = path._params["code"];
				overwrite = false;
				return level - 1;
			} else if (path._params["ctm"]) { //CUSTOM CUSTOM CUSTOM
				var customIndex:int = LevelSelectState.loadNewCustom(path._params["ctm"], levels);
				if (customIndex > -1) {
					linkCode = path._params["code"];
					Manufactoria.levelEntry = LevelSelectState;
					return customIndex;
				}
			}
			
			return -1;
		}
		
		public static function onKongLoad(e:Event):void {
			FlxG.kong.API.sharedContent.addLoadListener('Level', SaveLoadState.onLoadKongLevel);
			FlxG.kong.API.sharedContent.addLoadListener('Custom Level', LevelSelectState.onLoadKongCustom);
		}
		
		public static function onLoadKongCustom(e:Event):void {
			FlxG.log("Hello!");
		}
		
		override protected function onFocusLost(event:Event = null):void { } //Don't pause when alt-tabbed!
		override protected function onFocus(event:Event = null):void { } //Haha - and don't unpause.
		
		public static function get totalUnlocked():int {
			var total:int = 0;
			for (var i:int = 0; i < unlocked.length; i++) if (unlocked[i] == BEATEN) total++;
			return total;
		}
		
		public static function updateUnlocked():void {
			for (var i:int = 0; i < CUSTOM_OFFSET; i++) {
				if (!unlocked[i] && FlxG.levels[i].unlock.unlocked())
					unlocked[i] = UNLOCKED;
			}
			if (KONG && FlxG.kong && FlxG.kong.API) {
				var kongStatsArray:Array = [];
				//kongStatsArray["LevelsBeaten"] = totalUnlocked;
				kongStatsArray.push( { name:"LevelsBeaten", value:totalUnlocked } );
				//kongStatsArray["GameBeaten"] = unlocked[FINAL_LEVEL] == BEATEN;
				kongStatsArray.push( { name:"GameBeaten", value:(unlocked[FINAL_LEVEL] == BEATEN) } );
				//kongStatsArray["BonusLevelsBeaten"] = unlocked[BONUS_OFFSET + 2] == BEATEN;
				kongStatsArray.push( { name:"BonusLevelsBeaten", value:(unlocked[BONUS_OFFSET + 2] == BEATEN) } );
				//kongStatsArray["GameComplete"] = totalUnlocked == CUSTOM_OFFSET;
				kongStatsArray.push( { name:"GameComplete", value:(totalUnlocked >= CUSTOM_OFFSET) } );
				FlxG.kong.API.stats.submitArray(kongStatsArray);
			}
			save.write("unlocked", unlocked);
		}
		
		public static function saveLevel():void {
			//autosave
			save.write("mute", FlxG.mute);
			save.write("volume", FlxG.volume);
			save.write("version", VERSION);
			
			if (!overwrite || FlxG.level == -1)
				return;
			
			savedLevels[FlxG.level] = SaveLoadState.levelString;
			save.write("levels", savedLevels);
		}
		
		public static function saveRecords(totalTime:int, componentTally:int):void {
			FlxG.log("Saving records!");
			
			if (!timeRecords[FlxG.level] || timeRecords[FlxG.level] > totalTime)
				timeRecords[FlxG.level] = totalTime;
			if (!componentRecords[FlxG.level] || componentRecords[FlxG.level] > componentTally)
				componentRecords[FlxG.level] = componentTally;
			
			save.write("time", timeRecords);
			save.write("components", componentRecords);
			
			if (KONG && FlxG.kong && FlxG.kong.API && totalUnlocked >= CUSTOM_OFFSET) {
				FlxG.log("Uploading to Kongregate!");
				
				var timeSum:int = 0;
				for (var i:int = 0; i < CUSTOM_OFFSET && timeSum != int.MAX_VALUE; i++)
					timeSum = timeRecords[i] ? timeSum + timeRecords[i] : int.MAX_VALUE;
				if (timeSum == int.MAX_VALUE) {
					FlxG.log("Invalid time record at index: " + (i - 1));
					return;
				}
				
				var partsSum:int = 0;
				for (i = 0; i < CUSTOM_OFFSET && partsSum != int.MAX_VALUE; i++)
					partsSum = componentRecords[i] ? partsSum + componentRecords[i] : int.MAX_VALUE;
				if (partsSum == int.MAX_VALUE) {
					FlxG.log("Invalid parts record at index: " + (i - 1));
					return;
				}
				
				var kongStatsArray:Array = [];
				//kongStatsArray["Parts Used"] = partsSum;
				kongStatsArray.push( { name:"Parts Used", value:partsSum } );
				//kongStatsArray["Level Times"] = timeSum;
				kongStatsArray.push( { name:"Level Times", value:timeSum } );
				FlxG.kong.API.stats.submitArray(kongStatsArray);
			}
		}
		
		public static function reset():void {
			unlocked = new Array(Manufactoria.CUSTOM_OFFSET);
			unlocked[PROTO1] = UNLOCKED;
			savedLevels = new Array(FlxG.levels.length);
			IntroState.viewedScenes = new Array(IntroState.viewedScenes.length);
			loadRecords(null, null);
			
			save.write("unlocked", unlocked);
			save.write("levels", savedLevels);
			save.write("scenes", IntroState.viewedScenes);
			save.write("time", timeRecords);
			save.write("components", componentRecords);
		}
		
		
		
		
		
		public static function gridOccupant(X:int, Y:int):TileComponent {
			return grid[gridToArray(realToGrid(X, Y))];
		}
		
		public static function realToGrid(x:int, y:int):FlxPoint {
			return new FlxPoint(Math.floor((x - 80) / GRID_SIZE - inv_offset),
							 Math.floor(y / GRID_SIZE) - inv_offset);
		}
		
		public static function gridToArray(p:FlxPoint):int {
			return p.y * GRID_DIM + p.x;
		}
		
		public static function xInGrid(x:Number):Boolean {
			return x >= 80 + inv_offset * GRID_SIZE && x < 200 + GRID_DIM * GRID_SIZE / 2;
		}
		
		public static function yInGrid(y:Number):Boolean {
			return y >= inv_offset * GRID_SIZE && y < 120 + GRID_DIM * GRID_SIZE / 2;
		}
		
		
		public static function updateMusic():void {
			/*if ((FlxG.mute || !FlxG.volume) && FlxG.music && FlxG.music.playing)
				FlxG.music.pause();
			else if ((!FlxG.mute && FlxG.volume) && FlxG.music && !FlxG.music.playing)
				FlxG.music.fadeIn(1);
			else */
			if (FlxG.keys.justPressed('ZERO') && !(FlxG.state is BuildState)) {
				FlxG.mute = !FlxG.mute;
				_self.showSoundTray();
				if (AudioButton.instance)
					AudioButton.instance.refresh();
			} else if (FlxG.keys.justReleased('MINUS')) {
				FlxG.mute = false;
				FlxG.volume = FlxG.volume - 0.1;
				_self.showSoundTray();
				if (AudioButton.instance)
					AudioButton.instance.refresh();
			} else if (FlxG.keys.justReleased('PLUS')) {
				FlxG.mute = false;
				FlxG.volume = FlxG.volume + 0.1;
				_self.showSoundTray();
				if (AudioButton.instance)
					AudioButton.instance.refresh();
			} //else if (FlxG.keys.justReleased("P"))
				//FlxG.pause = !FlxG.pause;
			
			if (/*!OFFLINE && */!FlxG.mute && FlxG.volume) {
				if (!FlxG.music) {
					/*try {
						FlxG.music = new FlxSound().loadStream(MUSIC[0]);
					} catch (_:Event) { OFFLINE = true; } */
					music_timer = 60; //seconds
					FlxG.music = new FlxSound().loadEmbedded(MUSIC);
					FlxG.music.volume = .6;
					FlxG.music.survive = true;
					FlxG.music.play();
				} else if (!FlxG.music.playing) {
					music_timer -= FlxG.elapsed / FlxG.timeScale;
					if (music_timer <= 0)
						FlxG.music.play();
					/*music_index = (++music_index) % MUSIC.length;
					try {
						FlxG.music.loadStream(MUSIC[music_index]).play();
					} catch (_:Event) { OFFLINE = true; } */
				}
			}
			
		}
		
		/*private function onExit(_:Event):void {
			trace("roru");
			saveLevel();
		}
		*/
		
		
		public static const LOCKED:int = 0;
		public static const UNLOCKED:int = 1;
		public static const BEATEN:int = 2;
		
		public static const PROTO1:int = 0;
		public static const PROTO2:int = 1;
		public static var FINAL_LEVEL:int;
		public static var BONUS_OFFSET:int;
		public static var CUSTOM_OFFSET:int;
		public static var CUSTOM_MAX:int = 32;
		
		public static const BELT:int = 0;
		public static const BPUSH:int = 3;
		public static const RPUSH:int = 4;
		public static const BRPULL:int = 5;
		public static const GPUSH:int = 6;
		public static const YPUSH:int = 7;
		public static const GYPULL:int = 8;
		
		public static const PROTO_TOOLS:int = -1;
		public static const BASIC_TOOLS:int = 0;
		public static const WRITING_TOOLS:int = 1;
		public static const COLOR_TOOLS:int = 2;
		public static const FULL_TOOLS:int = 3;
		
		public static const GRID_SIZE:int = 16;
		
		public static const COMPONENT_TYPES:Array = new Array(  ConveyorBelt, ConveyorBridge, null,
																BluePusher, RedPusher, BlueRedPuller,
																GreenPusher, YellowPusher, GreenYellowPuller);
		public static const WRITTEN_NUMBERS:Array = new Array(	"ZERO",
																"ONE", "TWO", "THREE",
																"FOUR", "FIVE", "SIX",
																"SEVEN", "EIGHT", "NINE");
		public static const COMPONENTS_BY_ID:Array = new Array(	'c', 'i', null,
																'b', 'r', 'p',
																'g', 'y', 'q');
		public static const CONTROL_TIPS:Array = new Array(  "Click or drag to place; shift-click to bridge!", "Bridge!", "Garbage!",
																"Click to place!", "Click to place!", "Click to place; space to flip!",
																"Click to place!", "Click to place!", "Click to place; space to flip!");
		/*public static const MENU_STATE:int = 0;
		public static const BUILD_STATE:int = 1;
		public static const MENU_STATE:int = 2;
		public static const MENU_STATE:int = 3;
		public static const MENU_STATE:int = 4;
		public static const MENU_STATE:int = 5;
		public static const STATES:Array = new Array(MenuState, BuildState, HelpState, RunState, SaveLoadState, CreditsState); */
	}

}

