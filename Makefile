#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################
override VIM_OPTIONS := vim: filetype=make foldmethod=marker foldlevel=0 foldtext=foldtext()
override VIM_FOLDING := {{{1
################################################################################
# Release Checklist:
#	* Update
#		* Tooling Versions
#		* Pandoc Options
#		* TYPE_TARGETS
#	* Verify
#		* `make COMPOSER_DEBUGIT="1" _release`
#		* `make COMPOSER_DEBUGIT="config targets" debug-all`
#			* `make debug-file`
#			* `mv Composer-*.log artifacts/`
#		* `make test-targets`
#			#> update: TYPE_TARGETS
#			* README.html.0.0.html
#			* README.html.1.1.html
#			* README.html.x.x.html
#			* README.pdf.0.0.pdf
#			* README.pdf.2.2.pdf
#			* README.pdf.x.1.pdf
#			* README.pdf.x.x.pdf
#			* README.epub.0.0.epub
#			* README.epub.x.1.epub
#			* README.epub.x.2.epub
#			* README.epub.x.3.epub
#			* README.epub.x.x.epub
#			* README.revealjs.html.0.0.revealjs.html
#			* README.revealjs.html.1.1.revealjs.html
#			* README.revealjs.html.x.x.revealjs.html
#			* README.docx.0.0.docx
#			* README.docx.1.1.docx
#			* README.docx.x.x.docx
#		* Update: README.md
#			* `make COMPOSER_DEBUGIT="1" help-force | less -rX`
#				* `override INPUT := markdown_strict`
#				* Fits in $(COLUMNS) characters
#				* Mouse select color handling
#			* `make docs`
#				* Screenshot
#			* Spell check
#	* Publish
#		* Release: `rm rm -frv {.[^.],}*; make _release`
#		* Git commit and tag
#		* Update: COMPOSER_VERSION
################################################################################
#TODO
#	--defaults = switch to this, in a heredoc that goes to artifacts
#		maybe add additional ones, like COMPOSER_INCLUDE
#TODO
#	--title-prefix="$(TTL)" = replace with full title option...?
#	--resource-path = something like COMPOSER_CSS?
#	--strip-comments
#	--eol=lf
#	site:
#		--include-before-body
#		--include-after-body
#TODO
#	man pandoc = pandoc -o custom-reference.docx --print-default-data-file reference.docx
#	pandoc --from docx --to markdown --extract-media=README.markdown.files --track-changes=all --output=README.markdown README.docx ; vdiff README.md.txt README.markdown
#	--from "docx" --track-changes="all"
#	--from "docx|epub" --extract-media="[...]"
#TODO
#	--default-image-extension="png"?
#	--highlight-style="kate"?
#	--incremental?
#TODO
#	https://github.com/alexeygumirov/pandoc-for-pdf-how-to
#		https://github.com/Wandmalfarbe/pandoc-latex-template
#		https://learnbyexample.github.io/customizing-pandoc
#			https://dev.to/learnbyexample/customizing-pandoc-to-generate-beautiful-pdfs-from-markdown-3lbj
#	http://distrib-coffee.ipsl.jussieu.fr/pub/mirrors/ctan/macros/latex/contrib/fancyhdr/fancyhdr.pdf
#		https://en.wikibooks.org/wiki/LaTeX/Page_Layout
#		\\usepackage{showframe}
#		--variable="documentclass=book" \
#		--variable="classoption=twosides" \
#		--variable="classoption=draft"
#	--include-in-header="[...]" --include-before-body="[...]" --include-after-body="[...]"
#	--email-obfuscation="[...]"
#	--epub-metadata="[...]" --epub-cover-image="[...]" --epub-embed-font="[...]"
#TODO
#	add a way to add additional arguments, like: --variable=fontsize=28pt
#		--variable="fontsize=[...]"
#		--variable="theme=[...]"
#		--variable="transition=[...]"
#		--variable="links-as-notes=[...]"
#		--variable="lof=[...]"
#		--variable="lot=[...]"
#TODO : bootstrap!
#	site
#		post = comments ability through *-comments-$(date) files
#		index = yq crawl of directory to create a central file to build "search" pages out of
#	site is a special...?
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

override COMPOSER_HEADLINE		:= $(COMPOSER_TECHNAME): Content Make System
override COMPOSER_LICENSE		:= $(COMPOSER_TECHNAME) License
override COMPOSER_TAGLINE		:= Happy Making!

override COMPOSER_TIMESTAMP		= [$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)]

########################################

override COLUMNS			:= 80
override HEAD_MAIN			:= 1

override SPECIAL_VAL			:= 0
override DEPTH_DEFAULT			:= 2
override DEPTH_MAX			:= 6

override CSS_ALT			:= css_alt

########################################

override COMPOSER_SETTINGS		:= .composer.mk
override COMPOSER_CSS			:= .composer.css
override COMPOSER_LOG_DEFAULT		:= .composed
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

override TEX_PDF_TEMPLATE		:= $(COMPOSER_ART)/pdf.latex
override REVEALJS_CSS			:= $(COMPOSER_ART)/revealjs.css
override REVEALJS_LOGO			:= $(COMPOSER_ART)/logo.img

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

override COMPOSER_REGEX_OVERRIDE	= override[[:space:]]+($(if $(1),$(1),[^[:space:]]+))[[:space:]]+[$(if $(2),?,:)][=]
override COMPOSER_REGEX_DEFINE		= override[[:space:]]+(define[[:space:]]+)?($(if $(1),$(1),[^[:space:]]+))[[:space:]]+[=]
override COMPOSER_REGEX_EVAL		= [$$][(]eval[[:space:]]+(export[[:space:]]+)?$(call COMPOSER_REGEX_OVERRIDE,$(1),$(2))

override COMPOSER_FIND			= $(firstword $(wildcard $(abspath $(addsuffix /$(2),$(1)))))

override define READ_ALIASES =
	$(if $(COMPOSER_DEBUGIT_ALL),\
		$(info #> ALIAS			[$(1)|$($(1))|$(origin $(1))]) \
		$(info #> ALIAS			[$(2)|$($(2))|$(origin $(2))]) \
		$(info #> ALIAS			[$(3)|$($(3))|$(origin $(3))]) \
	)
	$(if $(filter undefined,$(origin $(3))),\
		$(if $(filter-out undefined,$(origin $(1))),$(eval override $(3) := $($(1)))) \
		$(if $(filter-out undefined,$(origin $(2))),$(eval override $(3) := $($(2)))) \
	) \
	$(eval override undefine $(1)) \
	$(eval override undefine $(2))
endef

########################################

#> update: includes duplicates

$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)
override COMPOSER_DEBUGIT_ALL		:=
ifeq ($(COMPOSER_DEBUGIT),$(SPECIAL_VAL))
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

override PATH_LIST			:= $(subst :, ,$(PATH))
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

override TOKEN				:= ~

########################################

override define SOURCE_INCLUDES =
ifneq ($$(wildcard $(1)/$$(COMPOSER_SETTINGS)),)
$$(if $$(COMPOSER_DEBUGIT_ALL),$$(info #> SOURCE			[$(1)/$$(COMPOSER_SETTINGS)]))
#>include $(1)/$$(COMPOSER_SETTINGS)
$$(foreach FILE,\
	$$(shell \
		$$(SED) -n "/^$$(call COMPOSER_REGEX_OVERRIDE).*$$$$/p" $(1)/$$(COMPOSER_SETTINGS) \
		| $$(SED) -e "s|[[:space:]]+|$$(TOKEN)|g" -e "s|$$$$| |g" \
	),\
	$$(if $$(COMPOSER_DEBUGIT_ALL),$$(info #> OVERRIDE			[$$(subst $$(TOKEN), ,$$(FILE))])) \
	$$(eval $$(subst $$(TOKEN), ,$$(FILE))) \
)
endif
endef

$(eval $(call SOURCE_INCLUDES,$(COMPOSER_DIR)))
$(eval $(call SOURCE_INCLUDES,$(CURDIR)))

$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDE		[$(COMPOSER_INCLUDE)]))

########################################

override COMPOSER_INCLUDES		:=
override COMPOSER_INCLUDES_LIST		:=

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
	$(eval override COMPOSER_INCLUDES := $(FILE) $(COMPOSER_INCLUDES)) \
)
override COMPOSER_INCLUDES_LIST		:= $(strip $(COMPOSER_INCLUDES))
override COMPOSER_INCLUDES		:=
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES_LIST	[$(COMPOSER_INCLUDES_LIST)]))

$(foreach FILE,$(addsuffix /$(COMPOSER_SETTINGS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD			[$(FILE)])) \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE			[$(FILE)])) \
		$(eval override MAKEFILE_LIST := $(filter-out $(FILE),$(MAKEFILE_LIST))) \
		$(eval override COMPOSER_INCLUDES := $(COMPOSER_INCLUDES) $(FILE)) \
		$(eval include $(FILE)) \
	) \
)

########################################

#> update: includes duplicates

ifneq ($(origin c_css),override)
ifeq ($(origin s),override)
undefine				c_css
$(call READ_ALIASES,s,s,c_css)
endif
endif

ifneq ($(origin c_css),override)
$(foreach FILE,$(addsuffix /$(COMPOSER_CSS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD_CSS			[$(FILE)])) \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE_CSS			[$(FILE)])) \
		$(eval override c_css := $(FILE)) \
	) \
)
endif

