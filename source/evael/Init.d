module evael.Init;

import std.experimental.logger;

import bindbc.openal;
import bindbc.glfw;
import bindbc.freeimage;

import derelict.util.exception;
import derelict.nanovg.nanovg;
import derelict.sndfile.sndfile;

/**
 * Initializes external libs.
 */
void loadExternalLibraries()
{
    debug infof("GLFW:%d", loadGLFW());
    debug infof("OpenAL:%d", loadOpenAL());
    debug infof("FreeImage:%d", loadFreeImage());

	DerelictSndFile.load();

    if (!glfwInit()) 
    {
        error("Error when calling glfwInit().");
        assert(0, "Error when calling glfwInit()");        
    }
}

void unloadExternalLibraries()
{
    DerelictNANOVG.unload();   
	DerelictSndFile.unload();

    glfwTerminate();
}