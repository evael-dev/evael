module evael.audio.audio_device;

import std.exception;

import evael.audio.al;

/**
 * AudioDevice
 */
class AudioDevice
{
	private ALCdevice*  m_audioDevice;
	private ALCcontext* m_audioContext;

	/**
	 * AudioDevice constructor.
	 */
	public this()
	{
		this.m_audioDevice = alcOpenDevice(null);

		enforce(this.m_audioDevice !is null, "Failed to open the audio device");

		this.m_audioContext = alcCreateContext(this.m_audioDevice, null);

		enforce(this.m_audioContext !is null, "Failed to create the audio context");

		alcMakeContextCurrent(this.m_audioContext);

		this.initialize();
	}
	
	/**
	 * AudioDevice destructor.
	 */
	@nogc
	public void dispose() nothrow
	{
		alcMakeContextCurrent(null);

		if (this.m_audioContext !is null)
		{
			alcDestroyContext(this.m_audioContext);
		}

		if (this.m_audioDevice !is null)
		{
			alcCloseDevice(this.m_audioDevice);
		}
	}

	/**
	 * Initializes the device.
	 */
	@nogc
	private void initialize() nothrow
	{
		al.Listener3f(AL_POSITION, 0, 0, 0);
		al.Listener3f(AL_VELOCITY, 0, 0, 0);
	}
}