$(if $(COMPOSER_DEBUGIT_ALL),$(info #> CSS				[$(c_css)]))

################################################################################
# {{{1 Make Settings -----------------------------------------------------------
################################################################################

.POSIX:
.SUFFIXES:

########################################

#> update: COMPOSER_OPTIONS
unexport

export MAKEFLAGS

########################################

#>override MAKEFILE			:= $(notdir $(firstword $(MAKEFILE_LIST)))
override MAKEFILE			:= Makefile
override MAKEFLAGS			:= --no-builtin-rules --no-builtin-variables --no-print-directory

ifneq ($(COMPOSER_DEBUGIT_ALL),)
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=verbose
else
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=none
endif

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
ifeq ($(MAKEJOBS),$(SPECIAL_VAL))
override MAKEJOBS_OPTS			:= $(subst --jobs=$(MAKEJOBS),--jobs,$(MAKEJOBS_OPTS))
endif

override MAKEFLAGS			:= $(MAKEFLAGS) $(MAKEJOBS_OPTS)

########################################

#> update: includes duplicates
override UNAME				:= $(call COMPOSER_FIND,$(PATH_LIST),uname) --all

override OS_UNAME			:= $(shell $(UNAME) 2>/dev/null)
override OS_TYPE			:=
#>ifneq ($(filter Linux,$(OS_UNAME)),)
#>override OS_TYPE			:= Linux
#>else ifneq ($(filter Windows,$(OS_UNAME)),)
ifneq ($(filter Windows,$(OS_UNAME)),)
override OS_TYPE			:= Windows
else ifneq ($(filter Darwin,$(OS_UNAME)),)
override OS_TYPE			:= Darwin
else ifneq ($(filter Linux,$(OS_UNAME)),)
override OS_TYPE			:= Linux
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
ifeq ($(COMPOSER_DEBUGIT),$(SPECIAL_VAL))
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

########################################

override COMPOSER_LOG			?= $(COMPOSER_LOG_DEFAULT)

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
$(call READ_ALIASES,g,g,c_lang)
$(call READ_ALIASES,s,s,c_css)
$(call READ_ALIASES,c,c,c_toc)
$(call READ_ALIASES,l,l,c_level)
$(call READ_ALIASES,m,m,c_margin)
$(call READ_ALIASES,mt,mt,c_margin_top)
$(call READ_ALIASES,mb,mb,c_margin_bottom)
$(call READ_ALIASES,ml,ml,c_margin_left)
$(call READ_ALIASES,mr,mr,c_margin_right)
$(call READ_ALIASES,o,o,c_options)

#> update: $(HEADERS)-vars
override c_type				?= $(TYPE_DEFAULT)
override c_base				?= $(OUT_README)
override c_list				?= $(c_base)$(COMPOSER_EXT)
override c_lang				?= en-US
#>override c_css			?= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override c_css				?=
override c_toc				?=
override c_level			?= $(DEPTH_DEFAULT)
override c_margin			?= 0.8in
override c_margin_top			?=
override c_margin_bottom		?=
override c_margin_left			?=
override c_margin_right			?=
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
ifneq ($(origin PANDOC_VER),override)
override PANDOC_VER			:= 2.18
endif
ifneq ($(origin PANDOC_CMT),override)
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
ifneq ($(origin YQ_VER),override)
override YQ_VER				:= 4.24.2
endif
ifneq ($(origin YQ_CMT),override)
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
ifneq ($(origin BOOTSTRAP_CMT),override)
override BOOTSTRAP_CMT			:= v5.1.3
endif
override BOOTSTRAP_LIC			:= MIT
override BOOTSTRAP_SRC			:= https://github.com/twbs/bootstrap.git
override BOOTSTRAP_DIR			:= $(COMPOSER_DIR)/bootstrap

########################################

# https://github.com/simov/markdown-viewer
# https://github.com/simov/markdown-viewer/blob/master/LICENSE
ifneq ($(origin MDVIEWER_CMT),override)
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
ifneq ($(origin REVEALJS_CMT),override)
override REVEALJS_CMT			:= 4.3.1
endif
override REVEALJS_LIC			:= MIT
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DIR			:= $(COMPOSER_DIR)/revealjs
#>override REVEALJS_CSS_THEME		:= $(REVEALJS_DIR)/dist/theme/solarized.css
override REVEALJS_CSS_THEME		:= $(REVEALJS_DIR)/dist/theme/black.css

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

override TMPL_HTML			:= html5
override TMPL_LPDF			:= latex
override TMPL_EPUB			:= epub3
override TMPL_PRES			:= $(TYPE_PRES)
override TMPL_DOCX			:= $(TYPE_DOCX)
override TMPL_PPTX			:= $(TYPE_PPTX)
override TMPL_TEXT			:= plain
override TMPL_LINT			:= $(TYPE_LINT)

override EXTN_HTML			:= $(TYPE_HTML)
override EXTN_LPDF			:= $(TYPE_LPDF)
override EXTN_EPUB			:= $(TYPE_EPUB)
override EXTN_PRES			:= $(TYPE_PRES).$(TYPE_HTML)
override EXTN_DOCX			:= $(TYPE_DOCX)
override EXTN_PPTX			:= $(TYPE_PPTX)
override EXTN_TEXT			:= txt
override EXTN_LINT			:= $(subst $(TOKEN),,$(subst $(TOKEN).,,$(addprefix $(TOKEN),$(COMPOSER_EXT_DEFAULT)))).$(EXTN_TEXT)

$(foreach FILE,\
	HTML \
	LPDF \
	EPUB \
	PRES \
	DOCX \
	PPTX \
	TEXT \
	LINT \
	,\
	$(if $(filter $(TYPE_$(FILE)),$(c_type)),\
		$(eval override OUTPUT		:= $(TMPL_$(FILE))); \
		$(eval override EXTENSION	:= $(EXTN_$(FILE))); \
	) \
)

#> update: COMPOSER_TARGETS.*=
ifneq ($(COMPOSER_RELEASE),)
override COMPOSER_TARGETS		:= $(strip \
	$(OUT_README).$(EXTN_HTML) \
	$(OUT_README).$(EXTN_LPDF) \
	$(OUT_README).$(EXTN_EPUB) \
	$(OUT_README).$(EXTN_PRES) \
	$(OUT_README).$(EXTN_DOCX) \
)
#>	$(OUT_README).$(EXTN_PPTX) \
#>	$(OUT_README).$(EXTN_TEXT) \
#>	$(OUT_README).$(EXTN_LINT) \
#>)
endif

########################################
# {{{2 CSS -----------------------------

override define c_css_select =
$(strip $(if $(c_css),\
	$(if $(filter $(SPECIAL_VAL),$(c_css)),,\
	$(if $(filter $(CSS_ALT),$(c_css)),$(MDVIEWER_CSS_ALT) ,\
	$(abspath $(c_css)) \
	)) \
,\
	$(if $(filter $(TYPE_PRES),$(c_type)),$(REVEALJS_CSS) ,\
	$(MDVIEWER_CSS) \
	) \
))
endef

#>$(eval override c_css			:= $(call c_css_select))

########################################
# {{{2 Command -------------------------

override PANDOC_OPTIONS_DATA		:=
ifneq ($(COMPOSER_DEBUGIT_ALL),)
override PANDOC_OPTIONS_DATA		:= --verbose
endif

override PANDOC_OPTIONS_DATA		:= $(PANDOC_OPTIONS_DATA) --data-dir="$(PANDOC_DIR)"

ifneq ($(wildcard $(COMPOSER_ART)/template.$(EXTENSION)),)
override PANDOC_OPTIONS_DATA		:= $(PANDOC_OPTIONS_DATA) --template="$(COMPOSER_ART)/template.$(EXTENSION)"
else ifneq ($(wildcard $(PANDOC_DIR)/data/templates/default.$(OUTPUT)),)
override PANDOC_OPTIONS_DATA		:= $(PANDOC_OPTIONS_DATA) --template="$(PANDOC_DIR)/data/templates/default.$(OUTPUT)"
endif

ifneq ($(wildcard $(COMPOSER_ART)/reference.$(EXTENSION)),)
override PANDOC_OPTIONS_DATA		:= $(PANDOC_OPTIONS_DATA) --reference-doc="$(COMPOSER_ART)/reference.$(EXTENSION)"
endif

########################################

override PANDOC_EXTENSIONS		:=
override PANDOC_EXTENSIONS		+= +ascii_identifiers
override PANDOC_EXTENSIONS		+= +auto_identifiers
override PANDOC_EXTENSIONS		+= +emoji
override PANDOC_EXTENSIONS		+= +fancy_lists
override PANDOC_EXTENSIONS		+= +fenced_divs
override PANDOC_EXTENSIONS		+= +footnotes
override PANDOC_EXTENSIONS		+= +gfm_auto_identifiers
override PANDOC_EXTENSIONS		+= +header_attributes
override PANDOC_EXTENSIONS		+= +implicit_figures
override PANDOC_EXTENSIONS		+= +implicit_header_references
override PANDOC_EXTENSIONS		+= +inline_notes
override PANDOC_EXTENSIONS		+= +intraword_underscores
override PANDOC_EXTENSIONS		+= +line_blocks
override PANDOC_EXTENSIONS		+= +pandoc_title_block
override PANDOC_EXTENSIONS		+= +pipe_tables
override PANDOC_EXTENSIONS		+= +shortcut_reference_links
override PANDOC_EXTENSIONS		+= +smart
override PANDOC_EXTENSIONS		+= +strikeout
override PANDOC_EXTENSIONS		+= +superscript
override PANDOC_EXTENSIONS		+= +task_lists
override PANDOC_EXTENSIONS		+= +yaml_metadata_block
override PANDOC_EXTENSIONS		+= -spaced_reference_links

override PANDOC_OPTIONS			= $(strip $(PANDOC_OPTIONS_DATA) \
	--output="$(CURDIR)/$(c_base).$(EXTENSION)" \
	--from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" \
	--to="$(OUTPUT)" \
	\
	--standalone \
	--self-contained \
	--columns="$(COLUMNS)" \
	\
	$(if $(c_lang),\
		--variable="lang=$(c_lang)" \
	) \
	$(if $(filter $(c_type),$(TYPE_LPDF)),\
		--pdf-engine="$(PANDOC_TEX_PDF)" \
		--pdf-engine-opt="-output-directory=$(COMPOSER_TMP)/$(c_base).$(EXTENSION).$(DATENAME)" \
		--include-in-header="$(TEX_PDF_TEMPLATE)" \
		--listings \
	) \
	$(if $(filter $(c_type),$(TYPE_PRES)),\
		--variable="revealjs-url=$(REVEALJS_DIR)" \
	) \
	$(if $(c_site),\
		--include-in-header="$(BOOTSTRAP_DIR)/dist/js/bootstrap.js" \
		--include-in-header="$(BOOTSTRAP_DIR)/dist/css/bootstrap.css" \
	) \
	$(if $(call c_css_select),\
		$(if $(filter $(c_type),$(TYPE_HTML)),	--css="$(call c_css_select)") \
		$(if $(filter $(c_type),$(TYPE_EPUB)),	--css="$(call c_css_select)") \
		$(if $(filter $(c_type),$(TYPE_PRES)),	--css="$(call c_css_select)") \
	) \
	$(if $(c_toc),\
		--table-of-contents \
		$(if $(filter $(SPECIAL_VAL),$(c_toc)),	--toc-depth="$(DEPTH_MAX)" --number-sections ,\
							--toc-depth="$(c_toc)" \
		) \
	) \
	$(if $(c_level),\
		$(if $(filter $(c_type),$(TYPE_HTML)),			--section-divs) \
		$(if $(filter $(c_type),$(TYPE_LPDF)),\
			$(if $(filter $(SPECIAL_VAL),$(c_level)),	--top-level-division="part" ,\
			$(if $(filter $(DEPTH_DEFAULT),$(c_level)),	--top-level-division="chapter" ,\
									--top-level-division="section" \
		))) \
		$(if $(filter $(c_type),$(TYPE_EPUB)),\
			$(if $(filter $(SPECIAL_VAL),$(c_level)),	--epub-chapter-level="$(DEPTH_DEFAULT)" ,\
									--epub-chapter-level="$(c_level)" \
		)) \
		$(if $(filter $(c_type),$(TYPE_PRES)),\
			$(if $(filter $(SPECIAL_VAL),$(c_level)),	--section-divs --slide-level="1" ,\
									--section-divs --slide-level="$(DEPTH_DEFAULT)" \
		)) \
	) \
	$(if $(filter $(c_type),$(TYPE_LPDF)),\
		$(if $(c_margin),		--variable="geometry=margin=$(c_margin)" ,\
		$(if $(c_margin_top),		--variable="geometry=top=$(c_margin_top)") \
		$(if $(c_margin_bottom),	--variable="geometry=bottom=$(c_margin_bottom)") \
		$(if $(c_margin_left),		--variable="geometry=left=$(c_margin_left)") \
		$(if $(c_margin_right),		--variable="geometry=right=$(c_margin_right)") \
	)) \
	$(if $(c_options),$(c_options)) \
	$(c_list) \
)

########################################

override PANDOC_OPTIONS_ERROR		:=
ifeq ($(c_type),$(TYPE_LPDF))
ifneq ($(c_toc),)
ifneq ($(c_level),$(SPECIAL_VAL))
ifneq ($(c_level),$(DEPTH_DEFAULT))
override PANDOC_OPTIONS_ERROR		= The 'c_toc' option must be empty when 'c_level != [$(SPECIAL_VAL)|$(DEPTH_DEFAULT)]' for '$(TYPE_LPDF)'
endif
endif
endif
endif

################################################################################
# {{{1 Bootstrap Options -------------------------------------------------------
################################################################################

#TODO : bootstrap!

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

override COMPOSER_PANDOC		:= compose

#> update: $(MAKE) / @+
override MAKE_OPTIONS			:= $(MAKEFLAGS)
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
	COMPOSER_LOG \
	COMPOSER_EXT \
	c_type \
	c_lang \
	c_css \
	c_toc \
	c_level \
	c_margin \
	c_margin_top \
	c_margin_bottom \
	c_margin_left \
	c_margin_right \
	c_options \

override COMPOSER_EXPORTED_NOT := \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES \
	c_base \
	c_list \

$(foreach FILE,$(COMPOSER_EXPORTED)	,$(eval export $(FILE)))
$(foreach FILE,$(COMPOSER_EXPORTED_NOT)	,$(eval unexport $(FILE)))

override COMPOSER_OPTIONS		:= \
	$(shell $(SED) -n "s|^$(call COMPOSER_REGEX_OVERRIDE,,1).*$$|\1|gp" $(COMPOSER) \
	| $(SED) $(if $(c_margin),"/^c_margin_.+$$/d","/^c_margin$$/d") \
)
$(foreach FILE,$(COMPOSER_OPTIONS),\
	$(if $(or \
		$(filter $(FILE),$(COMPOSER_EXPORTED)) ,\
		$(filter $(FILE),$(COMPOSER_EXPORTED_NOT)) ,\
		),,$(error #> $(COMPOSER_FULLNAME): COMPOSER_OPTIONS: $(FILE)) \
	) \
)

$(if $(COMPOSER_DEBUGIT_ALL),\
	$(info #> COMPOSER_EXPORTED		[$(strip $(COMPOSER_EXPORTED))]) \
	$(info #> COMPOSER_EXPORTED_NOT	[$(strip $(COMPOSER_EXPORTED_NOT))]) \
	$(info #> COMPOSER_OPTIONS		[$(strip $(COMPOSER_OPTIONS))]) \
)

########################################
# {{{2 Targets -------------------------

#> update: includes duplicates

#> update: $(DEBUGIT): targets list
#> update: $(TESTING): targets list

#> update: PHONY.*$(DOITALL)
#	$(DEBUGIT)-file + COMPOSER_DOITALL_$(TESTING)="$(DEBUGIT)"
#	$(TESTING)-file + COMPOSER_DOITALL_$(DEBUGIT)="$(TESTING)"
#> update: PHONY.*$(DOITALL)
#	$(HELPOUT)-$(DOITALL)
#	$(HEADERS)-$(EXAMPLE)-$(DOITALL)
#	$(CHECKIT)-$(DOITALL)
#	$(CONFIGS)-$(DOITALL)
#	$(CONVICT)-$(DOITALL)
#	$(UPGRADE)-$(DOITALL)
#	$(INSTALL)-$(DOITALL)
#	$(CLEANER)-$(DOITALL)
#	$(DOITALL)-$(DOITALL)
#> update: PHONY.*$(DOFORCE)
#	$(HELPOUT)-$(DOFORCE)
#	$(CHECKIT)-$(DOFORCE)
#	$(INSTALL)-$(DOFORCE)

override HELPOUT			:= help
override CREATOR			:= docs
override EXAMPLE			:= template

override HEADERS			:= headers

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
	$(COMPOSER_PANDOC) \
	\
	$(HELPOUT) \
	$(CREATOR) \
	$(EXAMPLE) \
	\
	$(HEADERS) \
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
ifeq ($(COMPOSER_SUBDIRS),)
#>override COMPOSER_SUBDIRS		:= $(subst /$(MAKEFILE),,$(wildcard $(addsuffix /$(MAKEFILE),$(COMPOSER_CONTENTS_DIRS))))
override COMPOSER_SUBDIRS		:= $(COMPOSER_CONTENTS_DIRS)
endif

ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out $(COMPOSER_IGNORES),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(CONFIGS)-$(TARGETS)
endif
endif
ifneq ($(COMPOSER_SUBDIRS),)
override COMPOSER_SUBDIRS		:= $(filter-out $(COMPOSER_IGNORES),$(COMPOSER_SUBDIRS))
ifeq ($(COMPOSER_SUBDIRS),)
override COMPOSER_SUBDIRS		:= $(NOTHING)-$(CONFIGS)-$(SUBDIRS)
endif
endif

#> $(CLEANER) > $(DOITALL)
ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out %-$(DOITALL),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(TARGETS)-$(DOITALL)
endif
endif
ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out %-$(CLEANER),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(TARGETS)-$(CLEANER)
endif
endif

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
		| $$(XARGS) $$(BASH) -ec '\
			if [ -f "$$(CURDIR)/{}" ]; then \
				$$(call $$(HEADERS)-rm,$$(CURDIR),{}); \
				$$(RM) $$(CURDIR)/{} >/dev/null; \
			fi; \
		'
endef

$(foreach FILE,$(COMPOSER_RESERVED_SPECIAL),\
	$(eval $(call COMPOSER_RESERVED_SPECIAL_TARGETS,$(FILE))) \
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
#>	@$(call TITLE_LN,0,$(COMPOSER_FULLNAME) $(DIVIDE) $(*))
	@$(call TITLE_LN,1,$(COMPOSER_FULLNAME) $(DIVIDE) $(*),0)

.PHONY: $(HELPOUT)-USAGE
$(HELPOUT)-USAGE:
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)[-f .../$(MAKEFILE)]$(_D) $(_E)[variables]$(_D) $(_M)<filename>.<extension>"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)[-f .../$(MAKEFILE)]$(_D) $(_E)[variables]$(_D) $(_M)<target>"

.PHONY: $(HELPOUT)-FOOTER
$(HELPOUT)-FOOTER:
	@$(ENDOLINE)
	@$(LINERULE)
	@$(ENDOLINE)
	@$(PRINT) "*$(_H)$(COMPOSER_TAGLINE)$(_D)*"

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
#>	$(HELPOUT)-TARGETS_PRIMARY_1 \
#>	$(HELPOUT)-TARGETS_SPECIALS_1 \
#>	$(HELPOUT)-EXAMPLES_1 \
#>	$(HELPOUT)-FOOTER
$(HELPOUT): $(HELPOUT)-TITLE_Help
$(HELPOUT): $(HELPOUT)-USAGE
$(HELPOUT): $(HELPOUT)-VARIABLES_TITLE_1
$(HELPOUT): $(HELPOUT)-VARIABLES_FORMAT_2
$(HELPOUT): $(HELPOUT)-VARIABLES_CONTROL_2
$(HELPOUT): $(HELPOUT)-TARGETS_TITLE_1
$(HELPOUT): $(HELPOUT)-TARGETS_PRIMARY_2
$(HELPOUT): $(HELPOUT)-TARGETS_SPECIALS_2
$(HELPOUT): $(HELPOUT)-TARGETS_ADDITIONAL_2
#>$(HELPOUT): $(HELPOUT)-TARGETS_INTERNAL_2
$(HELPOUT): $(HELPOUT)-EXAMPLES_1
$(HELPOUT): $(HELPOUT)-FOOTER
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
$(HELPOUT)-VARIABLES_FORMAT_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Formatting Variables); fi
	@$(TABLE_M3) "$(_H)Variable"			"$(_H)Purpose"				"$(_H)Value"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_C)[c_type]$(_D)    ~ $(_E)T"	"Desired output format"			"$(_M)$(c_type)"
	@$(TABLE_M3) "$(_C)[c_base]$(_D)    ~ $(_E)B"	"Base of output file"			"$(_M)$(c_base)"
	@$(TABLE_M3) "$(_C)[c_list]$(_D)    ~ $(_E)L"	"List of input files(s)"		"$(_M)$(c_list)"
	@$(TABLE_M3) "$(_C)[c_lang]$(_D)    ~ $(_E)g"	"Language for document headers"		"$(_M)$(c_lang)"
	@$(TABLE_M3) "$(_C)[c_css]$(_D)     ~ $(_E)s"	"Location of CSS file"			"$(if $(c_css),$(_M)$(notdir $(c_css))$(_D) )$(_N)(\`$(COMPOSER_CSS)\`)"
	@$(TABLE_M3) "$(_C)[c_toc]$(_D)     ~ $(_E)c"	"Table of contents depth"		"$(_M)$(c_toc)"
	@$(TABLE_M3) "$(_C)[c_level]$(_D)   ~ $(_E)l"	"Chapter/slide header level"		"$(_M)$(c_level)"
	@$(TABLE_M3) "$(_C)[c_margin]$(_D)  ~ $(_E)m"	"Size of margins ($(_C)[PDF]$(_D))"	"$(_M)$(c_margin)"
	@$(TABLE_M3) "$(_C)[c_options]$(_D) ~ $(_E)o"	"Custom Pandoc options"			"$(_M)$(c_options)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Values:$(_D) $(_C)c_type"	"$(_H)Format"				"$(_H)Extension"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_M)$(TYPE_HTML)"		"$(DESC_HTML)"				"$(_N)*$(_D).$(_E)$(EXTN_HTML)"
	@$(TABLE_M3) "$(_M)$(TYPE_LPDF)"		"$(DESC_LPDF)"				"$(_N)*$(_D).$(_E)$(EXTN_LPDF)"
	@$(TABLE_M3) "$(_M)$(TYPE_EPUB)"		"$(DESC_EPUB)"				"$(_N)*$(_D).$(_E)$(EXTN_EPUB)"
	@$(TABLE_M3) "$(_M)$(TYPE_PRES)"		"$(DESC_PRES)"				"$(_N)*$(_D).$(_E)$(EXTN_PRES)"
	@$(TABLE_M3) "$(_M)$(TYPE_DOCX)"		"$(DESC_DOCX)"				"$(_N)*$(_D).$(_E)$(EXTN_DOCX)"
	@$(TABLE_M3) "$(_M)$(TYPE_PPTX)"		"$(DESC_PPTX)"				"$(_N)*$(_D).$(_E)$(EXTN_PPTX)"
	@$(TABLE_M3) "$(_M)$(TYPE_TEXT)"		"$(DESC_TEXT)"				"$(_N)*$(_D).$(_E)$(EXTN_TEXT)"
	@$(TABLE_M3) "$(_M)$(TYPE_LINT)"		"$(DESC_LINT)"				"$(_N)*$(_D).$(_E)$(EXTN_LINT)"
	@$(ENDOLINE)
	@$(PRINT) "  * *Other $(_C)[c_type]$(_D) values will be passed directly to $(_C)[Pandoc]$(_D)*"
	@$(PRINT) "  * *Special values for $(_C)[c_css]$(_D):*"
	@$(COLUMN_2) "    * *\`$(_N)$(CSS_ALT)$(_D)\`"		"~ Use the alternate default stylesheet*"
	@$(COLUMN_2) "    * *\`$(_N)$(SPECIAL_VAL)$(_D)\`"			"~ Revert to the $(_C)[Pandoc]$(_D) default*"
	@$(COLUMN_2) "  * *Special value \`$(_N)$(SPECIAL_VAL)$(_D)\` for $(_C)[c_toc]$(_D)"	"~ List all headers, and number sections*"
	@$(COLUMN_2) "  * *Special value \`$(_N)$(SPECIAL_VAL)$(_D)\` for $(_C)[c_level]$(_D)"	"~ Varies by $(_C)[c_type]$(_D) $(_E)(see [$(HELPOUT)-$(DOITALL)])$(_D)*"
	@$(PRINT) "  * *An empty $(_C)[c_margin]$(_D) value enables individual margins:*"
	@$(PRINT) "    * *\`$(_C)c_margin_top$(_D)\`    ~ \`$(_E)mt$(_D)\`*"
	@$(PRINT) "    * *\`$(_C)c_margin_bottom$(_D)\` ~ \`$(_E)mb$(_D)\`*"
	@$(PRINT) "    * *\`$(_C)c_margin_left$(_D)\`   ~ \`$(_E)ml$(_D)\`*"
	@$(PRINT) "    * *\`$(_C)c_margin_right$(_D)\`  ~ \`$(_E)mr$(_D)\`*"

.PHONY: $(HELPOUT)-VARIABLES_CONTROL_%
$(HELPOUT)-VARIABLES_CONTROL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Control Variables); fi
	@$(TABLE_M3) "$(_H)Variable"		"$(_H)Purpose"					"$(_H)Value"
	@$(TABLE_M3) ":---"			":---"						":---"
	@$(TABLE_M3) "$(_C)[MAKEJOBS]"		"Parallel processing threads"			"$(if $(MAKEJOBS),$(_M)$(MAKEJOBS)$(_D) )\`$(_N)(makejobs)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_DOCOLOR]"	"Enable title/color sequences"			"$(if $(COMPOSER_DOCOLOR),$(_M)$(COMPOSER_DOCOLOR)$(_D) )\`$(_N)(boolean)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_DEBUGIT]"	"Use verbose output"				"$(if $(COMPOSER_DEBUGIT),$(_M)$(COMPOSER_DEBUGIT)$(_D) )\`$(_N)(debugit)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_INCLUDE]"	"Include all: \`$(_M)$(COMPOSER_SETTINGS)\`"	"$(if $(COMPOSER_INCLUDE),$(_M)$(COMPOSER_INCLUDE)$(_D) )\`$(_N)(boolean)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_DEPENDS]"	"Sub-directories first: $(_C)[$(DOITALL)]"	"$(if $(COMPOSER_DEPENDS),$(_M)$(COMPOSER_DEPENDS)$(_D) )\`$(_N)(boolean)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_LOG]"	"Timestamped command log"			"$(if $(COMPOSER_LOG),$(_M)$(COMPOSER_LOG))"
	@$(TABLE_M3) "$(_C)[COMPOSER_EXT]"	"Markdown file extension"			"$(if $(COMPOSER_EXT),$(_M)$(COMPOSER_EXT))"
	@$(TABLE_M3) "$(_C)[COMPOSER_TARGETS]"	"See: $(_C)[$(DOITALL)]$(_E)/$(_C)[$(CLEANER)]$(_D)"				"$(_C)[$(CONFIGS)]$(_E)/$(_C)[$(TARGETS)]"	#> "$(if $(COMPOSER_TARGETS),$(_M)$(COMPOSER_TARGETS))"
	@$(TABLE_M3) "$(_C)[COMPOSER_SUBDIRS]"	"See: $(_C)[$(DOITALL)]$(_E)/$(_C)[$(CLEANER)]$(_E)/$(_C)[$(INSTALL)]$(_D)"	"$(_C)[$(CONFIGS)]$(_E)/$(_C)[$(TARGETS)]"	#> "$(if $(COMPOSER_SUBDIRS),$(_M)$(COMPOSER_SUBDIRS))"
	@$(TABLE_M3) "$(_C)[COMPOSER_IGNORES]"	"See: $(_C)[$(DOITALL)]$(_E)/$(_C)[$(CLEANER)]$(_E)/$(_C)[$(INSTALL)]$(_D)"	"$(_C)[$(CONFIGS)]"				#> "$(if $(COMPOSER_IGNORES),$(_M)$(COMPOSER_IGNORES))"
	@$(ENDOLINE)
	@$(PRINT) "  * *$(_C)[MAKEJOBS]$(_D)         ~ \`$(_E)c_jobs$(_D)\`  ~ \`$(_E)J$(_D)\`*"
	@$(PRINT) "  * *$(_C)[COMPOSER_DOCOLOR]$(_D) ~ \`$(_E)c_color$(_D)\` ~ \`$(_E)C$(_D)\`*"
	@$(PRINT) "  * *$(_C)[COMPOSER_DEBUGIT]$(_D) ~ \`$(_E)c_debug$(_D)\` ~ \`$(_E)V$(_D)\`*"
	@$(PRINT) "  * *\`$(_N)(makejobs)$(_D)\` = empty is disabled / number of threads / \`$(_N)$(SPECIAL_VAL)$(_D)\` is no limit*"
	@$(PRINT) "  * *\`$(_N)(debugit)$(_D)\`  = empty is disabled / any value enables / \`$(_N)$(SPECIAL_VAL)$(_D)\` is full tracing*"
	@$(PRINT) "  * *\`$(_N)(boolean)$(_D)\`  = empty is disabled / any value enables*"

########################################
# {{{3 $(HELPOUT)-TARGETS --------------

#> update: PHONY.*$(CLEANER)
#> update: PHONY.*$(DOITALL)
#> update: PHONY.*$(DOFORCE)

.PHONY: $(HELPOUT)-TARGETS_TITLE_%
$(HELPOUT)-TARGETS_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Targets,$(HEAD_MAIN))

.PHONY: $(HELPOUT)-TARGETS_PRIMARY_%
$(HELPOUT)-TARGETS_PRIMARY_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Primary Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)]"			"Basic $(HELPOUT) overview $(_E)(default)$(_D)"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)-$(DOITALL)]"		"Console version of \`$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)\` $(_E)(mostly identical)$(_D)"
	@$(TABLE_M2) "$(_C)[$(EXAMPLE)]"			"Print settings template: \`$(_M)$(COMPOSER_SETTINGS)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_PANDOC)]"		"Document creation engine $(_E)(see [Formatting Variables])$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)]"			"Recursively create $(_C)[Bootstrap Websites]$(_D)"
	@$(TABLE_M2) "$(_C)[$(INSTALL)]"			"Current directory initialization: \`$(_M)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(INSTALL)-$(DOITALL)]"		"Do $(_C)[$(INSTALL)]$(_D) recursively $(_E)(no overwrite)$(_D)"
	@$(TABLE_M2) "$(_C)[$(INSTALL)-$(DOFORCE)]"		"Recursively force overwrite of \`$(_M)$(MAKEFILE)$(_D)\` files"
	@$(TABLE_M2) "$(_C)[$(CLEANER)]"			"Remove output files: $(_C)[COMPOSER_TARGETS]$(_D) $(_E)$(DIVIDE)$(_D) $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(CLEANER)-$(DOITALL)]"		"Do $(_C)[$(CLEANER)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_N)[*$(_C)-$(CLEANER)]"			"Any targets named this way will also be run by $(_C)[$(CLEANER)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DOITALL)]"			"Create output files: $(_C)[COMPOSER_TARGETS]$(_D) $(_E)$(DIVIDE)$(_D) $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DOITALL)-$(DOITALL)]"		"Do $(_C)[$(DOITALL)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_N)[*$(_C)-$(DOITALL)]"			"Any targets named this way will also be run by $(_C)[$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PRINTER)]"			"Print updated files: \`$(_N)*$(_M)$(COMPOSER_EXT)$(_D)\` $(_E)$(MARKER)$(_D) \`$(_M)$(COMPOSER_LOG)$(_D)\`"

