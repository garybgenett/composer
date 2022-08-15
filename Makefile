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
#		* PANDOC_OPTIONS_ERROR
#	* Verify
#		* `make COMPOSER_DEBUGIT="1" _release`
#			* `make test-_release`
#			* `make $(make .all_targets | sed -nr "s|[:][ ]test-Think||gp" | sed -e "/test-_release/d" -e "/test-speed/d" | sort -u)`
#			* `make test`
#		* `make COMPOSER_DEBUGIT="config targets" debug | less -rX`
#			* `make debug-file`
#			* `mv Composer-*.log artifacts/`
#		* `make test-targets`
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
#		* Test: Bootstrap
#			* Browsers
#				* Desktop
#				* Mobile
#				* Text-based
#			* Pages
#				* README.site.html (`make docs`)
#				* _site/index.html (`make site-template-all`)
#				* _site/index.html (`make site-template`)
#	* Prepare
#		* Update: README.md
#			* `make COMPOSER_DEBUGIT="1" help-force | less -rX`
#				* `override INPUT := commonmark`
#				* Fits in $(COLUMNS) characters
#				* Mouse select color handling
#				* Test all "Reference" links in browser
#			* `make docs`
#				* Screenshot
#			* Spell check
#	* Publish
#		* Check: `git diff master Makefile`
#		* Update: COMPOSER_VERSION
#		* Release: `rm -frv {.[^.],}*; make _release`
#		* Verify: `git diff master`
#		* Commit: `git commit`, `git tag`
#		* Branch: `git branch -D master`, `git checkout -B master`, `git checkout devel`
################################################################################
# {{{1 TODO
################################################################################
# PDF / EPUB / DOCX
#	man pandoc = REPRODUCIBLE BUILDS
#		Some of the document formats pandoc targets (such as EPUB, docx, and ODT) include build timestamps in the generated document.  That means that the files generated on successive builds will differ, even if the source does not.  To avoid this, set the SOURCE_DATE_EPOCH environment variable, and the timestamp will be taken from it instead of the current time.  SOURCE_DATE_EPOCH should contain an integer unix timestamp (specifying the number of second since midnight UTC January 1, 1970).
#		Some document formats also include a unique identifier.  For EPUB, this can be set explicitly by setting the identifier metadata field (see EPUB Metadata, above).
# PDF
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
# EPUB
#	--epub-metadata="[...]" --epub-cover-image="[...]" --epub-embed-font="[...]"
# DOCX
#	pandoc --from docx --to markdown --extract-media=README.markdown.files --track-changes=all --output=README.markdown README.docx ; vdiff README.md.txt README.markdown
#	--from "docx" --track-changes="all"
#	--from "docx|epub" --extract-media="[...]"
# SITE
#	SITE_GIT_REPO ?= git@github.com:garybgenett/garybgenett.net.git
#WORKING:NOW
# document
#	change in behavior... particularly yml files...
#		$(c_base).$(EXTENSION): $(COMPOSER_YML_LIST) $($(PUBLISH)-cache) $($(PUBLISH)-library)
#	$(COMPOSER_YML) and note that it is now an override for everything
#		expected behavior = *+ = https://mikefarah.gitbook.io/yq/operators/multiply-merge
#		hashes will overlap, and arrays will append
#		best practice is to put permanent site menus at the top, and maybe a sidebar or two, and then use sidebars and bottom nav for per-* use
#		probably not a bad idea to also do COMPOSER_INCLUDE globally...
#	if brand is empty or logo.img doesn't exist, they will be skipped
#		side note to remove revealjs per-directory hack...
#	if site_search_name is empty, it disables it
#	new $(CONVICT) -> $(PRINTER)/c_list hack
#	COMPOSER_TMP needs a mention, at this point...
#	everything stems from the Makefile, so that is the only place to check for changes...
#	only one build at a time...
# other
#	--resource-path = something like COMPOSER_CSS?
#	so many c_list/+ tests... really...?  probably...
#			3 = markdown/wildcard/list + book/page + empty c_type/c_base/c_list
#		documentation can be as simple as "+ > c_list" in precedence...?  probably...
#		release notes, now...?  meh...
#	what happens if a page/post file variable conflicts with a $(COMPOSER_YML)?  --defaults wins.
#		header-includes?  leave it to c_options?  maybe c_header?
#			only an issue for c_site, so maybe an array option in $(COMPOSER_YML)
#	COMPOSER_KEEPING test & document
#	$(CLEANER)-logs test & document
#	add aria information back in, because we are good people...
#		https://getbootstrap.com/docs/5.2/components/dropdowns/#accessibility
#		https://getbootstrap.com/docs/4.5/utilities/screen-readers
################################################################################
# }}}1
################################################################################
# {{{1 Composer Globals --------------------------------------------------------
################################################################################

override COMPOSER_COMPOSER		:= Gary B. Genett
override COMPOSER_BASENAME		:= Composer
override COMPOSER_TINYNAME		:= composer
override COMPOSER_VERSION		:= v3.1

override COMPOSER_HOMEPAGE		:= https://github.com/garybgenett/composer
override COMPOSER_SEARCH		:= garybgenett.net

override COMPOSER_TECHNAME		:= $(COMPOSER_BASENAME) CMS
override COMPOSER_FULLNAME		:= $(COMPOSER_TECHNAME) $(COMPOSER_VERSION)
override COMPOSER_FILENAME		:= $(COMPOSER_BASENAME)-$(COMPOSER_VERSION)

override COMPOSER_HEADLINE		:= $(COMPOSER_TECHNAME): Content Make System
override COMPOSER_LICENSE		:= $(COMPOSER_TECHNAME) License
override COMPOSER_TAGLINE		:= Happy Making!

override COPYRIGHT_FULL			:= Copyright (c) 2014, 2015, 2022, $(COMPOSER_COMPOSER)
override COPYRIGHT_SHORT		:= Copyright (c) 2022, $(COMPOSER_COMPOSER)
override CREATED_TAGLINE		:= Composed with $(COMPOSER_TECHNAME)

override COMPOSER_TIMESTAMP		= [$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)]

########################################

override SPECIAL_VAL			:= 0
override CSS_ALT			:= css_alt

override COLUMNS			:= 80
override EOL				:= lf

override HEAD_MAIN			:= 1
override DEPTH_DEFAULT			:= 2
override DEPTH_MAX			:= 6

########################################

override COMPOSER_SETTINGS		:= .composer.mk
override COMPOSER_YML			:= .composer.yml
override COMPOSER_CSS			:= .composer.css
override COMPOSER_LOG_DEFAULT		:= .composed
override COMPOSER_EXT_DEFAULT		:= .md
override COMPOSER_EXT_SPECIAL		:= $(COMPOSER_EXT_DEFAULT).cms

#> update: TYPE_TARGETS
override TYPE_DEFAULT			:= html
override EXTN_DEFAULT			:= $(TYPE_DEFAULT)

override OUT_README			:= README
override OUT_LICENSE			:= LICENSE
override OUT_MANUAL			:= $(COMPOSER_FILENAME).Manual

########################################

override MAKEFILE_LIST			:= $(abspath $(MAKEFILE_LIST))
override COMPOSER			:= $(lastword $(MAKEFILE_LIST))

override COMPOSER_DIR			:= $(abspath $(dir $(COMPOSER)))
override COMPOSER_ROOT			:= $(abspath $(dir $(lastword $(filter-out $(COMPOSER),$(MAKEFILE_LIST)))))
ifeq ($(COMPOSER_ROOT),)
override COMPOSER_ROOT			:= $(CURDIR)
endif

override COMPOSER_TMP			:= $(CURDIR)/.composer.tmp
override COMPOSER_LIBRARY		:=

override COMPOSER_PKG			:= $(COMPOSER_DIR)/.sources
override COMPOSER_ART			:= $(COMPOSER_DIR)/artifacts
override COMPOSER_BIN			:= $(COMPOSER_DIR)/bin

override BOOTSTRAP_CSS_JS		:= $(COMPOSER_ART)/bootstrap.source.js
override BOOTSTRAP_CSS_CSS		:= $(COMPOSER_ART)/bootstrap.source.css
override BOOTSTRAP_CSS			:= $(COMPOSER_ART)/bootstrap.css

override TEX_PDF_TEMPLATE		:= $(COMPOSER_ART)/pdf.latex
override REVEALJS_CSS			:= $(COMPOSER_ART)/revealjs.css

#WORKING:NOW:NOW
#	make these somehow configurable...
#	must be .composer.mk, for revealjs
#	however, must also be <composer_root> enabled...
#	document!
override COMPOSER_ICON			:= $(COMPOSER_ART)/icon.img
override COMPOSER_LOGO			:= $(COMPOSER_ART)/logo.img

########################################

override HTML_BREAK			:= <p></p>
override MENU_SELF			:= _

override PUBLISH_COLS_MAIN_SIZE		:= 6
override PUBLISH_COLS_MOBILE_HIDE	:= 1
override PUBLISH_COLS_STICKY		:= 1
override PUBLISH_COPY_SAFE		:= 1

override LIBRARY_FOLDER			:= null
override LIBRARY_AUTO_UPDATE		:= null

override LIBRARY_DIGEST_TITLE		:= Latest Updates
override LIBRARY_DIGEST_COUNT		:= 10
override LIBRARY_DIGEST_EXPANDED	:= 10
override LIBRARY_DIGEST_CHARS		:= 1024
override LIBRARY_DIGEST_SPACER		:= 1
override LIBRARY_DIGEST_CONTINUE	:= "[...]"
override LIBRARY_DIGEST_PERMALINK	:= (permalink to full text)

########################################

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
override OUTPUT_FILENAME		= $(COMPOSER_FILENAME).$(1)-$(DATENAME).$(EXTN_TEXT)
override TESTING_DIR			:= $(COMPOSER_DIR)/.$(COMPOSER_FILENAME)

########################################

override COMPOSER_RELEASE		:=
ifeq ($(COMPOSER_DIR),$(CURDIR))
override COMPOSER_RELEASE		:= 1
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
	) \
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

override TOKEN				:= ~^~

########################################

#>include $(1)/$(COMPOSER_SETTINGS)

override define SOURCE_INCLUDES =
$(if $(wildcard $(1)/$(COMPOSER_SETTINGS)),\
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> SOURCE			[$(1)/$(COMPOSER_SETTINGS)])) \
$(foreach FILE,\
	$(shell \
		$(SED) -n "/^$(call COMPOSER_REGEX_OVERRIDE).*$$/p" $(1)/$(COMPOSER_SETTINGS) \
		| $(SED) -e "s|[[:space:]]+|$(TOKEN)|g" -e "s|$$| |g" \
	),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> OVERRIDE			[$(subst $(TOKEN), ,$(FILE))])) \
	$(eval $(subst $(TOKEN), ,$(FILE))) \
))
endef

$(call SOURCE_INCLUDES,$(COMPOSER_DIR))
ifeq ($(COMPOSER_RELEASE),)
$(call SOURCE_INCLUDES,$(CURDIR))
endif

$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDE		[$(COMPOSER_INCLUDE)]))

########################################

override COMPOSER_INCLUDES_TREE		:=
$(foreach FILE,$(abspath $(dir $(MAKEFILE_LIST))),\
	$(eval override COMPOSER_INCLUDES_TREE := $(FILE) $(COMPOSER_INCLUDES_TREE)) \
)
override COMPOSER_INCLUDES_TREE		:= $(strip $(COMPOSER_INCLUDES_TREE))
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> MAKEFILE_LIST		[$(MAKEFILE_LIST)]))
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES_TREE	[$(COMPOSER_INCLUDES_TREE)]))

########################################

override COMPOSER_INCLUDES_LIST		:= $(COMPOSER_INCLUDES_TREE)
ifeq ($(COMPOSER_INCLUDE),)
ifneq ($(CURDIR),$(COMPOSER_DIR))
ifneq ($(CURDIR),$(COMPOSER_ROOT))
override COMPOSER_INCLUDES_LIST		:= $(firstword $(COMPOSER_INCLUDES_TREE)) $(lastword $(COMPOSER_INCLUDES_TREE))
endif
endif
endif
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES_LIST	[$(COMPOSER_INCLUDES_LIST)]))

########################################

override COMPOSER_INCLUDES		:=
$(foreach FILE,$(addsuffix /$(COMPOSER_SETTINGS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD			[$(FILE)])) \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE			[$(FILE)])) \
		$(eval override MAKEFILE_LIST := $(filter-out $(FILE),$(MAKEFILE_LIST))) \
		$(eval override COMPOSER_INCLUDES := $(COMPOSER_INCLUDES) $(FILE)) \
		$(eval override COMPOSER_MY_PATH := $(abspath $(dir $(FILE)))) \
		$(eval include $(FILE)) \
	) \
)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES		[$(COMPOSER_INCLUDES)]))

########################################

override COMPOSER_YML_LIST		:=
$(foreach FILE,$(addsuffix /$(COMPOSER_YML),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD_YML			[$(FILE)])) \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE_YML			[$(FILE)])) \
		$(eval override COMPOSER_YML_LIST := $(COMPOSER_YML_LIST) $(FILE)) \
	) \
)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_YML_LIST		[$(COMPOSER_YML_LIST)]))

########################################

#> update: includes duplicates

#>override c_css			?=
#>$(call READ_ALIASES,s,s,c_css)
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

override SILENT				:= --silent --debug=none

########################################

override MAKEJOBS_DEFAULT		:= 1

$(call READ_ALIASES,J,c_jobs,MAKEJOBS)
override MAKEJOBS			?= $(MAKEJOBS_DEFAULT)
ifeq ($(MAKEJOBS),)
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
#> update: COMPOSER_OPTIONS

########################################

$(call READ_ALIASES,C,c_color,COMPOSER_DOCOLOR)
$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)

override COMPOSER_DOCOLOR		?= 1
override COMPOSER_DEBUGIT		?=
override COMPOSER_INCLUDE		?=
override COMPOSER_DEPENDS		?=
override COMPOSER_KEEPING		?= 100

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

#>ifneq ($(COMPOSER_RELEASE),)
#>override COMPOSER_TARGETS		:=
#>override COMPOSER_SUBDIRS		:=
#>override COMPOSER_IGNORES		:=
#>endif

override COMPOSER_IGNORES		:= $(sort \
	$(COMPOSER_IGNORES) \
	$(notdir $(COMPOSER_TMP)) \
)

########################################

$(call READ_ALIASES,S,S,c_site)
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
#>override c_base			?= $(OUT_README)
#>override c_list			?= $(c_base)$(COMPOSER_EXT)
#>override c_css			?= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override c_site				?=
override c_type				?= $(TYPE_DEFAULT)
override c_base				?=
override c_list				?=
override c_lang				?= en-US
override c_css				?=
override c_toc				?=
override c_level			?= $(DEPTH_DEFAULT)
override c_margin			?= 0.8in
override c_margin_top			?=
override c_margin_bottom		?=
override c_margin_left			?=
override c_margin_right			?=
override c_options			?=

override c_list_plus			:=

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
override PANDOC_LNX_DST			:= $(patsubst %.tar.gz,%,$(PANDOC_LNX_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/bin/pandoc
override PANDOC_WIN_DST			:= $(patsubst %.zip,%,$(PANDOC_WIN_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/pandoc.exe
override PANDOC_MAC_DST			:= $(patsubst %.zip,%,$(PANDOC_MAC_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/bin/pandoc
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
override YQ_LNX_DST			:= $(patsubst %.tar.gz,%,$(YQ_LNX_SRC))-$(YQ_VER)/$(patsubst %.tar.gz,%,$(YQ_LNX_SRC))
override YQ_WIN_DST			:= $(patsubst %.zip,%,$(YQ_WIN_SRC))-$(YQ_VER)/$(patsubst %.zip,%,$(YQ_WIN_SRC)).exe
override YQ_MAC_DST			:= $(patsubst %.tar.gz,%,$(YQ_MAC_SRC))-$(YQ_VER)/$(patsubst %.tar.gz,%,$(YQ_MAC_SRC))
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

# https://commonmark.org
# https://github.com/commonmark/commonmark-spec
# https://github.com/commonmark/commonmark-spec/blob/master/LICENSE
ifneq ($(origin COMMONMARK_CMT),override)
override COMMONMARK_CMT			:= 0.30.0
endif
override COMMONMARK_LIC			:= CC-BY-SA
override COMMONMARK_SRC			:= https://github.com/commonmark/commonmark-spec.git
override COMMONMARK_DIR			:= $(COMPOSER_DIR)/commonmark

########################################

# https://getbootstrap.com
# https://github.com/twbs/bootstrap
# https://github.com/twbs/bootstrap/blob/main/LICENSE
ifneq ($(origin BOOTSTRAP_CMT),override)
override BOOTSTRAP_CMT			:= v5.1.3
endif
override BOOTSTRAP_DOC_VER		:= 5.1
override BOOTSTRAP_LIC			:= MIT
override BOOTSTRAP_SRC			:= https://github.com/twbs/bootstrap.git
override BOOTSTRAP_DIR			:= $(COMPOSER_DIR)/bootstrap
override BOOTSTRAP_CSS_JS_SRC		:= $(BOOTSTRAP_DIR)/dist/js/bootstrap.bundle.js
override BOOTSTRAP_CSS_CSS_SRC		:= $(BOOTSTRAP_DIR)/dist/css/bootstrap.css

########################################

# https://bootswatch.com
# https://github.com/thomaspark/bootswatch
# https://github.com/thomaspark/bootswatch/blob/master/LICENSE
ifneq ($(origin BOOTSWATCH_CMT),override)
override BOOTSWATCH_CMT			:= v5.1.3
endif
override BOOTSWATCH_LIC			:= MIT
override BOOTSWATCH_SRC			:= https://github.com/thomaspark/bootswatch.git
override BOOTSWATCH_DIR			:= $(COMPOSER_DIR)/bootswatch

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

########################################

# https://github.com/hakimel/reveal.js
# https://github.com/hakimel/reveal.js/blob/master/LICENSE
ifneq ($(origin REVEALJS_CMT),override)
override REVEALJS_CMT			:= 4.3.1
endif
override REVEALJS_LIC			:= MIT
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DIR			:= $(COMPOSER_DIR)/revealjs

########################################

#WORKING:NOW
# expose these as $(CSS_ALT)-type variables...?
# it's probably time to make each of them a tested part of the team...
# four options, including for revealjs, which has each of these
#	light (default)
#	dark (css_alt)
#	solarized-light
#	solarized-dark
# copy to, and reference from, $(COMPOSER_ART) ...?
# document

override MDVIEWER_CSS			:= $(MDVIEWER_DIR)/themes/markdown7.css
override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DIR)/themes/markdown9.css
override MDVIEWER_CSS_SOLAR		:= $(MDVIEWER_DIR)/themes/solarized-light.css
override MDVIEWER_CSS_SOLAR_ALT		:= $(MDVIEWER_DIR)/themes/solarized-dark.css

override BOOTSTRAP_CSS_THEME		:= $(MDVIEWER_CSS_SOLAR)

#WORKING:NOW
#		journal
#		quartz
#		sketchy
#		slate
#		solar

override BOOTSWATCH_CSS_LIGHT		:= $(COMPOSER_DIR)/bootswatch/dist/flatly/bootstrap.css
#>override BOOTSWATCH_CSS_DARK		:= $(COMPOSER_DIR)/bootswatch/dist/cyborg/bootstrap.css
override BOOTSWATCH_CSS_DARK		:= $(COMPOSER_DIR)/bootswatch/dist/darkly/bootstrap.css
override BOOTSWATCH_CSS_SOLAR_LIGHT	:= $(BOOTSWATCH_CSS_LIGHT)
override BOOTSWATCH_CSS_SOLAR_DARK	:= $(COMPOSER_DIR)/bootswatch/dist/solar/bootstrap.css

override REVEALJS_CSS_THEME		:= $(REVEALJS_DIR)/dist/theme/black.css
override REVEALJS_CSS_THEME_SOLAR	:= $(REVEALJS_DIR)/dist/theme/solarized.css

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

export LC_ALL				:=
export LC_COLLATE			:= C

########################################
## {{{2 Paths --------------------------

#> sed -nr "s|^override[[:space:]]+([^[:space:]]+).+[(]PATH_LIST[)].+$|\1|gp" Makefile | while read -r FILE; do echo "--- ${FILE} ---"; grep -E "[(]${FILE}[)]" Makefile; done

override BASH				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)
override FIND				:= $(call COMPOSER_FIND,$(PATH_LIST),find) -L
#WORKING no longer needed?  $(TESTING)-speed -> $(TESTING)-stress, and add $(CLEANER)/$(DOITALL) for a vary large directory of files
override XARGS				:= $(call COMPOSER_FIND,$(PATH_LIST),xargs) --max-procs=$(MAKEJOBS) -I {}
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

override BASE64				:= $(call COMPOSER_FIND,$(PATH_LIST),base64) -w0
override CAT				:= $(call COMPOSER_FIND,$(PATH_LIST),cat)
override CHMOD				:= $(call COMPOSER_FIND,$(PATH_LIST),chmod) -v 755
override CP				:= $(call COMPOSER_FIND,$(PATH_LIST),cp) -afv --dereference
override DATE				:= $(call COMPOSER_FIND,$(PATH_LIST),date) --iso=seconds
override DIRNAME			:= $(call COMPOSER_FIND,$(PATH_LIST),dirname)
override ECHO				:= $(call COMPOSER_FIND,$(PATH_LIST),echo) -en
override ENV				:= $(call COMPOSER_FIND,$(PATH_LIST),env) - PATH="$(PATH)"
override EXPR				:= $(call COMPOSER_FIND,$(PATH_LIST),expr)
override HEAD				:= $(call COMPOSER_FIND,$(PATH_LIST),head)
override LN				:= $(call COMPOSER_FIND,$(PATH_LIST),ln) -fsv --relative
override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) --color=auto --time-style=long-iso -asF -l
override LS_TIME			:= $(call COMPOSER_FIND,$(PATH_LIST),ls) -dt
override MKDIR				:= $(call COMPOSER_FIND,$(PATH_LIST),install) -dv
override MV				:= $(call COMPOSER_FIND,$(PATH_LIST),mv) -fv
override PRINTF				:= $(call COMPOSER_FIND,$(PATH_LIST),printf)
override REALPATH			:= $(call COMPOSER_FIND,$(PATH_LIST),realpath) --canonicalize-missing --no-symlinks --relative-to
override RM				:= $(call COMPOSER_FIND,$(PATH_LIST),rm) -fv
override SORT				:= $(call COMPOSER_FIND,$(PATH_LIST),sort) -uV
override SPLIT				:= $(call COMPOSER_FIND,$(PATH_LIST),split) --verbose --bytes="1000000" --numeric-suffixes="0" --suffix-length="3" --additional-suffix="-split"
override TAIL				:= $(call COMPOSER_FIND,$(PATH_LIST),tail)
override TEE				:= $(call COMPOSER_FIND,$(PATH_LIST),tee)
override TOUCH				:= $(call COMPOSER_FIND,$(PATH_LIST),touch) --date="@0"
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

#> update: includes duplicates
override DOMAKE				:= $(notdir $(MAKE))
export GZIP				:=
export LESS				:=

########################################

ifeq ($(wildcard $(PANDOC_BIN)),)
ifneq ($(wildcard $(COMPOSER_BIN)/$(notdir $(PANDOC_BIN)).*),)
$(shell \
	$(CAT) $(COMPOSER_BIN)/$(notdir $(PANDOC_BIN)).* >>$(PANDOC_BIN); \
	$(CHMOD) $(PANDOC_BIN) >/dev/null \
)
override PANDOC				:= $(PANDOC_BIN)
endif
endif
ifeq ($(wildcard $(YQ_BIN)),)
ifneq ($(wildcard $(COMPOSER_BIN)/$(notdir $(YQ_BIN)).*),)
$(shell \
	$(CAT) $(COMPOSER_BIN)/$(notdir $(YQ_BIN)).* >>$(YQ_BIN); \
	$(CHMOD) $(YQ_BIN) >/dev/null \
)
override YQ				:= $(YQ_BIN)
endif
endif

#>#> update: includes duplicates
#>override UPGRADE			:= _update
#>override DOITALL			:= all
ifneq ($(wildcard $(PANDOC_BIN)),)
override PANDOC				:= $(PANDOC_BIN)
endif
ifneq ($(wildcard $(YQ_BIN)),)
override YQ				:= $(YQ_BIN)
endif

########################################
## {{{2 Wrappers -----------------------

override DATESTAMP			:= $(shell $(DATE))
override DATENAME			:= $(shell $(DATE) | $(SED) \
	-e "s|[-]([0-9]{2}[:]?[0-9]{2})$$|T\1|g" \
	-e "s|[-:]||g" \
	-e "s|T|-|g" \
)
override DATEMARK			:= $(firstword $(subst T, ,$(DATESTAMP)))

########################################

override YQ_READ			:= $(YQ) --no-colors --no-doc --header-preprocess --front-matter "extract" --input-format "yaml" --output-format "json"
override YQ_WRITE			:= $(subst --front-matter "extract" ,,$(YQ_READ)) --output-format "yaml"
override YQ_WRITE_FILE			:= $(YQ_WRITE) --prettyPrint
override YQ_WRITE_OUT			:= $(YQ_WRITE_FILE) --colors
override COMPOSER_YML_DATA		:= $(YQ_READ) eval-all '. as $$file ireduce ({}; . *+ $$file)' $(COMPOSER_YML_LIST)

########################################

override GIT_RUN			= cd $(1) && $(GIT) --git-dir="$(2)" --work-tree="$(1)" $(3)
override GIT_RUN_COMPOSER		= $(call GIT_RUN,$(COMPOSER_ROOT),$(strip $(if \
		$(wildcard $(COMPOSER_ROOT).git),\
		$(COMPOSER_ROOT).git ,\
		$(COMPOSER_ROOT)/.git \
	)),$(1))

#>	$(RM) $(1)/.git
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
	fi
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
	$(CHMOD) $(1)/$(5); \
	$(MKDIR) $(COMPOSER_BIN); \
	$(RM) $(COMPOSER_BIN)/$(notdir $(5)).*; \
	$(SPLIT) $(1)/$(5) $(COMPOSER_BIN)/$(notdir $(5)).
endef

################################################################################
# {{{1 Pandoc Options ----------------------------------------------------------
################################################################################

#>override INPUT			:= commonmark
override INPUT				:= markdown
override OUTPUT				:= $(c_type)
override EXTENSION			:= $(c_type)

########################################
## {{{2 Types --------------------------

#> update: TYPE_TARGETS

override DESC_HTML			:= HyperText Markup Language
override DESC_LPDF			:= Portable Document Format
override DESC_EPUB			:= Electronic Publication
override DESC_PRES			:= Reveal.js Presentation
override DESC_DOCX			:= Microsoft Word
override DESC_PPTX			:= Microsoft PowerPoint
override DESC_TEXT			:= Plain Text (well-formatted)
override DESC_LINT			:= Markdown (for testing)

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

#> update: includes duplicates
override PUBLISH			:= site

#> update: COMPOSER_TARGETS.*=
ifneq ($(COMPOSER_RELEASE),)
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(strip \
	$(OUT_README).$(PUBLISH).$(EXTN_HTML) \
	$(OUT_README).$(EXTN_HTML) \
	$(OUT_README).$(EXTN_LPDF) \
	$(OUT_README).$(EXTN_EPUB) \
	$(OUT_README).$(EXTN_PRES) \
	$(OUT_README).$(EXTN_DOCX) \
)
#>
#>	$(OUT_README).$(EXTN_PPTX) \
#>	$(OUT_README).$(EXTN_TEXT) \
#>	$(OUT_README).$(EXTN_LINT) \
#>)
endif
endif

########################################
## {{{2 CSS ----------------------------

#WORKING:NOW do something like this for c_margin?

override define c_css_select =
$(strip $(if $(c_css),\
	$(if $(filter $(SPECIAL_VAL),$(c_css)),,\
	$(if $(filter $(CSS_ALT),$(c_css)),$(MDVIEWER_CSS_ALT) ,\
	$(abspath $(c_css)) \
	)) \
,\
	$(if $(c_site),$(BOOTSTRAP_CSS_THEME) ,\
	$(if $(filter $(TYPE_PRES),$(c_type)),$(REVEALJS_CSS_THEME) ,\
	$(MDVIEWER_CSS) \
	)) \
))
endef

#>$(eval override c_css			:= $(call c_css_select))

########################################
## {{{2 Command ------------------------

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

override PANDOC_OPTIONS_DATA		:= $(PANDOC_OPTIONS_DATA) $(foreach FILE,$(COMPOSER_YML_LIST),--defaults="$(FILE)")

########################################

override PANDOC_EXTENSIONS		:=
override PANDOC_EXTENSIONS		+= +ascii_identifiers
override PANDOC_EXTENSIONS		+= +emoji
override PANDOC_EXTENSIONS		+= +fancy_lists
override PANDOC_EXTENSIONS		+= +fenced_divs
override PANDOC_EXTENSIONS		+= +footnotes
override PANDOC_EXTENSIONS		+= +gfm_auto_identifiers
override PANDOC_EXTENSIONS		+= +implicit_figures
override PANDOC_EXTENSIONS		+= +implicit_header_references
override PANDOC_EXTENSIONS		+= +pipe_tables
override PANDOC_EXTENSIONS		+= +raw_html
override PANDOC_EXTENSIONS		+= +smart
override PANDOC_EXTENSIONS		+= +strikeout
override PANDOC_EXTENSIONS		+= +superscript
override PANDOC_EXTENSIONS		+= +task_lists
override PANDOC_EXTENSIONS		+= +yaml_metadata_block
ifneq ($(filter markdown,$(INPUT)),)
override PANDOC_EXTENSIONS		+= +auto_identifiers
override PANDOC_EXTENSIONS		+= +header_attributes
override PANDOC_EXTENSIONS		+= +inline_notes
override PANDOC_EXTENSIONS		+= +intraword_underscores
override PANDOC_EXTENSIONS		+= +line_blocks
override PANDOC_EXTENSIONS		+= +markdown_in_html_blocks
override PANDOC_EXTENSIONS		+= +pandoc_title_block
override PANDOC_EXTENSIONS		+= +raw_tex
override PANDOC_EXTENSIONS		+= +shortcut_reference_links
override PANDOC_EXTENSIONS		+= +spaced_reference_links
endif

override PANDOC_OPTIONS			= $(strip $(PANDOC_OPTIONS_DATA) \
	$(if $(c_lang),\
		--variable=lang="$(c_lang)" \
	) \
	$(if $(or \
		$(filter $(c_type),$(TYPE_HTML)) ,\
		$(filter $(c_type),$(TYPE_PRES)) ,\
		),--wrap="none",--wrap="auto" \
	) \
	$(if $(filter $(c_type),$(TYPE_LPDF)),\
		--pdf-engine="$(PANDOC_TEX_PDF)" \
		--pdf-engine-opt="-output-directory=$(COMPOSER_TMP)/$(notdir $(c_base)).$(EXTENSION).$(DATENAME)" \
		--include-in-header="$(TEX_PDF_TEMPLATE)" \
		--listings \
	) \
	$(if $(filter $(c_type),$(TYPE_PRES)),\
		--variable=revealjs-url="$(REVEALJS_DIR)" \
	) \
	$(if $(wildcard $(COMPOSER_ICON)),\
		$(if $(or \
			$(c_site) ,\
			$(filter $(c_type),$(TYPE_HTML)) ,\
			$(filter $(c_type),$(TYPE_EPUB)) ,\
			$(filter $(c_type),$(TYPE_PRES)) ,\
		),\
			--variable=header-includes="<link rel=\"icon\" type=\"image/x-icon\" href=\"$(COMPOSER_ICON)\"/>" \
		) \
	) \
	$(if $(c_site),\
		--include-in-header="$(BOOTSTRAP_CSS_JS)" \
		$(if $(call c_css_select),\
			--css="$(BOOTSTRAP_CSS_CSS)" \
			$(if $(wildcard $(BOOTSTRAP_CSS)),--css="$(BOOTSTRAP_CSS)") \
			$(if $(filter $(BOOTSTRAP_CSS_CSS),$(call c_css_select)),,--css="$(call c_css_select)") \
			,\
			--css="$(BOOTSTRAP_CSS_CSS_SRC)" \
		) \
	) \
	$(if $(call c_css_select),\
		$(if $(c_site),,\
		$(if $(filter $(c_type),$(TYPE_HTML)),	--css="$(call c_css_select)") \
		$(if $(filter $(c_type),$(TYPE_EPUB)),	--css="$(call c_css_select)") \
		$(if $(filter $(c_type),$(TYPE_PRES)),\
			$(if $(filter $(REVEALJS_CSS),$(call c_css_select)),,--css="$(call c_css_select)") \
			$(if $(wildcard $(REVEALJS_CSS)),--css="$(REVEALJS_CSS)") \
		) \
	)) \
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
		$(if $(c_margin),		--variable=geometry="margin=$(c_margin)" ,\
		$(if $(c_margin_top),		--variable=geometry="top=$(c_margin_top)") \
		$(if $(c_margin_bottom),	--variable=geometry="bottom=$(c_margin_bottom)") \
		$(if $(c_margin_left),		--variable=geometry="left=$(c_margin_left)") \
		$(if $(c_margin_right),		--variable=geometry="right=$(c_margin_right)") \
	)) \
	\
	--standalone \
	--self-contained \
	--columns="$(COLUMNS)" \
	--eol="$(EOL)" \
	\
	--from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" \
	--to="$(OUTPUT)" \
	--output="$(CURDIR)/$(c_base).$(EXTENSION)" \
	\
	$(if $(c_options),$(c_options)) \
	$(if $(c_list_plus),$(c_list_plus),$(c_list)) \
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
# {{{1 Composer Operation ------------------------------------------------------
################################################################################

override ENV_MAKE			:= $(ENV) $(REALMAKE)

override ~				:= "'$$'"
override COMPOSER_MY_PATH		:= $(~)(abspath $(~)(dir $(~)(lastword $(~)(MAKEFILE_LIST))))
override COMPOSER_TEACHER		:= $(~)(abspath $(~)(dir $(~)(COMPOSER_MY_PATH)))/$(MAKEFILE)

override COMPOSER_REGEX			:= [a-zA-Z0-9][a-zA-Z0-9_.-]*
override COMPOSER_REGEX_PREFIX		:= [_.]

#> update: includes duplicates
override DEBUGIT			:= debug
override PUBLISH			:= site

override $(DEBUGIT)-output		:= $(if $(COMPOSER_DEBUGIT),,>/dev/null)
override $(PUBLISH)-$(DEBUGIT)-output	:= $(if $(COMPOSER_DEBUGIT),$(if $(COMPOSER_DEBUGIT_ALL),,| $(SED) -n "/^<!--[[:space:]]/p"),>/dev/null)

########################################
## {{{2 Options ------------------------

#> update: COMPOSER_OPTIONS

override COMPOSER_OPTIONS_GLOBAL := \
	MAKEJOBS \
	COMPOSER_DOCOLOR \
	COMPOSER_DEBUGIT \
	COMPOSER_KEEPING \
	COMPOSER_LOG \
	COMPOSER_EXT \
	c_site \
	c_type \
	c_lang \

override COMPOSER_OPTIONS_LOCAL := \
	COMPOSER_INCLUDE \
	COMPOSER_DEPENDS \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES \
	c_base \
	c_list \
	c_css \
	c_toc \
	c_level \
	c_margin \
	c_margin_top \
	c_margin_bottom \
	c_margin_left \
	c_margin_right \
	c_options \

override COMPOSER_OPTIONS_PROTECT := \
	MAKEJOBS \
	COMPOSER_DOCOLOR \
	COMPOSER_DEBUGIT \
	\
	COMPOSER_INCLUDE \
	COMPOSER_DEPENDS \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES \
	c_base \
	c_list \

$(foreach FILE,$(COMPOSER_OPTIONS_GLOBAL)	,$(eval export $(FILE)))
$(foreach FILE,$(COMPOSER_OPTIONS_LOCAL)	,$(eval unexport $(FILE)))

override COMPOSER_OPTIONS := \
	$(shell $(SED) -n "s|^$(call COMPOSER_REGEX_OVERRIDE,,1).*$$|\1|gp" $(COMPOSER) \
	| $(SED) $(if $(c_margin),"/^c_margin_.+$$/d","/^c_margin$$/d") \
)
$(foreach FILE,$(COMPOSER_OPTIONS),\
	$(if $(or \
		$(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)) ,\
		$(filter $(FILE),$(COMPOSER_OPTIONS_LOCAL)) ,\
		),,$(error #> $(COMPOSER_FULLNAME): COMPOSER_OPTIONS: $(FILE)) \
	) \
)

$(if $(COMPOSER_DEBUGIT_ALL),\
	$(info #> COMPOSER_OPTIONS_GLOBAL	[$(strip $(COMPOSER_OPTIONS_GLOBAL))]) \
	$(info #> COMPOSER_OPTIONS_LOCAL	[$(strip $(COMPOSER_OPTIONS_LOCAL))]) \
)

########################################
## {{{2 Targets ------------------------

#> update: includes duplicates

#> update: $(DEBUGIT): targets list
#> update: $(TESTING): targets list

override COMPOSER_PANDOC		:= compose

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

########################################

override DOFORCE			:= force

########################################

override define COMPOSER_RESERVED_DOITALL =
$(if $(filter $(1)-$(2),$(MAKECMDGOALS)),\
	export override COMPOSER_DOITALL_$(1) := $(2))

.PHONY: $(1)-$(2)
$(1)-$(2): $(1)
$(1)-$(2):
	@$$(ECHO) ""
endef

$(foreach FILE,$(filter-out \
	$(HELPOUT) \
	$(HEADERS) \
	$(NOTHING) \
	$(SUBDIRS) \
,$(COMPOSER_RESERVED)),\
	$(eval export override COMPOSER_DOITALL_$(FILE) ?=) \
	$(foreach MOD,\
		$(DOITALL) \
		$(DOFORCE) \
		,\
		$(eval $(call COMPOSER_RESERVED_DOITALL,$(FILE),$(MOD))) \
	) \
)

$(eval $(call COMPOSER_RESERVED_DOITALL,$(HEADERS)-$(EXAMPLE),$(DOITALL)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(CONFIGS),$(PUBLISH)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(CONVICT),$(PRINTER)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-$(EXAMPLE),$(DOITALL)))

########################################
## {{{2 Publish ------------------------

override PUBLISH_BUILD_CMD_BEG		= <!-- $(COMPOSER_TINYNAME) $(MARKER)
override PUBLISH_BUILD_CMD_END		= $(MARKER) -->

override PUBLISH_BUILD_SH		:= $(COMPOSER_ART)/$(PUBLISH).build.sh
override PUBLISH_BUILD_SH_RUN		= \
	YQ="$(YQ)" \
	COMPOSER_YML_LIST="$(COMPOSER_YML_LIST)" \
	CURDIR="$(CURDIR)" \
	COMPOSER_ROOT="$(COMPOSER_ROOT)" \
	PUBLISH_LIBRARY_INDEX="$($(PUBLISH)-library-index)" \
	$(BASH) $(PUBLISH_BUILD_SH)

########################################

override $(PUBLISH)-cache		:= $(COMPOSER_TMP)/$(PUBLISH)-cache

override $(PUBLISH)-caches-begin := \
	nav-top \
	row-begin \
	nav-left \
	column-begin
override $(PUBLISH)-caches-end := \
	column-end \
	nav-right \
	row-end \
	nav-bottom
override $(PUBLISH)-caches := \
	$(foreach FILE,\
		$($(PUBLISH)-caches-begin) \
		$($(PUBLISH)-caches-end) \
		,\
		$($(PUBLISH)-cache).$(FILE).$(EXTN_HTML) \
	)

########################################

ifneq ($(COMPOSER_YML_LIST),)
override COMPOSER_LIBRARY_YML		:=
override COMPOSER_LIBRARY_DIR		:=
$(foreach FILE,$(addsuffix /$(COMPOSER_YML),$(COMPOSER_INCLUDES_TREE)),\
$(if $(wildcard $(FILE)),\
	$(eval override COMPOSER_LIBRARY_DIR := $(shell \
		$(CAT) $(FILE) \
		| $(YQ_WRITE) ".variables[\"$(PUBLISH)-library\"].[\"folder\"]" 2>/dev/null \
		| $(SED) "/^null$$/d" \
	)) \
	$(if $(COMPOSER_LIBRARY_DIR),\
		$(eval override COMPOSER_LIBRARY_YML := $(FILE)) \
		$(eval override COMPOSER_LIBRARY := $(abspath $(dir $(FILE)))/$(notdir $(COMPOSER_LIBRARY_DIR))) \
	) \
))

ifneq ($(and \
	$(c_site) ,\
	$(COMPOSER_LIBRARY_YML) \
),)
override $(PUBLISH)-library-variables := \
	folder:LIBRARY_FOLDER \
	auto_update:LIBRARY_AUTO_UPDATE \
	digest_title:LIBRARY_DIGEST_TITLE \
	digest_count:LIBRARY_DIGEST_COUNT \
	digest_expanded:LIBRARY_DIGEST_EXPANDED \
	digest_chars:LIBRARY_DIGEST_CHARS \
	digest_spacer:LIBRARY_DIGEST_SPACER \
	digest_continue:LIBRARY_DIGEST_CONTINUE \
	digest_permalink:LIBRARY_DIGEST_PERMALINK

override define $(PUBLISH)-library-variables-yml =
override $(PUBLISH)-library-$(word 1,$(subst :, ,$(1))) := $(shell \
	$(CAT) $(COMPOSER_LIBRARY_YML) \
	| $(YQ_WRITE) ".variables[\"$(PUBLISH)-library\"].[\"$(word 1,$(subst :, ,$(1)))\"]" 2>/dev/null \
	| $(SED) "/^null$$/d" \
)
endef

override define $(PUBLISH)-library-variables-default =
$(if $($(PUBLISH)-library-$(word 1,$(subst :, ,$(1)))),,override $(PUBLISH)-library-$(word 1,$(subst :, ,$(1))) := $($(word 2,$(subst :, ,$(1)))))
endef

$(foreach FILE,$($(PUBLISH)-library-variables),$(eval $(call $(PUBLISH)-library-variables-yml,$(FILE))))
$(foreach FILE,$($(PUBLISH)-library-variables),$(eval $(call $(PUBLISH)-library-variables-default,$(FILE))))
endif
endif

########################################

ifeq ($(abspath $(dir $(COMPOSER_LIBRARY))),$(COMPOSER_DIR))
override COMPOSER_LIBRARY		:= $(COMPOSER_ROOT)/$(notdir $(COMPOSER_LIBRARY))
endif

override $(PUBLISH)-library		:= $(COMPOSER_LIBRARY)/$(PUBLISH)-library
override $(PUBLISH)-library-metadata	:= $(COMPOSER_LIBRARY)/_metadata.yml
override $(PUBLISH)-library-index	:= $(COMPOSER_LIBRARY)/_index.yml
override $(PUBLISH)-library-digest	:= $(COMPOSER_LIBRARY)/index$(COMPOSER_EXT_DEFAULT)
override $(PUBLISH)-library-digest-src	:= $(COMPOSER_LIBRARY)/index-include$(COMPOSER_EXT_SPECIAL)

ifeq ($(abspath $(dir $(COMPOSER_LIBRARY))),$(CURDIR))
override COMPOSER_IGNORES		:= $(sort \
	$(COMPOSER_IGNORES) \
	$(notdir $(COMPOSER_LIBRARY)) \
)
endif

########################################
## {{{2 Filesystem ---------------------

#> update: COMPOSER_TARGETS.*=
#> update: COMPOSER_SUBDIRS.*=

override COMPOSER_CONTENTS		:= $(sort $(wildcard *))
override COMPOSER_CONTENTS_DIRS		:= $(patsubst %/.,%,$(wildcard $(addsuffix /.,$(COMPOSER_CONTENTS))))
override COMPOSER_CONTENTS_FILES	:= $(filter-out $(COMPOSER_CONTENTS_DIRS),$(COMPOSER_CONTENTS))
override COMPOSER_CONTENTS_EXT		:= $(filter %$(COMPOSER_EXT),$(COMPOSER_CONTENTS_FILES))

ifneq ($(COMPOSER_EXT),)
override COMPOSER_TARGETS_AUTO		:= $(patsubst %$(COMPOSER_EXT),%.$(EXTENSION),$(COMPOSER_CONTENTS_EXT))
else
override COMPOSER_TARGETS_AUTO		:= $(addsuffix .$(EXTENSION),$(filter-out %.$(EXTENSION),$(COMPOSER_CONTENTS_FILES)))
endif
#WORKING document!
override COMPOSER_TARGETS		:= $(patsubst .$(TARGETS),$(COMPOSER_TARGETS_AUTO),$(COMPOSER_TARGETS))

ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(COMPOSER_TARGETS_AUTO)
endif
ifeq ($(COMPOSER_SUBDIRS),)
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

################################################################################
# }}}1
################################################################################
# {{{1 Documentation -----------------------------------------------------------
################################################################################

########################################
## {{{2 $(HELPOUT) ---------------------

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
	@$(PRINT) "*$(_H)$(COMPOSER_TAGLINE)$(_D)*"

########################################

.PHONY: $(HELPOUT)
ifeq ($(MAKECMDGOALS),)
.NOTPARALLEL:
endif
ifneq ($(filter $(HELPOUT),$(MAKECMDGOALS)),)
.NOTPARALLEL:
endif
#>$(HELPOUT): \
#>	$(HELPOUT)-TITLE_Usage \
#>	$(HELPOUT)-USAGE \
#>	$(HELPOUT)-VARIABLES_FORMAT_1 \
#>	$(HELPOUT)-TARGETS_PRIMARY_1 \
#>	$(HELPOUT)-EXAMPLES_1 \
#>	$(HELPOUT)-FOOTER
$(HELPOUT): $(HELPOUT)-TITLE_Help
$(HELPOUT): $(HELPOUT)-USAGE
$(HELPOUT): $(HELPOUT)-VARIABLES_TITLE_1
$(HELPOUT): $(HELPOUT)-VARIABLES_FORMAT_2
$(HELPOUT): $(HELPOUT)-VARIABLES_CONTROL_2
$(HELPOUT): $(HELPOUT)-TARGETS_TITLE_1
$(HELPOUT): $(HELPOUT)-TARGETS_PRIMARY_2
$(HELPOUT): $(HELPOUT)-TARGETS_ADDITIONAL_2
#>$(HELPOUT): $(HELPOUT)-TARGETS_INTERNAL_2
$(HELPOUT): $(HELPOUT)-EXAMPLES_1
$(HELPOUT): $(HELPOUT)-FOOTER
$(HELPOUT):
	@$(ECHO) ""

########################################
### {{{3 $(HELPOUT)-VARIABLES ----------

.PHONY: $(HELPOUT)-VARIABLES_TITLE_%
$(HELPOUT)-VARIABLES_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Variables,1)

#> update: TYPE_TARGETS
#> update: READ_ALIASES
.PHONY: $(HELPOUT)-VARIABLES_FORMAT_%
$(HELPOUT)-VARIABLES_FORMAT_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Formatting Variables); fi
	@$(TABLE_M3) "$(_H)Variable"			"$(_H)Purpose"				"$(_H)Value"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_C)[c_site]$(_D)    ~ $(_E)S"	"Build as Bootstrap page"		"$(_M)$(c_site)"
	@$(TABLE_M3) "$(_C)[c_type]$(_D)    ~ $(_E)T"	"Desired output format"			"$(_M)$(c_type)"
	@$(TABLE_M3) "$(_C)[c_base]$(_D)    ~ $(_E)B"	"Base of output file"			"$(_M)$(c_base)"
	@$(TABLE_M3) "$(_C)[c_list]$(_D)    ~ $(_E)L"	"List of input files(s)"		"$(_M)$(notdir $(c_list))$(_D)"
	@$(TABLE_M3) "$(_C)[c_lang]$(_D)    ~ $(_E)g"	"Language for document headers"		"$(_M)$(c_lang)"
	@$(TABLE_M3) "$(_C)[c_css]$(_D)     ~ $(_E)s"	"Location of CSS file"			"$(_M)$(notdir $(call c_css_select))$(_D)"
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
	@$(PRINT) "  * *Special $(_C)[c_css]$(_D) values:*"
	@$(COLUMN_2) "    * *\`$(_M)$(COMPOSER_CSS)$(_D)\`"		"= Filesystem override of variable value*"
	@$(COLUMN_2) "    * *\`$(_N)$(CSS_ALT)$(_D)\`"		"= Use the alternate default stylesheet*"
	@$(COLUMN_2) "    * *\`$(_N)$(SPECIAL_VAL)$(_D)\`"			"= Revert to the $(_C)[Pandoc]$(_D) default*"
	@$(COLUMN_2) "  * *Special $(_C)[c_toc]$(_D) value: \`$(_N)$(SPECIAL_VAL)$(_D)\`"	"= List all headers, and number sections*"
	@$(COLUMN_2) "  * *Special $(_C)[c_level]$(_D) value: \`$(_N)$(SPECIAL_VAL)$(_D)\`"	"= Varies by $(_C)[c_type]$(_D) $(_E)(see [$(HELPOUT)-$(DOITALL)])$(_D)*"
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
	@$(TABLE_M3) "$(_C)[COMPOSER_KEEPING]"	"Log entries / cache files"			"$(if $(COMPOSER_KEEPING),$(_M)$(COMPOSER_KEEPING)$(_D) )\`$(_N)(keeping)$(_D)\`"
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
	@$(PRINT) "  * *\`$(_N)(keeping)$(_D)\`  = empty is no limit / number to keep / \`$(_N)0$(_D)\` is last run only*"
	@$(PRINT) "  * *\`$(_N)(boolean)$(_D)\`  = empty is disabled / any value enables*"

########################################
### {{{3 $(HELPOUT)-TARGETS ------------

.PHONY: $(HELPOUT)-TARGETS_TITLE_%
$(HELPOUT)-TARGETS_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Targets,1)

.PHONY: $(HELPOUT)-TARGETS_PRIMARY_%
$(HELPOUT)-TARGETS_PRIMARY_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Primary Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)]"			"Basic $(HELPOUT) overview $(_E)(default)$(_D)"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)-$(DOITALL)]"		"Console version of \`$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)\` $(_E)(mostly identical)$(_D)"
	@$(TABLE_M2) "$(_C)[$(EXAMPLE)]"			"Print settings template: \`$(_M)$(COMPOSER_SETTINGS)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_PANDOC)]"		"Document creation engine $(_E)(see [Formatting Variables])$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)]"			"$(_C)[Bootstrap Websites]$(_D) from all $(_C)[Markdown]$(_D) files"
