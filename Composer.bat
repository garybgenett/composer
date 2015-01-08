@echo off
set _CMS=%~dp0
set _SYS=Msys
set PATH=%_CMS%/bin/%_SYS%/usr/bin;%_CMS%/.home/.coreutils;%PATH%
start /b make --makefile Makefile --debug="a" COMPOSER_PROGS_USE="1" shell-msys
:: end of file
