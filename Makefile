#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################
override VIM_OPTIONS := vim: foldmethod=marker foldtext=foldtext() foldlevel=0 filetype=make
override VIM_FOLDING := {{{1
################################################################################
# Release Checklist:
#	* Upgrade
#		* Update: Tooling Versions
#		* Update: Pandoc Options
#		* Update: TYPE_TARGETS
#	* Verify
#		* `make COMPOSER_DEBUGIT="1" _release`
#		* `make all` (examine)
#		* `make debug-all` && `make debug-file` (review)
#		* `make test-all` && `make test-file` (review)
#		* `mv Composer-*.log artifacts/`
#	* Publish
#		* Update: README.md (#WORKING release notes?)
#		* Review: `make docs`
#		* Git commit and tag
#		* Update: COMPOSER_VERSION
################################################################################
#WORK
#	test: windows: wsl/debian(testing) -> sudo apt-get install pandoc yq texlive
#	test: mac osx: macports -> sudo port gmake install pandoc yq texlive
#WORK
#	https://www.w3.org/community/markdown/wiki/MarkdownImplementations
#	http://filoxus.blogspot.com/2008/01/how-to-insert-watermark-in-latex.html
#WORK
#	features
#		dual source targets (and empty COMPOSER_EXT) = readme/readme.html readme.md/readme.html readme.md/readme.md.html
#			and now a third option! = make MANUAL.hml LIST="README.md LICENSE.md"
#		document effects of $TOC and $LVL = test this first...
#		css_alt
#		install-all / cleaner-all / all-all
#		COMPOSER_TARGETS / COMPOSER_SUBDIRS / COMPOSER_IGNORES auto-detection behavior
#			will always auto-detect unless they are defined or COMPOSER_IGNORES or $(NOTHING)
#			COMPOSER_SUBDIRS may pick up directories that override core recipies ('docs' and 'test')
#				warning: overriding recipe for target 'pandoc'
#				warning: ignoring old recipe for target 'pandoc'
#			COMPOSER_IGNORES removes from both targets and subdirs
#			also, there is *-$(CLEANER) target stripping
#			DEFAULT_GOAL does not work = this is what COMPOSER_TARGETS is for
#		document "*-clean"
#			if COMPOSER_TARGETS is only *-clean entries, it is empty
#			edge case: the '.null' file will never be deleted, even if it is a target
#			document: we have $(DO_BOOK)-%!
#		somewhere: per-target variables = book-testing.html: export override TOC := 1
#			also, random note that extensions must match to get picked up
#				time to decide about TYPE/BASE/LIST... probably need to just drop these internals and only use the long/short ones...
#					another option = C_TYPE, etc.?
#			beware, internal variables like $TESTING, will be overwritten = ummm, no they won't, silly...
#		COMPOSER_INCLUDE
#			global to local = COMPOSER_DIR + COMPOSER_SETTINGS
#			COMPOSER_CSS wins over everything but COMPOSER_SETTINGS, and follows same rules for finding it
#			COMPOSER_INCLUDE includes all the intermediary COMPOSER_SETTINGS files
#			using := is the only thing supported = variable definitions must match COMPOSER_INCLUDE_REGEX
#			using COMPOSER_TARGETS and COMPOSER_SUBDIRS and COMPOSER_IGNORES is a commitment...
#		COMPOSER_DEPENDS
#			disables MAKEJOBS and is single-threaded
#			ordering only applies to $DOITALL = $INSTALL and $CLEANER always go top-down
#			dependencies using "parent: child" targets
#		nice new little feature: make subdirs-*, such as subdirs-list
#	notes
#		variable aliases, order of precedence (now that it is fixed)
#		we can use *_DEFAULTS variables in the documentation!  create more of these...?
#		a brief note about filenames with spaces and symlinks...?
#		document empty COMPOSER_EXT value
#		do not to use $(COMPOSER_RESERVED) or $(COMPOSER_RESERVED_SPECIAL) names (or as prefixes [:-])
#			meta: $(info $(addsuffix s,$(COMPOSER_RESERVED_SPECIAL)))
#			individual: $(info $(addsuffix -,$(COMPOSER_RESERVED_SPECIAL)))
#		do not start with $(COMPOSER_REGEX_PREFIX) = these are special/hidden and skipped by detection
#		document build times (~1100 dirs, ~87k files): 1 thead = ~75m, 10 = ~120m, 50 = resource exhaustion)
#			every effort has been made to parallelize (word?)
#			double-check xargs commands, and add to clean
#			J=1
#				#WORKING:NOW
#			J=10
#				install user: 1m3.932s
#				all user: 119m33.289s
#	code
#		PANDOC_CMT / REVEALJS_CMT / MDVIEWER_CMT
#			COMPOSER_SETTINGS only
#			for windows/darwin, document the need to do a "make _updatee" and/or add "override" for the right "pandoc" version
#			for windows/darwin, results of "_update-all" will be variable and untested
#			all that is done for windows/darwin is to keep the pandoc version up-to-date with wsl/debian and macports
#			windows/darwin should work just fine, provided the pandoc version matches
#			darwin also needs gmake, and the /opt/local/libexec/gnubin needs to be higher in $PATH
#		document *-$(DOITALL) ...and COMPOSER_DOITALL_*?
#			DEBUGIT-file / TESTING-file
#			NOTHING ...and COMPOSER_NOTHING?
#			COMPOSER_DEBUGIT="!"...?  maybe $(TESTING) is enough?
#		document that COMPOSER_DOITALL_* and +$(MAKE) go hand-in-hand, and are how recursion is handled
#			COMPOSER_EXPORTED! = need to make a note for me?
#WORKING
#	site
#		post = comments ability through *-comments-$(date) files
#		index = yq crawl of directory to create a central file to build "search" pages out of
#WORKING:NOW
#	add a "force" variable/option
#	double-check all "$$" and the new defines, to make sure the expanded make_database text makes sense...
#	symlink (e.g.../) in dependencies...?  if so, document!
#	convert all output to markdown
#		replace license and readme with help/license output
#		ensure all output fits within 80 characters
#		do a mouse-select of all text, to ensure proper color handling
#		the above should be reviewed during testing... maybe output some notes in $(TESTING)...?
#	dynamic import of targets
#		add some sort of composer_readme variable?
#		make COMPOSER_DOCOLOR= config | grep -vE "^[#]"
#		make COMPOSER_DOCOLOR= check | grep -vE "^[#]"
#WORKING:NOW
#	specials...
#		actually, need something better for site, which will probably remain singular...
#			a-ha!  create page-*, which we can later use to dynamically "dependency" in post-* files (page-index.html)
#				this will also allow for interesting things, like dynamic *.md files which get built first... or manual pages of posts (index!)
#				verify that pandoc ignores leading yaml/json, and that yq can be used to just grab the headers?
#			a page-* of post-*s will be <variable> post-*s truncated to <variable> length (and then [...])
#			this way, manual page-*s can be created that stay static (like gary-os and composer readmes on "project" pages)
#			also, the dynamic "index" pages, which pull in all post-*s that match
#				this can look like index: entries that use the dependencies to know which index to build?
#	long term, physical post-* files should automatically get pulled in (so should book-* [redundant]; add test case)
#		will need to do something with "targets" output, which will get super crowded (maybe only if there are dependencies? affirmative.)
#			they will show up in composer_targets, anyway, right? yes, ugly, parse them out and let *-all handle it
#			as they are parsed out of composer_targets, $(eval *-all: *) and $(eval $(subst post-,,*): *) them
#			test case this instead... it should be identical for all of book/page/post...
#		does the file take precedence over the target, or will both happen?  probably just the target, which is a better match
#	add findutils back in... we're going to need it later, which is probably why we had it in there in the first place...
#		got it... best practice is to keep the site in <variable=.site>, and ln ../ in the desired files
#		this way, there is a prestine source directory, things can be pulled in selectively, and we can pull .site into gh-pages
#		actually, no, .site=./; if keeping them separate is desired, a separate directory should be used...
#	need to truly switch to test-driven coding, where the code is being written along with the test...

#WORK
################################################################################
# }}}1
################################################################################
# {{{1 Composer Globals --------------------------------------------------------
################################################################################

override COMPOSER_COMPOSER		:= Gary B. Genett
override COMPOSER_VERSION		:= v3.0

override COMPOSER_BASENAME		:= Composer
override COMPOSER_FULLNAME		:= $(COMPOSER_BASENAME) CMS $(COMPOSER_VERSION)
override COMPOSER_FILENAME		:= $(COMPOSER_BASENAME)-$(COMPOSER_VERSION)

########################################

override COLUMNS			:= 80
override HEAD_MAIN			:= 1

override COMPOSER_SETTINGS		:= .composer.mk
override COMPOSER_CSS			:= .composer.css
override COMPOSER_STAMP_DEFAULT		:= .composed
override COMPOSER_EXT_DEFAULT		:= .md

#> update: TYPE_TARGETS
override TYPE_DEFAULT			:= html
override EXTN_DEFAULT			:= $(TYPE_DEFAULT)

override EXAMPLE_ONE			:= README
override EXAMPLE_TWO			:= LICENSE
override EXAMPLE_OUT			:= $(COMPOSER_FILENAME).Manual

########################################

override MAKEFILE_LIST			:= $(abspath $(MAKEFILE_LIST))
override COMPOSER			:= $(lastword $(MAKEFILE_LIST))
override COMPOSER_SRC			:= $(firstword $(MAKEFILE_LIST))

override COMPOSER_DIR			:= $(abspath $(dir $(COMPOSER)))
override COMPOSER_ROOT			:= $(abspath $(dir $(lastword $(filter-out $(COMPOSER),$(MAKEFILE_LIST)))))
ifeq ($(COMPOSER_ROOT),)
override COMPOSER_ROOT			:= $(CURDIR)
endif

override COMPOSER_PKG			:= $(COMPOSER_DIR)/.sources
override COMPOSER_TMP			:= $(COMPOSER_DIR)/.tmp
override COMPOSER_ART			:= $(COMPOSER_DIR)/artifacts

########################################

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
override OUTPUT_FILENAME		= $(COMPOSER_FILENAME).$(1)-$(DATENAME).$(EXTN_TEXT)
override TESTING_DIR			:= $(COMPOSER_DIR)/.$(COMPOSER_FILENAME)

########################################

override COMPOSER_RELEASE		:=
ifeq ($(COMPOSER_DIR),$(CURDIR))
override COMPOSER_RELEASE		:= 1
ifeq ($(MAKELEVEL),0)
#> update: includes duplicates
override HELPOUT			:= usage
$(info # $(COMPOSER_FULLNAME))
$(info #	Because this is the main directory, some features are disabled)
$(info #	Please set up as '.$(COMPOSER_BASENAME)', or use '-f' (see '$(notdir $(MAKE)) $(HELPOUT)'))
endif
endif

################################################################################
# {{{1 Include Files -----------------------------------------------------------
################################################################################

override COMPOSER_INCLUDE_REGEX		= override[[:space:]]+($(if $(1),$(1),[^[:space:]]+))[[:space:]]+[$(if $(2),?,:)][=]
override COMPOSER_INCLUDES		:=
override COMPOSER_INCLUDES_LIST		:=

########################################

override COMPOSER_FIND			= $(firstword $(wildcard $(abspath $(addsuffix /$(2),$(1)))))
override define READ_ALIASES =
	$(if $(filter undefined,$(origin $(3))),\
		$(if $(filter-out undefined,$(origin $(1))),$(eval override $(3) := $($(1))); $(eval override undefine $(1))); \
		$(if $(filter-out undefined,$(origin $(2))),$(eval override $(3) := $($(2))); $(eval override undefine $(2))); \
	); \
	$(eval override undefine $(1)); \
	$(eval override undefine $(2))
endef

########################################

#> update: includes duplicates

$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)
override COMPOSER_DEBUGIT_ALL		:=
ifeq ($(COMPOSER_DEBUGIT),!)
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

override PATH_LIST			:= $(subst :, ,$(PATH))
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

override TOKEN				:= ~

########################################

ifneq ($(wildcard $(CURDIR)/$(COMPOSER_SETTINGS)),)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #SOURCE [$(CURDIR)/$(COMPOSER_SETTINGS)]))
#>include $(CURDIR)/$(COMPOSER_SETTINGS)
$(foreach FILE,\
	$(shell \
		$(SED) -n "/^$(call COMPOSER_INCLUDE_REGEX).*$$/p" $(CURDIR)/$(COMPOSER_SETTINGS) \
		| $(SED) -e "s|[[:space:]]+|$(TOKEN)|g" -e "s|$$| |g" \
	),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #OVERRIDE [$(subst $(TOKEN), ,$(FILE))])) \
	$(eval $(subst $(TOKEN), ,$(FILE))) \
)
endif
$(if $(COMPOSER_DEBUGIT_ALL),$(info #COMPOSER_INCLUDE [$(COMPOSER_INCLUDE)]))

########################################

ifneq ($(COMPOSER_INCLUDE),)
override COMPOSER_INCLUDES_LIST		:= $(MAKEFILE_LIST)
else ifeq ($(firstword $(MAKEFILE_LIST)),$(lastword $(MAKEFILE_LIST)))
override COMPOSER_INCLUDES_LIST		:= $(MAKEFILE_LIST)
else ifeq ($(firstword $(MAKEFILE_LIST)),$(lastword $(filter-out $(lastword $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))
override COMPOSER_INCLUDES_LIST		:= $(MAKEFILE_LIST)
else
#>override COMPOSER_INCLUDES_LIST	:= $(firstword $(MAKEFILE_LIST)) $(lastword $(filter-out $(lastword $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
override COMPOSER_INCLUDES_LIST		:= $(firstword $(MAKEFILE_LIST)) $(lastword $(MAKEFILE_LIST))
endif

$(if $(COMPOSER_DEBUGIT_ALL),$(info #MAKEFILE_LIST [$(MAKEFILE_LIST)]))
$(foreach FILE,$(abspath $(dir $(COMPOSER_INCLUDES_LIST))),\
	$(eval override COMPOSER_INCLUDES := $(FILE) $(COMPOSER_INCLUDES)); \
)
override COMPOSER_INCLUDES_LIST		:= $(strip $(COMPOSER_INCLUDES))
override COMPOSER_INCLUDES		:=
$(if $(COMPOSER_DEBUGIT_ALL),$(info #COMPOSER_INCLUDES_LIST [$(COMPOSER_INCLUDES_LIST)]))

$(foreach FILE,$(addsuffix /$(COMPOSER_SETTINGS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #WILDCARD [$(FILE)])); \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #INCLUDE [$(FILE)])); \
		$(eval override MAKEFILE_LIST := $(filter-out $(FILE),$(MAKEFILE_LIST))); \
		$(eval override COMPOSER_INCLUDES := $(COMPOSER_INCLUDES) $(FILE)); \
		$(eval include $(FILE)); \
	) \
)

########################################

#> update: includes duplicates
$(call READ_ALIASES,s,c_css,CSS)

override _CSS				:=
ifneq ($(filter override,$(origin CSS)),)
override _CSS				:= $(CSS)
endif
ifeq ($(_CSS),)
$(foreach FILE,$(addsuffix /$(COMPOSER_CSS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #WILDCARD_CSS [$(FILE)])); \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #INCLUDE_CSS [$(FILE)])); \
		$(eval override _CSS := $(FILE)); \
	) \
)
endif
$(if $(COMPOSER_DEBUGIT_ALL),$(info #_CSS [$(_CSS)]))

################################################################################
# {{{1 Make Settings -----------------------------------------------------------
################################################################################

.POSIX:
.SUFFIXES:

########################################

#> update: COMPOSER_OPTIONS
unexport

########################################

override MAKEJOBS_DEFAULT		:= 1

$(call READ_ALIASES,J,c_jobs,MAKEJOBS)
override MAKEJOBS			?= $(MAKEJOBS_DEFAULT)
ifeq ($(MAKEJOBS),)
override MAKEJOBS			:= $(MAKEJOBS_DEFAULT)
endif

#> update: COMPOSER_DEPENDS: MAKEJOBS
ifneq ($(COMPOSER_DEPENDS),)
override MAKEJOBS			:= $(MAKEJOBS_DEFAULT)
endif

ifeq ($(MAKEJOBS),1)
.NOTPARALLEL:
endif

override MAKEJOBS_OPTS			:=
ifeq ($(MAKEJOBS),1)
override MAKEJOBS_OPTS			:= --jobs=$(MAKEJOBS) --output-sync=none
else
#>override MAKEJOBS_OPTS		:= --jobs=$(MAKEJOBS) --output-sync=line
override MAKEJOBS_OPTS			:= --jobs=$(MAKEJOBS) --output-sync=none
endif
ifeq ($(MAKEJOBS),0)
override MAKEJOBS_OPTS			:= $(subst --jobs=$(MAKEJOBS),--jobs,$(MAKEJOBS_OPTS))
endif

########################################

#>override MAKEFILE			:= $(notdir $(firstword $(MAKEFILE_LIST)))
override MAKEFILE			:= Makefile
override MAKEFLAGS			:= --no-builtin-rules --no-builtin-variables --no-print-directory $(MAKEJOBS_OPTS)

ifneq ($(COMPOSER_DEBUGIT_ALL),)
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=verbose
else
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=none
endif

########################################

#> update: includes duplicates
override UNAME				:= $(call COMPOSER_FIND,$(PATH_LIST),uname) --all

override OS_UNAME			:= $(shell $(UNAME) 2>/dev/null)
override OS_TYPE			:=
ifneq ($(filter Linux,$(OS_UNAME)),)
override OS_TYPE			:= Linux
else ifneq ($(filter Windows,$(OS_UNAME)),)
override OS_TYPE			:= Windows
else ifneq ($(filter Darwin,$(OS_UNAME)),)
override OS_TYPE			:= Darwin
endif

################################################################################
# {{{1 Composer Options --------------------------------------------------------
################################################################################

#> update: includes duplicates

$(call READ_ALIASES,C,c_color,COMPOSER_DOCOLOR)
$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)

#> update: COMPOSER_DEPENDS: MAKEJOBS
override COMPOSER_DOCOLOR		?= 1
override COMPOSER_DEBUGIT		?=
override COMPOSER_INCLUDE		?=
override COMPOSER_DEPENDS		?=

override COMPOSER_DEBUGIT_ALL		:=
ifeq ($(COMPOSER_DEBUGIT),!)
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

########################################

override COMPOSER_STAMP			?= $(COMPOSER_STAMP_DEFAULT)

override COMPOSER_EXT			?= $(COMPOSER_EXT_DEFAULT)
#>ifeq ($(COMPOSER_EXT),)
#>override COMPOSER_EXT			:= $(COMPOSER_EXT_DEFAULT)
#>endif
override COMPOSER_EXT			:= $(notdir $(COMPOSER_EXT))

########################################

#> update: COMPOSER_TARGETS.*=
#> update: COMPOSER_SUBDIRS.*=

override COMPOSER_TARGETS		?=
override COMPOSER_SUBDIRS		?=
override COMPOSER_IGNORES		?=

ifneq ($(COMPOSER_RELEASE),)
override COMPOSER_TARGETS		:=
override COMPOSER_SUBDIRS		:=
override COMPOSER_IGNORES		:=
endif

########################################

#> update: includes duplicates

$(call READ_ALIASES,T,c_type,TYPE)
$(call READ_ALIASES,B,c_base,BASE)
$(call READ_ALIASES,L,c_list,LIST)
$(call READ_ALIASES,s,c_css,CSS)
$(call READ_ALIASES,t,c_title,TTL)
$(call READ_ALIASES,c,c_contents,TOC)
$(call READ_ALIASES,l,c_level,LVL)
$(call READ_ALIASES,m,c_margin,MGN)
$(call READ_ALIASES,f,c_font,FNT)
$(call READ_ALIASES,o,c_options,OPT)

#> update: $(HEADERS)-vars
override TYPE				?= $(TYPE_DEFAULT)
override BASE				?= $(EXAMPLE_ONE)
override LIST				?= $(BASE)$(COMPOSER_EXT)
#>override CSS				?= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override CSS				?=
override TTL				?=
override TOC				?=
override LVL				?= 2
override MGN				?= 0.8in
override FNT				?= 10pt
override OPT				?=

################################################################################
# }}}1
################################################################################
# {{{1 Tooling Versions --------------------------------------------------------
################################################################################

#> update: PHONY.*(UPGRADE)

# https://github.com/jgm/pandoc
# https://github.com/jgm/pandoc/blob/master/COPYING.md
#>override PANDOC_VER			:= 2.13
ifeq ($(filter override,$(origin PANDOC_VER)),)
override PANDOC_VER			:= 2.18
endif
ifeq ($(filter override,$(origin PANDOC_CMT)),)
override PANDOC_CMT			:= $(PANDOC_VER)
endif
override PANDOC_LIC			:= GPL
override PANDOC_SRC			:= https://github.com/jgm/pandoc.git
override PANDOC_DIR			:= $(COMPOSER_DIR)/pandoc
override PANDOC_TEX_PDF			:= pdflatex
override PANDOC_URL			:= https://github.com/jgm/pandoc/releases/download/$(PANDOC_VER)
override PANDOC_LNX_SRC			:= pandoc-$(PANDOC_VER)-linux-amd64.tar.gz
override PANDOC_WIN_SRC			:= pandoc-$(PANDOC_VER)-windows-x86_64.zip
override PANDOC_MAC_SRC			:= pandoc-$(PANDOC_VER)-macOS.zip
override PANDOC_LNX_DST			:= $(subst .tar.gz,,$(PANDOC_LNX_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/bin/pandoc
override PANDOC_WIN_DST			:= $(subst .zip,,$(PANDOC_WIN_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/pandoc.exe
override PANDOC_MAC_DST			:= $(subst .zip,,$(PANDOC_MAC_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/bin/pandoc
override PANDOC_LNX_BIN			:= $(firstword $(subst /, ,$(PANDOC_LNX_DST)))
override PANDOC_WIN_BIN			:= $(firstword $(subst /, ,$(PANDOC_WIN_DST))).exe
override PANDOC_MAC_BIN			:= $(firstword $(subst /, ,$(PANDOC_MAC_DST))).bin
ifeq ($(OS_TYPE),Linux)
override PANDOC_BIN			:= $(PANDOC_DIR)/$(PANDOC_LNX_BIN)
else ifeq ($(OS_TYPE),Windows)
override PANDOC_BIN			:= $(PANDOC_DIR)/$(PANDOC_WIN_BIN)
else ifeq ($(OS_TYPE),Darwin)
override PANDOC_BIN			:= $(PANDOC_DIR)/$(PANDOC_MAC_BIN)
endif

########################################

# https://mikefarah.gitbook.io/yq
# https://github.com/mikefarah/yq
# https://github.com/mikefarah/yq/blob/master/LICENSE
#>override YQ_VER			:= 2.7.2
ifeq ($(filter override,$(origin YQ_VER)),)
override YQ_VER				:= 4.24.2
endif
ifeq ($(filter override,$(origin YQ_CMT)),)
override YQ_CMT				:= v$(YQ_VER)
endif
override YQ_LIC				:= MIT
override YQ_SRC				:= https://github.com/mikefarah/yq.git
override YQ_DIR				:= $(COMPOSER_DIR)/yq
override YQ_URL				:= https://github.com/mikefarah/yq/releases/download/v$(YQ_VER)
override YQ_LNX_SRC			:= yq_linux_amd64.tar.gz
override YQ_WIN_SRC			:= yq_windows_amd64.zip
override YQ_MAC_SRC			:= yq_darwin_amd64.tar.gz
override YQ_LNX_DST			:= $(subst .tar.gz,,$(YQ_LNX_SRC))-$(YQ_VER)/$(subst .tar.gz,,$(YQ_LNX_SRC))
override YQ_WIN_DST			:= $(subst .zip,,$(YQ_WIN_SRC))-$(YQ_VER)/$(subst .zip,,$(YQ_WIN_SRC)).exe
override YQ_MAC_DST			:= $(subst .tar.gz,,$(YQ_MAC_SRC))-$(YQ_VER)/$(subst .tar.gz,,$(YQ_MAC_SRC))
override YQ_LNX_BIN			:= $(firstword $(subst /, ,$(YQ_LNX_DST)))
override YQ_WIN_BIN			:= $(firstword $(subst /, ,$(YQ_WIN_DST))).exe
override YQ_MAC_BIN			:= $(firstword $(subst /, ,$(YQ_MAC_DST))).bin
override YQ_BIN				:=
ifeq ($(OS_TYPE),Linux)
override YQ_BIN				:= $(YQ_DIR)/$(YQ_LNX_BIN)
else ifeq ($(OS_TYPE),Windows)
override YQ_BIN				:= $(YQ_DIR)/$(YQ_WIN_BIN)
else ifeq ($(OS_TYPE),Darwin)
override YQ_BIN				:= $(YQ_DIR)/$(YQ_MAC_BIN)
endif

########################################

# https://github.com/simov/markdown-viewer
# https://github.com/simov/markdown-viewer/blob/master/LICENSE
#>override MDVIEWER_CMT			:= 059f3192d4ebf5fa9776478ea221d586480e7fa7
ifeq ($(filter override,$(origin MDVIEWER_CMT)),)
override MDVIEWER_CMT			:= 059f3192d4ebf5fa9776
endif
override MDVIEWER_LIC			:= MIT
override MDVIEWER_SRC			:= https://github.com/simov/markdown-viewer.git
override MDVIEWER_DIR			:= $(COMPOSER_DIR)/markdown-viewer
#>override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/screen.css
#>override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/markdown-alt.css
#>override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/markedapp-byword.css
#>override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/markdown9.css
override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/markdown7.css
#>override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DIR)/themes/solarized-dark.css
override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DIR)/themes/solarized-light.css

########################################

# https://github.com/hakimel/reveal.js
# https://github.com/hakimel/reveal.js/blob/master/LICENSE
ifeq ($(filter override,$(origin REVEALJS_CMT)),)
override REVEALJS_CMT			:= 4.3.1
endif
override REVEALJS_LIC			:= MIT
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DIR			:= $(COMPOSER_DIR)/revealjs
#>override REVEALJS_CSS_THEME		:= $(REVEALJS_DIR)/dist/theme/solarized.css
override REVEALJS_CSS_THEME		:= $(REVEALJS_DIR)/dist/theme/black.css
override REVEALJS_CSS			:= $(COMPOSER_ART)/revealjs.css

########################################

override BASH_VER			:= 5.0.18
override COREUTILS_VER			:= 8.31
override FINDUTILS_VER			:= 4.8.0
override SED_VER			:= 4.8

override MAKE_VER			:= 4.2.1
override PANDOC_VER			:= $(PANDOC_VER)
override YQ_VER				:= $(YQ_VER)
override TEX_PDF_VER			:= 2021 3.14159 2.6-1.40.22

override GIT_VER			:= 2.32.0
override WGET_VER			:= 1.20.3
override TAR_VER			:= 1.34
override GZIP_VER			:= 1.10
override 7Z_VER				:= 16.02

override DIFFUTILS_VER			:= 3.7
override RSYNC_VER			:= 3.2.3
override LESS_VER			:= 551

################################################################################
# {{{1 Tooling Options ---------------------------------------------------------
################################################################################

#> update: includes duplicates

override PATH_LIST			:= $(subst :, ,$(PATH))

override SHELL				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)
export SHELL

########################################
# {{{2 Paths ---------------------------

#> sed -nr "s|^override[[:space:]]+([^[:space:]]+).+[(]PATH_LIST[)].+$|\1|gp" Makefile | while read -r FILE; do echo "--- ${FILE} ---"; grep -E "[(]${FILE}[)]" Makefile; done

override BASH				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)
override FIND				:= $(call COMPOSER_FIND,$(PATH_LIST),find)
override XARGS				:= $(call COMPOSER_FIND,$(PATH_LIST),xargs) --max-procs=$(MAKEJOBS) -I {}
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

override BASE64				:= $(call COMPOSER_FIND,$(PATH_LIST),base64) -w0
override CAT				:= $(call COMPOSER_FIND,$(PATH_LIST),cat)
override CHMOD				:= $(call COMPOSER_FIND,$(PATH_LIST),chmod) -v 755
override CP				:= $(call COMPOSER_FIND,$(PATH_LIST),cp) -afv
override DATE				:= $(call COMPOSER_FIND,$(PATH_LIST),date) --iso=seconds
override ECHO				:= $(call COMPOSER_FIND,$(PATH_LIST),echo) -en
override ENV				:= $(call COMPOSER_FIND,$(PATH_LIST),env) - PATH="$(PATH)"
override EXPR				:= $(call COMPOSER_FIND,$(PATH_LIST),expr)
override HEAD				:= $(call COMPOSER_FIND,$(PATH_LIST),head)
override LN				:= $(call COMPOSER_FIND,$(PATH_LIST),ln) -fsv --relative
override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) --color=auto --time-style=long-iso -asF -l
override MKDIR				:= $(call COMPOSER_FIND,$(PATH_LIST),install) -dv
override MV				:= $(call COMPOSER_FIND,$(PATH_LIST),mv) -fv
override PRINTF				:= $(call COMPOSER_FIND,$(PATH_LIST),printf)
override REALPATH			:= $(call COMPOSER_FIND,$(PATH_LIST),realpath) --canonicalize-missing --relative-to
override RM				:= $(call COMPOSER_FIND,$(PATH_LIST),rm) -fv
override SORT				:= $(call COMPOSER_FIND,$(PATH_LIST),sort) -uV
override TAIL				:= $(call COMPOSER_FIND,$(PATH_LIST),tail)
override TEE				:= $(call COMPOSER_FIND,$(PATH_LIST),tee) -a
override TR				:= $(call COMPOSER_FIND,$(PATH_LIST),tr)
override TRUE				:= $(call COMPOSER_FIND,$(PATH_LIST),true)
override UNAME				:= $(call COMPOSER_FIND,$(PATH_LIST),uname) --all
override WC				:= $(call COMPOSER_FIND,$(PATH_LIST),wc) -l

#>override MAKE				:= $(call COMPOSER_FIND,$(PATH_LIST),make)
override REALMAKE			:= $(call COMPOSER_FIND,$(PATH_LIST),make)
override PANDOC				:= $(call COMPOSER_FIND,$(PATH_LIST),pandoc)
override YQ				:= $(call COMPOSER_FIND,$(PATH_LIST),yq)
override TEX_PDF			:= $(call COMPOSER_FIND,$(PATH_LIST),$(PANDOC_TEX_PDF))

override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git)
override WGET				:= $(call COMPOSER_FIND,$(PATH_LIST),wget) --verbose --progress=dot --timestamping
override TAR				:= $(call COMPOSER_FIND,$(PATH_LIST),tar) -vvx
override GZIP_BIN			:= $(call COMPOSER_FIND,$(PATH_LIST),gzip)
override 7Z				:= $(call COMPOSER_FIND,$(PATH_LIST),7z) x -aoa

override DIFF				:= $(call COMPOSER_FIND,$(PATH_LIST),diff) -u -U10
override RSYNC				:= $(call COMPOSER_FIND,$(PATH_LIST),rsync) -avv --recursive --itemize-changes --times --delete
override LESS_BIN			:= $(call COMPOSER_FIND,$(PATH_LIST),less) --force --raw-control-chars

export GZIP				:=
export LESS				:=

########################################

ifneq ($(wildcard $(PANDOC_BIN)),)
override PANDOC				:= $(PANDOC_BIN)
endif
ifneq ($(wildcard $(YQ_BIN)),)
override YQ				:= $(YQ_BIN)
endif

########################################
# {{{2 Wrappers ------------------------

override DATESTAMP			:= $(shell $(DATE))
override DATENAME			:= $(shell $(DATE) | $(SED) \
	-e "s|[-]([0-9]{2}[:]?[0-9]{2})$$|T\1|g" \
	-e "s|[-:]||g" \
	-e "s|T|-|g" \
)
override DATEMARK			:= $(firstword $(subst T, ,$(DATESTAMP)))

########################################

override GIT_RUN			= cd $(1) && $(GIT) --git-dir="$(2)" --work-tree="$(1)" $(3)
override GIT_RUN_COMPOSER		= $(call GIT_RUN,$(COMPOSER_ROOT),$(strip $(if \
		$(wildcard $(COMPOSER_ROOT).git),\
		$(COMPOSER_ROOT).git ,\
		$(COMPOSER_ROOT)/.git \
	)),$(1))

override GIT_REPO			= $(call GIT_REPO_DO,$(1),$(2),$(3),$(4),$(COMPOSER_PKG)/$(notdir $(1)).git)
override define GIT_REPO_DO =
	$(ENDOLINE); \
	$(PRINT) "$(_H)$(MARKER) $(@)$(_D) $(DIVIDE) $(_M)$(notdir $(1))$(_D) ($(_E)$(3)$(_D))"; \
	$(MKDIR) $(abspath $(dir $(5))) $(1); \
	if [ ! -d "$(5)" ] && [ -d "$(1).git"  ]; then $(MV) $(1).git  $(5); fi; \
	if [ ! -d "$(5)" ] && [ -d "$(1)/.git" ]; then $(MV) $(1)/.git $(5); fi; \
	if [ ! -d "$(5)" ]; then \
		$(call GIT_RUN,$(1),$(5),init); \
		$(call GIT_RUN,$(1),$(5),remote add origin $(2)); \
	fi; \
	$(ECHO) "gitdir: `$(REALPATH) $(1) $(5)`" >$(1)/.git; \
	$(call GIT_RUN,$(1),$(5),config --local --replace-all core.worktree $(1)); \
	$(call GIT_RUN,$(1),$(5),fetch --all); \
	if [ -n "$(3)" ] && [ -n "$(4)" ]; then $(call GIT_RUN,$(1),$(5),checkout --force -B $(4) $(3)); fi; \
	if [ -n "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),$(5),checkout --force -B $(COMPOSER_BASENAME) $(3)); fi; \
	if [ -z "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),$(5),checkout --force master); fi; \
	$(call GIT_RUN,$(1),$(5),reset --hard); \
	if [ -f "$(1)/.gitmodules" ]; then \
		$(call GIT_RUN,$(1),$(5),submodule update --init --recursive --force); \
	fi; \
	$(RM) $(1)/.git
endef

########################################

override WGET_PACKAGE			= $(call WGET_PACKAGE_DO,$(1),$(2),$(3),$(4),$(5),$(6),$(firstword $(subst /, ,$(4))),$(COMPOSER_PKG))
override define WGET_PACKAGE_DO =
	$(ENDOLINE); \
	$(PRINT) "$(_H)$(MARKER) $(@)$(_D) $(DIVIDE) $(_M)$(5)"; \
	$(MKDIR) $(8); \
	$(WGET) --directory-prefix $(8) $(2)/$(3); \
	$(RM) --recursive $(8)/$(7); \
	$(MKDIR) $(8)/$(7); \
	if [ -z "$(6)" ]; then \
		$(TAR) -C $(8)/$(7) -f $(8)/$(3); \
	else \
		$(7Z) -o$(8)/$(7) $(8)/$(3); \
	fi; \
	$(MKDIR) $(1); \
	$(CP) $(8)/$(4) $(1)/$(5); \
	$(CHMOD) $(1)/$(5)
endef

################################################################################
# {{{1 Pandoc Options ----------------------------------------------------------
################################################################################

override INPUT				:= markdown
override OUTPUT				:= $(TYPE)
override EXTENSION			:= $(TYPE)

########################################
# {{{2 Types ---------------------------

#> update: TYPE_TARGETS

override DESC_HTML			:= HyperText Markup Language
override DESC_LPDF			:= Portable Document Format
override DESC_EPUB			:= Electronic Publication
override DESC_PRES			:= Reveal.js Presentation
override DESC_DOCX			:= Microsoft Word
override DESC_PPTX			:= Microsoft PowerPoint
override DESC_TEXT			:= Plain Text (well-formatted)
override DESC_LINT			:= Pandoc Markdown (for testing)

override TYPE_HTML			:= html
override TYPE_LPDF			:= pdf
override TYPE_EPUB			:= epub
override TYPE_PRES			:= revealjs
override TYPE_DOCX			:= docx
override TYPE_PPTX			:= pptx
override TYPE_TEXT			:= text
override TYPE_LINT			:= $(INPUT)

override EXTN_HTML			:= $(TYPE_HTML)
override EXTN_LPDF			:= $(TYPE_LPDF)
override EXTN_EPUB			:= $(TYPE_EPUB)
override EXTN_PRES			:= $(TYPE_PRES).$(TYPE_HTML)
override EXTN_DOCX			:= $(TYPE_DOCX)
override EXTN_PPTX			:= $(TYPE_PPTX)
override EXTN_TEXT			:= txt
override EXTN_LINT			:= $(subst $(TOKEN),,$(subst $(TOKEN).,,$(addprefix $(TOKEN),$(COMPOSER_EXT_DEFAULT)))).$(EXTN_TEXT)

ifeq ($(TYPE),$(TYPE_HTML))
override OUTPUT				:= html5
override EXTENSION			:= $(EXTN_HTML)
else ifeq ($(TYPE),$(TYPE_LPDF))
override OUTPUT				:= latex
override EXTENSION			:= $(EXTN_LPDF)
else ifeq ($(TYPE),$(TYPE_EPUB))
override OUTPUT				:= epub3
override EXTENSION			:= $(EXTN_EPUB)
else ifeq ($(TYPE),$(TYPE_PRES))
override OUTPUT				:= $(TYPE_PRES)
override EXTENSION			:= $(EXTN_PRES)
else ifeq ($(TYPE),$(TYPE_DOCX))
override OUTPUT				:= $(TYPE_DOCX)
override EXTENSION			:= $(EXTN_DOCX)
else ifeq ($(TYPE),$(TYPE_PPTX))
override OUTPUT				:= $(TYPE_PPTX)
override EXTENSION			:= $(EXTN_PPTX)
else ifeq ($(TYPE),$(TYPE_TEXT))
override OUTPUT				:= plain
override EXTENSION			:= $(EXTN_TEXT)
else ifeq ($(TYPE),$(TYPE_LINT))
override OUTPUT				:= $(TYPE_LINT)
override EXTENSION			:= $(EXTN_LINT)
endif

#> update: COMPOSER_TARGETS.*=
ifneq ($(COMPOSER_RELEASE),)
override COMPOSER_TARGETS		:= $(strip \
	$(EXAMPLE_ONE).$(EXTN_HTML) \
	$(EXAMPLE_ONE).$(EXTN_LPDF) \
	$(EXAMPLE_ONE).$(EXTN_EPUB) \
	$(EXAMPLE_ONE).$(EXTN_PRES) \
	$(EXAMPLE_ONE).$(EXTN_DOCX) \
	$(EXAMPLE_ONE).$(EXTN_PPTX) \
	$(EXAMPLE_ONE).$(EXTN_TEXT) \
	$(EXAMPLE_ONE).$(EXTN_LINT) \
)
endif

########################################
# {{{2 CSS -----------------------------

override _COL				:= $(COLUMNS)
override _CSS_ALT			:= css_alt

ifeq ($(_CSS),)
ifeq ($(CSS),)
ifeq ($(OUTPUT),$(TYPE_PRES))
override _CSS				:= $(REVEALJS_CSS)
else
override _CSS				:= $(MDVIEWER_CSS)
endif
else
ifeq ($(CSS),$(_CSS_ALT))
override _CSS				:= $(MDVIEWER_CSS_ALT)
else
override _CSS				:= $(abspath $(CSS))
endif
endif
endif

########################################
# {{{2 Command -------------------------

#WORK TODO
#	--defaults = switch to this, in a heredoc that goes to artifacts
#		maybe add additional ones, like COMPOSER_INCLUDE
#	turn "lang" into a LANG variable, just above TYPE
#WORK TODO
#	--title-prefix="$(TTL)" = replace with full title option...?
#	--resource-path = something like COMPOSER_CSS?
#	--strip-comments
#	--eol=lf
#	site:
#		--include-before-body
#		--include-after-body
#WORK TODO
#	man pandoc = pandoc -o custom-reference.docx --print-default-data-file reference.docx
#	pandoc --from docx --to markdown --extract-media=README.markdown.files --track-changes=all --output=README.markdown README.docx ; vdiff README.md.txt README.markdown
#	--from "docx" --track-changes="all"
#	--from "docx|epub" --extract-media="[...]"
#WORK TODO
#	--default-image-extension="png"?
#	--highlight-style="kate"?
#	--incremental?
#WORK TODO
#	--include-in-header="[...]" --include-before-body="[...]" --include-after-body="[...]"
#	--email-obfuscation="[...]"
#	--epub-metadata="[...]" --epub-cover-image="[...]" --epub-embed-font="[...]"
#WORK TODO
#	add a way to add additional arguments, like: --variable=fontsize=28pt
#		--variable="fontsize=[...]"
#		--variable="theme=[...]"
#		--variable="transition=[...]"
#		--variable="links-as-notes=[...]"
#		--variable="lof=[...]"
#		--variable="lot=[...]"
#WORK TODO

override PANDOC_EXTENSIONS		:= +smart
override PANDOC_OPTIONS			:= $(strip \
	$(if $(COMPOSER_DEBUGIT_ALL),--verbose) \
	\
	--self-contained \
	--standalone \
	--variable="lang=en-US" \
	\
	--title-prefix="$(TTL)" \
	--output="$(CURDIR)/$(BASE).$(EXTENSION)" \
	--from="$(INPUT)$(PANDOC_EXTENSIONS)" \
	--to="$(OUTPUT)" \
	\
	$(if $(TOC),--table-of-contents) \
	$(if $(TOC),--number-sections) \
	$(if $(TOC),--toc-depth="$(TOC)") \
	\
	$(if $(LVL),--section-divs) \
	$(if $(LVL),--top-level-division=chapter) \
	$(if $(LVL),--slide-level="$(LVL)") \
	$(if $(LVL),--epub-chapter-level="$(LVL)") \
	\
	--columns="$(_COL)" \
	--css="$(_CSS)" \
	\
	--pdf-engine="$(PANDOC_TEX_PDF)" \
	--pdf-engine-opt="-output-directory=$(COMPOSER_TMP)" \
	--variable="geometry=margin=$(MGN)" \
	--variable="fontsize=$(FNT)" \
	--variable="revealjs-url=$(REVEALJS_DIR)" \
	\
	--listings \
	\
	$(OPT) \
	$(LIST) \
)

#WORK TODO
#>	--variable="geometry=top=$(MGN)" \
#>	--variable="geometry=bottom=$(MGN)" \
#>	--variable="geometry=left=$(MGN)" \
#>	--variable="geometry=right=$(MGN)" \

ifneq ($(wildcard $(COMPOSER_ART)/reference.$(EXTENSION)),)
override PANDOC_OPTIONS			:= --template="$(COMPOSER_ART)/reference.$(EXTENSION)" $(PANDOC_OPTIONS)
else ifneq ($(wildcard $(PANDOC_DIR)/data/templates/default.$(OUTPUT)),)
override PANDOC_OPTIONS			:= --template="$(PANDOC_DIR)/data/templates/default.$(OUTPUT)" $(PANDOC_OPTIONS)
endif
override PANDOC_OPTIONS			:= --data-dir="$(PANDOC_DIR)" $(PANDOC_OPTIONS)

################################################################################
# {{{1 Bootstrap Options -------------------------------------------------------
################################################################################

#WORK bootstrap!

# override SITE_SOURCE			?= $(COMPOSER_ROOT)
# override SITE_OUTPUT			?= $(COMPOSER_ROOT)/_site
# override SITE_SEARCH			?= 1

# override SITE_TITLE			?= $(COMPOSER_FULLNAME): Hexo
# override SITE_SUBTITLE			?= a simple proof of concept
# override SITE_DESCRIPTION		?= a brief summary
# override SITE_EXCERPT			?= Please expand on that...
# override SITE_AUTHOR			?= $(COMPOSER_COMPOSER)
# override SITE_LANGUAGE			?= en
# override SITE_TIMEZONE			?= US/Pacific

# override SITE_GOOGLEPLUS		?= https://plus.google.com/$(COMPOSER_BASENAME)
# override SITE_FACEBOOK			?= https://www.facebook.com/$(COMPOSER_BASENAME)
# override SITE_LINKEDIN			?= https://www.linkedin.com/$(COMPOSER_BASENAME)
# override SITE_TWITTER			?= https://twitter.com/$(COMPOSER_BASENAME)
# override SITE_GITHUB			?= https://github.com/$(COMPOSER_BASENAME)

# override SITE_GIT_REPO			?= git@github.com:garybgenett/garybgenett.net.git
# override SITE_ANALYTICS_ID		?=
# override SITE_URL			?= http://0.0.0.0:4000
# override SITE_ROOT			?=
# override SITE_SIDEBAR			?= right
# override SITE_PERMALINK			?= :year/:month/:day/:title/
# override SITE_DATE_FORMAT		?= YYYY-MM-DD
# override SITE_TIME_FORMAT		?= HH:mm:ss
# override SITE_FEED_TYPE			?= atom
# override SITE_PER_PAGE			?= 10

# override SITE_SIZE_BANNER		?= 128px
# override SITE_SIZE_LOGO			?= 32px
# override SITE_SIZE_SUBTITLE		?= 16px
# override SITE_SIZE_MOBLE_NAV		?= 256px

# override SITE_COLOR_BACKGROUND		?= \#202020
# override SITE_COLOR_BACKGROUND_BLOCK	?= \#404040
# override SITE_COLOR_BACKGROUND_FOOTER	?= \#000000
# override SITE_COLOR_BACKGROUND_MOBILE	?= \#000000
# override SITE_COLOR_BACKGROUND_WIDGET	?= \#404040
# override SITE_COLOR_BORDER		?= \#808080
# override SITE_COLOR_BORDER_WIDGET	?= \#808080
# override SITE_COLOR_SHADOW_BLOCK	?= \#004000
# override SITE_COLOR_SHADOW_TEXT		?= \#004000
# override SITE_COLOR_TEXT_DEFAULT	?= \#f0f0f0
# override SITE_COLOR_TEXT_GREY		?= \#808080
# override SITE_COLOR_TEXT_LINK		?= \#00f000
# override SITE_COLOR_TEXT_SIDEBAR	?= \#000000

# override SITE_WIDGETS_ARCHIVES		?= Archives
# override SITE_WIDGETS_CATEGORIES	?= Categories
# override SITE_WIDGETS_RECENTS		?= Recents
# override SITE_WIDGETS_TAGS		?= Tags
# override SITE_WIDGETS_TAGS_CLOUD	?= Tag Cloud
# override SITE_WIDGETS			?= \
	recent_posts \
	tagcloud \
	tag \
	category \
	archive \

# override SITE_MENU			?= \
	Home| \
	Testing|Test-page \
	$(SITE_WIDGETS_ARCHIVES)|archives \

# override SITE_SKIPS			?= \
	CNAME \

# override SITE_FOOTER_APPEND		?= \
	<br /><br /> \
	<a rel=\"author\" href=\"http://www.garybgenett.net\">					<img src=\"http://www.garybgenett.net/favicon.png\"					alt=\"Gary B. Genett\"	style=\"border:0; width:31px; height:31px;\"/></a> \
	<a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-nd/3.0/us/\">	<img src=\"http://i.creativecommons.org/l/by-nc-nd/3.0/us/88x31.png\"			alt=\"CC License\"	style=\"border:0; width:88px; height:31px;\"/></a> \
	<a href=\"http://validator.w3.org/check/referer\">					<img src=\"http://www.w3.org/Icons/valid-xhtml11-blue\"					alt=\"Valid HTML\"	style=\"border:0; width:88px; height:31px;\"/></a> \
	<a href=\"http://jigsaw.w3.org/css-validator/check/referer\">				<img src=\"http://www.w3.org/Icons/valid-css2-blue\"					alt=\"Valid CSS\"	style=\"border:0; width:88px; height:31px;\"/></a> \
	<br /> \
	<a href=\"https://github.com/garybgenett/composer\">					<img src=\"https://raw.githubusercontent.com/garybgenett/composer/devel/icon.png\"	alt=\"Composer\"	style=\"border:0; width:31px; height:31px;\"/></a> \
	<a href=\"http://www.vim.org\">								<img src=\"http://www.vim.org/images/vim_small.gif\"					alt=\"Vim\"		style=\"border:0; width:31px; height:31px;\"/></a> \
	<a href=\"http://git-scm.com\">								<img src=\"https://git.wiki.kernel.org/images-git/d/df/FrontPage%24git-logo.png\"	alt=\"Git\"		style=\"border:0; width:72px; height:27px;\"/></a>

# override SITE_SEARCH_SCRIPT		:= <script>function search_submit() { window.location.href = \"https://duckduckgo.com?kp=-1\&kz=-1\&kv=1\&kae=d\&ko=1\&q=site:\1 + config.url + \1 \" + document.search_form.q.value; }</script>
# override SITE_SEARCH_FORM		:= action=\"javascript:search_submit();\" name=\"search_form\"

# http://navaneeth.me/font-awesome-icons-css-content-values
#>override SITE_SOCIAL_ICON_googleplus	:= f0d5
#>override SITE_SOCIAL_ICON_facebook	:= f09a
#>override SITE_SOCIAL_ICON_linkedin	:= f0e1
#>override SITE_SOCIAL_ICON_twitter	:= f099
#>override SITE_SOCIAL_ICON_github	:= f09b
#>override SITE_SOCIAL_ICON_rss		:= f09e
# override SITE_SOCIAL_ICON_googleplus	:= f0d4
# override SITE_SOCIAL_ICON_facebook	:= f082
# override SITE_SOCIAL_ICON_linkedin	:= f08c
# override SITE_SOCIAL_ICON_twitter	:= f081
# override SITE_SOCIAL_ICON_github	:= f092
# override SITE_SOCIAL_ICON_rss		:= f143
# override SITE_SOCIAL_ICON		:= $(foreach FILE,googleplus facebook linkedin twitter github,\n\#nav-$(FILE)-link\n\t\&:before\n\t\tcontent: \"\\\\$(call SITE_SOCIAL_ICON_$(FILE))\"\n\n)
# override SITE_SOCIAL_LINK		:= $(foreach FILE,googleplus facebook linkedin twitter github,<% if (theme.url_$(FILE)){ %><a id=\"nav-$(FILE)-link\" class=\"nav-icon\" href=\"<%- theme.url_$(FILE) %>\" target=\"_blank\"></a><% } %>)

################################################################################
# {{{1 Composer Operation ------------------------------------------------------
################################################################################

override COMPOSER_CREATE		:= compose
override COMPOSER_PANDOC		:= pandoc

#> update: $(MAKE) / @+
override MAKE_OPTIONS			:=
override RUNMAKE			:= $(REALMAKE) --makefile $(COMPOSER_SRC) $(MAKE_OPTIONS)

########################################

override ~				:= "'$$'"
override COMPOSER_MY_PATH		:= $(~)(abspath $(~)(dir $(~)(lastword $(~)(MAKEFILE_LIST))))
override COMPOSER_TEACHER		:= $(~)(abspath $(~)(dir $(~)(COMPOSER_MY_PATH)))/$(MAKEFILE)

override COMPOSER_REGEX			:= [a-zA-Z0-9][a-zA-Z0-9_.-]*
override COMPOSER_REGEX_PREFIX		:= [_.]

########################################
# {{{2 Options -------------------------

#> update: COMPOSER_OPTIONS

override COMPOSER_EXPORTED := \
	MAKEJOBS \
	COMPOSER_DOCOLOR \
	COMPOSER_DEBUGIT \
	COMPOSER_INCLUDE \
	COMPOSER_DEPENDS \
	COMPOSER_STAMP \
	COMPOSER_EXT \
	TYPE \
	CSS \
	TTL \
	TOC \
	LVL \
	MGN \
	FNT \
	OPT \

override COMPOSER_EXPORTED_NOT := \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES \
	BASE \
	LIST \

#> update: $(MAKE) / @+
override MAKE_OPTIONS			:= $(MAKE_OPTIONS) $(foreach FILE,$(COMPOSER_EXPORTED), $(FILE)="$($(FILE))")
override RUNMAKE			:= $(RUNMAKE) $(MAKE_OPTIONS)
$(foreach FILE,$(COMPOSER_EXPORTED),$(eval export $(FILE)))
$(foreach FILE,$(COMPOSER_EXPORTED_NOT),$(eval unexport $(FILE)))

override COMPOSER_OPTIONS		:= $(shell $(SED) -n "s|^$(call COMPOSER_INCLUDE_REGEX,,1).*$$|\1|gp" $(COMPOSER))
$(foreach FILE,$(COMPOSER_OPTIONS),\
	$(if $(or \
		$(filter $(FILE),$(COMPOSER_EXPORTED)) ,\
		$(filter $(FILE),$(COMPOSER_EXPORTED_NOT)) \
		),,$(error # $(COMPOSER_FULLNAME): COMPOSER_OPTIONS: $(FILE)) \
	) \
)

########################################
# {{{2 Targets -------------------------

#> update: $(DEBUGIT): targets list
#> update: $(TESTING): targets list

#> update: PHONY.*$(DOITALL)
#	$(DEBUGIT)-$(DOITALL)
#	$(TESTING)-$(DOITALL)
#	$(CHECKIT)-$(DOITALL)
#	$(CONFIGS)-$(DOITALL)
#	$(CONVICT)-$(DOITALL)
#	$(UPGRADE)-$(DOITALL)
#	$(INSTALL)-$(DOITALL)
#	$(CLEANER)-$(DOITALL)
#	$(DOITALL)-$(DOITALL)

#> update: includes duplicates
override HELPOUT			:= usage
override HELPALL			:= help
override CREATOR			:= docs
override EXAMPLE			:= template

override HEADERS			:= headers
override WHOWHAT			:= whoami
override SETTING			:= settings

override MAKE_DB			:= .make_database
override LISTING			:= .all_targets
override NOTHING			:= .null

override DEBUGIT			:= debug
override TESTING			:= test
override CHECKIT			:= check
override CONFIGS			:= config
override TARGETS			:= targets

override CONVICT			:= _commit
override DISTRIB			:= _release
override UPGRADE			:= _update

override PUBLISH			:= site
override INSTALL			:= install
override CLEANER			:= clean
override DOITALL			:= all
override SUBDIRS			:= subdirs
override PRINTER			:= list

#> grep -E -e "[{][{][{][0-9]+" -e "^([#][>])?[.]PHONY[:]" Makefile
#> grep -E "[)]-[a-z]+" Makefile
override COMPOSER_RESERVED := \
	$(COMPOSER_CREATE) \
	$(COMPOSER_PANDOC) \
	\
	$(HELPOUT) \
	$(HELPALL) \
	$(CREATOR) \
	$(EXAMPLE) \
	\
	$(HEADERS) \
	$(WHOWHAT) \
	$(SETTING) \
	\
	$(MAKE_DB) \
	$(LISTING) \
	$(NOTHING) \
	\
	$(DEBUGIT) \
	$(TESTING) \
	$(CHECKIT) \
	$(CONFIGS) \
	$(TARGETS) \
	\
	$(CONVICT) \
	$(DISTRIB) \
	$(UPGRADE) \
	\
	$(PUBLISH) \
	$(INSTALL) \
	$(CLEANER) \
	$(DOITALL) \
	$(SUBDIRS) \
	$(PRINTER) \

override DOFORCE			:= force

########################################
# {{{2 Filesystem ----------------------

#> update: COMPOSER_TARGETS.*=
#> update: COMPOSER_SUBDIRS.*=

override COMPOSER_CONTENTS		:= $(sort $(wildcard *))
override COMPOSER_CONTENTS_DIRS		:= $(patsubst %/.,%,$(wildcard $(addsuffix /.,$(COMPOSER_CONTENTS))))
override COMPOSER_CONTENTS_FILES	:= $(filter-out $(COMPOSER_CONTENTS_DIRS),$(COMPOSER_CONTENTS))

ifeq ($(COMPOSER_RELEASE),)

ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER_EXT),)
override COMPOSER_TARGETS		:= $(patsubst %$(COMPOSER_EXT),%.$(EXTENSION),$(filter %$(COMPOSER_EXT),$(COMPOSER_CONTENTS_FILES)))
else
override COMPOSER_TARGETS		:= $(addsuffix .$(EXTENSION),$(filter-out %.$(EXTENSION),$(COMPOSER_CONTENTS_FILES)))
endif
endif

#> update: $(CLEANER)-$(TARGETS)
ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out %-$(CLEANER),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(CLEANER)-$(TARGETS)
endif
endif

ifeq ($(COMPOSER_SUBDIRS),)
#>override COMPOSER_SUBDIRS		:= $(subst /$(MAKEFILE),,$(wildcard $(addsuffix /$(MAKEFILE),$(COMPOSER_CONTENTS_DIRS))))
override COMPOSER_SUBDIRS		:= $(COMPOSER_CONTENTS_DIRS)
endif

override COMPOSER_TARGETS		:= $(filter-out $(COMPOSER_IGNORES),$(COMPOSER_TARGETS))
override COMPOSER_SUBDIRS		:= $(filter-out $(COMPOSER_IGNORES),$(COMPOSER_SUBDIRS))

endif

########################################

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
ifeq ($(notdir $(COMPOSER_ROOT)),$(notdir $(TESTING_DIR)))
override TESTING_DIR			:= $(COMPOSER_ROOT)
endif
ifeq ($(notdir $(abspath $(dir $(COMPOSER_ROOT)))),$(notdir $(TESTING_DIR)))
override TESTING_DIR			:= $(abspath $(dir $(COMPOSER_ROOT)))
endif

#> update: $(TESTING)-Think
ifeq ($(notdir $(TESTING_DIR)),$(notdir $(CURDIR)))
ifneq ($(COMPOSER_TARGETS),$(NOTHING))
override COMPOSER_TARGETS		:=
endif
ifneq ($(COMPOSER_SUBDIRS),$(NOTHING))
override COMPOSER_SUBDIRS		:=
endif
endif

########################################
# {{{2 Specials ------------------------

override DO_BOOK			:= book
override DO_POST			:= post

override COMPOSER_RESERVED_SPECIAL := \
	$(DO_BOOK) \
	$(DO_POST) \

########################################

#> update: $(MAKE) / @+
override define COMPOSER_RESERVED_SPECIAL_TARGETS =
override COMPOSER_TARGETS := $(filter-out $(1)-%,$(COMPOSER_TARGETS))
$(foreach FILE,$(filter $(1)-%$(COMPOSER_EXT),$(COMPOSER_CONTENTS_FILES)),\
	$(eval $(patsubst %$(COMPOSER_EXT),%.$(EXTENSION),$(FILE)): $(FILE)) \
)

.PHONY: $(1)s
$(1)s: .set_title-$(1)s
$(1)s: $$(HEADERS)-$(1)s
$(1)s: $(1)s-$(DOITALL)
$(1)s:
	@$(ECHO) ""

.PHONY: $(1)s-$(DOITALL)
$(1)s-$(DOITALL):
	@+$$(strip $$(call $$(TARGETS)-list)) \
		| $$(SED) -n "s|^($(1)[-][^:]+).*$$$$|\1|gp" \
		| $$(XARGS) $$(MAKE) $$(MAKE_OPTIONS) --silent {}

.PHONY: $(1)s-$(CLEANER)
$(1)s-$(CLEANER):
	@+$$(strip $$(call $$(TARGETS)-list)) \
		| $$(SED) -n "s|^$(1)[-]([^:]+).*$$$$|\1|gp" \
		| $$(XARGS) bash -c '\
			if [ -f "$$(CURDIR)/{}" ]; then \
				$$(call $$(HEADERS)-rm,$$(CURDIR),{}); \
				$$(RM) $$(CURDIR)/{} >/dev/null; \
			fi; \
		'

ifneq ($(COMPOSER_RELEASE),)
$(1)-$(COMPOSER_BASENAME)-$(1).$(EXTENSION): \
	$(EXAMPLE_ONE)$(COMPOSER_EXT_DEFAULT) \
	$(EXAMPLE_TWO)$(COMPOSER_EXT_DEFAULT)
endif
endef

$(foreach FILE,$(COMPOSER_RESERVED_SPECIAL),\
	$(eval $(call COMPOSER_RESERVED_SPECIAL_TARGETS,$(FILE))); \
)

################################################################################
# }}}1
################################################################################
# {{{1 Documentation -----------------------------------------------------------
################################################################################

########################################
# {{{2 $(HELPOUT) $(HELPALL) -----------

.PHONY: $(HELPOUT)
ifeq ($(MAKECMDGOALS),)
.NOTPARALLEL:
endif
ifneq ($(MAKECMDGOALS),$(filter-out $(HELPOUT),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(HELPOUT): \
	$(HELPALL)-TITLE_Usage \
	$(HELPALL)-USAGE \
	$(HELPALL)-VARIABLES_FORMAT_1 \
	$(HELPALL)-TARGETS_MAIN_1 \
	$(HELPALL)-COMMANDS_1 \
	$(HELPALL)-FOOTER
$(HELPOUT):
	@$(ECHO) ""

.PHONY: $(HELPALL)
ifneq ($(MAKECMDGOALS),$(filter-out $(HELPALL),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
#WORKING
#$(HELPALL): \
#	$(HELPALL)-TITLE_Help \
#	$(HELPALL)-USAGE \
#	$(HELPALL)-VARIABLES_TITLE_1 \
#	$(HELPALL)-VARIABLES_FORMAT_2 \

$(HELPALL): \
	$(HELPALL)-VARIABLES_CONTROL_2 \
	$(HELPALL)-TARGETS_TITLE_1 \
	$(HELPALL)-TARGETS_MAIN_2 \
	$(HELPALL)-TARGETS_ADDITIONAL_2 \
	$(HELPALL)-TARGETS_SUBTARGET_2 \

#WORKING
#	$(HELPALL)-COMMANDS_1 \
#	$(HELPALL)-SYSTEM \
#	$(HELPALL)-FOOTER
$(HELPALL):
	@$(ECHO) ""

.PHONY: $(HELPALL)-TITLE_%
$(HELPALL)-TITLE_%:
	@$(call TITLE_LN,0,$(COMPOSER_FULLNAME) $(DIVIDE) $(*))

.PHONY: $(HELPALL)-USAGE
$(HELPALL)-USAGE:
	@$(PRINT) "$(CODEBLOCK)$(_C)$(MAKE)$(_D) $(_M)[variables]$(_D) $(_C)$(COMPOSER_CREATE)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(MAKE)$(_D) $(_M)[variables] <filename>.<extension>"

.PHONY: $(HELPALL)-FOOTER
$(HELPALL)-FOOTER:
	@$(ENDOLINE)
	@$(LINERULE)
	@$(PRINT) "*$(_H)Happy Making!$(_D)*"

########################################
# {{{3 $(HELPALL)-VARIABLES ------------

.PHONY: $(HELPALL)-VARIABLES_TITLE_%
$(HELPALL)-VARIABLES_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Variables,$(HEAD_MAIN))

#> update: TYPE_TARGETS
#> update: READ_ALIASES
.PHONY: $(HELPALL)-VARIABLES_FORMAT_%
$(HELPALL)-VARIABLES_FORMAT_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Formatting Variables); fi
	@$(TABLE_M3) "$(_H)Variable"				"$(_H)Purpose"				"$(_H)Value"
	@$(TABLE_M3) ":---"					":---"					":---"
	@$(TABLE_M3) "$(_C)TYPE $(_E)(T, c_type)"		"Desired output format"			"$(_M)$(TYPE)"
	@$(TABLE_M3) "$(_C)BASE $(_E)(B, c_base)"		"Base of output file"			"$(_M)$(BASE)"
	@$(TABLE_M3) "$(_C)LIST $(_E)(L, c_list)"		"List of input files(s)"		"$(_M)$(LIST)"
	@$(TABLE_M3) "$(_C)CSS $(_E)(s, c_css)"			"Location of CSS file"			"$(if $(CSS),$(_M)$(CSS)$(_D) )$(_N)($(COMPOSER_CSS))"
	@$(TABLE_M3) "$(_C)TTL $(_E)(t, c_title)"		"Document title prefix"			"$(_M)$(TTL)"
	@$(TABLE_M3) "$(_C)TOC $(_E)(c, c_contents)"		"Table of contents depth"		"$(_M)$(TOC)"
	@$(TABLE_M3) "$(_C)LVL $(_E)(l, c_level)"		"Chapter/slide header level"		"$(_M)$(LVL)"
	@$(TABLE_M3) "$(_C)MGN $(_E)(m, c_margin)"		"Margin size [$(_C)$(TYPE_LPDF)$(_D)]"	"$(_M)$(MGN)"
	@$(TABLE_M3) "$(_C)FNT $(_E)(f, c_font)"		"Font size [$(_C)$(TYPE_HTML)$(_D) $(_E)&$(_D) $(_C)$(TYPE_LPDF)$(_D)]" \
													"$(_M)$(FNT)"
	@$(TABLE_M3) "$(_C)OPT $(_E)(o, c_options)"		"Custom Pandoc options"			"$(_M)$(OPT)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Defined $(_C)TYPE$(_H) Values"	"$(_H)Format"				"$(_H)Extension"
	@$(TABLE_M3) ":---"					":---"					":---"
	@$(TABLE_M3) "$(_C)$(TYPE_HTML)"			"$(DESC_HTML)"				"$(_N)*$(_D).$(_E)$(EXTN_HTML)"
	@$(TABLE_M3) "$(_C)$(TYPE_LPDF)"			"$(DESC_LPDF)"				"$(_N)*$(_D).$(_E)$(EXTN_LPDF)"
	@$(TABLE_M3) "$(_C)$(TYPE_EPUB)"			"$(DESC_EPUB)"				"$(_N)*$(_D).$(_E)$(EXTN_EPUB)"
	@$(TABLE_M3) "$(_C)$(TYPE_PRES)"			"$(DESC_PRES)"				"$(_N)*$(_D).$(_E)$(EXTN_PRES)"
	@$(TABLE_M3) "$(_C)$(TYPE_DOCX)"			"$(DESC_DOCX)"				"$(_N)*$(_D).$(_E)$(EXTN_DOCX)"
	@$(TABLE_M3) "$(_C)$(TYPE_PPTX)"			"$(DESC_PPTX)"				"$(_N)*$(_D).$(_E)$(EXTN_PPTX)"
	@$(TABLE_M3) "$(_C)$(TYPE_TEXT)"			"$(DESC_TEXT)"				"$(_N)*$(_D).$(_E)$(EXTN_TEXT)"
	@$(TABLE_M3) "$(_C)$(TYPE_LINT)"			"$(DESC_LINT)"				"$(_N)*$(_D).$(_E)$(EXTN_LINT)"
	@$(ENDOLINE)
	@$(PRINT) "  * *Other $(_C)TYPE$(_D) values will be passed directly to Pandoc*"

.PHONY: $(HELPALL)-VARIABLES_CONTROL_%
$(HELPALL)-VARIABLES_CONTROL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Control Variables); fi
	@$(TABLE_M3) "$(_H)Variable"		"$(_H)Purpose"					"$(_H)Value"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)MAKEJOBS"		"Parallel processing threads"			"$(if $(MAKEJOBS),$(_M)$(MAKEJOBS)$(_D) )$(_E)(makejobs)"
	@$(TABLE_M3) "$(_C)COMPOSER_DOCOLOR"	"Enable title/color sequences"			"$(if $(COMPOSER_DOCOLOR),$(_M)$(COMPOSER_DOCOLOR)$(_D) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_DEBUGIT"	"Use verbose output"				"$(if $(COMPOSER_DEBUGIT),$(_M)$(COMPOSER_DEBUGIT)$(_D) )$(_E)(debugit)"
	@$(TABLE_M3) "$(_C)COMPOSER_INCLUDE"	"Include all: $(_C)$(COMPOSER_SETTINGS)"	"$(if $(COMPOSER_INCLUDE),$(_M)$(COMPOSER_INCLUDE)$(_D) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_DEPENDS"	"Sub-directories first: $(_C)$(DOITALL)"	"$(if $(COMPOSER_DEPENDS),$(_M)$(COMPOSER_DEPENDS)$(_D) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_STAMP"	"Timestamp file"				"$(if $(COMPOSER_STAMP),$(_M)$(COMPOSER_STAMP))"
	@$(TABLE_M3) "$(_C)COMPOSER_EXT"	"Markdown file extension"			"$(if $(COMPOSER_EXT),$(_M)$(COMPOSER_EXT))"
	@$(TABLE_M3) "$(_C)COMPOSER_TARGETS"	"Target list: $(_C)$(DOITALL)"			"$(if $(COMPOSER_TARGETS),$(_M)$(COMPOSER_TARGETS))"
	@$(TABLE_M3) "$(_C)COMPOSER_SUBDIRS"	"Directories list: $(_C)$(DOITALL)"		"$(if $(COMPOSER_SUBDIRS),$(_M)$(COMPOSER_SUBDIRS))"
	@$(TABLE_M3) "$(_C)COMPOSER_IGNORES"	"Ignore list: $(_C)$(DOITALL)$(_D) $(_E)&$(_D) $(_C)$(SUBDIRS)" \
												"$(if $(COMPOSER_IGNORES),$(_M)$(COMPOSER_IGNORES))"
	@$(ENDOLINE)
	@$(PRINT) "  * *$(_C)MAKEJOBS$(_D) ~= $(_E)(J, c_jobs)$(_D)*"
	@$(PRINT) "  * *$(_C)COMPOSER_DOCOLOR$(_D) ~= $(_E)(C, c_color)$(_D)*"
	@$(PRINT) "  * *$(_C)COMPOSER_DEBUGIT$(_D) ~= $(_E)(V, c_debug)$(_D)*"
	@$(PRINT) "  * *$(_E)(makejobs)$(_D) = empty value disables / number of threads / 0 is no limit*"
	@$(PRINT) "  * *$(_E)(debugit)$(_D) = empty value disables / any value enables / ! is full tracing*"
	@$(PRINT) "  * *$(_N)(boolean)$(_D) = empty value disables / any value enables*"

########################################
# {{{3 $(HELPALL)-TARGETS --------------

.PHONY: $(HELPALL)-TARGETS_TITLE_%
$(HELPALL)-TARGETS_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Targets,$(HEAD_MAIN))

#WORKING:NOW

.PHONY: $(HELPALL)-TARGETS_MAIN_%
$(HELPALL)-TARGETS_MAIN_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Primary Targets); fi
	@$(TABLE_M2) "$(_H)Target"		"$(_H)Purpose"
	@$(TABLE_M2) ":---"			":---"
	@$(TABLE_M2) "$(_C)$(HELPOUT)"		"Basic help output $(_N)(default)"
	@$(TABLE_M2) "$(_C)$(HELPALL)"		"Complete help output"
#WORK	$(CREATOR)
	@$(TABLE_M2) "$(_C)$(EXAMPLE)"		"Print settings template: $(_C)$(COMPOSER_SETTINGS)"
#WORK	[.]$(EXAMPLE)*
	@$(TABLE_M2) "$(_C)$(COMPOSER_CREATE)"	"Document creation $(_N)(see: $(_C)usage$(_N))"
#WORK	$(COMPOSER_PANDOC)
	@$(TABLE_M2) "$(_C)$(INSTALL)"		"Recursive directory initialization: $(_C)$(MAKEFILE)"
	@$(TABLE_M2) "$(_C)$(CLEANER)"		"Remove output files: $(_C)COMPOSER_TARGETS$(_D) $(_E)$(DIVIDE)$(_D) $(_N)*$(_C)-$(CLEANER)"
#WORK not recursive
	@$(TABLE_M2) "$(_C)$(DOITALL)"		"Recursive run of directory tree: $(_C)$(MAKEFILE)"
#WORK these change!
	@$(TABLE_M2) "$(_C)$(PRINTER)"		"List updated files: $(_N)*$(_C)$(COMPOSER_EXT)$(_D) $(_E)$(MARKER)$(_D) $(_C)$(COMPOSER_STAMP)"

.PHONY: $(HELPALL)-TARGETS_ADDITIONAL_%
$(HELPALL)-TARGETS_ADDITIONAL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Additional Targets); fi
#WORKING
	@$(TABLE_M2) "$(_C)$(DEBUGIT)"		"Runs several key sub-targets and commands, to provide all helpful information in one place"
	@$(TABLE_M2) "$(_C)$(TARGETS)"		"Parse for all potential targets (for verification and/or troubleshooting): $(_C)$(MAKEFILE)"
	@$(TABLE_M2) "$(_C)$(TESTING)"		"Build example/test directory using all features and test/validate success"
	@$(TABLE_M2) "$(_C)$(UPGRADE)"		"Download/update all 3rd party components (need to do this at least once)"

#WORKING grep "^([#][>])?[.]PHONY[:]" Makefile

.PHONY: $(HELPALL)-TARGETS_SUBTARGET_%
$(HELPALL)-TARGETS_SUBTARGET_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Target Dependencies); fi
	@$(PRINT) "These are all the rest of the sub-targets used by the main targets above:"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Dynamic"		"-"						"-"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)$(CLEANER)"		"$(_E)$(~)(COMPOSER_TARGETS)-$(CLEANER)"	"$(_M)$(addsuffix -$(CLEANER),$(COMPOSER_TARGETS))"
	@$(TABLE_M3) "$(_C)$(DOITALL)"		"$(_E)$(~)(COMPOSER_TARGETS)"			"$(_M)$(COMPOSER_TARGETS)"
	@$(TABLE_M3) "$(_C)$(DOITALL)"		"$(_E)$(~)(COMPOSER_IGNORES)"			"$(_M)$(COMPOSER_IGNORES)"
	@$(TABLE_M3) "$(_C)$(SUBDIRS)"		"$(_E)$(~)(COMPOSER_SUBDIRS)"			"$(_M)$(COMPOSER_SUBDIRS)"
	@$(TABLE_M3) "$(_C)$(SUBDIRS)"		"$(_E)$(~)(COMPOSER_IGNORES)"			"$(_M)$(COMPOSER_IGNORES)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Hidden"		"-"						"-"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)$(_N)%"		"$(_E).set_title-$(_N)*"			"Set window title to current target using escape sequence"
	@$(TABLE_M3) "$(_C)$(DEBUGIT)"		"$(_E)$(MAKE_DB)"				"Output internal Make database, based on current: $(_C)$(MAKEFILE)"
	@$(TABLE_M3) "$(_C)$(TARGETS)"		"$(_E)$(LISTING)"				"Dynamically parse and print all potential targets"
#WORK don't expose this
	@$(TABLE_M3) "$(_C)$(EXAMPLE)"		"$(_E).$(EXAMPLE){-$(INSTALL)}"			"Prints raw template, with escape sequences"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Static"		"-"						"-"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)$(COMPOSER_CREATE)"	"$(_E)$(COMPOSER_PANDOC)"			"Wrapper target which calls Pandoc directly"
	@$(TABLE_M3) "$(_E)$(COMPOSER_PANDOC)"	"$(_E)$(SETTING)-$(_N)%"			"Prints marker and variable values, for readability"
	@$(TABLE_M3) "$(_C)$(DOITALL)"		"$(_E)$(WHOWHAT)-$(_N)%"			"Prints marker and variable values, for readability"
	@$(TABLE_M3) ""				"$(_E)$(SUBDIRS)"				"Aggregates/runs the targets: $(_C)COMPOSER_SUBDIRS"
	@$(ENDOLINE)
	@$(PRINT) "These do not need to be used directly during normal use, and are only documented for completeness."
	@$(ENDOLINE)

########################################
# {{{3 $(HELPALL)-* --------------------

.PHONY: $(HELPALL)-COMMANDS_%
$(HELPALL)-COMMANDS_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Command Examples); fi
#WORK clean up $(HELPALL)-COMMANDS section
#WORK add "make all COMPOSER_TARGETS=[...]" example
#WORK make MANUAL.html LIST="README.md LICENSE.md"
#WORK make MANUAL.revealjs.html LIST="README.md LICENSE.md"
#WORK make TYPE="json" compose
	@$(TABLE_C2) "$(_E)Have the system do all the work:"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_M)make $(BASE).$(EXTENSION)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)Be clear about what is wanted (or, for multiple or differently named input files):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_M)make compose TYPE=\"$(TYPE)\" BASE=\"$(EXAMPLE_OUT)\" LIST=\"$(EXAMPLE_ONE)$(COMPOSER_EXT) $(EXAMPLE_TWO)$(COMPOSER_EXT)\""

.PHONY: $(HELPALL)-SYSTEM
$(HELPALL)-SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
$(HELPALL)-SYSTEM:
	@$(HEADER_L)
	@$(ENDOLINE)
	@$(PRINT) "$(_H)Completely recursive build system:"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)The top-level '$(MAKEFILE)' is the only one which needs a direct reference:"
	@$(TABLE_C2) "$(_N)(NOTE: This must be an absolute path.)"
	@$(PRINT) "include $(COMPOSER)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)All sub-directories then each start with:"
	@$(PRINT) "override $(_C)COMPOSER_MY_PATH$(_D) := $(_C)$(COMPOSER_MY_PATH)"
	@$(PRINT) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(COMPOSER_TEACHER)"
	@$(PRINT) "override $(_C)COMPOSER_SUBDIRS$(_D) ?="
	@$(PRINT) "$(_C).DEFAULT_GOAL$(_D) := $(_C)$(DOITALL)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)And end with:"
	@$(PRINT) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)Back in the top-level '$(MAKEFILE)', and in all sub-'$(MAKEFILE)' instances which recurse further down:"
	@$(PRINT) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(PRINT) "include [...]"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)Create a new '$(MAKEFILE)' using a helpful template:"
	@$(PRINT) "$(_M)$(~)(RUNMAKE) COMPOSER_TARGETS=\"$(BASE).$(EXTENSION)\" $(EXAMPLE) >$(MAKEFILE)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)Or, recursively initialize the current directory tree:"
	@$(TABLE_C2) "$(_N)(NOTE: This is a non-destructive operation.)"
	@$(PRINT) "$(_M)$(~)(RUNMAKE) $(INSTALL)"
	@$(ENDOLINE)

########################################
# {{{2 $(CREATOR) ----------------------

.PHONY: $(CREATOR)
ifneq ($(MAKECMDGOALS),$(filter-out $(CREATOR),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(CREATOR): .set_title-$(CREATOR)
	@$(call $(HEADERS))
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_BASENAME)_Directory)
endif
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_GITIGNORE)		>$(CURDIR)/.gitignore
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_LICENSE)		>$(CURDIR)/LICENSE$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_README)		>$(CURDIR)/README$(COMPOSER_EXT_DEFAULT)
	@$(MKDIR)						$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))
	@$(ECHO) "$(DIST_ICO)"		| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/icon.ico
	@$(ECHO) "$(DIST_ICON)"		| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/icon.png
	@$(ECHO) "$(DIST_SCREENSHOT)"	| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/screenshot.png
	@$(MKDIR)						$(abspath $(dir $(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))))
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_REVEALJS_CSS)	>$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))
	@$(LS) \
		$(CURDIR)/.gitignore \
		$(CURDIR)/*$(COMPOSER_EXT_DEFAULT) \
		$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART)) \
		$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))
ifneq ($(COMPOSER_RELEASE),)
	@$(ECHO) "$(DO_BOOK)-$(EXAMPLE_OUT).$(EXTN_LPDF):" >$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(EXAMPLE_ONE)$(COMPOSER_EXT_DEFAULT)" >>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(EXAMPLE_TWO)$(COMPOSER_EXT_DEFAULT)" >>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n" >>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(RUNMAKE) COMPOSER_STAMP="$(COMPOSER_STAMP_DEFAULT)" COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(CLEANER)
	@$(RUNMAKE) COMPOSER_STAMP= COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(DOITALL)
	@$(RM) \
		$(CURDIR)/$(COMPOSER_SETTINGS) \
		$(CURDIR)/$(COMPOSER_STAMP) \
		>/dev/null
endif

########################################
# {{{2 $(EXAMPLE) ----------------------

#> update: COMPOSER_OPTIONS

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(RUNMAKE) --silent COMPOSER_DOCOLOR= .$(EXAMPLE)

.PHONY: .$(EXAMPLE)-$(INSTALL)
.$(EXAMPLE)-$(INSTALL):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN,6,$(_H)$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)))
	@$(call $(EXAMPLE)-var-static,,COMPOSER_MY_PATH)
	@$(call $(EXAMPLE)-var-static,,COMPOSER_TEACHER)
	@$(call $(EXAMPLE)-print,,include $(_E)$(~)(COMPOSER_TEACHER))

.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN,6,$(_H)$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)))
	@$(call $(EXAMPLE)-print,1,$(_H)$(MARKER) Global)
	@$(foreach FILE,$(COMPOSER_EXPORTED),\
		$(call $(EXAMPLE)-var,1,$(FILE)); \
	)
	@$(if $(COMPOSER_DOCOLOR),,$(ENDOLINE))
	@$(call $(EXAMPLE)-print,1,$(_H)$(MARKER) Local)
	@$(foreach FILE,$(COMPOSER_EXPORTED_NOT),\
		$(call $(EXAMPLE)-var,1,$(FILE)); \
	)
	@$(if $(COMPOSER_DOCOLOR),,$(ENDOLINE))
	@$(call $(EXAMPLE)-print,1,$(_H)$(MARKER) Special)
	@$(foreach FILE,$(COMPOSER_RESERVED_SPECIAL),\
		$(call $(EXAMPLE)-print,1,$(_C)$(FILE)-$(COMPOSER_BASENAME).$(FILE).$(EXTENSION)$(_D): $(_M)$(EXAMPLE_ONE)$(COMPOSER_EXT) $(EXAMPLE_TWO)$(COMPOSER_EXT)); \
	)

override define $(EXAMPLE)-print =
	$(PRINT) "$(if $(COMPOSER_DOCOLOR),$(CODEBLOCK))$(if $(1),$(COMMENTED))$(2)"
endef
override define $(EXAMPLE)-var-static =
	$(call $(EXAMPLE)-print,$(1),override $(_E)$(2)$(_D) :=$(if $($(2)), $(_N)$($(2))))
endef
override define $(EXAMPLE)-var =
	$(call $(EXAMPLE)-print,$(1),override $(_C)$(2)$(_D) :=$(if $($(2)), $(_M)$($(2))))
endef

################################################################################
# {{{1 Embedded Files ----------------------------------------------------------
################################################################################

override DIST_ICO			:= AAABAAEAEBACAAEAAQCwAAAAFgAAACgAAAAQAAAAIAAAAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAGA8AAAwZgAAGMIAAAzAAAAGwAAADMAAABjAAAAwwgAAYGYAAAA8AAAAAAAAAAAAAAAAAAD//wAA//8AAA+BAAAHAAAAAgAAAIAAAADAGAAA4B8AAMAfAACAGAAAAgAAAAYAAAAPAAAA/4EAAP//AAD//wAA
override DIST_ICON			:= iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAc0lEQVQ4y8VTQQ7AIAgrZA/z6fwMD8vcQCDspBcN0GIrAqcXNes0w1OQpBAsLjrujVdSwm4WPF7gE+MvW0gitqM/87pyRWLl0S4hJ6nMJwDEm3l9EgDAVRrWeFb+CVZfywU4lyRWt6bgxiB1JrEc5eOfEROp5CKUZInHTAAAAABJRU5ErkJggg==
override DIST_SCREENSHOT		:= iVBORw0KGgoAAAANSUhEUgAAAeQAAADjCAIAAADbvvCiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH3gUQBTsYVQy6lQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAVJ0lEQVR42u2d3basqA5G6Rr1RrVett9pnXc6F7Xb4eYnhBAQdM6L3dUuxYAQY5SPfz4hhBD+FwAAYEW+XvpFQwAArM/bvcTf39/vj5+fn559YBq/v79cCIANAuxPoxc27KbfKBR7Zn33t52/3r0W27U5QJOXfm00in5OuJ9r3FB3KXm0JyKyBlic4c5a/4h9bWQ0zltt6gfJjQAsxfvsKH9+fs5DtJRZ1uzT6qq+5TQ5iO/Oh+XnQs7njSxMj8oeUton6HLx0ZbWklObDfWKLpOv51XafO5R58bR1115BXk4gKdkQ87uoORx0r9mf5tz1nJknSaso9/VMg/7sztHv6N9SnvK57KVrGlVTb00NtuecjQ2l/5trbv+CgLc20u/m0ZsGqA5jpZqZJTuoAmmUguPo4TDJ2RF0six0wxNvdwTIL4NdQ6ZhfbxqinAfmkQecSen0Ojkbz+aMHCvcLPNIeDRwYImheM0VA/Yh93j+DrU0rJnJ6Ib/RXgxqb9QYcNjc5u9L+muSPpnDZpCgs2PquAzAwso5C5vM7otQLfB9Uq6/dovSivJvsWbJvqITn6Mj4asny2atZC8G/CCWnFmZtttXLKyaNaqG0OTUg/d9qOcqaAtwf/aSY1uipdZ+V46ael3X3sHm1JyeAp3npfxByavU1G8V3S9nMh9sAZmcdcNYAAFs4a1T3AAA2AGcNALCVs3afZsYWtly4BYDIGgAAZvPnBeO/tZkvbGHLRlsY2HAnPsd/PjxEs4U0CMDCzvpDZM0WImsAImu2sIXIGsAnsuYFIwDABjCDEQBggzQIkTUAwAbgrAEAcNYAAODBe2vr7yFLj7g+ADg768itROs0Rl+8HvtEW7LlpPsoEZae2cX3pY0AABAjfGdd8tSh5dPX7A/lb/3No+lPi8fXAACplzbmrOcErWb/xaIkAHAz3mlcvIinG2dMmiPOpmWOdYGDLpmjLDla+hYAoCHADo1pkFL64vdEupuQ+rAtoZvdobpWb2pzdkv6r+ao6pZsa5AGAQBVGqTkmMwZEtt7wugoQ+zZFIn7xrbfkDmKmtOb0PEnImsA0PNKfWW/E0mF0MYdtRQ/Pz/pJzEH9DYA6HXWhgB2gr9uLaEUVpfKaf3y5IvwsaBQd7IcANDDW5++OPugY+fqhI5zaiV67SanLLxeMEbl6Gsh52Q05WjaBwBAxfGCcUE0LxjT15KdEfSgEvprAQCP9tIrO+uNbhsAAEOdNXrWAACrO+uAkNP8kgEADDQ46+xCpU1CTiN837lA89vIdEoh4koAsFyArZzBmLrsy9cw1UwCVBrQcywAwGgv3bX4wBFKG0Ja/CAAgB7/6eZ6Tz3oRKn+RrRlWjUBAJwD7GBKg6RbUkkms0iTITzPyiRlzyuobxP+A8CCXtpfIjU9NlvaoK8s+HgDAG7JECEnAAAY4qznMz/DQE4DAPalQcjJxUuev1+esyRNdmWW6LxLLZEDAJBy2XRzF8/IDEYAuD2fa501AADonfWLhgAAWB+EnHY9OwDgrCu+KYjySZELmyzkFG0vnT2SoEqPEgSqwt8vY/nIBABm0DSDsTQ/MDtd8FohJ+HswvRFgxwVzhoAJnjprpx1dmFDZRB9lY+TbZ55pwEA0HNDIScXIrVuAIBreUe+qeqh0gkmqY+LIut0yzhXqDm7V8kAALOdtV7IKXoFJ2Q/zgmHUjkTIuL0RMqIPjoQHw0AF9Ir5PTzH6tlMPayGQBA5azdsxCOe47w1wAAe9Eg5HROldhy1uEKIafS5+FN9dKUAwAwDoScdj07ADwEhJwAALZx1gg5AQBsAEJO2AwA93LW2SxzdRLKjYWcWn008k8AYEcv5FT6U1YRSfg9IkotnXGCkFO/qQAAVS89MGeNkBMAgBcIORXvNK0fF/7+/mYD82M7AICZZiEnjY+rRtZ3FXKKmrGUGQcAMDprvZCTxl9HCQd5t9ERMUJOAHADeoWcls1gyDsg5AQAWzpr9yyE454j/PX8+gIA9NAg5BQUkkzKnPU9hJyytYh+480BwAWEnGbXghmMANAEQk4AANs4a4ScAAA2ACEneAr0Ftg+wP60dPdoPp5my4Th1/Sn9b2J+7G856QpYHsvbRNy0ggeTZu2jrNexFlv0eY4a9jUWRtz1umDpLxl8giZ81EgNlf7AAB44T/dvBTLrOOMlBrc55nr2Y+1NTokacnHx9el1kjP3lSOLEiSLed8oNLCVFQgPaR6Llv72Foe4C7ZEKuetTJnPUfPujUhICdzSkqEnVsi7WzZqpK3TcuR01A9Fv7+TWhXMO9vH9sVzJZDGgQ29dK9kXUaK2WFnKZFNzbjvZIAR0goxLZpm2hs9ipH02heClalW6mcH2vqM9G82aPls9cC4A5pEC+J1IeTPu+7NKZSanXa5VP2Fr23Hdfy9Ge4DS+z+whiSrQpNTE6rHax6sgDyLnmUJAEEWzQe5OqwWuqkWhMsn3NEvXDo/rytQDYOLIOCiGnVKRJsyVc/YKxKjVVEp+SswHm1jCkaM4P9Up//X38T9f5zVpoCMnTQ5TtfD7QJvs1uuUBFqVpUszQ2MpWrGYCjvtyt7BgbO7VWwAW9dJznDXOAgCgx1mjugcAsLqzDvcTciJTCQC3pMFZe83i8yX7GpCsBQDcMMBWzmA8/7VnFt+IyFq5HQBgUy/ttvjA4tJOAABb80qj4GnSpvhrAIA2Z32eEdOTWf5ORjh/zZpucTkRAMCj8JdIXU3aCQCAyBoAACY6637WlHYCALgHDTMYHb+z9vryWpDZ4/kAAO7Bp9VZ++LiT5nBCAA4awAAWMVZv2gIAID1QcgJAGCTAFupZ21e0zpaG3uEs1ZuBwDY1Eu/Ut/a5ByPhZqEo35O0O4AAAa6ctbZZfGUuh8EvwAAzc5aKeTUtGBr1VPjrwEA2pz10OnmCDkBAHTSLOQUBdfZ6Di7eou8DwAADIyseXMIADDPWTfh4ppJWAMA6HlHLnhEjJxmq12EswEAngNCTgAAS4OQEwDANs4aIScAgA1AyAkA4HbOOnKFpTeHpY0jHGj2m24+NQGAu3Go7lWngGcV9YS/yr99I2vldgCATb301Jz1OQrGnwIA6GkTcvKNiPHXAABtzto83fwQaSod9dUSQcgJAKCHZiGn1Bfr9zmXjKcGAJgXWQMAwDxnPQ4+2AAA6KdByOmsZN2UJylNXUHICQBACUJOAABLg5ATAMA2zhohJwCADcBZAwDgrAEAwNdZl7SZ2MKWHbcAEFkDAMBs/nwN8m+iQ/3LFrZsu4WBDXfic/znw0M0W0iDACzsrD9E1mwhsgYgsmYLW4isAXwia14wAgBsANPNAQA2SIMQWQMAbADOGgAAZw0AADhrAACcdRs7fjUl2Bwtx76m8amF65s9p//s2wh8fUj73DOyHnfl1p9YkVr4XXwnnSQyrZ1vMJCurUK211VNyu5wS6dma5/b9DHSIOEhffrG5+VqPvlaPKem79TZl9Yz/AZu343pPul9w31dxNSe4193mzVnF0r2renMktN6ado5u4OmfbzComz7VPtG1Of7e5S744hO1DQKzNeipxaac5X62Hdjkz3y0I4u9Aj/I9usHE1avhMZ05m7qZXnhFHPnOBSKuqgtCUtR046K20uPaHIv1tL7qmp0qpzIeaS03pp2rlkz1V9I1sLzdmjnWded3OfrKZBJl8Lzbmy+5Q0A/TtIzfOiFEp29w6mkr2fL30uym30nlrKh2ebs9uOW5Hmvi3yWZbfJfNGrceoqyppuRowXi54sJfvVrM0D62Fsv+1eXsco/6/tD0zNZayFe5OgoM19SxFhrDhMvUn9uNBsK4UWnoLT0X662p8CIp/POThaPNjjX1egpOa7pUYs7cYhfWYqjN1Z45cxQsWPLM65XaP25UTvaZrzT2jkxxPGtPUedkUPVRyCuGWr+mky10aeeht/+mbydKfV7/uF29XoNq19k3vodnH9In1GJcV5HvNONGpe1Erfa8S/efc9hfKlQWF44eEjtvcdlyouR9p83nPx0pJ30txtU0W3JkoWPJ8jOyssVaz94Z8uivjrxzqaYTrnu2DTX9sPRCT+4b6dvIQa9J9SVHSTxNHyttOQoZ6n80NldHUwPpC0aAJ/DkPq957QbrUH/BCAC3ZFwcDeNAzxoAYPXIOjCDEQBgC9qcdZOQSutrXJfcmaacdCbCUpQ+8jcYPHNlwplNOq4frtwHVrhei691OXnsTO6Hbc56nJCK77eQcpP9/MdVfc5lbshqCB+fTjsXrHm97jp2JgtLvRg564wTKjsiqtquta+1efHm2jdq6Uc13VwvpBKsMknVs0efUpolWryaUmOPIGojSPMEk7CUUNkmQR9lOytbvlXwKD171mbhobWnjwWFWI9G8iyYBLNKrbHU9Yp61HPGjpc/zNZd0z4hnL6z1ggnhXahmZKMiyxh0yMR1T99yCwsla2p3sIm2SbDY9cIKa6qJUIL9EgyaebvVROOyrqXJHs6t1Trtdr10vexW46daf4w3eev76zNwiUGt6gsTdOOXlIv1ejbbPM4wZpO8akmEQOXWe9pj1K2qlIgJZVJmP+8JYwdTd8QdC1WuF62lrzH2HH0h+a+966W0p9Bc1FPPz8Rd8obueQEU3smy0gNeiWraedOm3fMI9tadYQU1w2u16Zjx7c1DDeMlyats5R4UGfJEzzFZBmpmVenR8hphBSO8PjZ9Kbe8JmprL4m1FSwwZZwX+F63X7seLXGIaFlECKWZjAaXpuE8gIcoTHlX1r7o/P1gi0no3T90fsoWc4tq6QTdQXfdT2U9ujbOfvmLQpAzGt/GNpQDn/MrwHPbTKi5NLV2eJ6PWTsOPpDze05qtfXS/9JXQMMCpGWCsr6jbmr7NH86/XwcdHU1F8vjTYIjO2XN0tP3zjhfsvrtbK/1jf1p5oGAQCAy0HICQBgG15yuP5YuRyvuq8mfCPY8zTBI/2UmYc/sF8ooTPz1C6n08xUGuKsn5y9mizRAk/2hs+sZvWzwpn+59B3W3kNnZdXuz9BLufGdy8Ej9aJCZ4cDy1l1WoWvs/9/plyOWGkRIuL8E2wfuNZ6out9qwveBSdvakceSKc8strjSRT9LsqS2QWPPLqP16yTaEgEZWue9s5TrOTPKpiWJrxrhFgyraYlwcI4W8hp7TCD5HLqf7W7DlT+Mbr7He6gqXkYKkcjfSPzUKbLJpv+9iu4Ijea06DaNrHIAQml1O10D03omnDeMHcx8rljJNosbWJpv2zoki2WtxD8EhzB7KVo2m0kvrSiByjTfBoUP8xyza5tI9ZCCwtR9MTlLuN8wB7r27uJZdzuUSLY933yuQOEjxSSvwMGn7CiVrlHsfdL3fsP9PWk1qTrheM95DLuUSixSUDeLbZVovbCx5VDb5wdbfO+73t00Pf/jO/XtV9qr2upz9f21veGr+QvgfQv4Q8V6+0RfMsqSmnVLJ+uAo1Feo1+o49ru73uIJZS85vHZVhb7pzyUJDSJ4eomzn84HK9jFcQcf+I+e7SuOruo/SQmU2o7UNIzOuic1bhZyQy1E+c2ydX0LwaHee2f53rXX8gtEx3fPMr0eHxibz64K/4wrCUiDkBACwemQdEHICANiCVZx19Eo6+129Zk104Wt8eW311BhbLcZ9SD9I18bFwqGiSJfLCQUPbf6035a6q+2Tm0tGSk+vgFbera1vyIXZjipN3U5Lzr6orU4JHVGLcV/2aOoFI/rhuL7h/tXwIiMFbh5Z94wQ2UWuJlLqNTIBGCkPddaax6KQzLU3HCX4oBGeyPxdZEnzIfrrJfXKtmr2cbjVwpLMgtwa8rN2Tx8L3nJCsoXKK+jSNwbVdOZI0fQWcE6DaDSlstfSdpR+dIXuNYk1JVfTDqW62+ZHlLxb6WG5pFsW6YplH4cNFmbnYpSyMaWeI8+lkqc1tiZ8NG2YnZNiEwnx6hteqa1rR0pUU+VEf7A76zWf92W5HH1vMOjsTItuNDIu8m1ygqkXiiJ5teFqmShHC68dKXBBGmRZfy3vcIlU3qM44seqHCCRFCMFrnTWss5sSTbFa5W/aS7g3qtNzmmiXfz1tUJFg2xYcKTAkDSIIOwS/SnKnJbEeuSj+nuJoBWnX28i/L3QSVW+Mi05e4u65Os6pbiS4SF9QVGkziZyly4y9I2h4gSTR0q2t4A/rUJOd73H0sMAGCkre2mmm3dFoACMFJgDQk4AAKtH1oHIGgBgCzLO2mvWaes66DMxzLCqzsdTblm2TbyuMgCMCrA/Lc665+OkRXyWQUGtNDG6dcv9/B3OGmCOl36lY68690E5htd/EbGIhXztBABV6gvmhkRzIJph3PS1ZrbkkvZFv0tttbBHK7Jn0rNNQyd7daJWjcQwU9s0yhLCFgC4IA0iSJWXfgsKavJvOSOhSSCk4uilLVFqokd2XZOPNifrR6Rl0n/7kzl3WhoYYBcv/e5MXJRkzvu9kmaynCaSjSZbyjGsrFGpVJhLp65pGtacOPJN5pwfRIijAfZIgwxCKaK4WspbeROa7KlHkOp2Mg8C4HJevs6iVRdYs/GSD0UW9NQuK0aWhLfS0rKvPQmxAVaMrEuvlQxK9qUH7ZLY01CZG8FCvahN9qiS8I1QeJOnFmSAlEJOJeEtoRx5CwBMokfICSbnYS4vAQCu8tJMN98GEscATwYhJwCA1SPrMOJrkKb8L9HifLaYXAoAGZ/9UQ9y8279q3ytnG/dLhfstegabQ4wzUu/njmuVliF78IWI7IG2I7hzlr/0D3Tp4/zVpv6QXIjAIvzPjvKaCp2KbOs2afVedmWmtWIGaUTwTVyVK1fXkfN2FSyQdYqLVme8u4V6c8XjSpJcXFrgYdmQ0pyP5EnDQqRJnPOWo6s5dl0ss3y/lmxp6pVXiVr2rAkNdVqs+2Z5nLRKIP+OMD9vPS7aQxnZ1RfmEDwmg89ISviLofiJdzROh/Vt3E0olFIlAAEwVmXch3R2L52/FTzM4fB6+RkR5uxV/iJaBSAklfr4C/pQlw7Gbopo6KM+AzrNLo/FugNOGxuTfqXFEv6rxGiUQCjIusoZE7llqL4WiOBFCUc5d1kX1OVUhIkos7Fas5VzVoI/kXWy9YIMNlkrbxi0qVEowDgD+5CTpqYtLoIy7XsuBKKr82IRgGs5qXRBgnVJ3RsthlDaAzg5awDzhoAYAtnjUQqAMAG4KwBAHDWAACAswYAeAj/B20celP5v/1/AAAAAElFTkSuQmCC

################################################################################
# {{{1 Heredoc Function --------------------------------------------------------
################################################################################

override define DO_HEREDOC =
	$(ECHO) '$(subst ',[Q],$(subst $(call NEWLINE),[N],$(call $(1))))[N]' \
		| $(SED) \
			-e "s|[[]Q[]]|\'|g" \
			-e "s|[[]N[]]|\\n|g"
endef

################################################################################
# {{{1 Heredoc: gitignore ------------------------------------------------------
################################################################################

override define HEREDOC_DISTRIB_GITIGNORE =
################################################################################
# $(subst $(NULL) $(COMPOSER_VERSION),,$(COMPOSER_FULLNAME))
################################################################################

########################################
# $(COMPOSER_BASENAME)

#>/$(COMPOSER_SETTINGS)
#>/$(COMPOSER_CSS)
#>/$(COMPOSER_STAMP_DEFAULT)

$(subst $(COMPOSER_DIR),,$(COMPOSER_TMP))/

########################################
# $(UPGRADE)

$(subst $(COMPOSER_DIR),,$(COMPOSER_PKG))/

########################################
# $(DEBUGIT) / $(TESTING)

/.$(COMPOSER_BASENAME)**
/$(COMPOSER_BASENAME)**

################################################################################
# End Of File
################################################################################
endef

################################################################################
# {{{1 Heredoc: revealjs_css ---------------------------------------------------
################################################################################

override define HEREDOC_DISTRIB_REVEALJS_CSS =
/* #############################################################################
# $(subst $(NULL) $(COMPOSER_VERSION),,$(COMPOSER_FULLNAME))
############################################################################# */

