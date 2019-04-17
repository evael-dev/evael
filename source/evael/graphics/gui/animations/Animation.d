module evael.graphics.gui.animations.Animation;

import evael.graphics.gui.controls.Control;

/**
 * Animation.
 */
abstract class Animation
{
	public enum Status : ubyte
	{
		Waiting,
		Playing,
		Finished
	}

	protected alias OnAnimationStart = void delegate(Animation);
	protected alias OnAnimationEnd = void delegate(Animation);

	protected OnAnimationStart m_onAnimationStart;
	protected OnAnimationEnd m_onAnimationEnd;

	/// Animation duration in ms
	protected float m_duration;

	/// Animation status
	protected Status m_status;

	protected Control m_control;

	private uint m_id;

	@nogc @safe
	public this() pure nothrow
	{
		this.m_status = Status.Waiting;
		this.m_duration = 1000.0f;
	}

	public abstract void update(in float deltaTime);

	@nogc @safe
	public void reset() pure nothrow
	{
		this.m_status = Status.Waiting;
	}

	public void onAnimationStart()
	{
		this.m_status = Status.Playing;

		if (this.m_onAnimationStart !is null)
		{
			this.m_onAnimationStart(this);
		}
	}

	public void onAnimationEnd()
	{
		this.m_status = Status.Finished;

		if (this.m_onAnimationEnd !is null)
		{
			this.m_onAnimationEnd(this);
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public void duration(in float value)
		{
			this.m_duration = value;
		}

		public void control(Control value)
		{
			this.m_control = value;
		}

		public Status status() const
		{
			return this.m_status;
		}

		public void onAnimationStartEvent(OnAnimationStart value)
		{
			this.m_onAnimationStart = value;
		}

		public void onAnimationEndEvent(OnAnimationEnd value)
		{
			this.m_onAnimationEnd = value;
		}

		package void id(in uint value)
		{
			this.m_id = value;
		}

		package uint id() const
		{
			return this.m_id;
		}
	}
}