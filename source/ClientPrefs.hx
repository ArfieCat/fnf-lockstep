package;

import flixel.FlxG;

/*
Custom class containing user settings. Use this instead of directly accessing the save data for options
Copied from Psych Engine and non-functional for now.
*/

class ClientPrefs
{
	public static var easyMode:Bool = false;
	public static var lowQuality:Bool = false;
	public static var showFPS:Bool = false;

	public static var framerate:Int = 120;
	public static var noteOffset:Int = 0;

	public static function saveSettings()
	{
		FlxG.save.bind('game');

		FlxG.save.data.easyMode = easyMode;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.volume = FlxG.sound.volume;

		FlxG.save.flush();
		trace('JUST SAVED ' + FlxG.save.data);

		loadSettings();
	}

	public static function loadSettings()
	{		
		FlxG.save.bind('game');

		if (FlxG.save.data.easyMode != null)
		{
			easyMode = FlxG.save.data.easyMode;
		}
			
		if (FlxG.save.data.lowQuality != null)
		{
			lowQuality = FlxG.save.data.lowQuality;
		}
			
		if (FlxG.save.data.showFPS != null)
		{
			showFPS = FlxG.save.data.showFPS;

			// for some reason this can be null?
			if (Main.fpsVar != null)
			{
				Main.fpsVar.visible = showFPS;
			}
		}
		
		if (FlxG.save.data.framerate != null)
		{
			framerate = FlxG.save.data.framerate;
			FlxG.drawFramerate = framerate;
		}

		if (FlxG.save.data.noteOffset != null)
		{
			noteOffset = FlxG.save.data.noteOffset;
		}

		if (FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
	}

	public static function resetSettings()
	{
		FlxG.save.bind('game');
		FlxG.save.erase();

		easyMode = false;
		lowQuality = false;
		showFPS = false;
		framerate = 120;
		noteOffset = 0;

		saveSettings();
	}
}