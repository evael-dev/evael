module evael.graphics.gui.controls.TextArea;

import std.string;
import std.conv;
import std.typecons;

import evael.graphics.gui.controls.Container;
import evael.graphics.gui.controls.TextBlock;
import evael.graphics.gui.controls.ScrollBar;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

class TextArea : Container, IScrollable
{
	alias Line = Tuple!(wstring, "text", Color, "color");

	private Line[] m_lines;
	
	/// Position of the text in the textarea
	private vec2 m_globalTextPosition;

	/// Max lines that can be displayed
	private int m_maxLines;

	public this(in float x, in float y, in int width, in int height)
	{
		this(vec2(x, y,), Size!int(width, height));
	}

	public this()(in auto ref vec2 position, in auto ref Size!int size)
	{
		super(position, size);

		this.m_name = "textArea";

		this.m_globalTextPosition = vec2(0.0f);
		this.m_maxLines = 255;

//		this.addChild(new ScrollBar(0, 0, 20, size.height));
	}


	public void onScroll(ScrollBar.ScrollDirection direction, in float scrollBarPosition)
	{
		
	}

	public override void draw(in float deltaTime)
	{
		if(!this.m_isVisible)
		{
			return;
		}
		
		super.draw(deltaTime);

		auto vg = this.m_nvg;

		nvgSave(vg);
	
		nvgFontSize(vg, this.m_theme.fontSize);
		nvgFontFaceId(vg, this.m_theme.font.id);

		float lineh;		
		nvgTextMetrics(vg, null, null, &lineh);

		auto x = this.m_realPosition.x;
		auto y = this.m_realPosition.y + this.m_globalTextPosition.y;

		NVGtextRow[3] rows;

		foreach(ref line; this.m_lines)
		{
			const char* text = line.text.to!string.toStringz();
			const char* start = text;
			const char* end = text + line.text.length;

			int nrows = nvgTextBreakLines(vg, start, end, this.m_size.width, rows.ptr, 3);

			while(nrows) 
			{
				for(int i = 0; i < nrows; i++) 
				{
					NVGtextRow* row = &rows[i];

					// We check if we really need to draw this line
					if(y >= this.m_realPosition.y)
					{	
						// TODO : use font class maybe ?
						if(this.m_theme.drawTextShadow)
						{
							nvgFontBlur(vg, 2);
							nvgFillColor(vg, Color.Black.asNvg);
							nvgTextAlign(vg, NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP);
							nvgText(vg, x + 1.6f, y + 1.6f, row.start, row.end);
							nvgFontBlur(vg, 0.8);
						}

						nvgFillColor(vg, line.color.asNvg);
						nvgTextAlign(vg, NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP);
						nvgText(vg, x, y, row.start, row.end);
					}

					auto nextLineY = y + lineh;

					// We check if next line is gonna be displayed outside of the textarea
					if(nextLineY <= this.m_realPosition.y + this.m_size.height)
					{
						// No
						y = nextLineY;
					}
					else
					{
						// Yes, we need to update global text position instead of next line position
						this.m_globalTextPosition.y = this.m_globalTextPosition.y - lineh;	
					}
				}

				nrows = nvgTextBreakLines(vg, rows[nrows - 1].next, end, this.m_size.width, rows.ptr, 3);
			}
		}

		nvgRestore(vg);
	}

	public void appendLine(in wstring text, in ref Color color = Color.Black)  
	{
		// We check if we reached lines limit
		if(this.m_lines.length == this.m_maxLines)
		{
			// We need to remove the first line
			this.m_lines = this.m_lines[1..$];

			this.m_globalTextPosition.y = 0.0f;
		}

		this.m_lines ~= Line(text, color);
	}

	public void appendLine(in string text, in ref Color color = Color.Black)  
	{
		this.appendLine(to!wstring(text), color);
	}

	/**
	 * Clear all lines
	 */
	public void clear() nothrow @nogc
	{
		this.m_controls = [];
		this.m_globalTextPosition = vec2(0.0f);
	}

	@property
	{
		public void text(in wstring value)  
		{
			this.clear();

			this.appendLine(value);
		}

		public void maxLines(in int value) nothrow @nogc
		{
			this.m_maxLines = value;
		}
	}
}