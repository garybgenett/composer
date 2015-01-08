# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
PATH="${_CMS}/bin/${_SYS}/usr/bin:${_CMS}/.home/.coreutils:${PATH}"
exec make --makefile Makefile --debug="a" BUILD_PLAT="Linux" BUILD_ARCH="x86_64" COMPOSER_PROGS_USE="1" shell
# end of file
