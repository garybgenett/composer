@echo off
set _CMS=%~dp0
set _SYS=Msys
set _HOME=%_CMS%/.home
set _PATH=%_HOME%/bin
set _PATH=%_PATH%;%_HOME%/msys32/usr/bin
set _PATH=%_PATH%;%_CMS%/bin/%_SYS%/usr/bin
set _PATH=%_PATH%;%_HOME%/.coreutils
set PATH=%_PATH%;%PATH%
::WORKING : if [ ! -d %_HOME%/msys32/usr/bin ]; then COMPOSER_PROGS_USE="1"
start /b make --makefile Makefile --debug="a" shell-msys
:: end of file
