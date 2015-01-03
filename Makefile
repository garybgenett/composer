#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################
#
#TODO : portability
# Every attempt has been made to make this as portable as possible:
#	http://www.gnu.org/software/make/manual/make.html#toc-Features-of-GNU-make
#	http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Make
#	http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
#
# Please report any cross-platform issues, or issues with other versions of Make.
#
################################################################################

#WORKING
# _ make sure all commands are using their variable counterparts
# _ trim down the "ifeq($BUILD_PLAT,Msys)" to only the things which are necessary
# _ add "licenses" or "info" option, to display list of included programs and licenses
# _ make sure all referenced programs are included (goal is composer should function as a chroot)
# _ do an initial make in Composer.sh, to ensure dirname is available?
# _ update COMPOSER_ALL_REGEX :: will impact ALL_TARGETS variable
# _ make all network operations non-blocking (i.e. use "|| true" on "curl, git, cabal update, etc.")
# _ pull all external files into core makefile, so that entire repository sources from single text file (not necessary, but really cool!)
# _ template inherit & archive target
# _ double-check texlive directory list against list of modules in pandoc manual
# _ comments, comments, comments (& formatting :)
#WORKING

#TODO : new features
# http://www.html5rocks.com/en/tutorials/webcomponents/imports
# http://filoxus.blogspot.com/2008/01/how-to-insert-watermark-in-latex.html
#TODO

#TODO
# bash/less/vim
#	add needed files to bindir
#	does the right bash get run with shell-msys?  when in COMPOSER_ABODE?  when in bindir?
# mingw for windows?
#	re-verify all sed and other build hackery, for both linux and windows
# double-check all "thanks" comments; some are things you should have known
# double-check all licenses
# fix linux 32-bit make 4.1 segfault
# upx final binaries?
#TODO

#BUILD NOTES
# perl is a dependency
# add 'make check' to list; it's where you get current version information
# if using cygwin, need to map cygdrive to /
#	asssume "/c" paths
# if using windows, the $APPDATA/cabal directory
#BUILD NOTES

#BUILD TEST
# test install in gary-os
#	ifconfig eth0 down before make build
#	standalone pandoc binary without build directory
#	try building non-BUILD_DIST version
# test install in basic debian, with no devel packages
# test install in fresh cygwin
#	hack setup.bat
#	try "build" without networking available
#	try building 64-bit version
# full test pass
#	linux 64-bit stage3 BUILD_DIST=
#	linux 32-bit stage3 BUILD_DIST=1
#	windows 64-bit BUILD_DIST=
#	windows 32-bit BUILD_DIST=1
# do a "diff -qr" of build chroot after completion
#BUILD TEST

#OTHER NOTES
# dependencies/credits list
#	add msys/mingw-w64 project
#	add musl project (and libraries)
#	replace wget with curl project
# now need zip/unzip in path
#	add zip/unzip [ -x ... ] checks and message (read ENTER) if not
# markdown-viewer xpi package
#OTHER NOTES

#AFTER NOTES
# .bashrc
#	alias to "make shell"
# _sync clean
#	symlink ".bash_history" to "composer" directory in ".history"
# add composer to gary-os
#	use same git method as for gary-os repo, which should be "rsync" then "git reset --hard"
#AFTER NOTES

override COMPOSER_SETTINGS		:= .composer.mk
override COMPOSER_INCLUDE		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/$(COMPOSER_SETTINGS)

ifneq ($(wildcard $(COMPOSER_INCLUDE)),)
include $(COMPOSER_INCLUDE)
override MAKEFILE_LIST			:= $(filter-out $(COMPOSER_INCLUDE),$(MAKEFILE_LIST))
endif

########################################

override COMPOSER			:= $(abspath $(lastword $(MAKEFILE_LIST)))
override COMPOSER_SRC			:= $(abspath $(firstword $(MAKEFILE_LIST)))
override COMPOSER_DIR			:= $(abspath $(dir $(COMPOSER)))

override COMPOSER_FIND			= $(firstword $(wildcard $(abspath $(addsuffix /$(2),$(1)))))

########################################

override COMPOSER_VERSION_CURRENT	:= v1.4
override COMPOSER_BASENAME		:= Composer
override COMPOSER_FULLNAME		:= $(COMPOSER_BASENAME) CMS $(COMPOSER_VERSION_CURRENT)

ifneq ($(wildcard $(COMPOSER_DIR).git),)
override COMPOSER_GITREPO		?= $(COMPOSER_DIR).git
else ifneq ($(wildcard $(COMPOSER_DIR)/.git),)
override COMPOSER_GITREPO		?= $(COMPOSER_DIR)/.git
else
override COMPOSER_GITREPO		?= https://github.com/garybgenett/composer.git
endif

override COMPOSER_VERSION		?= $(COMPOSER_VERSION_CURRENT)
override COMPOSER_ESCAPES		?= 1

################################################################################

override MAKEFILE			:= Makefile
override MAKEFLAGS			:= --no-builtin-rules --no-builtin-variables

override COMPOSER_STAMP			?= .composed
override COMPOSER_CSS			?= composer.css

override COMPOSER_EXT			?= md
override COMPOSER_IMG			:= png
override COMPOSER_FILES			?=
#>	$(MAKEFILE) \
#>	*.$(COMPOSER_EXT) \
#>	*.$(COMPOSER_IMG) \
#>	*.css

########################################

override TYPE				?= html
override BASE				?= README
override LIST				?= $(BASE).$(COMPOSER_EXT)

# have to keep these around for a bit, after changing the names of them
override CSS				?= $(DCSS)
override TTL				?= $(NAME)
override OPT				?= $(OPTS)

override CSS_FILE			:= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override CSS				?=
override TTL				?=
override TOC				?=
override LVL				?= 2
override OPT				?=

################################################################################

override COMPOSER_TARGET		:= compose
override COMPOSER_PANDOC		:= pandoc
override RUNMAKE			:= $(MAKE) --makefile "$(COMPOSER_SRC)"
override COMPOSE			:= $(RUNMAKE) $(COMPOSER_TARGET)
override MAKEDOC			:= $(RUNMAKE) $(COMPOSER_PANDOC)

override HELPOUT			:= usage
override HELPALL			:= help

#WORK : turn remaining targets into variables, as well...
#	# grep PHONY Makefile
#	.make_database
#	.all_targets
#	.release-config
#	.release
#	.release-test
#	.release-debug
#	.dist
#	all
#	clean
#	whoami
#	settings
#	setup
#	subdirs
#	print

override DEBUGIT			:= debug
override TARGETS			:= targets

override EXAMPLE			:= template
override TESTING			:= test
override INSTALL			:= install
override REPLICA			:= clone
override UPGRADE			:= update

override STRAPIT			:= bootstrap
override FETCHIT			:= fetch
override BUILDIT			:= build
override CHECKIT			:= check
override SHELLIT			:= shell

override ~				:= "'$$'"
override COMPOSER_ABSPATH		:= $(~)(abspath $(~)(dir $(~)(lastword $(~)(MAKEFILE_LIST))))
override COMPOSER_ALL_REGEX		:= [a-zA-Z0-9][a-zA-Z0-9_.-]+

ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER),$(COMPOSER_SRC))
#>override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^($(COMPOSER_ALL_REGEX))[:].*$$|\1|gp" "$(COMPOSER_SRC)")
override COMPOSER_TARGETS		:= $(shell sed -r -n "s|^($(COMPOSER_ALL_REGEX))[:].*$$|\1|gp" "$(COMPOSER_SRC)")
else
override COMPOSER_TARGETS		?= $(BASE)
endif
endif

override COMPOSER_SUBDIRS		?=
override COMPOSER_DEPENDS		?=
override COMPOSER_DEBUGIT		?=
override COMPOSER_TESTING		?=

override TESTING_DIR			:= $(COMPOSER_DIR)/$(TESTING).dir

########################################

override INPUT				:= markdown
override OUTPUT				:= $(TYPE)
override EXTENSION			:= $(TYPE)

override TYPE_HTML			:= html
override TYPE_LPDF			:= pdf
override TYPE_PRES			:= revealjs
override TYPE_SHOW			:= slidy
override TYPE_DOCX			:= docx
override TYPE_EPUB			:= epub

override PRES_EXTN			:= $(TYPE_PRES).$(TYPE_HTML)
override SHOW_EXTN			:= $(TYPE_SHOW).$(TYPE_HTML)

ifeq ($(TYPE),$(TYPE_HTML))
override OUTPUT				:= html5
endif
ifeq ($(TYPE),$(TYPE_LPDF))
override OUTPUT				:= latex
endif
ifeq ($(TYPE),$(TYPE_PRES))
override OUTPUT				:= revealjs
override EXTENSION			:= $(PRES_EXTN)
endif
ifeq ($(TYPE),$(TYPE_SHOW))
override OUTPUT				:= slidy
override EXTENSION			:= $(SHOW_EXTN)
endif

override HTML_DESC			:= HTML: HyperText Markup Language
override LPDF_DESC			:= PDF: Portable Document Format
override PRES_DESC			:= HTML/JS Presentation: Reveal.js
override SHOW_DESC			:= HTML/JS Slideshow: W3C Slidy2
override DOCX_DESC			:= DocX: Microsoft Office Open XML
override EPUB_DESC			:= ePUB: Electronic Publication

########################################

# https://github.com/Thiht/markdown-viewer/blob/master/LICENSE (license: BSD)
# https://github.com/Thiht/markdown-viewer
override MDVIEWER_SRC			:= https://github.com/Thiht/markdown-viewer.git
override MDVIEWER_DST			:= $(COMPOSER_DIR)/markdown-viewer
override MDVIEWER_CSS			:= $(MDVIEWER_DST)/chrome/skin/markdown-viewer.css
override MDVIEWER_CMT			:= 015af3868d29088472876a36afd397efd5c767af
#WORK override MDVIEWER_CMT			:= 2fa921cf8ab7029f3a78e481c136240304ee28c8

# https://github.com/hakimel/reveal.js/blob/master/LICENSE (license: BSD)
# https://github.com/hakimel/reveal.js
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DST			:= $(COMPOSER_DIR)/revealjs
#>override REVEALJS_CSS			:= $(REVEALJS_DST)/css/theme/default.css
override REVEALJS_CSS			:= $(COMPOSER_DIR)/revealjs.css
override REVEALJS_CMT			:= 2.6.2

# http://www.w3.org/Consortium/Legal/copyright-software (license: MIT)
# http://www.w3.org/Talks/Tools/Slidy2/Overview.html#%286%29
override W3CSLIDY_SRC			:= http://www.w3.org/Talks/Tools/Slidy2/slidy.zip
override W3CSLIDY_DST			:= $(COMPOSER_DIR)/slidy/Slidy2
override W3CSLIDY_CSS			:= $(W3CSLIDY_DST)/styles/slidy.css

override _CSS				:= $(MDVIEWER_CSS)
ifneq ($(wildcard $(CSS)),)
override _CSS				:= $(CSS)
else ifneq ($(wildcard $(CSS_FILE)),)
override _CSS				:= $(CSS_FILE)
else ifeq ($(OUTPUT),revealjs)
override _CSS				:= $(REVEALJS_CSS)
else ifeq ($(OUTPUT),slidy)
override _CSS				:= $(W3CSLIDY_CSS)
endif

override _TOC				:=
ifneq ($(TOC),)
override _TOC				:= \
	--table-of-contents \
	--toc-depth $(TOC)
endif

override PANDOC_OPTIONS			:= \
	--standalone \
	--self-contained \
	\
	--css "$(_CSS)" \
	--title-prefix "$(TTL)" \
	--output "$(BASE).$(EXTENSION)" \
	--from "$(INPUT)" \
	--to "$(OUTPUT)" \
	\
	$(_TOC) \
	--slide-level $(LVL) \
	--variable "revealjs-url=$(REVEALJS_DST)" \
	--variable "slidy-url=$(W3CSLIDY_DST)" \
	\
	--chapters \
	--listings \
	--normalize \
	--smart \
	\
	$(OPT) \
	$(LIST)

########################################

override COMPOSER_OTHER			?= $(COMPOSER_DIR)
override COMPOSER_ABODE			?= $(COMPOSER_OTHER)/.home
override COMPOSER_STORE			?= $(COMPOSER_OTHER)/.sources
override COMPOSER_BUILD			?= $(COMPOSER_OTHER)/build

override BUILD_BRANCH			:= composer_$(BUILDIT)
override BUILD_STRAP			:= $(COMPOSER_BUILD)/$(STRAPIT)
override BUILD_DIST			?=
override BUILD_MSYS			?=
override BUILD_GHC_78			?=

#>override BUILD_PLAT			:= Linux
#>override BUILD_ARCH			:= x86_64
override BUILD_PLAT			?= $(shell uname -o)
override BUILD_ARCH			?= $(shell uname -m)

ifneq ($(BUILD_MSYS),)
override BUILD_PLAT			:= Msys
endif
ifeq ($(BUILD_PLAT),GNU/Linux)
override BUILD_PLAT			:= Linux
else ifeq ($(BUILD_PLAT),Cygwin)
override BUILD_PLAT			:= Msys
endif
ifeq ($(BUILD_PLAT),Msys)
override BUILD_MSYS			:= 1
endif

ifeq ($(BUILD_ARCH),x86_64)
override BUILD_BITS			:= 64
else
override BUILD_BITS			:= 32
endif

override COMPOSER_PROGS			?= $(COMPOSER_OTHER)/bin/$(BUILD_PLAT)
override COMPOSER_PROGS_USE		?=

# thanks for the 'LANG' fix below: https://stackoverflow.com/questions/23370392/failed-installing-dependencies-with-cabal
#	found by: https://github.com/faylang/fay/issues/261
override LANG				?= en_US.UTF-8
override TERM				?= ansi
override CC				?= gcc
override CHOST				:=
override CFLAGS				:= -L$(COMPOSER_ABODE)/lib -I$(COMPOSER_ABODE)/include
override LDFLAGS			:= -L$(COMPOSER_ABODE)/lib
#WORK : will need this to implement "chroot" composer
#override LD_LIBRARY_PATH		:= $(COMPOSER_PROGS)/lib.so:$(LD_LIBRARY_PATH)

ifneq ($(BUILD_DIST),)
ifeq ($(BUILD_PLAT),Linux)
override BUILD_MSYS			:=
override BUILD_PLAT			:= Linux
override BUILD_ARCH			:= i686
override BUILD_BITS			:= 32
override CHOST				:= $(BUILD_ARCH)-pc-linux-gnu
else ifeq ($(BUILD_PLAT),Msys)
override BUILD_MSYS			:= 1
override BUILD_PLAT			:= Msys
override BUILD_ARCH			:= i686
override BUILD_BITS			:= 32
override CHOST				:= $(BUILD_ARCH)-pc-msys$(BUILD_BITS)
endif
override CFLAGS				:= $(CFLAGS) -m$(BUILD_BITS) -march=$(BUILD_ARCH) -mtune=generic
endif

ifeq ($(BUILD_PLAT),Linux)
ifneq ($(BUILD_GHC_78),)
override GHC_BIN_PLAT			:= unknown-linux-deb7
else
override GHC_BIN_PLAT			:= unknown-linux
endif
else ifeq ($(BUILD_PLAT),FreeBSD)
ifneq ($(BUILD_GHC_78),)
override GHC_BIN_PLAT			:= portbld-freebsd
else
override GHC_BIN_PLAT			:= unknown-freebsd
endif
else ifeq ($(BUILD_PLAT),Darwin)
ifneq ($(BUILD_GHC_78),)
ifeq ($(BUILD_ARCH),x86_64)
override GHC_BIN_PLAT			:= apple-darwin
else
override GHC_BIN_PLAT			:= apple-ios
endif
else
override GHC_BIN_PLAT			:= apple-darwin
endif
else ifeq ($(BUILD_PLAT),Msys)
override GHC_BIN_PLAT			:= unknown-mingw32
endif

override MSYS_BIN_ARCH			:= $(BUILD_ARCH)
override GHC_BIN_ARCH			:= $(BUILD_ARCH)
ifeq ($(BUILD_ARCH),i686)
override GHC_BIN_ARCH			:= i386
else ifeq ($(BUILD_ARCH),i386)
override MSYS_BIN_ARCH			:= i686
endif

# http://git.savannah.gnu.org/gitweb/?p=config.git
override GNU_CFG_SRC			:= http://git.savannah.gnu.org/r/config.git
override GNU_CFG_FILE_SRC		:= http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=
override GNU_CFG_FILE_GUS		:= config.guess
override GNU_CFG_FILE_SUB		:= config.sub
override GNU_CFG_DST			:= $(COMPOSER_BUILD)/gnu-config
override GNU_CFG_CMT			:=

# http://sourceforge.net/p/msys2/code/ci/master/tree/COPYING3 (license: GPL, LGPL)
# http://sourceforge.net/projects/msys2
# http://sourceforge.net/p/msys2/wiki/MSYS2%20installation
# https://www.archlinux.org/groups
override MSYS_VERSION			:= 20140704
override MSYS_BIN_SRC			:= http://sourceforge.net/projects/msys2/files/Base/$(MSYS_BIN_ARCH)/msys2-base-$(MSYS_BIN_ARCH)-$(MSYS_VERSION).tar.xz
override MSYS_BIN_DST			:= $(COMPOSER_ABODE)/msys$(BUILD_BITS)
#WORK : mintty - installed before bash?  cygwin-console-helper?

# https://www.kernel.org/pub/linux/kernel/COPYING (license: GPL)
# https://www.kernel.org
override LINUX_VERSION			:= 3.18.1
override LINUX_TAR_SRC			:= https://www.kernel.org/pub/linux/kernel/v3.x/linux-$(LINUX_VERSION).tar.gz
override LINUX_TAR_DST			:= $(BUILD_STRAP)/linux-$(LINUX_VERSION)
# https://www.gnu.org/software/libc (license: GPL)
# https://www.gnu.org/software/libc
override GLIBC_VERSION			:= 2.20
override GLIBC_TAR_SRC			:= https://ftp.gnu.org/gnu/glibc/glibc-$(GLIBC_VERSION).tar.gz
override GLIBC_TAR_DST			:= $(BUILD_STRAP)/glibc-$(GLIBC_VERSION)
# http://www.zlib.net/zlib_license.html (license: custom = as-is)
# http://www.zlib.net
override ZLIB_VERSION			:= 1.2.8
override ZLIB_TAR_SRC			:= http://www.zlib.net/zlib-$(ZLIB_VERSION).tar.xz
override ZLIB_TAR_DST			:= $(BUILD_STRAP)/zlib-$(ZLIB_VERSION)
# https://gmplib.org (license: GPL, LGPL)
# https://gmplib.org
override GMP_VERSION			:= 6.0.0a
override GMP_TAR_SRC			:= https://gmplib.org/download/gmp/gmp-$(GMP_VERSION).tar.xz
override GMP_TAR_DST			:= $(BUILD_STRAP)/gmp-$(subst a,,$(GMP_VERSION))
# https://www.gnu.org/software/gettext (license: GPL, LGPL)
# https://www.gnu.org/software/gettext
override GETTEXT_VERSION		:= 0.19.3
override GETTEXT_TAR_SRC		:= https://ftp.gnu.org/pub/gnu/gettext/gettext-$(GETTEXT_VERSION).tar.gz
override GETTEXT_TAR_DST		:= $(BUILD_STRAP)/gettext-$(GETTEXT_VERSION)
# https://www.gnu.org/software/libiconv (license: GPL, LGPL)
# https://www.gnu.org/software/libiconv
override LIBICONV_VERSION		:= 1.14
override LIBICONV_TAR_SRC		:= https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(LIBICONV_VERSION).tar.gz
override LIBICONV_TAR_DST		:= $(BUILD_STRAP)/libiconv-$(LIBICONV_VERSION)
# https://www.gnu.org/software/ncurses (license: custom = as-is)
# https://www.gnu.org/software/ncurses
override NCURSES_VERSION		:= 5.9
override NCURSES_TAR_SRC		:= https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES_VERSION).tar.gz
override NCURSES_TAR_DST		:= $(BUILD_STRAP)/ncurses-$(NCURSES_VERSION)
# https://www.openssl.org/source/license.html (license: BSD)
# https://www.openssl.org
override OPENSSL_VERSION		:= 1.0.1j
override OPENSSL_TAR_SRC		:= https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz
override OPENSSL_TAR_DST		:= $(BUILD_STRAP)/openssl-$(OPENSSL_VERSION)
# http://sourceforge.net/projects/expat (license: MIT)
# http://expat.sourceforge.net
override EXPAT_VERSION			:= 2.1.0
override EXPAT_TAR_SRC			:= http://sourceforge.net/projects/expat/files/expat/$(EXPAT_VERSION)/expat-$(EXPAT_VERSION).tar.gz
override EXPAT_TAR_DST			:= $(BUILD_STRAP)/expat-$(EXPAT_VERSION)
# http://www.freetype.org/license.html (license: custom = BSD, GPL)
# http://www.freetype.org/download.html
override FREETYPE_VERSION		:= 2.5.3
override FREETYPE_TAR_SRC		:= http://download.savannah.gnu.org/releases/freetype/freetype-$(FREETYPE_VERSION).tar.gz
override FREETYPE_TAR_DST		:= $(BUILD_STRAP)/freetype-$(FREETYPE_VERSION)
# http://www.freedesktop.org/software/fontconfig/fontconfig-devel/ln12.html (license: custom = as-is)
# http://www.freedesktop.org/wiki/Software/fontconfig
override FONTCONFIG_VERSION		:= 2.11.1
override FONTCONFIG_TAR_SRC		:= http://www.freedesktop.org/software/fontconfig/release/fontconfig-$(FONTCONFIG_VERSION).tar.gz
override FONTCONFIG_TAR_DST		:= $(BUILD_STRAP)/fontconfig-$(FONTCONFIG_VERSION)

# https://www.gnu.org/software/coreutils (license: GPL)
# https://www.gnu.org/software/coreutils
override COREUTILS_VERSION		:= 8.23
override COREUTILS_TAR_SRC		:= https://ftp.gnu.org/gnu/coreutils/coreutils-$(COREUTILS_VERSION).tar.xz
override COREUTILS_TAR_DST		:= $(BUILD_STRAP)/coreutils-$(COREUTILS_VERSION)
# https://www.gnu.org/software/findutils (license: GPL)
# https://www.gnu.org/software/findutils
override FINDUTILS_VERSION		:= 4.4.2
override FINDUTILS_TAR_SRC		:= https://ftp.gnu.org/gnu/findutils/findutils-$(FINDUTILS_VERSION).tar.gz
override FINDUTILS_TAR_DST		:= $(BUILD_STRAP)/findutils-$(FINDUTILS_VERSION)
# https://savannah.gnu.org/projects/patch (license: GPL)
# https://savannah.gnu.org/projects/patch
override PATCH_VERSION			:= 2.7
override PATCH_TAR_SRC			:= https://ftp.gnu.org/gnu/patch/patch-$(PATCH_VERSION).tar.xz
override PATCH_TAR_DST			:= $(BUILD_STRAP)/patch-$(PATCH_VERSION)
# https://savannah.gnu.org/projects/sed (license: GPL)
# https://savannah.gnu.org/projects/sed
override SED_VERSION			:= 4.2
override SED_TAR_SRC			:= https://ftp.gnu.org/gnu/sed/sed-$(SED_VERSION).tar.gz
override SED_TAR_DST			:= $(BUILD_STRAP)/sed-$(SED_VERSION)
# http://www.bzip.org (license: custom = BSD)
# http://www.bzip.org
override BZIP_VERSION			:= 1.0.6
override BZIP_TAR_SRC			:= http://www.bzip.org/$(BZIP_VERSION)/bzip2-$(BZIP_VERSION).tar.gz
override BZIP_TAR_DST			:= $(BUILD_STRAP)/bzip2-$(BZIP_VERSION)
# https://www.gnu.org/software/gzip (license: GPL)
# https://www.gnu.org/software/gzip
override GZIP_VERSION			:= 1.6
override GZIP_TAR_SRC			:= https://ftp.gnu.org/gnu/gzip/gzip-$(GZIP_VERSION).tar.gz
override GZIP_TAR_DST			:= $(BUILD_STRAP)/gzip-$(GZIP_VERSION)
# http://www.tukaani.org/xz (license: custom = GPL, public-domain)
# http://www.tukaani.org/xz
override XZ_VERSION			:= 5.2.0
override XZ_TAR_SRC			:= http://www.tukaani.org/xz/xz-$(XZ_VERSION).tar.gz
override XZ_TAR_DST			:= $(BUILD_STRAP)/xz-$(XZ_VERSION)
# https://www.gnu.org/software/tar (license: GPL)
# https://www.gnu.org/software/tar
override TAR_VERSION			:= 1.28
override TAR_TAR_SRC			:= https://ftp.gnu.org/gnu/tar/tar-$(TAR_VERSION).tar.xz
override TAR_TAR_DST			:= $(BUILD_STRAP)/tar-$(TAR_VERSION)
# http://dev.perl.org/licenses (license: custom = GPL, Artistic)
# https://www.perl.org/get.html
override PERL_VERSION			:= 5.20.1
override PERL_TAR_SRC			:= http://www.cpan.org/src/5.0/perl-$(PERL_VERSION).tar.gz
override PERL_TAR_DST			:= $(BUILD_STRAP)/perl-$(PERL_VERSION)

# https://www.gnu.org/software/bash (license: GPL)
# https://www.gnu.org/software/bash
override BASH_VERSION			:= 4.3.30
override BASH_TAR_SRC			:= https://ftp.gnu.org/pub/gnu/bash/bash-$(BASH_VERSION).tar.gz
override BASH_TAR_DST			:= $(COMPOSER_BUILD)/bash-$(BASH_VERSION)

# http://www.greenwoodsoftware.com/less (license: GPL)
# http://www.greenwoodsoftware.com/less
override LESS_VERSION			:= 458
override LESS_TAR_SRC			:= http://www.greenwoodsoftware.com/less/less-$(LESS_VERSION).tar.gz
override LESS_TAR_DST			:= $(COMPOSER_BUILD)/less-$(LESS_VERSION)

# http://www.vim.org/about.php (license: custom = GPL)
# http://www.vim.org
override VIM_VERSION			:= 7.4
override VIM_TAR_SRC			:= http://ftp.vim.org/pub/vim/unix/vim-$(VIM_VERSION).tar.bz2
override VIM_TAR_DST			:= $(COMPOSER_BUILD)/vim$(subst .,,$(VIM_VERSION))

# https://www.gnu.org/software/make/manual/make.html#GNU-Free-Documentation-License (license: GPL)
# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make
# https://savannah.gnu.org/projects/make
override MAKE_SRC			:= http://git.savannah.gnu.org/r/make.git
override MAKE_DST			:= $(COMPOSER_BUILD)/make
override MAKE_CMT			:= 4.0

# http://www.info-zip.org/license.html (license: BSD)
# http://www.info-zip.org
override IZIP_VERSION			:= 3.0
override UZIP_VERSION			:= 6.0
override IZIP_TAR_SRC			:= http://sourceforge.net/projects/infozip/files/Zip%203.x%20%28latest%29/$(IZIP_VERSION)/zip$(subst .,,$(IZIP_VERSION)).tar.gz
override UZIP_TAR_SRC			:= http://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/UnZip%20$(UZIP_VERSION)/unzip$(subst .,,$(UZIP_VERSION)).tar.gz
override IZIP_TAR_DST			:= $(COMPOSER_BUILD)/zip$(subst .,,$(IZIP_VERSION))
override UZIP_TAR_DST			:= $(COMPOSER_BUILD)/unzip$(subst .,,$(UZIP_VERSION))

# http://www.curl.haxx.se/docs/copyright.html (license: MIT)
# http://www.curl.haxx.se/download.html
# http://www.curl.haxx.se/dev/source.html
override CURL_VERSION			:= 7.39.0
override CURL_TAR_SRC			:= http://www.curl.haxx.se/download/curl-$(CURL_VERSION).tar.gz
override CURL_SRC			:= https://github.com/bagder/curl.git
override CURL_TAR_DST			:= $(BUILD_STRAP)/curl-$(CURL_VERSION)
override CURL_DST			:= $(COMPOSER_BUILD)/curl
override CURL_CMT			:= curl-$(subst .,_,$(CURL_VERSION))

# https://github.com/git/git/blob/master/COPYING (license: GPL, LGPL)
# http://git-scm.com
override GIT_VERSION			:= 2.2.0
override GIT_TAR_SRC			:= https://www.kernel.org/pub/software/scm/git/git-$(GIT_VERSION).tar.xz
override GIT_SRC			:= https://git.kernel.org/pub/scm/git/git.git
override GIT_TAR_DST			:= $(BUILD_STRAP)/git-$(GIT_VERSION)
override GIT_DST			:= $(COMPOSER_BUILD)/git
override GIT_CMT			:= v$(GIT_VERSION)