#WORK
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(DOITALL)]"		"Recursively create $(_C)[Bootstrap Websites]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(DOFORCE)]"		"Recursively create $(_C)[Bootstrap Websites]$(_D)"
# $(PUBLISH)-$(COMPOSER_SETTINGS)
# $(PUBLISH)-$(COMPOSER_YML)
# $(PUBLISH)-$(EXAMPLE)
# $(PUBLISH)-$(EXAMPLE)-$(DOITALL)
# $(PUBLISH)-$(EXAMPLE)-$(EXAMPLE)
#WORK
	@$(TABLE_M2) "$(_C)[$(INSTALL)]"			"Current directory initialization: \`$(_M)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(INSTALL)-$(DOITALL)]"		"Do $(_C)[$(INSTALL)]$(_D) recursively $(_E)(no overwrite)$(_D)"
	@$(TABLE_M2) "$(_C)[$(INSTALL)-$(DOFORCE)]"		"Recursively force overwrite of \`$(_M)$(MAKEFILE)$(_D)\` files"
	@$(TABLE_M2) "$(_C)[$(CLEANER)]"			"Remove output files: $(_C)[COMPOSER_TARGETS]$(_D) $(_E)$(DIVIDE)$(_D) $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(CLEANER)-$(DOITALL)]"		"Do $(_C)[$(CLEANER)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_N)[*$(_C)-$(CLEANER)]"			"Any targets named this way will also be run by $(_C)[$(CLEANER)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DOITALL)]"			"Create output files: $(_C)[COMPOSER_TARGETS]$(_D) $(_E)$(DIVIDE)$(_D) $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DOITALL)-$(DOITALL)]"		"Do $(_C)[$(DOITALL)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_N)[*$(_C)-$(DOITALL)]"			"Any targets named this way will also be run by $(_C)[$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PRINTER)]"			"Show updated files: \`$(_N)*$(_D)\`$(_C)[COMPOSER_EXT]$(_D) $(_E)$(MARKER)$(_D) $(_C)[COMPOSER_LOG]$(_D)"

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
### {{{3 $(HELPOUT)-EXAMPLES -----------

.PHONY: $(HELPOUT)-EXAMPLES_%
$(HELPOUT)-EXAMPLES_%:
	@if [ "$(*)" -gt "0" ]; then $(call TITLE_LN,$(*),Command Examples); fi
	@$(PRINT) "Fetch the necessary binary components"
	@$(PRINT) "$(_E)(see [Requirements])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(UPGRADE)-$(DOITALL)$(_D)"
	@$(ENDOLINE)
	@$(PRINT) "Create documents from source $(_C)[Markdown]$(_D) files"
	@$(PRINT) "$(_E)(see [Formatting Variables])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README).$(EXTN_DEFAULT)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D) $(_E)c_list=\"$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)\"$(_D)"
	@$(ENDOLINE)
	@$(PRINT) "Save a persistent configuration"
	@$(PRINT) "$(_E)(see [Recommended Workflow] and [Configuration Settings])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)"
	@$(PRINT) "$(CODEBLOCK)$(_C)"'$$EDITOR'"$(_D) $(_M)$(COMPOSER_SETTINGS)"
	@$(PRINT) "$(CODEBLOCK)$(CODEBLOCK)$(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D): $(_E)$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)"
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
## {{{2 $(HELPOUT)-$(DOITALL) ----------

.PHONY: $(HELPOUT)-$(HEADERS)-%
$(HELPOUT)-$(HEADERS)-%:
	@if [ -z "$(c_site)" ]; then $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TITLE); fi
	@$(call TITLE_LN,-1,$(COMPOSER_TECHNAME))
		@$(MAKE) $(SILENT) $(HELPOUT)-$(DOITALL)-HEADER
		@if [ -n "$(c_site)" ]; then $(ENDOLINE); $(PRINT) "$(_S)$(HTML_BREAK)$(_D)"; fi
		@if [ "$(*)" = "$(DOFORCE)" ] || [ "$(*)" = "$(TYPE_PRES)" ]; then \
			$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS); \
		fi
		@if [ "$(*)" = "$(DOFORCE)" ]; then \
			$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS_EXT); \
		fi
	@$(call TITLE_LN,2,Overview)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-OVERVIEW)
		@$(call TITLE_END)
	@$(call TITLE_LN,2,Quick Start)			; $(PRINT) "Use \`$(_C)$(DOMAKE) $(HELPOUT)$(_D)\` to get started:"
		@$(ENDOLINE); $(MAKE) $(SILENT) $(HELPOUT)-USAGE
		@$(ENDOLINE); $(MAKE) $(SILENT) $(HELPOUT)-EXAMPLES_0
		@$(call TITLE_END)
	@$(call TITLE_LN,2,Principles)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-GOALS)
		@$(call TITLE_END)
	@$(call TITLE_LN,2,Requirements)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE)
		@$(ENDOLINE); $(MAKE) $(CHECKIT)-$(DOFORCE) | $(SED) "/^[^#]*[#]/d"
		@$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE_POST)
		@$(call TITLE_END)
	@$(call TITLE_END)

.PHONY: $(HELPOUT)-%
$(HELPOUT)-%:
	@$(MAKE) $(SILENT) $(HELPOUT)-$(HEADERS)-$(*)
	@$(call TITLE_LN,1,$(COMPOSER_BASENAME) Operation,1)
	@$(call TITLE_LN,2,Recommended Workflow)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-WORKFLOW)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Document Formatting)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-FORMAT)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Configuration Settings)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-SETTINGS)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Precedence Rules)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-ORDERS)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Specifying Dependencies)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-DEPENDS)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Custom Targets)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-CUSTOM)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Repository Versions)			; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VERSIONS)	; $(call TITLE_END)
	@$(call TITLE_END)
	@$(MAKE) $(SILENT) $(HELPOUT)-VARIABLES_TITLE_1
	@$(MAKE) $(SILENT) $(HELPOUT)-VARIABLES_FORMAT_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT)	; $(call TITLE_END)
	@$(MAKE) $(SILENT) $(HELPOUT)-VARIABLES_CONTROL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL)	; $(call TITLE_END)
	@$(call TITLE_END)
	@$(MAKE) $(SILENT) $(HELPOUT)-TARGETS_TITLE_1
	@$(MAKE) $(SILENT) $(HELPOUT)-TARGETS_PRIMARY_2		; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY)		; $(call TITLE_END)
	@$(MAKE) $(SILENT) $(HELPOUT)-TARGETS_ADDITIONAL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL)	; $(call TITLE_END)
	@if [ "$(*)" = "$(DOFORCE)" ]; then \
		$(MAKE) $(SILENT) $(HELPOUT)-TARGETS_INTERNAL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL)	; $(call TITLE_END); \
		$(call TITLE_END); \
		$(MAKE) $(SILENT) $(HELPOUT)-$(DOFORCE)-$(PRINTER); \
	else \
		$(call TITLE_END); \
	fi
	@if [ -z "$(c_site)" ]; then \
		$(MAKE) $(SILENT) $(HELPOUT)-FOOTER; \
	fi

########################################
### {{{3 $(HELPOUT)-$(PUBLISH) ---------

.PHONY: $(HELPOUT)-$(PUBLISH)
$(HELPOUT)-$(PUBLISH):
	@$(MAKE) $(SILENT) c_site="1" $(HELPOUT)-$(DOFORCE)

########################################
### {{{3 $(HELPOUT)-$(TYPE_PRES) -------

.PHONY: $(HELPOUT)-$(TYPE_PRES)
$(HELPOUT)-$(TYPE_PRES):
	@$(MAKE) $(SILENT) $(HELPOUT)-$(HEADERS)-$(TYPE_PRES)
	@$(ENDOLINE)
	@$(LINERULE)
	@$(MAKE) $(SILENT) $(HELPOUT)

########################################
### {{{3 $(HELPOUT)-$(DOFORCE) ---------

.PHONY: $(HELPOUT)-$(DOFORCE)-$(PRINTER)
$(HELPOUT)-$(DOFORCE)-$(PRINTER):
	@$(call TITLE_LN,1,Reference)
	@$(MAKE) $(SILENT) $(HELPOUT)-$(DOFORCE)-$(TARGETS)
	@$(call TITLE_LN,2,Configuration,1)
#WORKING reference this somewhere...
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Pandoc Extensions)"
	@$(ENDOLINE); $(PRINT) "$(_C)[$(COMPOSER_BASENAME)]$(_D) uses the \`$(_C)$(INPUT)$(_D)\` input format, with these extensions:"
	@$(ENDOLINE); $(foreach FILE,$(sort $(subst +,,$(PANDOC_EXTENSIONS))),\
		$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
	)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Templates)"
	@$(ENDOLINE); $(ECHO) "The $(_C)[$(INSTALL)]$(_D) target \`$(_M)$(MAKEFILE)$(_D)\` template $(_E)(for reference only)$(_D):"
	@$(if $(COMPOSER_DOCOLOR),$(ENDOLINE); $(ENDOLINE))
	@$(MAKE) .$(EXAMPLE)-$(INSTALL) \
		$(if $(COMPOSER_DOCOLOR),,| $(SED) \
			-e "/^[#]{$(DEPTH_MAX)}.+[[:space:]]/d" \
			-e "s|[\t]+| |g" \
			-e "s|^|$(CODEBLOCK)|g" \
			-e "s|^[[:space:]]+$$||g" \
			-e "s|[[:space:]]+$$||g" \
		)
	@$(ENDOLINE); $(ECHO) "Use the $(_C)[$(EXAMPLE)]$(_D) target to create \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` files:"
	@$(if $(COMPOSER_DOCOLOR),$(ENDOLINE); $(ENDOLINE))
	@$(MAKE) .$(EXAMPLE) \
		$(if $(COMPOSER_DOCOLOR),,| $(SED) \
			-e "/^[#]{$(DEPTH_MAX)}.+[[:space:]]/d" \
			-e "s|[\t]+| |g" \
			-e "s|^|$(CODEBLOCK)|g" \
			-e "s|^[[:space:]]+$$||g" \
			-e "s|[[:space:]]+$$||g" \
		)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Defaults)"
	@$(ENDOLINE); $(PRINT) "The default \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` in the $(_C)[$(COMPOSER_BASENAME)]$(_D) directory:"
	@$(ENDOLINE); $(call DO_HEREDOC,HEREDOC_COMPOSER_MK) \
		| $(SED) \
			-e "s|[\t]+| |g" \
			-e "s|^|$(CODEBLOCK)|g" \
			-e "s|^[[:space:]]+$$||g" \
			-e "s|[[:space:]]+$$||g"
	@$(ENDOLINE); $(PRINT) "The default \`$(_M)$(COMPOSER_YML)$(_D)\` in the $(_C)[$(COMPOSER_BASENAME)]$(_D) directory:"
	@$(ENDOLINE); $(call DO_HEREDOC,HEREDOC_COMPOSER_YML) \
		| $(SED) \
			-e "s|[\t]+| |g" \
			-e "s|^|$(CODEBLOCK)|g" \
			-e "s|^[[:space:]]+$$||g" \
			-e "s|[[:space:]]+$$||g"
	@$(call TITLE_END)
	@$(call TITLE_LN,2,Reserved,1)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Target Names)"
	@$(ENDOLINE); $(PRINT) "Do not create targets which match these, or use them as prefixes:"
#WORKING maybe just do: $(MAKE) $(SILENT) $(LISTING) | $(SED) -e "/^[#]/d" -e "s|^([^:]+).*$|\1|g" | $(SORT)
	@$(ENDOLINE); $(eval LIST := $(shell \
			$(ECHO) "$(COMPOSER_RESERVED)" \
			| $(TR) ' ' '\n' \
			| $(SORT) \
		))$(foreach FILE,$(LIST),\
			$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Variable Names)"
	@$(ENDOLINE); $(PRINT) "Do not create variables which match these, and avoid similar names:"
	@$(ENDOLINE); $(eval LIST := $(shell \
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
	@$(call TITLE_END)
	@$(call TITLE_END)

.PHONY: $(HELPOUT)-$(DOFORCE)-$(TARGETS)
$(HELPOUT)-$(DOFORCE)-$(TARGETS):
	@$(eval LIST := $(shell $(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-TITLES) \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(FILE)))]: #$(shell \
				$(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT,$(FILE)) \
			)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval LIST := $(shell $(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-SECTIONS) \
			| $(SED) "/[/]/d" \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(FILE)))]: #$(shell \
				$(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT,$(FILE)) \
			)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval LIST := $(shell $(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-SECTIONS) \
			| $(SED) -n "/[/]/p" \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(FILE)))]: #$(shell \
				$(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT,$(FILE)) \
			)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval LIST := $(shell $(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-SECTIONS) \
			| $(SED) -n "/[/]/p" \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(foreach HEAD,$(subst /, ,$(FILE)),\
				$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(HEAD)))]: #$(shell \
					$(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT,$(FILE)) \
				)"; \
				$(call NEWLINE) \
			) \
		)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(ENDOLINE)
	@$(eval LIST := $(shell $(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-TITLES) \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_N)[$(strip $(subst $(TOKEN), ,$(FILE)))]"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval LIST := $(shell $(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-SECTIONS) \
			| $(TR) '/' '|' \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_N)[$(strip $(subst $(TOKEN), ,$(FILE)))]"; \
			$(call NEWLINE) \
		)
endif

override define $(HELPOUT)-$(DOFORCE)-$(TARGETS)-TITLES =
	$(SED) -n -e "s|^.+TITLE_LN[,][^,]+[,]([^,]+).*.$$|\1|gp" $(COMPOSER) \
	| $(SED) "/TITLE[:][[:space:]]+[$$]/d" \
	| $(SED) \
		-e "s|.[[:space:]]+;.+$$||g" \
		-e "s|.;[[:space:]]+f$$||g" \
		-e "/MARKER/d" \
		-e "/DIVIDE/d" \
		-e "/TIMESTAMP/d" \
		-e "s|\\\\||g" \
		-e "s|$$|\||g"
endef

override define $(HELPOUT)-$(DOFORCE)-$(TARGETS)-SECTIONS =
	$(SED) -n "s|^.+[-]SECTION[,](.+)[)][\"]?$$|\1|gp" $(COMPOSER) \
	| $(SED) \
		-e "s|^[[:space:]]+||g" \
		-e "s|[[:space:]]+$$||g" \
		-e "s|\\\\||g" \
		-e "s|$$|\||g"
endef

#> update: $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT
override define $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT =
	$(ECHO) "$(strip $(subst $(TOKEN), ,$(1)))" \
	| $(TR) 'A-Z' 'a-z' \
	| $(SED) \
		-e "s|-|DASH|g" \
		-e "s|_|UNDER|g" \
	| $(SED) \
		-e "s|[[:punct:]]||g" \
		-e "s|[[:space:]]|-|g" \
	| $(SED) \
		-e "s|DASH|-|g" \
		-e "s|UNDER|_|g"
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TITLE ---

override define $(HELPOUT)-$(DOITALL)-TITLE =
$(_M)---$(_D)
$(_M)title: "$(COMPOSER_HEADLINE)"$(_D)
$(_M)author: $(COMPOSER_COMPOSER)$(_D)
$(_M)date: $(COMPOSER_VERSION) ($(DATEMARK))$(_D)
$(_M)---$(_D)
endef

.PHONY: $(HELPOUT)-$(DOITALL)-HEADER
$(HELPOUT)-$(DOITALL)-HEADER:
	@$(TABLE_M2) "$(_H)![$(COMPOSER_BASENAME) Icon]"	"$(_H)\"Creating Made Simple.\""
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_FULLNAME)]"		"$(_C)[License: GPL]"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_COMPOSER)]"		"$(_C)[composer@garybgenett.net]"

#WORKING these links need to be variables
override define $(HELPOUT)-$(DOITALL)-LINKS =
$(_E)[$(COMPOSER_BASENAME)]: $(COMPOSER_HOMEPAGE)$(_D)
$(_E)[License: GPL]: https://github.com/garybgenett/composer/blob/master/LICENSE$(COMPOSER_EXT_DEFAULT)$(_D)
$(_E)[$(COMPOSER_COMPOSER)]: http://www.garybgenett.net/projects/composer$(_D)
$(_E)[composer@garybgenett.net]: mailto:composer@garybgenett.net?subject=$(subst $(NULL) ,%20,$(COMPOSER_TECHNAME))%20Submission&body=Thank%20you%20for%20sending%20a%20message%21$(_D)

$(_S)[$(COMPOSER_FULLNAME)]: https://github.com/garybgenett/composer/tree/$(COMPOSER_VERSION)$(_D)
$(_S)[$(COMPOSER_BASENAME) Icon]: $(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART))/icon-v1.0.png$(_D)
$(_S)[$(COMPOSER_BASENAME) Screenshot]: $(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART))/screenshot-v3.0.png$(_D)
endef

override define $(HELPOUT)-$(DOITALL)-LINKS_EXT =
$(_E)[GNU Make]: http://www.gnu.org/software/make$(_D)
$(_S)#>[Markdown]: http://daringfireball.net/projects/markdown$(_D)
$(_S)#>[Markdown]: https://commonmark.org$(_D)
$(_E)[Markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown$(_D)
$(_E)[GitHub]: https://github.com$(_D)

$(_E)[Pandoc]: http://www.johnmacfarlane.net/pandoc$(_D)
$(_E)[YQ]: https://mikefarah.gitbook.io/yq$(_D)
$(_E)[CommonMark]: https://commonmark.org$(_D)
$(_E)[Bootstrap]: https://getbootstrap.com$(_D)
$(_E)[Bootswatch]: https://bootswatch.com$(_D)
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
### {{{3 $(HELPOUT)-$(DOITALL)-OVERVIEW

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
### {{{3 $(HELPOUT)-$(DOITALL)-GOALS ---

#WORK the file beats the directory, which beats the tree
#WORK the file beats the command line, which beats the environment

override define $(HELPOUT)-$(DOITALL)-GOALS =
The guiding principles of $(_C)[$(COMPOSER_BASENAME)]$(_D):

  * All source files in readable plain text
  * Professional output, suitable for publication
  * Minimal dependencies, and entirely command-line driven
  * Separate content and formatting; writing and publishing are independent
  * Inheritance and dependencies; global, tree, directory and file overrides
  * Fast; both to initiate commands and for processing to complete

Direct support for key document types $(_E)(see [Document Formatting])$(_D):

  * $(_C)[Bootstrap Websites]$(_D)
  * $(_C)[HTML]$(_D)
  * $(_C)[PDF]$(_D)
  * $(_C)[EPUB]$(_D)
  * $(_C)[Reveal.js Presentations]$(_D)
  * $(_C)[Microsoft Word & PowerPoint]$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-REQUIRE -

#WORK update this... the "bin" directory fixed this...

override define $(HELPOUT)-$(DOITALL)-REQUIRE =
$(_C)[$(COMPOSER_BASENAME)]$(_D) has almost no external dependencies.  All needed components are
integrated, including $(_C)[Pandoc]$(_D).  The repository needs to be initialized with
$(_C)[$(UPGRADE)-$(DOITALL)]$(_D) to fetch the $(_C)[Pandoc]$(_D) and $(_C)[YQ]$(_D) binaries $(_E)(see [Repository
Versions])$(_D).

$(_C)[$(COMPOSER_BASENAME)]$(_D) does require a minimal command-line environment based on $(_N)[GNU]$(_D) tools,
particularly $(_C)[GNU Make]$(_D), which is standard for all $(_N)[GNU/Linux]$(_D) systems.  The
$(_N)[Windows Subsystem for Linux]$(_D) for Windows and $(_N)[MacPorts]$(_D) for macOS both provide
suitable environments.

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
instructions in the `$(_M)README$(COMPOSER_EXT_DEFAULT)$(_D)`.

The versions of the integrated repositories can be changed, if desired $(_E)(see
[Repository Versions])$(_D).
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-WORKFLOW

#WORK
# note that main directory is usable right away, without $(INSTALL)
#	see config files for examples (unchanged composer.yml will impact websites created from this instance)
# non-single-user use is not recommended

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
### {{{3 $(HELPOUT)-$(DOITALL)-FORMAT --

#WORKING:NOW:NOW
#	also update revealjs documentation, based on css behavior change
#		need to update tests...?  yes!
#	note that they are intentionally reversed
#		bootstrap is just supporting where the markdown-viewer themes fall through
#		revealjs is usually using a theme, which we are refining
#	these can now be removed to be disabled
#	favicon.ico = idendical to $(_C)[Reveal.js Presentations]$(_D)
#		works on all html, including revealjs
#	order of nav presentation in plain-text: top, left, middle, right, bottom
#	the *-info-* fields will accept any markdown, html, or bootstrap
#		it is a simple span within the navbar, so flex and others will work
#		https://getbootstrap.com/docs/5.2/components/navbar
#		https://getbootstrap.com/docs/5.2/utilities/flex
#	any simple css should do...
#		https://getbootstrap.com/docs/5.2/utilities/colors
#	$(PUBLISH_BUILD_CMD_BEG) pane-begin 1 $(SPECIAL_VAL) $(COMPOSER_TECHNAME) $(PUBLISH_BUILD_CMD_END)<!-- -->
#		(the ' as a blank placeholder)
#	$(DO_PAGE)-% must end in $(EXTN_HTML)...
#	$(PUBLISH) rebuilds indexes, force recursively
#	examples of description/etc. metadata in $(COMPOSER_YML)
#	how to do an include of the digest file
#		it can only be used in the directory parallel to the library...
#		files must have a title or pagetitle to be included in the digest
#	$(PUBLISH)-$(CLEANER)[reset] / $(PUBLISH)-$(DO_PAGE) / $(PUBLISH)-index / $(PUBLISH)-library ...?
#		$(DOFORCE) will convert non-$(DO_PAGE) $(TYPE_HTML) to pages...?
#	$(PUBLISH)-* targets can reach up the tree, back to the closest COMPOSER_YML_LIST directory...
#	note: removed yaml fields will not update in the index = make site
#	note: pretty much everything is linked to COMPOSER_YML_LIST, so when those get updated...
#	COMPOSER_EXT="" and c_site="1" do not mix very well!
#		COMPOSER_EXT needs to be gloabal when library is enabled
#	the library indexes as a merge for new files
#		removed files and fields will remain
#		rm _library/site-library.yml or do "make site" to rebuild
#	c_site = title-block = title-prefix/pagetitle behavior
#	any date format that yq can understand [link] can be used, but be consisitent...
#	$(PUBLISH)-spacer[.spacer] / .box-begin / .box-end
#	need to do "null" to override on sub-composer.yml files
#	all it takes is c_site to make a site page... site/page are just wrappers
#		this is essentially what site-force does, is c_site=1 all, recursively
#	booleans are true with 1, disabled with any other value (0 recommended), and otherwise default
#	library folder can not be "null", and will be shortened to basename
#		note about how yml processing for this one is special
#		auto_update only works in the folder that owns the library
#	COMPOSER_INCLUDE + c_site = for the win?
#	COMPOSER_DEPENDS + library + auto_update = may need two-pass runs to make it work...
#		changes to include files will always get missed...
#		actually, fixed!... now it is just includes and markdown files that are built as targets
#		note that only the lowest library will be updated...
#	note: a first troubleshooting step is to do MAKEJOBS="1"
#		this came up with site-library when two different sub-directories triggered a rebuild simultaneously
#WORK
#	add a list of the formats here...
#	make sure all the level2 sections have links to the sub-sections...

override define $(HELPOUT)-$(DOITALL)-FORMAT =
As outlined in $(_C)[Overview]$(_D) and $(_C)[Principles]$(_D), a primary goal of $(_C)[$(COMPOSER_BASENAME)]$(_D) is to
produce beautiful and professional output.  $(_C)[Pandoc]$(_D) does reasonably well at
this, and yet its primary focus is document conversion, not document formatting.
$(_C)[$(COMPOSER_BASENAME)]$(_D) fills this gap by specifically tuning a select list of the most
commonly used document formats.

Further options for each document type are in $(_C)[Formatting Variables]$(_D).  All
improvements not exposed as variables will apply to all documents created with a
given instance of $(_C)[$(COMPOSER_BASENAME)]$(_D).

#WORK remove heredoc...

Note that all the files referenced below are embedded in the '$(_E)Embedded Files$(_D)'
and '$(_E)Heredoc$(_D)' sections of the `$(_M)$(MAKEFILE)$(_D)`.  They are exported by the
$(_C)[$(DISTRIB)]$(_D) target, and will be overwritten whenever it is run.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Bootstrap Websites)

