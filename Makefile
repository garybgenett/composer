################################################################################
# Composer CMS :: Primary Makefile
################################################################################

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
# test install in fresh cygwin
#	hack setup.bat
#	try "build" without networking available
#BUILD TEST

#OTHER NOTES
# now need zip/unzip in path
#	add zip/unzip [ -x ... ] checks and message (read ENTER) if not
# markdown-viewer xpi package
# no more texlive dependency
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

ifneq ($(wildcard $(COMPOSER_DIR).git),)
override COMPOSER_GITREPO		?= $(COMPOSER_DIR).git
else ifneq ($(wildcard $(COMPOSER_DIR)/.git),)
override COMPOSER_GITREPO		?= $(COMPOSER_DIR)/.git
else
override COMPOSER_GITREPO		?= https://github.com/garybgenett/composer.git
endif

override COMPOSER_VERSION		?= v1.4
override COMPOSER_BASENAME		:= Composer
override COMPOSER_FULLNAME		:= $(COMPOSER_BASENAME) CMS $(COMPOSER_VERSION)

################################################################################

override MAKEFILE			:= Makefile
override MAKEFLAGS			:=

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

override CSS_FILE			:= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override CSS				?=
override TTL				?=
override TOC				?=
override LVL				?= 2
override OPT				?=

# have to keep these around for a bit, after changing the names of them.
override CSS				?= $(DCSS)
override TTL				?= $(NAME)
override OPT				?= $(OPTS)

################################################################################

override COMPOSER_TARGET		:= compose
override COMPOSER_PANDOC		:= pandoc
override RUNMAKE			:= $(MAKE) --makefile $(COMPOSER_SRC)
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

override COMPOSER_ABSPATH		:= "'$$'"(abspath "'$$'"(dir "'$$'"(lastword "'$$'"(MAKEFILE_LIST))))
override COMPOSER_ALL_REGEX		:= ([a-zA-Z0-9][a-zA-Z0-9_.-]+)[:]
override COMPOSER_SUBDIRS		?=
override COMPOSER_DEPENDS		?=
override COMPOSER_TESTING		?=

ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^$(COMPOSER_ALL_REGEX).*$$|\1|gp" "$(COMPOSER_SRC)")
else
override COMPOSER_TARGETS		?= $(BASE)
endif
endif

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

# https://github.com/Thiht/markdown-viewer
# https://github.com/Thiht/markdown-viewer/blob/master/LICENSE (BSD)
override MDVIEWER_SRC			:= https://github.com/Thiht/markdown-viewer.git
override MDVIEWER_DST			:= $(COMPOSER_DIR)/markdown-viewer
override MDVIEWER_CSS			:= $(MDVIEWER_DST)/chrome/skin/markdown-viewer.css
override MDVIEWER_CMT			:= 86c90e73522678111f92840c4d88645b314f517e

# https://github.com/hakimel/reveal.js
# https://github.com/hakimel/reveal.js/blob/master/LICENSE (BSD)
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DST			:= $(COMPOSER_DIR)/revealjs
#>override REVEALJS_CSS			:= $(REVEALJS_DST)/css/theme/default.css
override REVEALJS_CSS			:= $(COMPOSER_DIR)/revealjs.css
override REVEALJS_CMT			:= 2.6.2

# http://www.w3.org/Talks/Tools/Slidy2/Overview.html#%286%29
# http://www.w3.org/Consortium/Legal/copyright-software (MIT)
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
ifeq ($(BUILD_ARCH),x86_64)
override BUILD_MSYS			:= 64
else
override BUILD_MSYS			:= 32
endif
override MSYSTEM_MSYS			:= MSYS$(BUILD_MSYS)
override MSYSTEM_MINGW			:= MINGW$(BUILD_MSYS)
endif

override CHOST				:=
override CHOST_MINGW			:=
override CFLAGS				:=
ifneq ($(BUILD_DIST),)
ifeq ($(BUILD_MSYS),)
override BUILD_PLAT			:= Linux
override BUILD_ARCH			:= i686
override CHOST				:= $(BUILD_ARCH)-pc-linux-gnu
override CHOST_MINGW			:= $(CHOST)
else
override BUILD_PLAT			:= Msys
override BUILD_ARCH			:= i686
override CHOST				:= $(BUILD_ARCH)-pc-msys
override CHOST_MINGW			:= $(BUILD_ARCH)-pc-mingw32
endif
override CFLAGS				:= -m32 -march=$(BUILD_ARCH) -mtune=generic
endif

override COMPOSER_PROGS			?= $(COMPOSER_DIR)/bin/$(BUILD_PLAT)

ifeq ($(BUILD_PLAT),Linux)
ifneq ($(BUILD_GHC_78),)
override GHC_BIN_PLAT			:= linux-deb7
else
override GHC_BIN_PLAT			:= linux
endif
else ifeq ($(BUILD_PLAT),FreeBSD)
override GHC_BIN_PLAT			:= freebsd
else ifeq ($(BUILD_PLAT),Darwin)
override GHC_BIN_PLAT			:= darwin
else ifeq ($(BUILD_PLAT),Msys)
override GHC_BIN_PLAT			:= mingw32
endif

override MSYS_BIN_ARCH			:= $(BUILD_ARCH)
override GHC_BIN_ARCH			:= $(BUILD_ARCH)
ifeq ($(BUILD_ARCH),i686)
override GHC_BIN_ARCH			:= i386
else ifeq ($(BUILD_ARCH),i386)
override MSYS_BIN_ARCH			:= i686
endif

# http://sourceforge.net/projects/msys2
# http://sourceforge.net/p/msys2/wiki/MSYS2%20installation
# https://www.archlinux.org/groups
override MSYS_VERSION			:= 20140704
override MSYS_BIN_SRC			:= http://sourceforge.net/projects/msys2/files/Base/$(MSYS_BIN_ARCH)/msys2-base-$(MSYS_BIN_ARCH)-$(MSYS_VERSION).tar.xz
override MSYS_BIN_DST			:= $(COMPOSER_ABODE)/msys$(BUILD_MSYS)

# https://www.haskell.org/ghc/download
# https://www.haskell.org/cabal/download.html
# https://hackage.haskell.org/package/cabal-install
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Tools
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Windows
# https://www.haskell.org/haskellwiki/Windows
ifneq ($(BUILD_GHC_78),)
override GHC_VERSION			:= 7.8.2
override GHC_VERSION_LIB		:= 1.18.1.3
override GHC_BIN_SRC			:= https://www.haskell.org/ghc/dist/$(GHC_VERSION)/ghc-$(GHC_VERSION)-$(GHC_BIN_ARCH)-unknown-$(GHC_BIN_PLAT).tar.xz
else
override GHC_VERSION			:= 7.6.3
override GHC_VERSION_LIB		:= 1.16.0
override GHC_BIN_SRC			:= https://www.haskell.org/ghc/dist/$(GHC_VERSION)/ghc-$(GHC_VERSION)-$(GHC_BIN_ARCH)-unknown-$(GHC_BIN_PLAT).tar.bz2
endif
override CABAL_VERSION			:= 1.20.0.2
override CABAL_VERSION_LIB		:= 1.20.0.1
override CBL_BIN_SRC			:= https://www.haskell.org/cabal/release/cabal-install-$(CABAL_VERSION)/cabal-install-$(CABAL_VERSION).tar.gz
override GHC_BIN_DST			:= $(BUILD_STRAP)/ghc-$(GHC_VERSION)
override CBL_BIN_DST			:= $(BUILD_STRAP)/cabal-install-$(CABAL_VERSION)

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
override PANDOC_MATH_CMT		:= 0.6.6.3
override PANDOC_HIGH_CMT		:= 0.5.8.5
override PANDOC_CITE_CMT		:= 0.3.1
override PANDOC_CMT			:= 1.12.4.2

# https://www.gnu.org/software/make/manual/make.html
# https://savannah.gnu.org/projects/make
override MAKE_VERSION			:= 3.82
override MAKE_BIN_SRC			:= https://ftp.gnu.org/gnu/make/make-$(MAKE_VERSION).tar.gz
override MAKE_SRC			:= http://git.savannah.gnu.org/r/make.git
override MAKE_BIN_DST			:= $(BUILD_STRAP)/make-$(MAKE_VERSION)
override MAKE_DST			:= $(COMPOSER_BUILD)/make
override MAKE_CMT			:= $(MAKE_VERSION)

# http://git-scm.com
# https://msysgit.github.io
override GIT_VERSION			:= 1.8.5.5
override GIT_BIN_SRC			:= https://www.kernel.org/pub/software/scm/git/git-$(GIT_VERSION).tar.xz
override GIT_SRC			:= https://git.kernel.org/pub/scm/git/git.git
override GIT_BIN_DST			:= $(BUILD_STRAP)/git-$(GIT_VERSION)
override GIT_DST			:= $(COMPOSER_BUILD)/git
override GIT_CMT			:= v$(GIT_VERSION)

override BUILD_PATH			:= $(COMPOSER_ABODE)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(BUILD_STRAP)/bin
override BUILD_PATH_MINGW		:= $(BUILD_PATH)
override BUILD_PATH_MINGW		:= $(BUILD_PATH_MINGW):$(MSYS_BIN_DST)/mingw$(BUILD_MSYS)/bin
override BUILD_PATH_MINGW		:= $(BUILD_PATH_MINGW):$(MSYS_BIN_DST)/usr/bin
override BUILD_PATH_MINGW		:= $(BUILD_PATH_MINGW):$(PATH)
override BUILD_PATH_MINGW		:= $(BUILD_PATH_MINGW):$(COMPOSER_PROGS)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(PATH)
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_PROGS)/bin

override BUILD_TOOLS			:=
ifneq ($(BUILD_MSYS),)
override BUILD_TOOLS			:= $(BUILD_TOOLS) \
	--with-gcc="$(MSYS_BIN_DST)/mingw$(BUILD_MSYS)/bin/gcc.exe" \
	--with-cpp="$(MSYS_BIN_DST)/mingw$(BUILD_MSYS)/bin/cpp.exe" \
	--with-ld="$(MSYS_BIN_DST)/mingw$(BUILD_MSYS)/bin/ld.exe"
endif

override WINDOWS_CMD			:= /c/Windows/System32/cmd /c
override MSYS_SHELL			:=  $(MSYS_BIN_DST)/usr/bin/sh
override CYGPATH			:= "$(MSYS_BIN_DST)/usr/bin/cygpath"
override PACMAN				:= "$(MSYS_BIN_DST)/usr/bin/pacman" --verbose --noconfirm --sync
override CABAL				:= cabal --verbose
override CABAL_INSTALL			= $(CABAL) install \
	--prefix="$(1)" \
	--global \
	--avoid-reinstalls
