package;

import flixel.FlxSprite;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float;
	public var direction:Int;
	public var mustHit:Bool;

	public var canBeHit:Bool = false;
	public var wasGoodHit:Bool = false;
	public var tooLate:Bool = false;

	public function new(strumTime:Float, direction:Int, mustHit:Bool)
	{
		super(-100, -100);		// spawn them off screen

		strumTime += ClientPrefs.noteOffset;
			
		this.strumTime = strumTime;
		this.direction = direction;
		this.mustHit = mustHit;

		loadNoteAnims();

		switch (direction % 2)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				animation.play('redScroll');
		}
	}

	function loadNoteAnims()
	{
		frames = Paths.getSparrowAtlas('gameplay/NOTE_assets');
		antialiasing = ClientPrefs.antialiasing;

		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		setGraphicSize(Std.int(width * 0.5));
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustHit)
		{
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset &&
				Conductor.songPosition > strumTime - Conductor.safeZoneOffset)
			{
				canBeHit = true;
			}
			else
			{
				canBeHit = false;
			}

			if (Conductor.songPosition - Conductor.safeZoneOffset > strumTime && !wasGoodHit)
			{
				tooLate = true;
			}
		}
		else
		{
			canBeHit = false;

			if (Conductor.songPosition >= strumTime)
			{
				wasGoodHit = true;
			}
		}
	}
}
