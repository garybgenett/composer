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
#		revealjs = artifacts/logo.img for logo
#		document this?  $(RUNMAKE) c_type="json" $(OUT_README).json
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
#				threads: ~20-30
#				Directories 18041
#				Files 81510
#				Output 82610
#				install 15m8.018s
#				all 140m43.641s
#			J=6
#				threads: 4478
#				Directories 18041
#				Files 81510
#				Output 82610
#				install 1m20.155s
#				all 17m46.724s
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
#	symlink (e.g.../) in dependencies...?  if so, document!
#	convert all output to markdown
#		replace license and readme with help/license output
#		ensure all output fits within 80 characters
#		do a mouse-select of all text, to ensure proper color handling
#		the above should be reviewed during testing... maybe output some notes in $(TESTING)...? == release checklist
#	dynamic import of targets
#		add some sort of composer_readme variable?
#		$(RUNMAKE) COMPOSER_DOCOLOR= $(CONFIGS) | $(SED) -n "/^[#]/d"
#		$(RUNMAKE) COMPOSER_DOCOLOR= $(CHECKIT) | $(SED) -n "/^[#]/d"
#WORKING
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
override COMPOSER_TECHNAME		:= $(COMPOSER_BASENAME) CMS
override COMPOSER_FULLNAME		:= $(COMPOSER_TECHNAME) $(COMPOSER_VERSION)
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

override OUT_README			:= README
override OUT_LICENSE			:= LICENSE
override OUT_MANUAL			:= $(COMPOSER_FILENAME).Manual

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
override HELPOUT			:= help
$(info #> $(COMPOSER_FULLNAME))
$(info #>	Because this is the main directory, some features are disabled)
$(info #>	Please set up as '.$(COMPOSER_BASENAME)', or use '-f' (see '$(notdir $(MAKE)) $(HELPOUT)'))
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
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> SOURCE			[$(CURDIR)/$(COMPOSER_SETTINGS)]))
#>include $(CURDIR)/$(COMPOSER_SETTINGS)
$(foreach FILE,\
	$(shell \
		$(SED) -n "/^$(call COMPOSER_INCLUDE_REGEX).*$$/p" $(CURDIR)/$(COMPOSER_SETTINGS) \
		| $(SED) -e "s|[[:space:]]+|$(TOKEN)|g" -e "s|$$| |g" \
	),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> OVERRIDE			[$(subst $(TOKEN), ,$(FILE))])) \
	$(eval $(subst $(TOKEN), ,$(FILE))) \
)
endif
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDE		[$(COMPOSER_INCLUDE)]))

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

$(if $(COMPOSER_DEBUGIT_ALL),$(info #> MAKEFILE_LIST		[$(MAKEFILE_LIST)]))
$(foreach FILE,$(abspath $(dir $(COMPOSER_INCLUDES_LIST))),\
	$(eval override COMPOSER_INCLUDES := $(FILE) $(COMPOSER_INCLUDES)); \
)
override COMPOSER_INCLUDES_LIST		:= $(strip $(COMPOSER_INCLUDES))
override COMPOSER_INCLUDES		:=
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES_LIST	[$(COMPOSER_INCLUDES_LIST)]))

$(foreach FILE,$(addsuffix /$(COMPOSER_SETTINGS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD			[$(FILE)])); \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE			[$(FILE)])); \
		$(eval override MAKEFILE_LIST := $(filter-out $(FILE),$(MAKEFILE_LIST))); \
		$(eval override COMPOSER_INCLUDES := $(COMPOSER_INCLUDES) $(FILE)); \
		$(eval include $(FILE)); \
	) \
)

########################################

#> update: includes duplicates
$(call READ_ALIASES,s,s,c_css)

override c_css_use			:=
ifneq ($(filter override,$(origin c_css)),)
override c_css_use			:= $(c_css)
endif
ifeq ($(c_css_use),)
$(foreach FILE,$(addsuffix /$(COMPOSER_CSS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD_CSS			[$(FILE)])); \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE_CSS			[$(FILE)])); \
		$(eval override c_css_use := $(FILE)); \
	) \
)
endif
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> CSS_USE			[$(c_css_use)]))

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

$(call READ_ALIASES,T,T,c_type)
$(call READ_ALIASES,B,B,c_base)
$(call READ_ALIASES,L,L,c_list)
$(call READ_ALIASES,s,s,c_css)
$(call READ_ALIASES,t,t,c_title)
$(call READ_ALIASES,c,c,c_toc)
$(call READ_ALIASES,l,l,c_level)
$(call READ_ALIASES,f,f,c_font)
$(call READ_ALIASES,m,m,c_margin)
$(call READ_ALIASES,o,o,c_options)

#> update: $(HEADERS)-vars
override c_type				?= $(TYPE_DEFAULT)
override c_base				?= $(OUT_README)
override c_list				?= $(c_base)$(COMPOSER_EXT)
override c_css_use			?= #> update: includes duplicates / COMPOSER_OPTIONS
#>override c_css			?= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override c_css				?=
override c_title			?=
override c_toc				?=
override c_level			?= 2
override c_font				?= 10pt
override c_margin			?= 0.8in
override c_options			?=

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

# https://getbootstrap.com
# https://github.com/twbs/bootstrap
# https://github.com/twbs/bootstrap/blob/main/LICENSE
ifeq ($(filter override,$(origin BOOTSTRAP_CMT)),)
override BOOTSTRAP_CMT			:= v5.1.3
endif
override BOOTSTRAP_LIC			:= MIT
override BOOTSTRAP_SRC			:= https://github.com/twbs/bootstrap.git
override BOOTSTRAP_DIR			:= $(COMPOSER_DIR)/bootstrap

########################################

# https://github.com/simov/markdown-viewer
# https://github.com/simov/markdown-viewer/blob/master/LICENSE
ifeq ($(filter override,$(origin MDVIEWER_CMT)),)
#>override MDVIEWER_CMT			:= 059f3192d4ebf5fa9776478ea221d586480e7fa7
override MDVIEWER_CMT			:= 059f3192d4ebf5fa9776
endif
override MDVIEWER_LIC			:= MIT
override MDVIEWER_SRC			:= https://github.com/simov/markdown-viewer.git
override MDVIEWER_DIR			:= $(COMPOSER_DIR)/markdown-viewer
override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/markdown7.css
#>override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DIR)/themes/solarized-dark.css
#>override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DIR)/themes/solarized-light.css
override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DIR)/themes/markdown9.css

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

override DOMAKE				:= $(notdir $(MAKE))
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
override OUTPUT				:= $(c_type)
override EXTENSION			:= $(c_type)

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

ifeq ($(c_type),$(TYPE_HTML))
override OUTPUT				:= html5
override EXTENSION			:= $(EXTN_HTML)
else ifeq ($(c_type),$(TYPE_LPDF))
override OUTPUT				:= latex
override EXTENSION			:= $(EXTN_LPDF)
else ifeq ($(c_type),$(TYPE_EPUB))
override OUTPUT				:= epub3
override EXTENSION			:= $(EXTN_EPUB)
else ifeq ($(c_type),$(TYPE_PRES))
override OUTPUT				:= $(TYPE_PRES)
override EXTENSION			:= $(EXTN_PRES)
else ifeq ($(c_type),$(TYPE_DOCX))
override OUTPUT				:= $(TYPE_DOCX)
override EXTENSION			:= $(EXTN_DOCX)
else ifeq ($(c_type),$(TYPE_PPTX))
override OUTPUT				:= $(TYPE_PPTX)
override EXTENSION			:= $(EXTN_PPTX)
else ifeq ($(c_type),$(TYPE_TEXT))
override OUTPUT				:= plain
override EXTENSION			:= $(EXTN_TEXT)
else ifeq ($(c_type),$(TYPE_LINT))
override OUTPUT				:= $(TYPE_LINT)
override EXTENSION			:= $(EXTN_LINT)
endif

