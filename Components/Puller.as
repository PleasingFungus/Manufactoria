package Components
{
	import flash.geom.Point;
	import org.flixel.FlxSprite;
	import TapeEngine.StackSymbol;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Puller extends TileComponent
	{
		protected var colorPair:Boolean;
		public static var queuePull:Function;
		public var flip:Boolean = false;
		
		public function Puller(X:int, Y:int, gridIndex:int, facing:int, png:Class, colorPair:Boolean, id:String) {
			if (facing >= 4) {
				facing -= 4;
				flip = true;
			}
			super(X, Y, gridIndex, facing, flip ? (colorPair ? GreenYellowPuller : BlueRedPuller).png_flip : png, id);
			this.colorPair = colorPair;
		}
		
		override public function direct(str:Robot):void {
			var fork:int = queuePull(colorPair);
			
			if (fork == StackSymbol.GREY) 
				str.facing = facing;
			else { 
				if (colorPair == GREEN_YELLOW)
					fork -= 2;
				str.facing = (fork * 2 - 1 + facing + (flip ? 2 : 0)) % 4;
			}
		}
		
		override public function mirror():void {
			super.mirror();
			flip = !flip;
			var c:Class = colorPair ? GreenYellowPuller : BlueRedPuller;
			loadGraphic(flip ? c.png_flip : c.png);
		}
		
		override public function hmirror():void {
			flip = !flip;
			var c:Class = colorPair ? GreenYellowPuller : BlueRedPuller;
			loadGraphic(flip ? c.png_flip : c.png);
			
			if (!(facing % 2))
				facing = (facing + 2) % 4;
		}
		
		override public function regenerationArguments():Array {
			return new Array(x / 16, y / 16, gridIndex, (facing + (flip ? 4 : 0)), id);
		}
		
		override public function toString():String {
			return id + Math.floor(x/16) + ":" + Math.floor(y/16) + "f" + (facing + (flip ? 4 : 0)) + ";";
		}
		
		public static const RED_BLUE:Boolean = false;
		public static const GREEN_YELLOW:Boolean = true;
	}
}