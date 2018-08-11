package  
{
	import org.flixel.FlxText;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class EmbossedText extends FlxText
	{
		
		[Embed(source='misc/CryptOf1950.ttf', fontFamily="cryptOf1950")] public static const magicFont:String;
		[Embed(source='misc/CryptOfTomorrow.ttf', fontFamily="cryptOfTomorrow")] public static const magicerFont:String;
		
		public function EmbossedText(X:Number, Y:Number, Width:uint, Text:String=null) {
			super(X, Y, Width, Text);
			//_tf.antiAliasType = AntiAliasType.ADVANCED;
			//_tf.sharpness = -400;
			font = "cryptOfTomorrow";
			color = 0x404040;
			shadow = 0xffffff;
		}
		
		override protected function renderShadow(tfa:TextFormat):void {
			_tf.setTextFormat(new TextFormat(tfa.font,tfa.size,_shadow,null,null,null,null,null,tfa.align));				
			_mtx.translate(0,1);
			_pixels.draw(_tf,_mtx,_ct);
			_mtx.translate(0,-1);
			_tf.setTextFormat(new TextFormat(tfa.font,tfa.size,tfa.color,null,null,null,null,null,tfa.align));
		}
		
		/*override public function render():void {
			var tf:TextFormat;
			
			tf = dtfCopy();
			tf.color = 0xffffff;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			calcFrame();
			
			super.render();
			y -= 1;
			
			tf = dtfCopy();
			tf.color = 0x404040;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			calcFrame();
			
			super.render();
			y += 1;
		}*/
		
	}

}