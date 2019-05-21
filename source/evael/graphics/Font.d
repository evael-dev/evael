module evael.graphics.Font;

import std.conv : to;
import std.string;
import std.experimental.logger;

import derelict.nanovg.nanovg;

import evael.graphics.GraphicsDevice;
import evael.graphics.Texture;
import evael.graphics.shaders.Shader;
import evael.graphics.Vertex;
import evael.system.Asset;

import evael.utils.Color;
import evael.utils.Math;

import jsonizer;

/**
 * Font. Using NanoVG.
 */
class Font : IAsset
{
	mixin JsonizeMe;

	/// Font size
	private ushort m_size;

	private int m_fontId;

	@jsonize("path") private string m_fontName;
	
	private NVGcontext* m_nvg;
	
	@nogc @safe
	public this() pure nothrow
	{

	}

	/**
	 * Font constructor.
	 * Params:
	 *		nvgContext : nanovg context
	 *		fontId : font id
	 *		fontName : font name
	 */
	@nogc @safe
	public this(NVGcontext* nvgContext, in int fontId, in string fontName) pure nothrow
	{
		this.m_nvg = nvgContext;
		this.m_fontId = fontId;
		this.m_fontName = fontName;
	}
	
	@nogc @safe
	public void dispose() const pure nothrow
	{

	}
	
	/**
	 * Renders text.
	 * Params:
	 *		text :
	 *		position :
	 *		color :
	 *		fontSize :
	 *		shadow : indicates if a shadow should be rendered
	 *		alignment
	 */
	public void draw()(in wstring text, in auto ref vec2 position, in auto ref Color color, in int fontSize, in bool shadow = true, 
		in int alignment = NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP) 
	{
		this.draw(text, position.x, position.y, color, fontSize, shadow, alignment);
	}

	public void draw()(in string text, in auto ref vec2 position, in auto ref Color color, in int fontSize, in bool shadow = true, 
		in int alignment = NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP) 
	{	
		this.draw(text.toStringz(), position.x, position.y, color, fontSize, shadow, alignment);
	}

	public void draw()(in string text, in float x, in float y, in auto ref Color color, in int fontSize, in bool shadow = true, 
		in int alignment = NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP) 
	{
		this.draw(text.toStringz(), x, y, color, fontSize, shadow, alignment);		
	}

	public void draw()(in wstring text, in float x, in float y, in auto ref Color color, in int fontSize, in bool shadow = true, 
		in int alignment = NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP) 
	{	
		this.draw(text.to!string().toStringz(), x, y, color, fontSize, shadow, alignment);
	}

	public void draw()(immutable(char)* data, in float x, in float y, in auto ref Color color, in int fontSize, in bool shadow = true, 
		in int alignment = NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP) 
	{
		auto vg = this.m_nvg;

		nvgSave(vg);
		
		nvgFontFaceId(vg, this.m_fontId);	
		nvgFontSize(vg, fontSize);
		
		if (shadow)
		{
			auto shadowColor = Color.Black;
			shadowColor.a = color.a;

			nvgFontBlur(vg, 2);
			nvgFillColor(vg, shadowColor.asNvg());
			nvgTextAlign(vg, alignment);
			nvgText(vg, x + 1.6f, y + 1.6f, data, null);
			nvgFontBlur(vg, 0.8);
		}
		
		nvgFillColor(vg, color.asNvg());
		nvgTextAlign(vg, alignment);
		
		nvgText(vg, x, y, data, null);

		nvgRestore(vg);
	}

	/**
	 * Returns glyph position in text.
	 * Params:
	 *		index : char index
	 *		textX : text position
	 *		text : text
	 */
	public NVGglyphPosition getGlyphPosition(in size_t index, in float textX, in wstring text, in int fontSize)
	{		
		NVGglyphPosition[1024] glyphs;

		nvgSave(this.m_nvg);
	
		nvgFontSize(this.m_nvg, fontSize);
		nvgFontFaceId(this.m_nvg, this.m_fontId);
		nvgFontBlur(this.m_nvg, 2);
		
		immutable nglyphs = nvgTextGlyphPositions(this.m_nvg, textX, 0, text.to!string().toStringz(), null, glyphs.ptr, 1024);

		nvgRestore(this.m_nvg);

		return glyphs[index];
	}
	
	/**
	 * Computes text width.
	 * Params:
	 *		text : text
	 */
	public uint getTextWidth(in wstring text)
	{
		return 0;
	}

	/**
	 * Computes text height.
	 * Params:
	 *		text : text
	 */
	@nogc @safe
	public uint getTextHeight(in wstring text) pure nothrow
	{
		return 0;
	}

	/**
	 * Measures the specified text string. Parameter bounds should be a pointer to float[4],
	 * if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
	 * Measured values are returned in local coordinate space.
	 */
	public float[4] getTextBounds(in wstring text, in float x, in int fontSize)
	{
		return this.getTextBounds(text.to!string().toStringz(), x, fontSize);
	}

	public float[4] getTextBounds(in string text, in float x, in int fontSize)
	{
		return this.getTextBounds(text.toStringz(), x, fontSize);
	}

	public float[4] getTextBounds(immutable(char)* data, in float x, in int fontSize)
	{
		float[4] bounds;
		nvgFontSize(this.m_nvg, fontSize);
		nvgFontFaceId(this.m_nvg, this.m_fontId);
		nvgTextAlign(this.m_nvg, NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP);		
		nvgTextBounds(this.m_nvg, x, 0, data, null, bounds.ptr);
		return bounds;
	}

	/**
	 * Loads font.
	 * Params:
	 *		fileName : font file
	 */
	public static Font load(in string fileName, NVGcontext* nvg)
	{
		import evael.utils.Config;
		import std.file : exists;
		import std.path : baseName;

		string file = Config.Paths.fonts!string ~ fileName;
		string fontShortName = fileName;

		if (!file.exists())
		{
			if (!fileName.exists())
			{
				throw new Exception("Invalid font : " ~ fileName);		
			}
			else
			{
				file = fileName;
				fontShortName = baseName(fileName);					
			}
		}

		immutable fontId = nvgCreateFont(nvg, fontShortName.toStringz(), file.toStringz());
		
		if (fontId == -1)
		{
			sharedLog.errorf("Unable to create font %s", fileName);
		}

		return new Font(nvg, fontId, file);
	}
	
	/**
	 * Properties
	 */
	@nogc @safe
	@property pure nothrow
	{
		public ushort size() const
		{
			return this.m_size;
		}
		
		public void size(in ushort value)
		{
			this.m_size = value;
		}

		public string name() const
		{
			return this.m_fontName;
		}

		public int id() const
		{
			return this.m_fontId;
		}
	}
}