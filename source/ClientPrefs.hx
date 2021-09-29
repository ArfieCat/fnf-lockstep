package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

// TODO: re-add controls
// import Controls;

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

	public static var defaultKeys:Array<FlxKey> = 
	[
		A, LEFT,			//Note Left
		S, DOWN,			//Note Down
		W, UP,				//Note Up
		D, RIGHT,			//Note Right

		A, LEFT,			//UI Left
		S, DOWN,			//UI Down
		W, UP,				//UI Up
		D, RIGHT,			//UI Right

		R, NONE,			//Reset
		SPACE, ENTER,		//Accept
		BACKSPACE, ESCAPE,	//Back
		ENTER, ESCAPE		//Pause
	];

	public static function saveSettings()
	{
		FlxG.save.data.antialiasing = antialiasing;
		FlxG.save.data.easyMode = easyMode;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.noteOffset = noteOffset;

		FlxG.save.flush();

		// TODO: re-add custom controls
		/*
		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99');
		save.data.customControls = lastControls;
		save.flush();
		FlxG.log.add("Settings saved!");
		*/
	}

	public static function loadSettings()
	{
		if (FlxG.save.data.antialiasing != null)
			antialiasing = FlxG.save.data.antialiasing;

		if (FlxG.save.data.easyMode != null)
			easyMode = FlxG.save.data.easyMode;

		if (FlxG.save.data.lowQuality != null)
			lowQuality = FlxG.save.data.lowQuality;

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
			noteOffset = FlxG.save.data.noteOffset;

		if (FlxG.save.data.volume != null)
		{
			volume = FlxG.save.data.volume;
			FlxG.sound.volume = volume;
		}

		/*
		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			reloadControls(save.data.customControls);
		}
		*/
	}

	/*
	public static function reloadControls(newKeys:Array<FlxKey>) {
		ClientPrefs.removeControls(ClientPrefs.lastControls);
		ClientPrefs.lastControls = newKeys.copy();
		ClientPrefs.loadControls(ClientPrefs.lastControls);
	}

	private static function removeControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToRemove:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToRemove.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToRemove.length > 0) {
				PlayerSettings.player1.controls.unbindKeys(keyBinds[i][0], controlsToRemove);
			}
		}
	}
	private static function loadControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToAdd:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToAdd.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToAdd.length > 0) {
				PlayerSettings.player1.controls.bindKeys(keyBinds[i][0], controlsToAdd);
			}
		}
	}
	*/
}