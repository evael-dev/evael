module evael.graphics.gui.controls.PictureBox;

import evael.graphics.gui.controls.Control;
import evael.graphics.gui.controls.Panel;
import evael.graphics.gui.controls.TextBlock;

import evael.graphics.Texture;

import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Color;
import evael.utils.Rectangle;

class PictureBox : Control
{
	enum ScaleType
	{
		Center,
		Fit
	}

	/// Scale type
	private ScaleType m_scaleType;

	public this(in float x, in float y, in int width, in int height)
	{
		this(vec2(x, y,), Size!int(width, height));
	}

	public this()(in auto ref vec2 position, in auto ref Size!int size)
	{
		super(position, size);

		this.m_name = "pictureBox";
		
		this.m_scaleType = ScaleType.Fit;
	}

	/**
	 * Renders the picturebox
	 */
	public override void draw(in float deltaTime)
	{
		if(!this.m_isVisible)
		{
			return;
		}

		super.draw(deltaTime);
		
		if(this.m_texture is null)
		{
			return;
		}

		immutable x = this.m_realPosition.x;
		immutable y = this.m_realPosition.y;
		immutable w = this.m_size.width;
		immutable h = this.m_size.height;

		auto vg = this.m_nvg;

		// https://github.com/memononen/nanovg/issues/348
		// Aspect ratios of pixel in x and y dimensions. 
		// This allows us to scale the sprite to fill the whole rectangle.
		immutable ax = cast(float)w / this.m_textureCoords.size.width;
		immutable ay = cast(float)h / this.m_textureCoords.size.height;
		
		// si w = 48
		// ax = 1
		// si w = 28
		// ax = 0.58
		NVGpaint imgPaint = nvgImagePattern(vg, x - this.m_textureCoords.left * ax, y - this.m_textureCoords.bottom * ay,
			this.m_texture.size.width * ax , this.m_texture.size.height * ay,  0, this.m_texture.nvgId, this.m_opacity / 255.0f);
			
		nvgBeginPath(vg);
		nvgRoundedRect(vg, x, y, w, h, 3);
		nvgFillPaint(vg, imgPaint);
		nvgFill(vg);
	}

	/**
	 * Event called on mouse button click
	 * Params:
	 *		mouseButton : mouse button	 
	 *		mousePosition : mouse position
	 */
	public override void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
	{
		super.onMouseClick(mouseButton, mousePosition);
		this.switchState!(State.Clicked);
	}

	/**
	 * Event called on mouse button release
	 * Params:
	 *		mouseButton : mouse button
	 */
	public override void onMouseUp(in MouseButton mouseButton)
	{
		super.onMouseUp(mouseButton);
		this.switchState!(State.Hovered);
	}

	/**
	 * Event called when mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{
		if(this.hasFocus)
		{
			return;
		}

		super.onMouseMove(mousePosition);

		if(this.isClicked)
		{
			this.switchState!(State.Clicked);
		}
		else
		{
			this.switchState!(State.Hovered);
		}
	}

	/**
	 * Event called when mouse leaves in control's rect
	 */
	public override void onMouseLeave()
	{
		super.onMouseLeave();
		this.switchState!(State.Normal);
	}

	@property
	{
		public void scaleType(in ScaleType value) nothrow @nogc
		{
			this.m_scaleType = value;
		}
	}
}
