module evael.graphics.gl;

debug import dnogc.Utils;

public import bindbc.opengl;

struct gl
{
	static string file = __FILE__;
	static int line = __LINE__;

	@nogc
	static auto ref opDispatch(string name, Args...)(Args args) nothrow
	{ 
		debug
		{
			scope (exit)
			{
				immutable uint error = glGetError();

				if (error != GL_NO_ERROR)
				{
					dln(file, ", ", line, " , gl", name, " : ", error);
				}
			}
		}

		return mixin("gl" ~ name ~ "(args)");
	}
}

public
{
	enum BufferType
	{
		VertexBuffer = GL_ARRAY_BUFFER,
		IndexBuffer  = GL_ELEMENT_ARRAY_BUFFER,
		FrameBuffer  = GL_FRAMEBUFFER
	}

	enum PrimitiveType 
	{
		Triangle      = GL_TRIANGLES,
		TriangleStrip = GL_TRIANGLE_STRIP,
		TriangleFan   = GL_TRIANGLE_FAN,
		Lines 	      = GL_LINES,
		LineStrip     = GL_LINE_STRIP,
		LineLoop 	  = GL_LINE_LOOP,
		Unfilled 	  = LineLoop,
		Circle 	      = TriangleFan,
		Points 	      = GL_POINTS
	}

	enum PolygonMode
	{
		Line = GL_LINE,
		Point = GL_POINT,
		Fill = GL_FILL
	}

	enum BufferUsage
	{
		StreamDraw  = GL_STREAM_DRAW,
		StreamRead  = GL_STREAM_READ,
		StreamCopy  = GL_STREAM_COPY,
		StaticDraw  = GL_STATIC_DRAW,
		StaticRead  = GL_STATIC_READ,
		StaticCopy  = GL_STATIC_COPY,
		DynamicDraw = GL_DYNAMIC_DRAW,
		DynamicRead = GL_DYNAMIC_READ,
		DynamicCopy = GL_DYNAMIC_COPY
	}

	enum TextureTarget
	{
		Texture2D 	     = GL_TEXTURE_2D,
		TextureRectangle = GL_TEXTURE_RECTANGLE,
		TextureArray 	 = GL_TEXTURE_2D_ARRAY
	}

	enum EnableCap
	{
		DepthTest 		 = GL_DEPTH_TEST,
		RasterizeDiscard = GL_RASTERIZER_DISCARD,
		Texture2D 		 = GL_TEXTURE_2D,
		Blend 		     = GL_BLEND,
	}

	enum ProjectionType : byte
	{
		Perspective,
		Orthographic,
	}

	enum ShaderType
	{
		Vertex 	 = GL_VERTEX_SHADER,
		Fragment = GL_FRAGMENT_SHADER,
		Geometry = GL_GEOMETRY_SHADER,
	}

	enum GLType
	{
		Float = GL_FLOAT,
		UByte = GL_UNSIGNED_BYTE
	}
}