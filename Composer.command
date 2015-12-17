# sh
_CMS="${PWD}"; [ "${TERM_PROGRAM}" == "Apple_Terminal" ] && _CMS="$(dirname ${0})" && cd "${_CMS}"
_SYS="Linux"; [ "${TERM_PROGRAM}" == "Apple_Terminal" ] && _SYS="Darwin"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
_MAK="make";
_TAB="etc/fstab"
_BIN="usr/bin"
_ABD="${_CMS}/.home"
_PRG="${_CMS}/bin/Linux"
if [ -e "${_ABD}/${_TAB}" ]; then
PATH="${_ABD}/${_BIN}:${PATH}"
_OPT=
elif [ -e "${_ABD}/msys64/${_TAB}" ]; then
PATH="${_ABD}/msys64/${_BIN}:${PATH}"
_OPT="0"
elif [ -e "${_CMS}/bin/${_SYS}/${_TAB}" ]; then
PATH="${_CMS}/bin/${_SYS}/${_BIN}:${PATH}"
_OPT="1"
fi
${_MAK} --makefile Makefile --debug="a" COMPOSER_PROGS_USE="${_OPT}" BUILD_PLAT="${_SYS}" BUILD_ARCH= shell
# end of file
