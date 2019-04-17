module evael.network.Packet;

import dnogc.DynamicArray;

struct Packet
{
	public DynamicArray!ubyte data;

	@nogc
	public this(in size_t capacity)
	{
		this.data = DynamicArray!ubyte(capacity);
		this.data.length = capacity;
	}

	public void dispose()
	{
		this.data.dispose();
	}
}