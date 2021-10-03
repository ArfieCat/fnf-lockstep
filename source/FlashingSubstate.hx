package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;

/*
FlxSubstate that is shown on first launch with a flashing lights warning.
*/

class FlashingSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var text:FlxSpriteGroup;

	public function new(closeCallback:() -> Void)
	{
		super();

		this.closeCallback = closeCallback;
	}

	override function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		text = new FlxSpriteGroup();
		add(text);

		var warning:Alphabet = new Alphabet(0, 240, 'This mod contains');
		warning.screenCenter(X);
		text.add(warning);

		var warning2:Alphabet = new Alphabet(0, 300, 'flashing lights!');
		warning2.screenCenter(X);
		text.add(warning2);

		var prompt:Alphabet = new Alphabet(0, 480, 'Press ENTER to continue.', 0.5);
		prompt.screenCenter(X);
		text.add(prompt);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			text.visible = false;

			FlxG.save.data.seenWarning = true;
			FlxG.save.flush();

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				close();
			});
		}
	}
}
