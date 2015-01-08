# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
PATH="${_CMS}/bin/${_SYS}/usr/bin:${_CMS}/.home/.coreutils:${PATH}"
exec make --makefile Makefile --debug="a" COMPOSER_PROGS_USE="1" shell
# end of file