#> update: COMPOSER_TARGETS.*=
ifneq ($(COMPOSER_RELEASE),)
override COMPOSER_TARGETS		:= $(strip \
	$(OUT_README).$(EXTN_HTML) \
	$(OUT_README).$(EXTN_LPDF) \
	$(OUT_README).$(EXTN_EPUB) \
	$(OUT_README).$(EXTN_PRES) \
	$(OUT_README).$(EXTN_DOCX) \
	$(OUT_README).$(EXTN_PPTX) \
	$(OUT_README).$(EXTN_TEXT) \
	$(OUT_README).$(EXTN_LINT) \
)
endif

########################################
# {{{2 CSS -----------------------------

override CSS_ALT			:= css_alt

ifeq ($(c_css_use),)
ifeq ($(c_css),)
ifeq ($(OUTPUT),$(TYPE_PRES))
override c_css_use			:= $(REVEALJS_CSS)
else
override c_css_use			:= $(MDVIEWER_CSS)
endif
else
ifeq ($(c_css),$(CSS_ALT))
override c_css_use			:= $(MDVIEWER_CSS_ALT)
else
override c_css_use			:= $(abspath $(c_css))
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
	--standalone \
	--self-contained \
	--variable="lang=en-US" \
	--columns="$(COLUMNS)" \
	\
	$(if $(c_site),--include-in-header="$(BOOTSTRAP_DIR)/dist/js/bootstrap.js") \
	$(if $(c_site),--include-in-header="$(BOOTSTRAP_DIR)/dist/css/bootstrap.css") \
	--css="$(c_css_use)" \
	\
	--pdf-engine="$(PANDOC_TEX_PDF)" \
	--pdf-engine-opt="-output-directory=$(COMPOSER_TMP)" \
	--listings \
	\
	--variable="revealjs-url=$(REVEALJS_DIR)" \
	\
	--title-prefix="$(c_title)" \
	--output="$(CURDIR)/$(c_base).$(EXTENSION)" \
	--from="$(INPUT)$(PANDOC_EXTENSIONS)" \
	--to="$(OUTPUT)" \
	\
	$(if $(c_toc),--table-of-contents) \
	$(if $(c_toc),--number-sections) \
	$(if $(c_toc),--toc-depth="$(c_toc)") \
	\
	$(if $(c_level),--section-divs) \
	$(if $(c_level),--top-level-division=chapter) \
	$(if $(c_level),--epub-chapter-level="$(c_level)") \
	$(if $(c_level),--slide-level="$(c_level)") \
	\
	--variable="fontsize=$(c_font)" \
	--variable="geometry=margin=$(c_margin)" \
	\
	$(c_options) \
	$(c_list) \
)

#WORK TODO
#>	--variable="geometry=top=$(c_margin)" \
#>	--variable="geometry=bottom=$(c_margin)" \
#>	--variable="geometry=left=$(c_margin)" \
#>	--variable="geometry=right=$(c_margin)" \

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
	c_type \
	c_css \
	c_title \
	c_toc \
	c_level \
	c_font \
	c_margin \
	c_options \

override COMPOSER_EXPORTED_NOT := \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES \
	c_base \
	c_list \
	c_css_use \

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
		),,$(error #> $(COMPOSER_FULLNAME): COMPOSER_OPTIONS: $(FILE)) \
	) \
)

########################################
# {{{2 Targets -------------------------

#> update: $(DEBUGIT): targets list
#> update: $(TESTING): targets list

#> update: PHONY.*$(DOITALL)
#	$(DEBUGIT)-file
#	$(TESTING)-file
#> update: PHONY.*$(DOITALL)
#	$(CHECKIT)-$(DOITALL)
#	$(CONFIGS)-$(DOITALL)
#	$(CONVICT)-$(DOITALL)
#	$(UPGRADE)-$(DOITALL)
#	$(INSTALL)-$(DOITALL)
#	$(CLEANER)-$(DOITALL)
#	$(DOITALL)-$(DOITALL)
#> update: PHONY.*$(DOFORCE)
#	$(CHECKIT)-$(DOFORCE)
#	$(INSTALL)-$(DOFORCE)

#> update: includes duplicates
override HELPOUT			:= help
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
override DO_PAGE			:= page
override DO_POST			:= post

override COMPOSER_RESERVED_SPECIAL := \
	$(DO_BOOK) \
	$(DO_PAGE) \
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
	$(OUT_README)$(COMPOSER_EXT_DEFAULT) \
	$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
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
# {{{2 $(HELPOUT) ----------------------

.PHONY: $(HELPOUT)-TITLE_%
$(HELPOUT)-TITLE_%:
	@$(call TITLE_LN,0,$(COMPOSER_FULLNAME) $(DIVIDE) $(*))

.PHONY: $(HELPOUT)-USAGE
$(HELPOUT)-USAGE:
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)[-f .../$(MAKEFILE)]$(_D) $(_E)[variables]$(_D) $(_M)<filename>.<extension>"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)[-f .../$(MAKEFILE)]$(_D) $(_E)[variables]$(_D) $(_M)<target>"

.PHONY: $(HELPOUT)-FOOTER
$(HELPOUT)-FOOTER:
	@$(ENDOLINE)
	@$(LINERULE)
	@$(ENDOLINE)
	@$(PRINT) "*$(_H)Happy Making!$(_D)*"

########################################

