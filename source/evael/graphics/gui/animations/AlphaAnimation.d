module evael.graphics.gui.animations.AlphaAnimation;

import evael.graphics.gui.animations.Animation;
import evael.graphics.gui.controls.Control;

/**
 * AlphaAnimation.
 */
class AlphaAnimation : Animation
{
	private float m_fromAlpha;
	private float m_toAlpha;
	private float m_currentValue;

	private float m_inc;

	@nogc @safe
	public this(in float from = 0.0f, in float to = 1.0f) pure nothrow
	{
		super();

		this.m_currentValue = this.m_fromAlpha = from;
		this.m_toAlpha = to;
		this.m_duration = 250.0f;
	}

	public override void update(in float deltaTime)
	{
		if (this.m_status != Status.Playing)
		{
			this.onAnimationStart();
			
			this.m_inc = ( (this.m_toAlpha - this.m_fromAlpha) / this.m_duration) * deltaTime;
		}
		
		import std.math : approxEqual;

		if (approxEqual(this.m_currentValue, this.m_toAlpha, 0.01f, 0.01f))
		{
			this.onAnimationEnd();
			return;
		}

		this.m_currentValue += this.m_inc;
		
		this.m_control.opacity = cast(ubyte)(this.m_currentValue * 255);
	}

	public override void reset()
	{
		super.reset();
		
		this.m_currentValue = this.m_fromAlpha;
	}
}