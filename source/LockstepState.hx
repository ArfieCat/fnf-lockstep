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

		camHud = new FlxCamera();
		camHud.bgColor.alpha = 0;
		camHud.alpha = 0;
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
				add(bg);

				bgFlash = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFFfb6da6);
				bgFlash.visible = false;
				add(bgFlash);

				bgStrums = new FlxSprite(STRUM_X - 25, 0).makeGraphic(200, FlxG.height, 0xFFe71b75);
				parentStepper = new Stepswitcher(0, 0);

			case 'lockstep-2':
				bg = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF30ade6);
				add(bg);

				bgFlash = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF1194cf);
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

		var camPos:FlxPoint = new FlxPoint(playableStepper.getGraphicMidpoint().x, playableStepper.getGraphicMidpoint().y);
		camera.focusOn(camPos);

		// screenCenter() dies when the camera isn't focused on (0, 0) apparently
		bg.setPosition(camPos.x - (bg.width / 2), camPos.y - (bg.height / 2));
		bgFlash.setPosition(camPos.x - (bgFlash.width / 2), camPos.y - (bgFlash.height / 2));

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

				if (songNotes[1] > 1)
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

		FlxTween.tween(camHud, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.cubeIn });

		if (ClientPrefs.easyMode)
		{
			FlxTween.tween(camStrums, { x: FlxG.width }, Conductor.crochet / 500, { ease: FlxEase.circIn });
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

		// update accuracy

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

		scoreText.text = 'CURBEAT: ${curBeat}\nCURSTEP: ${curStep}\n';

		// check for specific keypresses

		if (FlxG.keys.justPressed.ESCAPE)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			trace('theres a beat switch around here: ' + curBeat);
		}
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

		// intro sequence

		switch (curBeat)
		{
			case 8:
				FlxG.sound.play(Paths.sound('intro3'), 0.6);

			case 10: 
				FlxG.sound.play(Paths.sound('intro2'), 0.6);
			
			case 12:
				FlxG.sound.play(Paths.sound('intro3'), 0.6);

			case 13: 
				FlxG.sound.play(Paths.sound('intro2'), 0.6);

				var count = new FlxSprite().loadGraphic(Paths.image('gameplay/ready'));
				count.screenCenter();
				count.antialiasing = ClientPrefs.antialiasing;
				count.cameras = [camHud];
				add(count);

				FlxTween.tween(count, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						count.destroy();
					}
				});
		
			case 14:
				FlxG.sound.play(Paths.sound('intro1'), 0.6);

				var count = new FlxSprite().loadGraphic(Paths.image('gameplay/set'));
				count.screenCenter();
				count.antialiasing = ClientPrefs.antialiasing;
				count.cameras = [camHud];
				add(count);

				FlxTween.tween(count, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						count.destroy();
					}
				});

			case 15:
				finishedCountdown = true;
				FlxG.sound.play(Paths.sound('introGo'), 0.6);

				var count = new FlxSprite().loadGraphic(Paths.image('gameplay/go'));
				count.screenCenter();
				count.antialiasing = ClientPrefs.antialiasing;
				count.cameras = [camHud];
				add(count);

				FlxTween.tween(count, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						count.destroy();
					}
				});
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
			FlxTween.tween(camHud, { alpha: 1 }, Conductor.crochet / 1000, { ease: FlxEase.cubeOut });

			if (ClientPrefs.easyMode)
			{
				FlxTween.tween(camStrums, { x: 0 }, Conductor.crochet / 500, { ease: FlxEase.circOut });
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		// camera zooms and bg flashes

		if (curSong == 'lockstep')
		{
			switch (curStep) 
			{
				// HAHAHAHAHAHAHAHA AAGGHHHHH AAAGGHHHHHH
				case 
				112 | 116 | 120 | 124 | 126 |			// 'hai hai hai a-ha'
				184 | 186 | 188 | 190 | 192 |			// 'n-ha n-ha hai'
				240 | 244 | 248 | 252 | 254 |
				312 | 314 | 316 | 318 | 320 |
				336 | 340 | 344 | 348 | 350 |
				376 | 378 | 380 | 382 | 384 |
				400 | 404 | 408 | 412 | 414 |
				440 | 442 | 444 | 446 | 448 | 452 | 456 | 458 | 460 | 462 |	// 'n-ha n-ha hai hai hai a-ha'
				472 | 474 | 476 | 478 | 480 | 484 | 488 | 490 | 492 | 494 |
				504 | 506 | 508 | 510 | 512 | 516 | 520 | 522 | 524 | 526 |
				552 | 554 | 556 | 558 | 560 |			// 'n-ha n-ha hai'
				592 | 596 | 600 | 604 | 606 |
				624 | 626 | 628 | 630 | 632 |
				656 | 660 | 664 | 668 | 670 |
				688 | 690 | 692 | 694 | 696 |
				752 | 756 | 760 | 764 | 766 |
				824 | 826 | 828 | 830 | 832:
					bgFlash.visible = !bgFlash.visible;
			}

			switch (curStep) 
			{
				// NOOOOOOOOOOOO
				case 320 | 448 | 568 | 580 | 632 | 696 | 766 | 798:
					camera.zoom = 1;

				case 254 | 350 | 414 | 462 | 564 | 576 | 700 | 732 | 770 | 802:
					camera.zoom = 0.8;

				case 384 | 480 | 560 | 572 | 704 | 736 | 774 | 806:
					camera.zoom = 0.6;

				case 494 | 526 | 584 | 640 | 708 | 740 | 778 | 810:
					camera.zoom = 0.4;

				case 552 | 606 | 670 | 712 | 744 | 782 | 814:
					camera.zoom = 0.3;
			}
		}
		else if (curSong == 'lockstep-2')
		{
			switch (curStep) 
			{

			}
		}
	}
}