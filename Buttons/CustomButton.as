package Buttons
{
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	
	import org.flixel.FlxG;
	 
	public class CustomButton extends Button
	{
		public var onClick:Function;
		private var shortDescription:String;
		private var longDescription:String;
		
		public function CustomButton(X:int, Y:int, gif:Class,
									 onClick:Function, shortDescription:String, longDescription:String) {
			super(X, Y, gif);
			this.onClick = onClick;
			this.shortDescription = shortDescription;
			this.longDescription = longDescription;
		}
		
		override public function update():void {
			super.update();
			
			if (onClick != null && moused && FlxG.mouse.justPressed())
				onClick();
		}
		
		override public function getDescription(verbose:Boolean):String {
			return verbose ? longDescription : shortDescription;
		}
	}

}