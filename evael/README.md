evael 0.0.2
===========

Evael is a small 2D/3D game engine written in the D programming language. It is based on OpenGL 3.3.

### Features

- Asset loader (texture, models, shaders)
- Terrain rendering (blend map, normal map, height map)
- Model rendering (IQM, OBJ)
- Basic lighting support (directional light, point light)
- Shadow support
- Instancing (for OBJ models atm)
- Integrated custom GUI based on NanoVG (support multiple basic controls, theming, fonts...)
- GUI with [Nuklear](https://github.com/vurtun/nuklear/)
- Input handling as event mode or immediate mode (onMouseAction() or isMouseButtonClicked())
- Entity Component System with [decs](https://github.com/aldocd4/decs)

### Planned features

- Water rendering
- Network support
- Physics support
- Navigation support (recast & detour)
- Controller support
- more!

Some part of the code are old. They need to be updated:
 - Shaders sources
 - Models (write better loader and clean the code)
 - probably other parts...

### Supported platforms

- Windows (tested)
- Linux?
- Android?

### Build

You have to use [dub](https://code.dlang.org/download) to build the project.

Add this project as a dependency to your **dub.json**:

```json
"dependencies": {
    "evael": "~>0.0.1"
}
```

Documentation
===========

You can find tutorials on [this repository](https://github.com/evael-dev/evael-tutorials).

A base game template is provided [here](https://github.com/evael-dev/evael-game-template).

Screenshots
===========

![Game](https://pbs.twimg.com/media/Czla-BXWQAAGSxH.jpg)

License
===========

Boost Software License - Version 1.0