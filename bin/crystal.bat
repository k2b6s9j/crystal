@echo off
set dir=%~dp0
set dir=%dir:~0,-1%

set CC=gcc
set CRYSTAL_PATH=%dir%\..\src
set CRYSTAL_LINKER_FLAGS=-m32 -static -L%dir%/../win32/lib32

if exist %dir%\..\.build\crystal.exe (
	echo Using compiled compiler at .build/crystal
	set crystal=%dir%\..\.build\crystal.exe
) else (
	set crystal=%dir%\..\win32\crystal.exe
)
%crystal% %*
