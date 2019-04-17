module evael.graphics.gui.animations.WizzAnimation;

import evael.graphics.gui.animations.Animation;
import evael.graphics.gui.controls.Control;

import std.random : uniform;

import dlib.math.vector;

/**
 * WizzAnimation.
 */
class WizzAnimation : Animation
{
	private float m_elapsedTime;

	private vec2 m_initialControlPosition;

	@nogc @safe
	public this() pure nothrow
	{
		super();

		this.m_elapsedTime = 0.0f;
	}

	public override void update(in float deltaTime)
	{
		if(this.m_status != Status.Playing)
		{
			this.onAnimationStart();
		}

		this.m_elapsedTime += deltaTime;

		if(this.m_elapsedTime >= this.m_duration)
		{
			this.onAnimationEnd();
			return;
		}
		
		auto newPosition = vec2(this.m_initialControlPosition.x + uniform(-5, 5), this.m_initialControlPosition.y + uniform(-5, 5));

		this.m_control.realPosition = newPosition;
	}

	public override void onAnimationStart()
	{
		this.m_initialControlPosition = this.m_control.realPosition;

		super.onAnimationStart();
	}
	
	public override void onAnimationEnd()
	{
		this.m_control.realPosition = this.m_initialControlPosition;
		
		super.onAnimationEnd();
	}

	@nogc @safe
	public override void reset() pure nothrow
	{
		super.reset();
		this.m_elapsedTime = 0;
	}
}