.PHONY: $(HELPOUT)-TARGETS_SPECIALS_%
$(HELPOUT)-TARGETS_SPECIALS_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Special Targets); fi
	@$(PRINT) "$(_S)[Specials]: #special-targets"
	@$(PRINT) "$(_S)[Special]: #special-targets"
	@$(ENDOLINE)
	@$(PRINT) "There are a few targets considered $(_C)[Specials]$(_D), that have unique properties:"
	@$(ENDOLINE)
	@$(TABLE_M2) "$(_H)Base Name"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(DO_BOOK)]"			"Concatenate a source list into a single output file"
	@$(TABLE_M2) "$(_C)[$(DO_PAGE)]"			"$(_N)*(Reserved for the future [$(PUBLISH)] feature)*$(_D)"
	@$(TABLE_M2) "$(_C)[$(DO_POST)]"			"$(_N)*(Reserved for the future [$(PUBLISH)] feature)*$(_D)"
	@$(ENDOLINE)
	@$(PRINT) "For each of these base names, there are a standard set of actual targets:"
	@$(ENDOLINE)
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_E)%$(_C)s-$(CLEANER)"			"Called by $(_C)[$(CLEANER)]$(_D), removes all \`$(_E)%$(_M)-$(_N)*$(_D)\` files"
	@$(TABLE_M2) "$(_E)%$(_C)s-$(DOITALL)"			"Called by $(_C)[$(DOITALL)]$(_D), creates all \`$(_E)%$(_M)-$(_N)*$(_D)\` files"
	@$(TABLE_M2) "$(_E)%$(_C)s"				"Main target, which is a wrapper to \`$(_E)%$(_C)s-$(DOITALL)$(_D)\`"
	@$(TABLE_M2) "$(_E)%$(_C)-$(_N)*"			"Target files will be processed according to the base"

.PHONY: $(HELPOUT)-TARGETS_ADDITIONAL_%
$(HELPOUT)-TARGETS_ADDITIONAL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Additional Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(DEBUGIT)]"			"Diagnostics, tests targets list in $(_C)[COMPOSER_DEBUGIT]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DEBUGIT)-file]"			"Export $(_C)[$(DEBUGIT)]$(_D) results to a plain text file"
	@$(TABLE_M2) "$(_C)[$(CHECKIT)]"			"List system packages and versions $(_E)(see [Requirements])$(_D)"
	@$(TABLE_M2) "$(_C)[$(CHECKIT)-$(DOITALL)]"		"Complete $(_C)[$(CHECKIT)]$(_D) package list, and system information"
	@$(TABLE_M2) "$(_C)[$(CONFIGS)]"			"Show values of all $(_C)[$(COMPOSER_BASENAME) Variables]$(_D)"
	@$(TABLE_M2) "$(_C)[$(CONFIGS)-$(DOITALL)]"		"Complete $(_C)[$(CONFIGS)]$(_D), including environment variables"
	@$(TABLE_M2) "$(_C)[$(TARGETS)]"			"List all available targets for the current directory"
	@$(TABLE_M2) "$(_C)[$(CONVICT)]"			"Timestamped $(_N)[Git]$(_D) commit of the current directory tree"
	@$(TABLE_M2) "$(_C)[$(CONVICT)-$(DOITALL)]"		"Automatic $(_C)[$(CONVICT)]$(_D), without \`$(_C)"'$$EDITOR'"$(_D)\` step"
	@$(TABLE_M2) "$(_C)[$(DISTRIB)]"			"Full upgrade to current release, repository preparation"
	@$(TABLE_M2) "$(_C)[$(UPGRADE)]"			"Update all included components $(_E)(see [Requirements])$(_D)"
	@$(TABLE_M2) "$(_C)[$(UPGRADE)-$(DOITALL)]"		"Complete $(_C)[$(UPGRADE)]$(_D), including binaries: $(_C)[Pandoc]$(_D), $(_C)[YQ]$(_D)"

.PHONY: $(HELPOUT)-TARGETS_INTERNAL_%
$(HELPOUT)-TARGETS_INTERNAL_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Internal Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)-$(DOFORCE)]"		"Complete \`$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)\` content $(_E)(similar to [$(HELPOUT)-$(DOITALL)])$(_D)"
	@$(TABLE_M2) "$(_C)[.$(EXAMPLE)-$(INSTALL)]"		"The \`$(_M)$(MAKEFILE)$(_D)\` used by $(_C)[$(INSTALL)]$(_D) $(_E)(see [Templates])$(_D)"
	@$(TABLE_M2) "$(_C)[.$(EXAMPLE)]"			"The \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` used by $(_C)[$(EXAMPLE)]$(_D) $(_E)(see [Templates])$(_D)"
	@$(TABLE_M2) "$(_C)[$(CREATOR)]"			"Extracts embedded files from \`$(_M)$(MAKEFILE)$(_D)\`, and does $(_C)[$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(HEADERS)]"			"Series of targets that handle all informational output"
	@$(TABLE_M2) "$(_C)[$(HEADERS)-$(EXAMPLE)]"		"For testing default $(_C)[$(HEADERS)]$(_D) output"
	@$(TABLE_M2) "$(_C)[$(HEADERS)-$(EXAMPLE)-$(DOITALL)]"	"For testing complete $(_C)[$(HEADERS)]$(_D) output"
	@$(TABLE_M2) "$(_C)[$(MAKE_DB)]"			"Complete contents of $(_C)[GNU Make]$(_D) internal state"
	@$(TABLE_M2) "$(_C)[$(LISTING)]"			"Extracted list of all targets from $(_C)[$(MAKE_DB)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(NOTHING)]"			"Placeholder to specify or detect empty values"
	@$(TABLE_M2) "$(_C)[$(TESTING)]"			"Test suite, validates all supported features"
	@$(TABLE_M2) "$(_C)[$(TESTING)-file]"			"Export $(_C)[$(TESTING)]$(_D) results to a plain text file"
	@$(TABLE_M2) "$(_C)[$(CHECKIT)-$(DOFORCE)]"		"Minimized $(_C)[$(CHECKIT)]$(_D) output $(_E)(used for [Requirements])$(_D)"
	@$(TABLE_M2) "$(_C)[$(SUBDIRS)]"			"Expands $(_C)[COMPOSER_SUBDIRS]$(_D) into \`$(_N)*$(_C)-$(SUBDIRS)-$(_N)*$(_D)\` targets"

########################################
# {{{3 $(HELPOUT)-EXAMPLES -------------

.PHONY: $(HELPOUT)-EXAMPLES_%
$(HELPOUT)-EXAMPLES_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Command Examples); fi
	@$(PRINT) "Create documents from source $(_C)[Markdown]$(_D) files"
	@$(PRINT) "$(_E)(see [Formatting Variables])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README).$(EXTN_DEFAULT)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D) $(_E)c_list=\"$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)\"$(_D)"
	@$(ENDOLINE)
	@$(PRINT) "Save a persistent configuration"
	@$(PRINT) "$(_E)(see [Recommended Workflow], [Configuration Settings] and [Special Targets])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)"
	@$(PRINT) "$(CODEBLOCK)$(_C)"'$$EDITOR'"$(_D) $(_M)$(COMPOSER_SETTINGS)"
	@$(PRINT) "$(CODEBLOCK)$(CODEBLOCK)$(_M)$(DO_BOOK)-$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D): $(_E)$(OUT_README)$(COMPOSER_EXT) $(OUT_LICENSE)$(COMPOSER_EXT)$(_D)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(CLEANER)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)"
	@$(ENDOLINE)
	@$(PRINT) "Recursively install and build an entire directory tree"
	@$(PRINT) "$(_E)(see [Recommended Workflow])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)cd$(_D) $(_M).../documents"
	@$(PRINT) "$(CODEBLOCK)$(_C)mv$(_D) $(_M)$(call $(HEADERS)-release,$(COMPOSER_DIR)) .$(COMPOSER_BASENAME)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(INSTALL)-$(DOITALL)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)-$(DOITALL)"
	@$(ENDOLINE)
	@$(PRINT) "See \`$(_C)$(HELPOUT)-$(DOITALL)$(_D)\` for full details and additional targets."

########################################
# {{{2 $(HELPOUT)-$(DOITALL) -----------

.PHONY: $(HELPOUT)-$(TYPE_PRES)
$(HELPOUT)-$(TYPE_PRES):
	@$(RUNMAKE) $(HELPOUT)-$(HEADERS)-$(TYPE_PRES)
	@$(ENDOLINE)
	@$(LINERULE)
	@$(RUNMAKE) $(HELPOUT)

.PHONY: $(HELPOUT)-$(HEADERS)-%
$(HELPOUT)-$(HEADERS)-%:
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TITLE)	; $(call TITLE_LN,1,$(COMPOSER_TECHNAME),0)
		@$(RUNMAKE) $(HELPOUT)-$(DOITALL)-HEADER
		@if [ "$(*)" = "$(DOFORCE)" ] || [ "$(*)" = "$(TYPE_PRES)" ]; then \
		$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS); \
		fi
		@if [ "$(*)" = "$(DOFORCE)" ]; then \
		$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS_EXT); \
		fi
	@$(call TITLE_LN,2,Overview,0)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-OVERVIEW)
	@$(call TITLE_LN,2,Quick Start,0)		; $(PRINT) "Use \`$(_C)$(DOMAKE) $(HELPOUT)$(_D)\` to get started:"
		@$(ENDOLINE); $(RUNMAKE) $(HELPOUT)-USAGE
		@$(ENDOLINE); $(RUNMAKE) $(HELPOUT)-EXAMPLES_0
	@$(call TITLE_LN,2,Principles,0)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-GOALS)
	@$(call TITLE_LN,2,Requirements,0)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE)
		@$(ENDOLINE); $(RUNMAKE) $(CHECKIT)-$(DOFORCE) | $(SED) "/^[^#]*[#]/d"
		@$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE_POST)

#> update: PHONY.*$(DOITALL)
#> update: PHONY.*$(DOFORCE)
#>$(eval export override COMPOSER_DOITALL_$(HELPOUT) ?=)
.PHONY: $(HELPOUT)-%
$(HELPOUT)-%:
#>	@$(RUNMAKE) COMPOSER_DOITALL_$(HELPOUT)="$(*)" $(HELPOUT)
#>
#>.PHONY: $(HELPOUT)-$(DOITALL)
#>$(HELPOUT)-$(DOITALL):
	@$(RUNMAKE) $(HELPOUT)-$(HEADERS)-$(*)
	@$(call TITLE_LN,1,$(COMPOSER_BASENAME) Operation,$(HEAD_MAIN))
	@$(call TITLE_LN,2,Recommended Workflow)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-WORKFLOW)
	@$(call TITLE_LN,2,Document Formatting,0)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-FORMAT)
	@$(call TITLE_LN,2,Configuration Settings,0)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-SETTINGS)
	@$(call TITLE_LN,2,Precedence Rules,0)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-ORDERS)
	@$(call TITLE_LN,2,Specifying Dependencies,0)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-DEPENDS)
	@$(call TITLE_LN,2,Custom Targets,0)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-CUSTOM)
	@$(call TITLE_LN,2,Repository Versions,0)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VERSIONS)
	@$(RUNMAKE) $(HELPOUT)-VARIABLES_TITLE_1
	@$(RUNMAKE) $(HELPOUT)-VARIABLES_FORMAT_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT)
	@$(RUNMAKE) $(HELPOUT)-VARIABLES_CONTROL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL)
	@$(RUNMAKE) $(HELPOUT)-TARGETS_TITLE_1
	@$(RUNMAKE) $(HELPOUT)-TARGETS_PRIMARY_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY)
	@$(RUNMAKE) $(HELPOUT)-TARGETS_SPECIALS_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_SPECIALS)
	@$(RUNMAKE) $(HELPOUT)-TARGETS_ADDITIONAL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL)
	@if [ "$(*)" = "$(DOFORCE)" ]; then \
	$(RUNMAKE) $(HELPOUT)-TARGETS_INTERNAL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL); \
	$(RUNMAKE) --silent $(HELPOUT)-$(DOFORCE)-$(PRINTER); \
	fi
	@$(RUNMAKE) $(HELPOUT)-FOOTER

########################################
# {{{3 $(HELPOUT)-$(DOFORCE) -----------

.PHONY: $(HELPOUT)-$(DOFORCE)-$(PRINTER)
$(HELPOUT)-$(DOFORCE)-$(PRINTER):
	@$(call TITLE_LN,1,Reference,$(HEAD_MAIN))
	@$(ENDOLINE)
	@$(RUNMAKE) --silent $(HELPOUT)-$(DOFORCE)-$(TARGETS)
	@$(call TITLE_LN,2,Templates)
	@$(PRINT) "The $(_C)[$(INSTALL)]$(_D) target \`$(_M)$(MAKEFILE)$(_D)\` template $(_E)(for reference only)$(_D):"
	@$(ENDOLINE); $(RUNMAKE) .$(EXAMPLE)-$(INSTALL) \
		$(if $(COMPOSER_DOCOLOR),,| $(SED) \
			-e "/^[#]{$(DEPTH_MAX)}/d" \
			-e "/^$$/d" \
			-e "s|^|$(CODEBLOCK)|g" \
		)
	@$(ENDOLINE); $(PRINT) "Use the $(_C)[$(EXAMPLE)]$(_D) target to create \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` files:"
	@$(ENDOLINE); $(RUNMAKE) .$(EXAMPLE) \
		$(if $(COMPOSER_DOCOLOR),,| $(SED) \
			-e "/^[#]{$(DEPTH_MAX)}/d" \
			-e "/^$$/d" \
			-e "s|^|$(CODEBLOCK)|g" \
		)
	@$(call TITLE_LN,2,Reserved)
	@$(PRINT) "Reserved target names, including use as prefixes:"
	@$(ENDOLINE)
	@$(eval LIST := $(shell \
			$(ECHO) " \
				$(COMPOSER_RESERVED) \
				$(COMPOSER_RESERVED_SPECIAL) \
				$(addsuffix s,$(COMPOSER_RESERVED_SPECIAL)) \
			" \
			| $(TR) ' ' '\n' \
			| $(SORT) \
		))$(foreach FILE,$(LIST),\
			$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(PRINT) "Reserved variable names:"
	@$(ENDOLINE)
	@$(eval LIST := $(shell \
			$(SED) -n \
				-e "s|^$(call COMPOSER_REGEX_OVERRIDE).*$$|\1|gp" \
				-e "s|^$(call COMPOSER_REGEX_OVERRIDE,,1).*$$|\1|gp" \
				-e "s|^$(call COMPOSER_REGEX_DEFINE).*$$|\2|gp" \
				-e "s|^$(call COMPOSER_REGEX_EVAL,,1).*$$|\2|gp" \
				$(COMPOSER) \
			| $(SORT) \
		))$(foreach FILE,$(LIST),\
			$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
			$(call NEWLINE) \
		)

.PHONY: $(HELPOUT)-$(DOFORCE)-$(TARGETS)
$(HELPOUT)-$(DOFORCE)-$(TARGETS):
	@$(eval LIST := $(shell \
			$(SED) -n "s|^.+[-]SECTION[,]||gp" $(COMPOSER) \
			| $(SED) -e "s|.$$||g" \
			| $(SED) -n "/[/]/p" \
			| $(SED) \
				-e "s|^[[:space:]]+||g" \
				-e "s|[[:space:]]+$$||g" \
				-e "s|[[:space:]]|$(TOKEN)|g" \
				-e "s|\\\\||g" \
		))$(foreach FILE,$(LIST),\
			$(foreach HEAD,$(subst /, ,$(FILE)),\
				$(PRINT) "$(_C)[$(subst $(TOKEN),,$(HEAD))]: #$(shell \
					$(ECHO) "$(subst $(TOKEN), ,$(FILE))" \
					| $(TR) 'A-Z' 'a-z' \
					| $(SED) \
						-e "s|-|DASH|g" \
						-e "s|_|UNDER|g" \
					| $(SED) \
						-e "s|[[:punct:]]||g" \
						-e "s|[[:space:]]|-|g" \
					| $(SED) \
						-e "s|DASH|-|g" \
						-e "s|UNDER|_|g" \
				)"; \
				$(call NEWLINE) \
			) \
		)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(ENDOLINE)
	@$(eval LIST := $(shell \
			$(SED) -n "s|^.+[-]SECTION[,]||gp" $(COMPOSER) \
			| $(SED) -e "s|.$$||g" \
			| $(TR) '/' '\n' \
			| $(SED) \
				-e "s|^[[:space:]]+||g" \
				-e "s|[[:space:]]+$$||g" \
				-e "s|[[:space:]]|$(TOKEN)|g" \
				-e "s|\\\\||g" \
		))$(foreach FILE,$(LIST),\
			$(PRINT) "$(_N)[$(subst $(TOKEN), ,$(FILE))]"; \
			$(call NEWLINE) \
		)
endif

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-TITLE -----

override define $(HELPOUT)-$(DOITALL)-TITLE =
$(_M)% $(COMPOSER_HEADLINE)$(_D)
$(_M)% $(COMPOSER_COMPOSER)$(_D)
$(_M)% $(COMPOSER_VERSION) ($(DATEMARK))$(_D)
endef

.PHONY: $(HELPOUT)-$(DOITALL)-HEADER
$(HELPOUT)-$(DOITALL)-HEADER:
	@$(TABLE_M2) "$(_H)![$(COMPOSER_BASENAME) Icon]"	"$(_H)\"Creating Made Simple.\""
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_FULLNAME)]"		"$(_C)[License: GPL]"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_COMPOSER)]"		"$(_C)[composer@garybgenett.net]"

override define $(HELPOUT)-$(DOITALL)-LINKS =
$(_E)[$(COMPOSER_BASENAME)]: https://github.com/garybgenett/composer$(_D)
$(_E)[License: GPL]: https://github.com/garybgenett/composer/blob/master/LICENSE.md$(_D)
$(_E)[$(COMPOSER_COMPOSER)]: http://www.garybgenett.net/projects/composer$(_D)
$(_E)[composer@garybgenett.net]: mailto:composer@garybgenett.net?subject=$(subst $(NULL) ,%20,$(COMPOSER_TECHNAME))%20Submission&body=Thank%20you%20for%20sending%20a%20message%21$(_D)

$(_S)[$(COMPOSER_FULLNAME)]: https://github.com/garybgenett/composer/tree/$(COMPOSER_VERSION)$(_D)
$(_S)[$(COMPOSER_BASENAME) Icon]: $(subst $(COMPOSER_DIR)/,,$(COMPOSER_ART))/icon-v1.0.png$(_D)
$(_S)[$(COMPOSER_BASENAME) Screenshot]: $(subst $(COMPOSER_DIR)/,,$(COMPOSER_ART))/screenshot-v3.0.png$(_D)
endef

override define $(HELPOUT)-$(DOITALL)-LINKS_EXT =
$(_E)[GNU Make]: http://www.gnu.org/software/make$(_D)
$(_E)[Markdown]: http://daringfireball.net/projects/markdown$(_D)
$(_E)[GitHub]: https://github.com$(_D)

$(_E)[Pandoc]: http://www.johnmacfarlane.net/pandoc$(_D)
$(_E)[YQ]: https://mikefarah.gitbook.io/yq$(_D)
$(_E)[Bootstrap]: https://getbootstrap.com$(_D)
$(_E)[Markdown Viewer]: https://github.com/Thiht/markdown-viewer$(_D)
$(_E)[Reveal.js]: https://revealjs.com$(_D)
$(_E)[TeX Live]: https://tug.org/texlive$(_D)

$(_S)[GNU]: http://www.gnu.org$(_D)
$(_S)[GNU/Linux]: https://gnu.org/gnu/linux-and-gnu.html$(_D)
$(_S)[Windows Subsystem for Linux]: https://docs.microsoft.com/en-us/windows/wsl$(_D)
$(_S)[MacPorts]: https://www.macports.org$(_D)
$(_S)[Git]: https://git-scm.com$(_D)
endef

override define $(HELPOUT)-$(DOITALL)-SECTION =
$(_S)###$(_D) $(_H)$(patsubst _%,\_%,$(1))$(_D) $(_S)###$(_D)
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-OVERVIEW --

override define $(HELPOUT)-$(DOITALL)-OVERVIEW =
**$(_C)[$(COMPOSER_BASENAME)]$(_D) is a simple but powerful CMS based on $(_C)[Pandoc]$(_D), $(_C)[Bootstrap]$(_D) and
$(_C)[GNU Make]$(_D).**  It is a document and website build system that processes
directories or individual files in $(_C)[Markdown]$(_D) format.

