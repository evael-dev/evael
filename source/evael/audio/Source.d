module evael.audio.Source;

import evael.audio.AL;
import evael.audio.AudioException;

import evael.utils.math;

import evael.system.Asset;

/**
 * Source.
 */
struct Source
{
	/// Buffer id.
	private uint m_buffer;

	/// Source id.
	private uint m_id;

	/**
	 * Source constructor.
	 * Params:
	 *      id : AL source id
	 *      buffer : AL sound id
	 */
	@nogc
	public this(in uint id, in uint buffer) nothrow
	{
		this.m_id = id;
		this.m_buffer = buffer;

		this.volume = 1.0f;
		this.pitch = 1.0f;
		this.position = vec3(0);
	}
	
	/**
	 * Plays the current source.
	 */
	@nogc
	public void play() nothrow
	{
		al.Sourcei(this.m_id, AL_BUFFER, this.m_buffer);
		al.SourcePlay(this.m_id);
	}

	/**
	 * Stops current source.
	 */
	@nogc
	public void stop() nothrow
	{
		al.SourceStop(this.m_id);
	}

	/**
	 * Properties
	 */
	@nogc
	@property nothrow
	{
		public void volume(in float value) 
		{
			al.Sourcef(this.m_id, AL_GAIN, value);
		}

		public void pitch(in float value)
		{
			al.Sourcef(this.m_id, AL_PITCH, value);
		}

		public void position()(in auto ref vec3 value)
		{
			al.Source3f(this.m_id, AL_POSITION, value.x, value.y, value.z);
		}

		public void loop(in bool value)
		{
			al.Sourcei(this.m_id, AL_LOOPING, value);
		}
	}
}