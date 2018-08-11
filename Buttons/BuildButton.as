package Buttons
{
	import org.flixel.*
	import Components.*;
	import States.BuildState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class BuildButton extends Button implements HotkeyButton {
		[Embed(source = "/images/UI/selection_box.png")] public static const activeBox:Class;
		[Embed(source = "/images/UI/nonselection_box.png")] public static const inactiveBox:Class;
		
		public var type:int;
		protected var component:FlxSprite;
		protected var _selected:Boolean;
		
		public function BuildButton(X:int, Y:int, childType:int)  {
			super(X, Y, inactiveBox);
			type = childType;
		
			FlxG.state.add(component = new FlxSprite(X + 2, Y + 2));
			loadComponent();
			
			FlxG.state.add(new Hotkey(X + 3, Y + 21, childType + 1, this));
			_selected = false;
			
			byClass[Manufactoria.COMPONENT_TYPES[childType]] = this;
		}
		
		protected function loadComponent():void {
			if (type == Manufactoria.BELT) {
				component.loadGraphic(ConveyorBelt.pngs[facing], true, false, 15, 15);
			} else {
				if ((type == Manufactoria.BRPULL && BlueRedPuller.flipped) || (type == Manufactoria.GYPULL && GreenYellowPuller.flipped))
					component.loadRotatedGraphic(Manufactoria.COMPONENT_TYPES[type].png_flip, 4);
				else
					component.loadRotatedGraphic(Manufactoria.COMPONENT_TYPES[type].png, 4);
				component.angle = facing * 90;
			}
		}
		
		public function select():void {
			loadGraphic(activeBox);
			if (selectedButton)
				facing = selectedButton.facing;
			activateComponent();
			Tooltip.tracker.resetTime();
			BuildState.toolText.text = Manufactoria.CONTROL_TIPS[type];
			
			_selected = true;
			selectedButton = this;
		}
		
		public function deselect():void {
			loadGraphic(inactiveBox);
			revertComponent();
			_selected = false;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		
		protected function activateComponent():void {
			FlxG.mouse.cursor = component;
			loadComponent();
			component.offset.x = component.offset.y = 8;
		}
		
		protected function revertComponent():void {
			BuildState.resetCursorState();
			
			loadComponent();
			component.x = x + 2;
			component.y = y + 2;
			
			component.offset.x = component.offset.y = 0;
			component.facing = LEFT;
			component.visible = true;
		}
		
		override public function update():void {
			if (!exists)
				return;
			
			if (!selectedButton && !SelectTool.selected) {
				if (moused) {
					BuildState.setCursorState(BuildState.SUPER_CLENCHED);
				} else if (Tooltip.tracker.moused == this && !moused)
					BuildState.resetCursorState();
			}
			
			super.update();
			
			if (selectedButton == this) {
				if (FlxG.mouse.scrollingDown()) {
					facing = (facing + 3) % 4;
					loadComponent();
				} else if (FlxG.mouse.scrollingUp()) {
					facing = (facing + 1) % 4;
					loadComponent();
				} else
					for (var i:int = 0; i < DIRECTION_KEYS.length; i++)
						if (FlxG.keys.justPressed(DIRECTION_KEYS[i]) || FlxG.keys.justPressed(CURSOR_KEYS[i])) { //|| FlxG.keys.justPressed(NUM_KEYS[i])) {
							facing = i;
							loadComponent();
						}
					
				
				if (FlxG.keys.justReleased("SPACE")) {
					switch(type) {
						//case Manufactoria.BPUSH: setSelected(RedPusher); FlxG.log("b!"); break;
						//case Manufactoria.RPUSH: setSelected(GreenPusher); FlxG.log("r!"); break;
						case Manufactoria.BRPULL: BlueRedPuller.flip(); break;
						//case Manufactoria.GPUSH: setSelected(YellowPusher); FlxG.log("g!"); break;
						//case Manufactoria.YPUSH: setSelected(BluePusher); FlxG.log("y!"); break;
						case Manufactoria.GYPULL: GreenYellowPuller.flip(); break;
					} 
				}
			} else if (justClicked) {
				select();
			}
		}
		
		public function rotateCW():void {
			facing = (facing + 1) % 4
			loadComponent();
		}
		
		public function rotateCCW():void {
			facing = (facing + 3) % 4
			loadComponent();
		}
		
		public function flip():void {
			if (type == Manufactoria.BRPULL) 
				BlueRedPuller.flip();
			else if (type == Manufactoria.GYPULL)
				GreenYellowPuller.flip();
			else
				facing = (facing + 2) % 4;
			loadComponent();
		}
		
		public function get megafacing():int {
			var face:int = facing;
			if ((type == Manufactoria.BRPULL && BlueRedPuller.flipped) || (type == Manufactoria.GYPULL && GreenYellowPuller.flipped))
				face += 4;
			return face;
		}
		
		override public function getDescription(verbose:Boolean):String {
			var description:String = TileComponent.NAMES[type];
			if (verbose) description += ": " + TileComponent.DESCRIPTIONS[type];
			return description;
		}
		
		public static function setSelected(newselectedButton:Class):void {
			if (newselectedButton) {
				if (byClass[newselectedButton]) {
					///var oldSelected:BuildButton = selectedButton;
					byClass[newselectedButton].select();
					//oldSelected.deselect();
				} else
					FlxG.log("Invalid!");
			} else if (selectedButton) {
				selectedButton.deselect();
				selectedButton = null;
			}
		}
		
		public static function reset():void {
			byClass = new Array();
			selectedButton = null;
		}
		
		public static var selectedButton:BuildButton;
		public static var byClass:Array = new Array();			//I do not like this array (why?)
		
		public static const DIRECTION_KEYS:Array = new Array('A', 'W', 'D', 'S'); 
		public static const CURSOR_KEYS:Array = new Array('LEFT', 'UP', 'RIGHT', 'DOWN'); 
		//public static const NUM_KEYS:Array = new Array('NUM4', 'NUM8', 'NUM6', 'NUM2'); 
		/*public static const DIRECTIONS_BY_KEY:Array = new Array();
		DIRECTIONS_BY_KEY['w'] = UP;
		DIRECTIONS_BY_KEY['a'] = LEFT;
		DIRECTIONS_BY_KEY['s'] = DOWN;
		DIRECTIONS_BY_KEY['d'] = RIGHT; */
	}

}