Traditionally, CMS stands for $(_M)Content Management System$(_D).  $(_C)[$(COMPOSER_BASENAME)]$(_D) is designed
to be a $(_M)Content **Make** System$(_D).  Written content is vastly easier to manage as
plain text, which can be crafted with simple editors and tracked with revision
control.  However, professional documentation, publications, and websites
require formatting that is dynamic and feature-rich.

$(_C)[Pandoc]$(_D) is an extremely powerful document conversion tool, and is a widely used
standard for processing $(_C)[Markdown]$(_D) into other formats.  While it has reasonable
defaults, there are a large number of options, and additional tools are required
for some formats and features.

$(_C)[$(COMPOSER_BASENAME)]$(_D) consolidates all the necessary components, simplifies the options,
and prettifies the output formats, all in one place.  It also serves as a build
system, so that large repositories can be managed as documentation archives or
published as $(_C)[Bootstrap Websites]$(_D).

$(_S)![$(COMPOSER_BASENAME) Icon]$(_D)
$(_S)![$(COMPOSER_BASENAME) Screenshot]$(_D)
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-GOALS -----

override define $(HELPOUT)-$(DOITALL)-GOALS =
The guiding principles of $(_C)[$(COMPOSER_BASENAME)]$(_D):

  * All source files in readable plain text
  * Professional output, suitable for publication
  * Minimal dependencies, and entirely command-line driven
  * Separate content and formatting; writing and publishing are independent
  * Inheritance and dependencies; global, tree, directory and file overrides
  * Fast; both to initiate commands and for processing to complete

Direct support for key document types $(_E)(see [Document Formatting])$(_D):

  * $(_C)[HTML]$(_D) & $(_C)[Bootstrap Websites]$(_D)
  * $(_C)[PDF]$(_D)
  * $(_C)[EPUB]$(_D)
  * $(_C)[Reveal.js Presentations]$(_D)
  * $(_C)[Microsoft Word & PowerPoint]$(_D)
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-REQUIRE ---

override define $(HELPOUT)-$(DOITALL)-REQUIRE =
$(_C)[$(COMPOSER_BASENAME)]$(_D) has almost no external dependencies.  All needed components are
integrated directly into the repository, including $(_C)[Pandoc]$(_D).  It does require a
minimal command-line environment based on $(_N)[GNU]$(_D) tools, which is standard for all
$(_N)[GNU/Linux]$(_D) systems.  The $(_N)[Windows Subsystem for Linux]$(_D) for Windows and
$(_N)[MacPorts]$(_D) for macOS both provide suitable environments.

The one large external requirement is $(_C)[TeX Live]$(_D), and it can be installed using
the package managers of each of the above systems.  It is only necessary for
creating $(_C)[PDF]$(_D) files.

Below are the versions of the components in the repository, and the tested
versions of external tools for this iteration of $(_C)[$(COMPOSER_BASENAME)]$(_D).  Use $(_C)[$(CHECKIT)]$(_D) to
validate your system.
endef

override define $(HELPOUT)-$(DOITALL)-REQUIRE_POST =
$(_C)[Markdown Viewer]$(_D) is included both for its $(_M)CSS$(_D) stylesheets, and for real-time
rendering of $(_C)[Markdown]$(_D) files as they are being written.  To install, follow the
instructions in the `$(_M)README.md$(_D)`, and select the appropriate `$(_M)manifest.$(_N)*$(_M).json$(_D)`
file for your browser.

The versions of the integrated repositories can be changed, if desired $(_E)(see
[Repository Versions])$(_D).
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-WORKFLOW --

override define $(HELPOUT)-$(DOITALL)-WORKFLOW =
The ideal workflow is to put $(_C)[$(COMPOSER_BASENAME)]$(_D) in a top-level `$(_M).$(COMPOSER_BASENAME)$(_D)` for each
directory tree you want to manage, creating a structure similar to this:

$(CODEBLOCK).../$(_M).$(COMPOSER_BASENAME)$(_D)
$(CODEBLOCK).../
$(CODEBLOCK).../tld/
$(CODEBLOCK).../tld/sub/

Then, it can be converted to a $(_C)[$(COMPOSER_BASENAME)]$(_D) documentation archive $(_E)([Quick Start]
example)$(_D):

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(INSTALL)-$(DOITALL)$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)-$(DOITALL)$(_D)

If specific settings need to be used, either globally or per-directory,
`$(_M)$(COMPOSER_SETTINGS)$(_D)` files can be created $(_E)(see [Configuration Settings], [Quick Start]
example)$(_D):

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(_C)$$EDITOR$(_D) $(_M)$(COMPOSER_SETTINGS)$(_D)

Custom targets can also be defined, using standard $(_C)[GNU Make]$(_D) syntax $(_E)(see
[Custom Targets])$(_D).

$(_C)[GNU Make]$(_D) does not support file and directory names with spaces in them, and
neither does $(_C)[$(COMPOSER_BASENAME)]$(_D).  Documentation archives which have such files or
directories will produce unexpected results.

It is fully supported for input files to be symbolic links to files that reside
outside the documentation archive:

$(CODEBLOCK)$(_C)cd$(_D) $(_M).../tld$(_D)
$(CODEBLOCK)$(_C)ln$(_D) $(_N)-rs .../$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D) $(_M)./$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README).$(EXTN_DEFAULT)$(_D)

Finally, it is best practice to $(_C)[$(INSTALL)-$(DOFORCE)]$(_D) after every $(_C)[$(COMPOSER_BASENAME)]$(_D) upgrade,
in case there are any changes to the `$(_M)$(MAKEFILE)$(_D)` template $(_E)(see [Primary
Targets])$(_D).

The archive is ready, and each directory is both a part of the collective and
its own individual instance.  Targets can be run per-file, per-directory, or
recursively through an entire directory tree.  The most commonly used targets
are in $(_C)[Primary Targets]$(_D).

$(_H)**Welcome to [$(COMPOSER_BASENAME)].  $(COMPOSER_TAGLINE)**$(_D)
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-FORMAT ----

override define $(HELPOUT)-$(DOITALL)-FORMAT =
As outlined in $(_C)[Overview]$(_D) and $(_C)[Principles]$(_D), a primary goal of $(_C)[$(COMPOSER_BASENAME)]$(_D) is to
produce beautiful and professional output.  $(_C)[Pandoc]$(_D) does reasonably well at
this, and yet its primary focus is document conversion, not document formatting.
$(_C)[$(COMPOSER_BASENAME)]$(_D) fills this gap by specifically tuning a select list of the most
commonly used document formats.

Further options for each document type are in $(_C)[Formatting Variables]$(_D).  All
improvements not exposed as variables will apply to all documents created with a
given instance of $(_C)[$(COMPOSER_BASENAME)]$(_D).

Note that all the files referenced below are embedded in the '$(_E)Embedded Files$(_D)'
and '$(_E)Heredoc$(_D)' sections of the `$(_M)$(MAKEFILE)$(_D)`.  They are exported by the
$(_C)[$(DISTRIB)]$(_D) target, and will be overwritten whenever it is run.

$(call $(HELPOUT)-$(DOITALL)-SECTION,HTML)

In addition to being a helpful real-time rendering tool, $(_C)[Markdown Viewer]$(_D)
includes several $(_M)CSS$(_D) stylesheets that are much more visually appealing than the
$(_C)[Pandoc]$(_D) default, and which behave like normal webpages, so $(_C)[$(COMPOSER_BASENAME)]$(_D) uses them
for all $(_C)[HTML]$(_D)-based document types, including $(_C)[EPUB]$(_D).

Information on installing $(_C)[Markdown Viewer]$(_D) for use as a $(_C)[Markdown]$(_D) rendering
tool is in $(_C)[Requirements]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,Bootstrap Websites)

$(_C)[Bootstrap]$(_D) is a leading web development framework, capable of building static
webpages that behave dynamically.  Static sites are very easy and inexpensive to
host, and are extremely responsive compared to truly dynamic webpages.

$(_C)[$(COMPOSER_BASENAME)]$(_D) uses this framework to transform an archive of simple text files into
a modern website, with the appearance and behavior of dynamically indexed pages.

$(_N)*(This feature is reserved for a future release as the [$(PUBLISH)] target, along with
[$(DO_PAGE)] and [$(DO_POST)] in [Special Targets].)*$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,PDF)

The default formatting for $(_C)[PDF]$(_D) is geared towards academic papers and the
typesetting of printed books, instead of documents that are intended to be
purely digital.

Internally, $(_C)[Pandoc]$(_D) first converts to $(_M)LaTeX$(_D), and then uses $(_C)[TeX Live]$(_D) to
convert into the final $(_C)[PDF]$(_D).  $(_C)[$(COMPOSER_BASENAME)]$(_D) inserts customized $(_M)LaTeX$(_D) to modify the
final output:

$(CODEBLOCK)$(subst $(COMPOSER_DIR)/,.../$(_M),$(TEX_PDF_TEMPLATE))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,EPUB)

The $(_C)[EPUB]$(_D) format is essentially packaged $(_C)[HTML]$(_D), so $(_C)[$(COMPOSER_BASENAME)]$(_D) uses the same
$(_C)[Markdown Viewer]$(_D) $(_M)CSS$(_D) stylesheets for it.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Reveal.js Presentations)

The $(_M)CSS$(_D) for $(_C)[Reveal.js]$(_D) presentations has been modified to create a more
traditional and readable end result.  The customized version is at:

$(CODEBLOCK)$(subst $(COMPOSER_DIR)/,.../$(_M),$(REVEALJS_CSS))$(_D)

It links in a default theme from the `$(subst $(COMPOSER_DIR)/,.../$(_M),$(REVEALJS_DIR))/dist/theme$(_D)` directory.  Edit
the location in the file, or use $(_C)[c_css]$(_D) to select a different theme.

It is set up so that a logo can be placed in the upper right hand corner on each
slide, for presentations that need to be branded.  Simply copy an image file to
the logo location:

$(CODEBLOCK)$(subst $(COMPOSER_DIR)/,.../$(_M),$(REVEALJS_LOGO))$(_D)

To have different logos for different directories $(_E)(using [Recommended Workflow],
[Configuration Settings] and [Precedence Rules])$(_D):

$(CODEBLOCK)$(_C)cd$(_D) $(_M).../presentations$(_D)
$(CODEBLOCK)$(_C)cp$(_D) $(_N).../$(notdir $(REVEALJS_LOGO))$(_D) $(_M)./$(_D)
$(CODEBLOCK)$(_C)ln$(_D) $(_N)-rs .../$(subst $(COMPOSER_DIR),.$(COMPOSER_BASENAME),$(REVEALJS_CSS))$(_D) $(_M)./$(COMPOSER_CSS)$(_D)
$(CODEBLOCK)$(_C)echo$(_D) $(_N)'$(_E)override c_type := $(TYPE_PRES)'$(_D) >>$(_M)./$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,Microsoft Word & PowerPoint)

The internal $(_C)[Pandoc]$(_D) templates for these are exported by $(_C)[$(COMPOSER_BASENAME)]$(_D), so they
are available for customization:

$(CODEBLOCK)$(subst $(COMPOSER_DIR)/,.../$(_M),$(COMPOSER_ART))/reference.$(EXTN_DOCX)$(_D)
$(CODEBLOCK)$(subst $(COMPOSER_DIR)/,.../$(_M),$(COMPOSER_ART))/reference.$(EXTN_PPTX)$(_D)

They are not currently modified by $(_C)[$(COMPOSER_BASENAME)]$(_D).
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-SETTINGS --

override define $(HELPOUT)-$(DOITALL)-SETTINGS =
$(_C)[$(COMPOSER_BASENAME)]$(_D) uses `$(_M)$(COMPOSER_SETTINGS)$(_D)` files for persistent settings and definition of
$(_C)[Custom Targets]$(_D).  By default, they only apply to the directory they are in $(_E)(see
[COMPOSER_INCLUDE] in [Control Variables])$(_D).  The values in the most local file
override all others $(_E)(see [Precedence Rules])$(_D).

The easiest way to create a new `$(_M)$(COMPOSER_SETTINGS)$(_D)` is with the $(_C)[$(EXAMPLE)]$(_D) target
$(_E)([Quick Start] example)$(_D):

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(_C)$$EDITOR$(_D) $(_M)$(COMPOSER_SETTINGS)$(_D)

All variable definitions must be in the `$(_N)override [variable] := [value]$(_D)` format
from the $(_C)[$(EXAMPLE)]$(_D) target.  Doing otherwise will result in unexpected behavior,
and is not supported.  The regular expression that is used to detect them:

$(CODEBLOCK)$(_N)$(COMPOSER_REGEX_OVERRIDE)$(_D)

Variables can also be specified per-target, using $(_C)[GNU Make]$(_D) syntax $(_E)(these are
the settings used to process the [$(COMPOSER_BASENAME)] `$(OUT_README).*` files)$(_D):

$(CODEBLOCK)$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_css := $(CSS_ALT)$(_D)
$(CODEBLOCK)$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_toc := $(SPECIAL_VAL)$(_D)
$(CODEBLOCK)$(_M)$(OUT_README).$(EXTN_EPUB)$(_D): $(_E)override c_css :=$(_D)
$(CODEBLOCK)$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_css :=$(_D)
$(CODEBLOCK)$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_toc :=$(_D)

In this case, there are multiple definitions that could apply to
`$(_M)$(OUT_README).$(EXTN_PRES)$(_D)`, due to the `$(_N)%$(_D)` wildcard.  Since the most specific target
match is used, the final values for both $(_C)[c_css]$(_D) and $(_C)[c_toc]$(_D) would be empty.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-ORDERS ----

override define $(HELPOUT)-$(DOITALL)-ORDERS =
The order of precedence for `$(_M)$(COMPOSER_SETTINGS)$(_D)` files is global-to-local $(_E)(see
[COMPOSER_INCLUDE] in [Control Variables])$(_D).  This means that the values in the
most local file override all others.

Variable aliases, such as `$(_C)COMPOSER_DEBUGIT$(_D)`/`$(_E)c_debug$(_D)`/`$(_E)V$(_D)` are prioritized in
the order shown, with `$(_C)COMPOSER_*$(_D)` taking precedence over `$(_E)c_*$(_D)`, over the short
alias.

Selection of the $(_M)CSS$(_D) file can be done using `$(_M)$(COMPOSER_CSS)$(_D)` or the $(_C)[c_css]$(_D)
variable, with `$(_M)$(COMPOSER_CSS)$(_D)` taking precedence $(_E)(unless [c_css] comes from
`$(COMPOSER_SETTINGS)`)$(_D).  The process for `$(_M)$(COMPOSER_CSS)$(_D)` files is identical to
`$(_M)$(COMPOSER_SETTINGS)$(_D)` $(_E)(see [COMPOSER_INCLUDE] in [Control Variables])$(_D).

All values in `$(_M)$(COMPOSER_SETTINGS)$(_D)` take precedence over everything else, including
`$(_M)$(COMPOSER_CSS)$(_D)` and environment variables.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-DEPENDS ---

override define $(HELPOUT)-$(DOITALL)-DEPENDS =
If there are files or directories that have dependencies on other files or
directories being processed first, this can be done simply using $(_C)[GNU Make]$(_D)
syntax in `$(_M)$(COMPOSER_SETTINGS)$(_D)`:

$(CODEBLOCK)$(_M)$(OUT_LICENSE).$(EXTN_DEFAULT)$(_D): $(_E)$(OUT_README).$(EXTN_DEFAULT)$(_D)
$(CODEBLOCK)$(_M)$(DOITALL)-$(SUBDIRS)-$(notdir $(COMPOSER_ART))$(_D): $(_E)$(DOITALL)-$(SUBDIRS)-$(notdir $(BOOTSTRAP_DIR))$(_D)

This would require `$(_E)$(OUT_README).$(EXTN_DEFAULT)$(_D)` to be completed before `$(_M)$(OUT_LICENSE).$(EXTN_DEFAULT)$(_D)`, and for
`$(_E)$(notdir $(BOOTSTRAP_DIR))$(_D)` to be processed before `$(_M)$(notdir $(COMPOSER_ART))$(_D)`.  Directories need to be
specified with the `$(_C)$(DOITALL)-$(SUBDIRS)-$(_N)*$(_C)$(_D)` syntax in order to avoid conflicts with
target names $(_E)(see [Custom Targets])$(_D).  Good examples of this are the internal
$(_C)[$(CREATOR)]$(_D) and $(_C)[$(TESTING)]$(_D) targets, which are common directory names.

Chaining of dependencies can be as complex and layered as $(_C)[GNU Make]$(_D) will
support.  Note that if a file or directory is set to depend on a target, that
target will be run whenever the file or directory is called.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-CUSTOM ----

override define $(HELPOUT)-$(DOITALL)-CUSTOM =
If needed, custom targets can be defined inside a `$(_M)$(COMPOSER_SETTINGS)$(_D)` file $(_E)(see
[Configuration Settings])$(_D), using standard $(_C)[GNU Make]$(_D) syntax.  Naming them as
$(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) or $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) will include them in runs of the respective targets.
Targets with any other names will need to be run manually, or included in
$(_C)[COMPOSER_TARGETS]$(_D) $(_E)(see [Control Variables])$(_D).

There are a few limitations when naming custom targets.  Targets starting with
the regular expression `$(_N)$(COMPOSER_REGEX_PREFIX)$(_D)` are hidden, and are skipped by auto-detection.
Additionally, there is a list of reserved targets in $(_C)[Reserved]$(_D), along with a
list of reserved variables.

Any included `$(_M)$(COMPOSER_SETTINGS)$(_D)` files are sourced early in the main $(_C)[$(COMPOSER_BASENAME)]$(_D)
`$(_M)$(MAKEFILE)$(_D)`, so matching targets and most variables will be overridden.  In the
case of conflicting targets, $(_C)[GNU Make]$(_D) will produce warning messages.
Variables will have their values changed silently.  Changing the values of
internal $(_C)[$(COMPOSER_BASENAME)]$(_D) variables is not recommended or supported.

A final note is that $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) and $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) targets are stripped from
$(_C)[COMPOSER_TARGETS]$(_D).  In cases where this results in an empty $(_C)[COMPOSER_TARGETS]$(_D),
there will be a message and no actions will be taken.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-VERSIONS --

#> update: PHONY.*(UPGRADE)

override define $(HELPOUT)-$(DOITALL)-VERSIONS =
There are a few internal variables used by $(_C)[$(UPGRADE)]$(_D) to select the repository
and binary versions of integrated components $(_E)(see [Requirements])$(_D).  These are
exposed for configuration, but only within `$(_M)$(COMPOSER_SETTINGS)$(_D)`:

  * `$(_C)PANDOC_VER$(_D)` $(_E)(must be a binary version number)$(_D)
  * `$(_C)PANDOC_CMT$(_D)` $(_E)(defaults to `PANDOC_VER`)$(_D)
  * `$(_C)YQ_VER$(_D)` $(_E)(must be a binary version number)$(_D)
  * `$(_C)YQ_CMT$(_D)` $(_E)(defaults to `YQ_VER`)$(_D)
  * `$(_C)BOOTSTRAP_CMT$(_D)`
  * `$(_C)MDVIEWER_CMT$(_D)`
  * `$(_C)REVEALJS_CMT$(_D)`

Binaries for $(_C)[Pandoc]$(_D) and $(_C)[YQ]$(_D) are installed in their respective directories.
By moving or removing them, or changing the version number and foregoing
$(_C)[$(UPGRADE)-$(DOITALL)]$(_D) $(_E)(see [Additional Targets])$(_D), the system versions will be used
instead.  This will work as long as the commit versions match, so that
supporting files are in alignment.

It is possible that changing the versions will introduce incompatibilities with
$(_C)[$(COMPOSER_BASENAME)]$(_D), which are usually impacts to the prettification of output files
$(_E)(see [Document Formatting])$(_D).
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT

override define $(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT =
$(call $(HELPOUT)-$(DOITALL)-SECTION,c_type / c_base / c_list)

The $(_C)[$(COMPOSER_PANDOC)]$(_D) target uses these variables to decide what to build and how.  The
output file is `$(_C)[c_base]$(_D).$(_M)<extension>$(_D)`, and is constructed from the $(_C)[c_list]$(_D) input
files, in order.  The `$(_M)<extension>$(_D)` is selected based on the $(_C)[c_type]$(_D) table
above.  Generally, it is not required to use the $(_C)[$(COMPOSER_PANDOC)]$(_D) target directly for
supported $(_C)[c_type]$(_D) files, since it is run automatically based on what output
file `$(_M)<extension>$(_D)` is specified.

The automatic input file detection works by matching one of the following
$(_E)([Quick Start] example)$(_D):

$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README).$(EXTN_DEFAULT)$(_D)"				"~ $(_E)$(OUT_README)$(_D) $(_N)(empty [COMPOSER_EXT])$(_D)")
$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README).$(EXTN_DEFAULT)$(_D)"				"~ $(_E)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)")
$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT).$(EXTN_DEFAULT)$(_D)"	"~ $(_E)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)")
$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D)"				"$(_E)c_list=\"$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)\"$(_D)")

