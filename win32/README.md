Building Crystal with MinGW-w64
===============================

1. download [TDM64-GCC 4.9.2](http://tdm-gcc.tdragon.net/download) and the [win32-binaries](http://speedy.sh/3brTz/win32-binaries.7z).

2. extract the libs from _win32-binaries.7z_ into your crystal folder and add `C:\TDM-GCC\bin` (or whatever your path is) to windows' _PATH_-environment variable or change `CC` in `crystal.bat` accordingly.

3. cross-compile on linux, switch to windows and link with (skip if you already have `win32\crystal.exe`):

		bin/crystal build src/compiler/crystal.cr --cross-compile "windows x86" --single-module --target "i686-pc-win32-gnu" -o win32/crystal
		--
		gcc win32\crystal.o -m32 -static -lpthread -lws2_32 -Lwin32\lib32 -lgc -lpcre -lLLVM -limagehlp -lstdc++ -lz -o win32\crystal

4. * MSYS: use the Makefile with `make -fwin32/Makefile`.
   * or: `bin\crystal build src\compiler\crystal.cr -o .build\crystal`.

Problems
========

* Exceptions are not implemented yet.
* The specs have not been run yet.
* File descriptors are always in blocking mode.
* Sockets have not been tested yet at all.
* See `# win32:`-comments for more.
* ...
