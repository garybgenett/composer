#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################

#WORKING
# _ add "licenses" or "info" option, to display list of included programs and licenses
# _ make sure all referenced programs are included (goal is composer should function as a chroot)
# _ do an initial make in Composer.sh, to ensure dirname is available?
# _ update COMPOSER_ALL_REGEX :: will impact ALL_TARGETS variable
# _ make all network operations non-blocking (i.e. use "|| true" on "curl, git, cabal update, etc.")
# _ pull all external files into core makefile, so that entire repository sources from single text file (not necessary, but really cool!)
# _ template inherit & archive target
#WORKING

#TODO : http://www.html5rocks.com/en/tutorials/webcomponents/imports
#TODO : http://filoxus.blogspot.com/2008/01/how-to-insert-watermark-in-latex.html
#TODO : http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html

#WORKING
# http://www.gnu.org/software/make/manual/make.html#toc-Features-of-GNU-make
# http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Make
# http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
#WORKING

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

override STRAPIT			:= bootstrap
override FETCHIT			:= fetch
override BUILDIT			:= build
override CHECKIT			:= check
override SHELLIT			:= shell

override UPGRADE			:= update
override REPLICA			:= clone
override INSTALL			:= install
override TESTOUT			:= test
override EXAMPLE			:= template

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
override COMPOSER_TESTING		?=
override COMPOSER_DEBUGIT		?=

override TESTOUT_DIR			:= $(COMPOSER_DIR)/$(TESTOUT).dir

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
override MDVIEWER_CMT			:= 86c90e73522678111f92840c4d88645b314f517e

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

ifneq ($(wildcard $(CSS)),)
override _CSS				:= $(CSS)
else ifneq ($(wildcard $(CSS_FILE)),)
override _CSS				:= $(CSS_FILE)
else ifeq ($(OUTPUT),revealjs)
override _CSS				:= $(REVEALJS_CSS)
else ifeq ($(OUTPUT),slidy)
override _CSS				:= $(W3CSLIDY_CSS)
else
override _CSS				:= $(MDVIEWER_CSS)
endif

ifneq ($(TOC),)
override _TOC				:= \
	--table-of-contents \
	--toc-depth $(TOC)
else
override _TOC				:=
endif

override PANDOC				:= pandoc \
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
	--variable "revealjs-url:$(REVEALJS_DST)" \
	--variable "slidy-url:$(W3CSLIDY_DST)" \
	\
	--chapters \
	--listings \
	--normalize \
	--smart \
	\
	$(OPT) \
	$(LIST)

########################################

override COMPOSER_ABODE			?= $(COMPOSER_DIR)/.home
override COMPOSER_STORE			?= $(COMPOSER_DIR)/.sources
override COMPOSER_BUILD			?= $(COMPOSER_DIR)/build

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

override COMPOSER_PROGS			?= $(COMPOSER_DIR)/bin/$(BUILD_PLAT)
override COMPOSER_PROGS_USE		?=

# thanks for the 'LANG' fix below: https://stackoverflow.com/questions/23370392/failed-installing-dependencies-with-cabal
#	found by: https://github.com/faylang/fay/issues/261
override LANG				?= en_US.UTF-8
override TERM				?= ansi
override CC				?=
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

# https://www.kernel.org/pub/linux/kernel/COPYING (license: GPL)
# https://www.kernel.org
override LIB_KAPI_VERSION		:= 3.18.1
override LIB_KAPI_TAR_SRC		:= https://www.kernel.org/pub/linux/kernel/v3.x/linux-$(LIB_KAPI_VERSION).tar.gz
override LIB_KAPI_TAR_DST		:= $(BUILD_STRAP)/linux-$(LIB_KAPI_VERSION)
# https://www.gnu.org/software/libc (license: GPL)
# https://www.gnu.org/software/libc
override LIB_LIBC_VERSION		:= 2.20
override LIB_LIBC_TAR_SRC		:= https://ftp.gnu.org/gnu/glibc/glibc-$(LIB_LIBC_VERSION).tar.gz
override LIB_LIBC_TAR_DST		:= $(BUILD_STRAP)/glibc-$(LIB_LIBC_VERSION)
# http://dev.perl.org/licenses (license: custom = GPL, Artistic)
# https://www.perl.org/get.html
override LIB_PERL_VERSION		:= 5.20.1
override LIB_PERL_TAR_SRC		:= http://www.cpan.org/src/5.0/perl-$(LIB_PERL_VERSION).tar.gz
override LIB_PERL_TAR_DST		:= $(BUILD_STRAP)/perl-$(LIB_PERL_VERSION)
# http://www.bzip.org (license: custom = BSD)
# http://www.bzip.org
override LIB_BZIP_VERSION		:= 1.0.6
override LIB_BZIP_TAR_SRC		:= http://www.bzip.org/$(LIB_BZIP_VERSION)/bzip2-$(LIB_BZIP_VERSION).tar.gz
override LIB_BZIP_TAR_DST		:= $(BUILD_STRAP)/bzip2-$(LIB_BZIP_VERSION)
# http://www.zlib.net/zlib_license.html (license: custom = as-is)
# http://www.zlib.net
override LIB_ZLIB_VERSION		:= 1.2.8
override LIB_ZLIB_TAR_SRC		:= http://www.zlib.net/zlib-$(LIB_ZLIB_VERSION).tar.xz
override LIB_ZLIB_TAR_DST		:= $(BUILD_STRAP)/zlib-$(LIB_ZLIB_VERSION)
# https://gmplib.org (license: GPL, LGPL)
# https://gmplib.org
override LIB_LGMP_VERSION		:= 6.0.0a
override LIB_LGMP_TAR_SRC		:= https://gmplib.org/download/gmp/gmp-$(LIB_LGMP_VERSION).tar.xz
override LIB_LGMP_TAR_DST		:= $(BUILD_STRAP)/gmp-$(subst a,,$(LIB_LGMP_VERSION))
# https://www.gnu.org/software/libiconv (license: GPL, LGPL)
# https://www.gnu.org/software/libiconv
override LIB_ICNV_VERSION		:= 1.14
override LIB_ICNV_TAR_SRC		:= https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(LIB_ICNV_VERSION).tar.gz
override LIB_ICNV_TAR_DST		:= $(BUILD_STRAP)/libiconv-$(LIB_ICNV_VERSION)
# https://www.gnu.org/software/gettext (license: GPL, LGPL)
# https://www.gnu.org/software/gettext
override LIB_GTXT_VERSION		:= 0.19.3
override LIB_GTXT_TAR_SRC		:= https://ftp.gnu.org/pub/gnu/gettext/gettext-$(LIB_GTXT_VERSION).tar.gz
override LIB_GTXT_TAR_DST		:= $(BUILD_STRAP)/gettext-$(LIB_GTXT_VERSION)
# https://www.gnu.org/software/ncurses (license: custom = as-is)
# https://www.gnu.org/software/ncurses
override LIB_NCRS_VERSION		:= 5.9
override LIB_NCRS_TAR_SRC		:= https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(LIB_NCRS_VERSION).tar.gz
override LIB_NCRS_TAR_DST		:= $(BUILD_STRAP)/ncurses-$(LIB_NCRS_VERSION)
# https://www.openssl.org/source/license.html (license: BSD)
# https://www.openssl.org
override LIB_OSSL_VERSION		:= 1.0.1j
override LIB_OSSL_TAR_SRC		:= https://www.openssl.org/source/openssl-$(LIB_OSSL_VERSION).tar.gz
override LIB_OSSL_TAR_DST		:= $(BUILD_STRAP)/openssl-$(LIB_OSSL_VERSION)
# http://sourceforge.net/projects/expat (license: MIT)
# http://expat.sourceforge.net
override LIB_EXPT_VERSION		:= 2.1.0
override LIB_EXPT_TAR_SRC		:= http://sourceforge.net/projects/expat/files/expat/$(LIB_EXPT_VERSION)/expat-$(LIB_EXPT_VERSION).tar.gz
override LIB_EXPT_TAR_DST		:= $(BUILD_STRAP)/expat-$(LIB_EXPT_VERSION)
# http://www.freetype.org/license.html (license: custom = BSD, GPL)
# http://www.freetype.org/download.html
override LIB_FTYP_VERSION		:= 2.5.3
override LIB_FTYP_TAR_SRC		:= http://download.savannah.gnu.org/releases/freetype/freetype-$(LIB_FTYP_VERSION).tar.gz
override LIB_FTYP_TAR_DST		:= $(BUILD_STRAP)/freetype-$(LIB_FTYP_VERSION)
# http://www.freedesktop.org/software/fontconfig/fontconfig-devel/ln12.html (license: custom = as-is)
# http://www.freedesktop.org/wiki/Software/fontconfig
override LIB_FCFG_VERSION		:= 2.11.1
override LIB_FCFG_TAR_SRC		:= http://www.freedesktop.org/software/fontconfig/release/fontconfig-$(LIB_FCFG_VERSION).tar.gz
override LIB_FCFG_TAR_DST		:= $(BUILD_STRAP)/fontconfig-$(LIB_FCFG_VERSION)

# https://www.gnu.org/software/coreutils (license: GPL)
# https://www.gnu.org/software/coreutils
override COREUTILS_VERSION		:= 8.23
override COREUTILS_TAR_SRC		:= https://ftp.gnu.org/gnu/coreutils/coreutils-$(COREUTILS_VERSION).tar.xz
override COREUTILS_TAR_DST		:= $(COMPOSER_BUILD)/coreutils-$(COREUTILS_VERSION)
#WORKING : these tools need to be added
#	find
#	patch
#	sed
#	tar

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
#TODO : need this?
ifeq ($(BUILD_PLAT),Msys)
#>override TEX_WINDOWS_SRC		:= ftp://ftp.tug.org/tex-archive                /systems/win32/w32tex/w32tex-src.tar.xz
override TEX_WINDOWS_SRC		:= ftp://ftp.tug.org/mirror/rsync.tex.ac.uk/CTAN/systems/win32/w32tex/w32tex-src.tar.xz
override TEX_WINDOWS_DST		:= $(COMPOSER_BUILD)/texlive-$(TEX_VERSION)-source-w32tex/ktx
endif

# https://www.haskell.org/ghc/license (license: BSD)
# https://www.haskell.org/ghc/download
# https://www.haskell.org/cabal/download.html
# https://hackage.haskell.org/package/cabal-install
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Tools
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Windows
# https://www.haskell.org/haskellwiki/Windows
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
#WORK : pandoc css windows
#	https://github.com/rstudio/rmarkdown/issues/238
override PANDOC_TYPE_CMT		:= 1.12.4
#override PANDOC_MATH_CMT		:= 0.6.6.3
override PANDOC_MATH_CMT		:= 178df262f2cc2b146d70#>178df262f2cc2b146d7043de29506aa7d17254f5 0.8
override PANDOC_HIGH_CMT		:= 0.5.8.5
#override PANDOC_CITE_CMT		:= 0.3.1
override PANDOC_CITE_CMT		:= 0.5
#override PANDOC_CMT			:= 1.12.4.2
override PANDOC_CMT			:= 704cfc1e3c2b6bc97cc3#>704cfc1e3c2b6bc97cc315c92671dc47e9c76977 1.13.2
#override PANDOC_VERSION			:= $(PANDOC_CMT)
override PANDOC_VERSION			:= 1.13.2

override BUILD_PATH_MINGW		:=
override BUILD_PATH			:= $(COMPOSER_ABODE)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_ABODE)/texlive/bin
override BUILD_PATH			:= $(BUILD_PATH):$(BUILD_STRAP)/bin
ifneq ($(COMPOSER_PROGS_USE),)
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_PROGS)/usr/bin
endif
ifeq ($(BUILD_PLAT),Msys)
override BUILD_PATH_MINGW		:=               $(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(MSYS_BIN_DST)/usr/bin
endif
override BUILD_PATH			:= $(BUILD_PATH):$(PATH)
ifeq ($(COMPOSER_PROGS_USE),)
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_PROGS)/usr/bin
endif

override BUILD_TOOLS			:=
override WINDOWS_ACL			:=
override PACMAN_DB_UPGRADE		:=
override PACMAN_KEY			:=
override PACMAN				:=
ifeq ($(BUILD_PLAT),Msys)
override BUILD_TOOLS			:= $(BUILD_TOOLS) \
	--with-gcc="$(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin/gcc" \
	--with-ld="$(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin/ld"
override WINDOWS_ACL			:= $(call COMPOSER_FIND,/c/Windows/SysWOW64 /c/Windows/System32 /c/Windows/System,icacls)
override PACMAN_DB_UPGRADE		:= "$(MSYS_BIN_DST)/usr/bin/pacman-db-upgrade"
override PACMAN_KEY			:= "$(MSYS_BIN_DST)/usr/bin/pacman-key"
override PACMAN				:= "$(MSYS_BIN_DST)/usr/bin/pacman" --verbose --noconfirm --sync
endif
override CABAL				:= cabal --verbose
override CABAL_INSTALL			= $(CABAL) install \
	$(BUILD_TOOLS) \
	--prefix="$(1)" \
	--global \
	--reinstall \
	--force-reinstalls
#>	--avoid-reinstalls

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

override BUILD_BINARY_LIST		:= \
	coreutils \
	find \
	patch \
	sed \
	tar \
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
	pandoc

#TODO : is cygwin-console-helper really needed?  what about cygpath, just in case?
override WINDOWS_BINARY_LIST		:= \
	cygwin-console-helper \
	mintty

# thanks for the patches below: https://github.com/Alexpux/MSYS2-packages/tree/master/perl
override PERL_PATCH_LIST		:= \
	/|https://raw.githubusercontent.com/Alexpux/MSYS2-packages/master/perl/perl-5.20.0-msys2.patch

override PERL_MODULES_LIST		:= \
	Encode-Locale-1.03|https://cpan.metacpan.org/authors/id/G/GA/GAAS/Encode-Locale-1.03.tar.gz \
	HTTP-Date-6.02|https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Date-6.02.tar.gz \
	HTTP-Message-6.06|https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Message-6.06.tar.gz \
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
	tex/latex/graphics \
	tex/latex/hyperref \
	tex/latex/latexconfig \
	tex/latex/listings \
	tex/latex/lm \
	tex/latex/oberdiek \
	tex/latex/pdftex-def \
	tex/latex/url

override GHC_LIBRARIES_LIST		:= \
	alex|3.1.3 \
	happy|1.19.4

ifneq ($(BUILD_GHC_78),)
override GHC_BASE_LIBRARIES_LIST	:= \
	Win32|WORKING \
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

# second group is for dependency resolution
# third group is for build fixes
# fourth group is for missing directories
override HASKELL_UPGRADE_LIST		:= \
	GHC|$(GHC_VERSION) \
	ghc|$(GHC_VERSION) \
	cabal-install|$(CABAL_VERSION) \
	Cabal|$(CABAL_VERSION_LIB) \
	$(GHC_BASE_LIBRARIES_LIST) \
	$(GHC_LIBRARIES_LIST) \

#WORKING
#	\
#	HTTP|4000.2.9 \
#	async|2.0.1.5 \
#	parallel|3.2.0.4 \
#	primitive|0.5.1.0 \
#	\
#	cgi|3001.1.8.5 \
#	haskell-src|1.0.1.6 \
#	unordered-containers|0.2.3.3 \
#	vector|0.10.9.1 \
#	\
#	MonadCatchIO-mtl|0.3.1.0 \
#	MonadCatchIO-transformers|0.3.1.0 \
#	extensible-exceptions|0.1.1.4 \
#	monads-tf|0.1.0.2

# thanks for the 'cgi' patch below: https://www.google.com/search?q=haskell+cgi+Module+Data.Typeable+mkTyCon+patch
#	details are at: https://ghc.haskell.org/trac/ghc/wiki/GhcKinds/PolyTypeable
override HASKELL_PATCH_LIST		:= \

#WORKING
#	/packages/cgi-3001.1.8.5|http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/dev-haskell/cgi/files/cgi-3001.1.8.5-ghc78.patch

override PANDOC_DEPENDENCIES_LIST	:= \
	hsb2hs|0.2 \
	hxt|9.3.1.4

#WORKING
#	network-uri|2.6.0.1 \
#	network|2.6.0.1 \

override PANDOC_UPGRADE_LIST		:= \

#WORKING
#	zip-archive|0.2.2.1

########################################

override PATH_LIST			:= $(subst :, ,$(BUILD_PATH))

#WORK : if COMPOSER_PROGS coreutils does this, they will always override the system utilities!
#WORK : need a new disposable location?  should COMPOSER_ABODE be split up into an actual install location COMPOSER_BUILT and home COMPOSER_ABODE?

