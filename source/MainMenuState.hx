package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

using StringTools;

/*
FlxState containing the main menu. WIP!
*/

class MainMenuState extends MusicBeatState
{
	var menuOptions:Array<String> = ['story_mode', 'freeplay', 'options'];
	var curSelected:Int = 0;

	var bg:FlxSprite;

	// FLAGS
	var selectedSomething:Bool = false;		// the user has selected a menu item

	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
		bg.screenCenter();
		add(bg);

		// TODO: add menu items
		// changeItem();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomething)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				MusicBeatState.switchState(new TitleState());
			}

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}



	

	/*
	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
	*/
}