@import url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(REVEALJS_CSS_THEME))");

/* ########################################################################## */

.reveal .slides {
	background:			url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(COMPOSER_ART)/icon.png)");
	background-repeat:		no-repeat;
	background-position:		100% 0%;
	background-size:		auto 20%;
}

/* ################################## */

:root {
	--r-heading-text-transform:	none;
	--r-heading1-size:		200%;
	--r-heading2-size:		160%;
	--r-heading3-size:		140%;
	--r-heading4-size:		120%;
	--r-heading5-size:		100%;
	--r-heading6-size:		100%;
}

.reveal * {
	text-transform:			none;
	text-align:			left;
	block-align:			left;
}

.reveal dl,
.reveal ol,
.reveal ul,
.reveal table {
	display:			block;
	margin-left:			2em;
}

/* #############################################################################
# End Of File
############################################################################# */
endef

################################################################################
# {{{1 Heredoc: license --------------------------------------------------------
################################################################################

#WORKING

override define HEREDOC_DISTRIB_LICENSE =
Composer CMS License
========================================================================

License Source
------------------------------------

  * [http://opensource.org/licenses/BSD-3-Clause](http://opensource.org/licenses/BSD-3-Clause)

Copyright
------------------------------------

    Copyright (c) 2014, $(COMPOSER_COMPOSER)
    All rights reserved.

License
------------------------------------

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
endef

################################################################################
# {{{1 Heredoc: readme ---------------------------------------------------------
################################################################################

#WORKING

override define HEREDOC_DISTRIB_README =
% Composer CMS: User Guide & Example File
% $(COMPOSER_COMPOSER)
% $(COMPOSER_VERSION) ($(DATEMARK))

Composer CMS
------------------------------------------------------------------------

![Composer Icon]($(notdir $(COMPOSER_ART))/icon.png "Composer Icon")
"Creating Made Simple."

* Homepage: [https://github.com/garybgenett/composer](https://github.com/garybgenett/composer)
* [License]

Contents
------------------------------------

  * [Introduction]
    * [Overview]
    * [Quick Start]
    * [Goals]
  * [Details]
    * [Compatibility]
    * [Versioning]
    * [Dependencies]
    * [Caveats]

[Composer]: #composer-cms
[Contents]: #contents

[Introduction]: #introduction
[Overview]: #overview
[Quick Start]: #quick-start
[Goals]: #goals
[Details]: #details
[Compatibility]: #compatibility
[Versioning]: #versioning
[Dependencies]: #dependencies
[Caveats]: #caveats

[License]: https://github.com/garybgenett/composer/blob/master/LICENSE.md
[Readme]: https://github.com/garybgenett/composer/blob/master/README.md

[Coreutils]: http://www.gnu.org/software/coreutils
[GNU]: http://www.gnu.org
[Git]: http://www.git-scm.com
[LaTeX]: http://www.tug.org
[Make]: http://www.gnu.org/software/make
[Markdown Viewer]: https://github.com/Thiht/markdown-viewer
[Markdown]: http://daringfireball.net/projects/markdown
[Pandoc]: http://www.johnmacfarlane.net/pandoc
[Reveal.js]: https://github.com/hakimel/reveal.js
[W3C Slidy2]: http://www.w3.org/Talks/Tools/Slidy2
[Wget]: https://www.gnu.org/software/wget

Introduction
========================================================================

Overview
------------------------------------

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

![Composer Screenshot]($(notdir $(COMPOSER_ART))/screenshot.png "Composer Screenshot")

Quick Start
------------------------------------

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

Goals
------------------------------------

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
a wrapping engine based on it's years of history as one of the most
popular and highly used source file processing systems in use.

The final result is [Composer], which leverages these two tools to
accomplish the original goals with a minimum amount of user knowledge
and expertise, and to provide a solid foundation for simplified
management of larger content production efforts.

Details
========================================================================

Compatibility
------------------------------------

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

Versioning
------------------------------------

[Composer] is not really revisioned into "releases" outside of the
source code repository.  Each commit is tested using `make test` first,
so the latest source should always be ready for production.

If you require greater assurance of stability, use a version of the
source that is tagged with a version number.

Dependencies
------------------------------------

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

Officially, [Composer] is tested on [GNU]/Linux, Mac OS X and Windows (using
the included MSYS2 tools).

Caveats
------------------------------------

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
    * Recursion handling and the `$$(COMPOSER_MY_PATH)` variable may be
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
          to define it's own behavior (i.e. no inheritance).
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
endef

################################################################################
# }}}1
################################################################################
# }}}1
################################################################################
# {{{1 Composer Output ---------------------------------------------------------
################################################################################

# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
#	default	= light gray
#	header	= light green
#	core	= cyan
#	mark	= yellow
#	note	= red
#	extra	= magenta
#	syntax	= dark blue
ifneq ($(COMPOSER_DOCOLOR),)
#>override _D				:= \e[0;37m
override _D				:= \e[0m
override _H				:= \e[0;32m
override _C				:= \e[0;36m
override _M				:= \e[0;33m
override _N				:= \e[0;31m
override _E				:= \e[0;35m
override _S				:= \e[0;34m
else
override _D				:=
override _H				:=
override _C				:=
override _M				:=
override _N				:=
override _E				:=
override _S				:=
endif

########################################

#> update: includes duplicates
override MARKER				:= >>
override DIVIDE				:= ::
override TOKEN				:= ~
override NULL				:=

# https://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
override define NEWLINE =
$(NULL)
$(NULL)
endef

########################################

override COMMENTED			:= $(_S)\#$(_D) $(NULL)
override CODEBLOCK			:= $(NULL)	$(NULL)
override ENDOLINE			:= $(ECHO) "$(_D)\n"
override LINERULE			:= $(ECHO) "$(_H)";	$(PRINTF)  "-%.0s" {1..$(COLUMNS)}	; $(ENDOLINE)
override HEADER_L			:= $(ECHO) "$(_S)";	$(PRINTF) "\#%.0s" {1..$(COLUMNS)}	; $(ENDOLINE)

# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
ifneq ($(COMPOSER_DOCOLOR),)
override TABLE_C2			:= $(PRINTF) "$(COMMENTED)%b$(_D)\e[128D\e[22C%b$(_D)\n"
override TABLE_M2			:= $(PRINTF) "| %b$(_D)\e[128D\e[22C| %b$(_D)\n"
override TABLE_M3			:= $(PRINTF) "| %b$(_D)\e[128D\e[22C| %b$(_D)\e[128D\e[54C| %b$(_D)\n"
override PRINT				:= $(PRINTF) "%b$(_D)\n"
else
override TABLE_C2			:= $(PRINTF) "$(COMMENTED)%-20s%s\n"
override TABLE_M2			:= $(PRINTF) "| %-20s| %s\n"
override TABLE_M3			:= $(PRINTF) "| %-20s| %-30s| %s\n"
override PRINT				:= $(PRINTF) "%s\n"
endif

override define TITLE_LN =
	ttl_len="`$(EXPR) length '$(2)'`"; \
	ttl_len="`$(EXPR) $(COLUMNS) - 2 - $(1) - $${ttl_len}`"; \
	if [ "$(1)" -gt "0" ] && [ "$(1)" -le "$(HEAD_MAIN)" ]; then $(ENDOLINE); $(LINERULE); fi; \
	$(ENDOLINE); \
	$(ECHO) "$(_S)"; \
	if [ "$(1)" -le "0" ]; then $(ECHO) "#"; fi; \
	if [ "$(1)" -gt "0" ]; then $(PRINTF) "#%.0s" {1..$(1)}; fi; \
	$(ECHO) "$(_D) $(_H)$(2)$(_D) $(_S)"; \
	eval $(PRINTF) \"#%.0s\" {1..$${ttl_len}}; \
	$(ENDOLINE); \
	$(if $(3),\
		if [ "$(1)" -gt "$(HEAD_MAIN)" ]; then $(ENDOLINE); fi \
		,$(ENDOLINE) \
	); \
	if [ "$(1)" -le "0" ]; then $(LINERULE); $(ENDOLINE); fi
endef

################################################################################
# {{{1 Composer Headers --------------------------------------------------------
################################################################################

########################################
# {{{2 .set_title ----------------------

#> grep -E "[.]set_title" Makefile
.PHONY: .set_title-%
.set_title-%:
ifneq ($(COMPOSER_DOCOLOR),)
	@$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
else
	@$(ECHO) ""
endif

########################################
# {{{2 $(HEADERS) ----------------------

#> update: COMPOSER_OPTIONS
ifneq ($(COMPOSER_DEBUGIT_ALL),)
override $(HEADERS)-list := $(COMPOSER_OPTIONS)
override $(HEADERS)-vars := $($(HEADERS)-list)
else
override $(HEADERS)-list := \
	COMPOSER_DEPENDS \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES
#> update: $(HEADERS)-vars
override $(HEADERS)-vars := \
	TYPE \
	BASE \
	LIST \
	_CSS \
	CSS \
	TTL \
	TOC \
	LVL \
	MGN \
	FNT \
	OPT
endif

ifneq ($(COMPOSER_RELEASE),)
override $(HEADERS)-release = $(subst $(abspath $(dir $(COMPOSER_DIR))),...,$(1))
else
override $(HEADERS)-release = $(1)
endif

.PHONY: $(HEADERS)-$(EXAMPLE)-$(DOITALL)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): override export COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE) := $(DOITALL)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): override export $(HEADERS)-list := $(COMPOSER_OPTIONS)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): override export $(HEADERS)-vars := $(COMPOSER_OPTIONS)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): $(HEADERS)-$(EXAMPLE)
$(HEADERS)-$(EXAMPLE)-$(DOITALL):
	@$(ECHO) ""

.PHONY: $(HEADERS)-$(EXAMPLE)
$(HEADERS)-$(EXAMPLE):
	@$(call $(HEADERS))
	@$(call $(HEADERS),1)
	@$(call $(HEADERS)-run)
	@$(call $(HEADERS)-run,1)
	@$(call $(HEADERS)-note,$(CURDIR),$(@))
	@$(call $(HEADERS)-dir,$(CURDIR),directory)
	@$(call $(HEADERS)-file,$(CURDIR),creating)
	@$(call $(HEADERS)-skip,$(CURDIR),skipping)
	@$(call $(HEADERS)-rm,$(CURDIR),removing)

.PHONY: $(HEADERS)
$(HEADERS): $(NOTHING)-$(HEADERS)
	@$(ECHO) ""

.PHONY: $(HEADERS)-%
$(HEADERS)-%:
	@$(call $(HEADERS),,$(*))

.PHONY: $(HEADERS)-run-%
$(HEADERS)-run-%:
	@$(call $(HEADERS)-run,,$(*))

override define $(HEADERS) =
	$(HEADER_L); \
	$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(call $(HEADERS)-release,$(COMPOSER_DIR))"; \
	$(HEADER_L); \
	$(TABLE_C2) "$(_E)MAKEFILE_LIST"	"[$(_N)$(call $(HEADERS)-release,$(MAKEFILE_LIST))$(_D)]"; \
	$(TABLE_C2) "$(_E)COMPOSER_INCLUDES"	"[$(_N)$(call $(HEADERS)-release,$(COMPOSER_INCLUDES))$(_D)]"; \
	$(TABLE_C2) "$(_E)CURDIR"		"[$(_N)$(call $(HEADERS)-release,$(CURDIR))$(_D)]"; \
	$(TABLE_C2) "$(_E)MAKECMDGOALS"		"[$(_N)$(MAKECMDGOALS)$(_D)] ($(_M)$(strip $(if $(2),$(2),$(@))$(if $(COMPOSER_DOITALL_$(if $(2),$(2),$(@))),-$(_E)$(COMPOSER_DOITALL_$(if $(2),$(2),$(@))))$(_D)))"; \
	$(TABLE_C2) "$(_E)MAKELEVEL"		"[$(_N)$(MAKELEVEL)$(_D)]"; \
	$(foreach FILE,$(if $(COMPOSER_DEBUGIT_ALL),$($(HEADERS)-list),$(if $(1),$($(HEADERS)-list))),\
		$(TABLE_C2) "$(_C)$(FILE)"	"[$(_M)$($(FILE))$(_D)]$(if $(filter $(FILE),$(COMPOSER_EXPORTED)), $(_E)$(MARKER)$(_D))"; \
	) \
	$(HEADER_L)
endef

override define $(HEADERS)-run =
	$(LINERULE); \
	$(TABLE_M2) "$(_H)$(COMPOSER_FULLNAME)"	"$(_N)$(call $(HEADERS)-release,$(COMPOSER_DIR))"; \
	$(TABLE_M2) ":---"			":---"; \
	$(TABLE_M2) "$(_E)MAKEFILE_LIST"	"$(_N)$(call $(HEADERS)-release,$(MAKEFILE_LIST))"; \
	$(TABLE_M2) "$(_E)COMPOSER_INCLUDES"	"$(_N)$(call $(HEADERS)-release,$(COMPOSER_INCLUDES))"; \
	$(TABLE_M2) "$(_E)CURDIR"		"$(_N)$(call $(HEADERS)-release,$(CURDIR))"; \
	$(TABLE_M2) "$(_E)MAKECMDGOALS"		"$(_N)$(MAKECMDGOALS)$(_D) ($(_M)$(strip $(if $(2),$(2),$(@))$(if $(COMPOSER_DOITALL_$(if $(2),$(2),$(@))),-$(_E)$(COMPOSER_DOITALL_$(if $(2),$(2),$(@))))$(_D)))"; \
	$(TABLE_M2) "$(_E)MAKELEVEL"		"$(_N)$(MAKELEVEL)"; \
	$(foreach FILE,$(if $(COMPOSER_DEBUGIT_ALL),$($(HEADERS)-vars),$(if $(1),$($(HEADERS)-vars))),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$($(FILE))$(_D)$(if $(filter $(FILE),$(COMPOSER_EXPORTED)),$(if $($(FILE)), )$(_E)$(MARKER)$(_D))"; \
	) \
	$(LINERULE)
endef

override define $(HEADERS)-note =
	$(TABLE_M2) "$(_M)$(MARKER) NOTICE" "$(_E)$(call $(HEADERS)-release,$(1))$(_D) $(DIVIDE) [$(_C)$(@)$(_D)] $(_C)$(2)"
endef
override define $(HEADERS)-dir =
	$(TABLE_M2) "$(_C)$(MARKER) Directory" "$(_E)$(call $(HEADERS)-release,$(1))$(if $(2),$(_D) $(DIVIDE) $(_M)$(2))"
endef
override define $(HEADERS)-file =
	$(TABLE_M2) "$(_H)$(MARKER) Creating" "$(_N)$(call $(HEADERS)-release,$(1))$(if $(2),$(_D) $(DIVIDE) $(_M)$(2))"
endef
override define $(HEADERS)-skip =
	$(TABLE_M2) "$(_H)$(MARKER) Skipping" "$(_N)$(call $(HEADERS)-release,$(1))$(if $(2),$(_D) $(DIVIDE) $(_C)$(2))"
endef
override define $(HEADERS)-rm =
	$(TABLE_M2) "$(_N)$(MARKER) Removing" "$(_N)$(call $(HEADERS)-release,$(1))$(if $(2),$(_D) $(DIVIDE) $(_M)$(2))"
endef

########################################
# {{{2 $(WHOWHAT) ----------------------

.PHONY: $(WHOWHAT)-%
$(WHOWHAT)-%:
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-dir,$(CURDIR))
else
	@$(call $(HEADERS),1,$(*))
endif

########################################
# {{{2 $(SETTING) ----------------------

.PHONY: $(SETTING)-%
$(SETTING)-%:
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-file,$(CURDIR),$(BASE).$(EXTENSION))
else
	@$(call $(HEADERS)-run,1,$(*))
	@$(PRINT) '$(_C)$(MARKER) $(PANDOC) $(PANDOC_OPTIONS)'
endif

################################################################################
# {{{1 Global Targets ----------------------------------------------------------
################################################################################

########################################
# {{{2 .DEFAULT ------------------------

.DEFAULT_GOAL := $(HELPOUT)
ifneq ($(COMPOSER_SRC),$(COMPOSER))
.DEFAULT_GOAL := $(DOITALL)
endif

.DEFAULT:
	@$(call $(HEADERS))
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) ERROR"
	@$(ENDOLINE)
	@$(PRINT) "  * $(_N)Target '$(_C)$(@)$(_N)' is not defined"
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) DETAILS"
	@$(ENDOLINE)
	@$(PRINT) "  * This may be the result of a missing input file"
	@$(PRINT) "  * New targets can be defined in '$(_C)$(COMPOSER_SETTINGS)$(_D)'"
	@$(PRINT) "  * Use '$(_M)$(TARGETS)$(_D)' to get a list of available targets"
	@$(PRINT) "  * See '$(_M)$(HELPOUT)$(_D)' or '$(_M)$(HELPALL)$(_D)' for more information"
	@$(LINERULE)
	@exit 1

########################################
# {{{2 $(MAKE_DB) ----------------------

.PHONY: $(MAKE_DB)
$(MAKE_DB):
	@$(RUNMAKE) \
		--silent \
		--question \
		--print-data-base \
		--no-builtin-rules \
		--no-builtin-variables \
	|| $(TRUE)

########################################
# {{{2 $(LISTING) ----------------------

.PHONY: $(LISTING)
$(LISTING):
	@$(RUNMAKE) --silent $(MAKE_DB) \
		| $(SED) -n -e "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" \
		| $(SED) -n -e "/^$(COMPOSER_REGEX_PREFIX)?$(COMPOSER_REGEX)[:]+/p" \
		| $(SORT)

########################################
# {{{2 $(NOTHING) ----------------------


#> grep -E "[$][(]NOTHING[)][-]" Makefile
#> update: $(CLEANER)-$(TARGETS)
override NOTHING_IGNORES := \
	$(INSTALL)-$(SUBDIRS) \
	$(CLEANER)-$(SUBDIRS) \
	$(DOITALL)-$(TARGETS) \
	$(DOITALL)-$(SUBDIRS) \

#>	COMPOSER_STAMP \
#>	COMPOSER_EXT \
#>	$(CLEANER)-$(TARGETS) \
#>	$(HEADERS) \
#>	$(NOTHING)-$(INSTALL)-$(SUBDIRS) \
#>	$(NOTHING)-$(CLEANER)-$(SUBDIRS) \
#>	$(NOTHING)-$(DOITALL)-$(TARGETS) \
#>	$(NOTHING)-$(DOITALL)-$(SUBDIRS) \
#>	$(SUBDIRS) \
#>	$(MAKEFILE) \

$(eval override COMPOSER_NOTHING ?=)
.PHONY: $(NOTHING)-%
$(NOTHING)-%:
	@$(RUNMAKE) --silent COMPOSER_NOTHING="$(*)" $(NOTHING)

.PHONY: $(NOTHING)
$(NOTHING):
ifeq ($(COMPOSER_DEBUGIT),)
	@$(if $(filter $(COMPOSER_NOTHING),$(NOTHING_IGNORES)),\
		$(ECHO) "",\
		$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_NOTHING)) \
	)
