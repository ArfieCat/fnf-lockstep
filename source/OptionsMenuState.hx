package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
using StringTools;

/*
State containing a simplified options menu.
*/

class OptionsMenuState extends MusicBeatState
{
	var OPTIONS:Array<String> = ['View Controls', 'Preferences', 'Clear Save Data'];

	public static var menuItems:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;

	override function create() 
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuDesat'));
		bg.screenCenter();
		bg.antialiasing = !ClientPrefs.lowQuality;
		add(bg);

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
				case 'View Controls':
					openSubState(new ControlsSubstate());

				case 'Preferences':
					openSubState(new PreferencesSubstate());

				case 'Clear Save Data':
					FlxG.sound.play(Paths.sound('cancelMenu'));
					ClientPrefs.resetSettings();
					FlxFlicker.flicker(menuItems.members[curSelected], 0.5, 0.05, true, true, function(flk:FlxFlicker)
					{
						menuItems.members[curSelected].alpha = 0.6;
					});
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
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

/*
Substate containing a simple diagram of the controls.
*/

class ControlsSubstate extends MusicBeatSubstate 
{
	public function new() 
	{
		super();

		var controls:FlxSprite = new FlxSprite().makeGraphic(500, 500, 0xFF000000);
		controls.screenCenter();
		add(controls);
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
	}
}

/*
Substate containing a menu with user-settable options.
*/

class PreferencesSubstate extends MusicBeatSubstate
{
	var OPTIONS:Array<Dynamic> = 
	[
		// name, variable, whether its numeric
		['Easy Mode ', ClientPrefs.easyMode, false],
		['Low Quality ', ClientPrefs.lowQuality, false],
		['Show FPS ', ClientPrefs.showFPS, false],
		['Framerate ', ClientPrefs.framerate, true],
		['Note Delay ', ClientPrefs.noteOffset, true]
	];

	var menuItems:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;

	public function new()
	{
		OptionsMenuState.menuItems.visible = false;
		ClientPrefs.loadSettings();

		super();

		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

		for (i in 0...OPTIONS.length)
		{
			var text:String = OPTIONS[i][0];

			if (OPTIONS[i][2])
			{
				text += OPTIONS[i][1];
			}
			else
			{
				OPTIONS[i][1] ? text += 'ON' : text += 'OFF';
			}

			var item:Alphabet = new Alphabet(0, 0, text, 1, true, true);
			item.screenCenter(X);
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
			var selected:Array<Dynamic> = OPTIONS[curSelected];
			var item:Alphabet = menuItems.members[curSelected];

			if (!selected[2])
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));

				selected[1] = !selected[1];

				switch (selected[0])
				{
					case 'Easy Mode ':
						ClientPrefs.easyMode = selected[1];

					case 'Low Quality ':
						ClientPrefs.lowQuality = selected[1];

					case 'Show FPS ':
						ClientPrefs.showFPS = selected[1];
				}
				
				var text:String = selected[0];
				selected[1] ? text += 'ON' : text += 'OFF';

				var newItem:Alphabet = new Alphabet(0, 0, text, 1, true, true);
				newItem.screenCenter(X);
				newItem.y = item.y;
				newItem.targetY = item.targetY;

				menuItems.replace(item, newItem);
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));

			ClientPrefs.saveSettings();
			OptionsMenuState.menuItems.visible = true;
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