module evael.audio.Sound;

import derelict.sndfile.sndfile;

import evael.audio.AL;
import evael.audio.Source;
import evael.audio.AudioException;

import evael.system.Asset;

import evael.utils.Config;

import dnogc.DynamicArray;

/**
 * Sound asset.
 */
class Sound : IAsset
{
	private uint m_buffer;
	
	/// List of sources for this sound.
    private DynamicArray!uint m_sources;
    
	/**
	 * Sound constructor.
	 * Params:
	 *		buffer: AL buffer id
	 */
	@nogc
	public this(in uint buffer) nothrow
	{
		this.m_buffer = buffer;
	}

	/**
	 * Sound destructor.
	 */
 	@nogc
	public void dispose() nothrow
	{
        foreach (id; this.m_sources)
        {
            al.DeleteSources(1, &id);
        }

		al.DeleteBuffers(1, &this.m_buffer);
	}

	/**
	 * Creates a new source linked to this sound resource.
	 */
	@nogc
    public Source createSource() nothrow
    {
        uint id;
		al.GenSources(1, &id);

        this.m_sources.insert(id);

        return Source(id, this.m_buffer);
    }
    
	/**
	 * Loads sound.
	 * Params:
	 *		soundName: sound to load
	 */
	public static Sound load(in string soundName)
    {
        import std.string : format, toStringz;
        
		auto fileName = toStringz(Config.Paths.sounds!string ~ soundName);

		SF_INFO fileInfo;

		auto file = sf_open(fileName, SFM_READ, &fileInfo);

		if (!file)
		{
			throw new AudioFileNotFoundException(format("Can't open file %s", soundName));
		}

		short[] samples = new short[cast(uint)fileInfo.frames];

		if (sf_read_short(file, samples.ptr, fileInfo.frames) != fileInfo.frames)
		{
			throw new Exception("Something is wrong");
		}

		auto fileFormat = getFormatFromChannelCount(fileInfo.channels);

		if (fileFormat == 0)
		{
			throw new AudioUnsupportedChannelsException(format("Can't open file %s, unsupported number of channels %d", soundName, fileInfo.channels));
		}

		uint buffer;

		// Create the buffer
		al.GenBuffers(1, &buffer);
		al.BufferData(buffer, fileFormat, samples.ptr, cast(int) (samples.length * ushort.sizeof), fileInfo.samplerate);

        return new Sound(buffer);
    }

    /**
     * Finds the sound format according to the number of channels.
     * Params:
     * 		channelCount: number of channels
     */
	@nogc
    public static int getFormatFromChannelCount(in uint channelCount) nothrow
    {
        int format;

        switch (channelCount)
        {
            case 1:  format = AL_FORMAT_MONO16;                    break;
            case 2:  format = AL_FORMAT_STEREO16;                  break;
            case 4:  format = alGetEnumValue("AL_FORMAT_QUAD16");  break;
            case 6:  format = alGetEnumValue("AL_FORMAT_51CHN16"); break;
            case 7:  format = alGetEnumValue("AL_FORMAT_61CHN16"); break;
            case 8:  format = alGetEnumValue("AL_FORMAT_71CHN16"); break;
            default: format = 0;                                   break;
        }

        return format;
    }

}
