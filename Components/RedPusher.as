package Components
{
	import TapeEngine.StackSymbol;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class RedPusher extends Pusher {
		[Embed(source = "/images/Components/push_r_l.png")] public static const png:Class;
		
		public function RedPusher(X:int, Y:int, gridIndex:int, facing:int = DOWN) {
			super(X, Y, gridIndex, facing, StackSymbol.RED, png, 'r');
		}
	}

}