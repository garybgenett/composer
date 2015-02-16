# sh
_CMS="${PWD}"
_SYS="Linux"; [ -n "${MSYSTEM}" ] && _SYS="Msys"
_HOME=${_CMS}/.home
_PATH=${_HOME}/bin
_PATH=${_PATH};${_HOME}/msys32/usr/bin
_PATH=${_PATH};${_CMS}/bin/${_SYS}/usr/bin
_PATH=${_PATH};${_HOME}/.coreutils
PATH=${_PATH};${PATH}
#WORKING : if [ ! -d %_HOME%/msys32/usr/bin ]; then COMPOSER_PROGS_USE="1"
exec make --makefile Makefile --debug="a" shell
# end of file