Other values for $(_C)[c_type]$(_D), such as `$(_M)json$(_D)` or `$(_M)man$(_D)`, for example, can be passed
through to $(_C)[Pandoc]$(_D) manually:

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(COMPOSER_PANDOC)$(_D) $(_E)c_type="json" c_base="$(OUT_README)" c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT)"$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(COMPOSER_PANDOC)$(_D) $(_E)c_type="man" c_base="$(OUT_MANUAL)" c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT)"$(_D)

Any of the file types supported by $(_C)[Pandoc]$(_D) can be created this way.  The only
limitation is that the input files must be in $(_C)[Markdown]$(_D) format.

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_lang)

  * Primarily for $(_C)[PDF]$(_D), this specifies the language that the table of contents
    ($(_C)[c_toc]$(_D)) and chapter headings ($(_C)[c_level]$(_D)) will use.

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_css)

  * By default, a $(_M)CSS$(_D) stylesheet from $(_C)[Markdown Viewer]$(_D) is used for $(_C)[HTML]$(_D) and
    $(_C)[EPUB]$(_D), and one of the $(_C)[Reveal.js]$(_D) themes is used for $(_C)[Reveal.js
    Presentations]$(_D).  This variable allows for selection of a different file in
    all cases.
  * The special value `$(_N)$(CSS_ALT)$(_D)` selects the alternate default stylesheet.  Using
    `$(_N)$(SPECIAL_VAL)$(_D)` reverts to the $(_C)[Pandoc]$(_D) default.
  * This value can be overridden by the presence of `$(_M)$(COMPOSER_CSS)$(_D)` files.  See
    $(_C)[Precedence Rules]$(_D) for details.

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_toc)

  * Setting this to a value of `$(_N)[1-$(DEPTH_MAX)]$(_D)` creates a table of contents at the
    beginning of the document.  The numerical value is how many header levels
    deep the table should go.  A value of `$(_N)$(DEPTH_MAX)$(_D)` lists all header levels.
  * Using a value of `$(_N)$(SPECIAL_VAL)$(_D)` lists all header levels, and additionally numbers all
    the sections, for reference.

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_level)

  * This value has different effects, depending on the $(_C)[c_type]$(_D) of the output
    document.
  * For $(_C)[HTML]$(_D), any value enables `$(_E)section-divs$(_D)`, which wraps headings and their
    section content in `$(_E)<section>$(_D)` tags and attaches identifiers to them instead
    of the headings themselves.  This is for $(_M)CSS$(_D) styling, and is generally
    desired.
  * For $(_C)[PDF]$(_D), there are 3 top-level division types: `$(_M)part$(_D)`, `$(_M)chapter$(_D)`, and
    `$(_M)section$(_D)`.  This sets the top-level header to the specified type, which
    changes the way the document is presented.  Using `$(_M)part$(_D)` divides the
    document into "$(_N)Parts$(_D)", each starting with a stand-alone title page.  With
    this division type, each second-level heading starts a new "$(_N)Chapter$(_D)".  A
    `$(_M)chapter$(_D)` simply starts a new section on a new page, and lower-level
    headings continue as running portions within it.  Finally, `$(_M)section$(_D)` creates
    one long running document with no blank pages or section breaks $(_E)(like a
    [HTML] page)$(_D).  To set the desired value:
      * `$(_M)part$(_D)` ~ `$(_N)$(SPECIAL_VAL)$(_D)`
      * `$(_M)chapter$(_D)` ~ `$(_N)$(DEPTH_DEFAULT)$(_D)`
      * `$(_M)section$(_D)` ~ Any other value
  * For $(_C)[EPUB]$(_D), this creates chapter breaks at the specified level, starting the
    section on a new page.  The special `$(_N)$(SPECIAL_VAL)$(_D)` simply sets it to the default value
    of `$(_N)$(DEPTH_DEFAULT)$(_D)`.
  * For $(_C)[Reveal.js Presentations]$(_D), the top-level headings can persist on the
    screen when moving through slides in their sections, or they can rotate out
    as their own individual slides.  Setting to `$(_N)$(SPECIAL_VAL)$(_D)` enables persistent headings,
    and all other values use the default.
  * An empty value defers to the $(_C)[Pandoc]$(_D) defaults in all cases.

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_margin)

  * The default margins for $(_C)[PDF]$(_D) are formatted for typesetting of printed
    books, where there is a large amount of open space around the edges and the
    text on each page is shifted away from where the binding would be.  This is
    generally not what is desired in a purely digital $(_C)[PDF]$(_D) document.
  * This is one value for all the margins.  Setting it to an empty value exposes
    variables for each of the individual margins: `$(_C)c_margin_top$(_D)`,
    `$(_C)c_margin_bottom$(_D)`, `$(_C)c_margin_left$(_D)` and `$(_C)c_margin_right$(_D)`.

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_options)

  * In some cases, it may be desirable to add additional $(_C)[Pandoc]$(_D) options.
    Anything put in this variable will be passed directly to $(_C)[Pandoc]$(_D) as
    additional command-line arguments.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL

override define $(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL =
$(call $(HELPOUT)-$(DOITALL)-SECTION,MAKEJOBS)

  * By default, $(_C)[$(COMPOSER_BASENAME)]$(_D) progresses linearly, doing one task at a time.  If
    there are dependencies between items, this can be beneficial, since it
    ensures things will happen in a particular order.  The downside, however, is
    that it is very slow.
  * $(_C)[$(COMPOSER_BASENAME)]$(_D) supports $(_C)[GNU Make]$(_D) parallel execution, where multiple threads
    can be working through tasks independently.  Experiment with lower values
    first.  When recursing through large directories, each `$(_C)$(DOMAKE)$(_D)` that
    instantiates into a sub-directory has it's own jobs server, so the total
    number of threads running can proliferate rapidly.
  * This can drastically speed up execution, processing thousands of files and
    directories in minutes.  However, values that are too high can exhaust
    system resources.  With great power comes great responsibility.
  * A value of `$(_N)$(SPECIAL_VAL)$(_D)` does parallel execution with no thread limit.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DOCOLOR)

  * $(_C)[$(COMPOSER_BASENAME)]$(_D) uses colors to make all output and $(_C)[$(HELPOUT)]$(_D) text easier to read.
    The escape sequences used to accomplish this can create mixed results when
    reading in an output file or a `$(_C)$$PAGER$(_D)`, or just make it harder to read for
    some.
  * This is also used internally for targets like $(_C)[$(DEBUGIT)-file]$(_D) and $(_C)[$(EXAMPLE)]$(_D),
    where plain text is required.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DEBUGIT)

  * Provides more explicit details about what is happening at each step.
    Produces a lot more output, and can be slower.  It will also be hard to read
    unless $(_C)[MAKEJOBS]$(_D) is set to `$(_N)$(MAKEJOBS_DEFAULT)$(_D)`.
  * Full tracing using `$(_N)$(SPECIAL_VAL)$(_D)` also displays $(_C)[GNU Make]$(_D) debugging output.
  * *When doing $(_C)[$(DEBUGIT)]$(_D), this is used to pass a list of targets to test $(_E)(see
    [Additional Targets])$(_D).*

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_INCLUDE)

  * On every run, $(_C)[$(COMPOSER_BASENAME)]$(_D) walks through the `$(_M)MAKEFILE_LIST$(_D)`, all the way back
    to the main `$(_M)$(MAKEFILE)$(_D)`, looking for `$(_M)$(COMPOSER_SETTINGS)$(_D)` files in each directory.
    By default, it only reads the one in its main directory and the current
    directory, in that order.  Enabling this causes all of them to be read.
  * In the example directory tree below, normally the `$(_M)$(COMPOSER_SETTINGS)$(_D)` in
    `$(_M).$(COMPOSER_BASENAME)$(_D)` is read first, and then `$(_M)tld/sub/$(COMPOSER_SETTINGS)$(_D)`.  With this
    enabled, it will read all of them in order from top to bottom:
    `$(_M).$(COMPOSER_BASENAME)/$(COMPOSER_SETTINGS)$(_D)`, `$(_M)$(COMPOSER_SETTINGS)$(_D)`, `$(_M)tld/$(COMPOSER_SETTINGS)$(_D)`, and finally
    `$(_M)tld/sub/$(COMPOSER_SETTINGS)$(_D)`.
  * This is why it is best practice to have a `$(_M).$(COMPOSER_BASENAME)$(_D)` directory at the top
    level for each documentation archive $(_E)(see [Recommended Workflow])$(_D).  Not only
    does it allow for strict version control of $(_C)[$(COMPOSER_BASENAME)]$(_D) per-archive, it also
    provides a mechanism for setting $(_C)[$(COMPOSER_BASENAME) Variables]$(_D) globally.
  * Care should be taken setting "$(_N)Local$(_D)" variables from $(_C)[$(EXAMPLE)]$(_D) $(_E)(see
    [Templates])$(_D) when using this option.  In that case, they will be propagated
    down the tree.  This may be desired in some cases, but it will require that
    each directory set these manually, which could require a lot of maintenance.
  * This setting also causes `$(_M)$(COMPOSER_CSS)$(_D)` files to be processed in an
    identical manner $(_E)(see [Precedence Rules])$(_D).

Example directory tree $(_E)(see [Recommended Workflow])$(_D):

$(CODEBLOCK).../$(_M).$(COMPOSER_BASENAME)$(_D)/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../$(_M).$(COMPOSER_BASENAME)$(_D)/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK).../$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK).../tld/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../tld/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK).../tld/sub/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../tld/sub/$(_M)$(COMPOSER_SETTINGS)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DEPENDS)

  * When doing $(_C)[$(DOITALL)-$(DOITALL)]$(_D), $(_C)[$(COMPOSER_BASENAME)]$(_D) will process the current directory before
    recursing into sub-directories.  This reverses that, and sub-directories
    will be processed first.
  * In the example directory tree in $(_C)[COMPOSER_INCLUDE]$(_D) above, the default would
    be: `$(_M).../$(_D)`, `$(_M).../tld$(_D)`, and then `$(_M).../tld/sub$(_D)`.  If the higher-level
    directories have dependencies on the sub-directories being run first, this
    will support that by doing them in reverse order, processing them from
    bottom to top.
  * It should be noted that enabling this disables $(_C)[MAKEJOBS]$(_D), to ensure linear
    processing, and that it has no effect on $(_C)[$(INSTALL)]$(_D) or $(_C)[$(CLEANER)]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_LOG)

  * $(_C)[$(COMPOSER_BASENAME)]$(_D) appends to a `$(_M)$(COMPOSER_LOG_DEFAULT)$(_D)` log file in the current directory
    whenever it executes $(_C)[Pandoc]$(_D).  This provides some accounting, and is used
    by $(_C)[$(PRINTER)]$(_D) to determine which `$(_N)*$(_M)$(COMPOSER_EXT_DEFAULT)$(_D)` files have been updated since the last
    time $(_C)[$(COMPOSER_BASENAME)]$(_D) was run.
  * This setting can change the name of the log file, or disable it completely
    $(_E)(empty value)$(_D).
  * It is removed each time $(_C)[$(CLEANER)]$(_D) is run.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_EXT)

  * The $(_C)[Markdown]$(_D) file extension $(_C)[$(COMPOSER_BASENAME)]$(_D) uses: `$(_N)*$(_M)$(COMPOSER_EXT_DEFAULT)$(_D)`.  This is for
    auto-detection of files to add to $(_C)[COMPOSER_TARGETS]$(_D), files to output for
    $(_C)[$(PRINTER)]$(_D), and other tasks.  This is a widely used standard, including
    $(_C)[GitHub]$(_D).  Another commonly used extension is: `$(_N)*$(_M).$(INPUT)$(_D)`.
  * In some cases, they do not have any extension, such as `$(_M)$(OUT_README)$(_D)` and
    `$(_M)$(OUT_LICENSE)$(_D)` in source code directories.  Setting this to an empty value causes
    them to be detected and output.  It also causes all other files to be
    processed, because it becomes the wildcard `$(_N)*$(_D)`, so use with care.  It is
    likely best to use $(_C)[COMPOSER_TARGETS]$(_D) to explicitly set the targets list in
    these situations.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_TARGETS)

  * The list of output files to create or delete with $(_C)[$(CLEANER)]$(_D) and $(_C)[$(DOITALL)]$(_D).
    $(_C)[$(COMPOSER_BASENAME)]$(_D) does auto-detection using $(_C)[c_type]$(_D) and $(_C)[COMPOSER_EXT]$(_D), so this
    does not usually need to be set.  Hidden files that start with `$(_M).$(_D)` are
    skipped.
  * Setting this manually disables auto-detection.  It can also include non-file
    targets added into a `$(_M)$(COMPOSER_SETTINGS)$(_D)` file $(_E)(see [Custom Targets])$(_D).
  * The `$(_M)$(NOTHING)$(_D)` target is special, and when used as a value for
    $(_C)[COMPOSER_TARGETS]$(_D) or $(_C)[COMPOSER_SUBDIRS]$(_D) it will display a message and
    do nothing.  A side-effect of this target is that an actual file or
    directory named `$(_M)$(NOTHING)$(_D)` will never be created or removed by $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * An empty value triggers auto-detection
  * Use $(_C)[$(CONFIGS)]$(_D) or $(_C)[$(TARGETS)]$(_D) to check the current value.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_SUBDIRS)

  * The list of sub-directories to recurse into with $(_C)[$(INSTALL)]$(_D), $(_C)[$(CLEANER)]$(_D), and
    $(_C)[$(DOITALL)]$(_D).  The behavior and configuration is identical to $(_C)[COMPOSER_TARGETS]$(_D)
    above, including auto-detection and the `$(_M)$(NOTHING)$(_D)` target.  Hidden directories
    that start with `$(_M).$(_D)` are skipped.
  * An empty value triggers auto-detection
  * Use $(_C)[$(CONFIGS)]$(_D) or $(_C)[$(TARGETS)]$(_D) to check the current value.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_IGNORES)

  * The list of $(_C)[COMPOSER_TARGETS]$(_D) and $(_C)[COMPOSER_SUBDIRS]$(_D) to skip with
    $(_C)[$(INSTALL)]$(_D), $(_C)[$(CLEANER)]$(_D), and $(_C)[$(DOITALL)]$(_D).  This allows for selective auto-detection,
    when the list of items to process is larger than those to leave alone.
  * Use $(_C)[$(CONFIGS)]$(_D) to check the current value.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY

override define $(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY =
$(call $(HELPOUT)-$(DOITALL)-SECTION,$(HELPOUT) / $(HELPOUT)-$(DOITALL))

  * Outputs all of the documentation for $(_C)[Composer]$(_D).  The `$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)` has a few
    extra sections covering internal targets, along with reserved target and
    variable names, but is otherwise identical to the $(_C)[$(HELPOUT)-$(DOITALL)]$(_D) output.

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(EXAMPLE))

  * Prints a useful template for creating new `$(_M)$(COMPOSER_SETTINGS)$(_D)` files $(_E)(see
    [Configuration Settings] and [Templates])$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(COMPOSER_PANDOC))

  * This is the very core of $(_C)[$(COMPOSER_BASENAME)]$(_D), and does the actual work of the
    $(_C)[Pandoc]$(_D) conversion.  Details are in the $(_C)[c_type / c_base / c_list]$(_D) section
    of $(_C)[Formatting Variables]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(PUBLISH))

  * $(_N)*(This feature is reserved for a future release to create [Bootstrap
    Websites].  It will also include [$(DO_PAGE)] and [$(DO_POST)] from [Special Targets].)*$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(INSTALL) / $(INSTALL)-$(DOITALL) / $(INSTALL)-$(DOFORCE))

  * Creates the necessary `$(_M)$(MAKEFILE)$(_D)` files to set up a directory or a directory
    tree as a $(_C)[$(COMPOSER_BASENAME)]$(_D) archive.  By default, it will not overwrite any
    existing files.
  * Doing a simple $(_C)[$(INSTALL)]$(_D) will only create a file in the current directory,
    whereas $(_C)[$(INSTALL)-$(DOITALL)]$(_D) will recurse through the entire directory tree.  A
    full $(_C)[$(INSTALL)-$(DOFORCE)]$(_D) is the same as $(_C)[$(INSTALL)-$(DOITALL)]$(_D), with the exception that
    it will overwrite all `$(_M)$(MAKEFILE)$(_D)` files.
  * The topmost directory will have the `$(_M)$(MAKEFILE)$(_D)` created for it modified to
    point to $(_C)[$(COMPOSER_BASENAME)]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CLEANER) / $(CLEANER)-$(DOITALL) / \*-$(CLEANER))

  * Deletes all $(_C)[COMPOSER_TARGETS]$(_D) output files in the current directory, after
    first running all $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) targets, including those for $(_C)[Specials]$(_D).
  * Doing $(_C)[$(CLEANER)-$(DOITALL)]$(_D) does the same thing recursively, through all the
    $(_C)[COMPOSER_SUBDIRS]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DOITALL) / $(DOITALL)-$(DOITALL) / \*-$(DOITALL))

  * Creates all $(_C)[COMPOSER_TARGETS]$(_D) output files in the current directory, after
    first running all $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) targets, including those for $(_C)[Specials]$(_D).
  * Doing $(_C)[$(DOITALL)-$(DOITALL)]$(_D) does the same thing recursively, through all the
    $(_C)[COMPOSER_SUBDIRS]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(PRINTER))

  * Outputs all the $(_C)[COMPOSER_EXT]$(_D) files that have been modified since
    $(_C)[COMPOSER_LOG]$(_D) was last updated $(_E)(see both in [Control Variables])$(_D).  Acts as
    a quick reference to see if anything has changed.
  * Since the $(_C)[COMPOSER_LOG]$(_D) file is updated whenever $(_C)[Pandoc]$(_D) is executed, this
    target will primarily be useful when $(_C)[$(DOITALL)]$(_D) is the only target used to create
    files in the directory.
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_SPECIALS

override define $(HELPOUT)-$(DOITALL)-TARGETS_SPECIALS =
$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DO_BOOK))

An example $(_C)[$(DO_BOOK)]$(_D) definition in a `$(_M)$(COMPOSER_SETTINGS)$(_D)` file $(_E)([Quick Start] example)$(_D):

$(CODEBLOCK)$(_M)$(DO_BOOK)-$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D): $(_E)$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)

This configures it so that `$(_C)$(DO_BOOK)s$(_D)` will create `$(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D)` from
`$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)` and `$(_M)$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)`, concatenated together in order.  The primary
purpose of this $(_C)[Special]$(_D) is to gather multiple source files in this manner, so
that larger works can be comprised of multiple files, such as a book with each
chapter in a separate file.

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DO_PAGE) / $(DO_POST))

$(_N)*(Both [$(DO_PAGE)] and [$(DO_POST)] are reserved for the future [$(PUBLISH)] feature, which will
build website pages using [Bootstrap].)*$(_D)
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL

#> update: $(DEBUGIT): targets list

override define $(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL =
$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DEBUGIT) / $(DEBUGIT)-file)

  * This is the tool to use for any support issues.  Submit the output file to:
    $(_E)[composer@garybgenett.net]$(_D)
  * Internally, it also runs:
    * $(_C)[$(TESTING)]$(_D)
    * $(_C)[$(CHECKIT)-$(DOITALL)]$(_D)
    * $(_C)[$(CONFIGS)-$(DOITALL)]$(_D)
    * $(_C)[$(TARGETS)]$(_D)
  * If issues are occurring when running a particular set of targets, list them
    in $(_C)[COMPOSER_DEBUGIT]$(_D).
  * For general issues, run in the top-level directory $(_E)(see [Recommended
    Workflow])$(_D).  For specific issues, run in the directory where the issue is
    occurring.

