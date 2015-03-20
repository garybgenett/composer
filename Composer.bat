@echo off
set _CMS=%~dp0
set _SYS=Msys
set _DIR=%_CMS%/.home
set _BIN=
set _BIN=%_BIN%%_DIR%/bin/;
set _BIN=%_BIN%%_DIR%/msys32/usr/bin;
set _BIN=%_BIN%%_CMS%/bin/%_SYS%/usr/bin;
set PATH=%_BIN%%PATH%
set _OPT=1
if exist %_DIR%/bin set _OPT=
if exist %_DIR%/msys32/usr/bin set _OPT=
start /b make --makefile Makefile --debug="a" COMPOSER_PROGS_USE="%_OPT%" BUILD_PLAT="%_SYS%" shell-msys
:: end of file
