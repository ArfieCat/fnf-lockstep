package;

import Song.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
using flixel.util.FlxSpriteUtil;
using StringTools;

/*
State containing the entirety of the mod's gameplay.
*/

class LockstepState extends MusicBeatState
{
    var POPULATION:Int = 473;
	var PER_ROW:Int = 32;
	var OFFSET_X:Int = 210;
	var OFFSET_Y:Int = 280;

	var STRUM_X:Int = 1180;
	var STRUM_Y:Int = 620;

	var RATINGS:Array<Dynamic> = 
	[
		['Try Again', 0.8],
		['OK', 0.9], 
		['Superb', 1],
		['Perfect', 1]
	];

	// set from menu
	public static var SONG:SwagSong;

	var curSong:String;

	var songTotalNotes:Int = 0;
	var songMisses:Int = 0;
	var songAccuracy:Float = 1;
	var songRating:String = 'Perfect';

	var camStrums:FlxCamera;	// easy mode toggle	- doesn't stay in place!
	var camHud:FlxCamera;		// hud elements
	var camOther:FlxCamera;		// overlays and substates
	var camDefaultZoom:Float = 1;

	var parentStepper:Stepswitcher;
	var playableStepper:Stepswitcher;
	var bgSteppers:FlxTypedGroup<Stepswitcher>;
	var fgSteppers:FlxTypedGroup<Stepswitcher>;
	var playerIndex:Int;

	var bg:FlxSprite;
	var bgOffbeat:FlxSprite;
	var bgStrums:FlxSprite;

	var unspawnedNotes:Array<Note> = [];
	var notes:FlxTypedGroup<Note>;
	var playerStrum:StrumNote;

	var debugText:FlxTypedGroup<FlxText>;
	var scoreText:FlxText;
	var otherText:FlxText;
	var youText:FlxText;
	var perfectText:FlxSprite;
	var fadeOut:FlxSprite;

	// FLAGS
	var songPlaying:Bool = false;
	var countdownPlaying:Bool = false;
	var canMiss:Bool = true;			// disable misses (and pausing) before countdown and during fade out.

	override function create()
	{
		super.create();
 
		FlxG.sound.music.stop();
		FlxG.fixedTimestep = false;

		camStrums = new FlxCamera(FlxG.width);	// start off screen
		camStrums.bgColor.alpha = 0;
		FlxG.cameras.add(camStrums, false);

		camHud = new FlxCamera();
		camHud.bgColor.alpha = 0;
		FlxG.cameras.add(camHud, false);

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		if (!ClientPrefs.easyMode)
		{
			camStrums.visible = false;
			camStrums.active = false;
		}

		// TODO: remove this
		SONG = Song.loadFromJson('songs/lockstep');
		
		curSong = Utils.formatToSongPath(SONG.song);

		// --- SETTING UP THE STAGE ---

		switch (curSong)
		{
			case 'lockstep':
				bg = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFFff609c);
				add(bg);

				bgOffbeat = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFFfb6da6);
				bgOffbeat.visible = false;
				add(bgOffbeat);

				// stage unique stuff that will be added later
				bgStrums = new FlxSprite(STRUM_X - 25, 0).makeGraphic(200, FlxG.height, 0xFFe71b75);
				parentStepper = new Stepswitcher(0, 0);

