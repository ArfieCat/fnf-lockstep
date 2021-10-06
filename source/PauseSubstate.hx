package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/*
Substate containing a mid-game pause menu.
*/

class PauseSubstate extends MusicBeatSubstate
{
	var OPTIONS:Array<String> = ['Resume', 'Restart', 'Exit to Menu'];

	var menuItems:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;

	public function new(closeCallback:() -> Void)
	{
		super();

		this.closeCallback = closeCallback;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		add(bg);

		FlxTween.tween(bg, { alpha: 0.6 }, 0.1, { ease: FlxEase.cubeOut });

		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

		for (i in 0...OPTIONS.length)
		{
			var item:Alphabet = new Alphabet(0, (100 * i) + 200, OPTIONS[i]);
			item.screenCenter(X);
			menuItems.add(item);
		}

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			var daSelected:String = OPTIONS[curSelected];

			switch (daSelected)
			{
				case 'Resume':
					close();
			
				case 'Restart':
					MusicBeatState.switchState(new LockstepState());

				case "Exit to Menu":
					MusicBeatState.switchState(new MainMenuState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected < 0)
		{
			curSelected = OPTIONS.length - 1;
		}
		if (curSelected >= OPTIONS.length)
		{
			curSelected = 0;
		}
		
		menuItems.forEach(function(item:Alphabet)
		{
			if (menuItems.members.indexOf(item) == curSelected)
			{
				item.alpha = 1;
			}
			else
			{
				item.alpha = 0.6;
			}
		});
	}
}
