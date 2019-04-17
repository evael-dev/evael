module evael.graphics.gui.animations.AnimationSet;

import std.typecons;

import evael.graphics.gui.animations.Animation;
import evael.graphics.gui.controls.Control;

import dnogc.DynamicArray;

/**
 * AnimationSet.
 *
 * Contains multiple animations to be played one by one or all together.
 */
class AnimationSet
{
	public enum SequenceType : ubyte
	{
		AllTogether,
		OneByOne
	}

	protected alias OnSequenceEnd = void delegate();
	protected OnSequenceEnd m_onSequenceEnd;
	
	/// Animations
	private DynamicArray!Animation m_animations;

	/// Current animation
	private uint m_currentAnimation;
	
	/// Replay animations ?
	private bool m_loop;

	/// AnimationSet sequence type (play all animations together or one by one)
	private SequenceType m_sequenceType;

	/// Animations duration in ms
	protected float m_duration;

	private Control m_control;

	/**
	 * AnimationSet constructor.
	 * Params:
	 *      loop : loop animations
	 *      sequenceType : sequence type
	 */
	@nogc @safe
	public this(in Flag!"loop" loop = No.loop, in SequenceType sequenceType = SequenceType.OneByOne) pure nothrow
	{
		this.m_currentAnimation = 0;
		this.m_loop = loop;
		this.m_sequenceType = sequenceType;
		this.m_duration = 1000.0f;
	}

	public void dispose()
	{
		this.m_animations.dispose();
	}

	public void update(in float deltaTime)
	{
		if (this.m_sequenceType == SequenceType.OneByOne)
		{
			this.m_animations[this.m_currentAnimation].update(deltaTime);
		}
		else
		{
			foreach (animation; this.m_animations)
			{
				animation.update(deltaTime);
			}
		}
	}

	/**
	 * Adds animation to the set.
	 * Params:
	 *      animation : 
	 */
	@nogc @safe
	public void add(Animation animation) pure nothrow
	{
		animation.id = this.m_animations.length;
		
		this.m_animations.insert(animation);

		animation.onAnimationEndEvent = &this.onAnimationEndEvent;
	}

	/**
	 * Event received when an animation ended.
	 */
	public void onAnimationEndEvent(Animation endedAnimation)
	{
		final switch (this.m_sequenceType) with (SequenceType)
		{
			case OneByOne: 
			{
				if (++this.m_currentAnimation != this.m_animations.length)
					return;
				
				if (this.m_loop)
				{
					this.m_currentAnimation = 0;

					foreach (animation; this.m_animations)
					{
						animation.reset();
					}
				}
				else
				{
					if (this.m_onSequenceEnd !is null)
					{
						this.m_onSequenceEnd();
					}
				}
				break;
			}
			case AllTogether:
			{
				// We are playing all animations together
				if (this.m_loop)
				{
					endedAnimation.reset();
				}
				else
				{
					import std.algorithm : countUntil;

					auto animationIndex = this.m_animations[].countUntil!(a => a == endedAnimation);

					if (animationIndex >= 0)
					{
						this.m_animations.remove(animationIndex);
					}

					if (!this.m_animations.length)
					{
						if (this.m_onSequenceEnd !is null)
						{
							this.m_onSequenceEnd();
						}
					}
				}
				break;
			}
		}
	}
	
	@nogc @safe
	@property pure nothrow
	{
		public void control(Control value)
		{
			this.m_control = value;

			foreach (animation; this.m_animations)
			{
				animation.control = value;
			}
		}

		public void duration(in float value)
		{
			this.m_duration = value;

			foreach (animation; this.m_animations)
			{
				animation.duration = value;
			}
		}

		public void onSequenceEndEvent(OnSequenceEnd value)
		{
			this.m_onSequenceEnd = value;
		}
	}
}