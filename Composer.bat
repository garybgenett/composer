@echo off
set _CMS=%~dp0
set _SYS=Msys
set PATH=%_CMS%/bin/%_SYS%/usr/bin;%_CMS%/.home/.coreutils;%PATH%
start /b make --makefile Makefile --debug="a" BUILD_PLAT="Linux" BUILD_ARCH="x86_64" COMPOSER_PROGS_USE="1" shell-msys
:: end of file
