# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
_BIN="usr/bin"
_ABD="${_CMS}/.home"
_PRG="${_CMS}/bin/Linux"
_OPT="1"
if [ -e "${_ABD}/${_BIN}" ]; then
PATH="${_ABD}/${_BIN}:${PATH}"
_OPT=
elif [ -e "${_ABD}/msys32/${_BIN}" ]; then
PATH="${_ABD}/msys32/${_BIN}:${PATH}"
_OPT=
elif [ -e "${_CMS}/bin/${_SYS}/${_BIN}" ]; then
PATH="${_CMS}/bin/${_SYS}/${_BIN}:${PATH}"
_OPT=1
fi
exec make --makefile Makefile --debug="a" COMPOSER_ESCAPES="0" COMPOSER_PROGS_USE="${_OPT}" BUILD_PLAT="${_SYS}" BUILD_ARCH= shell
# end of file
