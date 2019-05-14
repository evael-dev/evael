module evael.graphics.gui.controls.TextBox;

import std.math : round;
import std.array : insertInPlace; 
import std.range;
import std.string : toStringz;
import std.conv : to;

import evael.graphics.gui.controls.Control;

import evael.system.Input;

import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Color;

extern (Windows) short GetKeyState(int nVirtKey);

class TextBox : Control
{
	/// Text
	private wstring m_text;

	private wstring m_visibleText;

	/// Text position
	private vec2 m_textPosition;

	private int m_textAlign;

	/// Caret position
	private vec2 m_caretPosition;

	/// Caret index in text
	private uint m_caretIndex;

	/// Characters limit
	private uint m_maxCharactersCount;

	private bool m_inSelectMode;

	private float m_textWidth;

	private float m_padding;

	public this(in float x, in float y, in int width, in int height)
	{
		this(vec2(x, y,), Size!int(width, height));
	}

	public this()(in auto ref vec2 position, in auto ref Size!int size)
	{
		super(position, size);

		this.m_name = "textBox";
		this.m_padding = 4.0f;		
		this.m_textPosition = vec2(0.0f, 0.0f);
		this.m_caretPosition = vec2(this.m_padding, 3.0f);
		this.m_inSelectMode = false;
		this.m_maxCharactersCount = 500;
		this.m_textAlign = NVGalign.NVG_ALIGN_LEFT | NVGalign.NVG_ALIGN_TOP;
		this.m_isFocusable = true;
	}

	/**
	 * Renders the textbox
	 */
	public override void draw(in float deltaTime)
	{		
		if(!this.m_isVisible)
		{
			return;
		}

		super.draw(deltaTime);

		immutable x = this.m_realPosition.x;
		immutable y = this.m_realPosition.y;
		immutable w = this.m_size.width;
		immutable h = this.m_size.height;

		auto vg = this.m_nvg;

		if(this.m_theme.borderType == Theme.BorderType.Solid)
		{
			nvgBeginPath(vg);
			nvgRoundedRect(vg, x, y, w, h, this.m_theme.cornerRadius);
			nvgStrokeColor(vg, this.m_theme.borderColor.asNvg);
			nvgStroke(vg);
		}

		nvgSave(vg);

		nvgIntersectScissor(vg, x + this.m_padding, y, this.m_size.width - (this.m_padding * 2), this.m_size.height);
		
		this.m_theme.font.draw(this.m_text, vec2(x + this.m_padding, y) + this.m_textPosition, 
			this.m_theme.fontColor, this.m_theme.fontSize, this.m_theme.drawTextShadow);
		
		nvgRestore(vg);

		// Caret
		if(this.m_hasFocus)
		{
			nvgBeginPath(vg);
			nvgMoveTo(vg, this.m_caretPosition.x + x, this.m_caretPosition.y + y);
			nvgLineTo(vg, this.m_caretPosition.x + x, this.m_caretPosition.y + y + h - 5.5f);
			nvgStrokeColor(vg, this.m_theme.fontColor.asNvg);
			nvgStroke(vg);
		}
	}

	/**
	 * Char event
	 * Params: 
	 */
	public override void onText(in int key)
	{
		if(this.m_maxCharactersCount != 0 && this.m_text.length >= this.m_maxCharactersCount)
			return;

		super.onText(key);

		immutable newChar = cast(char)key;

		// Return button
		if(key == 13)
		{
			return;
		}

		this.m_text.insertInPlace(this.m_caretIndex, newChar);
		this.moveCaretToRight();
	}

	/**
	 * Key pressed event
	 * Params: 
	 *		 key : key pressed
	 */
	public override void onKey(in int key)
	{
		super.onKey(key);

		if(this.m_text.length == 0)
		{
			return;
		}

		switch(key)
		{
			// Delete
			case Key.Back:
			
				if(this.m_inSelectMode)
				{
					this.clear();
				}
				else
				{
					if(this.m_caretIndex == 0)
					{
						return;
					}

					this.moveCaretToLeft();

					auto rest = this.m_text.save();
					rest.popFrontN(this.m_caretIndex + 1);
					this.m_text = this.m_text[0 .. this.m_caretIndex] ~ rest;
				}

				break;

			// Left
			case Key.Left:
				if(this.m_caretIndex == 0)
				{
					return;
				}

				if(this.m_inSelectMode)
				{
					this.m_inSelectMode = false;
				}

				this.moveCaretToLeft();

				break;

			// Right
			case Key.Right:

				if(this.m_caretIndex == this.m_text.length)
				{
					return;
				}

				if(this.m_inSelectMode)
				{
					this.m_inSelectMode = false;
				}

				this.moveCaretToRight();

				break;

			// A
			case Key.A:
				if(GetKeyState(0x11) < 0)
				{
					// TODO: 
					/*this.m_inSelectMode = true;

					this.m_buffer.bind();

					ubyte[16] data;

					this.initializeArrayFromColor(data.ptr, Color.red);

					glBufferSubData(GL_ARRAY_BUFFER, 48, data.sizeof, data.ptr);*/
				}

				break;
			
			// Delete
			case Key.Delete:

				break;

			// Home
			case Key.Home:
				this.m_caretIndex = 0;
				this.m_textPosition.x = 0;
				this.m_caretPosition.x = this.m_padding;
				break;
			
			// End
			case Key.End:
				this.m_caretIndex = this.m_text.length;
				this.m_textPosition.x = 0;
				this.m_caretPosition.x = this.m_size.width - this.m_padding;
				break;

			default:
				break;
		}
	}