#>	--reinstall \
#>	--force-reinstalls
override CABAL_INSTALL_MINGW		= $(call CABAL_INSTALL,$(1)) \
	$(BUILD_TOOLS)

# second group is for added packages below
override PACMAN_BASE_LIST		:= \
	bash \
	filesystem \
	libarchive \
	libcurl \
	libgpgme \
	libiconv \
	libintl \
	libreadline \
	msys2-runtime \
	ncurses \
	pacman \
	\
	msys2-runtime-devel

# second group is for composer
# third group is for make build
# fourth group is for git build
override PACMAN_PACKAGES_LIST		:= \
	base-devel \
	mingw-w64-i686-toolchain \
	mingw-w64-x86_64-toolchain \
	msys2-devel \
	\
	git \
	unzip \
	vim \
	wget \
	zip \
	\
	gettext-devel \
	texinfo \
	\
	libcurl-devel \
	libiconv-devel \
	zlib-devel

override GHC_LIBRARIES_LIST		:= \
	alex|3.1.3 \
	happy|1.19.4

ifneq ($(BUILD_GHC_78),)
override GHC_BASE_LIBRARIES_LIST	:= \
	Win32|2.3.0.2 \
	array|0.5.0.0 \
	base|4.7.0.0 \
	binary|0.7.1.0 \
	bytestring|0.10.4.0 \
	containers|0.5.5.1 \
	deepseq|1.3.0.2 \
	directory|1.2.1.0 \
	filepath|1.3.0.2 \
	ghc-prim|0.3.1.0 \
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
	time|1.4.2 \
	transformers|0.3.0.0 \
	unix|2.7.0.1
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
# third group is for 'OpenGL' fix
# fourth group is for build fixes
# fifth group is for missing directories
override HASKELL_UPGRADE_LIST		:= \
	GHC|$(GHC_VERSION) \
	ghc|$(GHC_VERSION) \
	cabal-install|$(CABAL_VERSION) \
	Cabal|$(CABAL_VERSION_LIB) \
	$(GHC_BASE_LIBRARIES_LIST) \
	$(GHC_LIBRARIES_LIST) \
	\
	HTTP|4000.2.9 \
	async|2.0.1.5 \
	parallel|3.2.0.4 \
	primitive|0.5.1.0 \
	\
	GLURaw|1.4.0.1 \
	GLUT|2.5.1.1 \
	OpenGLRaw|1.5.0.0 \
	OpenGL|2.9.2.0 \
	\
	cgi|3001.1.8.5 \
	haskell-src|1.0.1.6 \
	unordered-containers|0.2.3.3 \
	vector|0.10.9.1 \
	\
	MonadCatchIO-mtl|0.3.1.0 \
	MonadCatchIO-transformers|0.3.1.0 \
	extensible-exceptions|0.1.1.4 \
	monads-tf|0.1.0.2

# thanks for the 'cgi' patch below: https://www.google.com/search?q=haskell+cgi+Module+Data.Typeable+mkTyCon+patch
#	details are at: https://ghc.haskell.org/trac/ghc/wiki/GhcKinds/PolyTypeable
override HASKELL_PATCH_LIST		:= \
	cgi-3001.1.8.5|http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/dev-haskell/cgi/files/cgi-3001.1.8.5-ghc78.patch

override PANDOC_DEPENDENCIES_LIST	:= \
	hsb2hs|0.2 \
	hxt|9.3.1.4

########################################

override PATH_LIST			:= $(subst :, ,$(BUILD_PATH))
override BASH				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)

override CP				:= $(call COMPOSER_FIND,$(PATH_LIST),cp) -afv
override MKDIR				:= $(call COMPOSER_FIND,$(PATH_LIST),install) -dv
override MV				:= $(call COMPOSER_FIND,$(PATH_LIST),mv) -fv
override RM				:= $(call COMPOSER_FIND,$(PATH_LIST),rm) -fv

override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) --color=auto --time-style=long-iso -asF -l
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r
override TAR				:= $(call COMPOSER_FIND,$(PATH_LIST),tar) -vvx
override TIMESTAMP			:= $(call COMPOSER_FIND,$(PATH_LIST),date) --rfc-2822 >

override WGET				:= $(call COMPOSER_FIND,$(PATH_LIST),wget) --verbose --restrict-file-names=windows --server-response --timestamping
override WGET_FILE			= $(WGET) --directory-prefix="$(COMPOSER_STORE)" "$(1)"

override define UNZIP			=
	$(call COMPOSER_FIND,$(PATH_LIST),unzip) -ou -d "$(abspath $(dir $(1)))" "$(COMPOSER_STORE)/$(lastword $(subst /, ,$(2)))"
endef
override define UNTAR			=
	[ ! -d "$(1)" ] && \
		$(MKDIR) "$(abspath $(dir $(1)))" && \
		$(TAR) -C "$(abspath $(dir $(1)))" -f "$(COMPOSER_STORE)/$(lastword $(subst /, ,$(2)))"
endef
override define PATCH			=
	cd "$(1)" && \
		$(call WGET_FILE,$(2)) && \
		$(call COMPOSER_FIND,$(PATH_LIST),patch) -p1 <"$(COMPOSER_STORE)/$(lastword $(subst /, ,$(2)))"
endef

override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git)
override GIT_RUN			= cd "$(1)" && $(GIT) --git-dir="$(COMPOSER_STORE)/$(lastword $(subst /, ,$(1))).git" --work-tree="$(1)" $(2)
override define GIT_REPO		=
	$(MKDIR) "$(COMPOSER_STORE)"
	$(MKDIR) "$(1)"
	GIT_REPO="$(COMPOSER_STORE)/$(lastword $(subst /, ,$(1))).git"
	[ ! -d "$${GIT_REPO}" ] && [ -d "$(1).git"  ] && $(MV) "$(1).git"  "$${GIT_REPO}"
	[ ! -d "$${GIT_REPO}" ] && [ -d "$(1)/.git" ] && $(MV) "$(1)/.git" "$${GIT_REPO}"
	[ ! -d "$${GIT_REPO}" ] && \
		$(call GIT_RUN,$(1),init) && \
		$(call GIT_RUN,$(1),remote add origin "$(2)")
	echo "gitdir: $${GIT_REPO}" >"$(1)/.git"
	$(call GIT_RUN,$(1),config --local --replace-all core.worktree "$(1)")
	$(call GIT_RUN,$(1),fetch --all)
	[ -n "$(3)" ] && [ -n "$(4)" ] && $(call GIT_RUN,$(1),checkout --force -B $(4) $(3))
	[ -n "$(3)" ] && [ -z "$(4)" ] && $(call GIT_RUN,$(1),checkout --force -B $(BUILD_BRANCH) $(3))
	[ -z "$(3)" ] && [ -z "$(4)" ] && $(call GIT_RUN,$(1),checkout --force master)
	$(call GIT_RUN,$(1),reset --hard)
endef
override define GIT_SUBMODULE		=
	GIT_REPO="$(COMPOSER_STORE)/$(lastword $(subst /, ,$(1))).git"
	$(call GIT_RUN,$(1),submodule update --init)
	cd "$(1)" && find ./ -mindepth 2 -type d -name ".git" 2>/dev/null | $(SED) -e "s|^[.][/]||g" -e "s|[/][.]git$$||g" | while read FILE; do
		$(MKDIR) "$${GIT_REPO}/modules/$${FILE}"
		$(RM) -r "$${GIT_REPO}/modules/$${FILE}"
		$(MV) "$(1)/$${FILE}/.git" "$${GIT_REPO}/modules/$${FILE}"
	done
	cd "$${GIT_REPO}" && find ./modules -type f -name "index" 2>/dev/null | $(SED) -e "s|^[.][/]modules[/]||g" -e "s|[/]index$$||g" | while read FILE; do
		$(MKDIR) "$(1)/$${FILE}"
		echo "gitdir: $${GIT_REPO}/modules/$${FILE}" >"$(1)/$${FILE}/.git"
		cd "$(1)/$${FILE}" && $(GIT) checkout ./
	done
endef

# thanks for the 'LANG' fix below: https://stackoverflow.com/questions/23370392/failed-installing-dependencies-with-cabal
#	found by: https://github.com/faylang/fay/issues/261
override BUILD_ENV_BASE			:= \
	LANG="en_US.UTF8" \
	TERM="$${TERM}" \
	CFLAGS="$(CFLAGS)" \
	LDFLAGS= \
	\
	USER="$(USER)" \
	HOME="$(COMPOSER_ABODE)"
ifneq ($(BUILD_MSYS),)
# adding 'USERPROFILE' to list causes 'Setup.exe: illegal operation'
override BUILD_ENV_BASE			:= $(BUILD_ENV_BASE) \
	CYGWIN= \
	CYGWIN_ROOT= \
	USERNAME="$(USERNAME)" \
	HOMEPATH="$(COMPOSER_ABODE)" \
	\
	ALLUSERSPROFILE="$(COMPOSER_ABODE)" \
	APPDATA="$(COMPOSER_ABODE)" \
	LOCALAPPDATA="$(COMPOSER_ABODE)" \
	TEMP="$(COMPOSER_ABODE)"
endif
override BUILD_ENV_VARS			:= $(BUILD_ENV_BASE) \
	CHOST="$(CHOST)" \
	PATH="$(BUILD_PATH)"
override BUILD_ENV_VARS_MINGW		:= $(BUILD_ENV_VARS)
ifneq ($(BUILD_MSYS),)
override BUILD_ENV_VARS			:= $(BUILD_ENV_VARS) \
	MSYSTEM="$(MSYSTEM_MSYS)"
override BUILD_ENV_VARS_MINGW		:= $(BUILD_ENV_BASE) \
	CHOST="$(CHOST_MINGW)" \
	PATH="$(BUILD_PATH_MINGW)" \
	MSYSTEM="$(MSYSTEM_MINGW)"
endif
override BUILD_ENV			:= $(call COMPOSER_FIND,$(PATH_LIST),env) - $(BUILD_ENV_VARS)
override BUILD_ENV_MINGW		:= $(call COMPOSER_FIND,$(PATH_LIST),env) - $(BUILD_ENV_VARS_MINGW)

ifeq ($(BUILD_MSYS),)
override MINGW_PATH			= $(1)
else
override MINGW_PATH			= $(shell $(CYGPATH) --absolute --windows "$(1)")
endif

################################################################################

.NOTPARALLEL:
.POSIX:
.SUFFIXES:

.ONESHELL:
.SHELLFLAGS: -e

.DEFAULT_GOAL := $(HELPOUT)

########################################

override HELPLVL1 := printf "\#%.0s" {1..70}; echo
override HELPLVL2 := printf "\#%.0s" {1..40}; echo