.PHONY: $(HELPOUT)
ifeq ($(MAKECMDGOALS),)
.NOTPARALLEL:
endif
ifneq ($(MAKECMDGOALS),$(filter-out $(HELPOUT),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
#>$(HELPOUT): \
#>	$(HELPOUT)-TITLE_Usage \
#>	$(HELPOUT)-USAGE \
#>	$(HELPOUT)-VARIABLES_FORMAT_1 \
#>	$(HELPOUT)-TARGETS_MAIN_1 \
#>	$(HELPOUT)-QUICK_START_1 \
#>	$(HELPOUT)-FOOTER
$(HELPOUT): \
	$(HELPOUT)-TITLE_Help \
	$(HELPOUT)-USAGE \
	$(HELPOUT)-VARIABLES_TITLE_1 \
	$(HELPOUT)-VARIABLES_FORMAT_2 \
	$(HELPOUT)-VARIABLES_CONTROL_2 \
	$(HELPOUT)-TARGETS_TITLE_1 \
	$(HELPOUT)-TARGETS_MAIN_2 \
	$(HELPOUT)-TARGETS_ADDITIONAL_2 \
	$(HELPOUT)-TARGETS_INTERNAL_2 \
	$(HELPOUT)-QUICK_START_1 \
	$(HELPOUT)-FOOTER
$(HELPOUT):
	@$(ECHO) ""

########################################
# {{{3 $(HELPOUT)-VARIABLES ------------

.PHONY: $(HELPOUT)-VARIABLES_TITLE_%
$(HELPOUT)-VARIABLES_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Variables,$(HEAD_MAIN))

#> update: TYPE_TARGETS
#> update: READ_ALIASES
.PHONY: $(HELPOUT)-VARIABLES_FORMAT_%
$(HELPOUT)-VARIABLES_FORMAT_%: override FONT_LIST	= $(_C)$(TYPE_HTML)$(_D), $(_C)$(TYPE_LPDF)$(_D)
$(HELPOUT)-VARIABLES_FORMAT_%: override MARGIN_LIST	= $(_C)$(TYPE_LPDF)$(_D)
$(HELPOUT)-VARIABLES_FORMAT_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Formatting Variables); fi
	@$(TABLE_M3) "$(_H)Variable"			"$(_H)Purpose"				"$(_H)Value"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_C)c_type$(_D)    ~ $(_E)T"	"Desired output format"			"$(_M)$(c_type)"
	@$(TABLE_M3) "$(_C)c_base$(_D)    ~ $(_E)B"	"Base of output file"			"$(_M)$(c_base)"
	@$(TABLE_M3) "$(_C)c_list$(_D)    ~ $(_E)L"	"List of input files(s)"		"$(_M)$(c_list)"
	@$(TABLE_M3) "$(_C)c_css$(_D)     ~ $(_E)s"	"Location of CSS file"			"$(if $(c_css),$(_M)$(c_css)$(_D) )$(_N)($(COMPOSER_CSS))"
	@$(TABLE_M3) "$(_C)c_title$(_D)   ~ $(_E)t"	"Document title prefix"			"$(_M)$(c_title)"
	@$(TABLE_M3) "$(_C)c_toc$(_D)     ~ $(_E)c"	"Table of contents depth"		"$(_M)$(c_toc)"
	@$(TABLE_M3) "$(_C)c_level$(_D)   ~ $(_E)l"	"Chapter/slide header level"		"$(_M)$(c_level)"
	@$(TABLE_M3) "$(_C)c_font$(_D)    ~ $(_E)f"	"Font size [$(call FONT_LIST)]"		"$(_M)$(c_font)"
	@$(TABLE_M3) "$(_C)c_margin$(_D)  ~ $(_E)m"	"Margin size [$(call MARGIN_LIST)]"	"$(_M)$(c_margin)"
	@$(TABLE_M3) "$(_C)c_options$(_D) ~ $(_E)o"	"Custom Pandoc options"			"$(_M)$(c_options)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Values: \`$(_C)c_type\`"	"$(_H)Format"				"$(_H)Extension"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_C)$(TYPE_HTML)"		"$(DESC_HTML)"				"$(_N)*$(_D).$(_E)$(EXTN_HTML)"
	@$(TABLE_M3) "$(_C)$(TYPE_LPDF)"		"$(DESC_LPDF)"				"$(_N)*$(_D).$(_E)$(EXTN_LPDF)"
	@$(TABLE_M3) "$(_C)$(TYPE_EPUB)"		"$(DESC_EPUB)"				"$(_N)*$(_D).$(_E)$(EXTN_EPUB)"
	@$(TABLE_M3) "$(_C)$(TYPE_PRES)"		"$(DESC_PRES)"				"$(_N)*$(_D).$(_E)$(EXTN_PRES)"
	@$(TABLE_M3) "$(_C)$(TYPE_DOCX)"		"$(DESC_DOCX)"				"$(_N)*$(_D).$(_E)$(EXTN_DOCX)"
	@$(TABLE_M3) "$(_C)$(TYPE_PPTX)"		"$(DESC_PPTX)"				"$(_N)*$(_D).$(_E)$(EXTN_PPTX)"
	@$(TABLE_M3) "$(_C)$(TYPE_TEXT)"		"$(DESC_TEXT)"				"$(_N)*$(_D).$(_E)$(EXTN_TEXT)"
	@$(TABLE_M3) "$(_C)$(TYPE_LINT)"		"$(DESC_LINT)"				"$(_N)*$(_D).$(_E)$(EXTN_LINT)"
	@$(ENDOLINE)
	@$(PRINT) "  * *Other \`$(_C)c_type$(_D)\` values will be passed directly to Pandoc*"

.PHONY: $(HELPOUT)-VARIABLES_CONTROL_%
$(HELPOUT)-VARIABLES_CONTROL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Control Variables); fi
	@$(TABLE_M3) "$(_H)Variable"		"$(_H)Purpose"					"$(_H)Value"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)MAKEJOBS"		"Parallel processing threads"			"$(if $(MAKEJOBS),$(_M)$(MAKEJOBS)$(_D) )$(_E)(makejobs)"
	@$(TABLE_M3) "$(_C)COMPOSER_DOCOLOR"	"Enable title/color sequences"			"$(if $(COMPOSER_DOCOLOR),$(_M)$(COMPOSER_DOCOLOR)$(_D) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_DEBUGIT"	"Use verbose output"				"$(if $(COMPOSER_DEBUGIT),$(_M)$(COMPOSER_DEBUGIT)$(_D) )$(_E)(debugit)"
	@$(TABLE_M3) "$(_C)COMPOSER_INCLUDE"	"Include all: \`$(_C)$(COMPOSER_SETTINGS)\`"	"$(if $(COMPOSER_INCLUDE),$(_M)$(COMPOSER_INCLUDE)$(_D) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_DEPENDS"	"Sub-directories first: \`$(_C)$(DOITALL)\`"	"$(if $(COMPOSER_DEPENDS),$(_M)$(COMPOSER_DEPENDS)$(_D) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_STAMP"	"Timestamp file"				"$(if $(COMPOSER_STAMP),$(_M)$(COMPOSER_STAMP))"
	@$(TABLE_M3) "$(_C)COMPOSER_EXT"	"Markdown file extension"			"$(if $(COMPOSER_EXT),$(_M)$(COMPOSER_EXT))"
	@$(TABLE_M3) "$(_C)COMPOSER_TARGETS"	"Targets:   \`$(_C)$(DOITALL)$(_D)$(_E)/$(_D)$(_C)$(CLEANER)\`"					"(\`$(_C)$(CONFIGS)$(_D)\` or \`$(_C)$(TARGETS)$(_D)\`)"	#> "$(if $(COMPOSER_TARGETS),$(_M)$(COMPOSER_TARGETS))"
	@$(TABLE_M3) "$(_C)COMPOSER_SUBDIRS"	"Recursion: \`$(_C)$(DOITALL)$(_D)$(_E)/$(_D)$(_C)$(CLEANER)$(_D)$(_E)/$(_D)$(_C)$(INSTALL)\`"	"(\`$(_C)$(CONFIGS)$(_D)\` or \`$(_C)$(TARGETS)$(_D)\`)"	#> "$(if $(COMPOSER_SUBDIRS),$(_M)$(COMPOSER_SUBDIRS))"
	@$(TABLE_M3) "$(_C)COMPOSER_IGNORES"	"Ignore:    \`$(_C)$(DOITALL)$(_D)$(_E)/$(_D)$(_C)$(CLEANER)$(_D)$(_E)/$(_D)$(_C)$(INSTALL)\`"	"(\`$(_C)$(CONFIGS)$(_D)\`)"					#> "$(if $(COMPOSER_IGNORES),$(_M)$(COMPOSER_IGNORES))"
	@$(ENDOLINE)
	@$(PRINT) "  * *$(_C)MAKEJOBS$(_D)         ~ $(_E)c_jobs$(_D)  ~ $(_E)J$(_D)*"
	@$(PRINT) "  * *$(_C)COMPOSER_DOCOLOR$(_D) ~ $(_E)c_color$(_D) ~ $(_E)C$(_D)*"
	@$(PRINT) "  * *$(_C)COMPOSER_DEBUGIT$(_D) ~ $(_E)c_debug$(_D) ~ $(_E)V$(_D)*"
	@$(PRINT) "  * *$(_E)(makejobs)$(_D) = empty value disables / number of threads / 0 is no limit*"
	@$(PRINT) "  * *$(_E)(debugit)$(_D)  = empty value disables / any value enables / ! is full tracing*"
	@$(PRINT) "  * *$(_N)(boolean)$(_D)  = empty value disables / any value enables*"

########################################
# {{{3 $(HELPOUT)-TARGETS --------------

.PHONY: $(HELPOUT)-TARGETS_TITLE_%
$(HELPOUT)-TARGETS_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Targets,$(HEAD_MAIN))

#WORKING:NOW
#WORK	$(CREATOR)
#WORK	[.]$(EXAMPLE)*
#WORK	$(COMPOSER_PANDOC)

