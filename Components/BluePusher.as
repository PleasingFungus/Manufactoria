package Components
{
	import TapeEngine.StackSymbol;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class BluePusher extends Pusher {
		[Embed(source = "/images/Components/push_b_l.png")] public static const png:Class;
		
		public function BluePusher(X:int, Y:int, gridIndex:int, facing:int = DOWN) {
			super(X, Y, gridIndex, facing, StackSymbol.BLUE, png, 'b');
		}
	}

}