
module evael.graphics.gui.animations.FadeInAnimation;

import evael.graphics.gui.animations.AlphaAnimation;

/**
 * FadeInAnimation.
 */
class FadeInAnimation : AlphaAnimation
{
	@nogc @safe
	public this(in float to = 1.0f) pure nothrow
	{
		super(0.0f, to);
	}

	public override void onAnimationStart()
	{        
		super.onAnimationStart();

		this.m_control.show();        
	}
}