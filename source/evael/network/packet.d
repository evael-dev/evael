module evael.network.packet;

import evael.lib.containers : Array;

struct Packet
{
	public Array!ubyte data;

	@nogc
	public this(in size_t capacity)
	{
		this.data = Array!ubyte(capacity);
		this.data.length = capacity;
	}

	@nogc
	public ~this()
	{
		this.data.dispose();
	}
}