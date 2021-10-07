package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;

/*
Substate containing a flashing lights warning. Only shown once.
*/

class FlashingSubstate extends MusicBeatSubstate
{
	var text:FlxSpriteGroup;

	public function new(closeCallback:() -> Void)
	{
		super();

		this.closeCallback = closeCallback;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		text = new FlxSpriteGroup();
		add(text);

		var warning:Alphabet = new Alphabet(0, 240, 'This mod contains');
		warning.screenCenter(X);
		text.add(warning);

		var warning2:Alphabet = new Alphabet(0, 300, 'flashing lights!');
		warning2.screenCenter(X);
		text.add(warning2);

		var prompt:Alphabet = new Alphabet(0, 480, 'Press ENTER to continue.', 0.6);
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
