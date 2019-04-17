module evael.audio.AudioException;

class AudioFileNotFoundException : Exception
{
	public this(string msg, string file = __FILE__, size_t line = __LINE__) 
	{
		super(msg, file, line);
	}
}

class AudioUnsupportedChannelsException : Exception
{
	public this(string msg, string file = __FILE__, size_t line = __LINE__) 
	{
		super(msg, file, line);
	}
}