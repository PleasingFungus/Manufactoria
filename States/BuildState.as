package States {
	import Buttons.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import Components.*;
	import Malevolence.MalevolenceState;

	public class BuildState extends FlxState {
		[Embed(source = "/images/Backgrounds/grid.png")] public static const UIBar_png:Class;
		
		[Embed(source = "/images/UI/x.png")] public static const x_cursor:Class;
		[Embed(source = "/images/UI/clenched_hand.png")] public static const clenched:Class;
		
		[Embed(source = "/images/UI/cw_button.png")] private static const cw_png:Class;
		[Embed(source = "/images/UI/ccw_button.png")] private static const ccw_png:Class;
		[Embed(source = "/images/UI/flip_button.png")] private static const flip_png:Class;
		
		
		protected static var midground:FlxGroup;
		protected var foreground:FlxGroup;
		
		protected var nameAndParts:FlxText;
		
		protected var source:Source;
		protected var destination:Destination;
		
		protected static var cursorState:int;
		public static var toolText:FlxText;
		
		protected var autosaveTimer:Number = 0;
		
		protected var cw_button:CustomButton;
		protected var ccw_button:CustomButton;
		protected var flip_button:CustomButton;
		override public function create():void {
			add(new FlxSprite(76, 0, UIBar_png));
			add(midground = new FlxGroup());
			add(foreground = new FlxGroup());
			
			FlxG.timeScale = 1;
			
			if (Manufactoria.savedLevels[FlxG.level] && Manufactoria.overwrite)
				SaveLoadState.load(Manufactoria.savedLevels[FlxG.level]);
			
			var tooltip:Tooltip = new Tooltip();
			
			var availableTools:int = FlxG.levels[FlxG.level].tools;
			BuildButton.reset();
			
			var gp:BuildButton, yp:BuildButton, gyp:BuildButton,
				bp:BuildButton, rp:BuildButton, brp:BuildButton,
			    belt:BuildButton, sel:SelectTool;
			
			belt = new BuildButton(2, 76, Manufactoria.BELT);
			midground.add(belt);
			
			if (Manufactoria.unlocked[Manufactoria.PROTO2] == Manufactoria.BEATEN) {
				sel = new SelectTool(29, 76);
				midground.add(sel);
			} else
				midground.add(new Hotkey(32, 97, 2, null));
			
			if (availableTools >= Manufactoria.BASIC_TOOLS) {
				brp = new BuildButton(55, 40, Manufactoria.BRPULL);
				midground.add(brp);
			} else
				midground.add(new Hotkey(58, 61, Manufactoria.BRPULL+1, null));
			
			if (availableTools == Manufactoria.WRITING_TOOLS || availableTools == Manufactoria.FULL_TOOLS) {
				bp = new BuildButton(2, 40, Manufactoria.BPUSH);
				rp = new BuildButton(29, 40, Manufactoria.RPUSH);
				midground.add(bp);
				midground.add(rp);
			} else {
				midground.add(new Hotkey(5, 61, Manufactoria.BPUSH + 1, null));
				midground.add(new Hotkey(32, 61, Manufactoria.RPUSH + 1, null));
			}
			
			if (availableTools == Manufactoria.COLOR_TOOLS || availableTools == Manufactoria.FULL_TOOLS) {
				gp = new BuildButton(2, 4, Manufactoria.GPUSH);
				yp = new BuildButton(29, 4, Manufactoria.YPUSH);
				midground.add(gp);
				midground.add(yp);
			} else {
				midground.add(new Hotkey(5, 25, Manufactoria.GPUSH + 1, null));
				midground.add(new Hotkey(32, 25, Manufactoria.YPUSH + 1, null));
			}
			if (availableTools == Manufactoria.FULL_TOOLS) {
				gyp = new BuildButton(55, 4, Manufactoria.GYPULL);
				midground.add(gyp);
			} else
				midground.add(new Hotkey(58, 25, Manufactoria.GYPULL + 1, null));
			//add(new Hotkey( -1, -1, 3, null));
			add(new GarbageButton(55, 76));
			add(new Hotkey( -1, -1, 0, null));
			
			add(tooltip);
			if (FlxG.level == Manufactoria.PROTO1 || FlxG.level == Manufactoria.PROTO2)
				add(new WASDHint());
			
			midground.add(new FlxText(3, 136, 70, FlxG.levels[FlxG.level].description));
			
			if (Manufactoria.unlocked[Manufactoria.PROTO1] == Manufactoria.BEATEN || Manufactoria.components.length >= 3)
				midground.add(new StateTransitionButton(3, 112, RunState));
			if (Manufactoria.unlocked[Manufactoria.PROTO2] == Manufactoria.BEATEN && FlxG.level < Manufactoria.CUSTOM_OFFSET) {
				var inputTransistion:StateTransitionButton = new StateTransitionButton(28, 112, InputState);
				inputTransistion.modify(StateTransitionButton.edit, "Input!", "Create your own set of input! Experiment with your machine!");
				midground.add(inputTransistion);
			}
			if (Manufactoria.unlocked[Manufactoria.PROTO1] == Manufactoria.BEATEN)
				midground.add(new StateTransitionButton(53, 112, SaveLoadState));
			midground.add(new StateTransitionButton(3, 215, HelpState));
			if (Manufactoria.unlocked[Manufactoria.PROTO2] == Manufactoria.BEATEN)
				midground.add(new StateTransitionButton(29, 215, ConfirmClear));
			
			if (Manufactoria.unlocked[Manufactoria.PROTO1] == Manufactoria.BEATEN )
				midground.add(new StateTransitionButton(54, 215, Manufactoria.levelEntry));
			
			midground.add(source = new Source(false));
			midground.add(destination = new Destination());
			foreground.add(new Overlay);
			if (!Manufactoria.overwrite) {
				var overwriteWarning:FlxText = new FlxText(80, 3, 240, "Saving DISABLED for this level.");
				overwriteWarning.color = 0xf03030;
				overwriteWarning.alignment = "center";
				foreground.add(overwriteWarning);
			} else {
				nameAndParts = new FlxText(80, 2, 240, FlxG.levels[FlxG.level].name.toUpperCase());
				nameAndParts.alignment = 'center';
				foreground.add(nameAndParts);
			}
			toolText = new FlxText(80, 225, 240, "Click or drag to delete components!");
			toolText.alignment = "center";
			foreground.add(toolText);
			
			foreground.add(cw_button = new CustomButton(79, 80, cw_png, null, "Rotate CW!", "Rotate the current selection clockwise by 90 degrees!"));
			foreground.add(flip_button = new CustomButton(79, 112, flip_png, null, "Flip!", "Flip the current selection horizontally!"));
			foreground.add(ccw_button = new CustomButton(79, 144, ccw_png, null, "Rotate CCW!", "Rotate the current selection counterclockwise by 90 degrees!"));
			
			if (Manufactoria.linkCode){
				SaveLoadState.load(Manufactoria.linkCode);
			}
			
			for (var i:int = 0; i < Manufactoria.components.length; i++)
				if (Manufactoria.components[i].exists) {
					Manufactoria.components[i] = TileComponent.regenerate(Manufactoria.components[i]);
					midground.add(Manufactoria.components[i]);
				}
			
			add(new AudioButton());
			
			RunState.test = null;
			MalevolenceState.MALEVOLENCE_TIME = 0;
			
			FlxG.stage.frameRate = 60;
			FlxG.mouse.show();
			cursorState = 0;
			updateCursor();
		}
		
		private function partsUsed():int {
			var p:int = 0;
			for each (var t:TileComponent in Manufactoria.components)
				if (t.exists)
					p += 1;
			return p;
		}
		
		override public function update():void {
			if (FlxG.mouse.justPressed()) {
				if (Manufactoria.xInGrid(FlxG.mouse.x) && Manufactoria.yInGrid(FlxG.mouse.y))
					gridClick();
				 else  //UI-click
					UIClick();
			} else if (FlxG.mouse.pressed() && Manufactoria.xInGrid(FlxG.mouse.x) && Manufactoria.yInGrid(FlxG.mouse.y))
				dragClick();
			
			if (!BuildButton.selectedButton && !SelectTool.selected && !Tooltip.tracker.moused)
				updateCursor();
			else if (SelectTool.selected && SelectTool.instance.dragging)
				checkRotate();
			
			autosaveTimer += FlxG.elapsed;
			if (autosaveTimer >= 15) { //10?
				Manufactoria.saveLevel();
				autosaveTimer = 0;
			}
			
			if (nameAndParts) {
				var r:int = Manufactoria.componentRecords[FlxG.level];
				nameAndParts.text = FlxG.levels[FlxG.level].name + ' Parts Placed: ' + partsUsed() + (r ? '; Best: ' + r : '');
			}
			
			super.update();
			Manufactoria.updateMusic();
		}
		
		protected function gridClick():void {
			if (SelectTool.selected) {
				SelectTool.instance.click();
				return;
			}
			
			var gridLoc:FlxPoint = Manufactoria.realToGrid(FlxG.mouse.x, FlxG.mouse.y);
			var gridIndex:int = Manufactoria.gridToArray(gridLoc);
			var previousOccupant:TileComponent = Manufactoria.grid[gridIndex];
			
			place(gridLoc, gridIndex, previousOccupant);
		}
		
		protected function place(gridLoc:FlxPoint, gridIndex:int, previousOccupant:TileComponent):void {
			if (previousOccupant && !previousOccupant.die()) //can't build on source, destination, etc
				return;
			
			if (BuildButton.selectedButton) {	//the 'placing' bit
				var newComponent:TileComponent = new Manufactoria.COMPONENT_TYPES[BuildButton.selectedButton.type](Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE),
																											 Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE),
																											 gridIndex, BuildButton.selectedButton.megafacing);
				Manufactoria.components.push(newComponent);
				midground.add(newComponent);
			
				if (Manufactoria.unlocked[Manufactoria.PROTO1] != Manufactoria.BEATEN && Manufactoria.components.length == 3 )
					midground.add(new StateTransitionButton(7, 110, RunState));
			}
		}
		
		protected function UIClick():void {
			if (BuildButton.selectedButton && Tooltip.tracker.moused != BuildButton.selectedButton) {
				if (Tooltip.tracker.moused == cw_button)
					BuildButton.selectedButton.rotateCW();
				else if (Tooltip.tracker.moused == ccw_button)
					BuildButton.selectedButton.rotateCCW();
				else if (Tooltip.tracker.moused == flip_button)
					BuildButton.selectedButton.flip();
				else
					BuildButton.setSelected(null);
			} else if (SelectTool.selected && !SelectTool.instance.moused &&
					   Tooltip.tracker.moused != cw_button && Tooltip.tracker.moused != ccw_button && Tooltip.tracker.moused != flip_button)
				SelectTool.instance.deselect();
		}
		
		protected function dragClick():void {
			if (SelectTool.selected) {
				SelectTool.instance.clickDrag();
				return;
			} else if (!BuildButton.selectedButton) {
				dragDelete();
				return;
			} else if (BuildButton.selectedButton.type != Manufactoria.BELT)
				return;
			
			var gridLoc:FlxPoint = Manufactoria.realToGrid(FlxG.mouse.x, FlxG.mouse.y);
			var gridIndex:int = Manufactoria.gridToArray(gridLoc);
			
			var occupant:TileComponent = Manufactoria.grid[gridIndex];
			
			if (occupant &&
				((Manufactoria.COMPONENTS_BY_ID.indexOf(occupant.identifier) == Manufactoria.BELT && occupant.facing == BuildButton.selectedButton.facing)
				|| !occupant.die()))
				return;
			
			place(gridLoc, gridIndex, null);
		}
		
		public static function updateCursor():void {
			if (cursorState == SUPER_CLENCHED)
				return;
			
			if (!Manufactoria.xInGrid(FlxG.mouse.x) || !Manufactoria.yInGrid(FlxG.mouse.y)) {
				setCursorState(ARROW_CURSOR);
				return;
			}
			
			var occupant:TileComponent = Manufactoria.gridOccupant(FlxG.mouse.x, FlxG.mouse.y);
			if (occupant && occupant.identifier != "Source" && occupant.identifier != "Destination")
				setCursorState(X_CURSOR);
			else
				setCursorState(ARROW_CURSOR);
		}
		
		public static function setCursorState(newState:int):void {
			if (cursorState != newState) {
				FlxG.mouse.load(cursors[newState], cursors_offX[newState], cursors_offY[newState])
				cursorState = newState;
			}
		}
		
		public static function resetCursorState():void {
			FlxG.mouse.load(null);
			cursorState = ARROW_CURSOR;
			updateCursor();
		}
		
		protected function checkRotate():void {
			var t:SelectTool = SelectTool.instance
			if (cw_button.moused) {
				if (t.rotateTimer > 0)
					t.rotateTimer -= FlxG.elapsed / FlxG.timeScale; //?
				else {
					t.rotateCW();
					t.rotateTimer = .8;
				}
			} else if (ccw_button.moused) {
				if (t.rotateTimer > 0)
					t.rotateTimer -= FlxG.elapsed / FlxG.timeScale; //?
				else {
					t.rotateCCW();
					t.rotateTimer = .8;
				}
			} else if (flip_button.moused) {
				if (t.rotateTimer > 0)
					t.rotateTimer -= FlxG.elapsed / FlxG.timeScale; //?
				else {
					t.flip();
					t.rotateTimer = .8;
				}
			}
		}
		
		protected function dragDelete():void {
			var occupant:TileComponent = Manufactoria.gridOccupant(FlxG.mouse.x, FlxG.mouse.y);
			if (occupant)
				occupant.die();
		}
		
		
		public static function addToMid(o:FlxObject):void {
			midground.add(o);
		}
		
		public static function toolPermitted(component:TileComponent):Boolean {
			var availableTools:int = FlxG.levels[FlxG.level].tools;
			return ((component is ConveyorBelt || component is ConveyorBridge)
				|| (component is BlueRedPuller && availableTools >= Manufactoria.BASIC_TOOLS)
				|| ((component is BluePusher || component is RedPusher) && (availableTools == Manufactoria.WRITING_TOOLS || availableTools == Manufactoria.FULL_TOOLS))
				|| ((component is GreenPusher || component is YellowPusher) && availableTools >= Manufactoria.COLOR_TOOLS)
				|| (availableTools >= Manufactoria.FULL_TOOLS));
			var toolType:Class = Manufactoria.COMPONENT_TYPES[Manufactoria.COMPONENTS_BY_ID.indexOf(componentType)];
		}

		public static function renderForSave():DisplayObject {
			var bg:FlxSprite = new FlxSprite(76, 0, UIBar_png);
			bg.render();
			(new Source(false)).render();
			(new Destination()).render();
			for (var i:int = 0; i < Manufactoria.components.length; i++)
				TileComponent.regenerate(Manufactoria.components[i]).render();
			//new Overlay().render();
			
			var croppedScreenshot:BitmapData = new BitmapData(Manufactoria.GRID_DIM * Manufactoria.GRID_SIZE + 1,
															  Manufactoria.GRID_DIM * Manufactoria.GRID_SIZE + 1, false);
			var croppedRegion:Rectangle = new Rectangle(79 + Manufactoria.inv_offset * Manufactoria.GRID_SIZE,
														Manufactoria.inv_offset * Manufactoria.GRID_SIZE - 1,
														croppedScreenshot.width, croppedScreenshot.height);
			croppedScreenshot.copyPixels(FlxG.buffer, croppedRegion, new Point(0, 0));
			return new Bitmap(croppedScreenshot);
		}
		
		
		public static const ARROW_CURSOR:int = 0;
		public static const X_CURSOR:int = 1;
		public static const SUPER_CLENCHED:int = 2;
		
		public static const cursors:Array = new Array(null, x_cursor, clenched);
		public static const cursors_offX:Array = new Array(0, 5, 2);
		public static const cursors_offY:Array = new Array(0, 5, 4);
	}
}

