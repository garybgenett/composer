# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
_BIN="/usr/bin"
_DIR="${_CMS}/.home"
_PTH=
_PTH="${_PTH}${_DIR}${_BIN}:"
_PTH="${_PTH}${_DIR}/msys32${_BIN}:"
_PTH="${_PTH}${_CMS}/bin/${_SYS}${_BIN}:"
PATH="${_PTH}${PATH}"
_OPT="1"
[ -d "${_DIR}${_BIN}" ] && _OPT=
[ -d "${_DIR}/msys32${_BIN}" ] && _OPT=
exec make --makefile Makefile --debug="a" COMPOSER_PROGS_USE="${_OPT}" BUILD_PLAT="${_SYS}" shell
# end of file
