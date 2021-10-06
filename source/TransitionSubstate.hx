package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;

/*
Substate containing a custom fade transition.
*/

class TransitionSubstate extends MusicBeatSubstate
{
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	var finishCallback:() -> Void;

	public function new(duration:Float, isTransIn:Bool, ?finishCallback:() -> Void)
	{
		super();

		this.isTransIn = isTransIn;
		this.finishCallback = finishCallback;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var zoom:Float = Utils.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, 0xFF000000] : [0xFF000000, 0x0]));
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(width, height + 400, 0xFF000000);
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		if (isTransIn)
		{
			transGradient.y = transBlack.y - transBlack.height;

			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween) 
				{
					close();
				}
			});
		}
		else
		{
			transGradient.y = -transGradient.height;
			transBlack.y = transGradient.y - transBlack.height + 50;

			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					if (finishCallback != null)
					{
						finishCallback();
					}
				}
			});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isTransIn)
		{
			transBlack.y = transGradient.y + transGradient.height;
		} 
		else 
		{
			transBlack.y = transGradient.y - transBlack.height;
		}
	}
}