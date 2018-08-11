package  States
{
	import org.flixel.*;
	import Buttons.StateTransitionButton;
	import Buttons.AudioButton;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class CreditsState extends FlxState {
		[Embed(source = "/images/Backgrounds/credits.png")] public static const background:Class;
		
		override public function create():void {
			add(new FlxSprite(10, 25, background));
			
			//"Thanks to: Kelsey Higham, Adam Saltsman,\nZach Barth, and Daniele Micciancio."
			
			add(new FlxText(120, 77, 500, "THANKS TO:"));
			
			add(new FlxText(15, 90, 290, "Adam Saltsman - creator of the splendid Flixel! http://www.flixel.org - 'it's not half bad!'"));
			add(new FlxText(15, 113, 290, "Zach Barth - made ALCHEMY, KOHCTPYKTOP, and other direct inspirations! (zachtronicsindustries.com)"));
			add(new FlxText(15, 136, 290, "Daniele Micciancio - teaches a mean CSE class! (In the best possible sense.) Taught me everything I know!"));
			add(new FlxText(15, 159, 290, "All of my playtesters - in alpha (Ethan Feinberg, Kelsey Higham, Roland Phung, David Zhang), and in beta, the innumerable, amazing TIGSwarm. Thank you. You helped make Manufactoria the game it deserves to be."));
			//add(new FlxText(15, 177, 290, "(And you, the player, too! I like you. You are probably a good person!)"));
			
			add(new FlxText(165, 210, 130, "Visit the website: pleasingfungus.com!"));
			//add(new FlxText(5, 205, 130, "Music by FORTADELIS; licensed under Creative Commons.").setFormat(null,8,0x606060))
			add(new FlxText(5, 220, 290, "(C) Nicholas Feinberg, 2010"));
			add(new StateTransitionButton(295, 215, MenuState));
			var a:AudioButton = new AudioButton();
			//a.y += 20;
			add(a);
			add(new Tooltip());
			
			/*FlxG.panel = new CustomPanel();
			FlxG.panel.setup("nick.feinberg+paypal@gmail.com", 2, "Manufactoria", "http://pleasingfungus.com", " ");
			FlxG.panel.show();*/
		}
		
		override public function update():void {
			super.update();
			Manufactoria.updateMusic();
		}
		
	}

}