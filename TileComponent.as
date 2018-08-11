package
{
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	import Components.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class TileComponent extends FlxSprite {
		
		public var gridIndex:int;
		protected var gif:Class;
		protected var id:String;

		public function TileComponent(X:int, Y:int, gridIndex:int, facing:int, gif:Class, id:String, animated:Boolean = false) {
			super(X * 16, Y * 16);
			
			if (!animated) {
				angle = facing * 90;
				loadRotatedGraphic(gif, 4);
			}
			
			Manufactoria.grid[gridIndex] = this;
			
			this.gridIndex = gridIndex;
			this.facing = facing;
			this.gif = gif;
			this.id = id;
		}
		
		public function regenerationArguments():Array {
			return new Array(x / 16, y / 16, gridIndex, facing, id);
		}
		
		public static function regenerate(component:TileComponent):TileComponent { 	//TODO: make grid-dim independent (or dependent?)
			if (component is Source || component is Destination) return null;
			var rargs:Array = component.regenerationArguments();
			return new Manufactoria.COMPONENT_TYPES[Manufactoria.COMPONENTS_BY_ID.indexOf(rargs[4])](rargs[0], rargs[1], rargs[2], rargs[3]);
		}
		
		override public function set facing(newFacing:int):void {
			if (_facing != newFacing) {
				_facing = newFacing;
				angle = 90 * _facing;
			}
		}
		
		public function turnCW():void {
			facing = (facing + 1) % 4;
		}
		
		public function turnCCW():void {
			facing = (facing + 3) % 4;
		}
		
		public function mirror():void {
			facing = (facing + 2) % 4;
		}
		
		public function hmirror():void {
			if (!(facing & 1))
				mirror();
		}
		
		public function direct(str:Robot):void {
			str.facing = facing;
		}
		
		public function get identifier():String { return id }
		
		public function die():Boolean {
			Manufactoria.grid[gridIndex] = null;
			exists = false;
			return true;
		}
		
		override public function toString():String {
			return id + Math.floor(x/16) + ":" + Math.floor(y/16) + "f" + facing + ";";
		}
		
		public static function buildFromString(raw:String):TileComponent {
			var classID:String = raw.charAt(0);
			var type:Class = Manufactoria.COMPONENT_TYPES[Manufactoria.COMPONENTS_BY_ID.indexOf(classID)];
			
			var midIndex:int = raw.indexOf(':')
			var facingIndex:int = raw.indexOf('f')
			
			var x:int = Number(raw.slice(1, midIndex));
			if (x < 5 + Manufactoria.inv_offset || x > 19 - Manufactoria.inv_offset)
				return null;
			var y:int = Number(raw.slice(midIndex + 1, facingIndex));
			if (y < Manufactoria.inv_offset || y > 14 - Manufactoria.inv_offset)
				return null;
			var gridIndex:int = Manufactoria.gridToArray(Manufactoria.realToGrid(x*16,y*16));
			if (gridIndex == Source.grid || gridIndex == Destination.grid)
				return null;
			
			var facing:int = Number(raw.charAt(facingIndex + 1)); 
			
			return new type(x, y, gridIndex, facing);
		}
		
		public function unclip():TileComponent {
			die();
			return regenerate(this);
		}
		
		public function move(X:int, Y:int):void {
			x = X;
			y = Y;
		}
		
		public static const NAMES:Array = new Array("Conveyor", 	 "Bridge", 			"", 
													"Blue Writer",  "Red Writer",		"B/R Branch",
													"Green Writer", "Yellow Writer", 	"G/Y Branch");
		public static const PLURAL_NAMES:Array = new Array("Conveyors", 	 "Bridges", 			"", 
															"Blue Writers",  "Red Writers",		"B/R Branches",
															"Green Writers", "Yellow Writers", 	"G/Y Branches");
		public static const DESCRIPTIONS:Array = new Array(	"Pushes the robot in the belt's direction!",
															"Pushes the robot along its axis of movement!",
															"",
															"Writes a blue symbol onto the end of the tape!",
															"Writes a red symbol onto the end of the tape!",
															"Reads the next symbol and pushes the robot in that direction!", //(if it's red or blue)",
															"Writes a green symbol onto the end of the tape!",
															"Writes a yellow symbol onto the end of the tape!",
															"Reads the next symbol and pushes the robot in that direction!");
	}

}