			case 'lockstep-2':
				bg = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF30ade6);
				add(bg);

				bgOffbeat = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF1194cf);
				bgOffbeat.visible = false;
				add(bgOffbeat);

				bgStrums = new FlxSprite(STRUM_X - 30, 0).makeGraphic(200, FlxG.height, 0xFF009c93);
				parentStepper = new Stepswitcher(0, 0, "-blue");
		}

		// --- ADDING THE NPCS ---

		bgSteppers = new FlxTypedGroup();
		fgSteppers = new FlxTypedGroup();

		add(bgSteppers);

		if (ClientPrefs.lowQuality)
		{
			POPULATION = 3;		// wtf :'(
		}

		playerIndex = Std.int(POPULATION / 2);
		var cycle:Int = (PER_ROW * 2) - 1;

		for (i in 0...POPULATION) 
		{
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

		// screenCenter() dies when the camera isn't focused on (0, 0) apparently, thanks flixel
		bg.setPosition(camPos.x - (bg.width / 2), camPos.y - (bg.height / 2));
		bgOffbeat.setPosition(camPos.x - (bgOffbeat.width / 2), camPos.y - (bgOffbeat.height / 2));

		// --- SETTING UP THE HUD ---

		youText = new FlxText(camPos.x - 100, camPos.y - 225, 200, 'You');
		youText.setFormat('VCR OSD Mono', 64, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		youText.bold = true;
		youText.borderSize = 3;
		add(youText);

		debugText = new FlxTypedGroup();
		debugText.visible = false;
		add(debugText);

		scoreText = new FlxText(10, 10);
		scoreText.setFormat('VCR OSD Mono', 32, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		debugText.add(scoreText);

		otherText = new FlxText(10, 50);
		otherText.setFormat('VCR OSD Mono', 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		debugText.add(otherText);

		fadeOut = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		fadeOut.alpha = 0;
		add(fadeOut);

		debugText.cameras = [camHud];
		fadeOut.cameras = [camHud];

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

				// the player only uses the first two columns
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
		canMiss = false;
	
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			countdownPlaying = true;

			// begin the song
			Conductor.mapBPMChanges(SONG);
			Conductor.changeBPM(SONG.bpm);

			FlxG.sound.playMusic(Paths.inst(curSong), 1, false);
			FlxG.sound.music.onComplete = endSong;

			playAnimAll('bop', true);
			canMiss = true;

			// fade out the 'you' indicator
			FlxTween.tween(youText, { alpha: 0 }, Conductor.crochet / 500, { ease: FlxEase.circIn, 
				onComplete: function(twn:FlxTween)
				{
					youText.destroy();
				}
			});
		});
	}

	function endSong()
	{
		songPlaying = false;

		// hide the strumline
		if (ClientPrefs.easyMode)
		{
			FlxTween.tween(camera, { x: 0 }, Conductor.crochet / 500, { ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(camStrums, { x: FlxG.width }, Conductor.crochet / 500, { ease: FlxEase.circIn });
				}
			});
		}

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.6);
			MusicBeatState.switchState(new MainMenuState());
		});
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
				note.y = STRUM_Y + (0.5 * (Conductor.songPosition - note.strumTime) * SONG.speed);

				// bot notes that were hit
				if (!note.mustHit && note.wasGoodHit)
				{
					var animToPlay:String = '';

					switch (note.direction)
					{
						case 0:
							animToPlay = 'singLEFT';

						case 1:
							animToPlay = 'singRIGHT';
					}

					playAnimAll(animToPlay);
					notes.remove(note, true).destroy();
				}
				
				// player notes that weren't hit
				if (note.mustHit && note.tooLate && !note.wasGoodHit)
				{
					FlxG.sound.play(Paths.soundRandom('missnote', 3), 0.3);

					if (canMiss)
					{
						songMisses++;
					}

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

			if (!countdownPlaying)
			{
				playerInput();
			}
		}

		// reset camera zoom 
		var lerpVal:Float = Utils.boundTo(elapsed * 20, 0, 1);
		camera.zoom = FlxMath.lerp(camera.zoom, camDefaultZoom, lerpVal);

		// update debug text
		songAccuracy = Utils.boundTo((songTotalNotes - songMisses) / songTotalNotes, 0, 1);

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

		scoreText.text = 'Rating: ${songRating} (${Math.floor(songAccuracy * 10000) / 100}%)';
		otherText.text = 'Current zoom level: ${camera.zoom}';

		// check for specific keypresses
		if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) && canMiss)
		{
			FlxG.sound.pause();
			openSubState(new PauseSubstate(function()
			{
				FlxG.sound.resume();
			}));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			debugText.visible = !debugText.visible;
		}
	}

	function playerInput()
	{
		if (FlxG.keys.justPressed.SPACE)
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
		FlxG.sound.play(Paths.sound('step'), 0.6);

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
		FlxG.sound.play(Paths.soundRandom('missnote', 3), 0.3);

		if (canMiss)
		{
			songMisses++;
		}
		
		var direction:Int = Std.random(2);

		if (note != null)
		{
			direction = note.direction;
		}

		switch (direction)
		{
			case 0:
				playableStepper.playAnim('singLEFT', true);
				bgSteppers.members[bgSteppers.length - 1].playAnim('singLEFTmiss');

			case 1:
				playableStepper.playAnim('singRIGHT', true);
				fgSteppers.members[0].playAnim('singRIGHTmiss');
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

				var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/ready'));
				count.screenCenter();
				count.antialiasing = !ClientPrefs.lowQuality;
				count.cameras = [camHud];
				add(count);

				FlxTween.tween(count, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.circInOut,
					onComplete: function(twn:FlxTween)
					{
						count.destroy();
					}
				});

			case 14:
				FlxG.sound.play(Paths.sound('intro1'), 0.6);

				var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/set'));
				count.screenCenter();
				count.antialiasing = !ClientPrefs.lowQuality;
				count.cameras = [camHud];
				add(count);

				FlxTween.tween(count, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.circInOut,
					onComplete: function(twn:FlxTween)
					{
						count.destroy();
					}
				});

			case 15:
				countdownPlaying = false;
				FlxG.sound.play(Paths.sound('introGo'));

				var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/go'));
				count.screenCenter();
				count.antialiasing = !ClientPrefs.lowQuality;
				count.cameras = [camHud];
				add(count);

				FlxTween.tween(count, { alpha: 0 }, Conductor.crochet / 1000, { ease: FlxEase.circInOut,
					onComplete: function(twn:FlxTween)
					{
						count.destroy();
					}
				});
			
			case 232:
				canMiss = false;
				camera.zoom *= 1.1;
				FlxTween.tween(fadeOut, { alpha: 1 }, Conductor.crochet / 1000, { ease: FlxEase.circOut });
		}

		// intro bops
		if (curBeat < 16 && (curBeat >= 12 || curBeat % 2 == 0)) 
		{
			playAnimAll('bop', true);
		}

		// show the strumlines (delayed)
		if (curBeat == 12 && ClientPrefs.easyMode) 
		{
			FlxTween.tween(camStrums, { x: 0 }, Conductor.crochet / 500, { ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(camera, { x: -65 }, Conductor.crochet / 500, { ease: FlxEase.circInOut });
				}
			});
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
				440 | 442 | 444 | 446 | 448 | 452 | 456 | 458 | 460 | 462 |	// 'n-ha n-ha hai hai hai (ha) a-ha'
				472 | 474 | 476 | 478 | 480 | 484 | 488 | 490 | 492 | 494 |
				504 | 506 | 508 | 510 | 512 | 516 | 520 | 522 | 524 | 526 |
				552 | 554 | 556 | 558 | 560 |			// 'n-ha n-ha hai'
				592 | 596 | 600 | 604 | 606 |
				624 | 626 | 628 | 630 | 632 |
				656 | 660 | 664 | 668 | 670 |
				688 | 690 | 692 | 694 | 696 |
				752 | 756 | 760 | 764 | 766 |
				824 | 826 | 828 | 830 | 832:
					bgOffbeat.visible = !bgOffbeat.visible;
					
					if (camera.zoom - camDefaultZoom < camera.zoom * 0.02)
					{
						camera.zoom *= 1.1;
					}
			}

			switch (curStep) 
			{
				// NOOOOOOOOOOOO
				case 320 | 448 | 564 | 570 | 632 | 696 | 766 | 798:
					camDefaultZoom = 1;

				case 254 | 350 | 414 | 462 | 562 | 568 | 700 | 732 | 770 | 802:
					camDefaultZoom = 0.7;

				case 384 | 480 | 560 | 566 | 704 | 736 | 774 | 806:
					camDefaultZoom = 0.5;

				case 494 | 526 | 572 | 640 | 708 | 740 | 778 | 810:
					camDefaultZoom = 0.3;

				case 552 | 606 | 670 | 712 | 744 | 782 | 814:
					camDefaultZoom = 0.2;
			}
		}
		else if (curSong == 'lockstep-2')
		{
			switch (curStep) 
			{
				// these are technically a half-step off due to swing but i don't want to rewrite the conductor
				case 
				112 | 116 | 120 | 124 | 127 |			// 'hai hai hai a-ha'
				184 | 187 | 188 | 191 | 192 |			// 'n-ha n-ha hai'
				240 | 244 | 248 | 252 | 255 |
				312 | 315 | 316 | 319 | 320 |
				336 | 340 | 344 | 348 | 351 |
				376 | 379 | 380 | 383 | 384 |
				400 | 404 | 408 | 412 | 415 |
				440 | 443 | 444 | 447 | 448 | 452 | 456 | 459 | 460 | 463 |	// 'n-ha n-ha hai hai hai (ha) a-ha'
				472 | 475 | 476 | 479 | 480 | 484 | 488 | 491 | 492 | 495 |
				504 | 507 | 508 | 511 | 512 | 516 | 520 | 523 | 524 | 527 |
				552 | 555 | 556 | 559 | 560 |			// 'n-ha n-ha hai'
				592 | 596 | 600 | 604 | 607 |
				624 | 627 | 628 | 631 | 632 |
				656 | 660 | 664 | 668 | 671 |
				688 | 691 | 692 | 695 | 696 |
				752 | 756 | 760 | 764 | 767 |
				824 | 827 | 828 | 831 | 832:
					bgOffbeat.visible = !bgOffbeat.visible;

					if (camera.zoom - camDefaultZoom < camera.zoom * 0.02)
					{
						camera.zoom *= 1.1;
					}
			}

			switch (curStep) 
			{
				case 320 | 448 | 564 | 570 | 632 | 696 | 767 | 799:
					camDefaultZoom = 1;

				case 255 | 351 | 415 | 463 | 562 | 568 | 700 | 732 | 771 | 803:
					camDefaultZoom = 0.7;

				case 384 | 480 | 560 | 566 | 704 | 736 | 775 | 807:
					camDefaultZoom = 0.5;

				case 495 | 527 | 572 | 640 | 708 | 740 | 779 | 811:
					camDefaultZoom = 0.3;

				case 552 | 607 | 671 | 712 | 744 | 783 | 815:
					camDefaultZoom = 0.2;
			}
		}
	}

	function playAnimAll(animToPlay:String, includePlayer:Bool = false)
	{
		if (includePlayer)
		{
			playableStepper.playAnim(animToPlay, true);
		}

		bgSteppers.forEach(function(stepper) 
		{
			stepper.playAnim(animToPlay, true);
		});

		fgSteppers.forEach(function(stepper)
		{
			stepper.playAnim(animToPlay, true);
		});
	}
}