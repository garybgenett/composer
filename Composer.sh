# sh
_COMPOSER="/.g/_data/zactive/coding/composer"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
MSYS2_ARG_CONV_EXCL="--directory:--makefile"
exec "${_COMPOSER}/bin/${_SYS}/usr/bin/make" --directory "${_COMPOSER}" --makefile "${_COMPOSER}/Makefile" BUILD_PLAT="Linux" BUILD_ARCH="x86_64" COMPOSER_PROGS_USE="1" shell
# end of file
