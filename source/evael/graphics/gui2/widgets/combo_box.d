module evael.graphics.gui2.widgets.combo_box;

import evael.graphics.gui2.widgets.widget;

class ComboBox : Widget
{
	private alias OnSelectEvent = void delegate(in int value);
	private OnSelectEvent m_onSelectEvent;

	/// Entries speparated by zeros
	private string m_entries;

	private int m_entriesCount;

	/// Selected entry index
	private int m_selectedEntry;

	/// Entry height
	private int m_entryHeight;
	
	@nogc
	public this() nothrow
	{

	}

	public override void draw()
	{
		this.applyLayout();
		this.m_selectedEntry = nk_combo_string(
			this.nuklearContext, cast(char*) this.m_entries.ptr, this.m_selectedEntry, this.m_entriesCount, this.m_entryHeight, nk_vec2(200,200)
		);

		static int lastSelectedEntry;

		if (this.m_selectedEntry != lastSelectedEntry && this.m_onSelectEvent !is null)
		{
			lastSelectedEntry = this.m_selectedEntry;
			this.m_onSelectEvent(this.m_selectedEntry);
		}
	}

	/**
	 * Adds entry in the combobox.
	 * Params:
	 *      entry : entry
	 */
	public ComboBox add(in string entry)
	{
		this.m_entries ~= entry ~ '\0';
		this.m_entriesCount++;
		return this;
	}

	@nogc
	@property nothrow
	{
		public ComboBox height(in int value)
		{
			this.m_entryHeight = value;
			return this;
		}

		public ComboBox onSelect(OnSelectEvent value)
		{
			this.m_onSelectEvent = value;
			return this;
		}

		/**
		 * Returns selected entry.
		 */
		public int selected()
		{
			return this.m_selectedEntry;
		}
	}
}