module evael.network.ClientSocket;

import std.socket;
import std.string : format;
import std.array : insertInPlace;
import std.exception : enforce;

import core.thread;

public import evael.network.Packet;

import msgpack;

class ClientSocket
{
	enum PACKET_SIZE = 4096;

	private alias void delegate(ref Packet) OnDataEvent;
	private alias void delegate() OnDisconnectedEvent;
	
	private OnDataEvent m_onDataEvent;
	private OnDisconnectedEvent m_onDisconnectedEvent;
	
	/// Socket
	private Socket m_socket;
	
	/// Main thread
	private Thread m_thread;
	
	private bool m_connected;
	
	@nogc @safe
	public this() pure nothrow
	{
		this.m_connected = false;
	}
	
	@nogc @safe
	public this(Socket socket) pure nothrow
	{
		this.m_socket = socket;
		this();
	}
	
	/**
	 * Connects to a server.
	 * Params:
	 * 		 ip : server ip address
	 * 		 port : server port
	 */
	public void connect(in string ip, in ushort port)
	{
		assert(!this.m_connected, "Client is already connected to a server.");
		
		this.m_socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
		this.m_socket.blocking(true);
		this.m_socket.connect(new InternetAddress(ip, port));
		
		enforce(this.m_socket.isAlive(), format("Unable to connect to server %s:%d.", ip, port));
		
		this.m_connected = true;
		
		this.m_thread = new Thread(&this.waitForData);
		this.m_thread.start();
	}
	
	/**
	 * Main thread.
	 */
	private void waitForData()
	{
		while(this.m_connected)
		{
			auto packet = Packet(PACKET_SIZE);

			immutable length = this.m_socket.receive(packet.data[]);
			
			if (length > 0)
			{
				packet.data.length = length;
				this.m_onDataEvent(packet);
			}
			else 
			{
				this.m_connected = false;

				if (this.m_onDisconnectedEvent !is null)
				{
					this.m_onDisconnectedEvent();
				}
			}
		}
	}
	
	/**
	 * Sends data as struct messages.
	 * Params:
	 *		 message : message to send
	 */
	public void send(T)(in auto ref T message)
	{
		ubyte[] data = message.pack();

		data.insertInPlace(0, GetAttribute!(ubyte, "OpCode", T));

		this.m_socket.send(data);
	}
	
	/**
	 * Receives data.
	 */
	public int receive(ubyte[] data)
	{
		return this.m_socket.receive(data);
	}
	
	/**
	 * Closes connection.
	 */
	public void close()
	{
		this.m_connected = false;
		
		this.m_socket.shutdown(SocketShutdown.BOTH);
		this.m_socket.close();
	}
	
	@nogc @safe
	@property pure nothrow
	{
		public bool connected() const
		{
			return this.m_connected;
		}
		
		public Socket socket()
		{
			return this.m_socket;
		}
		
		public void onDataEvent(OnDataEvent value)
		{
			this.m_onDataEvent = value;
		}
		
		public void onDisconnectedEvent(OnDisconnectedEvent value)
		{
			this.m_onDisconnectedEvent = value;
		}
	}
}


T getStruct(T)(ubyte[] data)
{
	return data.unpack!T();
}

template GetAttribute(T, string name, alias symbol)
{
	import std.string;

	T GetAttribute()
	{
		enum UDAs = __traits(getAttributes, symbol);

		static if (UDAs.length)
		{
			foreach (i, UDA; UDAs)
			{
				if (UDA.stringof.startsWith(name))
					return UDA.value;
			}
		}
		else static assert(false, "No OpCode attribute for message " ~ symbol.stringof);

		return 0;
	}
}