# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
_DIR=${_CMS}/.home
_BIN=
_BIN=${_BIN}${_DIR}/bin:
_BIN=${_BIN}${_DIR}/msys64/usr/bin:
_BIN=${_BIN}${_DIR}/msys32/usr/bin:
_BIN=${_BIN}${_CMS}/bin/${_SYS}/usr/bin:
PATH=${_BIN}${PATH}
_OPT=1
[ -d ${_DIR}/bin ] && _OPT=
[ -d ${_DIR}/msys64/usr/bin ] && _OPT=
[ -d ${_DIR}/msys32/usr/bin ] && _OPT=
exec make --makefile Makefile --debug="a" COMPOSER_PROGS_USE="${_OPT}" BUILD_PLAT="${_SYS}" shell
# end of file
