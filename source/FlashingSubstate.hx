package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

/*
FlxSubstate that is shown on first launch with a flashing lights warning.
*/

class FlashingSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var warning:FlxText;

	public function new(closeCallback:() -> Void)
	{
		super();

		this.closeCallback = closeCallback;
	}

	override function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		warning = new FlxText(0, 0, 0, 
			'This mod contains flashing lights!\n\n' +
			'Press ENTER to continue.\n'
		);
		warning.setFormat("VCR OSD Mono", 64, 0xFFFFFFFF, CENTER);
		warning.screenCenter();
		add(warning);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			warning.visible = false;

			FlxG.save.data.seenWarning = true;
			FlxG.save.flush();

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				close();
			});
		}
	}
}
