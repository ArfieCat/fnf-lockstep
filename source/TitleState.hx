package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;

/*
FlxState containing the intro credits sequence and the title screen.
*/

class TitleState extends MusicBeatState
{
	var logo:FlxSprite;
	var prompt:Alphabet;

	var black:FlxSprite;
	var textGroup:FlxSpriteGroup;
	
	var quip:Array<String> = [];

	// FLAGS
	var finishedIntro:Bool = false;			// intro sequence finished or was skipped
	var selectedSomething:Bool = false;		// user has pressed enter to start

	override function create()
	{
		MusicBeatState.playTransOut = false;
		super.create();

		ClientPrefs.loadSettings('game');

		logo = new FlxSprite(0, -80);
		logo.frames = Paths.getSparrowAtlas('ui/logoBumpin');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.antialiasing = ClientPrefs.antialiasing;
		logo.screenCenter(X);
		add(logo);

		prompt = new Alphabet(0, 600, 'Press ENTER to start');
		prompt.screenCenter(X);
		add(prompt);

		if (!FlxG.save.data.seenWarning)
		{
			openSubState(new FlashingSubstate(startIntro));
		}
		else
		{
			startIntro();
		}
	}

	function startIntro()
	{
		quip = getRandomQuip();

		black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(black);

		textGroup = new FlxSpriteGroup();
		add(textGroup);

		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		FlxG.sound.music.fadeOut(3, 0.6);						// using fadeOut to fade in. genius!
		Conductor.changeBPM(102);
	}

	function skipIntro()
	{
		finishedIntro = true;
		
		FlxG.camera.flash(0xFFFFFFFF, 3);
		black.visible = false;
		textGroup.visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			if (!finishedIntro)
			{
				skipIntro();
			}
			else if (!selectedSomething)
			{
				selectedSomething = true;

				FlxG.camera.flash(0xFFFFFFFF, 1, null, true);
				FlxG.sound.play(Paths.sound('confirmMenu'));

				new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}
	}

    override function beatHit()
    {
        super.beatHit();

		logo.animation.play('bump');

		if (!finishedIntro)
		{
			switch (curBeat)
			{
				case 1:
					addText('ArfieCat', 30);
				case 3:
					addText('Presents', 30);
				case 4:
					textGroup.clear();
				case 5:
					addText('Wait', 30);
				case 7:
					addText('Is this even FNF anymore?', 30);
				case 8:
					textGroup.clear();
				case 9:
					if (quip[1] != '')
						addText(quip[0], 30);
					else
						addText(quip[0], 60);
				case 11:
					addText(quip[1], 30);
				case 12:
					textGroup.clear();
				case 13:
					addText('Friday');
				case 14:
					addText('Night');
				case 15:
					addText('Funkin\'?');
				case 16:
					skipIntro();
			}
		}
    }

	function addText(text:String, offset:Int = 0)
	{
		var newText:Alphabet = new Alphabet(0, 0, text);
		newText.screenCenter(X);
		newText.y += textGroup.length * 60 + 240 + offset;
		
		textGroup.add(newText);
	}

	function getRandomQuip():Array<String>
	{
		var allQuips:Array<String> = Utils.getTextFromFile('introText');
		var pairs:Array<Array<String>> = [];

		for (i in allQuips)
		{
			pairs.push(i.split('--'));
		}

		var quip:Array<String> = pairs[Std.random(pairs.length)];
		return quip;
	}
}
