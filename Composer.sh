# bash
_COMPOSER="`dirname "${0}"`"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
"${_COMPOSER}/bin/${_SYS}/usr/bin/make" BUILD_PLAT="Linux" BUILD_ARCH="i686" COMPOSER_PROGS_USE="1" shell
# end of file
