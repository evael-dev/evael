module evael.graphics.gui.StateList;

import evael.graphics.gui.State;

import jsonizer;

import std.traits : EnumMembers;
import std.conv : to;
import std.uni : toLower;

struct StateList(Type)
{
	mixin JsonizeMe;

	static foreach(e; [EnumMembers!(State)])
	{
		mixin("public @jsonize Type " ~ e.to!string.toLower ~ ";");
	}

	public this()(in auto ref Type type)
	{
		static foreach(e; [EnumMembers!(State)])
		{
			mixin("this." ~ e.to!string.toLower ~ " = type;");
		}
	}

	public ref Type fromEnum(State state)() nothrow
	{
		mixin("return this." ~ state.to!string.toLower ~ ";");
	}
}