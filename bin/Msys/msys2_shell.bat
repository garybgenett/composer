@echo off
if not defined MSYSTEM set MSYSTEM=MSYS32
set _CMS=%~dp0
set _BIN=usr/bin
set _ICO=%_CMS%/../icon.ico
if not exist %_ICO% set _ICO=%_CMS%/../../icon.ico
set _OPT=
set _OPT=%_OPT% --title ">> Composer CMS v2.0.beta3 :: MSYS2 Shell"
set _OPT=%_OPT% --icon "%_ICO%"
set _OPT=%_OPT% --exec "/%_BIN%/bash"
start /b %_CMS%/%_BIN%/mintty %_OPT%
::#>set /p ENTER="Hit ENTER to proceed."
:: end of file
