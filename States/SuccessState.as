package States 
{
	import Buttons.CustomButton;
	import Malevolence.MalevolenceState;
	import Malevolence.Malevobot;
	import org.flixel.*;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class SuccessState extends FlxState {
		[Embed(source = "/images/Backgrounds/success.png")] public static const background:Class;
		[Embed(source = "/images/UI/retry.png")] public static const retry:Class;
		[Embed(source = "/images/UI/share_button.png")] public static const share_png:Class;
		[Embed(source = "/images/UI/share_success.png")] public static const share_s_png:Class;
		
		private var shareButton:CustomButton;
		
		public function SuccessState() {
			add(new FlxSprite(0, 0, background));
			var title:FlxText = new FlxText(0, 4, 320, "Success!");
			title.size = 16;
			title.color = 0x216921;
			title.alignment = "center";
			add(title);
			
			if (!Manufactoria.overwrite) {
				var overwriteWarning:FlxText = new FlxText(3, 3, 100, "Saving off! Click the floppy-button to save.")
				overwriteWarning.color = 0xf03030;
				add(overwriteWarning);
			}
			
			var i:int;
			var totalTime:int = 0;
			var recordTime:int;
			
			if (FlxG.level < Manufactoria.CUSTOM_OFFSET) {
				if (!MalevolenceState.CHEATED) {
					var recordTicks:int = Manufactoria.timeRecords[FlxG.level];
					if (recordTicks < 0) recordTicks = Malevobot.TIMEOUT_TICKS; //historical thing
					
					var totalTrials:int = MalevolenceState.MALEVOLENCE_TRIALS;//(1 << ((FlxG.levels[FlxG.level] as Level).stringTestLength + 1)) - 1; //DOES NOT WORK
					var MT:int = MalevolenceState.MALEVOLENCE_TIME;
					var MT_AVG:Number = Number(int(MT * 100 / totalTrials)) / 100;
					var MT_SLOW:String = "'" + MalevolenceState.MALEVOLENCE_SLOWEST + "'";
					if (MalevolenceState.MALEVOLENCE_SLOWEST == '') MT_SLOW += " (THE EMPTY STRING)";
					var MT_SLOWTIME:String = renderTime((MalevolenceState.MALEVOLENCE_SLOTH - MT_AVG) * Manufactoria.GRID_SIZE / Robot.SPEED);
					
					var wallOfText:FlxText = new FlxText(8, 50, 140, "");
					add(wallOfText);
					
					if (MalevolenceState.MALEVOLENCE_TIME != Malevobot.TIMEOUT_TICKS) { //ran all tests
						wallOfText.text += "YOUR MACHINE TOOK " + MT + " TIME UNITS TO COMPLETE THE MALEVOLENCE ENGINE'S TRIALS, ";
						if (recordTicks) { //not your first attempt
							var recordAverage:Number = int(recordTicks * 100 / totalTrials) / 100;
							if (recordTicks == MT)
								wallOfText.text += "EXACTLY THE SAME AS ";
							else if (recordTicks < MT)
								wallOfText.text += (MT - recordTicks) + " MORE THAN ";
							else
								wallOfText.text += (recordTicks - MT) + " FEWER THAN ";
							wallOfText.text += "YOUR PREVIOUS BEST ATTEMPT. ";
						} else { //first attempt.
							var adjectives:Array = [" SERVICABLE", "N ADEQUATE", "N ACCEPTABLE", " TOLERABLE"];
							var adjective:String = adjectives[int(FlxU.random() * adjectives.length)];
							wallOfText.text += "A"+adjective+" FIRST ATTEMPT.";
						}
						wallOfText.text += "YOU AVERAGED " + MT_AVG + " TIME UNITS PER TEST, ";
						wallOfText.text += "THE SLOWEST BEING " + MT_SLOW + ", ";
						wallOfText.text += "AT " + MalevolenceState.MALEVOLENCE_SLOTH +" TIME UNITS - ";
						wallOfText.text += MT_SLOWTIME + " SLOWER THAN YOUR AVERAGE.";
						
						var importantThings:Array = ["SEES ALL", "GUARDS YOU FROM ERROR", "IS ALWAYS WATCHING", "ABHORS FALSEHOOD", "HATES CHEATS & LIARS", "NEVER SLEEPS", "EXISTS TO SERVE"];
						var toRemember:String = importantThings[int(FlxU.random() * importantThings.length)];
						var remember:FlxText = new FlxText(8, 173, 140, "REMEMBER: THE MALEVOLENCE ENGINE "+toRemember+".");
						remember.color = 0x400000;
						add(remember);
					} else { //timeout
						wallOfText.text += "YOUR MACHINE RAN FOR SO LONG THAT THE MALEVOLENCE ENGINE RAN OUT OF PATIENCE, "
						wallOfText.text += "GIVING UP ENTIRELY ON THE STRING '" + MalevolenceState.MALEVOLENCE_ENIGMA + "'. ";
						if (Manufactoria.componentRecords[FlxG.level]) { //beat the level before
							wallOfText.text += "THE MALEVOLENCE ENGINE IS DISAPPOINTED IN YOU. ";
						} else {
							wallOfText.text += "YOU COMPLETED THE PROBLEM ASSIGNED... BUT ";
						}
						wallOfText.text += "YOU CAN DO BETTER THAN THIS. ";
						
						wallOfText.text += "YOUR VERY MOST DISAPPOINTING TEST WAS " + MT_SLOW + ", ";
						wallOfText.text += "AT " + MalevolenceState.MALEVOLENCE_SLOTH +" TIME UNITS.";
					}
					
					totalTime = MT;
				} else { //Cheated.
					remember = new FlxText(8, 153, 140, "THE MALEVOLENCE ENGINE IS EXTREMELY DISAPPOINTED IN YOU.");
					remember.text += "\n\nCHEATER.";
					remember.color = 0x400000;
					add(remember);
					
					title.text = "'Success.'";
					
					add(new StateTransitionButton(191, 214, Manufactoria.levelEntry));
					if (!Manufactoria.overwrite)
						add(new StateTransitionButton(149, 214, OverwriteState));
					RunState.test = null;
					FlxG.stage.frameRate = 30;
					add(new AudioButton());
					add(new Tooltip());
					
					return;
				}
			} else {
				for (i = 0; i < RunState.times.length; i++) {
					var time:int = RunState.times[i];
					var y:int = 50 + 20 * i;
					
					add(new FlxText(10, y, 70, "Test " + i + ": " + renderTime(time)));
					
					recordTime = int.MAX_VALUE;
					
					var bestTimeText:FlxText = new FlxText(85, y, 70, "Best: " + (time < recordTime ? renderTime(time) : renderTime(recordTime)));
					bestTimeText.color = time < recordTime ? 0x30ff40 : time > recordTime ? 0xff4030 : 0xffffff;
					add(bestTimeText);
					
					totalTime += time;
				}
				
				add(new FlxText(5, 210, 100, "Total Time:  " + renderTime(totalTime)));
				
				var recordTotal:int = int.MAX_VALUE;
				var recordTotalTimeText:FlxText = new FlxText(5, 222, 100, "Best Time: " + (totalTime < recordTotal ? renderTime(totalTime) : renderTime(recordTotal)));
				recordTotalTimeText.color = totalTime < recordTotal ? 0x30ff40 : totalTime > recordTotal ? 0xff4030 : 0xffffff;
				add(recordTotalTimeText);
			}
			
			var partsByType:Array = new Array(0, 0, 0, 0, 0, 0, 0, 0, 0);
			var totalParts:int = 0;
			for (i = 0; i < Manufactoria.components.length; i++) {
				if (Manufactoria.components[i].exists) {
					partsByType[Manufactoria.COMPONENTS_BY_ID.indexOf(Manufactoria.components[i].identifier)] += 1;
					totalParts += 1;
				}
			}
			
			var Y:int = 50;
			for (i = 0; i < partsByType.length; i++)
				if (partsByType[i]) {
					add(new FlxText(175, Y, 100, TileComponent.PLURAL_NAMES[i] + ": " + partsByType[i]));
					Y += 20;
				}
			add(new FlxText(230, 210, 100, "Total Parts: " + totalParts));
			
			var recordParts:int;
			if (FlxG.level < Manufactoria.CUSTOM_OFFSET)
				recordParts = Manufactoria.componentRecords[FlxG.level];
			if (!recordParts)
				recordParts = int.MAX_VALUE;
			
			var recordPartsText:FlxText = new FlxText(230, 222, 100, "Fewest Parts: " + (totalParts < recordParts ? totalParts : recordParts));
			recordPartsText.color = totalParts < recordParts ? 0x30ff40 : totalParts > recordParts ? 0xff4030 : 0xffffff;
			add(recordPartsText);
			
			if (Manufactoria.overwrite && FlxG.level < Manufactoria.CUSTOM_OFFSET)
				Manufactoria.saveRecords(totalTime, totalParts);
			
			
			add(new StateTransitionButton(191, 214, Manufactoria.levelEntry));
			if (Manufactoria.unlocked[Manufactoria.PROTO2] == Manufactoria.BEATEN) {
				add(new StateTransitionButton(107, 214, RunState).modify(null, 'Re-run!', 'Run the machine again! Marvel at your prowess!'));
				//add(new StateTransitionButton(191, 214, BuildState).modify(retry, 'Retry!', 'Improve your machine! Maximize its efficiency!')); //141?
			}
			if (!Manufactoria.overwrite)
				add(new StateTransitionButton(149, 214, OverwriteState));
			else if (Manufactoria.KONG) {
				shareButton = new CustomButton(149, 214, share_png, kongShare, "Share level!", "Publish your solution to the widest depths of the Internets, for all to marvel at!");
				add(shareButton);
			}
			
			RunState.test = null;
			
			FlxG.stage.frameRate = 30;
			add(new AudioButton());
			add(new Tooltip());
		}
		
		public static function renderTime(time:int):String {
			var secs:int = time % 60;
			var secStr:String = secs < 10 ? "0" + secs : String(secs);
			//if (time < 60)
			//	return secStr;
			return int(time / 60) + ":" + secStr;
		}
		
		public static function proxySave():void {
			var recordTotal:int = Manufactoria.timeRecords[FlxG.level];
			if (!recordTotal)
				recordTotal = int.MAX_VALUE;
			Manufactoria.saveRecords((recordTotal < MalevolenceState.MALEVOLENCE_TIME) ? recordTotal : MalevolenceState.MALEVOLENCE_TIME,
									 Manufactoria.components.length);
		}
		
		
		
		private function kongShare():void {
			FlxG.log("Saving: " + SaveLoadState.outputString);
			FlxG.kong.API.sharedContent.save('Level', SaveLoadState.outputString, onSaveFinished, BuildState.renderForSave(), 'Level ' + FlxG.level + ' Solution')
			render(); //to prevent messiness
		}
		
		private function onSaveFinished(params:Object):void {
			if (params.success)
				shareButton.loadGraphic(share_s_png);
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
	}

}