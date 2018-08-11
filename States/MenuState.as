package States

{

	import org.flixel.*;
	import org.flixel.data.FlxKong;
	import Buttons.*;
	import Malevolence.MalevolenceState;
	
    import flash.display.Bitmap;
    import flash.geom.Point;
    import flash.display.Shape;



	public class MenuState extends FlxState {
		
		[Embed(source = "/images/Backgrounds/Manufactoria.png")] public static const title:Class;
		
		[Embed(source = "/images/UI/reset_button.png")] public static const r_png:Class;
		[Embed(source = "/images/UI/share_button.png")] public static const browse_png:Class;
		
		protected var reset:CustomButton;
		protected var resetArmed:Boolean = false;
		
		private static var levelText:FlxText;
		private static var levelDescription:FlxText;
		private static var levelTime:FlxText;
		private static var levelParts:FlxText;
		public static var mousedLevel:int = -1;
		
		override public function create():void {
			
			add(new FlxSprite(8, 4, title));
			add(new StateTransitionButton(90, 40, TabState));//IntroState));
			add(new StateTransitionButton(140, 40, LevelSelectState).modify(null, "Level Editor!", "Make new levels! Edit old ones!"));
			if (Manufactoria.KONG && Manufactoria.totalUnlocked >= Manufactoria.CUSTOM_OFFSET)
				add(new CustomButton(190, 40, browse_png, browse, "Browse levels!", "Browse solutions for all levels!"));
			add(new StateTransitionButton(240, 40, ConfirmReset));
			add(new StateTransitionButton(290, 40, CreditsState));
			
			deployButtons();
			
			add(levelText = new FlxText(5, 70, 260, " "));
			levelText.size = 16;
			add(levelTime = new FlxText(5, 95, 100, " "));
			add(levelParts = new FlxText(5, 115, 100, " "));
			add(levelDescription = new FlxText(5, 165, 95, " "));
			var version:FlxText = new FlxText(0, 225, 320, "v"+Manufactoria.VERSION+"!");
			version.alignment = "right";
			add(version);
			
			if (FlxG.level != -1 && Manufactoria.overwrite && Manufactoria.components.length) //popped in from a previous level
				Manufactoria.saveLevel();
			FlxG.level = -1;
			Manufactoria.linkCode = null;
			Manufactoria.overwrite = true;
			MalevolenceState.MALEVOLENCE_TIME = 0;
			
			if (FlxG.music && !FlxG.music.playing && FlxG.volume && !FlxG.mute)
				FlxG.music.play();
			
			add(new AudioButton());
			add(new Tooltip());
			
			Manufactoria.levelEntry = MenuState;
			FlxG.stage.frameRate = 30;
			FlxG.mouse.show();
		}
		
		protected function deployButtons():void {
			//for (var i:int = 0; i < FlxG.levels.length; i++)
			//	add(new MenuButton(i));
			var lineLayer:FlxGroup = new FlxGroup();
			var buttonLayer:FlxGroup = new FlxGroup();
			add(lineLayer);
			add(buttonLayer);
			var buttonsByLevel:Array = new Array();
			
			var cols:Array = Manufactoria.buttonLayout;
			var col:Array;
			var icon_dim:int = 19;
			
			var col_separation:Number = (320 - cols.length * icon_dim) / (cols.length + 1);
			for (var i:int = 0; i < cols.length; i++) {
				col = cols[i];
				var x:int = i * icon_dim + (i + 1) * col_separation;
				var row_separation:Number = (160 - col.length * icon_dim) / (col.length + 1);
				for (var j:int = 0; j < col.length; j++) {
					var y:int = j * icon_dim + (j + 1) * row_separation + 70;
					var level:int = col[j];
			/*var rows:Array = Manufactoria.buttonLayout;
			var row:Array;
			
			var icon_height:int = 19;
			var icon_width:int = 19;
			var row_space:Number = (160 - rows.length * icon_height) / rows.length; 
			for (var i:int = 0; i < rows.length; i++) {
				row = rows[i];
				var col_space:Number = (320 - row.length * icon_width) / (row.length + 1);
				for (var j:int = 0; j < row.length; j++) {
					var x:int = j * icon_width + (j + 1) * col_space;
					var y:int = i * icon_height + (i + 1) * row_space + 70;
					var level:int = row[j]; */
					buttonLayer.add(buttonsByLevel[level] = new LevelButton(x, y, level));
					
					if (FlxG.levels[level].unlock.hasParents) {
						var parents:Array = FlxG.levels[level].unlock.parents;
						var core:FlxPoint = new FlxPoint(x + icon_dim / 2, y + icon_dim / 2);
						for (var p:int = 0; p < parents.length; p++) {
							var parentLevel:int = Manufactoria.levelsByName[parents[p]];
							var parent:LevelButton = buttonsByLevel[parentLevel];
							var parentCenter:FlxPoint = new FlxPoint(parent.x + icon_dim / 2, parent.y + icon_dim / 2);
							lineLayer.add(new Line(core, parentCenter, 3,
												   Manufactoria.unlocked[parentLevel] == Manufactoria.BEATEN ? 0xff36f036 : 0xffcfcfcf));
						}
					}
				}
			}
			
			//add secret levels?
			if (Manufactoria.unlocked[Manufactoria.BONUS_OFFSET])
				for (level = Manufactoria.BONUS_OFFSET; level < Manufactoria.CUSTOM_OFFSET; level++) {
					x = 104 + (level - Manufactoria.BONUS_OFFSET) * (col_separation + icon_dim);
					y = 204;
					buttonLayer.add(buttonsByLevel[level] = new LevelButton(x, y, level));
					if (level > Manufactoria.BONUS_OFFSET) {
						core = new FlxPoint(x + icon_dim / 2, y + icon_dim / 2);
						parent = buttonsByLevel[level - 1];
						parentCenter = new FlxPoint(parent.x + icon_dim / 2, parent.y + icon_dim / 2);
						lineLayer.add(new Line(core, parentCenter, 3,
												   Manufactoria.unlocked[level - 1] == Manufactoria.BEATEN ? 0xff36f036 : 0xffcfcfcf));
					}
				}
		}
		
		public static function mouseLevel(level:int):void {
			mousedLevel = level;
			if (level == -1)
				levelDescription.text = levelTime.text = levelParts.text = levelText.text = ' ';
			else {
				levelText.text = FlxG.levels[level].name;
				levelDescription.text = FlxG.levels[level].fluff;
				if (Manufactoria.unlocked[level] == Manufactoria.BEATEN) {
					var bestTime:int = Manufactoria.timeRecords[level];
					var timeText:String;
					if (!bestTime || bestTime == int.MAX_VALUE)
						timeText = "(no record)";
					else
						timeText = SuccessState.renderTime(bestTime);
					levelTime.text = "Best time: " + timeText;
					
					var fewestParts:int = Manufactoria.componentRecords[level];
					var partsText:String = fewestParts ? String(fewestParts) : "(no record)";
					levelParts.text = "Fewest parts: " + partsText;
				} else {
					levelTime.text = " ";
					levelParts.text = " ";
				}
			}
		}
		
		public static function demouseLevel(level:int):void {
			if (mousedLevel == level) 
				levelDescription.text = levelTime.text = levelParts.text = levelText.text = ' ';
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
			if (Manufactoria.KONG && !Manufactoria.KONG_INIT) {
				if(!FlxG.kong) (FlxG.kong = parent.addChild(new FlxKong(Manufactoria.onKongLoad)) as FlxKong).init();
				Manufactoria.KONG_INIT = true;
			}
		}
		
		private function browse():void {
			FlxG.kong.API.sharedContent.browse('Level');
		}
	}

}

