module evael.graphics.gui.controls.Slider;

import std.algorithm : map;
import std.range : iota;
import std.array : array;

import evael.graphics.gui.controls.Container;
import evael.graphics.gui.controls.Button;
import evael.graphics.gui.controls.Panel;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

public class Slider : Container
{
	private alias void delegate(Control sender, int value) OnValueChangeEvent;
	private OnValueChangeEvent m_onValueChangeEvent;

	/// Values
	private int m_minimumValue, m_maximumValue;

	/// Possible values' position
	private int[] m_valuesPosition;

	/// Current selected value
	private int m_currentValueIndex;

	/// Incrementation, formula is : controlWidth / maximumValue
	private int m_incrementation;

	private Button m_scrollButton;

	public this(in float x, in float y, in int width)
	{
		this(vec2(x, y), Size!int(width + 20, 45));
	}

	public this(in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_opacity = 0;

		Panel panel = new Panel(10, 20, size.width - 20, 5);

		this.m_scrollButton = new Button(5, 16, 10, 16);
		this.m_scrollButton.type = Button.Type.Icon;

		this.addChild(panel);
		this.addChild(this.m_scrollButton);
	}

	/**
	 * Renders the slider
	 */
	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}



	/**
	 * Mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse's position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{	
		super.onMouseMove(mousePosition);

		static vec2 lastMousePosition;

		scope(exit) lastMousePosition =	mousePosition;

		if(this.m_scrollButton.isClicked && mousePosition.x != lastMousePosition.x)
		{
			bool change = false;

			vec2 buttonPosition = this.m_scrollButton.realPosition;

			// Slide to right
			if(mousePosition.x > lastMousePosition.x && this.m_currentValueIndex < this.m_maximumValue + 1)
			{
				// We check if we reach half position for the next value
				if(mousePosition.x > buttonPosition.x + (this.m_incrementation / 2))
				{
					buttonPosition.x = (buttonPosition.x + this.m_incrementation);
					this.m_currentValueIndex++;

					change = true;
				}
			}
			else if(mousePosition.x < lastMousePosition.x && this.m_currentValueIndex > 0)
			{
				if(mousePosition.x < buttonPosition.x - (this.m_incrementation / 2))
				{
					buttonPosition.x = (buttonPosition.x - this.m_incrementation);
					this.m_currentValueIndex--;

					change = true;
				}
			}

			// We update button's position and raise a new event if necessary
			if(change)
			{
				this.m_scrollButton.realPosition = buttonPosition;

				if(this.m_onValueChangeEvent !is null)
					this.m_onValueChangeEvent(this, this.m_currentValueIndex);
			}
		}
	}

	/**
	 * Properties
	 */
	@property 	
	public void onValueChangeEvent(OnValueChangeEvent callback) nothrow
	{
		this.m_onValueChangeEvent = callback;
	}

	@property
	public void minimumValue(in int value) nothrow
	{
		this.m_minimumValue = value;
	}

	@property
	public void maximumValue(in int value) nothrow
	{
		this.m_maximumValue = value;

		this.m_incrementation = this.m_controls[0].size.width / value;

		// this.m_values = iota(0, value + 1).map!(a => a * this.m_incrementation).array;
	}

	@property
	public int value() const nothrow
	{
		return this.m_currentValueIndex;
	}
}