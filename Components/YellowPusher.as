package Components
{
	import TapeEngine.StackSymbol;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class YellowPusher extends Pusher {
		[Embed(source = "/images/Components/push_y_l.png")] public static const png:Class;
		
		public function YellowPusher(X:int, Y:int, gridIndex:int, facing:int = DOWN) {
			super(X, Y, gridIndex, facing, StackSymbol.YELLOW, png, 'y');
		}
	}

}