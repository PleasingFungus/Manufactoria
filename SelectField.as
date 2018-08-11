package  
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas 'A' Feinberg
	 */
	public class SelectField extends FlxGroup
	{
		[Embed(source = "/images/UI/scroll_up.png")] private static const up_png:Class;
		[Embed(source = "/images/UI/scroll_down.png")] private static const down_png:Class;
		
		protected var _length:int;
		protected var _contents:Array;
		protected var _page:int;
		protected var _select:int;
		public var onSelect:Function;
		
		public function SelectField(X:int, Y:int) {
			super();
			x = X;
			y = Y;
			
			_length = 8;
			_select = _page = 0;
			
			add(new FlxSprite().createGraphic(160, 160, 0xff767676));
			for (var i:int = 0; i < _length; i++) {
				add(new FlxSprite(2, i * 20 + 2).createGraphic(148, 20));
				members[i * 2 + 1].color = i % 2 ? 0xff868686 : 0xff969696
				add(new FlxText(2, i * 20 + 2, 148, 'Test!'));
			}
			//add scroll buttons, on the right
			add(new FlxSprite(138, 2).createGraphic(16, 156, 0xffaaaaaa));
			add(new FlxSprite(138, 2, up_png));
			add(new FlxSprite(140, 143, down_png));
			//also a page-number
			add(new FlxText(138, 71, 16, '0'));
			//configure();
		}
		
		public function configure(width:int = -1, height:int = -1, length:int = -1):SelectField {
			members[0].createGraphic(width >= 0 ? width : members[0].width,
									 height >= 0 ? height : members[0].height,
									 0xff767676);
			//if (length > -1) _length = length; //doesn't work
			
			var heightPerField:Number = (members[0].height - 4) / _length;
			for (var i:int = 0; i < _length; i++) {
				var Y:int = i * heightPerField + 2;
				members[i * 2 + 1].y = Y;
				members[i * 2 + 1].createGraphic(members[0].width - 4, heightPerField);
				members[i * 2 + 1].color = i % 2 ? 0xff888888 : 0xff999999;//0xff868686 : 0xff969696
				
				members[i * 2 + 2].y = Y + 1// + heightPerField / 4;
				members[i * 2 + 2].width = members[0].width - 18;
			}
			//adjust scroll buttons / number
			members[_length * 2 + 1].createGraphic(16, members[0].height -4, 0xffaaaaaa).x = members[_length * 2 + 2].x = members[_length * 2 + 3].x = members[0].width - 18;
			members[_length * 2 + 3].y = members[0].height - 17;
			members[_length * 2 + 4].x = members[_length * 2 + 1].x + 2;
			members[_length * 2 + 4].y = 2 + members[0].height / 2 - 9;
			
			members[0].width -= 4;
			members[0].width -= 4;
			members[0].x += 2;
			members[0].y += 2;
			members[0].offset.x = members[0].offset.y = 2;
			
			return this;
		}
		
		public function load(contents:Array):void {
			_contents = contents;
			if (_contents.length < 1)
				_contents = new Array(_length);
			else if (_length * _page >= contents.length) {
				_select = contents.length - 1;
				_page = _select / _length
				members[_length * 2 + 4].text = String(_page);
			}
			members[_length * 2 + 1].visible = members[_length * 2 + 2].visible= members[_length * 2 + 3].visible = members[_length * 2 + 4].visible = _contents.length > _length;
			
			for (var i:int = 0; i < _length; i++) {
				if (_contents[_page * _length + i])
					members[i * 2 + 2].text = _contents[_page * _length + i].name;
				else
					members[i * 2 + 2].text = '-';
			}
		}
		
		public function set selection(newSelection:int):void {
			if (newSelection > _length * (_page + 1) - 1)
				setPage(newSelection / _length);
			
			var i:int = _select % _length;
			members[i * 2 + 1].color = i % 2 ? 0xff868686 : 0xff969696;
			members[i * 2 + 2].color = 0xffffff;
			
			if (onSelect != null)
				onSelect(newSelection);
			_select = newSelection;
			
			i = _select % _length;
			members[i * 2 + 1].color += 0x303030;
			members[i * 2 + 2].color = 0x0;
		}
		
		public function get selection():int {
			return _select;
		}
		
		protected function setPage(newPage:int):void {
			_select += (newPage - _page) * _length;
			_page = newPage;
			for (var i:int = 0; i < _length; i++) {
				if (_contents[_page * _length + i])
					members[i * 2 + 2].text = _contents[_page * _length + i].name;
				else
					members[i * 2 + 2].text = '-';
			}
			members[_length * 2 + 4].text = String(_page);
		}
		
		protected function scrollUp():void {
			setPage(_page ? _page - 1 : (_contents.length - 1) / _length);
			if (onSelect != null)
				onSelect(_select);
		}
		
		protected function scrollDown():void {
			setPage((_page + 1) % int(_contents.length / _length + 1) );
			if (onSelect != null)
				onSelect(_select);
		}
		
		override public function update():void {
			if (FlxG.mouse.justPressed() && members[0].overlapsPoint(FlxG.mouse.x, FlxG.mouse.y)) {
				if (members[_length * 2 + 2].overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
					scrollUp();
				else if (members[_length * 2 + 3].overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
					scrollDown();
				else if (FlxG.mouse.x - members[0].x < members[0].width - 20) {
					var clicked:int = (FlxG.mouse.y - members[0].y) / (members[0].height / _length);
					//if (clicked >= 0 && clicked <= _length)
					selection = clicked + _page * _length;
				}
			}
			super.update();
		} 
	}

}