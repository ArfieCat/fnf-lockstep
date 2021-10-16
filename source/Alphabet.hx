package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
using StringTools;

/*
Creates custom text for menus.
*/

class Alphabet extends FlxSpriteGroup
{
	var VALID_LETTERS:String = 'abcdefghijklmnopqrstuvwxyz';
	var VALID_SYMBOLS:String = "1234567890!&'.?";

	// set from state	
	public var targetY:Int = 0;

	var text:String;
	var size:Float;
	var bold:Bool;
	var isMenuItem:Bool;
	var lastSprite:AlphabetCharacter;

	var characterArray:Array<String> = [];
	var letterArray:Array<AlphabetCharacter> = [];

	public function new(x:Float, y:Float, text:String = '', size:Float = 1, bold:Bool = true, isMenuItem:Bool = false)
	{
		super(x, y);

		this.text = text;
		this.size = size;
		this.bold = bold;
		this.isMenuItem = isMenuItem;

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
			var validLetter:Bool = VALID_LETTERS.contains(character.toLowerCase());
			var validSymbol:Bool = VALID_SYMBOLS.contains(character);

			if (character == ' ')
			{
				consecutiveSpaces++;
			}

			if ((validLetter || validSymbol) && character != ' ')
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

				if (bold)
				{
					validLetter ? letter.createBoldLetter(character) : letter.createBoldSymbol(character);
				}
				else
				{
					validLetter ? letter.createLetter(character) : letter.createSymbol(character);
				}
				
				add(letter);
				letterArray.push(letter);
				lastSprite = letter;
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// scroll to menu position
		if (isMenuItem)
		{
			var lerpVal:Float = Utils.boundTo(elapsed * 10, 0, 1);
			y = FlxMath.lerp(y, (targetY * 100) + (FlxG.height / 2) - (height / 2), lerpVal);
		}	
	}
}

/*
Creates letters for Alphabet.
*/

class AlphabetCharacter extends FlxSprite
{
	var size:Float;

	public function new(x:Float, y:Float, size:Float)
	{
		super(x, y);

		this.size = size;

		frames = Paths.getSparrowAtlas('ui/alphabet');
		antialiasing = !ClientPrefs.lowQuality;

		setGraphicSize(Std.int(width * size));
		updateHitbox();
	}

	public function createLetter(letter:String)
	{
		var letterCase:String = (letter.toLowerCase() == letter) ? 'lowercase' : 'capital';

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		// align to bottom
		y = 60 - height;
	}

	public function createSymbol(letter:String)
	{
		if (letter == "'")
		{
			letter = 'apostrophe';
		}

		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);
		updateHitbox();

		y = 60 - height;
	}

	public function createBoldLetter(letter:String)
	{
		letter = letter.toUpperCase();

		animation.addByPrefix(letter, letter + ' bold', 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createBoldSymbol(letter:String)
	{
		if (letter == "'")
		{
			letter = 'apostrophe';
		}

		animation.addByPrefix(letter, 'bold ' + letter, 24);
		animation.play(letter);
		updateHitbox();

		switch (letter)
		{
			case '!' | '?':
				y -= 10 * size;

			case '.':
				y += 50 * size;
		}
	}
}