override HELPOUT1 := printf "   %-15s %-25s %s\n"
override HELPOUT2 := printf "\# %-20s %s\n"
override HELPMARK := "\>\>"

override EXAMPLE_SECOND := LICENSE
override EXAMPLE_TARGET := manual
override EXAMPLE_OUTPUT := Users_Guide

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
	@$(HELPOUT2) "$(COMPOSER_FULLNAME) :: Primary Makefile"
	@$(HELPLVL1)
	@echo ""
	@echo "Usage:"
	@$(HELPOUT1) "RUNMAKE := $(RUNMAKE)"
	@$(HELPOUT1) "COMPOSE := $(COMPOSE)"
	@$(HELPOUT1) ""'$$'"(RUNMAKE) [variables] <filename>.<extension>"
	@$(HELPOUT1) ""'$$'"(COMPOSE) <variables>"
	@echo ""

.PHONY: HELP_OPTIONS
HELP_OPTIONS:
	@$(HELPLVL2)
	@echo ""
	@echo "Variables:"
	@$(HELPOUT1) "TYPE"	"Desired output format"		"[$(TYPE)]"
	@$(HELPOUT1) "BASE"	"Base of output file(s)"	"[$(BASE)]"
	@$(HELPOUT1) "LIST"	"List of input files(s)"	"[$(LIST)]"
	@echo ""
	@echo "Optional Variables:"
	@$(HELPOUT1) "CSS"	"Location of CSS file"		"[$(CSS)] (overrides '$(COMPOSER_CSS)')"
	@$(HELPOUT1) "TTL"	"Document title prefix"		"[$(TTL)]"
	@$(HELPOUT1) "TOC"	"Table of contents depth"	"[$(TOC)]"
	@$(HELPOUT1) "LVL"	"New slide header level"	"[$(LVL)]"
	@$(HELPOUT1) "OPT"	"Custom Pandoc options"		"[$(OPT)]"
	@echo ""
	@echo "Pre-Defined Types:"
	@$(HELPOUT1) "[Type]"		"[Extension]"	"[Description]"
	@$(HELPOUT1) "$(TYPE_HTML)"	"$(TYPE_HTML)"	"$(HTML_DESC)"
	@$(HELPOUT1) "$(TYPE_LPDF)"	"$(TYPE_LPDF)"	"$(LPDF_DESC)"
	@$(HELPOUT1) "$(TYPE_PRES)"	"$(PRES_EXTN)"	"$(PRES_DESC)"
	@$(HELPOUT1) "$(TYPE_SHOW)"	"$(SHOW_EXTN)"	"$(SHOW_DESC)"
	@$(HELPOUT1) "$(TYPE_DOCX)"	"$(TYPE_DOCX)"	"$(DOCX_DESC)"
	@$(HELPOUT1) "$(TYPE_EPUB)"	"$(TYPE_EPUB)"	"$(EPUB_DESC)"
	@echo ""
	@echo "Any other types specified will be passed directly through to Pandoc."
	@echo ""

.PHONY: HELP_OPTIONS_SUB
HELP_OPTIONS_SUB:
	@$(HELPLVL2)
	@echo ""
	@echo "Following is the complete list of exposed/configurable variables:"
	@echo ""
	@echo "Options (^ := COMPOSER):"
	@$(HELPOUT1) "^_GITREPO"	"Source repository"		"[$(COMPOSER_GITREPO)]"
	@$(HELPOUT1) "^_VERSION"	"Version for cloning"		"[$(COMPOSER_VERSION)] (valid: any Git tag or commit)"
	@$(HELPOUT1) "^_STAMP"		"Timestamp file"		"[$(COMPOSER_STAMP)]"
	@$(HELPOUT1) "^_CSS"		"Default CSS file"		"[$(COMPOSER_CSS)]"
	@$(HELPOUT1) "^_EXT"		"Markdown file extension"	"[$(COMPOSER_EXT)]"
	@$(HELPOUT1) "^_FILES"		"List for '$(REPLICA)' target"	"[$(COMPOSER_FILES)]"
	@echo ""
	@echo "Recursion Options (^ := COMPOSER):"
	@$(HELPOUT1) "^_TARGETS"	"Default targets"		"[$(COMPOSER_TARGETS)]"
	@$(HELPOUT1) "^_SUBDIRS"	"Sub-directories list"		"[$(COMPOSER_SUBDIRS)]"
	@$(HELPOUT1) "^_DEPENDS"	"Sub-directory dependency"	"[$(COMPOSER_DEPENDS)] (valid: empty or 1)"
	@$(HELPOUT1) "^_TESTING"	"Modifies '$(TESTOUT)' target"	"[$(COMPOSER_TESTING)] (valid: empty, 0 or 1)"
	@echo ""
	@echo "Location Options (^ := COMPOSER):"
	@$(HELPOUT1) "^_ABODE"		"Install/binary directory"	"[$(COMPOSER_ABODE)]"
	@$(HELPOUT1) "^_STORE"		"Source files directory"	"[$(COMPOSER_STORE)]"
	@$(HELPOUT1) "^_BUILD"		"Build directory"		"[$(COMPOSER_BUILD)]"
	@$(HELPOUT1) "^_PROGS"		"Built binaries directory"	"[$(COMPOSER_PROGS)]"
	@echo ""
	@echo "Build Options (^ := BUILD):"
	@$(HELPOUT1) "^_DIST"		"Build generic binaries"	"[$(BUILD_DIST)] (valid: empty or 1)"
	@$(HELPOUT1) "^_MSYS"		"Force Windows detection"	"[$(BUILD_MSYS)] (valid: empty or 1)"
	@$(HELPOUT1) "^_GHC_78"		"GHC 7.8 instead of 7.6"	"[$(BUILD_GHC_78)] (valid: empty or 1)"
	@$(HELPOUT1) "^_PLAT"		"Overrides 'uname -o'"		"[$(BUILD_PLAT)]"
	@$(HELPOUT1) "^_ARCH"		"Overrides 'uname -m'"		"[$(BUILD_ARCH)]"
	@echo ""
	@echo "All of these can be set on the command line or in the environment."
	@echo ""
	@echo "To set them permanently, add them to the settings file (you may have to create it):"
	@$(HELPOUT1) "$(COMPOSER_INCLUDE)"
	@echo ""
	@echo "All of these change the fundamental operation of $(COMPOSER_BASENAME), and should be used with care."
	@echo ""

.PHONY: HELP_TARGETS
HELP_TARGETS:
	@$(HELPLVL2)
	@echo ""
	@echo "Primary Targets:"
	@$(HELPOUT1) "$(HELPOUT)"		"Basic help output"
	@$(HELPOUT1) "$(HELPALL)"		"Complete help output"
	@$(HELPOUT1) "$(COMPOSER_TARGET)"	"Main target used to build/format documents"
	@$(HELPOUT1) "$(COMPOSER_PANDOC)"	"Wrapper target which calls Pandoc directly (used internally)"
	@echo ""
	@echo "Installation Targets:"
	@$(HELPOUT1) "$(UPGRADE)"		"Download/update all 3rd party components (need to do this at least once)"
	@$(HELPOUT1) "$(REPLICA)"		"Clone key components into current directory (for inclusion in content repositories)"
	@$(HELPOUT1) "$(INSTALL)"		"Recursively create '$(MAKEFILE)' files (non-destructive build system initialization)"
	@$(HELPOUT1) "$(TESTOUT)"		"Build example/test directory using all features and test/validate success"
	@$(HELPOUT1) "$(EXAMPLE)"		"Print out example/template '$(MAKEFILE)' (helpful shortcut for creating recursive files)"
	@echo ""
	@echo "Compilation Targets:"
	@$(HELPOUT1) "$(STRAPIT)"		"Download and configure binary GHC bootstrap environment"
	@$(HELPOUT1) "$(FETCHIT)"		"Download/update GNU Make and Haskell/Pandoc source repositories"
	@$(HELPOUT1) "$(BUILDIT)"		"Build/compile local GNU Make and Haskell/Pandoc binaries from source"
	@$(HELPOUT1) "$(CHECKIT)"		"Diagnostic version information (for verification and/or troubleshooting)"
	@$(HELPOUT1) "$(SHELLIT)"		"$(COMPOSER_BASENAME) sub-shell environment, using native tools"
	@$(HELPOUT1) "$(SHELLIT)-msys"		"Launches MSYS2 shell into $(COMPOSER_BASENAME) environment"
	@echo ""
	@echo "Helper Targets:"
	@$(HELPOUT1) "all"			"Create all of the default output formats or configured targets"
	@$(HELPOUT1) "clean"			"Remove all of the default output files or configured targets"
	@$(HELPOUT1) "print"			"List all source files newer than the '$(COMPOSER_STAMP)' timestamp file"
	@echo ""