# https://www.tug.org/texlive/LICENSE.TL (license: custom = libre)
# https://www.tug.org/texlive
# https://www.tug.org/texlive/build.html
# ftp://ftp.tug.org/historic/systems/texlive
# http://www.slackbuilds.org/repository/14.0/office/texlive/
override TEX_YEAR			:= 2014
override TEX_VERSION			:= $(TEX_YEAR)0525
override TEX_PDF_VERSION		:= 1.40.15
override TEX_TEXMF_SRC			:= ftp://ftp.tug.org/historic/systems/texlive/$(TEX_YEAR)/texlive-$(TEX_VERSION)-texmf.tar.xz
override TEX_TAR_SRC			:= ftp://ftp.tug.org/historic/systems/texlive/$(TEX_YEAR)/texlive-$(TEX_VERSION)-source.tar.xz
override TEX_TEXMF_DST			:= $(COMPOSER_BUILD)/texlive-$(TEX_VERSION)-texmf
override TEX_TAR_DST			:= $(COMPOSER_BUILD)/texlive-$(TEX_VERSION)-source

# https://www.haskell.org/ghc/license (license: BSD)
# https://www.haskell.org/ghc/download
# https://www.haskell.org/cabal/download.html
# https://hackage.haskell.org/package/cabal-install
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Tools
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Windows
# https://www.haskell.org/haskellwiki/Windows
# https://downloads.haskell.org/~ghc/7.8.3/docs/html/users_guide/options-phases.html
ifneq ($(BUILD_GHC_78),)
override GHC_VERSION			:= 7.8.3
override GHC_VERSION_LIB		:= 1.18.1.3
override GHC_BIN_SRC			:= https://www.haskell.org/ghc/dist/$(GHC_VERSION)/ghc-$(GHC_VERSION)-$(GHC_BIN_ARCH)-$(GHC_BIN_PLAT).tar.xz
else
override GHC_VERSION			:= 7.6.3
override GHC_VERSION_LIB		:= 1.16.0
override GHC_BIN_SRC			:= https://www.haskell.org/ghc/dist/$(GHC_VERSION)/ghc-$(GHC_VERSION)-$(GHC_BIN_ARCH)-$(GHC_BIN_PLAT).tar.bz2
endif
override CABAL_VERSION			:= 1.20.0.2
override CABAL_VERSION_LIB		:= 1.20.0.1
override CBL_TAR_SRC			:= https://www.haskell.org/cabal/release/cabal-install-$(CABAL_VERSION)/cabal-install-$(CABAL_VERSION).tar.gz
override GHC_BIN_DST			:= $(BUILD_STRAP)/ghc-$(GHC_VERSION)
override CBL_TAR_DST			:= $(BUILD_STRAP)/cabal-install-$(CABAL_VERSION)

# https://ghc.haskell.org/trac/ghc/wiki/Building/GettingTheSources
# https://ghc.haskell.org/trac/ghc/wiki/Building/QuickStart
override GHC_SRC			:= https://git.haskell.org/ghc.git
override GHC_DST			:= $(COMPOSER_BUILD)/ghc
override GHC_CMT			:= ghc-$(GHC_VERSION)-release
override GHC_BRANCH			:= ghc-$(GHC_VERSION)

# https://github.com/haskell/haskell-platform
# https://www.vex.net/~trebla/haskell/haskell-platform.xhtml
# https://www.haskell.org/ghc/docs/latest/html/users_guide/packages.html
# https://www.vex.net/~trebla/haskell/sicp.xhtml
override HASKELL_SRC			:= https://github.com/haskell/haskell-platform.git
override HASKELL_DST			:= $(COMPOSER_BUILD)/haskell
override HASKELL_CMT			:= 2013.2.0.0
override HASKELL_TAR			:= $(HASKELL_DST)/src/generic/haskell-platform-$(HASKELL_CMT)

# https://github.com/jgm/pandoc/blob/master/COPYING (license: GPL)
# http://johnmacfarlane.net/pandoc/code.html
# http://johnmacfarlane.net/pandoc/installing.html
# https://github.com/jgm/pandoc/blob/master/INSTALL
# https://github.com/jgm/pandoc/wiki/Installing-the-development-version-of-pandoc
override PANDOC_TYPE_SRC		:= https://github.com/jgm/pandoc-types.git
override PANDOC_MATH_SRC		:= https://github.com/jgm/texmath.git
override PANDOC_HIGH_SRC		:= https://github.com/jgm/highlighting-kate.git
override PANDOC_CITE_SRC		:= https://github.com/jgm/pandoc-citeproc.git
override PANDOC_SRC			:= https://github.com/jgm/pandoc.git
override PANDOC_TYPE_DST		:= $(COMPOSER_BUILD)/pandoc-types
override PANDOC_MATH_DST		:= $(COMPOSER_BUILD)/pandoc-texmath
override PANDOC_HIGH_DST		:= $(COMPOSER_BUILD)/pandoc-highlighting
override PANDOC_CITE_DST		:= $(COMPOSER_BUILD)/pandoc-citeproc
override PANDOC_DST			:= $(COMPOSER_BUILD)/pandoc
override PANDOC_TYPE_CMT		:= 1.12.4
override PANDOC_MATH_CMT		:= 0.8.0.1
override PANDOC_HIGH_CMT		:= 0.5.11.1
override PANDOC_CITE_CMT		:= 0.5
override PANDOC_CMT			:= 1.13.2
override PANDOC_VERSION			:= $(PANDOC_CMT)

override BUILD_PATH_MINGW		:=
ifeq ($(COMPOSER_PROGS_USE),0)
override BUILD_PATH			:= $(PATH)
else
ifeq ($(COMPOSER_PROGS_USE),1)
override BUILD_PATH			:= $(COMPOSER_ABODE)/.coreutils:$(COMPOSER_PROGS)/usr/bin
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_ABODE)/bin
else
override BUILD_PATH			:= $(COMPOSER_ABODE)/bin
endif
override BUILD_PATH			:= $(BUILD_PATH):$(BUILD_STRAP)/bin
ifeq ($(BUILD_PLAT),Msys)
override BUILD_PATH_MINGW		:=               $(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(MSYS_BIN_DST)/usr/bin
endif
override BUILD_PATH			:= $(BUILD_PATH):$(PATH)
ifneq ($(COMPOSER_PROGS_USE),1)
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_ABODE)/.coreutils:$(COMPOSER_PROGS)/usr/bin
endif
endif

override PACMAN_BASE_LIST		:= \
	msys2-runtime \
	msys2-runtime-devel \
	pacman

#>	mingw-w64-i686-toolchain
#>	mingw-w64-x86_64-toolchain
override PACMAN_PACKAGES_LIST		:= \
	base-devel \
	mingw-w64-i686-binutils-git \
	mingw-w64-i686-gcc \
	mingw-w64-x86_64-binutils-git \
	mingw-w64-x86_64-gcc \
	msys2-devel

#TODO : is cygwin-console-helper really needed?  what about cygpath, just in case?
#TODO : probably not all these dlls are needed
# this list should be mirrored to "$(PATH_LIST)" and "$(CHECKIT)" sections
override MSYS_BINARY_LIST		:= \
	mintty cygwin-console-helper \
	\
	msys-2.0.dll \
	msys-gcc_s-1.dll \
	msys-ssp-0.dll \
	msys-stdc++-6.dll

# this list should be mirrored to "$(PATH_LIST)" and "$(CHECKIT)" sections
override BUILD_BINARY_LIST		:= \
	coreutils \
	find \
	patch \
	sed \
	bzip2 \
	gzip \
	xz \
	tar \
	perl \
	\
	bash sh \
	less \
	vim \
	\
	make \
	zip \
	unzip \
	curl \
	git \
	\
	pandoc \
	pandoc-citeproc \
	\
	tex \
	pdflatex \
	\
	ghc ghc-pkg \
	cabal

# thanks for the patches below: https://github.com/Alexpux/MSYS2-packages/tree/master/perl
override PERL_PATCH_LIST		:= \
	/|https://raw.githubusercontent.com/Alexpux/MSYS2-packages/master/perl/perl-5.20.0-msys2.patch

override PERL_MODULES_LIST		:= \
	Encode-Locale-1.03|https://cpan.metacpan.org/authors/id/G/GA/GAAS/Encode-Locale-1.03.tar.gz \
	HTTP-Date-6.02|https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Date-6.02.tar.gz \
	HTTP-Message-6.06|https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Message-6.06.tar.gz \
	Net-HTTP-6.07|https://cpan.metacpan.org/authors/id/M/MS/MSCHILLI/Net-HTTP-6.07.tar.gz \
	URI-1.65|https://cpan.metacpan.org/authors/id/E/ET/ETHER/URI-1.65.tar.gz \
	libwww-perl-6.08|https://cpan.metacpan.org/authors/id/M/MS/MSCHILLI/libwww-perl-6.08.tar.gz

override TEXLIVE_DIRECTORY_LIST		:= \
	fonts/enc/dvips/lm \
	fonts/map/pdftex/updmap \
	fonts/tfm/jknappen/ec \
	fonts/tfm/public/amsfonts/symbols \
	fonts/tfm/public/lm \
	fonts/type1/public/lm \
	tex/generic/ifxetex \
	tex/generic/oberdiek \
	tex/latex/amsfonts \
	tex/latex/amsmath \
	tex/latex/base \
	tex/latex/booktabs \
	tex/latex/graphics \
	tex/latex/hyperref \
	tex/latex/latexconfig \
	tex/latex/listings \
	tex/latex/lm \
	tex/latex/oberdiek \
	tex/latex/pdftex-def \
	tex/latex/tools \
	tex/latex/url

ifneq ($(BUILD_GHC_78),)
override GHC_BASE_LIBRARIES_LIST	:= \
	Win32|WORK \
	array|0.5.0.0 \
	base|4.7.0.1 \
	binary|0.7.1.0 \
	bytestring|0.10.4.0 \
	containers|0.5.5.1 \
	deepseq|1.3.0.2 \
	directory|1.2.1.0 \
	filepath|1.3.0.2 \
	ghc-prim|0.3.1.0 \
	haskeline|0.7.1.2 \
	haskell2010|1.1.2.0 \
	haskell98|2.0.0.3 \
	hoopl|3.10.0.1 \
	hpc|0.6.0.1 \
	integer-gmp|0.5.1.0 \
	old-locale|1.0.0.6 \
	old-time|1.1.0.2 \
	pretty|1.1.1.1 \
	process|1.2.0.0 \
	rts|1.0 \
	template-haskell|2.9.0.0 \
	terminfo|0.4.0.0 \
	time|1.4.2 \
	transformers|0.3.0.0 \
	unix|2.7.0.1 \
	xhtml|3000.2.1
else
override GHC_BASE_LIBRARIES_LIST	:= \
	Win32|2.3.0.0 \
	array|0.4.0.1 \
	base|4.6.0.1 \
	binary|0.5.1.1 \
	bytestring|0.10.0.2 \
	containers|0.5.0.0 \
	deepseq|1.3.0.1 \
	directory|1.2.0.1 \
	filepath|1.3.0.1 \
	ghc-prim|0.3.0.0 \
	haskell2010|1.1.1.0 \
	haskell98|2.0.0.2 \
	hoopl|3.9.0.0 \
	hpc|0.6.0.0 \
	integer-gmp|0.5.0.0 \
	old-locale|1.0.0.5 \
	old-time|1.1.0.1 \
	pretty|1.1.1.0 \
	process|1.1.0.2 \
	rts|1.0 \
	template-haskell|2.8.0.0 \
	time|1.4.0.1 \
	unix|2.6.0.1
endif

override GHC_LIBRARIES_LIST		:= \
	alex|3.1.3 \
	happy|1.19.4

override HASKELL_VERSION_LIST		:= \
	GHC|$(GHC_VERSION) \
	ghc|$(GHC_VERSION) \
	cabal-install|$(CABAL_VERSION) \
	Cabal|$(CABAL_VERSION_LIB) \
	$(GHC_BASE_LIBRARIES_LIST) \
	$(GHC_LIBRARIES_LIST) \

override PANDOC_DEPENDENCIES_LIST	:= \
	hsb2hs|0.2 \
	hxt|9.3.1.4

########################################

# this list should be mirrored from "$(MSYS_BINARY_LIST)" and "$(BUILD_BINARY_LIST)"

override PATH_LIST			:= $(subst :, ,$(BUILD_PATH))
override SHELL				:= $(call COMPOSER_FIND,$(PATH_LIST),sh)

override AUTORECONF			:= "$(call COMPOSER_FIND,$(PATH_LIST),autoreconf)" --force --install
override LDD				:= "$(call COMPOSER_FIND,$(PATH_LIST),ldd)"

override WINDOWS_ACL			:= "$(call COMPOSER_FIND,/c/Windows/SysWOW64 /c/Windows/System32 /c/Windows/System,icacls)"
override PACMAN_ENV			:= "$(MSYS_BIN_DST)/usr/bin/env" - PATH="$(MSYS_BIN_DST)/usr/bin"
override PACMAN_DB_UPGRADE		:= "$(MSYS_BIN_DST)/usr/bin/pacman-db-upgrade"
override PACMAN_KEY			:= "$(MSYS_BIN_DST)/usr/bin/pacman-key"
override PACMAN				:= "$(MSYS_BIN_DST)/usr/bin/pacman" --verbose --noconfirm --sync

override MINTTY				:= "$(call COMPOSER_FIND,$(PATH_LIST),mintty)"
override CYGWIN_CONSOLE_HELPER		:= "$(call COMPOSER_FIND,$(PATH_LIST),cygwin-console-helper)"

override COREUTILS			:= "$(call COMPOSER_FIND,$(PATH_LIST),coreutils)"
override SED				:= "$(call COMPOSER_FIND,$(PATH_LIST),sed)" -r
override define COREUTILS_INSTALL	=
	"$(1)" --coreutils-prog=ginstall -dv "$(2)"; \
	"$(1)" --help | $(SED) -n "s|^[ ]([[][ ])|\1|gp" | $(SED) "s|[ ]|\n|g" | while read FILE; do \
		"$(1)" --coreutils-prog=echo -en "#!$(1) --coreutils-prog-shebang=$${FILE}" >"$(2)/$${FILE}"; \
		"$(1)" --coreutils-prog=chmod 755 "$(2)/$${FILE}"; \
	done; \
	"$(1)" --coreutils-prog=echo -en "#!$(1) --coreutils-prog-shebang=ginstall" >"$(2)/install"; \
	"$(1)" --coreutils-prog=chmod 755 "$(2)/install"
endef
override define COREUTILS_UNINSTALL	=
	"$(1)" --help | $(SED) -n "s|^[ ]([[][ ])|\1|gp" | $(SED) "s|[ ]|\n|g" | while read FILE; do \
		if [ -f "$(2)/$${FILE}" ]; then \
			"$(1)" --coreutils-prog=rm -fv "$(2)/$${FILE}"; \
		fi; \
	done
endef
ifeq ($(COREUTILS),"$(COMPOSER_PROGS)/usr/bin/coreutils")
$(shell $(call COREUTILS_INSTALL,$(COMPOSER_PROGS)/usr/bin/coreutils,$(COMPOSER_ABODE)/.coreutils))
endif
override BASE64				:= "$(call COMPOSER_FIND,$(PATH_LIST),base64)" -w0
override CAT				:= "$(call COMPOSER_FIND,$(PATH_LIST),cat)"
override CHMOD				:= "$(call COMPOSER_FIND,$(PATH_LIST),chmod)" 755
override CP				:= "$(call COMPOSER_FIND,$(PATH_LIST),cp)" -afv
override DATE				:= "$(call COMPOSER_FIND,$(PATH_LIST),date)" --iso
override DIRCOLORS			:= "$(call COMPOSER_FIND,$(PATH_LIST),dircolors)"
override ECHO				:= "$(call COMPOSER_FIND,$(PATH_LIST),echo)" -en
override ENV				:= "$(call COMPOSER_FIND,$(PATH_LIST),env)"
override HEAD				:= "$(call COMPOSER_FIND,$(PATH_LIST),head)"
override LS				:= "$(call COMPOSER_FIND,$(PATH_LIST),ls)" --color=auto --time-style=long-iso -asF -l
override MKDIR				:= "$(call COMPOSER_FIND,$(PATH_LIST),install)" -dv
override MV				:= "$(call COMPOSER_FIND,$(PATH_LIST),mv)" -fv
override PRINTF				:= "$(call COMPOSER_FIND,$(PATH_LIST),printf)"
override RM				:= "$(call COMPOSER_FIND,$(PATH_LIST),rm)" -fv
override SORT				:= "$(call COMPOSER_FIND,$(PATH_LIST),sort)" -u
override TAIL				:= "$(call COMPOSER_FIND,$(PATH_LIST),tail)"
override TOUCH				:= "$(call COMPOSER_FIND,$(PATH_LIST),date)" --rfc-2822 >
override TRUE				:= "$(call COMPOSER_FIND,$(PATH_LIST),true)"

override FIND				:= "$(call COMPOSER_FIND,$(PATH_LIST),find)"
override PATCH				:= "$(call COMPOSER_FIND,$(PATH_LIST),patch)" -p1
#>override SED				:= "$(call COMPOSER_FIND,$(PATH_LIST),sed)" -r
override BZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),bzip2)"
override GZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),gzip)"
override XZ				:= "$(call COMPOSER_FIND,$(PATH_LIST),xz)"
override TAR				:= "$(call COMPOSER_FIND,$(PATH_LIST),tar)" -vvx
override PERL				:= "$(call COMPOSER_FIND,$(PATH_LIST),perl)"

override BASH				:= "$(call COMPOSER_FIND,$(PATH_LIST),bash)"
override SH				:= "$(SHELL)"
override LESS				:= "$(call COMPOSER_FIND,$(PATH_LIST),less)" -rX
override VIM				:= "$(call COMPOSER_FIND,$(PATH_LIST),vim)" -u "$(COMPOSER_ABODE)/.vimrc" -i NONE -p

override MAKE				:= "$(call COMPOSER_FIND,$(PATH_LIST),make)"
override ZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),zip)"
override UNZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),unzip)"
override CURL				:= "$(call COMPOSER_FIND,$(PATH_LIST),curl)" --verbose --location --remote-time
override GIT_PATH			:=  $(call COMPOSER_FIND,$(PATH_LIST),git)
override GIT				:= "$(GIT_PATH)"

override PANDOC				:= "$(call COMPOSER_FIND,$(PATH_LIST),pandoc)"
override PANDOC_CITEPROC		:= "$(call COMPOSER_FIND,$(PATH_LIST),pandoc-citeproc)"
override TEX				:= "$(call COMPOSER_FIND,$(PATH_LIST),tex)"
override PDFLATEX			:= "$(call COMPOSER_FIND,$(PATH_LIST),pdflatex)"
override GHC				:= "$(call COMPOSER_FIND,$(PATH_LIST),ghc)"
override GHC_PKG			:= "$(call COMPOSER_FIND,$(PATH_LIST),ghc-pkg)"
override CABAL				:= "$(call COMPOSER_FIND,$(PATH_LIST),cabal)" --verbose

override define DO_PATCH		=
	$(call CURL_FILE,$(2)); \
	cd "$(1)" && $(PATCH) <"$(COMPOSER_STORE)/$(notdir $(2))"
endef
override define DO_UNTAR		=
	if [ ! -d "$(1)" ]; then \
		$(MKDIR) "$(abspath $(dir $(1)))"; \
		$(TAR) -C "$(abspath $(dir $(1)))" -f "$(COMPOSER_STORE)/$(notdir $(2))" --exclude "$(3)"; \
	fi
endef
override define DO_UNZIP		=
	$(UNZIP) -ou -d "$(abspath $(dir $(1)))" "$(COMPOSER_STORE)/$(notdir $(2))"
endef

override define CURL_FILE		=
	$(MKDIR) "$(COMPOSER_STORE)"; \
	$(CURL) --time-cond "$(COMPOSER_STORE)/$(notdir $(1))" --output "$(COMPOSER_STORE)/$(notdir $(1))" "$(1)"
endef
override define CURL_FILE_GNU_CFG	=
	$(MKDIR) "$(GNU_CFG_DST)"; \
	$(CURL) --time-cond "$(GNU_CFG_DST)/$(1)" --output "$(GNU_CFG_DST)/$(1)" "$(GNU_CFG_FILE_SRC)$(1)"
endef

