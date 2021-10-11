package;

import flixel.FlxSprite;
using StringTools;

/*
Creates strumline notes.
*/

class StrumNote extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadStrumNoteAnims();
	}

	function loadStrumNoteAnims()
	{
		frames = Paths.getSparrowAtlas('gameplay/NOTE_assets');
		antialiasing = !ClientPrefs.lowQuality;

		animation.addByPrefix('static', 'arrowDOWN', 0, true);
		animation.addByPrefix('pressed', 'down press', 24, false);
		animation.addByPrefix('confirm', 'down confirm', 24, false);

		playAnim('static');

		setGraphicSize(Std.int(width * 0.5));
		updateHitbox();
	}

	public function playAnim(anim:String, force:Bool = false)
	{
		animation.play(anim, force);

		centerOffsets();

		if (anim == 'confirm')
		{
			offset.x -= 20;
			offset.y -= 20;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (animation.curAnim.name != 'static' && animation.curAnim.finished)
		{
			playAnim('static');
		}
	}
}
