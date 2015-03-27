@echo off
if not defined MSYSTEM set MSYSTEM=MSYS32
set _CMS=%~dp0
set _BIN=/usr/bin
set _OPT=
set _OPT=%_OPT% --title ">> Composer CMS v1.4 :: MSYS2 Shell"
set _OPT=%_OPT% --icon %_CMS%/../../icon.ico
set _OPT=%_OPT% --exec %_BIN%/bash
start /b %_CMS%%_BIN%/mintty %_OPT%
:: end of file
