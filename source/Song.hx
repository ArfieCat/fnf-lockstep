package;

import haxe.Json;
import openfl.utils.Assets;
using StringTools;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
}

/*
Creates song objects from JSON files.
*/

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String):SwagSong
	{
		var formattedSong:String = Utils.formatToSongPath(jsonInput);
		var rawJson:String = Assets.getText(Paths.json(formattedSong)).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var songJson:SwagSong = cast Json.parse(rawJson).song;
		return songJson;
	}
}
