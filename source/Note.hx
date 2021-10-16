package;

import flixel.FlxSprite;
using StringTools;

/*
Creates and manages notes and their properties.
*/

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
		super();

		strumTime += ClientPrefs.noteOffset;
			
		this.strumTime = strumTime;
		this.direction = direction;
		this.mustHit = mustHit;

		loadNoteAnims();	
	}

	function loadNoteAnims()
	{
		frames = Paths.getSparrowAtlas('gameplay/note-assets');
		antialiasing = !ClientPrefs.lowQuality;

		animation.addByPrefix('idle', 'note', 0);
		animation.play('idle');

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
