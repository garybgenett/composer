@echo off
if not defined MSYSTEM set MSYSTEM=MSYS32
if not defined MSYSCON set MSYSCON=mintty.exe
set WD=%~dp0
set BINDIR=/usr/bin
set PATH=%WD%%BINDIR%;%PATH%
set OPTIONS=
set OPTIONS=%OPTIONS% --title ">> Composer CMS v1.4 :: MSYS2 Shell"
set OPTIONS=%OPTIONS% --exec %BINDIR%/bash
start /b %WD%%BINDIR%/%MSYSCON% %OPTIONS%
:: end of file
