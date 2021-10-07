package;

import flixel.FlxSprite;

using StringTools;

/*
Creates Stepswitcher characters.
*/

class Stepswitcher extends FlxSprite
{    
	var animOffsets:Map<String, Array<Dynamic>>;

	var isPlayer:Bool;
	var skin:String;

	public function new(x:Float, y:Float, skin:String = '')
	{
		super(x, y);
		
		this.skin = skin;

        animOffsets = new Map();
		antialiasing = !ClientPrefs.lowQuality;

        frames = Paths.getSparrowAtlas('characters/stepswitcher' + skin);

        animation.addByPrefix('idle', 'stepswitcher idle', 30, true);
		animation.addByPrefix('bop', 'stepswitcher bop', 30, false);

        animation.addByPrefix('singLEFT', 'stepswitcher left', 30, false);
        animation.addByPrefix('singRIGHT', 'stepswitcher right', 30, false);
		animation.addByPrefix('singLEFTmiss', 'stepswitcher miss left', 30, false);
        animation.addByPrefix('singRIGHTmiss', 'stepswitcher miss right', 30, false);

		addOffset('bop', -16, 2);
		addOffset('singLEFT', 122, 8);
        addOffset('singRIGHT', -1, 8);
		addOffset('singLEFTmiss', 16, -1);
		addOffset('singRIGHTmiss', -38, -1);

        playAnim('idle');
	}

    override function clone():Stepswitcher
	{
        var clone:Stepswitcher = new Stepswitcher(this.x, this.y, this.skin);
        return clone;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
		{
			playAnim('idle');
		}
	}

	public function playAnim(anim:String, force:Bool = false)
	{
		animation.play(anim, force);

		var animOffset:Array<Dynamic> = animOffsets.get(anim);
        
		if (animOffsets.exists(anim))
		{
			offset.set(animOffset[0], animOffset[1]);
		}
		else
		{
            offset.set(0, 0);
        }
	}

	function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
