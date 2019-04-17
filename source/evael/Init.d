module evael.Init;

import std.experimental.logger;

import evael.graphics.GL;

import derelict.freeimage.freeimage;
import derelict.freetype.ft;
import derelict.glfw3.glfw3;
import derelict.util.exception;
import derelict.nanovg.nanovg;
import derelict.openal.al;
import derelict.sndfile.sndfile;

/**
 * Initializes external libs.
 */
void loadExternalLibraries()
{
    debug info("Initializing derelict...");

    DerelictGL3.load();    
    DerelictGLFW3.load();    
    DerelictFI.missingSymbolCallback = &handleDerelictsProblems;
    DerelictFI.load();
    DerelictFT.missingSymbolCallback = &handleDerelictsProblems;
    DerelictFT.load();
    DerelictAL.load();
	DerelictSndFile.load();

    if (!glfwInit()) 
    {
        error("Error when calling glfwInit().");
        assert(0, "Error when calling glfwInit()");        
    }
}

void unloadExternalLibraries()
{
    debug info("Unloading derelict...");

    DerelictGLFW3.unload();
    DerelictGL3.unload();    
    DerelictFT.unload();
    DerelictFI.unload();
    DerelictNANOVG.unload();   
	DerelictSndFile.unload();
	DerelictAL.unload();

    glfwTerminate();
}

ShouldThrow handleDerelictsProblems(string symbolName) 
{
	debug warningf("Failed to load %s, ignoring this.", symbolName);
	return ShouldThrow.No;
}