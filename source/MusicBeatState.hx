package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

/*
Extendable FlxState that implements basic rhythm functionality, as well as custom transitions.
*/

class MusicBeatState extends FlxState
{
	var curStep:Int = 0;
	var curBeat:Int = 0;

	override function create()
	{
		super.create();

		if(!FlxTransitionableState.skipNextTransOut)
			openSubState(new TransitionSubstate(1, true));
		else
			FlxTransitionableState.skipNextTransOut = false;
	}

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

	public static function switchState(nextState:FlxState)
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			FlxG.state.openSubState(new TransitionSubstate(0.5, false));
			TransitionSubstate.finishCallback = function()
			{
				FlxG.switchState(nextState);
			};
		}
		else
		{
			FlxTransitionableState.skipNextTransIn = false;
			FlxG.switchState(nextState);
		}
	}

	function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