.PHONY: HELP_TARGETS_SUB
HELP_TARGETS_SUB:
	@$(HELPLVL2)
	@echo ""
	@echo "These are all the rest of the sub-targets used by the main targets above:"
	@echo ""
	@echo "Static Sub-Targets:"
	@$(HELPOUT1) "$(INSTALL):"		"$(INSTALL)-dir"			"Per-directory engine which does all the work"
	@$(HELPOUT1) "$(COMPOSER_PANDOC):"	"settings"				"Prints marker and variable values, for readability"
	@$(HELPOUT1) "all:"			"whoami"				"Prints marker and variable values, for readability"
	@$(HELPOUT1) ""				"subdirs"				"Aggregates/runs the '"'$$'"(COMPOSER_SUBDIRS)' targets"
	@$(HELPOUT1) "$(STRAPIT):"		"$(STRAPIT)-check"			"Tries to proactively prevent common errors"
	@$(HELPOUT1) ""				"$(STRAPIT)-msys"			"Installs MSYS2 environment with MinGW-w64"
	@$(HELPOUT1) ""				"$(STRAPIT)-dlls"			"Copies MSYS2 DLL files (for native Windows usage)"
	@$(HELPOUT1) ""				"$(STRAPIT)-git"			"Build/compile of Git from source archive"
	@$(HELPOUT1) ""				"$(STRAPIT)-ghc-bin"			"Pre-built binary GHC installation"
	@$(HELPOUT1) ""				"$(STRAPIT)-ghc-lib"			"GHC libraries necessary for compilation"
	@$(HELPOUT1) "$(FETCHIT):"		"$(FETCHIT)-cabal"			"Updates Cabal database"
	@$(HELPOUT1) ""				"$(FETCHIT)-make"			"Download/preparation of GNU Make source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-git"			"Download/preparation of Git source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-ghc"			"Download/preparation of GHC source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-haskell"			"Download/preparation of Haskell Platform source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-pandoc"			"Download/preparation of Pandoc source repository"
	@$(HELPOUT1) "$(FETCHIT)-pandoc:"	"$(FETCHIT)-pandoc-type"		"Download/preparation of Pandoc-Types source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-pandoc-math"		"Download/preparation of TeXMath source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-pandoc-high"		"Download/preparation of Highlighting-Kate source repository"
	@$(HELPOUT1) ""				"$(FETCHIT)-pandoc-cite"		"Download/preparation of Pandoc-CiteProc source repository"
	@$(HELPOUT1) "$(BUILDIT):"		"$(BUILDIT)-clean"			"Archives/restores source files and removes temporary build files"
	@$(HELPOUT1) ""				"$(BUILDIT)-bindir"			"Copies compiled binaries to repository binaries directory"
	@$(HELPOUT1) ""				"$(BUILDIT)-make"			"Build/compile of GNU Make from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-git"			"Build/compile of Git from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-ghc"			"Build/compile of GHC from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-haskell"			"Build/compile of Haskell Platform from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-pandoc"			"Build/compile of stand-alone Pandoc(-CiteProc) from source"
	@$(HELPOUT1) "$(BUILDIT)-pandoc:"	"$(BUILDIT)-pandoc-deps"		"Build/compile of Pandoc dependencies from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-pandoc-type"		"Build/compile of Pandoc-Types from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-pandoc-math"		"Build/compile of TeXMath from source"
	@$(HELPOUT1) ""				"$(BUILDIT)-pandoc-high"		"Build/compile of Highlighting-Kate from source"
	@$(HELPOUT1) "$(SHELLIT)[-msys]:"	"$(SHELLIT)-bashrc"			"Initializes Bash configuration file"
	@$(HELPOUT1) ""				"$(SHELLIT)-vimrc"			"Initializes Vim configuration file"
	@echo ""
	@echo "Dynamic Sub-Targets:"
	@$(HELPOUT1) "all:"			""'$$'"(COMPOSER_TARGETS)"		"[$(COMPOSER_TARGETS)]"
	@$(HELPOUT1) "clean:"			""'$$'"(COMPOSER_TARGETS)-clean"	"[$(addsuffix -clean,$(COMPOSER_TARGETS))]"
	@$(HELPOUT1) "subdirs:"			""'$$'"(COMPOSER_SUBDIRS)"		"[$(COMPOSER_SUBDIRS)]"
	@echo ""
	@echo "Wildcard Sub-Targets:"
	@$(HELPOUT1) "$(REPLICA)-*:"		"$(REPLICA) COMPOSER_VERSION=*"		""
	@$(HELPOUT1) "do-*:"			"fetch-* build-*"			""
	@echo ""
	@echo "These do not need to be used directly during normal use, and are only documented for completeness."
	@echo ""

.PHONY: HELP_COMMANDS
HELP_COMMANDS:
	@$(HELPLVL1)
	@echo ""
	@echo "Command Examples:"
	@echo ""
	@$(HELPOUT2) "Have the system do all the work:"
	@echo ""'$$'"(RUNMAKE) $(BASE).$(EXTENSION)"
	@echo ""
	@$(HELPOUT2) "Be clear about what is wanted (or, for multiple or differently named input files):"
	@echo ""'$$'"(COMPOSE) LIST=\"$(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@echo ""

.PHONY: EXAMPLE_MAKEFILES
EXAMPLE_MAKEFILES: \
	EXAMPLE_MAKEFILES_HEADER \
	EXAMPLE_MAKEFILE_1 \
	EXAMPLE_MAKEFILE_2 \
	EXAMPLE_MAKEFILES_FOOTER

.PHONY: EXAMPLE_MAKEFILES_HEADER
EXAMPLE_MAKEFILES_HEADER:
	@$(HELPLVL2)
	@echo ""
	@echo "Calling from children '$(MAKEFILE)' files:"
	@echo ""

.PHONY: EXAMPLE_MAKEFILE_1
EXAMPLE_MAKEFILE_1:
	@$(HELPOUT2) "Simple, with filename targets and \"automagic\" detection of them:"
	@$(HELPOUT2) "include $(COMPOSER)"
	@echo ".PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "$(BASE): # so \"clean\" will catch the below files"
	@echo "$(EXAMPLE_TARGET): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@echo "$(EXAMPLE_SECOND).$(EXTENSION):"
	@echo ""

.PHONY: EXAMPLE_MAKEFILE_2
EXAMPLE_MAKEFILE_2:
	@$(HELPOUT2) "Advanced, with manual enumeration of user-defined targets and per-target variables:"
	@echo "override COMPOSER_TARGETS ?= $(BASE) $(EXAMPLE_TARGET) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(HELPOUT2) "include $(COMPOSER)"
	@echo ".PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "$(BASE): export TOC := 1"
	@echo "$(BASE): $(BASE).$(EXTENSION)"
	@echo "$(EXAMPLE_TARGET): $(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)"
	@echo "	"'$$'"(COMPOSE) LIST=\""'$$'"(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@echo "	"'$$'"(COMPOSE) LIST=\""'$$'"(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_LPDF)\""
	@echo "$(EXAMPLE_TARGET)-clean:"
	@echo "	"'$$'"(RM) $(EXAMPLE_OUTPUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@echo ""

.PHONY: EXAMPLE_MAKEFILES_FOOTER
EXAMPLE_MAKEFILES_FOOTER:
	@$(HELPOUT2) "Then, from the command line:"
	@echo "make clean && make all"
	@echo ""

.PHONY: HELP_SYSTEM
HELP_SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
HELP_SYSTEM:
	@$(HELPLVL1)
	@echo ""
	@echo "Completely recursive build system:"
	@echo ""
	@$(HELPOUT2) "The top-level '$(MAKEFILE)' is the only one which needs a direct reference:"
	@$(HELPOUT2) "(NOTE: This must be an absolute path.)"
	@echo "include $(COMPOSER)"
	@echo ""
	@$(HELPOUT2) "All sub-directories then each start with:"
	@echo "override COMPOSER_ABSPATH := $(COMPOSER_ABSPATH)"
	@echo "override COMPOSER_TEACHER := "'$$'"(abspath "'$$'"(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo "override COMPOSER_SUBDIRS ?="
	@echo ".DEFAULT_GOAL := all"
	@echo ""
	@$(HELPOUT2) "And end with:"
	@echo "include "'$$'"(COMPOSER_TEACHER)"
	@echo ""
	@$(HELPOUT2) "Back in the top-level '$(MAKEFILE)', and in all sub-'$(MAKEFILE)' instances which recurse further down:"
	@echo "override COMPOSER_SUBDIRS ?= $(COMPOSER_SUBDIRS)"
	@echo "include [...]"
	@echo ""
	@$(HELPOUT2) "Create a new '$(MAKEFILE)' using a helpful template:"
	@echo ""'$$'"(RUNMAKE) --quiet COMPOSER_TARGETS=\"$(BASE).$(EXTENSION)\" $(EXAMPLE) >$(MAKEFILE)"
	@echo ""
	@$(HELPOUT2) "Or, recursively initialize the current directory tree:"
	@$(HELPOUT2) "(NOTE: This is a non-destructive operation.)"
	@echo ""'$$'"(RUNMAKE) $(INSTALL)"
	@echo ""

.PHONY: EXAMPLE_MAKEFILE
EXAMPLE_MAKEFILE: \
	EXAMPLE_MAKEFILE_HEADER \
	EXAMPLE_MAKEFILE_FULL \

.PHONY: EXAMPLE_MAKEFILE_HEADER
EXAMPLE_MAKEFILE_HEADER:
	@$(HELPLVL2)
	@echo ""
	@echo "Finally, a completely recursive '$(MAKEFILE)' example:"
	@echo ""

.PHONY: EXAMPLE_MAKEFILE_FULL
EXAMPLE_MAKEFILE_FULL: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
EXAMPLE_MAKEFILE_FULL:
	@$(HELPOUT2) "$(HELPMARK) HEADERS"
	@echo ""
	@$(HELPOUT2) "These two statements must be at the top of every file:"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "(NOTE: The 'COMPOSER_TEACHER' variable can be modified for custom chaining, but with care.)"
	@echo ""
	@echo "override COMPOSER_ABSPATH := $(COMPOSER_ABSPATH)"
	@echo "override COMPOSER_TEACHER := "'$$'"(abspath "'$$'"(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) DEFINITIONS"
	@echo ""
	@$(HELPOUT2) "These statements are also required:"
	@$(HELPOUT2) " * Use '?=' declarations and define *before* the upstream 'include' statement"
	@$(HELPOUT2) " * They pass their values *up* the '$(MAKEFILE)' chain"
	@$(HELPOUT2) " * Should always be defined, even if empty, to prevent downward propagation of values"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "(NOTE: List of 'all' targets is '$(COMPOSER_ALL_REGEX)' if 'COMPOSER_TARGETS' is empty.)"
	@echo ""
	@echo "override COMPOSER_TARGETS ?= $(BASE).$(EXTENSION) $(EXAMPLE_SECOND).$(EXTENSION)"
	@echo "override COMPOSER_SUBDIRS ?= $(COMPOSER_SUBDIRS)"
	@echo "override COMPOSER_DEPENDS ?= $(COMPOSER_DEPENDS)"
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) VARIABLES"
	@echo ""
	@$(HELPOUT2) "The option variables are not required, but are available for locally-scoped configuration:"
	@$(HELPOUT2) " * For proper inheritance, use '?=' declarations and define *before* the upstream 'include' statement"
	@$(HELPOUT2) " * They pass their values *down* the '$(MAKEFILE)' chain"
	@$(HELPOUT2) " * Do not need to be defined when empty, unless necessary to override upstream values"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "To disable inheritance and/or insulate from environment variables:"
	@$(HELPOUT2) " * Replace 'override VAR ?=' with 'override VAR :='"
	@$(HELPOUT2) " * Define *after* the upstream 'include' statement"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "(NOTE: Any settings here will apply to all children, unless 'override' is used downstream.)"
	@echo ""
	@$(HELPOUT2) "Define the CSS template to use in this entire directory tree:"
	@$(HELPOUT2) " * Absolute path names should be used, so that children will be able to find it"
	@$(HELPOUT2) " * The '"'$$'"(COMPOSER_ABSPATH)' variable can be used to simplify this"
	@$(HELPOUT2) " * If not defined, the lowest-level '$(COMPOSER_CSS)' file will be used"
	@$(HELPOUT2) " * If not defined, and no '$(COMPOSER_CSS)' file can be found, will use default CSS file"
	@echo ""
	@echo ""'$$'"(eval override CSS ?= "'$$'"(COMPOSER_ABSPATH)/$(COMPOSER_CSS))"
	@echo ""
	@$(HELPOUT2) "All the other optional variables can also be made global in this directory scope:"
	@echo ""
	@echo "override TTL ?="
	@echo "override TOC ?= 2"
	@echo "override LVL ?= $(LVL)"
	@echo "override OPT ?="
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) INCLUDE"
	@echo ""
	@$(HELPOUT2) "Necessary include statement:"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "(NOTE: This must be after all references to '"'$$'"(COMPOSER_ABSPATH)' but before '.DEFAULT_GOAL'.)"
	@echo ""
	@echo "include "'$$'"(COMPOSER_TEACHER)"
	@echo ""
	@$(HELPOUT2) "For recursion to work, a default target needs to be defined:"
	@$(HELPOUT2) " * Needs to be 'all' for directories which must recurse into sub-directories"
	@$(HELPOUT2) " * The 'subdirs' target can be used manually, if desired, so this can be changed to another value"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "(NOTE: Recursion will cease if not 'all', unless 'subdirs' target is called.)"
	@echo ""
	@echo ".DEFAULT_GOAL := all"
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) RECURSION"
	@echo ""
	@$(HELPOUT2) "Dependencies can be specified, if needed:"
	@$(HELPOUT2) ""
	@$(HELPOUT2) "(NOTE: This defines the sub-directories which must be built before '$(firstword $(COMPOSER_SUBDIRS))'.)"
	@echo ""
	@echo "$(firstword $(COMPOSER_SUBDIRS)): $(wordlist 2,$(words $(COMPOSER_SUBDIRS)),$(COMPOSER_SUBDIRS))"
	@echo ""
	@$(HELPOUT2) "For parent/child directory dependencies, set '"'$$'"(COMPOSER_DEPENDS)' to a non-empty value."
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) MAKEFILE"
	@echo ""
	@$(HELPOUT2) "This is where the rest of the file should be defined."
	@$(HELPOUT2) ""
	@$(HELPOUT2) "In this example, '"'$$'"(COMPOSER_TARGETS)' is used completely in lieu of any explicit targets."
	@echo ""

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(HELPLVL1)
	@$(HELPOUT2) "Happy Hacking!"
	@$(HELPLVL1)