else
	@$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_NOTHING))
endif

################################################################################
# {{{1 Debug Targets -----------------------------------------------------------
################################################################################

########################################
# {{{2 $(DEBUGIT) ----------------------

#> update: PHONY.*$(DEBUGIT)
#	$(CONFIGS)
#	$(TARGETS)

#> update: PHONY.*$(DOITALL)$
$(eval override COMPOSER_DOITALL_$(DEBUGIT) ?=)
.PHONY: $(DEBUGIT)-file
$(DEBUGIT)-file: export override DEBUGIT_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(DEBUGIT))
$(DEBUGIT)-file: export override COMPOSER_DOITALL_$(DEBUGIT) := file
$(DEBUGIT)-file: .set_title-$(DEBUGIT)-file
$(DEBUGIT)-file: $(HEADERS)-$(DEBUGIT)
$(DEBUGIT)-file: $(DEBUGIT)-$(HEADERS)
$(DEBUGIT)-file:
	@$(ENDOLINE)
	@$(PRINT) "$(_M)$(MARKER) Printing to file $(DIVIDE) This may take a few minutes"
	@$(ENDOLINE)
	@$(ECHO) "# $(VIM_OPTIONS)\n" >$(DEBUGIT_FILE)
	@$(RUNMAKE) \
		COMPOSER_DOITALL_$(DEBUGIT)="$(COMPOSER_DOITALL_$(DEBUGIT))" \
		COMPOSER_DOITALL_$(TESTING)="$(DEBUGIT)" \
		COMPOSER_DOCOLOR= \
		COMPOSER_DEBUGIT="$(COMPOSER_DEBUGIT)" \
		$(DEBUGIT) 2>&1 \
		| $(TEE) $(DEBUGIT_FILE) \
		| $(SED) "s|^.*$$||g" \
		| $(TR) '\n' '.'
	@$(TAIL) -n10 $(DEBUGIT_FILE)
	@$(LS) $(DEBUGIT_FILE)

