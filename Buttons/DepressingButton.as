package Buttons 
{
	import Buttons.Button;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class DepressingButton extends Button {
		public var onClick:Function;
		public var onRelease:Function;
		private var shortDescription:String;
		private var longDescription:String;
		private var neutralSprite:Class;
		private var depressedSprite:Class;
		private var _depressed:Boolean;
		private var _disabled:Boolean;
		
		public function DepressingButton(X:int, Y:int, neutralSprite:Class = null, depressedSprite:Class = null, shortDescription:String = ' ', longDescription:String = ' ') {
			super(X, Y, neutralSprite);
			this.neutralSprite = neutralSprite;
			this.depressedSprite = depressedSprite;
			this.shortDescription = shortDescription;
			this.longDescription = longDescription;
			_depressed = _disabled = false;
		}
		
		override public function update():void {
			super.update();
			
			if (FlxG.mouse.justPressed() && !_disabled && moused) {
				depressed = true;
				if (onClick != null) onClick();
			} else if (_depressed && FlxG.mouse.justReleased()) {
				depressed = false;
				if (onRelease != null) onRelease();
			}
		}
		
		public function set depressed(dep:Boolean):void {
			if (dep != _depressed) {
				loadGraphic(dep ? depressedSprite : neutralSprite);
				_depressed = dep;
			}
		}
		
		public function get disabled():Boolean {
			return _disabled;
		}
		
		public function set disabled(dis:Boolean):void {
			if (dis != _disabled) {
				color = dis ? 0xff808080 : 0xffffffff;
				_disabled = dis;
			}
		}
		
		public function get depressed():Boolean {
			return _depressed;
		}
		
		
		override public function getDescription(verbose:Boolean):String {
			return verbose ? longDescription : shortDescription;
		}
	}

}