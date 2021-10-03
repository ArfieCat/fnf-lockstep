package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

/*
Object class that creates custom text for menus. Copied from Psych Engine for now.
*/

class Alphabet extends FlxSpriteGroup
{
	var VALID_LETTERS:String = 
		"abcdefghijklmnopqrstuvwxyz
		1234567890
		&()*+-_<>'!.?";

	var text:String;
	var size:Float;
	var lastSprite:AlphabetCharacter;

	var characterArray:Array<String> = [];
	var letterArray:Array<AlphabetCharacter> = [];

	public function new(x:Float, y:Float, text:String = '', size:Float = 1)
	{
		super(x, y);

		this.text = text;
		this.size = size;

		if (text != '')
		{
			addText();
		}
	}

	function addText()
	{
		characterArray = text.split('');

		var xPos:Float = 0;
		var consecutiveSpaces:Int = 0;

		for (character in characterArray)
		{
			var valid:Bool = VALID_LETTERS.contains(character.toLowerCase());

			if (character == ' ')
			{
				consecutiveSpaces++;
			}

			if (valid && character != ' ')
			{
				if (lastSprite != null)
				{
					xPos = lastSprite.x + lastSprite.width;
				}
					
				if (consecutiveSpaces > 0)
				{
					xPos += 40 * consecutiveSpaces * size;
					consecutiveSpaces = 0;
				}

				var letter:AlphabetCharacter = new AlphabetCharacter(xPos, 0, size);
				letter.createBoldLetter(character);

				add(letter);
				letterArray.push(letter);
				lastSprite = letter;
			}
		}
	}
}

/*
Object class that creates letters for Alphabet.
*/

class AlphabetCharacter extends FlxSprite
{
	var size:Float;

	public function new(x:Float, y:Float, size:Float)
	{
		super(x, y);

		this.size = size;

		frames = Paths.getSparrowAtlas('ui/alphabet');
		antialiasing = ClientPrefs.antialiasing;

		setGraphicSize(Std.int(width * size));
		updateHitbox();
	}

	public function createBoldLetter(letter:String)
	{
		var anim:String;

		switch (letter)
		{
			case "'":
				anim = 'apostrophe';
			default:
				anim = letter.toUpperCase();
		}

		animation.addByPrefix(letter, 'bold ${anim}', 24);
		animation.play(letter);
		updateHitbox();

		switch (letter)
		{
			case '(':
				x -= 65 * size;
				y -= 5 * size;
				offset.x = -60 * size;
			case ')':
				x -= 20 / size;
				y -= 5 * size;
				offset.x = 10 * size;
			case '-':
				y += 20 * size;
			case '_' | '.':
				y += 40 * size;
			case '!' | '?':
				y -= 10 * size;
		}
	}
}
