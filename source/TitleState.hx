package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

/*
State containing the intro credits sequence and title screen.
*/

class TitleState extends MusicBeatState
{
	var logo:FlxSprite;
	var prompt:Alphabet;

	var black:FlxSprite;
	var textGroup:FlxTypedGroup<Alphabet>;
	
	var quip:Array<String> = [];

	// FLAGS
	var finishedIntro:Bool = false;
	var selectedSomething:Bool = false;

	override function create()
	{
		// no need for this fade in
		MusicBeatState.playTransOut = false;
		ClientPrefs.loadSettings();	
		
		super.create();

		logo = new FlxSprite(0, -80);
		logo.frames = Paths.getSparrowAtlas('ui/logoBumpin');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.antialiasing = !ClientPrefs.lowQuality;
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

		textGroup = new FlxTypedGroup();
		add(textGroup);

		FlxG.sound.playMusic(Paths.music('menu'), 0.3);
		FlxG.sound.music.fadeOut(3, 0.6);		// using fadeOut() to fade in. genius!
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
				FlxG.sound.play(Paths.sound('menu-confirm'));

				selectedSomething = true;
				FlxG.camera.flash(0xFFFFFFFF, 1, null, true);
				FlxFlicker.flicker(prompt, 1.5, 0.05);

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}

		// reset camera zoom 
		var lerpVal:Float = Utils.boundTo(elapsed * 10, 0, 1);
		camera.zoom = FlxMath.lerp(camera.zoom, 1, lerpVal);
	}

    override function beatHit()
    {
        super.beatHit();

		logo.animation.play('bump');

		if (!finishedIntro)
		{
			switch (curBeat)
			{
				case 4 | 8 | 12:
					clearText();

				case 1:
					camera.zoom += 0.05;
					addText('ArfieCat', 30);

				case 3:
					camera.zoom += 0.05;
					addText('Presents', 30);

				case 5:
					camera.zoom += 0.05;
					addText('Wait', 30);

				case 7:
					camera.zoom += 0.05;
					addText('Is this even FNF anymore?', 30);

				case 9:
					camera.zoom += 0.05;
					if (quip[1] != '')
					{
						addText(quip[0], 30);
					}
					else
					{
						addText(quip[0], 60);
					}

				case 11:
					if (quip[1] != '')
					{
						camera.zoom += 0.05;
						addText(quip[1], 30);
					}

				case 13:
					camera.zoom += 0.05;
					addText('Friday');

				case 14:
					camera.zoom += 0.05;
					addText('Night');

				case 15:
					camera.zoom += 0.05;
					addText('Funkin\'?');

				case 16:
					clearText();
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

	function clearText()
	{
		while (textGroup.length > 0)
		{
			textGroup.remove(textGroup.members[0], true).destroy();
		}
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
