module evael.graphics.GraphicsDevice;

debug 
{
	import std.stdio;
	import std.format;
} 

public import evael.graphics.GL;
public import derelict.nanovg.nanovg;

import evael.graphics.GL;
import evael.graphics.shaders.Shader;
import evael.graphics.shaders.BasicShader;
import evael.graphics.shaders.BasicLightShader;
import evael.graphics.Drawable;
import evael.graphics.Vertex;
import evael.graphics.Texture;
import evael.graphics.FrameBuffer;
import evael.graphics.Font;
import evael.graphics.lights;
import evael.graphics.shapes;
import evael.graphics.Environment;

import evael.system.AssetLoader;

import evael.utils.Singleton;
import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Color;

import dnogc.DynamicArray;

/**
 * GraphicsDevice
 */
class GraphicsDevice
{
	mixin Singleton!();

	/// Asset loader
	private AssetLoader m_assetLoader;

	/// Nanovg context
	private NVGcontext* m_nvg;

	private Size!int m_viewportSize;
    
    /// Game resolution
    private Size!int m_resolution;
    
	/// Matrixes
	private mat4 m_viewMatrix, m_projectionMatrix;
	private mat4 m_2DprojectionMatrix;

	/// Current enabled shader
	private Shader m_currentShader;

	private Shader m_2dShader;

	/// Vertices display mode
	private PolygonMode m_polygonMode;

	/// Projection type
	private ProjectionType m_projectionType;

    /// List of VAOs
    private DynamicArray!uint m_vaos;
    
	/// List of generated buffers
	private DynamicArray!uint m_buffers;	

	private DynamicArray!FrameBuffer m_frameBuffers;

	/// Default font
	private Font m_defaultFont;

	/// Environment
	private Environment m_environment;

	private Circle m_circle;

	/// Shapes vao (lines, circles)
	private uint m_shapesVAO;
	private uint m_shapesVBO;

	/**
	 * GraphicsDevice constructor.
	 */
	private this()
	{
		this.m_nvg = nvgCreateGL3(NVGcreateFlags.NVG_STENCIL_STROKES | NVGcreateFlags.NVG_DEBUG);

		this.m_assetLoader = AssetLoader.getInstance();

		this.m_polygonMode = PolygonMode.Fill;
		this.resolution = Size!int(1024, 768);

		this.initializeOpenGL();
		this.initialize2DProjection(this.m_viewportSize);
		this.initializePerspectiveProjection(60.0f);

		this.m_environment = new Environment(this);

		this.m_circle = new Circle(this, 16, 1);
		this.m_circle.shader = this.m_assetLoader.load!(BasicLightShader)("colored_primitive");
		this.m_circle.initialize();

		this.m_shapesVAO = this.generateVAO();
		this.m_shapesVBO = this.createVertexBuffer(VertexPositionColor!3.sizeof * 2, null);
		this.setVertexBuffer!(VertexPositionColor!3)(this.m_shapesVBO);		

		this.bindVAO(0);
	}

	/**
	 * GraphicsDevice destructor.
	 */
	public void dispose()
	{
		foreach(id; this.m_buffers)
		{
			gl.DeleteBuffers(1, &id);
		}

		foreach(fb; this.m_frameBuffers)
		{
            fb.dispose();
		}

        foreach(vao; this.m_vaos)
        {
            gl.DeleteVertexArrays(1, &vao);
        }
        
		this.m_buffers.dispose();
		this.m_frameBuffers.dispose();
		this.m_vaos.dispose();

		nvgDeleteGL3(this.m_nvg);
	}