########################################

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(HELPOUT2) "$(HELPMARK) HEADERS"
	@echo "override COMPOSER_ABSPATH := $(COMPOSER_ABSPATH)"
	@echo "override COMPOSER_TEACHER := "'$$'"(abspath "'$$'"(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) DEFINITIONS"
	@echo "override COMPOSER_TARGETS ?= $(COMPOSER_TARGETS)"
	@echo "override COMPOSER_SUBDIRS ?= $(COMPOSER_SUBDIRS)"
	@echo "override COMPOSER_DEPENDS ?= $(COMPOSER_DEPENDS)"
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) VARIABLES"
	@$(HELPOUT2) ""'$$'"(eval override CSS ?= "'$$'"(COMPOSER_ABSPATH)/$(COMPOSER_CSS))"
	@$(HELPOUT2) "override TTL ?="
	@$(HELPOUT2) "override TOC ?="
	@$(HELPOUT2) "override LVL ?="
	@$(HELPOUT2) "override OPT ?="
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) INCLUDE"
	@echo "include "'$$'"(COMPOSER_TEACHER)"
	@echo ".DEFAULT_GOAL := all"
	@echo ""
	@$(HELPOUT2) "$(HELPMARK) MAKEFILE"
	@$(HELPOUT2) "(Contents of file go here.)"

override TEST_DIRECTORIES := \
	$(TESTOUT_DIR) \
	$(TESTOUT_DIR)/subdir1 \
	$(TESTOUT_DIR)/subdir1/example1 \
	$(TESTOUT_DIR)/subdir2 \
	$(TESTOUT_DIR)/subdir2/example2
