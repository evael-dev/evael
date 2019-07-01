module evael.system.I18n;

import std.json;
import std.conv;

class I18n
{
	private JSONValue m_texts;

	public this()
	{

	}

	/**
	 * Params:
	 *      language : ISO 639-1 code.
	 */
	public void setLocale(in string language)
	{
		import std.file;
		import std.exception;

		immutable path = "medias/translations/" ~ language ~ ".json";

		enforce(path.exists(), "Unable to find translation for language " ~ language);

		this.m_texts = parseJSON(read(path).to!string);
	}

	/**
	 * Returns a TranslationNode for a translation key
	 */
	@property
	public auto opDispatch(string key)()
	{   
		return TranslationNode(key in this.m_texts);
	}
}

struct TranslationNode
{
	private wstring m_textValue = "lang_error";
	private const(JSONValue)* m_jsonValue = null;

	public this(const(JSONValue)* value)
	{
		this.m_jsonValue = value;
	}

	public this(in wstring value)
	{
		this.m_textValue = value;
	}

	@property
	public auto opDispatch(string key)()
	{
		if(this.m_jsonValue !is null)
		{
			auto jsonValue = key in *this.m_jsonValue;

			immutable type = jsonValue.type();

			if(type == JSONType.string || type == JSONType.object)
			{
				return TranslationNode(jsonValue);
			}
		}

		return TranslationNode(this.m_textValue);
	}

	@property
	public wstring str()
	{
		if(this.m_jsonValue !is null)
		{
			immutable type = this.m_jsonValue.type();

			if(type == JSONType.string)
			{
				return this.m_jsonValue.str.to!wstring;
			}
		}

		return this.m_textValue;
	}
}