$(_C)[Bootstrap]$(_D) is a leading web development framework, capable of building static
webpages that behave dynamically.  Static sites are very easy and inexpensive to
host, and are extremely responsive compared to truly dynamic webpages.

$(_C)[$(COMPOSER_BASENAME)]$(_D) uses this framework to transform an archive of simple text files into
a modern website, with the appearance and behavior of dynamically indexed pages.

#WORKING

$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(BOOTSTRAP_CSS_JS))$(_D)
$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(BOOTSTRAP_CSS_CSS))$(_D)
$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(BOOTSTRAP_CSS))$(_D)
$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(COMPOSER_ICON))$(_D)
$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(COMPOSER_LOGO))$(_D)

$(_C)[Bootswatch]$(_D)

#WORK

$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(BOOTSWATCH_DIR))/docs/index.html$(_D)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,HTML)

In addition to being a helpful real-time rendering tool, $(_C)[Markdown Viewer]$(_D)
includes several $(_M)CSS$(_D) stylesheets that are much more visually appealing than the
$(_C)[Pandoc]$(_D) default, and which behave like normal webpages, so $(_C)[$(COMPOSER_BASENAME)]$(_D) uses them
for all $(_C)[HTML]$(_D)-based document types, including $(_C)[EPUB]$(_D).

Information on installing $(_C)[Markdown Viewer]$(_D) for use as a $(_C)[Markdown]$(_D) rendering
tool is in $(_C)[Requirements]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,PDF)

The default formatting for $(_C)[PDF]$(_D) is geared towards academic papers and the
typesetting of printed books, instead of documents that are intended to be
purely digital.

Internally, $(_C)[Pandoc]$(_D) first converts to $(_M)LaTeX$(_D), and then uses $(_C)[TeX Live]$(_D) to
convert into the final $(_C)[PDF]$(_D).  $(_C)[$(COMPOSER_BASENAME)]$(_D) inserts customized $(_M)LaTeX$(_D) to modify the
final output:

$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(TEX_PDF_TEMPLATE))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,EPUB)

The $(_C)[EPUB]$(_D) format is essentially packaged $(_C)[HTML]$(_D), so $(_C)[$(COMPOSER_BASENAME)]$(_D) uses the same
$(_C)[Markdown Viewer]$(_D) $(_M)CSS$(_D) stylesheets for it.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Reveal.js Presentations)

The $(_M)CSS$(_D) for $(_C)[Reveal.js]$(_D) presentations has been modified to create a more
traditional and readable end result.  The customized version is at:

$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(REVEALJS_CSS))$(_D)

It links in a default theme from the `$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(REVEALJS_DIR))/dist/theme$(_D)` directory.  Edit
the location in the file, or use $(_C)[c_css]$(_D) to select a different theme.

It is set up so that a logo can be placed in the upper right hand corner on each
slide, for presentations that need to be branded.  Simply copy an image file to
the logo location:

$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(COMPOSER_LOGO))$(_D)

To have different logos for different directories $(_E)(using [Recommended Workflow],
[Configuration Settings] and [Precedence Rules])$(_D):

$(CODEBLOCK)$(_C)cd$(_D) $(_M).../presentations$(_D)
$(CODEBLOCK)$(_C)cp$(_D) $(_N).../$(notdir $(COMPOSER_LOGO))$(_D) $(_M)./$(_D)
$(CODEBLOCK)$(_C)ln$(_D) $(_N)-rs .../$(patsubst $(COMPOSER_DIR)%,.$(COMPOSER_BASENAME)%,$(REVEALJS_CSS))$(_D) $(_M)./$(COMPOSER_CSS)$(_D)
$(CODEBLOCK)$(_C)echo$(_D) $(_N)'$(_E)override c_type := $(TYPE_PRES)'$(_D) >>$(_M)./$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,Microsoft Word & PowerPoint)

The internal $(_C)[Pandoc]$(_D) templates for these are exported by $(_C)[$(COMPOSER_BASENAME)]$(_D), so they
are available for customization:

$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(COMPOSER_ART))/reference.$(EXTN_DOCX)$(_D)
$(CODEBLOCK)$(patsubst $(COMPOSER_DIR)/%,.../$(_M)%,$(COMPOSER_ART))/reference.$(EXTN_PPTX)$(_D)

They are not currently modified by $(_C)[$(COMPOSER_BASENAME)]$(_D).
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-SETTINGS

override define $(HELPOUT)-$(DOITALL)-SETTINGS =
$(_C)[$(COMPOSER_BASENAME)]$(_D) uses `$(_M)$(COMPOSER_SETTINGS)$(_D)` files for persistent settings and definition of
$(_C)[Custom Targets]$(_D).  By default, they only apply to the directory they are in $(_E)(see
[COMPOSER_INCLUDE] in [Control Variables])$(_D).  A `$(_M)$(COMPOSER_SETTINGS)$(_D)` in the main
$(_C)[$(COMPOSER_BASENAME)]$(_D) directory will be global to all directories.  The targets and
settings in the most local file override all others $(_E)(see [Precedence Rules])$(_D).

The easiest way to create a new `$(_M)$(COMPOSER_SETTINGS)$(_D)` is with the $(_C)[$(EXAMPLE)]$(_D) target
$(_E)([Quick Start] example)$(_D):

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(_C)$$EDITOR$(_D) $(_M)$(COMPOSER_SETTINGS)$(_D)

All variable definitions must be in the `$(_N)override [variable] := [value]$(_D)` format
from the $(_C)[$(EXAMPLE)]$(_D) target.  Doing otherwise will result in unexpected behavior,
and is not supported.  The regular expression that is used to detect them:

$(CODEBLOCK)$(_N)$(COMPOSER_REGEX_OVERRIDE)$(_D)

Variables can also be specified per-target, using $(_C)[GNU Make]$(_D) syntax:

$(CODEBLOCK)$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_toc := $(SPECIAL_VAL)$(_D)
$(CODEBLOCK)$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_toc :=$(_D)

In this case, there are multiple definitions that could apply to
`$(_M)$(OUT_README).$(EXTN_PRES)$(_D)`, due to the `$(_N)%$(_D)` wildcard.  Since the most specific target
match is used, the final value for $(_C)[c_toc]$(_D) would be empty.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-ORDERS --

#WORKING
#	note about global/local variables, and config/$(MARKER)
#		add a link to this section at the top of both variable sections
#		denote each variable

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
### {{{3 $(HELPOUT)-$(DOITALL)-DEPENDS -

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
### {{{3 $(HELPOUT)-$(DOITALL)-CUSTOM --

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
### {{{3 $(HELPOUT)-$(DOITALL)-VERSIONS

#> update: PHONY.*(UPGRADE)

override define $(HELPOUT)-$(DOITALL)-VERSIONS =
There are a few internal variables used by $(_C)[$(UPGRADE)]$(_D) to select the repository
and binary versions of integrated components $(_E)(see [Requirements])$(_D).  These are
exposed for configuration, but only within `$(_M)$(COMPOSER_SETTINGS)$(_D)`:

  * `$(_C)PANDOC_VER$(_D)` $(_E)(must be a binary version number)$(_D)
  * `$(_C)PANDOC_CMT$(_D)` $(_E)(defaults to `PANDOC_VER`)$(_D)
  * `$(_C)YQ_VER$(_D)` $(_E)(must be a binary version number)$(_D)
  * `$(_C)YQ_CMT$(_D)` $(_E)(defaults to `YQ_VER`)$(_D)
  * `$(_C)COMMONMARK_CMT$(_D)`
  * `$(_C)BOOTSTRAP_CMT$(_D)`
  * `$(_C)BOOTSWATCH_CMT$(_D)`
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
### {{{3 $(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT

override define $(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT =
$(call $(HELPOUT)-$(DOITALL)-SECTION,c_site)

#WORK

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
### {{{3 $(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL

override define $(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL =
$(call $(HELPOUT)-$(DOITALL)-SECTION,MAKEJOBS)

#WORK a small number of large directories will process faster than a large number of small ones, especially with $(PUBLISH)

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
    By default, it only reads the ones in the main $(_C)[$(COMPOSER_BASENAME)]$(_D) directory and the
    current directory, in that order.  This option enables reading all of them.
  * In the example directory tree below, normally the `$(_M)$(COMPOSER_SETTINGS)$(_D)` in
    `$(_M).$(COMPOSER_BASENAME)$(_D)` is read first, and then `$(_M)tld/sub/$(COMPOSER_SETTINGS)$(_D)`.  With this
    enabled, it will read all of them in order from top to bottom:
    `$(_M).$(COMPOSER_BASENAME)/$(COMPOSER_SETTINGS)$(_D)`, `$(_M)$(COMPOSER_SETTINGS)$(_D)`, `$(_M)tld/$(COMPOSER_SETTINGS)$(_D)`, and finally
    `$(_M)tld/sub/$(COMPOSER_SETTINGS)$(_D)`.
  * This is why it is best practice to have a `$(_M).$(COMPOSER_BASENAME)$(_D)` directory at the top
    level for each documentation archive $(_E)(see [Recommended Workflow])$(_D).  Not only
    does it allow for strict version control of $(_C)[$(COMPOSER_BASENAME)]$(_D) per-archive, it also
    provides a mechanism for setting $(_C)[$(COMPOSER_BASENAME) Variables]$(_D) globally.
  * When using this option, care should be taken with "$(_N)Local$(_D)" variables from
    $(_C)[$(EXAMPLE)]$(_D) $(_E)(see [Templates])$(_D).  They will be propagated down the tree, which
    is generally not desired except in very specific cases.  Using
    `$(_C)COMPOSER_MY_PATH$(_D)` to limit their scope is recommended $(_E)(see below)$(_D).
  * The `$(_C)COMPOSER_MY_PATH$(_D)` variable is set to the directory of each
    `$(_M)$(COMPOSER_SETTINGS)$(_D)` file as it is being included.  Comparing this with `$(_E)CURDIR$(_D)`
    provides a way to limit particular portions of the file to the local
    directory, regardless of whether $(_C)[COMPOSER_INCLUDE]$(_D) is set or not.  An
    example of this is below.
  * This setting also causes `$(_M)$(COMPOSER_YML)$(_D)` and `$(_M)$(COMPOSER_CSS)$(_D)` files to be
    processed in an identical manner $(_E)(see [Precedence Rules])$(_D).

Example directory tree $(_E)(see [Recommended Workflow])$(_D):

$(CODEBLOCK).../$(_M).$(COMPOSER_BASENAME)$(_D)/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../$(_M).$(COMPOSER_BASENAME)$(_D)/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK).../$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK).../tld/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../tld/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK).../tld/sub/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK).../tld/sub/$(_M)$(COMPOSER_SETTINGS)$(_D)

Example usage of the `$(_C)COMPOSER_MY_PATH$(_D)` variable:

$(CODEBLOCK)$(_N)ifeq$(_D) ($(_E)$$(COMPOSER_MY_PATH)$(_D),$(_N)$$(CURDIR)$(_D))
$(CODEBLOCK)$(CODEBLOCK)[...]
$(CODEBLOCK)$(_N)endif$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DEPENDS)

  * When doing $(_C)[$(DOITALL)-$(DOITALL)]$(_D), $(_C)[$(COMPOSER_BASENAME)]$(_D) will process the current directory before
    recursing into sub-directories.  This reverses that, and sub-directories
    will be processed first.
  * In the example directory tree in $(_C)[COMPOSER_INCLUDE]$(_D) above, the default would
    be: `$(_M).../$(_D)`, `$(_M).../tld$(_D)`, and then `$(_M).../tld/sub$(_D)`.  If the higher-level
    directories have dependencies on the sub-directories being run first, this
    will support that by doing them in reverse order, processing them from
    bottom to top.
  * This has no effect on $(_C)[$(INSTALL)]$(_D) or $(_C)[$(CLEANER)]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_KEEPING)

#WORK

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
    $(_C)[GitHub]$(_D).  Another commonly used extension is: `$(_N)*$(_M).markdown$(_D)`.
  * In some cases, they do not have any extension, such as `$(_M)$(OUT_README)$(_D)` and
    `$(_M)$(OUT_LICENSE)$(_D)` in source code directories.  Setting this to an empty value causes
    them to be detected and output.  It also causes all other files to be
    processed, because it becomes the wildcard `$(_N)*$(_D)`, so use with care.  It is
    likely best to use $(_C)[COMPOSER_TARGETS]$(_D) to explicitly set the targets list in
    these situations.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_TARGETS)

#WORK does not pick up .* files/directories

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

#WORK either remove $(PUBLISH) here, or add it to the ones above...

  * The list of $(_C)[COMPOSER_TARGETS]$(_D) and $(_C)[COMPOSER_SUBDIRS]$(_D) to skip with $(_C)[$(PUBLISH)]$(_D),
    $(_C)[$(INSTALL)]$(_D), $(_C)[$(CLEANER)]$(_D), and $(_C)[$(DOITALL)]$(_D).  This allows for selective auto-detection,
    when the list of items to process is larger than those to leave alone.
  * Use $(_C)[$(CONFIGS)]$(_D) to check the current value.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY

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

#WORK $(PUBLISH) rebuilds indexes, force recursively

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
    first running all $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) targets.
  * Doing $(_C)[$(CLEANER)-$(DOITALL)]$(_D) does the same thing recursively, through all the
    $(_C)[COMPOSER_SUBDIRS]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DOITALL) / $(DOITALL)-$(DOITALL) / \*-$(DOITALL))

  * Creates all $(_C)[COMPOSER_TARGETS]$(_D) output files in the current directory, after
    first running all $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) targets.
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
### {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL

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

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_E)COMPOSER_DEBUGIT="$(OUT_README).$(EXTN_DEFAULT) $(OUT_MANUAL).$(EXTN_DEFAULT)"$(_D) $(_M)$(DEBUGIT)-file$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CHECKIT) / $(CHECKIT)-$(DOITALL) / $(CONFIGS) / $(CONFIGS)-$(DOITALL) / $(TARGETS))

#WORKING break this section up

#WORK $(PUBLISH)
#WORK $(PUBLISH)-$(DOITALL)
#WORK $(PUBLISH)-$(DOFORCE)
# $(PUBLISH)-$(COMPOSER_SETTINGS)
# $(PUBLISH)-$(COMPOSER_YML)
# $(PUBLISH)-$(EXAMPLE)
# $(PUBLISH)-$(EXAMPLE)-$(DOITALL)
# $(PUBLISH)-$(EXAMPLE)-$(EXAMPLE)

  * Useful targets for validating tooling and configurations.
  * Use $(_C)[$(CHECKIT)]$(_D) to see the list of components and their versions, in relation to
    the system installed versions.  Doing $(_C)[$(CHECKIT)-$(DOITALL)]$(_D) will show the complete
    list of tools that are used by $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * The current values of all $(_C)[Composer Variables]$(_D) is output by $(_C)[$(CONFIGS)]$(_D), and
    $(_C)[$(CONFIGS)-$(DOITALL)]$(_D) will additionally output all environment variables.
  * A structured list of detected targets, $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) and $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) targets,
    $(_C)[COMPOSER_TARGETS]$(_D), and $(_C)[COMPOSER_SUBDIRS]$(_D) is printed by $(_C)[$(TARGETS)]$(_D).
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
    top-level directory.  When calling $(_C)[$(COMPOSER_BASENAME)]$(_D) directly using `$(_N)-f$(_D)`, the
    current directory is used.

Commit title format:

$(CODEBLOCK)$(_E)$(call COMPOSER_TIMESTAMP)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DISTRIB) / $(UPGRADE) / $(UPGRADE)-$(DOITALL))

#WORKING break this section up

  * Using the repository configuration $(_E)(see [Repository Versions])$(_D), these fetch
    and install all external components.
  * The $(_C)[$(UPGRADE)-$(DOITALL)]$(_D) target also fetches the $(_C)[Pandoc]$(_D) and $(_C)[YQ]$(_D) binaries,
    whereas $(_C)[$(UPGRADE)]$(_D) only fetches the repositories.
  * In addition to doing $(_C)[$(UPGRADE)-$(DOITALL)]$(_D), $(_C)[$(DISTRIB)]$(_D) performs the steps necessary
    to turn the current directory into a complete clone of $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * One of the unique features of $(_C)[$(COMPOSER_BASENAME)]$(_D) is that everything needed to
    compose itself is embedded in the `$(_M)$(MAKEFILE)$(_D)`.

Rapid cloning:

$(CODEBLOCK)$(_C)mkdir$(_D) $(_M).../clone$(_D)
$(CODEBLOCK)$(_C)cd$(_D) $(_M).../clone$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .../.$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(DISTRIB)$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL

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
## {{{2 $(CREATOR) ---------------------

#> update: TYPE_TARGETS

.PHONY: $(CREATOR)
ifneq ($(filter $(CREATOR),$(MAKECMDGOALS)),)
.NOTPARALLEL:
endif
$(CREATOR): .set_title-$(CREATOR)
$(CREATOR):
	@$(call $(HEADERS))
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_BASENAME)_Directory)
	@$(call DO_HEREDOC,HEREDOC_GITATTRIBUTES)					>$(CURDIR)/.gitattributes
	@$(call DO_HEREDOC,HEREDOC_GITIGNORE)						>$(CURDIR)/.gitignore
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK,1)					>$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_README_COMPOSER_YML) | $(SED) "s|[[:space:]]+$$||g"	>$(CURDIR)/$(COMPOSER_YML)
	@$(ECHO) "$(_E)"
	@$(RM)										$(CURDIR)/$(COMPOSER_CSS)
	@$(ECHO) "$(_D)"
endif
	@$(ECHO) "$(_S)"
	@$(MKDIR)									$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART)) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_README)$(COMPOSER_EXT_DEFAULT))
	@$(MAKE) $(SILENT) --directory $(COMPOSER_DIR) COMPOSER_DOCOLOR= \
		$(HELPOUT)-$(DOFORCE)				| $(SED) "/^[#][>]/d"	>$(CURDIR)/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT))
	@$(MAKE) $(SILENT) --directory $(COMPOSER_DIR) COMPOSER_DOCOLOR= \
		$(HELPOUT)-$(PUBLISH)				| $(SED) "/^[#][>]/d"	>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT)
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT))
	@$(MAKE) $(SILENT) --directory $(COMPOSER_DIR) COMPOSER_DOCOLOR= \
		$(HELPOUT)-$(TYPE_PRES)				| $(SED) "/^[#][>]/d"	>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)
endif
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT))
	@$(call DO_HEREDOC,HEREDOC_LICENSE)						>$(CURDIR)/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
	@$(call $(HEADERS)-file,$(CURDIR),$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART)))
	@$(ECHO) "$(DIST_ICON_v1.0)"				| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v1.0)"			| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/screenshot-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v3.0)"			| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/screenshot-v3.0.png
	@$(ECHO) "$(ICON_AUTHOR)"				| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-author.jpg
	@$(ECHO) "$(ICON_GITHUB)"				| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-github.jpg
	@$(ECHO) "$(ICON_GPL)"					| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-gpl.jpg
	@$(ECHO) "$(ICON_CC)"					| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-cc.jpg
	@$(ECHO) "$(ICON_RESERVED)"				| $(BASE64) -d		>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-reserved.jpg
	@$(call DO_HEREDOC,HEREDOC_PUBLISH_BUILD_SH)					>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PUBLISH_BUILD_SH))
	@$(ECHO) "<script>\n"								>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS_JS))
	@$(CAT) $(BOOTSTRAP_CSS_JS_SRC)							>>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS_JS))
	@$(ECHO) "</script>\n"								>>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS_JS))
	@$(CAT) $(BOOTSTRAP_CSS_CSS_SRC)						>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS_CSS))
	@$(call HEREDOC_BOOTSTRAP_CSS_HACK)						$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS_CSS))
	@$(call DO_HEREDOC,HEREDOC_BOOTSTRAP_CSS)					>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS))
	@$(SED) -i 's&HEREDOC_BOOTSTRAP_CSS_HACK&$(strip \
		$(patsubst $(word 1,$(SED))%,$(notdir $(word 1,$(SED)))%,$(call HEREDOC_BOOTSTRAP_CSS_HACK)) \
		) $(patsubst $(COMPOSER_DIR)%,...%,$(BOOTSTRAP_CSS_CSS_SRC))&g' \
											$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS))
	@$(call DO_HEREDOC,HEREDOC_TEX_PDF_TEMPLATE)					>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(TEX_PDF_TEMPLATE))
	@$(call DO_HEREDOC,HEREDOC_REVEALJS_CSS)					>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(REVEALJS_CSS))
	@$(ECHO) ""									>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ICON))
	@$(ECHO) ""									>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_LOGO))
	@$(ECHO) "$(_E)"
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
			--output="$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/template.default.$(word 2,$(subst :, ,$(FILE)))" \
			--print-default-template="$(word 1,$(subst :, ,$(FILE)))"; \
		if [ ! -f $(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/template.$(word 2,$(subst :, ,$(FILE))) ]; then \
			$(LN) \
				$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/template.default.$(word 2,$(subst :, ,$(FILE))) \
				$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/template.$(word 2,$(subst :, ,$(FILE))); \
		fi; \
		$(call NEWLINE) \
	)
	@$(foreach FILE,\
		$(TMPL_DOCX):$(EXTN_DOCX) \
		$(TMPL_PPTX):$(EXTN_PPTX) \
		,\
		$(PANDOC) --verbose \
			--output="$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/reference.default.$(word 2,$(subst :, ,$(FILE)))" \
			--print-default-data-file="reference.$(word 1,$(subst :, ,$(FILE)))"; \
		if [ ! -f $(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/reference.$(word 2,$(subst :, ,$(FILE))) ]; then \
			$(LN) \
				$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/reference.default.$(word 2,$(subst :, ,$(FILE))) \
				$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/reference.$(word 2,$(subst :, ,$(FILE))); \
		fi; \
		$(call NEWLINE) \
	)
	@$(ECHO) "$(_D)"
	@$(LS) $(CURDIR)
	@$(LS) $(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))
ifneq ($(COMPOSER_RELEASE),)
	@$(ECHO) "$(_E)"
	@$(CP) $(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-v1.0.png	$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ICON))
	@$(CP) $(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ART))/icon-v1.0.png	$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_LOGO))
	@$(ECHO) "$(_D)"
	@$(ENV_MAKE) $(SILENT) COMPOSER_LOG="$(COMPOSER_LOG_DEFAULT)"			COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(CLEANER)
#>	@$(ENV_MAKE) $(SILENT) COMPOSER_LOG=						COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" COMPOSER_DEBUGIT="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_HTML)
	@$(ENV_MAKE) $(SILENT) COMPOSER_LOG=						COMPOSER_EXT="$(COMPOSER_EXT_DEFAULT)" $(DOITALL)
	@$(ECHO) "$(_E)"
	@$(MV) $(CURDIR)/$(COMPOSER_YML)						$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH).yml
	@$(ECHO) "$(_D)"
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML,1)					>$(CURDIR)/$(COMPOSER_YML)
	@$(ECHO) ""									>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_ICON))
	@$(ECHO) ""									>$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMPOSER_LOGO))
endif

########################################
## {{{2 $(EXAMPLE) ---------------------

#> update: COMPOSER_OPTIONS

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(MAKE) $(SILENT) COMPOSER_DOCOLOR= COMPOSER_DEBUGIT= .$(EXAMPLE)

.PHONY: .$(EXAMPLE)-$(INSTALL)
.$(EXAMPLE)-$(INSTALL):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN ,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
	@$(call $(EXAMPLE)-var-static,,COMPOSER_MY_PATH)
	@$(call $(EXAMPLE)-var-static,,COMPOSER_TEACHER)
	@$(call $(EXAMPLE)-print,,include $(_E)$(~)(COMPOSER_TEACHER))