override TEST_DIR_CSSDST := $(word 4,$(TEST_DIRECTORIES))
override TEST_DIR_DEPEND := $(word 2,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_1 := $(word 3,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_2 := $(word 5,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_F := $(word 1,$(TEST_DIRECTORIES))
override TEST_DEPEND_SUB := example1
override TEST_FULLMK_SUB := subdir1 subdir2

.PHONY: $(TESTOUT)
$(TESTOUT):
	$(foreach FILE,$(TEST_DIRECTORIES),\
		$(MKDIR) "$(FILE)" && \
			$(CP) \
				"$(COMPOSER_DIR)/"*.$(COMPOSER_EXT) \
				"$(COMPOSER_DIR)/"*.$(COMPOSER_IMG) \
				"$(FILE)/"
	)
	$(CP) "$(MDVIEWER_CSS)" "$(TEST_DIR_CSSDST)/$(COMPOSER_CSS)"
	$(RUNMAKE) --directory "$(TESTOUT_DIR)" $(INSTALL)
ifneq ($(COMPOSER_TESTING),0)
	$(RUNMAKE) --quiet COMPOSER_SUBDIRS="$(TEST_DEPEND_SUB)" COMPOSER_DEPENDS="1" $(EXAMPLE) >"$(TEST_DIR_DEPEND)/$(MAKEFILE)"
	$(RUNMAKE) --quiet EXAMPLE_MAKEFILE_1 >"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	$(RUNMAKE) --quiet EXAMPLE_MAKEFILE_2 >"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	$(RUNMAKE) --quiet COMPOSER_TARGETS="" COMPOSER_SUBDIRS="" $(EXAMPLE) >>"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	$(RUNMAKE) --quiet COMPOSER_TARGETS="" COMPOSER_SUBDIRS="" $(EXAMPLE) >>"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	$(RUNMAKE) --quiet COMPOSER_SUBDIRS="$(TEST_FULLMK_SUB)" EXAMPLE_MAKEFILE_FULL >"$(TEST_DIR_MAKE_F)/$(MAKEFILE)"
endif
	$(MKDIR) "$(TESTOUT_DIR)/$(COMPOSER_BASENAME)"
	$(RUNMAKE) --directory "$(TESTOUT_DIR)/$(COMPOSER_BASENAME)" $(REPLICA)
	$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1$$\(COMPOSER_ABSPATH\)/$(COMPOSER_BASENAME)/$(MAKEFILE)|g" "$(TESTOUT_DIR)/$(MAKEFILE)"
	$(MAKE) --directory "$(TESTOUT_DIR)"
ifneq ($(COMPOSER_TESTING),)
	$(foreach FILE,$(TEST_DIRECTORIES),\
		echo "" && \
		echo "[$(FILE)/$(MAKEFILE)]" && \
		echo "" && \
		cat "$(FILE)/$(MAKEFILE)"
	)
endif

.PHONY: $(INSTALL)
$(INSTALL): install-dir
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1$(COMPOSER)|g" "$(CURDIR)/$(MAKEFILE)"

.PHONY: $(INSTALL)-dir
$(INSTALL)-dir:
	if [ -f "$(CURDIR)/$(MAKEFILE)" ]; then
		@echo "[SKIPPING] $(CURDIR)/$(MAKEFILE)"
	else
		@echo "[CREATING] $(CURDIR)/$(MAKEFILE)"
		$(RUNMAKE) --quiet \
			COMPOSER_TARGETS="$(sort $(subst .$(COMPOSER_EXT),.$(TYPE_HTML),$(wildcard *.$(COMPOSER_EXT))))" \
			COMPOSER_SUBDIRS="$(sort $(subst /,,$(wildcard */)))" \
			COMPOSER_DEPENDS="$(COMPOSER_DEPENDS)" \
			$(EXAMPLE) >"$(CURDIR)/$(MAKEFILE)"
	fi
	$(foreach FILE,$(sort $(subst /,,$(wildcard */))),\
		$(RUNMAKE) --quiet --directory "$(CURDIR)/$(FILE)" $(INSTALL)-dir
	)

override REPLICA_GIT := $(COMPOSER_STORE)/$(COMPOSER_BASENAME).git
override GIT_REPLICA := $(GIT) --git-dir="$(REPLICA_GIT)"

.PHONY: $(REPLICA)
$(REPLICA):
	if [ ! -d "$(REPLICA_GIT)" ]; then
		$(GIT_REPLICA) init --bare
		$(GIT_REPLICA) remote add origin "$(COMPOSER_GITREPO)"
	fi
	$(GIT_REPLICA) remote remove origin
	$(GIT_REPLICA) remote add origin "$(COMPOSER_GITREPO)"
	$(GIT_REPLICA) fetch --all
	$(GIT_REPLICA) archive \
		--verbose \
		--remote="$(COMPOSER_GITREPO)" \
		--format="tar" \
		--prefix="" \
		"$(COMPOSER_VERSION)" \
		$(foreach FILE,$(COMPOSER_FILES),"$(FILE)") \
		| \
		$(TAR) -C "$(CURDIR)" -f -
	if [ -f "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" ]; then
		$(CP) "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" "$(CURDIR)/$(COMPOSER_SETTINGS)"
	fi
	$(TIMESTAMP) "$(CURDIR)/.$(COMPOSER_BASENAME).$(REPLICA)"

$(REPLICA)-%:
	$(RUNMAKE) --directory "$(CURDIR)" \
		COMPOSER_VERSION="$(*)" \
		$(REPLICA)

.PHONY: $(UPGRADE)
$(UPGRADE):
	$(call GIT_REPO,$(MDVIEWER_DST),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
	cd "$(MDVIEWER_DST)" &&
		chmod 755 ./build.sh &&
		$(BUILD_ENV) ./build.sh
	$(call GIT_REPO,$(REVEALJS_DST),$(REVEALJS_SRC),$(REVEALJS_CMT))
	$(call WGET_FILE,$(W3CSLIDY_SRC))
	$(call UNZIP,$(W3CSLIDY_DST),$(W3CSLIDY_SRC))

########################################

ifneq ($(BUILD_MSYS),)
ifneq ($(wildcard $(MSYS_SHELL)),)
$(STRAPIT)-git:	override SHELL := $(MSYS_SHELL)
$(FETCHIT)-%:	override SHELL := $(MSYS_SHELL)
$(BUILDIT)-%:	override SHELL := $(MSYS_SHELL)
endif
endif

.PHONY: $(STRAPIT)
ifeq ($(BUILD_MSYS),)
$(STRAPIT): $(STRAPIT)-check
else
$(STRAPIT): $(STRAPIT)-msys $(STRAPIT)-dlls
endif
$(STRAPIT): $(STRAPIT)-git
$(STRAPIT): $(FETCHIT)-make $(BUILDIT)-make
$(STRAPIT): $(STRAPIT)-ghc-bin $(STRAPIT)-ghc-lib

.PHONY: $(FETCHIT)
$(FETCHIT): $(BUILDIT)-clean
$(FETCHIT): $(FETCHIT)-cabal
$(FETCHIT): $(FETCHIT)-make $(FETCHIT)-git
$(FETCHIT): $(FETCHIT)-ghc $(FETCHIT)-haskell $(FETCHIT)-pandoc

.PHONY: $(BUILDIT)
$(BUILDIT): $(BUILDIT)-make $(BUILDIT)-git
$(BUILDIT): $(BUILDIT)-ghc $(BUILDIT)-haskell $(BUILDIT)-pandoc
$(BUILDIT): $(BUILDIT)-bindir
$(BUILDIT): $(BUILDIT)-clean
$(BUILDIT): $(CHECKIT)

do-%: $(FETCHIT)-% $(BUILDIT)-%
	@echo >/dev/null

.PHONY: $(FETCHIT)-cabal
$(FETCHIT)-cabal:
	$(BUILD_ENV_MINGW) $(CABAL) update

.PHONY: $(BUILDIT)-clean
$(BUILDIT)-clean:
	$(MKDIR) "$(COMPOSER_ABODE)/.cabal"
	$(MKDIR) "$(COMPOSER_STORE)/.cabal"
ifneq ($(BUILD_MSYS),)
	$(MKDIR) "$(APPDATA)/cabal"
	$(CP) "$(APPDATA)/cabal/"* "$(COMPOSER_STORE)/.cabal/" || true
	$(CP) "$(COMPOSER_STORE)/.cabal/"* "$(APPDATA)/cabal/" || true
endif
	$(CP) "$(COMPOSER_ABODE)/.cabal/"* "$(COMPOSER_STORE)/.cabal/" || true
	$(CP) "$(COMPOSER_STORE)/.cabal/"* "$(COMPOSER_ABODE)/.cabal/" || true
ifneq ($(BUILD_MSYS),)
	$(RM) "$(COMPOSER_ABODE)/"*.exe
endif

.PHONY: $(BUILDIT)-bindir
$(BUILDIT)-bindir:
	$(MKDIR) "$(COMPOSER_PROGS)/bin"
	$(MKDIR) "$(COMPOSER_PROGS)/libexec"
	$(CP) "$(COMPOSER_ABODE)/bin/"{make,git,pandoc}* "$(COMPOSER_PROGS)/bin/"
	$(CP) "$(COMPOSER_ABODE)/libexec/git-core" "$(COMPOSER_PROGS)/libexec/"
ifneq ($(BUILD_MSYS),)
	$(CP) "$(MSYS_BIN_DST)/usr/bin/"{,un}zip.exe "$(COMPOSER_PROGS)/bin/"
	$(BUILD_ENV) ldd "$(COMPOSER_PROGS)/bin/"*.exe "$(COMPOSER_PROGS)/libexec/git-core/"{,*/}* 2>/dev/null | $(SED) -n "s|^.*(msys[-][^ ]+[.]dll)[ ][=][>].+$$|\1|gp" | sort --unique | while read FILE; do
		$(CP) "$(MSYS_BIN_DST)/usr/bin/$${FILE}" "$(COMPOSER_PROGS)/bin/"
	done
endif

.PHONY: $(CHECKIT)
$(CHECKIT):
	@$(HELPOUT1) "Project"		"$(COMPOSER_BASENAME) Version"	"Current Version(s)"
	@$(HELPOUT1) "----------"	"--------------------"		"--------------------"
ifneq ($(BUILD_MSYS),)
	@$(HELPOUT1) "MSYS2"		"$(MSYS_VERSION)"	"$(shell $(BUILD_ENV) $(PACMAN) --version		2>/dev/null | $(SED) -n "s|^.*(Pacman[ ]v[^ ]+).*$$|\1|gp")"
endif
	@$(HELPOUT1) "GNU Make"		"$(MAKE_VERSION)"	"$(shell $(BUILD_ENV) make --version			2>/dev/null | $(SED) -n "s|^GNU[ ]Make[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "Git"		"$(GIT_VERSION)"	"$(shell $(BUILD_ENV) git --version			2>/dev/null | $(SED) -n "s|^.*version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "Pandoc"		"$(PANDOC_CMT)"		"$(shell $(BUILD_ENV) pandoc --version			2>/dev/null | $(SED) -n "s|^pandoc([.]exe)?[ ]([^ ]+).*$$|\2|gp")"
	@$(HELPOUT1) "- Types"		"$(PANDOC_TYPE_CMT)"	"$(shell $(BUILD_ENV) cabal info pandoc-types		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- TeXMath"	"$(PANDOC_MATH_CMT)"	"$(shell $(BUILD_ENV) cabal info texmath		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- HighlightKate"	"$(PANDOC_HIGH_CMT)"	"$(shell $(BUILD_ENV) cabal info highlighting-kate	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- CiteProc"	"$(PANDOC_CITE_CMT)"	"$(shell $(BUILD_ENV) pandoc-citeproc --version		2>/dev/null | $(SED) -n "s|^pandoc-citeproc[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "Haskell"		"$(HASKELL_CMT)"	"$(shell $(BUILD_ENV) cabal info haskell-platform	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "- GHC"		"$(GHC_VERSION)"	"$(shell $(BUILD_ENV) ghc --version			2>/dev/null | $(SED) -n "s|^.*version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- Cabal"		"$(CABAL_VERSION)"	"$(shell $(BUILD_ENV) cabal --version			2>/dev/null | $(SED) -n "s|^.*cabal-install[ ]version[ ]([^ ]+).*$$|\1|gp")"
	@$(HELPOUT1) "- Library"	"$(CABAL_VERSION_LIB)"	"$(shell $(BUILD_ENV) cabal info Cabal			2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HELPOUT1) "$(HELPMARK)"	"GHC Library:"		"$(GHC_VERSION_LIB)"

.PHONY: $(SHELLIT)
$(SHELLIT): $(SHELLIT)-bashrc $(SHELLIT)-vimrc
$(SHELLIT):
	@exec $(BUILD_ENV) $(BASH) || true

.PHONY: $(SHELLIT)-msys
$(SHELLIT)-msys: $(SHELLIT)-bashrc $(SHELLIT)-vimrc
$(SHELLIT)-msys:
	@if [ ! -d "$(MSYS_BIN_DST)/home/$(USERNAME)" ]; then
		$(CP) "$(MSYS_BIN_DST)/etc/skel" "$(MSYS_BIN_DST)/home/$(USERNAME)"
	fi
	@cd "$(MSYS_BIN_DST)" &&
		icacls msys2_shell.bat /grant:r $(USERNAME):f &&
		exec $(BUILD_ENV) $(WINDOWS_CMD) msys2_shell.bat || true

.PHONY: $(SHELLIT)-bashrc
$(SHELLIT)-bashrc:
	@$(MKDIR) "$(COMPOSER_ABODE)"
	@cat >"$(COMPOSER_ABODE)/.bashrc" <<'_EOF_'
		# bashrc
		#
		umask 022
		unalias -a
		set -o vi
		eval $$(dircolors 2>/dev/null)
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
		export PS1="\n// $(COMPOSER_BASENAME) \D{%FT%T%z}\n[\#/\!] (\u@\h \w)\\$$ "
		#
		export PAGER="less -RX"
		export EDITOR="vim -u $(COMPOSER_ABODE)/.vimrc -i NONE -p"
		unset VISUAL
		#
		alias more="$${PAGER}"
		alias vi="$${EDITOR}"
		#
		export LC_COLLATE="C"
		alias ll="$(LS)"
		#
		alias composer="$(RUNMAKE)"
		alias compose="$(COMPOSE)"
		alias home="cd $(COMPOSER_DIR)"
		#
		source "$(COMPOSER_ABODE)/.bashrc.custom"
		# end of file
	_EOF_
	@if [ ! -f "$(COMPOSER_ABODE)/.bashrc.custom" ]; then
		@echo >"$(COMPOSER_ABODE)/.bashrc.custom"
	fi

.PHONY: $(SHELLIT)-vimrc
$(SHELLIT)-vimrc:
	@$(MKDIR) "$(COMPOSER_ABODE)"
	@cat >"$(COMPOSER_ABODE)/.vimrc" <<'_EOF_'
		" vimrc
		"WORK
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
		source "$(COMPOSER_ABODE)/.vimrc.custom"
		" end of file
	_EOF_
	@if [ ! -f "$(COMPOSER_ABODE)/.vimrc.custom" ]; then
		@echo >"$(COMPOSER_ABODE)/.vimrc.custom"
	fi

override define AUTOTOOLS_BUILD =
	cd "$(1)" &&
		$(BUILD_ENV) ./configure \
			--exec-prefix="$(2)" \
			--prefix="$(2)" \
			$(3) \
			&&
		$(BUILD_ENV) $(MAKE) $(4) &&
		$(BUILD_ENV) $(MAKE) install
endef
override define AUTOTOOLS_BUILD_MINGW =
	cd "$(1)" &&
		$(BUILD_ENV_MINGW) ./configure \
			--exec-prefix="$(2)" \
			--prefix="$(2)" \
			$(3) \
			&&
		$(BUILD_ENV_MINGW) $(MAKE) $(4) &&
		$(BUILD_ENV_MINGW) $(MAKE) install
endef

ifneq ($(BUILD_GHC_78),)
override CHECK_LIB_NAME := Curses
override CHECK_LIB_SRC := lib{,n}curses.so
override CHECK_LIB_DST := libtinfo.so.5
else
override CHECK_LIB_NAME := GMP
override CHECK_LIB_SRC := libgmp.so
override CHECK_LIB_DST := libgmp.so.3
endif

.PHONY: $(STRAPIT)-check
$(STRAPIT)-check:
	@if [ ! -f "$(shell ls /{,usr/}lib*/$(CHECK_LIB_DST) 2>/dev/null | tail -n1)" ]; then
		@$(HELPLVL1)
		@$(HELPOUT2)
		@$(HELPOUT2) "ERROR:"
		@$(HELPOUT2)
		@$(HELPOUT2) "Could not find '$(CHECK_LIB_DST)' library file."
		@$(HELPOUT2)
		@$(HELPOUT2) "DETAILS:"
		@$(HELPOUT2)
		@$(HELPOUT2) "The pre-built GHC requires this specific file in order to run,"
		@$(HELPOUT2) "but not necessarily this version of $(CHECK_LIB_NAME)."
		@$(HELPOUT2)
		@$(HELPOUT2) "You can likely 'ln -s' one of the files below"
		@$(HELPOUT2) "to something like '/usr/lib/$(CHECK_LIB_DST)' to work around this."
		@echo
		@$(LS) /{,usr/}lib*/$(CHECK_LIB_SRC)* 2>/dev/null || true
		@echo
		@$(HELPOUT2) "If no files are listed above, you may need to"
		@$(HELPOUT2) "install some version of the $(CHECK_LIB_NAME) library to continue."
		@$(HELPOUT2)
		@$(HELPOUT2) "NOTES:"
		@$(HELPOUT2)
		@$(HELPOUT2) "This message was produced by $(COMPOSER_BASENAME)."
		@$(HELPOUT2)
		@$(HELPOUT2) "If you know this to be an error, you can remove the"
		@$(HELPOUT2) "'$(STRAPIT)-check' dependency from '$(STRAPIT)' in:"
		@$(HELPOUT2)
		@$(HELPOUT2) "$(COMPOSER)"
		@$(HELPOUT2)
		@$(HELPLVL1)
		@exit 1
	fi

.PHONY: $(STRAPIT)-msys
$(STRAPIT)-msys:
	$(call WGET_FILE,$(MSYS_BIN_SRC))
	$(call UNTAR,$(MSYS_BIN_DST),$(MSYS_BIN_SRC))
	@$(HELPLVL1)
	@$(HELPOUT2) "We need to initialize the MSYS2 environment."
	@$(HELPOUT2)
	@$(HELPOUT2) "To do this, we will pause here to open an initial shell window."
	@$(HELPOUT2)
	@$(HELPOUT2) "Once the shell window gets to a command prompt,"
	@$(HELPOUT2) "simply type 'exit' and hit ENTER to return."
	@$(HELPOUT2)
	@$(HELPOUT2) "Hit ENTER to proceed."
	@$(HELPLVL1)
	@read ENTER
	$(RUNMAKE) $(SHELLIT)-msys
	@$(HELPLVL1)
	@$(HELPOUT2) "The shell window has been launched."
	@$(HELPOUT2)
	@$(HELPOUT2) "It should have processed to a command prompt,"
	@$(HELPOUT2) "after which you typed 'exit' and hit ENTER."
	@$(HELPOUT2)
	@$(HELPOUT2) "If everything was successful (no errors above),"
	@$(HELPOUT2) "the build process can continue without interaction."
	@$(HELPOUT2)
	@$(HELPOUT2) "Hit ENTER to proceed, or CTRL-C to quit."
	@$(HELPLVL1)
	@read ENTER
	$(BUILD_ENV) $(PACMAN) --refresh
	$(BUILD_ENV) $(PACMAN) --needed $(PACMAN_BASE_LIST)
	cd "$(MSYS_BIN_DST)" && $(BUILD_ENV) $(WINDOWS_CMD) autorebase.bat
	$(BUILD_ENV) $(PACMAN) \
		--needed \
		--sysupgrade \
		$(PACMAN_PACKAGES_LIST)
	$(BUILD_ENV) $(PACMAN) --clean

.PHONY: $(STRAPIT)-dlls
$(STRAPIT)-dlls:
	$(MKDIR) "$(COMPOSER_ABODE)/bin"
	$(CP) "$(MSYS_BIN_DST)/usr/bin/"*.dll "$(COMPOSER_ABODE)/bin/"

.PHONY: $(FETCHIT)-make
$(FETCHIT)-make:
	$(call GIT_REPO,$(MAKE_DST),$(MAKE_SRC),$(MAKE_CMT))
	cd "$(MAKE_DST)" &&
		$(BUILD_ENV) autoreconf -i &&
		$(BUILD_ENV) ./configure &&
		$(BUILD_ENV) $(MAKE) update

.PHONY: $(BUILDIT)-make
# thanks for the 'texinfo' fix below: http://gnu-make.2324884.n4.nabble.com/Cannot-build-the-GNU-make-manual-with-development-version-of-Texinfo-td4530.html
$(BUILDIT)-make:
	$(SED) -i \
		-e "s|([@]item)x|\1|g" \
		"$(MAKE_DST)/doc/make.texi"
	$(call AUTOTOOLS_BUILD,$(MAKE_DST),$(COMPOSER_ABODE))

.PHONY: $(STRAPIT)-git
$(STRAPIT)-git:
	$(call WGET_FILE,$(GIT_BIN_SRC))
	$(call UNTAR,$(GIT_BIN_DST),$(GIT_BIN_SRC))
	cd "$(GIT_BIN_DST)" &&
		$(BUILD_ENV) $(MAKE) configure
	$(call AUTOTOOLS_BUILD,$(GIT_BIN_DST),$(COMPOSER_ABODE))

.PHONY: $(FETCHIT)-git
$(FETCHIT)-git:
	$(call GIT_REPO,$(GIT_DST),$(GIT_SRC),$(GIT_CMT))
	cd "$(GIT_DST)" &&
		$(BUILD_ENV) $(MAKE) configure

.PHONY: $(BUILDIT)-git
$(BUILDIT)-git:
	$(call AUTOTOOLS_BUILD,$(GIT_DST),$(COMPOSER_ABODE))

.PHONY: $(STRAPIT)-ghc-bin
# thanks for the 'getnameinfo' fix below: https://www.mail-archive.com/haskell-cafe@haskell.org/msg60731.html
# thanks for the 'createDirectory' fix below: https://github.com/haskell/cabal/issues/1698
$(STRAPIT)-ghc-bin:
	$(call WGET_FILE,$(GHC_BIN_SRC))
	$(call WGET_FILE,$(CBL_BIN_SRC))
	$(call UNTAR,$(GHC_BIN_DST),$(GHC_BIN_SRC))
	$(call UNTAR,$(CBL_BIN_DST),$(CBL_BIN_SRC))
ifeq ($(BUILD_MSYS),)
	$(call AUTOTOOLS_BUILD_MINGW,$(GHC_BIN_DST),$(BUILD_STRAP),,show)
else
	$(MKDIR) "$(BUILD_STRAP)"
	$(CP) "$(GHC_BIN_DST)/"* "$(BUILD_STRAP)/"
	@cat >"$(CBL_BIN_DST)/bootstrap.patch.sh" <<'_EOF_'
		#!/bin/bash
		$(SED) -i \
			-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" \
			-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" \
			-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" \
			"$(CBL_BIN_DST)/network-"*"/include/HsNet.h"
		# end of file
	_EOF_
	$(SED) -i \
		-e "s|^(.+[{]GZIP[}].+)$$|\1\n\"$(CBL_BIN_DST)/bootstrap.patch.sh\"|g" \
		"$(CBL_BIN_DST)/bootstrap.sh"
	$(SED) -i \
		-e "s|createDirectoryIfMissingVerbose[ ]verbosity[ ]False[ ]distDirPath||g" \
		"$(CBL_BIN_DST)/Distribution/Client/Install.hs"
endif
	$(SED) -i \
		-e "s|^(CABAL_VER[=][\"])[^\"]+|\1$(CABAL_VERSION_LIB)|g" \
		"$(CBL_BIN_DST)/bootstrap.sh"
	cd "$(CBL_BIN_DST)" &&
		$(BUILD_ENV_MINGW) PREFIX="$(call MINGW_PATH,$(BUILD_STRAP))" \
			./bootstrap.sh --global

.PHONY: $(STRAPIT)-ghc-lib
$(STRAPIT)-ghc-lib:
	$(RUNMAKE) $(FETCHIT)-cabal
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL,$(call MINGW_PATH,$(BUILD_STRAP))) \
		$(subst |,-,$(GHC_LIBRARIES_LIST))

.PHONY: $(FETCHIT)-ghc
$(FETCHIT)-ghc:
	$(call GIT_REPO,$(GHC_DST),$(GHC_SRC),$(GHC_CMT),$(GHC_BRANCH))
	$(call GIT_SUBMODULE,$(GHC_DST))
	$(SED) -i \
		-e "s|^([.][ ]+[-][ ]+ghc[.]git)|#\1|g" \
		"$(GHC_DST)/packages"
	$(SED) -i \
		-e "s|[-]d([ ][^ ]+[.]git)|-f\1|g" \
		"$(GHC_DST)/sync-all"
	cd "$(GHC_DST)" &&
		$(BUILD_ENV_MINGW) ./sync-all get &&
		$(BUILD_ENV_MINGW) ./sync-all fetch --all &&
		$(BUILD_ENV_MINGW) ./sync-all checkout --force -B $(GHC_BRANCH) $(GHC_CMT) &&
		$(BUILD_ENV_MINGW) ./sync-all reset --hard
	$(call GIT_SUBMODULE,$(GHC_DST))
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
#>			"$(FILE)"
#>	)
	cd "$(GHC_DST)" &&
		$(BUILD_ENV_MINGW) ./boot

.PHONY: $(BUILDIT)-ghc
# thanks for the 'removeFiles' fix below: https://ghc.haskell.org/trac/ghc/ticket/7712
$(BUILDIT)-ghc:
	$(foreach FILE,\
		$(GHC_DST)/driver/ghci/ghc.mk \
		$(GHC_DST)/ghc/ghc.mk \
		,\
		$(SED) -i \
			-e "s|(call[ ]removeFiles[,])(..GHCII_SCRIPT.)|\1\"\2\"|g" \
			-e "s|(call[ ]removeFiles[,])(..DESTDIR...bindir.[/]ghc.exe)|\1\"\2\"|g" \
			"$(FILE)"
	)
	$(call AUTOTOOLS_BUILD_MINGW,$(GHC_DST),$(COMPOSER_ABODE))
	$(RM) "$(BUILD_STRAP)/bin/ghc"*
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL_MINGW,$(COMPOSER_ABODE)) \
		Cabal-$(CABAL_VERSION_LIB)

.PHONY: $(FETCHIT)-haskell
$(FETCHIT)-haskell:
	$(call GIT_REPO,$(HASKELL_DST),$(HASKELL_SRC),$(HASKELL_CMT))
	$(SED) -i \
		-e "s|(GHC_VER[=])[.0-9]+$$|\1$(GHC_VERSION)|g" \
		"$(HASKELL_DST)/src/generic/tarball/configure.ac"
	$(SED) -i \
		$(foreach FILE,$(HASKELL_UPGRADE_LIST),\
			-e "s|([ ]+$(word 1,$(subst |, ,$(FILE)))[ ]+[=][=])([^,]+)|\1$(word 2,$(subst |, ,$(FILE)))|g" \
		) \
		"$(HASKELL_DST)/haskell-platform.cabal"
	$(SED) -i \
		-e "s|^(for[ ]pkg[ ]in[ ].[{]SRC_PKGS[}])$$|\1 $(subst |,-,$(HASKELL_UPGRADE_LIST))|g" \
		"$(HASKELL_DST)/src/generic/prepare.sh"
	cd "$(HASKELL_DST)/src/generic" &&
		$(BUILD_ENV_MINGW) ./prepare.sh
ifneq ($(BUILD_MSYS),)
	$(SED) -i \
		-e "s|^unix[-].+$$|$(subst |,-,$(filter Win32|%,$(GHC_BASE_LIBRARIES_LIST)))|g" \
		"$(HASKELL_TAR)/packages/core.packages"
	$(foreach FILE,\
		$(HASKELL_TAR)/packages/haskell-platform-$(HASKELL_CMT)/haskell-platform.cabal \
		$(HASKELL_TAR)/packages/platform.packages \
		,\
		$(SED) -i \
			-e "/(GLU|OpenGL)/d" \
			"$(FILE)"
	)
endif
	$(foreach FILE,$(HASKELL_PATCH_LIST),\
		$(call PATCH,$(HASKELL_TAR)/packages/$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE))))
	)

.PHONY: $(BUILDIT)-haskell
# thanks for the 'GHC_PACKAGE_PATH' fix below: http://www.reddit.com/r/haskell/comments/1f8730/basic_guide_on_how_to_install_ghcplatform_manually
# thanks for the 'programFindLocation' fix below: https://github.com/albertov/hdbc-postgresql/commit/d4cef4dd288432141dab6365699317f2bb26c489
#	found by: https://github.com/haskell/cabal/issues/1467
# thanks for the 'wspiapi.h' fix below: https://github.com/nurupo/InsertProjectNameHere/commit/23f13cd95d5d9afaadd859a4d256986817e613b9
#	found by: https://github.com/irungentoo/toxcore/issues/92
#	then by: https://github.com/irungentoo/toxcore/pull/94
$(BUILDIT)-haskell:
	$(SED) -i \
		-e "s|^([ ]+GHC_PACKAGE_PATH[=].+)|#\1|g" \
		"$(HASKELL_TAR)/scripts/build.sh"
	$(SED) -i \
		-e "s|^([ ]+programFindLocation[ ][=][ ].x)([ ][-])|\1 _\2|g" \
		"$(HASKELL_TAR)/packages/haskell-platform-$(HASKELL_CMT)/Setup.hs"
ifeq ($(BUILD_MSYS),)
	$(call AUTOTOOLS_BUILD_MINGW,$(HASKELL_TAR),$(COMPOSER_ABODE),--disable-user-install)
else
	$(SED) -i \
		-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" \
		-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" \
		-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" \
		-e "s|WSPIAPI[_]H|WS2TCPIP_H|g" \
		-e "s|wspiapi[.]h|ws2tcpip.h|g" \
		"$(HASKELL_TAR)/packages/network-"*"/include/HsNet.h"
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL_MINGW,$(COMPOSER_ABODE)) \
		$(foreach FILE,$(shell cat "$(HASKELL_TAR)/packages/platform.packages"),\
			"$(HASKELL_TAR)/packages/$(FILE)" \
		)
endif

.PHONY: $(FETCHIT)-pandoc-type
$(FETCHIT)-pandoc-type:
	$(call GIT_REPO,$(PANDOC_TYPE_DST),$(PANDOC_TYPE_SRC),$(PANDOC_TYPE_CMT))

.PHONY: $(FETCHIT)-pandoc-math
$(FETCHIT)-pandoc-math:
	$(call GIT_REPO,$(PANDOC_MATH_DST),$(PANDOC_MATH_SRC),$(PANDOC_MATH_CMT))

.PHONY: $(FETCHIT)-pandoc-high
$(FETCHIT)-pandoc-high:
	$(call GIT_REPO,$(PANDOC_HIGH_DST),$(PANDOC_HIGH_SRC),$(PANDOC_HIGH_CMT))

.PHONY: $(FETCHIT)-pandoc-cite
$(FETCHIT)-pandoc-cite:
	$(call GIT_REPO,$(PANDOC_CITE_DST),$(PANDOC_CITE_SRC),$(PANDOC_CITE_CMT))

.PHONY: $(FETCHIT)-pandoc
$(FETCHIT)-pandoc: $(FETCHIT)-pandoc-type
$(FETCHIT)-pandoc: $(FETCHIT)-pandoc-math
$(FETCHIT)-pandoc: $(FETCHIT)-pandoc-high
$(FETCHIT)-pandoc: $(FETCHIT)-pandoc-cite
$(FETCHIT)-pandoc:
	$(call GIT_REPO,$(PANDOC_DST),$(PANDOC_SRC),$(PANDOC_CMT))
	$(call GIT_SUBMODULE,$(PANDOC_DST))

.PHONY: $(BUILDIT)-pandoc-deps
$(BUILDIT)-pandoc-deps:
	echo && echo "$(HELPMARK) Dependencies"
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL_MINGW,$(COMPOSER_ABODE)) \
		$(subst |,-,$(PANDOC_DEPENDENCIES_LIST))
