package;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import openfl.utils.AssetType;

using StringTools;

/*
Returns asset paths. This mod uses a different file structure!
*/

class Paths
{
	public static function getPath(dir:String, type:AssetType):String
	{
		var path:String = 'assets/${dir}';

		if (Assets.exists(path, type))
		{
			return path;
		}
		else
		{
			trace('Could not find asset: ${path}');
			return '';
		}	
	}

	// --- data folder: txt, json ---

	public static inline function txt(dir:String):String
	{
		return getPath('data/${dir}.txt', TEXT);
	}

	public static inline function json(dir:String):String
	{
		return getPath('data/${dir}.json', TEXT);
	}

	// --- images folder: png, xml ---

	public static inline function image(dir:String):String
	{
		return getPath('images/${dir}.png', IMAGE);
	}

	public static inline function xml(dir:String):String
	{
		return getPath('images/${dir}.xml', TEXT);
	}

	public static inline function getSparrowAtlas(dir:String):FlxAtlasFrames	// this one doesn't return a path!
	{
		return FlxAtlasFrames.fromSparrow(image(dir), xml(dir));
	}

	// --- sounds folder: ogg (for sound effects) ---

	public static inline function sound(dir:String):String
	{
		return getPath('sounds/${dir}.ogg', SOUND);
	}

	public static inline function soundRandom(dir:String, max:Int):String		// use with files numbered 0...max (exclusive)
	{
		return sound(dir + Std.random(max));
	}

	// --- music folder: ogg (for music) ---

	public static inline function music(dir:String):String
	{
		return getPath('music/${dir}.ogg', MUSIC);
	}

	public static inline function inst(songName:String):String
	{
		return music('${songName}/Inst');
	}

	public static inline function voices(songName:String):String
	{
		return music('${songName}/Voices');
	}

	// --- fonts folder: ttf ---

	public static inline function font(dir:String):String
	{
		return getPath('fonts/${dir}.ttf', FONT);
	}
}