.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN ,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
	@$(call $(EXAMPLE)-print,,$(_S)########################################)
	@$(call $(EXAMPLE)-print,1,$(_H)Global)
	@$(ENDOLINE)
	@$(foreach FILE,$(COMPOSER_OPTIONS_GLOBAL),\
		$(call $(EXAMPLE)-var,1,$(FILE)); \
	)
	@$(ENDOLINE)
	@$(call $(EXAMPLE)-print,,$(_S)########################################)
	@$(call $(EXAMPLE)-print,1,$(_N)ifeq$(_D) ($(_E)\$$(COMPOSER_MY_PATH)$(_D),$(_N)\$$(CURDIR)$(_D)))
	@$(ENDOLINE)
	@$(call $(EXAMPLE)-print,,$(_S)########################################)
	@$(call $(EXAMPLE)-print,1,$(_H)Local)
	@$(ENDOLINE)
	@$(foreach FILE,$(COMPOSER_OPTIONS_LOCAL),\
		$(call $(EXAMPLE)-var,1,$(FILE)); \
	)
	@$(ENDOLINE)
	@$(call $(EXAMPLE)-print,,$(_S)########################################)
	@$(call $(EXAMPLE)-print,1,$(_N)endif$(_D))

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
override DIST_SCREENSHOT_v3.0		:= iVBORw0KGgoAAAANSUhEUgAAAeMAAADICAIAAABUCR4uAAABhGlDQ1BJQ0MgcHJvZmlsZQAAKJF9kT1Iw0AcxV9ba6VUOthBxCFDdWpBVMRRq1CECqFWaNXB5NIvaGJIUlwcBdeCgx+LVQcXZ10dXAVB8APE0clJ0UVK/F9SaBHjwXE/3t173L0D/M0aU82eMUDVLCObTgn5wooQekUQYfQiioTETH1WFDPwHF/38PH1LsmzvM/9OfqVoskAn0A8w3TDIl4nntq0dM77xDFWkRTic+KEQRckfuS67PIb57LDfp4ZM3LZOeIYsVDuYrmLWcVQiSeJ44qqUb4/77LCeYuzWquz9j35CyNFbXmJ6zSHkcYCFiFCgIw6qqjBQpJWjRQTWdpPefiHHL9ILplcVTByzGMDKiTHD/4Hv7s1SxPjblIkBQRfbPtjBAjtAq2GbX8f23brBAg8A1dax7/RBKY/SW90tPgREN0GLq47mrwHXO4Ag0+6ZEiOFKDpL5WA9zP6pgIwcAuEV93e2vs4fQBy1FXmBjg4BEbLlL3m8e6+7t7+PdPu7wc213KP0n9sFQAAAAlwSFlzAAAYJQAAGMMBG9cmzQAAAAd0SU1FB+YFCgYdDrfNAIIAAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAQfklEQVR42u2dW5LjKBBF6YreUddyWB7LqdnTfHhaI/NMXlYC50RHhytLQgiVr9MpuDJ/jPljAABAL18MAQDAQkrtbv8TIUKECBEtEXJqAADt/HoVqf95k3NjjDVEiBAhQkRFxJjbHUW+axAhQoSIxgg5NREiRIiQUxMhQoQIkb4IdxQBANTDyhcAAOWQUwMAoNQAAIBSAwCg1AAAsIpSO0EktaMTb/wIXg9d7BwbzsK9/6saWx2jAgAqyM6nHiHWTv1bv22m40DZc0oHB6UGWFOpG8Ra/9vdJXJh78UkzRN/Bvz8/BQjyDTAlnzF8rrsm1Sy+rGh2uASpQaX3ksS8QRXzuukbF9ufr22vdfpJcp3aQ4jU1W7OMzaLiDA2Tl1bWbtxNUGV1l/EEZcaw9T2lOl1G17PZ1TO8Hl0nMBAbbnd+IdZwvvY1uKfIArl7e3o7vYZt4LefvRH6tO1g4bou/v72JklExb2ZAov4AA+yn19W1/EZm+v3edjnezeAhB5wUEUEvlfOpOmW6b4mZLrdmOGYTCvea1ZqXfZNqqH64yku+F/gsIsCWXP/VMmXaxUkAqp8qkpcV28i3Le+hiVQsny/q8I0r6XCPTV8UjjJhpA6b/AgJsjlIvvb0Tqqaz+0xOzQUEQKl5o58CFxDgAKUGAIC/4NAEAIBSAwDAOKXm+ZJEiBAhojFCTg0AoJ1rPnXRdYkIESJEiDwSKTg0ESFChAiR5yPk1ESIECFCTk2ECBEiRPoi3FEEAFAPaxQBAJRDTg0AgFIDAABKDQCwN78ZAoVInhIAXAtAqSM44+zf52/IX7v3uYHRyGtj70f7/qyP6F6ZHoY73jsWPXSm5c8zVhf0PzklfFJMqs/yc7kep9u8wXUh5j0GHkBEdj61SWnl9fr1wvsx+quU5ubbL+7V03L+iBryuIE6qJzUhNLmc3Gx7Zufd4NSw7N8Vb6dfF1+ZaBhphxNb7Vhz3hE3yoJtShfaLnK8dcAK1Y/3Pv/NiVt0ZqGpAoBelJXk33CrHkvRLiY0jU/u7ZYcLDvW5r0o4Zd6THCDbUO4WONAZ5Sapt9qHRd3p0qMacqxVUZfWcufP+YOeHjJFX5zdSFwz+F4l7Cll324e/FpNiJX7uYNNtSql7VKwC9OXWobmFyfeXdmSJDm0SOEtbo/c/T6h5jT/ueLId5bnjQvCDaRJ6bOS+XSMybv3MAbJVTh2lyVKxhe8JkecjlT5U43JwCNH+yoJOvae9b61QmKG7ZtMlVRpygaCs/tMs26LIVBlef8hc7nCpluGmjDaAhpzZBTXKKOKYS7WtWSSpJr2on3Cs6TWWhrN8lEsx8xKTVzSYi0dTS1rdjB92ds+83OaMlDltzRzEzYpY7iqCV60kCK+aYGlesDCG6Ls5lJz80ZKkN9YcDYY0iqADXU6AOAKAcHJqgXH8AgGfBoYlv3MA1hb2UWuJ2lHFoyqx8KbomSW4nSvpjZG5QxbOQ+Ez1cKZD0x5EzwWnJ+iix6HpM5HU0YX9TJlJ1R4r005tD+X510Dt0K9u2+A+eGXhEBrr1MWstlmqPjmFY96xVE1EIaEG2Kb6IV1NLhEpiYvTJ+WYBZNhuqfWoWm5PodH5xMI5in1MIemTDnCZi36vG1G+TrNVL23/uhcU7O6Q5POPgd/wBVPQgBQkVOHOiWRrfC+X9TXqS07npTgZ5ynlGTxizo0Gd19pp4De+bUlDJOYJJD06J9tog1DKXxjuLYFLWqtbYEOfXcxafOoi1Broqs69DkFPdZ3hPL8k6YkFObokNTWIdtq8wK2xFOoI7KZSbvlhwr3OY+oUW+13CZPsGhqeia9Hifo+NsyaxhJjg0aeRwh6b+I87uc0P7rFGELnBogtqqC30GQKkBAOANHJo0cs43ZWoCAOOVusGPSeLQ1HbzcG8OcWjCtwhAxGyHpugL4Wty6oFKfdT5AmzGeIcm0AYTxQBWZ8pqctCs2n8/a+MRhQ5NADB+NXnb6o8Vnxe+XEK9hNsRAIR8JXLqdlL+SjP2gua6xwy3IxfIukuk5FxmgDaltsH/XWLdZs3B7cR1sYHThb39A4AhSt1Y4kCsP5kgV0X0OzQBgJDpDk0ZbyP8S2tl+gSHJgCIwGpyhfz8pSennpfLzz5TAECpQZFSA4CEL4YA8lC7AECpYWJNQN7OkGNx4QBmIa9+1Lp2XLcN7/+uX3k/Zva6/6oYMQIXkehe2pRaUpRwpYiwteIGr/HKRxBrgM8odbVDkwmMmfKeTZJtUr5OVXtF+yPU8VWU2ojvKPYr9UuaixGUGkBF9SPUwXC6nverPOG8PUk3MjMCU/2paue0Sssoh9Xv72/EGmCqUotWk78UsChwDROlhS0fi0sXN8Yfy8WLGwDwFFMcmjzBVeW+NPUJ4jO7/b9kz+60tf9LtuWjE0CTUktdT1MqnMmOhYIo3Mxb7hj9rfBAC2Xxn0xwyaYBdsupwwduzS5l5GvQ0f6sjouZPs+T6XtODQAamDWfWnhP7/N6urSCz+h66jZgg0wPvDkJANGc2oyyPM2LozW2zdepzR+q7ejasO+PYrmrdpVDk+hY9j+Nvl5cqh2m2xSyAT4Evh8KYY0iAKDUAAArge8HAIB2fjMECrkqCZkbdJJtAGATPu/QFPXiyGwjb2c/pX4fJemWALBxTt0yn/o1bzo/e7rKAKRzm11hZjPAyTzs0ARCmWYoAVBq87hDE2S/TADA0WhxaIquavE+GFZ0VgIAGKjUDzs0UacGAEjx9f4Nu3pB+Wt9tqehQtMPAACoUurB9Is1zxYAAHjxgEOTMNLWzpZ4rkx8dgGcxq/Xspd/GAlNsEYRAN7AoQkAQDk4NAEAoNQAAIBSAwCco9ThUnIiRIgQIfJ8hJwaAEA71yw9b5WKNUSIECFCREXkbZYe3zWIECFCRGOEnJoIESJEyKmJECFChEhfhDuKAADqYTU5AIByyKkBAFBqAABAqQEAUGoAAFCj1Jc5fRwniKR2dIYHK1ZRuBbdbH81nPvv33IdLnZb/tvhp985pF7fHJog5z73o6wODWLtxsmDO0hyUOpOQZmnVh/uf/RXxQ3mnfsQpQ5fQEVOXUayoCa/+3B4qmCTTK81bOHnlvyTzK72F+Jcss/Xr6ztUnM9WN6/Mn63KKP3RreVb31303cb5HipyH3NjreNrWwZYsl1fuDvF9nFPihdfSR6uVIy/fPzcz0xMoxUJXQvdXj9+JK8e8RTEG8vSeTV4NV+UY5Tr3vk794HSQ+jfQjPtCrjDscHPlX9aCiDRLf0nrbtZC0Xqx+1LR9Z/XDZ16mIE2zTEHGyi1ObU4fSENYEUv+n0tKqiCeRYQ06WqMoFqkllY3UGRV7WDV68h6mxoc69eScOvrlufbrtE2nW53CSuLcWvcYO3L3ZDlzka3s6GHu/NQT2e+paCZnvH51FSuqSgH9mbW3e6aHVR94A8eQusdkpe6XaYlOuOz7G1bABldyj/dmWC5oEJ17gWK2ZnmVjal7wSQq7yh2yrSr36ZzvofdeY6gq4zkr5WrPLTLNuiC5Lrn+1LPHcUqlbm+lWfqy15yPSoJzVczvIN6PRQeV7JZw0l5GxTHECbn1G0ybQX39MJt7PudrPAb9f0dn+/Gprm5S3z3cDXDkxl4E9w2Ntkfi+3Y1pu7DXcU7zIaTpa4K4inJuGPxXZSLdcWAaLthLocpuFR7U5VbFKyG24T3Ss8VrSHqTGEdjb30lv2juKMnHrecWfTk1P3Z7UPX2Wnveerz15HqdXoGSskF1dqPZoIjCFKDQAAEXBoAgDQztsdxcKir+aJH6wSrKd2AV71t9Str0a4Us77Vp5aHxju5W2Zasc7etu0h/yyRjgaHJrUKvVcLdv6rzq/Ui7zq+LKveb7ewMn0sGB4NB0Ikc5NGU0cTO3I0Cpx4m1iZk+mNgMDZfw8UgZfchbhsqB94w7nGCv5kuakum7NIeReTQvI0y5f3i/5TMAJlQ/GsogODQpq34c4tDkeQBFI6mih8m6OEl8lIpGzHlnKAAPHJqoe0wZuccdmsJcOMyLhbKYX8co2QXg40qNQxPUXNIHHZqKhQsciGAVcGhaO0Guihzo0PQx04kqjzqAmTk1Dk36ZBqHpjYxTc2DNoJJzanJ2sX8PWw56iKNCx1EwKHpnJx63nFn8xmHps/k1AAodfaLOiyr1AAoNQ5NAACqwaEJAEA7ODQpBYemrrN71KGp2DfviNw/hDI4NKlV6rlatvVf9bMOTcK+pZYvAoTg0HQiODQZTQ5N5NRQV/2oEGubjUh0IjozOhO5m0d429jKliGWXOcH/n6RXeyD0tVHopcrJdP986mbZTRa96iqvZA4w2erHw1lEByalFU/cGhKVUjMOIemYoFF0g5AR05tcGjas+6BQ5OwOjGkWNFspgoo9adkWqITODStDw5NAKPAoWntBLkqgkPTxGsR2E+//pE1w8dzahya9Mk0Dk1tYjrboSksmJC2Qxc4NJ2TU8877mzWcmhClAGlbtIVHJoWV+rFxocBApQaAOA0cGgCANAODk1KwaGp6+wUOzRl+sxEEUiCQ5NapZ6rZVv/VWt2aJL0GcADh6YTwaHJaHJoAiiCQxOqLRp4HJqqxPraOKy9pOoq4V4ArdWPhjIIDk3Kqh84NKUqJOazDk2SIgxAa05tcGjas+6BQ1OmqcyPRbEGeEKpcWiCmkt6pkMT5QsYCw5NayfIVREcmiZeC1eIpzybyL5hdE6NQ5M+mcahqU1Mpzo03T8eip5N9425owhJcGg6J6eed9zZrOXQVPtbgOOV2uDQtINSLz9iDBmg1AAAe4NDEwCAdnBoUgoOTV1nt6BDU9WpdR632Q1qyNGhBRya1Cr13Df81n/VKzo0tZ1dPjijBWruj4BD04ng0GS2c2giz0Wph4q1iZk+mNgMDZfw8UgZfchbhsqB94w7nGCv5kuakum7NIeRqQpYWyu4O4TcgxLXkfxemSN27hX2+XpNEr1g9aOhDIJDk7LqBw5Nea0MU+kGh6aqKorEoano35Q/r2IPw43Dc6f68SA4NFH3mDJyhzs0hUsTJcfKC3TVl4DXC4nnCWyq1Dg0Qc0lPdOhSSL312SS1Irz1LwU4bF43NdO4NC0doJcFcGhaeK1cCO3jBYiatv3zn1sD0FxTo1Dkz6ZxqGpTUynOjTlPzDuGbSXUHvbZFyc7o+JSXk/hV8ait8wwnOPOv+RrT8ADk3n5NTzjjub1R2aPnBcyUwPQKl16xmz9BZXashLMCqMUgMAwMPg0AQAoB0cmpSCQ1NnQeDiWYcmbr7BGHBoUqvUc7Vs679qPQ5NVJBhCDg0nQgOTWY7hybYm/o1ijZ4o9v69S+pmdGZyN08wtvGVrYMseQ6P/D3i+xiH5SuPhK9XCmZ7p9P3ZgJ2HjdozaVTs1xzlRaAFqrHw1lEByalFU/cGhKVUjMOIemYoFFWHIBaM2pDQ5Ne9Y9cGjKNJX5cUjanuozQKtS49AENZcUhyaAfnBoWjtBrorg0DTxWrgB+zYUxIGcepBM49A0U6ZxaGoT06kOTdFp1yn3JRPcUaQGAhFwaDonp5533Nng0AQoNQ5NoF2pAVBqHJoAAFSDQxMAAEoNAAAoNQAASg0AACg1AACk+Re1n+/TbyIf6gAAAABJRU5ErkJggg==

override ICON_AUTHOR			:= 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
override ICON_GITHUB			:= iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpFNTE3OEEyQTk5QTAxMUUyOUExNUJDMTA0NkE4OTA0RCIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpFNTE3OEEyQjk5QTAxMUUyOUExNUJDMTA0NkE4OTA0RCI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkU1MTc4QTI4OTlBMDExRTI5QTE1QkMxMDQ2QTg5MDREIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkU1MTc4QTI5OTlBMDExRTI5QTE1QkMxMDQ2QTg5MDREIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+m4QGuQAAAyRJREFUeNrEl21ojWEYx895TDPbMNlBK46IUiNmPvHBSUjaqc0H8pF5+aDUKPEBqU2NhRQpX5Rv5jWlDIWlMCv7MMSWsWwmb3tpXub4XXWdPHvc9/Gc41nu+nedc7/8r/99PffLdYdDPsvkwsgkTBwsA/PADJCnzX2gHTwBt8Hl7p537/3whn04XoDZDcpBlk+9P8AFcAghzRkJwPF4zGGw0Y9QS0mAM2AnQj77FqCzrtcwB1Hk81SYojHK4DyGuQ6mhIIrBWB9Xm7ug/6B/nZrBHBegrkFxoVGpnwBMSLR9EcEcC4qb8pP14BWcBcUgewMnF3T34VqhWMFkThLJAalwnENOAKiHpJq1FZgI2AT6HZtuxZwR9GidSHtI30jOrbawxlVX78/AbNfhHlomEUJJI89O2MqeE79T8/nk8nMBm/dK576hZgmA3cp/R4l9/UeSxiHLVIlNm4nFfT0bxyuIj7LHRTKai+zdJobwMKzcZSJb0ePV5PKN+BqAAKE47UlMnERELMM3EdYP/yrd+XYb2mOiYBiQ8OQnoRBlXrl9JZix7D1pHTazu4MoyBcnYamqAjIMTR8G4FT8LuhLsexXYYjICBiqhQBvYb6fLZIJCjPypVvaOoVAW2WcasCnL2Nq82xHJNSqlCeFcDshaPK0twkAhosjZL31QYw+1rlMpWGMArl23SBsZZO58F2tlJXmjOXS+s4WGvpMiBJT/I2PInZ6lIs9/hBsNS1hS6BG0DSqmYEDRlCXQrmy50P1oDRKTSegmNbUsA0zDMwRhPJXeCE3vWLPQMvan6X8AgIa1vcR4AkGZkDR4ejJ1UHpsaVI0g2LInpOsNFUud1rhxSV+fzC9Woz2EZkWQuja7/B+jUrgtIMpy9YCW4n4K41YfzRneW5E1KJTe4B2Zq1Q5EHEtj4U3AfEzR5SVY4l7QYQPJdN2as7RKBF0BPZqqH4VgMAMBL8Byxr7y8zCZiDlnOcEKIPmUpgB5Z2ww5RdOiiRiNajUmWda5IG6WbhsyY2fx6m8gLcoJDJFkH219M3We1+cnda93pfycZpIJEL/s/wSYADmOAwAQgdpBAAAAABJRU5ErkJggg==
override ICON_GPL			:= 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
override ICON_CC			:= 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
override ICON_RESERVED			:= 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

########################################
## {{{2 Heredoc Function ---------------

override define DO_HEREDOC =
	$(if $(2),$(eval $(call COMPOSER_NOCOLOR))) \
	$(ECHO) '$(subst ',[Q],$(subst $(call NEWLINE),[N],$(call $(1))))[N]' \
		| $(SED) \
			-e "s|[[]Q[]]|\'|g" \
			-e "s|[[]N[]]|\\n|g" \
	$(if $(and $(2),$(COMPOSER_DOCOLOR)),$(eval $(call COMPOSER_COLOR)))
endef

########################################
## {{{2 Heredoc: gitattributes ---------

override define HEREDOC_GITATTRIBUTES =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Git Attributes
################################################################################

########################################
# https://github.com/github/linguist/blob/master/docs/overrides.md

/**					linguist-vendored

/$(MAKEFILE)				!linguist-vendored
$(patsubst $(COMPOSER_DIR)%,%,$(COMPOSER_ART))/				!linguist-vendored

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: gitignore -------------

override define HEREDOC_GITIGNORE =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Git Exclusions
################################################################################

########################################
# $(COMPOSER_BASENAME)

#>**/$(COMPOSER_SETTINGS)
#>**/$(COMPOSER_YML)
#>**/$(COMPOSER_CSS)

**/$(COMPOSER_LOG_DEFAULT)
**$(patsubst $(COMPOSER_DIR)%,%,$(COMPOSER_TMP))/

########################################
# $(UPGRADE)

$(patsubst $(COMPOSER_DIR)%,%,$(COMPOSER_PKG))/
**/.git

$(patsubst $(COMPOSER_DIR)%,%,$(PANDOC_DIR))/pandoc-*
$(patsubst $(COMPOSER_DIR)%,%,$(YQ_DIR))/yq_*

########################################
# $(DEBUGIT) / $(TESTING)

/.$(COMPOSER_BASENAME)**
/$(COMPOSER_BASENAME)**

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: composer_mk -----------

override define HEREDOC_COMPOSER_MK =
$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)$(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration$(_D)
$(_S)################################################################################$(_D)

$(_S)########################################$(_D)
$(_N)ifeq$(_D) ($(_E)$$(COMPOSER_MY_PATH)$(_D),$(_N)$$(CURDIR)$(_D))

$(_S)########################################$(_D)
$(_S)#$(_D) $(_H)Wildcards$(_D)

$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_css		:= $(CSS_ALT)$(_D)
$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_toc		:= $(SPECIAL_VAL)$(_D)

$(_S)########################################$(_D)
$(_S)#$(_D) $(_H)Settings$(_D)

$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D):			$(_E)$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT)$(_D)
$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D): $(_E)override c_site	:= 1
$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D): $(_E)override c_css	:= $(patsubst $(COMPOSER_DIR)/%,%,$(MDVIEWER_CSS_SOLAR_ALT))$(_D)
$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D): $(_E)override c_toc	:=$(_D)
$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D): $(_E)override c_options	:= --variable=pagetitle="$(COMPOSER_TAGLINE)"$(_D)

$(_M)$(OUT_README).$(EXTN_LPDF)$(_D):				$(_E)$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)

$(_M)$(OUT_README).$(EXTN_EPUB)$(_D): $(_E)override c_css		:=$(_D)

$(_M)$(OUT_README).$(EXTN_PRES)$(_D):			$(_E)$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART))/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)$(_D)
$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_css	:=$(_D)
$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_toc	:=$(_D)

$(_S)########################################$(_D)
$(_N)endif$(_D)

$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)End Of File$(_D)
$(_S)################################################################################$(_D)
endef

########################################
## {{{2 Heredoc: composer_yml ----------

override define HEREDOC_COMPOSER_YML =
$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)$(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration$(_D)
$(_S)################################################################################$(_D)

$(_H)variables$(_D):

$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)$(COMPOSER_BASENAME) $(DIVIDE) $(PUBLISH)$(_D)

  $(_C)title-prefix$(_D):				$(_M)null$(_D) $(_S)#$(MARKER)$(_D) $(_N)EXAMPLE SITE$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-config$(_D):

    $(_C)homepage$(_D):				$(_M)http://www.example.net$(_D)
    $(_C)brand$(_D):				$(_M)LOGO / BRAND$(_D)
    $(_C)copyright$(_D):				$(_M)COPYRIGHT$(_D)

    $(_C)cols_main_size$(_D):			$(_M)$(PUBLISH_COLS_MAIN_SIZE)$(_D)
    $(_C)cols_mobile_hide$(_D):			$(_M)$(PUBLISH_COLS_MOBILE_HIDE)$(_D)
    $(_C)cols_sticky$(_D):			$(_M)$(PUBLISH_COLS_STICKY)$(_D)
    $(_C)copy_safe$(_D):				$(_M)$(PUBLISH_COPY_SAFE)$(_D)

    $(_C)search_name$(_D):			$(_M)SEARCH$(_D)
    $(_C)search_site$(_D):			$(_M)https://duckduckgo.com$(_D)
    $(_C)search_text$(_D):			$(_M)q$(_D)
    $(_C)search_form$(_D): $(_N)|$(_D)
      $(_M)<input type="hidden" name="sites" value="example.net"/>$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-library$(_D):

    $(_C)folder$(_D):				$(_M)$(LIBRARY_FOLDER)$(_D)
    $(_C)auto_update$(_D):			$(_M)$(LIBRARY_AUTO_UPDATE)$(_D)

    $(_C)digest_title$(_D):			$(_M)$(LIBRARY_DIGEST_TITLE)$(_D)
    $(_C)digest_count$(_D):			$(_M)$(LIBRARY_DIGEST_COUNT)$(_D)
    $(_C)digest_expanded$(_D):			$(_M)$(LIBRARY_DIGEST_EXPANDED)$(_D)
    $(_C)digest_chars$(_D):			$(_M)$(LIBRARY_DIGEST_CHARS)$(_D)
    $(_C)digest_spacer$(_D):			$(_M)$(LIBRARY_DIGEST_SPACER)$(_D)
    $(_C)digest_continue$(_D):			$(_M)$(LIBRARY_DIGEST_CONTINUE)$(_D)
    $(_C)digest_permalink$(_D):			$(_M)$(LIBRARY_DIGEST_PERMALINK)$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-nav-top$(_D):

    $(_M)MAIN$(_D):				$(_E)<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)$(_D)
    $(_M)PAGES$(_D):
      $(_N)$(MENU_SELF)$(_D): $(_N)"#"$(_D)
      $(_M)$(COMPOSER_BASENAME) $(OUT_README)$(_D):			$(_E)<composer_root>/../$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D)
      $(_M)Introduction$(_D):			$(_E)<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)$(_D)
      $(_M)Default Site$(_D):			$(_E)<composer_root>/$(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)$(_D)
      $(_M)Configured Site$(_D):			$(_E)<composer_root>/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)$(_D)
      $(_M)Default Digest Page$(_D):		$(_E)<composer_root>/$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML)$(_D)
      $(_M)Configured Digest Page$(_D):		$(_E)<composer_root>/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML)$(_D)
      $(_M)Default Markdown File$(_D):		$(_E)<composer_root>/$(CONFIGS)/$(notdir $(PANDOC_DIR))/MANUAL.$(EXTN_HTML)$(_D)
      $(_M)Configured Markdown File$(_D):		$(_E)<composer_root>/$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/introduction.$(EXTN_HTML)$(_D)
      $(_M)Elements & Includes$(_D):		$(_E)<composer_root>/$(CONFIGS)/$(PUBLISH)-$(TESTING).$(EXTN_HTML)$(_D)
    $(_M)AUTHORS$(_D):
      $(_N)$(MENU_SELF)$(_D): $(_N)"#"$(_D)
      $(_N).library-authors$(_D): $(_N)$(MENU_SELF)$(_D)
    $(_M)DATES$(_D):
      $(_N)$(MENU_SELF)$(_D): $(_N)"#"$(_D)
      $(_N).library-dates$(_D): $(_N)$(MENU_SELF)$(_D)
    $(_M)TAGS$(_D):
      $(_N)$(MENU_SELF)$(_D): $(_N)"#"$(_D)
      $(_N).library-tags$(_D): $(_N)$(MENU_SELF)$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-nav-bottom$(_D):

    $(_M)PATH 1$(_D): $(_E)"#"$(_D)
    $(_M)PATH 2$(_D): $(_E)"#"$(_D)
    $(_M)PATH 3$(_D): $(_E)"#"$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-nav-left$(_D):

    - $(_C)pane-begin$(_D) $(_M)$(DEPTH_MAX) 1 LEFT 1$(_D)
    - $(_C)text$(_D): $(_N)|$(_D)
        * $(_M)ITEM 1$(_D)
        * $(_M)ITEM 2$(_D)
        * $(_M)ITEM 3$(_D)
    - $(_C)pane-end$(_D)
    - $(_N).spacer$(_D)
    - $(_C)box-begin$(_D) $(_M)$(DEPTH_MAX) LEFT 2$(_D)
    - $(_C)text$(_D): $(_N)|$(_D)
        $(_M)LEFT TEXT$(_D)
    - $(_C)box-end$(_D)
    - $(_C)text$(_D): $(_N)|$(_D)
        $(_M)EXAMPLE TEXT$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-nav-right$(_D):

    - $(_C)pane-begin$(_D) $(_M)$(DEPTH_MAX) 1 RIGHT 1$(_D)
    - $(_C)text$(_D): $(_N)|$(_D)
        * $(_M)ITEM 1$(_D)
        * $(_M)ITEM 2$(_D)
        * $(_M)ITEM 3$(_D)
    - $(_C)pane-end$(_D)
    - $(_N).spacer$(_D)
    - $(_C)box-begin$(_D) $(_M)$(DEPTH_MAX) RIGHT 2$(_D)
    - $(_C)text$(_D): $(_N)|$(_D)
        $(_M)RIGHT TEXT$(_D)
    - $(_C)box-end$(_D)
    - $(_N).spacer$(_D)
    - $(_C)pane-begin$(_D) $(_M)$(DEPTH_MAX) $(SPECIAL_VAL) AUTHORS$(_D)
    - $(_N).library-authors$(_D)
    - $(_C)pane-end$(_D)
    - $(_N).spacer$(_D)
    - $(_C)pane-begin$(_D) $(_M)$(DEPTH_MAX) $(SPECIAL_VAL) DATES$(_D)
    - $(_N).library-dates$(_D)
    - $(_C)pane-end$(_D)
    - $(_N).spacer$(_D)
    - $(_C)pane-begin$(_D) $(_M)$(DEPTH_MAX) $(SPECIAL_VAL) TAGS$(_D)
    - $(_N).library-tags$(_D)
    - $(_C)pane-end$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-info-top$(_D): $(_N)|$(_D)
    $(_M)TOP INFO$(_D)

$(_S)########################################$(_D)

  $(_H)$(PUBLISH)-info-bottom$(_D): $(_N)|$(_D)
    $(_M)BOTTOM INFO$(_D)

$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)End Of File$(_D)
$(_S)################################################################################$(_D)
endef

########################################
## {{{2 Heredoc: composer_yml ($(OUT_README))

override define HEREDOC_README_COMPOSER_YML =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(OUT_README))
################################################################################

variables:

################################################################################
# $(COMPOSER_BASENAME) $(DIVIDE) $(PUBLISH)

  title-prefix:				"$(COMPOSER_HEADLINE)"

########################################

  $(PUBLISH)-config:

    homepage:				$(COMPOSER_HOMEPAGE)
    brand:				$(COMPOSER_TECHNAME)
    copyright:				$(COPYRIGHT_SHORT)

    cols_main_size:			6
    cols_mobile_hide:			1
    cols_sticky:			1
    copy_safe:				0

    search_name:			Search
    search_site:			https://duckduckgo.com
    search_text:			q
    search_form: |
      <input type="hidden" name="sites" value="$(COMPOSER_SEARCH)"/>
      <input type="hidden" name="ia" value="web"/>
      <input type="hidden" name="kae" value="d"/>
      <input type="hidden" name="ko" value="1"/>
      <input type="hidden" name="kp" value="-1"/>
      <input type="hidden" name="kv" value="1"/>
      <input type="hidden" name="kz" value="-1"/>

########################################

  $(PUBLISH)-library:

    folder:				null
    auto_update:			null

    digest_title:			null
    digest_count:			null
    digest_expanded:			null
    digest_chars:			null
    digest_spacer:			null
    digest_continue:			null
    digest_permalink:			null

########################################

  $(PUBLISH)-nav-top:

    Top: "#"
    CMS:
      $(MENU_SELF): "#$(COMPOSER_TINYNAME)-cms"
      Overview: "#overview"
      Quick Start: "#quick-start"
      Principles: "#principles"
      Requirements: "#requirements"
    Operation:
      $(MENU_SELF): "#$(COMPOSER_TINYNAME)-operation"
      Recommended Workflow: "#recommended-workflow"
      Document Formatting:
        $(MENU_SELF): "#document-formatting"
        Bootstrap Websites: "#bootstrap-websites"
        HTML: "#html"
        PDF: "#pdf"
        EPUB: "#epub"
        Reveal.js Presentations: "#revealjs-presentations"
        Microsoft Word & PowerPoint: "#microsoft-word--powerpoint"
      Configuration Settings: "#configuration-settings"
      Precedence Rules: "#precedence-rules"
      Specifying Dependencies: "#specifying-dependencies"
      Custom Targets: "#custom-targets"
      Repository Versions: "#repository-versions"
    Variables:
      $(MENU_SELF): "#$(COMPOSER_TINYNAME)-variables"
      Formatting Variables:
        $(MENU_SELF): "#formatting-variables"
        c_site: "#c_site"
        c_type / c_base / c_list: "#c_type--c_base--c_list"
        c_lang: "#c_lang"
        c_css: "#c_css"
        c_toc: "#c_toc"
        c_level: "#c_level"
        c_margin: "#c_margin"
        c_options: "#c_options"
      Control Variables:
        $(MENU_SELF): "#control-variables"
        MAKEJOBS: "#makejobs"
        COMPOSER_DOCOLOR: "#composer_docolor"
        COMPOSER_DEBUGIT: "#composer_debugit"
        COMPOSER_INCLUDE: "#composer_include"
        COMPOSER_DEPENDS: "#composer_depends"
        COMPOSER_KEEPING: "#composer_keeping"
        COMPOSER_LOG: "#composer_log"
        COMPOSER_EXT: "#composer_ext"
        COMPOSER_TARGETS: "#composer_targets"
        COMPOSER_SUBDIRS: "#composer_subdirs"
        COMPOSER_IGNORES: "#composer_ignores"
    Targets:
      $(MENU_SELF): "#$(COMPOSER_TINYNAME)-targets"
      Primary Targets:
        $(MENU_SELF): "#primary-targets"
        help / help-all: "#help--help-all"
        template: "#template"
        compose: "#compose"
        site: "#site"
        install / install-all / install-force: "#install--install-all--install-force"
        clean / clean-all / *-clean: "#clean--clean-all---clean"
        all / all-all / *-all: "#all--all-all---all"
        list: "#list"
      Additional Targets:
        $(MENU_SELF): "#additional-targets"
        debug / debug-file: "#debug--debug-file"
        check / check-all / config / config-site / config-all / targets: "#check--check-all--config--config-site--config-all--targets"
        _commit / _commit-all: "#_commit--_commit-all"
        _release / _update / _update-all: "#_release--_update--_update-all"
      Internal Targets: "#internal-targets"
    Reference:
      $(MENU_SELF): "#reference"
      Configuration:
        $(MENU_SELF): "#configuration"
        Pandoc Extensions: "#pandoc-extensions"
        Templates: "#templates"
        Defaults: "#defaults"
      Reserved:
        $(MENU_SELF): "#reserved"
        Target Names: "#target-names"
        Variable Names: "#variable-names"

########################################

  $(PUBLISH)-nav-bottom:

    Home:				./
    Source:				./$(notdir $(COMPOSER_PKG))
    Artifacts:				./$(notdir $(COMPOSER_ART))
    Pandoc:				./$(notdir $(PANDOC_DIR))
    Bootstrap:				./$(notdir $(BOOTSTRAP_DIR))

########################################

  $(PUBLISH)-nav-left:

    - pane-begin $(DEPTH_MAX) 1 $(COMPOSER_TECHNAME)
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Overview
    - text: |
        * [Overview]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Quick Start
    - text: |
        * [Quick Start]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Principles
    - text: |
        * [Principles]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Requirements
    - text: |
        * [Requirements]
    - pane-end
    - pane-end
    - .spacer
    - box-begin $(DEPTH_MAX) Formats
    - text: |
        * [Bootstrap Website](_$(PUBLISH)/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML))$(foreach FILE,$(COMPOSER_TARGETS),$(call NEWLINE)        * [$(FILE)]($(FILE)))
    - box-end
    - text: |
        $(COMPOSER_TAGLINE)

########################################

  $(PUBLISH)-nav-right:

    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) $(COMPOSER_BASENAME) Operation
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Recommended Workflow
    - text: |
        * [Recommended Workflow]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Document Formatting
    - text: |
        * [Bootstrap Websites]
        * [HTML]
        * [PDF]
        * [EPUB]
        * [Reveal.js Presentations]
        * [Microsoft Word & PowerPoint]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Configuration Settings
    - text: |
        * [Configuration Settings]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Precedence Rules
    - text: |
        * [Precedence Rules]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Specifying Dependencies
    - text: |
        * [Specifying Dependencies]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Custom Targets
    - text: |
        * [Custom Targets]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Repository Versions
    - text: |
        * [Repository Versions]
    - pane-end
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) $(COMPOSER_BASENAME) Variables
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Formatting Variables
    - text: |
        * [c_site]
        * [c_type / c_base / c_list]
        * [c_lang]
        * [c_css]
        * [c_toc]
        * [c_level]
        * [c_margin]
        * [c_options]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Control Variables
    - text: |
        * [MAKEJOBS]
        * [COMPOSER_DOCOLOR]
        * [COMPOSER_DEBUGIT]
        * [COMPOSER_INCLUDE]
        * [COMPOSER_DEPENDS]
        * [COMPOSER_KEEPING]
        * [COMPOSER_LOG]
        * [COMPOSER_EXT]
        * [COMPOSER_TARGETS]
        * [COMPOSER_SUBDIRS]
        * [COMPOSER_IGNORES]
    - pane-end
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) $(COMPOSER_BASENAME) Targets
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Primary Targets
    - text: |
        * [help / help-all]
        * [template]
        * [compose]
        * [site]
        * [install / install-all / install-force]
        * [clean / clean-all / *-clean]
        * [all / all-all / *-all]
        * [list]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Additional Targets
    - text: |
        * [debug / debug-file]
        * [check / check-all / config / config-site / config-all / targets]
        * [_commit / _commit-all]
        * [_release / _update / _update-all]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Internal Targets
    - text: |
        * [Internal Targets]
    - pane-end
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Reference
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Configuration
    - text: |
        * [Pandoc Extensions]
        * [Templates]
        * [Defaults]
    - pane-end
    - pane-begin $(DEPTH_MAX) $(SPECIAL_VAL) Reserved
    - text: |
        * [Target Names]
        * [Variable Names]
    - pane-end
    - pane-end

########################################

  $(PUBLISH)-info-top: |
    <a rel="author" href="$(COMPOSER_HOMEPAGE)">
      <img alt="$(COMPOSER_TECHNAME)"
      class="$(COMPOSER_TINYNAME)-icon"
      src="$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART)/icon-github.jpg)"/></a>

########################################

  $(PUBLISH)-info-bottom: |
    <a rel="author" href="http://www.garybgenett.net/projects/composer">
      <img alt="Gary B. Genett"
      class="$(COMPOSER_TINYNAME)-icon"
      src="$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART)/icon-author.jpg)"/></a>
    <a rel="license" href="https://www.gnu.org/licenses/gpl-3.0.html">
      <img alt="GPL License"
      class="$(COMPOSER_TINYNAME)-icon"
      src="$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART)/icon-gpl.jpg)"/></a>
    <a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/4.0">
      <img alt="CC License"
      class="$(COMPOSER_TINYNAME)-icon"
      src="$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART)/icon-cc.jpg)"/></a>
    <a rel="license" href="https://wikipedia.org/wiki/All_rights_reserved">
      <img alt="All Rights Reserved"
      class="$(COMPOSER_TINYNAME)-icon"
      src="$(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART)/icon-reserved.jpg)"/></a>

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: $(PUBLISH)_build_sh ---

override define HEREDOC_PUBLISH_BUILD_SH =
#!$(BASH)
set -e
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) $(PUBLISH).build.sh
################################################################################
### {{{3 Variables ---------------------

DEPTH_MAX="$(DEPTH_MAX)"

HTML_BREAK="$(HTML_BREAK)"

PUBLISH_COLS_MAIN_SIZE="$(PUBLISH_COLS_MAIN_SIZE)"
PUBLISH_COLS_MOBILE_HIDE="$(PUBLISH_COLS_MOBILE_HIDE)"
PUBLISH_COLS_STICKY="$(PUBLISH_COLS_STICKY)"
PUBLISH_COPY_SAFE="$(PUBLISH_COPY_SAFE)"

########################################

YQ_READ="$(subst ",,$(patsubst $(YQ),$${YQ},$(YQ_READ)))"
YQ_WRITE="$(subst ",,$(patsubst $(YQ),$${YQ},$(YQ_WRITE)))"

CURDIR="$${CURDIR}"
COMPOSER_ROOT="$${COMPOSER_ROOT}"
COMPOSER_ROOT_PATH="$$($(REALPATH) $${CURDIR} $${COMPOSER_ROOT})"
PUBLISH_LIBRARY_INDEX="$${PUBLISH_LIBRARY_INDEX}"
PUBLISH_LIBRARY_INDEX_PATH="$$($(REALPATH) $${CURDIR} $$($(DIRNAME) $${PUBLISH_LIBRARY_INDEX}))"

################################################################################
### {{{3 Functions ---------------------

########################################
#### {{{4 $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT

#> update: $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT
function $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT {
	$(ECHO) "$${@}" \\
	| $(TR) 'A-Z' 'a-z' \\
	| $(SED) \\
		-e "s|-|DASH|g" \\
		-e "s|_|UNDER|g" \\
	| $(SED) \\
		-e "s|[[:punct:]]||g" \\
		-e "s|[[:space:]]|-|g" \\
	| $(SED) \\
		-e "s|DASH|-|g" \\
		-e "s|UNDER|_|g"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-brand -------------

# 1 COMPOSER_LOGO

function $(PUBLISH)-brand {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<h1 class="navbar-brand">
$$(
	if [ -s "$${1}" ]; then
		$(ECHO) "<a href=\"$$(
			$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
			| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"homepage\"]" 2>/dev/null \\
			| $(SED) "/^null$$/d"
		)\"><img class=\"$(COMPOSER_TINYNAME)-logo\" src=\"$${1}\"/></a>\\n"
	else
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) skip $(MARKER) logo -->\\n"
	fi
)
&nbsp;$$(
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
	| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"brand\"]" 2>/dev/null \\
	| $(SED) "/^null$$/d"
)
</h1>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-search ------------

function $(PUBLISH)-search {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<form class="d-flex" action="$$(
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
	| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"search_site\"]" 2>/dev/null \\
	| $(SED) "/^null$$/d"
)">
<input class="form-control form-control-sm me-1" type="text" name="$$(
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
	| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"search_text\"]" 2>/dev/null \\
	| $(SED) "/^null$$/d"
)"/>
<button class="btn btn-sm" type="submit">$$(
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
	| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"search_name\"]" 2>/dev/null \\
	| $(SED) "/^null$$/d"
)</button>
$$(
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
	| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"search_form\"]" 2>/dev/null \\
	| $(SED) "/^null$$/d"
)</form>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-info-data ---------

# 1 .variables["$(PUBLISH)-info-$${1}"]	top || bottom

function $(PUBLISH)-info-data {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	INFO="$$(
		$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} ".variables[\"$(PUBLISH)-info-$${1}\"]" 2>/dev/null \\
		| $(SED) "/^null$$/d"
	)"
	if [ -n "$${INFO}" ]; then
$(CAT) <<_EOF_
<span class="me-3">
$$(
	$(ECHO) "$${INFO}" \
	| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
)
</span>
_EOF_
	else
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) skip $(MARKER) $${@} -->\\n"
		return 0
	fi
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-top -----------

# 1 $(PUBLISH)-nav-top-list 1		.variables["$(PUBLISH)-nav-top"]
# 2 $(PUBLISH)-nav-begin 3		$(PUBLISH)-brand 1 COMPOSER_LOGO

# x $(PUBLISH)-nav-begin 1		true = top
# x $(PUBLISH)-nav-begin 2		true = brand
# x $(PUBLISH)-nav-end 1		$(PUBLISH)-info-data 1 top || bottom
# x $(PUBLISH)-nav-end 2		$(PUBLISH)-search true = search

function $(PUBLISH)-nav-top {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	$(PUBLISH)-nav-begin "1" "1" "$${2}"	|| return 1
	$(PUBLISH)-nav-top-list "$${1}"		|| return 1
	$(PUBLISH)-nav-end "top" "1"		|| return 1
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-top-list ------

# 1 .variables["$(PUBLISH)-nav-top"]

# x $(PUBLISH)-nav-top-library 1	titles || authors || dates || tags

function $(PUBLISH)-nav-top-list {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} "$${1} | keys | .[]" 2>/dev/null \\
		| while read -r FILE; do
			if [ "$${FILE}" = "$(MENU_SELF)" ]; then	continue
			elif [ "$${FILE}" = ".library-titles" ]; then	$(PUBLISH)-nav-top-library titles	|| return 1; continue
			elif [ "$${FILE}" = ".library-authors" ]; then	$(PUBLISH)-nav-top-library authors	|| return 1; continue
			elif [ "$${FILE}" = ".library-dates" ]; then	$(PUBLISH)-nav-top-library dates	|| return 1; continue
			elif [ "$${FILE}" = ".library-tags" ]; then	$(PUBLISH)-nav-top-library tags		|| return 1; continue
			elif [ "$${FILE}" = ".contents" ]; then		$(ECHO) "$(PUBLISH_BUILD_CMD_BEG) contents $(PUBLISH_BUILD_CMD_END)\\n"; continue
			fi
			LINK="$$(
				$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
				| $${YQ_WRITE} "$${1}[\"$${FILE}\"].$(MENU_SELF)" 2>/dev/null \\
				| $(SED) "/^null$$/d"
			)"
			if [ -n "$${LINK}" ]; then
				if [ "$${1}" = ".variables[\"$(PUBLISH)-nav-top\"]" ]; then
$(CAT) <<_EOF_
<li class="nav-item dropdown">
<a class="nav-link dropdown-toggle" href="$$(
	$(ECHO) "$${LINK}" \
	| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
)" data-bs-toggle="dropdown">$${FILE}</a>
<ul class="dropdown-menu bg-dark">
_EOF_
				else