.PHONY: $(HELPOUT)-TARGETS_MAIN_%
$(HELPOUT)-TARGETS_MAIN_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Primary Targets); fi
	@$(TABLE_M2) "$(_H)Target"			"$(_H)Purpose"
	@$(TABLE_M2) ":---"				":---"
	@$(TABLE_M2) "$(_C)$(HELPOUT)"			"Basic $(HELPOUT) overview $(_N)(default)"
	@$(TABLE_M2) "$(_C)$(HELPOUT)-$(DOITALL)"	"Complete $(OUT_README) output"
	@$(TABLE_M2) "$(_C)$(EXAMPLE)"			"Print settings template: \`$(_C)$(COMPOSER_SETTINGS)$(_D)\`"
	@$(TABLE_M2) "$(_C)$(COMPOSER_CREATE)"		"Document creation $(_N)(see: \`$(_C)$(HELPOUT)$(_N)\`)"
	@$(TABLE_M2) "$(_C)$(INSTALL)"			"Recursive directory initialization: \`$(_C)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)$(CLEANER)"			"Remove output files: \`$(_C)COMPOSER_TARGETS$(_D)\` $(_E)$(DIVIDE)$(_D) \`$(_N)*$(_C)-$(CLEANER)$(_D)\`"
#WORK not recursive
	@$(TABLE_M2) "$(_C)$(DOITALL)"			"Recursive run of directory tree: \`$(_C)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)$(DOITALL)-$(DOITALL)"	"Recursive run of directory tree: \`$(_C)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)$(PRINTER)"			"List updated files: \`$(_N)*$(_C)$(COMPOSER_EXT)$(_D)\` $(_E)$(MARKER)$(_D) \`$(_C)$(COMPOSER_STAMP)$(_D)\`"

.PHONY: $(HELPOUT)-TARGETS_ADDITIONAL_%
$(HELPOUT)-TARGETS_ADDITIONAL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Additional Targets); fi
	@$(TABLE_M2) "$(_H)Target"			"$(_H)Purpose"
	@$(TABLE_M2) ":---"				":---"
#WORKING
	@$(TABLE_M2) "$(_C)$(DEBUGIT)"			"Runs several key sub-targets and commands, to provide all helpful information in one place"
	@$(TABLE_M2) "$(_C)$(TARGETS)"			"Parse for all potential targets (for verification and/or troubleshooting): \`$(_C)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)$(TESTING)"			"Build example/test directory using all features and test/validate success"
	@$(TABLE_M2) "$(_C)$(UPGRADE)"			"Download/update all 3rd party components (need to do this at least once)"

.PHONY: $(HELPOUT)-TARGETS_INTERNAL_%
$(HELPOUT)-TARGETS_INTERNAL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Internal Targets); fi
	@$(TABLE_M2) "$(_H)Target"			"$(_H)Purpose"
	@$(TABLE_M2) ":---"				":---"

#WORKING:NOW
#	$(COMPOSER_CREATE)
#	$(COMPOSER_PANDOC)
#	\
#	$(HELPOUT)
#	$(CREATOR)
#	$(EXAMPLE)
#	\
#	$(HEADERS)
#	$(WHOWHAT)
#	$(SETTING)
#	\
#	$(MAKE_DB)
#	$(LISTING)
#	$(NOTHING)
#	\
#	$(DEBUGIT)
#	$(TESTING)
#	$(CHECKIT)
#	$(CONFIGS)
#	$(TARGETS)
#	\
#	$(CONVICT)
#	$(DISTRIB)
#	$(UPGRADE)
#	\
#	$(PUBLISH)
#	$(INSTALL)
#	$(CLEANER)
#	$(DOITALL)
#	$(SUBDIRS)
#	$(PRINTER)
#> update: PHONY.*$(DOITALL)
#	$(DEBUGIT)-file
#	$(TESTING)-file
#> update: PHONY.*$(DOITALL)
#	$(CHECKIT)-$(DOITALL)
#	$(CONFIGS)-$(DOITALL)
#	$(CONVICT)-$(DOITALL)
#	$(UPGRADE)-$(DOITALL)
#	$(INSTALL)-$(DOITALL)
#	$(CLEANER)-$(DOITALL)
#	$(DOITALL)-$(DOITALL)
#> update: PHONY.*$(DOFORCE)
#	$(CHECKIT)-$(DOFORCE)
#	$(INSTALL)-$(DOFORCE)

########################################
# {{{3 $(HELPOUT)-QUICK_START ----------

.PHONY: $(HELPOUT)-QUICK_START_%
$(HELPOUT)-QUICK_START_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Command Examples); fi
	@$(PRINT) "Create documents from source $(INPUT) files:"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(c_base).$(EXTENSION)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_MANUAL).$(EXTENSION)$(_D) $(_E)c_list=\"$(OUT_README)$(COMPOSER_EXT) $(OUT_LICENSE)$(COMPOSER_EXT)\""
	@$(ENDOLINE)
	@$(PRINT) "Save a persistent configuration:"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)"'$$EDITOR'"$(_D) $(_M)$(COMPOSER_SETTINGS)"
	@$(PRINT) "$(CODEBLOCK)$(CODEBLOCK)$(_M)$(DO_BOOK)-$(OUT_MANUAL).$(EXTENSION)$(_D): $(_E)$(OUT_README)$(COMPOSER_EXT) $(OUT_LICENSE)$(COMPOSER_EXT)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(CLEANER)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)"
	@$(ENDOLINE)
	@$(PRINT) "Recursively install and build an entire directory tree:"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)cd$(_D) $(_M).../documents"
	@$(PRINT) "$(CODEBLOCK)$(_C)mv$(_D) $(_M)$(call $(HEADERS)-release,$(COMPOSER_DIR)) .$(COMPOSER_BASENAME)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(INSTALL)-$(DOITALL)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)-$(DOITALL)"
	@$(ENDOLINE)
	@$(PRINT) "See \`$(_C)$(HELPOUT)-$(DOITALL)$(_D)\` for full details and additional targets."

########################################
# {{{2 $(HELPOUT)-$(DOITALL) -----------

override define $(HELPOUT)-$(DOITALL)-TITLE =
% $(COMPOSER_TECHNAME): Content Make System
% $(COMPOSER_COMPOSER)
% $(COMPOSER_VERSION) ($(DATEMARK))
endef

.PHONY: $(HELPOUT)-$(DOITALL)-HEADER
$(HELPOUT)-$(DOITALL)-HEADER:
	@$(TABLE_M2) "$(_H)![Composer Icon]"		"$(_H)\"Creating Made Simple.\""
	@$(TABLE_M2) ":---"				":---"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_FULLNAME)]"	"$(_C)[License: GPL]"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_COMPOSER)]"	"$(_C)[composer@garybgenett.net]"

override define $(HELPOUT)-$(DOITALL)-LINKS =
[$(COMPOSER_BASENAME)]: https://github.com/garybgenett/composer
[License: GPL]: https://github.com/garybgenett/composer/blob/master/LICENSE.md
[$(COMPOSER_COMPOSER)]: http://www.garybgenett.net/projects/composer
[composer@garybgenett.net]: mailto:composer@garybgenett.net?subject=$(subst $(NULL) ,%20,$(COMPOSER_TECHNAME))%20Submission&body=Thank%20you%20for%20sending%20a%20message%21

[$(COMPOSER_FULLNAME)]: https://github.com/garybgenett/composer/tree/$(COMPOSER_VERSION)
[Composer Icon]: $(subst $(COMPOSER_DIR)/,,$(COMPOSER_ART))/icon-v1.0.png
[Composer Screenshot]: $(subst $(COMPOSER_DIR)/,,$(COMPOSER_ART))/screenshot-v3.0.png
endef

override define $(HELPOUT)-$(DOITALL)-LINKS_EXT =
[GNU Make]: http://www.gnu.org/software/make
[Markdown]: http://daringfireball.net/projects/markdown

[Pandoc]: http://www.johnmacfarlane.net/pandoc
[YQ]: https://mikefarah.gitbook.io/yq
[Bootstrap]: https://getbootstrap.com
[Markdown Viewer]: https://github.com/Thiht/markdown-viewer
[Reveal.js]: https://revealjs.com
[TeX Live]: https://tug.org/texlive

