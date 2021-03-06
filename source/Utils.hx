package;

import flixel.util.FlxSort;
import openfl.utils.Assets;
using StringTools;

/*
Contains miscellaneous useful functions.
*/

class Utils
{
	public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		if (value < min)
		{
			return min;
		}	
		else if (value > max || Math.isNaN(value))
		{
			return max;
		}
		else
		{
			return value;
		}
	}

	public static inline function formatToSongPath(songName:String):String		// 'Dad Battle' => 'dad-battle'
	{
		return songName.toLowerCase().replace(' ', '-');
	}

	public static function getTextFromFile(dir:String):Array<String>
	{
		var text:Array<String> = Assets.getText(Paths.txt(dir)).trim().split('\n');

		for (i in 0...text.length)
		{
			text[i].trim();
		}

		return text;
	}

	public static inline function sortByStrumTime(a:Note, b:Note):Int	
	{
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}
}
