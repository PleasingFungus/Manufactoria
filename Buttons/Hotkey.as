package Buttons 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class Hotkey extends FlxSprite {
		[Embed(source = "/images/UI/hotkey.png")] public static const png:Class;
		
		private var key:int;
		private var num:FlxText;
		private var associate:HotkeyButton;
		private var live:Boolean = false;
		
		public function Hotkey(X:int, Y:int, key:int, associate:HotkeyButton, live:Boolean = true) {
			super(X, Y, png);
			
			color = IDLE_COLOR;
			alpha = IDLE_ALPHA;
			
			this.key = key;
			this.associate = associate;
			if (associate) {
				num = new FlxText(X-2, Y, width, String(key));
				num.alpha = IDLE_ALPHA;
				num.alignment = "center";
			} else {
				visible = false;
			}
			this.live = live;
		}
		
		override public function render():void {
			super.render();
			num.render();
		}
		
		override public function update():void {
			super.update();
			
			var i:int;
			
			//if associate: fancy light-up tricks
			if (associate && (FlxG.keys.justReleased(Manufactoria.WRITTEN_NUMBERS[key]) || FlxG.keys.justReleased("NUM"+key))) {
				alpha = num.alpha = IDLE_ALPHA;
				color = IDLE_COLOR;
			} 
			
			if (FlxG.keys.justPressed(Manufactoria.WRITTEN_NUMBERS[key]) || FlxG.keys.justPressed("NUM"+key)) {
				if (!associate) {
					if (live) {
						//deselect!
						BuildButton.setSelected(null);
						if (SelectTool.selected)
							SelectTool.instance.deselect();
					}
				} else {
					if (live) {
						if (!associate.selected) { //select!
							BuildButton.setSelected(null);
							if (SelectTool.selected)
								SelectTool.instance.deselect();
							associate.select();
						}
					}
					
					color = 0xffffffff;
					alpha = num.alpha = 1;
				}
			}
		}
		
		private static const IDLE_ALPHA:Number = .6;
		private static const IDLE_COLOR:Number = 0xb8b8b8;
		public static const DIM:int = 12;
	}

}