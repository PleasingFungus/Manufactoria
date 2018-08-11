package Components
{
	import Buttons.BuildButton;
	import org.flixel.FlxG;
	import States.BuildState;
	import States.RunState;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class ConveyorBelt extends TileComponent
	{
		[Embed(source = "/images/Components/belt_l.png")] private static const _0:Class;
		[Embed(source = "/images/Components/belt_u.png")] private static const _1:Class;
		[Embed(source = "/images/Components/belt_r.png")] private static const _2:Class;
		[Embed(source = "/images/Components/belt_d.png")] private static const _3:Class;
		public static const pngs:Array = new Array(_0, _1, _2, _3);
		public static const BELTFRAMES:Array = new Array(0, 1, 2, 3, 4);
		public static const BELTSPEED:int = 10;
		
		protected var gifs:Array;
		
		public function ConveyorBelt(X:int, Y:int, gridIndex:int, facing:int = LEFT, id:String = 'c') {
			super(X, Y, gridIndex, facing, pngs[0], id, true);
			loadBelt();
			active = true;
		}
		
		protected function loadBelt():void {
			loadGraphic(pngs[facing], true, false, 15, 15);
			//if (FlxG.state is RunState) {
				addAnimation("run", BELTFRAMES, BELTSPEED);
				play("run");
			//}
		}
		
		override public function set facing(newFacing:int):void {
			if (_facing != newFacing) {
				while (newFacing < 0)
					newFacing += 4;
				_facing = newFacing % 4;
				loadBelt();
			}
		}
		
		override public function die():Boolean {
			if (!BuildButton.selectedButton || BuildButton.selectedButton.type != Manufactoria.BELT || BuildButton.selectedButton.facing % 2 == facing % 2 || !FlxG.keys.SHIFT)
				return super.die();
			else {
				BuildState.addToMid(Manufactoria.components[Manufactoria.components.indexOf(this)] = Manufactoria.grid[gridIndex] = new ConveyorBridge(x / 16, y / 16,
																																	gridIndex,
																																	(BuildButton.selectedButton.facing << 1) + (facing >> 1)));
				exists = false;
				return false;
			}
		}
	}

}