	/**
	 * Initializes Opengl.
	 */
	@nogc
	private void initializeOpenGL() const nothrow
	{
   	 	gl.ClearDepth(1.0f);

   		gl.Enable(GL_BLEND);
        gl.Enable(GL_DEPTH_TEST);
		gl.Enable(GL_MULTISAMPLE); 
            
		gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	/**
	 * Initializes a perspective projection.
	 * Params:
	 *		fov:
	 * 		nearPlane:
	 * 		farPlane:	
	 */
	public void initializePerspectiveProjection(in float fov, in float nearPlane = 0.1f, in float farPlane = 2000.0f)
	{
		this.m_projectionType = ProjectionType.Perspective;
		this.m_projectionMatrix = perspectiveMatrix(cast(float)fov, this.m_viewportSize.width / this.m_viewportSize.height, nearPlane, farPlane);
	}
	
	/**
	 * Initializes an orthographic projection.
	 * Params:
	 */
	public void initializeOrthographicProjection(
		in float left, in float right, in float bottom, in float top, in float near = -2000.0f, in float far = 2000.0f
	)
	{
		this.m_projectionType = ProjectionType.Orthographic;
		this.m_projectionMatrix = orthoMatrix(
			cast(float)left, cast(float)right, cast(float)bottom, cast(float)top,
			cast(float)near, cast(float)far
		);
	}

	/**
	 * Begin drawing.
	 * Params:
	 *		color : clear color
	 */
	@nogc
	public void beginScene(in Color color = Color.Black) const nothrow
	{
		gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		auto colorf = color.asFloat();
		gl.ClearColor(colorf[0], colorf[1], colorf[2], 1.0f); 
	}


	/**
	 * Renders a circle.
	 */
	public void drawCircle()(in float deltaTime, in auto ref vec3 position, in uint radius)
	{
		this.m_circle.position = position;
		this.m_circle.scale = radius;
		this.m_circle.draw(deltaTime);
	}

	/**
	 * Renders a line.
	 */
	public void drawLine()(in auto ref vec3 a, in auto ref vec3 b) 
	{
		this.bindTexture(0);
		auto shader = this.m_assetLoader.load!(BasicLightShader)("colored_primitive");

		this.enableShader(shader);

		auto vertices =
		[
			VertexPositionColor!3(a, Color.Red),
			VertexPositionColor!3(b, Color.Red),			
		];

		this.sendVertexBufferData(this.m_shapesVBO, 0, VertexPositionColor!3.sizeof * vertices.length, vertices.ptr);

		this.setMatrix(shader.modelMatrix, mat4.identity.arrayof.ptr);
		this.setMatrix(shader.viewMatrix, this.m_viewMatrix.arrayof.ptr);
		this.setProjectionMatrix();

		this.bindVAO(this.m_shapesVAO);

		this.drawPrimitives!(PrimitiveType.Lines)(1);

		this.bindVAO(0);

		this.disableShader();
	}

	/**
	 * Renders primitives.
	 * Params: http://www.opengl.org/sdk/docs/man/html/glDrawArrays.xhtml
	 */
	@nogc
	public void drawPrimitives(PrimitiveType type)(in int count, in int first = 0) const nothrow
	{
		static if(type == PrimitiveType.Triangle) 
		{
			gl.DrawArrays(type, first, count * 3);
		}
		else if(type == PrimitiveType.Lines)
		{
			gl.DrawArrays(type, first, count * 2);
		}
		else gl.DrawArrays(type, first, count);
	}

	/**
	 * Renders indexed primitives.
	 * Params: https://www.opengl.org/sdk/docs/man/html/glDrawElements.xhtml
	 */
	@nogc
	public void drawIndexedPrimitives(PrimitiveType type)(in int count, in void* offset) const nothrow
	{
		static if(type == PrimitiveType.Triangle)
		{ 
			gl.DrawElements(type, count * 3, GL_UNSIGNED_INT, offset);
		}
		else gl.DrawElements(type, count, GL_UNSIGNED_INT, offset);
	}
	
	@nogc
	public void drawIndexedPrimitives(PrimitiveType type)(in int count, in int offset = 0) const nothrow
	{
		this.drawIndexedPrimitives!(type)(count, cast(void*)offset);
	}

    /**
     * Generates a vertex array object.
     */
	@nogc
    public uint generateVAO() nothrow
    {
        uint id;
        gl.GenVertexArrays(1, &id); 
        gl.BindVertexArray(id);
        
        this.m_vaos ~= id;
        
        return id;
    }
    
	/**
	 * Generates a buffer object.
	 * Params:
	 *		type : buffer object type
	 */
	@nogc
    public uint generateBuffer(BufferType type) nothrow
	{
		uint id;
		gl.GenBuffers(1, &id);
		gl.BindBuffer(type, id);

		this.m_buffers ~= id;

		return id;
	}
    
	/**
	 * Generates multiple vertex buffer objects.
	 * Params:
	 *		type : buffer object type
	 *		count : count
	 * Todo: nogc
	 */
	/*@nogc*/ 
    public uint[] generateBuffers(BufferType type, in int count) nothrow
	{
		uint[] ids = new uint[count];
		gl.GenBuffers(count, ids.ptr);

		foreach (id; ids)
		{
			this.m_buffers ~= id;
		}

		return ids;
	}
    
	/**
	 * Generates a buffer object and send data.
	 * Params:
	 *		type : buffer object type
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public uint createBuffer(BufferType type, in int size, in void* data, BufferUsage usage = BufferUsage.StaticDraw) nothrow
	{
		immutable uint id = this.generateBuffer(type);

		gl.BufferData(type, size, data, usage);

		return id;
	}

	/**
	 * Creates a frame buffet object.
	 * Params:
	 *		width : 
	 *		height : 
	 */
	public T createFrameBuffer(T)(in int width, in int height) nothrow
	{
		auto frameBuffer = new T(this, width, height);

		this.m_frameBuffers ~= frameBuffer;

		gl.BindFramebuffer(GL_FRAMEBUFFER, 0);  

		return frameBuffer;
	}

	/**
	 * Creates a vertex buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public uint createVertexBuffer(in int size, in void* data, BufferUsage usage = BufferUsage.StaticDraw) nothrow
	{
		return this.createBuffer(BufferType.VertexBuffer, size, data, usage);
	}
	
	/**
	 * Creates an index buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 */
	@nogc
	public uint createIndexBuffer(in int size, in void* data) nothrow
	{
		return this.createBuffer(BufferType.IndexBuffer, size, data);
	}

	/**
	 * Deletes a buffer object.
	 * Params:
	 *		id : buffer id
	 */
	public void deleteBuffer(in uint id)
	{
		gl.DeleteBuffers(1, &id);

		foreach (i, bufferId; this.m_buffers)
		{
			if(bufferId == id)
			{
				this.m_buffers.remove(i);
				break;
			}
		}
	}

	/**
	 * Allocates and sends data to a vertex buffer object.
	 * Params:
	 *		vbo : vertex buffer object
	 *		data : data to send
	 */
	@nogc
	public uint allocVertexBufferData(in uint id, in int size, in void* data, BufferUsage usage = BufferUsage.StaticDraw) const nothrow
	{
		this.bindVertexBuffer(id);
		gl.BufferData(BufferType.VertexBuffer, size, data, usage);

		return size;
	}


	/**
	 * Sends data to vertex buffer object.
	 * Params:
	 *		 vbo : vertex buffer object
	 *		 data : data to send
	 */
	@nogc
	public uint sendVertexBufferData(in uint id, in uint offset, in uint size, in void* data) const nothrow
	{
		this.bindVertexBuffer(id);
		gl.BufferSubData(BufferType.VertexBuffer, offset, size, data);

		return offset + size;
	}

	/**
	 * Binds a vertex buffer object for the next drawing operation.
	 * Params:
	 *		vbo : vertex buffer object to bind
	 */
	@nogc
	public void setVertexBuffer(T, int line = __LINE__, string file = __FILE__)(in uint id) const nothrow
	{
		this.bindVertexBuffer(id);

		enum size = mixin(T.stringof ~ ".sizeof");
		
		T* nullStruct = null;

		foreach (i, member; __traits(allMembers, T))
		{
			static if (member == "opAssign")
			{
				continue;
			}
			else
			{
				enum UDAs = __traits(getAttributes, mixin(T.stringof ~ "." ~ member));

				static assert(UDAs.length > 0, "You need to specify UDA for member " ~ T.stringof ~ "." ~ member);

				enum shaderAttribute = UDAs[0];

				static if(is(typeof(shaderAttribute) : ShaderAttribute))
				{
					void* offset = i == 0 ? null : mixin("&nullStruct." ~ member);
					
					gl.EnableVertexAttribArray(shaderAttribute.layoutIndex);
					gl.VertexAttribPointer(
						shaderAttribute.layoutIndex, 
						shaderAttribute.size, 
						shaderAttribute.type, 
						shaderAttribute.normalized, 
						size, offset
					);

					version(GLDebug) 
					{
						pragma(msg, "%s:%d : gl.VertexAttribPointer(%d, %d, %d, %d, %d, %d);".format(file, line, shaderAttribute.layoutIndex,
							shaderAttribute.size, 
							shaderAttribute.type, 
							shaderAttribute.normalized, 
							size, 0
						));
					}
				}
				else 
				{
					static assert(false, "UDA defined member " ~ T.stringof ~ "." ~ member ~ " but is not of the good type.");
				}
			}
		}
	}

	/**
	 * Binds a vertex array object.
	 * Params:
	 *		id : id
	 */
	@nogc
	public void bindVAO(in uint id) const nothrow
	{
		gl.BindVertexArray(id);
	}

	/**
	 * Binds a vertex buffer object.
	 * Params:
	 *		id : id
	 */
	@nogc
	public void bindVertexBuffer(in uint id)  const nothrow
	{
		gl.BindBuffer(BufferType.VertexBuffer, id);
	}

	/**
	 * Binds an index array object.
	 * Params:
	 *		id : id
	 */
	@nogc
	public void bindIndexBuffer(in uint id) const nothrow 
	{
		gl.BindBuffer(BufferType.IndexBuffer, id);
	}

	/**
	 * Binds a frame buffer.
	 * Params:
	 *		id : id
	 */
	@nogc
	public void bindFrameBuffer(in uint id) const nothrow
	{
		gl.BindFramebuffer(GL_FRAMEBUFFER, id);
	}

	/**
	 * Binds a vertex array object.
	 * Params:
	 *		id : id
	 */
	@nogc
	public void bindFrameBuffer(FrameBuffer frameBuffer) const nothrow
	{
		gl.BindFramebuffer(GL_FRAMEBUFFER, frameBuffer.id);
	}

	/**
	 * Enables a shader for the next drawing operation.
	 * Params:
	 *		shader : shader to enable
	 */
	@nogc
	public void enableShader(Shader shader) nothrow
	{
        gl.UseProgram(shader.programID);
		this.m_currentShader = shader;
	}

	/**
	 * Disables last used shader.
	 */
	@nogc
	public void disableShader() const nothrow
	{
        gl.UseProgram(0);
	}
	
	/**
	 * Sets environment for the next render (lights, fog...).
	 */
	@nogc
	public void setEnvironment() nothrow
	{
		this.m_environment.set();
	}

	/**
	 * Binds a texture.
	 * Params:
	 *		texture : texture to bind
	 *		target : texture type
	 */
	@nogc
	public void bindTexture(Texture texture, TextureTarget target = TextureTarget.Texture2D) const nothrow
	{
		assert(texture !is null);
		gl.BindTexture(target, texture.id);
	}

	/**
	 * Binds a texture.
	 * Params:
	 *		textureId : texture to bind
	 *		target : texture type
	 */
	@nogc
	public void bindTexture(in uint textureId, TextureTarget target = TextureTarget.Texture2D) const nothrow
	{
		gl.BindTexture(target, textureId);
	}

	/**
	 * Unbinds last used texture.
	 * Params:
	 *		 target : texture type
	 */
	@nogc
	public void clearTexture(TextureTarget target = TextureTarget.Texture2D) const nothrow
	{
		gl.BindTexture(target, 0);
	}

	/**
	 * Enables GL capability.
	 */
	@nogc
	public void enable(in uint target) const nothrow
	{
		gl.Enable(target);
	}

	/**
	 * Disables GL capability.
	 */
	@nogc
	public void disable(in uint target) const nothrow
	{
		gl.Disable(target);
	}

	/**
	 * Switch display mode of vertices.
	 */
	@nogc
	public void switchPolygonMode() nothrow
	{
		final switch(this.m_polygonMode)
		{
			case PolygonMode.Fill:
				this.m_polygonMode = PolygonMode.Line;
				break;
			case PolygonMode.Line:
				this.m_polygonMode = PolygonMode.Point;
				break;
			case PolygonMode.Point:
				this.m_polygonMode = PolygonMode.Fill;
				break;
		}

		gl.PolygonMode(GL_FRONT_AND_BACK, this.m_polygonMode);
	}
	
	/**
	 * Converts screen coordinates to world coordinates.
	 * Params:
	 * 		mousePosition : mouse position
	 */
	@nogc
	public vec3 getWorldCoordinates(in ref vec2 mousePosition) nothrow
	{
		immutable mouseY = this.m_resolution.height - mousePosition.y; 

		float z;
		gl.ReadPixels(cast(int)mousePosition.x, cast(int)mouseY, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &z);
		mat4 A = this.m_projectionMatrix * this.viewMatrix;
		A.invert();
		vec4 i;

		/* Map x and y from window coordinates */
		i.x = mousePosition.x;
		i.y = mouseY;
		i.z = z;
		i.w = 1.0f;

		i.x = i.x / this.m_viewportSize.width;
		i.y = i.y / this.m_viewportSize.height;

		/* Map to range -1 to 1 */
		i.x = i.x * 2 - 1;
		i.y = i.y * 2 - 1;
		i.z = i.z * 2 - 1;

		vec4 o = i * A;

		o.x = o.x / o.w;
		o.y = o.y / o.w;
		o.z = o.z / o.w;

		return vec3(o.x, o.y, o.z);
	}

	/**
	 * Converts world coordinates to screen coordinates.
	 * Params:
	 * 		mousePosition : mouse position
	 * Credits: http://stackoverflow.com/questions/7748357/converting-3d-position-to-2d-screen-position
	 */
	@nogc
	public vec2 getScreenCoordinates(in ref vec3 position) nothrow
	{
		auto pos = position * this.m_viewMatrix;
		pos = pos * this.m_projectionMatrix;
		
      	pos.x = this.m_viewportSize.width * (pos.x + 1.0) / 2.0;
        pos.y = this.m_viewportSize.height * (1.0 - ( (pos.y + 1.0) / 2.0) );

		return vec2(pos.x, pos.y);
	}
										  
	/**
	 * Renders text using default font.
	 * Params :
	 *		text : text to draw
	 *		x :
	 *		y : 
	 */
	public void drawText()(in wstring text, in float x, in float y, in auto ref color = Color.Black) 
	{
		this.m_defaultFont.draw(text, x , y, color, 20);
	}

	/**
	 * Sends values to current shader.
	 * Params:
			 T : gl uniform name
			 U : values types
			 data : values
	 */
	public void setUniform(string T, U)(in int uniformLocation, in U* data, in size_t count, bool normalized = false) const
	{
		mixin("gl.Uniform" ~ T ~ "(uniformLocation, count, normalized, data);");
	}

	public void setUniform(string T, U)(in int uniformLocation, in U* data, in size_t count = 1) const
	{
		mixin("gl.Uniform" ~ T ~ "(uniformLocation, count, data);");
	}

	public void setUniform(string T, U)(in int uniformLocation, in U data) const
	{
		mixin("gl.Uniform" ~ T ~ "(uniformLocation, data);");
	}

	@nogc
    public void setMatrix(U)(in int location, in U* data, in size_t count = 1, in bool transposed = false) const nothrow
    {
		gl.UniformMatrix4fv(location, count, transposed, data);
    }
	
	/**
	 * Sets default projection matrix.
	 */
	@nogc
	public void setProjectionMatrix() nothrow
	{
		assert(this.m_currentShader !is null, "Trying to set projection matrix on null shader.");
		this.setMatrix(this.m_currentShader.projectionMatrix, this.m_projectionMatrix.arrayof.ptr, 1, false);
	}

	/**
	 * Sets viewport.
	 * Params:
	 *		width : viewport width
	 *		height : viewport height
	 */
	@nogc
	public void setViewport(in int width, in int height) const nothrow
	{
		gl.Viewport(0, 0, width, height);
	}
    
	/**
	 * Sets viewport.
	 * Params:
	 *		size : viewport size
	 */
	@nogc
	public void setViewport(in ref Size!int size) const nothrow
	{
		gl.Viewport(0, 0, size.width, size.height);
	}

	/**
	 * Sets viewport.
	 * Params:
	 *		position : viewport position
	 *		size : viewport size
	 */
	@nogc
	public void setViewport(V)(in ref V position, in ref Size!int size) const nothrow
		if(is(V : vec2) || is(V : ivec2))
	{
		gl.Viewport(position.x, position.y, size.width, size.height);
	}

	/**
	 * Resets viewport to its initial size.
	 */
	@nogc
	public void resetViewport() const nothrow
	{
		this.setViewport(this.m_viewportSize);
	}

	@nogc
	public void initialize2DProjection(T)(in ref T viewportSize) nothrow
	{
		this.m_2DprojectionMatrix = orthoMatrix(
			cast(float)0, cast(float)viewportSize.width, cast(float)0, cast(float)viewportSize.height, cast(float)-5,cast(float) 5
		);
	}

	@nogc
	public void initialize2DProjection(V, S)(in ref V position, in ref S viewportSize) nothrow
		if(is(V : vec2) || is(V : ivec2) && is(S : Size!int) || is(S : Size!float))
	{
		this.m_2DprojectionMatrix = orthoMatrix(position.x, viewportSize.width, position.y, viewportSize.height, -5, 5);
	}

	/**
	 * Resets 2d projection (GUI) to the default value.
	 */
	@nogc
	public void reset2DProjection() nothrow
	{
		this.initialize2DProjection(this.m_viewportSize);
	}

	/**
	 * Properties
	 */
	@nogc
	@property nothrow
	{
		public NVGcontext* nvgContext()
		{
			return this.m_nvg;
		}
		
		public mat4 viewMatrix() const
		{
			return this.m_viewMatrix;
		}

		public void viewMatrix(mat4 value)
		{
			this.m_viewMatrix = value;
		}
	
		public mat4 projectionMatrix() const
		{
			return this.m_projectionMatrix;
		}

		public mat4 GUIprojectionMatrix() const
		{ 
			return this.m_2DprojectionMatrix;
		}

		public void projectionType(ProjectionType value)
		{
			this.m_projectionType = value;
		}

		public ref const(Size!int) viewportSize() const
		{
			return this.m_viewportSize;
		}


		public Font defaultFont()
		{
			return this.m_defaultFont;
		}

		public void defaultFont(Font value)
		{
			this.m_defaultFont = value;
		}

    	public ref const(Size!int) resolution() const
		{
			return this.m_resolution;
		}
		
		public void resolution(in Size!int value)
		{
			this.m_resolution = value;
			this.m_viewportSize = value;

			this.setViewport(value);
		}

		public Environment environment()
		{
			return this.m_environment;
		}

		public Shader currentShader()
		{
			return this.m_currentShader;
		}
	}

} 