$(CAT) <<_EOF_
<li><a class="dropdown-item" href="$$(
	$(ECHO) "$${LINK}" \
	| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a>
<ul>
_EOF_
				fi
				$(PUBLISH)-nav-top-list "$${1}[\"$${FILE}\"]" || return 1
$(CAT) <<_EOF_
</ul></li>
_EOF_
			else
				VAL="$$(
					$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
					| $${YQ_WRITE} "$${1}[\"$${FILE}\"]" 2>/dev/null \\
					| $(SED) "/^null$$/d"
				)"
				if [ "$${1}" = ".variables[\"$(PUBLISH)-nav-top\"]" ]; then
$(CAT) <<_EOF_
<li class="nav-item"><a class="nav-link" href="$$(
	$(ECHO) "$${VAL}" \
	| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a></li>
_EOF_
				else
$(CAT) <<_EOF_
<li><a class="dropdown-item" href="$$(
	$(ECHO) "$${VAL}" \
	| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a></li>
_EOF_
				fi
			fi
		done
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-top-library ---

# 1 titles || authors || dates || tags

function $(PUBLISH)-nav-top-library {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	$(CAT) $${PUBLISH_LIBRARY_INDEX} \\
		| $${YQ_WRITE} ".$${1} | keys | .[]" 2>/dev/null \\
		| $(SED) "/^null$$/d" \\
	| while read -r FILE; do
$(CAT) <<_EOF_
<li><a class="dropdown-item" href="$${PUBLISH_LIBRARY_INDEX_PATH}/$${1}-$$(
	$(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT "$${FILE}"
).$(EXTN_HTML)">$${FILE} ($$(
	$(CAT) $${PUBLISH_LIBRARY_INDEX} \\
		| $${YQ_WRITE} ".$${1}.[\"$${FILE}\"] | length" 2>/dev/null \\
		| $(SED) "/^null$$/d" \\
))</a></li>
_EOF_
	done
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-bottom --------

# 1 $(PUBLISH)-nav-bottom-list 1	.variables["$(PUBLISH)-nav-bottom"]

# x $(PUBLISH)-nav-begin 1		true = top
# x $(PUBLISH)-nav-begin 2		true = brand
# x $(PUBLISH)-nav-begin 3		$(PUBLISH)-brand 1 COMPOSER_LOGO
# x $(PUBLISH)-nav-end 1		$(PUBLISH)-info-data 1 top || bottom
# x $(PUBLISH)-nav-end 2		$(PUBLISH)-search true = search

function $(PUBLISH)-nav-bottom {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	$(PUBLISH)-nav-begin "" "" ""		|| return 1
$(CAT) <<_EOF_
<li class="nav-item me-3">$$(
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
	| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"copyright\"]" 2>/dev/null \\
	| $(SED) "/^null$$/d"
)</li>
<li class="nav-item me-3">$(DIVIDE)&nbsp;<a href="$(COMPOSER_HOMEPAGE)">$(CREATED_TAGLINE)</a></li>
_EOF_
	$(PUBLISH)-nav-bottom-list "$${1}"	|| return 1
	$(PUBLISH)-nav-end "bottom" ""		|| return 1
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-bottom-list ---

# 1 .variables["$(PUBLISH)-nav-bottom"]

function $(PUBLISH)-nav-bottom-list {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	if [ -z "$$(
		$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} "$${1}" 2>/dev/null \\
		| $(SED) "/^null$$/d"
	)" ]; then
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) skip $(MARKER) $${@} -->\\n"
		return 0
	fi
$(CAT) <<_EOF_
<li class="nav-item me-3"><ol class="breadcrumb">
_EOF_
	$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} "$${1} | keys | .[]" 2>/dev/null \\
		| while read -r FILE; do
			VAL="$$(
				$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
				| $${YQ_WRITE} "$${1}[\"$${FILE}\"]" 2>/dev/null \\
				| $(SED) "/^null$$/d"
			)"
$(CAT) <<_EOF_
<li class="breadcrumb-item">$$(
	if [ -z "$${NBSP}" ]; then $(ECHO) "$(DIVIDE)&nbsp;"; fi
)<a href="$$(
	$(ECHO) "$${VAL}" \
	| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a></li>
_EOF_
			NBSP="true"
		done
$(CAT) <<_EOF_
</ol></li>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-side ----------

# 1 $(PUBLISH)-nav-side-list 1		.variables["$(PUBLISH)-nav-left"] || .variables["$(PUBLISH)-nav-left"]

# x $(PUBLISH)-column-begin 1		true = main
# x $(PUBLISH)-column-end

function $(PUBLISH)-nav-left	{ $(PUBLISH)-nav-side "$${@}" || return 1; return 0; }
function $(PUBLISH)-nav-right	{ $(PUBLISH)-nav-side "$${@}" || return 1; return 0; }

function $(PUBLISH)-nav-side {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	$(PUBLISH)-column-begin ""		|| return 1
	$(PUBLISH)-nav-side-list "$${1}"	|| return 1
	$(PUBLISH)-column-end			|| return 1
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-side-list -----

# 1 .variables["$(PUBLISH)-nav-left"] || .variables["$(PUBLISH)-nav-left"]

# x $(PUBLISH)-nav-side-library 1	titles || authors || dates || tags
# x $(PUBLISH)-select 1+@		file path || function name + null || function arguments
# x $(PUBLISH)-spacer

function $(PUBLISH)-nav-side-list {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	SIZE="$$(
		$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} "$${1} | length" 2>/dev/null \\
		| $(SED) "/^null$$/d" \\
	)"
	NUM="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${1}[\"$${NUM}\"] -->\\n"
		TEXT="$$(
			$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
			| $${YQ_WRITE} "$${1}[\"$${NUM}\"]" 2>/dev/null \\
			| $(SED) "/^null$$/d"
		)"
		if [ "$${TEXT}" = ".library-titles" ]; then	$(PUBLISH)-nav-side-library titles	|| return 1
		elif [ "$${TEXT}" = ".library-authors" ]; then	$(PUBLISH)-nav-side-library authors	|| return 1
		elif [ "$${TEXT}" = ".library-dates" ]; then	$(PUBLISH)-nav-side-library dates	|| return 1
		elif [ "$${TEXT}" = ".library-tags" ]; then	$(PUBLISH)-nav-side-library tags	|| return 1
		elif [ "$${TEXT}" = ".contents" ]; then		$(ECHO) "$(PUBLISH_BUILD_CMD_BEG) contents $(PUBLISH_BUILD_CMD_END)\\n"
		elif [ "$${TEXT}" = ".spacer" ]; then		$(PUBLISH)-spacer			|| return 1
		elif [ "$$(
			$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
				| $${YQ_WRITE} "$${1}[\"$${NUM}\"] | keys | .[]" 2>/dev/null \\
				| $(SED) "/^null$$/d"
		)" = "text" ]; then
			$(ECHO) "\\n"
			TEXT="$$(
				$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
					| $${YQ_WRITE} "$${1}[\"$${NUM}\"].text" 2>/dev/null \\
					| $(SED) "/^null$$/d"
			)"
			$(ECHO) "$${TEXT}" \\
			| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
		else
			$(PUBLISH)-select $${TEXT} || return 1
		fi
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${1}[\"$${NUM}\"] -->\\n"
		NUM="$$($(EXPR) $${NUM} + 1)"
	done
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-side-library --

# 1 titles || authors || dates || tags

function $(PUBLISH)-library { $(PUBLISH)-nav-side-library "$${@}" || return 1; return 0; }

function $(PUBLISH)-nav-side-library {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<table class="table table-sm table-borderless align-top text-nowrap">
_EOF_
	$(CAT) $${PUBLISH_LIBRARY_INDEX} \\
		| $${YQ_WRITE} ".$${1} | keys | .[]" 2>/dev/null \\
		| $(SED) "/^null$$/d" \\
	| while read -r FILE; do
$(CAT) <<_EOF_
<tr><td><a href="$${PUBLISH_LIBRARY_INDEX_PATH}/$${1}-$$(
	$(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT "$${FILE}"
).$(EXTN_HTML)">$${FILE}</a></td><td class="text-end">$$(
	$(CAT) $${PUBLISH_LIBRARY_INDEX} \\
		| $${YQ_WRITE} ".$${1}.[\"$${FILE}\"] | length" 2>/dev/null \\
		| $(SED) "/^null$$/d" \\
)</td></tr>
_EOF_
	done
$(CAT) <<_EOF_
</table>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-begin ---------

# 1 true = top
# 2 true = brand
# 3 $(PUBLISH)-brand 1			COMPOSER_LOGO

function $(PUBLISH)-nav-begin {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<nav class="navbar navbar-expand-sm fixed-$$(
	if [ -n "$${1}" ]; then	$(ECHO) "top"
	else			$(ECHO) "bottom"
	fi
) bg-dark">
<div class="container-fluid">
<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar-fixed-$$(
	if [ -n "$${1}" ]; then	$(ECHO) "top"
	else			$(ECHO) "bottom"
	fi
)">
<span class="navbar-toggler-icon"></span>
</button>
$$(
	if [ -n "$${2}" ]; then	$(PUBLISH)-brand "$${3}" || return 1
				$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) skip $(MARKER) brand -->\\n"
	fi
)
<div class="collapse navbar-collapse" id="navbar-fixed-$$(
	if [ -n "$${1}" ]; then	$(ECHO) "top"
	else			$(ECHO) "bottom"
	fi
)">
<ul class="navbar-nav navbar-nav-scroll me-auto">
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-end -----------

# 1 $(PUBLISH)-info-data 1		top || bottom
# 2 $(PUBLISH)-search			true = search

function $(PUBLISH)-nav-end {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
</ul>
$$(
	$(PUBLISH)-info-data "$${1}" || return 1
	if [ -n "$${2}" ] && [ -n "$$(
		$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"search_name\"]" 2>/dev/null \\
		| $(SED) "/^null$$/d"
	)" ]; then
		$(PUBLISH)-search || return 1
	else
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) skip $(MARKER) search -->\\n"
	fi
)
</div>
</div>
</nav>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-row-begin ---------

function $(PUBLISH)-row-begin {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<div class="container-fluid$$(
	COPY_SAFE="$$(
		$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"copy_safe\"]" 2>/dev/null \\
		| $(SED) "/^null$$/d"
	)"
	if [ -n "$${COPY_SAFE}" ]; then
		if [ "$${COPY_SAFE}" = "1" ]; then	$(ECHO) " user-select-none"; fi
	elif [ "$${PUBLISH_COPY_SAFE}" = "1" ]; then	$(ECHO) " user-select-none"; fi
)">
<div class="d-flex flex-row flex-wrap">
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-row-end -----------

function $(PUBLISH)-row-end {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
</div>
</div>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-column-begin ------

# 1 true = main

function $(PUBLISH)-column-begin {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<div class="d-flex flex-column$$(
	if [ -n "$${1}" ]; then
		COLS_MAIN_SIZE="$$(
			$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
			| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"cols_main_size\"]" 2>/dev/null \\
			| $(SED) "/^null$$/d"
		)"
		$(ECHO) " col-sm-$$(
			if [ -n "$${COLS_MAIN_SIZE}" ]; then	$(ECHO) "$${COLS_MAIN_SIZE}"
			else					$(ECHO) "$${PUBLISH_COLS_MAIN_SIZE}"
			fi
		)"
	else
		COLS_MOBILE_HIDE="$$(
			$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
			| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"cols_mobile_hide\"]" 2>/dev/null \\
			| $(SED) "/^null$$/d"
		)"
		if [ -n "$${COLS_MOBILE_HIDE}" ]; then
			if [ "$${COLS_MOBILE_HIDE}" = "1" ]; then	$(ECHO) " d-none d-sm-block"; fi
		elif [ "$${PUBLISH_COLS_MOBILE_HIDE}" = "1" ]; then	$(ECHO) " d-none d-sm-block"; fi
	fi
)$$(
	COLS_STICKY="$$(
		$(subst $(YQ_READ),$${YQ_READ},$(subst $(COMPOSER_YML_LIST),$${COMPOSER_YML_LIST},$(COMPOSER_YML_DATA))) 2>/dev/null \\
		| $${YQ_WRITE} ".variables[\"$(PUBLISH)-config\"].[\"cols_sticky\"]" 2>/dev/null \\
		| $(SED) "/^null$$/d"
	)"
	if [ -n "$${COLS_STICKY}" ]; then
		if [ "$${COLS_STICKY}" = "1" ]; then	$(ECHO) " $(COMPOSER_TINYNAME)-sticky"; fi
	elif [ "$${PUBLISH_COLS_STICKY}" = "1" ]; then	$(ECHO) " $(COMPOSER_TINYNAME)-sticky"; fi
) p-2">
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-column-end --------

function $(PUBLISH)-column-end {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
</div>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-pane-begin --------

# 1 header level
# 2 true = expanded
# 3 title				$${@:3} = $${3}++

function $(PUBLISH)-pane-begin {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<div class="accordion">
<div class="accordion-item">
<h$${1} class="accordion-header" id="$$($(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT "$${@:3}")">
<button class="accordion-button$$(
	if [ -z "$${2//$(SPECIAL_VAL)}" ]; then $(ECHO) " collapsed"; fi
)" type="button" data-bs-toggle="collapse" data-bs-target="#toggle-$$($(ECHO) "$${@:3}" | $(SED) "s|[^[:alnum:]_-]||g")">
$${@:3}
</button>
</h$${1}>
<div id="toggle-$$($(ECHO) "$${@:3}" | $(SED) "s|[^[:alnum:]_-]||g")" class="accordion-collapse collapse$$(
	if [ -n "$${2//$(SPECIAL_VAL)}" ]; then $(ECHO) " show"; fi
)">
<div class="accordion-body">
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-pane-end ----------

function $(PUBLISH)-pane-end {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
</div>
</div>
</div>
</div>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-box-begin ---------

# 1 header level
# 2 title				$${@:2} = $${2}++

function $(PUBLISH)-box-begin {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
<div class="card">
<h$${1} class="card-header" id="$$($(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT "$${@:2}")">
$${@:2}
</h$${1}>
<div class="card-body">
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-box-end -----------

function $(PUBLISH)-box-end {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
$(CAT) <<_EOF_
</div>
</div>
_EOF_
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-spacer ------------

function $(PUBLISH)-spacer {
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	$(ECHO) "$(HTML_BREAK)\\n"
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-file --------------

#> update: YQ_WRITE.*title

# 1 file path
# @ null

# x $(PUBLISH)-select 1+@		file path || function name + null || function arguments
# x $(PUBLISH)-*

function $(PUBLISH)-file {
	TITL="$$(
		$(SED) -n "1,/^---$$/p" $${1} \\
		| $${YQ_WRITE} ".title" 2>/dev/null \\
		| $(SED) "/^null$$/d"
	)"
	if [ -z "$${TITL}" ]; then
		TITL="$$(
			$(SED) -n "1,/^---$$/p" $${1} \\
			| $(YQ_WRITE) ".pagetitle" 2>/dev/null \\
			| $(SED) "/^null$$/d"
		)"
	fi
	if [ "$${!#}" = "title-block" ]; then
		if [ -n "$${TITL}" ]; then
			$(ECHO) "---\\n"
			$(ECHO) "pagetitle: \"$${TITL}\"\\n"
			$(ECHO) "---\\n"
		fi
		$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) done $(MARKER) $${@} -->\\n"
		return 0
	fi
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) begin $(MARKER) $${@} -->\\n"
	HEAD="$$($(SED) -n "s|^$(PUBLISH_BUILD_CMD_BEG) title-block (.+) $(PUBLISH_BUILD_CMD_END)$$|\\1|gp" $${1})"
	if [ -n "$${HEAD}" ]; then
		$(ECHO) "<!-- title-block $(DIVIDE) begin $(MARKER) $${HEAD} -->\\n"
		$(PUBLISH)-$$($(ECHO) "$${HEAD}" | $(SED) "s|^([^[:space:]]+)(.+)$$|\\1-begin \\2|g") $$(
			NAME="$$(
				$(SED) "1,/^$(PUBLISH_BUILD_CMD_BEG) title-block .+ $(PUBLISH_BUILD_CMD_END)$$/p" $${1} \\
				| $${YQ_WRITE} ".author" 2>/dev/null \\
				| $(SED) "/^null$$/d"
			)"
			if [ -n "$${NAME}" ]; then
				JOIN="$$(
					$(ECHO) "$${NAME}" \\
					| $${YQ_WRITE} "join(\"; \")" 2>/dev/null \\
					| $(SED) "/^null$$/d"
				)"
				if [ -n "$${JOIN}" ]; then
					NAME="$${JOIN}"
				fi
			fi
			DATE="$$(
				$(SED) "1,/^$(PUBLISH_BUILD_CMD_BEG) title-block .+ $(PUBLISH_BUILD_CMD_END)$$/p" $${1} \\
				| $${YQ_WRITE} ".date" 2>/dev/null \\
				| $(SED) "s|[T][0-9]{2}[:][0-9]{2}[:][0-9]{2}.*$$||g" \\
				| $(SED) "/^null$$/d"
			)"
			if [ -n "$${DATE}" ]; then
				$(ECHO) "$${DATE}"
			fi
			if [ -n "$${DATE}" ] && [ -n "$${TITL}" ]; then
				$(ECHO) " $(DIVIDE) "
			fi
			if [ -n "$${TITL}" ]; then
				$(ECHO) "$${TITL}"
			fi
			if [ -n "$${NAME}" ]; then
				if [ -n "$${DATE}" ] || [ -n "$${TITL}" ]; then
					$(ECHO) " </br> "
				fi
				$(ECHO) "$${NAME}"
			fi
		) || return 1
		$(ECHO) "<!-- title-block $(DIVIDE) end $(MARKER) $${HEAD} -->\\n"
	fi
	$(ECHO) "\\n"
	if [ -n "$${HEAD}" ]; then
		$(SED) "1,/^$(PUBLISH_BUILD_CMD_BEG) title-block .+ $(PUBLISH_BUILD_CMD_END)$$/d" $${1}
	else
		if [ -n "$$(
			$(HEAD) -n1 $${1} \\
			| $(SED) -n "/^---$$/p"
		)" ]; then
			$(SED) "1,/^---$$/d" $${1}
		else
			$(CAT) $${1}
		fi
	fi \\
		| while IFS=$$'\n' read -r FILE; do
			BUILD_CMD="$${FILE}"
			BUILD_CMD="$${BUILD_CMD/#$(PUBLISH_BUILD_CMD_BEG)}"
			BUILD_CMD="$${BUILD_CMD/%$(PUBLISH_BUILD_CMD_END)}"
			if [ "$${FILE}" != "$${BUILD_CMD}" ]; then
				$(PUBLISH)-select $${BUILD_CMD} || return 1
			else
				$(PRINTF) "%s\\n" "$${FILE}"
			fi \\
			| $(SED) "s|[<]composer_root[>]|$${COMPOSER_ROOT_PATH}|g"
			if [ "$${PIPESTATUS[0]}" != "0" ]; then return 1; fi
		done \\
		|| return 1
	if [ -n "$${HEAD}" ]; then
		$(PUBLISH)-$$($(ECHO) "$${HEAD}" | $(SED) "s|^([^[:space:]]+)(.+)$$|\\1-end|g") || return 1
	fi
	$(ECHO) "<!-- $${FUNCNAME} $(DIVIDE) end $(MARKER) $${@} -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-select ------------

# 1 file path || function name
# @ null || function arguments

function $(PUBLISH)-select {
	ACTION="$${1}"; shift
	if [ -f "$${ACTION}" ]; then
		if ! $(PUBLISH)-file $${ACTION} $${@}; then
			$(ECHO) "$(MARKER) ERROR [$${0/#*\/}] (file): $${ACTION} $${@}\\n" >&2
			return 1
		fi
	else
		if ! $(PUBLISH)-$${ACTION} $${@}; then
			$(ECHO) "$(MARKER) ERROR [$${0/#*\/}]: $${ACTION} $${@}\\n" >&2
			return 1
		fi
	fi
	return 0
}

################################################################################
### {{{3 Main Script ------------------

# x $(PUBLISH)-select 1+@		file path || function name + null || function arguments

$(PUBLISH)-select $${@} || exit 1

exit 0
################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: bootstrap_css ---------

override define HEREDOC_BOOTSTRAP_CSS_HACK =
	$(SED) -i \
		-e "/^[[:space:]]+background-color[:]/d" \
		-e "/^[[:space:]]+color[:]/d"
endef

override define HEREDOC_BOOTSTRAP_CSS =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Bootstrap CSS
############################################################################# */

/* #>@import url("$(shell $(REALPATH) $(abspath $(dir $(BOOTSTRAP_CSS))) $(BOOTSTRAP_CSS_THEME))"); */

/* HEREDOC_BOOTSTRAP_CSS_HACK */

/* ########################################################################## */

body {
	padding-top:			50px;
	padding-bottom:			50px;
}

.$(COMPOSER_TINYNAME)-sticky {
	max-height:			90vh;
	overflow:			auto;
}

.$(COMPOSER_TINYNAME)-logo {
	height:				24px;
	width:				auto;
}

.$(COMPOSER_TINYNAME)-icon {
	height:				24px;
	width:				auto;
}

/* ################################## */

.accordion-button {
	color:				inherit;
	font-weight:			bold;
}

.bg-dark				{ background-color: rgba(var(--bs-dark-rgb)); }
.card-header				{ background-color: rgba(var(--bs-dark-rgb)); }
.accordion-button			{ background-color: rgba(var(--bs-dark-rgb)); }

.card					{ border: 1px solid rgba(var(--bs-secondary-rgb)); }
.accordion-item				{ border: 1px solid rgba(var(--bs-secondary-rgb)); }

.accordion-button::after			{ background-color: rgba(var(--bs-danger-rgb)); }
.accordion-button:not(.collapsed)::after	{ background-color: rgba(var(--bs-success-rgb)); }
.accordion-button:focus				{ box-shadow: 0 0 0 0.25rem rgba(var(--bs-black-rgb)); }
.accordion-button:not(.collapsed):focus		{ box-shadow: 0 0 0 0.25rem rgba(var(--bs-black-rgb)); }

/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
## {{{2 Heredoc: pdf_latex -------------

override define HEREDOC_TEX_PDF_TEMPLATE =
% ##############################################################################
% $(COMPOSER_TECHNAME) $(DIVIDE) TeX Live (PDF)
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

########################################
## {{{2 Heredoc: revealjs_css ----------

override define HEREDOC_REVEALJS_CSS =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Reveal.js CSS
############################################################################# */

/* #>@import url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(REVEALJS_CSS_THEME))"); */

/* ########################################################################## */

.reveal .slides {
	background:			url("$(shell $(REALPATH) $(abspath $(dir $(REVEALJS_CSS))) $(COMPOSER_LOGO))");
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

########################################
## {{{2 Heredoc: license ---------------

override define HEREDOC_LICENSE =
# $(COMPOSER_LICENSE)

--------------------------------------------------------------------------------

## Copyright

	$(COPYRIGHT_FULL)
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

#>override _D				:= \e[0;37m
override define COMPOSER_COLOR =
override _D				:= \e[0m
override _H				:= \e[0;32m
override _C				:= \e[0;36m
override _M				:= \e[0;33m
override _N				:= \e[0;31m
override _E				:= \e[0;35m
override _S				:= \e[0;34m
override _F				:= \e[41;37m
endef

override define COMPOSER_NOCOLOR =
override _D				:=
override _H				:=
override _C				:=
override _M				:=
override _N				:=
override _E				:=
override _S				:=
override _F				:=
endef

override define COMPOSER_SHOWCOLOR =
$(_D)_D = Default$(_D)
$(_H)_H = Header$(_D)
$(_C)_C = Configuration$(_D)
$(_M)_M = Message$(_D)
$(_N)_N = Notice$(_D)
$(_E)_E = Extra$(_D)
$(_S)_S = Syntax$(_D)
$(_F)_F = Fail$(_D)
endef

ifneq ($(COMPOSER_DOCOLOR),)
$(eval $(call COMPOSER_COLOR))
else
$(eval $(call COMPOSER_NOCOLOR))
endif

########################################

#> update: includes duplicates
override MARKER				:= >>
override DIVIDE				:= ::
override TOKEN				:= ~^~
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

########################################

override define TITLE_LN =
	if [ -n "$(c_site)" ] && [ "$(1)" != "$(DEPTH_MAX)" ]; then \
		if [ "$(1)" = "-1" ]; then \
			$(ECHO) "$(_D)\n$(_N)$(PUBLISH_BUILD_CMD_BEG) pane-begin 1 1 $(2) $(PUBLISH_BUILD_CMD_END)$(_D)\n\n"; \
		else \
			$(ECHO) "$(_D)\n$(_N)$(PUBLISH_BUILD_CMD_BEG) pane-begin $(1) $(SPECIAL_VAL) $(2) $(PUBLISH_BUILD_CMD_END)$(_D)\n\n"; \
		fi; \
	else \
		ttl_len="`$(EXPR) length '$(2)'`"; \
		ttl_len="`$(EXPR) $(COLUMNS) - 2 - $(1) - $${ttl_len}`"; \
		if [ "$(1)" -le "0" ]; then ttl_len="`$(EXPR) $${ttl_len} - 1 + $(1)`"; fi; \
		if [ "$(1)" -gt "0" ] && [ "$(1)" -le "$(HEAD_MAIN)" ]; then $(ENDOLINE); $(LINERULE); fi; \
		$(ENDOLINE); \
		$(ECHO) "$(_S)"; \
		if [ "$(1)" -le "0" ]; then $(ECHO) "#"; fi; \
		if [ "$(1)" -gt "0" ]; then $(PRINTF) "#%.0s" {1..$(1)}; fi; \
		$(ECHO) "$(_D) $(_H)$(2)$(_D) $(_S)"; \
		eval $(PRINTF) \"#%.0s\" {1..$${ttl_len}}; \
		$(ENDOLINE); \
		if [ "$(1)" -eq "0" ]; then $(ENDOLINE); $(LINERULE); fi; \
		if [ -z "$(3)" ]; then $(ENDOLINE); fi; \
	fi
endef

override define TITLE_END =
	if [ -n "$(c_site)" ]; then \
		$(ECHO) "$(_D)\n$(_N)$(PUBLISH_BUILD_CMD_BEG) pane-end $(PUBLISH_BUILD_CMD_END)$(_D)\n\n"; \
	fi
endef

################################################################################
# {{{1 Composer Headers --------------------------------------------------------
################################################################################

########################################
## {{{2 .set_title ---------------------

#> grep -E "[.]set_title" Makefile
.PHONY: .set_title-%
.set_title-%:
ifneq ($(COMPOSER_DOCOLOR),)
	@$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
else
	@$(ECHO) ""
endif

########################################
## {{{2 $(HEADERS) ---------------------

#> update: COMPOSER_OPTIONS
ifneq ($(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),)
override COMPOSER_DEBUGIT		:= $(SPECIAL_VAL)
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif
ifneq ($(COMPOSER_DEBUGIT_ALL),)
override $(HEADERS)-list		:= $(COMPOSER_OPTIONS)
override $(HEADERS)-vars		:= $($(HEADERS)-list)
else
override $(HEADERS)-head := \
	MAKEFILE_LIST \
	COMPOSER_INCLUDES \
	COMPOSER_YML_LIST \
	COMPOSER_LIBRARY \
	CURDIR
override $(HEADERS)-list := \
	COMPOSER_INCLUDE \
	COMPOSER_DEPENDS \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_IGNORES
#> update: $(HEADERS)-vars
override $(HEADERS)-vars := \
	c_site \
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
override $(HEADERS)-release = $(patsubst $(abspath $(dir $(COMPOSER_DIR)))%,...%,$(1))
else
override $(HEADERS)-release = $(1)
endif

.PHONY: $(HEADERS)
$(HEADERS): .set_title-$(HEADERS)
$(HEADERS): $(NOTHING)-$(NOTHING)-$(TARGETS)-$(HEADERS)
$(HEADERS):
	@$(ECHO) ""

########################################
### {{{3 $(HEADERS)-$(EXAMPLE) ---------

.PHONY: $(HEADERS)-$(EXAMPLE)
$(HEADERS)-$(EXAMPLE): .set_title-$(HEADERS)-$(EXAMPLE)
$(HEADERS)-$(EXAMPLE):
ifneq ($(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),)
	@$(foreach FILE,-1 0 1 2 3,\
		$(call TITLE_LN ,$(FILE),TITLE: $(FILE) / x)	; $(PRINT) "$(EXAMPLE)"; \
		$(call TITLE_LN ,$(FILE),TITLE: $(FILE) / 1,1)	; $(PRINT) "$(EXAMPLE)"; \
	)
endif
	@$(call $(HEADERS))
	@$(call $(HEADERS),1)
	@$(call $(HEADERS)-run)
	@$(call $(HEADERS)-run,1)
ifneq ($(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),)
	@$(call $(HEADERS)-$(COMPOSER_PANDOC),$(@))
	@$(LINERULE)
endif
	@$(call $(HEADERS)-note,$(CURDIR),$(TESTING))
	@$(call $(HEADERS)-dir,$(CURDIR),directory)
	@$(call $(HEADERS)-file,$(CURDIR),creating)
	@$(call $(HEADERS)-skip,$(CURDIR),skipping)
	@$(call $(HEADERS)-rm,$(CURDIR),removing)

########################################
### {{{3 $(HEADERS)-% ------------------

.PHONY: $(HEADERS)-%
$(HEADERS)-%:
	@$(call $(HEADERS),,$(*))

.PHONY: $(HEADERS)-run-%
$(HEADERS)-run-%:
	@$(call $(HEADERS)-run,,$(*))

override define $(HEADERS) =
	$(HEADER_L); \
	$(TABLE_C2) "$(_H)$(COMPOSER_FULLNAME)"	"[$(_N)$(call $(HEADERS)-release,$(COMPOSER_DIR))$(_D)]"; \
	$(TABLE_C2) "---"			"---"; \
	$(foreach FILE,$($(HEADERS)-head),\
		$(TABLE_C2) "$(_E)$(FILE)"	"[$(_N)$(call $(HEADERS)-release,$($(FILE)))$(_D)]"; \
	) \
	$(TABLE_C2) "$(_E)MAKECMDGOALS"		"[$(_N)$(MAKECMDGOALS)$(_D)] ($(_M)$(strip $(if $(2),$(2),$(@))$(if $(COMPOSER_DOITALL_$(if $(2),$(2),$(@))),$(_D)-$(_E)$(COMPOSER_DOITALL_$(if $(2),$(2),$(@))))$(_D)))"; \
	$(TABLE_C2) "$(_E)MAKELEVEL"		"[$(_N)$(MAKELEVEL)$(_D)]"; \
	$(foreach FILE,$(if $(COMPOSER_DEBUGIT_ALL),$($(HEADERS)-list),$(if $(1),$($(HEADERS)-list))),\
		$(TABLE_C2) "$(_C)$(FILE)"	"[$(_M)$(strip $(if \
			$(filter c_list,$(FILE)),$(if $(c_list_plus),$(c_list_plus),$(c_list)) ,$(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		)))$(_D)]$(if $(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)), $(_E)$(MARKER)$(_D))"; \
	) \
	$(HEADER_L)
endef

#> update: $(HEADERS)-run
override define $(HEADERS)-run =
	$(LINERULE); \
	$(TABLE_M2) "$(_H)$(COMPOSER_FULLNAME)"	"$(_N)$(call $(HEADERS)-release,$(COMPOSER_DIR))"; \
	$(TABLE_M2) ":---"			":---"; \
	$(foreach FILE,$($(HEADERS)-head),\
		$(TABLE_M2) "$(_E)$(FILE)"	"$(_N)$(call $(HEADERS)-release,$($(FILE)))"; \
	) \
	$(TABLE_M2) "$(_E)MAKECMDGOALS"		"$(_N)$(MAKECMDGOALS)$(_D) ($(_M)$(strip $(if $(2),$(2),$(@))$(if $(COMPOSER_DOITALL_$(if $(2),$(2),$(@))),$(_D)-$(_E)$(COMPOSER_DOITALL_$(if $(2),$(2),$(@))))$(_D)))"; \
	$(TABLE_M2) "$(_E)MAKELEVEL"		"$(_N)$(MAKELEVEL)"; \
	$(foreach FILE,$(if $(COMPOSER_DEBUGIT_ALL),$($(HEADERS)-vars),$(if $(1),$($(HEADERS)-vars))),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$(strip $(if \
			$(filter c_list,$(FILE)),$(if $(c_list_plus),$(c_list_plus),$(c_list)) ,$(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		)))$(_D)$(if $(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)),$(if $(strip $(if \
			$(filter c_list,$(FILE)),$(if $(c_list_plus),$(c_list_plus),$(c_list)) ,$(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		))), )$(_E)$(MARKER)$(_D))"; \
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
	$(TABLE_M2) "$(_M)$(MARKER) Processing" "$(_E)$(call $(HEADERS)-release,$(1))$(_D) $(DIVIDE) [$(_C)$(if $(3),$(3),$(@))$(_D)] $(_C)$(2)"
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
## {{{2 .DEFAULT -----------------------

.DEFAULT_GOAL := $(DOITALL)
ifneq ($(COMPOSER_RELEASE),)
.DEFAULT_GOAL := $(HELPOUT)
endif

.DEFAULT:
	@$(call $(HEADERS))											>&2
	@$(LINERULE)												>&2
	@$(PRINT) "$(_H)$(MARKER) ERROR"									>&2
	@$(ENDOLINE)												>&2
	@$(PRINT) "  * $(_N)Target '$(_C)$(@)$(_N)' is not defined"						>&2
	@$(ENDOLINE)												>&2
	@$(PRINT) "$(_H)$(MARKER) DETAILS"									>&2
	@$(ENDOLINE)												>&2
	@$(PRINT) "  * This may be the result of a missing input file"						>&2
	@$(PRINT) "  * New targets can be defined in '$(_M)$(COMPOSER_SETTINGS)$(_D)'"				>&2
	@$(PRINT) "  * Use '$(_C)$(TARGETS)$(_D)' to get a list of available targets"				>&2
	@$(PRINT) "  * See '$(_C)$(HELPOUT)$(_D)' or '$(_C)$(HELPOUT)-$(DOITALL)$(_D)' for more information"	>&2
	@$(LINERULE)												>&2
	@exit 1

########################################
## {{{2 $(MAKE_DB) ---------------------

.PHONY: $(MAKE_DB)
$(MAKE_DB):
	@$(MAKE) \
		$(SILENT) \
		--question \
		--print-data-base \
		--no-builtin-rules \
		--no-builtin-variables \
	|| $(TRUE)

########################################
## {{{2 $(LISTING) ---------------------

.PHONY: $(LISTING)
$(LISTING):
	@$(MAKE) $(SILENT) $(MAKE_DB) \
		| $(SED) -n -e "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" \
		| $(SED) -n -e "/^$(COMPOSER_REGEX_PREFIX)?$(COMPOSER_REGEX)[:]+/p" \
		| $(SORT)

########################################
## {{{2 $(NOTHING) ---------------------

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

.PHONY: $(NOTHING)
$(NOTHING): $(NOTHING)-$(NOTHING)-$(TARGETS)-$(NOTHING)
$(NOTHING):
	@$(ECHO) ""

.PHONY: $(NOTHING)-%
$(NOTHING)-%:
ifeq ($(COMPOSER_DEBUGIT),)
	@$(if $(filter $(*),$(NOTHING_IGNORES)),\
		$(ECHO) "" ,\
		$(call $(HEADERS)-note,$(CURDIR),$(*),$(NOTHING)) \
	)
else
	@$(call $(HEADERS)-note,$(CURDIR),$(*),$(NOTHING))
endif

################################################################################
# {{{1 Debug Targets -----------------------------------------------------------
################################################################################

########################################
## {{{2 $(DEBUGIT) ---------------------

#> update: PHONY.*$(DEBUGIT)
#	$(CONFIGS)
#	$(TARGETS)

ifneq ($(filter $(DEBUGIT)-file,$(MAKECMDGOALS)),)
export override COMPOSER_DOITALL_$(DEBUGIT) := file
export override DEBUGIT_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(DEBUGIT))
endif
.PHONY: $(DEBUGIT)-file
$(DEBUGIT)-file: .set_title-$(DEBUGIT)-file
$(DEBUGIT)-file: $(HEADERS)-$(DEBUGIT)
$(DEBUGIT)-file: $(DEBUGIT)-$(HEADERS)
$(DEBUGIT)-file:
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) Printing to file$(_D) $(DIVIDE) $(_M)$(notdir $(DEBUGIT_FILE))"
	@$(PRINT) "$(_H)$(MARKER) This may take a few minutes..."
	@$(ENDOLINE)
	@$(ECHO) "# $(VIM_OPTIONS)\n" >$(DEBUGIT_FILE)
	@$(MAKE) \
		COMPOSER_DOITALL_$(DEBUGIT)="$(COMPOSER_DOITALL_$(DEBUGIT))" \
		COMPOSER_DOITALL_$(TESTING)="$(DEBUGIT)" \
		COMPOSER_DOCOLOR= \
		COMPOSER_DEBUGIT="$(COMPOSER_DEBUGIT)" \
		$(DEBUGIT) 2>&1 \
		| $(TEE) --append $(DEBUGIT_FILE) \
		| $(SED) "s|^.*$$||g" \
		| $(TR) '\n' '.'
	@$(TAIL) -n10 $(DEBUGIT_FILE)
	@$(LS) $(DEBUGIT_FILE)

#> update: $(DEBUGIT): targets list
.PHONY: $(DEBUGIT)
ifneq ($(filter $(DEBUGIT),$(MAKECMDGOALS)),)
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
$(DEBUGIT): $(DEBUGIT)-COMPOSER_YML_LIST
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
		$(call TITLE_LN ,1,$(MARKER)[ $(*) $(DIVIDE) $(FILE) ]$(MARKER) $(VIM_FOLDING)); \
		if [ "$(*)" = "COMPOSER_DEBUGIT" ]; then \
			$(MAKE) --just-print COMPOSER_DOCOLOR= COMPOSER_DEBUGIT="$(SPECIAL_VAL)" $(FILE) 2>&1; \
		elif [ -d "$(FILE)" ]; then \
			$(LS) --recursive $(FILE); \
		elif [ -f "$(FILE)" ]; then \
			$(CAT) $(FILE); \
		else \
			$(MAKE) COMPOSER_DEBUGIT= $(FILE) 2>&1; \
		fi; \
	)

########################################
## {{{2 $(TESTING) ---------------------

ifneq ($(filter $(TESTING)-file,$(MAKECMDGOALS)),)
export override COMPOSER_DOITALL_$(TESTING) := file
export override TESTING_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(TESTING))
endif
.PHONY: $(TESTING)-file
$(TESTING)-file: .set_title-$(TESTING)
$(TESTING)-file: $(HEADERS)-$(TESTING)
$(TESTING)-file: $(TESTING)-$(HEADERS)
$(TESTING)-file:
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) Printing to file$(_D) $(DIVIDE) $(_M)$(notdir $(TESTING_FILE))"
	@$(PRINT) "$(_H)$(MARKER) This may take a few minutes..."
	@$(ENDOLINE)
	@$(ECHO) "# $(VIM_OPTIONS)\n" >$(TESTING_FILE)
	@$(MAKE) \
		COMPOSER_DOITALL_$(TESTING)="$(COMPOSER_DOITALL_$(TESTING))" \
		COMPOSER_DOCOLOR= \
		$(TESTING) 2>&1 \
		| $(TEE) --append $(TESTING_FILE) \
		| $(SED) "s|^.*$$||g" \
		| $(TR) '\n' '.'
	@$(TAIL) -n10 $(TESTING_FILE)
	@$(LS) $(TESTING_FILE)

#> update: $(TESTING): targets list
.PHONY: $(TESTING)
ifneq ($(filter $(TESTING),$(MAKECMDGOALS)),)
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
	@$(PRINT) "  * All cases are run in the '$(_M)$(patsubst $(COMPOSER_DIR)/%,%,$(TESTING_DIR))$(_D)' directory"
	@$(PRINT) "  * It has a dedicated '$(_M)$(TESTING_COMPOSER_DIR)$(_D)', and '$(_C)$(DOMAKE)$(_D)' can be run anywhere in the tree"
	@$(PRINT) "  * Use '$(_C)$(TESTING)-file$(_D)' to create a text file with the results"
	@$(LINERULE)

.PHONY: $(TESTING)-$(HEADERS)-%
$(TESTING)-$(HEADERS)-%:
	@$(call TITLE_LN ,1,$(MARKER)[ $($(patsubst $(TESTING)-$(HEADERS)-%,%,$(@))) ]$(MARKER) $(VIM_FOLDING))
	@$(MAKE) $($(patsubst $(TESTING)-$(HEADERS)-%,%,$(@))) 2>&1

########################################
### {{{3 $(TESTING)-functions ----------

override TESTING_LOGFILE		:= .$(COMPOSER_BASENAME).$(TESTING).log
override TESTING_COMPOSER_DIR		:= .$(COMPOSER_BASENAME)
override TESTING_COMPOSER_MAKEFILE	:= $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE)
override TESTING_ENV_MAKE		:= $(ENV) \
	MAKEJOBS="$(MAKEJOBS)" \
	COMPOSER_DOCOLOR="$(COMPOSER_DOCOLOR)" \
	COMPOSER_DEBUGIT="$(COMPOSER_DEBUGIT)" \
	$(REALMAKE)

override $(TESTING)-pwd			= $(abspath $(TESTING_DIR)/$(patsubst %-init,%,$(patsubst %-done,%,$(if $(1),$(1),$(@)))))
override $(TESTING)-log			= $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(TESTING_LOGFILE)
override $(TESTING)-make		= $(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(MAKEFILE),-$(INSTALL),$(2),1)
override $(TESTING)-run			= $(TESTING_ENV_MAKE) --directory $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))

override define $(TESTING)-$(HEADERS) =
	$(call TITLE_LN ,1,$(MARKER)[ $(patsubst $(TESTING)-%,%,$(@)) ]$(MARKER) $(VIM_FOLDING));
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
	$(call $(TESTING)-make,$(if $(1),$(1),$(@))); \
	$(call $(TESTING)-run,$(if $(1),$(1),$(@))) $(CREATOR); \
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
	$(TESTING_ENV_MAKE) $(@)-init 2>&1 | $(TEE) $(call $(TESTING)-log,$(if $(1),$(1),$(@))); \
	if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
endef

override define $(TESTING)-done =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) DONE [$(@)]"; \
	$(TESTING_ENV_MAKE) $(@)-done 2>&1
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
### {{{3 $(TESTING)-Think --------------

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
	@$(call $(TESTING)-make,/,$(TESTING_COMPOSER_MAKEFILE))
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS),,,1)
	@$(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS),,,1)
	@$(call $(TESTING)-run) --makefile $(TESTING_COMPOSER_MAKEFILE) $(INSTALL)-$(DOFORCE)
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
### {{{3 $(TESTING)-$(DISTRIB) ---------

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
	@$(LS) \
		$(PANDOC_DIR)/$(PANDOC_LNX_BIN) \
		$(PANDOC_DIR)/$(PANDOC_WIN_BIN) \
		$(PANDOC_DIR)/$(PANDOC_MAC_BIN) \
		$(YQ_DIR)/$(YQ_LNX_BIN) \
		$(YQ_DIR)/$(YQ_WIN_BIN) \
		$(YQ_DIR)/$(YQ_MAC_BIN)
	@$(call $(TESTING)-hold)