override COREUTILS_PATH			:= $(call COMPOSER_FIND,$(PATH_LIST),coreutils)
override COREUTILS			:= "$(COREUTILS_PATH)"
ifneq ($(wildcard $(COREUTILS_PATH)),)
$(shell \
	$(COREUTILS) --coreutils-prog=ginstall -dv "$(COMPOSER_ABODE)/bin"; \
	$(COREUTILS) --help | sed -r -n "s|^[ ][[][ ]||gp" | sed -r "s|[ ]|\n|g" | while read FILE; do \
		$(COREUTILS) --coreutils-prog=echo -en "#!$(COREUTILS_PATH) --coreutils-prog-shebang=$${FILE}" >"$(COMPOSER_ABODE)/bin/$${FILE}"; \
		$(COREUTILS) --coreutils-prog=chmod 755 "$(COMPOSER_ABODE)/bin/$${FILE}"; \
	done; \
	$(COREUTILS) --coreutils-prog=echo -en "#!$(COREUTILS_PATH) --coreutils-prog-shebang=ginstall" >"$(COMPOSER_ABODE)/bin/install"; \
	$(COREUTILS) --coreutils-prog=chmod 755 "$(COMPOSER_ABODE)/bin/install"; \
	$(COREUTILS) --coreutils-prog=echo -en "#!$(call COMPOSER_FIND,$(PATH_LIST),sh)\ntype -P \"\$${@}\"\n# end of file" >"$(COMPOSER_ABODE)/bin/which"; \
)
endif

#WORKING : find all commands and make sure they get variables
#WORKING : what the f is up with printf?
override CHMOD				:= "$(call COMPOSER_FIND,$(PATH_LIST),chmod)" 755
override CP				:= "$(call COMPOSER_FIND,$(PATH_LIST),cp)" -afv
override ECHO				:= "$(call COMPOSER_FIND,$(PATH_LIST),echo)" -en
override LS				:= "$(call COMPOSER_FIND,$(PATH_LIST),ls)" --color=auto --time-style=long-iso -asF -l
override MKDIR				:= "$(call COMPOSER_FIND,$(PATH_LIST),install)" -dv
override MV				:= "$(call COMPOSER_FIND,$(PATH_LIST),mv)" -fv
override PRINTF				:= printf
override RM				:= "$(call COMPOSER_FIND,$(PATH_LIST),rm)" -fv
override SORT				:= "$(call COMPOSER_FIND,$(PATH_LIST),sort)" -u
override TOUCH				:= "$(call COMPOSER_FIND,$(PATH_LIST),date)" --rfc-2822 >
override TRUE				:= "$(call COMPOSER_FIND,$(PATH_LIST),true)"

override FIND				:= "$(call COMPOSER_FIND,$(PATH_LIST),find)"
override PATCH				:= "$(call COMPOSER_FIND,$(PATH_LIST),patch)" -p1
override SED				:= "$(call COMPOSER_FIND,$(PATH_LIST),sed)" -r
override TAR				:= "$(call COMPOSER_FIND,$(PATH_LIST),tar)" -vvx
override WHICH				:= "$(call COMPOSER_FIND,$(PATH_LIST),which)"

override BASH				:= "$(call COMPOSER_FIND,$(PATH_LIST),bash)"
override LESS				:= "$(call COMPOSER_FIND,$(PATH_LIST),less)" -rX
override VIM				:= "$(call COMPOSER_FIND,$(PATH_LIST),vim)" -u "$(COMPOSER_ABODE)/.vimrc" -i NONE -p

override define DO_PATCH		=
	$(call CURL_FILE,$(2)); \
	cd "$(1)" && $(PATCH) <"$(COMPOSER_STORE)/$(notdir $(2))"
endef
override define UNTAR			=
	if [ ! -d "$(1)" ]; then \
		$(MKDIR) "$(abspath $(dir $(1)))"; \
		$(TAR) -C "$(abspath $(dir $(1)))" -f "$(COMPOSER_STORE)/$(notdir $(2))" --exclude "$(3)"; \
	fi
endef
override define UNZIP			=
	"$(call COMPOSER_FIND,$(PATH_LIST),unzip)" -ou -d "$(abspath $(dir $(1)))" "$(COMPOSER_STORE)/$(notdir $(2))"
endef

override CURL				:= "$(call COMPOSER_FIND,$(PATH_LIST),curl)" --verbose --location --remote-time
override define CURL_FILE		=
	$(MKDIR) "$(COMPOSER_STORE)"; \
	$(CURL) --time-cond "$(COMPOSER_STORE)/$(notdir $(1))" --output "$(COMPOSER_STORE)/$(notdir $(1))" "$(1)"
endef
override define CURL_FILE_GNU_CFG	=
	$(MKDIR) "$(GNU_CFG_DST)"; \
	$(CURL) --time-cond "$(GNU_CFG_DST)/$(1)" --output "$(GNU_CFG_DST)/$(1)" "$(GNU_CFG_FILE_SRC)$(1)"
endef

override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git)
override GIT_EXEC			:= $(wildcard $(abspath $(dir $(GIT))../../git-core))
ifneq ($(GIT_EXEC),)
override GIT				:= $(GIT) --exec-path="$(GIT_EXEC)"
endif
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
override GIT_SUBMODULE_GHC		= $(call DO_GIT_SUBMODULE_GHC,$(1),$(2),$(COMPOSER_STORE)/$(notdir $(1)).git)
override define DO_GIT_SUBMODULE_GHC	=
	cd "$(1)" && $(FIND) ./ -mindepth 2 -type d -name ".git" 2>/dev/null | $(SED) -e "s|^[.][/]||g" -e "s|[/][.]git$$||g" | while read FILE; do \
		$(MKDIR) "$(3)/modules/$${FILE}"; \
		$(RM) -r "$(3)/modules/$${FILE}"; \
		$(MV) "$(1)/$${FILE}/.git" "$(3)/modules/$${FILE}"; \
	done; \
	cd "$(3)" && $(FIND) ./modules -type f -name "index" 2>/dev/null | $(SED) -e "s|^[.][/]modules[/]||g" -e "s|[/]index$$||g" | while read FILE; do \
		$(MKDIR) "$(1)/$${FILE}"; \
		$(ECHO) "gitdir: $(3)/modules/$${FILE}" >"$(1)/$${FILE}/.git"; \
		cd "$(1)/$${FILE}" && $(GIT) --git-dir="$(3)/modules/$${FILE}" config --local --replace-all core.worktree "$(1)/$${FILE}"; \
	done
endef

# thanks for the 'newline' fix below: https://stackoverflow.com/questions/649246/is-it-possible-to-create-a-multi-line-string-variable-in-a-makefile
#	also to: https://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
#WORK : this is a really, really ugly hack; it should be removed and then banished!
override CYGWIN_ESCAPE			:=
ifneq ($(CYGWIN_ROOT),)
override CYGWIN_ESCAPE			:= \\
endif
override define DO_TEXTFILE		=
	$(MKDIR) "$(abspath $(dir $(1)))"; \
	$(ECHO) -E '$(subst $(call NEWLINE),[N],$(call $(2)))' >"$(1)"; \
	$(SED) -i \
		-e "s|[[]B[]]|$(CYGWIN_ESCAPE)$(CYGWIN_ESCAPE)\\\\|g" \
		-e "s|[[]N[]]|$(CYGWIN_ESCAPE)\\n|g" \
		"$(1)"
endef

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
override PANDOC				:= $(PANDOC) --data-dir="$(PANDOC_DATA)"
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
override BUILD_ENV			:= "$(call COMPOSER_FIND,$(PATH_LIST),env)" - $(BUILD_ENV)
override BUILD_ENV_MINGW		:= $(BUILD_ENV)
ifeq ($(BUILD_PLAT),Msys)
override BUILD_ENV_MINGW		:= $(BUILD_ENV) \
	CC="$(MSYS_BIN_DST)/mingw$(BUILD_BITS)/bin/gcc" \
	MSYSTEM="MINGW$(BUILD_BITS)" \
	PATH="$(BUILD_PATH_MINGW):$(BUILD_PATH)"
endif

################################################################################

.NOTPARALLEL:
.POSIX:
.SUFFIXES:

#>.ONESHELL:
.SHELLFLAGS: -e

#WORK : make default header?

.DEFAULT_GOAL := $(HELPOUT)
.DEFAULT:
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(HELPOUT2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HELPLVL1)
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) ERROR:"
	@$(HELPOUT2) "$(_N)Target '$(_C)$(@)$(_N)' is not defined."
	@$(HELPOUT2)
	@$(HELPOUT2) "$(_H)$(MARKER) DETAILS:"
	@$(HELPOUT2) "You either need to define this target, or call a target which is already defined."
	@$(HELPOUT2) "Use '$(_M)targets$(_D)' to get a list of available targets for this '$(MAKEFILE)'."
	@$(HELPOUT2) "Or, review the output of '$(_M)$(HELPOUT)$(_D)' and/or '$(_M)$(HELPALL)$(_D)' for more information."
	@$(HELPLVL1)
	@exit 1

########################################

#WORK : move all this somewhere else?

#WORK : turn 'targets' and 'debug' into variables, like '$TESTOUT'?  others?

#WORK : document!
.PHONY: debug
debug:
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(HELPOUT2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(HELPOUT2) "$(_C)COMPOSER_DEBUGIT$(_D)"	"[$(_M)$(COMPOSER_DEBUGIT)$(_D)]"
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) DEBUG:"
	@$(HELPOUT2) "$(_N)This is the output of the '$(_C)debug$(_N)' target."
	@$(HELPOUT2)
	@$(HELPOUT2) "$(_H)$(MARKER) DETAILS:"
	@$(HELPOUT2) "This target runs several key sub-targets and diagnostic commands."
	@$(HELPOUT2) "The goal is to provide all needed troubleshooting information in one place."
	@$(HELPOUT2) "Set the '$(_M)COMPOSER_DEBUGIT$(_D)' variable to troubleshoot a particular list of targets $(_E)(they may be run)$(_D)."
	@$(HELPLVL1)
	@echo
	@$(RUNMAKE) --silent HELP_HEADER
	@$(RUNMAKE) --silent HELP_OPTIONS
	@$(RUNMAKE) --silent HELP_OPTIONS_SUB
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H) Diagnostics"
	@$(HELPLVL1)
	@echo
	@$(RUNMAKE) --silent check
	@echo
	@$(HELPLVL2)
	@echo
	@$(RUNMAKE) --silent targets
	@echo
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H) Targets Debug"
	@$(HELPLVL1)
	@echo
	@$(RUNMAKE) --silent --debug --just-print $(COMPOSER_DEBUGIT) || $(TRUE)
	@echo
	@$(foreach FILE,$(MAKEFILE_LIST),\
		$(HELPLINE); \
		$(HELPOUT1) "$(_H)$(MARKER) $(_M)$(FILE)"; \
		$(HELPLINE); \
		cat "$(FILE)"; \
		echo; \
	)
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H) Make Database Dump"
	@$(HELPLVL1)
	@echo
	@$(RUNMAKE) --silent .make_database
	@echo
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H) Composer Directory Listing"
	@$(HELPLVL1)
	@echo
	@$(LS) -R "$(COMPOSER_DIR)"
	@echo
	@$(RUNMAKE) --silent HELP_FOOTER

# thanks for the 'regex' fix below: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
#	also to: https://stackoverflow.com/questions/9691508/how-can-i-use-macros-to-generate-multiple-makefile-targets-rules-inside-foreach
#	also to: https://stackoverflow.com/questions/3063507/list-goals-targets-in-gnu-make
#	also to: http://backreference.org/2010/05/31/working-with-blocks-in-sed

#WORK : document!
.PHONY: .make_database
.make_database:
	@$(RUNMAKE) \
		--silent \
		--question \
		--print-data-base \
		--no-builtin-rules \
		--no-builtin-variables \
		: 2>/dev/null | cat

.PHONY: .all_targets
.all_targets:
	@$(RUNMAKE) --silent .make_database 2>/dev/null | \
		$(SED) -n -e "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" | \
		$(SED) -n -e "/^$(COMPOSER_ALL_REGEX)[:]/p" | \
		$(SORT)

#WORK : document!
override .ALL_TARGETS := \
	HELP[_] \
	EXAMPLE[_] \
	$(HELPOUT)[:-] \
	$(HELPALL)[:-] \
	$(COMPOSER_TARGET)[:-] \
	$(COMPOSER_PANDOC)[:-] \
	$(UPGRADE)[:-] \
	$(REPLICA)[:-] \
	$(INSTALL)[:-] \
	$(TESTOUT)[:-] \
	$(EXAMPLE)[:-] \
	$(STRAPIT)[:-] \
	$(FETCHIT)[:-] \
	$(BUILDIT)[:-] \
	$(CHECKIT)[:-] \
	$(SHELLIT)[:-] \
	debug[:] \
	targets[:] \
	all[:] \
	clean[:] \
	whoami[:] \
	settings[:] \
	setup[:] \
	subdirs[:] \
	print[:]

########################################

#WORK : move this to top with below?

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

ifneq ($(COMPOSER_ESCAPES),)
$(foreach FILE,\
	$(shell $(RUNMAKE) --silent COMPOSER_ESCAPES= .all_targets | $(SED) -n \
		$(foreach FILE,$(.ALL_TARGETS),\
			-e "/^$(FILE)/p" \
		) \
		| $(SED) "s|[:].*$$||g" \
	),\
	$(eval $(FILE): .set_title-$(FILE))\
)
.set_title-%:
	@$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
endif

########################################

#WORK : move this to top with above?

override NULL		:=
override define NEWLINE	=
$(NULL)
$(NULL)
endef

override MARKER		:= >>
override DIVIDE		:= ::
override INDENTING	:= $(NULL) $(NULL) $(NULL)
override COMMENTED	:= $(_S)\#$(_D) $(NULL)

#WORK : rename these!
override HELPLINE	:= $(ECHO) "$(_H)$(INDENTING)";	$(PRINTF)  "~%0.0s" {1..70}; $(ECHO) "$(_D)\n"
override HELPLVL1	:= $(ECHO) "$(_S)";		$(PRINTF) "\#%0.0s" {1..70}; $(ECHO) "$(_D)\n"
override HELPLVL2	:= $(ECHO) "$(_S)";		$(PRINTF) "\#%0.0s" {1..40}; $(ECHO) "$(_D)\n"
ifneq ($(COMPOSER_ESCAPES),)
override HELPOUT1	:= $(PRINTF) "$(INDENTING)%b\e[128D\e[22C%b\e[128D\e[52C%b$(_D)\n"
override HELPOUT2	:= $(PRINTF) "$(COMMENTED)%b\e[128D\e[22C%b$(_D)\n"
override HELPER		:= $(PRINTF) "%b$(_D)\n"
else
override HELPOUT1	:= $(PRINTF) "$(INDENTING)%-20s%-30s%s\n"
override HELPOUT2	:= $(PRINTF) "$(COMMENTED)%-20s%s\n"
override HELPER		:= $(PRINTF) "%s\n"
endif

override EXAMPLE_SECOND	:= LICENSE
override EXAMPLE_TARGET	:= manual
override EXAMPLE_OUTPUT	:= Users_Guide

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
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(COMPOSER_FULLNAME)"
	@$(HELPLVL1)
	@echo
	@$(HELPER) "$(_H)Usage:"
	@$(HELPOUT1) '$(_C)RUNMAKE$(_D) := $(_E)$(RUNMAKE)'
	@$(HELPOUT1) '$(_C)COMPOSE$(_D) := $(_E)$(COMPOSE)'
	@$(HELPOUT1) "$(_M)$(~)(RUNMAKE) [variables] <filename>.<extension>"
	@$(HELPOUT1) "$(_M)$(~)(COMPOSE) <variables>"
	@echo

.PHONY: HELP_OPTIONS
HELP_OPTIONS:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "$(_H)Variables:"
	@$(HELPOUT1) "$(_C)TYPE$(_D)"	"Desired output format"		"[$(_M)$(TYPE)$(_D)]"
	@$(HELPOUT1) "$(_C)BASE$(_D)"	"Base of output file(s)"	"[$(_M)$(BASE)$(_D)]"
	@$(HELPOUT1) "$(_C)LIST$(_D)"	"List of input files(s)"	"[$(_M)$(LIST)$(_D)]"
	@echo
	@$(HELPER) "$(_H)Optional Variables:"
	@$(HELPOUT1) "$(_C)CSS$(_D)"	"Location of CSS file"		"[$(_M)$(CSS)$(_D)] $(_N)(overrides '$(COMPOSER_CSS)')"
	@$(HELPOUT1) "$(_C)TTL$(_D)"	"Document title prefix"		"[$(_M)$(TTL)$(_D)]"
	@$(HELPOUT1) "$(_C)TOC$(_D)"	"Table of contents depth"	"[$(_M)$(TOC)$(_D)]"
	@$(HELPOUT1) "$(_C)LVL$(_D)"	"New slide header level"	"[$(_M)$(LVL)$(_D)]"
	@$(HELPOUT1) "$(_C)OPT$(_D)"	"Custom Pandoc options"		"[$(_M)$(OPT)$(_D)]"
	@echo
	@$(HELPER) "$(_H)Pre-Defined '$(_C)TYPE$(_H)' Values:"
	@$(HELPOUT1) "$(_C)$(TYPE_HTML)$(_D)"	"*.$(_E)$(TYPE_HTML)$(_D)"	"$(HTML_DESC)"
	@$(HELPOUT1) "$(_C)$(TYPE_LPDF)$(_D)"	"*.$(_E)$(TYPE_LPDF)$(_D)"	"$(LPDF_DESC)"
	@$(HELPOUT1) "$(_C)$(TYPE_PRES)$(_D)"	"*.$(_E)$(PRES_EXTN)$(_D)"	"$(PRES_DESC)"
	@$(HELPOUT1) "$(_C)$(TYPE_SHOW)$(_D)"	"*.$(_E)$(SHOW_EXTN)$(_D)"	"$(SHOW_DESC)"
	@$(HELPOUT1) "$(_C)$(TYPE_DOCX)$(_D)"	"*.$(_E)$(TYPE_DOCX)$(_D)"	"$(DOCX_DESC)"
	@$(HELPOUT1) "$(_C)$(TYPE_EPUB)$(_D)"	"*.$(_E)$(TYPE_EPUB)$(_D)"	"$(EPUB_DESC)"
	@$(HELPOUT1) "$(_M)Any other types specified will be passed directly through to Pandoc."
	@echo

