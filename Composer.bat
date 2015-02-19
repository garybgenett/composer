@echo off
set _CMS=%~dp0
set _SYS=Msys
set _DIR=%_CMS%/.home
set _BIN=
set _BIN=%_BIN%%_DIR%/bin/;
set _BIN=%_BIN%%_DIR%/msys64/usr/bin;
set _BIN=%_BIN%%_CMS%/bin/%_SYS%/usr/bin;
set PATH=%_BIN%%PATH%
set _OPT=
if not exist %_DIR%/msys64/usr/bin set _OPT=%_OPT% COMPOSER_PROGS_USE="1"
start /b make --makefile Makefile --debug="a" BUILD_PLAT="%_SYS%" %_OPT% shell-msys
:: end of file
