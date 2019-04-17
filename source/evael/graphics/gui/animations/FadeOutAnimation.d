
module evael.graphics.gui.animations.FadeOutAnimation;

import evael.graphics.gui.animations.AlphaAnimation;

/**
 * FadeOutAnimation.
 */
class FadeOutAnimation : AlphaAnimation
{
	@nogc @safe
	public this(in float from = 1.0f) pure nothrow
	{
		super(from, 0.0f);
	}

	public override void onAnimationEnd()
	{
		this.m_control.hide();
		
		super.onAnimationEnd();
	}
}