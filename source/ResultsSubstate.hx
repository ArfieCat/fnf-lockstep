package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/*
Substate containing a judgement screen to be shown after the game.
*/

class ResultsSubstate extends MusicBeatSubstate
{
    var rating:String;

	var judgementText:FlxText;
	var judgementIcon:FlxSprite;

	var sound:String = '';

	var fadeOut:FlxSprite;
	
	// FLAGS
	var finishedJudgement:Bool = false;

	public function new(rating:String, closeCallback:() -> Void)
	{
		super();

        this.rating = rating;
		this.closeCallback = closeCallback;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		startJudgement();
	}

	function startJudgement()
	{
		var title:Alphabet = new Alphabet(0, 120, 'Your Partners Say...', 0.6);
		title.screenCenter(X);
		add(title);

		FlxG.sound.play(Paths.sound('pixel-text'));

		var icon:String = '';
		var quip:String = '';

		switch (rating)
		{
			case 'Try Again':
				sound = Paths.sound('try-again');
				icon = Paths.image('gameplay/try-again');
				quip = 
					"On the beat? You're a little off.\n" +
					'Offbeat? More like just plain "off."\n' +
					'Sloppy work on the transitions.\n';

			case 'OK':
				sound = Paths.sound('ok');
				icon = Paths.image('gameplay/ok');
				quip = 
					'\n' +
					'I guess that was all right.\n';

			case 'Superb' | 'Perfect':
				sound = Paths.sound('superb');
				icon = Paths.image('gameplay/superb');
				quip = 
					'You were all right on the beat.\n' +
					'You hit the offbeats pretty well.\n' +
					'Nice transitions between beats.\n';
		}

		judgementText = new FlxText(0, 240, 0, quip);
		judgementText.setFormat('VCR OSD Mono', 32, 0xFFFFFFFF, CENTER);
		judgementText.screenCenter(X);
		judgementText.visible = false;
		add(judgementText);

		judgementIcon = new FlxSprite(900, 400).loadGraphic(icon);
		judgementIcon.setGraphicSize(Std.int(judgementIcon.width * 0.8));
		judgementIcon.x -= judgementIcon.width / 2;
		judgementIcon.antialiasing = !ClientPrefs.lowQuality;
		judgementIcon.visible = false;
		add(judgementIcon);

		fadeOut = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		fadeOut.alpha = 0;
		add(fadeOut);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (!judgementText.visible)
			{
				judgementText.visible = true;
				FlxG.sound.play(Paths.sound('pixel-text'));
			}
		});

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			if (!judgementIcon.visible)
			{
				skipJudgement();
			}
		});
	}

	function skipJudgement()
	{
		finishedJudgement = true;

		judgementText.visible = true;
		judgementIcon.visible = true;

		FlxG.sound.play(sound).fadeOut(4, 0);

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			FlxTween.tween(fadeOut, { alpha: 1 }, 1, { ease: FlxEase.circOut, 
				onComplete: function(twn:FlxTween)
				{
					close();
				}
			});
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			if (!finishedJudgement)
			{
				skipJudgement();
			}
			else
			{
				close();
			}
		}
	}
}