#> update: $(DEBUGIT): targets list
.PHONY: $(DEBUGIT)
ifneq ($(MAKECMDGOALS),$(filter-out $(DEBUGIT),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(DEBUGIT): export override COMPOSER_DOITALL_$(CHECKIT) := $(DOITALL)
$(DEBUGIT): export override COMPOSER_DOITALL_$(CONFIGS) := $(DOITALL)
$(DEBUGIT): .set_title-$(DEBUGIT)
$(DEBUGIT): $(HEADERS)-$(DEBUGIT)
$(DEBUGIT): $(DEBUGIT)-$(HEADERS)
$(DEBUGIT): $(DEBUGIT)-CHECKIT
$(DEBUGIT): $(DEBUGIT)-CONFIGS
$(DEBUGIT): $(DEBUGIT)-TARGETS
$(DEBUGIT): $(DEBUGIT)-COMPOSER_DEBUGIT
ifneq ($(COMPOSER_DOITALL_$(DEBUGIT)),)
ifneq ($(COMPOSER_DOITALL_$(DEBUGIT)),$(TESTING))
$(DEBUGIT): $(DEBUGIT)-TESTING
endif
endif
$(DEBUGIT): $(DEBUGIT)-MAKEFILE_LIST
$(DEBUGIT): $(DEBUGIT)-COMPOSER_INCLUDES
$(DEBUGIT): $(DEBUGIT)-LISTING
$(DEBUGIT): $(DEBUGIT)-MAKE_DB
$(DEBUGIT): $(DEBUGIT)-COMPOSER_DIR
$(DEBUGIT): $(DEBUGIT)-CURDIR
$(DEBUGIT): $(HELPALL)-FOOTER
$(DEBUGIT):
	@$(ECHO) ""

.PHONY: $(DEBUGIT)-$(HEADERS)
$(DEBUGIT)-$(HEADERS):
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) DEBUGIT"
	@$(ENDOLINE)
	@$(PRINT) "  * $(_N)This is the output of the '$(_C)$(DEBUGIT)$(_N)' target"
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) DETAILS"
	@$(ENDOLINE)
	@$(PRINT) "  * It runs several targets and diagnostic commands"
	@$(PRINT) "  * All information needed for troubleshooting is included"
	@$(PRINT) "  * Use '$(_C)COMPOSER_DEBUGIT$(_D)' to test a list of targets $(_E)(they may be run)$(_D)"
	@$(PRINT) "  * Use '$(_C)$(DEBUGIT)-file$(_D)' to create a text file with the results"
	@$(LINERULE)

