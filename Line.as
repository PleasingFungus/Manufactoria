package  
{
	import org.flixel.FlxObject;
	import org.flixel.FlxG;
    import flash.display.Bitmap;
    import flash.display.Shape;
	import flash.geom.Point;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Line extends FlxObject
	{
        protected var bmp:Bitmap;
        protected var p:Point;

        function Line(start:FlxPoint, end:FlxPoint, thickness:int, color:int) {
			//var canvasLoc:FlxPoint;
			//var dimensions:FlxPoint;
			//var 
			/*var width:int = bottomRight.x - topLeft.x;
			if (width < thickness) {
				bottomRight.x += (thickness - width) / 2;
				topLeft.x -= (thickness - width) / 2;
				width = thickness;
			}
			var height:int = bottomRight.y - topLeft.y;
			if (height < thickness) {
				bottomRight.y += (thickness - height) / 2;
				topLeft.y -= (thickness - height) / 2;
				height = thickness;
			}*/
			
			
			var dx:int = start.x - end.x;
			var dy:int = start.y - end.y;
			
            p = new Point(dx > 0 ? end.x : start.x,
						  dy > 0 ? end.y : start.y);
			
			var width:int = Math.abs(dx);
			if (width < thickness) {
				p.x -= (thickness - width) / 2;
				width = thickness;
			}
			var height:int = Math.abs(dy);
			if (height < 1) {
				p.y -= (thickness - height) / 2;
				height = thickness;
			}
			
			
            var s:Shape = new Shape();
            s.graphics.lineStyle(thickness, color);
			var sx:int = dx > 0 ? 0 : -dx;
			var sy:int = dy > 0 ? 0 : -dy;
            s.graphics.moveTo(sx, sy);
            s.graphics.lineTo(width - sx, height - sy); //dx+: dx    dx-: 0
			
            bmp = new Bitmap(FlxG.createBitmap(width, height, 0x00FFFFFF, true)); 
			
            bmp.bitmapData.draw(s);
        }

        override public function render():void {
            FlxG.buffer.copyPixels(
                    bmp.bitmapData,
                    bmp.bitmapData.rect,
                    p, null, null, true);
        }
    }
}