#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################
override VIM_OPTIONS := vim: foldmethod=marker foldtext=foldtext() foldlevel=0 filetype=make
override VIM_FOLDING := {{{1
################################################################################
#
#WORK portability? + bash shell is required?  need this notice?  put it in readme instead?
#WORK is there a better use for this space?  who is going to read this besides me, anyway?
#
# Every attempt has been made to make this as portable as possible:
#	http://www.gnu.org/software/make/manual/make.html#toc-Features-of-GNU-make
#	http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Make
#	http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
#
# Please report any cross-platform issues, or issues with other versions of Make.
#
################################################################################

#WORK reduce use of --silent to only what is mandatory = done!  working?

#WORK ultimately, before committing the new version, do a git-patch of Makefile (tags?), and git-am it in, for posterity...?
#WORK	what do the dates report, in this case?

#WORK limit global shell calls!
#WORK replace sort, as much as possible?  also removes the need for strip
#WORK remove quotes from all filenames... make a note in documentation that spaces are evil...
#WORK comments, comments, comments (& formatting :)
#WORK document, somehow, all the places "composer" is used personally, for debugging/testing...
#WORK prompt -z, my friend... early and everywhere...
#WORK patches directory?  heredocs below... starting with v3.0, just as a pattern?  I'm sure there is stuff that is changed... just good practice...

#WORK document not to use *-[...] target names...
#WORK a note somewhere about symlinks...

#WORK TODO FEATURES
# https://stackoverflow.com/questions/3828606/vim-markdown-folding
# https://gist.github.com/vim-voom/1035030
# http://vimcasts.org/episodes/writing-a-custom-fold-expression
# https://pygospasprofession.wordpress.com/2013/07/10/markdown-and-vim
# http://www.macworld.com/article/1161549/forget_fancy_formatting_why_plain_text_is_best.html
#WORK TODO FEATURES
# https://github.com/nelstrom/vim-markdown-folding
# https://github.com/tpope/vim-markdown
# https://github.com/hallison/vim-markdown
# https://github.com/plasticboy/vim-markdown
#WORK TODO FEATURES
# https://github.com/mikefarah/yq
# https://github.com/jgm/yst
# http://hackage.haskell.org/package/gitit
#WORK TODO FEATURES
# http://make.mad-scientist.net/constructed-include-files
# http://www.html5rocks.com/en/tutorials/webcomponents/imports
# http://filoxus.blogspot.com/2008/01/how-to-insert-watermark-in-latex.html
# https://gist.github.com/ryangray/1882525
# https://gist.github.com/Dashed/6714393
# https://www.w3.org/community/markdown/wiki/MarkdownImplementations
#WORK TODO FEATURES

################################################################################
# }}}1
################################################################################
# {{{1 Include Files -----------------------------------------------------------
################################################################################

override COMPOSER_FIND			= $(firstword $(wildcard $(abspath $(addsuffix /$(2),$(1)))))
override define READ_ALIASES =
	$(if $(subst undefined,,$(origin $(1))),$(eval override $(3) := $($(1))))
	$(if $(subst undefined,,$(origin $(2))),$(eval override $(3) := $($(2))))
endef

########################################

#> update: includes duplicates

$(call READ_ALIASES,J,c_jobs,MAKEJOBS)
$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)

override COMPOSER_DEBUGIT_ALL		:=
ifeq ($(COMPOSER_DEBUGIT),!)
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

override PATH_LIST			:= $(subst :, ,$(PATH))
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

########################################

override COMPOSER_SETTINGS		:= .composer.mk
override MAKEFILE_LIST			:= $(abspath $(MAKEFILE_LIST))

#WORK COMPOSER_INCLUDES documentation:
# by default, just the local .composer.mk and the one in composer, from top to bottom
#	using := is best, and will result in global-to-local definitons
#	using ?= will either pick up a global defined earlier, or allow a local environment variable override if not, so it is confusing to use
# setting COMPOSER_INCLUDE includes all the intermediary .composer.mk files, from global-to-local
#	all the same rules apply
# variable definitions must be the 'source_regex' (create this), or may not work properly (COMPOSER_INCLUDE, especially): override[ ][^ ]+[ ][:?][=].*
#WORK

#WORKING:NOW add $(COMPOSER_ROOT)/$(COMPOSER_SETTINGS) to this list, and add to $(TESTING)...

ifneq ($(wildcard $(CURDIR)/$(COMPOSER_SETTINGS)),)
$(if $(COMPOSER_DEBUGIT_ALL),$(warning #SOURCE $(CURDIR)/$(COMPOSER_SETTINGS)))
#>include $(CURDIR)/$(COMPOSER_SETTINGS)
$(foreach FILE,\
	$(shell \
		$(SED) -n "/^override[[:space:]]+([^[:space:]]+)[[:space:]]+[:?][=].*$$/p" $(CURDIR)/$(COMPOSER_SETTINGS) \
		| $(SED) -e "s|[[:space:]]+|~|g" -e "s|$$| |g" \
	),\
	$(eval $(subst ~, ,$(FILE))) \
)
endif

override COMPOSER_INCLUDES		:=
ifneq ($(COMPOSER_INCLUDE),)
override COMPOSER_INCLUDES_LIST		:= $(MAKEFILE_LIST)
else ifeq ($(firstword $(MAKEFILE_LIST)),$(lastword $(MAKEFILE_LIST)))
override COMPOSER_INCLUDES_LIST		:= $(MAKEFILE_LIST)
else
override COMPOSER_INCLUDES_LIST		:= $(firstword $(MAKEFILE_LIST)) $(lastword $(MAKEFILE_LIST))
endif

$(if $(COMPOSER_DEBUGIT_ALL),$(warning #COMPOSER_INCLUDE[$(COMPOSER_INCLUDE)]))
$(foreach FILE,$(addsuffix /$(COMPOSER_SETTINGS),$(abspath $(dir $(COMPOSER_INCLUDES_LIST)))),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(warning #WILDCARD $(FILE))); \
	$(if $(wildcard $(FILE)),$(eval override COMPOSER_INCLUDES := \
		$(FILE) $(COMPOSER_INCLUDES) \
	)); \
)
$(foreach FILE,$(COMPOSER_INCLUDES),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(warning #INCLUDE $(FILE))); \
	$(eval override MAKEFILE_LIST := $(filter-out $(FILE),$(MAKEFILE_LIST))); \
	$(eval include $(FILE)); \
)

override COMPOSER_INCLUDES		:= $(strip $(COMPOSER_INCLUDES))

################################################################################
# {{{1 Make Settings -----------------------------------------------------------
################################################################################

.POSIX:
.SUFFIXES:

########################################

export

unexport TITLE_LN

#> update: eval unexport
#>unexport COMPOSER_TARGETS
#>unexport COMPOSER_SUBDIRS

########################################

#> update: includes duplicates
#> update: $(EXAMPLE):
$(call READ_ALIASES,J,c_jobs,MAKEJOBS)
override MAKEJOBS			?=

ifeq ($(MAKEJOBS),)
.NOTPARALLEL:
endif
ifeq ($(MAKEJOBS),1)
.NOTPARALLEL:
endif

ifeq ($(MAKEJOBS),)
override MAKEJOBS			:= 1
endif

ifeq ($(MAKEJOBS),1)
override MAKEJOBS_OPTS			:= --jobs=$(MAKEJOBS) --output-sync=none
else
#>override MAKEJOBS_OPTS			:= --jobs=$(MAKEJOBS) --output-sync=line
override MAKEJOBS_OPTS			:= --jobs=$(MAKEJOBS) --output-sync=none
endif
ifeq ($(MAKEJOBS),0)
override MAKEJOBS_OPTS			:= $(subst --jobs=$(MAKEJOBS),--jobs,$(MAKEJOBS_OPTS))
endif

########################################

override MAKEFILE			:= Makefile
override MAKEFLAGS			:= --no-builtin-rules --no-builtin-variables --no-print-directory $(MAKEJOBS_OPTS)

################################################################################
# {{{1 Composer Globals --------------------------------------------------------
################################################################################

#> update: includes duplicates
#> update: $(EXAMPLE):

$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)
$(call READ_ALIASES,C,c_color,COMPOSER_ESCAPES)

override COMPOSER_DEBUGIT		?=
override COMPOSER_INCLUDE		?=
override COMPOSER_ESCAPES		?= 1

########################################

#> update: includes duplicates
override COMPOSER_DEBUGIT_ALL		:=
ifeq ($(COMPOSER_DEBUGIT),!)
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

ifneq ($(COMPOSER_DEBUGIT_ALL),)
#>override MAKEFLAGS			:= $(MAKEFLAGS) --debug=all
#>override MAKEFLAGS			:= $(MAKEFLAGS) --debug=verbose
#WORK what is the difference in output?
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=makefile
else
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=none
endif

########################################

override COMPOSER			:= $(abspath $(lastword $(MAKEFILE_LIST)))
override COMPOSER_SRC			:= $(abspath $(firstword $(MAKEFILE_LIST)))
override COMPOSER_DIR			:= $(abspath $(dir $(COMPOSER)))

override COMPOSER_ROOT			:= $(abspath $(dir $(lastword $(filter-out $(COMPOSER),$(MAKEFILE_LIST)))))
ifeq ($(COMPOSER_ROOT),)
override COMPOSER_ROOT			:= $(COMPOSER_DIR)
endif

########################################

override ~				:= "'$$'"
override COMPOSER_MY_PATH		:= $(~)(abspath $(~)(dir $(~)(lastword $(~)(MAKEFILE_LIST))))
override COMPOSER_TEACHER		:= $(~)(abspath $(~)(dir $(~)(COMPOSER_MY_PATH)))/$(MAKEFILE)

override COMPOSER_REGEX			:= [a-zA-Z0-9][a-zA-Z0-9_.-]*
override COMPOSER_REGEX_PREFIX		:= [_.]

################################################################################
# {{{1 Composer Settings -------------------------------------------------------
################################################################################

override COMPOSER_VERSION		:= v3.0
override COMPOSER_BASENAME		:= Composer
override COMPOSER_FULLNAME		:= $(COMPOSER_BASENAME) CMS $(COMPOSER_VERSION)

########################################

#WORK keep COMPOSER_MAN?
override COMPOSER_CSS			:= .composer.css

override COMPOSER_PKG			:= $(COMPOSER_DIR)/.sources
override COMPOSER_MAN			:= $(COMPOSER_DIR)/Pandoc_Manual
override COMPOSER_ART			:= $(COMPOSER_DIR)/artifacts

########################################

override DEFAULT_TYPE			:= html

override OUTPUT_FILENAME		= $(COMPOSER_BASENAME)-$(COMPOSER_VERSION).$(1)-$(DATENAME).$(EXTN_TEXT)
override TESTING_DIR			:= $(COMPOSER_DIR)/testing

#WORK keep EXAMPLE_OUT?
override EXAMPLE_TGT			:= manual
override EXAMPLE_OUT			:= Users_Guide
override EXAMPLE_ONE			:= README
override EXAMPLE_TWO			:= LICENSE

################################################################################
# {{{1 Composer Options --------------------------------------------------------
################################################################################

#> update: $(EXAMPLE):

override COMPOSER_STAMP			?= .composed

#WORK document empty COMPOSER_EXT value...
override COMPOSER_EXT_DEFAULT		:= .md
override COMPOSER_EXT			?= $(COMPOSER_EXT_DEFAULT)
#>ifeq ($(COMPOSER_EXT),)
#>override COMPOSER_EXT			:= $(COMPOSER_EXT_DEFAULT)
#>endif
override COMPOSER_EXT			:= $(notdir $(COMPOSER_EXT))

########################################

#WORK document COMPOSER_TARGETS and COMPOSER_SUBDIRS auto-detection behavior, including *-$(CLEANER) target stripping
#WORK a note about this is that COMPOSER_SUBDIRS may pick up directories that override core recipies ('docs' and 'test' are primary candidates)
#	warning: overriding recipe for target 'pandoc'
#	warning: ignoring old recipe for target 'pandoc'

ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER_DIR),$(CURDIR))
ifneq ($(COMPOSER_EXT),)
override COMPOSER_TARGETS		:= $(sort $(subst $(COMPOSER_EXT),.$(DEFAULT_TYPE),$(notdir $(wildcard $(CURDIR)/*$(COMPOSER_EXT)))))
else
override COMPOSER_TARGETS		:= $(sort $(addsuffix .$(DEFAULT_TYPE),$(notdir $(wildcard $(CURDIR)/*$(COMPOSER_EXT)))))
endif
endif
endif
ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^($(COMPOSER_REGEX))[:]+.*$$|\1|gp" $(CURDIR)/$(COMPOSER_SETTINGS) 2>/dev/null)
endif
endif
ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^($(COMPOSER_REGEX))[:]+.*$$|\1|gp" $(COMPOSER_SRC))
endif
endif

ifeq ($(COMPOSER_SUBDIRS),)
ifneq ($(COMPOSER_DIR),$(CURDIR))
#>override COMPOSER_SUBDIRS		:= $(sort $(notdir $(filter-out $(CURDIR),$(abspath $(dir $(wildcard $(CURDIR)/*/$(MAKEFILE)))))))
override COMPOSER_SUBDIRS		:= $(sort $(notdir $(filter-out $(CURDIR),$(abspath $(dir $(wildcard $(CURDIR)/*/))))))
endif
endif

#> update: Pandoc Options: COMPOSER_TARGETS
#> update: $(EXAMPLE):
override COMPOSER_TARGETS		?=
override COMPOSER_SUBDIRS		?=
override COMPOSER_DEPENDS		?=

########################################

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

#> update: $(EXAMPLE):
#> update: $(HEADERS)-vars
override TYPE				?= $(DEFAULT_TYPE)
override BASE				?= $(EXAMPLE_ONE)
override LIST				?= $(BASE)$(COMPOSER_EXT)
override CSS				?= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
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

#WORKING:NOW made the *_CMT variables user defined... are they in the right spot in $(CONFIGS), or is some relocation necessary?

# https://github.com/jgm/pandoc
# https://github.com/jgm/pandoc/blob/master/COPYING.md
override PANDOC_CMT			?= 2.13
override PANDOC_LIC			:= GPL
override PANDOC_SRC			:= https://github.com/jgm/pandoc.git
override PANDOC_DIR			:= $(COMPOSER_DIR)/pandoc
#WORK override PANDOC_TEX_PDF			:= xelatex
override PANDOC_TEX_PDF			:= pdflatex

# https://github.com/hakimel/reveal.js
# https://github.com/hakimel/reveal.js/blob/master/LICENSE
override REVEALJS_CMT			?= 4.3.1
override REVEALJS_LIC			:= MIT
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DIR			:= $(COMPOSER_DIR)/revealjs
override REVEALJS_CSS_THEME		:= $(notdir $(REVEALJS_DIR))/dist/theme/black.css
override REVEALJS_CSS			:= $(COMPOSER_ART)/revealjs.css

# https://github.com/simov/markdown-viewer
# https://github.com/simov/markdown-viewer/blob/master/LICENSE
#>override MDVIEWER_CMT			?= 059f3192d4ebf5fa9776478ea221d586480e7fa7
override MDVIEWER_CMT			?= 059f3192d4ebf5fa9776
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

override BASH_VER			:= 5.0.18
override COREUTILS_VER			:= 8.31
override FINDUTILS_VER			:= 4.8.0
override DIFFUTILS_VER			:= 3.7
override SED_VER			:= 4.8
override RSYNC_VER			:= 3.2.3
override MAKE_VER			:= 4.2.1
override GIT_VER			:= 2.32.0
override NPM_VER			:= 6.14.8

override GHC_VER			:= 8.10.5
override PANDOC_VER			:= $(PANDOC_CMT)
override PANDOC_TYPE_VER		:= 1.22
override PANDOC_MATH_VER		:= 0.12.2
override PANDOC_SKYL_VER		:= 0.10.5
override PANDOC_CITE_VER		:= 0.3.0.9

override TEX_YEAR			:= 2021
override TEX_PI				:= 3.141592653
override TEX_VER			:= $(TEX_PI) ($(TEX_YEAR))
override TEX_PDF_VER			:= $(TEX_PI) (2.6-1.40.22)

################################################################################
# {{{1 Tooling Options ---------------------------------------------------------
################################################################################

#> update: includes duplicates
override PATH_LIST			:= $(subst :, ,$(PATH))

override SHELL				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)
export SHELL

########################################

#WORK verify all of these are in packages listed in $(CHECKIT)

#> sed -nr "s|^override[[:space:]]+([^[:space:]]+).+[(]PATH_LIST[)].+$|\1|gp" Makefile | while read -r FILE; do echo "--- ${FILE} ---"; grep -E "[(]${FILE}[)]" Makefile; done

override BASH				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)
override COREUTILS			:= $(call COMPOSER_FIND,$(PATH_LIST),coreutils)

override BASE64				:= $(call COMPOSER_FIND,$(PATH_LIST),base64) -w0
override CAT				:= $(call COMPOSER_FIND,$(PATH_LIST),cat)
override CHMOD				:= $(call COMPOSER_FIND,$(PATH_LIST),chmod) -v 755
override CP				:= $(call COMPOSER_FIND,$(PATH_LIST),cp) -afv
override DATE				:= $(call COMPOSER_FIND,$(PATH_LIST),date) --iso=seconds
override DIFF				:= $(call COMPOSER_FIND,$(PATH_LIST),diff) -u -U10
override ECHO				:= $(call COMPOSER_FIND,$(PATH_LIST),echo) -en
override ENV				:= $(call COMPOSER_FIND,$(PATH_LIST),env) - PATH="$(PATH)"
override EXPR				:= $(call COMPOSER_FIND,$(PATH_LIST),expr)
override FIND				:= $(call COMPOSER_FIND,$(PATH_LIST),find)
override HEAD				:= $(call COMPOSER_FIND,$(PATH_LIST),head)
override LN				:= $(call COMPOSER_FIND,$(PATH_LIST),ln) -fsv --relative
override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) --color=auto --time-style=long-iso -asF -l
override MKDIR				:= $(call COMPOSER_FIND,$(PATH_LIST),install) -dv
override MV				:= $(call COMPOSER_FIND,$(PATH_LIST),mv) -fv
override PRINTF				:= $(call COMPOSER_FIND,$(PATH_LIST),printf)
override REALPATH			:= $(call COMPOSER_FIND,$(PATH_LIST),realpath) --canonicalize-missing --relative-to
override RM				:= $(call COMPOSER_FIND,$(PATH_LIST),rm) -fv
override RSYNC				:= $(call COMPOSER_FIND,$(PATH_LIST),rsync) -avv --recursive --itemize-changes --times --delete
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r
override SORT				:= $(call COMPOSER_FIND,$(PATH_LIST),sort) -uV
override TAIL				:= $(call COMPOSER_FIND,$(PATH_LIST),tail)
override TEE				:= $(call COMPOSER_FIND,$(PATH_LIST),tee) -a
override TRUE				:= $(call COMPOSER_FIND,$(PATH_LIST),true)

#>override MAKE				:= $(call COMPOSER_FIND,$(PATH_LIST),make)
override REALMAKE			:= $(call COMPOSER_FIND,$(PATH_LIST),make)
override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git)
override NPM				:= $(call COMPOSER_FIND,$(PATH_LIST),npm)
override NPM_PKG			:= $(COMPOSER_PKG)/_npm
override NPM_RUN			:= $(NPM) --prefix $(NPM_PKG) --cache $(NPM_PKG) --verbose

override PANDOC				:= $(call COMPOSER_FIND,$(PATH_LIST),pandoc)
override GHC_PKG			:= $(call COMPOSER_FIND,$(PATH_LIST),ghc-pkg) --verbose
override GHC_PKG_INFO			:= $(GHC_PKG) latest
override TEX				:= $(call COMPOSER_FIND,$(PATH_LIST),tex)
override TEX_PDF			:= $(call COMPOSER_FIND,$(PATH_LIST),$(PANDOC_TEX_PDF))

########################################

override DATESTAMP			:= $(shell $(DATE))
override DATENAME			:= $(shell $(DATE) | $(SED) \
	-e "s|[-]([0-9]{2}[:]?[0-9]{2})$$|T\1|g" \
	-e "s|[-:]||g" \
	-e "s|T|-|g" \
)

override COMPOSER_GIT_RUN		= cd $(COMPOSER_ROOT) && $(GIT) --git-dir="$(strip $(if \
		$(wildcard $(COMPOSER_ROOT).git),\
		$(COMPOSER_ROOT).git ,\
		$(COMPOSER_ROOT)/.git \
	))" --work-tree="$(COMPOSER_ROOT)" $(1)

override GIT_RUN			= cd $(1) && $(GIT) --git-dir="$(COMPOSER_PKG)/$(notdir $(1)).git" --work-tree="$(1)" $(2)
override GIT_REPO			= $(call DO_GIT_REPO,$(1),$(2),$(3),$(4),$(COMPOSER_PKG)/$(notdir $(1)).git)
override define DO_GIT_REPO =
	$(MKDIR) $(COMPOSER_PKG) $(1); \
	if [ ! -d "$(5)" ] && [ -d "$(1).git"  ]; then $(MV) $(1).git  $(5); fi; \
	if [ ! -d "$(5)" ] && [ -d "$(1)/.git" ]; then $(MV) $(1)/.git $(5); fi; \
	if [ ! -d "$(5)" ]; then \
		$(call GIT_RUN,$(1),init); \
		$(call GIT_RUN,$(1),remote add origin $(2)); \
	fi; \
	$(ECHO) "gitdir: `$(REALPATH) $(1) $(5)`" >$(1)/.git; \
	$(call GIT_RUN,$(1),config --local --replace-all core.worktree $(1)); \
	$(call GIT_RUN,$(1),fetch --all); \
	if [ -n "$(3)" ] && [ -n "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force -B $(4) $(3)); fi; \
	if [ -n "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force -B $(COMPOSER_BASENAME) $(3)); fi; \
	if [ -z "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force master); fi; \
	$(call GIT_RUN,$(1),reset --hard); \
	if [ -f "$(1)/.gitmodules" ]; then \
		$(call GIT_RUN,$(1),submodule update --init --recursive --force); \
	fi
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
ifneq ($(COMPOSER_ESCAPES),)
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

override MARKER				:= >>
override DIVIDE				:= ::
override NULL				:=

# https://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
override define NEWLINE =
$(NULL)
$(NULL)
endef

########################################

#WORKING:NOW
#WORKING convert all output to markdown
#WORKING ensure all output fits within 80 characters
#WORKING do a mouse-select of all text, to ensure proper color handling
#WORKING the above should be reviewed during testing... maybe output some notes in $(TESTING)...?

#WORK make COMPOSER_ESCAPES= config | grep -vE "^[#]"
#WORK make COMPOSER_ESCAPES= check | grep -vE "^[#]"

override NUMCOLUMN			:= 80
override HEAD_MAIN			:= 1

override COMMENTED			:= $(_S)\#$(_D) $(NULL)
override CODEBLOCK			:= $(NULL)	$(NULL)
override ENDOLINE			:= $(ECHO) "$(_D)\n"
override LINERULE			:= $(ECHO) "$(_H)";	$(PRINTF)  "-%.0s" {1..$(NUMCOLUMN)}	; $(ENDOLINE)
override HEADER_L			:= $(ECHO) "$(_S)";	$(PRINTF) "\#%.0s" {1..$(NUMCOLUMN)}	; $(ENDOLINE)

# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
ifneq ($(COMPOSER_ESCAPES),)
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
	$(eval override TTL_LEN := $(shell $(EXPR) length "$(2)")) \
	$(eval override TTL_LEN := $(shell $(EXPR) $(NUMCOLUMN) - 2 - $(1) - $(TTL_LEN))) \
	if [ "$(1)" -gt "0" ] && [ "$(1)" -le "$(HEAD_MAIN)" ]; then $(ENDOLINE); $(LINERULE); fi; \
	$(ENDOLINE); \
	$(ECHO) "$(_S)"; \
	if [ "$(1)" -le "0" ]; then $(ECHO) "#"; fi; \
	if [ "$(1)" -gt "0" ]; then $(PRINTF) "#%.0s" {1..$(1)}; fi; \
	$(ECHO) "$(_D) $(_H)$(2)$(_D) $(_S)"; \
	$(PRINTF) "#%.0s" {1..$(TTL_LEN)}; \
	$(ENDOLINE); \
	$(if $(3),\
		if [ "$(1)" -gt "$(HEAD_MAIN)" ]; then $(ENDOLINE); fi \
		,$(ENDOLINE) \
	); \
	if [ "$(1)" -le "0" ]; then $(LINERULE); $(ENDOLINE); fi
endef

################################################################################
# {{{1 Composer Operation ------------------------------------------------------
################################################################################

override COMPOSER_TARGET		:= compose
override COMPOSER_PANDOC		:= pandoc

#>override RUNMAKE			:= $(MAKE) --makefile "$(COMPOSER_SRC)"
override RUNMAKE			:= $(REALMAKE) --makefile "$(COMPOSER_SRC)"
override COMPOSE			:= $(RUNMAKE) $(COMPOSER_TARGET)
override MAKEDOC			:= $(RUNMAKE) $(COMPOSER_PANDOC)

########################################

#> update: $(DEBUGIT):
#> update: $(TESTING):

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

override CONVICT			:= _commit
override DISTRIB			:= _release
override UPGRADE			:= _update

override DEBUGIT			:= debug
override TESTING			:= test
override CHECKIT			:= check

override CONFIGS			:= config
override TARGETS			:= targets
override INSTALL			:= install

override DOITALL			:= all
override CLEANER			:= clean
override SUBDIRS			:= subdirs
override PRINTER			:= print

#WORKING replace HELP_* / EXAMPLE_* with $(CREATOR)_*, and re-sort the file...

#> grep -E -e "[{][{][{][0-9]+" -e "^([#][>])?[.]PHONY[:]" Makefile
#> grep -E "[)]-[a-z]+" Makefile
override LISTING_VAR := \
	$(COMPOSER_TARGET)[:] \
	$(COMPOSER_PANDOC)[:] \
	\
	$(HELPOUT)[:-] \
	$(HELPALL)[:-] \
	$(CREATOR)[:-] \
	$(EXAMPLE)[:-] \
	HELP[_] \
	EXAMPLE[_] \
	\
	$(HEADERS)[:-] \
	$(WHOWHAT)[:-] \
	$(SETTING)[:-] \
	\
	$(MAKE_DB)[:-] \
	$(LISTING)[:-] \
	$(NOTHING)[:-] \
	\
	$(CONVICT)[:-] \
	$(DISTRIB)[:-] \
	$(UPGRADE)[:-] \
	\
	$(DEBUGIT)[:-] \
	$(TESTING)[:-] \
	$(CHECKIT)[:-] \
	\
	$(CONFIGS)[:-] \
	$(TARGETS)[:-] \
	$(INSTALL)[:-] \
	\
	$(CLEANER)[:-] \
	$(DOITALL)[:-] \
	$(SUBDIRS)[:-] \
	$(PRINTER)[:-] \

########################################

#> update: eval unexport

$(INSTALL): $(eval unexport COMPOSER_TARGETS)
$(INSTALL): $(eval unexport COMPOSER_SUBDIRS)

$(DOITALL): $(eval unexport COMPOSER_TARGETS)
$(DOITALL): $(eval unexport COMPOSER_SUBDIRS)

########################################

#> update: COMPOSER_TARGETS.*filter-out
override COMPOSER_TARGETS		:= $(filter-out %-$(CLEANER),$(COMPOSER_TARGETS))

################################################################################
# {{{1 Pandoc Options ----------------------------------------------------------
################################################################################

override INPUT				:= markdown
override OUTPUT				:= $(TYPE)
override EXTENSION			:= $(TYPE)

########################################

override HTML_DESC			:= HyperText Markup Language
override LPDF_DESC			:= Portable Document Format
override PRES_DESC			:= Reveal.js Presentation
override DOCX_DESC			:= Microsoft Office Open XML
override EPUB_DESC			:= Electronic Publication
override TEXT_DESC			:= Plain Text (well-formatted)
override LINT_DESC			:= Pandoc Markdown (for testing)

#> update: COMPOSER_TARGETS.*strip
#> update: TYPE_TARGETS
override TYPE_HTML			:= html
override TYPE_LPDF			:= pdf
override TYPE_PRES			:= revealjs
override TYPE_DOCX			:= docx
override TYPE_EPUB			:= epub
override TYPE_TEXT			:= text
override TYPE_LINT			:= $(INPUT)

override EXTN_HTML			:= $(TYPE_HTML)
override EXTN_LPDF			:= $(TYPE_LPDF)
override EXTN_PRES			:= $(TYPE_PRES).$(TYPE_HTML)
override EXTN_DOCX			:= $(TYPE_DOCX)
override EXTN_EPUB			:= $(TYPE_EPUB)
override EXTN_TEXT			:= txt
override EXTN_LINT			:= $(subst ~,,$(subst ~.,,$(addprefix ~,$(COMPOSER_EXT_DEFAULT)))).$(EXTN_TEXT)

ifeq ($(TYPE),$(TYPE_HTML))
override OUTPUT				:= html5
override EXTENSION			:= $(EXTN_HTML)
else ifeq ($(TYPE),$(TYPE_LPDF))
override OUTPUT				:= latex
override EXTENSION			:= $(EXTN_LPDF)
else ifeq ($(TYPE),$(TYPE_PRES))
override OUTPUT				:= $(TYPE_PRES)
override EXTENSION			:= $(EXTN_PRES)
else ifeq ($(TYPE),$(TYPE_EPUB))
override OUTPUT				:= epub3
override EXTENSION			:= $(EXTN_EPUB)
else ifeq ($(TYPE),$(TYPE_TEXT))
override OUTPUT				:= plain
override EXTENSION			:= $(EXTN_TEXT)
else ifeq ($(TYPE),$(TYPE_LINT))
override OUTPUT				:= $(TYPE_LINT)
override EXTENSION			:= $(EXTN_LINT)
endif

########################################

#> update: Pandoc Options: COMPOSER_TARGETS
#> update: COMPOSER_TARGETS.*strip
ifeq ($(COMPOSER_DIR),$(CURDIR))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(strip \
	$(BASE).$(EXTN_HTML) \
	$(BASE).$(EXTN_LPDF) \
	$(BASE).$(EXTN_PRES) \
	$(BASE).$(EXTN_DOCX) \
	$(BASE).$(EXTN_EPUB) \
	$(BASE).$(EXTN_TEXT) \
	$(BASE).$(EXTN_LINT) \
)
endif
endif

########################################

override _COL				:= $(NUMCOLUMN)
override _CSS				:= $(MDVIEWER_CSS)
#WORK css_alt = document!
ifeq ($(CSS),css_alt)
override _CSS				:= $(MDVIEWER_CSS_ALT)
else ifneq ($(wildcard $(CSS)),)
override _CSS				:= $(CSS)
else ifeq ($(OUTPUT),revealjs)
override _CSS				:= $(REVEALJS_CSS)
endif

########################################

#WORK document effects of $TOC and $LVL!
#WORK TODO OPTIONS
#	pandoc --from docx --to markdown --extract-media=README.markdown.files --track-changes=all --output=README.markdown README.docx ; vdiff README.md.txt README.markdown
#	--from "docx" --track-changes="all"
#	--from "docx|epub" --extract-media="[...]"
#WORK TODO OPTIONS
#	--default-image-extension="png"?
#	--highlight-style="kate"?
#	--incremental?
#WORK TODO OPTIONS
#	--include-in-header="[...]" --include-before-body="[...]" --include-after-body="[...]"
#	--email-obfuscation="[...]"
#	--epub-metadata="[...]" --epub-cover-image="[...]" --epub-embed-font="[...]"
#WORK add a way to add additional arguments, like: --variable=fontsize=28pt
#	--variable="fontsize=[...]"
#	--variable="theme=[...]"
#	--variable="transition=[...]"
#	--variable="links-as-notes=[...]"
#	--variable="lof=[...]"
#	--variable="lot=[...]"
#WORK TODO OPTIONS
#	http://10.255.255.254/zactive/coding/composer/Pandoc_Manual.html#fenced-code-blocks
#	implicit_header_references
#	fenced_code_attributes
#WORK TODO OPTIONS
#	--chapters has been removed. Use --top-level-division=chapter instead.
#	--epub-stylesheet has been removed. Use --css instead.
#	--latex-engine has been removed.  Use --pdf-engine instead.
#	--normalize has been removed.  Normalization is now automatic.
#	--smart/-S has been removed.  Use +smart or -smart extension instead.
#WORK TODO OPTIONS
override PANDOC_EXTENSIONS		:= +smart
override PANDOC_OPTIONS			:= $(strip \
	\
	--self-contained \
	--standalone \
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
	--variable="geometry=margin=$(MGN)" \
	--variable="fontsize=$(FNT)" \
	--variable="revealjs-url=$(REVEALJS_DIR)" \
	\
	--listings \
	\
	$(OPT) \
	$(LIST) \
)

#WORK	--latex-engine="$(PANDOC_TEX_PDF)" => https://github.com/wkhtmltopdf/wkhtmltopdf
#WORK latex and geometry options
#>	--latex-engine="$(PANDOC_TEX_PDF)" \
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

#WORK think about this...
#> update: $(EXAMPLE):

#WORK bootstrap!
#WORK need some default content for TESTING... actually, TESTING should already have this...
#WORK realpath --relative-to /tmp ./

# override SITE_SOURCE			?= $(COMPOSER_ROOT)
# override SITE_OUTPUT			?= $(COMPOSER_ROOT)/_site
# override SITE_SEARCH			?= 1

# override SITE_TITLE			?= $(COMPOSER_FULLNAME): Hexo
# override SITE_SUBTITLE			?= a simple proof of concept
# override SITE_DESCRIPTION		?= a brief summary
# override SITE_EXCERPT			?= Please expand on that...
# override SITE_AUTHOR			?= Gary B. Genett
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

#WORK http://jr0cket.co.uk/hexo/
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
# }}}1
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

#WORK gitignore better headers/formatting?
#WORK review list!  SETTINGS and BASENAME should match everywhere...
#WORK	and then we need a new filename for adding per-release test & debug files into the repository?

override define HEREDOC_DISTRIB_GITIGNORE =
# $(COMPOSER_BASENAME)
/$(COMPOSER_BASENAME)*
/$(COMPOSER_SETTINGS)
/$(COMPOSER_CSS)
/$(COMPOSER_STAMP)

# $(UPGRADE)
$(subst $(COMPOSER_DIR),,$(COMPOSER_PKG))/

# $(TESTING)
$(subst $(COMPOSER_DIR),,$(TESTING_DIR))/
endef

################################################################################
# {{{1 Heredoc: revealjs_css ---------------------------------------------------
################################################################################

override define HEREDOC_DISTRIB_REVEALJS_CSS =
@import url("../$(REVEALJS_CSS_THEME)");

body {
	background-image:	url("./screenshot.png");
	background-repeat:	no-repeat;
	background-position:	98% 2%;
	background-size:	auto 20%;
}

.reveal h1 {
	font-size:	160%;
}
.reveal h2 {
	font-size:	140%;
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

################################################################################
# {{{1 Heredoc: license --------------------------------------------------------
################################################################################

#WORKING

#WORK replace license and readme with help/license output
#WORK should the README be broken up into sections throughout the Makefile anyway?
#WORK add some sort of composer_readme variable, like composer_escapes or *_debugit, so that targets like "check" can be pulled in, also...
#WORK	the 'grep -vE "^[#]"' technique should work fine...?

#WORKING format and update license

override define HEREDOC_DISTRIB_LICENSE =
Composer CMS License
========================================================================

License Source
------------------------------------

  * [http://opensource.org/licenses/BSD-3-Clause](http://opensource.org/licenses/BSD-3-Clause)

Copyright
------------------------------------

    Copyright (c) 2014, Gary B. Genett
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

#WORKING format and update readme

override define HEREDOC_DISTRIB_README =
% Composer CMS: User Guide & Example File
% Gary B. Genett
% $(COMPOSER_VERSION) ($(DATESTAMP))

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
	HELP_TITLE_Usage \
	HELP_USAGE \
	HELP_VARIABLES_FORMAT_1 \
	HELP_TARGETS_MAIN_1 \
	HELP_COMMANDS_1 \
	HELP_FOOTER

#WORKING:NOW
#	HELP_TITLE_Help \
#	HELP_USAGE \
#	HELP_VARIABLES_TITLE_1 \
#	HELP_VARIABLES_FORMAT_2 \

.PHONY: $(HELPALL)
ifneq ($(MAKECMDGOALS),$(filter-out $(HELPALL),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(HELPALL): \
	HELP_VARIABLES_CONTROL_2 \
	HELP_TARGETS_TITLE_1 \
	HELP_TARGETS_MAIN_2 \
	HELP_TARGETS_ADDITIONAL_2 \
	HELP_TARGETS_SUBTARGET_2 \

#	HELP_COMMANDS_1 \
#	EXAMPLE_MAKEFILES \
#	HELP_SYSTEM \
#	EXAMPLE_MAKEFILE \
#	HELP_FOOTER

#>.PHONY: HELP_TITLE_%
HELP_TITLE_%:
	@$(call TITLE_LN,0,$(COMPOSER_FULLNAME) $(DIVIDE) $(*))

.PHONY: HELP_USAGE
HELP_USAGE:
	@$(PRINT) '$(CODEBLOCK)$(_C)RUNMAKE$(_D) := $(_E)$(RUNMAKE)'
	@$(PRINT) '$(CODEBLOCK)$(_C)COMPOSE$(_D) := $(_E)$(COMPOSE)'
	@$(PRINT) "$(CODEBLOCK)$(_M)$(~)RUNMAKE [variables] <filename>.<extension>"
	@$(PRINT) "$(CODEBLOCK)$(_M)$(~)COMPOSE [variables]"

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(ENDOLINE)
	@$(LINERULE)
	@$(PRINT) "*$(_H)Happy Making!$(_D)*"

########################################
# {{{3 HELP_VARIABLES ------------------

#>.PHONY: HELP_VARIABLES_TITLE_%
HELP_VARIABLES_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Variables,$(HEAD_MAIN))

#>.PHONY: HELP_VARIABLES_FORMAT_%
HELP_VARIABLES_FORMAT_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Formatting Variables); fi
	@$(TABLE_M3) "$(_H)Variable"				"$(_H)Purpose"				"$(_H)Value"
	@$(TABLE_M3) ":---"					":---"					":---"
	@$(TABLE_M3) "$(_C)TYPE $(_E)(T, c_type)"		"Desired output format"			"$(_M)$(TYPE)"
	@$(TABLE_M3) "$(_C)BASE $(_E)(B, c_base)"		"Base of output file"			"$(_M)$(BASE)"
	@$(TABLE_M3) "$(_C)LIST $(_E)(L, c_list)"		"List of input files(s)"		"$(_M)$(LIST)"
	@$(TABLE_M3) "$(_C)CSS $(_E)(s, c_css)"			"Location of CSS file"			"$(if $(CSS),$(_M)$(CSS) )$(_N)($(COMPOSER_CSS))"
	@$(TABLE_M3) "$(_C)TTL $(_E)(t, c_title)"		"Document title prefix"			"$(_M)$(TTL)"
	@$(TABLE_M3) "$(_C)TOC $(_E)(c, c_contents)"		"Table of contents depth"		"$(_M)$(TOC)"
	@$(TABLE_M3) "$(_C)LVL $(_E)(l, c_level)"		"Chapter/slide header level"		"$(_M)$(LVL)"
#WORK are MGN and FNT only for PDF?
	@$(TABLE_M3) "$(_C)MGN $(_E)(m, c_margin)"		"Margin size [$(_C)$(TYPE_LPDF)$(_D)]"	"$(_M)$(MGN)"
	@$(TABLE_M3) "$(_C)FNT $(_E)(f, c_font)"		"Font size [$(_C)$(TYPE_LPDF)$(_D)]"	"$(_M)$(FNT)"
	@$(TABLE_M3) "$(_C)OPT $(_E)(o, c_options)"		"Custom Pandoc options"			"$(_M)$(OPT)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Defined $(_C)TYPE$(_H) Values"	"$(_H)Format"				"$(_H)Extension"
	@$(TABLE_M3) ":---"					":---"					":---"
	@$(TABLE_M3) "$(_C)$(TYPE_HTML)"			"$(HTML_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_HTML)"
	@$(TABLE_M3) "$(_C)$(TYPE_LPDF)"			"$(LPDF_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_LPDF)"
	@$(TABLE_M3) "$(_C)$(TYPE_PRES)"			"$(PRES_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_PRES)"
	@$(TABLE_M3) "$(_C)$(TYPE_DOCX)"			"$(DOCX_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_DOCX)"
	@$(TABLE_M3) "$(_C)$(TYPE_EPUB)"			"$(EPUB_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_EPUB)"
	@$(TABLE_M3) "$(_C)$(TYPE_TEXT)"			"$(TEXT_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_TEXT)"
	@$(TABLE_M3) "$(_C)$(TYPE_LINT)"			"$(LINT_DESC)"				"$(_N)*$(_D).$(_E)$(EXTN_LINT)"
	@$(ENDOLINE)
#WORK need to experiment with TYPE pass-through, or else just call it unsupported...
	@$(PRINT) "  * *Other $(_C)TYPE$(_D) values will be passed directly to Pandoc*"

#>.PHONY: HELP_VARIABLES_CONTROL_%
HELP_VARIABLES_CONTROL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Control Variables); fi
	@$(TABLE_M3) "$(_H)Variable"		"$(_H)Purpose"					"$(_H)Value"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)MAKEJOBS"		"Parallel processing threads"			"$(if $(MAKEJOBS),$(_M)$(MAKEJOBS) )$(_N)(makejobs)"
	@$(TABLE_M3) "$(_C)COMPOSER_DEBUGIT"	"Use verbose output"				"$(if $(COMPOSER_DEBUGIT),$(_M)$(COMPOSER_DEBUGIT) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_INCLUDE"	"Include all: $(_C)$(COMPOSER_SETTINGS)"	"$(if $(COMPOSER_INCLUDE),$(_M)$(COMPOSER_INCLUDE) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_ESCAPES"	"Enable title/color sequences"			"$(if $(COMPOSER_ESCAPES),$(_M)$(COMPOSER_ESCAPES) )$(_N)(boolean)"
	@$(TABLE_M3) "$(_C)COMPOSER_STAMP"	"Timestamp file"				"$(if $(COMPOSER_STAMP),$(_M)$(COMPOSER_STAMP))"
	@$(TABLE_M3) "$(_C)COMPOSER_EXT"	"Markdown file extension"			"$(if $(COMPOSER_EXT),$(_M)$(COMPOSER_EXT))"
	@$(TABLE_M3) "$(_C)COMPOSER_TARGETS"	"Target list: $(_C)$(DOITALL)"			"$(if $(COMPOSER_TARGETS),$(_M)$(COMPOSER_TARGETS))"
	@$(TABLE_M3) "$(_C)COMPOSER_SUBDIRS"	"Directories list: $(_C)$(DOITALL)"		"$(if $(COMPOSER_SUBDIRS),$(_M)$(COMPOSER_SUBDIRS))"
	@$(TABLE_M3) "$(_C)COMPOSER_DEPENDS"	"Sub-directories first: $(_C)$(DOITALL)"	"$(if $(COMPOSER_DEPENDS),$(_M)$(COMPOSER_DEPENDS) )$(_N)(boolean)"
	@$(ENDOLINE)
	@$(PRINT) "  * *$(_C)MAKEJOBS$(_D) ~= $(_E)(J, c_jobs)$(_D)*"
	@$(PRINT) "  * *$(_C)COMPOSER_DEBUGIT$(_D) ~= $(_E)(V, c_debug)$(_D)*"
	@$(PRINT) "  * *$(_C)COMPOSER_ESCAPES$(_D) ~= $(_E)(C, c_color)$(_D)*"
	@$(PRINT) "  * *$(_N)(makejobs)$(_D) = empty value disables / number of threads / 0 is no limit*"
	@$(PRINT) "  * *$(_N)(boolean)$(_D) = empty value disables / any value enables*"

########################################
# {{{3 HELP_TARGETS --------------------

#>.PHONY: HELP_TARGETS_TITLE_%
HELP_TARGETS_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Targets,$(HEAD_MAIN))

#WORKING:NOW

#>.PHONY: HELP_TARGETS_MAIN_%
HELP_TARGETS_MAIN_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Primary Targets); fi
	@$(TABLE_M2) "$(_H)Target"		"$(_H)Purpose"
	@$(TABLE_M2) ":---"			":---"
	@$(TABLE_M2) "$(_C)$(HELPOUT)"		"Basic help output $(_N)(default)"
	@$(TABLE_M2) "$(_C)$(HELPALL)"		"Complete help output"
#WORK	$(CREATOR)
	@$(TABLE_M2) "$(_C)$(EXAMPLE)"		"Print settings template: $(_C)$(COMPOSER_SETTINGS)"
#WORK	[.]$(EXAMPLE)*
	@$(TABLE_M2) "$(_C)$(COMPOSER_TARGET)"	"Document creation $(_N)(see: $(_C)usage$(_N))"
#WORK	$(COMPOSER_PANDOC)
#WORK document install-all / cleaner-all / all-all
	@$(TABLE_M2) "$(_C)$(INSTALL)"		"Recursive directory initialization: $(_C)$(MAKEFILE)"
	@$(TABLE_M2) "$(_C)$(CLEANER)"		"Remove output files: $(_C)COMPOSER_TARGETS$(_D) $(_E)$(DIVIDE)$(_D) $(_N)*$(_C)-$(CLEANER)"
#WORK not recursive
	@$(TABLE_M2) "$(_C)$(DOITALL)"		"Recursive run of directory tree: $(_C)$(MAKEFILE)"
	@$(TABLE_M2) "$(_C)$(PRINTER)"		"List updated files: $(_N)*$(_C)$(COMPOSER_EXT)$(_D) $(_E)$(MARKER)$(_D) $(_C)$(COMPOSER_STAMP)"

#>.PHONY: HELP_TARGETS_ADDITIONAL_%
HELP_TARGETS_ADDITIONAL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Additional Targets); fi
#WORKING
	@$(TABLE_M2) "$(_C)$(DEBUGIT)"		"Runs several key sub-targets and commands, to provide all helpful information in one place"
	@$(TABLE_M2) "$(_C)$(TARGETS)"		"Parse for all potential targets (for verification and/or troubleshooting): $(_C)$(MAKEFILE)"
	@$(TABLE_M2) "$(_C)$(TESTING)"		"Build example/test directory using all features and test/validate success"
	@$(TABLE_M2) "$(_C)$(UPGRADE)"		"Download/update all 3rd party components (need to do this at least once)"

#WORKING grep "^([#][>])?[.]PHONY[:]" Makefile

#>.PHONY: HELP_TARGETS_SUBTARGET_%
HELP_TARGETS_SUBTARGET_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Target Dependencies); fi
	@$(PRINT) "These are all the rest of the sub-targets used by the main targets above:"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Dynamic"		"-"						"-"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)$(CLEANER)"		"$(_E)$(~)(COMPOSER_TARGETS)-$(CLEANER)"	"$(_M)$(addsuffix -$(CLEANER),$(COMPOSER_TARGETS))"
	@$(TABLE_M3) "$(_C)$(DOITALL)"		"$(_E)$(~)(COMPOSER_TARGETS)"			"$(_M)$(COMPOSER_TARGETS)"
	@$(TABLE_M3) "$(_C)$(SUBDIRS)"		"$(_E)$(~)(COMPOSER_SUBDIRS)"			"$(_M)$(COMPOSER_SUBDIRS)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Hidden"		"-"						"-"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)$(_N)%"		"$(_E).set_title-$(_N)*"			"Set window title to current target using escape sequence"
	@$(TABLE_M3) "$(_C)$(DEBUGIT)"		"$(_E)$(MAKE_DB)"				"Output internal Make database, based on current: $(_C)$(MAKEFILE)"
	@$(TABLE_M3) "$(_C)$(TARGETS)"		"$(_E)$(LISTING)"				"Dynamically parse and print all potential targets"
	@$(TABLE_M3) "$(_C)$(EXAMPLE)"		"$(_E).$(EXAMPLE){-$(INSTALL)}"			"Prints raw template, with escape sequences"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Static"		"-"						"-"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)$(COMPOSER_TARGET)"	"$(_E)$(COMPOSER_PANDOC)"			"Wrapper target which calls Pandoc directly"
	@$(TABLE_M3) "$(_E)$(COMPOSER_PANDOC)"	"$(_E)$(SETTING)-$(_N)%"			"Prints marker and variable values, for readability"
	@$(TABLE_M3) "$(_C)$(DOITALL)"		"$(_E)$(WHOWHAT)-$(_N)%"			"Prints marker and variable values, for readability"
	@$(TABLE_M3) ""				"$(_E)$(SUBDIRS)"				"Aggregates/runs the targets: $(_C)COMPOSER_SUBDIRS"
	@$(ENDOLINE)
	@$(PRINT) "These do not need to be used directly during normal use, and are only documented for completeness."
	@$(ENDOLINE)

########################################
# {{{3 HELP_* --------------------------

#>.PHONY: HELP_COMMANDS_%
HELP_COMMANDS_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Command Examples); fi
#WORK clean up HELP_COMMANDS section
#WORK add "make all COMPOSER_TARGETS=[...]" example
	@$(TABLE_C2) "$(_E)Have the system do all the work:"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_M)make $(BASE).$(EXTENSION)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_E)Be clear about what is wanted (or, for multiple or differently named input files):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_M)make compose TYPE=\"$(TYPE)\" BASE=\"$(EXAMPLE_OUT)\" LIST=\"$(EXAMPLE_ONE)$(COMPOSER_EXT) $(EXAMPLE_TWO)$(COMPOSER_EXT)\""

.PHONY: HELP_SYSTEM
HELP_SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
HELP_SYSTEM:
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
# {{{3 EXAMPLE_* -----------------------

.PHONY: EXAMPLE_MAKEFILES
EXAMPLE_MAKEFILES: \
	EXAMPLE_MAKEFILES_HEADER \
	EXAMPLE_MAKEFILE_1 \
	EXAMPLE_MAKEFILE_2 \
	EXAMPLE_MAKEFILES_FOOTER

.PHONY: EXAMPLE_MAKEFILE
EXAMPLE_MAKEFILE: \
	EXAMPLE_MAKEFILE_HEADER \
	EXAMPLE_MAKEFILE_FULL \
	EXAMPLE_MAKEFILE_TEMPLATE

########################################
# {{{3 EXAMPLE_MAKEFILES ---------------

.PHONY: EXAMPLE_MAKEFILES_HEADER
EXAMPLE_MAKEFILES_HEADER:
	@$(HEADER_L)
	@$(ENDOLINE)
	@$(PRINT) "$(_H)Calling from children '$(MAKEFILE)' files:"
	@$(ENDOLINE)

.PHONY: EXAMPLE_MAKEFILE_1
EXAMPLE_MAKEFILE_1:
	@$(TABLE_C2) "$(_E)Simple, with filename targets and \"automagic\" detection of them:"
	@$(TABLE_C2) "$(_S)include $(COMPOSER)"
	@$(PRINT) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TGT)"
	@$(PRINT) "$(_C)$(BASE)$(_D): $(_N)# so \"$(CLEANER)\" will catch the below files"
	@$(PRINT) "$(_C)$(EXAMPLE_TGT)$(_D): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@$(PRINT) "$(_C)$(EXAMPLE_TWO).$(EXTENSION)$(_D):"
	@$(ENDOLINE)

.PHONY: EXAMPLE_MAKEFILE_2
EXAMPLE_MAKEFILE_2:
	@$(TABLE_C2) "$(_E)Advanced, with manual enumeration of user-defined targets and per-target variables:"
	@$(PRINT) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE) $(EXAMPLE_TGT) $(EXAMPLE_TWO).$(EXTENSION)"
	@$(TABLE_C2) "$(_S)include $(COMPOSER)"
	@$(PRINT) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TGT)"
	@$(PRINT) "$(_C)$(BASE)$(_D): export TOC := 1"
	@$(PRINT) "$(_C)$(BASE)$(_D): $(BASE).$(EXTENSION)"
	@$(PRINT) "$(_C)$(EXAMPLE_TGT)$(_D): $(BASE)$(COMPOSER_EXT) $(EXAMPLE_TWO)$(COMPOSER_EXT)"
	@$(PRINT) "	$(~)(COMPOSE) LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUT)\" TYPE=\"$(TYPE_HTML)\""
	@$(PRINT) "	$(~)(COMPOSE) LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUT)\" TYPE=\"$(TYPE_LPDF)\""
	@$(PRINT) "$(_C)$(EXAMPLE_TGT)-$(CLEANER)$(_D):"
	@$(PRINT) "	$(~)(RM) $(EXAMPLE_OUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@$(ECHO) "#WORK document this version of '$(CLEANER)'?\n"
	@$(ECHO) "#WORK 2017-07-31 : nope, this should be $(CLEANER): $(notdir $(COMPOSER_MAN))-clean, and skip the TYPE business\n"
	@$(ECHO) "#WORK make $(RELEASE)-debug\n"
	@$(PRINT) "$(_C)$(CLEANER)$(_D): COMPOSER_TARGETS += $(notdir $(COMPOSER_MAN))"
	@$(PRINT) "$(_C)$(CLEANER)$(_D): TYPE := latex"
	@$(PRINT) "$(_C)$(notdir $(COMPOSER_MAN)):"
	@$(PRINT) "	$(~)(CP) \"$(COMPOSER_DIR)/$(notdir $(COMPOSER_MAN)).\"* ./"
	@$(ENDOLINE)

.PHONY: EXAMPLE_MAKEFILES_FOOTER
EXAMPLE_MAKEFILES_FOOTER:
	@$(TABLE_C2) "$(_E)Then, from the command line:"
	@$(PRINT) "$(_M)make $(CLEANER) && make $(DOITALL)"
	@$(ENDOLINE)

########################################
# {{{3 EXAMPLE_MAKEFILE ----------------

.PHONY: EXAMPLE_MAKEFILE_HEADER
EXAMPLE_MAKEFILE_HEADER:
	@$(HEADER_L)
	@$(ENDOLINE)
	@$(PRINT) "$(_H)Finally, a completely recursive '$(MAKEFILE)' example:"
	@$(ENDOLINE)

.PHONY: EXAMPLE_MAKEFILE_FULL
EXAMPLE_MAKEFILE_FULL: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
EXAMPLE_MAKEFILE_FULL:
	@$(TABLE_C2) "$(_H)$(MARKER) HEADERS"
	@$(TABLE_C2) "$(_E)These two statements must be at the top of every file:"
	@$(TABLE_C2) "$(_N)(NOTE: The 'COMPOSER_TEACHER' variable can be modified for custom chaining, but with care.)"
	@$(PRINT) "override $(_C)COMPOSER_MY_PATH$(_D) := $(_C)$(COMPOSER_MY_PATH)"
	@$(PRINT) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(COMPOSER_TEACHER)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_H)$(MARKER) DEFINITIONS"
	@$(TABLE_C2) "$(_E)These statements are also required:"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Use '?=' declarations and define *before* the upstream 'include' statement"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* They pass their values *up* the '$(MAKEFILE)' chain"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Should always be defined, even if empty, to prevent downward propagation of values"
	@$(TABLE_C2) "$(_N)(NOTE: List of '$(DOITALL)' targets is '$(COMPOSER_REGEX)' if '$(~)(COMPOSER_TARGETS)' is empty.)"
	@$(PRINT) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE).$(EXTENSION) $(EXAMPLE_TWO).$(EXTENSION)"
	@$(PRINT) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(PRINT) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_H)$(MARKER) VARIABLES"
	@$(TABLE_C2) "$(_E)The option variables are not required, but are available for locally-scoped configuration:"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* For proper inheritance, use '?=' declarations and define *before* the upstream 'include' statement"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* They pass their values *down* the '$(MAKEFILE)' chain"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Do not need to be defined when empty, unless necessary to override upstream values"
	@$(TABLE_C2) "$(_E)To disable inheritance and/or insulate from environment variables:"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Replace 'override VAR ?=' with 'override VAR :='"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Define *after* the upstream 'include' statement"
	@$(TABLE_C2) "$(_N)(NOTE: Any settings here will apply to all children, unless 'override' is used downstream.)"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)Define the CSS template to use in this entire directory tree:"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Absolute path names should be used, so that children will be able to find it"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)$(CODEBLOCK)* The 'COMPOSER_MY_PATH' variable can be used to simplify this"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* If not defined, the lowest-level '$(COMPOSER_CSS)' file will be used"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* If not defined, and no '$(COMPOSER_CSS)' file can be found, will use default CSS file"
	@$(PRINT) "$(~)(eval override $(_C)CSS$(_D) ?= $(_C)$(~)(COMPOSER_MY_PATH)/$(COMPOSER_CSS)$(_D))"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)All the other optional variables can also be made global in this directory scope:"
	@$(PRINT) "override $(_C)TTL$(_D) ?="
	@$(PRINT) "override $(_C)TOC$(_D) ?= $(_C)2"
	@$(PRINT) "override $(_C)LVL$(_D) ?= $(_C)$(LVL)"
	@$(PRINT) "override $(_C)MGN$(_D) ?= $(_C)$(MGN)"
	@$(PRINT) "override $(_C)FNT$(_D) ?= $(_C)$(FNT)"
	@$(PRINT) "override $(_C)OPT$(_D) ?="
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_H)$(MARKER) INCLUDE"
	@$(TABLE_C2) "$(_E)Necessary include statement:"
	@$(TABLE_C2) "$(_N)(NOTE: This must be after all references to 'COMPOSER_MY_PATH' but before '.DEFAULT_GOAL'.)"
	@$(PRINT) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)For recursion to work, a default target needs to be defined:"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* Needs to be '$(DOITALL)' for directories which must recurse into sub-directories"
	@$(TABLE_C2) "$(_E)$(CODEBLOCK)* The '$(SUBDIRS)' target can be used manually, if desired, so this can be changed to another value"
	@$(TABLE_C2) "$(_N)(NOTE: Recursion will cease if not '$(DOITALL)', unless '$(SUBDIRS)' target is called.)"
	@$(PRINT) "$(_C).DEFAULT_GOAL$(_D) := $(_C)$(DOITALL)"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_H)$(MARKER) RECURSION"
	@$(TABLE_C2) "$(_E)Dependencies can be specified, if needed:"
	@$(TABLE_C2) "$(_N)(NOTE: This defines the sub-directories which must be built before '$(firstword $(COMPOSER_SUBDIRS))'.)"
	@$(TABLE_C2) "$(_N)(NOTE: For parent/child directory dependencies, set 'COMPOSER_DEPENDS' to a non-empty value.)"
	@$(PRINT) "$(_C)$(firstword $(COMPOSER_SUBDIRS))$(_D): $(_C)$(wordlist 2,$(words $(COMPOSER_SUBDIRS)),$(COMPOSER_SUBDIRS))"
	@$(ENDOLINE)
	@$(TABLE_C2) "$(_H)$(MARKER) MAKEFILE"
	@$(TABLE_C2) "$(_E)This is where the rest of the file should be defined."
	@$(TABLE_C2) "$(_N)(NOTE: In this example, 'COMPOSER_TARGETS' is used completely in lieu of any explicit targets.)"
	@$(ENDOLINE)

.PHONY: EXAMPLE_MAKEFILE_TEMPLATE
EXAMPLE_MAKEFILE_TEMPLATE:
	@$(HEADER_L)
	@$(ENDOLINE)
	@$(PRINT) "$(_H)With the current settings, the output of '$(EXAMPLE)' would be:"
	@$(ENDOLINE)
	@$(RUNMAKE) --silent .$(EXAMPLE)
	@$(ENDOLINE)

########################################
# {{{2 $(CREATOR) ----------------------

#WORKING

.PHONY: $(CREATOR)
ifneq ($(MAKECMDGOALS),$(filter-out $(CREATOR),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(CREATOR):
#WORKING
	@$(PRINT) "#WORKING CREATING DOCUMENTATION"

########################################
# {{{2 $(EXAMPLE) ----------------------

#> update: $(EXAMPLE):

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .$(EXAMPLE)

.PHONY: .$(EXAMPLE)-$(INSTALL)
.$(EXAMPLE)-$(INSTALL):
	@$(if $(COMPOSER_ESCAPES),,$(call TITLE_LN,6,$(_H)$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)))
	@$(call EXAMPLE_VAR_STATIC,,COMPOSER_MY_PATH)
	@$(call EXAMPLE_VAR_STATIC,,COMPOSER_TEACHER)
	@$(call EXAMPLE_PRINT,,include $(_E)$(~)(COMPOSER_TEACHER))
	@$(call EXAMPLE_PRINT,,$(_E).DEFAULT_GOAL$(_D) := $(_N)$(DOITALL))

#WORKING document that COMPOSER_TARGETS and COMPOSER_SUBDIRS will always auto-detect unless they are defined or ".null"
#WORKING what are the implications of DEFAULT_GOAL?  we should probably remove it in all cases... this is what COMPOSER_TARGETS is for...

.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(if $(COMPOSER_ESCAPES),,$(call TITLE_LN,6,$(_H)$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)))
#>	@$(call EXAMPLE_VAR,1,MAKEJOBS)
#>	@$(call EXAMPLE_VAR,1,COMPOSER_DEBUGIT)
	@$(call EXAMPLE_VAR,1,COMPOSER_INCLUDE)
	@$(call EXAMPLE_VAR,1,COMPOSER_DEPENDS)	#>
#>	@$(call EXAMPLE_VAR,1,COMPOSER_ESCAPES)
	@$(call EXAMPLE_VAR,1,COMPOSER_TARGETS)
	@$(call EXAMPLE_VAR,1,COMPOSER_SUBDIRS)
#>	@$(call EXAMPLE_VAR,1,COMPOSER_DEPENDS)
#>	@$(call EXAMPLE_VAR,1,CSS)
#>	@$(call EXAMPLE_VAR,1,TTL)
	@$(call EXAMPLE_VAR,1,TOC)
	@$(call EXAMPLE_VAR,1,LVL)
	@$(call EXAMPLE_VAR,1,MGN)
	@$(call EXAMPLE_VAR,1,FNT)
	@$(call EXAMPLE_VAR,1,OPT)
#>	@$(call EXAMPLE_PRINT,1,$(_E).DEFAULT_GOAL$(_D) := $(_M)$(DOITALL))

override define EXAMPLE_PRINT =
	$(PRINT) "$(if $(COMPOSER_ESCAPES),$(CODEBLOCK))$(if $(1),$(COMMENTED))$(2)"
endef
override define EXAMPLE_VAR_STATIC =
	$(call EXAMPLE_PRINT,$(1),override $(_E)$(2)$(_D) :=$(if $($(2)), $(_N)$($(2))))
endef
override define EXAMPLE_VAR =
	$(call EXAMPLE_PRINT,$(1),override $(_C)$(2)$(_D) :=$(if $($(2)), $(_M)$($(2))))
endef

################################################################################
# }}}1
################################################################################
# {{{1 Composer Headers --------------------------------------------------------
################################################################################

########################################
# {{{2 .set_title ----------------------

#WORK should really "reset" the status line once we're done...

#> grep -E "[.]set_title" Makefile
#>.PHONY: .set_title-%:
.set_title-%:
ifneq ($(COMPOSER_ESCAPES),)
	@$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
else
	@$(ECHO) ""
endif

########################################
# {{{2 $(HEADERS) ----------------------

#>.PHONY: $(HEADERS)-%
$(HEADERS)-%:
	@$(call $(HEADERS),,$(*))

#>.PHONY: $(HEADERS)-run-%
$(HEADERS)-run-%:
	@$(call $(HEADERS)-run,,$(*))

override define $(HEADERS) =
	$(HEADER_L); \
	$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)";
	$(HEADER_L)
	$(TABLE_C2) "$(_E)MAKEFILE_LIST"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"; \
	$(TABLE_C2) "$(_E)COMPOSER_INCLUDES"	"[$(_N)$(COMPOSER_INCLUDES)$(_D)]"; \
	$(TABLE_C2) "$(_E)CURDIR"		"[$(_N)$(CURDIR)$(_D)]"; \
	$(TABLE_C2) "$(_E)MAKECMDGOALS"		"[$(_N)$(MAKECMDGOALS)$(_D)] ($(_M)$(strip $(if $(2),$(2),$(@)))$(_D))"; \
	$(foreach FILE,$(1),\
		$(TABLE_C2) "$(_C)$(FILE)"	"[$(_M)$($(FILE))$(_D)]"; \
	) \
	$(HEADER_L)
endef

override define $(HEADERS)-run =
	$(LINERULE); \
	$(TABLE_M2) "$(_H)$(COMPOSER_FULLNAME)"	"$(_N)$(COMPOSER)"; \
	$(TABLE_M2) ":---"			":---"; \
	$(TABLE_M2) "$(_E)MAKEFILE_LIST"	"$(_N)$(MAKEFILE_LIST)"; \
	$(TABLE_M2) "$(_E)COMPOSER_INCLUDES"	"$(_N)$(COMPOSER_INCLUDES)"; \
	$(TABLE_M2) "$(_E)CURDIR"		"$(_N)$(CURDIR)"; \
	$(TABLE_M2) "$(_E)MAKECMDGOALS"		"$(_N)$(MAKECMDGOALS)$(_D) ($(_M)$(strip $(if $(2),$(2),$(@)))$(_D))"; \
	$(foreach FILE,$(1),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$($(FILE))"; \
	) \
	$(LINERULE)
endef

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
	OPT \

override define $(HEADERS)-note =
	$(TABLE_M2) "$(_M)$(MARKER) NOTICE" "$(_N)$(CURDIR)$(_D) $(DIVIDE) [$(_C)$(@)$(_D)] $(_C)$(1)"
endef
override define $(HEADERS)-dir =
	$(TABLE_M2) "$(_C)$(MARKER) Directory" "$(_E)$(1)$(if $(2),$(_D) $(DIVIDE) $(_M)$(2))"
endef
override define $(HEADERS)-file =
	$(TABLE_M2) "$(_H)$(MARKER) Creating" "$(_N)$(1)$(if $(2),$(_D) $(DIVIDE) $(_M)$(2))"
endef
override define $(HEADERS)-skip =
	$(TABLE_M2) "$(_N)$(MARKER) Skipping" "$(_N)$(1)$(if $(2),$(_D) $(DIVIDE) $(_C)$(2))"
endef

########################################
# {{{2 $(WHOWHAT) ----------------------

#>.PHONY: $(WHOWHAT)-%
$(WHOWHAT)-%:
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-dir,$(CURDIR))
else
	@$(call $(HEADERS),\
		COMPOSER_INCLUDE \
		COMPOSER_TARGETS \
		COMPOSER_SUBDIRS \
		COMPOSER_DEPENDS \
		$($(HEADERS)-vars) \
		,$(*) \
	)
endif

########################################
# {{{2 $(SETTING) ----------------------

#>.PHONY: $(SETTING)-%
$(SETTING)-%:
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-file,$(CURDIR),$(BASE).$(EXTENSION))
else
	@$(call $(HEADERS)-run,\
		$($(HEADERS)-vars) \
		,$(*) \
	)
	@$(PRINT) '$(_C)$(MARKER) $(PANDOC) $(PANDOC_OPTIONS)'
endif

################################################################################
# {{{1 Global Targets ----------------------------------------------------------
################################################################################

########################################
# {{{2 .DEFAULT ------------------------

.DEFAULT_GOAL := $(HELPOUT)
.DEFAULT:
	@$(call $(HEADERS))
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) ERROR"
	@$(ENDOLINE)
	@$(PRINT) "  * $(_N)Target '$(_C)$(@)$(_N)' is not defined"
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) DETAILS"
	@$(ENDOLINE)
	@$(PRINT) "  * It is possible that this is the result of a missing input file"
	@$(PRINT) "  * New targets can be defined in '$(_C)$(COMPOSER_SETTINGS)$(_D)'"
	@$(PRINT) "  * Use '$(_M)$(TARGETS)$(_D)' to get a list of available targets for this '$(_C)$(MAKEFILE)$(_D)'"
	@$(PRINT) "  * Use '$(_M)$(HELPOUT)$(_D)' or '$(_M)$(HELPALL)$(_D)' for more information"
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

#WORK document that targets which start with $(COMPOSER_REGEX_PREFIX) are special and skipped by most detection (they are hidden)

.PHONY: $(LISTING)
$(LISTING):
	@$(RUNMAKE) --silent $(MAKE_DB) \
		| $(SED) -n -e "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" \
		| $(SED) -n -e "/^$(COMPOSER_REGEX_PREFIX)?$(COMPOSER_REGEX)[:]+/p" \
		| $(SORT)

########################################
# {{{2 $(NOTHING) ----------------------

#WORK document NOTHING! ...and COMPOSER_NOTHING?
#>override COMPOSER_NOTHING ?=

#>.PHONY: $(NOTHING)-%
$(NOTHING)-%:
	@$(RUNMAKE) --silent COMPOSER_NOTHING="$(*)" $(NOTHING)

.PHONY: $(NOTHING)
$(NOTHING):
	@$(call $(HEADERS)-note,$(COMPOSER_NOTHING))

################################################################################
# {{{1 Release Targets ---------------------------------------------------------
################################################################################

########################################
# {{{2 $(CONVICT) ----------------------

override CONVICT_GIT_OPTS		:= --verbose .$(subst $(COMPOSER_ROOT),,$(CURDIR))

$(eval override COMPOSER_DOITALL_$(CONVICT) ?=)
.PHONY: $(CONVICT)-$(DOITALL)
$(CONVICT)-$(DOITALL):
	@$(RUNMAKE) COMPOSER_DOITALL_$(CONVICT)="1" $(CONVICT)

.PHONY: $(CONVICT)
$(CONVICT): .set_title-$(CONVICT)
	@$(call $(HEADERS))
	$(call COMPOSER_GIT_RUN,add --all $(CONVICT_GIT_OPTS))
	$(call COMPOSER_GIT_RUN,commit \
		$(if $(COMPOSER_DOITALL_$(CONVICT)),,--edit) \
		--message="[$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)]" \
		$(CONVICT_GIT_OPTS) \
	)

########################################
# {{{2 $(DISTRIB) ----------------------

.PHONY: $(DISTRIB)
$(DISTRIB): .set_title-$(DISTRIB)
	@$(call $(HEADERS))
	@if [ "$(COMPOSER)" !=						"$(CURDIR)/$(MAKEFILE)" ]; then \
		$(CP) $(COMPOSER)					$(CURDIR)/$(MAKEFILE); \
	fi
	@$(MKDIR)							$(CURDIR)/$(notdir $(COMPOSER_ART))
	@$(ECHO) "$(DIST_ICO)"		| $(BASE64) -d			>$(CURDIR)/$(notdir $(COMPOSER_ART))/icon.ico
	@$(ECHO) "$(DIST_ICON)"		| $(BASE64) -d			>$(CURDIR)/$(notdir $(COMPOSER_ART))/icon.png
	@$(ECHO) "$(DIST_SCREENSHOT)"	| $(BASE64) -d			>$(CURDIR)/$(notdir $(COMPOSER_ART))/screenshot.png
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_GITIGNORE)			>$(CURDIR)/.gitignore
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_REVEALJS_CSS)		>$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_LICENSE)			>$(CURDIR)/LICENSE$(COMPOSER_EXT)
	@$(call DO_HEREDOC,HEREDOC_DISTRIB_README)			>$(CURDIR)/README$(COMPOSER_EXT)
	@$(CHMOD) $(CURDIR)/$(MAKEFILE)
#WORK	@$(RUNMAKE) $(UPGRADE)
	@$(RUNMAKE) $(CREATOR)
	@$(RUNMAKE) $(DOITALL)

########################################
# {{{2 $(UPGRADE) ----------------------

.PHONY: $(UPGRADE)
$(UPGRADE): .set_title-$(UPGRADE)
	@$(call $(HEADERS))
	@$(call GIT_REPO,$(PANDOC_DIR),$(PANDOC_SRC),$(PANDOC_CMT))
	@$(call GIT_REPO,$(REVEALJS_DIR),$(REVEALJS_SRC),$(REVEALJS_CMT))
	@$(call GIT_REPO,$(MDVIEWER_DIR),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
ifneq ($(wildcard $(NPM)),)
	@$(MKDIR) $(NPM_PKG)
	@$(LN) $(NPM_PKG)/node_modules		$(MDVIEWER_DIR)/
	@$(LN) $(MDVIEWER_DIR)/package.json	$(NPM_PKG)/
	@$(LN) $(MDVIEWER_DIR)/build		$(NPM_PKG)/
	@$(LN) $(MDVIEWER_DIR)/themes		$(NPM_PKG)/
	@$(LN) $(MDVIEWER_DIR)/themes		$(dir $(NPM_PKG))markdown-themes
	@cd $(MDVIEWER_DIR) && \
		$(NPM_RUN) install && \
		$(NPM_RUN) run-script build:mdc && \
		$(NPM_RUN) run-script build:remark && \
		$(NPM_RUN) run-script build:prism && \
		$(NPM_RUN) run-script build:themes
	@$(RM)					$(MDVIEWER_DIR)/node_modules
	@$(RM)					$(dir $(NPM_PKG))markdown-themes
endif
	@$(LN) $(MDVIEWER_DIR)/manifest.json $(MDVIEWER_DIR)/manifest.chrome.json
	@$(ECHO) "$(_C)"
	@$(LS) --color=never --directory \
		$(PANDOC_DIR)/data/templates \
		$(MDVIEWER_DIR)/manifest.firefox.json \
		$(MDVIEWER_DIR)/manifest.chrome.json \
		$(dir $(REVEALJS_DIR))$(REVEALJS_CSS_THEME)
	@$(ECHO) "$(_D)"

################################################################################
# {{{1 Debug Targets -----------------------------------------------------------
################################################################################

########################################
# {{{2 $(DEBUGIT) ----------------------

#> update: $(DEBUGIT):

#WORK document DEBUGIT-file

.PHONY: $(DEBUGIT)-file
$(DEBUGIT)-file: override DEBUGIT_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(DEBUGIT))
$(DEBUGIT)-file:
	@$(ECHO) "# $(VIM_OPTIONS)\n" >$(DEBUGIT_FILE)
	@$(RUNMAKE) COMPOSER_DEBUGIT="$(COMPOSER_DEBUGIT)" COMPOSER_ESCAPES= $(DEBUGIT) >>$(DEBUGIT_FILE) 2>&1
	@$(LS) $(DEBUGIT_FILE)

.PHONY: $(DEBUGIT)
ifneq ($(MAKECMDGOALS),$(filter-out $(DEBUGIT),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(DEBUGIT): .set_title-$(DEBUGIT)
$(DEBUGIT): $(HEADERS)-$(DEBUGIT)
$(DEBUGIT): $(DEBUGIT)-$(HEADERS)
$(DEBUGIT): $(CONFIGS)
$(DEBUGIT): $(DEBUGIT)-CHECKIT
$(DEBUGIT): $(DEBUGIT)-TARGETS
$(DEBUGIT): $(DEBUGIT)-COMPOSER_DEBUGIT
$(DEBUGIT): $(DEBUGIT)-MAKEFILE_LIST
$(DEBUGIT): $(DEBUGIT)-COMPOSER_INCLUDES
#>$(DEBUGIT): $(DEBUGIT)-TESTING
$(DEBUGIT): $(DEBUGIT)-LISTING
$(DEBUGIT): $(DEBUGIT)-MAKE_DB
$(DEBUGIT): $(DEBUGIT)-COMPOSER_DIR
$(DEBUGIT): $(DEBUGIT)-CURDIR
$(DEBUGIT): HELP_FOOTER

.PHONY: $(DEBUGIT)-$(HEADERS)
$(DEBUGIT)-$(HEADERS):
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) DEBUG"
	@$(ENDOLINE)
	@$(PRINT) "  * $(_N)This is the output of the '$(_C)$(DEBUGIT)$(_N)' target"
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) DETAILS"
	@$(ENDOLINE)
	@$(PRINT) "  * It runs several targets and diagnostic commands"
	@$(PRINT) "  * All information needed for troubleshooting is included"
	@$(PRINT) "  * Use '$(_C)COMPOSER_DEBUGIT$(_D)' to test a list of targets $(_E)(they may be run)$(_D)"
	@$(LINERULE)

#WORK document COMPOSER_DEBUGIT="!" ...?  (just need to remember for myself... maybe $(TESTING) is enough?

#>.PHONY: $(DEBUGIT)-%
$(DEBUGIT)-%:
	@$(foreach FILE,$($(*)),\
		$(call TITLE_LN,1,$(MARKER)[ $(*) $(DIVIDE) $(FILE) ]$(MARKER) $(VIM_FOLDING)); \
		if [ "$(*)" = "COMPOSER_DEBUGIT" ]; then \
			$(RUNMAKE) --just-print COMPOSER_DEBUGIT="!" COMPOSER_ESCAPES= $(FILE) 2>&1; \
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

#> update: $(TESTING):

override TESTING_LOGFILE		:= .$(COMPOSER_BASENAME).$(INSTALL).log
override TESTING_COMPOSER_DIR		:= .$(COMPOSER_BASENAME)
override TESTING_COMPOSER_MAKEFILE	:= $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE)

#WORK document TESTING-file

.PHONY: $(TESTING)-file
$(TESTING)-file: override TESTING_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(TESTING))
$(TESTING)-file:
	@$(ECHO) "# $(VIM_OPTIONS)\n" >$(TESTING_FILE)
	@$(RUNMAKE) COMPOSER_ESCAPES= $(TESTING) >>$(TESTING_FILE) 2>&1
	@$(LS) $(TESTING_FILE)

.PHONY: $(TESTING)
ifneq ($(MAKECMDGOALS),$(filter-out $(TESTING),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(TESTING): .set_title-$(TESTING)
#WORK $(TESTING): $(HEADERS)-$(TESTING)
#WORK $(TESTING): $(TESTING)-$(HEADERS)
#WORK $(TESTING): $(CONFIGS)
#WORK $(TESTING): $(TESTING)-init
$(TESTING): $(TESTING)-$(COMPOSER_BASENAME)

#WORKING:NOW
#WORK $(TESTING): $(TESTING)-$(DISTRIB)
#WORK $(TESTING): $(TESTING)-$(INSTALL)
$(TESTING): $(TESTING)-use_case_template
$(TESTING): $(TESTING)-template

$(TESTING): HELP_FOOTER

########################################
# {{{3 $(TESTING)-$(HEADERS) -----------

.PHONY: $(TESTING)-$(HEADERS)
$(TESTING)-$(HEADERS):
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) TESTING"
	@$(ENDOLINE)
	@$(PRINT) "  * $(_N)This is the output of the '$(_C)$(TESTING)$(_N)' target"
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) DETAILS"
	@$(ENDOLINE)
	@$(PRINT) "  * #WORKING:NOW"
	@$(LINERULE)

.PHONY: $(TESTING)-init
$(TESTING)-init:
	@$(LINERULE)
#>	@$(RM) --recursive $(TESTING_DIR)
	@$(RM) --recursive $(TESTING_DIR)/*

override define TESTING_HEADER =
	$(call TITLE_LN,1,$(MARKER)[ $(@) ]$(MARKER) $(VIM_FOLDING)); \
	$(ECHO) "$(_M)$(MARKER) PURPOSE:$(_D) $(strip $(1))$(_D)\n"; \
	$(ECHO) "$(_M)$(MARKER) RESULTS:$(_D) $(strip $(2))$(_D)\n"; \
	if [ -z "$(1)" ]; then exit 1; fi; \
	if [ -z "$(2)" ]; then exit 1; fi; \
	$(ENDOLINE); \
	if [ "$(@)" != $(TESTING)-$(COMPOSER_BASENAME) ]; then \
		$(DIFF) $(COMPOSER) $(TESTING_COMPOSER_MAKEFILE); \
	fi
endef

override TESTING_PWD = $(TESTING_DIR)/$(subst -init,,$(subst -done,,$(if $(1),$(1),$(@))))
override TESTING_LOG = $(call TESTING_PWD,$(if $(1),$(1),$(@)))/$(TESTING_LOGFILE)
override TESTING_FIND = if [ -z "`$(SED) -n "/$(1)/p" $(call TESTING_LOG,$(if $(2),$(2),$(@)))`" ]; then exit 1; fi

override define TESTING_INIT =
	$(PRINT) "$(_M)$(MARKER) INIT:"; \
	$(MKDIR) $(TESTING_DIR)/$(if $(1),$(1),$(@)); \
	$(ECHO) "" >$(TESTING_DIR)/$(if $(1),$(1),$(@))/$(TESTING_LOGFILE); \
	$(ENV) $(RUNMAKE) $(@)-init 2>&1 | $(TEE) $(TESTING_DIR)/$(if $(1),$(1),$(@))/$(TESTING_LOGFILE); \
	if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
endef

override define TESTING_DONE =
	$(PRINT) "$(_M)$(MARKER) DONE:"; \
	$(ENV) $(RUNMAKE) $(@)-done 2>&1
endef

#WORKING keep TESTING_INIT_DIR?

override define TESTING_INIT_DIR =
	$(MKDIR) $(call TESTING_INIT_DIRS,$(subst -init,,$(@))); \
	$(foreach FILE,$(call TESTING_INIT_DIRS,$(subst -init,,$(@))),\
		$(CP) $(COMPOSER_DIR)/*$(COMPOSER_EXT) $(FILE)/; \
	)
	$(ENV) $(RUNMAKE) --directory $(TESTING_DIR)/$(subst -init,,$(@)) $(INSTALL)-$(DOITALL); \
endef

override define TESTING_INIT_DIRS =
	$(TESTING_DIR)/$(if $(1),$(1),$(@)) \
	$(foreach DIR,\
		subdir1 \
		subdir2 \
		subdir3 \
		,\
		$(foreach FILE,\
			example1 \
			example2 \
			example3 \
			,\
			$(TESTING_DIR)/$(if $(1),$(1),$(@))/$(DIR)/$(FILE) \
		)\
	)
endef

########################################
# {{{3 $(TESTING)-$(COMPOSER_BASENAME) -

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING)-$(COMPOSER_BASENAME):
	@$(call TESTING_HEADER,\
		Install the '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' directory ,\
		Top-level '$(_C)$(notdir $(TESTING_DIR))$(_D)' directory is ready for direct use \
	)
	@$(call TESTING_INIT,$(TESTING_COMPOSER_DIR))
	@$(ENDOLINE)
	@$(call TESTING_DONE,$(TESTING_COMPOSER_DIR))

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-init
$(TESTING)-$(COMPOSER_BASENAME)-init:
	@$(CP) $(COMPOSER) $(TESTING_COMPOSER_MAKEFILE)
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .$(EXAMPLE)-$(INSTALL) >$(TESTING_DIR)/$(MAKEFILE)
	@$(call $(INSTALL)-$(MAKEFILE)-$(COMPOSER_BASENAME),$(TESTING_DIR)/$(MAKEFILE),$(TESTING_COMPOSER_MAKEFILE))
	@$(ENV) $(REALMAKE) --silent --directory $(TESTING_DIR) COMPOSER_ESCAPES= .$(EXAMPLE) >$(TESTING_DIR)/$(COMPOSER_SETTINGS)
	@$(SED) -i \
		-e "s|^[#][[:space:]]+(override[[:space:]]+COMPOSER_TARGETS[[:space:]]+[:][=]).*$$|\1 $(NOTHING)|g" \
		-e "s|^[#][[:space:]]+(override[[:space:]]+COMPOSER_SUBDIRS[[:space:]]+[:][=]).*$$|\1 $(NOTHING)|g" \
		$(TESTING_DIR)/$(COMPOSER_SETTINGS)
	@$(ENDOLINE)
	@$(LS) $(COMPOSER) $(TESTING_DIR) $(call TESTING_PWD,$(TESTING_COMPOSER_DIR))
#>	@$(ENDOLINE)
	@$(CAT) $(TESTING_DIR)/$(MAKEFILE) $(TESTING_DIR)/$(COMPOSER_SETTINGS)
	@$(ENDOLINE)
	@$(ENV) $(REALMAKE) --directory $(TESTING_DIR) $(CONFIGS)
	@$(ENV) $(REALMAKE) --directory $(TESTING_DIR) $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-done
$(TESTING)-$(COMPOSER_BASENAME)-done:
	$(call TESTING_FIND,^override COMPOSER_TEACHER := .+$(TESTING_COMPOSER_DIR)/$(MAKEFILE)$$,$(TESTING_COMPOSER_DIR))
	$(call TESTING_FIND,NOTICE.+$(NOTHING).+$(DOITALL),$(TESTING_COMPOSER_DIR))
	$(call TESTING_FIND,NOTICE.+$(NOTHING).+$(SUBDIRS),$(TESTING_COMPOSER_DIR))

########################################
# {{{3 $(TESTING)-$(DISTRIB) -----------

.PHONY: $(TESTING)-$(DISTRIB)
$(TESTING)-$(DISTRIB):
	@$(call TESTING_HEADER,\
		Install/update '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' directory with '$(_C)$(DISTRIB)$(_D)' ,\
		Successful run; no specific validation \
	)
	@$(call TESTING_INIT)
	@$(ENDOLINE)
	@$(call TESTING_DONE)

.PHONY: $(TESTING)-$(DISTRIB)-init
$(TESTING)-$(DISTRIB)-init:
	@$(ENV) $(REALMAKE) --directory $(TESTING_DIR)/$(TESTING_COMPOSER_DIR) $(DISTRIB)

.PHONY: $(TESTING)-$(DISTRIB)-done
$(TESTING)-$(DISTRIB)-done:
	$(TRUE)

########################################
# {{{3 $(TESTING)-$(INSTALL) -----------

.PHONY: $(TESTING)-$(INSTALL)
$(TESTING)-$(INSTALL):
	@$(call TESTING_HEADER,\
		Test '$(_C)$(INSTALL)$(_D)' on a directory of random contents ,\
		\n\t 1. Verify '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' configuration \
		\n\t 2. Examine output to validate '$(_C)$(NOTHING)$(_D)' markers \
		\n\t 3. Parallel forced install \
		\n\t 4. Parallel build all [default target] \
		\n\t 5. Linear forced install \
		\n\t 6. Linear build all [default target] \
	)
	@$(call TESTING_INIT)
	@$(ENDOLINE)
	@$(call TESTING_DONE)

.PHONY: $(TESTING)-$(INSTALL)-init
$(TESTING)-$(INSTALL)-init:
	@$(RSYNC) $(PANDOC_DIR)/ $(call TESTING_PWD)
	@sleep 2; $(ENV) $(REALMAKE) --directory $(call TESTING_PWD) --makefile $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE) MAKEJOBS="0" $(INSTALL)-$(DOITALL)
	@$(ENV) $(REALMAKE) --silent --directory $(call TESTING_PWD) COMPOSER_ESCAPES= .$(EXAMPLE) >$(call TESTING_PWD)/$(COMPOSER_SETTINGS)
	@$(SED) -i \
		-e "s|^[#][[:space:]]+(override[[:space:]]+COMPOSER_SUBDIRS[[:space:]]+[:][=])(.*)($(TESTING))(.*)$$|\1\2\4|g" \
		$(call TESTING_PWD)/$(COMPOSER_SETTINGS)
	@sleep 2; $(ENV) $(REALMAKE) --directory $(call TESTING_PWD) MAKEJOBS="0" $(DOITALL)-$(DOITALL)
	@sleep 2; $(ENV) $(REALMAKE) --directory $(call TESTING_PWD) --makefile $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE) MAKEJOBS= $(INSTALL)-$(DOITALL)
	@$(ENV) $(REALMAKE) --silent --directory $(call TESTING_PWD) COMPOSER_ESCAPES= .$(EXAMPLE) >$(call TESTING_PWD)/$(COMPOSER_SETTINGS)
	@$(SED) -i \
		-e "s|^[#][[:space:]]+(override[[:space:]]+COMPOSER_SUBDIRS[[:space:]]+[:][=])(.*)($(TESTING))(.*)$$|\1\2\4|g" \
		$(call TESTING_PWD)/$(COMPOSER_SETTINGS)
	@sleep 2; $(ENV) $(REALMAKE) --directory $(call TESTING_PWD) MAKEJOBS= $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-$(INSTALL)-done
$(TESTING)-$(INSTALL)-done:
	@$(PRINT) "$(NOTHING)"

########################################
# {{{3 $(TESTING)-use_case_template ----

# {{{4 $(TESTING) #WORKING:NOW CASES ---

.PHONY: $(TESTING)-use_case_template
$(TESTING)-use_case_template:
	@$(call TESTING_HEADER,\
		#WORKING:NOW ,\
		#WORKING:NOW \
	)
	@$(call TESTING_INIT)
	@$(ENDOLINE)
	@$(call TESTING_DONE)

.PHONY: $(TESTING)-use_case_template-init
$(TESTING)-use_case_template-init:
	@$(PRINT) "$(NOTHING)"

.PHONY: $(TESTING)-use_case_template-done
$(TESTING)-use_case_template-done:
	@$(PRINT) "$(NOTHING)"

########################################
# {{{3 $(TESTING)-template -------------

.PHONY: $(TESTING)-template
$(TESTING)-template:
	@$(call TESTING_HEADER,\
		$(NOTHING) ,\
		$(NOTHING) \
	)
	@$(call TESTING_INIT)
	@$(ENDOLINE)
	@$(call TESTING_DONE)

.PHONY: $(TESTING)-template-init
$(TESTING)-template-init:
	@$(PRINT) "$(NOTHING)"

.PHONY: $(TESTING)-template-done
$(TESTING)-template-done:
	@$(PRINT) "$(NOTHING)"

#WORK
#	pull in EXAMPLE_* variables, from up by DEFAULT_TYPE?
#	COMPOSER_DEPENDS seems to work... test it with MAKEJOBS... https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html
#		/.g/_data/zactive/coding/composer/pandoc -> $(RUNMAKE) MAKEJOBS="8" COMPOSER_DEPENDS="1" $(DOITALL)-$(DOITALL) | grep pptx -> use a COMPOSER_SETTINGS target and COMPOSER_TARGETS to create a timestamp directory
#		add a note to documentation for "parent: child" targets, which establish a prerequisite dependency
#	for FILE in {999..1} ; do echo -en "\n.PHONY: test-${FILE}-clean\ntest-${FILE}-clean:\n\t@echo \$(@)\n" ; done
#	make TYPE="man" compose && man ./README.man
# review:
#	$(HELPOUT) -> COMPOSER_ESCAPES
#	$(HELPALL) -> COMPOSER_ESCAPES = .$(EXAMPLE)-$(INSTALL) .$(EXAMPLE)
#	$(DEBUGIT) -> $(CHECKIT) + $(CONFIGS) + $(TARGETS)
#	$(CREATOR) -> $(DISTRIB)?
#	$(CONVICT) -> git show --summary -1 2>/dev/null | cat
# recursion / setup:
#	MAKEJOBS=0 $(INSTALL)
#	$(INSTALL)
#	$(INSTALL)-$(DOITALL)
#	MAKEJOBS=8 $(DOITALL)-$(DOITALL)
#	MAKEJOBS=8 $(CLEANER)-$(DOITALL)
#	$(DOITALL)-$(DOITALL)
#	$(CLEANER)-$(DOITALL)
#	$(DOITALL)
#	$(CLEANER)
# features:
#	$(DISTRIB) -> $(UPGRADE) + $(CREATOR) + $(DOITALL)
#	$(CLEANER) -> *-$(CLEANER)
#	$(DOITALL) -> $(NOTHING) -> no $(MAKEFILE)	= $(TARGETS) -> COMPOSER_TARGETS empty/full = from * / *$(COMPOSER_EXT) / COMPOSER_SETTINGS / COMPOSER_SRC
#	$(DOITALL) -> $(NOTHING) -> no *$(COMPOSER_EXT)	= $(TARGETS) -> COMPOSER_SUBDIRS empty/full
#	$(NOTHING) -> file "$(NOTHING)" exempted during $(CLEANER)
#	$(NOTHING) -> COMPOSER_TARGETS="$(NOTHING)"
#	$(TARGETS) -> *-$(CLEANER)			= $(TARGETS) -> COMPOSER_TARGETS only *-$(CLEANER) entries
#	$(TARGETS) -> $(PRINTER)			= $(PRINTER)
#	$(COMPOSER_TARGET) -> from environment + COMPOSER_SETTINGS + COMPOSER_CSS (css_alt) = @$(CP) $(MDVIEWER_CSS) $(CURDIR)/$(COMPOSER_CSS)
#	COMPOSER_SETTINGS -> global in COMPOSER_DIR and unset in local
# flags / options:
#	MAKEJOBS=0 -> $(HELPOUT) / $(HELPALL) / ?
#	COMPOSER_DEBUGIT="0"
#	COMPOSER_DEBUGIT="1"
#	COMPOSER_INCLUDE="1" -> test local over global + #SOURCE functionality
#	COMPOSER_STAMP=
#	COMPOSER_EXT= -> #WORK need more than $(DOITALL) above?
#WORK

########################################
# {{{2 $(CHECKIT) ----------------------

.PHONY: $(CHECKIT)
$(CHECKIT): .set_title-$(CHECKIT)
	@$(call $(HEADERS))
	@$(TABLE_M3) "$(_H)Repository"		"$(_H)Commit"				"$(_H)License"
	@$(TABLE_M3) ":---"			":---"					":---"
	@$(TABLE_M3) "$(_E)Pandoc"		"$(_E)$(PANDOC_CMT)"			"$(_N)$(PANDOC_LIC)"
	@$(TABLE_M3) "$(_E)Reveal.js"		"$(_E)$(REVEALJS_CMT)"			"$(_N)$(REVEALJS_LIC)"
	@$(TABLE_M3) "$(_E)Markdown Viewer"	"$(_E)$(MDVIEWER_CMT)"			"$(_N)$(MDVIEWER_LIC)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Project"		"$(_H)$(COMPOSER_BASENAME) Version"	"$(_H)System Version"
	@$(TABLE_M3) ":---"			":---"					":---"
	@$(TABLE_M3) "$(_E)GNU Bash"		"$(_E)$(BASH_VER)"			"$(_N)$(shell $(BASH) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Coreutils"	"$(_E)$(COREUTILS_VER)"			"$(_N)$(shell $(LS) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Findutils"	"$(_E)$(FINDUTILS_VER)"			"$(_N)$(shell $(FIND) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Diffutils"	"$(_E)$(DIFFUTILS_VER)"			"$(_N)$(shell $(DIFF) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)GNU Sed"		"$(_E)$(SED_VER)"			"$(_N)$(shell $(SED) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_E)Rsync"		"$(_E)$(RSYNC_VER)"			"$(_N)$(shell $(RSYNC) --version		2>/dev/null | $(HEAD) -n1)"
#>	@$(TABLE_M3) "$(_C)GNU Make"		"$(_M)$(MAKE_VER)"			"$(_D)$(shell $(MAKE) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_C)GNU Make"		"$(_M)$(MAKE_VER)"			"$(_D)$(shell $(REALMAKE) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)Git SCM"		"$(_M)$(GIT_VER)"			"$(_D)$(shell $(GIT) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)Node.js NPM"	"$(_M)$(NPM_VER)"			"$(_D)$(shell $(NPM) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_C)Pandoc"		"$(_M)$(PANDOC_VER)"			"$(_D)$(shell $(PANDOC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)GHC"		"$(_M)$(GHC_VER)"			"$(_D)$(shell $(GHC_PKG) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)Types"		"$(_M)$(PANDOC_TYPE_VER)"		"$(_D)$(shell $(GHC_PKG_INFO) pandoc-types	2>/dev/null | $(TAIL) -n1)"
	@$(TABLE_M3) "- $(_C)TeXmath"		"$(_M)$(PANDOC_MATH_VER)"		"$(_D)$(shell $(GHC_PKG_INFO) texmath		2>/dev/null | $(TAIL) -n1)"
	@$(TABLE_M3) "- $(_C)Skylighting"	"$(_M)$(PANDOC_SKYL_VER)"		"$(_D)$(shell $(GHC_PKG_INFO) skylighting	2>/dev/null | $(TAIL) -n1)"
	@$(TABLE_M3) "- $(_C)CiteProc"		"$(_M)$(PANDOC_CITE_VER)"		"$(_D)$(shell $(GHC_PKG_INFO) citeproc		2>/dev/null | $(TAIL) -n1)"
	@$(TABLE_M3) "$(_C)TeX Live"		"$(_M)$(TEX_VER)"			"$(_D)$(shell $(TEX) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "- $(_C)TeX PDF"		"$(_M)$(TEX_PDF_VER)"			"$(_D)$(shell $(TEX_PDF) --version		2>/dev/null | $(HEAD) -n1)"
	@$(ENDOLINE)
	@$(TABLE_M2) "$(_H)Project"		"$(_H)Location & Options"
	@$(TABLE_M2) ":---"			":---"
	@$(TABLE_M2) "$(_E)GNU Bash"		"$(_N)$(BASH)"
#>	@$(TABLE_M2) "- $(_E)GNU Coreutils"	"$(_N)$(COREUTILS)"
	@$(TABLE_M2) "- $(_E)GNU Coreutils"	"$(_N)$(LS)"
	@$(TABLE_M2) "- $(_E)GNU Findutils"	"$(_N)$(FIND)"
	@$(TABLE_M2) "- $(_E)GNU Diffutils"	"$(_N)$(DIFF)"
	@$(TABLE_M2) "- $(_E)GNU Sed"		"$(_N)$(SED)"
	@$(TABLE_M2) "- $(_E)Rsync"		"$(_N)$(RSYNC)"
#>	@$(TABLE_M2) "$(_C)GNU Make"		"$(_D)$(MAKE)"
	@$(TABLE_M2) "$(_C)GNU Make"		"$(_D)$(REALMAKE)"
	@$(TABLE_M2) "- $(_C)Git SCM"		"$(_D)$(GIT)"
	@$(TABLE_M2) "- $(_C)Node.js NPM"	"$(_D)$(NPM)"
	@$(TABLE_M2) "$(_C)Pandoc"		"$(_D)$(PANDOC)"
	@$(TABLE_M2) "- $(_C)GHC"		"$(_D)$(GHC_PKG)"
	@$(TABLE_M2) "- $(_C)Types"		"$(_E)(GHC package)"
	@$(TABLE_M2) "- $(_C)TeXmath"		"$(_E)(GHC package)"
	@$(TABLE_M2) "- $(_C)Skylighting"	"$(_E)(GHC package)"
	@$(TABLE_M2) "- $(_C)CiteProc"		"$(_E)(GHC package)"
	@$(TABLE_M2) "$(_C)TeX Live"		"$(_D)$(TEX)"
	@$(TABLE_M2) "- $(_C)TeX PDF"		"$(_D)$(TEX_PDF)"

################################################################################
# {{{1 Helper Targets ----------------------------------------------------------
################################################################################

########################################
# {{{2 $(CONFIGS) ----------------------

.PHONY: $(CONFIGS)
$(CONFIGS): .set_title-$(CONFIGS)
	@$(call $(HEADERS))
	@$(TABLE_M2) "$(_H)Variable"		"$(_H)Value"
	@$(TABLE_M2) ":---"			":---"
	@$(foreach FILE,\
		$(shell $(SED) -n "s|^override[[:space:]]+([^[:space:]]+)[[:space:]]+[?][=].*$$|\1|gp" $(COMPOSER)),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$($(FILE))"; \
	)

########################################
# {{{2 $(TARGETS) ----------------------

.PHONY: $(TARGETS)
$(TARGETS): .set_title-$(TARGETS)
	@$(call $(HEADERS))
	@$(LINERULE)
	@$(foreach FILE,$(shell $(RUNMAKE) --silent $(LISTING) | $(SED) \
		$(foreach FILE,$(LISTING_VAR),\
			-e "/^$(FILE)/d" \
		) \
		$(if $(COMPOSER_EXT),\
			-e "/^[^:]+$(subst .,[.],$(COMPOSER_EXT))[:]/d" \
		) \
		-e "/^$(COMPOSER_REGEX_PREFIX)/d" \
		-e "/^$$/d" \
		-e "s|[:]$$||g" \
		-e "s|[[:space:]]+|~|g" \
		),\
		$(PRINT) "$(_M)$(subst : ,$(_D) $(DIVIDE) $(_C),$(subst ~, ,$(FILE)))"; \
	)
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) $(CLEANER)"; $(CLEANER_LISTING)		| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(DOITALL)"; $(ECHO) "$(COMPOSER_TARGETS)"	| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(SUBDIRS)"; $(ECHO) "$(COMPOSER_SUBDIRS)"	| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(LINERULE)
ifneq ($(COMPOSER_STAMP),)
#>	@$(RUNMAKE) --silent $(PRINTER)
	@$(RUNMAKE) --silent $(COMPOSER_STAMP)
endif

########################################
# {{{2 $(INSTALL) ----------------------

#WORK document *-DOITALL and COMPOSER_DOITALL_*?
#WORK somehow mark as "update" that COMPOSER_DOITALL_* and +$(MAKE) go hand-in-hand, and are how recursion is handled

$(eval override COMPOSER_DOITALL_$(INSTALL) ?=)
.PHONY: $(INSTALL)-$(DOITALL)
$(INSTALL)-$(DOITALL):
	@$(RUNMAKE) COMPOSER_DOITALL_$(INSTALL)="1" $(INSTALL)

.PHONY: $(INSTALL)
$(INSTALL): .set_title-$(INSTALL)
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS))
else
	@$(call $(HEADERS),\
		COMPOSER_INCLUDE \
		COMPOSER_SUBDIRS \
	)
endif
	@$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL))
#>	@$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(COMPOSER_SETTINGS))
	@$(call $(INSTALL)-$(MAKEFILE)-$(COMPOSER_BASENAME),$(CURDIR)/$(MAKEFILE),$(COMPOSER))
	@+$(MAKE) $(INSTALL)-$(SUBDIRS)

.PHONY: $(INSTALL)-$(SUBDIRS)
ifeq ($(COMPOSER_SUBDIRS),)
$(INSTALL)-$(SUBDIRS): $(NOTHING)-$(INSTALL)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
$(INSTALL)-$(SUBDIRS): $(NOTHING)-$(INSTALL)-$(SUBDIRS)
else
$(INSTALL)-$(SUBDIRS): $(addprefix $(INSTALL)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS))

.PHONY: $(addprefix $(INSTALL)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS))
$(addprefix $(INSTALL)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS)):
	@$(eval override $(@) := $(CURDIR)/$(subst $(INSTALL)-$(SUBDIRS)-,,$(@)))
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-dir,$($(@)))
else
	@$(call $(HEADERS),\
		COMPOSER_INCLUDE \
		COMPOSER_SUBDIRS \
	)
endif
	@$(call $(INSTALL)-$(MAKEFILE),$($(@))/$(MAKEFILE),-$(INSTALL))
#>	@$(call $(INSTALL)-$(MAKEFILE),$($(@))/$(COMPOSER_SETTINGS))
	@+$(MAKE) --directory="$($(@))" $(INSTALL)-$(SUBDIRS)
endif

override define $(INSTALL)-$(MAKEFILE)-$(COMPOSER_BASENAME) =
	$(SED) -i "s|^(override[[:space:]]+COMPOSER_TEACHER[[:space:]]+[:][=]).*$$|\1 \$$(COMPOSER_MY_PATH)/`$(REALPATH) $(dir $(1)) $(2)`|g" $(1)
endef
override define $(INSTALL)-$(MAKEFILE) =
	if [ -z "$(COMPOSER_DOITALL_$(INSTALL))" ] && [ -f "$(1)" ]; then \
		$(call $(HEADERS)-skip,$(abspath $(dir $(1))),$(notdir $(1))); \
	else \
		$(call $(HEADERS)-file,$(abspath $(dir $(1))),$(notdir $(1))); \
		$(RUNMAKE) --silent COMPOSER_ESCAPES= .$(EXAMPLE)$(2) >$(1); \
	fi
endef

################################################################################
# {{{1 Main Targets ------------------------------------------------------------
################################################################################

########################################
# {{{2 $(CLEANER) ----------------------

#> update: COMPOSER_TARGETS.*filter-out

#WORK document "*-clean"
#WORK document somewhere that clean removes files that match a phony target name?

$(eval override COMPOSER_DOITALL_$(CLEANER) ?=)
.PHONY: $(CLEANER)-$(DOITALL)
$(CLEANER)-$(DOITALL):
	@$(RUNMAKE) COMPOSER_DOITALL_$(CLEANER)="1" $(CLEANER)

.PHONY: $(CLEANER)
$(CLEANER): .set_title-$(CLEANER)
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS))
else
	@$(call $(HEADERS),\
		COMPOSER_INCLUDE \
		COMPOSER_SUBDIRS \
	)
endif
	@+$(MAKE) $(CLEANER)-do

.PHONY: $(CLEANER)-do
$(CLEANER)-do:
ifneq ($(COMPOSER_STAMP),)
	@$(RM) $(CURDIR)/$(COMPOSER_STAMP)
endif
	@$(foreach FILE,$(COMPOSER_TARGETS),\
		if [ "$(FILE)" != "$(NOTHING)" ] && [ ! -d "$(FILE)" ]; then \
			$(RM) "$(CURDIR)/$(FILE)"; \
		fi; \
	)
	@+$(MAKE) $(if $(shell $(CLEANER_LISTING)),$(shell $(CLEANER_LISTING)),$(NOTHING)-$(CLEANER))
ifneq ($(COMPOSER_DOITALL_$(CLEANER)),)
	@+$(MAKE) $(CLEANER)-$(SUBDIRS)
endif

.PHONY: $(CLEANER)-$(SUBDIRS)
ifeq ($(COMPOSER_SUBDIRS),)
$(CLEANER)-$(SUBDIRS): $(NOTHING)-$(CLEANER)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
$(CLEANER)-$(SUBDIRS): $(NOTHING)-$(CLEANER)-$(SUBDIRS)
else
$(CLEANER)-$(SUBDIRS): $(addprefix $(CLEANER)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS))

.PHONY: $(addprefix $(CLEANER)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS))
$(addprefix $(CLEANER)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS)):
	@$(eval override $(@) := $(CURDIR)/$(subst $(CLEANER)-$(SUBDIRS)-,,$(@)))
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-dir,$($(@)))
else
	@$(call $(HEADERS),\
		COMPOSER_INCLUDE \
		COMPOSER_SUBDIRS \
	)
endif
	@+$(MAKE) --directory="$($(@))" $(CLEANER)-do
endif

override define CLEANER_LISTING =
	$(RUNMAKE) --silent $(LISTING) \
	| $(SED) -n "s|^([^:]+[-]$(CLEANER))[:]+.*$$|\1|gp" \
	| $(SED) "/^.set_title[-]/d"
endef

########################################
# {{{2 $(DOITALL) ----------------------

$(eval override COMPOSER_DOITALL_$(DOITALL) ?=)
.PHONY: $(DOITALL)-$(DOITALL)
$(DOITALL)-$(DOITALL):
	@$(RUNMAKE) COMPOSER_DOITALL_$(DOITALL)="1" $(DOITALL)

.PHONY: $(DOITALL)
$(DOITALL): .set_title-$(DOITALL)
ifeq ($(COMPOSER_DEBUGIT),)
ifeq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(MAKELEVEL),0)
$(DOITALL): $(HEADERS)-$(DOITALL)
endif
endif
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(MAKELEVEL),1)
$(DOITALL): $(HEADERS)-$(DOITALL)
endif
endif
endif
$(DOITALL): $(WHOWHAT)-$(DOITALL)
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifneq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(SUBDIRS)
endif
endif
ifeq ($(COMPOSER_TARGETS),)
$(DOITALL): $(NOTHING)-$(DOITALL)
else ifeq ($(COMPOSER_TARGETS),$(NOTHING))
$(DOITALL): $(NOTHING)-$(DOITALL)
else
$(DOITALL): $(COMPOSER_TARGETS)
endif
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(SUBDIRS)
endif
endif

########################################
# {{{2 $(SUBDIRS) ----------------------

.PHONY: $(SUBDIRS)
ifeq ($(COMPOSER_SUBDIRS),)
$(SUBDIRS): $(NOTHING)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
$(SUBDIRS): $(NOTHING)-$(SUBDIRS)
else
$(SUBDIRS): $(COMPOSER_SUBDIRS)

.PHONY: $(COMPOSER_SUBDIRS)
$(COMPOSER_SUBDIRS):
ifneq ($(wildcard $(CURDIR)/$(@)/$(MAKEFILE)),)
	@+$(MAKE) --directory $(CURDIR)/$(@)
else
	@+$(MAKE) --directory $(CURDIR)/$(@) $(NOTHING)-$(MAKEFILE)
endif
endif

########################################
# {{{2 $(PRINTER) ----------------------

.PHONY: $(PRINTER)
$(PRINTER): .set_title-$(PRINTER)
$(PRINTER): $(HEADERS)-$(PRINTER)
ifneq ($(COMPOSER_STAMP),)
$(PRINTER): $(COMPOSER_STAMP)

$(COMPOSER_STAMP): *$(COMPOSER_EXT)
	@$(LS) --directory $(COMPOSER_STAMP) $(?) 2>/dev/null || $(TRUE)
endif

################################################################################
# {{{1 Pandoc Targets ----------------------------------------------------------
################################################################################

########################################
# {{{2 $(COMPOSER_TARGET) $(COMPOSER_PANDOC)

.PHONY: $(COMPOSER_TARGET)
$(COMPOSER_TARGET): .set_title-$(COMPOSER_TARGET)
$(COMPOSER_TARGET): $(BASE).$(EXTENSION)

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(SETTING)-$(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(LIST)
	@$(ECHO) "$(_N)"
	@$(PANDOC) $(PANDOC_OPTIONS)
	@$(ECHO) "$(_D)"
ifneq ($(COMPOSER_STAMP),)
	@$(ECHO) "$(DATESTAMP)" >$(CURDIR)/$(COMPOSER_STAMP)
endif

$(BASE).$(EXTENSION): $(LIST)
	@$(MAKEDOC) TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(LIST)"

########################################
# {{{2 $(COMPOSER_EXT) -----------------

#> update: TYPE_TARGETS

#WORK dual targets... document!  also, empty COMPOSER_EXT

override define TYPE_TARGETS =
%.$(2): %$(COMPOSER_EXT)
	@$(COMPOSE) TYPE="$(1)" BASE="$$(*)" LIST="$$(^)"
%.$(2): %
	@$(COMPOSE) TYPE="$(1)" BASE="$$(*)" LIST="$$(^)"
endef

$(eval $(call TYPE_TARGETS,$(TYPE_HTML),$(EXTN_HTML)))
$(eval $(call TYPE_TARGETS,$(TYPE_LPDF),$(EXTN_LPDF)))
$(eval $(call TYPE_TARGETS,$(TYPE_PRES),$(EXTN_PRES)))
$(eval $(call TYPE_TARGETS,$(TYPE_DOCX),$(EXTN_DOCX)))
$(eval $(call TYPE_TARGETS,$(TYPE_EPUB),$(EXTN_EPUB)))
$(eval $(call TYPE_TARGETS,$(TYPE_TEXT),$(EXTN_TEXT)))
$(eval $(call TYPE_TARGETS,$(TYPE_LINT),$(EXTN_LINT)))

################################################################################
# }}}1
################################################################################
# End Of File
################################################################################
