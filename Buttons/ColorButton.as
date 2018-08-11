package Buttons 
{
	import Buttons.Button;
	import TapeEngine.Queue;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class ColorButton extends Button {
		[Embed(source = "/images/UI/grey_up.png")] private static const grey_up:Class;
		[Embed(source = "/images/UI/blue_up.png")] private static const blue_up:Class;
		[Embed(source = "/images/UI/red_up.png")] private static const red_up:Class;
		[Embed(source = "/images/UI/yellow_up.png")] private static const yellow_up:Class;
		[Embed(source = "/images/UI/green_up.png")] private static const green_up:Class;
		private static const up:Array = new Array(grey_up, blue_up, red_up, yellow_up, green_up);
		
		protected var type:int;
		protected var queue:Queue;
		
		public function ColorButton(X:int, Y:int, color:int, queue:Queue) {
			super(X, Y, up[color]);
			this.type = color;
			this.queue = queue;
		}
		
		override public function update():void {
			super.update();
			if (justClicked)
				onClick();
		}
		
		protected function onClick():void {
			if (type)
				queue.bufferColor(type);
			else
				queue.debufferColor();
		}
		
		override public function getDescription(verbose:Boolean):String {
			if (type)
				return verbose ? "Add a " + COLORNAMES[type] + " symbol to the string!" : COLORNAMES[type].toUpperCase() + "!";
			return verbose ? "Remove a symbol from the string!" : "Delete!";
		}
		
		public static const COLORNAMES:Array = new Array("grey", "blue", "red", "yellow", "green");
	}

}