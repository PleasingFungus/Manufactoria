package  
{
	import org.flixel.data.FlxPanel;
	import org.flixel.FlxU;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class CustomPanel extends FlxPanel
	{
		override public function onDonate():void {
			FlxU.openURL("https://www.paypal.com/us/cgi-bin/webscr?cmd=_flow&SESSION=21bTuunrTlv747TbYWCiVIJq6jiJP8zAHsZyd_W5q-h4j8UeWjQvhQ-aKVS&dispatch=5885d80a13c0db1f22d2300ef60a6759516e590e949da361e9502e138eefdd27");
		}
	}

}