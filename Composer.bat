@echo off
set _CMS=%~dp0
set _SYS=Msys
set _MAK=make
set _TAB=etc/fstab
set _BIN=usr/bin
set _ABD=%_CMS%/.home
set _PRG=%_CMS%/bin/Linux
if exist %_ABD%/%_TAB%				goto dir_home
if exist %_ABD%/macports/%_TAB%			goto dir_port
if exist %_ABD%/msys64/%_TAB%	goto dir_msys
if exist %_CMS%/bin/%_SYS%/%_TAB%		goto dir_prog
::WORKING:MACP
goto do_make
:dir_home
set PATH=%_ABD%/%_BIN%;%PATH%
set _OPT=
goto do_make
:dir_port
set PATH=%_ABD%/macports/bin;%_ABD%/macports/libexec/gnubin;%PATH%
set _OPT=0
goto do_make
:dir_msys
set PATH=%_ABD%/msys64/%_BIN%;%PATH%
set _OPT=0
goto do_make
:dir_prog
set PATH=%_CMS%/bin/%_SYS%/%_BIN%;%PATH%
set _OPT=1
goto do_make
:do_make
start /b %_MAK% --makefile Makefile --debug="a" COMPOSER_PROGS_USE="%_OPT%" BUILD_PLAT="%_SYS%" BUILD_ARCH= shell-msys
::#>set /p ENTER="Hit ENTER to proceed."
:: end of file