########################################
### {{{3 $(TESTING)-speed --------------

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
	$(MKDIR) $(call $(TESTING)-pwd); \
	$(call DO_HEREDOC,HEREDOC_COMPOSER_YML,1)				>$(call $(TESTING)-pwd)/$(COMPOSER_YML); \
	for TLD in {1..3}; do \
		$(call $(TESTING)-speed-init-load,$(call $(TESTING)-pwd)/tld$${TLD}); \
		$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML))	>$(call $(TESTING)-pwd)/tld$${TLD}/$(COMPOSER_YML); \
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
	@$(ECHO) "override COMPOSER_INCLUDE := 1\n" >$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS)
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(INSTALL)-$(DOFORCE)
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(PUBLISH)-$(DOFORCE)
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(CLEANER)-$(DOITALL)
	@time $(call $(TESTING)-run) MAKEJOBS="$(MAKEJOBS)" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-speed-done
$(TESTING)-speed-done:
	@$(TABLE_M2) "$(_H)$(MARKER) Directories"	"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type d | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Files"		"$(_C)$(shell $(FIND) $(call $(TESTING)-pwd) -type f | $(SED) -n "/.+$(subst .,[.],$(COMPOSER_EXT_DEFAULT))$$/p" | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Output"		"$(_C)$(shell $(SED) -n "/Creating/p" $(call $(TESTING)-log) | $(WC))"
	@$(call $(TESTING)-find,MAKECMDGOALS)
	@$(call $(TESTING)-find,[0-9]s$$)
	@$(call $(TESTING)-hold)

########################################
### {{{3 $(TESTING)-$(COMPOSER_BASENAME)

#WORK COMPOSER_YML

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING)-$(COMPOSER_BASENAME): $(TESTING)-Think
$(TESTING)-$(COMPOSER_BASENAME):
	@$(call $(TESTING)-$(HEADERS),\
		Basic '$(_C)$(COMPOSER_BASENAME)$(_D)' functionality ,\
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
	#> precedence
	@$(call $(TESTING)-run) MAKEJOBS="1000" c_jobs="100" J="10" $(CONFIGS)
	@$(call $(TESTING)-run) c_jobs="100" J="10" $(CONFIGS)
	@$(call $(TESTING)-run) J="10" $(CONFIGS)
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
	#> precedence
	$(call $(TESTING)-count,1,MAKEJOBS.+1000)
	$(call $(TESTING)-count,1,MAKEJOBS.+100[^0])
	$(call $(TESTING)-count,1,MAKEJOBS.+10[^0])
	#> input
	$(call $(TESTING)-find,Creating.+$(OUT_README)$(COMPOSER_EXT_DEFAULT).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Creating.+$(OUT_MANUAL).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,1,$(COMPOSER_LICENSE))
	#> margins
	$(call $(TESTING)-count,16,\|.+c_margin)
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
	$(call $(TESTING)-count,1,Processing.+$(NOTHING).+$(NOTHING)-$(TARGETS))
	$(call $(TESTING)-count,1,Processing.+$(NOTHING).+$(NOTHING)-$(SUBDIRS))

########################################
### {{{3 $(TESTING)-$(TARGETS) ---------

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
### {{{3 $(TESTING)-$(INSTALL) ---------

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
	$(call $(TESTING)-find,Processing.+$(NOTHING).+$(MAKEFILE))
	@$(call $(TESTING)-hold)

########################################
### {{{3 $(TESTING)-$(CLEANER)-$(DOITALL)

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
### {{{3 $(TESTING)-COMPOSER_INCLUDE ---

#WORK COMPOSER_YML

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
		\n\t * Check '$(_C)COMPOSER_MY_PATH$(_D)' variable \
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
	$(ECHO) "ifeq (\$$(COMPOSER_MY_PATH),\$$(CURDIR))\n"	>>$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(ECHO) "\$$(info COMPOSER_MY_PATH)\n"			>>$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(ECHO) "endif\n"					>>$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_INCLUDES/p"; \
	$(CAT) \
		$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS) \
		$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS) \
		$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
endef

override define $(TESTING)-COMPOSER_INCLUDE-done =
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n \
		-e "/COMPOSER_MY_PATH/p" \
		-e "/COMPOSER_DEPENDS/p" \
		-e "/c_css/p" \
		; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_CSS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n \
		-e "/COMPOSER_MY_PATH/p" \
		-e "/COMPOSER_DEPENDS/p" \
		-e "/c_css/p" \
		; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(RM) $(call $(TESTING)-pwd,/)/$(COMPOSER_CSS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n \
		-e "/COMPOSER_MY_PATH/p" \
		-e "/COMPOSER_DEPENDS/p" \
		-e "/c_css/p" \
		; \
	$(SED) -i "/COMPOSER_DEPENDS/d" $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS); \
	$(RM) $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_CSS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n \
		-e "/COMPOSER_MY_PATH/p" \
		-e "/COMPOSER_DEPENDS/p" \
		-e "/c_css/p" \
		; \
	$(call $(TESTING)-run,/) $(CONFIGS) | $(SED) -n \
		-e "/COMPOSER_MY_PATH/p"
endef

.PHONY: $(TESTING)-COMPOSER_INCLUDE-done
$(TESTING)-COMPOSER_INCLUDE-done:
	$(call $(TESTING)-count,2,\|.+COMPOSER_DEPENDS.+$(subst /,.,$(call $(TESTING)-pwd)))
	$(call $(TESTING)-count,3,\|.+c_css.+$(subst /,\/,$(call $(TESTING)-pwd)/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,1,\|.+COMPOSER_DEPENDS.+$(subst /,.,$(call $(TESTING)-pwd,/))$(if $(COMPOSER_DOCOLOR),[^/],$$))
	$(call $(TESTING)-count,2,\|.+c_css.+$(subst /,\/,$(call $(TESTING)-pwd,/)/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,3,\|.+COMPOSER_DEPENDS.+$(subst /,.,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))))
	$(call $(TESTING)-count,4,\|.+c_css.+$(subst /,\/,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)/$(COMPOSER_CSS))))
	$(call $(TESTING)-count,2,^COMPOSER_MY_PATH)

########################################
### {{{3 $(TESTING)-COMPOSER_DEPENDS ---

.PHONY: $(TESTING)-COMPOSER_DEPENDS
$(TESTING)-COMPOSER_DEPENDS: $(TESTING)-Think
$(TESTING)-COMPOSER_DEPENDS:
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_DEPENDS$(_D)' behavior ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
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
	@$(ECHO) "$(sort \
		$(filter-out $(DOITALL)-$(SUBDIRS)-docx,\
		$(filter-out $(DOITALL)-$(SUBDIRS)-templates,\
		$(addprefix $(DOITALL)-$(SUBDIRS)-,\
		$(notdir \
		$(patsubst %/.,%,$(wildcard $(addsuffix /.,$(call $(TESTING)-pwd)/data/*))) \
		))))): $(DOITALL)-$(SUBDIRS)-docx\n" \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) MAKEJOBS="$(SPECIAL_VAL)" $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-done
$(TESTING)-COMPOSER_DEPENDS-done:
	$(call $(TESTING)-find,$(notdir $(call $(TESTING)-pwd))\/data)
	@$(call $(TESTING)-hold)

########################################
### {{{3 $(TESTING)-COMPOSER_IGNORES ---

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
### {{{3 $(TESTING)-$(COMPOSER_LOG)$(COMPOSER_EXT)

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
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(patsubst .%,%,$(COMPOSER_LOG_DEFAULT))$(COMPOSER_EXT_DEFAULT)
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_LOG_DEFAULT)
	@$(call $(TESTING)-run) $(PRINTER)

.PHONY: $(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)-done
$(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)-done:
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Removing.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Processing.+$(NOTHING).+COMPOSER_LOG)
	$(call $(TESTING)-find,Processing.+$(NOTHING).+COMPOSER_EXT)
	$(call $(TESTING)-find, $(subst .,[.],$(COMPOSER_LOG_DEFAULT))$$)
	$(call $(TESTING)-find, $(patsubst .%,%,$(COMPOSER_LOG_DEFAULT))$(subst .,[.],$(COMPOSER_EXT_DEFAULT))$$)

########################################
### {{{3 $(TESTING)-CSS ----------------

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
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_CSS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_HTML)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_PRES); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_PRES)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(patsubst $(COMPOSER_DIR)%,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))%,$(REVEALJS_CSS))" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(CSS_ALT)" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_CSS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override c_css := $(patsubst $(COMPOSER_DIR)%,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))%,$(MDVIEWER_CSS_ALT))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "$(OUT_README).$(EXTN_EPUB): override c_css := $(patsubst $(COMPOSER_DIR)%,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))%,$(REVEALJS_CSS))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)

.PHONY: $(TESTING)-CSS-done
$(TESTING)-CSS-done:
	$(call $(TESTING)-count,2,$(notdir $(MDVIEWER_CSS)))
	$(call $(TESTING)-count,6,$(notdir $(REVEALJS_CSS)))
	$(call $(TESTING)-count,6,$(notdir $(REVEALJS_CSS)))
	$(call $(TESTING)-count,6,$(notdir $(MDVIEWER_CSS_ALT)))
	$(call $(TESTING)-count,1,c_css[^/]+$$)
	$(call $(TESTING)-count,2,$(notdir $(COMPOSER_CSS)))
	$(call $(TESTING)-count,6,$(notdir $(MDVIEWER_CSS_ALT)))
	$(call $(TESTING)-count,6,$(notdir $(REVEALJS_CSS)))

########################################
### {{{3 $(TESTING)-other --------------

.PHONY: $(TESTING)-other
$(TESTING)-other: $(TESTING)-Think
$(TESTING)-other:
	@$(call $(TESTING)-$(HEADERS),\
		Miscellaneous test cases ,\
		\n\t * Check binary files \
		\n\t * Repository versions variables \
		\n\t * Use '$(_C).$(TARGETS)$(_D)' in '$(_C)COMPOSER_TARGETS$(_D)' \
		\n\t\t * Automatic '$(_C)c_list$(_D)' in '$(_C)$(COMPOSER_SETTINGS)$(_D)' \
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
	@$(ECHO) "override COMMONMARK_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override BOOTSTRAP_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override BOOTSWATCH_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override MDVIEWER_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override REVEALJS_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CHECKIT)
	@$(ECHO) "override PANDOC_VER := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override YQ_VER := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CHECKIT)
	#> targets
	@$(ECHO) "override COMPOSER_TARGETS := .$(TARGETS) $(OUT_MANUAL).$(EXTN_LPDF)\n" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(OUT_MANUAL).$(EXTN_LPDF):" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_README)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(CAT) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(DOITALL)
ifeq ($(OS_TYPE),Linux)
	@$(LESS_BIN) $(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_LPDF) \
		| $(SED) -n \
			-e "/$(COMPOSER_HEADLINE)/p" \
			-e "/$(COMPOSER_LICENSE)/p"
endif
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
	$(call $(TESTING)-count,32,$(NOTHING))
	$(call $(TESTING)-count,6,$(notdir $(PANDOC_BIN)))
	$(call $(TESTING)-count,1,$(notdir $(YQ_BIN)))
	#> targets
	$(call $(TESTING)-count,4,MAKECMDGOALS.+$(COMPOSER_PANDOC))
ifeq ($(OS_TYPE),Linux)
	$(call $(TESTING)-count,1,$(COMPOSER_HEADLINE))
	$(call $(TESTING)-count,10,$(COMPOSER_LICENSE))
endif
	#> pandoc
	$(call $(TESTING)-find,pandoc-api-version)
	#> git
	$(call $(TESTING)-find,$(COMPOSER_FULLNAME).+$(COMPOSER_BASENAME)@example.com)

########################################
### {{{3 $(TESTING)-$(EXAMPLE) ---------

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
	@$(call $(TESTING)-run) COMPOSER_DOCOLOR= $(NOTHING)-$(notdir $(call $(TESTING)-pwd))

.PHONY: $(TESTING)-$(EXAMPLE)-done
$(TESTING)-$(EXAMPLE)-done:
	$(call $(TESTING)-find,Processing.+$(NOTHING)$$)
	$(call $(TESTING)-find,Processing.+$(TESTING)-$(EXAMPLE)$$)
#>	@$(call $(TESTING)-hold)

########################################
## {{{2 $(CHECKIT) ---------------------

override PANDOC_CMT_DISPLAY := $(PANDOC_CMT)
override YQ_CMT_DISPLAY := $(YQ_CMT)
ifneq ($(PANDOC_CMT),$(PANDOC_VER))
override PANDOC_CMT_DISPLAY := $(PANDOC_CMT)$(_D) ($(_N)$(PANDOC_VER)$(_D))
endif
ifneq ($(patsubst v%,%,$(YQ_CMT)),$(YQ_VER))
override YQ_CMT_DISPLAY := $(YQ_CMT)$(_D) ($(_N)$(YQ_VER)$(_D))
endif

#> update: Tooling Versions
.PHONY: $(CHECKIT)
$(CHECKIT): .set_title-$(CHECKIT)
$(CHECKIT):
	@$(call $(HEADERS))
	@$(TABLE_M3) "$(_H)Repository"			"$(_H)Commit"				"$(_H)License"
	@$(TABLE_M3) ":---"				":---"					":---"
	@$(TABLE_M3) "$(_E)[Pandoc]"			"$(_E)$(PANDOC_CMT_DISPLAY)"		"$(_N)$(PANDOC_LIC)"
	@$(TABLE_M3) "$(_E)[YQ]"			"$(_E)$(YQ_CMT_DISPLAY)"		"$(_N)$(YQ_LIC)"
	@$(TABLE_M3) "$(_E)[CommonMark]"		"$(_E)$(COMMONMARK_CMT)"		"$(_N)$(COMMONMARK_LIC)"
	@$(TABLE_M3) "$(_E)[Bootstrap]"			"$(_E)$(BOOTSTRAP_CMT)"			"$(_N)$(BOOTSTRAP_LIC)"
	@$(TABLE_M3) "$(_E)[Bootswatch]"		"$(_E)$(BOOTSWATCH_CMT)"		"$(_N)$(BOOTSWATCH_LIC)"
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
## {{{2 $(CONFIGS) ---------------------

#> update: COMPOSER_OPTIONS
#> update: $(HEADERS)-run

.PHONY: $(CONFIGS)
$(CONFIGS): .set_title-$(CONFIGS)
$(CONFIGS):
	@$(call $(HEADERS))
	@$(TABLE_M2) "$(_H)Variable"		"$(_H)Value"
	@$(TABLE_M2) ":---"			":---"
	@$(foreach FILE,$(COMPOSER_OPTIONS),\
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$(strip $(if \
			$(filter c_list,$(FILE)),$(if $(c_list_plus),$(c_list_plus),$(c_list)) ,$(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		)))$(_D)$(if $(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)),$(if $(strip $(if \
			$(filter c_list,$(FILE)),$(if $(c_list_plus),$(c_list_plus),$(c_list)) ,$(if \
			$(filter c_css,$(FILE)),$(call c_css_select) ,\
			$(subst ",\",$($(FILE))) \
		))), )$(_E)$(MARKER)$(_D))"; \
	)
ifneq ($(COMPOSER_YML_LIST),)
	@$(LINERULE)
	@$(COMPOSER_YML_DATA) | $(YQ_WRITE_OUT)
endif
ifeq ($(COMPOSER_LIBRARY),$(CURDIR))
	@$(LINERULE)
ifneq ($(wildcard $($(PUBLISH)-library-index)),)
	@$(CAT) $($(PUBLISH)-library-index) | $(YQ_WRITE_OUT) "del(.\".Composer\") | (.[] |= .null)"
else
	@$(call $(HEADERS)-note,$(CURDIR),$(patsubst $(CURDIR)/%,%,$($(PUBLISH)-library-index)),$(NOTHING))
endif
endif
ifeq ($(COMPOSER_DOITALL_$(CONFIGS)),$(DOITALL))
	@$(LINERULE)
	@$(subst $(NULL) - , ,$(ENV)) | $(SORT)
endif

########################################
## {{{2 $(TARGETS) ---------------------

.PHONY: $(TARGETS)
$(TARGETS): .set_title-$(TARGETS)
$(TARGETS):
	@$(call $(HEADERS))
#>	@$(LINERULE)
	@$(foreach FILE,$(shell $(strip $(call $(TARGETS)-$(PRINTER)))),\
		$(PRINT) "$(_M)$(subst : ,$(_D) $(DIVIDE) $(_C),$(subst ",\",$(subst $(TOKEN), ,$(FILE))))"; \
	)
	@$(LINERULE)
	@$(PRINT) "$(_H)$(MARKER) $(CLEANER)"; $(strip $(call $(TARGETS)-$(PRINTER),$(CLEANER)))	| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(DOITALL)"; $(strip $(call $(TARGETS)-$(PRINTER),$(DOITALL)))	| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(TARGETS)"; $(ECHO) "$(COMPOSER_TARGETS)"				| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(PRINT) "$(_H)$(MARKER) $(SUBDIRS)"; $(ECHO) "$(COMPOSER_SUBDIRS)"				| $(SED) "s|[ ]+|\n|g" | $(SORT)
	@$(LINERULE)
	@$(MAKE) $(SILENT) $(PRINTER)-$(PRINTER)

override define $(TARGETS)-$(PRINTER) =
	$(MAKE) $(SILENT) $(LISTING) | $(SED) \
		-e "/^$(MAKEFILE)[:]/d" \
		-e "/^$(COMPOSER_REGEX_PREFIX)/d" \
		$(if $(COMPOSER_EXT),-e "/^[^:]+$(subst .,[.],$(COMPOSER_EXT))[:]/d") \
		$(if $(c_site),-e "s|$($(PUBLISH)-cache)||g") \
		$(if $(c_site),-e "s|$($(PUBLISH)-library)||g") \
		$(if $(1),-e "/^$(HEADERS)[-]$(1)[:]+.*$$/d",$(foreach FILE,$(COMPOSER_RESERVED),-e "/^$(FILE)[:-]/d")) \
		$(if $(1),,-e "/^[^:]+[-]$(CLEANER)[:]+.*$$/d") \
		$(if $(1),,-e "/^[^:]+[-]$(DOITALL)[:]+.*$$/d") \
		-e "s|[:]+[[:space:]]*$$||g" \
		-e "s|[[:space:]]+|$(TOKEN)|g" \
		$(if $(1),| $(SED) -n "/^[^:]+[-]$(1)$$/p")
endef

################################################################################
# {{{1 Release Targets ---------------------------------------------------------
################################################################################

########################################
## {{{2 $(CONVICT) ---------------------

override GIT_OPTS_CONVICT		:= --verbose $(if \
	$(filter $(PRINTER),$(COMPOSER_DOITALL_$(CONVICT))) ,\
	$(addprefix .$(patsubst $(COMPOSER_ROOT)%,%,$(CURDIR))/,$(c_list)) ,\
	$(addprefix .,$(patsubst $(COMPOSER_ROOT)%,%,$(CURDIR))/) \
)

.PHONY: $(CONVICT)
$(CONVICT): .set_title-$(CONVICT)
$(CONVICT):
	@$(call $(HEADERS))
	$(call GIT_RUN_COMPOSER,add --all $(GIT_OPTS_CONVICT))
	$(call GIT_RUN_COMPOSER,commit \
		$(if $(filter $(DOITALL),$(COMPOSER_DOITALL_$(CONVICT))),,--edit) \
		--message="$(call COMPOSER_TIMESTAMP)" \
		$(GIT_OPTS_CONVICT) \
	)

########################################
## {{{2 $(DISTRIB) ---------------------

#> update: PHONY.*$(DISTRIB)
#	$(UPGRADE)
#	$(CREATOR)

.PHONY: $(DISTRIB)
$(DISTRIB): .set_title-$(DISTRIB)
$(DISTRIB):
	@$(call $(HEADERS))
	@$(ECHO) "$(_E)"
	@if [ "$(COMPOSER)" != "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(CP) $(COMPOSER) $(CURDIR)/$(MAKEFILE); \
	fi
	@$(CHMOD) $(CURDIR)/$(MAKEFILE)
	@$(ECHO) "$(_D)"
	@$(MAKE) --makefile $(COMPOSER) $(UPGRADE)-$(DOITALL)
	@$(MAKE) --makefile $(COMPOSER) $(CREATOR)
	@$(ENDOLINE)
	@$(LS) $(CURDIR)

########################################
## {{{2 $(UPGRADE) ---------------------

#> update: PHONY.*(UPGRADE)

.PHONY: $(UPGRADE)
$(UPGRADE): .set_title-$(UPGRADE)
$(UPGRADE):
	@$(call $(HEADERS))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PANDOC_DIR)),$(PANDOC_SRC),$(PANDOC_CMT))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(YQ_DIR)),$(YQ_SRC),$(YQ_CMT))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(COMMONMARK_DIR)),$(COMMONMARK_SRC),$(COMMONMARK_CMT))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_DIR)),$(BOOTSTRAP_SRC),$(BOOTSTRAP_CMT))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSWATCH_DIR)),$(BOOTSWATCH_SRC),$(BOOTSWATCH_CMT))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_DIR)),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
	@$(call GIT_REPO,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(REVEALJS_DIR)),$(REVEALJS_SRC),$(REVEALJS_CMT))
ifneq ($(COMPOSER_DOITALL_$(UPGRADE)),)
	@$(call WGET_PACKAGE,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PANDOC_DIR)),$(PANDOC_URL),$(PANDOC_LNX_SRC),$(PANDOC_LNX_DST),$(PANDOC_LNX_BIN))
	@$(call WGET_PACKAGE,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PANDOC_DIR)),$(PANDOC_URL),$(PANDOC_WIN_SRC),$(PANDOC_WIN_DST),$(PANDOC_WIN_BIN),1)
	@$(call WGET_PACKAGE,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PANDOC_DIR)),$(PANDOC_URL),$(PANDOC_MAC_SRC),$(PANDOC_MAC_DST),$(PANDOC_MAC_BIN),1)
	@$(call WGET_PACKAGE,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(YQ_DIR)),$(YQ_URL),$(YQ_LNX_SRC),$(YQ_LNX_DST),$(YQ_LNX_BIN))
	@$(call WGET_PACKAGE,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(YQ_DIR)),$(YQ_URL),$(YQ_WIN_SRC),$(YQ_WIN_DST),$(YQ_WIN_BIN),1)
	@$(call WGET_PACKAGE,$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(YQ_DIR)),$(YQ_URL),$(YQ_MAC_SRC),$(YQ_MAC_DST),$(YQ_MAC_BIN))
endif
	@$(ENDOLINE)
	@$(ECHO) "$(_E)"
	@$(LN) $(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_DIR))/manifest.json \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_DIR))/manifest.chrome.json
ifneq ($(COMPOSER_DOITALL_$(UPGRADE)),)
	@$(ECHO) "$(_M)"
	@$(LS) --color=never --directory \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PANDOC_BIN)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(YQ_BIN))
endif
	@$(ECHO) "$(_D)"
	@$(LS) --directory \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(PANDOC_DIR))/data/templates \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_DIR))/dist \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSWATCH_DIR))/dist \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_DIR))/manifest.firefox.json \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_DIR))/manifest.chrome.json \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_DIR))/manifest.edge.json \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_CSS)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_CSS_ALT)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_CSS_SOLAR)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(MDVIEWER_CSS_SOLAR_ALT)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSTRAP_CSS_THEME)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSWATCH_CSS_LIGHT)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSWATCH_CSS_DARK)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSWATCH_CSS_SOLAR_LIGHT)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(BOOTSWATCH_CSS_SOLAR_DARK)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(REVEALJS_CSS_THEME)) \
		$(patsubst $(COMPOSER_DIR)%,$(CURDIR)%,$(REVEALJS_CSS_THEME_SOLAR))

################################################################################
# {{{1 Main Targets ------------------------------------------------------------
################################################################################

########################################
## {{{2 $(PUBLISH) ---------------------

ifneq ($(COMPOSER_DOITALL_$(PUBLISH)),)
export override COMPOSER_DOITALL_$(DOITALL) := $(COMPOSER_DOITALL_$(PUBLISH))
endif

.PHONY: $(PUBLISH)
$(PUBLISH): .set_title-$(PUBLISH)
$(PUBLISH):
	@$(call $(HEADERS))
	@$(eval export $(COMPOSER_OPTIONS)) \
		$(MAKE) c_site="1" $(DOITALL)

########################################
### {{{3 $(PUBLISH)-$(CLEANER) ---------

override define $(PUBLISH)-$(CLEANER) =
	if	[ -n "$(COMPOSER_LIBRARY)" ] && \
		[ -d "$(COMPOSER_LIBRARY)" ] && \
		[ "$$($(DIRNAME) $(COMPOSER_LIBRARY))" = "$(CURDIR)" ]; \
	then \
		$(call $(HEADERS)-rm,$(CURDIR),$(patsubst $(CURDIR)/%,%,$(COMPOSER_LIBRARY))); \
		$(ECHO) "$(_S)"; \
		$(RM) --recursive $(COMPOSER_LIBRARY) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

########################################
### {{{3 $(PUBLISH)-$(TARGETS) ---------

override define $(PUBLISH)-$(TARGETS) =
	$(ECHO) "$(_E)"; \
	$(ECHO) "" >$(1); \
	$(ECHO) "" >$(1).$(COMPOSER_BASENAME); \
	$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $(patsubst $(COMPOSER_ROOT)%,...%,$(1).$(COMPOSER_BASENAME)) -->\n" $($(PUBLISH)-$(DEBUGIT)-output); \
	for FILE in $(if $(c_list_plus),$(c_list_plus),$(c_list)); do \
			$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $(patsubst $(COMPOSER_ROOT)%,...%,$${FILE}) -->\n"; \
			$(call PUBLISH_BUILD_SH_RUN) $${FILE}; \
		done \
		| $(TEE) --append $(1).$(COMPOSER_BASENAME) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	if [ -n "$$( \
		$(SED) -n "/^$(PUBLISH_BUILD_CMD_BEG) contents .*$(PUBLISH_BUILD_CMD_END)$$/p" \
			$(foreach FILE,$($(PUBLISH)-caches-begin),$($(PUBLISH)-cache).$(FILE).$(EXTN_HTML)) \
			$(foreach FILE,$($(PUBLISH)-caches-end),$($(PUBLISH)-cache).$(FILE).$(EXTN_HTML)) \
	)" ]; then \
		$(ECHO) "$(_D)"; \
		$(call $(HEADERS)-note,$(1).$(COMPOSER_BASENAME),contents,$(PUBLISH)); \
		$(ECHO) "$(_E)"; \
		$(call $(PUBLISH)-$(TARGETS)-contents,$(1).$(COMPOSER_BASENAME),$(DEPTH_MAX)) \
			| $(TEE) $(1).contents $($(DEBUGIT)-output); \
			if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	fi; \
	$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $(patsubst $(COMPOSER_ROOT)%,...%,$(1)) -->\n" $($(PUBLISH)-$(DEBUGIT)-output); \
	$(call PUBLISH_BUILD_SH_RUN) $(word 1,$(if $(c_list_plus),$(c_list_plus),$(c_list))) title-block \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	for FILE in $($(PUBLISH)-caches-begin); do \
			$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $(patsubst $(COMPOSER_ROOT)%,...%,$($(PUBLISH)-cache).$${FILE}.$(EXTN_HTML)) -->\n"; \
			$(CAT) $($(PUBLISH)-cache).$${FILE}.$(EXTN_HTML); \
		done \
		| if [ -f $(1).contents ]; then \
			$(SED) "/^$(PUBLISH_BUILD_CMD_BEG) contents .*$(PUBLISH_BUILD_CMD_END)$$/r $(1).contents"; \
		else \
			$(CAT); \
		fi \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	$(CAT) $(1).$(COMPOSER_BASENAME) \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	for FILE in $($(PUBLISH)-caches-end); do \
			$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $(patsubst $(COMPOSER_ROOT)%,...%,$($(PUBLISH)-cache).$${FILE}.$(EXTN_HTML)) -->\n"; \
			$(CAT) $($(PUBLISH)-cache).$${FILE}.$(EXTN_HTML); \
		done \
		| if [ -f $(1).contents ]; then \
			$(SED) "/^$(PUBLISH_BUILD_CMD_BEG) contents .*$(PUBLISH_BUILD_CMD_END)$$/r $(1).contents"; \
		else \
			$(CAT); \
		fi \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	$(ECHO) "$(_S)"; \
	$(RM) \
		$(1).$(COMPOSER_BASENAME) $($(DEBUGIT)-output) \
		$(1).contents $($(DEBUGIT)-output) \
		; \
	$(ECHO) "$(_D)"; \
	$(eval override c_list := $(1))
endef

