package TapeEngine 
{
	import TapeEngine.StackSymbol;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class PseudoStackSymbol extends StackSymbol
	{
		
		public function PseudoStackSymbol(index:int, type:int) 
		{
			super(type, null, null, null);
			x = (index % Queue.SYMBOLS_PER_LINE) * GAP_X + OFF_X;
			y = (Math.floor(index / Queue.SYMBOLS_PER_LINE)) * GAP_Y + OFF_Y;
			
			active = false;
		}
		
	}

}