[GNU]: http://www.gnu.org
[GNU/Linux]: https://gnu.org/gnu/linux-and-gnu.html
[Windows Subsystem for Linux]: https://docs.microsoft.com/en-us/windows/wsl
[MacPorts]: https://www.macports.org
endef

########################################

.PHONY: $(HELPOUT)-$(DOITALL)
$(HELPOUT)-$(DOITALL):
	@$(ECHO) "$(_M)";	$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TITLE)			; $(ECHO) "$(_D)"
	@$(ECHO) "";		$(call TITLE_LN,1,$(COMPOSER_TECHNAME),0)
	@$(RUNMAKE)		$(HELPOUT)-$(DOITALL)-HEADER								; $(ENDOLINE)
	@$(ECHO) "$(_S)";	$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS)			; $(ECHO) "$(_D)"	; $(ENDOLINE)
	@$(ECHO) "$(_S)";	$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS_EXT)		; $(ECHO) "$(_D)"
	@			$(call TITLE_LN,2,Overview,0)
	@			$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-OVERVIEW)
	@			$(call TITLE_LN,2,Quick Start,0)
	@$(PRINT)		"Use \`$(_C)$(DOMAKE) $(HELPOUT)$(_D)\` to get started:"	; $(ENDOLINE)
	@$(RUNMAKE)		$(HELPOUT)-USAGE						; $(ENDOLINE)
	@$(RUNMAKE)		$(HELPOUT)-QUICK_START_0
#WORKING:NOW
	@$(ECHO) "";		$(call TITLE_LN,1,#WORKING:NOW: Details,$(HEAD_MAIN))
	@$(PRINT) "#WORKING:NOW"
	@$(ECHO) "";		$(call TITLE_LN,2,#WORKING:NOW: Goals,0)
	@			$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-GOALS)
	@$(ECHO) "";		$(call TITLE_LN,2,Requirements,0)
	@			$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE)		; $(ENDOLINE)
	@$(RUNMAKE) $(CHECKIT)-$(DOFORCE)							| $(SED) "/^[^#]*[#]/d"
	@$(ECHO) "";		$(call TITLE_LN,2,#WORKING:NOW,0)
	@			$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-WORKING)		; $(ENDOLINE)
#WORKING:NOW
	@$(RUNMAKE)		$(HELPOUT)-VARIABLES_TITLE_1
	@$(RUNMAKE)		$(HELPOUT)-VARIABLES_FORMAT_2
	@$(RUNMAKE)		$(HELPOUT)-VARIABLES_CONTROL_2
	@$(RUNMAKE)		$(HELPOUT)-TARGETS_TITLE_1
	@$(RUNMAKE)		$(HELPOUT)-TARGETS_MAIN_2
	@$(RUNMAKE)		$(HELPOUT)-TARGETS_ADDITIONAL_2
	@$(RUNMAKE)		$(HELPOUT)-TARGETS_INTERNAL_2
#WORKING:NOW
#	@$(RUNMAKE)		.$(EXAMPLE)-$(INSTALL)
#	@$(RUNMAKE)		.$(EXAMPLE)
#WORKING:NOW
	@$(RUNMAKE)		$(HELPOUT)-FOOTER

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-OVERVIEW --

override define $(HELPOUT)-$(DOITALL)-OVERVIEW =
[Composer] is a simple but powerful CMS based on [Pandoc] and [GNU Make].  It is
a document and website build system that processes directories or individual
files in [Markdown] format.

Traditionally, CMS stands for Content Management System.  [Composer] is designed
to be a Content **Make** System.  Written content is vastly easier to manage as
plain text, which can be crafted with simple editors and tracked with revision
control.  However, professional documentation, publications and websites require
formatting that is dynamic and feature-rich.

[Pandoc] is a veritable swiss-army knife of document conversion, and is
a widely-used standard for processing [Markdown] into other formats.  While it
has reasonable defaults, there are a large number of options, and additional
tools are required for some formats and features.  [Composer] consoldiates all
the necessary components, streamlines the options, and prettifies the output
formats, all in one place.  It also serves as a build system, so that large
repositories can be managed as documentation archives or published as
[Bootstrap] websites.

![Composer Icon]
![Composer Screenshot]
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-GOALS -----

override define $(HELPOUT)-$(DOITALL)-GOALS =
The guiding principles of [Composer]:

  * All source files in readable plain text
  * Professional output, suitable for publication
  * Minimal dependencies, and entirely command-line driven
  * Separate content and formatting; writing and publishing are independent
  * Inheritance and dependencies; global, tree, directory and file overrides
  * Fast; both to initiate commands and for processing to complete

Direct support for key document types:

  * HTML (standalone and websites)
  * PDF
  * EPUB
  * Presentations
  * Microsoft Office
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-REQUIRE ---

override define $(HELPOUT)-$(DOITALL)-REQUIRE =
[Composer] has almost no external dependencies.  All needed components are
included directly in the repository, including [Pandoc].  It does require
a minimal command-line environment based on [GNU] tools, which is standard for
all [GNU/Linux] systems.  The [Windows Subsystem for Linux] for Windows and
[MacPorts] for macOS both provide suitable environments.

The one large external requirement is [TeX Live], and it can be installed using
the package managers of each of the above systems.  It is only necessary for
creating PDF files.

Below are the versions of the components in the repository, and the tested
versions of external tools for this iteration of [Composer].  Use
`$(_C)$(DOMAKE) $(CHECKIT)$(_D)` to validate your system.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-WORKING ---

override define $(HELPOUT)-$(DOITALL)-WORKING =
#WORKING:NOW

  * [Markdown Viewer]
    * Simple and elegant CSS for HTML files
  * [Reveal.js]
    * Beautifully slick HTML presentation framework
  * [W3C Slidy2]
    * Essentially the grandfather of HTML presentation systems
endef

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
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_GITIGNORE)					>$(CURDIR)/.gitignore
	@$(RUNMAKE) COMPOSER_DOCOLOR= $(HELPOUT)-$(DOITALL)	| $(SED) "/^[#][>]/d"	>$(CURDIR)/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_LICENSE)					>$(CURDIR)/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
	@$(MKDIR)									$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))
	@$(ECHO) "$(DIST_ICON_v1.0)"				| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/icon-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v1.0)"			| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/screenshot-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v3.0)"			| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/screenshot-v3.0.png
	@$(CP) $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/icon-v1.0.png		$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/logo.img
	@$(MKDIR)									$(abspath $(dir $(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))))
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_REVEALJS_CSS)				>$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))
	@$(LS) \
		$(CURDIR)/.gitignore \
		$(CURDIR)/*$(COMPOSER_EXT_DEFAULT) \
		$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART)) \
		$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))
ifneq ($(COMPOSER_RELEASE),)
	@$(ECHO) "$(DO_BOOK)-$(OUT_MANUAL).$(EXTN_LPDF):"	>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_README)$(COMPOSER_EXT_DEFAULT)"	>>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)"	>>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n"						>>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(RM)							$(CURDIR)/$(COMPOSER_CSS)
	@$(RUNMAKE) COMPOSER_STAMP="$(COMPOSER_STAMP_DEFAULT)"	COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(CLEANER)
#WORKING:NOW
#	@$(RUNMAKE) COMPOSER_STAMP=				COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(DOITALL)
	@$(RUNMAKE) c_toc=6 README.html
#	@$(RUNMAKE) README.revealjs.html
#WORK
	@$(ECHO) "" >$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/logo.img
	@$(RM) \
		$(CURDIR)/$(COMPOSER_SETTINGS) \
		$(CURDIR)/$(COMPOSER_CSS) \
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
		$(call $(EXAMPLE)-print,1,$(_C)$(FILE)-$(COMPOSER_BASENAME).$(FILE).$(EXTENSION)$(_D): $(_M)$(OUT_README)$(COMPOSER_EXT) $(OUT_LICENSE)$(COMPOSER_EXT)); \
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

override DIST_ICON_v1.0			:= iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAc0lEQVQ4y8VTQQ7AIAgrZA/z6fwMD8vcQCDspBcN0GIrAqcXNes0w1OQpBAsLjrujVdSwm4WPF7gE+MvW0gitqM/87pyRWLl0S4hJ6nMJwDEm3l9EgDAVRrWeFb+CVZfywU4lyRWt6bgxiB1JrEc5eOfEROp5CKUZInHTAAAAABJRU5ErkJggg==
override DIST_SCREENSHOT_v1.0		:= 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
override DIST_SCREENSHOT_v3.0		:= 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

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
# $(COMPOSER_TECHNAME)
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
# $(COMPOSER_TECHNAME)
############################################################################# */