override GIT_EXEC			:= $(wildcard $(abspath $(dir $(GIT_PATH))../../git-core))
ifneq ($(GIT_EXEC),)
override GIT				:= $(GIT) --exec-path="$(GIT_EXEC)"
endif
override REPLICA_GIT_DIR		:= $(COMPOSER_STORE)/$(COMPOSER_BASENAME).git
override REPLICA_GIT			:= cd "$(CURDIR)" && $(GIT) --git-dir="$(REPLICA_GIT_DIR)"
override GIT_RUN			= cd "$(1)" && $(GIT) --git-dir="$(COMPOSER_STORE)/$(notdir $(1)).git" --work-tree="$(1)" $(2)
override GIT_REPO			= $(call DO_GIT_REPO,$(1),$(2),$(3),$(4),$(COMPOSER_STORE)/$(notdir $(1)).git)
override define DO_GIT_REPO		=
	$(MKDIR) "$(COMPOSER_STORE)"; \
	$(MKDIR) "$(1)"; \
	if [ ! -d "$(5)" ] && [ -d "$(1).git"  ]; then $(MV) "$(1).git"  "$(5)"; fi; \
	if [ ! -d "$(5)" ] && [ -d "$(1)/.git" ]; then $(MV) "$(1)/.git" "$(5)"; fi; \
	if [ ! -d "$(5)" ]; then \
		$(call GIT_RUN,$(1),init); \
		$(call GIT_RUN,$(1),remote add origin "$(2)"); \
	fi; \
	$(ECHO) "gitdir: $(5)" >"$(1)/.git"; \
	$(call GIT_RUN,$(1),config --local --replace-all core.worktree "$(1)"); \
	$(call GIT_RUN,$(1),fetch --all); \
	if [ -n "$(3)" ] && [ -n "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force -B $(4) $(3)); fi; \
	if [ -n "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force -B $(BUILD_BRANCH) $(3)); fi; \
	if [ -z "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force master); fi; \
	$(call GIT_RUN,$(1),reset --hard)
endef
override define GIT_SUBMODULE		=
	if [ -f "$(1)/.gitmodules" ]; then \
		$(call GIT_RUN,$(1),submodule update --init --force); \
	fi
endef
override GIT_SUBMODULE_GHC		= $(call DO_GIT_SUBMODULE_GHC,$(1),$(COMPOSER_STORE)/$(notdir $(1)).git)
override define DO_GIT_SUBMODULE_GHC	=
	$(ECHO) "gitdir: $(2)" >"$(1)/.git"; \
	$(SED) -i \
		-e "s|^([.][ ]+[-][ ]+ghc[.]git)|#\1|g" \
		"$(1)/packages"; \
	$(SED) -i \
		-e "s|[-]d([ ][^ ]+[.]git)|-f\1|g" \
		"$(1)/sync-all"; \
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all get; \
	cd "$(1)" && $(FIND) ./ -mindepth 2 -type d -name ".git" 2>/dev/null | $(SED) -e "s|^[.][/]||g" -e "s|[/][.]git$$||g" | while read FILE; do \
		$(MKDIR) "$(2)/modules/$${FILE}"; \
		$(RM) -r "$(2)/modules/$${FILE}"; \
		$(MV) "$(1)/$${FILE}/.git" "$(2)/modules/$${FILE}"; \
	done; \
	cd "$(2)" && $(FIND) ./modules -type f -name "index" 2>/dev/null | $(SED) -e "s|^[.][/]modules[/]||g" -e "s|[/]index$$||g" | while read FILE; do \
		$(MKDIR) "$(1)/$${FILE}"; \
		$(ECHO) "gitdir: $(2)/modules/$${FILE}" >"$(1)/$${FILE}/.git"; \
		cd "$(1)/$${FILE}" && $(GIT) --git-dir="$(2)/modules/$${FILE}" config --local --replace-all core.worktree "$(1)/$${FILE}"; \
	done; \
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all fetch --all && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all checkout --force -B $(GHC_BRANCH) $(GHC_CMT) && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all reset --hard
endef

override BUILD_TOOLS			:=
ifeq ($(BUILD_PLAT),Msys)
override BUILD_TOOLS			:= $(BUILD_TOOLS) \
	--with-gcc="$(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin/gcc" \
	--with-ld="$(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin/ld"
endif
override CABAL_INSTALL			= $(CABAL) install \
	$(BUILD_TOOLS) \
	--prefix="$(1)" \
	--global \
	--reinstall \
	--force-reinstalls
#>	--avoid-reinstalls

ifneq ($(wildcard $(COMPOSER_ABODE)/ca-bundle.crt),)
override CURL_CA_BUNDLE			?= $(COMPOSER_ABODE)/ca-bundle.crt
else ifneq ($(wildcard $(COMPOSER_PROGS)/ca-bundle.crt),)
override CURL_CA_BUNDLE			?= $(COMPOSER_PROGS)/ca-bundle.crt
else
override CURL_CA_BUNDLE			?=
endif
ifneq ($(CURL_CA_BUNDLE),)
export CURL_CA_BUNDLE
endif

override TEXMFDIST			:= $(wildcard $(abspath $(dir $(call COMPOSER_FIND,$(PATH_LIST),pdflatex))../../texmf-dist))
override TEXMFDIST_BUILD		:= $(wildcard $(abspath $(dir $(call COMPOSER_FIND,$(PATH_LIST),pdflatex))../texmf-dist))
override PANDOC_DATA			:= $(wildcard $(abspath $(dir $(call COMPOSER_FIND,$(PATH_LIST),pandoc))../../pandoc/data))
override PANDOC_DATA_BUILD		:=

ifeq ($(TEXMFDIST),)
ifneq ($(TEXMFDIST_BUILD),)
override TEXMFDIST			:= $(TEXMFDIST_BUILD)
endif
endif
override TEXMFVAR			:= $(subst -dist,-var,$(TEXMFDIST))

ifneq ($(PANDOC_DATA),)
override PANDOC_OPTIONS			:= --data-dir="$(PANDOC_DATA)" $(PANDOC_OPTIONS)
#TODO : some better way to do this?
ifeq ($(BUILD_PLAT),Linux)
override PANDOC_DATA_BUILD		:= $(COMPOSER_ABODE)/share/i386-linux-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/data
else ifeq ($(BUILD_PLAT),Msys)
override PANDOC_DATA_BUILD		:= $(COMPOSER_ABODE)/i386-windows-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/data
endif
endif

override BUILD_ENV			:= \
	LC_ALL="$(LANG)" \
	LANG="$(LANG)" \
	TERM="$(TERM)" \
	CC="$(CC)" \
	CHOST="$(CHOST)" \
	CFLAGS="$(CFLAGS)" \
	CXXFLAGS="$(CFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	\
	USER="$(USER)" \
	HOME="$(COMPOSER_ABODE)" \
	PATH="$(BUILD_PATH)" \
	CURL_CA_BUNDLE="$(CURL_CA_BUNDLE)" \
	TEXMFDIST="$(TEXMFDIST)" \
	TEXMFVAR="$(TEXMFVAR)"
ifeq ($(BUILD_PLAT),Msys)
#TODO : is this still true?
# adding 'USERPROFILE' to list causes 'Setup.exe: illegal operation'
override BUILD_ENV			:= $(BUILD_ENV) \
	CC="$(MSYS_BIN_DST)/usr/bin/gcc" \
	MSYSTEM="MSYS$(BUILD_BITS)" \
	USERNAME="$(USERNAME)" \
	HOMEPATH="$(COMPOSER_ABODE)" \
	\
	ALLUSERSPROFILE="$(COMPOSER_ABODE)" \
	APPDATA="$(COMPOSER_ABODE)" \
	LOCALAPPDATA="$(COMPOSER_ABODE)" \
	TEMP="$(COMPOSER_ABODE)"
endif
override BUILD_ENV			:= $(ENV) - $(BUILD_ENV)
override BUILD_ENV_MINGW		:= $(BUILD_ENV)
ifeq ($(BUILD_PLAT),Msys)
override BUILD_ENV_MINGW		:= $(BUILD_ENV) \
	CC="$(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin/gcc" \
	MSYSTEM="MINGW$(BUILD_BITS)" \
	PATH="$(BUILD_PATH_MINGW):$(BUILD_PATH)"
endif

################################################################################

#WORK : move these to top of file?

.NOTPARALLEL:
.POSIX:
.SUFFIXES:

#>.ONESHELL:
.SHELLFLAGS: -e

########################################

# http://en.wikipedia.org/wiki/ANSI_escape_code
# http://ascii-table.com/ansi-escape-sequences.php
#	default	= light gray
#	header	= light green
#	core	= cyan
#	mark	= yellow
#	note	= red
#	extra	= magenta
#	syntax	= dark blue
ifneq ($(COMPOSER_ESCAPES),)
override [	:= \[
override ]	:= \]
override _D	:= \e[0;37m
override _H	:= \e[0;32m
override _C	:= \e[0;36m
override _M	:= \e[0;33m
override _N	:= \e[0;31m
override _E	:= \e[0;35m
override _S	:= \e[0;34m
else
override [	:=
override ]	:=
override _D	:=
override _H	:=
override _C	:=
override _M	:=
override _N	:=
override _E	:=
override _S	:=
endif

########################################

override NULL		:=
override define NEWLINE	=
$(NULL)
$(NULL)
endef

# thanks for the 'newline' fix below: https://stackoverflow.com/questions/649246/is-it-possible-to-create-a-multi-line-string-variable-in-a-makefile
#	also to: https://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
override define DO_HEREDOC		=
	$(ECHO) -E '$(subst $(call NEWLINE),[N],$(call $(1)))[N]' | $(SED) \
			-e "s|[[]B[]]|\\\\|g" \
			-e "s|[[]N[]]|\\n|g" \
			-e "s|[[]Q[]]|\'|g"
endef

override MARKER		:= >>
override DIVIDE		:= ::
override INDENTING	:= $(NULL) $(NULL) $(NULL)
override COMMENTED	:= $(_S)\#$(_D) $(NULL)

override HEADER_L	:= $(ECHO) "$(_H)$(INDENTING)";	$(PRINTF)  "~%.0s" {1..70}; $(ECHO) "$(_D)\n"
override HEADER_1	:= $(ECHO) "$(_S)";		$(PRINTF) "\#%.0s" {1..72}; $(ECHO) "$(_D)\n"
override HEADER_2	:= $(ECHO) "$(_S)";		$(PRINTF) "\#%.0s" {1..36}; $(ECHO) "$(_D)\n"
ifneq ($(COMPOSER_ESCAPES),)
override TABLE_C2	:= $(PRINTF) "$(COMMENTED)%b\e[128D\e[22C%b$(_D)\n"
override TABLE_I3	:= $(PRINTF) "$(INDENTING)%b\e[128D\e[22C%b\e[128D\e[52C%b$(_D)\n"
override ESCAPE		:= $(PRINTF) "%b$(_D)\n"
else
override TABLE_C2	:= $(PRINTF) "$(COMMENTED)%-20s%s\n"
override TABLE_I3	:= $(PRINTF) "$(INDENTING)%-20s%-30s%s\n"
override ESCAPE		:= $(PRINTF) "%s\n"
endif

override EXAMPLE_SECOND	:= LICENSE
override EXAMPLE_TARGET	:= manual
override EXAMPLE_OUTPUT	:= Users_Guide

########################################

# thanks for the 'regex' fix below: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
#	also to: https://stackoverflow.com/questions/9691508/how-can-i-use-macros-to-generate-multiple-makefile-targets-rules-inside-foreach
#	also to: https://stackoverflow.com/questions/3063507/list-goals-targets-in-gnu-make
#	also to: http://backreference.org/2010/05/31/working-with-blocks-in-sed

.PHONY: .make_database
.make_database:
	@$(RUNMAKE) \
		--silent \
		--question \
		--print-data-base \
		--no-builtin-rules \
		--no-builtin-variables \
		: 2>/dev/null | $(CAT)

.PHONY: .all_targets
.all_targets:
	@$(RUNMAKE) --silent .make_database 2>/dev/null | \
		$(SED) -n -e "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" | \
		$(SED) -n -e "/^$(COMPOSER_ALL_REGEX)[:]/p" | \
		$(SORT)

override .ALL_TARGETS := \
	HELP[_] \
	EXAMPLE[_] \
	$(COMPOSER_TARGET)[:] \
	$(COMPOSER_PANDOC)[:] \
	$(HELPOUT)[:] \
	$(HELPALL)[:] \
	$(DEBUGIT)[:] \
	$(TARGETS)[:] \
	$(EXAMPLE)[:] \
	$(TESTING)[:] \
	$(INSTALL)[:-] \
	$(REPLICA)[:] \
	$(UPGRADE)[:] \
	$(STRAPIT)[:-] \
	$(FETCHIT)[:-] \
	$(BUILDIT)[:-] \
	$(CHECKIT)[:] \
	$(SHELLIT)[:-] \
	all[:] \
	clean[:] \
	whoami[:] \
	settings[:] \
	setup[:] \
	subdirs[:] \
	print[:]

ifneq ($(COMPOSER_ESCAPES),)
$(foreach FILE,\
	$(shell $(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_PROGS_USE="$(COMPOSER_PROGS_USE)" .all_targets | $(SED) -n \
		$(foreach FILE,$(.ALL_TARGETS),\
			-e "/^$(FILE)/p" \
		) \
		| $(SED) "s|[:].*$$||g" \
	),\
	$(eval $(FILE): .set_title-$(FILE))\
)
.set_title-%:
	@if [ "$(*)" != "$(EXAMPLE)" ]; then \
		$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"; \
	fi
endif

########################################

.DEFAULT_GOAL := $(HELPOUT)
.DEFAULT:
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_1)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) ERROR:"
	@$(TABLE_C2) "$(_N)Target '$(_C)$(@)$(_N)' is not defined."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "You either need to define this target, or call a target which is already defined."
	@$(TABLE_C2) "Use '$(_M)$(TARGETS)$(_D)' to get a list of available targets for this '$(MAKEFILE)'."
	@$(TABLE_C2) "Or, review the output of '$(_M)$(HELPOUT)$(_D)' and/or '$(_M)$(HELPALL)$(_D)' for more information."
	@$(HEADER_1)
	@exit 1

########################################

.PHONY: $(HELPOUT)
$(HELPOUT): \
	HELP_HEADER \
	HELP_OPTIONS \
	HELP_TARGETS \
	HELP_COMMANDS \
	HELP_FOOTER

.PHONY: $(HELPALL)
$(HELPALL): \
	HELP_HEADER \
	HELP_OPTIONS \
	HELP_OPTIONS_SUB \
	HELP_TARGETS \
	HELP_TARGETS_SUB \
	HELP_COMMANDS \
	EXAMPLE_MAKEFILES \
	HELP_SYSTEM \
	EXAMPLE_MAKEFILE \
	HELP_FOOTER

.PHONY: HELP_HEADER
HELP_HEADER:
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(COMPOSER_FULLNAME)"
	@$(HEADER_1)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Usage:"
	@$(TABLE_I3) '$(_C)RUNMAKE$(_D) := $(_E)$(RUNMAKE)'
	@$(TABLE_I3) '$(_C)COMPOSE$(_D) := $(_E)$(COMPOSE)'
	@$(TABLE_I3) "$(_M)$(~)(RUNMAKE) [variables] <filename>.<extension>"
	@$(TABLE_I3) "$(_M)$(~)(COMPOSE) <variables>"
	@$(ECHO) "\n"

.PHONY: HELP_OPTIONS
HELP_OPTIONS:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Variables:"
	@$(TABLE_I3) "$(_C)TYPE$(_D)"	"Desired output format"		"[$(_M)$(TYPE)$(_D)]"
	@$(TABLE_I3) "$(_C)BASE$(_D)"	"Base of output file(s)"	"[$(_M)$(BASE)$(_D)]"
	@$(TABLE_I3) "$(_C)LIST$(_D)"	"List of input files(s)"	"[$(_M)$(LIST)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Optional Variables:"
	@$(TABLE_I3) "$(_C)CSS$(_D)"	"Location of CSS file"		"[$(_M)$(CSS)$(_D)] $(_N)(overrides '$(COMPOSER_CSS)')"
	@$(TABLE_I3) "$(_C)TTL$(_D)"	"Document title prefix"		"[$(_M)$(TTL)$(_D)]"
	@$(TABLE_I3) "$(_C)TOC$(_D)"	"Table of contents depth"	"[$(_M)$(TOC)$(_D)]"
	@$(TABLE_I3) "$(_C)LVL$(_D)"	"New slide header level"	"[$(_M)$(LVL)$(_D)]"
	@$(TABLE_I3) "$(_C)OPT$(_D)"	"Custom Pandoc options"		"[$(_M)$(OPT)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Pre-Defined '$(_C)TYPE$(_H)' Values:"
	@$(TABLE_I3) "$(_C)$(TYPE_HTML)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_HTML)$(_D)"	"$(HTML_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_LPDF)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_LPDF)$(_D)"	"$(LPDF_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_PRES)$(_D)"	"$(_N)*$(_D).$(_E)$(PRES_EXTN)$(_D)"	"$(PRES_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_SHOW)$(_D)"	"$(_N)*$(_D).$(_E)$(SHOW_EXTN)$(_D)"	"$(SHOW_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_DOCX)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_DOCX)$(_D)"	"$(DOCX_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_EPUB)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_EPUB)$(_D)"	"$(EPUB_DESC)"
	@$(TABLE_I3) "$(_M)Any other types specified will be passed directly through to Pandoc."
	@$(ECHO) "\n"

.PHONY: HELP_OPTIONS_SUB
HELP_OPTIONS_SUB:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "Following is the complete list of exposed/configurable variables:"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_GITREPO$(_D)"	"Source repository"		"[$(_M)$(COMPOSER_GITREPO)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_VERSION$(_D)"	"Version for cloning"		"[$(_M)$(COMPOSER_VERSION)$(_D)] $(_N)(valid: any Git tag or commit)"
	@$(TABLE_I3) "$(_C)COMPOSER_ESCAPES$(_D)"	"Enable color/title sequences"	"[$(_M)$(COMPOSER_ESCAPES)$(_D)] $(_N)(valid: empty or 1)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)File Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_STAMP$(_D)"		"Timestamp file"		"[$(_M)$(COMPOSER_STAMP)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_CSS$(_D)"		"Default CSS file"		"[$(_M)$(COMPOSER_CSS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_EXT$(_D)"		"Markdown file extension"	"[$(_M)$(COMPOSER_EXT)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_FILES$(_D)"		"List for '$(REPLICA)' target"	"[$(_M)$(COMPOSER_FILES)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Recursion Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_TARGETS$(_D)"	"Target list for 'all'"		"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_SUBDIRS$(_D)"	"Sub-directories list"		"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_DEPENDS$(_D)"	"Sub-directory dependency"	"[$(_M)$(COMPOSER_DEPENDS)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)COMPOSER_DEBUGIT$(_D)"	"Modifies '$(DEBUGIT)' target"	"[$(_M)$(COMPOSER_DEBUGIT)$(_D)] $(_N)(valid: any target)"
	@$(TABLE_I3) "$(_C)COMPOSER_TESTING$(_D)"	"Modifies '$(TESTING)' target"	"[$(_M)$(COMPOSER_TESTING)$(_D)] $(_N)(valid: empty, 0 or 1)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Location Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_OTHER$(_D)"		"Root of below directories"	"[$(_M)$(COMPOSER_OTHER)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_ABODE$(_D)"		"Install/binary directory"	"[$(_M)$(COMPOSER_ABODE)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_STORE$(_D)"		"Source files directory"	"[$(_M)$(COMPOSER_STORE)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_BUILD$(_D)"		"Build directory"		"[$(_M)$(COMPOSER_BUILD)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_PROGS$(_D)"		"Built binaries directory"	"[$(_M)$(COMPOSER_PROGS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_PROGS_USE$(_D)"	"Prefer repository binaries"	"[$(_M)$(COMPOSER_PROGS_USE)$(_D)] $(_N)(valid: empty, 0 or 1)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Build Options:"
	@$(TABLE_I3) "$(_C)BUILD_DIST$(_D)"		"Build generic binaries"	"[$(_M)$(BUILD_DIST)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)BUILD_MSYS$(_D)"		"Force Windows detection"	"[$(_M)$(BUILD_MSYS)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)BUILD_GHC_78$(_D)"		"GHC 7.8 instead of 7.6"	"[$(_M)$(BUILD_GHC_78)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)BUILD_PLAT$(_D)"		"Overrides 'uname -o'"		"[$(_M)$(BUILD_PLAT)$(_D)]"
	@$(TABLE_I3) "$(_C)BUILD_ARCH$(_D)"		"Overrides 'uname -m'"		"[$(_M)$(BUILD_ARCH)$(_D)] $(_E)($(BUILD_BITS)-bit)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Environment Options:"
	@$(TABLE_I3) "$(_C)LANG$(_D)"			"Locale default language"	"[$(_M)$(LANG)$(_D)] $(_N)(NOTE: use UTF-8)"
	@$(TABLE_I3) "$(_C)TERM$(_D)"			"Terminfo terminal type"	"[$(_M)$(TERM)$(_D)]"
	@$(TABLE_I3) "$(_C)CC$(_D)"			"C compiler"			"[$(_M)$(CC)$(_D)]"
#WORK : will need this to implement "chroot" composer
#	@$(TABLE_I3) "$(_C)LD_LIBRARY_PATH$(_D)"	"Linker library directories"	"[$(_M)$(LD_LIBRARY_PATH)$(_D)]"
	@$(TABLE_I3) "$(_C)PATH$(_D)"			"Run-time binary directories"	"[$(_M)$(BUILD_PATH)$(_D)]"
	@$(TABLE_I3) "$(_C)CURL_CA_BUNDLE$(_D)"		"SSL certificate bundle"	"[$(_M)$(CURL_CA_BUNDLE)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "All of these can be set on the command line or in the environment."
	@$(ECHO) "\n"
	@$(ESCAPE) "To set them permanently, add them to the settings file (you may have to create it):"
	@$(TABLE_I3) "$(_M)$(COMPOSER_INCLUDE)"
	@$(ECHO) "\n"
	@$(ESCAPE) "All of these change the fundamental operation of $(COMPOSER_BASENAME), and should be used with care."
	@$(ECHO) "\n"

.PHONY: HELP_TARGETS
HELP_TARGETS:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Primary Targets:"
	@$(TABLE_I3) "$(_C)$(HELPOUT)$(_D)"		"Basic help output"
	@$(TABLE_I3) "$(_C)$(HELPALL)$(_D)"		"Complete help output"
	@$(TABLE_I3) "$(_C)$(COMPOSER_TARGET)$(_D)"	"Main target used to build/format documents"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Helper Targets:"
	@$(TABLE_I3) "$(_C)all$(_D)"			"Create all of the default output formats or configured targets"
	@$(TABLE_I3) "$(_C)clean$(_D)"			"Remove all of the default output files or configured targets"
	@$(TABLE_I3) "$(_C)print$(_D)"			"List all source files newer than the '$(COMPOSER_STAMP)' timestamp file"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Diagnostic Targets:"
	@$(TABLE_I3) "$(_C)$(DEBUGIT)$(_D)"		"Runs several key sub-targets and commands, to provide all helpful information in one place"
	@$(TABLE_I3) "$(_C)$(TARGETS)$(_D)"		"Parse '$(MAKEFILE)' for all potential targets (for verification and/or troubleshooting)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Installation Targets:"
	@$(TABLE_I3) "$(_C)$(EXAMPLE)$(_D)"		"Print out example/template '$(MAKEFILE)' (helpful shortcut for creating recursive files)"
	@$(TABLE_I3) "$(_C)$(TESTING)$(_D)"		"Build example/test directory using all features and test/validate success"
	@$(TABLE_I3) "$(_C)$(INSTALL)$(_D)"		"Recursively create '$(MAKEFILE)' files (non-destructive build system initialization)"
	@$(TABLE_I3) "$(_C)$(REPLICA)$(_D)"		"Clone key components into current directory (for inclusion in content repositories)"
	@$(TABLE_I3) "$(_C)$(UPGRADE)$(_D)"		"Download/update all 3rd party components (need to do this at least once)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Compilation Targets:"
	@$(TABLE_I3) "$(_C)$(STRAPIT)$(_D)"		"Download and build/compile essential libraries and tools"
	@$(TABLE_I3) "$(_C)$(FETCHIT)$(_D)"		"Download/update and prepare all source repositories and archives"
	@$(TABLE_I3) "$(_C)$(BUILDIT)$(_D)"		"Build/compile specific versions of all tools necessary for $(COMPOSER_BASENAME) operation"
	@$(TABLE_I3) "$(_C)$(CHECKIT)$(_D)"		"Diagnostic version information (for verification and/or troubleshooting)"
	@$(TABLE_I3) "$(_C)$(SHELLIT)$(_D)"		"Launches into $(COMPOSER_BASENAME) sub-shell environment"
	@$(TABLE_I3) "$(_C)$(SHELLIT)-msys$(_D)"	"Launches MSYS2 shell (for Windows) into $(COMPOSER_BASENAME) sub-shell environment"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Wildcard Targets:"
	@$(TABLE_I3) "$(_C)$(REPLICA)-$(_N)%$(_D):"	"$(_E)$(REPLICA) COMPOSER_VERSION=$(_N)*$(_D)"	""
	@$(TABLE_I3) "$(_C)do-$(_N)%$(_D):"		"$(_E)fetch-$(_N)*$(_E) build-$(_N)*$(_D)"	""
	@$(ECHO) "\n"

.PHONY: HELP_TARGETS_SUB
HELP_TARGETS_SUB:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "These are all the rest of the sub-targets used by the main targets above:"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Dynamic Sub-Targets:"
	@$(TABLE_I3) "$(_C)all$(_D):"			"$(_E)$(~)(COMPOSER_TARGETS)$(_D)"		"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(TABLE_I3) "$(_C)clean$(_D):"			"$(_E)$(~)(COMPOSER_TARGETS)-clean$(_D)"	"[$(_M)$(addsuffix -clean,$(COMPOSER_TARGETS))$(_D)]"
	@$(TABLE_I3) "$(_C)subdirs$(_D):"		"$(_E)$(~)(COMPOSER_SUBDIRS)$(_D)"		"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Hidden Sub-Targets:"
	@$(TABLE_I3) "$(_C)$(_N)%$(_D):"		"$(_E).set_title-$(_N)*$(_D)"			"Set window title to current target using escape sequence"
	@$(TABLE_I3) "$(_C)$(DEBUGIT)$(_D):"		"$(_E).make_database$(_D)"			"Output internal Make database, based on current '$(MAKEFILE)'"
	@$(TABLE_I3) "$(_C)$(TARGETS)$(_D):"		"$(_E).all_targets$(_D)"			"Dynamically parse and print all potential targets"
	@$(TABLE_I3) "$(_C)$(EXAMPLE)$(_D):"		"$(_E).$(EXAMPLE)$(_D)"				"Prints raw template, with escape sequences"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Static Sub-Targets:"
	@$(TABLE_I3) "$(_C)$(COMPOSER_TARGET)$(_D):"	"$(_E)$(COMPOSER_PANDOC)$(_D)"			"Wrapper target which calls Pandoc directly"
	@$(TABLE_I3) "$(_E)$(COMPOSER_PANDOC)$(_D):"	"$(_E)settings$(_D)"				"Prints marker and variable values, for readability"
	@$(TABLE_I3) ""					"$(_E)setup$(_D)"				"Does essential configuration for correct building of documents"
	@$(TABLE_I3) "$(_C)all$(_D):"			"$(_E)whoami$(_D)"				"Prints marker and variable values, for readability"
	@$(TABLE_I3) ""					"$(_E)subdirs$(_D)"				"Aggregates/runs the 'COMPOSER_SUBDIRS' targets"
	@$(TABLE_I3) "$(_C)$(INSTALL)$(_D):"		"$(_E)$(INSTALL)-dir$(_D)"			"Per-directory engine which does all the work"
	@$(TABLE_I3) "$(_C)$(STRAPIT)$(_D):"		"$(_E)$(STRAPIT)-check$(_D)"			"Tries to proactively prevent common errors"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-config$(_D)"			"Fetches current Gnu.org configuration files/scripts"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-msys$(_D)"			"Installs MSYS2 environment with MinGW-w64 (for Windows)"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs$(_D)"			"Build/compile of necessary libraries from source archives"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util$(_D)"			"Build/compile of necessary utilities from source archives"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-curl$(_D)"			"Build/compile of cURL from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-git$(_D)"			"Build/compile of Git from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-ghc$(_D)"			"Build/complie of GHC from source archive"
	@$(TABLE_I3) "$(_E)$(STRAPIT)-msys$(_D):"	"$(_E)$(STRAPIT)-msys-bin$(_D)"			"Installs base MSYS2/MinGW-w64 system"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-msys-init$(_D)"		"Initializes base MSYS2/MinGW-w64 system"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-msys-fix$(_D)"			"Proactively fixes common MSYS2/MinGW-w64 issues"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-msys-pkg$(_D)"			"Installs/updates MSYS2/MinGW-w64 packages"
	@$(TABLE_I3) "$(_E)$(STRAPIT)-libs$(_D):"	"$(_E)$(STRAPIT)-libs-linux$(_D)"		"Build/compile of Linux kernel headers from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-glibc$(_D)"		"Build/compile of Glibc from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-zlib$(_D)"		"Build/compile of Zlib from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-gmp$(_D)"			"Build/compile of GMP from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-libiconv1$(_D)"		"Build/compile of Libiconv (before Gettext) from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-gettext$(_D)"		"Build/compile of Gettext from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-libiconv2$(_D)"		"Build/compile of Libiconv (after Gettext) from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-ncurses$(_D)"		"Build/compile of Ncurses from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-openssl$(_D)"		"Build/compile of OpenSSL from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-expat$(_D)"		"Build/compile of Expat from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-freetype$(_D)"		"Build/compile of FreeType from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-libs-fontconfig$(_D)"		"Build/compile of Fontconfig from source archive"
	@$(TABLE_I3) "$(_E)$(STRAPIT)-util$(_D):"	"$(_E)$(STRAPIT)-util-coreutils$(_D)"		"Build/compile of GNU Coreutils from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-findutils$(_D)"		"Build/compile of GNU Findutils from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-patch$(_D)"		"Build/compile of GNU Patch from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-sed$(_D)"			"Build/compile of GNU Sed from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-bzip$(_D)"		"Build/compile of Bzip2 from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-gzip$(_D)"		"Build/compile of Gzip from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-xz$(_D)"			"Build/compile of XZ Utils from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-tar$(_D)"			"Build/compile of GNU Tar from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-perl$(_D)"		"Build/compile of Perl from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-util-perl-modules$(_D)"	"Build/compile of Perl modules from source archives"
	@$(TABLE_I3) "$(_E)$(STRAPIT)-curl$(_D):"	"$(_E)$(STRAPIT)-curl-pull$(_D)"		"Download of cURL source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-curl-prep$(_D)"		"Preparation of cURL source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-curl-build$(_D)"		"Build/compile of cURL from source archive"
	@$(TABLE_I3) "$(_E)$(STRAPIT)-git$(_D):"	"$(_E)$(STRAPIT)-git-pull$(_D)"			"Download of Git source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-git-prep$(_D)"			"Preparation of Git source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-git-build$(_D)"		"Build/compile of Git from source archive"
	@$(TABLE_I3) "$(_E)$(STRAPIT)-ghc$(_D):"	"$(_E)$(STRAPIT)-ghc-pull$(_D)"			"Download of GHC source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-ghc-prep$(_D)"			"Preparation of GHC source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-ghc-build$(_D)"		"Build/compile of GHC from source archive"
	@$(TABLE_I3) ""					"$(_E)$(STRAPIT)-ghc-depends$(_D)"		"Build/compile of GHC prerequisites"
	@$(TABLE_I3) "$(_C)$(FETCHIT)$(_D):"		"$(_E)$(FETCHIT)-config$(_D)"			"Fetches current Gnu.org configuration files/scripts"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-cabal$(_D)"			"Updates Cabal database"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-bash$(_D)"			"Download/preparation of Bash source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-less$(_D)"			"Download/preparation of Less source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-vim$(_D)"			"Download/preparation of Vim source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-make$(_D)"			"Download/preparation of GNU Make source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-infozip$(_D)"			"Download/preparation of Info-ZIP source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-curl$(_D)"			"Download/preparation of cURL source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-git$(_D)"			"Download/preparation of Git source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-texlive$(_D)"			"Download/preparation of TeX Live source archives"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-ghc$(_D)"			"Download/preparation of GHC source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-haskell$(_D)"			"Download/preparation of Haskell Platform source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-pandoc$(_D)"			"Download/preparation of Pandoc source repositories"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-bash$(_D):"	"$(_E)$(FETCHIT)-bash-pull$(_D)"		"Download of Bash source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-bash-prep$(_D)"		"Preparation of Bash source archive"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-less$(_D):"	"$(_E)$(FETCHIT)-less-pull$(_D)"		"Download of Less source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-less-prep$(_D)"		"Preparation of Less source archive"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-vim$(_D):"	"$(_E)$(FETCHIT)-vim-pull$(_D)"			"Download of Vim source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-vim-prep$(_D)"			"Preparation of Vim source archive"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-make$(_D):"	"$(_E)$(FETCHIT)-make-pull$(_D)"		"Download of GNU Make source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-make-prep$(_D)"		"Preparation of GNU Make source repository"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-infozip$(_D):"	"$(_E)$(FETCHIT)-infozip-pull$(_D)"		"Download of Info-ZIP source archive"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-infozip-prep$(_D)"		"Preparation of Info-ZIP source archive"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-curl$(_D):"	"$(_E)$(FETCHIT)-curl-pull$(_D)"		"Download of cURL source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-curl-prep$(_D)"		"Preparation of cURL source repository"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-git$(_D):"	"$(_E)$(FETCHIT)-git-pull$(_D)"			"Download of Git source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-git-prep$(_D)"			"Preparation of Git source repository"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-texlive$(_D):"	"$(_E)$(FETCHIT)-texlive-pull$(_D)"		"Download of TeX Live source archives"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-texlive-prep$(_D)"		"Preparation of TeX Live source archives"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-ghc$(_D):"	"$(_E)$(FETCHIT)-ghc-pull$(_D)"			"Download of GHC source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-ghc-prep$(_D)"			"Preparation of GHC source repository"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-haskell$(_D):"	"$(_E)$(FETCHIT)-haskell-pull$(_D)"		"Download of Haskell Platform source repository"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-haskell-packages$(_D)"		"Download/preparation of Haskell Platform packages"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-haskell-prep$(_D)"		"Preparation of Haskell Platform source repository"
	@$(TABLE_I3) "$(_E)$(FETCHIT)-pandoc$(_D):"	"$(_E)$(FETCHIT)-pandoc-pull$(_D)"		"Download of Pandoc source repositories"
	@$(TABLE_I3) ""					"$(_E)$(FETCHIT)-pandoc-prep$(_D)"		"Preparation of Pandoc source repositories"
	@$(TABLE_I3) "$(_C)$(BUILDIT)$(_D):"		"$(_E)$(BUILDIT)-cleanup$(_D)"			"Archives/restores source files and removes temporary build files"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-bindir$(_D)"			"Copies compiled binaries to repository binaries directory"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-bash$(_D)"			"Build/compile of Bash from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-less$(_D)"			"Build/compile of Less from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-vim$(_D)"			"Build/compile of Vim from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-make$(_D)"			"Build/compile of GNU Make from source"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-infozip$(_D)"			"Build/compile of Info-ZIP from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-curl$(_D)"			"Build/compile of cURL from source"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-git$(_D)"			"Build/compile of Git from source"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-texlive$(_D)"			"Build/compile of TeX Live from source archives"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-ghc$(_D)"			"Build/compile of GHC from source"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-haskell$(_D)"			"Build/compile of Haskell Platform from source"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-pandoc$(_D)"			"Build/compile of Pandoc(-CiteProc) from source"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-texlive$(_D):"	"$(_E)$(BUILDIT)-texlive-fmtutil$(_D)"		"Build/install TeX Live format files"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-pandoc$(_D):"	"$(_E)$(BUILDIT)-pandoc-deps$(_D)"		"Build/compile of Pandoc dependencies from source"
	@$(TABLE_I3) "$(_C)$(SHELLIT)[-msys]$(_D):"	"$(_E)$(SHELLIT)-bashrc$(_D)"			"Initializes Bash configuration file"
	@$(TABLE_I3) ""					"$(_E)$(SHELLIT)-vimrc$(_D)"			"Initializes Vim configuration file"
	@$(ECHO) "\n"
	@$(ESCAPE) "These do not need to be used directly during normal use, and are only documented for completeness."
	@$(ECHO) "\n"

.PHONY: HELP_COMMANDS
HELP_COMMANDS:
	@$(HEADER_1)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Command Examples:"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Have the system do all the work:"
	@$(ESCAPE) "$(_M)$(~)(RUNMAKE) $(BASE).$(EXTENSION)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Be clear about what is wanted (or, for multiple or differently named input files):"
	@$(ESCAPE) "$(_M)$(~)(COMPOSE) LIST=\"$(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILES
EXAMPLE_MAKEFILES: \
	EXAMPLE_MAKEFILES_HEADER \
	EXAMPLE_MAKEFILE_1 \
	EXAMPLE_MAKEFILE_2 \
	EXAMPLE_MAKEFILES_FOOTER

.PHONY: EXAMPLE_MAKEFILES_HEADER
EXAMPLE_MAKEFILES_HEADER:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Calling from children '$(MAKEFILE)' files:"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE_1
EXAMPLE_MAKEFILE_1:
	@$(TABLE_C2) "$(_E)Simple, with filename targets and \"automagic\" detection of them:"
	@$(TABLE_C2) "$(_S)include $(COMPOSER)"
	@$(ESCAPE) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TARGET)"
	@$(ESCAPE) "$(_C)$(BASE)$(_D): $(_N)# so \"clean\" will catch the below files"
	@$(ESCAPE) "$(_C)$(EXAMPLE_TARGET)$(_D): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@$(ESCAPE) "$(_C)$(EXAMPLE_SECOND).$(EXTENSION)$(_D):"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE_2
EXAMPLE_MAKEFILE_2:
	@$(TABLE_C2) "$(_E)Advanced, with manual enumeration of user-defined targets and per-target variables:"
	@$(ESCAPE) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE) $(EXAMPLE_TARGET) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(TABLE_C2) "$(_S)include $(COMPOSER)"
	@$(ESCAPE) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TARGET)"
	@$(ESCAPE) "$(_C)$(BASE)$(_D): export TOC := 1"
	@$(ESCAPE) "$(_C)$(BASE)$(_D): $(BASE).$(EXTENSION)"
	@$(ESCAPE) "$(_C)$(EXAMPLE_TARGET)$(_D): $(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)"
	@$(ESCAPE) "	$(~)(COMPOSE) LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@$(ESCAPE) "	$(~)(COMPOSE) LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_LPDF)\""
	@$(ESCAPE) "$(_C)$(EXAMPLE_TARGET)-clean$(_D):"
	@$(ESCAPE) "	$(~)(RM) $(EXAMPLE_OUTPUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@$(ECHO) "#WORK : document this version of 'clean'?\n"
	@$(ECHO) "#WORK : make .release-test .release-debug\n"
	@$(ESCAPE) "$(_C)clean$(_D): COMPOSER_TARGETS += $(notdir $(.RELEASE_MAN_DST))"
	@$(ESCAPE) "$(_C)clean$(_D): TYPE := latex"
	@$(ESCAPE) "$(_C)$(notdir $(.RELEASE_MAN_DST)):"
	@$(ESCAPE) "	$(~)(CP) \"$(COMPOSER_DIR)/$(notdir $(.RELEASE_MAN_DST)).\"* ./"
	@$(ECHO) "#WORK\n"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILES_FOOTER
EXAMPLE_MAKEFILES_FOOTER:
	@$(TABLE_C2) "$(_E)Then, from the command line:"
	@$(ESCAPE) "$(_M)make clean && make all"
	@$(ECHO) "\n"

.PHONY: HELP_SYSTEM
HELP_SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
HELP_SYSTEM:
	@$(HEADER_1)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Completely recursive build system:"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)The top-level '$(MAKEFILE)' is the only one which needs a direct reference:"
	@$(TABLE_C2) "$(_N)(NOTE: This must be an absolute path.)"
	@$(ESCAPE) "include $(COMPOSER)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)All sub-directories then each start with:"
	@$(ESCAPE) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(ESCAPE) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?="
	@$(ESCAPE) "$(_C).DEFAULT_GOAL$(_D) := $(_C)all"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)And end with:"
	@$(ESCAPE) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Back in the top-level '$(MAKEFILE)', and in all sub-'$(MAKEFILE)' instances which recurse further down:"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(ESCAPE) "include [...]"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Create a new '$(MAKEFILE)' using a helpful template:"
	@$(ESCAPE) "$(_M)$(~)(RUNMAKE) COMPOSER_TARGETS=\"$(BASE).$(EXTENSION)\" $(EXAMPLE) >$(MAKEFILE)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Or, recursively initialize the current directory tree:"
	@$(TABLE_C2) "$(_N)(NOTE: This is a non-destructive operation.)"
	@$(ESCAPE) "$(_M)$(~)(RUNMAKE) $(INSTALL)"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE
EXAMPLE_MAKEFILE: \
	EXAMPLE_MAKEFILE_HEADER \
	EXAMPLE_MAKEFILE_FULL \
	EXAMPLE_MAKEFILE_TEMPLATE

.PHONY: EXAMPLE_MAKEFILE_HEADER
EXAMPLE_MAKEFILE_HEADER:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Finally, a completely recursive '$(MAKEFILE)' example:"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE_FULL
EXAMPLE_MAKEFILE_FULL: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
EXAMPLE_MAKEFILE_FULL:
	@$(TABLE_C2) "$(_H)$(MARKER) HEADERS"
	@$(TABLE_C2) "$(_E)These two statements must be at the top of every file:"
	@$(TABLE_C2) "$(_N)(NOTE: The 'COMPOSER_TEACHER' variable can be modified for custom chaining, but with care.)"
	@$(ESCAPE) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(ESCAPE) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) DEFINITIONS"
	@$(TABLE_C2) "$(_E)These statements are also required:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Use '?=' declarations and define *before* the upstream 'include' statement"
	@$(TABLE_C2) "$(_E)$(INDENTING)* They pass their values *up* the '$(MAKEFILE)' chain"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Should always be defined, even if empty, to prevent downward propagation of values"
	@$(TABLE_C2) "$(_N)(NOTE: List of 'all' targets is '$(COMPOSER_ALL_REGEX)' if '$(~)(COMPOSER_TARGETS)' is empty.)"
	@$(ESCAPE) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE).$(EXTENSION) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(ESCAPE) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) VARIABLES"
	@$(TABLE_C2) "$(_E)The option variables are not required, but are available for locally-scoped configuration:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* For proper inheritance, use '?=' declarations and define *before* the upstream 'include' statement"
	@$(TABLE_C2) "$(_E)$(INDENTING)* They pass their values *down* the '$(MAKEFILE)' chain"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Do not need to be defined when empty, unless necessary to override upstream values"
	@$(TABLE_C2) "$(_E)To disable inheritance and/or insulate from environment variables:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Replace 'override VAR ?=' with 'override VAR :='"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Define *after* the upstream 'include' statement"
	@$(TABLE_C2) "$(_N)(NOTE: Any settings here will apply to all children, unless 'override' is used downstream.)"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)Define the CSS template to use in this entire directory tree:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Absolute path names should be used, so that children will be able to find it"
	@$(TABLE_C2) "$(_E)$(INDENTING)$(INDENTING)* The 'COMPOSER_ABSPATH' variable can be used to simplify this"
	@$(TABLE_C2) "$(_E)$(INDENTING)* If not defined, the lowest-level '$(COMPOSER_CSS)' file will be used"
	@$(TABLE_C2) "$(_E)$(INDENTING)* If not defined, and no '$(COMPOSER_CSS)' file can be found, will use default CSS file"
	@$(ESCAPE) "$(~)(eval override $(_C)CSS$(_D) ?= $(_C)$(~)(COMPOSER_ABSPATH)/$(COMPOSER_CSS)$(_D))"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)All the other optional variables can also be made global in this directory scope:"
	@$(ESCAPE) "override $(_C)TTL$(_D) ?="
	@$(ESCAPE) "override $(_C)TOC$(_D) ?= $(_C)2"
	@$(ESCAPE) "override $(_C)LVL$(_D) ?= $(_C)$(LVL)"
	@$(ESCAPE) "override $(_C)OPT$(_D) ?="
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) INCLUDE"
	@$(TABLE_C2) "$(_E)Necessary include statement:"
	@$(TABLE_C2) "$(_N)(NOTE: This must be after all references to 'COMPOSER_ABSPATH' but before '.DEFAULT_GOAL'.)"
	@$(ESCAPE) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)For recursion to work, a default target needs to be defined:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Needs to be 'all' for directories which must recurse into sub-directories"
	@$(TABLE_C2) "$(_E)$(INDENTING)* The 'subdirs' target can be used manually, if desired, so this can be changed to another value"
	@$(TABLE_C2) "$(_N)(NOTE: Recursion will cease if not 'all', unless 'subdirs' target is called.)"
	@$(ESCAPE) "$(_C).DEFAULT_GOAL$(_D) := $(_C)all"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) RECURSION"
	@$(TABLE_C2) "$(_E)Dependencies can be specified, if needed:"
	@$(TABLE_C2) "$(_N)(NOTE: This defines the sub-directories which must be built before '$(firstword $(COMPOSER_SUBDIRS))'.)"
	@$(TABLE_C2) "$(_N)(NOTE: For parent/child directory dependencies, set 'COMPOSER_DEPENDS' to a non-empty value.)"
	@$(ESCAPE) "$(_C)$(firstword $(COMPOSER_SUBDIRS))$(_D): $(_C)$(wordlist 2,$(words $(COMPOSER_SUBDIRS)),$(COMPOSER_SUBDIRS))"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) MAKEFILE"
	@$(TABLE_C2) "$(_E)This is where the rest of the file should be defined."
	@$(TABLE_C2) "$(_N)(NOTE: In this example, 'COMPOSER_TARGETS' is used completely in lieu of any explicit targets.)"
	@$(ECHO) "\n"