.PHONY: HELP_OPTIONS_SUB
HELP_OPTIONS_SUB:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "Following is the complete list of exposed/configurable variables:"
	@echo
	@$(HELPER) "$(_H)Options:"
	@$(HELPOUT1) "$(_C)COMPOSER_GITREPO$(_D)"	"Source repository"		"[$(_M)$(COMPOSER_GITREPO)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_VERSION$(_D)"	"Version for cloning"		"[$(_M)$(COMPOSER_VERSION)$(_D)] $(_N)(valid: any Git tag or commit)"
	@$(HELPOUT1) "$(_C)COMPOSER_ESCAPES$(_D)"	"Enable color/title sequences"	"[$(_M)$(COMPOSER_ESCAPES)$(_D)] $(_N)(valid: empty or 1)"
	@echo
	@$(HELPER) "$(_H)File Options:"
	@$(HELPOUT1) "$(_C)COMPOSER_STAMP$(_D)"		"Timestamp file"		"[$(_M)$(COMPOSER_STAMP)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_CSS$(_D)"		"Default CSS file"		"[$(_M)$(COMPOSER_CSS)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_EXT$(_D)"		"Markdown file extension"	"[$(_M)$(COMPOSER_EXT)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_FILES$(_D)"		"List for '$(REPLICA)' target"	"[$(_M)$(COMPOSER_FILES)$(_D)]"
	@echo
	@$(HELPER) "$(_H)Recursion Options:"
	@$(HELPOUT1) "$(_C)COMPOSER_TARGETS$(_D)"	"Target list for 'all'"		"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_SUBDIRS$(_D)"	"Sub-directories list"		"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_DEPENDS$(_D)"	"Sub-directory dependency"	"[$(_M)$(COMPOSER_DEPENDS)$(_D)] $(_N)(valid: empty or 1)"
	@$(HELPOUT1) "$(_C)COMPOSER_TESTING$(_D)"	"Modifies '$(TESTOUT)' target"	"[$(_M)$(COMPOSER_TESTING)$(_D)] $(_N)(valid: empty, 0 or 1)"
	@$(HELPOUT1) "$(_C)COMPOSER_DEBUGIT$(_D)"	"Modifies 'debug' target"	"[$(_M)$(COMPOSER_DEBUGIT)$(_D)] $(_N)(valid: any target)"
	@echo
	@$(HELPER) "$(_H)Location Options:"
	@$(HELPOUT1) "$(_C)COMPOSER_ABODE$(_D)"		"Install/binary directory"	"[$(_M)$(COMPOSER_ABODE)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_STORE$(_D)"		"Source files directory"	"[$(_M)$(COMPOSER_STORE)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_BUILD$(_D)"		"Build directory"		"[$(_M)$(COMPOSER_BUILD)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_PROGS$(_D)"		"Built binaries directory"	"[$(_M)$(COMPOSER_PROGS)$(_D)]"
	@$(HELPOUT1) "$(_C)COMPOSER_PROGS_USE$(_D)"	"Prefer repository binaries"	"[$(_M)$(COMPOSER_PROGS_USE)$(_D)] $(_N)(valid: empty or 1)"
	@echo
	@$(HELPER) "$(_H)Build Options:"
	@$(HELPOUT1) "$(_C)BUILD_DIST$(_D)"		"Build generic binaries"	"[$(_M)$(BUILD_DIST)$(_D)] $(_N)(valid: empty or 1)"
	@$(HELPOUT1) "$(_C)BUILD_MSYS$(_D)"		"Force Windows detection"	"[$(_M)$(BUILD_MSYS)$(_D)] $(_N)(valid: empty or 1)"
	@$(HELPOUT1) "$(_C)BUILD_GHC_78$(_D)"		"GHC 7.8 instead of 7.6"	"[$(_M)$(BUILD_GHC_78)$(_D)] $(_N)(valid: empty or 1)"
	@$(HELPOUT1) "$(_C)BUILD_PLAT$(_D)"		"Overrides 'uname -o'"		"[$(_M)$(BUILD_PLAT)$(_D)]"
	@$(HELPOUT1) "$(_C)BUILD_ARCH$(_D)"		"Overrides 'uname -m'"		"[$(_M)$(BUILD_ARCH)$(_D)] $(_E)($(BUILD_BITS)-bit)"
	@echo
	@$(HELPER) "$(_H)Environment Options:"
	@$(HELPOUT1) "$(_C)LANG$(_D)"			"Locale default language"	"[$(_M)$(LANG)$(_D)] $(_N)(NOTE: use UTF-8)"
	@$(HELPOUT1) "$(_C)TERM$(_D)"			"Terminfo terminal type"	"[$(_M)$(TERM)$(_D)]"
	@$(HELPOUT1) "$(_C)CC$(_D)"			"C compiler"			"[$(_M)$(CC)$(_D)]"
#WORK : will need this to implement "chroot" composer
#	@$(HELPOUT1) "$(_C)LD_LIBRARY_PATH$(_D)"	"Linker library directories"	"[$(_M)$(LD_LIBRARY_PATH)$(_D)]"
	@$(HELPOUT1) "$(_C)PATH$(_D)"			"Run-time binary directories"	"[$(_M)$(BUILD_PATH)$(_D)]"
	@$(HELPOUT1) "$(_C)CURL_CA_BUNDLE$(_D)"		"SSL certificate bundle"	"[$(_M)$(CURL_CA_BUNDLE)$(_D)]"
	@echo
	@$(HELPER) "All of these can be set on the command line or in the environment."
	@echo
	@$(HELPER) "To set them permanently, add them to the settings file (you may have to create it):"
	@$(HELPOUT1) "$(_M)$(COMPOSER_INCLUDE)"
	@echo
	@$(HELPER) "All of these change the fundamental operation of $(COMPOSER_BASENAME), and should be used with care."
	@echo

.PHONY: HELP_TARGETS
HELP_TARGETS:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "$(_H)Primary Targets:"
	@$(HELPOUT1) "$(_C)$(HELPOUT)$(_D)"		"Basic help output"
	@$(HELPOUT1) "$(_C)$(HELPALL)$(_D)"		"Complete help output"
	@$(HELPOUT1) "$(_C)$(COMPOSER_TARGET)$(_D)"	"Main target used to build/format documents"
	@$(HELPOUT1) "$(_C)$(COMPOSER_PANDOC)$(_D)"	"Wrapper target which calls Pandoc directly (used internally)"
	@echo
	@$(HELPER) "$(_H)Installation Targets:"
	@$(HELPOUT1) "$(_C)$(UPGRADE)$(_D)"		"Download/update all 3rd party components (need to do this at least once)"
	@$(HELPOUT1) "$(_C)$(REPLICA)$(_D)"		"Clone key components into current directory (for inclusion in content repositories)"
	@$(HELPOUT1) "$(_C)$(INSTALL)$(_D)"		"Recursively create '$(MAKEFILE)' files (non-destructive build system initialization)"
	@$(HELPOUT1) "$(_C)$(TESTOUT)$(_D)"		"Build example/test directory using all features and test/validate success"
	@$(HELPOUT1) "$(_C)$(EXAMPLE)$(_D)"		"Print out example/template '$(MAKEFILE)' (helpful shortcut for creating recursive files)"
	@echo
	@$(HELPER) "$(_H)Compilation Targets:"
	@$(HELPOUT1) "$(_C)$(STRAPIT)$(_D)"		"Download and configure binary GHC bootstrap environment"
	@$(HELPOUT1) "$(_C)$(FETCHIT)$(_D)"		"Download/update GNU Make and Haskell/Pandoc source repositories"
	@$(HELPOUT1) "$(_C)$(BUILDIT)$(_D)"		"Build/compile local GNU Make and Haskell/Pandoc binaries from source"
	@$(HELPOUT1) "$(_C)$(CHECKIT)$(_D)"		"Diagnostic version information (for verification and/or troubleshooting)"
	@$(HELPOUT1) "$(_C)$(SHELLIT)$(_D)"		"$(COMPOSER_BASENAME) sub-shell environment, using native tools"
	@$(HELPOUT1) "$(_C)$(SHELLIT)-msys$(_D)"	"Launches MSYS2 shell (for Windows) into $(COMPOSER_BASENAME) environment"
	@echo
	@$(HELPER) "$(_H)Helper Targets:"
	@$(HELPOUT1) "$(_C)targets$(_D)"		"Parse '$(MAKEFILE)' for all potential targets (for verification and/or troubleshooting)"
	@$(HELPOUT1) "$(_C)all$(_D)"			"Create all of the default output formats or configured targets"
	@$(HELPOUT1) "$(_C)clean$(_D)"			"Remove all of the default output files or configured targets"
	@$(HELPOUT1) "$(_C)print$(_D)"			"List all source files newer than the '$(COMPOSER_STAMP)' timestamp file"
	@echo
	@$(HELPER) "$(_H)Wildcard Targets:"
	@$(HELPOUT1) "$(_C)$(REPLICA)-$(_N)%$(_D):"	"$(_E)$(REPLICA) COMPOSER_VERSION=$(_N)*$(_D)"	""
	@$(HELPOUT1) "$(_C)do-$(_N)%$(_D):"		"$(_E)fetch-$(_N)*$(_E) build-$(_N)*$(_D)"	""
	@echo

.PHONY: HELP_TARGETS_SUB
HELP_TARGETS_SUB:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "These are all the rest of the sub-targets used by the main targets above:"
	@echo
	@$(HELPER) "$(_H)Static Sub-Targets:"
	@$(HELPOUT1) "$(_C)$(INSTALL)$(_D):"		"$(_E)$(INSTALL)-dir$(_D)"			"Per-directory engine which does all the work"
	@$(HELPOUT1) "$(_C)$(COMPOSER_PANDOC)$(_D):"	"$(_E)settings$(_D)"				"Prints marker and variable values, for readability"
	@$(HELPOUT1) "$(_C)all$(_D):"			"$(_E)whoami$(_D)"				"Prints marker and variable values, for readability"
	@$(HELPOUT1) ""					"$(_E)subdirs$(_D)"				"Aggregates/runs the 'COMPOSER_SUBDIRS' targets"
	@$(HELPOUT1) "$(_C)$(STRAPIT)$(_D):"		"$(_E)$(STRAPIT)-check$(_D)"			"Tries to proactively prevent common errors"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-config$(_D)"			"Fetches current Gnu.org configuration files/scripts"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-msys$(_D)"			"Installs MSYS2 environment with MinGW-w64 (for Windows)"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs$(_D)"			"Build/compile of necessary libraries from source archives"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-curl$(_D)"			"Build/compile of cURL from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-git$(_D)"			"Build/compile of Git from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-ghc$(_D)"			"Build/complie of GHC from source archive"
	@$(HELPOUT1) "$(_E)$(STRAPIT)-msys$(_D):"	"$(_E)$(STRAPIT)-msys-bin$(_D)"			"Installs base MSYS2/MinGW-w64 system"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-msys-init$(_D)"		"Initializes base MSYS2/MinGW-w64 system"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-msys-fix$(_D)"			"Proactively fixes common MSYS2/MinGW-w64 issues"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-msys-pkg$(_D)"			"Installs/updates MSYS2/MinGW-w64 packages"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-msys-dll$(_D)"			"Copies MSYS2/MinGW-w64 DLL files (for native Windows usage)"
	@$(HELPOUT1) "$(_E)$(STRAPIT)-libs"		"$(_E)$(STRAPIT)-libs-glibc$(_D)"		"Build/compile of Glibc from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-perl$(_D)"		"Build/compile of Perl from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-bzip$(_D)"		"Build/compile of Bzip2 from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-zlib$(_D)"		"Build/compile of Zlib from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-gmp$(_D)"			"Build/compile of GMP from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-libiconv1$(_D)"		"Build/compile of Libiconv (before Gettext) from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-gettext$(_D)"		"Build/compile of Gettext from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-libiconv2$(_D)"		"Build/compile of Libiconv (after Gettext) from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-ncurses$(_D)"		"Build/compile of Ncurses from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-openssl$(_D)"		"Build/compile of OpenSSL from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-expat$(_D)"		"Build/compile of Expat from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-freetype$(_D)"		"Build/compile of FreeType from source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-libs-fontconfig$(_D)"		"Build/compile of Fontconfig from source archive"
	@$(HELPOUT1) "$(_E)$(STRAPIT)-curl$(_D):"	"$(_E)$(STRAPIT)-curl-pull$(_D)"		"Download of cURL source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-curl-prep$(_D)"		"Preparation of cURL source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-curl-build$(_D)"		"Build/compile of cURL from source archive"
	@$(HELPOUT1) "$(_E)$(STRAPIT)-git$(_D):"	"$(_E)$(STRAPIT)-git-pull$(_D)"			"Download of Git source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-git-prep$(_D)"			"Preparation of Git source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-git-build$(_D)"		"Build/compile of Git from source archive"
	@$(HELPOUT1) "$(_E)$(STRAPIT)-ghc$(_D):"	"$(_E)$(STRAPIT)-ghc-pull$(_D)"			"Download of GHC source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-ghc-prep$(_D)"			"Preparation of GHC source archive"
	@$(HELPOUT1) ""					"$(_E)$(STRAPIT)-ghc-build$(_D)"		"Build/compile of GHC from source archive"
	@$(HELPOUT1) "$(_C)$(FETCHIT)$(_D):"		"$(_E)$(FETCHIT)-config$(_D)"			"Fetches current Gnu.org configuration files/scripts"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-cabal$(_D)"			"Updates Cabal database"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-coreutils$(_D)"		"Download/preparation of GNU Coreutils source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-bash$(_D)"			"Download/preparation of Bash source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-less$(_D)"			"Download/preparation of Less source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-vim$(_D)"			"Download/preparation of Vim source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-make$(_D)"			"Download/preparation of GNU Make source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-infozip$(_D)"			"Download/preparation of Info-ZIP source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-curl$(_D)"			"Download/preparation of cURL source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-git$(_D)"			"Download/preparation of Git source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-tex$(_D)"			"Download/preparation of TeX Live source archives"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-ghc$(_D)"			"Download/preparation of GHC source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-haskell$(_D)"			"Download/preparation of Haskell Platform source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-pandoc$(_D)"			"Download/preparation of Pandoc source repositories"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-coreutils$(_D):"	"$(_E)$(FETCHIT)-coreutils-pull$(_D)"		"Download of GNU Coreutils source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-coreutils-prep$(_D)"		"Preparation of GNU Coreutils source archive"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-bash$(_D):"	"$(_E)$(FETCHIT)-bash-pull$(_D)"		"Download of Bash source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-bash-prep$(_D)"		"Preparation of Bash source archive"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-less$(_D):"	"$(_E)$(FETCHIT)-less-pull$(_D)"		"Download of Less source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-less-prep$(_D)"		"Preparation of Less source archive"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-vim$(_D):"	"$(_E)$(FETCHIT)-vim-pull$(_D)"			"Download of Vim source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-vim-prep$(_D)"			"Preparation of Vim source archive"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-make$(_D):"	"$(_E)$(FETCHIT)-make-pull$(_D)"		"Download of GNU Make source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-make-prep$(_D)"		"Preparation of GNU Make source repository"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-infozip$(_D):"	"$(_E)$(FETCHIT)-infozip-pull$(_D)"		"Download of Info-ZIP source archive"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-infozip-prep$(_D)"		"Preparation of Info-ZIP source archive"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-curl$(_D):"	"$(_E)$(FETCHIT)-curl-pull$(_D)"		"Download of cURL source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-curl-prep$(_D)"		"Preparation of cURL source repository"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-git$(_D):"	"$(_E)$(FETCHIT)-git-pull$(_D)"			"Download of Git source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-git-prep$(_D)"			"Preparation of Git source repository"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-tex$(_D):"	"$(_E)$(FETCHIT)-tex-pull$(_D)"			"Download of TeX Live source archives"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-tex-prep$(_D)"			"Preparation of TeX Live source archives"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-ghc$(_D):"	"$(_E)$(FETCHIT)-ghc-pull$(_D)"			"Download of GHC source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-ghc-prep$(_D)"			"Preparation of GHC source repository"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-haskell$(_D):"	"$(_E)$(FETCHIT)-haskell-pull$(_D)"		"Download of Haskell Platform source repository"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-haskell-packages$(_D)"		"Download/preparation of Haskell Platform packages"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-haskell-prep$(_D)"		"Preparation of Haskell Platform source repository"
	@$(HELPOUT1) "$(_E)$(FETCHIT)-pandoc$(_D):"	"$(_E)$(FETCHIT)-pandoc-pull$(_D)"		"Download of Pandoc source repositories"
	@$(HELPOUT1) ""					"$(_E)$(FETCHIT)-pandoc-prep$(_D)"		"Preparation of Pandoc source repositories"
	@$(HELPOUT1) "$(_C)$(BUILDIT)$(_D):"		"$(_E)$(BUILDIT)-clean$(_D)"			"Archives/restores source files and removes temporary build files"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-bindir$(_D)"			"Copies compiled binaries to repository binaries directory"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-coreutils$(_D)"		"Build/compile of GNU Coreutils from source archive"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-bash$(_D)"			"Build/compile of Bash from source archive"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-less$(_D)"			"Build/compile of Less from source archive"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-vim$(_D)"			"Build/compile of Vim from source archive"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-make$(_D)"			"Build/compile of GNU Make from source"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-infozip$(_D)"			"Build/compile of Info-ZIP from source archive"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-curl$(_D)"			"Build/compile of cURL from source"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-git$(_D)"			"Build/compile of Git from source"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-tex$(_D)"			"Build/compile of TeX Live from source archives"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-ghc$(_D)"			"Build/compile of GHC from source"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-haskell$(_D)"			"Build/compile of Haskell Platform from source"
	@$(HELPOUT1) ""					"$(_E)$(BUILDIT)-pandoc$(_D)"			"Build/compile of Pandoc(-CiteProc) from source"
	@$(HELPOUT1) "$(_E)$(BUILDIT)-tex$(_D):"	"$(_E)$(BUILDIT)-tex-fmt$(_D)"			"Build/install TeX Live format files"
	@$(HELPOUT1) "$(_E)$(BUILDIT)-pandoc$(_D):"	"$(_E)$(BUILDIT)-pandoc-deps$(_D)"		"Build/compile of Pandoc dependencies from source"
	@$(HELPOUT1) "$(_C)$(SHELLIT)[-msys]$(_D):"	"$(_E)$(SHELLIT)-bashrc$(_D)"			"Initializes Bash configuration file"
	@$(HELPOUT1) ""					"$(_E)$(SHELLIT)-vimrc$(_D)"			"Initializes Vim configuration file"
	@echo
	@$(HELPER) "$(_H)Dynamic Sub-Targets:"
	@$(HELPOUT1) "$(_C)all$(_D):"			"$(_E)$(~)(COMPOSER_TARGETS)$(_D)"		"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(HELPOUT1) "$(_C)clean$(_D):"			"$(_E)$(~)(COMPOSER_TARGETS)-clean$(_D)"	"[$(_M)$(addsuffix -clean,$(COMPOSER_TARGETS))$(_D)]"
	@$(HELPOUT1) "$(_C)subdirs$(_D):"		"$(_E)$(~)(COMPOSER_SUBDIRS)$(_D)"		"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@echo
	@$(HELPER) "$(_H)Hidden Sub-Targets:"
	@$(HELPOUT1) "$(_C)targets$(_D):"		"$(_E).all_targets$(_D)"			"Dynamically parse and print all potential targets"
	@$(HELPOUT1) "$(_C)$(_N)%$(_D):"		"$(_E).set_title-$(_N)*$(_D)"			"Set window title to current target using escape sequence"
	@echo
	@$(HELPER) "These do not need to be used directly during normal use, and are only documented for completeness."
	@echo

