@echo off
set _COMPOSER=%~dp0
set _SYS=Msys
"%_COMPOSER%/bin/%_SYS%/usr/bin/make" BUILD_PLAT="Linux" BUILD_ARCH="i686" COMPOSER_PROGS_USE="1" shell-msys
:: end of file
