package Buttons 
{
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public interface HotkeyButton 
	{
		function get selected():Boolean;
		function select():void;
		function deselect():void;
	}
	
}