.PHONY: HELP_COMMANDS
HELP_COMMANDS:
	@$(HELPLVL1)
	@echo
	@$(HELPER) "$(_H)Command Examples:"
	@echo
	@$(HELPOUT2) "$(_E)Have the system do all the work:"
	@$(HELPER) "$(_M)$(~)(RUNMAKE) $(BASE).$(EXTENSION)"
	@echo
	@$(HELPOUT2) "$(_E)Be clear about what is wanted (or, for multiple or differently named input files):"
	@$(HELPER) "$(_M)$(~)(COMPOSE) LIST=\"$(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@echo

.PHONY: EXAMPLE_MAKEFILES
EXAMPLE_MAKEFILES: \
	EXAMPLE_MAKEFILES_HEADER \
	EXAMPLE_MAKEFILE_1 \
	EXAMPLE_MAKEFILE_2 \
	EXAMPLE_MAKEFILES_FOOTER

.PHONY: EXAMPLE_MAKEFILES_HEADER
EXAMPLE_MAKEFILES_HEADER:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "$(_H)Calling from children '$(MAKEFILE)' files:"
	@echo

.PHONY: EXAMPLE_MAKEFILE_1
EXAMPLE_MAKEFILE_1:
	@$(HELPOUT2) "$(_E)Simple, with filename targets and \"automagic\" detection of them:"
	@$(HELPOUT2) "$(_S)include $(COMPOSER)"
	@$(HELPER) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TARGET)"
	@$(HELPER) "$(_C)$(BASE)$(_D): $(_N)# so \"clean\" will catch the below files"
	@$(HELPER) "$(_C)$(EXAMPLE_TARGET)$(_D): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@$(HELPER) "$(_C)$(EXAMPLE_SECOND).$(EXTENSION)$(_D):"
	@echo

.PHONY: EXAMPLE_MAKEFILE_2
EXAMPLE_MAKEFILE_2:
	@$(HELPOUT2) "$(_E)Advanced, with manual enumeration of user-defined targets and per-target variables:"
	@$(HELPER) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE) $(EXAMPLE_TARGET) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(HELPOUT2) "$(_S)include $(COMPOSER)"
	@$(HELPER) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TARGET)"
	@$(HELPER) "$(_C)$(BASE)$(_D): export TOC := 1"
	@$(HELPER) "$(_C)$(BASE)$(_D): $(BASE).$(EXTENSION)"
	@$(HELPER) "$(_C)$(EXAMPLE_TARGET)$(_D): $(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)"
	@$(HELPER) "	$(~)(COMPOSE) LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@$(HELPER) "	$(~)(COMPOSE) LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_LPDF)\""
	@$(HELPER) "$(_C)$(EXAMPLE_TARGET)-clean$(_D):"
	@$(HELPER) "	$(~)(RM) $(EXAMPLE_OUTPUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@echo

.PHONY: EXAMPLE_MAKEFILES_FOOTER
EXAMPLE_MAKEFILES_FOOTER:
	@$(HELPOUT2) "$(_E)Then, from the command line:"
	@$(HELPER) "$(_M)make clean && make all"
	@echo

.PHONY: HELP_SYSTEM
HELP_SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
HELP_SYSTEM:
	@$(HELPLVL1)
	@echo
	@$(HELPER) "$(_H)Completely recursive build system:"
	@echo
	@$(HELPOUT2) "$(_E)The top-level '$(MAKEFILE)' is the only one which needs a direct reference:"
	@$(HELPOUT2) "$(_N)(NOTE: This must be an absolute path.)"
	@$(HELPER) "include $(COMPOSER)"
	@echo
	@$(HELPOUT2) "$(_E)All sub-directories then each start with:"
	@$(HELPER) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(HELPER) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@$(HELPER) "override $(_C)COMPOSER_SUBDIRS$(_D) ?="
	@$(HELPER) "$(_C).DEFAULT_GOAL$(_D) := $(_C)all"
	@echo
	@$(HELPOUT2) "$(_E)And end with:"
	@$(HELPER) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@echo
	@$(HELPOUT2) "$(_E)Back in the top-level '$(MAKEFILE)', and in all sub-'$(MAKEFILE)' instances which recurse further down:"
	@$(HELPER) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(HELPER) "include [...]"
	@echo
	@$(HELPOUT2) "$(_E)Create a new '$(MAKEFILE)' using a helpful template:"
	@$(HELPER) "$(_M)$(~)(RUNMAKE) COMPOSER_TARGETS=\"$(BASE).$(EXTENSION)\" $(EXAMPLE) >$(MAKEFILE)"
	@echo
	@$(HELPOUT2) "$(_E)Or, recursively initialize the current directory tree:"
	@$(HELPOUT2) "$(_N)(NOTE: This is a non-destructive operation.)"
	@$(HELPER) "$(_M)$(~)(RUNMAKE) $(INSTALL)"
	@echo

.PHONY: EXAMPLE_MAKEFILE
EXAMPLE_MAKEFILE: \
	EXAMPLE_MAKEFILE_HEADER \
	EXAMPLE_MAKEFILE_FULL \
	EXAMPLE_MAKEFILE_TEMPLATE

.PHONY: EXAMPLE_MAKEFILE_HEADER
EXAMPLE_MAKEFILE_HEADER:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "$(_H)Finally, a completely recursive '$(MAKEFILE)' example:"
	@echo

.PHONY: EXAMPLE_MAKEFILE_FULL
EXAMPLE_MAKEFILE_FULL: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
EXAMPLE_MAKEFILE_FULL:
	@$(HELPOUT2) "$(_H)$(MARKER) HEADERS"
	@$(HELPOUT2) "$(_E)These two statements must be at the top of every file:"
	@$(HELPOUT2) "$(_N)(NOTE: The 'COMPOSER_TEACHER' variable can be modified for custom chaining, but with care.)"
	@$(HELPER) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(HELPER) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) DEFINITIONS"
	@$(HELPOUT2) "$(_E)These statements are also required:"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Use '?=' declarations and define *before* the upstream 'include' statement"
	@$(HELPOUT2) "$(_E)$(INDENTING)* They pass their values *up* the '$(MAKEFILE)' chain"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Should always be defined, even if empty, to prevent downward propagation of values"
	@$(HELPOUT2) "$(_N)(NOTE: List of 'all' targets is '$(COMPOSER_ALL_REGEX)' if '$(~)(COMPOSER_TARGETS)' is empty.)"
	@$(HELPER) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE).$(EXTENSION) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(HELPER) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(HELPER) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) VARIABLES"
	@$(HELPOUT2) "$(_E)The option variables are not required, but are available for locally-scoped configuration:"
	@$(HELPOUT2) "$(_E)$(INDENTING)* For proper inheritance, use '?=' declarations and define *before* the upstream 'include' statement"
	@$(HELPOUT2) "$(_E)$(INDENTING)* They pass their values *down* the '$(MAKEFILE)' chain"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Do not need to be defined when empty, unless necessary to override upstream values"
	@$(HELPOUT2) "$(_E)To disable inheritance and/or insulate from environment variables:"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Replace 'override VAR ?=' with 'override VAR :='"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Define *after* the upstream 'include' statement"
	@$(HELPOUT2) "$(_N)(NOTE: Any settings here will apply to all children, unless 'override' is used downstream.)"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "$(_E)Define the CSS template to use in this entire directory tree:"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Absolute path names should be used, so that children will be able to find it"
	@$(HELPOUT2) "$(_E)$(INDENTING)$(INDENTING)* The 'COMPOSER_ABSPATH' variable can be used to simplify this"
	@$(HELPOUT2) "$(_E)$(INDENTING)* If not defined, the lowest-level '$(COMPOSER_CSS)' file will be used"
	@$(HELPOUT2) "$(_E)$(INDENTING)* If not defined, and no '$(COMPOSER_CSS)' file can be found, will use default CSS file"
	@$(HELPER) "$(~)(eval override $(_C)CSS$(_D) ?= $(_C)$(~)(COMPOSER_ABSPATH)/$(COMPOSER_CSS)$(_D))"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "$(_E)All the other optional variables can also be made global in this directory scope:"
	@$(HELPER) "override $(_C)TTL$(_D) ?="
	@$(HELPER) "override $(_C)TOC$(_D) ?= $(_C)2"
	@$(HELPER) "override $(_C)LVL$(_D) ?= $(_C)$(LVL)"
	@$(HELPER) "override $(_C)OPT$(_D) ?="
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) INCLUDE"
	@$(HELPOUT2) "$(_E)Necessary include statement:"
	@$(HELPOUT2) "$(_N)(NOTE: This must be after all references to 'COMPOSER_ABSPATH' but before '.DEFAULT_GOAL'.)"
	@$(HELPER) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "$(_E)For recursion to work, a default target needs to be defined:"
	@$(HELPOUT2) "$(_E)$(INDENTING)* Needs to be 'all' for directories which must recurse into sub-directories"
	@$(HELPOUT2) "$(_E)$(INDENTING)* The 'subdirs' target can be used manually, if desired, so this can be changed to another value"
	@$(HELPOUT2) "$(_N)(NOTE: Recursion will cease if not 'all', unless 'subdirs' target is called.)"
	@$(HELPER) "$(_C).DEFAULT_GOAL$(_D) := $(_C)all"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) RECURSION"
	@$(HELPOUT2) "$(_E)Dependencies can be specified, if needed:"
	@$(HELPOUT2) "$(_N)(NOTE: This defines the sub-directories which must be built before '$(firstword $(COMPOSER_SUBDIRS))'.)"
	@$(HELPOUT2) "$(_N)(NOTE: For parent/child directory dependencies, set 'COMPOSER_DEPENDS' to a non-empty value.)"
	@$(HELPER) "$(_C)$(firstword $(COMPOSER_SUBDIRS))$(_D): $(_C)$(wordlist 2,$(words $(COMPOSER_SUBDIRS)),$(COMPOSER_SUBDIRS))"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) MAKEFILE"
	@$(HELPOUT2) "$(_E)This is where the rest of the file should be defined."
	@$(HELPOUT2) "$(_N)(NOTE: In this example, 'COMPOSER_TARGETS' is used completely in lieu of any explicit targets.)"
	@echo

.PHONY: EXAMPLE_MAKEFILE_TEMPLATE
EXAMPLE_MAKEFILE_TEMPLATE:
	@$(HELPLVL2)
	@echo
	@$(HELPER) "$(_H)With the current settings, the output of '$(EXAMPLE)' would be:"
	@echo
	@$(RUNMAKE) --silent .$(EXAMPLE)
	@echo

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)Happy Hacking!"
	@$(HELPLVL1)

########################################

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .$(EXAMPLE)

#WORK : document!
.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(HELPOUT2) "$(_H)$(MARKER) HEADERS"
	@$(HELPER) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(HELPER) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) DEFINITIONS"
	@$(HELPER) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(COMPOSER_TARGETS)"
	@$(HELPER) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(HELPER) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) VARIABLES"
	@$(HELPOUT2) "$(_E)$(~)(eval override CSS ?= $(~)(COMPOSER_ABSPATH)/$(COMPOSER_CSS))"
	@$(HELPOUT2) "$(_E)override TTL ?="
	@$(HELPOUT2) "$(_E)override TOC ?="
	@$(HELPOUT2) "$(_E)override LVL ?="
	@$(HELPOUT2) "$(_E)override OPT ?="
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) INCLUDE"
	@$(HELPER) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(HELPER) "$(_C).DEFAULT_GOAL$(_D) := $(_C)all"
	@echo
	@$(HELPOUT2) "$(_H)$(MARKER) MAKEFILE"
	@$(HELPOUT2) "$(_N)(Contents of file go here.)"

override TEST_DIRECTORIES	:= \
	$(TESTOUT_DIR) \
	$(TESTOUT_DIR)/subdir1 \
	$(TESTOUT_DIR)/subdir1/example1 \
	$(TESTOUT_DIR)/subdir2 \
	$(TESTOUT_DIR)/subdir2/example2