	/**
	 * Mouse click
	 */
	public override void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
	{
		super.onMouseClick(mouseButton, mousePosition);
		this.switchState!(State.Clicked);

		// this.m_theme.borderColor = Color.Orange;

		this.m_hasFocus = true;
	}

	/**
	 * Mouse enters control's rect
	 * Params:
	 * 		 mousePosition : mouse's position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{
		this.switchState!(State.Hovered);
	}

	/**
	 * Mouse leaves control's rect
	 */
	public override void onMouseLeave()
	{
		this.switchState!(State.Normal);
	}


	/**
	 * Moves caret to left
	 */
	private void moveCaretToLeft()
	{
		auto i = --this.m_caretIndex;
		
		auto glyph = this.m_theme.font.getGlyphPosition(i, this.m_padding, this.m_text, this.m_theme.fontSize);

		// Explanation of : glyph.x - (-this.m_textPosition.x);
		// We get glyph position with x = 0
		// If the text position has been moved, glyph.x become invalid cause text is not at coord x = 0 anymore, but we still get glyph with x = 0
		// So we substract this value from glyph.x
		this.m_caretPosition.x = glyph.x - (-this.m_textPosition.x);

		// We check if the new displayed character is gonna be displayed outside of textbox
		if(this.m_caretPosition.x < this.m_padding)
		{
			// Yes, we need to move text position to the right
			// We just need to add abs(caretPosition.x) to text.x
			this.m_textPosition.x = this.m_textPosition.x + (- this.m_caretPosition.x ) + this.m_padding;
			
			this.m_caretPosition.x = this.m_padding;
		}
	}

	/**
	 * Moves caret to right
	 */
	private void moveCaretToRight()
	{
		auto i = ++this.m_caretIndex;

		NVGglyphPosition glyph;

		if(this.m_caretIndex < this.m_text.length)
		{
			glyph = this.m_theme.font.getGlyphPosition(i, this.m_padding, this.m_text, this.m_theme.fontSize);
			// Explanation of : glyph.x - (-this.m_textPosition.x);
			// We get glyph position with x = 0 (if padding = 0)
			// If the text position has been moved, glyph.x become invalid cause text is not at coord x = 0 anymore, but we still get glyph with x = 0
			// So we substract this value from glyph.x
			this.m_caretPosition.x = glyph.x - (-this.m_textPosition.x);
		}
		else
		{
			glyph = this.m_theme.font.getGlyphPosition(i - 1, this.m_padding, this.m_text, this.m_theme.fontSize);
			
			// Adding text at the end, we need to do that
			glyph.x = glyph.maxx;
			
			this.m_caretPosition.x = glyph.maxx;
		}

		immutable w = this.m_size.width - this.m_padding;

		// We check if the new displayed character is gonna be displayed outside of textbox
		if(this.m_caretPosition.x > w)
		{
			// Yes, we need to move text position to the left
			// TextBox width = 120
			// if glyph.x = 123, then we move text to -(123 - 120)
			this.m_textPosition.x = -(glyph.x - w);

			this.m_caretPosition.x = w;
		}
	}

	public override void initialize()
	{
		super.initialize();

		float[4] bounds = this.m_theme.font.getTextBounds(this.m_text, 0, this.m_theme.fontSize);

		immutable float h = bounds[3] - bounds[1];

		if(h > this.m_size.height)
		{
			this.m_size.height = cast(int)h + 5;
		}

		import std.math : round;

		this.m_textPosition.y = round(this.m_size.halfHeight - (h / 2));
	}

	/**
	 * Clear the textbox
	 */
	public void clear() nothrow
	{
		this.m_text = "";

		this.m_textPosition.x = 0.0f;
		this.m_caretPosition.x = 0.0f;
		this.m_caretIndex = 0;

		this.m_inSelectMode = false;

		this.switchState!(State.Hovered);
	}

	@property
	{
		public string text() const nothrow
		{
			import std.utf;
			return toUTF8(this.m_text);
		}

		public wstring textw() const nothrow @nogc
		{
			return this.m_text;
		}

		public void text(in wstring value) nothrow @nogc
		{
			this.m_text = value;
			this.m_visibleText = value;
		}

		public void maxCharactersCount(in ushort value) nothrow @nogc
		{
			this.m_maxCharactersCount = value;
		}
	}

}