@import url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(REVEALJS_CSS_THEME))");

/* ########################################################################## */

.reveal .slides {
	background:			url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(COMPOSER_ART)/logo.img)");
	background-repeat:		no-repeat;
	background-position:		100% 0%;
	background-size:		auto 20%;
}

/* ################################## */

:root {
	--r-heading-text-transform:	none;
	--r-heading1-size:		140%;
	--r-heading2-size:		120%;
	--r-heading3-size:		100%;
	--r-heading4-size:		100%;
	--r-heading5-size:		100%;
	--r-heading6-size:		100%;
}

.reveal * {
	font-size:			90%;
	text-transform:			none;
	vertical-align:			text-top;
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

override define HEREDOC_DISTRIB_LICENSE =
# $(COMPOSER_TECHNAME) License

--------------------------------------------------------------------------------

## Copyright

	Copyright (c) 2014, 2015, 2022, Gary B. Genett
	All rights reserved.

--------------------------------------------------------------------------------

## License

*Source: <https://www.gnu.org/licenses/gpl-3.0.html>*

GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

### Preamble

The GNU General Public License is a free, copyleft license for
software and other kinds of works.

The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

The precise terms and conditions for copying, distribution and
modification follow.

### TERMS AND CONDITIONS

#### 0. Definitions.

"This License" refers to version 3 of the GNU General Public License.

"Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

"The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

A "covered work" means either the unmodified Program or a work based
on the Program.

To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

#### 1. Source Code.

The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

The Corresponding Source for a work in source code form is that
same work.

#### 2. Basic Permissions.

All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

#### 3. Protecting Users' Legal Rights From Anti-Circumvention Law.

No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

#### 4. Conveying Verbatim Copies.

You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

#### 5. Conveying Modified Source Versions.

You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

a) The work must carry prominent notices stating that you modified
it, and giving a relevant date.

b) The work must carry prominent notices stating that it is
released under this License and any conditions added under section
7.  This requirement modifies the requirement in section 4 to
"keep intact all notices".

c) You must license the entire work, as a whole, under this
License to anyone who comes into possession of a copy.  This
License will therefore apply, along with any applicable section 7
additional terms, to the whole of the work, and all its parts,
regardless of how they are packaged.  This License gives no
permission to license the work in any other way, but it does not
invalidate such permission if you have separately received it.

d) If the work has interactive user interfaces, each must display
Appropriate Legal Notices; however, if the Program has interactive
interfaces that do not display Appropriate Legal Notices, your
work need not make them do so.

A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

#### 6. Conveying Non-Source Forms.

You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

a) Convey the object code in, or embodied in, a physical product
(including a physical distribution medium), accompanied by the
Corresponding Source fixed on a durable physical medium
customarily used for software interchange.

b) Convey the object code in, or embodied in, a physical product
(including a physical distribution medium), accompanied by a
written offer, valid for at least three years and valid for as
long as you offer spare parts or customer support for that product
model, to give anyone who possesses the object code either (1) a
copy of the Corresponding Source for all the software in the
product that is covered by this License, on a durable physical
medium customarily used for software interchange, for a price no
more than your reasonable cost of physically performing this
conveying of source, or (2) access to copy the
Corresponding Source from a network server at no charge.

c) Convey individual copies of the object code with a copy of the
written offer to provide the Corresponding Source.  This
alternative is allowed only occasionally and noncommercially, and
only if you received the object code with such an offer, in accord
with subsection 6b.

d) Convey the object code by offering access from a designated
place (gratis or for a charge), and offer equivalent access to the
Corresponding Source in the same way through the same place at no
further charge.  You need not require recipients to copy the
Corresponding Source along with the object code.  If the place to
copy the object code is a network server, the Corresponding Source
may be on a different server (operated by you or a third party)
that supports equivalent copying facilities, provided you maintain
clear directions next to the object code saying where to find the
Corresponding Source.  Regardless of what server hosts the
Corresponding Source, you remain obligated to ensure that it is
available for as long as needed to satisfy these requirements.

e) Convey the object code using peer-to-peer transmission, provided
you inform other peers where the object code and Corresponding
Source of the work are being offered to the general public at no
charge under subsection 6d.

A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

"Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

#### 7. Additional Terms.

"Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

a) Disclaiming warranty or limiting liability differently from the
terms of sections 15 and 16 of this License; or

b) Requiring preservation of specified reasonable legal notices or
author attributions in that material or in the Appropriate Legal
Notices displayed by works containing it; or

c) Prohibiting misrepresentation of the origin of that material, or
requiring that modified versions of such material be marked in
reasonable ways as different from the original version; or

d) Limiting the use for publicity purposes of names of licensors or
authors of the material; or

e) Declining to grant rights under trademark law for use of some
trade names, trademarks, or service marks; or

f) Requiring indemnification of licensors and authors of that
material by anyone who conveys the material (or modified versions of
it) with contractual assumptions of liability to the recipient, for
any liability that these contractual assumptions directly impose on
those licensors and authors.

All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

#### 8. Termination.

You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

#### 9. Acceptance Not Required for Having Copies.

You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

#### 10. Automatic Licensing of Downstream Recipients.

Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

#### 11. Patents.

A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

#### 12. No Surrender of Others' Freedom.

If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

#### 13. Use with the GNU Affero General Public License.

Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

#### 14. Revised Versions of this License.

The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

#### 15. Disclaimer of Warranty.

THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

#### 16. Limitation of Liability.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (ITHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

#### 17. Interpretation of Sections 15 and 16.

If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

### END OF TERMS AND CONDITIONS

How to Apply These Terms to Your New Programs

If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

\<one line to give the program's name and a brief idea of what it does.\>
Copyright (C) \<year>  \<name of author>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

\<program\>  Copyright (C) \<year\>  \<name of author\>
This program comes with ABSOLUTELY NO WARRANTY; for details type 'show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type 'show c' for details.

The hypothetical commands 'show w' and 'show c' should show the appropriate
parts of the General Public License.  Of course, your program's commands
might be different; for a GUI interface, you would use an "about box".

You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<https://www.gnu.org/licenses/>.

The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<https://www.gnu.org/licenses/why-not-lgpl.html>.

--------------------------------------------------------------------------------

*End Of File*
endef

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
	$(if $(filter 0,$(3)),\
		$(ECHO) "" \
		,if [ "$(1)" -gt "0" ] && [ "$(1)" -le "$(HEAD_MAIN)" ]; then $(ENDOLINE); $(LINERULE); fi \
	); \
	$(ENDOLINE); \
	$(ECHO) "$(_S)"; \
	if [ "$(1)" -le "0" ]; then $(ECHO) "#"; fi; \
	if [ "$(1)" -gt "0" ]; then $(PRINTF) "#%.0s" {1..$(1)}; fi; \
	$(ECHO) "$(_D) $(_H)$(2)$(_D) $(_S)"; \
	eval $(PRINTF) \"#%.0s\" {1..$${ttl_len}}; \
	$(ENDOLINE); \
	$(if $(filter 0,$(3)),\
		$(ENDOLINE) \
		,$(if $(3),\
			if [ "$(1)" -gt "$(HEAD_MAIN)" ]; then $(ENDOLINE); fi \
			,$(ENDOLINE) \
		) \
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
	c_type \
	c_base \
	c_list \
	c_css_use \
	c_css \
	c_title \
	c_toc \
	c_level \
	c_font \
	c_margin \
	c_options
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
	@$(call $(HEADERS)-file,$(CURDIR),$(c_base).$(EXTENSION))
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
	@$(PRINT) "  * Use '$(_C)$(TARGETS)$(_D)' to get a list of available targets"
	@$(PRINT) "  * See '$(_C)$(HELPOUT)$(_D)' or '$(_C)$(HELPOUT)-$(DOITALL)$(_D)' for more information"
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

