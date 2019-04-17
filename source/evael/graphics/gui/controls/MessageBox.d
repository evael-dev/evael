module evael.graphics.gui.controls.MessageBox;

import evael.graphics.gui.controls.Container;
import evael.graphics.gui.controls.Button;
import evael.graphics.gui.controls.TextBlock;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

class MessageBox : Container
{
	enum ButtonType : ubyte
	{
		Ok,
		No,
	}

	protected alias void delegate(ButtonType buttonType) OnAnswerEvent;
	protected OnAnswerEvent m_onAnswerEvent;

	/// MessageBox content
	private wstring m_message;

	public this(in wstring message, in float x, in float y, in int width = 0, in int height = 0)
	{
		this(message, vec2(x, y), Size!int(width, height));
	}

	public this(in wstring message, in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_movable = false;
		this.m_message = message;
		
		this.hide();
	}

	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}

	public override void initialize()
	{
		this.m_size.width = cast(int)this.m_theme.font.getTextWidth(this.m_message) + 120;
		this.m_size.height = this.m_theme.font.getTextHeight(this.m_message) + 60;

		auto noButton = new Button("Non", this.m_theme.font.getTextWidth(this.m_message) - 40, 5);
		auto okButton = new Button("Oui", noButton.position.x - noButton.size.width - 50, 5);

		okButton.onClickEvent = (sender) => this.m_onAnswerEvent(ButtonType.Ok);
		noButton.onClickEvent = (sender) => this.m_onAnswerEvent(ButtonType.No);

		auto text = new TextBlock();
		text.text = this.m_message;
		text.dock = Control.Dock.Fill;

		this.addChild(text);
		this.addChild(okButton);
		this.addChild(noButton);

		super.initialize();
	}

	@property
	public void onAnswerEvent(OnAnswerEvent value) nothrow
	{
		this.m_onAnswerEvent = value;
	}

}