For example:

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_E)COMPOSER_DEBUGIT="$(DO_BOOK)s $(OUT_README).$(EXTN_DEFAULT)"$(_D) $(_M)$(DEBUGIT)-file$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CHECKIT) / $(CHECKIT)-$(DOITALL) / $(CONFIGS) / $(CONFIGS)-$(DOITALL) / $(TARGETS))

  * Useful targets for validating tooling and configurations.
  * Use $(_C)[$(CHECKIT)]$(_D) to see the list of components and their versions, in relation to
    the system installed versions.  Doing $(_C)[$(CHECKIT)-$(DOITALL)]$(_D) will show the complete
    list of tools that are used by $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * The current values of all $(_C)[Composer Variables]$(_D) is output by $(_C)[$(CONFIGS)]$(_D), and
    $(_C)[$(CONFIGS)-$(DOITALL)]$(_D) will additionally output all environment variables.
  * A structured list of detected targets, available $(_C)[Specials]$(_D), $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) and
    $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) targets, $(_C)[COMPOSER_TARGETS]$(_D), and $(_C)[COMPOSER_SUBDIRS]$(_D) is printed by
    $(_C)[$(TARGETS)]$(_D).
  * Together, $(_C)[$(CONFIGS)]$(_D) and $(_C)[$(TARGETS)]$(_D) reveal the entire internal state of
    $(_C)[$(COMPOSER_BASENAME)]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CONVICT) / $(CONVICT)-$(DOITALL))

  * Using the directory structure in $(_C)[Recommended Workflow]$(_D), `$(_M).../$(_D)` is
    considered the top-level directory.  Meaning, it is the last directory
    before linking to $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * If the top-level directory is a $(_N)[Git]$(_D) repository $(_E)(it has `<directory>.git`
    or `<directory>/.git`)$(_D), this target creates a commit of the current
    directory tree with the title format below.
  * For example, if it is run in the `$(_M).../tld$(_D)` directory, that entire tree would
    be in the commit, including `$(_M).../tld/sub$(_D)`.  The purpose of this is to create
    quick and easy checkpoints when working on documentation that does not
    necessarily fit in a process where there are specific atomic steps being
    accomplished.
  * When this target is run in a $(_C)[$(COMPOSER_BASENAME)]$(_D) directory, it uses itself as the
    top-level directory.

Commit title format:

$(CODEBLOCK)$(_E)$(call COMPOSER_TIMESTAMP)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DISTRIB) / $(UPGRADE) / $(UPGRADE)-$(DOITALL))

  * Using the repository configuration $(_E)(see [Repository Versions])$(_D), these fetch
    and install all external components.
  * The $(_C)[$(UPGRADE)-$(DOITALL)]$(_D) target also fetches the $(_C)[Pandoc]$(_D) and $(_C)[YQ]$(_D) binaries,
    whereas $(_C)[$(UPGRADE)]$(_D) only fetches the repositories.
  * In addition to doing $(_C)[$(UPGRADE)-$(DOITALL)]$(_D), $(_C)[$(DISTRIB)]$(_D) performs the steps necessary
    to turn the current directory into a complete clone of $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * If `$(_N)rsync$(_D)` is installed, $(_C)[$(DISTRIB)]$(_D) can be used to rapidly replicate
    $(_C)[$(COMPOSER_BASENAME)]$(_D), like below.
  * One of the unique features of $(_C)[$(COMPOSER_BASENAME)]$(_D) is that everything needed to
    compose itself is embedded in the `$(_M)$(MAKEFILE)$(_D)`.

Rapid cloning $(_E)(requires `rsync`)$(_D):

$(CODEBLOCK)$(_C)mkdir$(_D) $(_M).../clone$(_D)
$(CODEBLOCK)$(_C)cd$(_D) $(_M).../clone$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .../.$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(DISTRIB)$(_D)
endef

########################################
# {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL

override define $(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL =
$(_S)[$(HELPOUT)-$(DOFORCE)]: #internal-targets$(_D)
$(_S)[.$(EXAMPLE)-$(INSTALL)]: #internal-targets$(_D)
$(_S)[.$(EXAMPLE)]: #internal-targets$(_D)
$(_S)[$(CREATOR)]: #internal-targets$(_D)
$(_S)[$(HEADERS)]: #internal-targets$(_D)
$(_S)[$(HEADERS)-$(EXAMPLE)]: #internal-targets$(_D)
$(_S)[$(HEADERS)-$(EXAMPLE)-$(DOITALL)]: #internal-targets$(_D)
$(_S)[$(MAKE_DB)]: #internal-targets$(_D)
$(_S)[$(LISTING)]: #internal-targets$(_D)
$(_S)[$(NOTHING)]: #internal-targets$(_D)
$(_S)[$(TESTING)]: #internal-targets$(_D)
$(_S)[$(TESTING)-file]: #internal-targets$(_D)
$(_S)[$(CHECKIT)-$(DOFORCE)]: #internal-targets$(_D)
$(_S)[$(SUBDIRS)]: #internal-targets$(_D)

$(_N)*(None of these are intended to be run directly during normal use, and are only
documented for completeness.)*$(_D)
endef

########################################
# {{{2 $(CREATOR) ----------------------

#> update: TYPE_TARGETS

.PHONY: $(CREATOR)
ifneq ($(MAKECMDGOALS),$(filter-out $(CREATOR),$(MAKECMDGOALS)))
.NOTPARALLEL:
endif
$(CREATOR): .set_title-$(CREATOR)
$(CREATOR):
	@$(call $(HEADERS))
ifneq ($(COMPOSER_RELEASE),)
	@$(ENDOLINE)
	@$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_BASENAME)_Directory)
	@$(ENDOLINE)
endif
	@$(call DO_HEREDOC,HEREDOC_GITIGNORE)						>$(CURDIR)/.gitignore
#>	@$(RUNMAKE) COMPOSER_DOCOLOR= $(HELPOUT)-$(DOITALL)	| $(SED) "/^[#][>]/d"	>$(CURDIR)/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
	@$(RUNMAKE) COMPOSER_DOCOLOR= $(HELPOUT)-$(DOFORCE)	| $(SED) "/^[#][>]/d"	>$(CURDIR)/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
ifneq ($(COMPOSER_RELEASE),)
	@$(RUNMAKE) COMPOSER_DOCOLOR= $(HELPOUT)-$(TYPE_PRES)	| $(SED) "/^[#][>]/d"	>$(CURDIR)/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)
endif
	@$(call DO_HEREDOC,HEREDOC_LICENSE)						>$(CURDIR)/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
	@$(MKDIR)									$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))
	@$(ECHO) "$(DIST_ICON_v1.0)"				| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/icon-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v1.0)"			| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/screenshot-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v3.0)"			| $(BASE64) -d		>$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/screenshot-v3.0.png
	@$(ECHO) ""									>$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_LOGO))
	@$(MKDIR)									$(abspath $(dir $(subst $(COMPOSER_DIR),$(CURDIR),$(TEX_PDF_TEMPLATE))))
	@$(call DO_HEREDOC,HEREDOC_TEX_PDF_TEMPLATE)					>$(subst $(COMPOSER_DIR),$(CURDIR),$(TEX_PDF_TEMPLATE))
	@$(MKDIR)									$(abspath $(dir $(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))))
	@$(call DO_HEREDOC,HEREDOC_REVEALJS_CSS)					>$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_CSS))
	@$(foreach FILE,\
		$(TMPL_HTML):$(EXTN_HTML) \
		$(TMPL_LPDF):$(EXTN_LPDF) \
		$(TMPL_EPUB):$(EXTN_EPUB) \
		$(TMPL_PRES):$(EXTN_PRES) \
		\
		$(TMPL_TEXT):$(EXTN_TEXT) \
		$(TMPL_LINT):$(EXTN_LINT) \
		,\
		$(PANDOC) --verbose \
			--output="$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/template.default.$(word 2,$(subst :, ,$(FILE)))" \
			--print-default-template="$(word 1,$(subst :, ,$(FILE)))"; \
		if [ ! -f $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/template.$(word 2,$(subst :, ,$(FILE))) ]; then \
			$(LN) \
				$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/template.default.$(word 2,$(subst :, ,$(FILE))) \
				$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/template.$(word 2,$(subst :, ,$(FILE))); \
		fi; \
		$(call NEWLINE) \
	)
	@$(foreach FILE,\
		$(TMPL_DOCX):$(EXTN_DOCX) \
		$(TMPL_PPTX):$(EXTN_PPTX) \
		,\
		$(PANDOC) --verbose \
			--output="$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/reference.default.$(word 2,$(subst :, ,$(FILE)))" \
			--print-default-data-file="reference.$(word 1,$(subst :, ,$(FILE)))"; \
		if [ ! -f $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/reference.$(word 2,$(subst :, ,$(FILE))) ]; then \
			$(LN) \
				$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/reference.default.$(word 2,$(subst :, ,$(FILE))) \
				$(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/reference.$(word 2,$(subst :, ,$(FILE))); \
		fi; \
		$(call NEWLINE) \
	)
ifneq ($(COMPOSER_RELEASE),)
	@$(call DO_HEREDOC,HEREDOC_$(CREATOR)_$(COMPOSER_SETTINGS))			>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(RM)										$(CURDIR)/$(COMPOSER_CSS)
#>	@$(LN) $(subst $(COMPOSER_DIR),$(CURDIR),$(MDVIEWER_CSS))			$(CURDIR)/$(COMPOSER_CSS)
	@$(CP) $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))/icon-v1.0.png		$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_LOGO))
endif
	@$(ENDOLINE)
	@$(LS) $(CURDIR)
	@$(ENDOLINE)
	@$(LS) --recursive $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_ART))
ifneq ($(COMPOSER_RELEASE),)
	@$(ENDOLINE)
	@$(ECHO) "$(_C)"
	@$(CAT) $(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(_D)"
	@$(ENDOLINE)
	@$(RUNMAKE) COMPOSER_LOG="$(COMPOSER_LOG_DEFAULT)"	COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(CLEANER)
#>	@$(RUNMAKE) COMPOSER_LOG=				COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" COMPOSER_DEBUGIT="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_HTML)
	@$(RUNMAKE) COMPOSER_LOG=				COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(DOITALL) \
		| $(SED) "/install[:][[:space:]]/d"
#>		| $(SED) "s|$(abspath $(dir $(COMPOSER_DIR)))|...|g"
	@$(RM) \
		$(CURDIR)/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT) \
		>/dev/null
	@$(RM) \
		$(CURDIR)/$(COMPOSER_SETTINGS) \
		$(CURDIR)/$(COMPOSER_CSS) \
		$(CURDIR)/$(COMPOSER_LOG_DEFAULT) \
		>/dev/null
	@$(ECHO) ""									>$(subst $(COMPOSER_DIR),$(CURDIR),$(REVEALJS_LOGO))
endif

override define HEREDOC_$(CREATOR)_$(COMPOSER_SETTINGS) =
$(OUT_README).%: override c_css := $(CSS_ALT)
$(OUT_README).%: override c_toc := $(SPECIAL_VAL)
$(OUT_README).$(EXTN_LPDF): $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
$(OUT_README).$(EXTN_EPUB): override c_css :=
$(OUT_README).$(EXTN_PRES): override c_list := $(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)
$(OUT_README).$(EXTN_PRES): override c_css :=
$(OUT_README).$(EXTN_PRES): override c_toc :=
endef

ifneq ($(COMPOSER_RELEASE),)
$(DO_BOOK)-$(OUT_MANUAL).$(EXTN_LPDF): override c_toc := $(SPECIAL_VAL)
$(DO_BOOK)-$(OUT_MANUAL).$(EXTN_LPDF): \
	$(OUT_README)$(COMPOSER_EXT_DEFAULT) \
	$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
endif

########################################
# {{{2 $(EXAMPLE) ----------------------

#> update: COMPOSER_OPTIONS

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(RUNMAKE) --silent COMPOSER_DOCOLOR= .$(EXAMPLE)

.PHONY: .$(EXAMPLE)-$(INSTALL)
.$(EXAMPLE)-$(INSTALL):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
	@$(call $(EXAMPLE)-var-static,,COMPOSER_MY_PATH)
	@$(call $(EXAMPLE)-var-static,,COMPOSER_TEACHER)
	@$(call $(EXAMPLE)-print,,include $(_E)$(~)(COMPOSER_TEACHER))

.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
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
#>	$(call $(EXAMPLE)-print,$(1),override $(_E)$(2)$(_D) :=$(if $($(2)), $(_N)$(subst ",\",$($(2)))))
override define $(EXAMPLE)-var-static =
	$(call $(EXAMPLE)-print,$(1),override $(_E)$(2)$(_D) :=$(if $($(2)), $(_N)$($(2))))
endef
override define $(EXAMPLE)-var =
	$(call $(EXAMPLE)-print,$(1),override $(_C)$(2)$(_D) :=$(if $($(2)), $(_M)$(subst ",\",$($(2)))))
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

override define HEREDOC_GITIGNORE =
################################################################################
# $(COMPOSER_TECHNAME)
################################################################################

########################################
# $(COMPOSER_BASENAME)

#>/$(COMPOSER_SETTINGS)
#>/$(COMPOSER_CSS)
#>/$(COMPOSER_LOG_DEFAULT)

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
# {{{1 Heredoc: pdf_latex ------------------------------------------------------
################################################################################

override define HEREDOC_TEX_PDF_TEMPLATE =
% ##############################################################################
% $(COMPOSER_TECHNAME)
% ##############################################################################

\\usepackage{extramarks}
\\usepackage{fancyhdr}
\\pagestyle{fancy}
\\fancyhf{}

\\fancypagestyle{plain}{%
  \\pagestyle{fancy}
  \\fancyhead{}
  \\renewcommand{\\headrulewidth}{0pt}
}

\\fancyhead[EL,OR]{\\nouppercase{\\firstleftmark}}
\\fancyhead[OL,ER]{}
\\renewcommand{\\headrulewidth}{0.1pt}

\\fancyfoot[EL,OR]{\\nouppercase{\\thepage}}
\\fancyfoot[OL,ER]{}
\\renewcommand{\\footrulewidth}{0.1pt}

% ######################################

\\usepackage{longtable}
\\setlength{\\LTleft}{1.5em}

\\usepackage{listings}
\\lstset{xleftmargin=1.5em}

% ##############################################################################
% End Of File
% ##############################################################################
endef

################################################################################
# {{{1 Heredoc: revealjs_css ---------------------------------------------------
################################################################################

override define HEREDOC_REVEALJS_CSS =
/* #############################################################################
# $(COMPOSER_TECHNAME)
############################################################################# */

@import url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(REVEALJS_CSS_THEME))");

/* ########################################################################## */

.reveal .slides {
	background:			url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(REVEALJS_LOGO))");
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

override define HEREDOC_LICENSE =
# $(COMPOSER_LICENSE)

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
override _F				:= \e[41;37m
else
override _D				:=
override _H				:=
override _C				:=
override _M				:=
override _N				:=
override _E				:=
override _S				:=
override _F				:=
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
override CODEBLOCK			:= $(NULL)    $(NULL)
override ENDOLINE			:= $(ECHO) "$(_D)\n"
override LINERULE			:= $(ECHO) "$(_H)";	$(PRINTF)  "-%.0s" {1..$(COLUMNS)}	; $(ENDOLINE)
override HEADER_L			:= $(ECHO) "$(_S)";	$(PRINTF) "\#%.0s" {1..$(COLUMNS)}	; $(ENDOLINE)

# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
ifneq ($(COMPOSER_DOCOLOR),)
override TABLE_C2			:= $(PRINTF) "$(COMMENTED)%b$(_D)\e[128D\e[22C%b$(_D)\n"
override TABLE_M2			:= $(PRINTF) "| %b$(_D)\e[128D\e[22C| %b$(_D)\n"
override TABLE_M3			:= $(PRINTF) "| %b$(_D)\e[128D\e[22C| %b$(_D)\e[128D\e[54C| %b$(_D)\n"
override COLUMN_2			:= $(PRINTF) "%b$(_D)\e[128D\e[39C %b$(_D)\n"
override PRINT				:= $(PRINTF) "%b$(_D)\n"
else
override TABLE_C2			:= $(PRINTF) "$(COMMENTED)%-20s%s\n"
override TABLE_M2			:= $(PRINTF) "| %-20s| %s\n"
override TABLE_M3			:= $(PRINTF) "| %-20s| %-30s| %s\n"
override COLUMN_2			:= $(PRINTF) "%-39s %s\n"
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
	c_lang \
	c_css \
	c_toc \
	c_level \
	$(if $(c_margin),c_margin,\
		$(if $(or \
			$(c_margin_top) ,\
			$(c_margin_bottom) ,\
			$(c_margin_left) ,\
			$(c_margin_right) \
		),\
			c_margin_top \
			c_margin_bottom \
			c_margin_left \
			c_margin_right \
		,\
			c_margin \
		) \
	) \
	c_options
endif

ifneq ($(COMPOSER_RELEASE),)
override $(HEADERS)-release = $(subst $(abspath $(dir $(COMPOSER_DIR))),...,$(1))
else
override $(HEADERS)-release = $(1)
endif

########################################
# {{{3 $(HEADERS)-$(EXAMPLE) -----------

.PHONY: $(HEADERS)-$(EXAMPLE)-$(DOITALL)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): export override COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE) := $(DOITALL)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): export override $(HEADERS)-list := $(COMPOSER_OPTIONS)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): export override $(HEADERS)-vars := $(COMPOSER_OPTIONS)
$(HEADERS)-$(EXAMPLE)-$(DOITALL): $(HEADERS)-$(EXAMPLE)
$(HEADERS)-$(EXAMPLE)-$(DOITALL):
	@$(ECHO) ""

.PHONY: $(HEADERS)-$(EXAMPLE)
$(HEADERS)-$(EXAMPLE):
	@$(call $(HEADERS))
	@$(call $(HEADERS),1)
	@$(call $(HEADERS)-run)
	@$(call $(HEADERS)-run,1)
	@$(call $(HEADERS)-note,$(CURDIR),$(TESTING))
	@$(call $(HEADERS)-dir,$(CURDIR),directory)
	@$(call $(HEADERS)-file,$(CURDIR),creating)
	@$(call $(HEADERS)-skip,$(CURDIR),skipping)
	@$(call $(HEADERS)-rm,$(CURDIR),removing)

########################################
# {{{3 $(HEADERS)-% --------------------

.PHONY: $(HEADERS)
$(HEADERS): $(NOTHING)-$(NOTHING)-$(TARGETS)-$(HEADERS)
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
		$(TABLE_C2) "$(_C)$(FILE)"	"[$(_M)$(strip $(if \
			$(filter c_css,$(FILE)),$(call c_css_select),\
			$(subst ",\",$($(FILE))) \
		))$(_D)]$(if $(filter $(FILE),$(COMPOSER_EXPORTED)), $(_E)$(MARKER)$(_D))"; \
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
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$(strip $(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		))$(_D)$(if $(filter $(FILE),$(COMPOSER_EXPORTED)),$(if $(strip $(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		)), )$(_E)$(MARKER)$(_D))"; \
	) \
	$(LINERULE)
endef

override define $(HEADERS)-$(SUBDIRS) =
	if [ -z "$(COMPOSER_DEBUGIT)" ]; then \
		$(call $(HEADERS)-dir,$(CURDIR)); \
	else \
		$(call $(HEADERS),1,$(1)); \
	fi
endef
override define $(HEADERS)-$(COMPOSER_PANDOC) =
	if [ -z "$(COMPOSER_DEBUGIT)" ]; then \
		$(call $(HEADERS)-file,$(CURDIR),$(1)); \
	else \
		$(call $(HEADERS)-run,1,$(1)); \
		$(PRINT) "$(_H)$(MARKER)$(_D) $(_C)$(PANDOC) $(subst ",\",$(call PANDOC_OPTIONS))"; \
	fi
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
	@$(PRINT) "  * New targets can be defined in '$(_M)$(COMPOSER_SETTINGS)$(_D)'"
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
override NOTHING_IGNORES := \
	$(TARGETS) \
	$(SUBDIRS) \

#>	$(CONFIGS)-$(TARGETS) \
#>	$(CONFIGS)-$(SUBDIRS) \
#>	$(TARGETS)-$(CLEANER) \
#>	$(TARGETS)-$(DOITALL) \
#>	$(NOTHING)-$(TARGETS)-$(HEADERS) \
#>	$(TARGETS) \
#>	$(NOTHING)-$(TARGETS) \
#>	$(NOTHING)-$(TARGETS)-$(SUBDIRS) \
#>	$(SUBDIRS) \
#>	$(NOTHING)-$(SUBDIRS) \
#>	$(MAKEFILE) \
#>	COMPOSER_LOG \
#>	COMPOSER_EXT \

$(eval export override COMPOSER_NOTHING ?=)
.PHONY: $(NOTHING)-%
$(NOTHING)-%:
	@$(RUNMAKE) --silent COMPOSER_NOTHING="$(*)" $(NOTHING)