.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(TABLE_C2) "$(_H)$(MARKER) HEADERS"
	@$(ESCAPE) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(ESCAPE) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) DEFINITIONS"
	@$(ESCAPE) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(COMPOSER_TARGETS)"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(ESCAPE) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) VARIABLES"
	@$(TABLE_C2) "$(_E)$(~)(eval override CSS ?= $(~)(COMPOSER_ABSPATH)/$(COMPOSER_CSS))"
	@$(TABLE_C2) "$(_E)override TTL ?="
	@$(TABLE_C2) "$(_E)override TOC ?="
	@$(TABLE_C2) "$(_E)override LVL ?="
	@$(TABLE_C2) "$(_E)override OPT ?="
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) INCLUDE"
	@$(ESCAPE) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(ESCAPE) "$(_C).DEFAULT_GOAL$(_D) := $(_C)all"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) MAKEFILE"
	@$(TABLE_C2) "$(_N)(Contents of file go here.)"

.PHONY: EXAMPLE_MAKEFILE_TEMPLATE
EXAMPLE_MAKEFILE_TEMPLATE:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)With the current settings, the output of '$(EXAMPLE)' would be:"
	@$(ECHO) "\n"
	@$(RUNMAKE) --silent .$(EXAMPLE)
	@$(ECHO) "\n"

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)Happy Hacking!"
	@$(HEADER_1)

########################################

.PHONY: $(DEBUGIT)
$(DEBUGIT):
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_DEBUGIT$(_D)"	"[$(_M)$(COMPOSER_DEBUGIT)$(_D)]"
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) DEBUG:"
	@$(TABLE_C2) "$(_N)This is the output of the '$(_C)debug$(_N)' target."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "This target runs several key sub-targets and diagnostic commands."
	@$(TABLE_C2) "The goal is to provide all needed troubleshooting information in one place."
	@$(TABLE_C2) "Set the '$(_M)COMPOSER_DEBUGIT$(_D)' variable to troubleshoot a particular list of targets $(_E)(they may be run)$(_D)."
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,HELP_HEADER HELP_OPTIONS HELP_OPTIONS_SUB)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H) Diagnostics"
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,$(CHECKIT))
	@$(ECHO) "\n"
	@$(HEADER_2)
	@$(call DEBUGIT_TARGET,$(TARGETS))
	@$(ECHO) "\n"
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H) Targets Debug"
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,--debug --just-print $(COMPOSER_DEBUGIT))
	@$(ECHO) "\n"
	@$(foreach FILE,$(MAKEFILE_LIST),\
		$(call DEBUGIT_CONTENTS,$(FILE)); \
		$(ECHO) "\n"; \
	)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H) Make Database Dump"
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,.make_database)
	@$(call DEBUGIT_LISTING,NULL,DIR)
	@$(call DEBUGIT_LISTING,DIR,OTHER)
	@$(call DEBUGIT_LISTING,OTHER,ABODE)
	@$(call DEBUGIT_LISTING,OTHER,STORE)
	@$(call DEBUGIT_LISTING,OTHER,BUILD)
	@$(call DEBUGIT_LISTING,OTHER,PROGS)
	@$(RUNMAKE) --silent HELP_FOOTER

override define DEBUGIT_TARGET =
	$(ECHO) "\n"; \
	$(RUNMAKE) --silent $(1)
endef

override define DEBUGIT_LISTING =
	if [ "$(COMPOSER_$(2))" == "$(subst $(COMPOSER_$(1)),,$(COMPOSER_$(2)))" ]; then \
		$(HEADER_1); \
		$(TABLE_C2) "$(_H) Directory Listing: COMPOSER_$(2)"; \
		$(HEADER_1); \
		$(ECHO) "\n"; \
		$(LS) -R "$(COMPOSER_$(2))"; \
		$(ECHO) "\n"; \
	fi
endef

override define DEBUGIT_CONTENTS =
	$(HEADER_L); \
	$(TABLE_I3) "$(_H)$(MARKER) $(_M)$(1)"; \
	$(HEADER_L); \
	$(CAT) "$(1)"
endef

.PHONY: $(TARGETS)
$(TARGETS):
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_H)Targets$(_D) $(DIVIDE) $(_M)$(COMPOSER_SRC)"
	@$(HEADER_L)
	@$(ECHO) "$(_C)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .all_targets | $(SED) \
		$(foreach FILE,$(.ALL_TARGETS),\
			-e "/^$(FILE)/d" \
		) \
		-e "/^[^:]*[.]$(COMPOSER_EXT)[:]/d" \
		-e "/^$$/d"
	@$(HEADER_L)
	@$(TABLE_I3) "$(_H)$(MARKER) all";	$(ECHO) "$(COMPOSER_TARGETS)"				| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(TABLE_I3) "$(_H)$(MARKER) clean";	$(ECHO) "$(addsuffix -clean,$(COMPOSER_TARGETS))"	| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(TABLE_I3) "$(_H)$(MARKER) subdirs";	$(ECHO) "$(COMPOSER_SUBDIRS)"				| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(HEADER_L)

########################################

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .$(EXAMPLE)

override TEST_DIRECTORIES	:= \
	$(TESTING_DIR) \
	$(TESTING_DIR)/subdir1 \
	$(TESTING_DIR)/subdir1/example1 \
	$(TESTING_DIR)/subdir2 \
	$(TESTING_DIR)/subdir2/example2
