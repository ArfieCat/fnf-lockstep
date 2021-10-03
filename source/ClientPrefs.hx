package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

/*
Custom class containing user settings. Use this instead of directly accessing the save data for options
Copied from Psych Engine and non-functional for now.
*/

class ClientPrefs
{
	public static var antialiasing:Bool = true;
	public static var easyMode:Bool = false;
	public static var lowQuality:Bool = false;
	public static var showFPS:Bool = true;

	public static var framerate:Int = 120;
	public static var noteOffset:Int = 0;
	public static var volume:Float = 0.5;

	public static var inputKey:FlxKey = SPACE;
	public static var inputKeyAlt:FlxKey = SPACE;

	public static function saveSettings()
	{
		FlxG.save.bind('settings');

		FlxG.save.data.antialiasing = antialiasing;
		FlxG.save.data.easyMode = easyMode;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.inputKey = inputKey;
		FlxG.save.data.inputKeyAlt = inputKeyAlt;

		FlxG.save.flush();
	}

	public static function loadSettings(saveFile:String = 'settings')
	{
		FlxG.save.bind(saveFile);

		if (FlxG.save.data.antialiasing != null)
		{
			antialiasing = FlxG.save.data.antialiasing;
		}
			
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
			Main.fpsVar.visible = showFPS;
		}
		
		if (FlxG.save.data.framerate != null)
		{
			framerate = FlxG.save.data.framerate;
			FlxG.drawFramerate = framerate;
			FlxG.updateFramerate = framerate;
		}

		if (FlxG.save.data.noteOffset != null)
		{
			noteOffset = FlxG.save.data.noteOffset;
		}

		if (FlxG.save.data.volume != null)
		{
			volume = FlxG.save.data.volume;
			FlxG.sound.volume = volume;
		}

		if (FlxG.save.data.inputKey != null)
		{
			inputKey = FlxG.save.data.inputKey;
		}

		if (FlxG.save.data.inputKeyAlt != null)
		{
			inputKeyAlt = FlxG.save.data.inputKeyAlt;
		}
	}
}