override TEST_DIR_CSSDST	:= $(word 4,$(TEST_DIRECTORIES))
override TEST_DIR_DEPEND	:= $(word 2,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_1	:= $(word 3,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_2	:= $(word 5,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_F	:= $(word 1,$(TEST_DIRECTORIES))
override TEST_DEPEND_SUB	:= example1
override TEST_FULLMK_SUB	:= subdir1 subdir2

.PHONY: $(TESTOUT)
$(TESTOUT):
	@$(foreach FILE,$(TEST_DIRECTORIES),\
		$(MKDIR) "$(FILE)"; \
		$(CP) \
			"$(COMPOSER_DIR)/"*.$(COMPOSER_EXT) \
			"$(COMPOSER_DIR)/"*.$(COMPOSER_IMG) \
			"$(FILE)/"; \
	)
	@$(CP) "$(MDVIEWER_CSS)" "$(TEST_DIR_CSSDST)/$(COMPOSER_CSS)"
	@$(RUNMAKE) --directory "$(TESTOUT_DIR)" $(INSTALL)
ifneq ($(COMPOSER_TESTING),0)
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_SUBDIRS="$(TEST_DEPEND_SUB)" COMPOSER_DEPENDS="1" $(EXAMPLE) >"$(TEST_DIR_DEPEND)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= EXAMPLE_MAKEFILE_1 >"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= EXAMPLE_MAKEFILE_2 >"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_TARGETS= COMPOSER_SUBDIRS= $(EXAMPLE) >>"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_TARGETS= COMPOSER_SUBDIRS= $(EXAMPLE) >>"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_SUBDIRS="$(TEST_FULLMK_SUB)" EXAMPLE_MAKEFILE_FULL >"$(TEST_DIR_MAKE_F)/$(MAKEFILE)"
endif
	@$(MKDIR) "$(TESTOUT_DIR)/$(COMPOSER_BASENAME)"
	@$(RUNMAKE) --directory "$(TESTOUT_DIR)/$(COMPOSER_BASENAME)" $(REPLICA)
ifeq ($(COMPOSER_TESTING),2)
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1\$$(COMPOSER_ABSPATH)/$(COMPOSER_BASENAME)/$(MAKEFILE)|g" "$(TESTOUT_DIR)/$(MAKEFILE)"
endif
	@$(MAKE) --directory "$(TESTOUT_DIR)"
ifneq ($(COMPOSER_TESTING),)
	@$(foreach FILE,$(TEST_DIRECTORIES),\
		echo; \
		$(HELPLINE); \
		$(HELPOUT1) "$(_H)$(MARKER) $(_M)$(FILE)/$(MAKEFILE)"; \
		$(HELPLINE); \
		cat "$(FILE)/$(MAKEFILE)"; \
	)
endif

.PHONY: $(INSTALL)
$(INSTALL): install-dir
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1$(COMPOSER)|g" "$(CURDIR)/$(MAKEFILE)"

.PHONY: $(INSTALL)-dir
$(INSTALL)-dir:
	@if [ -f "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(HELPOUT1) "$(_H)$(MARKER) $(_N)Skipping$(_D) $(DIVIDE) $(_E)$(CURDIR)/$(MAKEFILE)"; \
	else \
		$(HELPOUT1) "$(_H)$(MARKER) $(_H)Creating$(_D) $(DIVIDE) $(_M)$(CURDIR)/$(MAKEFILE)"; \
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

#WORK : move up by GIT_* variables?
override REPLICA_GIT	:= $(COMPOSER_STORE)/$(COMPOSER_BASENAME).git
override GIT_REPLICA	:= cd "$(CURDIR)" && $(GIT) --git-dir="$(REPLICA_GIT)"

$(REPLICA)-%:
	@$(RUNMAKE) --silent --directory "$(CURDIR)" \
		COMPOSER_VERSION="$(*)" \
		$(REPLICA)

.PHONY: $(REPLICA)
$(REPLICA):
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(HELPOUT2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(HELPOUT2) "$(_C)COMPOSER_VERSION$(_D)"	"[$(_M)$(COMPOSER_VERSION)$(_D)]"
	@$(HELPOUT2) "$(_C)COMPOSER_FILES$(_D)"		"[$(_M)$(COMPOSER_FILES)$(_D)]"
	@$(HELPLVL1)
	@if [ ! -d "$(REPLICA_GIT)" ]; then \
		$(MKDIR) "$(abspath $(dir $(REPLICA_GIT)))"; \
		$(GIT_REPLICA) init --bare; \
		$(GIT_REPLICA) remote add origin "$(COMPOSER_GITREPO)"; \
	fi
	@$(GIT_REPLICA) remote remove origin
	@$(GIT_REPLICA) remote add origin "$(COMPOSER_GITREPO)"
	@$(GIT_REPLICA) fetch --all
	@$(ECHO) "$(_C)"
	@$(GIT_REPLICA) archive \
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
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(HELPOUT2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HELPLVL1)
	@$(call GIT_REPO,$(MDVIEWER_DST),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
	@$(ECHO) "$(_C)"
	@cd "$(MDVIEWER_DST)" && \
		$(CHMOD) ./build.sh && \
		$(BUILD_ENV) ./build.sh
	@$(ECHO) "$(_D)"
	@$(call GIT_REPO,$(REVEALJS_DST),$(REVEALJS_SRC),$(REVEALJS_CMT))
	@$(call CURL_FILE,$(W3CSLIDY_SRC))
	@$(ECHO) "$(_E)"
	@$(call UNZIP,$(W3CSLIDY_DST),$(W3CSLIDY_SRC))
	@$(ECHO) "$(_D)"

########################################

.PHONY: $(STRAPIT)
$(STRAPIT): $(STRAPIT)-check
ifeq ($(BUILD_PLAT),Msys)
$(STRAPIT): $(STRAPIT)-msys
endif
$(STRAPIT): $(STRAPIT)-config
$(STRAPIT): $(STRAPIT)-libs
$(STRAPIT):
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(STRAPIT)-curl
	$(RUNMAKE) $(STRAPIT)-git
	$(RUNMAKE) $(STRAPIT)-ghc

.PHONY: $(FETCHIT)
$(FETCHIT): $(FETCHIT)-cabal
$(FETCHIT): $(BUILDIT)-clean
$(FETCHIT): $(FETCHIT)-config
$(FETCHIT): $(FETCHIT)-coreutils $(FETCHIT)-bash $(FETCHIT)-less $(FETCHIT)-vim
$(FETCHIT): $(FETCHIT)-make $(FETCHIT)-infozip $(FETCHIT)-curl $(FETCHIT)-git
$(FETCHIT): $(FETCHIT)-tex
$(FETCHIT): $(FETCHIT)-ghc $(FETCHIT)-haskell $(FETCHIT)-pandoc

.PHONY: $(BUILDIT)
$(BUILDIT): $(BUILDIT)-coreutils $(BUILDIT)-bash $(BUILDIT)-less $(BUILDIT)-vim
$(BUILDIT): $(BUILDIT)-make $(BUILDIT)-infozip $(BUILDIT)-curl $(BUILDIT)-git
$(BUILDIT): $(BUILDIT)-tex
$(BUILDIT): $(BUILDIT)-ghc $(BUILDIT)-haskell $(BUILDIT)-pandoc
$(BUILDIT): $(BUILDIT)-clean
$(BUILDIT): $(BUILDIT)-bindir
$(BUILDIT): $(CHECKIT)

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
	$(BUILD_ENV) $(CABAL) update

.PHONY: $(BUILDIT)-clean
$(BUILDIT)-clean:
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
	$(foreach FILE,$(BUILD_BINARY_LIST),\
		$(CP) "$(COMPOSER_ABODE)/bin/$(FILE)"* "$(COMPOSER_PROGS)/usr/bin/"; \
	)
	$(CP) "$(COMPOSER_ABODE)/ca-bundle.crt" "$(COMPOSER_PROGS)/"
	$(CP) "$(COMPOSER_ABODE)/libexec/git-core" "$(COMPOSER_PROGS)/"
	$(MKDIR) "$(COMPOSER_PROGS)/pandoc"
ifeq ($(BUILD_PLAT),Linux)
	$(CP) "$(COMPOSER_ABODE)/share/"*"-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/"* "$(COMPOSER_PROGS)/pandoc/"
else ifeq ($(BUILD_PLAT),Msys)
	$(CP) "$(COMPOSER_ABODE)/"*"-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/"* "$(COMPOSER_PROGS)/pandoc/"
else
	$(CP) "$(COMPOSER_ABODE)/share/"*"-ghc-$(GHC_VERSION)/pandoc-$(PANDOC_VERSION)/"* "$(COMPOSER_PROGS)/pandoc/"
endif
	$(foreach FILE,$(TEXLIVE_DIRECTORY_LIST),\
		$(MKDIR) "$(COMPOSER_PROGS)/texmf-dist/$(FILE)"; \
		$(CP) "$(COMPOSER_ABODE)/texlive/texmf-dist/$(FILE)/"* "$(COMPOSER_PROGS)/texmf-dist/$(FILE)/"; \
	)
	$(MKDIR)								"$(COMPOSER_PROGS)/texmf-dist/web2c"
	$(CP) "$(COMPOSER_ABODE)/texlive/texmf-dist/web2c/texmf.cnf"		"$(COMPOSER_PROGS)/texmf-dist/web2c/"
	$(CP) "$(COMPOSER_ABODE)/texlive/texmf-dist/ls-R"			"$(COMPOSER_PROGS)/texmf-dist/"
	$(MKDIR)								"$(COMPOSER_PROGS)/texmf-var/web2c/pdftex"
	$(CP) "$(COMPOSER_ABODE)/texlive/texmf-var/web2c/pdftex/pdflatex.fmt"	"$(COMPOSER_PROGS)/texmf-var/web2c/pdftex/"
	$(CP) "$(COMPOSER_ABODE)/texlive/bin/pdftex"				"$(COMPOSER_PROGS)/usr/bin/pdflatex"
ifeq ($(BUILD_PLAT),Msys)
	$(MKDIR) "$(COMPOSER_PROGS)/etc"
	$(CP) "$(MSYS_BIN_DST)/etc/"{bash.bashrc,fstab} "$(COMPOSER_PROGS)/etc/"
	$(MKDIR) "$(COMPOSER_PROGS)/usr/share"
	$(CP) "$(MSYS_BIN_DST)/usr/share/"{locale,terminfo} "$(COMPOSER_PROGS)/usr/share/"
	$(foreach FILE,$(WINDOWS_BINARY_LIST),\
		$(CP) "$(MSYS_BIN_DST)/usr/bin/$(FILE).exe" "$(COMPOSER_PROGS)/usr/bin/"; \
	)
#WORK : should only need the two msys-*.dll files
	$(CP) \
		"$(MSYS_BIN_DST)/usr/bin/msys-2.0.dll" \
		"$(MSYS_BIN_DST)/usr/bin/msys-gcc_s-1.dll" \
		"$(COMPOSER_PROGS)/usr/bin/"
#	$(BUILD_ENV) ldd "$(COMPOSER_PROGS)/"{,usr/}bin/*.exe "$(COMPOSER_PROGS)/git-core/"{,*/}* 2>/dev/null | \
#		$(SED) -n "s|^.*(msys[-][^ ]+[.]dll)[ ][=][>].+$$|\1|gp" | \
#		$(SORT) | \
#		while read FILE; do \
#			$(CP) "$(MSYS_BIN_DST)/usr/bin/$${FILE}" "$(COMPOSER_PROGS)/usr/bin/"; \
#		done
	$(call DO_TEXTFILE,$(COMPOSER_PROGS)/msys2_shell.bat,TEXTFILE_MSYS_SHELL)
endif

override define TEXTFILE_MSYS_SHELL =
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

#WORKING : these tools need to be added
#	find
#	patch
#	sed
#	tar

.PHONY: $(CHECKIT)
$(CHECKIT): override PANDOC_VERSIONS := $(PANDOC_CMT) $(_D)($(_E)$(PANDOC_VERSION)$(_D))
$(CHECKIT):
	@$(HELPOUT1) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT1) "$(_H)Project"			"$(COMPOSER_BASENAME) Version"	"Current Version(s)"
	@$(HELPLINE)
ifeq ($(BUILD_PLAT),Msys)
	@$(HELPOUT1) "$(MARKER) $(_E)MSYS2"		"$(_E)$(MSYS_VERSION)"		"$(_N)$(shell $(BUILD_ENV) $(PACMAN) --version		2>/dev/null | $(SED) -n "s|^.*(Pacman[ ]v[^ ]+).*$$|\1|gp")"
endif
	@$(HELPOUT1) "$(MARKER) $(_E)GNU Coreutils"	"$(_E)$(COREUTILS_VERSION)"	"$(_N)$(shell $(BUILD_ENV) ls --version			2>/dev/null | $(SED) -n "s|^ls[ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "$(_C)GNU Bash"			"$(_M)$(BASH_VERSION)"		"$(_D)$(shell $(BUILD_ENV) bash --version		2>/dev/null | $(SED) -n "s|^.*[,][ ]version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Less"			"$(_M)$(LESS_VERSION)"		"$(_D)$(shell $(BUILD_ENV) less --version		2>/dev/null | $(SED) -n "s|^less[ ]([^c][^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Vim"			"$(_M)$(VIM_VERSION)"		"$(_D)$(shell $(BUILD_ENV) vim --version		2>/dev/null | $(SED) -n "s|^.*Vi[ ]IMproved[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "$(_C)GNU Make"			"$(_M)$(MAKE_CMT)"		"$(_D)$(shell $(BUILD_ENV) make --version		2>/dev/null | $(SED) -n "s|^GNU[ ]Make[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Info-ZIP (Zip)"		"$(_M)$(IZIP_VERSION)"		"$(_D)$(shell $(BUILD_ENV) zip --version		2>/dev/null | $(SED) -n "s|^This[ ]is[ ]Zip[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Info-ZIP (UnZip)"		"$(_M)$(UZIP_VERSION)"		"$(_D)$(shell $(BUILD_ENV) unzip --version		2>&1        | $(SED) -n "s|^UnZip[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)cURL"			"$(_M)$(CURL_VERSION)"		"$(_D)$(shell $(BUILD_ENV) curl --version		2>/dev/null | $(SED) -n "s|^curl[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Git SCM"			"$(_M)$(GIT_VERSION)"		"$(_D)$(shell $(BUILD_ENV) git --version		2>/dev/null | $(SED) -n "s|^.*version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "$(_C)Pandoc"			"$(_M)$(PANDOC_VERSIONS)"	"$(_D)$(shell $(BUILD_ENV) pandoc --version		2>/dev/null | $(SED) -n "s|^pandoc([.]exe)?[ ]([^ ]+).*$$|\2|gp")"
	@$(HELPOUT1) "- $(_C)Types"			"$(_M)$(PANDOC_TYPE_CMT)"	"$(_D)$(shell $(BUILD_ENV) cabal info pandoc-types	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)TeXMath"			"$(_M)$(PANDOC_MATH_CMT)"	"$(_D)$(shell $(BUILD_ENV) cabal info texmath		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Highlighting-Kate"		"$(_M)$(PANDOC_HIGH_CMT)"	"$(_D)$(shell $(BUILD_ENV) cabal info highlighting-kate	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)CiteProc"			"$(_M)$(PANDOC_CITE_CMT)"	"$(_D)$(shell $(BUILD_ENV) pandoc-citeproc --version	2>/dev/null | $(SED) -n "s|^pandoc-citeproc[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "$(_C)TeX Live"			"$(_M)$(TEX_VERSION)"		"$(_D)$(shell $(BUILD_ENV) tex --version		2>/dev/null | $(SED) -n "s|^TeX[ ](.+)TeX[ ]Live[ ](.+)$$|\1\2|gp")"
	@$(HELPOUT1) "- $(_C)PDFLaTeX"			"$(_M)$(TEX_PDF_VERSION)"	"$(_D)$(shell $(BUILD_ENV) pdflatex --version		2>/dev/null | $(SED) -n "s|^.*pdfTeX[ ][^-]+[-][^-]+[-]([^ ]+)[ ].*$$|\1|gp")"
	@$(HELPOUT1) "$(_C)Haskell"			"$(_M)$(HASKELL_CMT)"		"$(_D)$(shell $(BUILD_ENV) cabal info haskell-platform	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)GHC"			"$(_M)$(GHC_VERSION)"		"$(_D)$(shell $(BUILD_ENV) ghc --version		2>/dev/null | $(SED) -n "s|^.*version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Cabal"			"$(_M)$(CABAL_VERSION)"		"$(_D)$(shell $(BUILD_ENV) cabal --version		2>/dev/null | $(SED) -n "s|^.*cabal-install[ ]version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- $(_C)Library"			"$(_M)$(CABAL_VERSION_LIB)"	"$(_D)$(shell $(BUILD_ENV) cabal info Cabal		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "$(MARKER)"			"$(_E)GHC Library$(_D):"	"$(_M)$(GHC_VERSION_LIB)"
	@$(HELPLINE)
	@$(HELPOUT1) "$(MARKER) $(_E)GNU Coreutils"	"$(_N)$(shell $(BUILD_ENV) $(WHICH) coreutils		2>/dev/null)"
	@$(HELPOUT1) "$(_C)GNU Bash"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) bash		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Less"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) less		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Vim"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) vim			2>/dev/null)"
	@$(HELPOUT1) "$(_C)GNU Make"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) make		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Info-ZIP (Zip)"		"$(_D)$(shell $(BUILD_ENV) $(WHICH) zip			2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Info-ZIP (UnZip)"		"$(_D)$(shell $(BUILD_ENV) $(WHICH) unzip		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)cURL"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) curl		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Git SCM"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) git			2>/dev/null)"
	@$(HELPOUT1) "$(_C)Pandoc"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) pandoc		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Types"			"$(_E)(no binary to report)"
	@$(HELPOUT1) "- $(_C)TeXMath"			"$(_E)(no binary to report)"
	@$(HELPOUT1) "- $(_C)Highlighting-Kate"		"$(_E)(no binary to report)"
	@$(HELPOUT1) "- $(_C)CiteProc"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) pandoc-citeproc	2>/dev/null)"
	@$(HELPOUT1) "$(_C)TeX Live"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) tex			2>/dev/null)"
	@$(HELPOUT1) "- $(_C)PDFLaTeX"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) pdflatex		2>/dev/null)"
	@$(HELPOUT1) "$(_C)Haskell"			"$(_E)(no binary to report)"
	@$(HELPOUT1) "- $(_C)GHC"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) ghc			2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Cabal"			"$(_D)$(shell $(BUILD_ENV) $(WHICH) cabal		2>/dev/null)"
	@$(HELPOUT1) "- $(_C)Library"			"$(_E)(no binary to report)"
	@$(HELPLINE)
	@$(BUILD_ENV) $(WHICH) coreutils bash less vim make zip unzip curl git pandoc pandoc-citeproc tex pdflatex ghc cabal 2>/dev/null | \
		while read FILE; do \
			ldd $${FILE}; \
		done | \
		$(SED) "s|[(][^)]+[)]||g" | \
		$(SORT)
	@$(HELPLINE)

