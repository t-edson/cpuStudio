cpuStudio 1.0.0
===============

Cross-platform Pascal IDE and tools for development in 8bits CPU using several compilers like P65Pas or PicPas.

### Folder structure

This repository includes all the files for both development and execution. It also includes the IDE and compiler files.

IDE files:

* "/" -> Includes the binaries and config files.
* "/Source" -> Source files for the IDE.
* "/syntax" -> Syntax files for highlighter and completion code.
* "/temp" -> Temporal folder for new files.
* "/themes" -> Themes files for the IDE.

## IDE

Some features of the IDE are:

•	Cross-platform.

•	Multiple editors windows.

•	Syntax highlighting, code folding, word, and line highlighting for Pascal and ASM.

•	Code completion, and templates for the common structures IF, REPEAT, WHILE, …

•	Shows the assembler code and the resources used.

•	Support for themes (skins).

•	Code tools for completion and navigation.

•	Check syntax in REAL TIME!!!.

•	Several setting options.


## Source Code

To have more information about the compiler internals and design, check the Technical Documentation (Only in spanish by now):.

To compile the IDE, it's needed to have the following libraries:

* MiConfig: https://github.com/t-edson/MiConfig
* MisUtils: https://github.com/t-edson/MisUtils
* SynFacilUtils: https://github.com/t-edson/SynFacilUtils
* UtilsGrilla: https://github.com/t-edson/UtilsGrilla
* EpikTimer: https://wiki.freepascal.org/EpikTimer

All of them, are include in the folder /_libraries located in the /Source folder. 

IMPORTANT:

The source code here provided is only for the IDE project. It dosen't include a compiler. To see the IDE with a compiler embeded check https://github.com/t-edson/P65Pas
