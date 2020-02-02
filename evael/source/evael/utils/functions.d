module evael.utils.functions;

import std.parallelism;
import std.datetime;
import std.array;
import std.traits;

import core.exception;
import core.stdc.string;
import core.thread;

immutable MonoTime startupTime;

shared static this()
{
	startupTime = MonoTime.currTime;
}

void startTask(void delegate() func)
{
	task(func).executeInNewThread();
}

/**
 * Starts a task after X time.
 * Params:
 * 		callback : task to execute
 * 		interval : interval
 */
void startDelayedTask(void delegate() callback, in int interval)
{
	task(()
	{
		Thread.sleep(interval.seconds);
		callback();

	}).executeInNewThread();
}

@nogc
Duration timeSinceProgramStarted() nothrow
{
	return MonoTime.currTime - startupTime;
}

@nogc
float getCurrentTime() nothrow
{
	return timeSinceProgramStarted.total!"msecs";
}

@nogc
auto bindDelegate(T)(T t) nothrow
	if(isDelegate!T)
{
	static T dg;

	dg = t;

	extern(C)
	static ReturnType!T func(ParameterTypeTuple!T args)
	{
		return dg(args);
	}

	return &func;
}