.PHONY: $(DEBUGIT)-%
$(DEBUGIT)-%:
	@$(foreach FILE,$($(*)),\
		$(call TITLE_LN,1,$(MARKER)[ $(*) $(DIVIDE) $(FILE) ]$(MARKER) $(VIM_FOLDING)); \
		if [ "$(*)" = "COMPOSER_DEBUGIT" ]; then \
			$(RUNMAKE) --just-print COMPOSER_DOCOLOR= COMPOSER_DEBUGIT="!" $(FILE) 2>&1; \
		elif [ -d "$(FILE)" ]; then \
			$(LS) --recursive $(FILE); \
		elif [ -f "$(FILE)" ]; then \
			$(CAT) $(FILE); \
		else \
			$(RUNMAKE) COMPOSER_DEBUGIT= $(FILE) 2>&1; \
		fi; \
	)

########################################
# {{{2 $(TESTING) ----------------------

#> update: PHONY.*$(DOITALL)$
$(eval override COMPOSER_DOITALL_$(TESTING) ?=)
.PHONY: $(TESTING)-file
$(TESTING)-file: export override TESTING_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(TESTING))
$(TESTING)-file: export override COMPOSER_DOITALL_$(TESTING) := file
$(TESTING)-file: .set_title-$(TESTING)
$(TESTING)-file: $(HEADERS)-$(TESTING)
$(TESTING)-file: $(TESTING)-$(HEADERS)
$(TESTING)-file:
	@$(ENDOLINE)
	@$(PRINT) "$(_M)$(MARKER) Printing to file $(DIVIDE) This may take a few minutes"
	@$(ENDOLINE)
	@$(ECHO) "# $(VIM_OPTIONS)\n" >$(TESTING_FILE)
	@$(RUNMAKE) \
		COMPOSER_DOITALL_$(DEBUGIT)="$(TESTING)" \
		COMPOSER_DOITALL_$(TESTING)="$(COMPOSER_DOITALL_$(TESTING))" \
		COMPOSER_DOCOLOR= \
		$(TESTING) 2>&1 \
		| $(TEE) $(TESTING_FILE) \
		| $(SED) "s|^.*$$||g" \
		| $(TR) '\n' '.'
	@$(TAIL) -n10 $(TESTING_FILE)
	@$(LS) $(TESTING_FILE)

