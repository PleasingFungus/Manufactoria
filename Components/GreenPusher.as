package Components
{
	import TapeEngine.StackSymbol;
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class GreenPusher extends Pusher {
		[Embed(source = "/images/Components/push_g_l.png")] public static const png:Class;
		
		public function GreenPusher(X:int, Y:int, gridIndex:int, facing:int = DOWN) {
			super(X, Y, gridIndex, facing, StackSymbol.GREEN, png, 'g');
		}
		
	}

}