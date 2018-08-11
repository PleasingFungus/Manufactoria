package  
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import Buttons.BuildButton;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class WASDHint extends FlxGroup
	{
		[Embed(source = "/images/key.png")] private static const png:Class;
		[Embed(source = "/images/spacebar.png")] private static const sbar:Class;
		
		public function WASDHint() {
			super();
			for (var i:int = 0; i < 4; i++) {
				var center:FlxPoint = new FlxPoint(	FlxG.mouse.x + Math.cos(ANGLES[i]) * RADIUS,
													FlxG.mouse.y + Math.sin(ANGLES[i]) * RADIUS);
				
				var key:FlxSprite = new FlxSprite(center.x, center.y, png);
				key.offset.x = key.offset.y = 10;
				key.color = IDLE_COLOR;
				key.alpha = IDLE_ALPHA;
				add(key);
				
				var keyText:FlxText = new FlxText(center.x, center.y, 10, BuildButton.DIRECTION_KEYS[i]);
				keyText.offset.x = keyText.textWidth;
				keyText.offset.y = keyText.height / 2;
				keyText.color = 0x0;
				keyText.alpha = IDLE_ALPHA;
				add(keyText);
			}
			var spacebar:FlxSprite;
			add(spacebar = new FlxSprite(FlxG.mouse.x - 36, FlxG.mouse.y + RADIUS*2, sbar));
			spacebar.color = IDLE_COLOR;
			spacebar.alpha = IDLE_ALPHA;
		}
		
		override public function update():void {
			super.update();
			
			visible = BuildButton.selectedButton && !FlxG.keys.SHIFT;
			if (!visible)
				return;
			members[8].visible = BuildButton.selectedButton.type == Manufactoria.BRPULL;
			
			for (var i:int = 0; i < 4; i++) {
				if ((FlxG.keys.justReleased(BuildButton.DIRECTION_KEYS[i]) && !FlxG.keys.pressed(BuildButton.CURSOR_KEYS[i]))
					|| (FlxG.keys.justReleased(BuildButton.CURSOR_KEYS[i]) && !FlxG.keys.pressed(BuildButton.DIRECTION_KEYS[i]))) {
					members[i * 2].color = IDLE_COLOR;
					members[i * 2].alpha = members[i * 2 + 1].alpha = IDLE_ALPHA;
				} else if (FlxG.keys.justPressed(BuildButton.DIRECTION_KEYS[i]) || FlxG.keys.justPressed(BuildButton.CURSOR_KEYS[i])) {
					members[i * 2].color = 0xffffff;
					members[i * 2].alpha = members[i * 2 + 1].alpha = 1;
				}
				
				var center:FlxPoint = new FlxPoint(	FlxG.mouse.x + Math.cos(ANGLES[i]) * RADIUS,
													FlxG.mouse.y + Math.sin(ANGLES[i]) * RADIUS);
				members[i * 2].x = members[i * 2 + 1].x = center.x;
				members[i * 2].y = members[i * 2 + 1].y = center.y;
			}
			
			var spacebar:FlxSprite = members[SPACEBAR]
			spacebar.x = FlxG.mouse.x - 36;
			spacebar.y = FlxG.mouse.y + RADIUS * 2;
			if (FlxG.keys.justReleased("SPACE")) {
				spacebar.color = IDLE_COLOR;
				spacebar.alpha = IDLE_ALPHA;
			} else if (FlxG.keys.justPressed("SPACE")) {
				spacebar.color = 0xffffff;
				spacebar.alpha = 1;
			}
		}
		
		private static const RADIUS:int = 20;
		public static const ANGLES:Array = new Array(Math.PI, Math.PI * 3 / 2, 0, Math.PI / 2);
		private static const IDLE_ALPHA:Number = .6;
		private static const IDLE_COLOR:Number = 0xb8b8b8;
		private static const SPACEBAR:int = 8;
	}

}