#> update: $(TESTING): targets list
.PHONY: $(TESTING)
ifneq ($(MAKECMDGOALS),$(filter-out $(TESTING),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(TESTING): export override COMPOSER_DOITALL_$(CHECKIT) := $(DOITALL)
$(TESTING): export override COMPOSER_DOITALL_$(CONFIGS) := $(DOITALL)
$(TESTING): .set_title-$(TESTING)
$(TESTING): $(HEADERS)-$(TESTING)
$(TESTING): $(TESTING)-$(HEADERS)
$(TESTING): $(TESTING)-$(HEADERS)-CHECKIT
$(TESTING): $(TESTING)-$(HEADERS)-CONFIGS
$(TESTING): $(TESTING)-Think
$(TESTING): $(TESTING)-$(DISTRIB)
#>ifneq ($(COMPOSER_DOITALL_$(TESTING)),)
#>ifneq ($(COMPOSER_DOITALL_$(TESTING)),$(DEBUGIT))
#>$(TESTING): $(TESTING)-$(DEBUGIT)
#>endif
#>endif
#>$(TESTING): $(TESTING)-speed
$(TESTING): $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING): $(TESTING)-$(INSTALL)
$(TESTING): $(TESTING)-$(CLEANER)-$(DOITALL)
$(TESTING): $(TESTING)-COMPOSER_INCLUDE
$(TESTING): $(TESTING)-COMPOSER_DEPENDS
$(TESTING): $(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT)
$(TESTING): $(TESTING)-CSS
$(TESTING): $(TESTING)-other
$(TESTING): $(TESTING)-$(EXAMPLE)
$(TESTING): $(HELPALL)-FOOTER
$(TESTING):
	@$(ECHO) ""

.PHONY: $(TESTING)-$(HEADERS)
$(TESTING)-$(HEADERS):
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) TESTING"
	@$(ENDOLINE)
	@$(PRINT) "  * $(_N)This is the output of the '$(_C)$(TESTING)$(_N)' target"
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) DETAILS"
	@$(ENDOLINE)
	@$(PRINT) "  * It runs test cases for all supported functionality $(_E)(some are interactive)$(_D)"
	@$(PRINT) "  * All cases are run in the '$(_C)$(subst $(COMPOSER_DIR)/,,$(TESTING_DIR))$(_D)' directory"
	@$(PRINT) "  * It has a dedicated '$(_C)$(TESTING_COMPOSER_DIR)$(_D)', and '$(_C)$(notdir $(MAKE))$(_D)' can be run anywhere in the tree"
	@$(PRINT) "  * Use '$(_C)$(TESTING)-file$(_D)' to create a text file with the results"
	@$(LINERULE)

.PHONY: $(TESTING)-$(HEADERS)-%
$(TESTING)-$(HEADERS)-%:
	@$(call TITLE_LN,1,$(MARKER)[ $($(subst $(TESTING)-$(HEADERS)-,,$(@))) ]$(MARKER) $(VIM_FOLDING))
	@$(RUNMAKE) $($(subst $(TESTING)-$(HEADERS)-,,$(@))) 2>&1

########################################
# {{{3 $(TESTING)-functions ------------

override TESTING_LOGFILE		:= .$(COMPOSER_BASENAME).$(TESTING).log
override TESTING_COMPOSER_DIR		:= .$(COMPOSER_BASENAME)
override TESTING_COMPOSER_MAKEFILE	:= $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE)
override TESTING_ENV			:= $(ENV) \
	COMPOSER_DOCOLOR="$(COMPOSER_DOCOLOR)" \
	COMPOSER_DEBUGIT="$(COMPOSER_DEBUGIT)" \

override $(TESTING)-pwd			= $(abspath $(TESTING_DIR)/$(subst -init,,$(subst -done,,$(if $(1),$(1),$(@)))))
override $(TESTING)-log			= $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(TESTING_LOGFILE)
override $(TESTING)-make		= $(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(MAKEFILE),-$(INSTALL),$(2),1)
#>override $(TESTING)-run		= $(TESTING_ENV) $(RUNMAKE) --directory $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))
override $(TESTING)-run			= $(TESTING_ENV) $(REALMAKE) --directory $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))

override define $(TESTING)-$(HEADERS) =
	$(call TITLE_LN,1,$(MARKER)[ $(subst $(TESTING)-,,$(@)) ]$(MARKER) $(VIM_FOLDING));
	$(ECHO) "$(_M)$(MARKER) PURPOSE:$(_D) $(strip $(1))$(_D)\n"; \
	$(ECHO) "$(_M)$(MARKER) RESULTS:$(_D) $(strip $(2))$(_D)\n"; \
	if [ -z "$(1)" ]; then exit 1; fi; \
	if [ -z "$(2)" ]; then exit 1; fi; \
	$(ENDOLINE); \
	if [ "$(@)" != "$(TESTING)-Think" ]; then \
		$(DIFF) $(COMPOSER) $(TESTING_COMPOSER_MAKEFILE); \
	fi
endef

override define $(TESTING)-mark =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) MARK [$(@)]:"; \
	$(MKDIR) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@))); \
	$(call $(TESTING)-run,$(if $(1),$(1),$(@))) --makefile $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE) $(CREATOR); \
	if [ -n "$(2)" ]; then \
		$(MV) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(EXAMPLE_ONE)$(COMPOSER_EXT_DEFAULT) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(EXAMPLE_ONE); \
		$(MV) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(EXAMPLE_TWO)$(COMPOSER_EXT_DEFAULT) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(EXAMPLE_TWO); \
	fi
endef

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
override define $(TESTING)-load =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) LOAD [$(@)]:"; \
	$(MKDIR) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@))); \
	if [ "$(COMPOSER_ROOT)" != "$(TESTING_DIR)" ] && [ "$(abspath $(dir $(COMPOSER_ROOT)))" != "$(TESTING_DIR)" ]; then \
		$(RSYNC) \
			--filter="-_/$(TESTING_LOGFILE)" \
			--filter="-_/$(PANDOC_LNX_BIN)" \
			--filter="-_/$(PANDOC_WIN_BIN)" \
			--filter="-_/$(PANDOC_MAC_BIN)" \
			$(PANDOC_DIR)/ $(call $(TESTING)-pwd,$(if $(1),$(1),$(@))); \
		$(call $(TESTING)-make,$(if $(1),$(1),$(@))); \
	fi; \
	$(ECHO) "override COMPOSER_IGNORES := $(TESTING)\n" >$(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run,$(if $(1),$(1),$(@))) MAKEJOBS="0" $(INSTALL)-$(DOFORCE)
endef

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
override define $(TESTING)-init =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) INIT [$(@)]:"; \
	$(MKDIR) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@))); \
	$(ECHO) "" >$(call $(TESTING)-log,$(if $(1),$(1),$(@))); \
	if [ "$(@)" = "$(TESTING)-Think" ]; then \
		$(MKDIR) $(abspath $(dir $(TESTING_COMPOSER_MAKEFILE))); \
		$(CP) $(COMPOSER) $(TESTING_COMPOSER_MAKEFILE); \
	else \
		$(call $(TESTING)-make,$(if $(1),$(1),$(@))); \
	fi; \
	$(RUNMAKE) $(@)-init 2>&1 | $(TEE) $(call $(TESTING)-log,$(if $(1),$(1),$(@))); \
	if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
endef

override define $(TESTING)-done =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) DONE [$(@)]"; \
	$(RUNMAKE) $(@)-done 2>&1
endef

override define $(TESTING)-find =
	$(SED) -n "/$(1)/p" $(call $(TESTING)-log,$(if $(2),$(2),$(@))); \
	if [ $(if $(3),-n,-z) "$(shell $(SED) -n "/$(1)/p" $(call $(TESTING)-log,$(if $(2),$(2),$(@))) | $(SED) "s|[$$]|.|g")" ]; then \
		$(call $(TESTING)-fail); \
		if [ -z "$(COMPOSER_DOITALL_$(TESTING))" ]; then \
			exit 1; \
		fi; \
	fi
endef

override define $(TESTING)-count =
	$(SED) -n "/$(2)/p" $(call $(TESTING)-log,$(if $(3),$(3),$(@))); \
	$(SED) -n "/$(2)/p" $(call $(TESTING)-log,$(if $(3),$(3),$(@))) | $(WC); \
	if [ "$(shell $(SED) -n "/$(2)/p" $(call $(TESTING)-log,$(if $(3),$(3),$(@))) | $(WC))" != "$(1)" ]; then \
		$(call $(TESTING)-fail); \
		if [ -z "$(COMPOSER_DOITALL_$(TESTING))" ]; then \
			exit 1; \
		fi; \
	fi
endef

override define $(TESTING)-fail =
	$(ENDOLINE); \
	$(call $(HEADERS)-note,$(call $(TESTING)-pwd,$(if $(1),$(1),$(@))),FAILED!); \
	$(ENDOLINE)
endef

override define $(TESTING)-hold =
	$(ENDOLINE); \
	if [ -z "$(COMPOSER_DOITALL_$(TESTING))" ]; then \
		$(PRINT) "$(_H)$(MARKER) ENTER TO CONTINUE"; \
		read $(TESTING); \
	else \
		$(PRINT) "$(_H)$(MARKER) PAUSE TO REVIEW"; \
	fi
endef

########################################
# {{{3 $(TESTING)-Think ----------------

.PHONY: $(TESTING)-Think
$(TESTING)-Think:
	@$(call $(TESTING)-$(HEADERS),\
		Install the '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' directory ,\
		\n\t * Top-level '$(_C)$(notdir $(TESTING_DIR))$(_D)' directory ready for direct use \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

#> update: $(TESTING)-Think
.PHONY: $(TESTING)-Think-init
$(TESTING)-Think-init:
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS),,,1)
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS),,,1)
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,/)/$(MAKEFILE),-$(INSTALL),$(TESTING_COMPOSER_MAKEFILE),1)
	@$(ENDOLINE)
	@$(LS) \
		$(COMPOSER) \
		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)) \
		$(call $(TESTING)-pwd,/) \
		$(call $(TESTING)-pwd)
#>	@$(CAT) \
#>		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS) \
#>		$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS)
	@$(CAT) \
		$(call $(TESTING)-pwd,/)/$(MAKEFILE)

.PHONY: $(TESTING)-Think-done
$(TESTING)-Think-done:
	$(call $(TESTING)-find,override COMPOSER_TEACHER := .+$(TESTING_COMPOSER_DIR)\/$(MAKEFILE))

########################################
# {{{3 $(TESTING)-$(COMPOSER_BASENAME) -

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING)-$(COMPOSER_BASENAME): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Basic '$(_C)$(COMPOSER_BASENAME)$(_D)' functionality ,\
		\n\t * Command-line '$(_C)LIST$(_D)' shortcut \
		\n\t * Empty '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' \
		\n\t * Use of '$(_C)$(NOTHING)$(_D)' targets \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-init
$(TESTING)-$(COMPOSER_BASENAME)-init:
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_TARGETS := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_SUBDIRS := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CONFIGS)
	@$(RM) $(call $(TESTING)-pwd)/$(EXAMPLE_OUT).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) $(EXAMPLE_OUT).$(EXTN_DEFAULT) LIST="$(EXAMPLE_ONE)$(COMPOSER_EXT_DEFAULT) $(EXAMPLE_TWO)$(COMPOSER_EXT_DEFAULT)"
#WORKING turn these into variables with the readme/license work... also fix *-count checks below
	@$(SED) -n "/Composer CMS License/p" $(call $(TESTING)-pwd)/$(EXAMPLE_OUT).$(EXTN_DEFAULT)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-done
$(TESTING)-$(COMPOSER_BASENAME)-done:
	$(call $(TESTING)-count,1,NOTICE.+$(NOTHING).+$(NOTHING)-$(DOITALL)-$(TARGETS))
	$(call $(TESTING)-count,1,NOTICE.+$(NOTHING).+$(NOTHING)-$(DOITALL)-$(SUBDIRS))
	$(call $(TESTING)-find,COMPOSER_TARGETS.+$(EXAMPLE_ONE).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,COMPOSER_SUBDIRS.+artifacts)
	$(call $(TESTING)-find,Creating.+$(EXAMPLE_OUT).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,1,Composer CMS License)

########################################
# {{{3 $(TESTING)-$(DISTRIB) -----------

#> update: PHONY.*$(DISTRIB)
#	$(UPGRADE)
#	$(CREATOR)

.PHONY: $(TESTING)-$(DISTRIB)
$(TESTING)-$(DISTRIB): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Install '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' using '$(_C)$(DISTRIB)$(_D)' ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(DISTRIB)-init
$(TESTING)-$(DISTRIB)-init:
	@$(call $(TESTING)-run,$(TESTING_COMPOSER_DIR)) $(DISTRIB)

.PHONY: $(TESTING)-$(DISTRIB)-done
$(TESTING)-$(DISTRIB)-done:
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(DEBUGIT) -----------

#> update: PHONY.*$(DEBUGIT)
#	$(CONFIGS)
#	$(TARGETS)

.PHONY: $(TESTING)-$(DEBUGIT)
$(TESTING)-$(DEBUGIT): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)$(DEBUGIT)$(_D)' using '$(_C)COMPOSER_DEBUGIT$(_D)' ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(DEBUGIT)-init
$(TESTING)-$(DEBUGIT)-init: export override COMPOSER_DEBUGIT := $(CONFIGS) $(TARGETS)
$(TESTING)-$(DEBUGIT)-init:
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="$(COMPOSER_DEBUGIT)" $(DEBUGIT)

.PHONY: $(TESTING)-$(DEBUGIT)-done
$(TESTING)-$(DEBUGIT)-done:
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-speed ----------------

.PHONY: $(TESTING)-speed
$(TESTING)-speed: $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Performance test of the speed processing a large directory ,\
		\n\t * $(_H)For general information and fun only$(_D) \
	)
	@$(call $(TESTING)-speed-init)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

override define $(TESTING)-speed-init =
	for TLD in {0..9}; do \
		$(call $(TESTING)-speed-init-load,$(call $(TESTING)-pwd)/tld$${TLD}); \
		for SUB in {0..9}; do \
			$(call $(TESTING)-speed-init-load,$(call $(TESTING)-pwd)/tld$${TLD}/sub$${SUB}); \
		done; \
	done
endef

override define $(TESTING)-speed-init-load =
	$(MKDIR) $(1); \
	$(RSYNC) \
		--filter="-_/$(notdir $(PANDOC_LNX_BIN))" \
		--filter="-_/$(notdir $(PANDOC_WIN_BIN))" \
		--filter="-_/$(notdir $(PANDOC_MAC_BIN))" \
		--filter="-_/sub**" \
		$(PANDOC_DIR)/ \
		$(1)
