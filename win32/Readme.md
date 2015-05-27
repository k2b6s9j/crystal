Building Crystal with MinGW-w64
===============================

1. Download [TDM64-GCC 4.9.2](http://tdm-gcc.tdragon.net/download), [win32-crystal](http://www52.zippyshare.com/v/wIboBK0o/file.html) and the needed [x86 libraries](http://www23.zippyshare.com/v/6K1mwB0J/file.html) (optionally, the [x86_64 libraries](http://www75.zippyshare.com/v/fPItFQvP/file.html), too).

2. Extract the win32-binaries into your crystal folder and add `C:\TDM-GCC\bin` (or whatever your path is) to windows' _PATH_-environment variable or change `CC` in `crystal.bat` accordingly.

3. * with MSYS: use the Makefile with `make -fwin32/Makefile`.
   * without MSYS:
```
    cd path_to_your_crystal_folder
    mkdir .build
    bin\crystal build src\compiler\crystal.cr -o .build\crystal`
```

You can also add `path_to_your_crystal_folder\bin` to your _PATH_ and invoke crystal directly with `crystal hello_world.cr`.

Problems
========

* Exceptions are not implemented yet.
* The specs have not been run yet.
* File descriptors are always in blocking mode.
* Sockets have not been tested yet at all.
* See `# win32:`-comments for more.
* ...