.PHONY: $(SHELLIT)
$(SHELLIT): $(SHELLIT)-bashrc $(SHELLIT)-vimrc
$(SHELLIT):
	@$(BUILD_ENV) $(BASH) || $(TRUE)

.PHONY: $(SHELLIT)-msys
$(SHELLIT)-msys: $(SHELLIT)-bashrc $(SHELLIT)-vimrc
$(SHELLIT)-msys: export MSYS2_ARG_CONV_EXCL := /grant:r
$(SHELLIT)-msys:
ifneq ($(COMPOSER_PROGS_USE),)
ifneq ($(wildcard $(COMPOSER_PROGS)),)
	@cd "$(COMPOSER_PROGS)" && \
		$(WINDOWS_ACL) ./msys2_shell.bat /grant:r $(USERNAME):f && \
		$(BUILD_ENV) ./msys2_shell.bat
else
	@cd "$(MSYS_BIN_DST)" && \
		$(WINDOWS_ACL) ./msys2_shell.bat /grant:r $(USERNAME):f && \
		$(BUILD_ENV) ./msys2_shell.bat
endif
endif

.PHONY: $(SHELLIT)-bashrc
$(SHELLIT)-bashrc:
	@$(call DO_TEXTFILE,$(COMPOSER_ABODE)/.bash_profile,TEXTFILE_BASH_PROFILE)
	@$(call DO_TEXTFILE,$(COMPOSER_ABODE)/.bashrc,TEXTFILE_BASHRC)
	@if [ ! -f "$(COMPOSER_ABODE)/.bashrc.custom" ]; then \
		$(ECHO) >"$(COMPOSER_ABODE)/.bashrc.custom"; \
	fi

.PHONY: $(SHELLIT)-vimrc
$(SHELLIT)-vimrc:
	@$(call DO_TEXTFILE,$(COMPOSER_ABODE)/.vimrc,TEXTFILE_VIMRC)
	@if [ ! -f "$(COMPOSER_ABODE)/.vimrc.custom" ]; then \
		$(ECHO) >"$(COMPOSER_ABODE)/.vimrc.custom"; \
	fi

override define TEXTFILE_BASH_PROFILE =
source "$(COMPOSER_ABODE)/.bashrc"
endef

override define TEXTFILE_BASHRC =
#!/usr/bin/env bash
umask 022
unalias -a
set -o vi
eval $$(dircolors 2>/dev/null)
#
export LANG="$(LANG)"
export LC_ALL="$${LANG}"
export LC_COLLATE="C"
export LC_ALL=
#
$(MKDIR) "$(COMPOSER_ABODE)/.bash_history"
export HISTFILE="$(COMPOSER_ABODE)/.bash_history/$$(date +%Y-%m)"
export HISTSIZE="$$(( (2**31)-1 ))"
export HISTFILESIZE="$${HISTSIZE}"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S "
export HISTCONTROL=
export HISTIGNORE=
#
export CDPATH=".:$(COMPOSER_DIR):$(COMPOSER_ABODE):$(COMPOSER_STORE):$(COMPOSER_BUILD)"
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
alias .composer="$(subst ",[B]",$(RUNMAKE))"
alias .compose="$(subst ",[B]",$(COMPOSE))"
#
cd "$(COMPOSER_DIR)"
source "$(COMPOSER_ABODE)/.bashrc.custom"
# end of file
endef

override define TEXTFILE_VIMRC =
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
		$(BUILD_ENV) $(3) FORCE_UNSAFE_CONFIGURE="1" ./configure --host="$(CHOST)" --target="$(CHOST)" --prefix="$(2)" $(4) && \
		$(BUILD_ENV) $(3) $(MAKE) $(5) && \
		$(BUILD_ENV) $(3) $(MAKE) install
endef
override define AUTOTOOLS_BUILD_MINGW =
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(3) FORCE_UNSAFE_CONFIGURE="1" ./configure --host="$(CHOST)" --target="$(CHOST)" --prefix="$(2)" $(4) && \
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
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) ERROR:"
	@$(HELPOUT2) "$(_N)Could not find '$(_C)$(CHECK_GHCLIB_DST)$(_N)' library file."
	@$(HELPOUT2)
	@$(HELPOUT2) "$(_H)$(MARKER) DETAILS:"
	@$(HELPOUT2) "The pre-built GHC requires this specific file in order to run, but not necessarily this version of $(CHECK_GHCLIB_NAME)."
	@$(HELPOUT2) "You can likely '$(_M)ln -s$(_D)' one of the files below to something like '$(_M)/usr/lib/$(CHECK_GHCLIB_DST)$(_D)' to work around this."
	@echo
	@$(LS) /{,usr/}lib*/$(CHECK_GHCLIB_SRC)* 2>/dev/null || $(TRUE)
	@echo
	@$(HELPOUT2) "If no files are listed above, you may need to install some version of the $(CHECK_GHCLIB_NAME) library to continue."
	@$(HELPLVL1)
endif
ifneq ($(CHECK_MSYS),)
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) ERROR:"
	@$(HELPOUT2) "$(_N)Must use MSYS2 on Windows systems."
	@$(HELPOUT2)
	@$(HELPOUT2) "$(_H)$(MARKER) DETAILS:"
	@$(HELPOUT2) "This appears to be a Windows system, but the '$(_C)MSYSTEM$(_D)' variable is not set."
	@$(HELPOUT2) "You should run the '$(_M)$(STRAPIT)-msys$(_D)' target to install the MSYS2 environment."
	@$(HELPOUT2) "Then you can run the '$(_M)$(SHELLIT)-msys$(_D)' target to run the MSYS2 environment and try '$(_C)$(STRAPIT)$(_D)' again."
	@$(HELPLVL1)
endif
ifneq ($(CHECK_FAILED),)
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) NOTES:"
	@$(HELPOUT2) "This message was produced by $(_H)$(COMPOSER_FULLNAME)$(_D)."
	@$(HELPOUT2) "If you know the above to be incorrect, you can remove the check from the '$(_C)$(~)(STRAPIT)-check$(_D)' target in:"
	@$(HELPOUT2) "$(INDENTING)$(_M)$(COMPOSER)"
	@$(HELPLVL1)
	@exit 1
endif

.PHONY: $(STRAPIT)-msys
$(STRAPIT)-msys: $(STRAPIT)-msys-bin
$(STRAPIT)-msys: $(STRAPIT)-msys-init
$(STRAPIT)-msys: $(STRAPIT)-msys-fix
$(STRAPIT)-msys: $(STRAPIT)-msys-pkg
$(STRAPIT)-msys: $(STRAPIT)-msys-dll

.PHONY: $(STRAPIT)-msys-bin
$(STRAPIT)-msys-bin:
	$(call CURL_FILE,$(MSYS_BIN_SRC))
	$(call UNTAR,$(MSYS_BIN_DST),$(MSYS_BIN_SRC))

.PHONY: $(STRAPIT)-msys-init
$(STRAPIT)-msys-init:
	@$(HELPLVL1)
	@$(HELPOUT2) "We need to initialize the MSYS2 environment."
	@$(HELPOUT2) "To do this, we will pause here to open an initial shell window."
	@$(HELPOUT2) "Once the shell window gets to a command prompt, simply type '$(_M)exit$(_D)' and hit $(_M)ENTER$(_D) to return."
	@$(HELPOUT2)
	@$(HELPOUT2) "$(_N)Hit $(_C)ENTER$(_N) to proceed."
	@$(HELPLVL1)
	@read -s -n1 ENTER
	@$(RUNMAKE) --silent $(SHELLIT)-msys
	@$(HELPLVL1)
	@$(HELPOUT2) "The shell window has been launched."
	@$(HELPOUT2) "It should have processed to a command prompt, after which you typed '$(_M)exit$(_D)' and hit $(_M)ENTER$(_D)."
	@$(HELPOUT2) "If everything was successful $(_E)(no errors above)$(_D), the build process can continue without interaction."
	@$(HELPOUT2)
	@$(HELPOUT2) "$(_N)Hit $(_C)ENTER$(_N) to proceed, or $(_C)CTRL-C$(_N) to quit."
	@$(HELPLVL1)
	@read -s -n1 ENTER

.PHONY: $(STRAPIT)-msys-fix
# thanks for the 'pacman-key' fix below: http://sourceforge.net/p/msys2/tickets/85/#2e02
$(STRAPIT)-msys-fix:
	$(BUILD_ENV) $(PACMAN) --refresh
	$(BUILD_ENV) $(PACMAN) --needed $(PACMAN_BASE_LIST)
	cd "$(MSYS_BIN_DST)" && \
		$(WINDOWS_ACL) ./autorebase.bat /grant:r $(USERNAME):f && \
		./autorebase.bat
	$(BUILD_ENV) $(PACMAN_DB_UPGRADE)
	$(BUILD_ENV) $(PACMAN_KEY) --init		|| $(TRUE)
	$(BUILD_ENV) $(PACMAN_KEY) --populate msys2	|| $(TRUE)
	$(BUILD_ENV) $(PACMAN_KEY) --refresh-keys	|| $(TRUE)

.PHONY: $(STRAPIT)-msys-pkg
$(STRAPIT)-msys-pkg:
	$(BUILD_ENV) $(PACMAN) \
		--force \
		--needed \
		--sysupgrade \
		$(PACMAN_PACKAGES_LIST)
	$(BUILD_ENV) $(PACMAN) --clean

.PHONY: $(STRAPIT)-msys-dll
$(STRAPIT)-msys-dll:
	$(MKDIR) "$(COMPOSER_ABODE)/bin"
#WORK : should only need the two msys-*.dll files
	$(CP) \
		"$(MSYS_BIN_DST)/usr/bin/msys-2.0.dll" \
		"$(MSYS_BIN_DST)/usr/bin/msys-gcc_s-1.dll" \
		"$(COMPOSER_ABODE)/bin/"
#	$(CP) "$(MSYS_BIN_DST)/usr/bin/"*.dll "$(COMPOSER_ABODE)/bin/"

.PHONY: $(STRAPIT)-libs
#WORKING : causes build errors
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
#WORKING
#ifeq ($(BUILD_PLAT),Linux)
#$(STRAPIT)-libs: $(STRAPIT)-libs-glibc
#endif
$(STRAPIT)-libs: $(STRAPIT)-libs-perl
$(STRAPIT)-libs: $(STRAPIT)-libs-bzip
$(STRAPIT)-libs: $(STRAPIT)-libs-zlib
$(STRAPIT)-libs: $(STRAPIT)-libs-gmp
$(STRAPIT)-libs: $(STRAPIT)-libs-libiconv1
$(STRAPIT)-libs: $(STRAPIT)-libs-gettext
$(STRAPIT)-libs: $(STRAPIT)-libs-libiconv2
$(STRAPIT)-libs: $(STRAPIT)-libs-ncurses
$(STRAPIT)-libs: $(STRAPIT)-libs-openssl
$(STRAPIT)-libs: $(STRAPIT)-libs-expat
$(STRAPIT)-libs: $(STRAPIT)-libs-freetype
$(STRAPIT)-libs: $(STRAPIT)-libs-fontconfig

.PHONY: $(STRAPIT)-libs-glibc
$(STRAPIT)-libs-glibc:
	$(call CURL_FILE,$(LIB_KAPI_TAR_SRC))
	$(call CURL_FILE,$(LIB_LIBC_TAR_SRC))
	$(call UNTAR,$(LIB_KAPI_TAR_DST),$(LIB_KAPI_TAR_SRC))
	$(call UNTAR,$(LIB_LIBC_TAR_DST),$(LIB_LIBC_TAR_SRC))
	cd "$(LIB_KAPI_TAR_DST)" && \
		$(BUILD_ENV) $(MAKE) mrproper && \
		$(BUILD_ENV) $(MAKE) INSTALL_HDR_PATH="$(COMPOSER_ABODE)" headers_install
	$(MKDIR) "$(LIB_LIBC_TAR_DST).build"
	$(ECHO) "\"$(LIB_LIBC_TAR_DST)/configure\" \"\$${@}\"" >"$(LIB_LIBC_TAR_DST).build/configure"
	$(CHMOD) "$(LIB_LIBC_TAR_DST).build/configure"
	$(call AUTOTOOLS_BUILD,$(LIB_LIBC_TAR_DST).build,$(COMPOSER_ABODE),\
		CFLAGS="$(CFLAGS) -O2" \
	)

override define PERL_MODULES_BUILD =
	$(call CURL_FILE,$(2)); \
	$(call UNTAR,$(LIB_PERL_TAR_DST)/$(1),$(2)); \
	cd "$(LIB_PERL_TAR_DST)/$(1)" && \
		$(BUILD_ENV) perl Makefile.PL && \
		$(BUILD_ENV) $(MAKE) && \
		$(BUILD_ENV) $(MAKE) install
endef

.PHONY: $(STRAPIT)-libs-perl
$(STRAPIT)-libs-perl:
	$(call CURL_FILE,$(LIB_PERL_TAR_SRC))
	$(call UNTAR,$(LIB_PERL_TAR_DST),$(LIB_PERL_TAR_SRC))
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" requires some patches
	if [ ! -f "$(LIB_PERL_TAR_DST)/Configure.perl" ]; then \
		$(SED) -i \
			-e "s|[ ][-]Wl[,][-][-]image[-]base[,]0x52000000||g" \
			"$(LIB_PERL_TAR_DST)/Makefile.SH"; \
		$(foreach FILE,$(PERL_PATCH_LIST),\
			$(call DO_PATCH,$(LIB_PERL_TAR_DST)$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
		) \
	fi
	# "$(BUILD_PLAT),Msys" does not have "/proc" filesystem or symlinks
	$(SED) -i \
		-e "s|^(case[ ][\"])[$$]d_readlink|\1NULL|g" \
		"$(LIB_PERL_TAR_DST)/Configure"
	$(SED) -i \
		-e "s|[$$]issymlink|test -f|g" \
		"$(LIB_PERL_TAR_DST)/Makefile.SH"
endif
	# "$(BUILD_PLAT),Msys" is case-insensitive, so 'Configure' is already 'configure'
	if [ ! -f "$(LIB_PERL_TAR_DST)/Configure.perl" ]; then \
		$(MV) "$(LIB_PERL_TAR_DST)/Configure" "$(LIB_PERL_TAR_DST)/Configure.perl"; \
		$(CP) "$(LIB_PERL_TAR_DST)/configure.gnu" "$(LIB_PERL_TAR_DST)/configure"; \
		$(SED) -i \
			-e "s|(Configure)([^.])|\1.perl\2|g" \
			"$(LIB_PERL_TAR_DST)/Configure.perl" \
			"$(LIB_PERL_TAR_DST)/MANIFEST" \
			"$(LIB_PERL_TAR_DST)/configure"; \
	fi
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_PERL_TAR_DST),$(COMPOSER_ABODE))
	$(foreach FILE,$(PERL_MODULES_LIST),\
		$(call PERL_MODULES_BUILD,$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
	)

.PHONY: $(STRAPIT)-libs-bzip
$(STRAPIT)-libs-bzip:
	$(call CURL_FILE,$(LIB_BZIP_TAR_SRC))
	$(call UNTAR,$(LIB_BZIP_TAR_DST),$(LIB_BZIP_TAR_SRC))
	$(ECHO) >"$(LIB_BZIP_TAR_DST)/configure"
	$(CHMOD) "$(LIB_BZIP_TAR_DST)/configure"
	$(call AUTOTOOLS_BUILD,$(LIB_BZIP_TAR_DST),$(COMPOSER_ABODE),\
		PREFIX="$(COMPOSER_ABODE)" \
	)

.PHONY: $(STRAPIT)-libs-zlib
$(STRAPIT)-libs-zlib:
	$(call CURL_FILE,$(LIB_ZLIB_TAR_SRC))
	$(call UNTAR,$(LIB_ZLIB_TAR_DST),$(LIB_ZLIB_TAR_SRC))
ifeq ($(BUILD_BITS),64)
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_ZLIB_TAR_DST),$(COMPOSER_ABODE),,\
		--64 \
		--static \
	)
else
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_ZLIB_TAR_DST),$(COMPOSER_ABODE),,\
		--static \
	)
endif

