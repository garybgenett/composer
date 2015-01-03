#!/usr/bin/env sh
_COMPOSER="`dirname "${0}"`"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
export PATH="${_COMPOSER}/bin/${_SYS}/usr/bin:${PATH}"
make --makefile "${_COMPOSER}/Makefile" BUILD_PLAT="Linux" BUILD_ARCH="i686" COMPOSER_PROGS_USE="1" shell
# end of file