endef

.PHONY: $(TESTING)-speed-init
$(TESTING)-speed-init: export override COMPOSER_DEBUGIT := $(CONFIGS) $(TARGETS)
$(TESTING)-speed-init:
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(INSTALL)-$(DOFORCE)
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-speed-done
$(TESTING)-speed-done:
	@$(TABLE_M2) "$(_H)$(MARKER)Directories"	"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type d | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER)Files"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+$(subst .,[.],$(COMPOSER_EXT_DEFAULT))$$/p" | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER)Output"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+$(EXTN_DEFAULT)$$/p" | $(WC))"
	@$(call $(TESTING)-find,[0-9]s$$)		| $(SED) "s|^(real)|\n\1|g"
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(INSTALL) -----------

.PHONY: $(TESTING)-$(INSTALL)
$(TESTING)-$(INSTALL): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Test '$(_C)$(INSTALL)$(_D)' in an existing directory ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
		\n\t * Verify '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' configuration \
		\n\t * Examine output to validate '$(_C)$(NOTHING)$(_D)' markers \
		\n\t * Ensure threading is working properly \
		\n\t * Test runs: \
		\n\t\t * Forced install $(_E)(from '$(TESTING)-load')$(_D) \
		\n\t\t * Linear build all \
		\n\t\t * Linear clean all \
		\n\t\t * Parallel safe install \
		\n\t\t * Parallel build all \
	)
	@$(call $(TESTING)-load)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(INSTALL)-init
$(TESTING)-$(INSTALL)-init:
	@$(call $(TESTING)-run) MAKEJOBS= $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run) MAKEJOBS= $(CLEANER)-$(DOITALL)
	@$(call $(TESTING)-run) MAKEJOBS="0" $(INSTALL)-$(DOITALL)
	@$(call $(TESTING)-run) MAKEJOBS="0" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-$(INSTALL)-done
$(TESTING)-$(INSTALL)-done:
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(CLEANER)-$(DOITALL)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)
$(TESTING)-$(CLEANER)-$(DOITALL): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Test '$(_C)$(CLEANER)-$(DOITALL)$(_D)' and '$(_C)$(DOITALL)-$(DOITALL)$(_D)' behavior ,\
		\n\t * Creation and deletion of files \
		\n\t * Missing '$(_C)$(MAKEFILE)$(_D)' detection \
		\n\t * Proper execution of '$(_C)*-$(CLEANER)$(_D)' targets \
	)
	@$(call $(TESTING)-load)
	@$(RM) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)-init