override TEST_DIR_CSSDST	:= $(word 4,$(TEST_DIRECTORIES))
override TEST_DIR_DEPEND	:= $(word 2,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_1	:= $(word 3,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_2	:= $(word 5,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_F	:= $(word 1,$(TEST_DIRECTORIES))
override TEST_DEPEND_SUB	:= example1
override TEST_FULLMK_SUB	:= subdir1 subdir2

.PHONY: $(TESTING)
$(TESTING):
	@$(foreach FILE,$(TEST_DIRECTORIES),\
		$(MKDIR) "$(FILE)"; \
		$(CP) \
			"$(COMPOSER_DIR)/"*.$(COMPOSER_EXT) \
			"$(COMPOSER_DIR)/"*.$(COMPOSER_IMG) \
			"$(FILE)/"; \
	)
	@$(CP) "$(MDVIEWER_CSS)" "$(TEST_DIR_CSSDST)/$(COMPOSER_CSS)"
	@$(RUNMAKE) --directory "$(TESTING_DIR)" $(INSTALL)
ifneq ($(COMPOSER_TESTING),0)
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_SUBDIRS="$(TEST_DEPEND_SUB)" COMPOSER_DEPENDS="1" $(EXAMPLE) >"$(TEST_DIR_DEPEND)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= EXAMPLE_MAKEFILE_1 >"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= EXAMPLE_MAKEFILE_2 >"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_TARGETS= COMPOSER_SUBDIRS= $(EXAMPLE) >>"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_TARGETS= COMPOSER_SUBDIRS= $(EXAMPLE) >>"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_SUBDIRS="$(TEST_FULLMK_SUB)" EXAMPLE_MAKEFILE_FULL >"$(TEST_DIR_MAKE_F)/$(MAKEFILE)"
endif
	@$(MKDIR) "$(TESTING_DIR)/$(COMPOSER_BASENAME)"
	@$(RUNMAKE) --directory "$(TESTING_DIR)/$(COMPOSER_BASENAME)" $(REPLICA)
ifeq ($(COMPOSER_TESTING),2)
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1\$$(COMPOSER_ABSPATH)/$(COMPOSER_BASENAME)/$(MAKEFILE)|g" "$(TESTING_DIR)/$(MAKEFILE)"
endif
	@$(MAKE) --directory "$(TESTING_DIR)"
ifneq ($(COMPOSER_TESTING),)
	@$(foreach FILE,$(TEST_DIRECTORIES),\
		$(ECHO) "\n"; \
		$(call DEBUGIT_CONTENTS,$(FILE)/$(MAKEFILE)); \
	)
endif

.PHONY: $(INSTALL)
$(INSTALL): $(INSTALL)-dir
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1$(COMPOSER)|g" "$(CURDIR)/$(MAKEFILE)"

.PHONY: $(INSTALL)-dir
$(INSTALL)-dir:
	@if [ -f "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(TABLE_I3) "$(_H)$(MARKER) $(_N)Skipping$(_D) $(DIVIDE) $(_E)$(CURDIR)/$(MAKEFILE)"; \
	else \
		$(TABLE_I3) "$(_H)$(MARKER) $(_H)Creating$(_D) $(DIVIDE) $(_M)$(CURDIR)/$(MAKEFILE)"; \
		$(RUNMAKE) --silent \
			COMPOSER_ESCAPES= \
			COMPOSER_TARGETS="$(sort $(subst .$(COMPOSER_EXT),.$(TYPE_HTML),$(wildcard *.$(COMPOSER_EXT))))" \
			COMPOSER_SUBDIRS="$(sort $(subst /,,$(wildcard */)))" \
			COMPOSER_DEPENDS="$(COMPOSER_DEPENDS)" \
			$(EXAMPLE) >"$(CURDIR)/$(MAKEFILE)"; \
	fi
	@$(foreach FILE,$(sort $(subst /,,$(wildcard */))),\
		$(RUNMAKE) --silent --directory "$(CURDIR)/$(FILE)" $(INSTALL)-dir; \
	)

$(REPLICA)-%:
	@$(RUNMAKE) --silent --directory "$(CURDIR)" \
		COMPOSER_VERSION="$(*)" \
		$(REPLICA)

.PHONY: $(REPLICA)
$(REPLICA):
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_VERSION$(_D)"	"[$(_M)$(COMPOSER_VERSION)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_FILES$(_D)"		"[$(_M)$(COMPOSER_FILES)$(_D)]"
	@$(HEADER_1)
	@if [ ! -d "$(REPLICA_GIT_DIR)" ]; then \
		$(MKDIR) "$(abspath $(dir $(REPLICA_GIT_DIR)))"; \
		$(REPLICA_GIT) init --bare; \
		$(REPLICA_GIT) remote add origin "$(COMPOSER_GITREPO)"; \
	fi
	@$(REPLICA_GIT) remote remove origin
	@$(REPLICA_GIT) remote add origin "$(COMPOSER_GITREPO)"
	@$(REPLICA_GIT) fetch --all
	@$(ECHO) "$(_C)"
	@$(REPLICA_GIT) archive \
		--format="tar" \
		--prefix= \
		"$(COMPOSER_VERSION)" \
		$(foreach FILE,$(COMPOSER_FILES),"$(FILE)") \
		| \
		$(TAR) -C "$(CURDIR)" -f -
	@$(ECHO) "$(_E)"
	@if [ -f "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" ] && \
	    [ "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" != "$(CURDIR)/$(COMPOSER_SETTINGS)" ]; then \
		$(CP) "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" "$(CURDIR)/$(COMPOSER_SETTINGS)"; \
	fi
	@$(TOUCH) "$(CURDIR)/.$(COMPOSER_BASENAME).$(REPLICA)"
	@$(ECHO) "$(_D)"

.PHONY: $(UPGRADE)
$(UPGRADE):
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_1)
	@$(call GIT_REPO,$(MDVIEWER_DST),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
	@$(ECHO) "$(_C)"
	@cd "$(MDVIEWER_DST)" && \
		$(CHMOD) ./build.sh && \
		$(BUILD_ENV) $(SH) ./build.sh
	@$(ECHO) "$(_D)"
	@$(call GIT_REPO,$(REVEALJS_DST),$(REVEALJS_SRC),$(REVEALJS_CMT))
	@$(call CURL_FILE,$(W3CSLIDY_SRC))
	@$(ECHO) "$(_E)"
	@$(call DO_UNZIP,$(W3CSLIDY_DST),$(W3CSLIDY_SRC))
	@$(ECHO) "$(_D)"

########################################

.PHONY: $(STRAPIT)
$(STRAPIT): $(STRAPIT)-check
ifeq ($(BUILD_PLAT),Msys)
$(STRAPIT): $(STRAPIT)-msys
endif
$(STRAPIT): $(STRAPIT)-config
$(STRAPIT): $(STRAPIT)-libs
$(STRAPIT): $(STRAPIT)-util
$(STRAPIT):
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(STRAPIT)-curl
	$(RUNMAKE) $(STRAPIT)-git
	$(RUNMAKE) $(STRAPIT)-ghc

.PHONY: $(FETCHIT)
$(FETCHIT): $(FETCHIT)-cabal
$(FETCHIT): $(BUILDIT)-cleanup
$(FETCHIT): $(FETCHIT)-config
$(FETCHIT): $(FETCHIT)-bash $(FETCHIT)-less $(FETCHIT)-vim
$(FETCHIT): $(FETCHIT)-make $(FETCHIT)-infozip $(FETCHIT)-curl $(FETCHIT)-git
$(FETCHIT): $(FETCHIT)-texlive
$(FETCHIT): $(FETCHIT)-ghc $(FETCHIT)-haskell $(FETCHIT)-pandoc

.PHONY: $(BUILDIT)
$(BUILDIT): $(BUILDIT)-bash $(BUILDIT)-less $(BUILDIT)-vim
$(BUILDIT): $(BUILDIT)-make $(BUILDIT)-infozip $(BUILDIT)-curl $(BUILDIT)-git
$(BUILDIT): $(BUILDIT)-texlive
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-ghc
	$(RUNMAKE) $(BUILDIT)-haskell
	$(RUNMAKE) $(BUILDIT)-pandoc
	$(RUNMAKE) $(BUILDIT)-cleanup
	$(RUNMAKE) $(BUILDIT)-bindir
	$(RUNMAKE) $(CHECKIT)

do-%: $(FETCHIT)-% $(BUILDIT)-%
	@$(ECHO) >/dev/null

.PHONY: $(STRAPIT)-config
$(STRAPIT)-config:
	$(call CURL_FILE_GNU_CFG,$(GNU_CFG_FILE_GUS))
	$(call CURL_FILE_GNU_CFG,$(GNU_CFG_FILE_SUB))

.PHONY: $(FETCHIT)-config
$(FETCHIT)-config:
	$(call GIT_REPO,$(GNU_CFG_DST),$(GNU_CFG_SRC),$(GNU_CFG_CMT))

override define GNU_CFG_INSTALL =
	$(CP) "$(GNU_CFG_DST)/$(GNU_CFG_FILE_GUS)" "$(1)/"
	$(CP) "$(GNU_CFG_DST)/$(GNU_CFG_FILE_SUB)" "$(1)/"
endef

.PHONY: $(FETCHIT)-cabal
$(FETCHIT)-cabal:
#WORKING : need to make this work for "msys"
	$(RM) "$(COMPOSER_ABODE)/.cabal/config"
	$(BUILD_ENV) $(CABAL) update
#WORKING : need to do this for all ghc builds, namely cabal
	# make sure GHC looks for libraries in the right place
	$(SED) -i \
		-e "s|(gcc[-]options[:]).*$$|\1 $(CFLAGS)|g" \
		-e "s|(ghc[-]options[:]).*$$|\1 -optc-I$(COMPOSER_ABODE)/include -optc-L$(COMPOSER_ABODE)/lib -optl-L$(COMPOSER_ABODE)/lib|g" \
		"$(COMPOSER_ABODE)/.cabal/config"

.PHONY: $(BUILDIT)-cleanup
$(BUILDIT)-cleanup:
	$(MKDIR) "$(COMPOSER_ABODE)/.cabal"
	$(MKDIR) "$(COMPOSER_STORE)/.cabal"
ifeq ($(BUILD_PLAT),Msys)
	$(MKDIR) "$(APPDATA)/cabal"
	$(CP) "$(APPDATA)/cabal/"* "$(COMPOSER_STORE)/.cabal/" || $(TRUE)
	$(CP) "$(COMPOSER_STORE)/.cabal/"* "$(APPDATA)/cabal/" || $(TRUE)
endif
	$(CP) "$(COMPOSER_ABODE)/.cabal/"* "$(COMPOSER_STORE)/.cabal/" || $(TRUE)
	$(CP) "$(COMPOSER_STORE)/.cabal/"* "$(COMPOSER_ABODE)/.cabal/" || $(TRUE)
ifeq ($(BUILD_PLAT),Msys)
	$(RM) "$(COMPOSER_ABODE)/"*.exe
endif

.PHONY: $(BUILDIT)-bindir
$(BUILDIT)-bindir:
	$(MKDIR) "$(COMPOSER_PROGS)/usr/bin"
ifeq ($(BUILD_PLAT),Msys)
	$(call DO_HEREDOC,HEREDOC_MSYS_SHELL) >"$(COMPOSER_PROGS)/msys2_shell.bat"
	$(CHMOD) "$(COMPOSER_PROGS)/msys2_shell.bat"
	$(MKDIR) "$(COMPOSER_PROGS)/etc"
	$(CP) "$(MSYS_BIN_DST)/etc/"{bash.bashrc,fstab} "$(COMPOSER_PROGS)/etc/"
#WORK : probably need this for linux, too
	$(MKDIR) "$(COMPOSER_PROGS)/usr/share"
	$(CP) "$(MSYS_BIN_DST)/usr/share/"{locale,terminfo} "$(COMPOSER_PROGS)/usr/share/"
#WORK
	$(foreach FILE,$(MSYS_BINARY_LIST),\
		$(CP) "$(MSYS_BIN_DST)/usr/bin/$(FILE)" "$(COMPOSER_PROGS)/usr/bin/"; \
	)
	$(CP) "$(COMPOSER_ABODE)/bin/"*.dll "$(COMPOSER_PROGS)/usr/bin/"
endif
	$(foreach FILE,$(BUILD_BINARY_LIST),\
		$(CP) "$(COMPOSER_ABODE)/bin/$(FILE)" "$(COMPOSER_PROGS)/usr/bin/"; \
	)
	$(CP) "$(COMPOSER_ABODE)/ca-bundle.crt" "$(COMPOSER_PROGS)/"
	$(CP) "$(COMPOSER_ABODE)/libexec/git-core" "$(COMPOSER_PROGS)/"
	$(foreach FILE,$(TEXLIVE_DIRECTORY_LIST),\
		$(MKDIR) "$(COMPOSER_PROGS)/texmf-dist/$(FILE)"; \
		$(CP) "$(COMPOSER_ABODE)/texmf-dist/$(FILE)/"* "$(COMPOSER_PROGS)/texmf-dist/$(FILE)/"; \
	)
	$(MKDIR)							"$(COMPOSER_PROGS)/texmf-dist/web2c"
	$(CP) "$(COMPOSER_ABODE)/texmf-dist/web2c/texmf.cnf"		"$(COMPOSER_PROGS)/texmf-dist/web2c/"
	$(CP) "$(COMPOSER_ABODE)/texmf-dist/ls-R"			"$(COMPOSER_PROGS)/texmf-dist/"
	$(MKDIR)							"$(COMPOSER_PROGS)/texmf-var/web2c/pdftex"
	$(CP) "$(COMPOSER_ABODE)/texmf-var/web2c/pdftex/pdflatex.fmt"	"$(COMPOSER_PROGS)/texmf-var/web2c/pdftex/"
	$(MKDIR) "$(COMPOSER_PROGS)/pandoc"
ifeq ($(BUILD_PLAT),Linux)
	$(CP) "$(COMPOSER_ABODE)/share/"*"-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/"* "$(COMPOSER_PROGS)/pandoc/"
else ifeq ($(BUILD_PLAT),Msys)
	$(CP) "$(COMPOSER_ABODE)/"*"-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/"* "$(COMPOSER_PROGS)/pandoc/"
else
	$(CP) "$(COMPOSER_ABODE)/share/"*"-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/"* "$(COMPOSER_PROGS)/pandoc/"
endif
#WORK
	$(RM) \
		"$(COMPOSER_PROGS)/usr/bin/"perl \
		"$(COMPOSER_PROGS)/usr/bin/"ghc \
		"$(COMPOSER_PROGS)/usr/bin/"ghc-pkg \
		"$(COMPOSER_PROGS)/usr/bin/"cabal

override define HEREDOC_MSYS_SHELL =
@echo off
if not defined MSYSTEM set MSYSTEM=MSYS$(BUILD_BITS)
if not defined MSYSCON set MSYSCON=mintty.exe
set WD=%~dp0
set BINDIR=/usr/bin
set PATH=%WD%%BINDIR%;%PATH%
set OPTIONS=
set OPTIONS=%OPTIONS% --title "$(MARKER) $(COMPOSER_FULLNAME) $(DIVIDE) MSYS2 Shell"
set OPTIONS=%OPTIONS% --exec %BINDIR%/bash
start /b %WD%%BINDIR%/%MSYSCON% %OPTIONS%
:: end of file
endef

# this list should be mirrored from "$(MSYS_BINARY_LIST)" and "$(BUILD_BINARY_LIST)"
# for some reason, "$(BZIP)" hangs with the "--version" argument, so we'll use "--help" instead
# "$(BZIP)" and "$(LESS)" use those environment variables as additional arguments, so they need to be empty
.PHONY: $(CHECKIT)
$(CHECKIT): override PANDOC_VERSIONS := $(PANDOC_CMT) $(_D)($(_E)$(PANDOC_VERSION)$(_D))
$(CHECKIT):
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_H)Project"			"$(COMPOSER_BASENAME) Version"	"Current Version(s)"
	@$(HEADER_L)
ifeq ($(BUILD_PLAT),Msys)
	@$(TABLE_I3) "$(MARKER) $(_E)MSYS2"		"$(_E)$(MSYS_VERSION)"		"$(_N)$(shell $(PACMAN) --version			2>/dev/null | $(SED) -n "s|^.*(Pacman[ ].*)$$|\1|gp")"
	@$(TABLE_I3) "- $(_E)MinTTY"			"$(_E)*"			"$(_N)$(shell $(MINTTY) --version			2>/dev/null | $(HEAD) -n1)"
endif
	@$(TABLE_I3) "$(MARKER) $(_E)GNU Coreutils"	"$(_E)$(COREUTILS_VERSION)"	"$(_N)$(shell $(LS) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Findutils"		"$(_E)$(FINDUTILS_VERSION)"	"$(_N)$(shell $(FIND) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Patch"			"$(_E)$(PATCH_VERSION)"		"$(_N)$(shell $(PATCH) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Sed"			"$(_E)$(SED_VERSION)"		"$(_N)$(shell $(SED) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Bzip2"			"$(_E)$(BZIP_VERSION)"		"$(_N)$(shell BZIP= $(BZIP) --help			2>&1        | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Gzip"			"$(_E)$(GZIP_VERSION)"		"$(_N)$(shell $(GZIP) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)XZ Utils"			"$(_E)$(XZ_VERSION)"		"$(_N)$(shell $(XZ) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Tar"			"$(_E)$(TAR_VERSION)"		"$(_N)$(shell $(TAR) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Perl"			"$(_E)$(PERL_VERSION)"		"$(_N)$(shell $(PERL) --version				2>/dev/null | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_I3) "$(_C)GNU Bash"			"$(_M)$(BASH_VERSION)"		"$(_D)$(shell $(BASH) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Less"			"$(_M)$(LESS_VERSION)"		"$(_D)$(shell LESS= $(LESS) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Vim"			"$(_M)$(VIM_VERSION)"		"$(_D)$(shell $(VIM) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)GNU Make"			"$(_M)$(MAKE_CMT)"		"$(_D)$(shell $(MAKE) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Info-ZIP (Zip)"		"$(_M)$(IZIP_VERSION)"		"$(_D)$(shell $(ZIP) --version				2>/dev/null | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_I3) "- $(_C)Info-ZIP (UnZip)"		"$(_M)$(UZIP_VERSION)"		"$(_D)$(shell $(UNZIP) --version			2>&1        | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_I3) "- $(_C)cURL"			"$(_M)$(CURL_VERSION)"		"$(_D)$(shell $(CURL) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Git SCM"			"$(_M)$(GIT_VERSION)"		"$(_D)$(shell $(GIT) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)Pandoc"			"$(_M)$(PANDOC_VERSIONS)"	"$(_D)$(shell $(PANDOC) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Types"			"$(_M)$(PANDOC_TYPE_CMT)"	"$(_D)$(shell $(CABAL) info pandoc-types		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)TeXMath"			"$(_M)$(PANDOC_MATH_CMT)"	"$(_D)$(shell $(CABAL) info texmath			2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)Highlighting-Kate"		"$(_M)$(PANDOC_HIGH_CMT)"	"$(_D)$(shell $(CABAL) info highlighting-kate		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)CiteProc"			"$(_M)$(PANDOC_CITE_CMT)"	"$(_D)$(shell $(PANDOC_CITEPROC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)TeX Live"			"$(_M)$(TEX_VERSION)"		"$(_D)$(shell $(TEX) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)PDFLaTeX"			"$(_M)$(TEX_PDF_VERSION)"	"$(_D)$(shell $(PDFLATEX) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)Haskell"			"$(_M)$(HASKELL_CMT)"		"$(_D)$(shell $(CABAL) info haskell-platform		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)GHC"			"$(_M)$(GHC_VERSION)"		"$(_D)$(shell $(GHC) --version				2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Cabal"			"$(_M)$(CABAL_VERSION)"		"$(_D)$(shell $(CABAL) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Library"			"$(_M)$(CABAL_VERSION_LIB)"	"$(_D)$(shell $(CABAL) info Cabal			2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "$(MARKER)"			"$(_E)GHC Library$(_D):"	"$(_M)$(GHC_VERSION_LIB)"
	@$(HEADER_L)
ifeq ($(BUILD_PLAT),Msys)
	@$(TABLE_I3) "$(MARKER) $(_E)MSYS2"		"$(_N)$(subst \",,$(word 1,$(PACMAN)))"
	@$(TABLE_I3) "- $(_E)MinTTY"			"$(_N)$(subst \",,$(word 1,$(MINTTY))) $(_S)($(subst \",,$(word 1,$(CYGWIN_CONSOLE_ESCAPE))))"
endif
	@$(TABLE_I3) "$(MARKER) $(_E)GNU Coreutils"	"$(_N)$(subst \",,$(word 1,$(COREUTILS)))"
	@$(TABLE_I3) "- $(_E)GNU Find"			"$(_N)$(subst \",,$(word 1,$(FIND)))"
	@$(TABLE_I3) "- $(_E)GNU Patch"			"$(_N)$(subst \",,$(word 1,$(PATCH)))"
	@$(TABLE_I3) "- $(_E)GNU Sed"			"$(_N)$(subst \",,$(word 1,$(SED)))"
	@$(TABLE_I3) "- $(_E)Bzip2"			"$(_N)$(subst \",,$(word 1,$(BZIP)))"
	@$(TABLE_I3) "- $(_E)Gzip"			"$(_N)$(subst \",,$(word 1,$(GZIP)))"
	@$(TABLE_I3) "- $(_E)XZ Utils"			"$(_N)$(subst \",,$(word 1,$(XZ)))"
	@$(TABLE_I3) "- $(_E)GNU Tar"			"$(_N)$(subst \",,$(word 1,$(TAR)))"
	@$(TABLE_I3) "- $(_E)Perl"			"$(_N)$(subst \",,$(word 1,$(PERL)))"
	@$(TABLE_I3) "$(_C)GNU Bash"			"$(_D)$(subst \",,$(word 1,$(BASH))) $(_S)($(subst \",,$(word 1,$(SH))))"
	@$(TABLE_I3) "- $(_C)Less"			"$(_D)$(subst \",,$(word 1,$(LESS)))"
	@$(TABLE_I3) "- $(_C)Vim"			"$(_D)$(subst \",,$(word 1,$(VIM)))"
	@$(TABLE_I3) "$(_C)GNU Make"			"$(_D)$(subst \",,$(word 1,$(MAKE)))"
	@$(TABLE_I3) "- $(_C)Info-ZIP (Zip)"		"$(_D)$(subst \",,$(word 1,$(ZIP)))"
	@$(TABLE_I3) "- $(_C)Info-ZIP (UnZip)"		"$(_D)$(subst \",,$(word 1,$(UNZIP)))"
	@$(TABLE_I3) "- $(_C)cURL"			"$(_D)$(subst \",,$(word 1,$(CURL)))"
	@$(TABLE_I3) "- $(_C)Git SCM"			"$(_D)$(subst \",,$(word 1,$(GIT)))"
	@$(TABLE_I3) "$(_C)Pandoc"			"$(_D)$(subst \",,$(word 1,$(PANDOC)))"
	@$(TABLE_I3) "- $(_C)Types"			"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)TeXMath"			"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)Highlighting-Kate"		"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)CiteProc"			"$(_D)$(subst \",,$(word 1,$(PANDOC_CITEPROC)))"
	@$(TABLE_I3) "$(_C)TeX Live"			"$(_D)$(subst \",,$(word 1,$(TEX)))"
	@$(TABLE_I3) "- $(_C)PDFLaTeX"			"$(_D)$(subst \",,$(word 1,$(PDFLATEX)))"
	@$(TABLE_I3) "$(_C)Haskell"			"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)GHC"			"$(_D)$(subst \",,$(word 1,$(GHC))) $(_S)($(subst \",,$(word 1,$(GHC_PKG))))"
	@$(TABLE_I3) "- $(_C)Cabal"			"$(_D)$(subst \",,$(word 1,$(CABAL)))"
	@$(TABLE_I3) "- $(_C)Library"			"$(_E)(no binary to report)"
	@$(HEADER_L)
	@$(LDD) \
		$(word 1,$(MINTTY)) $(word 1,$(CYGWIN_CONSOLE_ESCAPE)) \
		$(word 1,$(COREUTILS)) \
		$(word 1,$(FIND)) \
		$(word 1,$(PATCH)) \
		$(word 1,$(SED)) \
		$(word 1,$(BZIP)) \
		$(word 1,$(GZIP)) \
		$(word 1,$(XZ)) \
		$(word 1,$(TAR)) \
		$(word 1,$(PERL)) \
		$(word 1,$(BASH)) $(word 1,$(SH)) \
		$(word 1,$(LESS)) \
		$(word 1,$(VIM)) \
		$(word 1,$(MAKE)) \
		$(word 1,$(ZIP)) \
		$(word 1,$(UNZIP)) \
		$(word 1,$(CURL)) \
		$(word 1,$(GIT)) \
		$(word 1,$(PANDOC)) \
		$(word 1,$(PANDOC_CITEPROC)) \
		$(word 1,$(TEX)) \
		$(word 1,$(PDFLATEX)) \
		$(word 1,$(GHC)) $(word 1,$(GHC_PKG)) \
		$(word 1,$(CABAL)) \
		2>/dev/null \
		| $(SED) -e "/^[:/]/d" -e "s|[(][^)]+[)]||g" \
		| $(SORT)
	@$(HEADER_L)

.PHONY: $(SHELLIT)
$(SHELLIT): $(SHELLIT)-bashrc $(SHELLIT)-vimrc
$(SHELLIT):
	@$(BUILD_ENV) $(BASH) || $(TRUE)

.PHONY: $(SHELLIT)-msys
$(SHELLIT)-msys: $(SHELLIT)-bashrc $(SHELLIT)-vimrc
$(SHELLIT)-msys: export MSYS2_ARG_CONV_EXCL := /grant:r
$(SHELLIT)-msys:
ifeq ($(COMPOSER_PROGS_USE),1)
	@cd "$(COMPOSER_PROGS)" && \
		$(WINDOWS_ACL) ./msys2_shell.bat /grant:r $(USERNAME):f && \
		$(BUILD_ENV) ./msys2_shell.bat
else
	@cd "$(MSYS_BIN_DST)" && \
		$(WINDOWS_ACL) ./msys2_shell.bat /grant:r $(USERNAME):f && \
		$(BUILD_ENV) ./msys2_shell.bat
endif

.PHONY: $(SHELLIT)-bashrc
$(SHELLIT)-bashrc:
	@$(MKDIR) "$(COMPOSER_ABODE)"
	@$(call DO_HEREDOC,HEREDOC_BASH_PROFILE)	>"$(COMPOSER_ABODE)/.bash_profile"
	@$(call DO_HEREDOC,HEREDOC_BASHRC)		>"$(COMPOSER_ABODE)/.bashrc"
	@if [ ! -f "$(COMPOSER_ABODE)/.bashrc.custom" ]; then \
		$(ECHO) >"$(COMPOSER_ABODE)/.bashrc.custom"; \
	fi

.PHONY: $(SHELLIT)-vimrc
$(SHELLIT)-vimrc:
	@$(MKDIR) "$(COMPOSER_ABODE)"
	@$(call DO_HEREDOC,HEREDOC_VIMRC)		>"$(COMPOSER_ABODE)/.vimrc"
	@if [ ! -f "$(COMPOSER_ABODE)/.vimrc.custom" ]; then \
		$(ECHO) >"$(COMPOSER_ABODE)/.vimrc.custom"; \
	fi

override define HEREDOC_BASH_PROFILE =
source "$(COMPOSER_ABODE)/.bashrc"
endef

override define HEREDOC_BASHRC =
#!$(subst ",,$(ENV)) bash
umask 022
unalias -a
set -o vi
eval $$($(DIRCOLORS) 2>/dev/null)
#
export LANG="$(LANG)"
export LC_ALL="$${LANG}"
export LC_COLLATE="C"
export LC_ALL=
#
if [ -f "$(COMPOSER_ABODE)/.bash_history" ]; then $(RM) "$(COMPOSER_ABODE)/.bash_history"; fi
$(MKDIR) "$(COMPOSER_ABODE)/.bash_history"
export HISTFILE="$(COMPOSER_ABODE)/.bash_history/$$(date +%Y-%m)"
export HISTSIZE="$$(( (2**31)-1 ))"
export HISTFILESIZE="$${HISTSIZE}"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S "
export HISTCONTROL=
export HISTIGNORE=
#
export CDPATH=".:$(COMPOSER_DIR):$(COMPOSER_OTHER):$(COMPOSER_ABODE):$(COMPOSER_STORE):$(COMPOSER_BUILD)"
#
export PROMPT_DIRTRIM="1"
export PS1=
export PS1="$${PS1}$([)\e]0;$(MARKER) $(COMPOSER_FULLNAME) $(DIVIDE) \w\a$(])\n"					# title escape, new line (for spacing)
export PS1="$${PS1}$([)$(_H)$(])$(MARKER) $(COMPOSER_FULLNAME)$([)$(_D)$(]) $(DIVIDE) $([)$(_C)$(])\D{%FT%T%z}\n"	# title, date (iso format)
export PS1="$${PS1}$([)$(_C)$(])[\#/\!] ($([)$(_M)$(])\u@\h \w$([)$(_C)$(]))\\$$ $([)$(_D)$(])"				# history counters, username@hostname, directory, prompt
#
export PAGER="$(subst ",[B]",$(LESS))"
export EDITOR="$(subst ",[B]",$(VIM))"
unset VISUAL
#
alias ll="$(subst ",[B]",$(LS))"
alias less="$${PAGER}"
alias more="$${PAGER}"
alias vi="$${EDITOR}"
#
alias .composer_root="cd [B]"$(COMPOSER_DIR)[B]""
alias .composer_other="cd [B]"$(COMPOSER_OTHER)[B]""
alias .composer="$(subst ",[B]",$(RUNMAKE))"
alias .compose="$(subst ",[B]",$(COMPOSE))"
#
cd "$(COMPOSER_DIR)"
source "$(COMPOSER_ABODE)/.bashrc.custom"
# end of file
endef

override define HEREDOC_VIMRC =
" vimrc
"TODO
set nocompatible
set autoread
set secure
set ttyfast
"
set viminfo		=
set swapfile
set directory		=.
"
filetype on
syntax on
"
set noautowrite
set noautowriteall
set hidden
set hlsearch
set ignorecase
set incsearch
set modeline
set noruler
set showcmd
set noshowmode
set smartcase
set nospell
set novisualbell
"
set autoindent
set noexpandtab
set smartindent
set shiftwidth		=8
set tabstop		=8
"
set foldenable
set foldcolumn		=1
set foldlevelstart	=99
set foldminlines	=0
set foldmethod		=indent
"
" clean up folding
map z. <ESC>:set foldlevel=0<CR>zv
"
source $(COMPOSER_ABODE)/.vimrc.custom
" end of file
endef

override define AUTOTOOLS_BUILD =
	cd "$(1)" && \
		$(BUILD_ENV) $(3) FORCE_UNSAFE_CONFIGURE="1" $(SH) ./configure --host="$(CHOST)" --target="$(CHOST)" --prefix="$(2)" $(4) && \
		$(BUILD_ENV) $(3) $(MAKE) $(5) && \
		$(BUILD_ENV) $(3) $(MAKE) install
endef
override define AUTOTOOLS_BUILD_MINGW =
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(3) FORCE_UNSAFE_CONFIGURE="1" $(SH) ./configure --host="$(CHOST)" --target="$(CHOST)" --prefix="$(2)" $(4) && \
		$(BUILD_ENV_MINGW) $(3) $(MAKE) $(5) && \
		$(BUILD_ENV_MINGW) $(3) $(MAKE) install
endef
override AUTOTOOLS_BUILD_NOTARGET	= $(patsubst --host="%",,$(patsubst --target="%",,$(AUTOTOOLS_BUILD)))
override AUTOTOOLS_BUILD_NOTARGET_MINGW	= $(patsubst --host="%",,$(patsubst --target="%",,$(AUTOTOOLS_BUILD_MINGW)))

override CHECK_FAILED		:=
override CHECK_GHCLIB		:=
override CHECK_MSYS		:=

ifneq ($(BUILD_GHC_78),)
override CHECK_GHCLIB_NAME	:= Curses
override CHECK_GHCLIB_SRC	:= lib{,n}curses.so
override CHECK_GHCLIB_DST	:= libtinfo.so.5
else
override CHECK_GHCLIB_NAME	:= GMP
override CHECK_GHCLIB_SRC	:= libgmp.so
override CHECK_GHCLIB_DST	:= libgmp.so.3
endif

ifeq ($(BUILD_PLAT),Linux)
ifeq ($(shell $(LS) /{,usr/}lib*/$(CHECK_GHCLIB_DST) 2>/dev/null),)
override CHECK_FAILED		:= 1
override CHECK_GHCLIB		:= 1
endif
endif
ifeq ($(BUILD_PLAT),Msys)
ifeq ($(MSYSTEM),)
override CHECK_FAILED		:= 1
override CHECK_MSYS		:= 1
endif
endif

.PHONY: $(STRAPIT)-check
$(STRAPIT)-check:
ifneq ($(CHECK_GHCLIB),)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) ERROR:"
	@$(TABLE_C2) "$(_N)Could not find '$(_C)$(CHECK_GHCLIB_DST)$(_N)' library file."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "The pre-built GHC requires this specific file in order to run, but not necessarily this version of $(CHECK_GHCLIB_NAME)."
	@$(TABLE_C2) "You can likely '$(_M)ln -s$(_D)' one of the files below to something like '$(_M)/usr/lib/$(CHECK_GHCLIB_DST)$(_D)' to work around this."
	@$(ECHO) "\n"
	@$(LS) /{,usr/}lib*/$(CHECK_GHCLIB_SRC)* 2>/dev/null || $(TRUE)
	@$(ECHO) "\n"
	@$(TABLE_C2) "If no files are listed above, you may need to install some version of the $(CHECK_GHCLIB_NAME) library to continue."
	@$(HEADER_1)
endif
ifneq ($(CHECK_MSYS),)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) ERROR:"
	@$(TABLE_C2) "$(_N)Must use MSYS2 on Windows systems."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "This appears to be a Windows system, but the '$(_C)MSYSTEM$(_D)' variable is not set."
	@$(TABLE_C2) "You should run the '$(_M)$(STRAPIT)-msys$(_D)' target to install the MSYS2 environment."
	@$(TABLE_C2) "Then you can run the '$(_M)$(SHELLIT)-msys$(_D)' target to run the MSYS2 environment and try '$(_C)$(STRAPIT)$(_D)' again."
	@$(HEADER_1)
endif
ifneq ($(CHECK_FAILED),)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) NOTES:"
	@$(TABLE_C2) "This message was produced by $(_H)$(COMPOSER_FULLNAME)$(_D)."
	@$(TABLE_C2) "If you know the above to be incorrect, you can remove the check from the '$(_C)$(~)(STRAPIT)-check$(_D)' target in:"
	@$(TABLE_C2) "$(INDENTING)$(_M)$(COMPOSER)"
	@$(HEADER_1)
	@exit 1
endif

.PHONY: $(STRAPIT)-msys
$(STRAPIT)-msys: $(STRAPIT)-msys-bin
$(STRAPIT)-msys: $(STRAPIT)-msys-init
$(STRAPIT)-msys: $(STRAPIT)-msys-fix
$(STRAPIT)-msys: $(STRAPIT)-msys-pkg

.PHONY: $(STRAPIT)-msys-bin
$(STRAPIT)-msys-bin:
	$(call CURL_FILE,$(MSYS_BIN_SRC))
	$(call DO_UNTAR,$(MSYS_BIN_DST),$(MSYS_BIN_SRC))

.PHONY: $(STRAPIT)-msys-init
$(STRAPIT)-msys-init:
	@$(HEADER_1)
	@$(TABLE_C2) "We need to initialize the MSYS2 environment."
	@$(TABLE_C2) "To do this, we will pause here to open an initial shell window."
	@$(TABLE_C2) "Once the shell window gets to a command prompt, simply type '$(_M)exit$(_D)' and hit $(_M)ENTER$(_D) to return."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_N)Hit $(_C)ENTER$(_N) to proceed."
	@$(HEADER_1)
	@read -s -n1 ENTER
	@$(RUNMAKE) --silent $(SHELLIT)-msys
	@$(HEADER_1)
	@$(TABLE_C2) "The shell window has been launched."
	@$(TABLE_C2) "It should have processed to a command prompt, after which you typed '$(_M)exit$(_D)' and hit $(_M)ENTER$(_D)."
	@$(TABLE_C2) "If everything was successful $(_E)(no errors above)$(_D), the build process can continue without interaction."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_N)Hit $(_C)ENTER$(_N) to proceed, or $(_C)CTRL-C$(_N) to quit."
	@$(HEADER_1)
	@read -s -n1 ENTER

.PHONY: $(STRAPIT)-msys-fix
# thanks for the 'pacman-key' fix below: http://sourceforge.net/p/msys2/tickets/85/#2e02
$(STRAPIT)-msys-fix:
	$(PACMAN_ENV) $(PACMAN) --refresh
	$(PACMAN_ENV) $(PACMAN) --needed $(PACMAN_BASE_LIST)
	cd "$(MSYS_BIN_DST)" && \
		$(WINDOWS_ACL) ./autorebase.bat /grant:r $(USERNAME):f && \
		./autorebase.bat
	$(PACMAN_ENV) $(PACMAN_DB_UPGRADE)
	$(PACMAN_ENV) $(PACMAN_KEY) --init		|| $(TRUE)
	$(PACMAN_ENV) $(PACMAN_KEY) --populate msys2	|| $(TRUE)
	$(PACMAN_ENV) $(PACMAN_KEY) --refresh-keys	|| $(TRUE)

.PHONY: $(STRAPIT)-msys-pkg
$(STRAPIT)-msys-pkg:
	$(PACMAN_ENV) $(PACMAN) \
		--force \
		--needed \
		--sysupgrade \
		$(PACMAN_PACKAGES_LIST)
	$(PACMAN_ENV) $(PACMAN) --clean

#WORK : causes build errors
#make[2]: Entering directory `/.composer.build/build/bootstrap/libiconv-1.14/srclib'
#make[3]: Entering directory `/.composer.build/build/bootstrap/libiconv-1.14'
#make[3]: Nothing to be done for `am--refresh'.
#make[3]: Leaving directory `/.composer.build/build/bootstrap/libiconv-1.14'
#cc -DHAVE_CONFIG_H -DEXEEXT=\"\" -I. -I.. -I../lib  -I../intl -DDEPENDS_ON_LIBICONV=1 -DDEPENDS_ON_LIBINTL=1   -L/.composer.build/.home/lib -I/.composer.build/.home/include -m32 -march=i686 -mtune=generic -c allocator.c
#cc -DHAVE_CONFIG_H -DEXEEXT=\"\" -I. -I.. -I../lib  -I../intl -DDEPENDS_ON_LIBICONV=1 -DDEPENDS_ON_LIBINTL=1   -L/.composer.build/.home/lib -I/.composer.build/.home/include -m32 -march=i686 -mtune=generic -c areadlink.c
#cc -DHAVE_CONFIG_H -DEXEEXT=\"\" -I. -I.. -I../lib  -I../intl -DDEPENDS_ON_LIBICONV=1 -DDEPENDS_ON_LIBINTL=1   -L/.composer.build/.home/lib -I/.composer.build/.home/include -m32 -march=i686 -mtune=generic -c careadlinkat.c
#cc -DHAVE_CONFIG_H -DEXEEXT=\"\" -I. -I.. -I../lib  -I../intl -DDEPENDS_ON_LIBICONV=1 -DDEPENDS_ON_LIBINTL=1   -L/.composer.build/.home/lib -I/.composer.build/.home/include -m32 -march=i686 -mtune=generic -c malloca.c
#cc -DHAVE_CONFIG_H -DEXEEXT=\"\" -I. -I.. -I../lib  -I../intl -DDEPENDS_ON_LIBICONV=1 -DDEPENDS_ON_LIBINTL=1   -L/.composer.build/.home/lib -I/.composer.build/.home/include -m32 -march=i686 -mtune=generic -c progname.c
#In file included from progname.c:26:0:
#./stdio.h:1010:1: error: ‘gets’ undeclared here (not in a function)
# _GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");
#  ^
#  make[2]: *** [progname.o] Error 1
#  make[2]: Leaving directory `/.composer.build/build/bootstrap/libiconv-1.14/srclib'
#  make[1]: *** [all] Error 2
#  make[1]: Leaving directory `/.composer.build/build/bootstrap/libiconv-1.14/srclib'
#  make: *** [all] Error 2
#  make: *** [bootstrap-libs-libiconv1] Error 2
#WORK

.PHONY: $(STRAPIT)-libs
$(STRAPIT)-libs:
	# call recursively instead of using dependencies, so that environment variables update
#WORK
#ifeq ($(BUILD_PLAT),Linux)
#	$(RUNMAKE) $(STRAPIT)-libs-linux
#	$(RUNMAKE) $(STRAPIT)-libs-glibc
#endif
	$(RUNMAKE) $(STRAPIT)-libs-zlib
	$(RUNMAKE) $(STRAPIT)-libs-gmp
	$(RUNMAKE) $(STRAPIT)-libs-libiconv1
	$(RUNMAKE) $(STRAPIT)-libs-gettext
	$(RUNMAKE) $(STRAPIT)-libs-libiconv2
	$(RUNMAKE) $(STRAPIT)-libs-ncurses
	$(RUNMAKE) $(STRAPIT)-libs-openssl
	$(RUNMAKE) $(STRAPIT)-libs-expat
	# need the "bzip" headers/library for "freetype"
	$(RUNMAKE) $(STRAPIT)-util-bzip
	$(RUNMAKE) $(STRAPIT)-libs-freetype
	$(RUNMAKE) $(STRAPIT)-libs-fontconfig

.PHONY: $(STRAPIT)-libs-linux
$(STRAPIT)-libs-linux:
	$(call CURL_FILE,$(LINUX_TAR_SRC))
	$(call DO_UNTAR,$(LINUX_TAR_DST),$(LINUX_TAR_SRC))
	cd "$(LINUX_TAR_DST)" && \
		$(BUILD_ENV) $(MAKE) mrproper && \
		$(BUILD_ENV) $(MAKE) INSTALL_HDR_PATH="$(COMPOSER_ABODE)" headers_install

.PHONY: $(STRAPIT)-libs-glibc
$(STRAPIT)-libs-glibc:
	$(call CURL_FILE,$(GLIBC_TAR_SRC))
	$(call DO_UNTAR,$(GLIBC_TAR_DST),$(GLIBC_TAR_SRC))
	$(MKDIR) "$(GLIBC_TAR_DST).build"
	$(ECHO) "\"$(GLIBC_TAR_DST)/configure\" \"\$${@}\"" >"$(GLIBC_TAR_DST).build/configure"
	$(CHMOD) "$(GLIBC_TAR_DST).build/configure"
	$(call AUTOTOOLS_BUILD,$(GLIBC_TAR_DST).build,$(COMPOSER_ABODE),\
		CFLAGS="$(CFLAGS) -O2" \
	)

.PHONY: $(STRAPIT)-libs-zlib
$(STRAPIT)-libs-zlib:
	$(call CURL_FILE,$(ZLIB_TAR_SRC))
	$(call DO_UNTAR,$(ZLIB_TAR_DST),$(ZLIB_TAR_SRC))
ifeq ($(BUILD_BITS),64)
	$(call AUTOTOOLS_BUILD_NOTARGET,$(ZLIB_TAR_DST),$(COMPOSER_ABODE),,\
		--64 \
		--static \
	)
else
	$(call AUTOTOOLS_BUILD_NOTARGET,$(ZLIB_TAR_DST),$(COMPOSER_ABODE),,\
		--static \
	)
endif

.PHONY: $(STRAPIT)-libs-gmp
$(STRAPIT)-libs-gmp:
	$(call CURL_FILE,$(GMP_TAR_SRC))
	$(call DO_UNTAR,$(GMP_TAR_DST),$(GMP_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(GMP_TAR_DST),$(COMPOSER_ABODE),\
		ABI="$(BUILD_BITS)" \
		,\
		--disable-assembly \
		--disable-shared \
		--enable-static \
	)

override define LIBICONV_BUILD =
	$(call CURL_FILE,$(LIBICONV_TAR_SRC))
	# start with fresh source directory, due to circular dependency with "gettext"
	$(RM) -r "$(LIBICONV_TAR_DST)"
	$(call DO_UNTAR,$(LIBICONV_TAR_DST),$(LIBICONV_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(LIBICONV_TAR_DST)/build-aux)
	$(call GNU_CFG_INSTALL,$(LIBICONV_TAR_DST)/libcharset/build-aux)
	$(call AUTOTOOLS_BUILD,$(LIBICONV_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
endef

.PHONY: $(STRAPIT)-libs-libiconv1
$(STRAPIT)-libs-libiconv1:
	$(call LIBICONV_BUILD)

.PHONY: $(STRAPIT)-libs-gettext
$(STRAPIT)-libs-gettext:
	$(call CURL_FILE,$(GETTEXT_TAR_SRC))
	$(call DO_UNTAR,$(GETTEXT_TAR_DST),$(GETTEXT_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(GETTEXT_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-libs-libiconv2
$(STRAPIT)-libs-libiconv2:
	$(call LIBICONV_BUILD)

.PHONY: $(STRAPIT)-libs-ncurses
$(STRAPIT)-libs-ncurses:
	$(call CURL_FILE,$(NCURSES_TAR_SRC))
	$(call DO_UNTAR,$(NCURSES_TAR_DST),$(NCURSES_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(NCURSES_TAR_DST))
	$(call AUTOTOOLS_BUILD,$(NCURSES_TAR_DST),$(COMPOSER_ABODE),,\
		--without-shared \
	)

.PHONY: $(STRAPIT)-libs-openssl
# thanks for the 'static' fix below: http://www.openwall.com/lists/musl/2014/11/06/17
$(STRAPIT)-libs-openssl:
	$(call CURL_FILE,$(OPENSSL_TAR_SRC))
	$(call DO_UNTAR,$(OPENSSL_TAR_DST),$(OPENSSL_TAR_SRC))
ifeq ($(BUILD_PLAT),Linux)
ifneq ($(BUILD_DIST),)
	$(CP) "$(OPENSSL_TAR_DST)/Configure" "$(OPENSSL_TAR_DST)/configure"
else
	$(CP) "$(OPENSSL_TAR_DST)/config" "$(OPENSSL_TAR_DST)/configure"
endif
else ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" is case-insensitive, so 'Configure' is already 'configure'
else
	$(CP) "$(OPENSSL_TAR_DST)/config" "$(OPENSSL_TAR_DST)/configure"
endif
	$(SED) -i \
		-e "s|(TERMIO)([^S])|\1S\2|g" \
		-e "s|(termio)([^s])|\1s\2|g" \
		"$(OPENSSL_TAR_DST)/configure" \
		"$(OPENSSL_TAR_DST)/crypto/ui/ui_openssl.c"
ifeq ($(BUILD_PLAT),Linux)
ifneq ($(BUILD_DIST),)
	$(call AUTOTOOLS_BUILD_NOTARGET,$(OPENSSL_TAR_DST),$(COMPOSER_ABODE),,\
		linux-generic$(BUILD_BITS) \
		no-shared \
		no-dso \
	)
else
	$(call AUTOTOOLS_BUILD_NOTARGET,$(OPENSSL_TAR_DST),$(COMPOSER_ABODE),,\
		no-shared \
		no-dso \
	)
endif
else ifeq ($(BUILD_PLAT),Msys)
	$(call AUTOTOOLS_BUILD_NOTARGET,$(OPENSSL_TAR_DST),$(COMPOSER_ABODE),,\
		linux-generic$(BUILD_BITS) \
		no-shared \
		no-dso \
	)
else
	$(call AUTOTOOLS_BUILD_NOTARGET,$(OPENSSL_TAR_DST),$(COMPOSER_ABODE),,\
		no-shared \
		no-dso \
	)
endif

.PHONY: $(STRAPIT)-libs-expat
$(STRAPIT)-libs-expat:
	$(call CURL_FILE,$(EXPAT_TAR_SRC))
	$(call DO_UNTAR,$(EXPAT_TAR_DST),$(EXPAT_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(EXPAT_TAR_DST)/conftools)
	$(call AUTOTOOLS_BUILD,$(EXPAT_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-libs-freetype
$(STRAPIT)-libs-freetype:
	$(call CURL_FILE,$(FREETYPE_TAR_SRC))
	$(call DO_UNTAR,$(FREETYPE_TAR_DST),$(FREETYPE_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(FREETYPE_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-libs-fontconfig
$(STRAPIT)-libs-fontconfig:
	$(call CURL_FILE,$(FONTCONFIG_TAR_SRC))
	$(call DO_UNTAR,$(FONTCONFIG_TAR_DST),$(FONTCONFIG_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "expat" options in order to find it
	$(call AUTOTOOLS_BUILD,$(FONTCONFIG_TAR_DST),$(COMPOSER_ABODE),\
		FREETYPE_CFLAGS="$(CFLAGS) -I$(COMPOSER_ABODE)/include/freetype2" \
		FREETYPE_LIBS="$(shell "$(COMPOSER_ABODE)/bin/freetype-config" --libs) -lm" \
		,\
		--disable-docs \
		--enable-iconv \
		--with-libiconv-includes="$(COMPOSER_ABODE)/include" \
		--with-libiconv-lib="$(COMPOSER_ABODE)/lib" \
		--with-expat-includes="$(COMPOSER_ABODE)/include" \
		--with-expat-lib="$(COMPOSER_ABODE)/lib" \
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-util
$(STRAPIT)-util:
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(STRAPIT)-util-coreutils
	$(RUNMAKE) $(STRAPIT)-util-findutils
	$(RUNMAKE) $(STRAPIT)-util-patch
	$(RUNMAKE) $(STRAPIT)-util-sed
	$(RUNMAKE) $(STRAPIT)-util-bzip
	$(RUNMAKE) $(STRAPIT)-util-gzip
	$(RUNMAKE) $(STRAPIT)-util-xz
	$(RUNMAKE) $(STRAPIT)-util-tar
	$(RUNMAKE) $(STRAPIT)-util-perl
	$(RUNMAKE) $(STRAPIT)-util-perl-modules

.PHONY: $(STRAPIT)-util-coreutils
$(STRAPIT)-util-coreutils:
	$(call CURL_FILE,$(COREUTILS_TAR_SRC))
	$(call DO_UNTAR,$(COREUTILS_TAR_DST),$(COREUTILS_TAR_SRC))
	# "$(BUILD_PLAT),Msys" can't build "*.so" files, so disabling "stdbuf" which requires "libstdbuf.so"
	$(SED) -i \
		-e "s|(stdbuf[_]supported[=])yes|\1no|g" \
		"$(COREUTILS_TAR_DST)/configure"
	$(call AUTOTOOLS_BUILD,$(COREUTILS_TAR_DST),$(COMPOSER_ABODE),,\
		--enable-single-binary="shebangs" \
		--disable-acl \
		--disable-xattr \
	)
#WORK : does not work for msys
ifeq ($(BUILD_PLAT),Msys)
	$(call COREUTILS_UNINSTALL,$(COMPOSER_ABODE)/bin/coreutils,$(COMPOSER_ABODE)/bin)
endif

.PHONY: $(STRAPIT)-util-findutils
$(STRAPIT)-util-findutils:
	$(call CURL_FILE,$(FINDUTILS_TAR_SRC))
	$(call DO_UNTAR,$(FINDUTILS_TAR_DST),$(FINDUTILS_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(FINDUTILS_TAR_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(FINDUTILS_TAR_DST),$(COMPOSER_ABODE))

.PHONY: $(STRAPIT)-util-patch
$(STRAPIT)-util-patch:
	$(call CURL_FILE,$(PATCH_TAR_SRC))
	$(call DO_UNTAR,$(PATCH_TAR_DST),$(PATCH_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(PATCH_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-xattr \
	)

.PHONY: $(STRAPIT)-util-sed
$(STRAPIT)-util-sed:
	$(call CURL_FILE,$(SED_TAR_SRC))
	$(call DO_UNTAR,$(SED_TAR_DST),$(SED_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(SED_TAR_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(SED_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-acl \
	)

.PHONY: $(STRAPIT)-util-bzip
$(STRAPIT)-util-bzip:
	$(call CURL_FILE,$(BZIP_TAR_SRC))
	$(call DO_UNTAR,$(BZIP_TAR_DST),$(BZIP_TAR_SRC))
	$(ECHO) >"$(BZIP_TAR_DST)/configure"
	$(CHMOD) "$(BZIP_TAR_DST)/configure"
	$(SED) -i \
		-e "s|^(PREFIX[=]).+$$|\1$(COMPOSER_ABODE)|g" \
		"$(BZIP_TAR_DST)/Makefile"
	$(call AUTOTOOLS_BUILD,$(BZIP_TAR_DST),$(COMPOSER_ABODE))

.PHONY: $(STRAPIT)-util-gzip
$(STRAPIT)-util-gzip:
	$(call CURL_FILE,$(GZIP_TAR_SRC))
	$(call DO_UNTAR,$(GZIP_TAR_DST),$(GZIP_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(GZIP_TAR_DST),$(COMPOSER_ABODE))

.PHONY: $(STRAPIT)-util-xz
$(STRAPIT)-util-xz:
	$(call CURL_FILE,$(XZ_TAR_SRC))
	$(call DO_UNTAR,$(XZ_TAR_DST),$(XZ_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(XZ_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-util-tar
$(STRAPIT)-util-tar:
	$(call CURL_FILE,$(TAR_TAR_SRC))
	$(call DO_UNTAR,$(TAR_TAR_DST),$(TAR_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(TAR_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-acl \
		--without-posix-acls \
		--without-xattrs \
	)

.PHONY: $(STRAPIT)-util-perl
$(STRAPIT)-util-perl:
	$(call CURL_FILE,$(PERL_TAR_SRC))
	$(call DO_UNTAR,$(PERL_TAR_DST),$(PERL_TAR_SRC))
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" requires some patches
	if [ ! -f "$(PERL_TAR_DST)/Configure.perl" ]; then \
		$(SED) -i \
			-e "s|[ ][-]Wl[,][-][-]image[-]base[,]0x52000000||g" \
			"$(PERL_TAR_DST)/Makefile.SH"; \
		$(foreach FILE,$(PERL_PATCH_LIST),\
			$(call DO_PATCH,$(PERL_TAR_DST)$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
		) \
	fi
	# "$(BUILD_PLAT),Msys" does not have "/proc" filesystem or symlinks
	$(SED) -i \
		-e "s|^(case[ ][\"])[$$]d_readlink|\1NULL|g" \
		"$(PERL_TAR_DST)/Configure"
	$(SED) -i \
		-e "s|[$$]issymlink|test -f|g" \
		"$(PERL_TAR_DST)/Makefile.SH"
endif
	# "$(BUILD_PLAT),Msys" is case-insensitive, so 'Configure' is already 'configure'
	if [ ! -f "$(PERL_TAR_DST)/Configure.perl" ]; then \
		$(MV) "$(PERL_TAR_DST)/Configure" "$(PERL_TAR_DST)/Configure.perl"; \
		$(CP) "$(PERL_TAR_DST)/configure.gnu" "$(PERL_TAR_DST)/configure"; \
		$(SED) -i \
			-e "s|(Configure)([^.])|\1.perl\2|g" \
			"$(PERL_TAR_DST)/Configure.perl" \
			"$(PERL_TAR_DST)/MANIFEST" \
			"$(PERL_TAR_DST)/configure"; \
	fi
	$(call AUTOTOOLS_BUILD_NOTARGET,$(PERL_TAR_DST),$(COMPOSER_ABODE))

override define PERL_MODULES_BUILD =
	$(call CURL_FILE,$(2)); \
	$(call DO_UNTAR,$(PERL_TAR_DST)/$(1),$(2)); \
	cd "$(PERL_TAR_DST)/$(1)" && \
		$(BUILD_ENV) $(PERL) ./Makefile.PL PREFIX="$(COMPOSER_ABODE)" && \
		$(BUILD_ENV) $(MAKE) && \
		$(BUILD_ENV) $(MAKE) install
endef

.PHONY: $(STRAPIT)-util-perl-modules
$(STRAPIT)-util-perl-modules:
	$(foreach FILE,$(PERL_MODULES_LIST),\
		$(call PERL_MODULES_BUILD,$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
	)

.PHONY: $(FETCHIT)-bash
$(FETCHIT)-bash: $(FETCHIT)-bash-pull
$(FETCHIT)-bash: $(FETCHIT)-bash-prep

.PHONY: $(FETCHIT)-bash-pull
$(FETCHIT)-bash-pull:
	$(call CURL_FILE,$(BASH_TAR_SRC))
	# "$(BUILD_PLAT),Msys" does not support symlinks, so we have to exclude some files
	$(call DO_UNTAR,$(BASH_TAR_DST),$(BASH_TAR_SRC),$(notdir $(BASH_TAR_DST))/ChangeLog)

.PHONY: $(FETCHIT)-bash-prep
$(FETCHIT)-bash-prep:
	$(SED) -i \
		-e "s|[-]lcurses|-lncurses|g" \
		"$(BASH_TAR_DST)/configure"

.PHONY: $(BUILDIT)-bash
# thanks for the 'sigsetjmp' fix below: https://www.mail-archive.com/cygwin@cygwin.com/msg137488.html
# thanks for the 'malloc' fix below: http://www.linuxfromscratch.org/lfs/view/development/chapter05/bash.html
$(BUILDIT)-bash:
	# "$(BUILD_PLAT),Msys" requires "sigsetjmp" fix in order to build
	$(call AUTOTOOLS_BUILD,$(BASH_TAR_DST),$(COMPOSER_ABODE),\
		bash_cv_func_sigsetjmp="missing" \
		,\
		--enable-static-link \
		--without-bash-malloc \
	)
	$(CP) "$(COMPOSER_ABODE)/bin/bash" "$(COMPOSER_ABODE)/bin/sh"

.PHONY: $(FETCHIT)-less
$(FETCHIT)-less: $(FETCHIT)-less-pull
$(FETCHIT)-less: $(FETCHIT)-less-prep

.PHONY: $(FETCHIT)-less-pull
$(FETCHIT)-less-pull:
	$(call CURL_FILE,$(LESS_TAR_SRC))
	$(call DO_UNTAR,$(LESS_TAR_DST),$(LESS_TAR_SRC))

.PHONY: $(FETCHIT)-less-prep
$(FETCHIT)-less-prep:
	$(SED) -i \
		-e "s|[-]lncursesw|-lncurses|g" \
		"$(LESS_TAR_DST)/configure"

.PHONY: $(BUILDIT)-less
$(BUILDIT)-less:
	$(call AUTOTOOLS_BUILD,$(LESS_TAR_DST),$(COMPOSER_ABODE))

.PHONY: $(FETCHIT)-vim
$(FETCHIT)-vim: $(FETCHIT)-vim-pull
$(FETCHIT)-vim: $(FETCHIT)-vim-prep

.PHONY: $(FETCHIT)-vim-pull
$(FETCHIT)-vim-pull:
	$(call CURL_FILE,$(VIM_TAR_SRC))
	$(call DO_UNTAR,$(VIM_TAR_DST),$(VIM_TAR_SRC))

.PHONY: $(FETCHIT)-vim-prep
$(FETCHIT)-vim-prep:

.PHONY: $(BUILDIT)-vim
$(BUILDIT)-vim:
	$(call AUTOTOOLS_BUILD,$(VIM_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-acl \
		--disable-gpm \
		--disable-gui \
		--without-x \
	)

.PHONY: $(FETCHIT)-make
$(FETCHIT)-make: $(FETCHIT)-make-pull
$(FETCHIT)-make: $(FETCHIT)-make-prep

.PHONY: $(FETCHIT)-make-pull
$(FETCHIT)-make-pull:
	$(call GIT_REPO,$(MAKE_DST),$(MAKE_SRC),$(MAKE_CMT))

.PHONY: $(FETCHIT)-make-prep
$(FETCHIT)-make-prep:
	cd "$(MAKE_DST)" && \
		$(BUILD_ENV) $(AUTORECONF) && \
		$(BUILD_ENV) $(SH) ./configure && \
		$(BUILD_ENV) $(MAKE) update

.PHONY: $(BUILDIT)-make
$(BUILDIT)-make:
	$(call AUTOTOOLS_BUILD,$(MAKE_DST),$(COMPOSER_ABODE),,\
		--without-guile \
	)

.PHONY: $(FETCHIT)-infozip
$(FETCHIT)-infozip: $(FETCHIT)-infozip-pull
$(FETCHIT)-infozip: $(FETCHIT)-infozip-prep

.PHONY: $(FETCHIT)-infozip-pull
$(FETCHIT)-infozip-pull:
	$(call CURL_FILE,$(IZIP_TAR_SRC))
	$(call CURL_FILE,$(UZIP_TAR_SRC))
	$(call CURL_FILE,$(BZIP_TAR_SRC))
	$(call DO_UNTAR,$(IZIP_TAR_DST),$(IZIP_TAR_SRC))
	$(call DO_UNTAR,$(UZIP_TAR_DST),$(UZIP_TAR_SRC))
	$(call DO_UNTAR,$(BZIP_TAR_DST),$(BZIP_TAR_SRC))
	$(MKDIR) \
		"$(IZIP_TAR_DST)/bzip2" \
		"$(UZIP_TAR_DST)/bzip2"
	$(CP) "$(BZIP_TAR_DST)/"* "$(IZIP_TAR_DST)/bzip2/"
	$(CP) "$(BZIP_TAR_DST)/"* "$(UZIP_TAR_DST)/bzip2/"

.PHONY: $(FETCHIT)-infozip-prep
$(FETCHIT)-infozip-prep:
	$(SED) -i \
		-e "s|^(prefix[ ][=][ ]).+$$|\1$(COMPOSER_ABODE)|g" \
		"$(IZIP_TAR_DST)/unix/Makefile" \
		"$(UZIP_TAR_DST)/unix/Makefile"

.PHONY: $(BUILDIT)-infozip
$(BUILDIT)-infozip:
	cd "$(IZIP_TAR_DST)" && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile generic && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile install
	cd "$(UZIP_TAR_DST)" && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile generic && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile install

.PHONY: $(STRAPIT)-curl
$(STRAPIT)-curl: $(STRAPIT)-curl-pull
$(STRAPIT)-curl: $(STRAPIT)-curl-prep
$(STRAPIT)-curl: $(STRAPIT)-curl-build

.PHONY: $(FETCHIT)-curl
$(FETCHIT)-curl: $(FETCHIT)-curl-pull
$(FETCHIT)-curl: $(FETCHIT)-curl-prep

.PHONY: $(STRAPIT)-curl-pull
$(STRAPIT)-curl-pull:
	$(call CURL_FILE,$(CURL_TAR_SRC))
	$(call DO_UNTAR,$(CURL_TAR_DST),$(CURL_TAR_SRC))

.PHONY: $(FETCHIT)-curl-pull
$(FETCHIT)-curl-pull:
	$(call GIT_REPO,$(CURL_DST),$(CURL_SRC),$(CURL_CMT))

# thanks for the 'CURL_CA_BUNDLE' fix below: http://www.curl.haxx.se/mail/lib-2006-11/0276.html
#	also to: http://comments.gmane.org/gmane.comp.web.curl.library/29555
override define CURL_PREP =
	# don't unlink the "certdata.txt" file after downloading and processing it
	$(SED) -i \
		-e "s|([ ][-]b[ ][-]l)[ ][-]u|\1|g" \
		"$(1)/Makefile.in" \
		"$(1)/Makefile"
	$(SED) -i \
		-e "s|^([#]define[ ]CURL_CA_BUNDLE[ ]).*$$|\1getenv(\"CURL_CA_BUNDLE\")|g" \
		"$(1)/configure"
endef

.PHONY: $(STRAPIT)-curl-prep
$(STRAPIT)-curl-prep:
	$(call CURL_PREP,$(CURL_TAR_DST))

.PHONY: $(FETCHIT)-curl-prep
$(FETCHIT)-curl-prep:
	cd "$(CURL_DST)" && \
		$(BUILD_ENV) $(AUTORECONF) && \
		$(BUILD_ENV) $(SH) ./configure
	$(call CURL_PREP,$(CURL_DST))

#WORK : would be nice to double-check:
#	* this works from bootstrap
#	* perl-lwp works if curl fails
#	* curl works on re-entry
override define CURL_BUILD =
	cd "$(1)" && \
		$(BUILD_ENV) $(MAKE) CURL_CA_BUNDLE="$(CURL_CA_BUNDLE)" ca-bundle && \
		$(MKDIR) "$(COMPOSER_STORE)" && \
		$(MKDIR) "$(COMPOSER_ABODE)" && \
		$(MV) "$(1)/certdata.txt" "$(COMPOSER_STORE)/" && \
		$(MV) "$(1)/lib/ca-bundle.crt" "$(COMPOSER_ABODE)/"
	$(call AUTOTOOLS_BUILD,$(1),$(COMPOSER_ABODE),,\
		--with-ca-bundle="./ca-bundle.crt" \
		--disable-ldap \
		--without-libidn \
		--without-libssh2 \
		--disable-shared \
		--enable-static \
	)
endef

.PHONY: $(STRAPIT)-curl-build
$(STRAPIT)-curl-build:
	$(call CURL_BUILD,$(CURL_TAR_DST))

.PHONY: $(BUILDIT)-curl
$(BUILDIT)-curl:
	$(call CURL_BUILD,$(CURL_DST))

.PHONY: $(STRAPIT)-git
$(STRAPIT)-git: $(STRAPIT)-git-pull
$(STRAPIT)-git: $(STRAPIT)-git-prep
$(STRAPIT)-git: $(STRAPIT)-git-build

.PHONY: $(FETCHIT)-git
$(FETCHIT)-git: $(FETCHIT)-git-pull
$(FETCHIT)-git: $(FETCHIT)-git-prep

.PHONY: $(STRAPIT)-git-pull
$(STRAPIT)-git-pull:
	$(call CURL_FILE,$(GIT_TAR_SRC))
	$(call DO_UNTAR,$(GIT_TAR_DST),$(GIT_TAR_SRC))

.PHONY: $(FETCHIT)-git-pull
$(FETCHIT)-git-pull:
	$(call GIT_REPO,$(GIT_DST),$(GIT_SRC),$(GIT_CMT))

# thanks for the 'curl' fix below: http://www.curl.haxx.se/mail/lib-2007-05/0155.html
#	also to: http://www.makelinux.net/alp/021
# thanks for the 'librt' fix below: https://stackoverflow.com/questions/2418157/ubuntu-linux-c-error-undefined-reference-to-clock-gettime-and-clock-settim
override define GIT_PREP =
	cd "$(1)" && \
		$(BUILD_ENV) $(MAKE) configure
	$(SED) -i \
		-e "s|([-]lcurl)(.[^-])|\1 -lssl -lcrypto -lz -lrt\2|g" \
		"$(1)/configure"
	$(SED) -i \
		-e "s|([-]lcurl)$$|\1 -lssl -lcrypto -lz -lrt|g" \
		"$(1)/Makefile"
endef

.PHONY: $(STRAPIT)-git-prep
$(STRAPIT)-git-prep:
	$(call GIT_PREP,$(GIT_TAR_DST))

.PHONY: $(FETCHIT)-git-prep
$(FETCHIT)-git-prep:
	$(call GIT_PREP,$(GIT_DST))

override define GIT_BUILD =
	$(call AUTOTOOLS_BUILD,$(1),$(COMPOSER_ABODE),,\
		--without-tcltk \
	)
endef

.PHONY: $(STRAPIT)-git-build
$(STRAPIT)-git-build:
	$(call GIT_BUILD,$(GIT_TAR_DST))

.PHONY: $(BUILDIT)-git
$(BUILDIT)-git:
	$(call GIT_BUILD,$(GIT_DST))

.PHONY: $(FETCHIT)-texlive
$(FETCHIT)-texlive: $(FETCHIT)-texlive-pull
$(FETCHIT)-texlive: $(FETCHIT)-texlive-prep

.PHONY: $(FETCHIT)-texlive-pull
$(FETCHIT)-texlive-pull:
	$(call CURL_FILE,$(TEX_TEXMF_SRC))
	$(call CURL_FILE,$(TEX_TAR_SRC))
	$(call DO_UNTAR,$(TEX_TEXMF_DST),$(TEX_TEXMF_SRC))
	$(call DO_UNTAR,$(TEX_TAR_DST),$(TEX_TAR_SRC))

.PHONY: $(FETCHIT)-texlive-prep
# thanks for the 'libpng/floor' fix below: https://stackoverflow.com/questions/14743023/c-undefined-reference-to-floor
$(FETCHIT)-texlive-prep:
	# "$(BUILD_PLAT),Msys" is not detected, so default to "linux" settings
	$(CP) \
		"$(TEX_TAR_DST)/libs/icu/icu-"*"/source/config/mh-linux" \
		"$(TEX_TAR_DST)/libs/icu/icu-"*"/source/config/mh-unknown"
	# "$(BUILD_PLAT),Msys" doesn't seem to build these files
	$(SED) -i \
		-e "s|allcm[:]allec||g" \
		-e "s|fmtutil[:]mktexfmt||g" \
		-e "s|kpsetool[:]kpsexpand||g" \
		-e "s|kpsetool[:]kpsepath||g" \
		"$(TEX_TAR_DST)/texk/texlive/tl_scripts/Makefile.in"
	# dear texlive, please don't remove the destination directory before installing to it...
	$(SED) -i \
		-e "s|^([ ]*rm[ ][-]rf[ ][$$]TL[_]WORKDIR[ ]).+$$|\1|g" \
		"$(TEX_TAR_DST)/Build"
	# make sure we link in all the right libraries
	$(SED) -i \
		-e "s|(kpse_cv_fontconfig_libs[=]).*$$|\1\"-lfontconfig -lexpat -liconv -L$(TEX_TAR_DST)/Work/libs/freetype2 $(shell "$(COMPOSER_ABODE)/bin/freetype-config" --libs) -lm\"|g" \
		"$(TEX_TAR_DST)/texk/web2c/configure"

.PHONY: $(BUILDIT)-texlive
$(BUILDIT)-texlive:
	cd "$(TEX_TAR_DST)" && $(BUILD_ENV) TL_INSTALL_DEST="$(COMPOSER_ABODE)" \
		$(SH) ./Build \
		--disable-multiplatform \
		--without-ln-s \
		--without-x \
		--disable-shared \
		--enable-static
#>	$(call AUTOTOOLS_BUILD_NOTARGET,$(TEX_TAR_DST),$(COMPOSER_ABODE),,\
#>		--enable-build-in-source-tree \
#>		--disable-multiplatform \
#>		--without-ln-s \
#>		--without-x \
#>		--disable-shared \
#>		--enable-static \
#>	)
	$(CP) "$(TEX_TEXMF_DST)/"*		"$(COMPOSER_ABODE)/"
	$(RM)					"$(COMPOSER_ABODE)/bin/pdflatex"
	$(CP) "$(COMPOSER_ABODE)/bin/pdftex"	"$(COMPOSER_ABODE)/bin/pdflatex"
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-texlive-fmtutil

.PHONY: $(BUILDIT)-texlive-fmtutil
$(BUILDIT)-texlive-fmtutil:
	$(BUILD_ENV) fmtutil --all

.PHONY: $(STRAPIT)-ghc
$(STRAPIT)-ghc: $(STRAPIT)-ghc-pull
$(STRAPIT)-ghc: $(STRAPIT)-ghc-prep
$(STRAPIT)-ghc: $(STRAPIT)-ghc-build
$(STRAPIT)-ghc:
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(STRAPIT)-ghc-depends

.PHONY: $(FETCHIT)-ghc
$(FETCHIT)-ghc: $(FETCHIT)-ghc-pull
$(FETCHIT)-ghc: $(FETCHIT)-ghc-prep

.PHONY: $(STRAPIT)-ghc-pull
$(STRAPIT)-ghc-pull:
	$(call CURL_FILE,$(GHC_BIN_SRC))
	$(call CURL_FILE,$(CBL_TAR_SRC))
	$(call DO_UNTAR,$(GHC_BIN_DST),$(GHC_BIN_SRC))
	$(call DO_UNTAR,$(CBL_TAR_DST),$(CBL_TAR_SRC))

.PHONY: $(FETCHIT)-ghc-pull
$(FETCHIT)-ghc-pull:
	$(call GIT_REPO,$(GHC_DST),$(GHC_SRC),$(GHC_CMT),$(GHC_BRANCH))
	$(call GIT_SUBMODULE_GHC,$(GHC_DST))

.PHONY: $(STRAPIT)-ghc-prep
# thanks for the 'getnameinfo' fix below: https://www.mail-archive.com/haskell-cafe@haskell.org/msg60731.html
# thanks for the 'createDirectory' fix below: https://github.com/haskell/cabal/issues/1698
$(STRAPIT)-ghc-prep:
ifeq ($(BUILD_PLAT),Msys)
	$(call DO_HEREDOC,HEREDOC_CABAL_BOOTSTRAP) >"$(CBL_TAR_DST)/bootstrap.patch.sh"
	$(CHMOD) "$(CBL_TAR_DST)/bootstrap.patch.sh"
	$(SED) -i \
		-e "s|^(.+[{]GZIP[}].+)$$|\1\n\"$(CBL_TAR_DST)/bootstrap.patch.sh\"|g" \
		"$(CBL_TAR_DST)/bootstrap.sh"
	$(SED) -i \
		-e "s|createDirectoryIfMissingVerbose[ ]verbosity[ ]False[ ]distDirPath||g" \
		"$(CBL_TAR_DST)/Distribution/Client/Install.hs"
endif
	$(SED) -i \
		-e "s|^(CABAL_VER[=][\"])[^\"]+|\1$(CABAL_VERSION_LIB)|g" \
		"$(CBL_TAR_DST)/bootstrap.sh"

override define HEREDOC_CABAL_BOOTSTRAP =
#!$(SHELL)
[ -f "$(CBL_TAR_DST)/network-"*"/include/HsNet.h" ] && $(SED) -i [B]
	-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" [B]
	-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" [B]
	-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" [B]
	"$(CBL_TAR_DST)/network-"*"/include/HsNet.h" || exit 1
exit 0
endef

.PHONY: $(FETCHIT)-ghc-prep
# thanks for the 'removeFiles' fix below: https://ghc.haskell.org/trac/ghc/ticket/7712
$(FETCHIT)-ghc-prep:
	cd "$(GHC_DST)" && \
		$(BUILD_ENV_MINGW) $(PERL) ./boot
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" seems to find "gmp.h" in a different spot
	$(SED) -i \
		-e "s|^([#]include[ ].)(gmp[.]h.)$$|\1../gmp/\2|g" \
		"$(GHC_DST)/libraries/integer-gmp/cbits/alloc.c" \
		"$(GHC_DST)/libraries/integer-gmp/cbits/float.c"
endif
	# "$(BUILD_PLAT),Msys" fails if we don't have these calls quoted
	$(SED) -i \
		-e "s|(call[ ]removeFiles[,])([$$][(]GHCII[_]SCRIPT[)])|\1\"\2\"|g" \
		$(GHC_DST)/driver/ghci/ghc.mk
	$(SED) -i \
		-e "s|(call[ ]removeFiles[,])([$$][(]DESTDIR[)][$$][(]bindir[)][/]ghc.exe)|\1\"\2\"|g" \
		$(GHC_DST)/ghc/ghc.mk
#>	$(SED) -i \
#>		-e "s|$(GHC_VERSION_LIB)|$(CABAL_VERSION_LIB)|g" \
#>		"$(GHC_DST)/libraries/Cabal/Cabal/Cabal.cabal" \
#>		"$(GHC_DST)/libraries/Cabal/Cabal/Makefile"
#>	$(SED) -i \
#>		-e "s|([ ]+Cabal[ ]+)[>][=][^,]+|\1==$(CABAL_VERSION_LIB)|g" \
#>		"$(GHC_DST)/libraries/Cabal/cabal-install/cabal-install.cabal" \
#>		"$(GHC_DST)/libraries/bin-package-db/bin-package-db.cabal" \
#>		"$(GHC_DST)/utils/ghc-cabal/ghc-cabal.cabal"

.PHONY: $(STRAPIT)-ghc-build
$(STRAPIT)-ghc-build:
ifeq ($(BUILD_PLAT),Msys)
	$(MKDIR) "$(BUILD_STRAP)"
	$(CP) "$(GHC_BIN_DST)/"* "$(BUILD_STRAP)/"
else
	$(call AUTOTOOLS_BUILD_NOTARGET_MINGW,$(GHC_BIN_DST),$(BUILD_STRAP),,,\
		show \
	)
endif
	cd "$(CBL_TAR_DST)" && \
		$(BUILD_ENV_MINGW) PREFIX="$(BUILD_STRAP)" \
			$(SH) ./bootstrap.sh --global

.PHONY: $(STRAPIT)-ghc-depends
$(STRAPIT)-ghc-depends:
	$(RUNMAKE) $(FETCHIT)-cabal
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(BUILD_STRAP)) \
		$(subst |,-,$(GHC_LIBRARIES_LIST))

.PHONY: $(BUILDIT)-ghc
$(BUILDIT)-ghc:
#ifeq ($(BUILD_PLAT),Msys)
#	$(ECHO) "WORK : move this to 'prep' if it works...\n"
#	$(SED) -i \
#		-e "s|(cygpath[ ])[-][-]mixed|\1--unix|g" \
#		-e "s|(cygpath[ ])[-]m|\1--unix|g" \
#		"$(GHC_DST)/aclocal.m4" \
#		"$(GHC_DST)/configure"
#	$(call AUTOTOOLS_BUILD_NOTARGET_MINGW,$(GHC_DST),$(COMPOSER_ABODE))
#	$(ECHO) "WORK\n"; $(RM) -r "$(BUILD_STRAP)/mingw"*
#else
	$(call AUTOTOOLS_BUILD_NOTARGET_MINGW,$(GHC_DST),$(COMPOSER_ABODE))
#endif
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(COMPOSER_ABODE)) \
		Cabal-$(CABAL_VERSION_LIB)

.PHONY: $(FETCHIT)-haskell
$(FETCHIT)-haskell: $(FETCHIT)-haskell-pull
$(FETCHIT)-haskell: $(FETCHIT)-haskell-packages
$(FETCHIT)-haskell: $(FETCHIT)-haskell-prep

.PHONY: $(FETCHIT)-haskell-pull
$(FETCHIT)-haskell-pull:
	$(call GIT_REPO,$(HASKELL_DST),$(HASKELL_SRC),$(HASKELL_CMT))

.PHONY: $(FETCHIT)-haskell-packages
$(FETCHIT)-haskell-packages:
	$(SED) -i \
		-e "s|^(REQUIRED_GHC_VER[=]).+$$|\1$(GHC_VERSION)|g" \
		"$(HASKELL_DST)/src/generic/tarball/configure.ac"
	$(SED) -i \
		$(foreach FILE,$(HASKELL_VERSION_LIST),\
			-e "s|([ ]+$(word 1,$(subst |, ,$(FILE)))[ ]+[=][=])([^,]+)|\1$(word 2,$(subst |, ,$(FILE)))|g" \
		) \
		"$(HASKELL_DST)/haskell-platform.cabal"
	$(SED) -i \
		-e "s|^(for[ ]pkg[ ]in[ ][$$][{]SRC_PKGS[}])$$|\1 $(subst |,-,$(HASKELL_VERSION_LIST))|g" \
		"$(HASKELL_DST)/src/generic/prepare.sh"
	cd "$(HASKELL_DST)/src/generic" && \
		$(BUILD_ENV_MINGW) $(SH) ./prepare.sh

.PHONY: $(FETCHIT)-haskell-prep
# thanks for the 'OpenGL' fix below: https://stackoverflow.com/questions/18116201/how-can-i-disable-opengl-in-the-haskell-platform
# thanks for the 'GHC_PACKAGE_PATH' fix below: https://www.reddit.com/r/haskell/comments/1f8730/basic_guide_on_how_to_install_ghcplatform_manually
# thanks for the 'programFindLocation' fix below: https://github.com/albertov/hdbc-postgresql/commit/d4cef4dd288432141dab6365699317f2bb26c489
#	found by: https://github.com/haskell/cabal/issues/1467
# thanks for the 'wspiapi.h' fix below: https://github.com/nurupo/InsertProjectNameHere/commit/23f13cd95d5d9afaadd859a4d256986817e613b9
#	found by: https://github.com/irungentoo/toxcore/issues/92
#	then by: https://github.com/irungentoo/toxcore/pull/94
$(FETCHIT)-haskell-prep:
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(HASKELL_TAR)/scripts)
	$(SED) -i \
		-e "s|^unix[-].+$$|$(subst |,-,$(filter Win32|%,$(GHC_BASE_LIBRARIES_LIST)))|g" \
		"$(HASKELL_TAR)/packages/core.packages"
	$(SED) -i \
		-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" \
		-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" \
		-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" \
		-e "s|WSPIAPI[_]H|WS2TCPIP_H|g" \
		-e "s|wspiapi[.]h|ws2tcpip.h|g" \
		"$(HASKELL_TAR)/packages/network-"*"/include/HsNet.h"
endif
	$(foreach FILE,\
		$(HASKELL_TAR)/packages/haskell-platform-$(HASKELL_CMT)/haskell-platform.cabal \
		$(HASKELL_TAR)/packages/platform.packages \
		,\
		$(SED) -i \
			-e "/GLU/d" \
			-e "/OpenGL/d" \
			"$(FILE)"; \
	)
	$(SED) -i \
		-e "s|as_fn_error[ ](.+GLU)|echo \1|g" \
		-e "s|as_fn_error[ ](.+OpenGL)|echo \1|g" \
		"$(HASKELL_TAR)/configure"
	$(SED) -i \
		-e "s|^([ ]+GHC_PACKAGE_PATH[=].+)|#\1|g" \
		"$(HASKELL_TAR)/scripts/build.sh"
	$(SED) -i \
		-e "s|^([ ]+programFindLocation[ ][=][ ].x)([ ][-])|\1 _\2|g" \
		"$(HASKELL_TAR)/packages/haskell-platform-$(HASKELL_CMT)/Setup.hs"

.PHONY: $(BUILDIT)-haskell
$(BUILDIT)-haskell:
#WORK : must be a better way to do this than the configure option
	# "$(BUILD_PLAT),Msys" detects the version with a "^M" in it, which requires "unsupported-ghc" option to bypass
	$(call AUTOTOOLS_BUILD_MINGW,$(HASKELL_TAR),$(COMPOSER_ABODE),,\
		--enable-unsupported-ghc-version \
		--disable-user-install \
	)
#>	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(COMPOSER_ABODE)) \
#>		$(foreach FILE,$(shell $(CAT) "$(HASKELL_TAR)/packages/platform.packages"),\
#>			"$(HASKELL_TAR)/packages/$(FILE)" \
#>		)

.PHONY: $(FETCHIT)-pandoc
$(FETCHIT)-pandoc: $(FETCHIT)-pandoc-pull
$(FETCHIT)-pandoc: $(FETCHIT)-pandoc-prep

.PHONY: $(FETCHIT)-pandoc-pull
$(FETCHIT)-pandoc-pull:
	$(call GIT_REPO,$(PANDOC_TYPE_DST),$(PANDOC_TYPE_SRC),$(PANDOC_TYPE_CMT))
	$(call GIT_REPO,$(PANDOC_MATH_DST),$(PANDOC_MATH_SRC),$(PANDOC_MATH_CMT))
	$(call GIT_REPO,$(PANDOC_HIGH_DST),$(PANDOC_HIGH_SRC),$(PANDOC_HIGH_CMT))
	$(call GIT_REPO,$(PANDOC_CITE_DST),$(PANDOC_CITE_SRC),$(PANDOC_CITE_CMT))
	$(call GIT_REPO,$(PANDOC_DST),$(PANDOC_SRC),$(PANDOC_CMT))
	$(call GIT_SUBMODULE,$(PANDOC_DST))

.PHONY: $(FETCHIT)-pandoc-prep
$(FETCHIT)-pandoc-prep:
#WORKING : need to do this for all ghc builds, namely cabal
#	# make sure GHC looks for libraries in the right place
#	$(SED) -i \
#		-e "s|(Ghc[-]Options[:][ ]+)([-]rtsopts)|\1-optc-L$(COMPOSER_ABODE)/lib -optl-L$(COMPOSER_ABODE)/lib \2|g" \
#		-e "s|(ghc[-]options[:][ ]+)([-]funbox[-]strict[-]fields)|\1-optc-L$(COMPOSER_ABODE)/lib -optl-L$(COMPOSER_ABODE)/lib \2|g" \
#		"$(PANDOC_CITE_DST)/pandoc-citeproc.cabal" \
#		"$(PANDOC_DST)/pandoc.cabal"
#WORKING : pandoc css windows
#	# fix the pathname fix, since MSYS2 uses "mixed"-style pathnames: https://github.com/jgm/pandoc/commit/2956ef251c815c332679ff4666031a5b7a65aadc
#	$(SED) -i \
#		-e "s|(ensureEscaped[ ]x[@][(].+)\\\\\\\\|\1/|g" \
#		"$(PANDOC_DST)/src/Text/Pandoc/Shared.hs"

.PHONY: $(BUILDIT)-pandoc-deps
$(BUILDIT)-pandoc-deps:
	$(ESCAPE) "\n$(_H)$(MARKER) Dependencies"
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(COMPOSER_ABODE)) \
		--enable-tests \
		$(subst |,-,$(PANDOC_DEPENDENCIES_LIST))
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(COMPOSER_ABODE)) \
		--only-dependencies \
		--enable-tests \
		$(PANDOC_TYPE_DST) \
		$(PANDOC_MATH_DST) \
		$(PANDOC_HIGH_DST) \
		$(PANDOC_CITE_DST) \
		$(PANDOC_DST)
	cd "$(PANDOC_HIGH_DST)" && \
		$(BUILD_ENV_MINGW) $(MAKE) prep

#WORK			--flags="make-pandoc-man-pages embed_data_files network-uri https" \

override define PANDOC_BUILD =
	cd "$(1)" && \
		$(ESCAPE) "\n$(_H)$(MARKER) Configure$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(CABAL) configure \
			--prefix="$(COMPOSER_ABODE)" \
			--flags="make-pandoc-man-pages embed_data_files" \
			--enable-tests
	cd "$(1)" && \
		$(ESCAPE) "\n$(_H)$(MARKER) Build$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(CABAL) build;
	cd "$(1)" && \
		$(ESCAPE) "\n$(_H)$(MARKER) Test$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(CABAL) test || $(TRUE);
	cd "$(1)" && \
		$(ESCAPE) "\n$(_H)$(MARKER) Install$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(COMPOSER_ABODE))
endef

.PHONY: $(BUILDIT)-pandoc
$(BUILDIT)-pandoc: $(BUILDIT)-pandoc-deps
$(BUILDIT)-pandoc:
	$(call PANDOC_BUILD,$(PANDOC_TYPE_DST))
	$(call PANDOC_BUILD,$(PANDOC_MATH_DST))
	$(call PANDOC_BUILD,$(PANDOC_HIGH_DST))
	$(call PANDOC_BUILD,$(PANDOC_DST))
	$(call PANDOC_BUILD,$(PANDOC_CITE_DST))
	@$(ECHO) "\n"
	@$(BUILD_ENV) "$(COMPOSER_ABODE)/bin/pandoc" --version

########################################

#WORK : this all works great, but something more elegant needs to be done with it
#WORK : document!

override .RELEASE_DIR		?= $(abspath $(dir $(COMPOSER_OTHER)))
override .RELEASE_MAN_SRC	:= $(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))/pandoc/README
override .RELEASE_MAN_DST	:= $(CURDIR)/Pandoc_Manual

.PHONY: .release-config
.release-config:
	@$(ECHO) "override COMPOSER_OTHER ?= $(COMPOSER_OTHER)\n"	>"$(CURDIR)/$(COMPOSER_SETTINGS)"
	@$(ECHO) "override BUILD_DIST := 1\n"				>"$(abspath $(dir $(COMPOSER_OTHER)))/Msys/$(COMPOSER_SETTINGS)"
	@$(ECHO) "override BUILD_DIST := 1\n"				>"$(abspath $(dir $(COMPOSER_OTHER)))/Linux/$(COMPOSER_SETTINGS)"
	@$(call DEBUGIT_CONTENTS,$(CURDIR)/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(abspath $(dir $(COMPOSER_OTHER)))/Msys/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(abspath $(dir $(COMPOSER_OTHER)))/Linux/$(COMPOSER_SETTINGS))

.PHONY: .release
.release:
	@$(RUNMAKE) COMPOSER_OTHER="$(.RELEASE_DIR)/Msys"	BUILD_DIST="1" BUILD_PLAT="Msys"	COMPOSER_PROGS_USE="0" .dist
	@$(RUNMAKE) COMPOSER_OTHER="$(.RELEASE_DIR)/Linux"	BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_PROGS_USE="1" .dist
	@$(FIND) "$(CURDIR)" | $(SED) -n "/[.]git$$/p" | while read FILE; do \
		$(RM) "$${FILE}"; \
	done
	@$(RM) "$(.RELEASE_MAN_DST)."*
	@$(RUNMAKE) COMPOSER_OTHER="$(CURDIR)"			BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_PROGS_USE="1" $(COMPOSER_TARGET) \
		BASE="$(.RELEASE_MAN_DST)" LIST="$(.RELEASE_MAN_SRC)" TYPE="html" TOC="3"

.PHONY: .release-test
# this is only for testing conversion of the full Pandoc manual syntax into our primary document types
.release-test:
	@$(CP) "$(.RELEASE_MAN_SRC)" "$(.RELEASE_MAN_DST).$(COMPOSER_EXT)"
	# fix multi-line footnotes and copyright symbols, so "pdflatex" doesn't choke on them
	@$(SED) -i \
		-e "1459d; 1461d; 1463d; 1465d; 1467d; 1470d;" \
		-e "2770d; 2775d;" \
		-e "s|(rights[:][ ])\xc2\xa9|\1\(c\)|g" \
		"$(.RELEASE_MAN_DST).$(COMPOSER_EXT)"
	@$(RUNMAKE) COMPOSER_OTHER="$(CURDIR)"			BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_PROGS_USE="1" all \
		BASE="$(.RELEASE_MAN_DST)"

.PHONY: .release-debug
# this is only for debugging "pdflatex" conversion of the Pandoc manual
.release-debug:
	@$(RM) "$(.RELEASE_MAN_DST).latex"
	@$(RUNMAKE) COMPOSER_OTHER="$(CURDIR)"			BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_PROGS_USE="1" $(COMPOSER_TARGET) \
		BASE="$(.RELEASE_MAN_DST)" TYPE="latex"
	@$(BUILD_ENV) $(PDFLATEX) "$(.RELEASE_MAN_DST).latex"

override .DIST_ICON		:= iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3gUQBRoEzZLzOQAAAFFJREFUKM/NUcsVADAEC1Ma0Zi9qd/THjkRCWkB64LmtqpaLiIX9Q3PNjxzqqZFALBf1+5JljjVsyYIPjVcXd7fmAVPdnh0ZSd7ltA8uz/csjih8jivOCtEBAAAAABJRU5ErkJggg==
override .DIST_SCREENSHOT	:= iVBORw0KGgoAAAANSUhEUgAAAeQAAADjCAIAAADbvvCiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH3gUQBTsYVQy6lQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAVJ0lEQVR42u2d3basqA5G6Rr1RrVett9pnXc6F7Xb4eYnhBAQdM6L3dUuxYAQY5SPfz4hhBD+FwAAYEW+XvpFQwAArM/bvcTf39/vj5+fn559YBq/v79cCIANAuxPoxc27KbfKBR7Zn33t52/3r0W27U5QJOXfm00in5OuJ9r3FB3KXm0JyKyBlic4c5a/4h9bWQ0zltt6gfJjQAsxfvsKH9+fs5DtJRZ1uzT6qq+5TQ5iO/Oh+XnQs7njSxMj8oeUton6HLx0ZbWklObDfWKLpOv51XafO5R58bR1115BXk4gKdkQ87uoORx0r9mf5tz1nJknSaso9/VMg/7sztHv6N9SnvK57KVrGlVTb00NtuecjQ2l/5trbv+CgLc20u/m0ZsGqA5jpZqZJTuoAmmUguPo4TDJ2RF0six0wxNvdwTIL4NdQ6ZhfbxqinAfmkQecSen0Ojkbz+aMHCvcLPNIeDRwYImheM0VA/Yh93j+DrU0rJnJ6Ib/RXgxqb9QYcNjc5u9L+muSPpnDZpCgs2PquAzAwso5C5vM7otQLfB9Uq6/dovSivJvsWbJvqITn6Mj4asny2atZC8G/CCWnFmZtttXLKyaNaqG0OTUg/d9qOcqaAtwf/aSY1uipdZ+V46ael3X3sHm1JyeAp3npfxByavU1G8V3S9nMh9sAZmcdcNYAAFs4a1T3AAA2AGcNALCVs3afZsYWtly4BYDIGgAAZvPnBeO/tZkvbGHLRlsY2HAnPsd/PjxEs4U0CMDCzvpDZM0WImsAImu2sIXIGsAnsuYFIwDABjCDEQBggzQIkTUAwAbgrAEAcNYAAODBe2vr7yFLj7g+ADg768itROs0Rl+8HvtEW7LlpPsoEZae2cX3pY0AABAjfGdd8tSh5dPX7A/lb/3No+lPi8fXAACplzbmrOcErWb/xaIkAHAz3mlcvIinG2dMmiPOpmWOdYGDLpmjLDla+hYAoCHADo1pkFL64vdEupuQ+rAtoZvdobpWb2pzdkv6r+ao6pZsa5AGAQBVGqTkmMwZEtt7wugoQ+zZFIn7xrbfkDmKmtOb0PEnImsA0PNKfWW/E0mF0MYdtRQ/Pz/pJzEH9DYA6HXWhgB2gr9uLaEUVpfKaf3y5IvwsaBQd7IcANDDW5++OPugY+fqhI5zaiV67SanLLxeMEbl6Gsh52Q05WjaBwBAxfGCcUE0LxjT15KdEfSgEvprAQCP9tIrO+uNbhsAAEOdNXrWAACrO+uAkNP8kgEADDQ46+xCpU1CTiN837lA89vIdEoh4koAsFyArZzBmLrsy9cw1UwCVBrQcywAwGgv3bX4wBFKG0Ja/CAAgB7/6eZ6Tz3oRKn+RrRlWjUBAJwD7GBKg6RbUkkms0iTITzPyiRlzyuobxP+A8CCXtpfIjU9NlvaoK8s+HgDAG7JECEnAAAY4qznMz/DQE4DAPalQcjJxUuev1+esyRNdmWW6LxLLZEDAJBy2XRzF8/IDEYAuD2fa501AADonfWLhgAAWB+EnHY9OwDgrCu+KYjySZELmyzkFG0vnT2SoEqPEgSqwt8vY/nIBABm0DSDsTQ/MDtd8FohJ+HswvRFgxwVzhoAJnjprpx1dmFDZRB9lY+TbZ55pwEA0HNDIScXIrVuAIBreUe+qeqh0gkmqY+LIut0yzhXqDm7V8kAALOdtV7IKXoFJ2Q/zgmHUjkTIuL0RMqIPjoQHw0AF9Ir5PTzH6tlMPayGQBA5azdsxCOe47w1wAAe9Eg5HROldhy1uEKIafS5+FN9dKUAwAwDoScdj07ADwEhJwAALZx1gg5AQBsAEJO2AwA93LW2SxzdRLKjYWcWn008k8AYEcv5FT6U1YRSfg9IkotnXGCkFO/qQAAVS89MGeNkBMAgBcIORXvNK0fF/7+/mYD82M7AICZZiEnjY+rRtZ3FXKKmrGUGQcAMDprvZCTxl9HCQd5t9ERMUJOAHADeoWcls1gyDsg5AQAWzpr9yyE454j/PX8+gIA9NAg5BQUkkzKnPU9hJyytYh+480BwAWEnGbXghmMANAEQk4AANs4a4ScAAA2ACEneAr0Ftg+wP60dPdoPp5my4Th1/Sn9b2J+7G856QpYHsvbRNy0ggeTZu2jrNexFlv0eY4a9jUWRtz1umDpLxl8giZ81EgNlf7AAB44T/dvBTLrOOMlBrc55nr2Y+1NTokacnHx9el1kjP3lSOLEiSLed8oNLCVFQgPaR6Llv72Foe4C7ZEKuetTJnPUfPujUhICdzSkqEnVsi7WzZqpK3TcuR01A9Fv7+TWhXMO9vH9sVzJZDGgQ29dK9kXUaK2WFnKZFNzbjvZIAR0goxLZpm2hs9ipH02heClalW6mcH2vqM9G82aPls9cC4A5pEC+J1IeTPu+7NKZSanXa5VP2Fr23Hdfy9Ge4DS+z+whiSrQpNTE6rHax6sgDyLnmUJAEEWzQe5OqwWuqkWhMsn3NEvXDo/rytQDYOLIOCiGnVKRJsyVc/YKxKjVVEp+SswHm1jCkaM4P9Up//X38T9f5zVpoCMnTQ5TtfD7QJvs1uuUBFqVpUszQ2MpWrGYCjvtyt7BgbO7VWwAW9dJznDXOAgCgx1mjugcAsLqzDvcTciJTCQC3pMFZe83i8yX7GpCsBQDcMMBWzmA8/7VnFt+IyFq5HQBgUy/ttvjA4tJOAABb80qj4GnSpvhrAIA2Z32eEdOTWf5ORjh/zZpucTkRAMCj8JdIXU3aCQCAyBoAACY6637WlHYCALgHDTMYHb+z9vryWpDZ4/kAAO7Bp9VZ++LiT5nBCAA4awAAWMVZv2gIAID1QcgJAGCTAFupZ21e0zpaG3uEs1ZuBwDY1Eu/Ut/a5ByPhZqEo35O0O4AAAa6ctbZZfGUuh8EvwAAzc5aKeTUtGBr1VPjrwEA2pz10OnmCDkBAHTSLOQUBdfZ6Di7eou8DwAADIyseXMIADDPWTfh4ppJWAMA6HlHLnhEjJxmq12EswEAngNCTgAAS4OQEwDANs4aIScAgA1AyAkA4HbOOnKFpTeHpY0jHGj2m24+NQGAu3Go7lWngGcV9YS/yr99I2vldgCATb301Jz1OQrGnwIA6GkTcvKNiPHXAABtzto83fwQaSod9dUSQcgJAKCHZiGn1Bfr9zmXjKcGAJgXWQMAwDxnPQ4+2AAA6KdByOmsZN2UJylNXUHICQBACUJOAABLg5ATAMA2zhohJwCADcBZAwDgrAEAwNdZl7SZ2MKWHbcAEFkDAMBs/nwN8m+iQ/3LFrZsu4WBDXfic/znw0M0W0iDACzsrD9E1mwhsgYgsmYLW4isAXwia14wAgBsANPNAQA2SIMQWQMAbADOGgAAZw0AADhrAACcdRs7fjUl2Bwtx76m8amF65s9p//s2wh8fUj73DOyHnfl1p9YkVr4XXwnnSQyrZ1vMJCurUK211VNyu5wS6dma5/b9DHSIOEhffrG5+VqPvlaPKem79TZl9Yz/AZu343pPul9w31dxNSe4193mzVnF0r2renMktN6ado5u4OmfbzComz7VPtG1Of7e5S744hO1DQKzNeipxaac5X62Hdjkz3y0I4u9Aj/I9usHE1avhMZ05m7qZXnhFHPnOBSKuqgtCUtR046K20uPaHIv1tL7qmp0qpzIeaS03pp2rlkz1V9I1sLzdmjnWded3OfrKZBJl8Lzbmy+5Q0A/TtIzfOiFEp29w6mkr2fL30uym30nlrKh2ebs9uOW5Hmvi3yWZbfJfNGrceoqyppuRowXi54sJfvVrM0D62Fsv+1eXsco/6/tD0zNZayFe5OgoM19SxFhrDhMvUn9uNBsK4UWnoLT0X662p8CIp/POThaPNjjX1egpOa7pUYs7cYhfWYqjN1Z45cxQsWPLM65XaP25UTvaZrzT2jkxxPGtPUedkUPVRyCuGWr+mky10aeeht/+mbydKfV7/uF29XoNq19k3vodnH9In1GJcV5HvNONGpe1Erfa8S/efc9hfKlQWF44eEjtvcdlyouR9p83nPx0pJ30txtU0W3JkoWPJ8jOyssVaz94Z8uivjrxzqaYTrnu2DTX9sPRCT+4b6dvIQa9J9SVHSTxNHyttOQoZ6n80NldHUwPpC0aAJ/DkPq957QbrUH/BCAC3ZFwcDeNAzxoAYPXIOjCDEQBgC9qcdZOQSutrXJfcmaacdCbCUpQ+8jcYPHNlwplNOq4frtwHVrhei691OXnsTO6Hbc56nJCK77eQcpP9/MdVfc5lbshqCB+fTjsXrHm97jp2JgtLvRg564wTKjsiqtquta+1efHm2jdq6Uc13VwvpBKsMknVs0efUpolWryaUmOPIGojSPMEk7CUUNkmQR9lOytbvlXwKD171mbhobWnjwWFWI9G8iyYBLNKrbHU9Yp61HPGjpc/zNZd0z4hnL6z1ggnhXahmZKMiyxh0yMR1T99yCwsla2p3sIm2SbDY9cIKa6qJUIL9EgyaebvVROOyrqXJHs6t1Trtdr10vexW46daf4w3eev76zNwiUGt6gsTdOOXlIv1ejbbPM4wZpO8akmEQOXWe9pj1K2qlIgJZVJmP+8JYwdTd8QdC1WuF62lrzH2HH0h+a+966W0p9Bc1FPPz8Rd8obueQEU3smy0gNeiWraedOm3fMI9tadYQU1w2u16Zjx7c1DDeMlyats5R4UGfJEzzFZBmpmVenR8hphBSO8PjZ9Kbe8JmprL4m1FSwwZZwX+F63X7seLXGIaFlECKWZjAaXpuE8gIcoTHlX1r7o/P1gi0no3T90fsoWc4tq6QTdQXfdT2U9ujbOfvmLQpAzGt/GNpQDn/MrwHPbTKi5NLV2eJ6PWTsOPpDze05qtfXS/9JXQMMCpGWCsr6jbmr7NH86/XwcdHU1F8vjTYIjO2XN0tP3zjhfsvrtbK/1jf1p5oGAQCAy0HICQBgG15yuP5YuRyvuq8mfCPY8zTBI/2UmYc/sF8ooTPz1C6n08xUGuKsn5y9mizRAk/2hs+sZvWzwpn+59B3W3kNnZdXuz9BLufGdy8Ej9aJCZ4cDy1l1WoWvs/9/plyOWGkRIuL8E2wfuNZ6out9qwveBSdvakceSKc8strjSRT9LsqS2QWPPLqP16yTaEgEZWue9s5TrOTPKpiWJrxrhFgyraYlwcI4W8hp7TCD5HLqf7W7DlT+Mbr7He6gqXkYKkcjfSPzUKbLJpv+9iu4Ijea06DaNrHIAQml1O10D03omnDeMHcx8rljJNosbWJpv2zoki2WtxD8EhzB7KVo2m0kvrSiByjTfBoUP8xyza5tI9ZCCwtR9MTlLuN8wB7r27uJZdzuUSLY933yuQOEjxSSvwMGn7CiVrlHsfdL3fsP9PWk1qTrheM95DLuUSixSUDeLbZVovbCx5VDb5wdbfO+73t00Pf/jO/XtV9qr2upz9f21veGr+QvgfQv4Q8V6+0RfMsqSmnVLJ+uAo1Feo1+o49ru73uIJZS85vHZVhb7pzyUJDSJ4eomzn84HK9jFcQcf+I+e7SuOruo/SQmU2o7UNIzOuic1bhZyQy1E+c2ydX0LwaHee2f53rXX8gtEx3fPMr0eHxibz64K/4wrCUiDkBACwemQdEHICANiCVZx19Eo6+129Zk104Wt8eW311BhbLcZ9SD9I18bFwqGiSJfLCQUPbf6035a6q+2Tm0tGSk+vgFbera1vyIXZjipN3U5Lzr6orU4JHVGLcV/2aOoFI/rhuL7h/tXwIiMFbh5Z94wQ2UWuJlLqNTIBGCkPddaax6KQzLU3HCX4oBGeyPxdZEnzIfrrJfXKtmr2cbjVwpLMgtwa8rN2Tx8L3nJCsoXKK+jSNwbVdOZI0fQWcE6DaDSlstfSdpR+dIXuNYk1JVfTDqW62+ZHlLxb6WG5pFsW6YplH4cNFmbnYpSyMaWeI8+lkqc1tiZ8NG2YnZNiEwnx6hteqa1rR0pUU+VEf7A76zWf92W5HH1vMOjsTItuNDIu8m1ygqkXiiJ5teFqmShHC68dKXBBGmRZfy3vcIlU3qM44seqHCCRFCMFrnTWss5sSTbFa5W/aS7g3qtNzmmiXfz1tUJFg2xYcKTAkDSIIOwS/SnKnJbEeuSj+nuJoBWnX28i/L3QSVW+Mi05e4u65Os6pbiS4SF9QVGkziZyly4y9I2h4gSTR0q2t4A/rUJOd73H0sMAGCkre2mmm3dFoACMFJgDQk4AAKtH1oHIGgBgCzLO2mvWaes66DMxzLCqzsdTblm2TbyuMgCMCrA/Lc665+OkRXyWQUGtNDG6dcv9/B3OGmCOl36lY68690E5htd/EbGIhXztBABV6gvmhkRzIJph3PS1ZrbkkvZFv0tttbBHK7Jn0rNNQyd7daJWjcQwU9s0yhLCFgC4IA0iSJWXfgsKavJvOSOhSSCk4uilLVFqokd2XZOPNifrR6Rl0n/7kzl3WhoYYBcv/e5MXJRkzvu9kmaynCaSjSZbyjGsrFGpVJhLp65pGtacOPJN5pwfRIijAfZIgwxCKaK4WspbeROa7KlHkOp2Mg8C4HJevs6iVRdYs/GSD0UW9NQuK0aWhLfS0rKvPQmxAVaMrEuvlQxK9qUH7ZLY01CZG8FCvahN9qiS8I1QeJOnFmSAlEJOJeEtoRx5CwBMokfICSbnYS4vAQCu8tJMN98GEscATwYhJwCA1SPrMOJrkKb8L9HifLaYXAoAGZ/9UQ9y8279q3ytnG/dLhfstegabQ4wzUu/njmuVliF78IWI7IG2I7hzlr/0D3Tp4/zVpv6QXIjAIvzPjvKaCp2KbOs2afVedmWmtWIGaUTwTVyVK1fXkfN2FSyQdYqLVme8u4V6c8XjSpJcXFrgYdmQ0pyP5EnDQqRJnPOWo6s5dl0ss3y/lmxp6pVXiVr2rAkNdVqs+2Z5nLRKIP+OMD9vPS7aQxnZ1RfmEDwmg89ISviLofiJdzROh/Vt3E0olFIlAAEwVmXch3R2L52/FTzM4fB6+RkR5uxV/iJaBSAklfr4C/pQlw7Gbopo6KM+AzrNLo/FugNOGxuTfqXFEv6rxGiUQCjIusoZE7llqL4WiOBFCUc5d1kX1OVUhIkos7Fas5VzVoI/kXWy9YIMNlkrbxi0qVEowDgD+5CTpqYtLoIy7XsuBKKr82IRgGs5qXRBgnVJ3RsthlDaAzg5awDzhoAYAtnjUQqAMAG4KwBAHDWAACAswYAeAj/B20celP5v/1/AAAAAElFTkSuQmCC

.PHONY: .dist
.dist:
	@if [ "$(COMPOSER)" !=				"$(CURDIR)/$(MAKEFILE)" ]; then \
		$(CP) "$(COMPOSER)"			"$(CURDIR)/$(MAKEFILE)"; \
	fi
	@if [ -d "$(COMPOSER_PROGS)" ] && \
	    [ "$(COMPOSER_PROGS)" !=			"$(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))" ]; then \
		$(MKDIR)				"$(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))"; \
		$(CP) "$(COMPOSER_PROGS)/"*		"$(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))/"; \
	fi
	@$(ECHO) "$(.DIST_ICON)"	| $(BASE64) -d	>"$(CURDIR)/icon.png"
	@$(ECHO) "$(.DIST_SCREENSHOT)"	| $(BASE64) -d	>"$(CURDIR)/screenshot.png"
	@$(call DO_HEREDOC,.HEREDOC_DIST_GITIGNORE)	>"$(CURDIR)/.gitignore"
	@$(call DO_HEREDOC,.HEREDOC_DIST_COMPOSER_BAT)	>"$(CURDIR)/Composer.bat"
	@$(call DO_HEREDOC,.HEREDOC_DIST_COMPOSER_SH)	>"$(CURDIR)/Composer.sh"
	@$(call DO_HEREDOC,.HEREDOC_DIST_LICENSE)	>"$(CURDIR)/LICENSE.$(COMPOSER_EXT)"
	@$(call DO_HEREDOC,.HEREDOC_DIST_README)	>"$(CURDIR)/README.$(COMPOSER_EXT)"
	@$(call DO_HEREDOC,.HEREDOC_DIST_REVEALJS_CSS)	>"$(CURDIR)/revealjs.css"
	@$(CHMOD) \
		"$(CURDIR)/$(MAKEFILE)" \
		"$(CURDIR)/Composer.bat" \
		"$(CURDIR)/Composer.sh"
	@$(RUNMAKE) --directory "$(CURDIR)" $(UPGRADE)
	@$(RUNMAKE) --directory "$(CURDIR)" all

override define .HEREDOC_DIST_GITIGNORE =
# $(COMPOSER_BASENAME)
/$(COMPOSER_SETTINGS)

# make $(COMPOSER_TARGET)
/$(COMPOSER_STAMP)
/$(COMPOSER_CSS)

# make $(TESTING)
/$(notdir $(TESTING_DIR))/

# make $(UPGRADE) && make $(BUILDIT)
/$(notdir $(COMPOSER_ABODE))/
/$(notdir $(COMPOSER_STORE))/
/$(notdir $(COMPOSER_BUILD))/
endef

override define .HEREDOC_DIST_COMPOSER_BAT =
@echo off
set _COMPOSER=%~dp0
set _SYS=Msys
"%_COMPOSER%/bin/%_SYS%/usr/bin/make" BUILD_PLAT="$(BUILD_PLAT)" BUILD_ARCH="$(BUILD_ARCH)" COMPOSER_PROGS_USE="1" shell-msys
:: end of file
endef

override define .HEREDOC_DIST_COMPOSER_SH =
# bash
_COMPOSER="`dirname "$${0}"`"
_SYS="Linux"; [ -n "$${MSYSTEM}" ] && _SYS="Msys"
"$${_COMPOSER}/bin/$${_SYS}/usr/bin/make" BUILD_PLAT="$(BUILD_PLAT)" BUILD_ARCH="$(BUILD_ARCH)" COMPOSER_PROGS_USE="1" shell
# end of file
endef

override define .HEREDOC_DIST_LICENSE =
# Composer CMS License
<!-- ############################################################### -->

<!-- ########################### -->
## License Source

  * [http://opensource.org/licenses/BSD-3-Clause](http://opensource.org/licenses/BSD-3-Clause)

<!-- ########################### -->
## Copyright

    Copyright (c) 2014, Gary B. Genett
    All rights reserved.

<!-- ########################### -->
## License

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the
     distribution.

  3. Neither the name of the copyright holder nor the names of its
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<!-- ############################################################### -->
<!-- End Of File -->
<!-- ############################################################### -->
endef

override define .HEREDOC_DIST_README =
% Composer CMS: User Guide & Example File
% Gary B. Genett
% $(COMPOSER_VERSION) ($(shell $(DATE)))

## Composer CMS
<!-- ############################################################### -->
[Composer]: #composer-cms

![Composer Icon](icon.png "Composer Icon")
"Creating Made Simple."

* Homepage: [https://github.com/garybgenett/composer](https://github.com/garybgenett/composer)
* [License]

[License]: https://github.com/garybgenett/composer/blob/master/LICENSE.md
[Readme]: https://github.com/garybgenett/composer/blob/master/README.md

[Make]: http://www.gnu.org/software/make
[Pandoc]: http://www.johnmacfarlane.net/pandoc
[Markdown]: http://daringfireball.net/projects/markdown
[LaTeX]: http://www.tug.org
[GNU]: http://www.gnu.org
[Coreutils]: http://www.gnu.org/software/coreutils

[Wget]: https://www.gnu.org/software/wget
[Git]: http://www.git-scm.com

[Markdown Viewer]: https://github.com/Thiht/markdown-viewer
[Reveal.js]: https://github.com/hakimel/reveal.js
[W3C Slidy2]: http://www.w3.org/Talks/Tools/Slidy2

<!-- ########################### -->
## Contents
[Contents]: #contents

  * [Introduction]
    * [Overview]
    * [Quick Start]
    * [Goals]
  * [Details]
    * [Compatibility]
    * [Versioning]
    * [Dependencies]
    * [Caveats]

<!-- ############################################################### -->
# Introduction
[Introduction]: #introduction

<!-- ########################### -->
## Overview
[Overview]: #overview

[Composer] is a simple but powerful CMS based on [Pandoc] and [Make].
By default, input files are written in a variation of [Markdown].

Traditionally, CMS stands for Content Management System.  In the case of
[Composer], however, CMS really means a Content **Make** System.  For
many types of content, maybe even most, simpler is better.  Content is
very easy to manage when it lives its full life-cycle as plain text,
since there are a veritable multitude of solutions available for
tracking and managing text and source files.  What is really needed is
a basic system with advanced capabilities for "making" these simple text
files into richer, more capable document types.

This is the goal of [Composer].

![Composer Screenshot](screenshot.png "Composer Screenshot")

<!-- ########################### -->
## Quick Start
[Quick Start]: #quick-start

[Composer] is completely self-documenting.  To get the full usage and
help output:

  * `make help`

To download/update some necessary 3rd party components:

  * `make update`

To build an example/test directory using all features:

  * `make test`

In the simplest case, [Composer] can be used to make the conversion of
[Markdown] files to other formats a trivial task.  The real strength and
goal of [Composer], however, is as a recursive build system for any type
of output content (websites, manuals/documentation, etc.).

The [Readme] and [License] also serve as example source files.

<!-- ########################### -->
## Goals
[Goals]: #goals

[Composer] is really nothing more than a [Make]-based wrapper to
[Pandoc].  The author started out with the following requirements for an
all-purpose documentation production system:

  * Minimal dependencies, and entirely command-line driven.
  * All source files in plain-text, and readable/usable as stand-alone
    documents, which means no inline syntax/formatting that is
    aesthetically displeasing or difficult to integrate/camouflage.
  * Clear isolation of content from formatting, so writing and
    editing/publishing tasks can be performed independently.
  * Relatively basic command-line syntax for producing "ad hoc"
    documents, regardless of the complexity of the source/output.
  * Scalable and recursive, so whole directories of information can be
    managed easily, with websites and large documents (books, manuals,
    etc.) being primary in mind.
  * Support for dependencies and inheritance, with global, per-tree,
    per-directory and per-file overrides.
  * Workflow agnostic, so it can be used by semi-technical team
    members in a corporate environment.
  * Professional output, suitable for business environments or
    publication.

While support for a multitude of output formats was desired, the
following were absolute necessities:

  * HTML
  * PDF
  * Presentation / Slideshow
  * DocX (completely negotiable, but valuable)
  * ePUB (somewhat negotiable, but highly desired)

A thorough review and test of the large number of available input
formats and formatting engines resulted in a very short list of projects
which could support the above requirements.  [Pandoc] was selected for
a number of reasons:

  * [Markdown] is an increasingly universal/portable and popular
    plain-text format.
  * Required formats worked "out of the box", and intermediary formats
    like [LaTeX] were almost completely abstracted.
  * Did not require any expertise with output or intermediary formats to
    accomplish advanced results/output.
  * Supported a large number of input and output formats, and was
    designed very intelligently to allow translation from any supported
    input format to any supported output format.
  * Internally, normalizes documents into a single data structure which
    can be manipulated or modified.
  * If necessary, all templates could be modified and the internal
    conversion could be scripted at a very deep level.

[Pandoc] provided the perfect engine, but running long strings of
commands was not feasible for quick and simple command-line use, and the
thought of writing new scripting/automation each time a large-scale
project emerged was not terribly exciting.  Thus, [Make] was selected as
a wrapping engine based on it[Q]s years of history as one of the most
popular and highly used source file processing systems in use.

The final result is [Composer], which leverages these two tools to
accomplish the original goals with a minimum amount of user knowledge
and expertise, and to provide a solid foundation for simplified
management of larger content production efforts.

<!-- ############################################################### -->
# Details
[Details]: #details

<!-- ########################### -->
## Compatibility
[Compatibility]: #compatibility

[Composer] is developed and tested on a Funtoo/Gentoo [GNU]/Linux
system.  An effort has been made to do things in a portable way, but
cross-platform development is not an area of expertise for the author.

Output of `make --version` on development system:

```
GNU Make 3.82
Built for x86_64-pc-linux-gnu
```

Output of `pandoc --version` on development system:

```
pandoc 1.12.3.3
Compiled with texmath 0.6.6, highlighting-kate 0.5.6.1.
```

If you discover issues, please contact the author directly, with advance
thanks.  It is highly desirable for [Composer] to be as "run anywhere"
as possible.

Running the commands in the [Quick Start] section will help you validate
whether your system will work as expected.  In particular, the `make
test` command validates the proper functioning of all the supported
features and uses of [Composer].

<!-- ########################### -->
## Versioning
[Versioning]: #versioning

[Composer] is not really revisioned into "releases" outside of the
source code repository.  Each commit is tested using `make test` first,
so the latest source should always be ready for production.

If you require greater assurance of stability, use a version of the
source that is tagged with a version number.

<!-- ########################### -->
## Dependencies
[Dependencies]: #dependencies

[Composer] was designed to have a minimum of external dependencies:

  * [Pandoc]
    * Also need some version of [LaTeX] installed
  * [Make]
    * [GNU] version is highly recommended (other versions may not work)
  * [Coreutils]
    * [GNU] version is highly recommended (other versions may not work)

In order to download/update the 3rd party components, such as style
sheets and formatters, these are also needed:

  * [Wget]
    * General-purpose HTTP/FTP retrieval tool
  * [Git]
    * Distributed version control system

Components from these 3rd party projects are used:

  * [Markdown Viewer]
    * Simple and elegant CSS for HTML files
  * [Reveal.js]
    * Beautifully slick HTML presentation framework
  * [W3C Slidy2]
    * Essentially the grandfather of HTML presentation systems

Basically, any [GNU]-based system, such as [GNU]/Linux, Cygwin or
FreeBSD (with the [GNU] tools installed), should work just fine.  The
biggest external dependency is [Pandoc] itself and the [LaTeX] system it
uses to produce some of the output formats (namely PDF).

<!-- ########################### -->
## Caveats
[Caveats]: #caveats

There are a couple important items to be aware of when using [Composer]:

  * Portability
    * Running it on non-Linux systems or with different versions of
      [Make] (see [Compatibility]) may not produce expected results.
    * Portability is a goal of the project, and it is written with
      standards compliance in mind, but it may very well depend
      specifically on the [GNU] version of [Make] despite this.
    * An effort has been made to anticipate file names with spaces or
      other special characters, but horribly named files may produce
      equally horrible results (this is generally the case with any
      file-based automation).
    * The "automagic" target detection uses a simple regular
      expression and is very basic.
  * Recursion
    * While it simplifies things quite a bit, it does not completely
      hide away the complexities of using [Make] recursively.
    * Recursion handling and the `$$(COMPOSER_ABSPATH)` variable may be
      overly-clever and therefore not portable.
    * By default, recursion into sub-directories occurs after the
      current directory targets are run, which makes the output much
      more readable but precludes dependencies between parent
      directories and their children.
        * This behavior can be toggled globally or per-directory using
          the `$$(COMPOSER_DEPENDS)` variable as documented.
    * There are some who have made good arguments that systems other
      than [Make] should be used for recursion.  This author concedes
      some of their points, but has chosen to ignore them and use the
      most widely deployed and used [Make] system available.
  * Variables
    * This system gives precedence to environment variables at the top
      level and in all the examples, which is key to making the
      inheritance behavior work.
        * If you wish to be insulated from this, you can make all the
          option variable definitions in children [Make] files explicit
          (use `override OPTS :=` instead of `override OPTS ?=`) and
          place them below the upstream `include` statements.
        * The side effect of this will be that each directory will need
          to define it[Q]s own behavior (i.e. no inheritance).
        * This solution is documented in `make help`, is tested and
          supported, and does not require any modifications to the main
          [Make] file.
    * Similarly to the above, the `export` command should not be used in
      any [Make] files read by [Composer], other than the provided
      examples in `make help` which have been tested.
  * Output
    * The `make help` output could be much more kind to those not
      working on huge terminal windows.

Finally, it could be that [Composer] introduces more complexity than it
does add value, which this author guesses is likely true for many.

The author encourages the reader to review the [Goals] section and
decide for themselves if [Composer] will be beneficial for their needs.

<!-- ############################################################### -->
<!-- End Of File -->
<!-- ############################################################### -->
endef

override define .HEREDOC_DIST_REVEALJS_CSS =
@import url("./revealjs/css/theme/default.css");

body {
	background-image:	url("screenshot.png");
	background-repeat:	no-repeat;
	background-position:	98% 2%;
	background-size:	auto 20%;
}

.reveal h1 {
	font-size:	200%;
}

.reveal h1,
.reveal h2,
.reveal h3,
.reveal h4,
.reveal h5,
.reveal h6,
.reveal p {
	text-align:	left;
	text-transform:	none;
}

.reveal ol,
.reveal ul {
	display:	block;
}

.reveal figure {
	/* percent does not seem to work here */
	/* optimized for 1024x768 fullscreen */
	height:		18em;
}
endef

########################################

.PHONY: all
ifeq ($(COMPOSER_DEPENDS),)
all: whoami
else
all: whoami subdirs
endif
ifneq ($(COMPOSER_TARGETS),$(BASE))
all: \
	$(COMPOSER_TARGETS)
else
#WORKING	$(BASE).$(PRES_EXTN) \
#WORKING
all: \
	$(BASE).$(TYPE_HTML) \
	$(BASE).$(TYPE_LPDF) \
	$(BASE).$(SHOW_EXTN) \
	$(BASE).$(TYPE_DOCX) \
	$(BASE).$(TYPE_EPUB)
endif
ifeq ($(COMPOSER_DEPENDS),)
all: subdirs
endif

.PHONY: clean
.PHONY: $(addsuffix -clean,$(COMPOSER_TARGETS))
clean: $(addsuffix -clean,$(COMPOSER_TARGETS))
	@$(foreach FILE,$(COMPOSER_TARGETS),\
		$(RM) \
			"$(FILE)" \
			"$(FILE).$(TYPE)" \
			"$(FILE).$(TYPE_HTML)" \
			"$(FILE).$(TYPE_LPDF)" \
			"$(FILE).$(PRES_EXTN)" \
			"$(FILE).$(SHOW_EXTN)" \
			"$(FILE).$(TYPE_DOCX)" \
			"$(FILE).$(TYPE_EPUB)"; \
	)
	@$(RM) $(COMPOSER_STAMP)

.PHONY: whoami
whoami:
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_TARGETS$(_D)"	"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_SUBDIRS$(_D)"	"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_DEPENDS$(_D)"	"[$(_M)$(COMPOSER_DEPENDS)$(_D)]"
	@$(HEADER_2)
	@$(TABLE_C2) "$(_C)TYPE$(_D)"	"[$(_M)$(TYPE)$(_D)]"
	@$(TABLE_C2) "$(_C)BASE$(_D)"	"[$(_M)$(BASE)$(_D)]"
	@$(TABLE_C2) "$(_C)LIST$(_D)"	"[$(_M)$(LIST)$(_D)]"
	@$(TABLE_C2) "$(_C)_CSS$(_D)"	"[$(_M)$(_CSS)$(_D)]"
	@$(TABLE_C2) "$(_C)CSS$(_D)"	"[$(_M)$(CSS)$(_D)]"
	@$(TABLE_C2) "$(_C)TTL$(_D)"	"[$(_M)$(TTL)$(_D)]"
	@$(TABLE_C2) "$(_C)TOC$(_D)"	"[$(_M)$(TOC)$(_D)]"
	@$(TABLE_C2) "$(_C)LVL$(_D)"	"[$(_M)$(LVL)$(_D)]"
	@$(TABLE_C2) "$(_C)OPT$(_D)"	"[$(_M)$(OPT)$(_D)]"
	@$(HEADER_1)

.PHONY: settings
settings:
	@$(HEADER_L)
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_I3) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_L)
	@$(TABLE_I3) "$(_C)TYPE$(_D)"	"[$(_M)$(TYPE)$(_D)]"
	@$(TABLE_I3) "$(_C)BASE$(_D)"	"[$(_M)$(BASE)$(_D)]"
	@$(TABLE_I3) "$(_C)LIST$(_D)"	"[$(_M)$(LIST)$(_D)]"
	@$(TABLE_I3) "$(_C)_CSS$(_D)"	"[$(_M)$(_CSS)$(_D)]"
	@$(TABLE_I3) "$(_C)CSS$(_D)"	"[$(_M)$(CSS)$(_D)]"
	@$(TABLE_I3) "$(_C)TTL$(_D)"	"[$(_M)$(TTL)$(_D)]"
	@$(TABLE_I3) "$(_C)TOC$(_D)"	"[$(_M)$(TOC)$(_D)]"
	@$(TABLE_I3) "$(_C)LVL$(_D)"	"[$(_M)$(LVL)$(_D)]"
	@$(TABLE_I3) "$(_C)OPT$(_D)"	"[$(_M)$(OPT)$(_D)]"
	@$(HEADER_L)

.PHONY: setup
setup:
	@$(ECHO) "$(_S)"
ifeq ($(TYPE),$(TYPE_DOCX))
ifneq ($(PANDOC_DATA),)
ifneq ($(PANDOC_DATA_BUILD),)
	@$(MKDIR) "$(PANDOC_DATA_BUILD)"
	@$(CP) "$(PANDOC_DATA)/reference.docx" "$(PANDOC_DATA_BUILD)/"
endif
endif
endif
	@$(ECHO) "$(_D)"

.PHONY: subdirs $(COMPOSER_SUBDIRS)
subdirs: $(COMPOSER_SUBDIRS)
$(COMPOSER_SUBDIRS):
	@$(MAKE) --directory "$(CURDIR)/$(@)"

.PHONY: print
print: $(COMPOSER_STAMP)
$(COMPOSER_STAMP): *.$(COMPOSER_EXT)
	@$(LS) $(?)

########################################

.PHONY: $(COMPOSER_TARGET)
$(COMPOSER_TARGET): $(BASE).$(EXTENSION)

#WORKING : pandoc css windows
#	https://github.com/jgm/pandoc/issues/1558
#	https://github.com/jgm/pandoc/commit/2956ef251c815c332679ff4666031a5b7a65aadc

override MSYS_SED_FIXES	:= -e "s|[:]|;|g" -e "s|[/]([a-z])[/]|\1:\\\\\\\\|g" -e "s|[/]|\\\\\\\\|g"
override OPTIONS_ENV	:= $(subst $(ENV) - ,,$(BUILD_ENV))
override OPTIONS_DOC	:= $(PANDOC_OPTIONS)
ifeq ($(BUILD_PLAT),Msys)
override OPTIONS_ENV	:= $(subst $(TEXMFDIST),$(shell $(ECHO) '$(TEXMFDIST)'		| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_ENV))
override OPTIONS_ENV	:= $(subst $(TEXMFVAR),$(shell $(ECHO) '$(TEXMFVAR)'		| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_ENV))
override OPTIONS_DOC	:= $(subst $(_CSS),$(shell $(ECHO) '$(_CSS)'			| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_DOC))
override OPTIONS_DOC	:= $(subst $(REVEALJS_DST),$(shell $(ECHO) '$(REVEALJS_DST)'	| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_DOC))
override OPTIONS_DOC	:= $(subst $(W3CSLIDY_DST),$(shell $(ECHO) '$(W3CSLIDY_DST)'	| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_DOC))
endif

#WORKING
#override ENV		:= $(subst $(ENV),$(shell $(ECHO) '$(ENV)'			| $(SED) $(MSYS_SED_FIXES)),$(ENV))
override DOC		:= $(subst $(PANDOC),$(shell $(ECHO) '$(PANDOC)'		| $(SED) $(MSYS_SED_FIXES)),$(PANDOC))
#override OPTIONS_DOC	:= $(shell $(ECHO) '$(OPTIONS_DOC)'				| $(SED) $(MSYS_SED_FIXES))
#override OPTIONS_ENV	:= $(shell $(ECHO) '$(subst $(ENV) - ,,$(BUILD_ENV))'		| $(SED) $(MSYS_SED_FIXES))
#override OPTIONS_ENV	:= $(ENV) - $(OPTIONS_ENV)
#	$(ENV) - $(subst /,\,$(subst /c/,C:\,$(subst $(ENV) - ,,$(BUILD_ENV) $(PANDOC))))
#override MSYS_CSS	:= $(shell $(ECHO) '$(_CSS)'		| $(SED) -e "s|[/]([a-z])[/]|\1:\\\\|g" -e "s|[/]|\\\\|g")
#override MSYS_TEXMFDIST	:= $(shell $(ECHO) '$(TEXMFDIST)'	| $(SED) -e "s|[/]([a-z])[/]|\1:\\\\|g" -e "s|[/]|\\\\|g")
#override MSYS_TEXMFVAR	:= $(shell $(ECHO) '$(TEXMFVAR)'	| $(SED) -e "s|[/]([a-z])[/]|\1:\\\\|g" -e "s|[/]|\\\\|g")
#override PANDOC		:= $(subst $(_CSS),$(MSYS_CSS),$(subst $(TEXMFDIST),$(MSYS_TEXMFDIST),$(subst $(TEXMFVAR),$(MSYS_TEXMFVAR),$(PANDOC))))
#$(shell $(call DO_HEREDOC,.HEREDOC_DIST_REVEALJS_CSS)				| $(SED) -e "s|[:]|;|g" -e "s|[/]([a-z])[/]|file:///\1:\\\\|g" -e "s|[/]|\\\\|g" >"$(COMPOSER_DIR)/revealjs.css")

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(LIST) settings setup
	@$(TABLE_I3) "$(_H)Environment:"	'$(_D)$(OPTIONS_ENV)'
	@$(TABLE_I3) "$(_H)Pandoc Options:"	'$(_D)$(OPTIONS_DOC)'
	@$(ECHO) "$(_N)"
#WORKING
	@$(ECHO) '\n$(DOC) $(OPTIONS_DOC)\n\n'
#WORKING
#	@$(ENV) - $(OPTIONS_ENV) $(PANDOC) $(OPTIONS_DOC)
	$(ENV) - $(OPTIONS_ENV) $(PANDOC) $(OPTIONS_DOC)
	@$(ECHO) "$(_D)"
	@$(TOUCH) "$(CURDIR)/$(COMPOSER_STAMP)"

$(BASE).$(EXTENSION): $(LIST)
#WORKING
#	@$(MAKEDOC) --silent TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(LIST)"
	$(MAKEDOC) TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(LIST)"

%.$(TYPE_HTML): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_HTML)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_LPDF): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_LPDF)" BASE="$(*)" LIST="$(^)"

%.$(PRES_EXTN): %.$(COMPOSER_EXT)
#WORKING
#	@$(COMPOSE) --silent TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"
	$(COMPOSE) TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"

%.$(SHOW_EXTN): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_DOCX): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_DOCX)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_EPUB): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)"

################################################################################
# End Of File
################################################################################
