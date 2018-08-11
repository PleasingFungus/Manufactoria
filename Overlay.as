package  
{
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Overlay extends FlxSprite
	{
		
		public function Overlay() 
		{
			super(79, 0);
			createGraphic(241, 241, 0xffa1a1a1, true); //a sprite would be nice
			if (Manufactoria.inv_offset) {
				_pixels.fillRect(new Rectangle(Manufactoria.inv_offset * Manufactoria.GRID_SIZE,
											   Manufactoria.inv_offset * Manufactoria.GRID_SIZE - 1,
											   Manufactoria.GRID_DIM * Manufactoria.GRID_SIZE + 1,
											   Manufactoria.GRID_DIM * Manufactoria.GRID_SIZE + 1), 0x0);
			} else {
				_pixels.fillRect(new Rectangle(Manufactoria.inv_offset * Manufactoria.GRID_SIZE - 1,
											   Manufactoria.inv_offset * Manufactoria.GRID_SIZE - 1,
											   Manufactoria.GRID_DIM * Manufactoria.GRID_SIZE + 2,
											   Manufactoria.GRID_DIM * Manufactoria.GRID_SIZE + 1), 0x0);
			}
			calcFrame();
		}
		
	}

}