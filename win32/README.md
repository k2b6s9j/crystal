Building Crystal on windows with MinGW-w64
==========================================

1. download [TDM64-GCC 4.9.2](http://tdm-gcc.tdragon.net/download).

2. cross-compile on linux, switch to windows and link with:

		bin/crystal build src/compiler/crystal.cr --cross-compile "windows x86" --single-module --target "i686-pc-win32-gnu" -o win32/crystal
		--
		gcc win32\crystal.o -m32 -static -lpthread -lws2_32 -Lwin32\lib32 -lgc -lpcre -lLLVM -limagehlp -lstdc++ -lz -o win32\crystal
Skip if you already have `win32\crystal.exe`.

3. * MSYS: use the Makefile with `make -fwin32/Makefile`.
   * or: `bin\crystal build src\compiler\crystal.cr -o .build\crystal`.

Problems
========

* Exceptions are not implemented yet.
* The specs have not been run yet.
* File descriptors are still always blocking.
* Sockets have not been tested yet at all.
* `--single-module` is always true, otherwise the commandline is too huge and can't be handled atm.
* Also, parallelizing must be done with processes or threads as _fork()_ is just a _yield_ for now (shouldn't be defined on windows in the first place).
* ...