override define $(PUBLISH)-$(TARGETS)-contents =
	FILE="$$( \
		$(CAT) $(1) \
		| $(PANDOC) --from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" --to="json" \
		| $(YQ_WRITE) ".blocks | map(select(.t == \"Header\")) | map(.c)" \
	)"; \
	MAX="$(2)"; if [ -z "$${MAX}" ]; then \
		MAX="$(DEPTH_MAX)"; \
	fi; \
	NUM="0"; while [ "$${NUM}" -lt "$$( \
		$(ECHO) "$${FILE}" \
		| $(YQ_WRITE) "length" \
	)" ]; do \
		LVL="$$($(ECHO) "$${FILE}" | $(YQ_WRITE) ".[$${NUM}][0]")"; \
		LNK="$$($(ECHO) "$${FILE}" | $(YQ_WRITE) ".[$${NUM}][1][0]")"; \
		TXT=; STR="0"; while [ "$${STR}" -lt "$$( \
			$(ECHO) "$${FILE}" \
			| $(YQ_WRITE) ".[$${NUM}][2] | length" \
		)" ]; do \
			TYP="$$( \
				$(ECHO) "$${FILE}" \
				| $(YQ_WRITE) ".[$${NUM}][2][$${STR}][\"t\"]" \
			)"; \
			if [ "$${TYP}" = "Space" ]; then \
				TXT="$${TXT} "; \
			elif [ "$${TYP}" = "Str" ]; then \
				TXT="$${TXT}$$( \
					$(ECHO) "$${FILE}" \
					| $(YQ_WRITE) ".[$${NUM}][2][$${STR}][\"c\"]" \
				)"; \
			fi; \
			STR="$$($(EXPR) $${STR} + 1)"; \
		done; \
		if [ "$${LVL}" -le "$${MAX}" ]; then \
			if [ "$${LVL}" = "1" ]; then	$(ECHO) "  *"; \
			elif [ "$${LVL}" = "2" ]; then	$(ECHO) "    *"; \
			elif [ "$${LVL}" = "3" ]; then	$(ECHO) "        *"; \
			elif [ "$${LVL}" = "4" ]; then	$(ECHO) "            *"; \
			elif [ "$${LVL}" = "5" ]; then	$(ECHO) "                *"; \
			elif [ "$${LVL}" = "6" ]; then	$(ECHO) "                    *"; \
			fi; \
			$(ECHO) " [$${TXT}](#$${LNK})"; \
			$(ECHO) "\n"; \
		fi; \
		NUM="$$($(EXPR) $${NUM} + 1)"; \
	done
endef

########################################
### {{{3 $(PUBLISH)-cache --------------

ifneq ($(c_site),)
$(filter %.$(EXTN_HTML),$(COMPOSER_TARGETS)): $($(PUBLISH)-cache)
endif

$($(PUBLISH)-cache): $(COMPOSER_YML_LIST)
$($(PUBLISH)-cache): $($(PUBLISH)-caches)
$($(PUBLISH)-cache):
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$($(PUBLISH)-cache)

$($(PUBLISH)-caches): $(COMPOSER_YML_LIST)
$($(PUBLISH)-caches):
	@$(eval $(@) := $(patsubst $($(PUBLISH)-cache).%.$(EXTN_HTML),%,$(@)))
	@$(call $(HEADERS)-note,$(COMPOSER_TMP),$($(@)),$(PUBLISH)-cache)
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_TMP) $($(DEBUGIT)-output)
	@$(ECHO) "$(_E)"
	@if [ "$($(@))" = "nav-top" ]; then \
		$(call PUBLISH_BUILD_SH_RUN) "$($(@))" ".variables[\"$(PUBLISH)-$($(@))\"]" "$(COMPOSER_LOGO)"; \
	elif [ "$($(@))" != "$(patsubst nav-%,%,$($(@)))" ]; then \
		$(call PUBLISH_BUILD_SH_RUN) "$($(@))" ".variables[\"$(PUBLISH)-$($(@))\"]"; \
	elif [ "$($(@))" = "column-begin" ]; then \
		$(call PUBLISH_BUILD_SH_RUN) "$($(@))" "1"; \
	else \
		$(call PUBLISH_BUILD_SH_RUN) "$($(@))"; \
	fi \
		| $(TEE) $(@).$(COMPOSER_BASENAME) \
		$($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
	@$(ECHO) "$(_D)"
	@if [ -s "$(@).$(COMPOSER_BASENAME)" ]; then \
		$(ECHO) "$(_S)"; \
		$(MV) $(@).$(COMPOSER_BASENAME) $(@) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	else \
		exit 1; \
	fi

########################################
### {{{3 $(PUBLISH)-library ------------

ifneq ($(and \
	$(c_site) ,\
	$(filter-out $(CURDIR),$(COMPOSER_LIBRARY)) ,\
	$(or \
		$(filter 1,$($(PUBLISH)-library-auto_update)) ,\
		$(filter $(DOFORCE),$(COMPOSER_DOITALL_$(PUBLISH))) \
	) \
),)

$(c_base).$(EXTN_HTML) \
$(DOITALL)-$(TARGETS) $(COMPOSER_TARGETS) \
$(DOITALL)-$(SUBDIRS) $(addprefix $(DOITALL)-$(SUBDIRS)-,$(COMPOSER_SUBDIRS)) \
	: \
	$($(PUBLISH)-library)

$($(PUBLISH)-cache) \
$($(PUBLISH)-caches) \
	: \
	$($(PUBLISH)-library)

$($(PUBLISH)-library) \
$($(PUBLISH)-library-metadata) \
$($(PUBLISH)-library-index) \
$($(PUBLISH)-library-digest) \
	: \
	$(COMPOSER_YML_LIST) \
	$(COMPOSER_CONTENTS_EXT)

endif

#> update: COMPOSER_OPTIONS
$($(PUBLISH)-library): $($(PUBLISH)-library-metadata)
$($(PUBLISH)-library): $($(PUBLISH)-library-index)
$($(PUBLISH)-library): $($(PUBLISH)-library-digest)
$($(PUBLISH)-library):
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call $(INSTALL)-$(MAKEFILE),$(COMPOSER_LIBRARY)/$(MAKEFILE),-$(INSTALL),,1)
	@$(call $(HEADERS)-file,$(COMPOSER_LIBRARY),$(COMPOSER_SETTINGS))
	@$(ENV_MAKE) $(SILENT) --directory $(abspath $(dir $(COMPOSER_LIBRARY))) c_site="1" c_type="$(TYPE_HTML)" $(PUBLISH)-$(COMPOSER_SETTINGS) >$(COMPOSER_LIBRARY)/$(COMPOSER_SETTINGS)
	@$(call $(HEADERS)-file,$(COMPOSER_LIBRARY),$(COMPOSER_YML))
	@$(ENV_MAKE) $(SILENT) --directory $(abspath $(dir $(COMPOSER_LIBRARY))) c_site="1" c_type="$(TYPE_HTML)" $(PUBLISH)-$(COMPOSER_YML) >$(COMPOSER_LIBRARY)/$(COMPOSER_YML)
	@if [ -f "$(abspath $(dir $(COMPOSER_LIBRARY)))/$(COMPOSER_CSS)" ]; then \
		$(call $(HEADERS)-file,$(COMPOSER_LIBRARY),$(COMPOSER_CSS)); \
		$(ECHO) "$(_E)"; \
		$(CP) $(abspath $(dir $(COMPOSER_LIBRARY)))/$(COMPOSER_CSS) $(COMPOSER_LIBRARY)/$(COMPOSER_CSS) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	elif [ -f "$(COMPOSER_LIBRARY)/$(COMPOSER_CSS)" ]; then \
		$(call $(HEADERS)-rm,$(COMPOSER_LIBRARY),$(COMPOSER_CSS)); \
		$(ECHO) "$(_S)"; \
		$(RM) $(COMPOSER_LIBRARY)/$(COMPOSER_CSS) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
#>	@$(ENV_MAKE) $(if $(COMPOSER_DEBUGIT),,$(SILENT)) --directory $(COMPOSER_LIBRARY) c_site="1" $(DOITALL)
	@$(MAKE) $(if $(COMPOSER_DEBUGIT),,$(SILENT)) --directory $(COMPOSER_LIBRARY) c_site="1" $(DOITALL)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$($(PUBLISH)-library)

.PHONY: $(PUBLISH)-$(COMPOSER_SETTINGS)
$(PUBLISH)-$(COMPOSER_SETTINGS):
	@$(foreach FILE,$(filter-out $(COMPOSER_OPTIONS_PROTECT),$(COMPOSER_OPTIONS)),\
		$(ECHO) "override $(FILE) := $($(FILE))\n"; \
		$(call NEWLINE) \
	)

.PHONY: $(PUBLISH)-$(COMPOSER_YML)
$(PUBLISH)-$(COMPOSER_YML):
	@$(patsubst $(COMPOSER_DIR)/$(COMPOSER_YML),,$(COMPOSER_YML_DATA)) \
		| $(YQ_WRITE_FILE) " \
				.variables[\"$(PUBLISH)-library\"].[\"folder\"] = null \
				| .variables[\"$(PUBLISH)-library\"].[\"auto_update\"] = null \
			"

override define $(PUBLISH)-library-sort-yq =
	sort_by(.path) \
	| sort_by(.title) \
	| (sort_by(.date) | reverse)
endef

override define $(PUBLISH)-library-sort-sh =
	if [ "$(1)" = "date" ]; then \
		$(SORT) --reverse; \
	else \
		$(SORT); \
	fi
endef

########################################
### {{{3 $(PUBLISH)-library-metadata ---

#> update: YQ_WRITE.*title

$($(PUBLISH)-library-metadata): $(COMPOSER_YML_LIST)
$($(PUBLISH)-library-metadata):
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_F)"
	@$(ECHO) "{" >$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_N)"
	@$(ECHO) "\".$(COMPOSER_BASENAME)\": { \".updated\": \"$(DATESTAMP)\" }," \
		| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
		$($(DEBUGIT)-output); \
		$(if $(COMPOSER_DEBUGIT),$(ECHO) "\n")
	@$(ECHO) "$(_D)"
	@$(FIND) $(abspath $(dir $(COMPOSER_LIBRARY))) \
		\( -path $(COMPOSER_DIR) -prune \) \
		-o \( -path $(COMPOSER_TMP) -prune \) \
		-o \( -path $(COMPOSER_LIBRARY) -prune \) \
		-o \( -path \*/$(notdir $(COMPOSER_TMP)) -prune \) \
		$(shell $(FIND) $(abspath $(dir $(COMPOSER_LIBRARY))) -path \*/$(COMPOSER_YML) \
			| while read -r FILE; do \
				DIR="$$( \
					$(CAT) $${FILE} \
					| $(YQ_WRITE) ".variables[\"$(PUBLISH)-library\"].[\"folder\"]" 2>/dev/null \
					| $(SED) "/^null$$/d" \
				)"; \
				if [ -n "$${DIR}" ]; then \
					$(ECHO) " -o \\( -path $$( \
							$(DIRNAME) $${FILE} \
						)/$$( \
							$(ECHO) "$${DIR}" \
							| $(SED) "s|^.+[/]([^/]+)$$|\1|g" \
						) -prune \\)"; \
				fi; \
			done \
		) \
		-o \( -type f $$( \
				if [ -f "$(@)" ]; then \
					$(ECHO) "-newer $(@)"; \
				fi \
			) -name "*$(COMPOSER_EXT)" -print \) \
	| while read -r FILE; do \
		$(ECHO) "$(_D)"; \
		$(call $(HEADERS)-note,$(@),$$( \
				$(ECHO) "$${FILE}" \
				| $(SED) "s|^$(abspath $(dir $(COMPOSER_LIBRARY)))/||g" \
			),$(PUBLISH)-metadata); \
		if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
			else				$(ECHO) "$(_N)"; \
			fi; \
		$(ECHO) "\"$${FILE}\": " \
			| $(SED) "s|^([\"])$(abspath $(dir $(COMPOSER_LIBRARY)))/|\1|g" \
			| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
			$($(DEBUGIT)-output); \
		if [ -n "$$( \
			$(YQ_READ) $${FILE} 2>/dev/null \
				| $(YQ_WRITE) ".title" \
				| $(SED) "/^null$$/d" \
		)" ] || [ -n "$$( \
			$(YQ_READ) $${FILE} 2>/dev/null \
				| $(YQ_WRITE) ".pagetitle" \
				| $(SED) "/^null$$/d" \
		)" ]; then \
			$(YQ_READ) $${FILE} 2>/dev/null \
				| $(YQ_WRITE) ". += { \".$(COMPOSER_BASENAME)\": true }"; \
		else \
			$(ECHO) "{ \".$(COMPOSER_BASENAME)\": null }"; \
		fi \
			| $(YQ_WRITE) ". += { \"path\": \"$$( \
					$(ECHO) "$${FILE}" \
					| $(SED) "s|^$(abspath $(dir $(COMPOSER_LIBRARY)))/||g" \
				)\" }" \
			| $(YQ_WRITE) ". += { \".updated\": \"$(DATESTAMP)\" }" \
			| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
			$($(DEBUGIT)-output); \
		$(ECHO) "," >>$(@).$(COMPOSER_BASENAME); \
		$(ECHO) "$(_D)"; \
	done
	@$(ECHO) "}" >>$(@).$(COMPOSER_BASENAME)
	@if [ ! -s "$(@)" ]; then \
		$(ECHO) "{}" >$(@).$(PRINTER); \
	else \
		$(ECHO) "$(_S)"; \
		$(CP) $(@) $(@).$(PRINTER) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
	@$(ECHO) "$(_F)"
	@$(YQ_READ) eval-all '. as $$file ireduce ({}; . * $$file)' \
			$(@).$(PRINTER) \
			$(@).$(COMPOSER_BASENAME) \
		| $(YQ_WRITE_FILE) "sort_keys(..)" \
		>$(@).$(PUBLISH); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
	@$(ECHO) "$(_D)"
	@if [ -s "$(@).$(PUBLISH)" ]; then \
		$(ECHO) "$(_S)"; \
		$(RM) $(@).$(COMPOSER_BASENAME)	$($(DEBUGIT)-output); \
		$(RM) $(@).$(PRINTER)		$($(DEBUGIT)-output); \
		$(MV) $(@).$(PUBLISH) $(@)	$($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	else \
		exit 1; \
	fi

########################################
### {{{3 $(PUBLISH)-library-index ------

$($(PUBLISH)-library-index): $(COMPOSER_YML_LIST)
$($(PUBLISH)-library-index): $($(PUBLISH)-library-metadata)
$($(PUBLISH)-library-index):
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(ECHO) "{\n" >$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_N)"
	@$(ECHO) "\".$(COMPOSER_BASENAME)\": { \".updated\": \"$(DATESTAMP)\" }," \
		| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
		$($(DEBUGIT)-output); \
		$(if $(COMPOSER_DEBUGIT),$(ECHO) "\n")
	@$(ECHO) "$(_D)"
	@$(foreach FILE,\
		title \
		author \
		date \
		tag \
		,\
		$(call $(PUBLISH)-library-indexer,$(FILE)); \
		$(call NEWLINE) \
	)
	@$(ECHO) "}" >>$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_F)"
#>		| $(YQ_WRITE_FILE) "sort_keys(..)"
	@$(CAT) $(@).$(COMPOSER_BASENAME) \
		| $(YQ_WRITE_FILE) \
		>$(@).$(PUBLISH); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
	@$(ECHO) "$(_D)"
	@if [ -s "$(@).$(PUBLISH)" ]; then \
		$(ECHO) "$(_S)"; \
		$(RM) $(@).$(COMPOSER_BASENAME)	$($(DEBUGIT)-output); \
		$(MV) $(@).$(PUBLISH) $(@)	$($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	else \
		exit 1; \
	fi

#> update: Title / Author / Date[Year] / Tag
override define $(PUBLISH)-library-indexer =
	$(ECHO) "$(_E)"; \
	$(ECHO) "$(1)s: {\n" >>$(@).$(COMPOSER_BASENAME); \
	$(CAT) $($(PUBLISH)-library-metadata) \
		|	if [ "$(1)" = "title" ]; then \
				$(YQ_WRITE) ".[].[\".$(COMPOSER_BASENAME)\"]"; \
			elif [ "$(1)" = "author" ]; then \
				$(YQ_WRITE) ".[].author" \
				| $(SED) "s|^[-][ ]||g"; \
			elif [ "$(1)" = "date" ]; then \
				$(YQ_WRITE) ".[].date" \
				| $(SED) \
					-e "s|^([0-9]{4}).*$$|\1|g" \
					-e "s|^.*([0-9]{4})$$|\1|g"; \
			elif [ "$(1)" = "tag" ]; then \
				$(YQ_WRITE) ".[].tags" \
				| $(SED) "s|^[-][ ]||g"; \
			fi \
		| $(call $(PUBLISH)-library-sort-sh,$(1)) \
		| while read -r FILE; do \
			$(ECHO) "$(_D)"; \
			$(call $(HEADERS)-note,$(@),$$( \
					if [ "$(1)" = "title" ]; then		$(ECHO) "Title"; \
					elif [ "$(1)" = "author" ]; then	$(ECHO) "Author"; \
					elif [ "$(1)" = "date" ]; then		$(ECHO) "Year"; \
					elif [ "$(1)" = "tag" ]; then		$(ECHO) "Tag"; \
					fi \
				): $${FILE},$(PUBLISH)-index); \
			if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
				else				$(ECHO) "$(_N)"; \
				fi; \
			$(ECHO) "\"$${FILE}\": [\n" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
				$($(DEBUGIT)-output); \
			$(CAT) $($(PUBLISH)-library-metadata) \
				|	if [ "$(1)" = "title" ]; then \
						if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.\".$(COMPOSER_BASENAME)\" == null))"; \
							else				$(YQ_WRITE) "map(select(.\".$(COMPOSER_BASENAME)\" == $${FILE}))"; \
							fi; \
					elif [ "$(1)" = "author" ]; then \
						if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.author == null))"; \
							else				$(YQ_WRITE) "map(select((.author == \"$${FILE}\") or (.author | .[] | contains(\"$${FILE}\"))))"; \
							fi; \
					elif [ "$(1)" = "date" ]; then \
						if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.date == null))"; \
							else				$(YQ_WRITE) "map(select(.date == \"$${FILE}*\" or .date == \"*$${FILE}\"))"; \
							fi; \
					elif [ "$(1)" = "tag" ]; then \
						if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.tags == null))"; \
							else				$(YQ_WRITE) "map(select(.tags | contains([\"$${FILE}\"])))"; \
							fi; \
					fi \
				| $(YQ_WRITE) "$(call $(PUBLISH)-library-sort-yq) | .[].path" \
				| $(SED) "s|$$|,|g" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
				$($(DEBUGIT)-output); \
			$(ECHO) "],\n" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) \
				$($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
		done; \
	$(ECHO) "$(_E)"; \
	$(ECHO) "},\n" >>$(@).$(COMPOSER_BASENAME); \
	$(ECHO) "$(_D)"
endef

########################################
### {{{3 $(PUBLISH)-library-digest -----

#>		titles
#>			| $(SED) "/^null$$/d"
override define $(PUBLISH)-library-digest-list =
	for TYPE in \
		authors \
		dates \
		tags \
	; do \
		$(CAT) $($(PUBLISH)-library-index) \
			| $(YQ_WRITE) ".$${TYPE} | keys | .[]" \
			| $(SED) "/^null$$/d" \
			| while read -r FILE; do \
				OUTFILE="$(COMPOSER_LIBRARY)/$${TYPE}-$$( \
						$(call $(HELPOUT)-$(DOFORCE)-$(TARGETS)-FORMAT,$${FILE}) \
					)$(COMPOSER_EXT_DEFAULT)"; \
				if [ -n "$(1)" ]; then \
					if [ "$(1)" = "$${OUTFILE}" ]; then \
						$(ECHO) "$${TYPE}$(TOKEN)$${FILE}\n"; \
					fi; \
				else \
					$(ECHO) "$${OUTFILE}\n"; \
				fi; \
			done; \
	done
endef

ifneq ($(and \
	$(c_site) ,\
	$(wildcard $($(PUBLISH)-library-index)) \
),)
override $(PUBLISH)-library-digest-files := $(shell $(call $(PUBLISH)-library-digest-list))
endif

$($(PUBLISH)-library-digest): $(COMPOSER_YML_LIST)
$($(PUBLISH)-library-digest): $($(PUBLISH)-library-metadata)
$($(PUBLISH)-library-digest): $($(PUBLISH)-library-index)
$($(PUBLISH)-library-digest): $($(PUBLISH)-library-digest-files)
$($(PUBLISH)-library-digest): $($(PUBLISH)-library-digest-src)
$($(PUBLISH)-library-digest):
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(MAKE) $(if $(COMPOSER_DEBUGIT),,$(SILENT)) c_site="1" $$($(call $(PUBLISH)-library-digest-list))
	@$(ECHO) "$(_F)"
	@$(ECHO) "" >$(@)
	@$(ECHO) "---\n" >>$(@)
	@$(ECHO) "pagetitle: $($(PUBLISH)-library-digest_title)\n" >>$(@)
	@$(ECHO) "---\n" >>$(@)
	@$(ECHO) "$(_D)"
	@$(call $(PUBLISH)-library-digest-main,$(@))

$($(PUBLISH)-library-digest-src): $(COMPOSER_YML_LIST)
$($(PUBLISH)-library-digest-src): $($(PUBLISH)-library-metadata)
$($(PUBLISH)-library-digest-src): $($(PUBLISH)-library-index)
$($(PUBLISH)-library-digest-src):
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call $(PUBLISH)-library-digest-main,$(COMPOSER_LIBRARY).$(notdir $($(PUBLISH)-library-digest-src)))
	@$(ECHO) "$(_S)"
	@$(MV) $(COMPOSER_LIBRARY).$(notdir $($(PUBLISH)-library-digest-src)) $($(PUBLISH)-library-digest-src) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

#> update: Title / Author / Date[Year] / Tag
$($(PUBLISH)-library-digest-files): $(COMPOSER_YML_LIST)
$($(PUBLISH)-library-digest-files): $($(PUBLISH)-library-metadata)
$($(PUBLISH)-library-digest-files): $($(PUBLISH)-library-index)
$($(PUBLISH)-library-digest-files):
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_F)"
	@$(ECHO) "" >$(@)
	@TOKEN="$$($(ECHO) "$(TOKEN)" | $(SED) "s|(.)|\\\\\1|g")"; \
		TYPE="$$($(call $(PUBLISH)-library-digest-list,$(@)) | $(SED) "s|^(.+)$${TOKEN}(.+)$$|\1|g")"; \
		NAME="$$($(call $(PUBLISH)-library-digest-list,$(@)) | $(SED) "s|^(.+)$${TOKEN}(.+)$$|\2|g")"; \
		$(ECHO) "---\n" >>$(@); \
		$(ECHO) "pagetitle: \"$$( \
				if [ "$${TYPE}" = "titles" ]; then	$(ECHO) "Title"; \
				elif [ "$${TYPE}" = "authors" ]; then	$(ECHO) "Author"; \
				elif [ "$${TYPE}" = "dates" ]; then	$(ECHO) "Year"; \
				elif [ "$${TYPE}" = "tags" ]; then	$(ECHO) "Tag"; \
				fi \
			): $${NAME}\"\n" >>$(@); \
		$(ECHO) "---\n" >>$(@); \
		$(CAT) $($(PUBLISH)-library-index) \
			| $(YQ_WRITE) ".$${TYPE}.[\"$${NAME}\"] | .[]" \
			| while read -r FILE; do \
				$(call $(PUBLISH)-library-digest-create,$(@),$${FILE},$(COMPOSER_EXT_DEFAULT),$(SPECIAL_VAL)); \
			done

override define $(PUBLISH)-library-digest-main =
	$(ECHO) "$(_F)"; \
	NUM="0"; for FILE in $$( \
		$(CAT) $($(PUBLISH)-library-metadata) \
			| $(YQ_WRITE) " \
				map(select(.title != null or .pagetitle != null)) \
				| $(call $(PUBLISH)-library-sort-yq) \
				| .[].path \
			" \
			| $(HEAD) -n$($(PUBLISH)-library-digest_count); \
	); do \
		if [ "$${NUM}" -gt "0" ] && [ "$($(PUBLISH)-library-digest_spacer)" = "1" ]; then \
			$(ECHO) "$(PUBLISH_BUILD_CMD_BEG) spacer $(PUBLISH_BUILD_CMD_END)\n" >>$(1); \
		fi; \
		$(ECHO) "$(_D)"; \
		EXPAND="$(SPECIAL_VAL)"; \
		if [ "$${NUM}" -lt "$($(PUBLISH)-library-digest_expanded)" ]; then \
			EXPAND="1"; \
		fi; \
		$(call $(PUBLISH)-library-digest-create,$(1),$${FILE},$(COMPOSER_EXT),$${EXPAND}); \
		NUM="$$($(EXPR) $${NUM} + 1)"; \
	done; \
	$(ECHO) "$(_D)"
endef

#> update: YQ_WRITE.*title
override define $(PUBLISH)-library-digest-create =
	$(ECHO) "$(_D)"; \
	$(call $(HEADERS)-note,$(1),$(2),$(PUBLISH)-digest); \
	if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
		else				$(ECHO) "$(_N)"; \
		fi; \
	$(ECHO) "$(PUBLISH_BUILD_CMD_BEG) pane-begin $(DEPTH_MAX) $(4) " \
			| $(TEE) --append $(1) \
			$($(DEBUGIT)-output); \
		TITL="$$( \
			$(CAT) $($(PUBLISH)-library-metadata) \
			| $(YQ_WRITE) ".\"$(2)\".title" 2>/dev/null \
			| $(SED) "/^null$$/d"; \
		)"; \
		if [ -z "$${TITL}" ]; then \
			TITL="$$( \
				$(CAT) $($(PUBLISH)-library-metadata) \
				| $(YQ_WRITE) ".\"$(2)\".pagetitle" 2>/dev/null \
				| $(SED) "/^null$$/d"; \
			)"; \
		fi; \
		if [ -z "$${TITL}" ]; then \
			TITL="$$( \
				$(CAT) $($(PUBLISH)-library-metadata) \
				| $(YQ_WRITE) ".\"$(2)\".path" 2>/dev/null \
				| $(SED) "s|^$(abspath $(dir $(COMPOSER_LIBRARY)))/||g"; \
			)"; \
		fi; \
		NAME="$$( \
			$(CAT) $($(PUBLISH)-library-metadata) \
			| $(YQ_WRITE) ".\"$(2)\".author" 2>/dev/null \
			| $(SED) "/^null$$/d"; \
		)"; \
		if [ -n "$${NAME}" ]; then \
			JOIN="$$( \
				$(ECHO) "$${NAME}" \
				| $(YQ_WRITE) "join(\"; \")" 2>/dev/null \
				| $(SED) "/^null$$/d"; \
			)"; \
			if [ -n "$${JOIN}" ]; then \
				NAME="$${JOIN}"; \
			fi; \
		fi; \
		DATE="$$( \
			$(CAT) $($(PUBLISH)-library-metadata) \
			| $(YQ_WRITE) ".\"$(2)\".date" 2>/dev/null \
			| $(SED) "s|[T][0-9]{2}[:][0-9]{2}[:][0-9]{2}.*$$||g" \
			| $(SED) "/^null$$/d"; \
		)"; \
		if [ -n "$${DATE}" ]; then \
			$(ECHO) "$${DATE}" \
				| $(TEE) --append $(1) \
				$($(DEBUGIT)-output); \
		fi; \
		if [ -n "$${DATE}" ] && [ -n "$${TITL}" ]; then \
			$(ECHO) " $(DIVIDE) " \
				| $(TEE) --append $(1) \
				$($(DEBUGIT)-output); \
		fi; \
		if [ -n "$${TITL}" ]; then \
			$(ECHO) "$${TITL}" \
				| $(TEE) --append $(1) \
				$($(DEBUGIT)-output); \
		fi; \
		if [ -n "$${NAME}" ]; then \
			if [ -n "$${DATE}" ] || [ -n "$${TITL}" ]; then \
				$(ECHO) " </br> " \
					| $(TEE) --append $(1) \
					$($(DEBUGIT)-output); \
			fi; \
			$(ECHO) "$${NAME}" \
				| $(TEE) --append $(1) \
				$($(DEBUGIT)-output); \
		fi; \
		$(ECHO) " $(PUBLISH_BUILD_CMD_END)\n\n" \
			| $(TEE) --append $(1) \
			$($(DEBUGIT)-output); \
	$(CAT) $(abspath $(dir $(COMPOSER_LIBRARY)))/$(2) \
		| $(PANDOC) --strip-comments --from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" --to="$(TMPL_LINT)" \
		| $(SED) "/^$(PUBLISH_BUILD_CMD_BEG) .+ $(PUBLISH_BUILD_CMD_END)$$/d" \
		| $(TR) '\n' '$(TOKEN)' \
		| $(SED) "s|^(.{$($(PUBLISH)-library-digest_chars)}).+$$|\1 $($(PUBLISH)-library-digest_continue)|g" \
		| $(TR) '$(TOKEN)' '\n' \
		| $(TEE) --append $(1) \
		$($(DEBUGIT)-output); \
	$(ECHO) "\n\n[$($(PUBLISH)-library-digest_permalink)]($$( \
			$(REALPATH) $(abspath $(dir $(1))) $(abspath $(dir $(COMPOSER_LIBRARY)))/$(2) \
			| $(SED) "s|$(3)$$|.$(EXTN_HTML)|g" \
		))\n" \
		| $(TEE) --append $(1) \
		$($(DEBUGIT)-output); \
	$(ECHO) "\n$(PUBLISH_BUILD_CMD_BEG) pane-end $(PUBLISH_BUILD_CMD_END)\n" \
		| $(TEE) --append $(1) \
		$($(DEBUGIT)-output); \
	$(ECHO) "$(_D)"
endef

########################################
### {{{3 $(PUBLISH)-$(EXAMPLE) ---------

override $(PUBLISH)-$(EXAMPLE)				:= $(CURDIR)/_$(PUBLISH)
override $(PUBLISH)-$(EXAMPLE)-main			:= index
override $(PUBLISH)-$(EXAMPLE)-include			:= index-digest
override $(PUBLISH)-$(EXAMPLE)-folder			:= _library
override $(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS)	:= _index
override $(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir		:= $(CONFIGS)/$(notdir $(BOOTSTRAP_DIR))/site/content/docs/$(BOOTSTRAP_DOC_VER)/getting-started

.PHONY: $(PUBLISH)-$(EXAMPLE)
$(PUBLISH)-$(EXAMPLE): .set_title-$(PUBLISH)-$(EXAMPLE)
$(PUBLISH)-$(EXAMPLE):
	@$(call $(HEADERS))
ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),)
	@$(ECHO) "$(_S)"
	@$(MKDIR) $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)
	@$(MKDIR) $($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))
	@$(MKDIR)				$(patsubst $(COMPOSER_DIR)%,$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)%,$(PANDOC_DIR))
	@$(MKDIR)				$(patsubst $(COMPOSER_DIR)%,$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)%,$(BOOTSTRAP_DIR))
	@$(ECHO) "$(_D)"
	@$(RSYNC) \
		--delete-excluded \
		--prune-empty-dirs \
		--filter="+_/**/" \
		--filter="-_/test/**" \
		--filter="+_/**$(COMPOSER_EXT_DEFAULT)" \
		--filter="-_/**" \
		$(PANDOC_DIR)/			$(patsubst $(COMPOSER_DIR)%,$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)%,$(PANDOC_DIR))
	@$(RSYNC) \
		--delete-excluded \
		--prune-empty-dirs \
		--filter="+_/site" \
		--filter="+_/site/content" \
		--filter="-_/site/content/docs/*/about" \
		--filter="-_/site/content/docs/*/examples" \
		--filter="-_/site/*" \
		--filter="-_/*" \
		$(BOOTSTRAP_DIR)/		$(patsubst $(COMPOSER_DIR)%,$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)%,$(BOOTSTRAP_DIR))
	@$(RSYNC) $(PANDOC_DIR)/MANUAL.txt	$(patsubst $(COMPOSER_DIR)%,$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)%,$(PANDOC_DIR))/MANUAL$(COMPOSER_EXT_DEFAULT)
	@$(ENV_MAKE) $(SILENT) --makefile $(COMPOSER) --directory $($(PUBLISH)-$(EXAMPLE)) $(INSTALL)-$(DOFORCE)
endif
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-file,$(abspath $(dir $(PUBLISH_BUILD_SH))),$(notdir $(PUBLISH_BUILD_SH)))
	@$(call DO_HEREDOC,HEREDOC_PUBLISH_BUILD_SH)				>$(PUBLISH_BUILD_SH)
	@$(call $(HEADERS)-file,$(COMPOSER_DIR),$(COMPOSER_YML))
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML,1)				>$(COMPOSER_DIR)/$(COMPOSER_YML)
endif
	@$(call $(HEADERS)-file,$($(PUBLISH)-$(EXAMPLE)),.../$(COMPOSER_SETTINGS))
	@$(ECHO) "override COMPOSER_INCLUDE := 1\n"				>$($(PUBLISH)-$(EXAMPLE))/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_INCLUDE := 1\n"				>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_INCLUDE := 1\n"				>$($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_INCLUDE := 0\n"				>$($(PUBLISH)-$(EXAMPLE))/$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/$(COMPOSER_SETTINGS)
ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),)
	@$(ECHO) "override COMPOSER_INCLUDE := 1\n"				>$($(PUBLISH)-$(EXAMPLE))/$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n"				>>$($(PUBLISH)-$(EXAMPLE))/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n"				>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n"				>>$($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n"				>>$($(PUBLISH)-$(EXAMPLE))/$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/$(COMPOSER_SETTINGS)
endif
	@$(call $(HEADERS)-file,$($(PUBLISH)-$(EXAMPLE)),.../$(COMPOSER_YML))
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML))		>$($(PUBLISH)-$(EXAMPLE))/$(COMPOSER_YML)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)-$(CONFIGS))	>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_YML)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)-$(NOTHING))	>$($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))/$(COMPOSER_YML)
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),)
	@$(SED) -i "s|^(.+auto_update.+)1$$|\1null|g" \
										$(if $(COMPOSER_RELEASE),$(COMPOSER_DIR)/$(COMPOSER_YML)) \
										$($(PUBLISH)-$(EXAMPLE))/$(COMPOSER_YML) \
										$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_YML) \
										$($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))/$(COMPOSER_YML)
	@$(TOUCH) \
										$(if $(COMPOSER_RELEASE),$(COMPOSER_DIR)/$(COMPOSER_YML)) \
										$($(PUBLISH)-$(EXAMPLE))/$(COMPOSER_YML) \
										$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_YML) \
										$($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))/$(COMPOSER_YML)
endif
	@$(call $(HEADERS)-file,$($(PUBLISH)-$(EXAMPLE)),.../$(COMPOSER_CSS))
ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),)
	@$(ECHO) "$(_S)"
	@$(RM) $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_CSS) $($(DEBUGIT)-output)
	@$(MKDIR) $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS)) $($(DEBUGIT)-output)
	@$(ECHO) "$(_E)"
	@$(LN) $(BOOTSWATCH_CSS_SOLAR_LIGHT) $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))/$(COMPOSER_CSS) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
