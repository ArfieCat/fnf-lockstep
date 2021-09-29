package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

/*
Extendable FlxSubstate that implements basic rhythm functionality.
*/

class MusicBeatSubstate extends FlxSubState
{
	var curStep:Int = 0;
	var curBeat:Int = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var oldStep:Int = curStep;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		updateTiming();

		if (oldStep != curStep && curStep > 0)
			stepHit();
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

	function stepHit()
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	function beatHit()
	{
		// do literally nothing dumbass
	}
}
