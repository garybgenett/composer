@echo off
set _COMPOSER=%~dp0
set _SYS=Msys
set PATH=%_COMPOSER%/bin/%_SYS%/usr/bin;%PATH%
start /b make --makefile %_COMPOSER%/Makefile BUILD_PLAT="Linux" BUILD_ARCH="i686" COMPOSER_PROGS_USE="1" shell-msys
:: end of file