#>		--enable-tests
	$(BUILD_ENV_MINGW) $(call CABAL_INSTALL_MINGW,$(COMPOSER_ABODE)) \
		--only-dependencies \
		$(PANDOC_TYPE_DST) \
		$(PANDOC_MATH_DST) \
		$(PANDOC_HIGH_DST) \
		$(PANDOC_CITE_DST) \
		$(PANDOC_DST)
#>		--enable-tests
	cd "$(PANDOC_HIGH_DST)" && \
		$(BUILD_ENV_MINGW) $(MAKE) prep

.PHONY: $(BUILDIT)-pandoc-type
$(BUILDIT)-pandoc-type:
	$(call PANDOC_BUILD,$(PANDOC_TYPE_DST))

.PHONY: $(BUILDIT)-pandoc-math
$(BUILDIT)-pandoc-math:
	$(call PANDOC_BUILD,$(PANDOC_MATH_DST))

.PHONY: $(BUILDIT)-pandoc-high
$(BUILDIT)-pandoc-high:
	$(call PANDOC_BUILD,$(PANDOC_HIGH_DST))

.PHONY: $(BUILDIT)-pandoc
$(BUILDIT)-pandoc: $(BUILDIT)-pandoc-deps
$(BUILDIT)-pandoc: $(BUILDIT)-pandoc-type
$(BUILDIT)-pandoc: $(BUILDIT)-pandoc-math
$(BUILDIT)-pandoc: $(BUILDIT)-pandoc-high
$(BUILDIT)-pandoc:
	$(call PANDOC_BUILD,$(PANDOC_DST))
	$(call PANDOC_BUILD,$(PANDOC_CITE_DST))
	@echo
	$(BUILD_ENV) pandoc --version

