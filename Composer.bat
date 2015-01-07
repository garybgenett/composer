@echo off
set _COMPOSER=%~dp0
set _SYS=Msys
set MSYS2_ARG_CONV_EXCL=--directory:--makefile
start /b "%_COMPOSER%/bin/%_SYS%/usr/bin/make" --directory "%_COMPOSER%" --makefile "%_COMPOSER%/Makefile" BUILD_PLAT="Linux" BUILD_ARCH="x86_64" COMPOSER_PROGS_USE="1" shell-msys
:: end of file
