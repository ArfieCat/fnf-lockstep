package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxState;

/*
Extendable State with commonly used features.
*/

class MusicBeatState extends FlxState
{
	var curStep:Int = 0;
	var curBeat:Int = 0;

	public static var playTransOut:Bool = true;
	public static var playTransIn:Bool = true;

	override function create()
	{
		super.create();

		if (playTransOut)
		{
			openSubState(new TransitionSubstate(1, true));
		}
		else
		{
			playTransOut = !playTransOut;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var oldStep:Int = curStep;

		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		updateTiming();

		if (oldStep != curStep && curStep > 0)
		{
			stepHit();
		}
	}

	function updateTiming()
	{
		var lastChange:BPMChangeEvent = 
		{
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
			{
				lastChange = Conductor.bpmChangeMap[i];
				Conductor.changeBPM(lastChange.bpm);
			}
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
		curBeat = Math.floor(curStep / 4);
	}

	public static function switchState(nextState:FlxState)
	{
		if (playTransIn)
		{
			FlxG.state.openSubState(new TransitionSubstate(0.5, false, function()
			{
				FlxG.switchState(nextState);
			}));
		}
		else
		{
			playTransIn = !playTransIn;
			FlxG.switchState(nextState);
		}
	}

	function stepHit()
	{
		if (curStep % 4 == 0)
		{
			beatHit();
		}
	}

	function beatHit()
	{
		//do literally nothing dumbass
	}
}