#>			--enable-tests
#>		echo && echo "$(HELPMARK) Test [$(1)]" &&
#>		$(BUILD_ENV_MINGW) $(CABAL) test &&
override define PANDOC_BUILD =
	cd "$(1)" &&
		echo && echo "$(HELPMARK) Configure [$(1)]" &&
		$(BUILD_ENV_MINGW) $(CABAL) configure \
			--prefix="$(COMPOSER_ABODE)" \
			--flags="embed_data_files http-conduit" \
			--disable-executable-dynamic \
			--disable-shared \
			&&
		echo && echo "$(HELPMARK) Build [$(1)]" &&
		$(BUILD_ENV_MINGW) $(CABAL) build &&
		echo && echo "$(HELPMARK) Install [$(1)]" &&
		$(BUILD_ENV_MINGW) $(call CABAL_INSTALL_MINGW,$(COMPOSER_ABODE))
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
	$(foreach FILE,$(COMPOSER_TARGETS),\
		$(RM) \
			"$(FILE)" \
			"$(FILE).$(TYPE_HTML)" \
			"$(FILE).$(TYPE_LPDF)" \
			"$(FILE).$(PRES_EXTN)" \
			"$(FILE).$(SHOW_EXTN)" \
			"$(FILE).$(TYPE_DOCX)" \
			"$(FILE).$(TYPE_EPUB)"
	)
	$(RM) $(COMPOSER_STAMP)

.PHONY: whoami
whoami:
	@$(HELPLVL1)
	@$(HELPOUT2) "CURDIR:"			"[$(CURDIR)]"
	@$(HELPOUT2) "COMPOSER_TARGETS:"	"[$(COMPOSER_TARGETS)]"
	@$(HELPOUT2) "COMPOSER_SUBDIRS:"	"[$(COMPOSER_SUBDIRS)]"
	@$(HELPOUT2) "COMPOSER_DEPENDS:"	"[$(COMPOSER_DEPENDS)]"
	@$(HELPLVL2)
	@$(HELPOUT2) "TYPE:"	"[$(TYPE)]"
	@$(HELPOUT2) "BASE:"	"[$(BASE)]"
	@$(HELPOUT2) "LIST:"	"[$(LIST)]"
	@$(HELPOUT2) "_CSS:"	"[$(_CSS)]"
	@$(HELPOUT2) "CSS:"	"[$(CSS)]"
	@$(HELPOUT2) "TTL:"	"[$(TTL)]"
	@$(HELPOUT2) "TOC:"	"[$(TOC)]"
	@$(HELPOUT2) "LVL:"	"[$(LVL)]"
	@$(HELPOUT2) "OPT:"	"[$(OPT)]"
	@$(HELPLVL1)

.PHONY: settings
settings:
	@$(HELPLVL2)
	@$(HELPOUT2) "CURDIR: [$(CURDIR)]"
	@$(HELPOUT2) "TYPE:   [$(TYPE)]"
	@$(HELPOUT2) "BASE:   [$(BASE)]"
	@$(HELPOUT2) "LIST:   [$(LIST)]"
	@$(HELPOUT2) "_CSS:   [$(_CSS)]"
	@$(HELPOUT2) "CSS:    [$(CSS)]"
	@$(HELPOUT2) "TTL:    [$(TTL)]"
	@$(HELPOUT2) "TOC:    [$(TOC)]"
	@$(HELPOUT2) "LVL:    [$(LVL)]"
	@$(HELPOUT2) "OPT:    [$(OPT)]"
	@$(HELPLVL2)

.PHONY: subdirs $(COMPOSER_SUBDIRS)
subdirs: $(COMPOSER_SUBDIRS)
$(COMPOSER_SUBDIRS):
	$(MAKE) --directory "$(CURDIR)/$(@)"

.PHONY: print
print: $(COMPOSER_STAMP)
$(COMPOSER_STAMP): *.$(COMPOSER_EXT)
	@$(LS) $(?)

########################################

.PHONY: $(COMPOSER_TARGET)
$(COMPOSER_TARGET): $(BASE).$(EXTENSION)

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): settings $(LIST)
	$(BUILD_ENV) $(PANDOC)
	$(TIMESTAMP) "$(CURDIR)/$(COMPOSER_STAMP)"

$(BASE).$(EXTENSION): $(LIST)
	$(MAKEDOC) TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(^)"

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