.PHONY: $(NOTHING)
$(NOTHING):
ifeq ($(COMPOSER_DEBUGIT),)
	@$(if $(filter $(COMPOSER_NOTHING),$(NOTHING_IGNORES)),\
		$(ECHO) "" ,\
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
$(eval export override COMPOSER_DOITALL_$(DEBUGIT) ?=)
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
			$(RUNMAKE) --just-print COMPOSER_DOCOLOR= COMPOSER_DEBUGIT="$(SPECIAL_VAL)" $(FILE) 2>&1; \
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
$(eval export override COMPOSER_DOITALL_$(TESTING) ?=)
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
$(TESTING): $(TESTING)-$(TARGETS)
$(TESTING): $(TESTING)-$(INSTALL)
$(TESTING): $(TESTING)-$(CLEANER)-$(DOITALL)
$(TESTING): $(TESTING)-COMPOSER_INCLUDE
$(TESTING): $(TESTING)-COMPOSER_DEPENDS
$(TESTING): $(TESTING)-COMPOSER_IGNORES
$(TESTING): $(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)
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
	@$(PRINT) "  * All cases are run in the '$(_M)$(subst $(COMPOSER_DIR)/,,$(TESTING_DIR))$(_D)' directory"
	@$(PRINT) "  * It has a dedicated '$(_M)$(TESTING_COMPOSER_DIR)$(_D)', and '$(_C)$(DOMAKE)$(_D)' can be run anywhere in the tree"
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
	$(call $(TESTING)-run,$(if $(1),$(1),$(@))) --makefile $(TESTING_COMPOSER_MAKEFILE) $(CREATOR); \
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
	$(call $(TESTING)-run,$(if $(1),$(1),$(@))) MAKEJOBS="$(SPECIAL_VAL)" $(INSTALL)-$(DOFORCE)
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
		\n\t * Verify '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' configuration \
		\n\t * Top-level '$(_C)$(notdir $(TESTING_DIR))$(_D)' directory ready for direct use \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

#> update: $(TESTING)-Think
.PHONY: $(TESTING)-Think-init
$(TESTING)-Think-init:
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,/)/$(MAKEFILE),-$(INSTALL),$(TESTING_COMPOSER_MAKEFILE),1)
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS),,,1)
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS),,,1)
	@$(call $(TESTING)-run) --makefile $(TESTING_COMPOSER_MAKEFILE) $(INSTALL)
	@$(call $(TESTING)-run) $(CONFIGS)
	@$(ENDOLINE)
	@$(LS) \
		$(COMPOSER) \
		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)) \
		$(call $(TESTING)-pwd,/) \
		$(call $(TESTING)-pwd)
	@$(CAT) \
		$(call $(TESTING)-pwd,/)/$(MAKEFILE) \
		$(call $(TESTING)-pwd)/$(MAKEFILE)
#>	@$(CAT) \
#>		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS) \
#>		$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS)

.PHONY: $(TESTING)-Think-done
$(TESTING)-Think-done:
	$(call $(TESTING)-find,COMPOSER_TARGETS)
	$(call $(TESTING)-count,2,override COMPOSER_TEACHER := .+$(TESTING_COMPOSER_DIR)\/$(MAKEFILE))

########################################
# {{{3 $(TESTING)-$(DISTRIB) -----------

#> update: PHONY.*$(DISTRIB)
#	$(UPGRADE)
#	$(CREATOR)

.PHONY: $(TESTING)-$(DISTRIB)
$(TESTING)-$(DISTRIB): $(TESTING)-Think
$(TESTING)-$(DISTRIB):
	@$(call $(TESTING)-$(HEADERS),\
		Install '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' using '$(_C)$(DISTRIB)$(_D)' ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(DISTRIB)-init
$(TESTING)-$(DISTRIB)-init:
#>	@$(call $(TESTING)-run,$(TESTING_COMPOSER_DIR)) $(DISTRIB)
	@$(call $(TESTING)-run,$(TESTING_COMPOSER_DIR)) --makefile $(COMPOSER) $(DISTRIB)

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
$(TESTING)-$(DEBUGIT):
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
$(TESTING)-speed:
	@$(call $(TESTING)-$(HEADERS),\
		Performance test of the speed processing a large directory ,\
		\n\t * $(_H)For general information and fun only$(_D) \
	)
	@$(call $(TESTING)-speed-init)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

override define $(TESTING)-speed-init =
	for TLD in {1..3}; do \
		$(call $(TESTING)-speed-init-load,$(call $(TESTING)-pwd)/tld$${TLD}); \
		for SUB in {1..3}; do \
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
$(TESTING)-speed-init:
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(INSTALL)-$(DOFORCE)
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-speed-done
$(TESTING)-speed-done:
	@$(TABLE_M2) "$(_H)$(MARKER) Directories"	"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type d | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Files"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+$(subst .,[.],$(COMPOSER_EXT_DEFAULT))$$/p" | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Output"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+[.]$(EXTN_DEFAULT)$$/p" | $(WC))"
	@$(call $(TESTING)-find,[0-9]s$$)
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(COMPOSER_BASENAME) -

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING)-$(COMPOSER_BASENAME): $(TESTING)-Think
$(TESTING)-$(COMPOSER_BASENAME):
	@$(call $(TESTING)-$(HEADERS),\
		Basic '$(_C)$(COMPOSER_BASENAME)$(_D)' functionality ,\
		\n\t * Verify lock files \
		\n\t * Variable alias precedence \
		\n\t * Automatic input file detection \
		\n\t\t * Command-line '$(_C)c_list$(_D)' shortcut \
		\n\t * Expansion of '$(_C)c_margins$(_D)' variable \
		\n\t * Quoting in '$(_C)c_options$(_D)' variable \
		\n\t * Empty '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' values \
		\n\t\t * Use of '$(_C)$(NOTHING)$(_D)' targets \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-init
$(TESTING)-$(COMPOSER_BASENAME)-init:
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	#> lock
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_DEFAULT)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >>$(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_DEFAULT).lock
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_DEFAULT) || $(TRUE)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_DEFAULT).lock
	#> precedence
	@unset COMPOSER_DEBUGIT c_debug V && $(RUNMAKE) COMPOSER_DEBUGIT="order-COMPOSER_DEBUGIT" c_debug="order-c_debug" V="order-V" $(CONFIGS)
	@unset COMPOSER_DEBUGIT c_debug V && $(RUNMAKE) c_debug="order-c_debug" V="order-V" $(CONFIGS)
	@unset COMPOSER_DEBUGIT c_debug V && $(RUNMAKE) V="order-V" $(CONFIGS)
	@$(RUNMAKE) COMPOSER_DEBUGIT=0 C="order-C" $(CONFIGS)
	#> input
	@$(call $(TESTING)-run) $(OUT_README)$(COMPOSER_EXT_DEFAULT).$(EXTN_DEFAULT)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) $(OUT_MANUAL).$(EXTN_DEFAULT) c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)"
	@$(SED) -n "/$(COMPOSER_LICENSE)/p" $(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_DEFAULT)
	#> margins
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_margin= c_margin_top="1in" c_margin_bottom="2in" c_margin_left="3in" c_margin_right="4in" $(OUT_README).$(EXTN_LPDF)
	#> options
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable='$(TESTING)=$(DEBUGIT)'" $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable='$(TESTING)=$(DEBUGIT)'" $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable=\"$(TESTING)=$(DEBUGIT)\"" $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable=\"$(TESTING)=$(DEBUGIT)\"" $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable="$(TESTING)=$(DEBUGIT)"' $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable="$(TESTING)=$(DEBUGIT)"' $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable='"'$(TESTING)=$(DEBUGIT)'" $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable='"'$(TESTING)=$(DEBUGIT)'" $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	#> values
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CONFIGS)
	@$(ECHO) "override COMPOSER_TARGETS := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_SUBDIRS := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-done
$(TESTING)-$(COMPOSER_BASENAME)-done:
	#> lock
	$(call $(TESTING)-find,lock file exists)
	#> precedence
	$(call $(TESTING)-count,1,order-COMPOSER_DEBUGIT)
	$(call $(TESTING)-count,1,order-c_debug)
	$(call $(TESTING)-count,1,order-V)
	#> input
	$(call $(TESTING)-find,Creating.+$(OUT_MANUAL).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Creating.+$(OUT_README)$(COMPOSER_EXT_DEFAULT).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,1,$(COMPOSER_LICENSE))
	#> margins
	$(call $(TESTING)-count,26,c_margin)
	$(call $(TESTING)-find,c_margin_top.+1in)
	$(call $(TESTING)-find,c_margin_bottom.+2in)
	$(call $(TESTING)-find,c_margin_left.+3in)
	$(call $(TESTING)-find,c_margin_right.+4in)
	#> options
	$(call $(TESTING)-count,6,[\"]$(TESTING)=$(DEBUGIT)[\"])
	$(call $(TESTING)-count,6,[']$(TESTING)=$(DEBUGIT)['])
	#> values
	$(call $(TESTING)-find,COMPOSER_TARGETS.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,COMPOSER_SUBDIRS.+artifacts)
	$(call $(TESTING)-count,1,NOTICE.+$(NOTHING).+$(NOTHING)-$(TARGETS))
	$(call $(TESTING)-count,1,NOTICE.+$(NOTHING).+$(NOTHING)-$(SUBDIRS))

########################################
# {{{3 $(TESTING)-$(TARGETS) -----------

.PHONY: $(TESTING)-$(TARGETS)
$(TESTING)-$(TARGETS): $(TESTING)-Think
$(TESTING)-$(TARGETS):
	@$(call $(TESTING)-$(HEADERS),\
		Test every combination of formats and formatting variables ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

#> update: TYPE_TARGETS
.PHONY: $(TESTING)-$(TARGETS)-init
$(TESTING)-$(TARGETS)-init:
#>	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).*.[x0-9].*
	@$(ECHO) "override COMPOSER_TARGETS :=\n" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(foreach EXTN,\
		$(EXTN_HTML) \
		$(EXTN_LPDF) \
		$(EXTN_EPUB) \
		$(EXTN_PRES) \
		$(EXTN_DOCX) \
		$(EXTN_PPTX) \
		$(EXTN_TEXT) \
		$(EXTN_LINT) \
		,\
		$(foreach TOC,x 0 1 2 3 4 5 6,\
			$(foreach LEVEL,x 0 1 2 3 4 5 6,\
				$(ECHO) "override COMPOSER_TARGETS += $(OUT_README).$(EXTN).$(TOC).$(LEVEL).$(EXTN)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(ECHO) "$(OUT_README).$(EXTN).$(TOC).$(LEVEL).$(EXTN): override c_toc := $(subst x,,$(TOC))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(ECHO) "$(OUT_README).$(EXTN).$(TOC).$(LEVEL).$(EXTN): override c_level := $(subst x,,$(LEVEL))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(ECHO) "$(OUT_README).$(EXTN).$(TOC).$(LEVEL).$(EXTN): $(OUT_README)$(COMPOSER_EXT_DEFAULT)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(call $(TESTING)-run) $(OUT_README).$(EXTN).$(TOC).$(LEVEL).$(EXTN) || $(TRUE); \
				$(call NEWLINE) \
			) \
		) \
	)
#>	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(LS) $(call $(TESTING)-pwd)/$(OUT_README).*.[x0-9].*

.PHONY: $(TESTING)-$(TARGETS)-done
$(TESTING)-$(TARGETS)-done:
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_HTML)[.][x0-9][.][x0-9][.]$(EXTN_HTML))
	$(call $(TESTING)-count,22,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_LPDF)[.][x0-9][.][x0-9][.]$(EXTN_LPDF))
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_EPUB)[.][x0-9][.][x0-9][.]$(EXTN_EPUB))
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_PRES)[.][x0-9][.][x0-9][.]$(EXTN_PRES))
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_DOCX)[.][x0-9][.][x0-9][.]$(EXTN_DOCX))
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_PPTX)[.][x0-9][.][x0-9][.]$(EXTN_PPTX))
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_TEXT)[.][x0-9][.][x0-9][.]$(EXTN_TEXT))
	$(call $(TESTING)-count,64,$(notdir $(call $(TESTING)-pwd))\/$(OUT_README)[.]$(EXTN_LINT)[.][x0-9][.][x0-9][.]$(EXTN_LINT))
	$(call $(TESTING)-count,42,ERROR)
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(INSTALL) -----------

