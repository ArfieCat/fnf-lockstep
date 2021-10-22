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

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menu-bg-desat'));
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
					FlxG.sound.play(Paths.sound('menu-cancel'));
					ClientPrefs.resetSettings();
					FlxFlicker.flicker(menuItems.members[curSelected], 0.6, 0.05, true, true, function(flk:FlxFlicker)
					{
						menuItems.members[curSelected].alpha = 0.6;
					});
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('menu-cancel'));
			MusicBeatState.switchState(new MainMenuState());
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
		
		var index:Int = 0;

		menuItems.forEach(function(item:Alphabet)
		{
			item.targetY = index - curSelected;
			
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
			else
			{
				item.alpha = 0.6;
			}

			index++;
		});
	}
}

/*
Substate containing a simple list of the controls.
*/

class ControlsSubstate extends MusicBeatSubstate 
{
	var titleGroup:FlxTypedGroup<Alphabet>;
	var keyGroup:FlxTypedGroup<Alphabet>;
	var bindGroup:FlxTypedGroup<Alphabet>;

	public function new() 
	{
		OptionsMenuState.menuItems.visible = false;

		super();

		titleGroup = new FlxTypedGroup();
		add(titleGroup);

		keyGroup = new FlxTypedGroup();
		add(keyGroup);

		bindGroup = new FlxTypedGroup();
		add(bindGroup);

		var menu:Alphabet = new Alphabet(0, 80, 'MENU', 1, true);
		menu.screenCenter(X);
		titleGroup.add(menu);

		var esc:Alphabet = new Alphabet(0, 180, 'Esc', 0.8, true);
		var enter:Alphabet = new Alphabet(0, 240, 'Enter', 0.8, true);
		var arrows:Alphabet = new Alphabet(0, 300, 'Arrow Keys', 0.8, true);
		keyGroup.add(esc);
		keyGroup.add(enter);
		keyGroup.add(arrows);

		var escText:Alphabet = new Alphabet(0, 180, 'Exit', 0.8, false);
		var enterText:Alphabet = new Alphabet(0, 240, 'Confirm', 0.8, false);
		var arrowsText:Alphabet = new Alphabet(0, 300, 'Navigate Menu', 0.8, false);
		bindGroup.add(escText);
		bindGroup.add(enterText);
		bindGroup.add(arrowsText);

		var gameplay:Alphabet = new Alphabet(0, 420, 'GAMEPLAY', 1, true);
		gameplay.screenCenter(X);
		titleGroup.add(gameplay);

		var esc2:Alphabet = new Alphabet(0, 520, 'Esc', 0.8, true);
		var space:Alphabet = new Alphabet(0, 580, 'Space', 0.8, true);
		keyGroup.add(esc2);
		keyGroup.add(space);

		var escText2:Alphabet = new Alphabet(0, 520, 'Pause', 0.8, false);
		var spaceText:Alphabet = new Alphabet(0, 580, 'March!', 0.8, false);
		bindGroup.add(escText2);
		bindGroup.add(spaceText);

		keyGroup.forEach(function(item:Alphabet)
		{
			item.x = 600 - item.width;
		});

		bindGroup.forEach(function(item:Alphabet)
		{
			item.x = 680;
			item.y -= 10;
		});
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('menu-cancel'));
			OptionsMenuState.menuItems.visible = true;
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
	var holdTime:Float = 0;

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

		// toggles
		if (FlxG.keys.justPressed.ENTER && !OPTIONS[curSelected][2]) 
		{
			var selected:Array<Dynamic> = OPTIONS[curSelected];
			var item:Alphabet = menuItems.members[curSelected];

			FlxG.sound.play(Paths.sound('menu-scroll'));

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

		// sliders
		if ((FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT) && OPTIONS[curSelected][2])
		{
			var selected:Array<Dynamic> = OPTIONS[curSelected];
			var item:Alphabet = menuItems.members[curSelected];
			var add:Int = FlxG.keys.pressed.LEFT ? -1 : 1;

			if (holdTime == 0) 
			{
				FlxG.sound.play(Paths.sound('menu-scroll'));
			}

			if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
			{
				selected[1] += add;

				switch (selected[0]) 
				{
					case 'Framerate ':
						selected[1] = Utils.boundTo(selected[1], 60, 240);
						ClientPrefs.framerate = selected[1];
	
					case 'Note Delay ':
						selected[1] = Utils.boundTo(selected[1], 0, 500);
						ClientPrefs.noteOffset = selected[1];
				}

				var text:String = selected[0] + selected[1];

				var newItem:Alphabet = new Alphabet(0, 0, text, 1, true, true);
				newItem.screenCenter(X);
				newItem.y = item.y;
				newItem.targetY = item.targetY;

				menuItems.replace(item, newItem);
			}

			holdTime += elapsed;
		} 
		else
		{
			holdTime = 0;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.play(Paths.sound('menu-cancel'));

			ClientPrefs.saveSettings();
			OptionsMenuState.menuItems.visible = true;
			close();
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
		
		var index:Int = 0;

		menuItems.forEach(function(item:Alphabet)
		{
			item.targetY = index - curSelected;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
			else
			{
				item.alpha = 0.6;
			}

			index++;
		});
	}
}