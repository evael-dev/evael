module evael.init;

import std.experimental.logger;

import bindbc.openal;
import bindbc.glfw;
import bindbc.freeimage;
import bindbc.nuklear;

import derelict.util.exception;
import derelict.nanovg.nanovg;
import derelict.sndfile.sndfile;

/**
 * Initializes external libs.
 */
void loadExternalLibraries()
{
    infof("GLFW:%d", loadGLFW());
    infof("OpenAL:%d", loadOpenAL());
    infof("FreeImage:%d", loadFreeImage());
    infof("Nuklear:%d", loadNuklear());

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