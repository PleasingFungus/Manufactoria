package Components
{
	import org.flixel.*;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Pusher extends TileComponent
	{
		protected var symbol:int;
		
		public static var queuePush:Function;
		
		public function Pusher(X:int, Y:int, gridIndex:int, facing:int,
							   color:int, png:Class, id:String) {
			super(X, Y, gridIndex, facing, png, id);
			
			this.symbol = color;
		}
		
		override public function direct(str:Robot):void {
			super.direct(str);
			queuePush(symbol);
		}
	}

}