else
	@$(ECHO) "$(_S)"
	@$(RM) $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))/$(COMPOSER_CSS) $($(DEBUGIT)-output)
	@$(ECHO) "$(_E)"
	@$(LN) $(BOOTSWATCH_CSS_SOLAR_LIGHT) $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_CSS) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
	@$(call $(HEADERS)-file,$($(PUBLISH)-$(EXAMPLE)),.../*$(COMPOSER_EXT_DEFAULT))
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-digest)			>$($(PUBLISH)-$(EXAMPLE))/$($(PUBLISH)-$(EXAMPLE)-include)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-digest-$(CONFIGS))		>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-page)				>$($(PUBLISH)-$(EXAMPLE))/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-page-$(CONFIGS))		>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-page-$(NOTHING))		>$($(PUBLISH)-$(EXAMPLE))/$(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-features)			>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(PUBLISH)-$(TESTING)-features$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,$(PUBLISH)-$(EXAMPLE)-comments)			>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(PUBLISH)-$(TESTING)-comments$(COMPOSER_EXT_SPECIAL)
	@$(call $(HEADERS)-file,$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS),$(COMPOSER_SETTINGS))
	@$(ECHO) "ifeq (\$$(COMPOSER_MY_PATH),\$$(CURDIR))\n"			>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_TARGETS := .$(TARGETS)"			>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) " $(PUBLISH)-$(TESTING).$(EXTN_HTML)\n"			>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) '$(PUBLISH)-$(TESTING).$(EXTN_HTML): \\\n'			>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) '\t$(PUBLISH)-$(TESTING)-features$(COMPOSER_EXT_SPECIAL) \\\n'	>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(foreach NUM,0 1 2 3 4 5 6 7 8 9,\
		$(eval override MARK := 203$(NUM)-01-01) \
		$(eval override FILE := $($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(MARK)-$(EXAMPLE)_0$(NUM)$(COMPOSER_EXT_DEFAULT)) \
		$(call $(HEADERS)-file,$(abspath $(dir $(FILE))),$(notdir $(FILE))); \
		$(ECHO) "---\n"											>$(FILE); \
		$(ECHO) "title: Number 0$(NUM) in $(patsubst %-01-01,%,$(MARK))\n"				>>$(FILE); \
		$(ECHO) "author: $(COMPOSER_COMPOSER)\n"							>>$(FILE); \
		$(ECHO) "date: $(MARK)\n"									>>$(FILE); \
		$(ECHO) "tags: [$(TESTING)1, $(TESTING)2, $(TESTING)3, $(TESTING)$(NUM)]\n"			>>$(FILE); \
		$(ECHO) "---\n"											>>$(FILE); \
		$(ECHO) "$(PUBLISH_BUILD_CMD_BEG) title-block box $(DEPTH_MAX) $(PUBLISH_BUILD_CMD_END)\n"	>>$(FILE); \
		$(MAKE) $(SILENT) COMPOSER_DOCOLOR= COMPOSER_DEBUGIT= $(PUBLISH)-$(EXAMPLE)-$(EXAMPLE)		>>$(FILE); \
		$(ECHO) '\t$(notdir $(FILE)) \\\n'				>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS); \
	)
	@$(ECHO) '\t$(PUBLISH)-$(TESTING)-comments$(COMPOSER_EXT_SPECIAL)\n'	>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
	@$(ECHO) "endif\n"							>>$($(PUBLISH)-$(EXAMPLE))/$(CONFIGS)/$(COMPOSER_SETTINGS)
ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),)
	@time $(ENV_MAKE) $(SILENT) --directory $($(PUBLISH)-$(EXAMPLE)) MAKEJOBS="$(SPECIAL_VAL)" $(PUBLISH)-$(DOITALL)
else
	@time $(ENV_MAKE) $(SILENT) --directory $($(PUBLISH)-$(EXAMPLE)) MAKEJOBS= $(PUBLISH)-$(DOITALL)
	@time $(ENV_MAKE) $(SILENT) --directory $($(PUBLISH)-$(EXAMPLE)) MAKEJOBS= $(PUBLISH)-$(DOFORCE)
endif

#WORKING:NOW:NOW
#	verify: $(eval export $(COMPOSER_OPTIONS))
#		c_margins error in $(TESTING)-$(COMPOSER_BASENAME) ?
#	site
#		css tables align=top
#		add ".contents" to site-template-all
#			garybgenett -> Error: open . as $file ireduce ({}; . *+ $file): no such file or directory
#				works -> home projects gary-os composer / contents 3 / history / tags
#			add a "depth" option to ".contents"...
#			make it work on "$(1)" instead of "$(c_list)"?
#				do a "function-loop" walk of the ast, and pull out the "header" paths
#			need a test for all ascii characters...
#		add banner and footer...?
#			create "sections" for nav-*, so they can be dynamically reconfigured...
#			these are going to be a pita to implement, and then change all the yml files...
#		light color versions of all icons, for dark backgrounds...
#			https://github.com/logos ... etc.
#		https://github.com/garybgenett/www.garybgenett.net
#	build.sh
#		are "file path"s getting truncated?
#		add tests for all 6 composer_root: top button, top menu, top nav tree, top nav branch, bottom, html[include]
#		which are default "#" links/hashes?  make them so, and remove the need from the configuration files?
#		convert echo/cat/etc. to passed-in variables, because paths may be different between systems...
#	fixes
#		pagetitle for digest pages...
#		actually, maybe rename or symlink digest.html?  this would be in addition to the include?
#		ability to disable digest in library, and do flat links instead?
#		h1/etc. sizes are *way* huge...
#	c_site -> c_type = $(PUBLISH) ?
#		would make documentation and other things much easier... no need to keep c_site/EXTN_HTML in sync...
#		probably more future-proof, too...
#	work backwards, turning YQ_WRITE.*title into a dedicated title-block function
#		replace the YQ_WRITE.*title code in library-digest with a call to title-block
#		test
#	empty configuration versus hard-defaults
#		they should match, and $(NOTHING) and pandoc directories should not have _library
#		incorporate the COMPOSER_DEPENDS and other testing happening here, now

########################################
#### {{{4 Heredoc: Example Page(s) -----

.PHONY: $(PUBLISH)-$(EXAMPLE)-$(EXAMPLE)
$(PUBLISH)-$(EXAMPLE)-$(EXAMPLE):
	@$(call TITLE_LN ,$(DEPTH_MAX),Recommended Workflow)
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-WORKFLOW)

override define $(PUBLISH)-$(EXAMPLE)-digest =
---
pagetitle: Latest Updates
---
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) #WORKING $(PUBLISH_BUILD_CMD_END)
#WORKING
Library Digest Page: [$($(PUBLISH)-$(EXAMPLE)-folder)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest)))](<composer_root>/$($(PUBLISH)-$(EXAMPLE)-folder)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest))))
$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) spacer $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) $($(PUBLISH)-$(EXAMPLE)-folder)/$(notdir $($(PUBLISH)-library-digest-src)) $(PUBLISH_BUILD_CMD_END)
endef

override define $(PUBLISH)-$(EXAMPLE)-digest-$(CONFIGS) =
---
pagetitle: Digest
---
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) #WORKING $(PUBLISH_BUILD_CMD_END)
#WORKING
Library Digest Page ($(CONFIGS)): [$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest)))](<composer_root>/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest))))
$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) spacer $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) $($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))/$(notdir $($(PUBLISH)-library-digest-src)) $(PUBLISH_BUILD_CMD_END)
endef

override define $(PUBLISH)-$(EXAMPLE)-features =
---
pagetitle: Site Features Page
---
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) LIBRARY $(PUBLISH_BUILD_CMD_END)
<div class="container-fluid">
<div class="d-flex flex-row flex-wrap">
<div class="d-flex flex-column border border-1 me-3 p-2">
$(PUBLISH_BUILD_CMD_BEG) library authors $(PUBLISH_BUILD_CMD_END)
</div>
<div class="d-flex flex-column border border-1 me-3 p-2">
$(PUBLISH_BUILD_CMD_BEG) library dates $(PUBLISH_BUILD_CMD_END)
</div>
<div class="d-flex flex-column border border-1 me-3 p-2">
$(PUBLISH_BUILD_CMD_BEG) library tags $(PUBLISH_BUILD_CMD_END)
</div>
</div>
</div>
$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
endef

override define $(PUBLISH)-$(EXAMPLE)-comments =
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) COMMENT $(PUBLISH_BUILD_CMD_END)
COMMENT
$(PUBLISH_BUILD_CMD_BEG) spacer $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) REPLY $(PUBLISH_BUILD_CMD_END)
REPLY
$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
endef

########################################
#### {{{4 Heredoc: Page: Main ----------

override define $(PUBLISH)-$(EXAMPLE)-page =
---
pagetitle: Main Page
---
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) Example Pages $(PUBLISH_BUILD_CMD_END)

#WORKING:NOW introduction
# add <composer_root> to all links
# add date, pagetitle (not title) and no author to config/index.html
# note on example page about logo/icon

  * [$(OUT_README).$(PUBLISH).$(EXTN_HTML)](<composer_root>/../$(OUT_README).$(PUBLISH).$(EXTN_HTML)) *([$(notdir $(COMPOSER_ART))/$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT)](<composer_root>/../$(notdir $(COMPOSER_ART))/$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT)))*
    * An interactive '$(PUBLISH)' rendered version of the $(COMPOSER_BASENAME) $(OUT_README)$(COMPOSER_EXT_DEFAULT) file
    * All elements and the page layout were specifically tuned *([$(notdir $(COMPOSER_ART))/$(OUT_README).$(PUBLISH).yml](<composer_root>/../$(notdir $(COMPOSER_ART))/$(OUT_README).$(PUBLISH).yml))*
  * [$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML)]($($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML)) *([$($(PUBLISH)-$(EXAMPLE)-include)$(COMPOSER_EXT_DEFAULT)]($($(PUBLISH)-$(EXAMPLE)-include)$(COMPOSER_EXT_DEFAULT)))*
    * Automatically generated digest page
    * Default settings, with example page elements
  * [$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML)]($(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML)) *([$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include)$(COMPOSER_EXT_DEFAULT)]($(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include)$(COMPOSER_EXT_DEFAULT)))*
    * Automatically generated digest page
    * All settings modified
  * [$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)]($($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)) *([$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)]($($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)))*
    * Written for $(COMPOSER_BASENAME), manual titles and formatting
    * All settings changed, with chained menus
  * [$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)]($(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)) *([$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)]($(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)))*
    * Written for $(COMPOSER_BASENAME), manual titles and formatting
    * All settings changed, with changed configuration of top menu
  * [$(CONFIGS)/$(PUBLISH)-$(TESTING).$(EXTN_HTML)]($(CONFIGS)/$(PUBLISH)-$(TESTING).$(EXTN_HTML)) *([$(CONFIGS)/$(COMPOSER_SETTINGS)]($(CONFIGS)/$(COMPOSER_SETTINGS)))*
    * #WORKING:NOW
    * #WORKING:NOW
  * [$(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)]($(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)) *([$(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)]($(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)))*
    * Written for $(COMPOSER_BASENAME), automatic titles and formatting
    * Default settings, with all page elements empty
  * [$(CONFIGS)/$(notdir $(PANDOC_DIR))/MANUAL.$(EXTN_HTML)]($(CONFIGS)/$(notdir $(PANDOC_DIR))/MANUAL.$(EXTN_HTML)) *([$(CONFIGS)/$(notdir $(PANDOC_DIR))/MANUAL$(COMPOSER_EXT_DEFAULT)]($(CONFIGS)/$(notdir $(PANDOC_DIR))/MANUAL$(COMPOSER_EXT_DEFAULT)))*
    * External file, written in default syntax, without $(COMPOSER_BASENAME) automatic formatting
    * Inherited settings and page elements, with changed configuration of top menu
  * [$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/introduction.$(EXTN_HTML)]($($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/introduction.$(EXTN_HTML)) *([$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/introduction$(COMPOSER_EXT_DEFAULT)]($($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/introduction$(COMPOSER_EXT_DEFAULT)))*
    * #WORKING:NOW
    * #WORKING:NOW

  * [$(COMPOSER_BASENAME) $(OUT_README)](<composer_root>/../$(OUT_README).$(PUBLISH).$(EXTN_HTML))
  * [Introduction](<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML))
  * [Default Site](<composer_root>/$(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML))
  * [Configured Site](<composer_root>/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML))
  * [Default Digest Page](<composer_root>/$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML))
  * [Configured Digest Page](<composer_root>/$(CONFIGS)/$($(PUBLISH)-$(EXAMPLE)-include).$(EXTN_HTML))
  * [Default Markdown File](<composer_root>/$(CONFIGS)/$(notdir $(PANDOC_DIR))/MANUAL.$(EXTN_HTML))
  * [Configured Markdown File](<composer_root>/$($(PUBLISH)-$(EXAMPLE)-$(CONFIGS)-dir)/introduction.$(EXTN_HTML))
  * [Elements & Includes](<composer_root>/$(CONFIGS)/$(PUBLISH)-$(TESTING).$(EXTN_HTML))

#WORKING:NOW swap out the config/index, which is a test of a composer.mk page build, with the .nav/.spacer tokens

The rest below is an example "digest" page, created from the most recent pages, in reverse chronological order.

At the very bottom of the page is an example of including a file to emulate a comments section.

$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) spacer $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) Default Configuration $(PUBLISH_BUILD_CMD_END)

#WORKING:NOW default css
#WORKING:NOW integrate this (and as much of the rest as makes sense) into $(HELPOUT), and back-port as $(MAKE) / DO_HEREDOC

| $(PUBLISH)-config | defaults
|:---|:---|
| cols_main_size   | $(PUBLISH_COLS_MAIN_SIZE)
| cols_mobile_hide | $(PUBLISH_COLS_MOBILE_HIDE)
| cols_sticky      | $(PUBLISH_COLS_STICKY)
| copy_safe        | $(PUBLISH_COPY_SAFE)

| $(PUBLISH)-library | defaults
|:---|:---|
| folder           | $(LIBRARY_FOLDER)
| auto_update      | $(LIBRARY_AUTO_UPDATE)
| digest_title     | $(LIBRARY_DIGEST_TITLE)
| digest_count     | $(LIBRARY_DIGEST_COUNT)
| digest_expanded  | $(LIBRARY_DIGEST_EXPANDED)
| digest_chars     | $(LIBRARY_DIGEST_CHARS)
| digest_spacer    | $(LIBRARY_DIGEST_SPACER)
| digest_continue  | $(LIBRARY_DIGEST_CONTINUE)
| digest_permalink | $(LIBRARY_DIGEST_PERMALINK)

*(For this test site, the library has been enabled as `$($(PUBLISH)-$(EXAMPLE)-folder)`, along with `auto_update`.)*

$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
endef

########################################
#### {{{4 Heredoc: Page: Config --------

override define $(PUBLISH)-$(EXAMPLE)-page-$(CONFIGS) =
---
pagetitle: Configuration Testing
date: 2040-01-01
---
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) #WORKING:NOW $(PUBLISH_BUILD_CMD_END)

#WORKING:NOW

$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) spacer $(PUBLISH_BUILD_CMD_END)
$(PUBLISH_BUILD_CMD_BEG) box-begin $(DEPTH_MAX) Configuration Settings $(PUBLISH_BUILD_CMD_END)

| $(PUBLISH)-config | defaults | values
|:---|:---|:---|
| cols_main_size   | $(PUBLISH_COLS_MAIN_SIZE) | 8
| cols_mobile_hide | $(PUBLISH_COLS_MOBILE_HIDE) | 0
| cols_sticky      | $(PUBLISH_COLS_STICKY) | 0
| copy_safe        | $(PUBLISH_COPY_SAFE) | 0

| $(PUBLISH)-library | defaults | values
|:---|:---|:---|
| folder           | $(LIBRARY_FOLDER) | $($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))
| auto_update      | $(LIBRARY_AUTO_UPDATE) | 1
| digest_title     | $(LIBRARY_DIGEST_TITLE) | Digest
| digest_count     | $(LIBRARY_DIGEST_COUNT) | 20
| digest_expanded  | $(LIBRARY_DIGEST_EXPANDED) | 5
| digest_chars     | $(LIBRARY_DIGEST_CHARS) | 2048
| digest_spacer    | $(LIBRARY_DIGEST_SPACER) | 0
| digest_continue  | $(LIBRARY_DIGEST_CONTINUE) | \*(continued)\*
| digest_permalink | $(LIBRARY_DIGEST_PERMALINK) | (permalink)

$(PUBLISH_BUILD_CMD_BEG) box-end $(PUBLISH_BUILD_CMD_END)
endef

########################################
#### {{{4 Heredoc: Page: Nothing -------

override define $(PUBLISH)-$(EXAMPLE)-page-$(NOTHING) =
---
title: Empty Configuration
author: $(COMPOSER_COMPOSER)
date: 1970-01-01
---
$(PUBLISH_BUILD_CMD_BEG) title-block box $(DEPTH_MAX) $(PUBLISH_BUILD_CMD_END)

All the settings and menus are empty for this page, except for this content.  This file was written for $(COMPOSER_BASENAME), so the page title and layout were done automatically.

  * *Source file: [_$(PUBLISH)/$(patsubst .%,%,$(NOTHING))/$($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT)]($($(PUBLISH)-$(EXAMPLE)-main)$(COMPOSER_EXT_DEFAULT))*
  * *Main page: [_$(PUBLISH)/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)](<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML))*
endef

########################################
#### {{{4 Heredoc: Config: Main --------

override define $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML) =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH)-$(EXAMPLE))
################################################################################

variables:

  title-prefix:				EXAMPLE SITE

  $(PUBLISH)-config:				{}

  $(PUBLISH)-library:
    folder:				$($(PUBLISH)-$(EXAMPLE)-folder)
    auto_update:			1

  $(PUBLISH)-nav-top:
    MAIN:				<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)
    CHAINED:
      $(MENU_SELF): "#"
      ITEM 1: "#"
      ITEM 2: "#"
      ITEM 3: "#"

  $(PUBLISH)-nav-bottom:
    CHAINED:				<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)

  $(PUBLISH)-nav-left:
    - .spacer
    - text: |
        CHAINED TEXT

  $(PUBLISH)-nav-right:
    - .spacer
    - box-begin $(DEPTH_MAX) CHAINED
    - text: |
        CHAINED TEXT
    - box-end

################################################################################
# End Of File
################################################################################
endef

########################################
#### {{{4 Heredoc: Config: Config ------

override define $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)-$(CONFIGS) =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH)-$(EXAMPLE) = $(CONFIGS))
################################################################################

variables:

  $(PUBLISH)-config:
    cols_main_size:			8
    cols_mobile_hide:			0
    cols_sticky:			0
    copy_safe:				0

  $(PUBLISH)-library:
    folder:				$($(PUBLISH)-$(EXAMPLE)-folder-$(CONFIGS))
    auto_update:			1
    digest_title:			Digest
    digest_count:			20
    digest_expanded:			5
    digest_chars:			2048
    digest_spacer:			0
    digest_continue:			"*(continued)*"
    digest_permalink:			(permalink)

  $(PUBLISH)-nav-top:
    MAIN:
      $(MENU_SELF): "#"
      CHAINED:				<composer_root>/$($(PUBLISH)-$(EXAMPLE)-main).$(EXTN_HTML)

################################################################################
# End Of File
################################################################################
endef

########################################
#### {{{4 Heredoc: Config: Nothing -----

override define $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)-$(NOTHING) =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH)-$(EXAMPLE) = $(NOTHING))
################################################################################

variables:

  title-prefix:				null

  $(PUBLISH)-config:				null
  $(PUBLISH)-library:				null
  $(PUBLISH)-nav-top:				null
  $(PUBLISH)-nav-bottom:			null
  $(PUBLISH)-nav-left:			null
  $(PUBLISH)-nav-right:			null
  $(PUBLISH)-info-top:			null
  $(PUBLISH)-info-bottom:			null

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 $(INSTALL) ---------------------

.PHONY: $(INSTALL)
#>$(INSTALL): .set_title-$(INSTALL)
$(INSTALL): $(INSTALL)-$(SUBDIRS)-$(HEADERS)
$(INSTALL):
#>	@$(call $(HEADERS))
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_BASENAME)_Directory)
else
	@if	[ "$(COMPOSER_ROOT)" = "$(CURDIR)" ]; \
	then \
		if	[ -f "$(CURDIR)/$(MAKEFILE)" ] && \
			[ "$(COMPOSER_DOITALL_$(INSTALL))" != "$(DOFORCE)" ]; \
		then \
			$(call $(HEADERS)-note,$(CURDIR),$(_H)Main_$(MAKEFILE)); \
		fi; \
		if	[ "$(COMPOSER_DOITALL_$(INSTALL))" = "$(DOFORCE)" ]; \
		then \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME),-$(INSTALL),$(COMPOSER)); \
			$(ECHO) "$(_S)"; \
			$(MV) $(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME) $(CURDIR)/$(MAKEFILE) $($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
		else \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL),$(COMPOSER)); \
		fi; \
	elif	[ "$(MAKELEVEL)" = "0" ]; \
	then \
		if	[ "$(COMPOSER_DOITALL_$(INSTALL))" = "$(DOFORCE)" ]; \
		then \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME),-$(INSTALL)); \
			$(ECHO) "$(_S)"; \
			$(MV) $(CURDIR)/$(MAKEFILE).$(COMPOSER_BASENAME) $(CURDIR)/$(MAKEFILE) $($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
		else \
			$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL)); \
		fi; \
	fi
endif
ifneq ($(COMPOSER_DOITALL_$(INSTALL)),)
	@$(foreach FILE,$(filter-out $(NOTHING),$(filter-out $(NOTHING)-%,$(COMPOSER_SUBDIRS))),\
		$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(FILE)/$(MAKEFILE),-$(INSTALL)); \
	)
	@$(MAKE) $(INSTALL)-$(SUBDIRS)
endif

override define $(INSTALL)-$(MAKEFILE) =
	if	[ "$(COMPOSER_DOITALL_$(@))" != "$(DOFORCE)" ] && \
		[ -z "$(4)" ] && \
		[ -f "$(1)" ]; \
	then \
		$(call $(HEADERS)-skip,$(abspath $(dir $(1))),$(notdir $(1))); \
	else \
		$(call $(HEADERS)-file,$(abspath $(dir $(1))),$(notdir $(1))); \
		$(MAKE) $(SILENT) --makefile $(COMPOSER) COMPOSER_DOCOLOR= COMPOSER_DEBUGIT= .$(EXAMPLE)$(2) >$(1); \
	fi; \
	if [ -n "$(3)" ]; then \
		$(SED) -i \
			"s|^($(call COMPOSER_REGEX_OVERRIDE,COMPOSER_TEACHER)).*$$|\1 $(~)(abspath $(~)(COMPOSER_MY_PATH)/`$(REALPATH) $(abspath $(dir $(1))) $(3)`)|g" \
			$(1); \
	fi
endef

########################################
## {{{2 $(CLEANER) ---------------------

.PHONY: $(CLEANER)
#>$(CLEANER): .set_title-$(CLEANER)
$(CLEANER): $(CLEANER)-$(SUBDIRS)-$(HEADERS)
$(CLEANER):
#>	@$(call $(HEADERS))
#>	@$(call $(CLEANER)-logs)
ifneq ($(COMPOSER_LOG),)
ifneq ($(wildcard $(CURDIR)/$(COMPOSER_LOG)),)
	@$(call $(HEADERS)-rm,$(CURDIR),$(COMPOSER_LOG))
	@$(ECHO) "$(_S)"
	@$(RM) $(CURDIR)/$(COMPOSER_LOG) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
endif
ifneq ($(wildcard $(COMPOSER_TMP)),)
	@$(call $(HEADERS)-rm,$(CURDIR),$(notdir $(COMPOSER_TMP)))
	@$(ECHO) "$(_S)"
	@$(RM) --recursive $(COMPOSER_TMP) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
	@$(call $(PUBLISH)-$(CLEANER))
	@$(if $(shell $(strip $(call $(TARGETS)-$(PRINTER),$(CLEANER)))),\
		$(eval export $(COMPOSER_OPTIONS)) \
		$(MAKE) $$($(strip $(call $(TARGETS)-$(PRINTER),$(CLEANER)))) \
	)
	@$(foreach FILE,$(COMPOSER_TARGETS),\
		if	[ "$(FILE)" != "$(NOTHING)" ] && \
			[ -f "$(FILE)" ]; \
		then \
			$(call $(HEADERS)-rm,$(CURDIR),$(FILE)); \
			$(ECHO) "$(_S)"; \
			$(RM) $(CURDIR)/$(FILE) $($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
		fi; \
		$(call NEWLINE) \
	)
ifneq ($(COMPOSER_DOITALL_$(CLEANER)),)
	@$(MAKE) $(CLEANER)-$(SUBDIRS)
endif

override define $(CLEANER)-logs =
	if	[ -n "$(COMPOSER_KEEPING)" ] && \
		[ -n "$(COMPOSER_LOG)" ] && \
		[ -f "$(CURDIR)/$(COMPOSER_LOG)" ] && \
		[ "$$($(CAT) $(CURDIR)/$(COMPOSER_LOG) | $(WC))" -gt "$(COMPOSER_KEEPING)" ]; \
	then \
		$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_LOG),$(CLEANER)-logs); \
		$(ECHO) "$(_S)"; \
		$(MV) $(CURDIR)/$(COMPOSER_LOG) $(CURDIR)/$(COMPOSER_LOG).$(@) $($(DEBUGIT)-output); \
		$(TAIL) -n$(COMPOSER_KEEPING) $(CURDIR)/$(COMPOSER_LOG).$(@) >$(CURDIR)/$(COMPOSER_LOG); \
		$(RM) $(CURDIR)/$(COMPOSER_LOG).$(@) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi; \
	if	[ -d "$(COMPOSER_TMP)" ] && \
		[ "$$($(LS_TIME) $(COMPOSER_TMP)/{.[^.],}* 2>/dev/null | $(WC))" -gt "$(COMPOSER_KEEPING)" ]; \
	then \
		$(call $(HEADERS)-note,$(CURDIR),$(notdir $(COMPOSER_TMP)),$(CLEANER)-logs); \
		$(ECHO) "$(_S)"; \
		$(RM) --recursive $$( \
				$(LS_TIME) $(COMPOSER_TMP)/{.[^.],}* 2>/dev/null \
				| $(TAIL) -n+$(COMPOSER_KEEPING) \
			) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

########################################
## {{{2 $(DOITALL) ---------------------

.PHONY: $(DOITALL)
#>$(DOITALL): .set_title-$(DOITALL)
$(DOITALL): $(DOITALL)-$(SUBDIRS)-$(HEADERS)
$(DOITALL):
#>	@$(call $(HEADERS))
	@$(call $(CLEANER)-logs)
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifneq ($(COMPOSER_DEPENDS),)
	@$(MAKE) $(DOITALL)-$(SUBDIRS)
endif
endif
	@$(if $(shell $(strip $(call $(TARGETS)-$(PRINTER),$(DOITALL)))),\
		$(eval export $(COMPOSER_OPTIONS)) \
		$(MAKE) $$($(strip $(call $(TARGETS)-$(PRINTER),$(DOITALL)))) \
	)
ifeq ($(COMPOSER_TARGETS),)
	@$(MAKE) $(NOTHING)-$(TARGETS)
else ifeq ($(COMPOSER_TARGETS),$(NOTHING))
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(TARGETS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_TARGETS)),)
	@$(MAKE) $(COMPOSER_TARGETS)
else
	@$(eval export $(COMPOSER_OPTIONS)) \
		$(MAKE) $(if $(COMPOSER_DEBUGIT),,$(SILENT)) $(DOITALL)-$(TARGETS)
endif
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(COMPOSER_DEPENDS),)
	@$(MAKE) $(DOITALL)-$(SUBDIRS)
endif
endif

#WORK document!
.PHONY: $(DOITALL)-$(TARGETS)
$(DOITALL)-$(TARGETS): $(COMPOSER_TARGETS)
$(DOITALL)-$(TARGETS):
	@$(ECHO) ""

########################################
## {{{2 $(SUBDIRS) ---------------------

.PHONY: $(SUBDIRS)
$(SUBDIRS): .set_title-$(SUBDIRS)
$(SUBDIRS): $(NOTHING)-$(NOTHING)-$(TARGETS)-$(SUBDIRS)
$(SUBDIRS):
	@$(ECHO) ""

override define $(SUBDIRS)-$(EXAMPLE) =
.PHONY: $(1)-$(SUBDIRS)-$(HEADERS)
ifeq ($(MAKELEVEL),0)
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
	@$$(eval override $$(@) := $$(CURDIR)/$$(patsubst $(1)-$$(SUBDIRS)-%,%,$$(@)))
	@$$(if $$(wildcard $$($$(@))/$$(MAKEFILE)),\
		$$(MAKE) --directory $$($$(@)) $(1) ,\
		$$(MAKE) --directory $$($$(@)) --makefile $$(COMPOSER) $$(NOTHING)-$$(MAKEFILE) \
	)
endef

$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(INSTALL)))
$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(CLEANER)))
$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(DOITALL)))

########################################
## {{{2 $(PRINTER) ---------------------

.PHONY: $(PRINTER)
$(PRINTER): .set_title-$(PRINTER)
$(PRINTER): $(HEADERS)-$(PRINTER)
$(PRINTER): $(PRINTER)-$(PRINTER)
$(PRINTER):
	@$(ECHO) ""

#WORK document?  do we really need to document every last target...?
.PHONY: $(PRINTER)-$(PRINTER)
$(PRINTER)-$(PRINTER): $(if $(COMPOSER_LOG),\
	$(COMPOSER_LOG) ,\
	$(NOTHING)-COMPOSER_LOG \
)
$(PRINTER)-$(PRINTER):
	@$(ECHO) ""

$(COMPOSER_LOG): $(if $(COMPOSER_EXT),\
	$(COMPOSER_CONTENTS_EXT) ,\
	$(NOTHING)-COMPOSER_EXT \
)
$(COMPOSER_LOG):
	@$(LS) --directory \
		$(COMPOSER_LOG) \
		$(filter-out $(NOTHING)-COMPOSER_EXT,$(?)) \
		|| $(TRUE)

################################################################################
# {{{1 Pandoc Targets ----------------------------------------------------------
################################################################################

########################################
## {{{2 $(COMPOSER_PANDOC) -------------

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(c_base).$(EXTENSION)
$(COMPOSER_PANDOC):
	@$(call $(COMPOSER_PANDOC)-c_list_plus)
	@$(call $(COMPOSER_PANDOC)-$(NOTHING))
ifneq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-note,$(c_base) $(MARKER) $(c_type),c_list=\"$(c_list)\" (+)=\"$(c_list_plus)\")
endif

ifneq ($(COMPOSER_YML_LIST),)
$(c_base).$(EXTENSION): $(COMPOSER_YML_LIST)
endif
ifneq ($(c_site),)
$(c_base).$(EXTN_HTML): $($(PUBLISH)-cache)
endif

$(c_base).$(EXTENSION): $(c_list)
$(c_base).$(EXTENSION):
	@$(call $(COMPOSER_PANDOC)-c_list_plus)
	@$(call $(COMPOSER_PANDOC)-$(NOTHING))
	@$(call $(HEADERS)-$(COMPOSER_PANDOC),$(@))
ifneq ($(PANDOC_OPTIONS_ERROR),)
	@$(ENDOLINE)
	@$(PRINT) "$(_F)$(MARKER) ERROR: $(c_base).$(EXTENSION): $(call PANDOC_OPTIONS_ERROR)" >&2
	@$(ENDOLINE)
	@exit 1
endif
ifneq ($(c_site),)
	@$(call $(HEADERS)-note,$(CURDIR),$(if $(c_list_plus),$(c_list_plus),$(c_list))$(_D) $(MARKER) $(_E)$(notdir $(COMPOSER_TMP))/$(@).$(DATENAME)$(COMPOSER_EXT_DEFAULT),$(PUBLISH))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_TMP) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call $(PUBLISH)-$(TARGETS),$(COMPOSER_TMP)/$(notdir $(@)).$(DATENAME)$(COMPOSER_EXT_DEFAULT))
ifneq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-$(COMPOSER_PANDOC),$(@))
endif
endif
ifeq ($(c_type),$(TYPE_LPDF))
	@$(call $(HEADERS)-note,$(CURDIR),$(if $(c_list_plus),$(c_list_plus),$(c_list))$(_D) $(MARKER) $(_E)$(notdir $(COMPOSER_TMP))/$(@).$(DATENAME),$(TYPE_LPDF))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_TMP)/$(notdir $(@)).$(DATENAME) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
	@$(ECHO) "$(_F)"
#>	@$(PANDOC) $(subst ",\",$(call PANDOC_OPTIONS))
	@$(PANDOC) $(call PANDOC_OPTIONS)
	@$(ECHO) "$(_D)"
ifneq ($(COMPOSER_LOG),)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP) $(subst ",\",$(call PANDOC_OPTIONS))\n" >>$(CURDIR)/$(COMPOSER_LOG)
endif
ifneq ($(COMPOSER_DEBUGIT),)
ifneq ($(c_site),)
	@$(call $(HEADERS)-note,$(c_base) $(MARKER) c_site,c_list=\"$(c_list)\" (+)=\"$(c_list_plus)\")
else
	@$(call $(HEADERS)-note,$(c_base) $(MARKER) $(c_type),c_list=\"$(c_list)\" (+)=\"$(c_list_plus)\")
endif
endif

override define $(COMPOSER_PANDOC)-c_list_plus =
	$(eval override c_list_plus := $(filter-out .set_title-%,$(+)))
	$(eval override c_list_plus := $(filter-out $(COMPOSER_YML_LIST),$(c_list_plus)))
	$(eval override c_list_plus := $(filter-out $($(PUBLISH)-cache),$(c_list_plus)))
	$(eval override c_list_plus := $(filter-out $($(PUBLISH)-library),$(c_list_plus)))
	$(eval override c_list_plus := $(filter-out $(c_list),$(c_list_plus)))
endef

override define $(COMPOSER_PANDOC)-$(NOTHING) =
	if	[ -z "$(c_type)" ] || \
		[ -z "$(c_base)" ] || \
		[ -z "$(if $(c_list_plus),$(c_list_plus),$(c_list))" ]; \
	then \
		$(call $(HEADERS)-note,$(COMPOSER_PANDOC),c_type=\"$(c_type)\" c_base=\"$(c_base)\" c_list=\"$(c_list)\" (+)=\"$(c_list_plus)\",$(NOTHING)); \
		exit 1; \
	fi
endef

########################################
## {{{2 $(COMPOSER_EXT) ----------------

#> update: TYPE_TARGETS

override define TYPE_TARGETS =
%.$(2): \
	$$(COMPOSER_YML_LIST) \
	$$(if $$(and \
		$$(c_site) ,\
		$$(filter %.$$(EXTN_HTML),$(2)) \
		),\
		$$($$(PUBLISH)-cache) \
	) \
	%$$(COMPOSER_EXT)
	@$$(call $$(COMPOSER_PANDOC)-c_list_plus)
	@$$(eval export $$(COMPOSER_OPTIONS)) \
		$$(MAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(if $$(c_list_plus),$$(c_list_plus),$$(c_list))"
ifneq ($$(COMPOSER_DEBUGIT),)
	@$$(call $$(HEADERS)-note,$$(*) $$(MARKER) $(1),c_list=\"$$(c_list)\" (+)=\"$$(c_list_plus)\",extension)
endif

%.$(2): \
	$$(COMPOSER_YML_LIST) \
	$$(if $$(and \
		$$(c_site) ,\
		$$(filter %.$$(EXTN_HTML),$(2)) \
		),\
		$$($$(PUBLISH)-cache) \
	) \
	%
	@$$(call $$(COMPOSER_PANDOC)-c_list_plus)
	@$$(eval export $$(COMPOSER_OPTIONS)) \
		$$(MAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(if $$(c_list_plus),$$(c_list_plus),$$(c_list))"
ifneq ($$(COMPOSER_DEBUGIT),)
	@$$(call $$(HEADERS)-note,$$(*) $$(MARKER) $(1),c_list=\"$$(c_list)\" (+)=\"$$(c_list_plus)\",wildcard)
endif

%.$(2): \
	$$(COMPOSER_YML_LIST) \
	$$(if $$(and \
		$$(c_site) ,\
		$$(filter %.$$(EXTN_HTML),$(2)) \
		),\
		$$($$(PUBLISH)-cache) \
	) \
	$$(c_list)
	@$$(call $$(COMPOSER_PANDOC)-c_list_plus)
	@$$(eval export $$(COMPOSER_OPTIONS)) \
		$$(MAKE) $$(COMPOSER_PANDOC) c_type="$(1)" c_base="$$(*)" c_list="$$(if $$(c_list_plus),$$(c_list_plus),$$(c_list))"
ifneq ($$(COMPOSER_DEBUGIT),)
	@$$(call $$(HEADERS)-note,$$(*) $$(MARKER) $(1),c_list=\"$$(c_list)\" (+)=\"$$(c_list_plus)\",list)
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

################################################################################
# }}}1
################################################################################
# End Of File
################################################################################
