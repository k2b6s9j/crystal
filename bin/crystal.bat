@echo off
set cwd=%~dp0
set CC=gcc
set CRYSTAL_PATH=%cwd%..\src
set CRYSTAL_LINKER_FLAGS=-m32 -static -Lwin32/lib32
if exist %cwd%\..\.build\crystal.exe (
	echo Using compiled compiler at .build/crystal
	set crystal=%cwd%\..\.build\crystal.exe
) else (
	set crystal=%cwd%\..\win32\crystal.exe
)
%crystal% %*
