module evael.graphics.gui.animations.TranslationAnimation;

import evael.graphics.gui.animations.Animation;
import evael.graphics.gui.controls.Control;

import dlib.math.vector;

/**
 * TranslationAnimation.
 */
class TranslationAnimation : Animation
{
	private vec2 m_targetPosition;

	private vec2 m_translation;

	private float m_incX, m_incY;

	@nogc @safe
	public this()(in auto ref vec2 translation) pure nothrow
	{
		super();

		this.m_translation = translation;
		this.m_incX = 0.0f;
		this.m_incY = 0.0f;
	}

	public override void update(in float deltaTime)
	{
		if (this.m_status != Status.Playing)
		{
			this.onAnimationStart();

			this.m_targetPosition = this.m_control.realPosition + this.m_translation;

			// ( pxPerUpdate ) * deltaTime
			this.m_incX = ( (this.m_targetPosition.x - this.m_control.realPosition.x) / (this.m_duration) ) * deltaTime;
			this.m_incY = ( (this.m_targetPosition.y - this.m_control.realPosition.y) / (this.m_duration) ) * deltaTime;
		}

		auto position = this.m_control.realPosition;

		this.m_control.realPosition = vec2(position.x + this.m_incX, position.y + this.m_incY);
	
		import std.math;
		
		// We check if we reached the target position
		if (approxEqual(this.m_control.realPosition.x, this.m_targetPosition.x) 
			&& approxEqual(this.m_control.realPosition.y, this.m_targetPosition.y))
		{
			this.m_control.realPosition = this.m_targetPosition;
			
			this.onAnimationEnd();
			return;
		}
	}
}