#> update: PHONY.*$(DOITALL)
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
$(DEBUGIT): $(HELPOUT)-FOOTER
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

#> update: PHONY.*$(DOITALL)
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
$(TESTING): $(HELPOUT)-FOOTER
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
	@$(PRINT) "  * It has a dedicated '$(_C)$(TESTING_COMPOSER_DIR)$(_D)', and '$(_C)$(DOMAKE)$(_D)' can be run anywhere in the tree"
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
		$(MV) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(OUT_README); \
		$(MV) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(OUT_LICENSE); \
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
		\n\t * Command-line '$(_C)c_list$(_D)' shortcut \
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
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) $(OUT_MANUAL).$(EXTN_DEFAULT) c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)"
#WORKING turn these into variables with the readme/license work... also fix *-count checks below
	@$(SED) -n "/$(COMPOSER_TECHNAME) License/p" $(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_DEFAULT)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-done
$(TESTING)-$(COMPOSER_BASENAME)-done:
	$(call $(TESTING)-count,1,NOTICE.+$(NOTHING).+$(NOTHING)-$(DOITALL)-$(TARGETS))
	$(call $(TESTING)-count,1,NOTICE.+$(NOTHING).+$(NOTHING)-$(DOITALL)-$(SUBDIRS))
	$(call $(TESTING)-find,COMPOSER_TARGETS.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,COMPOSER_SUBDIRS.+artifacts)
	$(call $(TESTING)-find,Creating.+$(OUT_MANUAL).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,1,$(COMPOSER_TECHNAME) License)

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
	@$(TABLE_M2) "$(_H)$(MARKER) Directories"	"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type d | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Files"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+$(subst .,[.],$(COMPOSER_EXT_DEFAULT))$$/p" | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Output"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+[.]$(EXTN_DEFAULT)$$/p" | $(WC))"
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
		\n\t * Manual '$(_C)$(DOITALL)$(_D)' dependencies $(_E)('$(OUT_LICENSE).$(EXTN_DEFAULT)' before '$(OUT_README).$(EXTN_DEFAULT)')$(_D) \
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
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_MANUAL)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "$(OUT_LICENSE).$(EXTN_DEFAULT): $(OUT_README).$(EXTN_DEFAULT)\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_IGNORES := $(OUT_MANUAL).$(EXTN_DEFAULT) artifacts\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(CONFIGS) | $(SED) -n "/COMPOSER_TARGETS/p"
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(CONFIGS) | $(SED) -n "/COMPOSER_SUBDIRS/p"
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data MAKEJOBS="0" $(DOITALL)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-done
$(TESTING)-COMPOSER_DEPENDS-done:
	$(call $(TESTING)-count,1,MAKEJOBS.+1)
	$(call $(TESTING)-find,Directory.+$(notdir $(call $(TESTING)-pwd))\/data)
	$(call $(TESTING)-find,Creating.+$(notdir $(call $(TESTING)-pwd))\/data)
	$(call $(TESTING)-find,Creating.+$(OUT_MANUAL).$(EXTN_DEFAULT),,1)
	$(call $(TESTING)-find,COMPOSER_TARGETS.+$(OUT_MANUAL).$(EXTN_DEFAULT),,1)
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
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Removing.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+COMPOSER_STAMP)
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+COMPOSER_EXT)
	$(call $(TESTING)-find, $(subst $(TESTING)-.,,$(notdir $(call $(TESTING)-pwd))))
	$(call $(TESTING)-find, $(COMPOSER_STAMP_DEFAULT))

########################################
# {{{3 $(TESTING)-CSS ------------------

.PHONY: $(TESTING)-CSS
$(TESTING)-CSS: $(TESTING)-Think
	@$(call $(TESTING)-$(HEADERS),\
		Use '$(_C)c_css$(_D)' to verify each method of setting variables ,\
		\n\t * Default value \
		\n\t * Default for '$(_C)$(TYPE_PRES)$(_D)' \
		\n\t * From the environment \
		\n\t * From '$(_C)$(CSS_ALT)$(_D)' alias \
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
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css= $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_type="$(TYPE_PRES)" c_css= $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(REVEALJS_CSS))" $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(CSS_ALT)" $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_CSS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(CSS_ALT)" $(SETTING)-$(notdir $(call $(TESTING)-pwd))
	@$(ECHO) "override c_css := $(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(REVEALJS_CSS))\n" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(CSS_ALT)" $(SETTING)-$(notdir $(call $(TESTING)-pwd))

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
		\n\t * Pandoc '$(_C)c_type$(_D)' pass-through \
		\n\t * Git '$(_C)$(CONVICT)$(_D)' target \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-other-init
$(TESTING)-other-init:
	#> book
	@$(ECHO) "$(DO_BOOK)-$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF):" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_README)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_MANUAL)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "# $(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)" >$(call $(TESTING)-pwd)/$(OUT_MANUAL)$(COMPOSER_EXT_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(DOITALL)
#WORKING turn these into variables with the readme/license work... also fix *-count checks below
ifeq ($(OS_TYPE),Linux)
	@$(LESS_BIN) $(call $(TESTING)-pwd)/$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF) \
		| $(SED) -n \
			-e "/$(COMPOSER_TECHNAME): Content Make System/p" \
			-e "/$(COMPOSER_TECHNAME) License/p" \
			-e "/$(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)/p"
endif
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CLEANER)
	#> pandoc
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_type="json" $(OUT_README).json
	@$(CAT) $(call $(TESTING)-pwd)/$(OUT_README).json | $(SED) "s|[]][}][,].+$$||g"
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
	$(call $(TESTING)-count,1,$(COMPOSER_TECHNAME): Content Make System)
	$(call $(TESTING)-count,1,$(COMPOSER_TECHNAME) License)
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

#> update: PHONY.*$(DOITALL)
#> update: PHONY.*$(DOFORCE)
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
	@$(TABLE_M3) "$(_E)[Pandoc]"			"$(_E)$(PANDOC_CMT_DISPLAY)"		"$(_N)$(PANDOC_LIC)"
	@$(TABLE_M3) "$(_E)[YQ]"			"$(_E)$(YQ_CMT_DISPLAY)"		"$(_N)$(YQ_LIC)"
	@$(TABLE_M3) "$(_E)[Bootstrap]"			"$(_E)$(BOOTSTRAP_CMT)"			"$(_N)$(BOOTSTRAP_LIC)"
	@$(TABLE_M3) "$(_E)[Markdown Viewer]"		"$(_E)$(MDVIEWER_CMT)"			"$(_N)$(MDVIEWER_LIC)"
	@$(TABLE_M3) "$(_E)[Reveal.js]"			"$(_E)$(REVEALJS_CMT)"			"$(_N)$(REVEALJS_LIC)"
	@$(ENDOLINE)
ifeq ($(COMPOSER_DOITALL_$(CHECKIT)),$(DOFORCE))
	@$(TABLE_M2) "$(_H)Project"			"$(_H)$(COMPOSER_BASENAME) Version"
	@$(TABLE_M2) ":---"				":---"
	@$(TABLE_M2) "$(_C)GNU Bash"			"$(_M)$(BASH_VER)"
	@$(TABLE_M2) "- $(_C)GNU Coreutils"		"$(_M)$(COREUTILS_VER)"
	@$(TABLE_M2) "- $(_C)GNU Findutils"		"$(_M)$(FINDUTILS_VER)"
	@$(TABLE_M2) "- $(_C)GNU Sed"			"$(_M)$(SED_VER)"
	@$(TABLE_M2) "$(_C)[GNU Make]"			"$(_M)$(MAKE_VER)"
	@$(TABLE_M2) "- $(_C)[Pandoc]"			"$(_M)$(PANDOC_VER)"
	@$(TABLE_M2) "- $(_C)[YQ]"			"$(_M)$(YQ_VER)"
	@$(TABLE_M2) "- $(_C)[TeX Live] ($(TYPE_LPDF))"	"$(_M)$(TEX_PDF_VER)"
