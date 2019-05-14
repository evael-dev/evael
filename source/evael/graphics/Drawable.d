module evael.graphics.Drawable;

import evael.graphics.GraphicsDevice;
import evael.graphics.Texture;
import evael.graphics.shaders.Shader;

import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Rectangle;

abstract class Drawable
{	
	protected GraphicsDevice m_graphicsDevice;
	protected Shader 	     m_shader;
	protected vec3 			 m_position;
	protected vec3 			 m_scale;
	protected Quaternionf 	 m_rotation;
	protected Size!int	     m_size;
	protected Texture 	     m_texture;
	protected bool 			 m_isVisible;
	
	protected uint m_vao, m_vertexBuffer, m_indexBuffer;

	/**
	 * Drawable constructor.
	 */
	@nogc @safe
	public this(GraphicsDevice graphicsDevice) pure nothrow
	{
		this.m_graphicsDevice = graphicsDevice;

		this.m_position = vec3(0, 0, 0);
		this.m_scale = vec3(1, 1, 1);
		this.m_rotation = Quaternionf.identity;
		this.m_isVisible = true;
	}

	@nogc @safe
	public this(in float x = 0.0f, in float y = 0.0f, in float z = 0.0f) pure nothrow
	{
		auto position = vec3(x, y, z);
		auto size = Size!int();

		this(position, size);
	}

	@nogc @safe
	public this(in float x, in float y, in float z, in Size!int size) pure nothrow
	{
		vec3 position = vec3(x, y, z);
		this(position, size);
	}

	@nogc @safe
	public this()(in ref vec3 position, in Size!int size) pure nothrow
	{
		this.m_position = position;
		this.m_size = size;
		this.m_isVisible = true;
		this.m_scale = vec3(1, 1, 1);
		this.m_rotation = Quaternionf.identity;
	}

	public abstract void draw(in float deltaTime, mat4 view, mat4 projection);

	@nogc 
	@property nothrow
	{
		public GraphicsDevice graphics()
		{	
			return this.m_graphicsDevice;
		}

		public void graphics(GraphicsDevice value)
		{	
			this.m_graphicsDevice = value;
		}

		public ref const(vec3) position() const
		{	
			return this.m_position;
		}
	
		public void position(in vec3 value)
		{	
			this.m_position = value;
		}
	
		public void scale(in float value)
		{	
			this.m_scale = vec3(value, value, value);
		}

		public ref vec3 scale()
		{	
			return this.m_scale;
		}

		public void rotation(in Quaternionf value)
		{	
			this.m_rotation = value;
		}

		public ref const(Size!int) size() const
		{	
			return this.m_size;
		}

		public void size(in Size!int value)
		{	
			this.m_size = value;
		}
	
		public Texture texture()
		{	
			return this.m_texture;
		}
	
		public void texture(Texture value)
		{	
			this.m_texture = value;
		}
		
		public bool isVisible() const
		{	
			return this.m_isVisible;
		}

		public void isVisible(in bool value)
		{
			this.m_isVisible = value;
		}	

		public uint vertexBuffer() const
		{	
			return this.m_vertexBuffer;
		}

		public Shader shader()
		{	
			return this.m_shader;
		}
	
		public void shader(Shader value)
		{
			this.m_shader = value;
		}
	}
}