.PHONY: $(TESTING)-$(INSTALL)
$(TESTING)-$(INSTALL): $(TESTING)-Think
$(TESTING)-$(INSTALL):
	@$(call $(TESTING)-$(HEADERS),\
		Test '$(_C)$(INSTALL)$(_D)' in an existing directory ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
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
	@$(RM) $(call $(TESTING)-pwd)/data/*/$(MAKEFILE)
	@$(call $(TESTING)-run) MAKEJOBS= $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run) MAKEJOBS= $(CLEANER)-$(DOITALL)
	@$(call $(TESTING)-run) MAKEJOBS="$(SPECIAL_VAL)" $(INSTALL)-$(DOITALL)
	@$(call $(TESTING)-run) MAKEJOBS="$(SPECIAL_VAL)" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-$(INSTALL)-done
$(TESTING)-$(INSTALL)-done:
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+$(MAKEFILE))
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-$(CLEANER)-$(DOITALL)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)
$(TESTING)-$(CLEANER)-$(DOITALL): $(TESTING)-Think
$(TESTING)-$(CLEANER)-$(DOITALL):
	@$(call $(TESTING)-$(HEADERS),\
		Test '$(_C)$(CLEANER)-$(DOITALL)$(_D)' and '$(_C)$(DOITALL)-$(DOITALL)$(_D)' behavior ,\
		\n\t * Creation and deletion of files \
		\n\t * Missing '$(_C)$(MAKEFILE)$(_D)' detection \
		\n\t * Proper execution of '$(_N)*$(_C)-$(DOITALL)$(_D)' and '$(_N)*$(_C)-$(CLEANER)$(_D)' targets \
		\n\t * Empty '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' values \
	)
	@$(call $(TESTING)-load)
	@$(RM) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)-init
$(TESTING)-$(CLEANER)-$(DOITALL)-init:
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) '$(foreach FILE,9 8 7 6 5 4 3 2 1,\n.PHONY: $(TESTING)-$(FILE)-$(CLEANER)\n$(TESTING)-$(FILE)-$(CLEANER):\n\t@$$(PRINT) "$$(@): $$(CURDIR)"\n)' \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) '$(foreach FILE,9 8 7 6 5 4 3 2 1,\n.PHONY: $(TESTING)-$(FILE)-$(DOITALL)\n$(TESTING)-$(FILE)-$(DOITALL):\n\t@$$(PRINT) "$$(@): $$(CURDIR)"\n)' \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(CLEANER) $(TESTING)-2-$(CLEANER)" $(DOITALL)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(DOITALL) $(TESTING)-2-$(DOITALL)" $(DOITALL)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run) $(CLEANER)-$(DOITALL)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)-done
$(TESTING)-$(CLEANER)-$(DOITALL)-done:
	$(call $(TESTING)-find,Creating.+changelog.html)
	$(call $(TESTING)-find,Creating.+getting-started.html)
	$(call $(TESTING)-find,Removing.+changelog.html)
	$(call $(TESTING)-find,Removing.+getting-started.html)
	$(call $(TESTING)-find,Removing.+\/$(notdir $(call $(TESTING)-pwd))[^\/].+$(COMPOSER_LOG_DEFAULT))
	$(call $(TESTING)-find,Removing.+\/$(notdir $(call $(TESTING)-pwd))\/doc[^\/].+$(COMPOSER_LOG_DEFAULT))
	$(call $(TESTING)-count,1,$(NOTHING).+$(TARGETS)-$(CLEANER))
	$(call $(TESTING)-count,1,$(NOTHING).+$(TARGETS)-$(DOITALL))
	$(call $(TESTING)-count,3,$(TESTING)-1-$(CLEANER))

########################################
# {{{3 $(TESTING)-COMPOSER_INCLUDE -----

.PHONY: $(TESTING)-COMPOSER_INCLUDE
$(TESTING)-COMPOSER_INCLUDE: $(TESTING)-Think
$(TESTING)-COMPOSER_INCLUDE:
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_INCLUDE$(_D)' behavior ,\
		\n\t * Use '$(_C)COMPOSER_DEPENDS$(_D)' in '$(_C)$(COMPOSER_SETTINGS)$(_D)' \
		\n\t * One run each with '$(_C)COMPOSER_INCLUDE$(_D)' enabled and disabled: \
		\n\t\t * All files in place \
		\n\t\t * Remove from '$(_C)$(notdir $(call $(TESTING)-pwd))$(_D)' \
		\n\t\t * Remove from '$(_C)$(notdir $(call $(TESTING)-pwd,/))$(_D)' \
		\n\t\t * Remove from '$(_C)$(notdir $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)))$(_D)' \
		\n\t * Verify '$(_C)$(COMPOSER_CSS)$(_D)' in parallel \
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
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))\n" >$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_CSS); \
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd,/)\n" >$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd,/)\n" >$(call $(TESTING)-pwd,/)/$(COMPOSER_CSS); \
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd)\n" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(ECHO) "override COMPOSER_DEPENDS := $(call $(TESTING)-pwd)\n" >$(call $(TESTING)-pwd)/$(COMPOSER_CSS); \
	$(ECHO) "override COMPOSER_INCLUDE := $(1)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_INCLUDES/p"; \
	$(CAT) \
		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS) \
		$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS) \
		$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
endef

override define $(TESTING)-COMPOSER_INCLUDE-done =
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/c_css/p"; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_CSS) >/dev/null; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/c_css/p"; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(RM) $(call $(TESTING)-pwd,/)/$(COMPOSER_CSS) >/dev/null; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/c_css/p"; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS); \
	$(RM) $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_CSS) >/dev/null; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_DEPENDS/p"; \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/c_css/p"
endef

.PHONY: $(TESTING)-COMPOSER_INCLUDE-done
$(TESTING)-COMPOSER_INCLUDE-done:
	$(call $(TESTING)-count,2,\|.+COMPOSER_DEPENDS.+$(subst /,.,$(call $(TESTING)-pwd)))
	$(call $(TESTING)-count,2,\|.+c_css.+$(subst /,\/,$(call $(TESTING)-pwd)/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,1,\|.+COMPOSER_DEPENDS.+$(subst /,.,$(call $(TESTING)-pwd,/))$(if $(COMPOSER_DOCOLOR),[^/],[ $$]))
	$(call $(TESTING)-count,1,\|.+c_css.+$(subst /,\/,$(call $(TESTING)-pwd,/)/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,3,\|.+COMPOSER_DEPENDS.+$(subst /,.,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))))
	$(call $(TESTING)-count,3,\|.+c_css.+$(subst /,\/,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)/$(COMPOSER_CSS))))

########################################
# {{{3 $(TESTING)-COMPOSER_DEPENDS -----

.PHONY: $(TESTING)-COMPOSER_DEPENDS
$(TESTING)-COMPOSER_DEPENDS: $(TESTING)-Think
$(TESTING)-COMPOSER_DEPENDS:
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_DEPENDS$(_D)' behavior ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
		\n\t * Disable '$(_C)MAKEJOBS$(_D)' threading \
		\n\t * Reverse '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' processing \
		\n\t * Manual '$(_C)$(DOITALL)-$(DOITALL)$(_D)' dependencies $(_E)('templates' before 'docx')$(_D) \
		\n\t * Manual '$(_C)$(DOITALL)$(_D)' dependencies $(_E)('$(OUT_README).$(EXTN_DEFAULT)' before '$(OUT_LICENSE).$(EXTN_DEFAULT)')$(_D) \
	)
	@$(call $(TESTING)-load)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-init
$(TESTING)-COMPOSER_DEPENDS-init:
	@$(RM) $(call $(TESTING)-pwd)/data/*$(COMPOSER_EXT_DEFAULT)
	@$(RM) $(call $(TESTING)-pwd)/data/*.$(EXTN_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n" >$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(OUT_LICENSE).$(EXTN_DEFAULT): $(OUT_README).$(EXTN_DEFAULT)\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(DOITALL)-$(SUBDIRS)-docx: $(DOITALL)-$(SUBDIRS)-templates\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) MAKEJOBS="$(SPECIAL_VAL)" --directory $(call $(TESTING)-pwd)/data $(CONFIGS)
	@$(call $(TESTING)-run) MAKEJOBS="$(SPECIAL_VAL)" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-done
$(TESTING)-COMPOSER_DEPENDS-done:
	$(call $(TESTING)-count,1,MAKEJOBS.+ 1 )
	$(call $(TESTING)-find,$(notdir $(call $(TESTING)-pwd))\/data)
	@$(call $(TESTING)-hold)

########################################
# {{{3 $(TESTING)-COMPOSER_IGNORES -----

.PHONY: $(TESTING)-COMPOSER_IGNORES
$(TESTING)-COMPOSER_IGNORES: $(TESTING)-Think
$(TESTING)-COMPOSER_IGNORES:
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_IGNORES$(_D)' behavior ,\
		\n\t * Verify '$(_C)COMPOSER_IGNORES$(_D)' are skipped \
		\n\t * Empty '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' values \
	)
	@$(call $(TESTING)-load)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-COMPOSER_IGNORES-init
$(TESTING)-COMPOSER_IGNORES-init:
	@$(RM) $(call $(TESTING)-pwd)/data/*$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "override COMPOSER_IGNORES := $(OUT_README).$(EXTN_DEFAULT) $(notdir $(wildcard $(call $(TESTING)-pwd)/data/*))\n" >$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(CONFIGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(INSTALL)-$(DOITALL)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(CLEANER)-$(DOITALL)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-COMPOSER_IGNORES-done
$(TESTING)-COMPOSER_IGNORES-done:
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_DEFAULT),,1)
	$(call $(TESTING)-count,2,$(NOTHING).+$(CONFIGS)-$(TARGETS))
	$(call $(TESTING)-count,4,$(NOTHING).+$(CONFIGS)-$(SUBDIRS))

########################################
# {{{3 $(TESTING)-$(COMPOSER_LOG)$(COMPOSER_EXT)

.PHONY: $(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)
$(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT): $(TESTING)-Think
$(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT):
	@$(call $(TESTING)-$(HEADERS),\
		Proper operation of '$(_C)COMPOSER_LOG$(_D)' and '$(_C)COMPOSER_EXT$(_D)' ,\
		\n\t * Build '$(_C)$(DOITALL)$(_D)' with empty '$(_C)COMPOSER_EXT$(_D)' \
		\n\t * Do '$(_C)$(CLEANER)$(_D)' with both empty \
		\n\t * Do '$(_C)$(PRINTER)$(_D)' with empty '$(_C)COMPOSER_LOG$(_D)' \
		\n\t * Do '$(_C)$(PRINTER)$(_D)' with empty '$(_C)COMPOSER_EXT$(_D)' \
		\n\t * Detect updated files with '$(_C)$(PRINTER)$(_D)' \
	)
	@$(call $(TESTING)-mark,,1)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)-init
$(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)-init:
	@$(call $(TESTING)-run) COMPOSER_EXT= $(DOITALL)
	@$(call $(TESTING)-run) COMPOSER_LOG= COMPOSER_EXT= $(CLEANER)
	@$(call $(TESTING)-run) COMPOSER_LOG= $(PRINTER)
	@$(call $(TESTING)-run) COMPOSER_EXT= $(PRINTER)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(subst $(TESTING)-.,,$(notdir $(call $(TESTING)-pwd)))
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_LOG_DEFAULT)
	@$(call $(TESTING)-run) $(PRINTER)

.PHONY: $(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)-done
$(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)-done:
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Removing.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+COMPOSER_LOG)
	$(call $(TESTING)-find,NOTICE.+$(NOTHING).+COMPOSER_EXT)
	$(call $(TESTING)-find, $(subst $(TESTING)-.,,$(notdir $(call $(TESTING)-pwd))))
	$(call $(TESTING)-find, $(COMPOSER_LOG_DEFAULT))

########################################
# {{{3 $(TESTING)-CSS ------------------

.PHONY: $(TESTING)-CSS
$(TESTING)-CSS: $(TESTING)-Think
$(TESTING)-CSS:
	@$(call $(TESTING)-$(HEADERS),\
		Use '$(_C)c_css$(_D)' to verify each method of setting variables ,\
		\n\t * Default: '$(_C)$(TYPE_HTML)$(_D)' \
		\n\t * Default: '$(_C)$(TYPE_PRES)$(_D)' \
		\n\t * Environment: '$(_C)$(notdir $(REVEALJS_CSS))$(_D)' \
		\n\t * Environment: '$(_C)$(CSS_ALT)$(_D)' alias \
		\n\t * Environment: '$(_C)$(SPECIAL_VAL)$(_D)' Pandoc default \
		\n\t * File: '$(_C)$(COMPOSER_CSS)$(_D)' $(_E)(precedence over environment)$(_D) \
		\n\t * File: '$(_C)$(COMPOSER_SETTINGS)$(_D)' $(_E)(precedence over everything)$(_D) \
		\n\t * File: '$(_C)$(COMPOSER_SETTINGS)$(_D)' per-target $(_E)(precedence over everything)$(_D) \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-CSS-init
$(TESTING)-CSS-init:
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS) >/dev/null
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_CSS) >/dev/null
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_HTML)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_PRES); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_PRES)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(REVEALJS_CSS))" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(CSS_ALT)" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_CSS)
	@$(LS) $(call $(TESTING)-pwd)/$(COMPOSER_CSS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override c_css := $(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(MDVIEWER_CSS_ALT))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "$(OUT_README).$(EXTN_EPUB): override c_css := $(subst $(COMPOSER_DIR),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)),$(REVEALJS_CSS))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)

.PHONY: $(TESTING)-CSS-done
$(TESTING)-CSS-done:
	$(call $(TESTING)-count,2,$(notdir $(MDVIEWER_CSS)))
	$(call $(TESTING)-count,7,$(notdir $(REVEALJS_CSS)))
	$(call $(TESTING)-count,7,$(notdir $(REVEALJS_CSS)))
	$(call $(TESTING)-count,6,$(notdir $(MDVIEWER_CSS_ALT)))
	$(call $(TESTING)-count,1,c_css[^/]+$$)
	$(call $(TESTING)-count,3,$(notdir $(COMPOSER_CSS)))
	$(call $(TESTING)-count,6,$(notdir $(MDVIEWER_CSS_ALT)))
	$(call $(TESTING)-count,7,$(notdir $(REVEALJS_CSS)))

########################################
# {{{3 $(TESTING)-other ----------------

.PHONY: $(TESTING)-other
$(TESTING)-other: $(TESTING)-Think
$(TESTING)-other:
	@$(call $(TESTING)-$(HEADERS),\
		Miscellaneous test cases ,\
		\n\t * Check binary files \
		\n\t * Repository versions variables \
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
	#> versions
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override PANDOC_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override YQ_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override BOOTSTRAP_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override MDVIEWER_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override REVEALJS_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
#>	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CHECKIT)
	@$(ECHO) "override PANDOC_VER := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override YQ_VER := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
#>	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CHECKIT)
	#> book
	@$(ECHO) "$(DO_BOOK)-$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF):" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_README)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_MANUAL)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "# $(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)" >$(call $(TESTING)-pwd)/$(OUT_MANUAL)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "# $(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)" >$(call $(TESTING)-pwd)/$(DO_BOOK)-$(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(DOITALL)
ifeq ($(OS_TYPE),Linux)
	@$(LESS_BIN) $(call $(TESTING)-pwd)/$(notdir $(call $(TESTING)-pwd)).$(EXTN_LPDF) \
		| $(SED) -n \
			-e "/$(COMPOSER_HEADLINE)/p" \
			-e "/$(COMPOSER_LICENSE)/p" \
			-e "/$(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT)/p"
endif
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CLEANER)
	#> pandoc
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(COMPOSER_PANDOC) c_type="json" c_base="$(OUT_README)" c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT)"
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
	#> binaries
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
	#> versions
	$(call $(TESTING)-find,[(].*$(PANDOC_VER).*[)])
	$(call $(TESTING)-find,[(].*$(YQ_VER).*[)])
	$(call $(TESTING)-count,12,$(NOTHING))
	$(call $(TESTING)-count,9,$(notdir $(PANDOC_BIN)))
	$(call $(TESTING)-count,1,$(notdir $(YQ_BIN)))
	#> book
ifeq ($(OS_TYPE),Linux)
	$(call $(TESTING)-count,1,$(COMPOSER_HEADLINE))
	$(call $(TESTING)-count,10,$(COMPOSER_LICENSE))
	$(call $(TESTING)-count,7,$(notdir $(call $(TESTING)-pwd))$(COMPOSER_EXT_DEFAULT))
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
$(TESTING)-$(EXAMPLE):
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
ifneq ($(patsubst v%,%,$(YQ_CMT)),$(YQ_VER))
override YQ_CMT_DISPLAY := $(YQ_CMT)$(_D) ($(_N)$(YQ_VER)$(_D))
endif

#> update: PHONY.*$(DOITALL)
#> update: PHONY.*$(DOFORCE)
$(eval export override COMPOSER_DOITALL_$(CHECKIT) ?=)
.PHONY: $(CHECKIT)-%
$(CHECKIT)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CHECKIT)="$(*)" $(CHECKIT)

#> update: Tooling Versions
.PHONY: $(CHECKIT)
$(CHECKIT): .set_title-$(CHECKIT)
$(CHECKIT):
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
$(eval export override COMPOSER_DOITALL_$(CONFIGS) ?=)
.PHONY: $(CONFIGS)-%
$(CONFIGS)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CONFIGS)="$(*)" $(CONFIGS)

.PHONY: $(CONFIGS)
$(CONFIGS): .set_title-$(CONFIGS)
$(CONFIGS):
	@$(call $(HEADERS))
	@$(TABLE_M2) "$(_H)Variable"		"$(_H)Value"
	@$(TABLE_M2) ":---"			":---"
	@$(foreach FILE,$(COMPOSER_OPTIONS),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$(subst ",\",$($(FILE)))$(if $(filter $(FILE),$(COMPOSER_EXPORTED)),$(if $($(FILE)), )$(_E)$(MARKER)$(_D))"; \
	)
ifneq ($(COMPOSER_DOITALL_$(CONFIGS)),)
	@$(LINERULE)
	@$(subst $(NULL) -,,$(ENV)) | $(SORT)
endif

########################################
# {{{2 $(TARGETS) ----------------------

.PHONY: $(TARGETS)
$(TARGETS): .set_title-$(TARGETS)
$(TARGETS):
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
			$(PRINT) "$(_E)$(subst : ,$(_D) $(DIVIDE) $(_N),$(subst $(TOKEN), ,$(FILE)))$(_D)"; \
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
		$(if $(COMPOSER_EXT),-e "/^[^:]+$(subst .,[.],$(COMPOSER_EXT))[:]/d") \
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

override GIT_OPTS_CONVICT		:= --verbose .$(subst $(COMPOSER_ROOT),,$(CURDIR))

#> update: PHONY.*$(DOITALL)
$(eval export override COMPOSER_DOITALL_$(CONVICT) ?=)
.PHONY: $(CONVICT)-%
$(CONVICT)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CONVICT)="$(*)" $(CONVICT)

.PHONY: $(CONVICT)
$(CONVICT): .set_title-$(CONVICT)
$(CONVICT):
	@$(call $(HEADERS))
	$(call GIT_RUN_COMPOSER,add --all $(GIT_OPTS_CONVICT))
	$(call GIT_RUN_COMPOSER,commit \
		$(if $(COMPOSER_DOITALL_$(CONVICT)),,--edit) \
		--message="$(call COMPOSER_TIMESTAMP)" \
		$(GIT_OPTS_CONVICT) \
	)

########################################
# {{{2 $(DISTRIB) ----------------------

#> update: PHONY.*$(DISTRIB)
#	$(UPGRADE)
#	$(CREATOR)

.PHONY: $(DISTRIB)
$(DISTRIB): .set_title-$(DISTRIB)
$(DISTRIB):
	@$(call $(HEADERS))
	@if [ "$(COMPOSER)" != "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(CP) $(COMPOSER) $(CURDIR)/$(MAKEFILE); \
		if	[ -n "$(call COMPOSER_FIND,$(PATH_LIST),rsync)" ] && \
			[ -d "$(COMPOSER_PKG)" ]; \
		then \
			$(MKDIR) $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_PKG)); \
			$(RSYNC) $(COMPOSER_PKG)/ $(subst $(COMPOSER_DIR),$(CURDIR),$(COMPOSER_PKG)); \
		fi; \
	fi
	@$(CHMOD) $(CURDIR)/$(MAKEFILE)
#>	@$(RUNMAKE) $(UPGRADE)-$(DOITALL)
#>	@$(RUNMAKE) $(CREATOR)
	@$(REALMAKE) --directory $(CURDIR) $(UPGRADE)-$(DOITALL)
	@$(REALMAKE) --directory $(CURDIR) $(CREATOR)
	@$(ENDOLINE)
	@$(LS) $(CURDIR)

########################################
# {{{2 $(UPGRADE) ----------------------

#> update: PHONY.*(UPGRADE)

#> update: PHONY.*$(DOITALL)
$(eval export override COMPOSER_DOITALL_$(UPGRADE) ?=)
.PHONY: $(UPGRADE)-%
$(UPGRADE)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(UPGRADE)="$(*)" $(UPGRADE)

.PHONY: $(UPGRADE)
$(UPGRADE): .set_title-$(UPGRADE)
$(UPGRADE):
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
$(PUBLISH):
	@$(call $(HEADERS))
	@$(RUNMAKE) $(NOTHING)-$(PUBLISH)-FUTURE

########################################
# {{{2 $(INSTALL) ----------------------

#> update: $(MAKE) / @+

#> update: PHONY.*$(DOITALL)
#> update: PHONY.*$(DOFORCE)
$(eval export override COMPOSER_DOITALL_$(INSTALL) ?=)
.PHONY: $(INSTALL)-%
$(INSTALL)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(INSTALL)="$(*)" $(INSTALL)

.PHONY: $(INSTALL)
#>$(INSTALL): .set_title-$(INSTALL)
$(INSTALL): $(INSTALL)-$(SUBDIRS)-$(HEADERS)
$(INSTALL):
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
	@$(foreach FILE,$(filter-out $(NOTHING)-%,$(COMPOSER_SUBDIRS)),\
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
			"s|^($(call COMPOSER_REGEX_OVERRIDE,COMPOSER_TEACHER)).*$$|\1 $(~)(abspath $(~)(COMPOSER_MY_PATH)/`$(REALPATH) $(abspath $(dir $(1))) $(3)`)|g" \
			$(1); \
	fi
endef

########################################
# {{{2 $(CLEANER) ----------------------

#> update: $(MAKE) / @+

#> update: PHONY.*$(DOITALL)
$(eval export override COMPOSER_DOITALL_$(CLEANER) ?=)
.PHONY: $(CLEANER)-%
$(CLEANER)-%:
	@$(RUNMAKE) COMPOSER_DOITALL_$(CLEANER)="$(*)" $(CLEANER)

.PHONY: $(CLEANER)
#>$(CLEANER): .set_title-$(CLEANER)
$(CLEANER): $(CLEANER)-$(SUBDIRS)-$(HEADERS)
$(CLEANER):
ifneq ($(COMPOSER_LOG),)
ifneq ($(wildcard $(CURDIR)/$(COMPOSER_LOG)),)
	@$(call $(HEADERS)-rm,$(CURDIR),$(COMPOSER_LOG))
	@$(RM) $(CURDIR)/$(COMPOSER_LOG) >/dev/null
endif
endif
ifneq ($(COMPOSER_RELEASE),)
ifneq ($(wildcard $(COMPOSER_TMP)),)
	@$(call $(HEADERS)-rm,$(CURDIR),$(notdir $(COMPOSER_TMP)))
	@$(ECHO) "$(_S)"
	@$(RM) --recursive $(COMPOSER_TMP)
	@$(ECHO) "$(_D)"
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
		$(call NEWLINE) \
	)
ifneq ($(COMPOSER_DOITALL_$(CLEANER)),)
	@+$(MAKE) $(MAKE_OPTIONS) $(CLEANER)-$(SUBDIRS)
endif

########################################
# {{{2 $(DOITALL) ----------------------

#> update: $(MAKE) / @+

#> update: PHONY.*$(DOITALL)
$(eval export override COMPOSER_DOITALL_$(DOITALL) ?=)
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
$(DOITALL): $(NOTHING)-$(TARGETS)
else ifeq ($(COMPOSER_TARGETS),$(NOTHING))
$(DOITALL): $(NOTHING)-$(NOTHING)-$(TARGETS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_TARGETS)),)
$(DOITALL): $(COMPOSER_TARGETS)
else
$(DOITALL): $(COMPOSER_TARGETS)
endif
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(DOITALL)-$(SUBDIRS)
endif
endif
$(DOITALL):
	@$(ECHO) ""

.PHONY: $(DOITALL)-specials
$(DOITALL)-specials:
	@+$(strip $(call $(TARGETS)-list,$(DOITALL))) \
		| $(XARGS) $(MAKE) $(MAKE_OPTIONS) {}

########################################
# {{{2 $(SUBDIRS) ----------------------

.PHONY: $(SUBDIRS)
$(SUBDIRS): $(NOTHING)-$(NOTHING)-$(TARGETS)-$(SUBDIRS)
$(SUBDIRS):
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
	@$$(call $$(HEADERS)-$$(SUBDIRS),$(1))
endif
	@$$(ECHO) ""

.PHONY: $(1)-$(SUBDIRS)
ifeq ($(COMPOSER_SUBDIRS),)
$(1)-$(SUBDIRS): $(NOTHING)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
$(1)-$(SUBDIRS): $(NOTHING)-$(NOTHING)-$(SUBDIRS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_SUBDIRS)),)
$(1)-$(SUBDIRS): $(COMPOSER_SUBDIRS)
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
ifeq ($(COMPOSER_LOG),)
$(PRINTER): $(NOTHING)-COMPOSER_LOG
endif
$(PRINTER): $(PRINTER)-list
$(PRINTER):
	@$(ECHO) ""

.PHONY: $(PRINTER)-list
$(PRINTER)-list: $(COMPOSER_LOG)
$(PRINTER)-list:
	@$(ECHO) ""

$(COMPOSER_LOG): $(if \
		$(COMPOSER_EXT),\
		$(wildcard $(filter %$(COMPOSER_EXT),$(COMPOSER_CONTENTS_FILES))),\
		$(NOTHING)-COMPOSER_EXT \
		)
$(COMPOSER_LOG):
	@$(LS) --directory $(COMPOSER_LOG) $(?) \
		|| $(TRUE)

################################################################################
# {{{1 Pandoc Targets ----------------------------------------------------------
################################################################################

########################################
# {{{2 $(COMPOSER_PANDOC) --------------

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(c_base).$(EXTENSION)
$(COMPOSER_PANDOC):
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := $(COMPOSER_PANDOC))$(call $(HEADERS)-note,$(c_base) $(MARKER) $(c_type),$(c_list))
endif
	@$(ECHO) ""

$(c_base).$(EXTENSION): $(c_list)
$(c_base).$(EXTENSION):
	@$(call $(HEADERS)-$(COMPOSER_PANDOC),$(@))
ifneq ($(PANDOC_OPTIONS_ERROR),)
	@$(ENDOLINE)
	@$(PRINT) "$(_F)$(MARKER) ERROR: $(c_base).$(EXTENSION): $(call PANDOC_OPTIONS_ERROR)"
	@$(ENDOLINE)
	@exit 1
endif
ifneq ($(wildcard $(CURDIR)/$(c_base).$(EXTENSION).lock),)
	@$(ENDOLINE)
	@$(PRINT) "$(_F)$(MARKER) ERROR: $(c_base).$(EXTENSION): lock file exists"
	@$(ENDOLINE)
	@exit 1
endif
	@$(ECHO) "$(_F)"
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >>$(CURDIR)/$(c_base).$(EXTENSION).lock
ifeq ($(c_type),$(TYPE_LPDF))
	@$(ECHO) "$(_E)"
	@$(MKDIR) $(COMPOSER_TMP)/$(c_base).$(EXTENSION).$(DATENAME)
	@$(ECHO) "$(_F)"
endif
#>	@$(PANDOC) $(subst ",\",$(call PANDOC_OPTIONS))
	@$(PANDOC) $(call PANDOC_OPTIONS)
ifneq ($(COMPOSER_LOG),)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP) $(subst ",\",$(call PANDOC_OPTIONS))\n" >>$(CURDIR)/$(COMPOSER_LOG)
endif
	@$(RM) $(c_base).$(EXTENSION).lock >/dev/null
	@$(ECHO) "$(_D)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := $(c_base).$(EXTENSION))$(call $(HEADERS)-note,$(c_base) $(MARKER) $(c_type),$(c_list))
endif

########################################
# {{{2 $(COMPOSER_EXT) -----------------

#> update: TYPE_TARGETS

override define TYPE_TARGETS =
%.$(2): %$(COMPOSER_EXT)
#>%.$(2):
	@$$(RUNMAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(+)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := $(INPUT))$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(+))
endif

%.$(2): %
#>%.$(2):
	@$$(RUNMAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(+)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := wildcard)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(+))
endif

%.$(2): $(c_list)
#>%.$(2):
	@$$(RUNMAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(+)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := list)$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(+))
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

#> update: TYPE_TARGETS

override define TYPE_DO_BOOK =
$(DO_BOOK)-%.$(2):
	@$$(RUNMAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(+)"
ifneq ($(COMPOSER_DEBUGIT),)
	@$(eval override @ := $(DO_BOOK))$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(+))
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
	@$(eval override @ := $(DO_PAGE))$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(+))
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
	@$(eval override @ := $(DO_POST))$(call $(HEADERS)-note,$$(*) $(MARKER) $(1),$$(+))
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
