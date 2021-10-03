package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

using StringTools;

/*
FlxState containing the main menu. Barely functional, will be updated!
*/

class MainMenuState extends MusicBeatState
{
	var OPTIONS:Array<String> = ['freeplay', 'awards', 'options'];
	var PLAYABLE_ITEMS:Array<String> = ['lockstep', 'lockstep-2'];

	var curSelected:Int = 0;

	var camSelect:FlxCamera;
	var camUI:FlxCamera;

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var menuItems:FlxSpriteGroup;

	// FLAGS
	var selectedSomething:Bool = false;		// the user has selected a menu item

	override function create()
	{
		super.create();

		FlxG.sound.music.fadeOut(1, 0.8);

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
		bg.screenCenter();
		add(bg);

		magenta = new FlxSprite().loadGraphic(Paths.image('ui/menuBGMagenta'));
		magenta.screenCenter();
		magenta.visible = false;
		add(magenta);

		menuItems = new FlxSpriteGroup();
		add(menuItems);

		for (i in 0...OPTIONS.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, (i * 180) + 120);
			menuItem.screenCenter(X);
			menuItem.antialiasing = ClientPrefs.antialiasing;

			menuItem.frames = Paths.getSparrowAtlas('ui/mainmenu/menu_' + OPTIONS[i]);
			menuItem.animation.addByPrefix('idle', OPTIONS[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', OPTIONS[i] + " white", 24);
			menuItem.animation.play('idle');

			menuItems.add(menuItem);
		}

		changeSelection(curSelected);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomething)
		{
			if (FlxG.keys.justPressed.UP)
			{
				changeSelection(curSelected--);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				changeSelection(curSelected++);
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				selectedSomething = true;

				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(magenta, 1, 0.15, false);

				menuItems.forEach(function(item:FlxSprite)
				{
					if (menuItems.members.indexOf(item) == curSelected)
					{
						FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.05, false, false, function(flk:FlxFlicker)
						{
							switch (OPTIONS[curSelected])
							{
								case 'freeplay':
									MusicBeatState.switchState(new LockstepState());
								case 'awards':
									MusicBeatState.switchState(new MainMenuState());
								case 'options':
									MusicBeatState.switchState(new MainMenuState());
							}
						});
					}
					else
					{
						FlxTween.tween(item, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
					}
				});
			}
		}

		menuItems.forEach(function(item:FlxSprite)
		{
			item.screenCenter(X);
		});
	}

	function changeSelection(selected:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= menuItems.length)
		{
			curSelected = 0;
		}
		else if (curSelected < 0)
		{
			curSelected = menuItems.length - 1;
		}

		menuItems.forEach(function(item:FlxSprite)
		{
			item.animation.play('idle');
			item.offset.x = 0;
			item.offset.y = 0;

			if (menuItems.members.indexOf(item) == curSelected)
			{
				item.animation.play('selected');
				item.offset.x = 0.15 * (item.frameWidth / 2 + 180);
				item.offset.y = 0.15 * item.frameHeight;
			}
		});
	}
}