.PHONY: $(STRAPIT)-libs-gmp
$(STRAPIT)-libs-gmp:
	$(call CURL_FILE,$(LIB_LGMP_TAR_SRC))
	$(call UNTAR,$(LIB_LGMP_TAR_DST),$(LIB_LGMP_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(LIB_LGMP_TAR_DST),$(COMPOSER_ABODE),\
		ABI="$(BUILD_BITS)" \
		,\
		--disable-assembly \
		--disable-shared \
		--enable-static \
	)

override define LIBICONV_BUILD =
	$(call CURL_FILE,$(LIB_ICNV_TAR_SRC))
	# start with fresh source directory, due to circular dependency with gettext
	$(RM) -r "$(LIB_ICNV_TAR_DST)"
	$(call UNTAR,$(LIB_ICNV_TAR_DST),$(LIB_ICNV_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(LIB_ICNV_TAR_DST)/build-aux)
	$(call GNU_CFG_INSTALL,$(LIB_ICNV_TAR_DST)/libcharset/build-aux)
	$(call AUTOTOOLS_BUILD,$(LIB_ICNV_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
endef

.PHONY: $(STRAPIT)-libs-libiconv1
$(STRAPIT)-libs-libiconv1:
	$(call LIBICONV_BUILD)

.PHONY: $(STRAPIT)-libs-gettext
$(STRAPIT)-libs-gettext:
	$(call CURL_FILE,$(LIB_GTXT_TAR_SRC))
	$(call UNTAR,$(LIB_GTXT_TAR_DST),$(LIB_GTXT_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(LIB_GTXT_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-libs-libiconv2
$(STRAPIT)-libs-libiconv2:
	$(call LIBICONV_BUILD)

.PHONY: $(STRAPIT)-libs-ncurses
$(STRAPIT)-libs-ncurses:
	$(call CURL_FILE,$(LIB_NCRS_TAR_SRC))
	$(call UNTAR,$(LIB_NCRS_TAR_DST),$(LIB_NCRS_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(LIB_NCRS_TAR_DST))
	$(call AUTOTOOLS_BUILD,$(LIB_NCRS_TAR_DST),$(COMPOSER_ABODE),,\
		--without-shared \
	)

.PHONY: $(STRAPIT)-libs-openssl
# thanks for the 'static' fix below: http://www.openwall.com/lists/musl/2014/11/06/17
$(STRAPIT)-libs-openssl:
	$(call CURL_FILE,$(LIB_OSSL_TAR_SRC))
	$(call UNTAR,$(LIB_OSSL_TAR_DST),$(LIB_OSSL_TAR_SRC))
ifeq ($(BUILD_PLAT),Linux)
ifneq ($(BUILD_DIST),)
	$(CP) "$(LIB_OSSL_TAR_DST)/Configure" "$(LIB_OSSL_TAR_DST)/configure"
else
	$(CP) "$(LIB_OSSL_TAR_DST)/config" "$(LIB_OSSL_TAR_DST)/configure"
endif
else ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" is case-insensitive, so 'Configure' is already 'configure'
else
	$(CP) "$(LIB_OSSL_TAR_DST)/config" "$(LIB_OSSL_TAR_DST)/configure"
endif
	$(SED) -i \
		-e "s|(TERMIO)([^S])|\1S\2|g" \
		-e "s|(termio)([^s])|\1s\2|g" \
		"$(LIB_OSSL_TAR_DST)/configure" \
		"$(LIB_OSSL_TAR_DST)/crypto/ui/ui_openssl.c"
ifeq ($(BUILD_PLAT),Linux)
ifneq ($(BUILD_DIST),)
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_OSSL_TAR_DST),$(COMPOSER_ABODE),,\
		linux-generic$(BUILD_BITS) \
		no-shared \
		no-dso \
	)
else
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_OSSL_TAR_DST),$(COMPOSER_ABODE),,\
		no-shared \
		no-dso \
	)
endif
else ifeq ($(BUILD_PLAT),Msys)
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_OSSL_TAR_DST),$(COMPOSER_ABODE),,\
		linux-generic$(BUILD_BITS) \
		no-shared \
		no-dso \
	)
else
	$(call AUTOTOOLS_BUILD_NOTARGET,$(LIB_OSSL_TAR_DST),$(COMPOSER_ABODE),,\
		no-shared \
		no-dso \
	)
endif

.PHONY: $(STRAPIT)-libs-expat
$(STRAPIT)-libs-expat:
	$(call CURL_FILE,$(LIB_EXPT_TAR_SRC))
	$(call UNTAR,$(LIB_EXPT_TAR_DST),$(LIB_EXPT_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(LIB_EXPT_TAR_DST)/conftools)
	$(call AUTOTOOLS_BUILD,$(LIB_EXPT_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-libs-freetype
$(STRAPIT)-libs-freetype:
	$(call CURL_FILE,$(LIB_FTYP_TAR_SRC))
	$(call UNTAR,$(LIB_FTYP_TAR_DST),$(LIB_FTYP_TAR_SRC))
	$(call AUTOTOOLS_BUILD,$(LIB_FTYP_TAR_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)

.PHONY: $(STRAPIT)-libs-fontconfig
$(STRAPIT)-libs-fontconfig:
	$(call CURL_FILE,$(LIB_FCFG_TAR_SRC))
	$(call UNTAR,$(LIB_FCFG_TAR_DST),$(LIB_FCFG_TAR_SRC))
	# "$(BUILD_PLAT),Msys" requires "expat" options in order to find it
	$(call AUTOTOOLS_BUILD,$(LIB_FCFG_TAR_DST),$(COMPOSER_ABODE),\
		FREETYPE_CFLAGS="$(CFLAGS) -I$(COMPOSER_ABODE)/include/freetype2" \
		FREETYPE_LIBS="-lfreetype" \
		,\
		--enable-iconv \
		--with-libiconv-includes="$(COMPOSER_ABODE)/include" \
		--with-libiconv-lib="$(COMPOSER_ABODE)/lib" \
		--with-expat-includes="$(COMPOSER_ABODE)/include" \
		--with-expat-lib="$(COMPOSER_ABODE)/lib" \
		--disable-shared \
		--enable-static \
	)

.PHONY: $(FETCHIT)-coreutils
$(FETCHIT)-coreutils: $(FETCHIT)-coreutils-pull
$(FETCHIT)-coreutils: $(FETCHIT)-coreutils-prep

.PHONY: $(FETCHIT)-coreutils-pull
$(FETCHIT)-coreutils-pull:
	$(call CURL_FILE,$(COREUTILS_TAR_SRC))
	$(call UNTAR,$(COREUTILS_TAR_DST),$(COREUTILS_TAR_SRC))

.PHONY: $(FETCHIT)-coreutils-prep
$(FETCHIT)-coreutils-prep:

.PHONY: $(BUILDIT)-coreutils
$(BUILDIT)-coreutils:
	$(call AUTOTOOLS_BUILD,$(COREUTILS_TAR_DST),$(COMPOSER_ABODE),,\
		--enable-single-binary="shebangs" \
		--disable-acl \
		--disable-xattr \
	)

.PHONY: $(FETCHIT)-bash
$(FETCHIT)-bash: $(FETCHIT)-bash-pull
$(FETCHIT)-bash: $(FETCHIT)-bash-prep

.PHONY: $(FETCHIT)-bash-pull
$(FETCHIT)-bash-pull:
	$(call CURL_FILE,$(BASH_TAR_SRC))
	# "$(BUILD_PLAT),Msys" does not support symlinks, so we have to exclude some files
	$(call UNTAR,$(BASH_TAR_DST),$(BASH_TAR_SRC),$(notdir $(BASH_TAR_DST))/ChangeLog)

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
	$(call UNTAR,$(LESS_TAR_DST),$(LESS_TAR_SRC))

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
	$(call UNTAR,$(VIM_TAR_DST),$(VIM_TAR_SRC))

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
		$(BUILD_ENV) autoreconf --force --install && \
		$(BUILD_ENV) ./configure && \
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
	$(call CURL_FILE,$(LIB_BZIP_TAR_SRC))
	$(call UNTAR,$(IZIP_TAR_DST),$(IZIP_TAR_SRC))
	$(call UNTAR,$(UZIP_TAR_DST),$(UZIP_TAR_SRC))
	$(call UNTAR,$(LIB_BZIP_TAR_DST),$(LIB_BZIP_TAR_SRC))
	$(MKDIR) \
		"$(IZIP_TAR_DST)/bzip2" \
		"$(UZIP_TAR_DST)/bzip2"
	$(CP) "$(LIB_BZIP_TAR_DST)/"* "$(IZIP_TAR_DST)/bzip2/"
	$(CP) "$(LIB_BZIP_TAR_DST)/"* "$(UZIP_TAR_DST)/bzip2/"

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
	$(call UNTAR,$(CURL_TAR_DST),$(CURL_TAR_SRC))

.PHONY: $(FETCHIT)-curl-pull
$(FETCHIT)-curl-pull:
	$(call GIT_REPO,$(CURL_DST),$(CURL_SRC),$(CURL_CMT))

#WORK : archive certdata.txt in $COMPOSER_STORE

.PHONY: $(STRAPIT)-curl-prep
# thanks for the 'CURL_CA_BUNDLE' fix below: http://www.curl.haxx.se/mail/lib-2006-11/0276.html
#	also to: http://comments.gmane.org/gmane.comp.web.curl.library/29555
$(STRAPIT)-curl-prep:
	$(SED) -i \
		-e "s|(out[ ][=][ ].)(curl[ ][-]w)|\1CURL_CA_BUNDLE=\"\$${ENV{\"CURL_CA_BUNDLE\"}}\" \2|g" \
		"$(CURL_TAR_DST)/lib/mk-ca-bundle.pl"
	$(SED) -i \
		-e "s|^([#]define[ ]CURL_CA_BUNDLE[ ]).*$$|\1getenv(\"CURL_CA_BUNDLE\")|g" \
		"$(CURL_TAR_DST)/configure"

.PHONY: $(FETCHIT)-curl-prep
# thanks for the 'CURL_CA_BUNDLE' fix below: http://www.curl.haxx.se/mail/lib-2006-11/0276.html
#	also to: http://comments.gmane.org/gmane.comp.web.curl.library/29555
$(FETCHIT)-curl-prep:
	cd "$(CURL_DST)" && \
		$(BUILD_ENV) autoreconf --force --install && \
		$(BUILD_ENV) ./configure
	$(SED) -i \
		-e "s|(out[ ][=][ ].)(curl[ ][-]w)|\1CURL_CA_BUNDLE=\"\$${ENV{\"CURL_CA_BUNDLE\"}}\" \2|g" \
		"$(CURL_DST)/lib/mk-ca-bundle.pl"
	$(SED) -i \
		-e "s|^([#]define[ ]CURL_CA_BUNDLE[ ]).*$$|\1getenv(\"CURL_CA_BUNDLE\")|g" \
		"$(CURL_DST)/configure"

.PHONY: $(STRAPIT)-curl-build
$(STRAPIT)-curl-build:
	cd "$(CURL_TAR_DST)" && \
		$(BUILD_ENV) $(MAKE) CURL_CA_BUNDLE="$(CURL_CA_BUNDLE)" ca-bundle && \
		$(CP) "$(CURL_TAR_DST)/lib/ca-bundle.crt" "$(COMPOSER_ABODE)/"
	$(call AUTOTOOLS_BUILD,$(CURL_TAR_DST),$(COMPOSER_ABODE),,\
		--with-ca-bundle="./ca-bundle.crt" \
		--without-libidn \
		--disable-shared \
		--enable-static \
	)

.PHONY: $(BUILDIT)-curl
$(BUILDIT)-curl:
	cd "$(CURL_DST)" && \
		$(BUILD_ENV) $(MAKE) CURL_CA_BUNDLE="$(CURL_CA_BUNDLE)" ca-bundle && \
		$(CP) "$(CURL_DST)/lib/ca-bundle.crt" "$(COMPOSER_ABODE)/"
	$(call AUTOTOOLS_BUILD,$(CURL_DST),$(COMPOSER_ABODE),,\
		--with-ca-bundle="./ca-bundle.crt" \
		--without-libidn \
		--disable-shared \
		--enable-static \
	)

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
	$(call UNTAR,$(GIT_TAR_DST),$(GIT_TAR_SRC))

.PHONY: $(FETCHIT)-git-pull
$(FETCHIT)-git-pull:
	$(call GIT_REPO,$(GIT_DST),$(GIT_SRC),$(GIT_CMT))

.PHONY: $(STRAPIT)-git-prep
# thanks for the 'curl' fix below: http://www.curl.haxx.se/mail/lib-2007-05/0155.html
#	also to: http://www.makelinux.net/alp/021
# thanks for the 'librt' fix below: https://stackoverflow.com/questions/2418157/ubuntu-linux-c-error-undefined-reference-to-clock-gettime-and-clock-settim
$(STRAPIT)-git-prep:
	cd "$(GIT_TAR_DST)" && \
		$(BUILD_ENV) $(MAKE) configure
	$(SED) -i \
		-e "s|([-]lcurl)(.[^-])|\1 -lssl -lcrypto -lz -lrt\2|g" \
		"$(GIT_TAR_DST)/configure"
	$(SED) -i \
		-e "s|([-]lcurl)$$|\1 -lssl -lcrypto -lz -lrt|g" \
		"$(GIT_TAR_DST)/Makefile"

.PHONY: $(FETCHIT)-git-prep
# thanks for the 'curl' fix below: http://www.curl.haxx.se/mail/lib-2007-05/0155.html
#	also to: http://www.makelinux.net/alp/021
# thanks for the 'librt' fix below: https://stackoverflow.com/questions/2418157/ubuntu-linux-c-error-undefined-reference-to-clock-gettime-and-clock-settim
$(FETCHIT)-git-prep:
	cd "$(GIT_DST)" && \
		$(BUILD_ENV) $(MAKE) configure
	$(SED) -i \
		-e "s|([-]lcurl)(.[^-])|\1 -lssl -lcrypto -lz -lrt\2|g" \
		"$(GIT_DST)/configure"
	$(SED) -i \
		-e "s|([-]lcurl)$$|\1 -lssl -lcrypto -lz -lrt|g" \
		"$(GIT_DST)/Makefile"

.PHONY: $(STRAPIT)-git-build
$(STRAPIT)-git-build:
	$(call AUTOTOOLS_BUILD,$(GIT_TAR_DST),$(COMPOSER_ABODE),,\
		--without-tcltk \
	)

.PHONY: $(BUILDIT)-git
$(BUILDIT)-git:
	$(call AUTOTOOLS_BUILD,$(GIT_DST),$(COMPOSER_ABODE),,\
		--without-tcltk \
	)

.PHONY: $(FETCHIT)-tex
$(FETCHIT)-tex: $(FETCHIT)-tex-pull
$(FETCHIT)-tex: $(FETCHIT)-tex-prep

.PHONY: $(FETCHIT)-tex-pull
$(FETCHIT)-tex-pull:
	$(call CURL_FILE,$(TEX_TEXMF_SRC))
	$(call CURL_FILE,$(TEX_TAR_SRC))
	$(call UNTAR,$(TEX_TEXMF_DST),$(TEX_TEXMF_SRC))
	$(call UNTAR,$(TEX_TAR_DST),$(TEX_TAR_SRC))
ifeq ($(BUILD_PLAT),Msys)
	$(call CURL_FILE,$(TEX_WINDOWS_SRC))
	$(call UNTAR,$(TEX_WINDOWS_DST),$(TEX_WINDOWS_SRC))
endif

.PHONY: $(FETCHIT)-tex-prep
$(FETCHIT)-tex-prep:
	$(SED) -i \
		-e "s|[-]lfontconfig(.)$$|-lfontconfig -lfreetype -lexpat -liconv -lz\1|g" \
		"$(TEX_TAR_DST)/texk/web2c/configure"
#ifeq ($(BUILD_PLAT),Msys)
#	$(CP) \
#		"$(TEX_TAR_DST)/libs/icu/icu-"*"/source/config/mh-linux" \
#		"$(TEX_TAR_DST)/libs/icu/icu-"*"/source/config/mh-unknown"
#WORK this was needed for mingw?
#	$(SED) -i \
#		-e "s|([^Y])(INPUT)|\1MY\2|g" \
#		"$(TEX_TAR_DST)/texk/web2c/otps/otp-"*
#>	$(CP) "$(TEX_WINDOWS_DST)/"* "$(TEX_TAR_DST)/"
#WORK thanks for the 'header' fix below: https://build.opensuse.org/package/view_file?project=windows%3Amingw%3Awin32&package=mingw32-texlive&file=texlive-20110705-source-header.patch&rev=048df827a351be452769105398cad811
#	$(SED) -i \
#		-e "s|^([#]define header)|#undef header\n\1|g" \
#		"$(TEX_TAR_DST)/texk/cjkutils/hbf2gf.c"
#endif

.PHONY: $(BUILDIT)-tex
$(BUILDIT)-tex:
	cd "$(TEX_TAR_DST)" && $(BUILD_ENV) TL_INSTALL_DEST="$(COMPOSER_ABODE)/texlive" \
		CFLAGS="-L$(TEX_TAR_DST)/Work/libs/freetype2 $(CFLAGS)" \
		./Build \
		--with-fontconfig-includes="$(COMPOSER_ABODE)/include/fontconfig" \
		--disable-multiplatform \
		--without-ln-s \
		--without-x \
		--disable-shared \
		--enable-static
#>	$(call AUTOTOOLS_BUILD,$(TEX_TAR_DST),$(COMPOSER_ABODE)/texlive,\
#>		CFLAGS="-L$(TEX_TAR_DST)/Work/libs/freetype2 $(CFLAGS)" \
#>		,\
#>		--enable-build-in-source-tree \
#>		--with-fontconfig-includes="$(COMPOSER_ABODE)/include/fontconfig" \
#>		--disable-multiplatform \
#>		--without-ln-s \
#>		--without-x \
#>		--disable-shared \
#>		--enable-static \
#>	)
	$(CP) "$(TEX_TEXMF_DST)/"* "$(COMPOSER_ABODE)/texlive/"
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-tex-fmt

.PHONY: $(BUILDIT)-tex-fmt
$(BUILDIT)-tex-fmt:
	$(BUILD_ENV) fmtutil --all

.PHONY: $(STRAPIT)-ghc
$(STRAPIT)-ghc: $(STRAPIT)-ghc-pull
$(STRAPIT)-ghc: $(STRAPIT)-ghc-prep
$(STRAPIT)-ghc: $(STRAPIT)-ghc-build

.PHONY: $(FETCHIT)-ghc
$(FETCHIT)-ghc: $(FETCHIT)-ghc-pull
$(FETCHIT)-ghc: $(FETCHIT)-ghc-prep

.PHONY: $(STRAPIT)-ghc-pull
$(STRAPIT)-ghc-pull:
	$(call CURL_FILE,$(GHC_BIN_SRC))
	$(call CURL_FILE,$(CBL_TAR_SRC))
	$(call UNTAR,$(GHC_BIN_DST),$(GHC_BIN_SRC))
	$(call UNTAR,$(CBL_TAR_DST),$(CBL_TAR_SRC))

.PHONY: $(FETCHIT)-ghc-pull
$(FETCHIT)-ghc-pull:
	$(call GIT_REPO,$(GHC_DST),$(GHC_SRC),$(GHC_CMT),$(GHC_BRANCH))
	# pre-process "sync-all" repositories, in case source already lives in "$(COMPOSER_STORE)"
	$(call GIT_SUBMODULE_GHC,$(GHC_DST))
	$(SED) -i \
		-e "s|^([.][ ]+[-][ ]+ghc[.]git)|#\1|g" \
		"$(GHC_DST)/packages"
	$(SED) -i \
		-e "s|[-]d([ ][^ ]+[.]git)|-f\1|g" \
		"$(GHC_DST)/sync-all"
	cd "$(GHC_DST)" && \
		$(BUILD_ENV_MINGW) ./sync-all get && \
		$(BUILD_ENV_MINGW) ./sync-all fetch --all && \
		$(BUILD_ENV_MINGW) ./sync-all checkout --force -B $(GHC_BRANCH) $(GHC_CMT) && \
		$(BUILD_ENV_MINGW) ./sync-all reset --hard
	# post-process "sync-all" repositories, to ensure source lives in "$(COMPOSER_STORE)"
	$(call GIT_SUBMODULE_GHC,$(GHC_DST))

.PHONY: $(STRAPIT)-ghc-prep
# thanks for the 'getnameinfo' fix below: https://www.mail-archive.com/haskell-cafe@haskell.org/msg60731.html
# thanks for the 'createDirectory' fix below: https://github.com/haskell/cabal/issues/1698
$(STRAPIT)-ghc-prep:
ifeq ($(BUILD_PLAT),Msys)
	$(call DO_TEXTFILE,$(CBL_TAR_DST)/bootstrap.patch.sh,TEXTFILE_CABAL_BOOTSTRAP)
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

override define TEXTFILE_CABAL_BOOTSTRAP =
#!/usr/bin/env bash
[ -f "$(CBL_TAR_DST)/network-"*"/include/HsNet.h" ] && $(SED) -i [B]
	-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" [B]
	-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" [B]
	-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" [B]
	"$(CBL_TAR_DST)/network-"*"/include/HsNet.h"
exit 0
endef

.PHONY: $(FETCHIT)-ghc-prep
# thanks for the 'removeFiles' fix below: https://ghc.haskell.org/trac/ghc/ticket/7712
$(FETCHIT)-ghc-prep:
	cd "$(GHC_DST)" && \
		$(BUILD_ENV_MINGW) ./boot
#WORKING
#ifeq ($(BUILD_PLAT),Msys)
#	$(foreach FILE,\
#		$(GHC_DST)/driver/ghci/ghc.mk \
#		$(GHC_DST)/ghc/ghc.mk \
#		,\
#		$(SED) -i \
#			-e "s|(call[ ]removeFiles[,])(..GHCII_SCRIPT.)|\1\"\2\"|g" \
#			-e "s|(call[ ]removeFiles[,])(..DESTDIR...bindir.[/]ghc.exe)|\1\"\2\"|g" \
#			"$(FILE)"; \
#	)
#	$(SED) -i \
#		-e "s|^([#]include[ ].)(gmp[.]h.)$$|\1../gmp/\2|g" \
#		"$(GHC_DST)/libraries/integer-gmp/cbits/alloc.c" \
#		"$(GHC_DST)/libraries/integer-gmp/cbits/float.c"
#endif
#WORKING
#>	$(foreach FILE,\
#>		$(GHC_DST)/libraries/Cabal/Cabal/Cabal.cabal \
#>		$(GHC_DST)/libraries/Cabal/Cabal/Makefile \
#>		\
#>		$(GHC_DST)/libraries/Cabal/cabal-install/cabal-install.cabal \
#>		$(GHC_DST)/libraries/bin-package-db/bin-package-db.cabal \
#>		$(GHC_DST)/utils/ghc-cabal/ghc-cabal.cabal \
#>		,\
#>		$(SED) -i \
#>			-e "s|$(GHC_VERSION_LIB)|$(CABAL_VERSION_LIB)|g" \
#>			\
#>			-e "s|([ ]+Cabal[ ]+)[>][=][^,]+|\1==$(CABAL_VERSION_LIB)|g" \
#>			"$(FILE)"; \
#>	)

#WORK
# https://ghc.haskell.org/trac/ghc/wiki/Building/Architecture
# https://ghc.haskell.org/trac/ghc/wiki/Building/Modifying
# https://ghc.haskell.org/trac/ghc/wiki/Building/Shake
# https://ghc.haskell.org/trac/ghc/wiki/CrossCompilation
# https://downloads.haskell.org/~ghc/7.6.3/docs/html/users_guide/options-phases.html
#WORK

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
			./bootstrap.sh --global
	$(RUNMAKE) $(FETCHIT)-cabal
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(BUILD_STRAP)) \
		$(subst |,-,$(GHC_LIBRARIES_LIST))

.PHONY: $(BUILDIT)-ghc
$(BUILDIT)-ghc:
ifeq ($(BUILD_PLAT),Msys)
	$(ECHO) "WORK : move this to 'prep' if it works...\n"
#	$(SED) -i \
#		-e "s|(cygpath[ ])[-][-]mixed|\1--unix|g" \
#		-e "s|(cygpath[ ])[-]m|\1--unix|g" \
#		"$(GHC_DST)/aclocal.m4" \
#		"$(GHC_DST)/configure"
	$(call AUTOTOOLS_BUILD_MINGW,$(GHC_DST),$(COMPOSER_ABODE))
	$(ECHO) "WORKING\n"; $(RM) -r "$(BUILD_STRAP)/mingw"*
else
	$(call AUTOTOOLS_BUILD_MINGW,$(GHC_DST),$(COMPOSER_ABODE))
endif
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
		$(foreach FILE,$(HASKELL_UPGRADE_LIST),\
			-e "s|([ ]+$(word 1,$(subst |, ,$(FILE)))[ ]+[=][=])([^,]+)|\1$(word 2,$(subst |, ,$(FILE)))|g" \
		) \
		"$(HASKELL_DST)/haskell-platform.cabal"
	$(SED) -i \
		-e "s|^(for[ ]pkg[ ]in[ ][$$][{]SRC_PKGS[}])$$|\1 $(subst |,-,$(HASKELL_UPGRADE_LIST))|g" \
		"$(HASKELL_DST)/src/generic/prepare.sh"
	cd "$(HASKELL_DST)/src/generic" && \
		$(BUILD_ENV_MINGW) ./prepare.sh
	$(foreach FILE,$(HASKELL_PATCH_LIST),\
		$(call DO_PATCH,$(HASKELL_TAR)$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
	)

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
	$(ECHO) "WORK\n"
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
#	$(call GNU_CFG_INSTALL,$(HASKELL_TAR)/scripts)
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
	$(call AUTOTOOLS_BUILD_MINGW,$(HASKELL_TAR),$(COMPOSER_ABODE),,\
		--disable-user-install \
	)
#>	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(COMPOSER_ABODE)) \
#>		$(foreach FILE,$(shell cat "$(HASKELL_TAR)/packages/platform.packages"),\
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
#WORKING
#	$(SED) -i \
#		$(foreach FILE,$(PANDOC_UPGRADE_LIST),\
#			-e "s|([ ]+$(word 1,$(subst |, ,$(FILE))))[ ]+([^,]+)|\1 == $(word 2,$(subst |, ,$(FILE)))|g" \
#		) \
#		"$(PANDOC_DST)/pandoc.cabal"
#WORKING
	# make sure GHC looks for libraries in the right place
	$(SED) -i \
		-e "s|(Ghc[-]Options[:][ ]+)([-]rtsopts)|\1-optc-L$(COMPOSER_ABODE)/lib -optl-L$(COMPOSER_ABODE)/lib \2|g" \
		-e "s|(ghc[-]options[:][ ]+)([-]funbox[-]strict[-]fields)|\1-optc-L$(COMPOSER_ABODE)/lib -optl-L$(COMPOSER_ABODE)/lib \2|g" \
		"$(PANDOC_CITE_DST)/pandoc-citeproc.cabal" \
		"$(PANDOC_DST)/pandoc.cabal"

.PHONY: $(BUILDIT)-pandoc-deps
$(BUILDIT)-pandoc-deps:
	$(HELPER) "\n$(_H)$(MARKER) Dependencies"
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

#WORKING			--flags="make-pandoc-man-pages embed_data_files network-uri https" \

override define PANDOC_BUILD =
	cd "$(1)" && \
		$(HELPER) "\n$(_H)$(MARKER) Configure$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(CABAL) configure \
			--prefix="$(COMPOSER_ABODE)" \
			--flags="make-pandoc-man-pages embed_data_files" \
			--enable-tests
	cd "$(1)" && \
		$(HELPER) "\n$(_H)$(MARKER) Build$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(CABAL) build;
	cd "$(1)" && \
		$(HELPER) "\n$(_H)$(MARKER) Test$(_D) $(DIVIDE) $(_M)$(1)" && \
		$(BUILD_ENV_MINGW) $(CABAL) test || $(TRUE);
	cd "$(1)" && \
		$(HELPER) "\n$(_H)$(MARKER) Install$(_D) $(DIVIDE) $(_M)$(1)" && \
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
	@echo
	@$(BUILD_ENV) pandoc --version

########################################

.PHONY: targets
targets:
	@$(HELPOUT1) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT1) "$(_H)Targets$(_D) $(DIVIDE) $(_M)$(COMPOSER_SRC)"
	@$(HELPLINE)
	@$(ECHO) "$(_C)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .all_targets | $(SED) \
		$(foreach FILE,$(.ALL_TARGETS),\
			-e "/^$(FILE)/d" \
		) \
		-e "/^[^:]*[.]$(COMPOSER_EXT)[:]/d" \
		-e "/^$$/d"
	@$(HELPLINE)
	@$(HELPOUT1) "$(_H)$(MARKER) all";	$(ECHO) "$(COMPOSER_TARGETS)"				| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(HELPOUT1) "$(_H)$(MARKER) clean";	$(ECHO) "$(addsuffix -clean,$(COMPOSER_TARGETS))"	| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(HELPOUT1) "$(_H)$(MARKER) subdirs";	$(ECHO) "$(COMPOSER_SUBDIRS)"				| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(HELPLINE)

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
all: \
	$(BASE).$(TYPE_HTML) \
	$(BASE).$(TYPE_LPDF) \
	$(BASE).$(PRES_EXTN) \
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
	@$(HELPLVL1)
	@$(HELPOUT2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(HELPOUT2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(HELPOUT2) "$(_C)COMPOSER_TARGETS$(_D)"	"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(HELPOUT2) "$(_C)COMPOSER_SUBDIRS$(_D)"	"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(HELPOUT2) "$(_C)COMPOSER_DEPENDS$(_D)"	"[$(_M)$(COMPOSER_DEPENDS)$(_D)]"
	@$(HELPLVL2)
	@$(HELPOUT2) "$(_C)TYPE$(_D)"	"[$(_M)$(TYPE)$(_D)]"
	@$(HELPOUT2) "$(_C)BASE$(_D)"	"[$(_M)$(BASE)$(_D)]"
	@$(HELPOUT2) "$(_C)LIST$(_D)"	"[$(_M)$(LIST)$(_D)]"
	@$(HELPOUT2) "$(_C)_CSS$(_D)"	"[$(_M)$(_CSS)$(_D)]"
	@$(HELPOUT2) "$(_C)CSS$(_D)"	"[$(_M)$(CSS)$(_D)]"
	@$(HELPOUT2) "$(_C)TTL$(_D)"	"[$(_M)$(TTL)$(_D)]"
	@$(HELPOUT2) "$(_C)TOC$(_D)"	"[$(_M)$(TOC)$(_D)]"
	@$(HELPOUT2) "$(_C)LVL$(_D)"	"[$(_M)$(LVL)$(_D)]"
	@$(HELPOUT2) "$(_C)OPT$(_D)"	"[$(_M)$(OPT)$(_D)]"
	@$(HELPLVL1)

.PHONY: settings
settings:
	@$(HELPLVL2)
	@$(HELPOUT2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(HELPOUT2) "$(_E)MAKEFILE_LIST$(_D)  [$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(HELPOUT2) "$(_E)CURDIR$(_D)         [$(_N)$(CURDIR)$(_D)]"
	@$(HELPLVL2)
	@$(HELPOUT2) "$(_C)TYPE$(_D)           [$(_M)$(TYPE)$(_D)]"
	@$(HELPOUT2) "$(_C)BASE$(_D)           [$(_M)$(BASE)$(_D)]"
	@$(HELPOUT2) "$(_C)LIST$(_D)           [$(_M)$(LIST)$(_D)]"
	@$(HELPOUT2) "$(_C)_CSS$(_D)           [$(_M)$(_CSS)$(_D)]"
	@$(HELPOUT2) "$(_C)CSS$(_D)            [$(_M)$(CSS)$(_D)]"
	@$(HELPOUT2) "$(_C)TTL$(_D)            [$(_M)$(TTL)$(_D)]"
	@$(HELPOUT2) "$(_C)TOC$(_D)            [$(_M)$(TOC)$(_D)]"
	@$(HELPOUT2) "$(_C)LVL$(_D)            [$(_M)$(LVL)$(_D)]"
	@$(HELPOUT2) "$(_C)OPT$(_D)            [$(_M)$(OPT)$(_D)]"
	@$(HELPLVL2)

.PHONY: setup
setup:
ifeq ($(TYPE),$(TYPE_DOCX))
ifneq ($(PANDOC_DATA),)
ifneq ($(PANDOC_DATA_BUILD),)
	@$(MKDIR) "$(PANDOC_DATA_BUILD)"
	@$(CP) "$(PANDOC_DATA)/reference.docx" "$(PANDOC_DATA_BUILD)/"
endif
endif
endif

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

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(LIST) settings setup
	$(BUILD_ENV) $(PANDOC)
	@$(TOUCH) "$(CURDIR)/$(COMPOSER_STAMP)"

$(BASE).$(EXTENSION): $(LIST)
	$(MAKEDOC) TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(LIST)"

%.$(TYPE_HTML): %.$(COMPOSER_EXT)
	$(MAKEDOC) TYPE="$(TYPE_HTML)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_LPDF): %.$(COMPOSER_EXT)
	$(MAKEDOC) TYPE="$(TYPE_LPDF)" BASE="$(*)" LIST="$(^)"

%.$(PRES_EXTN): %.$(COMPOSER_EXT)
	$(MAKEDOC) TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"

%.$(SHOW_EXTN): %.$(COMPOSER_EXT)
	$(MAKEDOC) TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_DOCX): %.$(COMPOSER_EXT)
	$(MAKEDOC) TYPE="$(TYPE_DOCX)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_EPUB): %.$(COMPOSER_EXT)
	$(MAKEDOC) TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)"

################################################################################
# End Of File
################################################################################
