package;

import flixel.text.FlxText;
import Song.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class LockstepState extends MusicBeatState
{
    var POPULATION = 185;
	var PER_ROW = 21;
	var OFFSET_X = 210;
	var OFFSET_Y = 280;

	var STRUM_X:Int = 1180;
	var STRUM_Y:Int = 620;

	var RATINGS:Array<Dynamic> = 
	[
		['Try Again', 0.8],
		['OK', 0.9], 
		['Superb', 1],
		['Perfect', 1]
	];

	public static var SONG:SwagSong;	// set this from the menu

	var curSong:String;			// formatted
	var curStage:String;

	var songTotalNotes:Int = 0;
	var songMisses:Int = 0;
	var songAccuracy:Float = 1;
	var songRating:String = 'Perfect';

	var camHud:FlxCamera;
	var camStrums:FlxCamera;	// easy mode
	
	var bg:FlxSprite;
	var bgFlash:FlxSprite;
	var bgStrums:FlxSprite;
	var parentStepper:Stepswitcher;
	var playableStepper:Stepswitcher;
	var bgSteppers:FlxTypedGroup<Stepswitcher>;
	var fgSteppers:FlxTypedGroup<Stepswitcher>;

	var unspawnedNotes:Array<Note> = [];
	var notes:FlxTypedGroup<Note>;
	var playerStrum:StrumNote;

	var scoreText:FlxText;
	var perfectText:FlxSprite;

	var inputKey:FlxKey = ClientPrefs.inputKey;
	var inputKeyAlt:FlxKey = ClientPrefs.inputKeyAlt;

	// FLAGS
	var songPlaying:Bool = false;
	var finishedCountdown:Bool = false;

	override function create()
	{
		super.create();
 
		FlxG.sound.music.stop();
		FlxG.fixedTimestep = false;

		camHud = new FlxCamera(-FlxG.width);	// start off screen
		camHud.bgColor.alpha = 0;
		FlxG.cameras.add(camHud, false);

		camStrums = new FlxCamera(FlxG.width);	// start off screen
		camStrums.bgColor.alpha = 0;
		FlxG.cameras.add(camStrums, false);

		// TODO: remove this
		SONG = Song.loadFromJson('songs/lockstep');
			
		curSong = Utils.formatToSongPath(SONG.song);
		curStage = SONG.stage;

		// --- SETTING UP THE STAGE ---

		if (curStage == null)
		{
			curStage = curSong;
		}

		switch (curStage)
		{
			case 'lockstep':
				bg = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFFff609c);
				bg.screenCenter();
				add(bg);

				bgFlash = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFFfb6da6);
				bgFlash.screenCenter();
				bgFlash.visible = false;
				add(bgFlash);

				bgStrums = new FlxSprite(STRUM_X - 25, 0).makeGraphic(200, FlxG.height, 0xFFe71b75);
				parentStepper = new Stepswitcher(0, 0);

			case 'lockstep-2':
				bg = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF30ade6);
				bg.screenCenter();
				add(bg);

				bgFlash = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF1194cf);
				bgFlash.screenCenter();
				bgFlash.visible = false;
				add(bgFlash);

				bgStrums = new FlxSprite(STRUM_X - 30, 0).makeGraphic(200, FlxG.height, 0xFF009c93);
				parentStepper = new Stepswitcher(0, 0, "-blue");
		}

		bgSteppers = new FlxTypedGroup();
		fgSteppers = new FlxTypedGroup();

		add(bgSteppers);

		if (ClientPrefs.lowQuality)
		{
			POPULATION = 3;		// wtf :'(
		}

		var playerIndex = Std.int(POPULATION / 2);
		var cycle = (PER_ROW * 2) - 1;

		for (i in 0...POPULATION) {

			// first adjust position of parent stepper
			if (i == 0)
			{
				// do literally nothing dumbass
			} 
			else if (i % cycle == 0) 			// first stepper in odd row
			{				
				parentStepper.x = 0;
				parentStepper.y += OFFSET_Y;
			} 
			else if (i % cycle == PER_ROW)		// first stepper in even row
			{			
				parentStepper.x = 0 + (OFFSET_X / 2);
				parentStepper.y += OFFSET_Y;
			} 
			else 								// regular boys :)
			{
				parentStepper.x += OFFSET_X;
			}

			// then clone and add the new stepper
			if (i == playerIndex)				// this is the player, give it a special var
			{
				playableStepper = parentStepper.clone();
				add(playableStepper);
			} 
			else if (i < playerIndex) 			// behind the player
			{
				bgSteppers.add(parentStepper.clone());
			} 
			else 								// in front
			{
				fgSteppers.add(parentStepper.clone());
			}
		}

		add(fgSteppers);

		camera.focusOn(new FlxPoint(playableStepper.getGraphicMidpoint().x, playableStepper.getGraphicMidpoint().y));

		// --- SETTING UP THE HUD ---

		scoreText = new FlxText(10, 10);
		scoreText.setFormat('VCR OSD Mono', 32, 0xFFFFFFFF, null, OUTLINE, 0xFF000000);
		add(scoreText);
		
		scoreText.cameras = [camHud];

		// strums and notes on a separate camera

		add(bgStrums);

		playerStrum = new StrumNote(STRUM_X, STRUM_Y);
		add(playerStrum);

		notes = new FlxTypedGroup();
		add(notes);

		bgStrums.cameras = [camStrums];
		playerStrum.cameras = [camStrums];
		notes.cameras = [camStrums];

		generateSong();
	}

	function generateSong()
	{
		// read the chart and figure out the notes beforehand
		var noteData:Array<SwagSection> = SONG.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var strumTime:Float = songNotes[0];
				var direction:Int = Std.int(songNotes[1] % 2);
				var mustHit:Bool = true;

				if (songNotes[1] > 3) // TODO: fix this later
				{
					mustHit = false;
				}

				var newNote:Note = new Note(strumTime, direction, mustHit);
				newNote.visible = newNote.mustHit;
				unspawnedNotes.push(newNote);
			}
		}

		unspawnedNotes.sort(Utils.sortByStrumTime);
		songPlaying = true;

		// begin the song
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		FlxG.sound.playMusic(Paths.inst(curSong), 1, false);
		FlxG.sound.music.onComplete = endSong;
	}

	function endSong()
	{
		songPlaying = false;

		FlxTween.tween(camHud, { x: -FlxG.width }, 1, { ease: FlxEase.circIn });

		if (true) // TODO: ClientPrefs.easyMode;
		{
			FlxTween.tween(camStrums, { x: FlxG.width }, 1, { ease: FlxEase.circIn });
		}

		trace('SONG FINISHED');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// spawn notes as needed
		if (unspawnedNotes[0] != null)
		{
			var spawnTime:Float = 2000;
			spawnTime /= SONG.speed;

			while (unspawnedNotes.length > 0 && unspawnedNotes[0].strumTime - Conductor.songPosition < spawnTime)
			{
				var dunceNote:Note = unspawnedNotes.splice(0, 1)[0];
				notes.add(dunceNote);

				if (dunceNote.mustHit)
				{
					songTotalNotes++;
				}
			}
		}

		if (songPlaying)
		{
			// do hitreg
			notes.forEachAlive(function(note:Note)
			{
				note.x = STRUM_X;
				note.y = STRUM_Y + 0.5 * (Conductor.songPosition - note.strumTime) * SONG.speed;

				if (!note.mustHit && note.wasGoodHit)		// bot notes that were hit
				{
					var animToPlay:String = '';
					switch (note.direction)
					{
						case 0:
							animToPlay = 'singLEFT';
						case 1:
							animToPlay = 'singRIGHT';
					}

					bgSteppers.forEach(function(stepper) 
					{
						stepper.playAnim(animToPlay, true);
					});
					
					fgSteppers.forEach(function(stepper) 
					{
						stepper.playAnim(animToPlay, true);
					});

					notes.remove(note, true).destroy();
				}
				
				if (note.mustHit && note.tooLate && !note.wasGoodHit)		// player notes that weren't hit
				{
					songMisses++;

					FlxG.sound.play(Paths.soundRandom('missnote', 3), 0.3);

					switch (note.direction)
					{
						case 0:
							playableStepper.playAnim('singLEFTmiss', true);
						case 1:
							playableStepper.playAnim('singRIGHTmiss', true);
					}

					notes.remove(note, true).destroy();
				}
			});

			if (finishedCountdown)
			{
				playerInput();
			}
		}

		var songHits:Int = songTotalNotes - songMisses;
		songAccuracy = Utils.boundTo(songHits / songTotalNotes, 0, 1);

		if (songAccuracy < 1)
		{
			for (i in 0...RATINGS.length - 1)
			{
				if (songAccuracy < RATINGS[i][1]) 
				{
					songRating = RATINGS[i][0];
					break;
				}
			}
		}

		scoreText.text = 'Rating: ${songRating} (${Math.floor(songAccuracy * 100)})';
	}

	function playerInput()
	{
		var controlPressed:Bool = FlxG.keys.anyJustPressed([inputKey, inputKeyAlt]);

		if (controlPressed)
		{
			// reset
			var hittableNotes:Array<Note> = [];

			// look for hittable notes on screen
			notes.forEachAlive(function(note:Note)
			{
				if (note.mustHit && note.canBeHit && !note.wasGoodHit) 
				{
					hittableNotes.push(note);
				}
			});
			
			// hit the closest one if it exists or it was a mispress
			if (hittableNotes.length > 0) 
			{
				hittableNotes.sort(Utils.sortByStrumTime);
				goodNoteHit(hittableNotes[0]);
			}
			else
			{
				noteMiss(notes.getFirstAlive());
			}
		}
	}

	function goodNoteHit(note:Note)
	{
		note.wasGoodHit = true;

		switch (note.direction)
		{
			case 0:
				playableStepper.playAnim('singLEFT', true);
			case 1:
				playableStepper.playAnim('singRIGHT', true);
		}

		playerStrum.playAnim('confirm', true);

		notes.remove(note, true).destroy();
	}

	function noteMiss(?note:Note)
	{
		songMisses++;

		FlxG.sound.play(Paths.soundRandom('missnote', 3), 0.3);
		
		var direction = Std.random(2);

		if (note != null)
		{
			direction = note.direction;
		}

		switch (direction)
		{
			case 0:
				playableStepper.playAnim('singLEFT', true);
			case 1:
				playableStepper.playAnim('singRIGHT', true);
		}

		if (playerStrum.animation.curAnim.name != 'confirm') 
		{
			playerStrum.playAnim('pressed', true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		switch (curBeat)
		{
			case 8 | 12:
				FlxG.sound.play(Paths.sound('intro3'), 0.6);

			case 10 | 13: 
				FlxG.sound.play(Paths.sound('intro2'), 0.6);
			
			case 14:
				FlxG.sound.play(Paths.sound('intro1'), 0.6);

			case 15:
				FlxG.sound.play(Paths.sound('introGo'), 0.6);
				finishedCountdown = true;
			
		}

		if (curBeat < 16) 
		{
			if (curBeat >= 12 || curBeat % 2 == 0)
			{
				playableStepper.playAnim('bop');

				bgSteppers.forEach(function(stepper) 
				{
					stepper.playAnim('bop', true);
				});

				fgSteppers.forEach(function(stepper)
				{
					stepper.playAnim('bop', true);
				});
			}
		}

		if (curBeat == 12) 
		{
			FlxTween.tween(camHud, { x: 0 }, 1, { ease: FlxEase.circOut });

			if (true) // TODO: ClientPrefs.easyMode;
			{
				FlxTween.tween(camStrums, { x: 0 }, 1, { ease: FlxEase.circOut });
			}
		}
	}
}