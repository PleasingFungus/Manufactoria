package Buttons 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Dial extends FlxGroup
	{
		[Embed(source = "/images/UI/dial_on.png")] public static const on_png:Class;
		[Embed(source = "/images/UI/dial_off.png")] public static const off_png:Class;
		
		public var onClick:Function;
		public var on:Boolean;
		
		public function Dial(X:int, Y:int, offText:String, onText:String) {
			super();
			add(new FlxSprite(X, Y, off_png));
			add(new FlxText(X - 22, Y - 15, 50, offText).setFormat(null, 8, 0xffb0b0));
			add(new FlxText(X + 20, Y - 15, 50, onText).setFormat(null, 8, 0xb0ffb0));
			on = false;
		}
		
		override public function update():void {
			if (FlxG.mouse.justPressed() && members[0].overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) {
				toggle();
				if (onClick != null) onClick();
			}
		}
		
		public function toggle():void {
			on = !on;
			members[0].loadGraphic(on ? on_png : off_png);
		}
	}

}