else
	@$(TABLE_M3) "$(_H)Project"			"$(_H)$(COMPOSER_BASENAME) Version"	"$(_H)System Version"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_C)GNU Bash"			"$(_M)$(BASH_VER)"			"$(_D)$(shell $(BASH) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GNU Coreutils"		"$(_M)$(COREUTILS_VER)"			"$(_D)$(shell $(LS) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GNU Findutils"		"$(_M)$(FINDUTILS_VER)"			"$(_D)$(shell $(FIND) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GNU Sed"			"$(_M)$(SED_VER)"			"$(_D)$(shell $(SED) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_C)[GNU Make]"			"$(_M)$(MAKE_VER)"			"$(_D)$(shell $(REALMAKE) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)[Pandoc]"			"$(_M)$(PANDOC_VER)"			"$(_D)$(shell $(PANDOC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)[YQ]"			"$(_M)$(YQ_VER)"			"$(_D)$(shell $(YQ) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)[TeX Live] ($(TYPE_LPDF))"	"$(_M)$(TEX_PDF_VER)"			"$(_D)$(shell $(TEX_PDF) --version		2>/dev/null | $(HEAD) -n1)"
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(TABLE_M3) "$(_H)Target: $(UPGRADE)"		"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "- $(_E)Git SCM"			"$(_E)$(GIT_VER)"			"$(_N)$(shell $(GIT) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Wget"			"$(_E)$(WGET_VER)"			"$(_N)$(shell $(WGET) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Tar"			"$(_E)$(TAR_VER)"			"$(_N)$(shell $(TAR) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Gzip"			"$(_E)$(GZIP_VER)"			"$(_N)$(shell $(GZIP_BIN) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)7z"			"$(_E)$(7Z_VER)"			"$(_N)$(shell $(7Z)				2>/dev/null | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_M3) "$(_H)Target: $(TESTING)"		"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "- $(_E)GNU Diffutils"		"$(_E)$(DIFFUTILS_VER)"			"$(_N)$(shell $(DIFF) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Rsync"			"$(_E)$(RSYNC_VER)"			"$(_N)$(shell $(RSYNC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Less"			"$(_E)$(LESS_VER)"			"$(_N)$(shell $(LESS_BIN) --version		2>/dev/null | $(HEAD) -n1)"
endif
	@$(ENDOLINE)
	@$(TABLE_M2) "$(_H)Project"			"$(_H)Location & Options"
	@$(TABLE_M2) ":---"				":---"
	@$(TABLE_M2) "$(_C)GNU Bash"			"$(_D)$(BASH)"
	@$(TABLE_M2) "- $(_C)GNU Coreutils"		"$(_D)$(LS)"
	@$(TABLE_M2) "- $(_C)GNU Findutils"		"$(_D)$(FIND)"
	@$(TABLE_M2) "- $(_C)GNU Sed"			"$(_D)$(SED)"
	@$(TABLE_M2) "$(_C)[GNU Make]"			"$(_D)$(REALMAKE)"
	@$(TABLE_M2) "- $(_C)[Pandoc]"			"$(if $(filter $(PANDOC),$(PANDOC_BIN)),$(_M),$(_E))$(call $(HEADERS)-release,$(PANDOC))"
	@$(TABLE_M2) "- $(_C)[YQ]"			"$(if $(filter $(YQ),$(YQ_BIN)),$(_M),$(_E))$(call $(HEADERS)-release,$(YQ))"
	@$(TABLE_M2) "- $(_C)[TeX Live] ($(TYPE_LPDF))"	"$(_D)$(TEX_PDF)"
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
	@$(call GIT_REPO,$(BOOTSTRAP_DIR),$(BOOTSTRAP_SRC),$(BOOTSTRAP_CMT))
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
		$(BOOTSTRAP_DIR)/dist \
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
#> update: PHONY.*$(DOFORCE)
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
		| $(SED) "/^$(HELPOUT)[-]/d" \
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
	@$$(RUNMAKE) $$(WHOWHAT)-$(1)
endif
	@$$(ECHO) ""

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
	@$$(eval override $$(@) := $$(CURDIR)/$$(subst $(1)-$$(SUBDIRS)-,,$$(@)))
	@+$$(if $$(wildcard $$($$(@))/$$(MAKEFILE)),\
		$$(MAKE) $$(MAKE_OPTIONS) --directory $$($$(@)) $(1),\
		$$(RUNMAKE) --directory $$($$(@)) $$(NOTHING)-$$(MAKEFILE) \
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
$(COMPOSER_PANDOC): $(c_list)
	@$(ECHO) "$(_N)"
	@$(MKDIR) $(COMPOSER_TMP)
	@$(PANDOC) $(PANDOC_OPTIONS)
	@$(ECHO) "$(_D)"
ifneq ($(COMPOSER_STAMP),)
	@$(ECHO) "$(DATESTAMP)" >$(CURDIR)/$(COMPOSER_STAMP)
endif

.PHONY: $(COMPOSER_CREATE)
$(COMPOSER_CREATE): $(c_base).$(EXTENSION)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := create)$(call $(HEADERS)-note,$(c_base) $(MARKER) $(EXTENSION),$(c_list))
endif
	@$(ECHO) ""

$(c_base).$(EXTENSION): $(c_list)
	@$(RUNMAKE) $(COMPOSER_PANDOC) c_type="$(c_type)" c_base="$(c_base)" c_list="$(c_list)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := base)$(call $(HEADERS)-note,$(c_base) $(MARKER) $(c_type),$(c_list))
endif

########################################
# {{{2 $(COMPOSER_EXT) -----------------

#> update: TYPE_TARGETS

override define TYPE_TARGETS =
%.$(2): %$(COMPOSER_EXT)
	@$$(RUNMAKE) $$(COMPOSER_CREATE) c_type="$(1)" c_base="$$(*)" c_list="$$(^)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := $(INPUT))$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif

%.$(2): %
	@$$(RUNMAKE) $$(COMPOSER_CREATE) c_type="$(1)" c_base="$$(*)" c_list="$$(^)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := wildcard)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif

%.$(2): $(c_list)
	@$$(RUNMAKE) $$(COMPOSER_CREATE) c_type="$(1)" c_base="$$(*)" c_list="$$(^)"
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
	@$$(RUNMAKE) $$(COMPOSER_CREATE) c_type="$(1)" c_base="$$(*)" c_list="$$(^)"
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

override define TYPE_DO_PAGE =
$(DO_PAGE)-%.$(2):
	@$$(RUNMAKE) $$(NOTHING)-$$(DO_PAGE)-FUTURE
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := do_post)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(^))
endif
endef

$(eval $(call TYPE_DO_PAGE,$(TYPE_HTML),$(EXTN_HTML)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_LPDF),$(EXTN_LPDF)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_EPUB),$(EXTN_EPUB)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_PRES),$(EXTN_PRES)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_DOCX),$(EXTN_DOCX)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_PPTX),$(EXTN_PPTX)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_TEXT),$(EXTN_TEXT)))
$(eval $(call TYPE_DO_PAGE,$(TYPE_LINT),$(EXTN_LINT)))

########################################

#> update: TYPE_TARGETS

override define TYPE_DO_POST =
$(DO_POST)-%.$(2):
	@$$(RUNMAKE) $$(NOTHING)-$$(DO_POST)-FUTURE
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
