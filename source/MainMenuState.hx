package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

/*
State containing the main menu.
*/

class MainMenuState extends MusicBeatState
{
	var OPTIONS:Array<Dynamic> = 
	[
		// name, menu bg suffix
		['lockstep', '-pink'],
		['lockstep-2', '-blue'],
		['options', '']
	];

	var curSelected:Int = 0;

	var bgs:FlxSpriteGroup;
	var menuItems:FlxSpriteGroup;

	// FLAGS
	var selectedSomething:Bool = false;		// the user has selected a menu item

	override function create()
	{
		super.create();

		bgs = new FlxSpriteGroup();
		add(bgs);

		menuItems = new FlxSpriteGroup();
		add(menuItems);

		for (i in 0...OPTIONS.length)
		{
			var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menu-bg${OPTIONS[i][1]}'));
			bg.screenCenter();
			bg.alpha = 0;
			bg.antialiasing = !ClientPrefs.lowQuality;

			var menuItem:FlxSprite = new FlxSprite(0, (i * 180) + 120);
			menuItem.screenCenter(X);
			menuItem.antialiasing = !ClientPrefs.lowQuality;

			menuItem.frames = Paths.getSparrowAtlas('ui/main-menu/menu-${OPTIONS[i][0]}');
			menuItem.animation.addByPrefix('idle', '${OPTIONS[i][0]} basic', 24);
			menuItem.animation.addByPrefix('selected', '${OPTIONS[i][0]} white', 24);
			menuItem.animation.play('idle');

			bgs.add(bg);
			menuItems.add(menuItem);
		}

		bgs.members[curSelected].alpha = 1;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomething)
		{
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
				selectedSomething = true;

				FlxG.sound.play(Paths.sound('menu-confirm'));

				menuItems.forEach(function(item:FlxSprite)
				{
					if (menuItems.members.indexOf(item) == curSelected)
					{
						FlxFlicker.flicker(item, 1, 0.05, true, false, function(flk:FlxFlicker)
						{
							switch (OPTIONS[curSelected][0])
							{
								case 'options':
									MusicBeatState.switchState(new OptionsMenuState());

								default:
									LockstepState.SONG = Song.loadFromJson('songs/${OPTIONS[curSelected][0]}');
									MusicBeatState.switchState(new LockstepState());
							}
						});
					}
					else
					{
						FlxTween.tween(item, { alpha: 0 }, 0.6, { ease: FlxEase.circOut });
					}
				});
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('menu-scroll'));

		curSelected += change;

		if (curSelected < 0)
		{
			curSelected = OPTIONS.length - 1;
		}
		else if (curSelected >= OPTIONS.length)
		{
			curSelected = 0;
		}

		bgs.forEach(function(bg:FlxSprite)
		{
			if (bgs.members.indexOf(bg) == curSelected)
			{
				FlxTween.tween(bg, { alpha: 1 }, 1, { ease: FlxEase.circInOut });
			}
			else
			{
				FlxTween.tween(bg, { alpha: 0 }, 1, { ease: FlxEase.circInOut });
			}
		});
		
		menuItems.forEach(function(item:FlxSprite)
		{
			if (menuItems.members.indexOf(item) == curSelected)
			{
				item.animation.play('selected');
				item.offset.x = 60;
				item.offset.y = 20;
			}
			else
			{
				item.animation.play('idle');
				item.offset.x = 0;
				item.offset.y = 0;
			}

			item.screenCenter(X);
		});
	}
}