$(TESTING)-$(CLEANER)-$(DOITALL)-init:
	@$(RM) $(call $(TESTING)-pwd)/data/*/$(MAKEFILE)
	@$(ECHO) '$(foreach FILE,9 8 7 6 5 4 3 2 1,\n.PHONY: $(TESTING)-$(FILE)-$(CLEANER)\n$(TESTING)-$(FILE)-$(CLEANER):\n\t@$$(PRINT) "$$(@): $$(CURDIR)"\n)' \
		>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(CLEANER) $(TESTING)-2-$(CLEANER)" $(DOITALL)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run) $(CLEANER)-$(DOITALL)

#> update: $(CLEANER)-$(TARGETS)
.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)-done
$(TESTING)-$(CLEANER)-$(DOITALL)-done:
	$(call $(TESTING)-find,Creating.+changelog.html)
	$(call $(TESTING)-find,Creating.+getting-started.html)
	$(call $(TESTING)-find,Removing.+changelog.html)
	$(call $(TESTING)-find,Removing.+getting-started.html)
	$(call $(TESTING)-find,Removing.+\/$(notdir $(call $(TESTING)-pwd))[^\/].+$(COMPOSER_STAMP_DEFAULT))
	$(call $(TESTING)-find,Removing.+\/$(notdir $(call $(TESTING)-pwd))\/doc[^\/].+$(COMPOSER_STAMP_DEFAULT))
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+$(MAKEFILE))
	$(call $(TESTING)-count,1,$(CLEANER)-$(TARGETS))
	$(call $(TESTING)-count,3,$(TESTING)-1-$(CLEANER))

########################################
# {{{3 $(TESTING)-COMPOSER_INCLUDE -----

.PHONY: $(TESTING)-COMPOSER_INCLUDE
$(TESTING)-COMPOSER_INCLUDE: $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_INCLUDE$(_D)' behavior ,\
		\n\t * Use '$(_C)COMPOSER_DEPENDS$(_D)' in '$(_C)$(COMPOSER_SETTINGS)$(_D)' \
		\n\t * One run each with '$(_C)COMPOSER_INCLUDE$(_D)' enabled and disabled: \
		\n\t\t * All files in place \
		\n\t\t * Remove from '$(_C)$(notdir $(call $(TESTING)-pwd))$(_D)' \
		\n\t\t * Remove from '$(_C)$(notdir $(call $(TESTING)-pwd,/))$(_D)' \
		\n\t\t * Remove from '$(_C)$(notdir $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)))$(_D)' \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-COMPOSER_INCLUDE-init
$(TESTING)-COMPOSER_INCLUDE-init:
	@$(call $(TESTING)-COMPOSER_INCLUDE-init,1)
	@$(call $(TESTING)-COMPOSER_INCLUDE-done)
	@$(call $(TESTING)-COMPOSER_INCLUDE-init)
	@$(call $(TESTING)-COMPOSER_INCLUDE-done)

override define $(TESTING)-COMPOSER_INCLUDE-init =
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))\n" >$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS); \
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd,/)\n" >$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd)\n" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(ECHO) "override COMPOSER_INCLUDE := $(1)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_INCLUDES/p"; \
	$(CAT) \
		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS) \
		$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS) \
		$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
endef

override define $(TESTING)-COMPOSER_INCLUDE-done =
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"
endef

.PHONY: $(TESTING)-COMPOSER_INCLUDE-done
$(TESTING)-COMPOSER_INCLUDE-done:
	$(call $(TESTING)-count,2,\|.+$(subst /,.,$(call $(TESTING)-pwd)))
	$(call $(TESTING)-count,1,\|.+$(subst /,.,$(call $(TESTING)-pwd,/))$(if $(COMPOSER_DOCOLOR),[^/],[ $$]))
	$(call $(TESTING)-count,3,\|.+$(subst /,.,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))))

########################################
# {{{3 $(TESTING)-COMPOSER_DEPENDS -----

.PHONY: $(TESTING)-COMPOSER_DEPENDS
$(TESTING)-COMPOSER_DEPENDS: $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_DEPENDS$(_D)' behavior ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
		\n\t * Disable '$(_C)MAKEJOBS$(_D)' threading \
		\n\t * Reverse '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' processing \
		\n\t * Manual '$(_C)$(DOITALL)-$(DOITALL)$(_D)' dependencies $(_E)('templates' before 'docx')$(_D) \
		\n\t * Manual '$(_C)$(DOITALL)$(_D)' dependencies $(_E)('$(EXAMPLE_TWO).$(EXTN_DEFAULT)' before '$(EXAMPLE_ONE).$(EXTN_DEFAULT)')$(_D) \
		\n\t * Verify '$(_C)COMPOSER_IGNORES$(_D)' \
	)
	@$(call $(TESTING)-load)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-init
$(TESTING)-COMPOSER_DEPENDS-init:
	@$(RM) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/data/*$(COMPOSER_EXT_DEFAULT)
	@$(RM) $(call $(TESTING)-pwd)/data/*.$(EXTN_DEFAULT)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n" >$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data MAKEJOBS="0" $(CONFIGS) | $(SED) -n "/MAKEJOBS/p"
	@$(ECHO) "docx: templates\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) MAKEJOBS="0" $(DOITALL)-$(DOITALL)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(EXAMPLE_ONE)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(EXAMPLE_TWO)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(EXAMPLE_OUT)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "$(EXAMPLE_TWO).$(EXTN_DEFAULT): $(EXAMPLE_ONE).$(EXTN_DEFAULT)\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_IGNORES := $(EXAMPLE_OUT).$(EXTN_DEFAULT) artifacts\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(CONFIGS) | $(SED) -n "/COMPOSER_TARGETS/p"
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(CONFIGS) | $(SED) -n "/COMPOSER_SUBDIRS/p"
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data MAKEJOBS="0" $(DOITALL)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-done
$(TESTING)-COMPOSER_DEPENDS-done:
	$(call $(TESTING)-count,1,MAKEJOBS.+1)
	$(call $(TESTING)-find,Directory.+$(notdir $(call $(TESTING)-pwd))\/data)
	$(call $(TESTING)-find,Creating.+$(notdir $(call $(TESTING)-pwd))\/data)
	$(call $(TESTING)-find,Creating.+$(EXAMPLE_OUT).$(EXTN_DEFAULT),,1)
	$(call $(TESTING)-find,COMPOSER_TARGETS.+$(EXAMPLE_OUT).$(EXTN_DEFAULT),,1)
	$(call $(TESTING)-find,COMPOSER_SUBDIRS.+artifacts,,1)
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(COMPOSER_STAMP)$(COMPOSER_EXT)

.PHONY: $(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT)
$(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Proper operation of '$(_C)COMPOSER_STAMP$(_D)' and '$(_C)COMPOSER_EXT$(_D)' ,\
		\n\t * Build '$(_C)$(DOITALL)$(_D)' with empty '$(_C)COMPOSER_EXT$(_D)' \
		\n\t * Do '$(_C)$(CLEANER)$(_D)' with both empty \
		\n\t * Do '$(_C)$(PRINTER)$(_D)' with empty '$(_C)COMPOSER_STAMP$(_D)' \
		\n\t * Do '$(_C)$(PRINTER)$(_D)' with empty '$(_C)COMPOSER_EXT$(_D)' \
		\n\t * Detect updated files with '$(_C)$(PRINTER)$(_D)' \
	)
	@$(call $(TESTING)-mark,,1)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT)-init
$(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT)-init:
	@$(call $(TESTING)-run) COMPOSER_EXT= $(DOITALL)
	@$(call $(TESTING)-run) COMPOSER_STAMP= COMPOSER_EXT= $(CLEANER)
	@$(call $(TESTING)-run) COMPOSER_STAMP= $(PRINTER)
	@$(call $(TESTING)-run) COMPOSER_EXT= $(PRINTER)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(subst $(TESTING)-.,,$(notdir $(call $(TESTING)-pwd)))
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_STAMP_DEFAULT)
	@$(call $(TESTING)-run) $(PRINTER)

.PHONY: $(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT)-done
$(TESTING)-$(COMPOSER_STAMP_DEFAULT)$(COMPOSER_EXT_DEFAULT)-done:
	$(call $(TESTING)-find,Creating.+$(EXAMPLE_ONE).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Removing.+$(EXAMPLE_ONE).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+COMPOSER_STAMP)
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+COMPOSER_EXT)
	$(call $(TESTING)-find, $(subst $(TESTING)-.,,$(notdir $(call $(TESTING)-pwd))))
	$(call $(TESTING)-find, $(COMPOSER_STAMP_DEFAULT))

########################################
# {{{3 $(TESTING)-CSS ------------------

.PHONY: $(TESTING)-CSS
$(TESTING)-CSS: $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Use '$(_C)CSS$(_D)' to verify each method of setting variables ,\
		\n\t * Default value \
		\n\t * Default for '$(_C)$(TYPE_PRES)$(_D)' \
		\n\t * From the environment \
		\n\t * From '$(_C)$(_CSS_ALT)$(_D)' alias \
		\n\t * A '$(_C)$(COMPOSER_CSS)$(_D)' file $(_E)(precedence over environment)$(_D) \
		\n\t * A '$(_C)$(COMPOSER_SETTINGS)$(_D)' file $(_E)(precedence over everything)$(_D) \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-CSS-init
$(TESTING)-CSS-init:
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_CSS) >/dev/null
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" CSS= $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" TYPE="$(TYPE_PRES)" CSS= $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" CSS="$(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(REVEALJS_CSS))" $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" CSS="$(_CSS_ALT)" $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_CSS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" CSS="$(_CSS_ALT)" $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(ECHO) "override CSS := $(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(REVEALJS_CSS))\n" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" CSS="$(_CSS_ALT)" $(SETTING)-$(notdir $(call $(TESTING)-pwd))

.PHONY: $(TESTING)-CSS-done
$(TESTING)-CSS-done:
	$(call $(TESTING)-count,2,$(notdir $(MDVIEWER_CSS)))
	$(call $(TESTING)-count,8,$(notdir $(REVEALJS_CSS)))
	$(call $(TESTING)-count,8,$(notdir $(REVEALJS_CSS)))
	$(call $(TESTING)-count,2,$(notdir $(MDVIEWER_CSS_ALT)))
	$(call $(TESTING)-count,2,\/$(COMPOSER_CSS))
	$(call $(TESTING)-count,8,$(notdir $(REVEALJS_CSS)))

########################################
# {{{3 $(TESTING)-other ----------------

.PHONY: $(TESTING)-other
$(TESTING)-other: $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Miscellaneous test cases ,\
		\n\t * Use '$(_C)$(DO_BOOK)s$(_D)' special \
		\n\t\t * Verify '$(_C)$(TYPE_LPDF)$(_D)' format $(_E)(TeX Live)$(_D) \
		\n\t * Pandoc '$(_C)TYPE$(_D)' pass-through \
		\n\t * Git '$(_C)$(CONVICT)$(_D)' target \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-other-init
$(TESTING)-other-init:
	#> book
	@$(ECHO) "$(DO_BOOK)-$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF):" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(EXAMPLE_ONE)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(EXAMPLE_TWO)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(EXAMPLE_OUT)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "# $(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)" >$(call $(TESTING)-pwd)/$(EXAMPLE_OUT)$(COMPOSER_EXT_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(DOITALL)
#WORKING turn these into variables with the readme/license work... also fix *-count checks below
ifeq ($(OS_TYPE),Linux)
	@$(LESS_BIN) $(call $(TESTING)-pwd)/$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF) \
		| $(SED) -n \
			-e "/User Guide/p" \
			-e "/Composer CMS License/p" \
			-e "/$(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)/p"
endif
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CLEANER)
	#> pandoc
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" TYPE="json" $(COMPOSER_PANDOC)
	@$(CAT) $(call $(TESTING)-pwd)/$(EXAMPLE_ONE).json | $(SED) "s|[]][}][,].+$$||g"
	#> git
	@$(call $(TESTING)-make,,$(TESTING_COMPOSER_MAKEFILE))
	@$(RM) --recursive $(call $(TESTING)-pwd)/.git
	@cd $(call $(TESTING)-pwd) \
		&& $(GIT) init \
		&& $(GIT) config --local user.name "$(COMPOSER_FULLNAME)" \
		&& $(GIT) config --local user.email "$(COMPOSER_BASENAME)@example.com"
	@$(call $(TESTING)-run) $(CONVICT)-$(DOITALL)
	@cd $(call $(TESTING)-pwd) \
		&& $(GIT) log
	@$(call $(TESTING)-make)

.PHONY: $(TESTING)-other-done
$(TESTING)-other-done:
	#> pandoc
	@$(PRINT) "$(_C)Pandoc: $(PANDOC_BIN) = $(PANDOC)"
	@$(PRINT) "$(_C)YQ: $(YQ_BIN) = $(YQ)"
	@if	[ "$(PANDOC)" != "$(PANDOC_BIN)" ] || \
		[ "$(YQ)" != "$(YQ_BIN)" ]; \
	then \
		$(call $(TESTING)-fail); \
		if [ -z "$(COMPOSER_DOITALL_$(TESTING))" ]; then \
			exit 1; \
		fi; \
	fi
	#> book
ifeq ($(OS_TYPE),Linux)
	$(call $(TESTING)-count,1,User Guide)
	$(call $(TESTING)-count,1,Composer CMS License)
	$(call $(TESTING)-count,1,$(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT))
endif
	$(call $(TESTING)-find,Removing.+$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF))
	#> pandoc
	$(call $(TESTING)-find,pandoc-api-version)
	#> git
	$(call $(TESTING)-find,$(COMPOSER_FULLNAME).+$(COMPOSER_BASENAME)@example.com)

########################################
# {{{3 $(TESTING)-$(EXAMPLE) -----------

.PHONY: $(TESTING)-$(EXAMPLE)
$(TESTING)-$(EXAMPLE): $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Template '$(_C)$(TESTING)$(_D)' test case ,\
		\n\t * Empty '$(_C)COMPOSER_DOCOLOR$(_D)' \
		\n\t * Manual '$(_C)$(NOTHING)$(_D)' markers \
	)
#>	@$(call $(TESTING)-load)
#>	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(EXAMPLE)-init
$(TESTING)-$(EXAMPLE)-init:
	@$(call $(TESTING)-run) COMPOSER_DOCOLOR= $(NOTHING)
	@$(call $(TESTING)-run) COMPOSER_DOCOLOR= COMPOSER_NOTHING="$(notdir $(call $(TESTING)-pwd))" $(NOTHING)

.PHONY: $(TESTING)-$(EXAMPLE)-done
$(TESTING)-$(EXAMPLE)-done:
	$(call $(TESTING)-find,NOTICE.+$(NOTHING)[]].?$$)
	$(call $(TESTING)-find,NOTICE.+$(TESTING)-$(EXAMPLE)$$)
#>	@$(call $(TESTING)-hold)

########################################
# {{{2 $(CHECKIT) ----------------------

override PANDOC_CMT_DISPLAY := $(PANDOC_CMT)
override YQ_CMT_DISPLAY := $(YQ_CMT)
ifneq ($(PANDOC_CMT),$(PANDOC_VER))
override PANDOC_CMT_DISPLAY := $(PANDOC_CMT)$(_D) ($(_N)$(PANDOC_VER)$(_D))
endif
ifneq ($(subst v,,$(YQ_CMT)),$(YQ_VER))
override YQ_CMT_DISPLAY := $(YQ_CMT)$(_D) ($(_N)$(YQ_VER)$(_D))
endif

#> update: PHONY.*$(DOITALL)$
$(eval override COMPOSER_DOITALL_$(CHECKIT) ?=)
.PHONY: $(CHECKIT)-%
$(CHECKIT)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CHECKIT)="$(*)" $(CHECKIT)

#> update: Tooling Versions
.PHONY: $(CHECKIT)
$(CHECKIT): .set_title-$(CHECKIT)
	@$(call $(HEADERS))
	@$(TABLE_M3) "$(_H)Repository"			"$(_H)Commit"				"$(_H)License"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_E)Pandoc"			"$(_E)$(PANDOC_CMT_DISPLAY)"		"$(_N)$(PANDOC_LIC)"
	@$(TABLE_M3) "$(_E)YQ"				"$(_E)$(YQ_CMT_DISPLAY)"		"$(_N)$(YQ_LIC)"
	@$(TABLE_M3) "$(_E)Markdown Viewer"		"$(_E)$(MDVIEWER_CMT)"			"$(_N)$(MDVIEWER_LIC)"
	@$(TABLE_M3) "$(_E)Reveal.js"			"$(_E)$(REVEALJS_CMT)"			"$(_N)$(REVEALJS_LIC)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Project"			"$(_H)$(COMPOSER_BASENAME) Version"	"$(_H)System Version"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_C)GNU Bash"			"$(_M)$(BASH_VER)"			"$(_D)$(shell $(BASH) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GNU Coreutils"		"$(_M)$(COREUTILS_VER)"			"$(_D)$(shell $(LS) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GNU Findutils"		"$(_M)$(FINDUTILS_VER)"			"$(_D)$(shell $(FIND) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GNU Sed"			"$(_M)$(SED_VER)"			"$(_D)$(shell $(SED) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_C)GNU Make"			"$(_M)$(MAKE_VER)"			"$(_D)$(shell $(REALMAKE) --version		2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)Pandoc"			"$(_M)$(PANDOC_VER)"			"$(_D)$(shell $(PANDOC) --version		2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)YQ"			"$(_M)$(YQ_VER)"			"$(_D)$(shell $(YQ) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)TeX Live ($(TYPE_LPDF))"	"$(_M)$(TEX_PDF_VER)"			"$(_D)$(shell $(TEX_PDF) --version		2>&1 | $(HEAD) -n1)"
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(TABLE_M3) "$(_H)Target: $(UPGRADE)"		"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "- $(_E)Git SCM"			"$(_E)$(GIT_VER)"			"$(_N)$(shell $(GIT) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Wget"			"$(_E)$(WGET_VER)"			"$(_N)$(shell $(WGET) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Tar"			"$(_E)$(TAR_VER)"			"$(_N)$(shell $(TAR) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Gzip"			"$(_E)$(GZIP_VER)"			"$(_N)$(shell $(GZIP_BIN) --version		2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)7z"			"$(_E)$(7Z_VER)"			"$(_N)$(shell $(7Z)				2>&1 | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_M3) "$(_H)Target: $(TESTING)"		"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "- $(_E)GNU Diffutils"		"$(_E)$(DIFFUTILS_VER)"			"$(_N)$(shell $(DIFF) --version			2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Rsync"			"$(_E)$(RSYNC_VER)"			"$(_N)$(shell $(RSYNC) --version		2>&1 | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Less"			"$(_E)$(LESS_VER)"			"$(_N)$(shell $(LESS_BIN) --version		2>&1 | $(HEAD) -n1)"
endif
	@$(ENDOLINE)
	@$(TABLE_M2) "$(_H)Project"			"$(_H)Location & Options"
	@$(TABLE_M2) ":---"				":---"
	@$(TABLE_M2) "$(_C)GNU Bash"			"$(_D)$(BASH)"
	@$(TABLE_M2) "- $(_C)GNU Coreutils"		"$(_D)$(LS)"
	@$(TABLE_M2) "- $(_C)GNU Findutils"		"$(_D)$(FIND)"
	@$(TABLE_M2) "- $(_C)GNU Sed"			"$(_D)$(SED)"
	@$(TABLE_M2) "$(_C)GNU Make"			"$(_D)$(REALMAKE)"
	@$(TABLE_M2) "- $(_C)Pandoc"			"$(if $(filter $(PANDOC),$(PANDOC_BIN)),$(_M),$(_E))$(PANDOC)"
	@$(TABLE_M2) "- $(_C)YQ"			"$(if $(filter $(YQ),$(YQ_BIN)),$(_M),$(_E))$(YQ)"
	@$(TABLE_M2) "- $(_C)TeX Live ($(TYPE_LPDF))"	"$(_D)$(TEX_PDF)"
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(TABLE_M2) "$(_H)Target: $(UPGRADE)"		"$(_H)$(MARKER)"
	@$(TABLE_M2) "- $(_E)Git SCM"			"$(_N)$(GIT)"
	@$(TABLE_M2) "- $(_E)Wget"			"$(_N)$(WGET)"
	@$(TABLE_M2) "- $(_E)GNU Tar"			"$(_N)$(TAR)"
	@$(TABLE_M2) "- $(_E)GNU Gzip"			"$(_N)$(GZIP_BIN)"
	@$(TABLE_M2) "- $(_E)7z"			"$(_N)$(7Z)"
	@$(TABLE_M2) "$(_H)Target: $(TESTING)"		"$(_H)$(MARKER)"
	@$(TABLE_M2) "- $(_E)GNU Diffutils"		"$(_N)$(DIFF)"
	@$(TABLE_M2) "- $(_E)Rsync"			"$(_N)$(RSYNC)"
	@$(TABLE_M2) "- $(_E)Less"			"$(_N)$(LESS_BIN)"
endif
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(ENDOLINE)
	@$(PRINT) "$(_E)*$(OS_UNAME)*"
endif

########################################
# {{{2 $(CONFIGS) ----------------------

#> update: COMPOSER_OPTIONS

#> update: PHONY.*$(DOITALL)
$(eval override COMPOSER_DOITALL_$(CONFIGS) ?=)
.PHONY: $(CONFIGS)-%
$(CONFIGS)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CONFIGS)="$(*)" $(CONFIGS)

.PHONY: $(CONFIGS)
$(CONFIGS): .set_title-$(CONFIGS)
	@$(call $(HEADERS))
	@$(TABLE_M2) "$(_H)Variable"		"$(_H)Value"
	@$(TABLE_M2) ":---"			":---"
	@$(foreach FILE,$(COMPOSER_OPTIONS),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$($(FILE))$(if $(filter $(FILE),$(COMPOSER_EXPORTED)),$(if $($(FILE)), )$(_E)$(MARKER)$(_D))"; \
	)
ifneq ($(COMPOSER_DOITALL_$(CONFIGS)),)
	@$(LINERULE)
	@$(subst $(NULL) -,,$(ENV)) | $(SORT)
endif

########################################
# {{{2 $(TARGETS) ----------------------

.PHONY: $(TARGETS)
$(TARGETS): .set_title-$(TARGETS)
	@$(call $(HEADERS))
	@$(LINERULE)
	@$(foreach FILE,$(shell $(call $(TARGETS)-list) | $(SED) \
		$(foreach FILE,$(COMPOSER_RESERVED_SPECIAL),\
			-e "/^$(FILE)[s-]/d" \
		)),\
		$(PRINT) "$(_M)$(subst : ,$(_D) $(DIVIDE) $(_C),$(subst $(TOKEN), ,$(FILE)))"; \
	)
	@$(LINERULE)
	@$(foreach SPECIAL,$(COMPOSER_RESERVED_SPECIAL),\
		$(PRINT) "$(_H)$(MARKER) $(SPECIAL)s"; \
		$(foreach FILE,$(shell $(call $(TARGETS)-list) | $(SED) -n "s|^$(SPECIAL)[-]||gp"),\
			$(PRINT) "$(_E)$(subst : ,$(_D) $(DIVIDE) $(_N),$(subst $(TOKEN), ,$(FILE)))"; \
		) \
	)
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) $(CLEANER)"; $(strip $(call $(TARGETS)-list,$(CLEANER)))	| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(DOITALL)"; $(strip $(call $(TARGETS)-list,$(DOITALL)))	| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(TARGETS)"; $(ECHO) "$(COMPOSER_TARGETS)"			| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(SUBDIRS)"; $(ECHO) "$(COMPOSER_SUBDIRS)"			| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(LINERULE)
	@$(RUNMAKE) --silent $(PRINTER)-list

override define $(TARGETS)-list =
	$(RUNMAKE) --silent $(LISTING) | $(SED) \
		-e "/^$(COMPOSER_REGEX_PREFIX)/d" \
		$(if $(COMPOSER_EXT),-e "/^[^:]+$(subst .,[.],$(COMPOSER_EXT))[:]/d")
		$(if $(1),,$(foreach FILE,$(COMPOSER_RESERVED),-e "/^$(FILE)[:-]/d")) \
		$(if $(1),,-e "/^[^:]+[-]$(CLEANER)[:]+.*$$/d") \
		$(if $(1),,-e "/^[^:]+[-]$(DOITALL)[:]+.*$$/d") \
		-e "s|[:]$$||g" \
		-e "s|[[:space:]]+|$(TOKEN)|g" \
		$(if $(1),| $(SED) -n "s|^([^:]+[-]$(1))$$|\1|gp")
endef

################################################################################
# {{{1 Release Targets ---------------------------------------------------------
################################################################################

########################################
# {{{2 $(CONVICT) ----------------------

#WORKING override GIT_OPTS_CONVICT		:= --verbose .$(subst $(COMPOSER_ROOT),,$(CURDIR))
override GIT_OPTS_CONVICT		:= --verbose $(MAKEFILE)

#> update: PHONY.*$(DOITALL)
$(eval override COMPOSER_DOITALL_$(CONVICT) ?=)
.PHONY: $(CONVICT)-%
$(CONVICT)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CONVICT)="$(*)" $(CONVICT)

.PHONY: $(CONVICT)
$(CONVICT): .set_title-$(CONVICT)
	@$(call $(HEADERS))
	$(call GIT_RUN_COMPOSER,add --all $(GIT_OPTS_CONVICT))
	$(call GIT_RUN_COMPOSER,commit \
		$(if $(COMPOSER_DOITALL_$(CONVICT)),,--edit) \
		--message="[$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)]" \
		$(GIT_OPTS_CONVICT) \
	)

########################################
# {{{2 $(DISTRIB) ----------------------

#> update: PHONY.*$(DISTRIB)
#	$(UPGRADE)
#	$(CREATOR)

.PHONY: $(DISTRIB)
$(DISTRIB): .set_title-$(DISTRIB)
	@$(call $(HEADERS))
	@if [ "$(COMPOSER)" != "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(CP) $(COMPOSER) $(CURDIR)/$(MAKEFILE); \
	fi
	@$(CHMOD) $(CURDIR)/$(MAKEFILE)
	@$(RUNMAKE) $(UPGRADE)-$(DOITALL)
	@$(RUNMAKE) $(CREATOR)

########################################
# {{{2 $(UPGRADE) ----------------------

#> update: PHONY.*(UPGRADE)

#> update: PHONY.*$(DOITALL)
$(eval override COMPOSER_DOITALL_$(UPGRADE) ?=)
.PHONY: $(UPGRADE)-%
$(UPGRADE)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(UPGRADE)="$(*)" $(UPGRADE)

.PHONY: $(UPGRADE)
$(UPGRADE): .set_title-$(UPGRADE)
	@$(call $(HEADERS))
	@$(call GIT_REPO,$(PANDOC_DIR),$(PANDOC_SRC),$(PANDOC_CMT))
	@$(call GIT_REPO,$(YQ_DIR),$(YQ_SRC),$(YQ_CMT))
	@$(call GIT_REPO,$(MDVIEWER_DIR),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
	@$(call GIT_REPO,$(REVEALJS_DIR),$(REVEALJS_SRC),$(REVEALJS_CMT))
ifneq ($(COMPOSER_DOITALL_$(UPGRADE)),)
	@$(call WGET_PACKAGE,$(PANDOC_DIR),$(PANDOC_URL),$(PANDOC_LNX_SRC),$(PANDOC_LNX_DST),$(PANDOC_LNX_BIN))
	@$(call WGET_PACKAGE,$(PANDOC_DIR),$(PANDOC_URL),$(PANDOC_WIN_SRC),$(PANDOC_WIN_DST),$(PANDOC_WIN_BIN),1)
	@$(call WGET_PACKAGE,$(PANDOC_DIR),$(PANDOC_URL),$(PANDOC_MAC_SRC),$(PANDOC_MAC_DST),$(PANDOC_MAC_BIN),1)
	@$(call WGET_PACKAGE,$(YQ_DIR),$(YQ_URL),$(YQ_LNX_SRC),$(YQ_LNX_DST),$(YQ_LNX_BIN))
	@$(call WGET_PACKAGE,$(YQ_DIR),$(YQ_URL),$(YQ_WIN_SRC),$(YQ_WIN_DST),$(YQ_WIN_BIN),1)
	@$(call WGET_PACKAGE,$(YQ_DIR),$(YQ_URL),$(YQ_MAC_SRC),$(YQ_MAC_DST),$(YQ_MAC_BIN))
endif
	@$(ENDOLINE)
	@$(LN) $(MDVIEWER_DIR)/manifest.json	$(MDVIEWER_DIR)/manifest.chrome.json
ifneq ($(COMPOSER_DOITALL_$(UPGRADE)),)
	@$(ECHO) "$(_M)"
	@$(LS) --color=never --directory \
		$(PANDOC_BIN) \
		$(YQ_BIN)
endif
	@$(ECHO) "$(_C)"
	@$(LS) --color=never --directory \
		$(PANDOC_DIR)/data/templates \
		$(MDVIEWER_DIR)/manifest.firefox.json \
		$(MDVIEWER_DIR)/manifest.chrome.json \
		$(MDVIEWER_DIR)/manifest.edge.json \
		$(MDVIEWER_CSS) \
		$(MDVIEWER_CSS_ALT) \
		$(REVEALJS_CSS_THEME)
	@$(ECHO) "$(_D)"

################################################################################
# {{{1 Main Targets ------------------------------------------------------------
################################################################################

########################################
# {{{2 $(PUBLISH) ----------------------

.PHONY: $(PUBLISH)
$(PUBLISH): .set_title-$(PUBLISH)
	@$(call $(HEADERS))
	@$(RUNMAKE) $(NOTHING)-$(PUBLISH)-FUTURE

.PHONY: $(PUBLISH)-$(CLEANER)
$(PUBLISH)-$(CLEANER):
	@$(ECHO) ""

########################################
# {{{2 $(INSTALL) ----------------------

#WORKING:NOW test case?
#	$(RM) $(call $(TESTING)-pwd)/$(MAKEFILE)
#	make -f ../Makefile install-force	= Creating.+$(call $(TESTING)-pwd)/$(MAKEFILE)
#	make -f ../Makefile install-all		= $(NOTHING).+$(INSTALL)-$(MAKEFILE)
#	make -f ../Makefile install		= $(NOTHING).+$(INSTALL)-$(MAKEFILE)
#	$(RM) $(call $(TESTING)-pwd)/$(MAKEFILE)
#	make install-force			= $(NOTHING).+$(INSTALL)-$(MAKEFILE)
#	make install-all			= $(NOTHING).+$(INSTALL)-$(MAKEFILE)
#	make install				= $(NOTHING).+$(INSTALL)-$(MAKEFILE)

#> update: $(MAKE) / @+

#> update: PHONY.*$(DOITALL)
$(eval override COMPOSER_DOITALL_$(INSTALL) ?=)
.PHONY: $(INSTALL)-%
$(INSTALL)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(INSTALL)="$(*)" $(INSTALL)

.PHONY: $(INSTALL)
#>$(INSTALL): .set_title-$(INSTALL)
$(INSTALL): $(INSTALL)-$(SUBDIRS)-$(HEADERS)
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_BASENAME)_Directory)
else
	@if	[ "$(COMPOSER_ROOT)" = "$(CURDIR)" ]; \
	then \
		if	[ -f "$(CURDIR)/$(MAKEFILE)" ] && \
			[ "$(COMPOSER_DOITALL_$(INSTALL))" != "$(DOFORCE)" ]; \
		then \
			$(call $(HEADERS)-note,$(CURDIR),Main_$(MAKEFILE)); \
		fi; \
		if	[ "$(COMPOSER_DOITALL_$(INSTALL))" = "$(DOFORCE)" ]; \
		then \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME),-$(INSTALL),$(COMPOSER)); \
			$(MV) $(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME) $(CURDIR)/$(MAKEFILE) >/dev/null; \
		else \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL),$(COMPOSER)); \
		fi; \
	elif	[ "$(MAKELEVEL)" = "0" ] || \
		[ "$(MAKELEVEL)" = "1" ]; \
	then \
		if	[ "$(COMPOSER_DOITALL_$(INSTALL))" = "$(DOFORCE)" ]; \
		then \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME),-$(INSTALL)); \
			$(MV) $(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME) $(CURDIR)/$(MAKEFILE) >/dev/null; \
		else \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL)); \
		fi; \
	fi
ifneq ($(COMPOSER_DOITALL_$(INSTALL)),)
ifneq ($(COMPOSER_SUBDIRS),$(NOTHING))
	@$(foreach FILE,$(COMPOSER_SUBDIRS),\
		$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(FILE)/$(MAKEFILE),-$(INSTALL)); \
	)
	@+$(MAKE) $(MAKE_OPTIONS) $(INSTALL)-$(SUBDIRS)
endif
endif
endif

override define $(INSTALL)-$(MAKEFILE) =
	if	[ "$(COMPOSER_DOITALL_$(@))" != "$(DOFORCE)" ] && \
		[ -z "$(4)" ] && \
		[ -f "$(1)" ]; \
	then \
		$(call $(HEADERS)-skip,$(abspath $(dir $(1))),$(notdir $(1))); \
	else \
		$(call $(HEADERS)-file,$(abspath $(dir $(1))),$(notdir $(1))); \
		$(RUNMAKE) --silent COMPOSER_DOCOLOR= .$(EXAMPLE)$(2) >$(1); \
	fi; \
	if [ -n "$(3)" ]; then \
		$(SED) -i \
			"s|^($(call COMPOSER_INCLUDE_REGEX,COMPOSER_TEACHER)).*$$|\1 $(~)(abspath $(~)(COMPOSER_MY_PATH)/`$(REALPATH) $(abspath $(dir $(1))) $(3)`)|g" \
			$(1); \
	fi
endef

########################################
# {{{2 $(CLEANER) ----------------------

#> update: $(MAKE) / @+

#> update: PHONY.*$(DOITALL)
$(eval override COMPOSER_DOITALL_$(CLEANER) ?=)
.PHONY: $(CLEANER)-%
$(CLEANER)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CLEANER)="$(*)" $(CLEANER)

.PHONY: $(CLEANER)
#>$(CLEANER): .set_title-$(CLEANER)
$(CLEANER): $(CLEANER)-$(SUBDIRS)-$(HEADERS)
ifneq ($(COMPOSER_STAMP),)
ifneq ($(wildcard $(CURDIR)/$(COMPOSER_STAMP)),)
	@$(call $(HEADERS)-rm,$(CURDIR),$(COMPOSER_STAMP))
	@$(RM) $(CURDIR)/$(COMPOSER_STAMP) >/dev/null
endif
endif
	@+$(strip $(call $(TARGETS)-list,$(CLEANER))) \
		| $(XARGS) $(MAKE) $(MAKE_OPTIONS) {}
	@+$(foreach FILE,$(COMPOSER_TARGETS),\
		if	[ "$(FILE)" != "$(NOTHING)" ] && \
			[ -f "$(FILE)" ]; \
		then \
			$(call $(HEADERS)-rm,$(CURDIR),$(FILE)); \
			$(RM) $(CURDIR)/$(FILE) >/dev/null; \
		fi; \
		$(NEWLINE) \
	)
ifneq ($(COMPOSER_DOITALL_$(CLEANER)),)
	@+$(MAKE) $(MAKE_OPTIONS) $(CLEANER)-$(SUBDIRS)
endif

########################################
# {{{2 $(DOITALL) ----------------------

#> update: $(MAKE) / @+

#> update: PHONY.*$(DOITALL)
$(eval override COMPOSER_DOITALL_$(DOITALL) ?=)
.PHONY: $(DOITALL)-%
$(DOITALL)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(DOITALL)="$(*)" $(DOITALL)

.PHONY: $(DOITALL)
#>$(DOITALL): .set_title-$(DOITALL)
$(DOITALL): $(DOITALL)-$(SUBDIRS)-$(HEADERS)
$(DOITALL): $(DOITALL)-specials
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifneq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(DOITALL)-$(SUBDIRS)
endif
endif
ifeq ($(COMPOSER_TARGETS),)
$(DOITALL): $(NOTHING)-$(DOITALL)-$(TARGETS)
else ifeq ($(COMPOSER_TARGETS),$(NOTHING))
$(DOITALL): $(NOTHING)-$(NOTHING)-$(DOITALL)-$(TARGETS)
else
$(DOITALL): $(COMPOSER_TARGETS)
endif
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(DOITALL)-$(SUBDIRS)
endif
endif

.PHONY: $(DOITALL)-specials
$(DOITALL)-specials:
	@+$(strip $(call $(TARGETS)-list,$(DOITALL))) \
		| $(XARGS) $(MAKE) $(MAKE_OPTIONS) {}

########################################
# {{{2 $(SUBDIRS) ----------------------

.PHONY: $(SUBDIRS)
$(SUBDIRS): $(NOTHING)-$(SUBDIRS)
	@$(ECHO) ""

override define $(SUBDIRS)-$(EXAMPLE) =
.PHONY: $(1)-$(SUBDIRS)-$(HEADERS)
ifeq ($(MAKELEVEL),0)
$(1)-$(SUBDIRS)-$(HEADERS): .set_title-$(1)
$(1)-$(SUBDIRS)-$(HEADERS): $(HEADERS)-$(1)
endif
ifeq ($(MAKELEVEL),1)
$(1)-$(SUBDIRS)-$(HEADERS): .set_title-$(1)
$(1)-$(SUBDIRS)-$(HEADERS): $(HEADERS)-$(1)
endif
$(1)-$(SUBDIRS)-$(HEADERS):
ifneq ($(COMPOSER_DOITALL_$(1)),)
#>$(1)-$(SUBDIRS)-$(HEADERS): $(WHOWHAT)-$(1)
	@$(RUNMAKE) $(WHOWHAT)-$(1)
endif
	@$(ECHO) ""

.PHONY: $(1)-$(SUBDIRS)
ifeq ($(COMPOSER_SUBDIRS),)
$(1)-$(SUBDIRS): $(NOTHING)-$(1)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
$(1)-$(SUBDIRS): $(NOTHING)-$(NOTHING)-$(1)-$(SUBDIRS)
else
$(1)-$(SUBDIRS): $(addprefix $(1)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS))
endif
$(1)-$(SUBDIRS):
	@$(ECHO) ""

.PHONY: $(addprefix $(1)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS))
$(addprefix $(1)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS)):
	@$$(eval override $$(@) := $(CURDIR)/$$(subst $(1)-$(SUBDIRS)-,,$$(@)))
	@+$$(if $$(wildcard $$($$(@))/$(MAKEFILE)),\
		$$(MAKE) $$(MAKE_OPTIONS) --directory $$($$(@)) $(1),\
		$$(RUNMAKE) --directory $$($$(@)) $(NOTHING)-$(MAKEFILE) \
	)
endef

$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(INSTALL)))
$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(CLEANER)))
$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(DOITALL)))

########################################
# {{{2 $(PRINTER) ----------------------

.PHONY: $(PRINTER)
$(PRINTER): .set_title-$(PRINTER)
$(PRINTER): $(HEADERS)-$(PRINTER)
ifeq ($(COMPOSER_STAMP),)
$(PRINTER): $(NOTHING)-COMPOSER_STAMP
endif
$(PRINTER): $(PRINTER)-list
$(PRINTER):
	@$(ECHO) ""

.PHONY: $(PRINTER)-list
$(PRINTER)-list: $(COMPOSER_STAMP)
	@$(ECHO) ""

$(COMPOSER_STAMP): $(if \
		$(COMPOSER_EXT),\
		$(wildcard $(filter %$(COMPOSER_EXT),$(COMPOSER_CONTENTS_FILES))),\
		$(NOTHING)-COMPOSER_EXT \
		)
	@$(LS) --directory $(COMPOSER_STAMP) $(?) \
		|| $(TRUE)

################################################################################
# {{{1 Pandoc Targets ----------------------------------------------------------
################################################################################

########################################
# {{{2 $(COMPOSER_CREATE) $(COMPOSER_PANDOC)

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(SETTING)-$(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(LIST)
	@$(ECHO) "$(_N)"
	@$(MKDIR) $(COMPOSER_TMP)
	@$(PANDOC) $(PANDOC_OPTIONS)
	@$(ECHO) "$(_D)"
ifneq ($(COMPOSER_STAMP),)
	@$(ECHO) "$(DATESTAMP)" >$(CURDIR)/$(COMPOSER_STAMP)
endif

.PHONY: $(COMPOSER_CREATE)
$(COMPOSER_CREATE): $(BASE).$(EXTENSION)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := create)$(call $(HEADERS)-note,$(BASE) $(MARKER) $(EXTENSION),$(LIST))
endif
	@$(ECHO) ""

$(BASE).$(EXTENSION): $(LIST)
	@$(RUNMAKE) $(COMPOSER_PANDOC) TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(LIST)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := base)$(call $(HEADERS)-note,$(BASE) $(MARKER) $(TYPE),$(LIST))
endif

########################################
# {{{2 $(COMPOSER_EXT) -----------------

#> update: TYPE_TARGETS

override define TYPE_TARGETS =
%.$(2): %$(COMPOSER_EXT)
	@$(RUNMAKE) $(COMPOSER_CREATE) TYPE="$(1)" BASE="$$(*)" LIST="$$(^)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := $(INPUT))$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif

%.$(2): %
	@$(RUNMAKE) $(COMPOSER_CREATE) TYPE="$(1)" BASE="$$(*)" LIST="$$(^)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := wildcard)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif

%.$(2): $(LIST)
	@$(RUNMAKE) $(COMPOSER_CREATE) TYPE="$(1)" BASE="$$(*)" LIST="$$(^)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := list)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif
endef

$(eval $(call TYPE_TARGETS,$(TYPE_HTML),$(EXTN_HTML)))
$(eval $(call TYPE_TARGETS,$(TYPE_LPDF),$(EXTN_LPDF)))
$(eval $(call TYPE_TARGETS,$(TYPE_EPUB),$(EXTN_EPUB)))
$(eval $(call TYPE_TARGETS,$(TYPE_PRES),$(EXTN_PRES)))
$(eval $(call TYPE_TARGETS,$(TYPE_DOCX),$(EXTN_DOCX)))
$(eval $(call TYPE_TARGETS,$(TYPE_PPTX),$(EXTN_PPTX)))
$(eval $(call TYPE_TARGETS,$(TYPE_TEXT),$(EXTN_TEXT)))
$(eval $(call TYPE_TARGETS,$(TYPE_LINT),$(EXTN_LINT)))

########################################
# {{{2 SPECIALS ------------------------

#WORKING:NOW
#	create test cases for COMPOSER_EXT and SPECIALS... catch all 4 possibilities
#	cd .Composer-v*/test-Composer ; while :; do inotifywait ../../Makefile ; rm *.md *.html ; for file in {1..9} ; do echo ${FILE} >book-${file}.md ; echo "book-MANUAL.html: README.md LICENSE.md" >.composer.mk ; done ; make docs books targets ; ll ; done

#> update: TYPE_TARGETS

override define TYPE_DO_BOOK =
$(DO_BOOK)-%.$(2):
	@$(RUNMAKE) $(COMPOSER_CREATE) TYPE="$(1)" BASE="$$(*)" LIST="$$(^)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := do_book)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif
endef

$(eval $(call TYPE_DO_BOOK,$(TYPE_HTML),$(EXTN_HTML)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_LPDF),$(EXTN_LPDF)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_EPUB),$(EXTN_EPUB)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_PRES),$(EXTN_PRES)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_DOCX),$(EXTN_DOCX)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_PPTX),$(EXTN_PPTX)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_TEXT),$(EXTN_TEXT)))
$(eval $(call TYPE_DO_BOOK,$(TYPE_LINT),$(EXTN_LINT)))

########################################

#> update: TYPE_TARGETS

override define TYPE_DO_POST =
$(DO_POST)-%.$(2):
	@$(RUNMAKE) $(NOTHING)-$(DO_POST)-FUTURE
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := do_post)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif
endef

$(eval $(call TYPE_DO_POST,$(TYPE_HTML),$(EXTN_HTML)))
$(eval $(call TYPE_DO_POST,$(TYPE_LPDF),$(EXTN_LPDF)))
$(eval $(call TYPE_DO_POST,$(TYPE_EPUB),$(EXTN_EPUB)))
$(eval $(call TYPE_DO_POST,$(TYPE_PRES),$(EXTN_PRES)))
$(eval $(call TYPE_DO_POST,$(TYPE_DOCX),$(EXTN_DOCX)))
$(eval $(call TYPE_DO_POST,$(TYPE_PPTX),$(EXTN_PPTX)))
$(eval $(call TYPE_DO_POST,$(TYPE_TEXT),$(EXTN_TEXT)))
$(eval $(call TYPE_DO_POST,$(TYPE_LINT),$(EXTN_LINT)))

################################################################################
# }}}1
################################################################################
# End Of File
################################################################################
