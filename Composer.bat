@echo off
set _CMS=%~dp0
set _SYS=Msys
set _BIN=/usr/bin
set _DIR=%_CMS%/.home
set _PTH=
set _PTH=%_PTH%%_DIR%%_BIN%;
set _PTH=%_PTH%%_DIR%/msys32%_BIN%;
set _PTH=%_PTH%%_CMS%/bin/%_SYS%%_BIN%;
set PATH=%_PTH%%PATH%
set _OPT=1
if exist %_DIR%%_BIN% set _OPT=
if exist %_DIR%/msys32%_BIN% set _OPT=
start /b make --makefile Makefile --debug="a" COMPOSER_PROGS_USE="%_OPT%" BUILD_PLAT="%_SYS%" shell-msys
:: end of file
