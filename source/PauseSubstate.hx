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

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		add(bg);

		FlxTween.tween(bg, { alpha: 0.6 }, 0.1, { ease: FlxEase.circOut });

		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

		for (i in 0...OPTIONS.length)
		{
			var item:Alphabet = new Alphabet(0, 0, OPTIONS[i], 1, true, true);
			item.screenCenter();
			item.targetY = i;
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
			var selected:String = OPTIONS[curSelected];

			switch (selected)
			{
				case 'Resume':
					close();

				case 'Restart':
					MusicBeatState.switchState(new LockstepState());
					
				case "Exit to Menu":
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.6);
					MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected < 0)
		{
			curSelected = OPTIONS.length - 1;
		}
		else if (curSelected >= OPTIONS.length)
		{
			curSelected = 0;
		}
		
		var index:Int = 0;

		menuItems.forEach(function(item:Alphabet)
		{
			item.targetY = index - curSelected;
			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
			
			index++;
		});
	}
}
