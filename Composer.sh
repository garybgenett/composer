# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
_DIR=${_CMS}/.home
_BIN=
_BIN=${_BIN}${_DIR}/bin:
_BIN=${_BIN}${_DIR}/msys64/usr/bin:
_BIN=${_BIN}${_CMS}/bin/${_SYS}/usr/bin:
PATH=${_BIN}${PATH}
_OPT=
[ ! -d ${_DIR}/msys64/usr/bin ] && _OPT="${_OPT} COMPOSER_PROGS_USE=\"1\""
exec make --makefile Makefile --debug="a" BUILD_PLAT="${_SYS}" ${_OPT} shell
# end of file
