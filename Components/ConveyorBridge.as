package Components 
{
	import Buttons.BuildButton;
	import org.flixel.FlxG
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class ConveyorBridge extends TileComponent {
		protected var overbelt:ConveyorBelt = null;
		protected var underbelt:ConveyorBelt = null;
		
		public function ConveyorBridge(X:int, Y:int, gridIndex:int, facing:int = LEFT, id:String='i')  {
			super(X, Y, gridIndex, 0, null, id, true);
			overbelt = new ConveyorBelt(X, Y, gridIndex, facing >> 1);
			underbelt = new ConveyorBelt(X, Y, gridIndex, (1 - overbelt.facing % 2) + ((facing % 2) << 1));
			Manufactoria.grid[gridIndex] = this;
			active = true;
		}
		
		/*public function mount(newBelt:ConveyorBelt) {
			//underbelt.exists = true;
			if (newBelt.facing % 2 == underbelt.facing)
				this.underbelt = this.overbelt;
			this.overbelt = newBelt;
		} */
		
		override public function die():Boolean {
			if (!BuildButton.selectedButton || !(BuildButton.selectedButton.type == Manufactoria.BELT && FlxG.keys.SHIFT))
				return super.die();
			else {
				if (BuildButton.selectedButton.facing % 2 != overbelt.facing % 2)
					underbelt.facing = overbelt.facing;
				overbelt.facing = BuildButton.selectedButton.facing;
				return false;
			}
		}
		
		override public function set facing(newFacing:int):void { //dubious
			if (_facing != newFacing) {
				var delta:int = (_facing > newFacing) ? _facing - newFacing : newFacing - _facing;
				if (underbelt) underbelt.facing += delta;
				if (overbelt) overbelt.facing += delta;
				_facing = newFacing;
			}
		}
		
		override public function turnCW():void {
			underbelt.turnCW();
			overbelt.turnCW();
		}
		
		override public function turnCCW():void {
			underbelt.turnCCW();
			overbelt.turnCCW();
		}
		
		override public function mirror():void {
			underbelt.mirror();
			overbelt.mirror();
		}
		
		override public function hmirror():void {
			underbelt.hmirror();
			overbelt.hmirror();
		}

		
		override public function move(X:int, Y:int):void {
			x = overbelt.x = underbelt.x = X;
			y = overbelt.y = underbelt.y = Y;
		}
		
		override public function update():void {
			overbelt.update();
			underbelt.update();
		}
		
		override public function render():void {
			underbelt.render();
			overbelt.render();
		}
		
		override public function set alpha(a:Number):void {
			super.alpha = overbelt.alpha = underbelt.alpha = a;
		}
		
		override public function direct(robo:Robot):void {
			if (robo.facing % 2 == underbelt.facing % 2)
				robo.facing = underbelt.facing;
			else
				robo.facing = overbelt.facing;
		}
		
		/*override public function regenerationArguments():Array {
			return new Array(x / 16, y / 16, gridIndex, saveFace, id);
		}*/
		
		/*override public function toString():String {
			return id + Math.floor(x/16) + ":" + Math.floor(y/16) + "f" + saveFace + ";";
		}*/
		
		override public function get facing():int {
			return (overbelt.facing << 1) + (underbelt.facing >> 1);
		}
	}

}