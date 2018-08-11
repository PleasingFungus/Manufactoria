package Buttons 
{
	import Buttons.Button;
	import org.flixel.*;
	import States.BuildState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class SelectTool extends Button implements HotkeyButton {
		[Embed(source = "/images/UI/selection_box.png")] private static const activeBox:Class;
		[Embed(source = "/images/UI/nonselection_box.png")] private static const inactiveBox:Class;
		[Embed(source = "/images/UI/select_cursor.png")] private static const cursor_sprite:Class;
		[Embed(source = "/images/UI/move_sprite.png")] private static const arrow_sprite:Class;
		[Embed(source = "/images/UI/select_icon.png")] private static const icon_sprite:Class;
		
		public static var selected:Boolean;
		public static var instance:SelectTool;
		public static const HOTKEY:int = 2;
		protected var icon:FlxSprite;
		
		protected var selectionOrigin:FlxPoint;
		protected var selectionBox:FlxSprite;
		
		protected var selectionGroup:FlxGroup;
		protected var selectionOffset:FlxPoint;
		
		protected static var clipboard:Array;
		
		protected var cursorState:Boolean;
		protected var justRotated:Boolean;
		public var rotateTimer:Number;
		
		public function SelectTool(X:int, Y:int) {
			super(X, Y, inactiveBox);
			
			FlxG.state.add(icon = new FlxSprite(X + 2, Y + 2, icon_sprite));
			selectionBox = new FlxSprite( -10, -10);
			
			FlxG.state.add(new Hotkey(X + 3, Y + 21, HOTKEY, this));
			SelectTool.selected = false;
			instance = this; 
		}
		
		public function select():void {
			SelectTool.selected = true;
			Tooltip.tracker.resetTime();
			BuildState.toolText.text = "Drag to select & move! A&D rotate, space flips!";
			
			FlxG.mouse.load(cursor_sprite, 8, 8);
			loadGraphic(activeBox);
			icon.exists = false;
		}
		
		public function deselect():void {
			SelectTool.selected = false;
			BuildState.resetCursorState();
			selectionBox.exists = false;
			if (selectionGroup)
				placeSelection();
			loadGraphic(inactiveBox);
			icon.exists = true;
		}
		
		public function get selected():Boolean {
			return SelectTool.selected;
		}
		
		override public function update():void {
			var i:int;
			
			if (!BuildButton.selectedButton && !selected) {
				if (moused) {
					BuildState.setCursorState(BuildState.SUPER_CLENCHED);
				} else if (Tooltip.tracker.moused == this && !moused)
					BuildState.resetCursorState();
			}
			
			super.update();
			
			if (FlxG.keys.justPressed("DELETE") && selectionBox && selectionBox.visible && selectionBox.exists && !selectionGroup) {
				var sel:Array = findSelection();
				for (i = 0; i < sel.length; i++)
					sel[i].die();
			}
			
			if ((FlxG.keys.justPressed("V") && FlxG.keys.SHIFT) || (FlxG.keys.justPressed("SHIFT") && FlxG.keys.V))
				paste(clipboard);
			
			if (selected) {
				if ((FlxG.keys.justPressed("C") && FlxG.keys.SHIFT) || (FlxG.keys.justPressed("SHIFT") && FlxG.keys.C))
					copy(findSelection());
				
				if (selectionGroup) { //draggin' stuff around!
					if (FlxG.mouse.justReleased())// && !justRotated)
						placeSelection();
					else {
						var offset:FlxPoint = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE - selectionOffset.x,
														   Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE - selectionOffset.y);
						if (offset.x != selectionGroup.x || offset.y != selectionGroup.y)
							for (i = 0; i < selectionGroup.members.length; i++) {
								var component:TileComponent = selectionGroup.members[i];
								component.move(component.x + offset.x - selectionGroup.x,
											   component.y + offset.y - selectionGroup.y);
								//component.visible = Manufactoria.xInGrid(component.x) && Manufactoria.yInGrid(component.y);
							}
						selectionGroup.x = offset.x;
						selectionGroup.y = offset.y;
						
						if (FlxG.keys.justPressed("A") || FlxG.keys.justPressed("LEFT") || FlxG.mouse.scrollingUp())
							rotateCW();
						else if (FlxG.keys.justPressed("D") || FlxG.keys.justPressed("RIGHT") || FlxG.mouse.scrollingDown())
							rotateCCW(); 
						else if (FlxG.keys.justPressed("SPACE"))
							flip();
					}
				} else if (!FlxG.mouse.pressed()) {
					if (cursorState == SELECT_CURSOR && selectionBox.exists && selectionBox.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) {
						FlxG.mouse.load(arrow_sprite, 8, 8);
						cursorState = MOVE_CURSOR;
					} else if (cursorState == MOVE_CURSOR && (!selectionBox.exists || !selectionBox.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))) {
						FlxG.mouse.load(cursor_sprite, 8, 8);
						cursorState = SELECT_CURSOR;
					}
				}
			} else if (justClicked)
				select();
			justRotated = false;
		}
		
		public function rotateCW():void {
			var gridMouse:FlxPoint = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE,
												  Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE);
			var offset:FlxPoint = gridMouse;
			
			for (var i:int = 0; i < selectionGroup.members.length; i++) {
				var component:TileComponent = selectionGroup.members[i];
				var oX:int = component.x;
				var oY:int = component.y;
				component.move( -(oY - offset.y) + offset.x,
								oX - offset.x + offset.y);
				component.turnCW();
			}
			justRotated = true;
		}
		
		public function rotateCCW():void {
			var gridMouse:FlxPoint = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE,
												  Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE);
			var offset:FlxPoint = gridMouse;
			
			for (var i:int = 0; i < selectionGroup.members.length; i++) {
				var component:TileComponent = selectionGroup.members[i];
				var oX:int = component.x;
				var oY:int = component.y;
				component.move( oY - offset.y + offset.x,
								-(oX - offset.x) + offset.y);
				component.turnCCW();
			}
			justRotated = true;
		}
		
		public function flip():void {
			var gridMouse:FlxPoint = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE,
												  Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE);
			var offset:FlxPoint = gridMouse;
			
			for (var i:int = 0; i < selectionGroup.members.length; i++) {
				var component:TileComponent = selectionGroup.members[i];
				var oX:int = component.x;
				var oY:int = component.y;
				component.move( -(oX - offset.x) + offset.x,
								oY);
				component.hmirror();
			}
			justRotated = true;
		}
		
		public function click():void {
			if (selectionGroup) return;
			
			var oldBox:FlxSprite = selectionBox;
			if (cursorState == SELECT_CURSOR) {
				selectionOrigin = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE,
											   Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE);
				selectionBox = new FlxSprite();
				selectionBox.visible = false;
				FlxG.state.add(selectionBox);
			} else {
				selectionOffset = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE,
											   Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE);
				
				var sel:Array = findSelection();
				selectionGroup = new FlxGroup();
				for (var i:int = 0; i < sel.length; i++) {
					var occupant:TileComponent = sel[i].unclip();
					if (occupant) { //might be source or dest otherwise
						Manufactoria.grid[occupant.gridIndex] = null;
						selectionGroup.add(occupant);
					}
				}
				
				selectionGroup.alpha = .6;
				
				FlxG.state.add(selectionGroup);
			}
			oldBox.exists = false; //cleanup!
		}
		
		public function clickDrag():void {
			if (cursorState == SELECT_CURSOR && !selectionGroup)
				dragSelection();
		}
		
		private function dragSelection():void {
			var rawPoint:FlxPoint = new FlxPoint(FlxG.mouse.x / Manufactoria.GRID_SIZE, FlxG.mouse.y / Manufactoria.GRID_SIZE);
			var mousedX:int = (FlxG.mouse.x < selectionOrigin.x ?  Math.floor(rawPoint.x) : Math.ceil(rawPoint.x)) * Manufactoria.GRID_SIZE;
			var mousedY:int = (FlxG.mouse.y < selectionOrigin.y ?  Math.floor(rawPoint.y) : Math.ceil(rawPoint.y)) * Manufactoria.GRID_SIZE;
			
			if ((mousedX != selectionBox.x && mousedX != selectionBox.x + selectionBox.width) || 
				(mousedY != selectionBox.y && mousedY != selectionBox.y + selectionBox.height)) {
					//if (FlxG.mouse.x < selectionBox.x - Manufactoria.GRID_SIZE) mousedX -= Manufactoria.GRID_SIZE;
					//if (FlxG.mouse.y < selectionBox.y - Manufactoria.GRID_SIZE) mousedY -= Manufactoria.GRID_SIZE;
					
					if (mousedX < selectionOrigin.x) {
						selectionBox.x = mousedX;
						selectionBox.width = selectionOrigin.x + Manufactoria.GRID_SIZE - mousedX;
					} else {
						selectionBox.x = selectionOrigin.x;
						selectionBox.width = mousedX - selectionOrigin.x;
					}
					
					if (mousedY < selectionOrigin.y) {
						selectionBox.y = mousedY;
						selectionBox.height = selectionOrigin.y + Manufactoria.GRID_SIZE - mousedY;
					} else {
						selectionBox.y = selectionOrigin.y;
						selectionBox.height = mousedY - selectionOrigin.y;
					}
					
					//FlxG.log(mousedX + ", " + mousedY + " - " + selectionOrigin.x + ", " + selectionOrigin.y +" - " +selectionBox.width +", " + selectionBox.height);
					
					if (selectionBox.width > 0 && selectionBox.height > 0) {
						selectionBox.createGraphic(selectionBox.width, selectionBox.height, 0x80808080);
						selectionBox.visible = true;
					} else {
						selectionBox.visible = false;
					}
				}
		}
		
		
		
		
		protected function findSelection():Array {
			if (!selectionBox.visible || !selectionBox.exists)
				return null;
			
			var sel:Array = new Array();//(selectionBox.width / Manufactoria.GRID_SIZE) * (selectionBox.height / Manufactoria.GRID_SIZE));
			for (var X:int = selectionBox.x; X < selectionBox.x + selectionBox.width; X += Manufactoria.GRID_SIZE) {
				for (var Y:int = selectionBox.y; Y < selectionBox.y + selectionBox.height; Y += Manufactoria.GRID_SIZE) {
					var occupant:TileComponent = Manufactoria.gridOccupant(X, Y);
					if (occupant)
						sel.push(occupant);
				}
			}
			return sel;
		}
		
		protected function placeSelection():void {
			for (var i:int = 0; i < selectionGroup.members.length; i++) {
				var component:TileComponent = selectionGroup.members[i];
				if (Manufactoria.xInGrid(component.x) && Manufactoria.yInGrid(component.y)) {
					var gridIndex:int = Manufactoria.gridToArray(Manufactoria.realToGrid(component.x, component.y));
					var occupant:TileComponent = Manufactoria.grid[gridIndex];
					if (!occupant || occupant.die()) {
						component.gridIndex = gridIndex;
						component = TileComponent.regenerate(component);
						//component.alpha = 1;
						BuildState.addToMid(component);
						//Manufactoria.grid[gridIndex] = component;
						Manufactoria.components.push(component);
					}
				}
			}
			selectionGroup.exists = false;
			selectionGroup = null;
			
			/*selectionBox = new FlxSprite(selectionGroup.members[0].x, selectionGroup.members[0].y).createGraphic(selectionGroup.members[selectionGroup.members.length - 1].x - selectionGroup.members[0].x + Manufactoria.GRID_SIZE,
																												 selectionGroup.members[selectionGroup.members.length - 1].y - selectionGroup.members[0].y + Manufactoria.GRID_SIZE,
																												 0x80808080);
			FlxG.state.add(selectionBox); */ 
		}
		
		protected function copy(toCopy:Array):void {
			//FlxG.log("Copying: "+toCopy);
			var clipboard:Array = new Array();
			for (var i:int = 0; i < toCopy.length; i++) {
				var copy:TileComponent = TileComponent.regenerate(toCopy[i]);
				if (copy) {
					Manufactoria.grid[copy.gridIndex] = toCopy[i]; //bloody side-effects
					clipboard.push(copy);
				}
			}
			
			if (clipboard.length) { //actually copied something!
				selectionBox.exists = selectionBox.visible = false;
				SelectTool.clipboard = clipboard;
			}
		}
		
		protected function paste(toPaste:Array):void {
			if (!toPaste || !toPaste.length)
				return;
			
			selectionGroup = new FlxGroup();
			var maxX:int = -1;
			var maxY:int = -1;
			var minX:int = 10000;
			var minY:int = 10000;
			for (var i:int = 0; i < toPaste.length; i++) {
				var component:TileComponent = toPaste[i];
				
				if (BuildState.toolPermitted(component)) {
					if (component.x < minX) minX = component.x;
					if (component.x > maxX) maxX = component.x;
					if (component.y < minY) minY = component.y;
					if (component.y > maxY) maxY = component.y;
					
					selectionGroup.add(component);
				} else {
					FlxG.log("Impermissible: " + component);
				}
			}
			if (!selectionGroup.members.length)
				return;
			
			selectionOffset = new FlxPoint(Math.floor(FlxG.mouse.x / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE,
										   Math.floor(FlxG.mouse.y / Manufactoria.GRID_SIZE) * Manufactoria.GRID_SIZE);
			var centerpoint:FlxPoint = new FlxPoint(Math.floor((maxX + minX) / (2 * Manufactoria.GRID_SIZE)) * Manufactoria.GRID_SIZE,
													Math.floor((maxY + minY) / (2 * Manufactoria.GRID_SIZE)) * Manufactoria.GRID_SIZE);
			//FlxG.log(selectionOffset.x + ", " + selectionOffset.y + " - " + centerpoint.x + ", " + centerpoint.y +" - " + minX +", "  + minY +", " + maxX +", " + maxY +", ");
			for (i = 0; i < selectionGroup.members.length; i++) {
				component = selectionGroup.members[i];
				component.move(component.x + selectionOffset.x - centerpoint.x,
							   component.y + selectionOffset.y - centerpoint.y);
				//component.move(component.x + 16, component.y + 16);
				//component.visible = Manufactoria.xInGrid(component.x) && Manufactoria.yInGrid(component.y);
			}
			//FlxG.log("In paste-group: " + selectionGroup.members);
			
			selectionGroup.alpha = .6;
			FlxG.state.add(selectionGroup);
			
			if (!selected)
				select();
		}
		
		override public function getDescription(verbose:Boolean):String {
			return verbose ? "Select groups of pieces! Drag them around, copy them, and paste them!" : "Select!";
		}
		
		public function get dragging():Boolean {
			return selectionGroup != null;
		}
		
		public static const SELECT_CURSOR:Boolean = false;
		public static const MOVE_CURSOR:Boolean = true;
	}
}