#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################
override VIM_OPTIONS := vim: filetype=make nowrap noexpandtab tabstop=8 list listchars=tab\:,.,trail\:=,extends\:>,precedes\:< foldenable foldmethod=marker foldlevel=0 foldtext=printf('%1s\ [%4s\ %5s-%5s]\ %-0.1s\ %s\ ',v\:foldlevel,(v\:foldend\ \-\ v\:foldstart\ \+\ 1),v\:foldstart,v\:foldend,v\:folddashes,substitute(getline(v\:foldstart),'\ \{\{\{\\d\\\+\ \\\|\\s\\\+','\ ','g'))
override VIM_FOLDING = $(subst -,$(if $(2),},{),---$(if $(1),$(1),1))
################################################################################
# {{{1 IMPORTANT NOTES
################################################################################
# This Makefile is the very heart of Composer CMS.  All the other files in the
# repository are sourced from it.  It is the only file needed to re-create the
# entire directory.  This one file *IS* Composer CMS.
#
# The author of Composer CMS uses the Vim editor, because it is the bestest text
# editor in the whole wide world.  You should consider using it, too.  ;^}
#
# If you are not, this file will likely appear as one big long stream of text,
# which is perfectly fine... I guess.  It has been structured and formatted in
# such a way as to to support this.
#
# However... if you are an awesome Vim user like me, it is highly recommended
# that you enable "modeline", which will use the optimized settings above.  The
# "folding" feature has been used extensively, which makes this monstrosity much
# easier to work with, and the folding headers have also been prettified in the
# "modeline" above.  Other touches, such as "nowrap" and "tabstop" will also
# preserve your sanity when wading into this behemoth.  The quickest way to
# purchase these options, and a whole lot more, is to run the following Vim
# commands (or, better yet, put them in your ".vimrc"):
#
#	:set modeline
#	:set modelines=5
#	:set modelineexpr
#	:syntax on
#	:highlight comment guibg=black ctermbg=none guifg=darkgreen ctermfg=darkgreen
#	:highlight folded guibg=darkblue ctermbg=darkblue guifg=darkcyan ctermfg=darkcyan
#
# Whatever editor you are using... if you are not using a "tabstop" of "8", this
# file will absolutely make your eyes bleed.  You have been warned.  I'm
# honestly amazed you are reading it in the first place.  <^D
#
# With all sincerity, though, thank you for your interest in Composer CMS.  It
# has been a labor of love, and I believe it is an extraordinarily powerful
# toolkit for text-based command-line warriors like us.  I hope it serves you as
# well as it serves me.
#
# Happy Hacking!
################################################################################
# {{{1 RELEASE PROCESS
################################################################################
# UPDATE
#	* Tooling Versions
#	* Pandoc Options
#		* `TYPE_TARGETS`
#		* `PANDOC_OPTIONS`
#		* `PANDOC_OPTIONS_ERROR`
# VERIFY
#	* `env - USER="${USER}" HOME="${HOME}" PATH="${PATH}" make _setup-all`
#		* `rm ~/.vimrc; vi Makefile`
#	* `make COMPOSER_DEBUGIT="1" _release`
#		* `make _update-list`
#		* `make _test-dir`
#		* `make _test-list`
#		* `make _test-file`
#	* `make COMPOSER_DEBUGIT="check config targets" _debug | less -rX`
#		* `rm Composer-*._debug-*.txt`
#			* `make COMPOSER_DEBUGIT="help" _debug-file`
#			* `mv Composer-*._debug-*.txt artifacts/`
#		* `make COMPOSER_DEBUGIT="1" targets`
#			* `make COMPOSER_DEBUGIT="1" c_site="1" c_base="README.site" targets`
#	* `make headers-template`
#		* `make COMPOSER_DEBUGIT="1" headers-template`
#		* `make COMPOSER_DEBUGIT="1" c_type="[X]" headers-template-all`
#		* `make headers-template-all`
#	* `make _test-targets`
#		* README.html.0.0.html
#		* README.html.1.1.html
#		* README.html.x.x.html
#		* README.pdf.0.0.pdf
#		* README.pdf.2.2.pdf
#		* README.pdf.x.1.pdf
#		* README.pdf.x.x.pdf
#		* README.epub.0.0.epub
#		* README.epub.x.1.epub
#		* README.epub.x.2.epub
#		* README.epub.x.3.epub
#		* README.epub.x.x.epub
#		* README.revealjs.html.0.0.revealjs.html
#		* README.revealjs.html.1.1.revealjs.html
#		* README.revealjs.html.x.x.revealjs.html
#		* README.docx.0.0.docx
#		* README.docx.1.1.docx
#		* README.docx.x.x.docx
#	* Test: Bootstrap
#		* Browsers
#			* Desktop
#			* Mobile
#			* Text-based
#		* Pages
#			* README.site.html
#				* `make _setup-all`
#					* `make COMPOSER_DEBUGIT="1" _setup-all`
#			* _site/index.html
#				* `make site-template`
#					* `make COMPOSER_DEBUGIT="1" site-template`
#				* `make site-template-_test`
#					* `make COMPOSER_DEBUGIT="1" site-template-_test`
#					* `make site-list`
#					* `make site-list-null.md`
#				* `make site-template-config`
#					* `make site-all`
#					* `make site-force`
#				* `make MAKEJOBS="0" site-template`
#			* _site
#				* `make site-list`
#				* `make site-list-list`
#				* `make site-list-null`
#				* `make site-list-all`
#				* `make site-list-index.md`
#		* Paths
#			* `override COMPOSER_EXPORT_DEFAULT := $(COMPOSER_ROOT)/../+$(COMPOSER_BASENAME)`
#			* `override PUBLISH_ROOT := $(CURDIR)/+$(PUBLISH)`
#			* `override PUBLISH_DIRS := [...] +$(CONFIGS)`
#	* Test: Performance
#		* `time make COMPOSER_DEBUGIT="0" FAIL`
#			* `time make COMPOSER_DEBUGIT="0" FAIL 2>&1 | grep -E "^[+]"`
#			* Make sure '--trace' debug output is identical
#			* Minimize '$(shell)' and '/: override .* $(shell' calls
#			* With and without 'c_site' enabled
#		* `time make README.site.html`
#			* `time make -C _site/config config`
#			* `time make -C _site/config/_library-config config`
#		* `make _test-speed`
#			* `make MAKEJOBS="[X]" _test-speed`
#			* `make MAKEJOBS="[X]" COMPOSER_DEBUGIT="1" _test-speed`
#			* Update comments
# PREPARE
#	* Update: Makefile
#		* Formatting
#			* `make _test-heredoc`
#		* Markers
#			* '#>[ ]'
#			* '#>[^ ]'
#	* Update: README.md
#		* `make COMPOSER_DEBUGIT="1" help-help | less -rX`
#			* `make COMPOSER_DOCOLOR= COMPOSER_DEBUGIT="1" help-help | less -rX`
#			* `override INPUT := commonmark`
#				* `PANDOC_EXTENSIONS`
#			* Output
#				* Fits in $(COLUMNS) characters
#				* Mouse select color handling
#				* Test all "Reference" links in browser
#				* Spell check
#		* `make README.html`
#			* Minimize: `<col style="width: *%" />`
#		* `make _setup-all`
#			* Review each, including CSS
#			* Create screenshot
# PUBLISH
#	* Check: `git diff main Makefile`
#	* Update: COMPOSER_VERSION
#	* Release: `rm -frv {.[^.],}*; make _release`
#	* Verify: `git diff main`
#	* Commit: `git commit`, `git tag`
#	* Branch: `git branch -D main`, `git checkout -B main`, `git checkout devel`
################################################################################
# {{{1 TODO
################################################################################
# CODE
#	--resource-path = integrate with COMPOSER_ART, COMPOSER_INCLUDES_TREE, etc...?
#	add aria information back in, because we are good people...
#		https://getbootstrap.com/docs/5.2/components/dropdowns/#accessibility
#		https://getbootstrap.com/docs/4.5/utilities/screen-readers
#	remove once fixed in upstream
#		[Google Firebase] = $(UPGRADE)-$(notdir $(FIREBASE_DIR))
#		$(MKDIR) $(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR))/vendor
#		MDVIEWER_FIX_SASS_VER
#	$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_EXT_DEFAULT)
#		$(SED) -i "/^[[][_]/d" $(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
# HTML
#	metadata / keywords
# PDF / EPUB / DOCX
#	man pandoc = REPRODUCIBLE BUILDS = https://pandoc.org/MANUAL.html#reproducible-builds
#		Some of the document formats pandoc targets (such as EPUB, docx, and ODT) include build timestamps in the generated document.  That means that the files generated on successive builds will differ, even if the source does not.  To avoid this, set the SOURCE_DATE_EPOCH environment variable, and the timestamp will be taken from it instead of the current time.  SOURCE_DATE_EPOCH should contain an integer unix timestamp (specifying the number of second since midnight UTC January 1, 1970).
#		Some document formats also include a unique identifier.  For EPUB, this can be set explicitly by setting the identifier metadata field (see EPUB Metadata, above).
# PDF
#	two different templates, with an option, for left/right versus left-only headers/footers
#		maybe also a customizable version, akin to the resume and agreement formats i use
#		these can live in an "artifacts/templates" directory, and can be "ln" as ".composer-pdf.header" or "file.pdf.header", as desired
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
#	--from "docx+styles"
#	--from "docx" --track-changes="all"
#	--from "docx|epub" --extract-media="[...]"
################################################################################
# }}}1
################################################################################
# {{{1 Composer Globals
################################################################################

override COMPOSER_CNAME			:= garybgenett.net
override COMPOSER_HOMEPAGE		:= http://www.$(COMPOSER_CNAME)/projects/composer
override COMPOSER_REPOPAGE		:= https://github.com/garybgenett/composer
override COMPOSER_VERSION		:= v3.1

override COMPOSER_COMPOSER		:= Gary B. Genett
override COMPOSER_BASENAME		:= Composer
override COMPOSER_TINYNAME		:= composer
override COMPOSER_TECHNAME		:= $(COMPOSER_BASENAME) CMS
override COMPOSER_FULLNAME		:= $(COMPOSER_TECHNAME) $(COMPOSER_VERSION)
override COMPOSER_FILENAME		:= $(COMPOSER_BASENAME)-$(COMPOSER_VERSION)

override COMPOSER_HEADLINE		:= $(COMPOSER_TECHNAME): Content Make System
override COMPOSER_LICENSE		:= $(COMPOSER_TECHNAME) License
#>override COMPOSER_CLOSING		:= Go Make A Thing
override COMPOSER_CLOSING		:= Go Do A Thing
override COMPOSER_TAGLINE		:= *Happy Making!*

override COPYRIGHT_FULL			:= Copyright (c) 2014, 2015, 2022, $(COMPOSER_COMPOSER)
override COPYRIGHT_SHORT		:= Copyright (c) 2022, $(COMPOSER_COMPOSER)
override CREATED_TAGLINE		:= Composed with $(COMPOSER_TECHNAME)

override COMPOSER_TIMESTAMP		= [$(COMPOSER_FULLNAME) $(DIVIDE) $(DATESTAMP)]

########################################

override MARKER				:= >>
override DIVIDE				:= ::
override EXPAND				:= ...
override TOKEN				:= ~---~
override NULL				:=

override define NEWLINE =
$(NULL)
$(NULL)
endef

########################################

override SPECIAL_VAL			:= 0
override CSS_ALT			:= css_alt

override COLUMNS			:= 80
override EOL				:= lf

override HEAD_MAIN			:= 1
override DEPTH_DEFAULT			:= 2
override DEPTH_MAX			:= 6

########################################

override COMPOSER_SETTINGS		:= .$(COMPOSER_TINYNAME).mk
override COMPOSER_YML			:= .$(COMPOSER_TINYNAME).yml

override COMPOSER_LOG_DEFAULT		:= .$(COMPOSER_TINYNAME).log
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
override COMPOSER_CONV			= $(patsubst $(COMPOSER_DIR)/%,$(1)%,$(patsubst $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/%,$(1)%,$(2)))

#> update: includes duplicates
override EXPORTS			:= export
override PUBLISH			:= site

override COMPOSER_EXPORT_DEFAULT	:= $(COMPOSER_ROOT)/+$(COMPOSER_BASENAME)
override COMPOSER_EXPORT		:= $(COMPOSER_EXPORT_DEFAULT)

override COMPOSER_LIBRARY_ROOT		:=
override COMPOSER_LIBRARY		:=

override COMPOSER_SRC			:= $(COMPOSER_DIR)/.sources
override COMPOSER_ART			:= $(COMPOSER_DIR)/artifacts
override COMPOSER_BIN			:= $(COMPOSER_DIR)/bin

override COMPOSER_CUSTOM		:= $(COMPOSER_ART)/$(COMPOSER_TINYNAME)/$(COMPOSER_TINYNAME)
override CUSTOM_PUBLISH_SH		:= $(COMPOSER_CUSTOM).$(PUBLISH).sh
override CUSTOM_PUBLISH_CSS		:= $(COMPOSER_CUSTOM).$(PUBLISH).css
override CUSTOM_PUBLISH_CSS_OVERLAY	= $(COMPOSER_CUSTOM).$(PUBLISH).overlay.$(1).css
override CUSTOM_HTML_CSS		:= $(COMPOSER_CUSTOM).html.css
override CUSTOM_PDF_LATEX		:= $(COMPOSER_CUSTOM).pdf.latex
override CUSTOM_REVEALJS_CSS		:= $(COMPOSER_CUSTOM).revealjs.css

override COMPOSER_IMAGES		:= $(COMPOSER_ART)/images
override COMPOSER_LOGO			:= $(COMPOSER_IMAGES)/logo.img
override COMPOSER_LOGO_VER		:= v1.0
override COMPOSER_ICON			:= $(COMPOSER_IMAGES)/icon.img
override COMPOSER_ICON_VER		:= v1.0

override COMPOSER_DAT			:= $(COMPOSER_ART)/pandoc

override BOOTSTRAP_DEF_JS		:= $(COMPOSER_ART)/bootstrap/bootstrap-default.js
override BOOTSTRAP_DEF_CSS		:= $(COMPOSER_ART)/bootstrap/bootstrap-default.css
override BOOTSTRAP_ART_JS		:= $(COMPOSER_ART)/bootstrap/bootstrap.js
override BOOTSTRAP_ART_CSS		:= $(COMPOSER_ART)/bootstrap/bootstrap.css

########################################

override HTML_SPACE			:= &nbsp;
override HTML_BREAK			:= <p></p>
#>override HTML_HIDE			:= <br hidden>
#>override HTML_HIDE			:= <span hidden>$(EXPAND)</span>
override HTML_HIDE			:= &\#0000;
override MENU_SELF			:= _

########################################

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
#> update: OUTPUT_FILENAME
override OUTPUT_FILENAME		= $(COMPOSER_FILENAME).$(1)-$(DATENAME).$(EXTN_TEXT)
override TESTING_DIR			:= $(COMPOSER_DIR)/.$(COMPOSER_FILENAME)

override COMPOSER_TMP			:= $(CURDIR)/.$(COMPOSER_TINYNAME).tmp
override COMPOSER_TMP_FILE		= $(if $(1),$(notdir $(COMPOSER_TMP)),$(COMPOSER_TMP))/$(notdir $(c_base)).$(EXTN_OUTPUT).$(DATENAME)

#> update: includes duplicates
override TYPE_HTML			:= html
override PUBLISH			:= site

override COMPOSER_CSS_PUBLISH		:= .$(notdir $(COMPOSER_CUSTOM))-$(PUBLISH).css
override COMPOSER_CSS			:= .$(notdir $(COMPOSER_CUSTOM))-$(TYPE_HTML).css

########################################

override COMPOSER_RELEASE		:=
ifeq ($(COMPOSER_DIR),$(CURDIR))
override COMPOSER_RELEASE		:= 1
endif

################################################################################
# {{{1 Include Files
################################################################################

override COMPOSER_REGEX_OVERRIDE	= override[[:space:]]+($(if $(1),$(1),[^[:space:]]+))[[:space:]]+[$(if $(2),?,:)][=]
override COMPOSER_REGEX_DEFINE		= override[[:space:]]+(define[[:space:]]+)?($(if $(1),$(1),[^[:space:]]+))[[:space:]]+[=]

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
#> update: READ_ALIASES

$(call READ_ALIASES,V,c_debug,COMPOSER_DEBUGIT)
override COMPOSER_DEBUGIT_ALL		:=
ifeq ($(COMPOSER_DEBUGIT),$(SPECIAL_VAL))
override COMPOSER_DEBUGIT_ALL		:= $(COMPOSER_DEBUGIT)
endif

override PATH_LIST			:= $(subst :, ,$(PATH))
override SHELL				:= $(call COMPOSER_FIND,$(PATH_LIST),bash) $(if $(COMPOSER_DEBUGIT_ALL),-x)
export SHELL

override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

########################################

#>include $(1)/$(COMPOSER_SETTINGS)

override define SOURCE_INCLUDES =
	$(if $(wildcard $(1)/$(COMPOSER_SETTINGS)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> SOURCE			[$(1)/$(COMPOSER_SETTINGS)])) \
	$(foreach FILE,\
		$(shell \
			$(SED) -n "/^$(call COMPOSER_REGEX_OVERRIDE,COMPOSER_INCLUDE).*$$/p" $(1)/$(COMPOSER_SETTINGS) \
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
override COMPOSER_INCLUDES_LIST		:= $(firstword $(COMPOSER_INCLUDES_TREE)) $(lastword $(COMPOSER_INCLUDES_TREE))
endif
endif
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES_LIST	[$(COMPOSER_INCLUDES_LIST)]))

########################################

override COMPOSER_CURDIR		:=
override COMPOSER_INCLUDES		:=
$(foreach FILE,$(addsuffix /$(COMPOSER_SETTINGS),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD			[$(FILE)])) \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE			[$(FILE)])) \
		$(eval override MAKEFILE_LIST := $(filter-out $(FILE),$(MAKEFILE_LIST))) \
		$(eval override COMPOSER_INCLUDES := $(COMPOSER_INCLUDES) $(FILE)) \
		$(eval override COMPOSER_CURDIR := $(filter $(CURDIR),$(abspath $(dir $(FILE))))) \
		$(eval include $(FILE)) \
	) \
)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_INCLUDES		[$(COMPOSER_INCLUDES)]))

########################################

#> update: WILDCARD_YML

override COMPOSER_YML_LIST		:=
$(foreach FILE,$(addsuffix /$(COMPOSER_YML),$(COMPOSER_INCLUDES_LIST)),\
	$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD_YML			[$(FILE)])) \
	$(if $(wildcard $(FILE)),\
		$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE_YML			[$(FILE)])) \
		$(eval override COMPOSER_YML_LIST := $(COMPOSER_YML_LIST) $(FILE)) \
	) \
)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_YML_LIST		[$(COMPOSER_YML_LIST)]))

################################################################################
# {{{1 Make Settings
################################################################################

.POSIX:
.SUFFIXES:

########################################

export MAKEFLAGS

########################################

#>override MAKEFILE			:= $(notdir $(firstword $(MAKEFILE_LIST)))
override MAKEFILE			:= Makefile

override MAKEFLAGS_ENV			= --no-builtin-rules --no-builtin-variables $(if $(1),--print-directory,--no-print-directory)
override NOFAIL				:= --keep-going

override MAKEFLAGS			:= $(call MAKEFLAGS_ENV,$(COMPOSER_DEBUGIT_ALL)) $(if $(filter k%,$(MAKEFLAGS)),$(NOFAIL),--stop)
ifneq ($(COMPOSER_DEBUGIT_ALL),)
#>override MAKEFLAGS			:= $(MAKEFLAGS) --debug=verbose --trace
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=verbose
else
#>override MAKEFLAGS			:= $(MAKEFLAGS) --debug=none --silent
override MAKEFLAGS			:= $(MAKEFLAGS) --debug=none
endif

########################################

override MAKEJOBS_DEFAULT		:= 1

#> update: READ_ALIASES
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
# {{{1 Composer Options
################################################################################

#> update: includes duplicates
#> update: COMPOSER_OPTIONS

########################################

ifneq ($(origin _EXPORT_DIRECTORY),override)
override _EXPORT_DIRECTORY		:= $(COMPOSER_EXPORT)
else
override COMPOSER_EXPORT		:= $(_EXPORT_DIRECTORY)
endif

ifneq ($(origin _EXPORT_GIT_REPO),override)
override _EXPORT_GIT_REPO		:=
endif
ifneq ($(origin _EXPORT_GIT_BNCH),override)
override _EXPORT_GIT_BNCH		:=
endif

ifneq ($(origin _EXPORT_FIRE_ACCT),override)
override _EXPORT_FIRE_ACCT		:=
endif
ifneq ($(origin _EXPORT_FIRE_PROJ),override)
override _EXPORT_FIRE_PROJ		:=
endif

########################################

#> update: READ_ALIASES
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
override COMPOSER_EXPORTS		?=
override COMPOSER_IGNORES		?=

#>ifneq ($(COMPOSER_RELEASE),)
#>override COMPOSER_TARGETS		:=
#>override COMPOSER_SUBDIRS		:=
#>override COMPOSER_EXPORTS		:=
#>override COMPOSER_IGNORES		:=
#>endif

########################################

#> update: READ_ALIASES
$(call READ_ALIASES,S,S,c_site)
$(call READ_ALIASES,T,T,c_type)
$(call READ_ALIASES,B,B,c_base)
$(call READ_ALIASES,L,L,c_list)
$(call READ_ALIASES,a,a,c_lang)
$(call READ_ALIASES,g,g,c_logo)
$(call READ_ALIASES,i,i,c_icon)
$(call READ_ALIASES,c,c,c_css)
$(call READ_ALIASES,t,t,c_toc)
$(call READ_ALIASES,l,l,c_level)
$(call READ_ALIASES,m,m,c_margin)
$(call READ_ALIASES,mt,mt,c_margin_top)
$(call READ_ALIASES,mb,mb,c_margin_bottom)
$(call READ_ALIASES,ml,ml,c_margin_left)
$(call READ_ALIASES,mr,mr,c_margin_right)
$(call READ_ALIASES,o,o,c_options)

#>override c_base			?= $(OUT_README)
#>override c_list			?= $(c_base)$(COMPOSER_EXT)

override c_site				?=
override c_type				?= $(TYPE_DEFAULT)
override c_base				?=
override c_list				?=
override c_lang				?= en-US
override c_logo				?= $(COMPOSER_LOGO)
override c_icon				?= $(COMPOSER_ICON)
override c_css				?=
override c_toc				?=
override c_level			?= $(DEPTH_DEFAULT)
override c_margin			?= 0.8in
override c_margin_top			?=
override c_margin_bottom		?=
override c_margin_left			?=
override c_margin_right			?=
override c_options			?=

override c_list_var			= $(strip $(if $($(if $(1),$(1),$(c_base)).$(if $(2),$(2),$(EXTN_OUTPUT))),                   $($(if $(1),$(1),$(c_base)).$(if $(2),$(2),$(EXTN_OUTPUT))),$(if $($(if $(1),$(1),$(c_base)).*),                   $($(if $(1),$(1),$(c_base)).*),$(c_list))))
override c_list_var_source		= $(strip $(if $($(if $(1),$(1),$(c_base)).$(if $(2),$(2),$(EXTN_OUTPUT))),$(if $(3),\$$$$,\$$)($(if $(1),$(1),$(c_base)).$(if $(2),$(2),$(EXTN_OUTPUT))),$(if $($(if $(1),$(1),$(c_base)).*),$(if $(3),\$$$$,\$$)($(if $(1),$(1),$(c_base)).*))))
override c_list_file			:=

########################################

override PUBLISH_KEEPING		:= 256

override PUBLISH_FILE_HEADER		:= _header$(COMPOSER_EXT_SPECIAL)
override PUBLISH_FILE_FOOTER		:= _footer$(COMPOSER_EXT_SPECIAL)
override PUBLISH_FILE_APPEND		:= _append$(COMPOSER_EXT_SPECIAL)

override PUBLISH_COMPOSER		:= 1
override PUBLISH_COMPOSER_ALT		:= $(PUBLISH_COMPOSER)
override PUBLISH_COMPOSER_MOD		:= null

override PUBLISH_HEADER			:= null
override PUBLISH_HEADER_ALT		= $(PUBLISH_CMD_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_HEADER)
override PUBLISH_FOOTER			:= null
override PUBLISH_FOOTER_ALT		= $(PUBLISH_CMD_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_FOOTER)

override PUBLISH_CSS_OVERLAY		:= dark
override PUBLISH_CSS_OVERLAY_ALT	:= null
override PUBLISH_COPY_PROTECT		:= null
override PUBLISH_COPY_PROTECT_ALT	:= 1

override PUBLISH_COLS_BREAK		:= lg
override PUBLISH_COLS_BREAK_ALT		:= md

override PUBLISH_COLS_STICKY_L		:= 1
override PUBLISH_COLS_STICKY_C		:= 1
override PUBLISH_COLS_STICKY_R		:= 1
override PUBLISH_COLS_RESTICKY_L	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESTICKY_C	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESTICKY_R	:= $(SPECIAL_VAL)

override PUBLISH_COLS_STICKY_L_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_STICKY_C_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_STICKY_R_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESTICKY_L_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESTICKY_L_MOD	:= 1
override PUBLISH_COLS_RESTICKY_C_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESTICKY_C_MOD	:= 1
override PUBLISH_COLS_RESTICKY_R_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESTICKY_R_MOD	:= 1

override PUBLISH_COLS_ORDER_L		:= 1
override PUBLISH_COLS_ORDER_C		:= 2
override PUBLISH_COLS_ORDER_R		:= 3
override PUBLISH_COLS_REORDER_L		:= 1
override PUBLISH_COLS_REORDER_C		:= 3
override PUBLISH_COLS_REORDER_R		:= 2

override PUBLISH_COLS_ORDER_L_ALT	:= 1
override PUBLISH_COLS_ORDER_C_ALT	:= 3
override PUBLISH_COLS_ORDER_R_ALT	:= 2
override PUBLISH_COLS_REORDER_L_ALT	:= 2
override PUBLISH_COLS_REORDER_L_MOD	:= $(SPECIAL_VAL)
override PUBLISH_COLS_REORDER_C_ALT	:= 3
override PUBLISH_COLS_REORDER_C_MOD	:= $(PUBLISH_COLS_REORDER_C_ALT)
override PUBLISH_COLS_REORDER_R_ALT	:= 1
override PUBLISH_COLS_REORDER_R_MOD	:= $(PUBLISH_COLS_REORDER_R_ALT)

override PUBLISH_COLS_SIZE_L		:= 3
override PUBLISH_COLS_SIZE_C		:= 7
override PUBLISH_COLS_SIZE_R		:= 2
override PUBLISH_COLS_RESIZE_L		:= 6
override PUBLISH_COLS_RESIZE_C		:= 12
override PUBLISH_COLS_RESIZE_R		:= 6

override PUBLISH_COLS_SIZE_L_ALT	:= 12
override PUBLISH_COLS_SIZE_C_ALT	:= 9
override PUBLISH_COLS_SIZE_R_ALT	:= 3
override PUBLISH_COLS_RESIZE_L_ALT	:= 12
override PUBLISH_COLS_RESIZE_L_MOD	:= $(PUBLISH_COLS_RESIZE_L_ALT)
override PUBLISH_COLS_RESIZE_C_ALT	:= 12
override PUBLISH_COLS_RESIZE_C_MOD	:= $(PUBLISH_COLS_RESIZE_C_ALT)
override PUBLISH_COLS_RESIZE_R_ALT	:= $(SPECIAL_VAL)
override PUBLISH_COLS_RESIZE_R_MOD	:= 12

#> talk: 183 / read: 234
override PUBLISH_METAINFO		:= <date> $(DIVIDE) <title><|> -- <author|; >
override PUBLISH_METAINFO_ALT		:= <title>$(HTML_SPACE)$(HTML_SPACE)*(<date>)*<|><br>*-- <author| -- >*<br>*. <tags| . >*
override PUBLISH_METAINFO_MOD		:= <title>$(HTML_SPACE)$(HTML_SPACE)*(<date>)*<|><br>*-- <author>*<br>*. <tags>*
override PUBLISH_METAINFO_NULL		:= *(none)*
override PUBLISH_METAINFO_NULL_ALT	:= null
#>override PUBLISH_CONTENTS		:=
#>override PUBLISH_CONTENTS_ALT		:=
override PUBLISH_CREATORS		:= author
override PUBLISH_CREATORS_TITLE		:= Author
override PUBLISH_CREATORS_TITLE_ALT	:= Creator
override PUBLISH_CREATORS_TITLE_MOD	:= #> null
override PUBLISH_CREATORS_PRINT		:= *Authors: <|>, <|>*
override PUBLISH_CREATORS_PRINT_ALT	:= <ul><li><|></li><li><|></li></ul>
override PUBLISH_CREATORS_PRINT_MOD	:= #> null
override PUBLISH_METALIST		:= tags
override PUBLISH_METALIST_TITLE		:= Tag
override PUBLISH_METALIST_TITLE_ALT	:= Mark
override PUBLISH_METALIST_TITLE_MOD	:= #> null
override PUBLISH_METALIST_PRINT		:= *Tags: <|>, <|>*
override PUBLISH_METALIST_PRINT_ALT	:= <ul><li><|></li><li><|></li></ul>
override PUBLISH_METALIST_PRINT_MOD	:= #> null
override PUBLISH_READTIME		:= *Reading time: <word> words, <time> minutes*
override PUBLISH_READTIME_ALT		:= *Words: <word> / Minutes: <time>*
override PUBLISH_READTIME_WPM		:= 220
override PUBLISH_READTIME_WPM_ALT	:= 200

override LIBRARY_FOLDER			:= null
override LIBRARY_FOLDER_ALT		:= _library
override LIBRARY_AUTO_UPDATE		:= null
override LIBRARY_AUTO_UPDATE_ALT	:= 1

override LIBRARY_APPEND			:= null
override LIBRARY_APPEND_ALT		= $(PUBLISH_CMD_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)

override LIBRARY_DIGEST_TITLE		:= Latest Updates
override LIBRARY_DIGEST_TITLE_ALT	:= Digest
override LIBRARY_DIGEST_CONTINUE	:= [$(EXPAND)]
override LIBRARY_DIGEST_CONTINUE_ALT	:= *(continued)*
override LIBRARY_DIGEST_PERMALINK	:= *(permalink to full text)*
override LIBRARY_DIGEST_PERMALINK_ALT	:= *(permalink)*
override LIBRARY_DIGEST_CHARS		:= 1024
override LIBRARY_DIGEST_CHARS_ALT	:= 2048
override LIBRARY_DIGEST_COUNT		:= 10
override LIBRARY_DIGEST_COUNT_ALT	:= 20
override LIBRARY_DIGEST_EXPANDED	:= $(SPECIAL_VAL)
override LIBRARY_DIGEST_EXPANDED_ALT	:= null
override LIBRARY_DIGEST_EXPANDED_MOD	:= 2
override LIBRARY_DIGEST_SPACER		:= 1
override LIBRARY_DIGEST_SPACER_ALT	:= null

override LIBRARY_LISTS_EXPANDED		:= $(SPECIAL_VAL)
override LIBRARY_LISTS_EXPANDED_ALT	:= null
override LIBRARY_LISTS_EXPANDED_MOD	:= 2
override LIBRARY_LISTS_SPACER		:= 1
override LIBRARY_LISTS_SPACER_ALT	:= null

override LIBRARY_SITEMAP_TITLE		:= Site Map
override LIBRARY_SITEMAP_TITLE_ALT	:= Directory
override LIBRARY_SITEMAP_EXPANDED	:= $(SPECIAL_VAL)
override LIBRARY_SITEMAP_EXPANDED_ALT	:= null
override LIBRARY_SITEMAP_EXPANDED_MOD	:= 2
override LIBRARY_SITEMAP_SPACER		:= 1
override LIBRARY_SITEMAP_SPACER_ALT	:= null

################################################################################
# }}}1
################################################################################
# {{{1 Tooling Versions
################################################################################

override REPOSITORIES_LIST		:=

override OS_VAR_LIST			:= LNX WIN MAC
override OS_VAR_LNX			:= linux
override OS_VAR_WIN			:= windows
override OS_VAR_MAC			:= macos

########################################

override REPOSITORIES_LIST		+= PANDOC
override PANDOC_NAME			:= Pandoc
override PANDOC_HOME			:= https://pandoc.org

#>override PANDOC_VER_COMPOSER		:= 2.18
override PANDOC_VER_COMPOSER		:= 2.18
ifneq ($(origin PANDOC_VER),override)
override PANDOC_VER			:= $(PANDOC_VER_COMPOSER)
endif
ifneq ($(origin PANDOC_CMT),override)
override PANDOC_CMT			:= $(PANDOC_VER)
endif
override PANDOC_LIC			:= GPL
override PANDOC_SRC			:= https://github.com/jgm/pandoc.git
override PANDOC_DIR			:= $(COMPOSER_DIR)/pandoc

override PANDOC_URL			:= https://github.com/jgm/pandoc/releases/download/$(PANDOC_VER)
override PANDOC_LNX_SRC			:= pandoc-$(PANDOC_VER)-linux-amd64.tar.gz
override PANDOC_WIN_SRC			:= pandoc-$(PANDOC_VER)-windows-x86_64.zip
override PANDOC_MAC_SRC			:= pandoc-$(PANDOC_VER)-macOS.zip
override PANDOC_LNX_DST			:= $(patsubst %.tar.gz,%,$(PANDOC_LNX_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/bin/pandoc
override PANDOC_WIN_DST			:= $(patsubst %.zip,%,$(PANDOC_WIN_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/pandoc.exe
override PANDOC_MAC_DST			:= $(patsubst %.zip,%,$(PANDOC_MAC_SRC))-$(PANDOC_VER)/pandoc-$(PANDOC_VER)/bin/pandoc
override PANDOC_LNX_BIN			:= $(notdir $(PANDOC_DIR))-$(PANDOC_VER)-$(OS_VAR_LNX)
override PANDOC_WIN_BIN			:= $(notdir $(PANDOC_DIR))-$(PANDOC_VER)-$(OS_VAR_WIN).exe
override PANDOC_MAC_BIN			:= $(notdir $(PANDOC_DIR))-$(PANDOC_VER)-$(OS_VAR_MAC).bin
override PANDOC_LNX_ZIP			:=
override PANDOC_WIN_ZIP			:= 1
override PANDOC_MAC_ZIP			:= 1
ifeq ($(OS_TYPE),Linux)
override PANDOC_BIN			:= $(PANDOC_DIR)/$(PANDOC_LNX_BIN)
else ifeq ($(OS_TYPE),Windows)
override PANDOC_BIN			:= $(PANDOC_DIR)/$(PANDOC_WIN_BIN)
else ifeq ($(OS_TYPE),Darwin)
override PANDOC_BIN			:= $(PANDOC_DIR)/$(PANDOC_MAC_BIN)
endif

override PDF_LATEX_NAME			:= TeX Live
override PDF_LATEX_HOME			:= https://tug.org/texlive
override PDF_LATEX			:= pdflatex

########################################

override REPOSITORIES_LIST		+= YQ
override YQ_NAME			:= YQ
override YQ_HOME			:= https://mikefarah.gitbook.io/yq

#>override YQ_VER_COMPOSER		:= 3.1.0
override YQ_VER_COMPOSER		:= 4.24.2
ifneq ($(origin YQ_VER),override)
override YQ_VER				:= $(YQ_VER_COMPOSER)
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
override YQ_LNX_BIN			:= $(notdir $(YQ_DIR))-$(YQ_VER)-$(OS_VAR_LNX)
override YQ_WIN_BIN			:= $(notdir $(YQ_DIR))-$(YQ_VER)-$(OS_VAR_WIN).exe
override YQ_MAC_BIN			:= $(notdir $(YQ_DIR))-$(YQ_VER)-$(OS_VAR_MAC).bin
override YQ_LNX_ZIP			:=
override YQ_WIN_ZIP			:= 1
override YQ_MAC_ZIP			:=
override YQ_BIN				:=
ifeq ($(OS_TYPE),Linux)
override YQ_BIN				:= $(YQ_DIR)/$(YQ_LNX_BIN)
else ifeq ($(OS_TYPE),Windows)
override YQ_BIN				:= $(YQ_DIR)/$(YQ_WIN_BIN)
else ifeq ($(OS_TYPE),Darwin)
override YQ_BIN				:= $(YQ_DIR)/$(YQ_MAC_BIN)
endif

########################################

override REPOSITORIES_LIST		+= BOOTSTRAP
override BOOTSTRAP_NAME			:= Bootstrap
override BOOTSTRAP_HOME			:= https://getbootstrap.com

ifneq ($(origin BOOTSTRAP_CMT),override)
override BOOTSTRAP_CMT			:= v5.1.3
endif
override BOOTSTRAP_LIC			:= MIT
override BOOTSTRAP_SRC			:= https://github.com/twbs/bootstrap.git
override BOOTSTRAP_DIR			:= $(COMPOSER_DIR)/bootstrap

override BOOTSTRAP_DOC_VER		:= 5.1
override BOOTSTRAP_DIR_JS		:= $(BOOTSTRAP_DIR)/dist/js/bootstrap.bundle.js
override BOOTSTRAP_DIR_CSS		:= $(BOOTSTRAP_DIR)/dist/css/bootstrap.css

########################################

override REPOSITORIES_LIST		+= BOOTLINT
override BOOTLINT_NAME			:= Bootlint
override BOOTLINT_HOME			:= https://github.com/twbs/bootlint

ifneq ($(origin BOOTLINT_CMT),override)
override BOOTLINT_CMT			:= v1.1.0
endif
override BOOTLINT_LIC			:= MIT
override BOOTLINT_SRC			:= https://github.com/twbs/bootlint.git
override BOOTLINT_DIR			:= $(COMPOSER_DIR)/bootlint

########################################

override REPOSITORIES_LIST		+= BOOTSWATCH
override BOOTSWATCH_NAME		:= Bootswatch
override BOOTSWATCH_HOME		:= https://bootswatch.com

ifneq ($(origin BOOTSWATCH_CMT),override)
override BOOTSWATCH_CMT			:= v5.1.3
endif
override BOOTSWATCH_LIC			:= MIT
override BOOTSWATCH_SRC			:= https://github.com/thomaspark/bootswatch.git
override BOOTSWATCH_DIR			:= $(COMPOSER_DIR)/bootswatch

########################################

override REPOSITORIES_LIST		+= FONTAWES
override FONTAWES_NAME			:= Font-Awesome
override FONTAWES_HOME			:= https://fontawesome.com

ifneq ($(origin FONTAWES_CMT),override)
override FONTAWES_CMT			:= 6.1.2
endif
override FONTAWES_LIC			:= MIT / CC-BY
override FONTAWES_SRC			:= https://github.com/FortAwesome/Font-Awesome.git
override FONTAWES_DIR			:= $(COMPOSER_DIR)/font-awesome

########################################

override REPOSITORIES_LIST		+= WATERCSS
override WATERCSS_NAME			:= Water.css
override WATERCSS_HOME			:= https://watercss.kognise.dev

ifneq ($(origin WATERCSS_CMT),override)
#>override WATERCSS_CMT			:= d950cbc9f8607521587fae1aa523f85e25f8396f
override WATERCSS_CMT			:= d950cbc9f8607521587f
endif
override WATERCSS_LIC			:= MIT
override WATERCSS_SRC			:= https://github.com/kognise/water.css.git
override WATERCSS_DIR			:= $(COMPOSER_DIR)/water.css

########################################

override REPOSITORIES_LIST		+= MDVIEWER
override MDVIEWER_NAME			:= Markdown Viewer
override MDVIEWER_HOME			:= https://github.com/simov/markdown-viewer

ifneq ($(origin MDVIEWER_CMT),override)
#>override MDVIEWER_CMT			:= 3bd40d84c071379440b3dd94e2a48fbbbb03829f
override MDVIEWER_CMT			:= 3bd40d84c071379440b3
endif
override MDVIEWER_LIC			:= MIT
override MDVIEWER_SRC			:= https://github.com/simov/markdown-viewer.git
override MDVIEWER_DIR			:= $(COMPOSER_DIR)/markdown-viewer

#> update: MDVIEWER_MODULES
override MDVIEWER_MODULES		= $(SED) -n "s|^[[:space:]]*sh[ ]([^/]+)[/]build.sh$$|\1|gp" $(MDVIEWER_DIR)/build/package.sh
override MDVIEWER_MANIFEST		:= manifest.firefox.json
override MDVIEWER_FIX_SASS_VER		:= ^1.0.0

########################################

override REPOSITORIES_LIST		+= MDTHEMES
override MDTHEMES_NAME			:= Markdown Themes
override MDTHEMES_HOME			:= https://github.com/simov/markdown-themes

ifneq ($(origin MDTHEMES_CMT),override)
#>override MDTHEMES_CMT			:= 6b3643d0f703727d847207c1ddfdde700216cc11
override MDTHEMES_CMT			:= 6b3643d0f703727d8472
endif
override MDTHEMES_LIC			:= None
override MDTHEMES_SRC			:= https://github.com/simov/markdown-themes.git
override MDTHEMES_DIR			:= $(COMPOSER_DIR)/markdown-themes

########################################

override REPOSITORIES_LIST		+= REVEALJS
override REVEALJS_NAME			:= Reveal.js
override REVEALJS_HOME			:= https://revealjs.com

ifneq ($(origin REVEALJS_CMT),override)
override REVEALJS_CMT			:= 4.3.1
endif
override REVEALJS_LIC			:= MIT
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DIR			:= $(COMPOSER_DIR)/reveal.js

########################################

override REPOSITORIES_LIST		+= FIREBASE
override FIREBASE_NAME			:= Google Firebase
override FIREBASE_HOME			:= https://firebase.google.com

override FIREBASE_VER_COMPOSER		:= 12.4.7
ifneq ($(origin FIREBASE_VER),override)
override FIREBASE_VER			:= $(FIREBASE_VER_COMPOSER)
endif
ifneq ($(origin FIREBASE_CMT),override)
override FIREBASE_CMT			:= v$(FIREBASE_VER)
endif
override FIREBASE_LIC			:= MIT
override FIREBASE_SRC			:= https://github.com/firebase/firebase-tools.git
override FIREBASE_DIR			:= $(COMPOSER_DIR)/firebase-tools

override FIREBASE_URL			:= https://github.com/firebase/firebase-tools/releases/download/v$(FIREBASE_VER)
override FIREBASE_LNX_SRC		:= firebase-tools-linux
override FIREBASE_WIN_SRC		:= firebase-tools-win.exe
override FIREBASE_MAC_SRC		:= firebase-tools-macos
override FIREBASE_LNX_DST		:= $(patsubst %,%,$(FIREBASE_LNX_SRC))-$(FIREBASE_VER)/$(FIREBASE_LNX_SRC)
override FIREBASE_WIN_DST		:= $(patsubst %.exe,%,$(FIREBASE_WIN_SRC))-$(FIREBASE_VER)/$(FIREBASE_WIN_SRC)
override FIREBASE_MAC_DST		:= $(patsubst %,%,$(FIREBASE_MAC_SRC))-$(FIREBASE_VER)/$(FIREBASE_MAC_SRC)
override FIREBASE_LNX_BIN		:= $(notdir $(FIREBASE_DIR))-$(FIREBASE_VER)-$(OS_VAR_LNX)
override FIREBASE_WIN_BIN		:= $(notdir $(FIREBASE_DIR))-$(FIREBASE_VER)-$(OS_VAR_WIN).exe
override FIREBASE_MAC_BIN		:= $(notdir $(FIREBASE_DIR))-$(FIREBASE_VER)-$(OS_VAR_MAC).bin
override FIREBASE_LNX_ZIP		:= $(SPECIAL_VAL)
override FIREBASE_WIN_ZIP		:= $(SPECIAL_VAL)
override FIREBASE_MAC_ZIP		:= $(SPECIAL_VAL)
ifeq ($(OS_TYPE),Linux)
override FIREBASE_BIN			:= $(FIREBASE_DIR)/$(FIREBASE_LNX_BIN)
else ifeq ($(OS_TYPE),Windows)
override FIREBASE_BIN			:= $(FIREBASE_DIR)/$(FIREBASE_WIN_BIN)
else ifeq ($(OS_TYPE),Darwin)
override FIREBASE_BIN			:= $(FIREBASE_DIR)/$(FIREBASE_MAC_BIN)
endif

override FIREBASE_BIN_BLD		:= $(FIREBASE_DIR)/node_modules/.bin/firebase
ifneq ($(wildcard $(FIREBASE_BIN_BLD)),)
override FIREBASE_BIN			:= $(FIREBASE_BIN_BLD)
endif

override define FIREBASE_IGNORE =
/.firebase*
**firebase**.json
endef

########################################

override BASH_VER			:= 5.1.16
override COREUTILS_VER			:= 8.32
override FINDUTILS_VER			:= 4.9.0
override SED_VER			:= 4.8

override MAKE_VER			:= 4.3
override PANDOC_VER			:= $(PANDOC_VER)
override YQ_VER				:= $(YQ_VER)
override PDF_LATEX_VER			:= 2021 3.141592653-2.6-1.40.22

override GIT_VER			:= 2.37.4
override DIFFUTILS_VER			:= 3.8
override RSYNC_VER			:= 3.2.4

override WGET_VER			:= 1.21.3
override TAR_VER			:= 1.34
override GZIP_VER			:= 1.12
override 7Z_VER				:= 16.02
override NPM_VER			:= 8.19.2
override CURL_VER			:= 7.85.0

override FIREBASE_VER			:= $(FIREBASE_VER)

################################################################################
# {{{1 Tooling Options
################################################################################

#> update: includes duplicates

override PATH_LIST			:= $(subst :, ,$(PATH))
override SHELL				:= $(call COMPOSER_FIND,$(PATH_LIST),bash) $(if $(COMPOSER_DEBUGIT_ALL),-x)
export SHELL

export LC_ALL				:=
export LC_COLLATE			:= C

########################################
## {{{2 Paths
########################################

#> validate: sed -nr "s|^override[[:space:]]+([^[:space:]]+).+[(]PATH_LIST[)].+$|\1|gp" Makefile | while read -r FILE; do echo "--- ${FILE} ---"; grep -E "[(]${FILE}[)]" Makefile; done

override BASH				:= $(call COMPOSER_FIND,$(PATH_LIST),bash)
override FIND				:= $(call COMPOSER_FIND,$(PATH_LIST),find)
override FIND_ALL			:= $(call COMPOSER_FIND,$(PATH_LIST),find) -L
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r

override BASE64				:= $(call COMPOSER_FIND,$(PATH_LIST),base64) --wrap=0 --decode
override CAT				:= $(call COMPOSER_FIND,$(PATH_LIST),cat)
override CHMOD				:= $(call COMPOSER_FIND,$(PATH_LIST),chmod) -v 755
override CP				:= $(call COMPOSER_FIND,$(PATH_LIST),cp) -afv --dereference
override DATE				:= $(call COMPOSER_FIND,$(PATH_LIST),date) --iso=seconds
override ECHO				:= $(call COMPOSER_FIND,$(PATH_LIST),echo) -en
override ENV				:= $(call COMPOSER_FIND,$(PATH_LIST),env) - USER="$(USER)" HOME="$(HOME)" PATH="$(PATH)"
override EXPR				:= $(call COMPOSER_FIND,$(PATH_LIST),expr)
override HEAD				:= $(call COMPOSER_FIND,$(PATH_LIST),head)
override LN				:= $(call COMPOSER_FIND,$(PATH_LIST),ln) -fsv --relative
override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) $(if $(COMPOSER_DOCOLOR),--color=auto,--color=none) --time-style=long-iso -asF -l
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
override WC				:= $(call COMPOSER_FIND,$(PATH_LIST),wc) --lines
override WC_CHAR			:= $(call COMPOSER_FIND,$(PATH_LIST),wc) --bytes
override WC_WORD			:= $(call COMPOSER_FIND,$(PATH_LIST),wc) --words

#>override MAKE				:= $(call COMPOSER_FIND,$(PATH_LIST),make)
override REALMAKE			:= $(call COMPOSER_FIND,$(PATH_LIST),make)
override PANDOC				:= $(call COMPOSER_FIND,$(PATH_LIST),pandoc)
override YQ				:= $(call COMPOSER_FIND,$(PATH_LIST),yq)
override PDF_LATEX			:= $(call COMPOSER_FIND,$(PATH_LIST),$(PDF_LATEX))

#> update: $(NOTHING)-%

override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git) --no-pager
override DIFF				:= $(call COMPOSER_FIND,$(PATH_LIST),diff) -u -U10
override RSYNC				:= $(call COMPOSER_FIND,$(PATH_LIST),rsync) -avv --recursive --itemize-changes --times --delete

override WGET				:= $(call COMPOSER_FIND,$(PATH_LIST),wget) --verbose --progress=dot --timestamping
override TAR				:= $(call COMPOSER_FIND,$(PATH_LIST),tar) -vvx
override GZIP_BIN			:= $(call COMPOSER_FIND,$(PATH_LIST),gzip)
override 7Z				:= $(call COMPOSER_FIND,$(PATH_LIST),7z) x -aoa
override NPM				:= $(call COMPOSER_FIND,$(PATH_LIST),npm) --verbose
override CURL				:= $(call COMPOSER_FIND,$(PATH_LIST),curl)

override FIREBASE			:= $(call COMPOSER_FIND,$(PATH_LIST),firebase)

override DOMAKE				:= $(notdir $(MAKE))
export GZIP				:=

########################################

$(foreach FILE,$(REPOSITORIES_LIST),\
	$(if $($(FILE)_BIN),\
	$(if $(wildcard $($(FILE)_BIN)),\
		$(eval override $(FILE) := $($(FILE)_BIN)) \
		,\
		$(if $(wildcard $(COMPOSER_BIN)/$(notdir $($(FILE)_BIN)).*),\
			$(shell \
				$(MKDIR) $($(FILE)_DIR) >/dev/null; \
				$(CAT) $(COMPOSER_BIN)/$(notdir $($(FILE)_BIN)).* >$($(FILE)_BIN); \
				$(CHMOD) $($(FILE)_BIN) >/dev/null; \
			) \
			$(eval override $(FILE) := $($(FILE)_BIN)) \
		) \
	)) \
)

########################################
## {{{2 Wrappers
########################################

override DATESTAMP			:= $(shell $(DATE))
override DATENAME			:= $(shell $(DATE) | $(SED) \
	-e "s|[-]([0-9]{2}[:]?[0-9]{2})$$|T\1|g" \
	-e "s|[-:]||g" \
	-e "s|T|-|g" \
)
override DATEMARK			:= $(firstword $(subst T, ,$(DATESTAMP)))

########################################

override YQ_READ			:= $(YQ) --no-colors --no-doc --header-preprocess --front-matter "extract" --input-format "yaml" --output-format "json"
override YQ_WRITE			:= $(subst --front-matter "extract" ,,$(subst --output-format "json",--output-format "yaml",$(YQ_READ)))
override YQ_WRITE_JSON			:= $(subst --front-matter "extract" ,,$(YQ_READ))
override YQ_WRITE_FILE			:= $(YQ_WRITE) --prettyPrint
override YQ_WRITE_OUT			:= $(YQ_WRITE_FILE) $(if $(COMPOSER_DOCOLOR),--colors)

#>override YQ_EVAL			:= . *+
override YQ_EVAL			:= . *
override YQ_EVAL_FILES			:= $(YQ_READ) eval-all '. as $$file ireduce ({}; $(YQ_EVAL) $$file)'
override YQ_EVAL_DATA_FORMAT		= $(subst ','"'"',$(subst \n,\\n,$(1)))
#>				$(YQ_READ) ".variables.$(PUBLISH)-$(3)" $(FILE) 2>/dev/null
#>			)) }}' 2>/dev/null
#>			| $(YQ_WRITE_JSON) '$(YQ_EVAL) load("$(FILE)")' 2>/dev/null
override define YQ_EVAL_DATA =
	$(ECHO) '$(call YQ_EVAL_DATA_FORMAT,$(1))' \
	$(foreach FILE,$(wildcard $(2)),\
		$(if $(3),\
			| $(YQ_WRITE_JSON) '$(YQ_EVAL) { "variables": { "$(PUBLISH)-$(3)": $(call YQ_EVAL_DATA_FORMAT,$(shell \
				$(YQ_READ) ".variables.$(PUBLISH)-$(3)" $(FILE) \
			)) }}' \
		,\
			| $(YQ_WRITE_JSON) '$(YQ_EVAL) load("$(FILE)")' \
		) \
	)
endef

########################################

override GIT_LOG_FORMAT			:= %ai %H %s %d
override GIT_LOG_COUNT			:= 10

override GIT_RUN			= cd $(1) && $(GIT) --no-pager --git-dir="$(2)" --work-tree="$(1)" $(3)
override define GIT_RUN_COMPOSER =
	$(call $(HEADERS)-action,$(1)); \
	$(call GIT_RUN,$(COMPOSER_ROOT),$(strip $(if \
		$(wildcard $(COMPOSER_ROOT).git),\
		$(COMPOSER_ROOT).git ,\
		$(COMPOSER_ROOT)/.git \
	)),$(1))
endef
override define GIT_RUN_REPO =
	$(call $(HEADERS)-action,$(2),$(notdir $(1))); \
	$(call GIT_RUN,$(1),$(strip \
		$(COMPOSER_SRC)/$(notdir $(1)).git \
	),$(2))
endef

#>	$(RM) $(1)/.git
override GIT_REPO			= $(call GIT_REPO_DO,$(1),$(2),$(strip $(3)),$(4),$(COMPOSER_SRC)/$(notdir $(1)).git)
override define GIT_REPO_DO =
	$(call $(HEADERS)-action,$(1),$(3)); \
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

#> update: $(NOTHING)-%

override WGET_PACKAGE			= $(call WGET_PACKAGE_DO,$(1),$(2),$(3),$(4),$(5),$(6),$(firstword $(subst /, ,$(4))),$(COMPOSER_SRC))
override define WGET_PACKAGE_DO =
	$(call $(HEADERS)-action,$(5)); \
	$(MKDIR) $(8); \
	$(WGET) --directory-prefix $(8) $(2)/$(3); \
	$(RM) --recursive $(8)/$(7); \
	$(MKDIR) $(8)/$(7); \
	if [ "$(6)" = "$(SPECIAL_VAL)" ]; then \
		$(CP) $(8)/$(3) $(8)/$(4); \
	elif [ -n "$(6)" ]; then \
		$(7Z) -o$(8)/$(7) $(8)/$(3); \
	else \
		$(TAR) -C $(8)/$(7) -f $(8)/$(3); \
	fi; \
	$(MKDIR) $(1); \
	$(CP) $(8)/$(4) $(1)/$(5); \
	$(CHMOD) $(1)/$(5); \
	$(MKDIR) $(COMPOSER_BIN); \
	$(RM) $(COMPOSER_BIN)/$(notdir $(5)).*; \
	$(SPLIT) $(1)/$(5) $(COMPOSER_BIN)/$(notdir $(5)).
endef

########################################

override NPM_NAME			= $(subst /,-,$(call COMPOSER_CONV,,$(1)))

override define NPM_RUN =
	cd $(1) && \
		PATH="$(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm/node_modules/.bin:$(PATH)" \
		$(if $(3),\
			$(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm/node_modules/.bin/$(3) \
		,\
			$(NPM) \
				$(if $(2),,--prefix $(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm) \
				--cache $(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm \
				$(2) \
		)
endef

override define NPM_SETUP =
	$(MKDIR) $(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm; \
	$(RM) --recursive $(1)/node_modules; \
	$(LN) $(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm/node_modules $(1)/; \
	$(RM) $(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm/package.json; \
	$(LN) $(1)/package.json $(COMPOSER_SRC)/$(call NPM_NAME,$(1)).npm/; \
	$(SED) -i "s|^(.+[\"])(node-)?(sass[\"].+[\"]).+([\"].*)$$|\1\3$(MDVIEWER_FIX_SASS_VER)\4|g" $(1)/package.json
endef

override define NPM_INSTALL =
	$(call $(HEADERS)-action,$(1),npm,$(2)); \
	if [ -f "$(1)/package.json" ]; then \
		$(call NPM_SETUP,$(1)); \
		$(call NPM_RUN,$(1)) install $(2); \
	fi
endef

#> update: MDVIEWER_MODULES
override define NPM_BUILD =
	$(call $(HEADERS)-action,$(1),npm,build); \
	$(RM) --recursive \
		$(1)/cleanrmd \
		$(1)/tmp \
		; \
	$(SED) -i \
		-e "s|^[^[:space:]]*(npm install)|#$(MARKER)\1|g" \
		-e "s|^[^[:space:]]*(rm -rf)|#$(MARKER)\1|g" \
		$(1)/build.sh; \
	if [ -f "$(1)/package.json" ]; then \
		$(YQ_WRITE_JSON) --inplace ". += { \"scripts\": { \"build\": \"./build.sh\" } }" $(1)/package.json; \
		$(call NPM_SETUP,$(1)); \
		$(call NPM_RUN,$(1),run-script) build; \
	else \
		(cd $(1) && $(BASH) -e $(if $(COMPOSER_DEBUGIT_ALL),-x) $(1)/build.sh); \
	fi
endef

########################################

override define FIREBASE_RUN =
	$(if $(filter $(FIREBASE),$(FIREBASE_BIN_BLD)),\
		$(subst cd $(FIREBASE_DIR),cd $(COMPOSER_ROOT),\
		$(subst PATH=,HOME="$(COMPOSER_ROOT)" PATH=,\
			$(call NPM_RUN,$(FIREBASE_DIR),,firebase) \
		)) \
	,\
		cd $(COMPOSER_ROOT) && \
			HOME="$(COMPOSER_ROOT)" \
			$(FIREBASE) \
	)
endef

################################################################################
# {{{1 Pandoc Options
################################################################################

#>override INPUT			:= commonmark
override INPUT				:= markdown
override TMPL_OUTPUT			:= $(c_type)
override EXTN_OUTPUT			:= $(c_type)

########################################
## {{{2 Types
########################################

#> update: TYPE_TARGETS

override DESC_HTML			:= HyperText Markup Language
override DESC_LPDF			:= Portable Document Format
override DESC_EPUB			:= Electronic Publication
override DESC_PRES			:= Reveal.js Presentation
override DESC_DOCX			:= Microsoft Word
override DESC_PPTX			:= Microsoft PowerPoint
override DESC_TEXT			:= Plain Text (well-formatted)
override DESC_LINT			:= Markdown (for testing)

#> update: includes duplicates
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
override EXTN_LINT			:= $(patsubst .%,%,$(COMPOSER_EXT_DEFAULT)).$(EXTN_TEXT)

override TYPE_TARGETS_LIST := \
	HTML \
	LPDF \
	EPUB \
	PRES \
	DOCX \
	PPTX \
	TEXT \
	LINT \

$(foreach TYPE,$(TYPE_TARGETS_LIST),\
	$(if $(filter $(c_type),$(TYPE_$(TYPE))),\
		$(eval override TMPL_OUTPUT := $(TMPL_$(TYPE))); \
		$(eval override EXTN_OUTPUT := $(EXTN_$(TYPE))); \
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
## {{{2 CSS
########################################

override CSS_ICON_MENU			:= $(FONTAWES_DIR)/svgs/solid/list-ul.svg
override CSS_ICON_ARROW_U		:= $(FONTAWES_DIR)/svgs/solid/chevron-up.svg
override CSS_ICON_ARROW_D		:= $(FONTAWES_DIR)/svgs/solid/chevron-down.svg
override CSS_ICON_ARROW_L		:= $(FONTAWES_DIR)/svgs/solid/chevron-left.svg
override CSS_ICON_ARROW_R		:= $(FONTAWES_DIR)/svgs/solid/chevron-right.svg
override CSS_ICON_SEARCH		:= $(FONTAWES_DIR)/svgs/solid/magnifying-glass.svg
override CSS_ICON_COPYRIGHT		:= $(FONTAWES_DIR)/svgs/regular/copyright.svg
override CSS_ICON_GITHUB		:= $(FONTAWES_DIR)/svgs/brands/github.svg

override CSS_ICONS = $(subst |, ,$(subst $(NULL) ,,$(strip \
	|menu		;svg	;$(CSS_ICON_MENU)	;$(TOKEN)	;Menu \
	|arrow-up	;svg	;$(CSS_ICON_ARROW_U)	;$(TOKEN)	;Arrow$(TOKEN)Up \
	|arrow-down	;svg	;$(CSS_ICON_ARROW_D)	;$(TOKEN)	;Arrow$(TOKEN)Down \
	|arrow-left	;svg	;$(CSS_ICON_ARROW_L)	;$(TOKEN)	;Arrow$(TOKEN)Left \
	|arrow-right	;svg	;$(CSS_ICON_ARROW_R)	;$(TOKEN)	;Arrow$(TOKEN)Right \
	|search		;svg	;$(CSS_ICON_SEARCH)	;search		;Search \
	|gpl		;png	;$(EXT_ICON_GPL)	;license	;GPL$(TOKEN)License			;https://www.gnu.org/licenses/gpl-3.0.html \
	|cc-by-nc-nd	;png	;$(EXT_ICON_CC)		;license	;CC$(TOKEN)License			;https://creativecommons.org/licenses/by-nc-nd/4.0 \
	|copyright	;svg	;$(CSS_ICON_COPYRIGHT)	;license	;All$(TOKEN)Rights$(TOKEN)Reserved	;https://wikipedia.org/wiki/All_rights_reserved \
	|github		;svg	;$(CSS_ICON_GITHUB)	;author		;GitHub					;https://github.com \
)))

########################################

override BOOTSWATCH_CSS_LIGHT		:= $(BOOTSWATCH_DIR)/dist/flatly/bootstrap.css
override BOOTSWATCH_CSS_DARK		:= $(BOOTSWATCH_DIR)/dist/slate/bootstrap.css
#>override BOOTSWATCH_CSS_SOLAR_LIGHT	:= $(BOOTSWATCH_DIR)/dist/solar/bootstrap.css
override BOOTSWATCH_CSS_SOLAR_DARK	:= $(BOOTSWATCH_DIR)/dist/solar/bootstrap.css
override BOOTSWATCH_CSS_SOLAR_LIGHT	:= $(BOOTSWATCH_CSS_SOLAR_DARK)
override BOOTSWATCH_CSS_ALT		:= $(BOOTSWATCH_DIR)/dist/quartz/bootstrap.css

override WATERCSS_CSS_LIGHT		:= $(WATERCSS_DIR)/out/light.css
override WATERCSS_CSS_DARK		:= $(WATERCSS_DIR)/out/dark.css
#>override WATERCSS_CSS_ALT		:= $(WATERCSS_DIR)/out/water.css
override WATERCSS_CSS_ALT		:= $(WATERCSS_DIR)/out/water-all.css
override WATERCSS_CSS_SOLAR_LIGHT	:= $(WATERCSS_DIR)/out/solarized-light.css
override WATERCSS_CSS_SOLAR_DARK	:= $(WATERCSS_DIR)/out/solarized-dark.css
override WATERCSS_CSS_SOLAR_ALT		:= $(WATERCSS_DIR)/out/solarized-all.css

#>override MDVIEWER_CSS_DIR		:= $(MDVIEWER_DIR)/themes
override MDVIEWER_CSS_DIR		:= $(MDTHEMES_DIR)
override MDVIEWER_CSS_LIGHT		:= $(MDVIEWER_CSS_DIR)/markdown7.css
override MDVIEWER_CSS_DARK		:= $(MDVIEWER_CSS_DIR)/markdown9.css
override MDVIEWER_CSS_SOLAR_LIGHT	:= $(MDVIEWER_CSS_DIR)/solarized-light.css
override MDVIEWER_CSS_SOLAR_DARK	:= $(MDVIEWER_CSS_DIR)/solarized-dark.css
override MDVIEWER_CSS_ALT		:= $(MDVIEWER_CSS_DIR)/screen.css

override REVEALJS_CSS_LIGHT		:= $(REVEALJS_DIR)/dist/theme/white.css
override REVEALJS_CSS_DARK		:= $(REVEALJS_DIR)/dist/theme/black.css
override REVEALJS_CSS_SOLAR_LIGHT	:= $(REVEALJS_DIR)/dist/theme/solarized.css
override REVEALJS_CSS_SOLAR_DARK	:= $(REVEALJS_DIR)/dist/theme/moon.css
override REVEALJS_CSS_ALT		:= $(REVEALJS_DIR)/dist/theme/league.css

#> update: FILE.*CSS_THEMES
override CSS_THEME			= $(COMPOSER_ART)/themes/theme.$(1)$(if $(filter-out $(SPECIAL_VAL),$(2)),.$(2),-default).css
override CSS_THEMES := $(subst |, ,$(subst $(NULL) ,,$(strip \
	$(foreach FILE,\
		custom \
		custom-solar \
		,\
		|$(PUBLISH)	;$(FILE)	;$(call CUSTOM_PUBLISH_CSS_OVERLAY,$(FILE))		;null		$(if $(filter custom,$(FILE)),;[$(COMPOSER_BASENAME)]) \
		|$(TYPE_HTML)	;$(FILE)	;$(call CUSTOM_PUBLISH_CSS_OVERLAY,$(FILE)) \
		|$(TYPE_PRES)	;$(FILE)	;$(call CUSTOM_PUBLISH_CSS_OVERLAY,$(FILE)) \
	) \
	|$(PUBLISH)	;$(SPECIAL_VAL)		;$(call CSS_THEME,$(TYPE_HTML),solar-$(CSS_ALT))	;$(TOKEN)	;[Bootswatch] \
	|$(PUBLISH)	;light			;$(BOOTSWATCH_CSS_LIGHT)				;light \
	|$(PUBLISH)	;dark			;$(BOOTSWATCH_CSS_DARK)					;dark \
	|$(PUBLISH)	;solar-light		;$(BOOTSWATCH_CSS_SOLAR_LIGHT)				;dark \
	|$(PUBLISH)	;solar-dark		;$(BOOTSWATCH_CSS_SOLAR_DARK)				;dark \
	|$(PUBLISH)	;$(CSS_ALT)		;$(BOOTSWATCH_CSS_ALT)					;dark \
	|$(PUBLISH)	;$(CSS_ALT)		;$(BOOTSWATCH_CSS_ALT)					;null \
	\
	|$(TYPE_HTML)	;$(SPECIAL_VAL)		;$(call CSS_THEME,$(TYPE_HTML),$(CSS_ALT))		;$(TOKEN)	;[Water.css] \
	|$(TYPE_HTML)	;light			;$(WATERCSS_CSS_LIGHT)					;light \
	|$(TYPE_HTML)	;dark			;$(WATERCSS_CSS_DARK)					;dark \
	|$(TYPE_HTML)	;$(CSS_ALT)		;$(WATERCSS_CSS_ALT)					;dark \
	|$(TYPE_HTML)	;$(CSS_ALT)		;$(WATERCSS_CSS_ALT)					;null		;$(TOKEN)	;$(TYPE_HTML) \
	|$(TYPE_HTML)	;solar-light		;$(WATERCSS_CSS_SOLAR_LIGHT)				;dark \
	|$(TYPE_HTML)	;solar-dark		;$(WATERCSS_CSS_SOLAR_DARK)				;dark \
	|$(TYPE_HTML)	;solar-$(CSS_ALT)	;$(WATERCSS_CSS_SOLAR_ALT)				;dark		;$(TOKEN)	;$(PUBLISH) \
	|$(TYPE_HTML)	;solar-$(CSS_ALT)	;$(WATERCSS_CSS_SOLAR_ALT)				;null \
	\
	|$(TOKEN)	;$(TOKEN)		;$(TOKEN)						;$(TOKEN)	;[Markdown$(TOKEN)Viewer] \
	|$(TYPE_HTML)	;alt-light		;$(MDVIEWER_CSS_LIGHT)					;light \
	|$(TYPE_HTML)	;alt-dark		;$(MDVIEWER_CSS_DARK)					;dark \
	|$(TYPE_HTML)	;alt-solar-light	;$(MDVIEWER_CSS_SOLAR_LIGHT)				;dark \
	|$(TYPE_HTML)	;alt-solar-dark		;$(MDVIEWER_CSS_SOLAR_DARK)				;dark \
	|$(TYPE_HTML)	;alt-$(CSS_ALT)		;$(MDVIEWER_CSS_ALT)					;dark \
	\
	|$(TYPE_PRES)	;$(SPECIAL_VAL)		;$(call CSS_THEME,$(TYPE_PRES),dark)			;$(TOKEN)	;[Reveal.js] \
	|$(TYPE_PRES)	;light			;$(REVEALJS_CSS_LIGHT)					;null \
	|$(TYPE_PRES)	;dark			;$(REVEALJS_CSS_DARK)					;null		;$(TOKEN)	;$(TYPE_PRES) \
	|$(TYPE_PRES)	;solar-light		;$(REVEALJS_CSS_SOLAR_LIGHT)				;null \
	|$(TYPE_PRES)	;solar-dark		;$(REVEALJS_CSS_SOLAR_DARK)				;null \
	|$(TYPE_PRES)	;$(CSS_ALT)		;$(REVEALJS_CSS_ALT)					;null \
)))

########################################

override c_css_select_theme = $(strip \
$(subst $(NULL) ,,\
$(call CSS_THEME,\
	$(if $(and $(c_site),$(filter $(1),$(TYPE_HTML))),$(PUBLISH) ,\
	$(if $(filter $(1),$(TYPE_EPUB)),$(TYPE_HTML) ,\
	$(1) \
	)) \
,\
	$(2) \
)))

override c_css_select = $(strip \
$(subst $(NULL) ,,\
$(if $(or \
	$(filter $(1),$(TYPE_HTML)) ,\
	$(filter $(1),$(TYPE_EPUB)) ,\
	$(filter $(1),$(TYPE_PRES)) ,\
),\
$(if $(c_css),\
	$(if $(filter $(c_css),$(SPECIAL_VAL)),,\
	$(if $(wildcard	$(call CSS_THEME,$(word 1,$(subst ., ,$(c_css))),$(word 2,$(subst ., ,$(c_css))))) ,\
			$(call CSS_THEME,$(word 1,$(subst ., ,$(c_css))),$(word 2,$(subst ., ,$(c_css)))) ,\
	$(if $(wildcard	$(call c_css_select_theme,$(1),$(c_css))) ,\
			$(call c_css_select_theme,$(1),$(c_css)) ,\
	$(abspath $(c_css)) \
	))) \
,\
	$(call c_css_select_theme,$(1)) \
))))

########################################
## {{{2 Extensions
########################################

#> validate: ./pandoc/pandoc-*-linux-* --list-extensions=commonmark
#> validate: ./pandoc/pandoc-*-linux-* --list-extensions=markdown

override PANDOC_EXTENSIONS		:=
override PANDOC_EXTENSIONS		+= +ascii_identifiers
override PANDOC_EXTENSIONS		+= +emoji
override PANDOC_EXTENSIONS		+= +fancy_lists
override PANDOC_EXTENSIONS		+= +fenced_divs
override PANDOC_EXTENSIONS		+= +footnotes
override PANDOC_EXTENSIONS		+= +gfm_auto_identifiers
override PANDOC_EXTENSIONS		+= +implicit_figures
override PANDOC_EXTENSIONS		+= +implicit_header_references
override PANDOC_EXTENSIONS		+= +link_attributes
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
endif

########################################
## {{{2 Command
########################################

override PANDOC_FROM			:= $(PANDOC) --strip-comments --wrap="none"
override PANDOC_MD_TO_HTML		:= $(PANDOC_FROM) --from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" --to="$(TMPL_HTML)"
override PANDOC_MD_TO_TEXT		:= $(PANDOC_FROM) --from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" --to="$(TMPL_TEXT)"
override PANDOC_MD_TO_JSON		:= $(PANDOC_FROM) --from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" --to="json"
override PANDOC_JSON_TO_LINT		:= $(PANDOC_FROM) --from="json" --to="$(TMPL_LINT)"

########################################

#> update: TYPE_TARGETS
#> update: PANDOC_FILES

override PANDOC_FILES_MAIN = $(strip \
	$(wildcard $(COMPOSER_DAT)/template.$(2)) \
	$(wildcard $(COMPOSER_DAT)/reference.$(2)) \
	$(if $(or \
		$(filter $(1),$(TYPE_HTML)) ,\
		$(filter $(1),$(TYPE_PRES)) ,\
	),\
		$(wildcard $(abspath $(c_logo))) \
		$(wildcard $(abspath $(c_icon))) \
	) \
)

override PANDOC_FILES_OVERRIDE = $(strip \
	$(if $(1),\
		$(wildcard				$(COMPOSER_CUSTOM)-$(if $(and $(c_site),$(filter $(1),$(TYPE_HTML))),$(PUBLISH),$(strip $(1))).$(3)) \
		$(wildcard $(addsuffix /.$(notdir	$(COMPOSER_CUSTOM))-$(if $(and $(c_site),$(filter $(1),$(TYPE_HTML))),$(PUBLISH),$(strip $(1))).$(3),$(COMPOSER_INCLUDES_TREE))) \
	) \
	$(if $(2),\
		$(wildcard $(CURDIR)/$(2).$(3)) \
	) \
)

override PANDOC_FILES_HEADER = $(strip \
	$(if $(and $(c_site),$(filter $(1),$(TYPE_HTML))),\
						$(patsubst %.js,%-pre.js,$(BOOTSTRAP_ART_JS)) \
		$(if $(call c_css_select,$(1)),	$(BOOTSTRAP_ART_JS) ,\
						$(BOOTSTRAP_DEF_JS) \
		)				$(patsubst %.js,%-post.js,$(BOOTSTRAP_ART_JS)) \
	) \
	$(call PANDOC_FILES_OVERRIDE,$(1),$(2),header) \
)

#>				$(abspath $(call c_css_select,$(1))) ,
override PANDOC_FILES_CSS = $(strip \
	$(if $(and $(c_site),$(filter $(1),$(TYPE_HTML))),\
						$(patsubst %.css,%-pre.css,$(BOOTSTRAP_ART_CSS)) \
		$(if $(call c_css_select,$(1)),	$(BOOTSTRAP_ART_CSS) ,\
						$(BOOTSTRAP_DEF_CSS) \
		)				$(patsubst %.css,%-post.css,$(BOOTSTRAP_ART_CSS)) \
	) \
	$(if $(call c_css_select,$(1)),\
		$(if $(or \
			$(filter $(1),$(TYPE_HTML)) ,\
			$(filter $(1),$(TYPE_EPUB)) ,\
			$(filter $(1),$(TYPE_PRES)) ,\
		),\
			$(if \
				$(and $(3),$(wildcard $(call c_css_select,$(1)))) ,\
				$(realpath $(call c_css_select,$(1))) ,\
				$(call c_css_select,$(1)) \
			) \
		) \
	) \
	$(if $(and $(c_site),$(filter $(1),$(TYPE_HTML))),\
		$(if $(call COMPOSER_YML_DATA_VAL,config.css_overlay),\
			$(call CUSTOM_PUBLISH_CSS_OVERLAY,$(call COMPOSER_YML_DATA_VAL,config.css_overlay)) \
		) \
	) \
	$(if $(and $(3),$(filter $(1),$(TYPE_PRES))),\
		$(patsubst \
			$(COMPOSER_CUSTOM)-$(TYPE_PRES).css ,\
			$(call COMPOSER_TMP_FILE).css \
			,\
			$(call PANDOC_FILES_OVERRIDE,$(1),$(2),css) \
		) \
	,\
		$(call PANDOC_FILES_OVERRIDE,$(1),$(2),css) \
	) \
)

########################################

#> update: TYPE_TARGETS
#> update: PANDOC_FILES

override PANDOC_OPTIONS = $(strip \
	$(if $(COMPOSER_DEBUGIT_ALL),--verbose) \
	\
	--standalone \
	--self-contained \
	--columns="$(COLUMNS)" \
	--eol="$(EOL)" \
	$(if $(or \
		$(filter $(c_type),$(TYPE_HTML)) ,\
		$(filter $(c_type),$(TYPE_PRES)) ,\
		),--wrap="none",--wrap="auto" \
	) \
	\
	$(if $(filter $(c_type),$(TYPE_LPDF)),\
		--pdf-engine="$(PDF_LATEX)" \
		--pdf-engine-opt="-output-directory=$(call COMPOSER_TMP_FILE)" \
		--listings \
	) \
	$(if $(filter $(c_type),$(TYPE_PRES)),\
		--variable=revealjs-url="$(REVEALJS_DIR)" \
	) \
	\
	--from="$(INPUT)$(subst $(NULL) ,,$(PANDOC_EXTENSIONS))" \
	--data-dir="$(COMPOSER_DAT)" \
	$(if $(wildcard $(COMPOSER_DAT)/template.$(TMPL_OUTPUT)),	--template="$(COMPOSER_DAT)/template.$(TMPL_OUTPUT)") \
	$(if $(wildcard $(COMPOSER_DAT)/reference.$(TMPL_OUTPUT)),	--reference-doc="$(COMPOSER_DAT)/reference.$(TMPL_OUTPUT)") \
	\
	$(foreach FILE,$(call PANDOC_FILES_HEADER	,$(c_type),$(c_base).$(EXTN_OUTPUT),1),--include-in-header="$(FILE)") \
	$(foreach FILE,$(call PANDOC_FILES_CSS		,$(c_type),$(c_base).$(EXTN_OUTPUT),1),--css="$(FILE)") \
	\
	$(foreach FILE,$(COMPOSER_YML_LIST),--defaults="$(FILE)") \
	\
	$(if $(c_lang),\
		--variable=lang="$(c_lang)" \
	) \
	$(if $(wildcard $(c_icon)),\
		$(if $(or \
			$(filter $(c_type),$(TYPE_HTML)) ,\
			$(filter $(c_type),$(TYPE_PRES)) ,\
		),\
			--variable=header-includes="<link rel=\"icon\" type=\"image/x-icon\" href=\"$(abspath $(c_icon))\">" \
		) \
	) \
	$(if $(c_toc),\
		--table-of-contents \
		$(if $(filter $(c_toc),$(SPECIAL_VAL)),	--toc-depth="$(DEPTH_MAX)" --number-sections ,\
							--toc-depth="$(c_toc)" \
		) \
	) \
	$(if $(c_level),\
		$(if $(filter $(c_type),$(TYPE_HTML)),			--section-divs) \
		$(if $(filter $(c_type),$(TYPE_LPDF)),\
			$(if $(filter $(c_level),$(SPECIAL_VAL)),	--top-level-division="part" ,\
			$(if $(filter $(c_level),$(DEPTH_DEFAULT)),	--top-level-division="chapter" ,\
									--top-level-division="section" \
		))) \
		$(if $(filter $(c_type),$(TYPE_EPUB)),\
			$(if $(filter $(c_level),$(SPECIAL_VAL)),	--epub-chapter-level="$(DEPTH_DEFAULT)" ,\
									--epub-chapter-level="$(c_level)" \
		)) \
		$(if $(filter $(c_type),$(TYPE_PRES)),\
			$(if $(filter $(c_level),$(SPECIAL_VAL)),	--section-divs --slide-level="1" ,\
									--section-divs --slide-level="$(DEPTH_DEFAULT)" \
		)) \
	) \
	$(if $(filter $(c_type),$(TYPE_LPDF)),\
		$(if $(c_margin),			--variable=geometry="margin=$(c_margin)" ,\
			$(if $(c_margin_top),		--variable=geometry="top=$(c_margin_top)") \
			$(if $(c_margin_bottom),	--variable=geometry="bottom=$(c_margin_bottom)") \
			$(if $(c_margin_left),		--variable=geometry="left=$(c_margin_left)") \
			$(if $(c_margin_right),		--variable=geometry="right=$(c_margin_right)") \
		) \
	) \
	$(if $(c_options),$(c_options)) \
	\
	--to="$(TMPL_OUTPUT)" \
	--output="$(CURDIR)/$(c_base).$(EXTN_OUTPUT)" \
)

########################################

override PANDOC_OPTIONS_ERROR		:=

################################################################################
# {{{1 Composer Operation
################################################################################

override ENV_MAKE			= $(ENV) $(REALMAKE) $(call MAKEFLAGS_ENV) \
	$(if $(filter $(NOTHING),$(1)),,MAKEJOBS="$(1)") \
	$(if $(filter $(NOTHING),$(2)),,COMPOSER_DOCOLOR="$(2)") \
	$(if $(filter $(NOTHING),$(3)),,COMPOSER_DEBUGIT="$(3)") \
	$(foreach FILE,$(4),$(FILE)="$($(FILE))")

override COMPOSER_MY_PATH		:= \$$(abspath \$$(dir \$$(lastword \$$(MAKEFILE_LIST))))
override COMPOSER_TEACHER		:= \$$(abspath \$$(dir \$$(COMPOSER_MY_PATH)))/$(MAKEFILE)

override COMPOSER_REGEX			:= [a-zA-Z0-9][a-zA-Z0-9+_.-]*
override COMPOSER_REGEX_PREFIX		:= [_.]
override SED_ESCAPE_LIST		:= ^[:alnum:]

#> update: includes duplicates
override DEBUGIT			:= _debug
override PUBLISH			:= site

override $(DEBUGIT)-output		:= $(if $(COMPOSER_DEBUGIT),,>/dev/null)
override $(PUBLISH)-$(DEBUGIT)-output	:= $(if $(COMPOSER_DEBUGIT),$(if $(COMPOSER_DEBUGIT_ALL),,| $(SED) -n "/^<!--[[:space:]]/p"),>/dev/null)

########################################
## {{{2 Options
########################################

#> update: COMPOSER_OPTIONS

override COMPOSER_OPTIONS_GLOBAL := \
	MAKEJOBS \
	COMPOSER_DOCOLOR \
	COMPOSER_DEBUGIT \
	COMPOSER_INCLUDE \
	COMPOSER_DEPENDS \
	COMPOSER_KEEPING \
	COMPOSER_LOG \
	COMPOSER_EXT \
	c_site \
	c_type \
	c_lang \
	c_logo \
	c_icon \
	c_css \

override COMPOSER_OPTIONS_LOCAL := \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_EXPORTS \
	COMPOSER_IGNORES \
	c_base \
	c_list \
	c_toc \
	c_level \
	c_margin \
	c_margin_top \
	c_margin_bottom \
	c_margin_left \
	c_margin_right \
	c_options \

override COMPOSER_OPTIONS_MAKE := \
	MAKEJOBS \
	COMPOSER_DOCOLOR \
	COMPOSER_DEBUGIT \
	COMPOSER_INCLUDE \
	COMPOSER_DEPENDS \
	COMPOSER_KEEPING \
	COMPOSER_LOG \
	COMPOSER_EXT \
	COMPOSER_TARGETS \
	COMPOSER_SUBDIRS \
	COMPOSER_EXPORTS \
	COMPOSER_IGNORES \

override COMPOSER_OPTIONS_PANDOC := \
	c_site \
	c_type \
	c_base \
	c_list \
	c_lang \
	c_logo \
	c_icon \
	c_css \
	c_toc \
	c_level \
	$(if $(and \
		$(if $(c_margin),,1) ,\
		$(or \
			$(c_margin_top) ,\
			$(c_margin_bottom) ,\
			$(c_margin_left) ,\
			$(c_margin_right) ,\
		)),\
			c_margin_top \
			c_margin_bottom \
			c_margin_left \
			c_margin_right \
		,\
			c_margin \
	) \
	c_options \

override COMPOSER_OPTIONS_PUBLISH_ENV := \
	MAKEJOBS \
	COMPOSER_DOCOLOR \
	COMPOSER_DEBUGIT \
	c_base \
	c_list \

#>	COMPOSER_INCLUDE$(TOKEN)
override COMPOSER_OPTIONS_PUBLISH := \
	COMPOSER_DEPENDS$(TOKEN) \
	COMPOSER_EXT$(TOKEN)$(COMPOSER_EXT_DEFAULT) \
	COMPOSER_TARGETS$(TOKEN) \
	COMPOSER_SUBDIRS$(TOKEN) \
	c_site$(TOKEN)1 \
	c_type$(TOKEN)$(EXTN_HTML) \

$(foreach FILE,$(COMPOSER_OPTIONS_GLOBAL)	,$(eval export $(FILE)))
$(foreach FILE,$(COMPOSER_OPTIONS_LOCAL)	,$(eval unexport $(FILE)))
$(if $(COMPOSER_DEBUGIT_ALL),\
	$(info #> COMPOSER_OPTIONS_GLOBAL	[$(strip $(COMPOSER_OPTIONS_GLOBAL))]) \
	$(info #> COMPOSER_OPTIONS_LOCAL	[$(strip $(COMPOSER_OPTIONS_LOCAL))]) \
)

override COMPOSER_OPTIONS := \
	$(shell $(SED) -n "s|^$(call COMPOSER_REGEX_OVERRIDE,,1).*$$|\1|gp" $(COMPOSER) \
	| $(SED) $(if $(and \
		$(if $(c_margin),,1) ,\
		$(or \
			$(c_margin_top) ,\
			$(c_margin_bottom) ,\
			$(c_margin_left) ,\
			$(c_margin_right) ,\
		)),\
			"/^c_margin$$/d" \
		,\
			"/^c_margin_.+$$/d" \
	) \
)
$(foreach FILE,$(COMPOSER_OPTIONS),\
	$(if $(or \
		$(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)) ,\
		$(filter $(FILE),$(COMPOSER_OPTIONS_LOCAL)) ,\
		),,$(error #> $(COMPOSER_FULLNAME): COMPOSER_OPTIONS (scope): $(FILE)) \
	) \
)
$(foreach FILE,$(COMPOSER_OPTIONS),\
	$(if $(or \
		$(filter $(FILE),$(COMPOSER_OPTIONS_MAKE)) ,\
		$(filter $(FILE),$(COMPOSER_OPTIONS_PANDOC)) ,\
		),,$(error #> $(COMPOSER_FULLNAME): COMPOSER_OPTIONS (headers): $(FILE)) \
	) \
)

#>		$(FILE)="$($(FILE))"
override COMPOSER_OPTIONS_EXPORT = \
	$(foreach FILE,\
		$(COMPOSER_OPTIONS_GLOBAL) \
		$(COMPOSER_OPTIONS_LOCAL) \
		,\
		$(FILE)="$(subst ",\",$($(FILE)))" \
	)

########################################
## {{{2 Targets
########################################

#> update: includes duplicates

#> update: $(DEBUGIT): targets list
#> update: $(TESTING): targets list

override COMPOSER_PANDOC		:= compose

override HELPOUT			:= help
override EXAMPLE			:= template

override HEADERS			:= .headers

override MAKE_DB			:= .make_database
override LISTING			:= .all_targets
override NOTHING			:= .null

override DISTRIB			:= _release
override UPGRADE			:= _update
override CREATOR			:= _setup

override DEBUGIT			:= _debug
override TESTING			:= _test

override CHECKIT			:= check
override CONFIGS			:= config
override TARGETS			:= targets

override DOSETUP			:= init
override CONVICT			:= commit
override EXPORTS			:= export

override PUBLISH			:= site
override INSTALL			:= install
override CLEANER			:= clean
override DOITALL			:= all
override SUBDIRS			:= subdirs
override PRINTER			:= list

#> validate: grep -E -e "[{][{][{][0-9]+" -e "^([#][>])?[.]PHONY[:]" Makefile
#> validate: grep -E "[)]-[a-z]+" Makefile
#> validate: make .all_targets | sed -r "s|[:].*$||g" | sort -u
override COMPOSER_RESERVED := \
	$(COMPOSER_PANDOC) \
	\
	$(HELPOUT) \
	$(EXAMPLE) \
	\
	$(HEADERS) \
	\
	$(MAKE_DB) \
	$(LISTING) \
	$(NOTHING) \
	\
	$(DISTRIB) \
	$(UPGRADE) \
	$(CREATOR) \
	\
	$(DEBUGIT) \
	$(TESTING) \
	\
	$(CHECKIT) \
	$(CONFIGS) \
	$(TARGETS) \
	\
	$(DOSETUP) \
	$(CONVICT) \
	$(EXPORTS) \
	\
	$(PUBLISH) \
	$(INSTALL) \
	$(CLEANER) \
	$(DOITALL) \
	$(SUBDIRS) \
	$(PRINTER) \

override COMPOSER_RESERVED_SKIP := \
	$(COMPOSER_PANDOC) \
	\
	$(HELPOUT) \
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
	\
	$(SUBDIRS) \

########################################

override DOFORCE			:= force

########################################

override define COMPOSER_RESERVED_DOITALL =
$(if $(filter $(1)-$(2),$(MAKECMDGOALS)),\
	$(eval export override COMPOSER_DOITALL_$(1) := $(2)) \
)
.PHONY: $(1)-$(2)
$(1)-$(2): $(1)
$(1)-$(2):
	@$(ECHO) ""
endef

$(foreach FILE,\
	$(filter-out $(COMPOSER_RESERVED_SKIP),$(COMPOSER_RESERVED)),\
	$(foreach MOD,\
		$(DOITALL) \
		$(DOFORCE) \
		,\
		$(eval $(call COMPOSER_RESERVED_DOITALL,$(FILE),$(MOD))) \
	) \
)

$(eval $(call COMPOSER_RESERVED_DOITALL,$(HEADERS)-$(EXAMPLE),$(DOITALL)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(UPGRADE),$(PRINTER)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(CHECKIT),$(HELPOUT)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(CONVICT),$(PRINTER)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-library,$(DOITALL)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-library,$(DOFORCE)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-$(PRINTER),$(patsubst .%,%,$(NOTHING))))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-$(PRINTER),$(DOITALL)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-$(PRINTER),$(PRINTER)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-$(EXAMPLE),$(TESTING)))
$(eval $(call COMPOSER_RESERVED_DOITALL,$(PUBLISH)-$(EXAMPLE),$(CONFIGS)))

ifneq ($(COMPOSER_DOITALL_$(PUBLISH)),)
export override COMPOSER_DOITALL_$(DOITALL) := $(COMPOSER_DOITALL_$(PUBLISH))
endif

########################################
## {{{2 Testing
########################################

override TESTING_MAKEJOBS		:= 8
ifneq ($(and \
	$(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))) ,\
	$(filter $(MAKEJOBS_DEFAULT),$(MAKEJOBS)) \
),)
override MAKEJOBS			:= $(TESTING_MAKEJOBS)
override MAKEFLAGS			:= $(subst --jobs=$(MAKEJOBS_DEFAULT),--jobs=$(MAKEJOBS),$(MAKEFLAGS))
endif

override TESTING_LOGFILE		:= .$(COMPOSER_BASENAME).$(TESTING).log
override TESTING_COMPOSER_DIR		:= .$(COMPOSER_BASENAME)
override TESTING_COMPOSER_MAKEFILE	:= $(TESTING_DIR)/$(TESTING_COMPOSER_DIR)/$(MAKEFILE)

########################################
## {{{2 Publish
########################################

override define COMPOSER_YML_DATA_SKEL =
{ variables: {
  title-prefix:				null,

  $(PUBLISH)-config: {
    homepage:				null,
    brand:				null,
    copyright:				null,
    $(COMPOSER_TINYNAME):				$(PUBLISH_COMPOSER),

    search_name:			null,
    search_site:			null,
    search_call:			null,
    search_form:			null,

    header:				null,
    footer:				null,

    css_overlay:			$(PUBLISH_CSS_OVERLAY),
    copy_protect:			$(PUBLISH_COPY_PROTECT),

    cols_break:				$(PUBLISH_COLS_BREAK),
    cols_sticky:			[ $(PUBLISH_COLS_STICKY_L), $(PUBLISH_COLS_STICKY_C), $(PUBLISH_COLS_STICKY_R) ],
    cols_resticky:			[ $(PUBLISH_COLS_RESTICKY_L), $(PUBLISH_COLS_RESTICKY_C), $(PUBLISH_COLS_RESTICKY_R) ],
    cols_order:				[ $(PUBLISH_COLS_ORDER_L), $(PUBLISH_COLS_ORDER_C), $(PUBLISH_COLS_ORDER_R) ],
    cols_reorder:			[ $(PUBLISH_COLS_REORDER_L), $(PUBLISH_COLS_REORDER_C), $(PUBLISH_COLS_REORDER_R) ],
    cols_size:				[ $(PUBLISH_COLS_SIZE_L), $(PUBLISH_COLS_SIZE_C), $(PUBLISH_COLS_SIZE_R) ],
    cols_resize:			[ $(PUBLISH_COLS_RESIZE_L), $(PUBLISH_COLS_RESIZE_C), $(PUBLISH_COLS_RESIZE_R) ],

    metainfo:				"$(PUBLISH_METAINFO)",
    metainfo_null:			"$(PUBLISH_METAINFO_NULL)",
    metalist: {
      $(PUBLISH_CREATORS): {
        title:				"$(PUBLISH_CREATORS_TITLE)",
        display:			"$(PUBLISH_CREATORS_PRINT)",
      },
      $(PUBLISH_METALIST): {
        title:				"$(PUBLISH_METALIST_TITLE)",
        display:			"$(PUBLISH_METALIST_PRINT)",
      },
    },

    readtime:				"$(PUBLISH_READTIME)",
    readtime_wpm:			$(PUBLISH_READTIME_WPM),
  },

  $(PUBLISH)-library: {
    folder:				$(LIBRARY_FOLDER),
    auto_update:			$(LIBRARY_AUTO_UPDATE),

    append:				$(LIBRARY_APPEND),

    digest_title:			"$(LIBRARY_DIGEST_TITLE)",
    digest_continue:			"$(LIBRARY_DIGEST_CONTINUE)",
    digest_permalink:			"$(LIBRARY_DIGEST_PERMALINK)",
    digest_chars:			$(LIBRARY_DIGEST_CHARS),
    digest_count:			$(LIBRARY_DIGEST_COUNT),
    digest_expanded:			$(LIBRARY_DIGEST_EXPANDED),
    digest_spacer:			$(LIBRARY_DIGEST_SPACER),

    lists_expanded:			$(LIBRARY_LISTS_EXPANDED),
    lists_spacer:			$(LIBRARY_LISTS_SPACER),

    sitemap_title:			"$(LIBRARY_SITEMAP_TITLE)",
    sitemap_expanded:			$(LIBRARY_SITEMAP_EXPANDED),
    sitemap_spacer:			$(LIBRARY_SITEMAP_SPACER),
  },

  $(PUBLISH)-nav-top:				null,
  $(PUBLISH)-nav-bottom:			null,
  $(PUBLISH)-nav-left:			null,
  $(PUBLISH)-nav-right:			null,

  $(PUBLISH)-info-top:			null,
  $(PUBLISH)-info-bottom:			null,
}}
endef

override define COMPOSER_YML_DATA_METALIST_SKEL =
  title:				{ null: [] },
  date:				{ null: [] },$(foreach FILE,$(COMPOSER_YML_DATA_METALIST),$(NEWLINE)  $(FILE): { null: [] },)
endef

#>	| $(YQ_WRITE) ".variables.$(PUBLISH)-$(1)" 2>/dev/null
override COMPOSER_YML_DATA_VAL = $(shell \
	$(ECHO) '$(call YQ_EVAL_DATA_FORMAT,$(COMPOSER_YML_DATA))' \
	| $(YQ_WRITE) ".variables.$(PUBLISH)-$(1)" \
	| $(SED) "/^null$$/d" \
)

########################################

override $(PUBLISH)-cache-root		:= $(COMPOSER_TMP)/$(PUBLISH)-cache
override $(PUBLISH)-cache		:= $($(PUBLISH)-cache-root)

#> update: WILDCARD_YML
#> update: $(COMPOSER_LIBRARY): $($(PUBLISH)-cache): $(COMPOSER_YML_DATA): $(COMPOSER_YML_LIST_FILE)
override COMPOSER_YML_LIST_FILE		:= $(call PANDOC_FILES_OVERRIDE,,$(c_base).$(EXTN_OUTPUT),yml)
ifneq ($(COMPOSER_YML_LIST_FILE),)
override $(PUBLISH)-cache		:= $($(PUBLISH)-cache-root)-$(c_base).$(EXTN_OUTPUT)
endif

override $(PUBLISH)-caches-begin := \
	nav-top \
	row-begin \
	nav-left \
	column-begin \

override $(PUBLISH)-caches-end := \
	column-end \
	nav-right \
	row-end \
	nav-bottom \

override $(PUBLISH)-caches := \
	$(foreach FILE,\
		$($(PUBLISH)-caches-begin) \
		$($(PUBLISH)-caches-end) \
		,\
		$($(PUBLISH)-cache).$(FILE).$(EXTN_HTML) \
	)

########################################

ifneq ($(COMPOSER_YML_LIST),)
override COMPOSER_LIBRARY_DIR		:=
$(foreach FILE,$(addsuffix /$(COMPOSER_YML),$(COMPOSER_INCLUDES_TREE)),\
$(if $(wildcard $(FILE)),\
	$(eval override COMPOSER_LIBRARY_DIR := $(shell \
		$(YQ_WRITE) ".variables.$(PUBLISH)-library.folder" $(FILE) 2>/dev/null \
		| $(SED) "/^null$$/d" \
	)) \
	$(if $(COMPOSER_LIBRARY_DIR),\
		$(eval override COMPOSER_LIBRARY_ROOT	:= $(abspath $(dir $(FILE)))) \
		$(eval override COMPOSER_LIBRARY	:= $(COMPOSER_LIBRARY_ROOT)/$(notdir $(COMPOSER_LIBRARY_DIR))) \
	) \
))
endif

ifeq ($(COMPOSER_LIBRARY_ROOT),$(COMPOSER_DIR))
override COMPOSER_LIBRARY_ROOT		:= $(COMPOSER_ROOT)
override COMPOSER_LIBRARY		:= $(COMPOSER_LIBRARY_ROOT)/$(notdir $(COMPOSER_LIBRARY))
endif

override $(PUBLISH)-library		:= $(COMPOSER_LIBRARY)/$(PUBLISH)-library
override $(PUBLISH)-library-metadata	:= $(COMPOSER_LIBRARY)/_metadata.yml
override $(PUBLISH)-library-index	:= $(COMPOSER_LIBRARY)/_index.yml
override $(PUBLISH)-library-digest	:= $(COMPOSER_LIBRARY)/index$(COMPOSER_EXT_DEFAULT)
override $(PUBLISH)-library-digest-src	:= $(COMPOSER_LIBRARY)/index-include$(COMPOSER_EXT_SPECIAL)
override $(PUBLISH)-library-sitemap	:= $(COMPOSER_LIBRARY)/sitemap$(COMPOSER_EXT_DEFAULT)
override $(PUBLISH)-library-sitemap-src	:= $(COMPOSER_LIBRARY)/sitemap-include$(COMPOSER_EXT_SPECIAL)
override $(PUBLISH)-library-append	:= $(COMPOSER_LIBRARY)/$(PUBLISH)-append$(COMPOSER_EXT_SPECIAL)

override define $(PUBLISH)-library-append-src =
$(NULL)
$(PUBLISH_CMD_BEG) break $(PUBLISH_CMD_END)
$(NULL)
endef

########################################

override COMPOSER_YML_DATA		:= $(strip $(call COMPOSER_YML_DATA_SKEL))
ifneq ($(COMPOSER_YML_LIST),)
override COMPOSER_YML_DATA		:= $(shell $(call YQ_EVAL_DATA,$(COMPOSER_YML_DATA),$(COMPOSER_YML_LIST)))
endif

#> update: WILDCARD_YML
ifneq ($(c_base),)
override COMPOSER_YML_LIST_FILE		:= $(call PANDOC_FILES_OVERRIDE,,$(c_base).$(EXTN_OUTPUT),yml)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> WILDCARD_YML			[$(COMPOSER_YML_LIST_FILE)]))
ifneq ($(COMPOSER_YML_LIST_FILE),)
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> INCLUDE_YML			[$(COMPOSER_YML_LIST_FILE)]))
override COMPOSER_YML_LIST		:= $(strip $(COMPOSER_YML_LIST) $(COMPOSER_YML_LIST_FILE))
$(if $(COMPOSER_DEBUGIT_ALL),$(info #> COMPOSER_YML_LIST		[$(COMPOSER_YML_LIST)]))
override COMPOSER_YML_DATA		:= $(shell $(call YQ_EVAL_DATA,$(COMPOSER_YML_DATA),$(COMPOSER_YML_LIST_FILE)))
endif
endif

ifneq ($(COMPOSER_LIBRARY),)
ifneq ($(COMPOSER_LIBRARY),$(CURDIR))
ifneq ($(COMPOSER_LIBRARY_ROOT),$(CURDIR))
override COMPOSER_YML_DATA		:= $(shell $(call YQ_EVAL_DATA,$(COMPOSER_YML_DATA),$(shell $(call ENV_MAKE) --directory $(COMPOSER_LIBRARY_ROOT) $(CONFIGS)-COMPOSER_YML_LIST),library))
endif
endif
endif

#>override COMPOSER_YML_DATA		:= $(call YQ_EVAL_DATA_FORMAT,$(COMPOSER_YML_DATA))

override COMPOSER_YML_DATA_METALIST := $(shell \
	$(ECHO) '$(call COMPOSER_YML_DATA_VAL,config.metalist)' \
	| $(YQ_WRITE) "keys | .[]" 2>/dev/null \
	| $(SED) "/^null$$/d" \
)

#######################################

override PUBLISH_CMD_ROOT		:= <$(COMPOSER_TINYNAME)_root>
override PUBLISH_CMD_BEG		:= <!-- $(COMPOSER_TINYNAME) $(MARKER)
#>override PUBLISH_CMD_END		:= $(MARKER) -->
override PUBLISH_CMD_END		:= -->

override COMPOSER_ROOT_PATH		:=
override COMPOSER_LIBRARY_PATH		:=
ifneq ($(c_site),)
override COMPOSER_ROOT_PATH		:= $(shell $(REALPATH) $(CURDIR) $(COMPOSER_ROOT))
ifneq ($(COMPOSER_LIBRARY),)
override COMPOSER_LIBRARY_PATH		:= $(shell $(REALPATH) $(CURDIR) $(COMPOSER_LIBRARY) 2>/dev/null)
endif
endif

override PUBLISH_SH_GLOBAL := \
	COMPOSER_HOMEPAGE \
	COMPOSER_TINYNAME \
	CREATED_TAGLINE \
	$(TOKEN) \
	\
	MARKER \
	DIVIDE \
	EXPAND \
	TOKEN \
	$(TOKEN) \
	\
	SPECIAL_VAL \
	DEPTH_MAX \
	$(TOKEN) \
	\
	HTML_SPACE \
	HTML_BREAK \
	HTML_HIDE \
	MENU_SELF \
	$(TOKEN) \
	\
	SED_ESCAPE_LIST \
	$(TOKEN) \
	\
	PUBLISH_CMD_ROOT \
	PUBLISH_CMD_BEG \
	PUBLISH_CMD_END \

override PUBLISH_SH_LOCAL := \
	SED \
	$(TOKEN) \
	\
	CAT \
	ECHO \
	EXPR \
	HEAD \
	PRINTF \
	TR \
	$(TOKEN) \
	\
	YQ_WRITE \
	COMPOSER_YML_DATA \
	COMPOSER_YML_DATA_METALIST \
	$(TOKEN) \
	\
	COMPOSER_DIR \
	COMPOSER_ROOT \
	COMPOSER_ROOT_REGEX \
	COMPOSER_ROOT_PATH \
	COMPOSER_LIBRARY_PATH \
	COMPOSER_LIBRARY_METADATA \
	COMPOSER_LIBRARY_INDEX \

#>		$(filter-out $(TOKEN),$(PUBLISH_SH_GLOBAL))
override PUBLISH_SH_RUN = \
	$(foreach FILE,\
		$(filter-out $(TOKEN),$(PUBLISH_SH_LOCAL)) \
		,\
		$(if $(filter $(FILE),YQ_WRITE),			$(FILE)="$(subst ",,$($(FILE)))" ,\
		$(if $(filter $(FILE),COMPOSER_YML_DATA),		$(FILE)='$(call YQ_EVAL_DATA_FORMAT,$($(FILE)))' ,\
		$(if $(filter $(FILE),COMPOSER_LIBRARY_METADATA),	$(FILE)="$($(PUBLISH)-library-metadata)" ,\
		$(if $(filter $(FILE),COMPOSER_LIBRARY_INDEX),		$(FILE)="$($(PUBLISH)-library-index)" ,\
		$(FILE)="$($(FILE))" \
		)))) \
	) \
	$(BASH) -e $(if $(COMPOSER_DEBUGIT_ALL),-x) $(CUSTOM_PUBLISH_SH)

override PUBLISH_SH_HELPERS := \
	metainfo \
	contents \
	$(addprefix metalist-,$(COMPOSER_YML_DATA_METALIST)) \
	readtime \

########################################

override PUBLISH_ROOT			:= $(CURDIR)/_$(PUBLISH)
override PUBLISH_INDEX			:= index
override PUBLISH_LIBRARY		:= $(LIBRARY_FOLDER_ALT)
override PUBLISH_LIBRARY_ALT		:= $(PUBLISH_LIBRARY)-$(CONFIGS)

#>override PUBLISH_OUT_README		:= $(PUBLISH_CMD_ROOT)/../$(OUT_README).$(PUBLISH).$(EXTN_HTML)
override PUBLISH_OUT_README		:= $(PUBLISH_CMD_ROOT)/../$(PUBLISH_INDEX).$(EXTN_HTML)

override PUBLISH_BOOTSTRAP_TREE		:= $(notdir $(BOOTSTRAP_DIR))/site/content
override PUBLISH_DIRS := \
	. \
	$(patsubst .%,%,$(NOTHING)) \
	$(CONFIGS) \
	$(notdir $(PANDOC_DIR)) \
	$(PUBLISH_BOOTSTRAP_TREE)/docs/$(BOOTSTRAP_DOC_VER)/getting-started \

override PUBLISH_FILES := \
	$(PUBLISH_INDEX).$(EXTN_HTML) \
	$(word 2,$(PUBLISH_DIRS))/$(PUBLISH_INDEX).$(EXTN_HTML) \
	$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_INDEX).$(EXTN_HTML) \
	$(word 4,$(PUBLISH_DIRS))/MANUAL.$(EXTN_HTML) \
	$(word 5,$(PUBLISH_DIRS))/introduction.$(EXTN_HTML) \

override PUBLISH_EXAMPLE		:= $(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/examples)
override PUBLISH_PAGEDIR		:= $(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/pages)
override PUBLISH_TESTING		:= $(patsubst ./%,%,$(PUBLISH_PAGEDIR)/2020-01-01+$(EXAMPLE)_00)
override PUBLISH_SHOWDIR		:= $(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/themes)
override PUBLISH_INCLUDE		:= $(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_INDEX)-digest)
override PUBLISH_INCLUDE_ALT		:= $(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/$(notdir $(PUBLISH_INCLUDE)))

override PUBLISH_DIRS_CONFIGS := \
	.$(COMPOSER_BASENAME) \
	$(PUBLISH_DIRS) \
	$(PUBLISH_BOOTSTRAP_TREE) \
	$(PUBLISH_PAGEDIR) \
	$(PUBLISH_SHOWDIR) \

#> $(PUBLISH_SHOWDIR) > $(PUBLISH_INCLUDE)
override PUBLISH_DIRS_DEBUGIT := \
	$(word 1,$(PUBLISH_FILES)) \
	$(PUBLISH_EXAMPLE).$(EXTN_HTML) \

#WORKING:NOW:NOW:DOCS
#	$(word 1,$(PUBLISH_FILES)) \
#	$(word 2,$(PUBLISH_FILES)) \
#	$(word 3,$(PUBLISH_FILES)) \
#	$(word 4,$(PUBLISH_FILES)) \
#	$(word 5,$(PUBLISH_FILES)) \
#	$(PUBLISH_EXAMPLE).$(EXTN_HTML) \
#	$(PUBLISH_PAGEDIR).$(EXTN_HTML) \
#	$(PUBLISH_TESTING).$(EXTN_HTML) \
#	$(PUBLISH_INCLUDE).$(EXTN_HTML) \
#	$(PUBLISH_INCLUDE_ALT).$(EXTN_HTML) \
#	$(PUBLISH_SHOWDIR)/$(DOITALL) \

########################################

override COMPOSER_LIBRARY_AUTO_UPDATE	:=
ifneq ($(and \
	$(c_site) ,\
	$(COMPOSER_LIBRARY) ,\
	$(filter-out $(CURDIR),$(COMPOSER_LIBRARY)) ,\
	$(or \
		$(call COMPOSER_YML_DATA_VAL,library.auto_update) ,\
		$(filter $(DOFORCE),$(COMPOSER_DOITALL_$(PUBLISH))) ,\
	) \
),)
override COMPOSER_LIBRARY_AUTO_UPDATE	:= 1
endif

########################################
## {{{2 Filesystem
########################################

override COMPOSER_ROOT_REGEX		:= $(shell $(ECHO) "$(COMPOSER_ROOT)"		| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g")
override COMPOSER_EXPORT_REGEX		:= $(shell $(ECHO) "$(COMPOSER_EXPORT)"		| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g")
override COMPOSER_LIBRARY_ROOT_REGEX	:= $(shell $(ECHO) "$(COMPOSER_LIBRARY_ROOT)"	| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g")

########################################

override COMPOSER_DOSETUP_DIR		:= $(CURDIR)/.$(COMPOSER_BASENAME)

#> update: TYPE_TARGETS
override COMPOSER_EXPORTS_DEFAULT	:= $(foreach TYPE,$(TYPE_TARGETS_LIST),*.$(EXTN_$(TYPE)))
ifeq ($(abspath $(dir $(COMPOSER_EXPORT))),$(CURDIR))
ifeq ($(filter $(notdir $(COMPOSER_EXPORT)),$(COMPOSER_IGNORES)),)
override COMPOSER_IGNORES		:= $(notdir $(COMPOSER_EXPORT))$(if $(COMPOSER_IGNORES), $(COMPOSER_IGNORES))
endif
endif

########################################

#> update: COMPOSER_TARGETS.*=
#> update: COMPOSER_SUBDIRS.*=

override COMPOSER_CONTENTS		:= $(sort $(wildcard *))
override COMPOSER_CONTENTS_DIRS		:= $(patsubst %/.,%,$(wildcard $(addsuffix /.,$(COMPOSER_CONTENTS))))
override COMPOSER_CONTENTS_FILES	:= $(filter-out $(COMPOSER_CONTENTS_DIRS),$(COMPOSER_CONTENTS))
override COMPOSER_CONTENTS_EXT		:= $(filter %$(COMPOSER_EXT),$(COMPOSER_CONTENTS_FILES))

ifneq ($(COMPOSER_EXT),)
override COMPOSER_TARGETS_AUTO		:= $(patsubst %$(COMPOSER_EXT),%.$(EXTN_OUTPUT),$(COMPOSER_CONTENTS_EXT))
else
override COMPOSER_TARGETS_AUTO		:= $(addsuffix .$(EXTN_OUTPUT),$(filter-out %.$(EXTN_OUTPUT),$(COMPOSER_CONTENTS_FILES)))
endif

override COMPOSER_TARGETS		:= $(patsubst .$(TARGETS),$(COMPOSER_TARGETS_AUTO),$(COMPOSER_TARGETS))
override COMPOSER_SUBDIRS		:= $(patsubst .$(TARGETS),$(COMPOSER_CONTENTS_DIRS),$(COMPOSER_SUBDIRS))
override COMPOSER_EXPORTS		:= $(patsubst .$(TARGETS),$(COMPOSER_EXPORTS_DEFAULT),$(COMPOSER_EXPORTS))
override COMPOSER_IGNORES		:= $(patsubst .$(TARGETS),$(COMPOSER_TARGETS_AUTO) $(COMPOSER_CONTENTS_DIRS),$(COMPOSER_IGNORES))

ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(COMPOSER_TARGETS_AUTO)
endif
ifeq ($(COMPOSER_SUBDIRS),)
override COMPOSER_SUBDIRS		:= $(COMPOSER_CONTENTS_DIRS)
endif

ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out $(subst *,%,$(COMPOSER_IGNORES)),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(CONFIGS)-$(TARGETS)
endif
endif
ifneq ($(COMPOSER_SUBDIRS),)
override COMPOSER_SUBDIRS		:= $(filter-out $(subst *,%,$(COMPOSER_IGNORES)),$(COMPOSER_SUBDIRS))
ifeq ($(COMPOSER_SUBDIRS),)
override COMPOSER_SUBDIRS		:= $(NOTHING)-$(CONFIGS)-$(SUBDIRS)
endif
endif

ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out %-$(EXPORTS),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(TARGETS)-$(EXPORTS)
endif
endif
ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out %-$(CLEANER),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(TARGETS)-$(CLEANER)
endif
endif
ifneq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(filter-out %-$(DOITALL),$(COMPOSER_TARGETS))
ifeq ($(COMPOSER_TARGETS),)
override COMPOSER_TARGETS		:= $(NOTHING)-$(TARGETS)-$(DOITALL)
endif
endif

ifeq ($(COMPOSER_EXPORTS),)
override COMPOSER_EXPORTS		:= $(COMPOSER_EXPORTS_DEFAULT)
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
#> update: COMPOSER_TARGETS.*=
#> update: COMPOSER_SUBDIRS.*=
ifeq ($(notdir $(TESTING_DIR)),$(notdir $(CURDIR)))
ifneq ($(COMPOSER_TARGETS),$(NOTHING))
override COMPOSER_TARGETS		:=
endif
ifneq ($(COMPOSER_SUBDIRS),$(NOTHING))
override COMPOSER_SUBDIRS		:=
endif
endif

########################################
## {{{2 Functions
########################################

#> update: $(HEADERS)-$(EXAMPLE)

override define $(COMPOSER_TINYNAME)-note =
	$(call $(HEADERS)-note,$(CURDIR),$(1),note,$(@))
endef

override define $(COMPOSER_TINYNAME)-makefile =
	$(call $(INSTALL)-$(MAKEFILE),$(1),-$(INSTALL),,$(2))
endef

override define $(COMPOSER_TINYNAME)-make =
	$(call $(HEADERS)-note,$(CURDIR),$(1),$(notdir $(MAKE)),$(@)); \
	$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(1)
endef

override define $(COMPOSER_TINYNAME)-mkdir =
	if [ ! -d "$(1)" ]; then \
		$(call $(HEADERS)-file,$(CURDIR),$(1),$(@)); \
		$(ECHO) "$(_S)"; \
		$(MKDIR) $(1) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

override define $(COMPOSER_TINYNAME)-ln =
	if	[ -d "$(1)" ] || \
		[ -f "$(1)" ]; \
	then \
		$(call $(HEADERS)-file,$(CURDIR),$(_E)$(1)$(_D) $(MARKER) $(_M)$(2),$(@)); \
		$(ECHO) "$(_S)"; \
		$(LN) $(1) $(2) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

override define $(COMPOSER_TINYNAME)-cp =
	if	[ -d "$(1)" ] || \
		[ -f "$(1)" ]; \
	then \
		$(call $(HEADERS)-file,$(CURDIR),$(_E)$(1)$(_D) $(MARKER) $(_M)$(2),$(@)); \
		$(ECHO) "$(_S)"; \
		$(CP) $(1) $(2) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

override define $(COMPOSER_TINYNAME)-mv =
	if	[ -d "$(1)" ] || \
		[ -f "$(1)" ]; \
	then \
		$(call $(HEADERS)-file,$(CURDIR),$(_N)$(1)$(_D) $(MARKER) $(_M)$(2),$(@)); \
		$(ECHO) "$(_S)"; \
		$(MV) $(1) $(2) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

override define $(COMPOSER_TINYNAME)-rm =
	if	[ -d "$(1)" ] || \
		[ -f "$(1)" ]; \
	then \
		$(call $(HEADERS)-rm,$(CURDIR),$(1),$(@)); \
		$(ECHO) "$(_S)"; \
		$(RM) $(if $(2),--recursive) $(1) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
endef

########################################
## {{{2 $(COMPOSER_PANDOC)
########################################

#> update: TYPE_TARGETS
#> update: PANDOC_FILES

ifneq ($(c_site),)
ifneq ($(COMPOSER_YML_LIST),)
override INCLUDE_FILE_HEADER		:= $(shell $(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.header)"	| $(SED) "s|$(PUBLISH_CMD_ROOT)|$(COMPOSER_ROOT)|g")
override INCLUDE_FILE_FOOTER		:= $(shell $(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.footer)"	| $(SED) "s|$(PUBLISH_CMD_ROOT)|$(COMPOSER_ROOT)|g")
override INCLUDE_FILE_APPEND		:= $(shell $(ECHO) "$(call COMPOSER_YML_DATA_VAL,library.append)"	| $(SED) "s|$(PUBLISH_CMD_ROOT)|$(COMPOSER_ROOT)|g")
endif
endif

override PANDOC_FILES_TYPE = $(strip \
	$(foreach TYPE,$(TYPE_TARGETS_LIST),\
		$(if $(filter $(1),$(TYPE_$(TYPE))),\
			$(TYPE) \
		) \
	) \
)

override PANDOC_FILES_LIST = $(strip \
	$(filter-out \
		$(if $(filter $(1),$(TYPE_HTML)),%.$(EXTN_PRES)) \
		$(if $(filter $(1),$(TYPE_TEXT)),%.$(EXTN_LINT)) \
		,\
		$(filter %.$(EXTN_$(call PANDOC_FILES_TYPE,$(1))),$(2)) \
	) \
)

override PANDOC_FILES_SPLIT = $(strip \
	$(foreach TYPE,$(TYPE_TARGETS_LIST),\
		$(foreach SPLIT,$(call PANDOC_FILES_LIST,$(TYPE_$(TYPE)),$(1)),\
			$(patsubst %.$(EXTN_$(TYPE)),%,$(SPLIT))$(TOKEN)$(EXTN_$(TYPE)) \
		) \
	) \
)

#> update: WILDCARD_YML
override $(COMPOSER_PANDOC)-dependencies = $(strip $(filter-out $(3),\
	$(COMPOSER) \
	$(COMPOSER_INCLUDES) \
	$(COMPOSER_YML_LIST) \
	$(if $(filter $(1),$(PUBLISH)-cache),\
		$(if $(COMPOSER_LIBRARY_AUTO_UPDATE),\
			$($(PUBLISH)-library) \
		) \
	) \
	$(if $(filter $(1),$(PUBLISH)),\
		$(COMPOSER_LIBRARY)/$(MAKEFILE) \
		$($(PUBLISH)-library-metadata) \
		$($(PUBLISH)-library-index) \
		$(INCLUDE_FILE_APPEND) \
		$(if $(filter-out $(CURDIR),$(COMPOSER_LIBRARY)),\
			$(COMPOSER_CONTENTS_EXT) \
		) \
	) \
	$(if $(filter $(1),$(TYPE_HTML)),\
		$(if $(c_site),\
			$(if $(call PANDOC_FILES_OVERRIDE,,$(2),yml),\
				$($(PUBLISH)-cache-root)-$(2) ,\
				$($(PUBLISH)-cache) \
			) \
			$(INCLUDE_FILE_HEADER) \
			$(INCLUDE_FILE_FOOTER) \
		) \
	) \
	$(if $(and $(1),\
		$(filter-out $(PUBLISH)-cache,\
		$(filter-out $(PUBLISH),\
		$(1) \
		)) \
	),\
		$(eval override NAME := $(call PANDOC_FILES_TYPE,$(1))) \
		$(eval override BASE := $(word 1,$(subst $(TOKEN), ,$(call PANDOC_FILES_SPLIT,$(2))))) \
		$(eval override EXTN := $(word 2,$(subst $(TOKEN), ,$(call PANDOC_FILES_SPLIT,$(2))))) \
		$(call PANDOC_FILES_MAIN	,$(TYPE_$(NAME)),$(TMPL_$(NAME))) \
		$(call PANDOC_FILES_HEADER	,$(TYPE_$(NAME)),$(2)) \
		$(call PANDOC_FILES_CSS		,$(TYPE_$(NAME)),$(2)) \
		$(call PANDOC_FILES_OVERRIDE	,,$(2),yml) \
		$(call c_list_var		,$(BASE),$(EXTN)) \
	) \
))

########################################

ifneq ($(c_base),)
ifeq ($(filter $(c_base).$(EXTN_OUTPUT),$(COMPOSER_TARGETS)),)
$(c_base).$(EXTN_OUTPUT): $(call $(COMPOSER_PANDOC)-dependencies,$(c_type),$(c_base).$(EXTN_OUTPUT))
endif
endif
$(foreach TYPE,$(TYPE_TARGETS_LIST),\
	$(foreach FILE,$(call PANDOC_FILES_LIST,$(TYPE_$(TYPE)),$(COMPOSER_TARGETS)),\
		$(eval $(FILE): $(call $(COMPOSER_PANDOC)-dependencies,$(TYPE_$(TYPE)),$(FILE))) \
		$(if $(and \
			$(filter-out $(c_base).$(EXTN_OUTPUT),$(FILE)) ,\
			$(call PANDOC_FILES_OVERRIDE,,$(FILE),yml) \
		),\
			$(eval $($(PUBLISH)-cache-root)-$(FILE): $($(PUBLISH)-cache-root)) \
			$(eval $($(PUBLISH)-cache-root)-$(FILE): ;) \
		) \
	) \
)
$(sort \
	$(foreach TYPE,$(TYPE_TARGETS_LIST),\
		$(call PANDOC_FILES_MAIN	,$(TYPE_$(TYPE)),$(TMPL_$(TYPE))) \
	) \
): ;

#>$(DOITALL)-$(TARGETS) $(COMPOSER_TARGETS) \
#>$(DOITALL)-$(TARGETS) $(filter %.$(EXTN_HTML),$(COMPOSER_TARGETS)) \
#>$(SUBDIRS)-$(DOITALL) $(COMPOSER_SUBDIRS) $(addprefix $(SUBDIRS)-$(DOITALL)-,$(COMPOSER_SUBDIRS))
ifneq ($(COMPOSER_LIBRARY_AUTO_UPDATE),)
$(DOITALL)-$(TARGETS) \
$(SUBDIRS)-$(DOITALL) $(addprefix $(SUBDIRS)-$(DOITALL)-,$(COMPOSER_SUBDIRS)) \
	: \
	$($(PUBLISH)-library)
endif

########################################

override define $(COMPOSER_PANDOC)-$(NOTHING) =
	if	[ -z "$(c_type)" ] || \
		[ -z "$(c_base)" ] || \
		[ -z "$(call c_list_var)" ]; \
	then \
		$(call $(HEADERS)-note,$(COMPOSER_PANDOC),c_type=\"$(c_type)\" c_base=\"$(c_base)\" c_list=\"$(c_list)\"$(_D) $(_E)c_list_var=\"$(call c_list_var)\",$(NOTHING)); \
		exit 1; \
	fi
endef

override define $(COMPOSER_PANDOC)-$(PRINTER) =
	{	$(ECHO) "$(call COMPOSER_TIMESTAMP) "; \
		$(call $(HEADERS)-$(COMPOSER_PANDOC)-PANDOC_OPTIONS); \
		if [ -n "$(c_list_file)" ]; then \
			$(ECHO) " #$(MARKER) $(c_list_file)"; \
		fi; \
		$(ECHO) "\n"; \
	}
endef

################################################################################
# }}}1
################################################################################
# {{{1 Documentation
################################################################################

########################################
## {{{2 $(HELPOUT)
########################################

.PHONY: $(HELPOUT)-TITLE_%
$(HELPOUT)-TITLE_%:
#>	@$(call TITLE_LN,0,$(COMPOSER_FULLNAME) $(DIVIDE) $(*))
	@$(call TITLE_LN,-1,$(COMPOSER_FULLNAME) $(DIVIDE) $(*))

.PHONY: $(HELPOUT)-CLOSING_TITLE_%
$(HELPOUT)-CLOSING_TITLE_%:
	@$(call TITLE_LN,$(*),Final Notes,1)

.PHONY: $(HELPOUT)-USAGE
$(HELPOUT)-USAGE:
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)[-f $(EXPAND)/$(MAKEFILE)]$(_D) $(_E)[variables]$(_D) $(_M)<filename>.<extension>"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)[-f $(EXPAND)/$(MAKEFILE)]$(_D) $(_E)[variables]$(_D) $(_M)<target>"

.PHONY: $(HELPOUT)-FOOTER
$(HELPOUT)-FOOTER:
	@if [ "$(COMPOSER_DOITALL_$(HELPOUT))" = "$(TYPE_PRES)" ]; then \
		$(call TITLE_LN,2,$(COMPOSER_CLOSING)); \
	else \
		$(ENDOLINE); \
		$(LINERULE); \
		$(ENDOLINE); \
	fi
	@$(PRINT) "$(_H)$(COMPOSER_TAGLINE)$(_D)"

########################################

.PHONY: $(HELPOUT)
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
$(HELPOUT): $(HELPOUT)-VARIABLES_HELPER_2
$(HELPOUT): $(HELPOUT)-TARGETS_TITLE_1
$(HELPOUT): $(HELPOUT)-TARGETS_PRIMARY_2
$(HELPOUT): $(HELPOUT)-TARGETS_ADDITIONAL_2
#>$(HELPOUT): $(HELPOUT)-TARGETS_INTERNAL_2
ifeq ($(COMPOSER_DOITALL_$(HELPOUT)),$(TYPE_PRES))
$(HELPOUT): $(HELPOUT)-CLOSING_TITLE_1
$(HELPOUT): $(HELPOUT)-EXAMPLES_2
$(HELPOUT): $(HELPOUT)-FOOTER
else
$(HELPOUT): $(HELPOUT)-EXAMPLES_1
$(HELPOUT): $(HELPOUT)-FOOTER
endif
$(HELPOUT):
	@$(ECHO) ""

########################################
### {{{3 $(HELPOUT)-VARIABLES
########################################

.PHONY: $(HELPOUT)-VARIABLES_TITLE_%
$(HELPOUT)-VARIABLES_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Variables,1)

#> update: TYPE_TARGETS
#> update: READ_ALIASES
.PHONY: $(HELPOUT)-VARIABLES_FORMAT_%
$(HELPOUT)-VARIABLES_FORMAT_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Formatting Variables); fi
	@$(TABLE_M3) "$(_H)Variable"				"$(_H)Purpose"				"$(_H)Value"
	@$(TABLE_M3) ":---"					":---"					":---"
	@$(TABLE_M3) "$(_C)[c_site]$(_D)    ~ \`$(_E)S$(_D)\`"	"Enable $(_C)[Static Websites]$(_D)"	"$(_M)$(c_site)"
	@$(TABLE_M3) "$(_C)[c_type]$(_D)    ~ \`$(_E)T$(_D)\`"	"Desired output format"			"$(_M)$(c_type)"
	@$(TABLE_M3) "$(_C)[c_base]$(_D)    ~ \`$(_E)B$(_D)\`"	"Base of output file"			"$(_M)$(c_base)"
	@$(TABLE_M3) "$(_C)[c_list]$(_D)    ~ \`$(_E)L$(_D)\`"	"List of input files(s)"		"$(_M)$(notdir $(call c_list_var))$(_D)$(if $(call c_list_var_source), $(_S)#$(MARKER)$(_D) $(_E)$(call c_list_var_source)$(_D))"
	@$(TABLE_M3) "$(_C)[c_lang]$(_D)    ~ \`$(_E)a$(_D)\`"	"Language for document headers"		"$(_M)$(c_lang)"
	@$(TABLE_M3) "$(_C)[c_logo]$(_D)    ~ \`$(_E)g$(_D)\`"	"Logo image ($(_C)[HTML]$(_D) formats)"	"$(_M)$(notdir $(c_logo))"
	@$(TABLE_M3) "$(_C)[c_icon]$(_D)    ~ \`$(_E)i$(_D)\`"	"Icon image ($(_C)[HTML]$(_D) formats)"	"$(_M)$(notdir $(c_icon))"
	@$(TABLE_M3) "$(_C)[c_css]$(_D)     ~ \`$(_E)c$(_D)\`"	"Location of CSS file"			"$(_M)$(notdir $(call c_css_select,$(c_type)))$(_D)"
	@$(TABLE_M3) "$(_C)[c_toc]$(_D)     ~ \`$(_E)t$(_D)\`"	"Table of contents depth"		"$(_M)$(c_toc)"
	@$(TABLE_M3) "$(_C)[c_level]$(_D)   ~ \`$(_E)l$(_D)\`"	"Chapter/slide header level"		"$(_M)$(c_level)"
	@$(TABLE_M3) "$(_C)[c_margin]$(_D)  ~ \`$(_E)m$(_D)\`"	"Size of margins ($(_C)[PDF]$(_D))"	"$(_M)$(c_margin)"
	@$(TABLE_M3) "$(_C)[c_options]$(_D) ~ \`$(_E)o$(_D)\`"	"Custom Pandoc options"			"$(_M)$(c_options)"
	@$(ENDOLINE)
	@$(TABLE_M3) "$(_H)Values$(_D) ($(_C)[c_type]$(_D))"	"$(_H)Format"			"$(_H)Extension"
	@$(TABLE_M3) ":---"					":---"				":---"
	@$(TABLE_M3) "\`$(_M)$(TYPE_HTML)$(_D)\`"		"$(_C)[$(DESC_HTML)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_HTML)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_LPDF)$(_D)\`"		"$(_C)[$(DESC_LPDF)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_LPDF)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_EPUB)$(_D)\`"		"$(_C)[$(DESC_EPUB)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_EPUB)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_PRES)$(_D)\`"		"$(_C)[$(DESC_PRES)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_PRES)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_DOCX)$(_D)\`"		"$(_C)[$(DESC_DOCX)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_DOCX)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_PPTX)$(_D)\`"		"$(_C)[$(DESC_PPTX)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_PPTX)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_TEXT)$(_D)\`"		"$(_C)[$(DESC_TEXT)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_TEXT)"
	@$(TABLE_M3) "\`$(_M)$(TYPE_LINT)$(_D)\`"		"$(_C)[$(DESC_LINT)]$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_LINT)"
	@$(ENDOLINE)
	@$(PRINT) "  * *Other $(_C)[c_type]$(_D) values will be passed directly to $(_C)[Pandoc]$(_D)*"
	@$(PRINT) "  * *Special $(_C)[c_css]$(_D) values:*"
	@$(COLUMN_2) "      * *\`$(_N)$(CSS_ALT)$(_D)\`"					"= Use the alternate default stylesheet*"
	@$(COLUMN_2) "      * *\`$(_N)$(SPECIAL_VAL)$(_D)\`"					"= Revert to the $(_C)[Pandoc]$(_D) default*"
	@$(COLUMN_2) "  * *Special $(_C)[c_toc]$(_D) value: \`$(_N)$(SPECIAL_VAL)$(_D)\`"	"= List all headers, and number sections*"
	@$(COLUMN_2) "  * *Special $(_C)[c_level]$(_D) value: \`$(_N)$(SPECIAL_VAL)$(_D)\`"	"= Varies by $(_C)[c_type]$(_D) $(_E)(see [c_level])$(_D)*"
	@$(PRINT) "  * *An empty $(_C)[c_margin]$(_D) value enables individual margins:*"
	@$(PRINT) "      * *\`$(_C)c_margin_top$(_D)\`    ~ \`$(_E)mt$(_D)\`*"
	@$(PRINT) "      * *\`$(_C)c_margin_bottom$(_D)\` ~ \`$(_E)mb$(_D)\`*"
	@$(PRINT) "      * *\`$(_C)c_margin_left$(_D)\`   ~ \`$(_E)ml$(_D)\`*"
	@$(PRINT) "      * *\`$(_C)c_margin_right$(_D)\`  ~ \`$(_E)mr$(_D)\`*"

.PHONY: $(HELPOUT)-VARIABLES_CONTROL_%
$(HELPOUT)-VARIABLES_CONTROL_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Control Variables); fi
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
	@$(TABLE_M3) "$(_C)[COMPOSER_EXPORTS]"	"See also: $(_C)[c_site]$(_E)/$(_C)[$(EXPORTS)]$(_D)"				"$(_C)[$(CONFIGS)]"				#> "$(if $(COMPOSER_EXPORTS),$(_M)$(COMPOSER_EXPORTS))"
	@$(TABLE_M3) "$(_C)[COMPOSER_IGNORES]"	"See also: $(_C)[c_site]$(_E)/$(_C)[$(EXPORTS)]$(_D)"				"$(_C)[$(CONFIGS)]"				#> "$(if $(COMPOSER_IGNORES),$(_M)$(COMPOSER_IGNORES))"
	@$(ENDOLINE)
	@$(PRINT) "  * *$(_C)[MAKEJOBS]$(_D)         ~ \`$(_E)c_jobs$(_D)\`  ~ \`$(_E)J$(_D)\`*"
	@$(PRINT) "  * *$(_C)[COMPOSER_DOCOLOR]$(_D) ~ \`$(_E)c_color$(_D)\` ~ \`$(_E)C$(_D)\`*"
	@$(PRINT) "  * *$(_C)[COMPOSER_DEBUGIT]$(_D) ~ \`$(_E)c_debug$(_D)\` ~ \`$(_E)V$(_D)\`*"
	@$(PRINT) "  * *\`$(_N)(makejobs)$(_D)\` = empty is disabled / number of threads / \`$(_N)$(SPECIAL_VAL)$(_D)\` is no limit*"
	@$(PRINT) "  * *\`$(_N)(debugit)$(_D)\`  = empty is disabled / any value enables / \`$(_N)$(SPECIAL_VAL)$(_D)\` is full tracing*"
	@$(PRINT) "  * *\`$(_N)(keeping)$(_D)\`  = empty is no limit / number to keep / \`$(_N)0$(_D)\` is none*"
	@$(PRINT) "  * *\`$(_N)(boolean)$(_D)\`  = empty is disabled / any value enables*"

.PHONY: $(HELPOUT)-VARIABLES_HELPER_%
$(HELPOUT)-VARIABLES_HELPER_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Helper Variables); fi
	@$(TABLE_M3) "$(_H)Variable"		"$(_H)Purpose"							"$(_H)Value"
	@$(TABLE_M3) ":---"			":---"								":---"
	@$(TABLE_M3) "$(_C)[CURDIR]"		"$(_C)[GNU Make]$(_D) current directory"			"\`$(_C)\$$PWD$(_D)\` $(_E)$(DIVIDE)$(_D) \`$(_M)$(DOMAKE)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_CURDIR]"	"Detects $(_C)[COMPOSER_INCLUDE]$(_D)"				"$(_H)[CURDIR]$(_D) $(_E)$(DIVIDE)$(_D) \`$(_M)$(COMPOSER_SETTINGS)$(_D)\`"
#>	@$(TABLE_M3) "$(_C)[COMPOSER_DIR]"	"Location of $(_C)[$(COMPOSER_BASENAME)]$(_D)"			"$(_M)$(call $(HEADERS)-path-dir,$(COMPOSER_DIR))"
	@$(TABLE_M3) "$(_C)[COMPOSER_DIR]"	"Location of $(_C)[$(COMPOSER_BASENAME)]$(_D)"			"$(_M)$(call $(HEADERS)-path-root,$(COMPOSER_DIR))"
	@$(TABLE_M3) "$(_C)[COMPOSER_ROOT]"	"Topmost level of current tree"					"$(_M)$(call $(HEADERS)-path-root,$(COMPOSER_ROOT))"
	@$(TABLE_M3) "$(_C)[COMPOSER_EXPORT]"	"Target: $(_C)[$(EXPORTS)]$(_D)"				"$(if $(COMPOSER_EXPORT),$(_M)$(patsubst $(COMPOSER_ROOT)/%,$(_H)[COMPOSER_ROOT]$(_D)/$(_M)%,$(COMPOSER_EXPORT))$(_D) )\`$(_N)(mk)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_LIBRARY]"	"Target: $(_C)[$(PUBLISH)]$(_E)/$(_C)[$(PUBLISH)-library]$(_D)"	"$(if $(COMPOSER_LIBRARY),$(_M)$(patsubst $(COMPOSER_ROOT)/%,$(_H)[COMPOSER_ROOT]$(_D)/$(_M)%,$(COMPOSER_LIBRARY))$(_D) )\`$(_N)(yml)$(_D)\`"
	@$(TABLE_M3) "$(_C)[COMPOSER_SRC]"	"Repositories and downloads"					"$(_H)[COMPOSER_DIR]$(_D)/$(_M)$(call COMPOSER_CONV,,$(COMPOSER_SRC))"
	@$(TABLE_M3) "$(_C)[COMPOSER_ART]"	"$(_C)[$(COMPOSER_BASENAME)]$(_D) supporting files"		"$(_H)[COMPOSER_DIR]$(_D)/$(_M)$(call COMPOSER_CONV,,$(COMPOSER_ART))"
#>	@$(TABLE_M3) "$(_C)[COMPOSER_DAT]"	"$(_C)[Pandoc]$(_D) supporting files"				"$(_H)[COMPOSER_DIR]$(_D)/$(_M)$(call COMPOSER_CONV,,$(COMPOSER_DAT))"
	@$(TABLE_M3) "$(_C)[COMPOSER_DAT]"	"$(_C)[Pandoc]$(_D) supporting files"				"$(_H)[COMPOSER_ART]$(_D)/$(_M)$(patsubst $(COMPOSER_ART)/%,%,$(COMPOSER_DAT))"
	@$(TABLE_M3) "$(_C)[COMPOSER_TMP]"	"Cache and working directory"					"$(_H)[CURDIR]$(_D)/$(_M)$(notdir $(COMPOSER_TMP))"
	@$(ENDOLINE)
	@$(PRINT) "  * *\`$(_N)(mk)$(_D)\` = configurable in \`$(_M)$(COMPOSER_SETTINGS)$(_D)\`*"
	@$(PRINT) "  * *\`$(_N)(yml)$(_D)\` = configurable in \`$(_M)$(COMPOSER_YML)$(_D)\`*"

########################################
### {{{3 $(HELPOUT)-TARGETS
########################################

.PHONY: $(HELPOUT)-TARGETS_TITLE_%
$(HELPOUT)-TARGETS_TITLE_%:
	@$(call TITLE_LN,$(*),$(COMPOSER_BASENAME) Targets,1)

.PHONY: $(HELPOUT)-TARGETS_PRIMARY_%
$(HELPOUT)-TARGETS_PRIMARY_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Primary Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)]"			"Basic $(HELPOUT) overview $(_E)(default)$(_D)"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)-$(DOITALL)]"		"Console version of \`$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)\` $(_E)(no reference sections)$(_D)"
	@$(TABLE_M2) "$(_C)[$(EXAMPLE)]"			"Print settings template: \`$(_M)$(COMPOSER_SETTINGS)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(EXAMPLE)-yml]"			"Print settings template: \`$(_M)$(COMPOSER_YML)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(EXAMPLE)-md]"			"Print \`$(_C)$(INPUT)$(_D)\` file template"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_PANDOC)]"		"Document creation engine $(_E)(see [c_type])$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)]"			"Build $(_C)[HTML]$(_D) files as $(_C)[Static Websites]$(_D) $(_E)(see [c_site])$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(DOITALL)]"		"Do $(_C)[$(PUBLISH)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(DOFORCE)]"		"Do $(_C)[$(PUBLISH)]$(_D) recursively: including $(_H)[COMPOSER_LIBRARY]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(CLEANER)]"		"Remove $(_C)[c_site]$(_D) only: $(_H)[COMPOSER_LIBRARY]$(_E)/$(_H)[COMPOSER_TMP]$(_D)"
	@$(TABLE_M2) "$(_C)[$(INSTALL)]"			"Current directory initialization: \`$(_M)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(INSTALL)-$(DOITALL)]"		"Do $(_C)[$(INSTALL)]$(_D) recursively $(_E)(no overwrite)$(_D)"
	@$(TABLE_M2) "$(_C)[$(INSTALL)-$(DOFORCE)]"		"Recursively force overwrite of \`$(_M)$(MAKEFILE)$(_D)\` files"
	@$(TABLE_M2) "$(_C)[$(CLEANER)]"			"Remove output files: $(_C)[COMPOSER_TARGETS]$(_D) $(_E)$(DIVIDE)$(_D) $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(CLEANER)-$(DOITALL)]"		"Do $(_C)[$(CLEANER)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_C)[$(_N)*$(_C)-$(CLEANER)]"		"Any targets named this way will also be run by $(_C)[$(CLEANER)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DOITALL)]"			"Create output files: $(_C)[COMPOSER_TARGETS]$(_D) $(_E)$(DIVIDE)$(_D) $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DOITALL)-$(DOITALL)]"		"Do $(_C)[$(DOITALL)]$(_D) recursively: $(_C)[COMPOSER_SUBDIRS]$(_D)"
	@$(TABLE_M2) "$(_C)[$(_N)*$(_C)-$(DOITALL)]"		"Any targets named this way will also be run by $(_C)[$(DOITALL)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PRINTER)]"			"Show updated files: \`$(_N)*$(_D)\`$(_C)[COMPOSER_EXT]$(_D) $(_E)$(MARKER)$(_D) $(_C)[COMPOSER_LOG]$(_D)"

.PHONY: $(HELPOUT)-TARGETS_ADDITIONAL_%
$(HELPOUT)-TARGETS_ADDITIONAL_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Additional Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(DISTRIB)]"			"Upgrade all tools and supporting files to next versions"
	@$(TABLE_M2) "$(_C)[$(DISTRIB)-$(DOITALL)]"		"Also make \`$(_M)$(OUT_README).$(_N)*$(_D)\` files and $(_C)[Static Websites]$(_D)"
	@$(TABLE_M2) "$(_C)[$(UPGRADE)]"			"Update all included components $(_E)(see [Requirements])$(_D)"
	@$(TABLE_M2) "$(_C)[$(UPGRADE)-$(DOITALL)]"		"Additionally perform all source code builds"
	@$(TABLE_M2) "$(_C)[$(UPGRADE)-$(PRINTER)]"		"Show changes made to each $(_E)(see [Repository Versions])$(_D)"
	@$(TABLE_M2) "$(_C)[$(UPGRADE)-$(_N)*$(_C)]"		"Complete fetch and build for a specific component"
	@$(TABLE_M2) "$(_C)[$(DEBUGIT)]"			"Diagnostics, tests targets list in $(_C)[COMPOSER_DEBUGIT]$(_D)"
	@$(TABLE_M2) "$(_C)[$(DEBUGIT)-file]"			"Export $(_C)[$(DEBUGIT)]$(_D) results to a plain text file"
	@$(TABLE_M2) "$(_C)[$(CHECKIT)]"			"List system packages and versions $(_E)(see [Requirements])$(_D)"
	@$(TABLE_M2) "$(_C)[$(CHECKIT)-$(DOITALL)]"		"Complete $(_C)[$(CHECKIT)]$(_D) package list, and system information"
	@$(TABLE_M2) "$(_C)[$(CONFIGS)]"			"Show values of all $(_C)[$(COMPOSER_BASENAME) Variables]$(_D)"
	@$(TABLE_M2) "$(_C)[$(CONFIGS)-$(DOITALL)]"		"Complete $(_C)[$(CONFIGS)]$(_D), including environment variables"
	@$(TABLE_M2) "$(_C)[$(CONFIGS)-$(_N)*$(_C)]"		"Export individual $(_C)[Composer Variables]$(_D) values"
	@$(TABLE_M2) "$(_C)[$(CONFIGS)-yml]"			"JSON export of \`$(_M)$(COMPOSER_YML)$(_D)\` configuration"
	@$(TABLE_M2) "$(_C)[$(TARGETS)]"			"List all available targets for the current directory"
	@$(TABLE_M2) "$(_C)[$(DOSETUP)]"			"Create and link a \`$(_M).$(COMPOSER_BASENAME)$(_D)\` in current directory"
	@$(TABLE_M2) "$(_C)[$(DOSETUP)-$(DOFORCE)]"		"Completely reset and relink an existing \`$(_M).$(COMPOSER_BASENAME)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(CONVICT)]"			"Timestamped $(_N)[Git]$(_D) commit of the current directory tree"
	@$(TABLE_M2) "$(_C)[$(CONVICT)-$(DOITALL)]"		"Automatic $(_C)[$(CONVICT)]$(_D), without \`$(_C)\$$EDITOR$(_D)\` step"
	@$(TABLE_M2) "$(_C)[$(EXPORTS)]"			"Synchronize \`$(_M)$(notdir $(COMPOSER_EXPORT_DEFAULT))$(_D)\` export of $(_H)[COMPOSER_ROOT]$(_D)"
	@$(TABLE_M2) "$(_C)[$(EXPORTS)-$(DOITALL)]"		"Also publish to upstream hosting providers"
	@$(TABLE_M2) "$(_C)[$(EXPORTS)-$(DOFORCE)]"		"Publish only, without synchronizing first"
	@$(TABLE_M2) "$(_C)[$(_N)*$(_C)-$(EXPORTS)]"		"Any targets named this way will also be run by $(_C)[$(EXPORTS)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-library]"		"Build or update the $(_H)[COMPOSER_LIBRARY]$(_D)"
#> $(PUBLISH)-$(PRINTER)-$(patsubst .%,%,$(NOTHING)) > $(PUBLISH)-$(PRINTER)-$(DOITALL)
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(PRINTER)]"		"Show $(_H)[COMPOSER_LIBRARY]$(_D) metadata for current directory"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(PRINTER)-$(DOITALL)]"	"Do $(_C)[$(PUBLISH)-$(PRINTER)]$(_D) for entire directory tree"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(PRINTER)-$(PRINTER)]"	"Output existing metadata fields and values"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(PRINTER)-$(patsubst .%,%,$(NOTHING))]"	"List files which are missing metadata fields"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(PRINTER)-$(_N)*$(_C)]"	"Find and export all files named \`$(_N)*$(_D)\` in the tree"

.PHONY: $(HELPOUT)-TARGETS_INTERNAL_%
$(HELPOUT)-TARGETS_INTERNAL_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Internal Targets); fi
	@$(TABLE_M2) "$(_H)Target"				"$(_H)Purpose"
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(HELPOUT)-$(HELPOUT)]"		"Complete \`$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)\` content $(_E)(similar to [$(HELPOUT)-$(DOITALL)])$(_D)"
	@$(TABLE_M2) "$(_C)[.$(EXAMPLE)-$(INSTALL)]"		"The \`$(_M)$(MAKEFILE)$(_D)\` used by $(_C)[$(INSTALL)]$(_D) $(_E)(see [Templates])$(_D)"
	@$(TABLE_M2) "$(_C)[.$(EXAMPLE)]"			"The \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` used by $(_C)[$(EXAMPLE)]$(_D) $(_E)(see [Templates])$(_D)"
	@$(TABLE_M2) "$(_C)[$(HEADERS)]"			"Series of targets that handle all informational output"
	@$(TABLE_M2) "$(_C)[$(HEADERS)-$(EXAMPLE)]"		"For testing default $(_C)[$(HEADERS)]$(_D) output"
	@$(TABLE_M2) "$(_C)[$(HEADERS)-$(EXAMPLE)-$(DOITALL)]"	"For testing complete $(_C)[$(HEADERS)]$(_D) output"
	@$(TABLE_M2) "$(_C)[$(MAKE_DB)]"			"Complete contents of $(_C)[GNU Make]$(_D) internal state"
	@$(TABLE_M2) "$(_C)[$(LISTING)]"			"Extracted list of all targets from $(_C)[$(MAKE_DB)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(NOTHING)]"			"Placeholder to specify or detect empty values"
	@$(TABLE_M2) "$(_C)[$(CREATOR)]"			"Extracts embedded files from \`$(_M)$(MAKEFILE)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(CREATOR)-$(DOITALL)]"		"Also builds all \`$(_M)$(OUT_README).$(_N)*$(_D)\` output files"
	@$(TABLE_M2) "$(_C)[$(TESTING)]"			"Test suite, validates all supported features"
	@$(TABLE_M2) "$(_C)[$(TESTING)-file]"			"Export $(_C)[$(TESTING)]$(_D) results to a plain text file"
	@$(TABLE_M2) "$(_C)[$(TESTING)-dir]"			"Only create directory structure, and do $(_C)[$(DISTRIB)]$(_D)"
	@$(TABLE_M2) "$(_C)[$(TESTING)-$(PRINTER)]"		"Output available test cases, for running directly"
	@$(TABLE_M2) "$(_C)[$(CHECKIT)-$(HELPOUT)]"		"Minimized $(_C)[$(CHECKIT)]$(_D) output $(_E)(used for [Requirements])$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(COMPOSER_SETTINGS)]"	"$(_H)[COMPOSER_LIBRARY]$(_D) configured template: \`$(_M)$(COMPOSER_SETTINGS)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(COMPOSER_YML)]"	"$(_H)[COMPOSER_LIBRARY]$(_D) configured template: \`$(_M)$(COMPOSER_YML)$(_D)\`"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(EXAMPLE)]"		"$(_C)[Static Websites]$(_D) example \`$(_M)$(notdir $(PUBLISH_ROOT))$(_D)\` in $(_H)[COMPOSER_DIR]$(_D)"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(EXAMPLE)-$(TESTING)]"	"Version configured to test specific variations"
	@$(TABLE_M2) "$(_C)[$(PUBLISH)-$(EXAMPLE)-$(CONFIGS)]"	"Only create directory structure and source files"
	@$(TABLE_M2) "$(_C)[$(SUBDIRS)]"			"Expands $(_C)[COMPOSER_SUBDIRS]$(_D) into \`$(_C)$(SUBDIRS)-$(_N)*$(_C)-$(_N)*$(_D)\` targets"
	@$(TABLE_M2) "$(_C)[$(PRINTER)-$(PRINTER)]"		"Same as $(_C)[$(PRINTER)]$(_D), but only lists the files $(_E)(no headers)"

########################################
### {{{3 $(HELPOUT)-EXAMPLES
########################################

.PHONY: $(HELPOUT)-EXAMPLES_%
$(HELPOUT)-EXAMPLES_%:
	@if [ "$(*)" != "0" ]; then $(call TITLE_LN,$(*),Command Examples); fi
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
	@$(PRINT) "$(CODEBLOCK)$(_C)\$$EDITOR$(_D) $(_M)$(COMPOSER_SETTINGS)"
#>	@$(PRINT) "$(CODEBLOCK)$(CODEBLOCK)$(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D): $(_E)override c_list := $(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)"
	@$(PRINT) "$(CODEBLOCK)$(CODEBLOCK)$(_N)override$(_D) $(_C)COMPOSER_TARGETS$(_D) := $(_N).$(TARGETS)$(_D) $(_E)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D)"
	@$(PRINT) "$(CODEBLOCK)$(CODEBLOCK)$(_N)override$(_D) $(_M)$(OUT_MANUAL).$(EXTN_DEFAULT)$(_D) := $(_E)$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(CLEANER)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)"
	@$(ENDOLINE)
	@$(PRINT) "Recursively install and build an entire directory tree"
	@$(PRINT) "$(_E)(see [Recommended Workflow])$(_D):"
	@$(ENDOLINE)
	@$(PRINT) "$(CODEBLOCK)$(_C)cd$(_D) $(_M)$(EXPAND)/documents"
	@$(PRINT) "$(CODEBLOCK)$(_C)mv$(_D) $(_M)$(EXPAND)/$(notdir $(COMPOSER_DIR)) .$(COMPOSER_BASENAME)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(INSTALL)-$(DOITALL)"
	@$(PRINT) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)-$(DOITALL)"
	@$(ENDOLINE)
	@$(PRINT) "See \`$(_C)$(HELPOUT)-$(DOITALL)$(_D)\` for full details and additional targets."

########################################
## {{{2 $(HELPOUT)-$(DOITALL)
########################################

.PHONY: $(HELPOUT)-$(HEADERS)-%
$(HELPOUT)-$(HEADERS)-%:
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TITLE)
	@$(call TITLE_LN,-1,$(COMPOSER_TECHNAME))
		@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-$(DOITALL)-HEADER
		@$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-FILES)
		@if [ "$(*)" = "$(HELPOUT)" ] || [ "$(*)" = "$(TYPE_PRES)" ]; then \
			$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS); \
		fi
		@if [ "$(*)" = "$(HELPOUT)" ]; then \
			$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS_EXT); \
		fi
	@$(call TITLE_LN,2,Overview)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-OVERVIEW)
		@$(call TITLE_END)
	@$(call TITLE_LN,2,Quick Start)		; $(PRINT) "Use \`$(_C)$(DOMAKE) $(HELPOUT)$(_D)\` to get started:"
		@$(ENDOLINE); $(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-USAGE
		@$(ENDOLINE); $(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-EXAMPLES_0
		@$(call TITLE_END)
	@$(call TITLE_LN,2,Principles)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-GOALS)
		@$(call TITLE_END)
	@$(call TITLE_LN,2,Requirements)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE)
		@$(ENDOLINE); $(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(CHECKIT)-$(HELPOUT) | $(SED) "/$(SED_ESCAPE_COLOR)[#]/d"
		@$(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-REQUIRE_POST)
		@$(call TITLE_END)
#>	@$(call TITLE_END)

.PHONY: $(HELPOUT)-%
$(HELPOUT)-%:
	@$(if $(and $(c_site),$(filter $(HELPOUT),$(*))),\
		$(eval export override COMPOSER_DOITALL_$(HELPOUT) := $(PUBLISH)) \
	)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-$(HEADERS)-$(*)
	@$(call TITLE_LN,1,$(COMPOSER_BASENAME) Operation,1)
	@$(call TITLE_LN,2,Recommended Workflow)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-WORKFLOW)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Document Formatting)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-FORMAT)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Configuration Settings)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-SETTINGS)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Precedence Rules)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-ORDERS)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Specifying Dependencies)	; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-DEPENDS)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Custom Targets)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-CUSTOM)	; $(call TITLE_END)
	@$(call TITLE_LN,2,Repository Versions)		; $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VERSIONS)	; $(call TITLE_END)
#>	@$(call TITLE_END)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-VARIABLES_TITLE_1
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-VARIABLES_FORMAT_2		; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT)	; $(call TITLE_END)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-VARIABLES_CONTROL_2		; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL)	; $(call TITLE_END)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-VARIABLES_HELPER_2		; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-VARIABLES_HELPER)	; $(call TITLE_END)
#>	@$(call TITLE_END)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-TARGETS_TITLE_1
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-TARGETS_PRIMARY_2		; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY)		; $(call TITLE_END)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-TARGETS_ADDITIONAL_2		; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL)	; $(call TITLE_END)
	@if [ "$(*)" = "$(HELPOUT)" ]; then \
		$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-TARGETS_INTERNAL_2	; $(ENDOLINE); $(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL)	; $(call TITLE_END); \
	fi
#>	@$(call TITLE_END)
	@if [ "$(*)" = "$(HELPOUT)" ]; then \
		$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-$(HELPOUT)-$(PRINTER); \
	fi
	@if [ "$(COMPOSER_DOITALL_$(HELPOUT))" != "$(PUBLISH)" ]; then \
		$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-FOOTER; \
	fi

########################################
### {{{3 $(HELPOUT)-$(PUBLISH)
########################################

.PHONY: $(HELPOUT)-$(PUBLISH)
$(HELPOUT)-$(PUBLISH):
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) \
		c_site="1" \
		$(HELPOUT)-$(HELPOUT)

########################################
### {{{3 $(HELPOUT)-$(TYPE_PRES)
########################################

.PHONY: $(HELPOUT)-$(TYPE_PRES)
$(HELPOUT)-$(TYPE_PRES):
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) \
		$(HELPOUT)-$(HEADERS)-$(TYPE_PRES) \
		| $(SED) "/^[-][-][-][-]/,+1d"
#>	@$(ENDOLINE)
#>	@$(LINERULE)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) \
		COMPOSER_DOITALL_$(HELPOUT)="$(TYPE_PRES)" \
		$(HELPOUT) \
		| $(SED) "/^[-][-][-][-]/,+1d"

########################################
### {{{3 $(HELPOUT)-$(HELPOUT)
########################################

.PHONY: $(HELPOUT)-$(HELPOUT)-$(PRINTER)
$(HELPOUT)-$(HELPOUT)-$(PRINTER):
	@$(call TITLE_LN,1,Reference)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(HELPOUT)) $(HELPOUT)-$(HELPOUT)-$(TARGETS)
	@$(call TITLE_LN,2,Configuration,1)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Pandoc Extensions)"
	@$(ENDOLINE); $(PRINT) "$(_C)[$(COMPOSER_BASENAME)]$(_D) uses the \`$(_C)$(INPUT)$(_D)\` input format, with these extensions:"
	@$(ENDOLINE); $(foreach FILE,$(sort $(subst +,,$(PANDOC_EXTENSIONS))),\
		$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
	)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Templates)"
	@$(ENDOLINE); $(ECHO) "The $(_C)[$(INSTALL)]$(_D) target \`$(_M)$(MAKEFILE)$(_D)\` template $(_E)(for reference only)$(_D):"
	@$(if $(COMPOSER_DOCOLOR),$(ENDOLINE); $(ENDOLINE))
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR)) .$(EXAMPLE)-$(INSTALL)	$(call $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE),$(COMPOSER_DOCOLOR))
	@$(ENDOLINE); $(ECHO) "Use the $(_C)[$(EXAMPLE)]$(_D) target to create \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` files:"
	@$(if $(COMPOSER_DOCOLOR),$(ENDOLINE); $(ENDOLINE))
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR)) .$(EXAMPLE)		$(call $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE),$(COMPOSER_DOCOLOR))
	@$(ENDOLINE); $(ECHO) "Use the $(_C)[$(EXAMPLE)-yml]$(_D) target to create \`$(_M)$(COMPOSER_YML)$(_D)\` files:"
	@$(if $(COMPOSER_DOCOLOR),$(ENDOLINE); $(ENDOLINE))
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR)) .$(EXAMPLE)-yml		$(call $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE),$(COMPOSER_DOCOLOR))
	@$(ENDOLINE); $(ECHO) "Use the $(_C)[$(EXAMPLE)-md]$(_D) target to create new \`$(_C)$(INPUT)$(_D)\` files:"
#>	@$(if $(COMPOSER_DOCOLOR),$(ENDOLINE); $(ENDOLINE))
	@$(ENDOLINE); $(ENDOLINE)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR)) .$(EXAMPLE)-md		$(call $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE),$(COMPOSER_DOCOLOR))
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Defaults)"
	@$(ENDOLINE); $(PRINT) "The default \`$(_M)$(COMPOSER_SETTINGS)$(_D)\` in the $(_C)[$(COMPOSER_BASENAME)]$(_D) directory:"
	@$(ENDOLINE); $(call DO_HEREDOC,HEREDOC_COMPOSER_MK)		$(call $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE))
	@$(ENDOLINE); $(PRINT) "The template \`$(_M)$(COMPOSER_YML)$(_D)\` in the \`$(_M)$(call COMPOSER_CONV,,$(COMPOSER_ART))$(_D)\` directory:"
	@$(ENDOLINE); $(call DO_HEREDOC,HEREDOC_COMPOSER_YML)		$(call $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE))
	@$(call TITLE_END)
	@$(call TITLE_LN,2,Reserved,1)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Target Names)"
	@$(ENDOLINE); $(PRINT) "Do not create targets which match these, or use them as prefixes:"
	@$(ENDOLINE); $(eval override LIST := $(COMPOSER_RESERVED)) \
		$(foreach FILE,$(sort $(LIST)),\
			$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE); $(PRINT) "$(call $(HELPOUT)-$(DOITALL)-SECTION,Variable Names)"
	@$(ENDOLINE); $(PRINT) "Do not create variables which match these, and avoid similar names:"
#> update: $(1).$(2)+$(3).$(4)
	@$(ENDOLINE); $(eval override LIST := $(shell \
			$(SED) -n \
				-e "s|^$(call COMPOSER_REGEX_OVERRIDE).*$$|\1|gp" \
				-e "s|^$(call COMPOSER_REGEX_OVERRIDE,,1).*$$|\1|gp" \
				-e "s|^$(call COMPOSER_REGEX_DEFINE).*$$|\2|gp" \
				$(COMPOSER) \
			| $(SED) "/[$$][(]1[)][.][$$][(]2[)][+][$$][(]3[)][.][$$][(]4[)]/d" \
		)) \
		$(foreach FILE,$(sort $(LIST)),\
			$(PRINT) "$(CODEBLOCK)$(_E)$(FILE)"; \
			$(call NEWLINE) \
		)
	@$(call TITLE_END)
#>	@$(call TITLE_END)

.PHONY: $(HELPOUT)-$(HELPOUT)-$(TARGETS)
$(HELPOUT)-$(HELPOUT)-$(TARGETS):
	@$(eval override LIST := $(shell $(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-TITLES) \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(FILE)))]: #$(shell \
				$(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$(FILE)) \
			)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval override LIST := $(shell $(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-SECTIONS) \
			| $(SED) "/[/]/d" \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(FILE)))]: #$(shell \
				$(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$(FILE)) \
			)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval override LIST := $(shell $(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-SECTIONS) \
			| $(SED) -n "/[/]/p" \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(FILE)))]: #$(shell \
				$(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$(FILE)) \
			)"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval override LIST := $(shell $(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-SECTIONS) \
			| $(SED) -n "/[/]/p" \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(foreach HEAD,$(subst /, ,$(FILE)),\
				$(PRINT) "$(_S)[$(strip $(subst $(TOKEN), ,$(HEAD)))]: #$(shell \
					$(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$(FILE)) \
				)"; \
				$(call NEWLINE) \
			) \
		)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(ENDOLINE)
	@$(eval override LIST := $(shell $(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-TITLES) \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_N)[$(strip $(subst $(TOKEN), ,$(FILE)))]"; \
			$(call NEWLINE) \
		)
	@$(ENDOLINE)
	@$(eval override LIST := $(shell $(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-SECTIONS) \
			| $(TR) '/' '|' \
		))$(foreach FILE,$(subst |, ,$(subst $(NULL) ,$(TOKEN),$(LIST))),\
			$(PRINT) "$(_N)[$(strip $(subst $(TOKEN), ,$(FILE)))]"; \
			$(call NEWLINE) \
		)
endif

override define $(HELPOUT)-$(HELPOUT)-$(TARGETS)-TITLES =
	$(SED) -n -e "s|^.+TITLE_LN[,][^,]+[,]([^,]+).*.$$|\1|gp" $(COMPOSER) \
	| $(SED) \
		-e "s|.;[[:space:]]+f$$||g" \
		-e "s|.[[:space:]]+$$||g" \
		-e "s|.[[:space:]]+;.+$$||g" \
		-e "/DIVIDE/d" \
		-e "s|$$|\||g"
endef

override define $(HELPOUT)-$(HELPOUT)-$(TARGETS)-SECTIONS =
	$(SED) -n "s|^.+[-]SECTION[,](.+)[)][\"]?$$|\1|gp" $(COMPOSER) \
	| $(SED) \
		-e "s|^[[:space:]]+||g" \
		-e "s|[[:space:]]+$$||g" \
		-e "s|\\\\||g" \
		-e "s|$$|\||g"
endef

#> update: $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT
override define $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT =
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

override define $(HELPOUT)-$(HELPOUT)-$(PRINTER)-$(EXAMPLE) =
	$(if $(1),,| $(SED) \
		-e "/^[#]{$(DEPTH_MAX)}.+[[:space:]]/d" \
		-e "s|[\t]+| |g" \
		-e "s|^|$(CODEBLOCK)|g" \
		-e "s|^[[:space:]]+$$||g" \
		-e "s|[[:space:]]+$$||g" \
	)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TITLE
########################################

#> update: COMPOSER_TARGETS.*=

override define $(HELPOUT)-$(DOITALL)-TITLE =
$(_M)---$(_D)
$(_M)title: "$(COMPOSER_HEADLINE)"$(_D)
$(_M)date: $(COMPOSER_VERSION) ($(DATEMARK))$(_D)
$(_M)$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)$(_D)
$(_M)---$(_D)
endef

.PHONY: $(HELPOUT)-$(DOITALL)-HEADER
$(HELPOUT)-$(DOITALL)-HEADER:
	@$(TABLE_M2) "$(_H)![$(COMPOSER_BASENAME) Icon]"	"$(_H)\"Creating Made Simple.\""
	@$(TABLE_M2) ":---"					":---"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_FULLNAME)]"		"$(_C)[License: GPL]"
	@$(TABLE_M2) "$(_C)[$(COMPOSER_COMPOSER)]"		"$(_C)[composer@garybgenett.net]"

override define $(HELPOUT)-$(DOITALL)-FILES =
$(_S)-- $(_N)Formats:$(_D)
              $(_S)[$(_N)webpage$(_S)]($(_N)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_S))$(_D)
$(_S)/$(_D)                $(_S)[$(_N)$(EXTN_HTML)$(_S)]($(_N)$(OUT_README).$(EXTN_HTML)$(_S))$(_D)
$(_S)/$(_D)                 $(_S)[$(_N)$(EXTN_LPDF)$(_S)]($(_N)$(OUT_README).$(EXTN_LPDF)$(_S))$(_D)
$(_S)/$(_D)                $(_S)[$(_N)$(EXTN_EPUB)$(_S)]($(_N)$(OUT_README).$(EXTN_EPUB)$(_S))$(_D)
$(_S)/$(_D)       $(_S)[$(_N)$(EXTN_PRES)$(_S)]($(_N)$(OUT_README).$(EXTN_PRES)$(_S))$(_D)
$(_S)/$(_D)                $(_S)[$(_N)$(EXTN_DOCX)$(_S)]($(_N)$(OUT_README).$(EXTN_DOCX)$(_S))$(_D)
endef

override define $(HELPOUT)-$(DOITALL)-LINKS =
$(_E)[$(COMPOSER_BASENAME)]: $(COMPOSER_HOMEPAGE)$(_D)
$(_E)[$(COMPOSER_FULLNAME)]: $(COMPOSER_REPOPAGE)/tree/$(COMPOSER_VERSION)$(_D)
$(_E)[License: GPL]: $(COMPOSER_REPOPAGE)/blob/main/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)
$(_E)[$(COMPOSER_COMPOSER)]: http://www.garybgenett.net/projects/composer$(_D)
$(_E)[composer@garybgenett.net]: mailto:composer@garybgenett.net?subject=$(subst $(NULL) ,%20,$(COMPOSER_TECHNAME))%20Submission&body=Thank%20you%20for%20sending%20a%20message%21$(_D)

$(_S)[$(COMPOSER_BASENAME) Icon]: $(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/icon-v1.0.png$(_D)
$(_S)[$(COMPOSER_BASENAME) Screenshot]: $(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/screenshot-v4.0.png$(_D)

$(_S)[$(DESC_HTML)]: #html$(_D)
$(_S)[$(DESC_LPDF)]: #pdf$(_D)
$(_S)[$(DESC_EPUB)]: #epub$(_D)
$(_S)[$(DESC_PRES)]: #revealjs-presentations$(_D)
$(_S)[$(DESC_DOCX)]: #microsoft-word--powerpoint$(_D)
$(_S)[$(DESC_PPTX)]: #microsoft-word--powerpoint$(_D)
$(_S)[$(DESC_TEXT)]: #plain-text$(_D)
$(_S)[$(DESC_LINT)]: #pandoc-markdown$(_D)
endef

override define $(HELPOUT)-$(DOITALL)-LINKS_EXT =
$(_S)<!-- #$(MARKER)$(_D) $(_S)[Markdown]: http://daringfireball.net/projects/markdown$(_D) $(_S)-->$(_D)
$(_S)<!-- #$(MARKER)$(_D) $(_S)[Markdown]: https://commonmark.org$(_D) $(_S)-->$(_D)
$(_E)[Markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown$(_D)
$(_E)[GitHub]: https://github.com$(_D)

$(_E)[GNU Bash]: http://www.gnu.org/software/bash$(_D)
$(_E)[GNU Coreutils]: http://www.gnu.org/software/coreutils$(_D)
$(_E)[GNU Findutils]: http://www.gnu.org/software/findutils$(_D)
$(_E)[GNU Sed]: http://www.gnu.org/software/sed$(_D)
$(_E)[GNU Make]: http://www.gnu.org/software/make$(_D)
$(foreach FILE,$(REPOSITORIES_LIST),\
$(call NEWLINE)$(_E)[$($(FILE)_NAME)]: $($(FILE)_HOME)$(_D) \
)

$(_E)[$(PDF_LATEX_NAME)]: $(PDF_LATEX_HOME)$(_D)

$(_S)[Git]: https://git-scm.com$(_D)
$(_S)[Git SCM]: https://git-scm.com$(_D)
$(_S)[GNU Diffutils]: http://www.gnu.org/software/diffutils$(_D)
$(_S)[Rsync]: https://rsync.samba.org$(_D)
$(_S)[NPM]: https://www.npmjs.com$(_D)

$(_S)[GNU]: http://www.gnu.org$(_D)
$(_S)[GNU/Linux]: https://gnu.org/gnu/linux-and-gnu.html$(_D)
$(_S)[Windows Subsystem for Linux]: https://docs.microsoft.com/en-us/windows/wsl$(_D)
$(_S)[MacPorts]: https://www.macports.org$(_D)
endef

override define $(HELPOUT)-$(DOITALL)-SECTION =
$(_S)###$(_D) $(_H)$(patsubst _%,\_%,$(1))$(_D) $(_S)###$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-OVERVIEW
########################################

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
published as $(_C)[Static Websites]$(_D).

$(_N)![$(COMPOSER_BASENAME) Screenshot]($(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/screenshot-v4.0.png)$(_S)\\$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-GOALS
########################################

override define $(HELPOUT)-$(DOITALL)-GOALS =
The guiding principles of $(_C)[$(COMPOSER_BASENAME)]$(_D):

  * All source files in readable plain text
  * Professional output, suitable for publication
  * Minimal dependencies, and entirely command-line driven
  * Separate content and formatting; writing and publishing are independent
  * Inheritance and dependencies; global, tree, directory and file overrides
  * Fast; both to initiate commands and for processing to complete

Direct support for key document types $(_E)(see [Document Formatting])$(_D):

  * $(_C)[Static Websites]$(_D)
  * $(_C)[HTML]$(_D)
  * $(_C)[PDF]$(_D)
  * $(_C)[EPUB]$(_D)
  * $(_C)[Reveal.js Presentations]$(_D)
  * $(_C)[Microsoft Word & PowerPoint]$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-REQUIRE
########################################

override define $(HELPOUT)-$(DOITALL)-REQUIRE =
$(_C)[$(COMPOSER_BASENAME)]$(_D) has almost no external dependencies.  All needed components are
integrated directly into the repository, including $(_C)[Pandoc]$(_D).  $(_C)[$(COMPOSER_BASENAME)]$(_D) does
require a minimal command-line environment based on $(_N)[GNU]$(_D) tools, particularly
$(_C)[GNU Make]$(_D), which is standard for all $(_N)[GNU/Linux]$(_D) systems.  The $(_N)[Windows
Subsystem for Linux]$(_D) for Windows and $(_N)[MacPorts]$(_D) for macOS both provide suitable
environments.

The one large external requirement is $(_C)[$(PDF_LATEX_NAME)]$(_D), and it can be installed using
the package managers of each of the above systems.  It is only necessary for
creating $(_C)[PDF]$(_D) files.

Below are the versions of the components in the repository, and the tested
versions of external tools for this iteration of $(_C)[$(COMPOSER_BASENAME)]$(_D).  Use $(_C)[$(CHECKIT)]$(_D) to
validate your system.
endef

override define $(HELPOUT)-$(DOITALL)-REQUIRE_POST =
$(_C)[Markdown Viewer]$(_D) is included both for its $(_M)CSS$(_D) stylesheets, and for real-time
rendering of $(_C)[Markdown]$(_D) files as they are being written.  To install, follow the
instructions in the `$(_M)README.md$(_D)`.

$(_C)[Google Firebase]$(_D) is only necessary for uploading via the $(_C)[$(EXPORTS)-$(DOITALL)]$(_D) and
$(_C)[$(EXPORTS)-$(DOFORCE)]$(_D) targets.  Binaries are included in the repository, but do not
seem to work with all versions of their respective operating systems.  If the
included binary fails, use $(_M)`$(UPGRADE)-$(notdir $(FIREBASE_DIR))`$(_D) to build a local version
$(_E)(see [_update-*])$(_D).

The versions of the integrated repositories can be changed, if desired $(_E)(see
[Repository Versions])$(_D).
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-WORKFLOW
########################################

override define $(HELPOUT)-$(DOITALL)-WORKFLOW =
$(call $(HELPOUT)-$(DOITALL)-SECTION,Directory Tree)

The ideal workflow is to put $(_C)[$(COMPOSER_BASENAME)]$(_D) in a top-level `$(_M).$(COMPOSER_BASENAME)$(_D)` for each
directory tree you want to manage, creating a structure similar to this:

$(CODEBLOCK)$(EXPAND)/$(_M).$(COMPOSER_BASENAME)$(_D)
$(CODEBLOCK)$(EXPAND)/
$(CODEBLOCK)$(EXPAND)/tld/
$(CODEBLOCK)$(EXPAND)/tld/sub/

To save on disk space, using a central $(_C)[$(COMPOSER_BASENAME)]$(_D) install for multiple directory
trees, the $(_C)[$(DOSETUP)]$(_D) target can be used to create a linked `$(_M).$(COMPOSER_BASENAME)$(_D)` directory:

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f $(EXPAND)/$(MAKEFILE)$(_D) $(_M)$(DOSETUP)$(_D)

The directory tree can then be converted to a $(_C)[$(COMPOSER_BASENAME)]$(_D) documentation archive
$(_E)([Quick Start] example)$(_D):

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f .$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(INSTALL)-$(DOITALL)$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)-$(DOITALL)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,Customization)

If specific settings need to be used, either globally or per-directory,
`$(_M)$(COMPOSER_SETTINGS)$(_D)` and `$(_M)$(COMPOSER_YML)$(_D)` files can be created $(_E)(see [Configuration
Settings], [Quick Start] example)$(_D):

$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)$(_D)"	"$(_E)&&$(_D) $(_C)\$$EDITOR$(_D) $(_M)$(COMPOSER_SETTINGS)$(_D)")
$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)-yml$(_D) >$(_M)$(COMPOSER_YML)$(_D)"	"$(_E)&&$(_D) $(_C)\$$EDITOR$(_D) $(_M)$(COMPOSER_YML)$(_D)")

Custom targets can also be defined, using standard $(_C)[GNU Make]$(_D) syntax $(_E)(see
[Custom Targets])$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,Important Notes)

$(_C)[GNU Make]$(_D) does not support file and directory names with spaces in them, and
neither does $(_C)[$(COMPOSER_BASENAME)]$(_D).  Documentation archives which have such files or
directories will produce unexpected results.

It is fully supported for input files to be symbolic links to files that reside
outside the documentation archive:

$(CODEBLOCK)$(_C)cd$(_D) $(_M)$(EXPAND)/tld$(_D)
$(CODEBLOCK)$(_C)ln$(_D) $(_N)-rs $(EXPAND)/$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D) $(_M)./$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(OUT_README).$(EXTN_DEFAULT)$(_D)

Similarly to source code, $(_C)[GNU Make]$(_D) is meant to only run one instance within
the directory at a time, and $(_C)[$(COMPOSER_BASENAME)]$(_D) shares this requirement.  It should be
run as a single user, to avoid duplication and conflicts.  Concurrent runs will
produce unexpected results.  It is highly recommended to set $(_C)[MAKEJOBS]$(_D) to a
value greater than the default, to speed up processing.

It is best practice to $(_C)[$(INSTALL)-$(DOFORCE)]$(_D) after every $(_C)[$(COMPOSER_BASENAME)]$(_D) upgrade, in case
there are any changes to the `$(_M)$(MAKEFILE)$(_D)` template $(_E)(see [Templates])$(_D).  Everything
in $(_C)[$(COMPOSER_BASENAME)]$(_D) sources from the main `$(_M)$(MAKEFILE)$(_D)`, so that is the only file which
requires review to see what changes have been made between versions.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Next Steps)

The archive is ready, and each directory is both a part of the collective and
its own individual instance.  Targets can be run per-file, per-directory, or
recursively through an entire directory tree.  The most commonly used targets
are in $(_C)[Primary Targets]$(_D).

$(_H)**Welcome to [$(COMPOSER_BASENAME)].  $(COMPOSER_TAGLINE)**$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-FORMAT
########################################

#WORKING:NOW:NOW
#	make it so that an empty digest_title/sitemap_title disables/removes them...
#	items like README.site.html aren't getting metadata, because sitemap is only looking for *.md...
#		maybe we can somehow check for $(word 1,$(README.site.html)) variable and use that...?
#		naw, just document... example of proper use is: _site/config/pages*
#WORKING:NOW:NOW
#	add "demo" target
#		slowly, sleep 0.1 per character, print a series of commands and then run them
#		add to help and/or quick start
#		comment/remove cruft from setup-all, such as clean and keeping=0
#		make demo = peek = replace screenshot with a gif
#	also update revealjs documentation, based on css behavior change
#		need to update tests...?  yes!
#	note that they are intentionally reversed
#		bootstrap is just supporting where the markdown-viewer themes fall through
#		revealjs is usually using a theme, which we are refining
#	these can now be removed to be disabled
#	favicon.ico = idendical to $(_C)[Reveal.js Presentations]$(_D)
#		works on all html, including revealjs
#	order of nav presentation in plain-text: top, left, middle, right, bottom
#	breakpoints = https://getbootstrap.com/docs/5.2/layout/grid/#grid-options
#	the *-info-* fields will accept any markdown, html, or bootstrap
#		it is a simple span within the navbar, so flex and others will work
#		https://getbootstrap.com/docs/5.2/components/navbar
#		https://getbootstrap.com/docs/5.2/utilities/flex
#	any simple css should do...
#		https://getbootstrap.com/docs/5.2/utilities/colors
#	$(PUBLISH_CMD_BEG) fold-begin . $(SPECIAL_VAL) $(SPECIAL_VAL) $(COMPOSER_TECHNAME) $(PUBLISH_CMD_END)
#		(the . as a blank placeholder)
#	$(DO_PAGE)-% must end in $(EXTN_HTML)...
#		$(PUBLISH) requires $(EXTN_HTML) to work... hard-change it if required...
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
#	c_site = metainfo = title-prefix/pagetitle behavior
#		regardless of include, main file, etc...
#	any date format that yq can understand [link] can be used, but be consisitent...
#	$(PUBLISH)-spacer[spacer] / box-begin / box-end
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
#	need to document "header 0" for fold-begin and box-begin
#		need to document "contents 0"
#			first instance of "contents.*" wins...
#			same with readtime, although it doesn't matter...
#		also, "header x" at any old time...
#	document readtime = <word> / <time>
#	document "make config" in "library", to show files with missing headers
#	document .$(TARGETS) special value
#		all four of: TARGETS, SUBDIRS, EXPORTS, IGNORES
#		wildcards work, as "*", but only once is allowed
#	document template.*/reference.* and $(COMPOSER_CUSTOM)-header.*/$(COMPOSER_CUSTOM)-css.* files
#	maybe a note that all files also "depend" on Makefile, so they will all update along with it?
#	includes tree is based off of makefile list, so need to $(INSTALL) in order to get $(COMPOSER_SETTINGS/YML)
#		that said, -f now works for single files with no configuration file reading...
#	document composer_dir/composer_root ... in composer.mk section?
#	make targets = Argument list too long ... how many is too many, and does it matter ...?  seems to be around ~400-55, depending...
#	COMPOSER_IGNORES now works for the "library", also...
#		in terms of the library, however, it does not pay attention to COMPOSER_INCLUDES, and only local COMPOSER_SETTINGS files trigger it...
#			is this difference in behavior acceptable...?
#			it would be extremely expensive to make it otherwise...
#		and then there is COMPOSER_EXPORTS...
#	file targets can not depend on non-file targets...?
#		MANUAL.pdf: pre-process README.md LICENSE.md
#	infinite "include" loops are not detected...
#	index.html: $(CURDIR)/history/index-include.md.cms
#		add to to documentation
#		must use the full path name for the library include...
#	CURDIR and files must match, or settings and includes will break...
#	the library can be used purely as a documentation archive manager, if desired... (i.e. metadata, sitemap, etc.)
#		test this... it may require c_site more than we think...
#	every output file needs to have a *.md with the metadata in it in order for the library to work...
#	library does great with additions and updates, but removals require site-clean or hand-editing of metadata/index...
#	$(TESTING)-speed -> $(TESTING)-stress
#		add $(CLEANER)/$(DOITALL) for a vary large directory of files
#	document c_list_var
#	site-include files will not be parsed into digests, to avoid mangled output...
#	leading numeric [0-9] in $(PUBLISH)-display name in yml file causes them to break...?
#		only for "banner"...?
#	based on the "for" loop in the code, header/footer could be a list of files...
#		see: define $(PUBLISH)-$(TARGETS)-file
#		document this...?
#		test as an array...? could just do a "metalist" on it, to be sure...
#		duplicate all of this for append...
#	document "config.composer" option
#	document "$(c_base).$(extension)" and "$(c_base).*" variables...
#	document "$(c_base).$(EXTN_OUTPUT).header" and "$(c_base).$(EXTN_OUTPUT).css" special files, and add to testing
#	firebase is not included in the repository...?  need to note this...
#	try to remove "manual review of output throughout $(TESTING)...
#	add $(TESTING)-$(DOSETUP)
#		integrate with $(TESTING)-$(DISTRIB), so they clean up after each other...
#		add to documentation, along with $(TESTING)-speed...
#	note: never run in the "/" directory
#	document test case of proper PUBLISH_PAGE_TESTING sorting in $(CONFIGS) library

#WORKING:NOW
#	features
#		100% configurable using simple plain-text files
#		extremely flexible, complete control over page layout and elements
#		supports dependencies
#		fast; multi-threaded
#	random note/thought
#		composer makes it very easy to create rich interfaces for delivering content efficiently
#		the trade-off is that the computational horsepower is spent as capital rather than operational cost
#		best practice is to have an overnight $(PUBLISH)-$(DOFORCE) process...

#WORKING:NOW
#	add a list of the formats here...
#	make sure all the level2 sections have links to the sub-sections...

#WORK
# styles.html = https://github.com/jgm/pandoc/blob/main/data/templates/styles.html = $(COMPOSER_DAT)
# epub.css = https://github.com/jgm/pandoc/blob/master/data/epub.css = $(COMPOSER_DAT)
# header-includes

#> update: COMPOSER_TARGETS.*=

#>$(_N)-- Example: [$(OUT_README).$(EXTN_PPTX)]($(OUT_README).$(EXTN_PPTX))$(_D)
#>$(_N)-- Example: [$(OUT_README).$(EXTN_TEXT)]($(OUT_README).$(EXTN_TEXT))$(_D)
#>$(_N)-- Example: [$(OUT_README).$(EXTN_LINT)]($(OUT_README).$(EXTN_LINT))$(_D)

override define $(HELPOUT)-$(DOITALL)-FORMAT =
$(_F)
#WORKING:NOW:NOW:DOCS:FIX#######################################################
$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_DAT))/template.$(_N)*$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_DAT))/reference.$(_N)*$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_CUSTOM))-$(PUBLISH).css$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_CUSTOM))-$(TYPE_HTML).css$(_D)
$(_F)
#WORKING:NOW:NOW:DOCS:FIX#######################################################
$(_D)
As outlined in $(_C)[Overview]$(_D) and $(_C)[Principles]$(_D), a primary goal of $(_C)[$(COMPOSER_BASENAME)]$(_D) is to
produce beautiful and professional output.  $(_C)[Pandoc]$(_D) does reasonably well at
this, and yet its primary focus is document conversion, not document formatting.
$(_C)[$(COMPOSER_BASENAME)]$(_D) fills this gap by specifically tuning a select list of the most
commonly used document formats.

The input $(_C)[Markdown]$(_D) format used by $(_C)[$(COMPOSER_BASENAME)]$(_D) is the $(_C)[Pandoc]$(_D) default.
However, the $(_C)[Pandoc Extensions]$(_D) list has been modified slightly.  See that
section and the $(_C)[Pandoc]$(_D) $(_C)[Markdown]$(_D) documentation for the exact list and details
for each.

Further options for each document type are in $(_C)[Formatting Variables]$(_D).  All
improvements not exposed as variables will apply to all documents created with a
given instance of $(_C)[$(COMPOSER_BASENAME)]$(_D).

Note that all the files referenced below are embedded in the '$(_E)Embedded Files$(_D)'
section of the `$(_M)$(MAKEFILE)$(_D)`.  They are exported by the $(_C)[$(DISTRIB)]$(_D) target $(_E)(using
[$(CREATOR)])$(_D), and will be overwritten whenever it is run.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Static Websites)

$(_C)[Bootstrap]$(_D) is a leading web development framework, capable of building static
webpages that behave dynamically.  Static sites are very easy and inexpensive to
host, and are extremely responsive compared to truly dynamic webpages.

$(_C)[$(COMPOSER_BASENAME)]$(_D) uses this framework to transform an archive of simple text files into
a modern website, with the appearance and behavior of dynamically indexed pages.

$(_F)
#WORKING:NOW:NOW:FIX############################################################
$(_D)

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(BOOTSTRAP_ART_JS))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(BOOTSTRAP_ART_CSS))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(CUSTOM_PUBLISH_CSS))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(call CUSTOM_PUBLISH_CSS_OVERLAY,light))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(call CUSTOM_PUBLISH_CSS_OVERLAY,dark))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_LOGO))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_ICON))$(_D)

$(_C)[Bootlint]$(_D)
$(_C)[Bootswatch]$(_D)

$(_F)
#WORKING:NOW:NOW:FIX############################################################
$(_D)

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(BOOTSWATCH_DIR))/docs/index.html$(_D)

$(_F)
#WORKING:NOW:NOW:FIX############################################################
$(_D)

$(_N)-- Examples:
[Example Website]($(notdir $(PUBLISH_ROOT))/$(word 1,$(PUBLISH_FILES)))
/ [$(OUT_README).$(PUBLISH).$(EXTN_HTML)]($(OUT_README).$(PUBLISH).$(EXTN_HTML))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,HTML)

In addition to being a helpful real-time rendering tool, $(_C)[Markdown Viewer]$(_D)
includes several $(_M)CSS$(_D) stylesheets that are much more visually appealing than the
$(_C)[Pandoc]$(_D) default, and which behave like normal webpages, so $(_C)[$(COMPOSER_BASENAME)]$(_D) uses them
for all $(_C)[HTML]$(_D)-based document types, including $(_C)[EPUB]$(_D).

Information on installing $(_C)[Markdown Viewer]$(_D) for use as a $(_C)[Markdown]$(_D) rendering
tool is in $(_C)[Requirements]$(_D).

$(_N)-- Example: [$(OUT_README).$(EXTN_HTML)]($(OUT_README).$(EXTN_HTML))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,PDF)

The default formatting for $(_C)[PDF]$(_D) is geared towards academic papers and the
typesetting of printed books, instead of documents that are intended to be
purely digital.

Internally, $(_C)[Pandoc]$(_D) first converts to $(_M)LaTeX$(_D), and then uses $(_C)[$(PDF_LATEX_NAME)]$(_D) to
convert into the final $(_C)[PDF]$(_D).  $(_C)[$(COMPOSER_BASENAME)]$(_D) inserts customized $(_M)LaTeX$(_D) to modify the
final output:

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_CUSTOM))-$(TYPE_LPDF).header$(_D)
#WORK $(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(CUSTOM_PDF_LATEX))$(_D)

$(_N)-- Example: [$(OUT_README).$(EXTN_LPDF)]($(OUT_README).$(EXTN_LPDF))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,EPUB)

The $(_C)[EPUB]$(_D) format is essentially packaged $(_C)[HTML]$(_D), so $(_C)[$(COMPOSER_BASENAME)]$(_D) uses the same
$(_C)[Markdown Viewer]$(_D) $(_M)CSS$(_D) stylesheets for it.

$(_N)-- Example: [$(OUT_README).$(EXTN_EPUB)]($(OUT_README).$(EXTN_EPUB))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,Reveal.js Presentations)

The $(_M)CSS$(_D) for $(_C)[Reveal.js]$(_D) presentations has been modified to create a more
traditional and readable end result.  The customized version is at:

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_CUSTOM))-$(TYPE_PRES).css$(_D)
#WORK $(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(CUSTOM_REVEALJS_CSS))$(_D)

$(_F)
#WORKING:NOW:NOW:FIX############################################################
#	rework this
$(_D)

It links in a default theme from the `$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(REVEALJS_DIR))/dist/theme$(_D)` directory.  Edit
the location in the file, or use $(_C)[c_css]$(_D) to select a different theme.

It is set up so that a logo can be placed in the upper right hand corner on each
slide, for presentations that need to be branded.  Simply copy an image file to
the logo location:

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_LOGO))$(_D)

To have different logos for different directories $(_E)(using [Recommended Workflow],
[Configuration Settings] and [Precedence Rules])$(_D):

#WORK no longer the best way to do this...
$(CODEBLOCK)$(_C)cd$(_D) $(_M)$(EXPAND)/presentations$(_D)
$(CODEBLOCK)$(_C)cp$(_D) $(_N)$(EXPAND)/$(notdir $(COMPOSER_LOGO))$(_D) $(_M)./$(_D)
$(CODEBLOCK)$(_C)ln$(_D) $(_N)-rs $(EXPAND)/.$(COMPOSER_BASENAME)/$(call COMPOSER_CONV,,$(CUSTOM_REVEALJS_CSS))$(_D) $(_M)./.$(notdir $(COMPOSER_CUSTOM))-$(TYPE_PRES).css$(_D)
$(CODEBLOCK)$(_C)echo$(_D) $(_N)'$(_E)override c_type := $(TYPE_PRES)'$(_D) >>$(_M)./$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(DOITALL)$(_D)

$(_N)-- Example: [$(OUT_README).$(EXTN_PRES)]($(OUT_README).$(EXTN_PRES))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,Microsoft Word & PowerPoint)

The internal $(_C)[Pandoc]$(_D) templates for these are exported by $(_C)[$(COMPOSER_BASENAME)]$(_D), so they
are available for customization:

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_DAT))/reference.$(EXTN_DOCX)$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_DAT))/reference.$(EXTN_PPTX)$(_D)

They are not currently modified by $(_C)[$(COMPOSER_BASENAME)]$(_D).

$(_N)-- Example: [$(OUT_README).$(EXTN_DOCX)]($(OUT_README).$(EXTN_DOCX))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,Plain Text)

This output format is still parseable by $(_C)[Pandoc]$(_D) as valid $(_C)[Markdown]$(_D), but is
formatted to read as pure plain text that is only `$(_M)$(COLUMNS)$(_D)` columns wide.  There are
cases where this conversion is desireable, such as technical documentation,
where it is easier to write and format as $(_C)[Pandoc]$(_D) $(_C)[Markdown]$(_D) but the output
needs to be in a universally accepted text layout and presentation.

$(_C)[$(COMPOSER_BASENAME)]$(_D) currently does not modify this format, other than using the
`$(_M)--columns=$(COLUMNS)$(_D)` and `$(_M)--wrap=auto$(_D)` options to $(_C)[Pandoc]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,Pandoc Markdown)

Output $(_C)[Markdown]$(_D) that is specific to $(_C)[Pandoc]$(_D).  This is for linting or creating
standardized versions of source files for shared archives.

Due to the expressed purposes of this format, $(_C)[$(COMPOSER_BASENAME)]$(_D) will never modify it.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-SETTINGS
########################################

#WORKING
#	change in behavior... particularly yml files...
#		$(c_base).$(EXTN_OUTPUT): $(COMPOSER) $(COMPOSER_YML_LIST) $($(PUBLISH)-cache) $($(PUBLISH)-library)
#		$(COMPOSER) upgrade = use $(PRINTER) to check files to update...
#	create "upgrades/updates" section...
#		duplicate or reference this

override define $(HELPOUT)-$(DOITALL)-SETTINGS =
$(_F)
#WORKING:NOW:NOW:FIX############################################################
$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,GNU Make ($(COMPOSER_SETTINGS)))

$(call $(HELPOUT)-$(DOITALL)-SECTION,Pandoc & Bootstrap ($(COMPOSER_YML)))

$(_C)[$(COMPOSER_BASENAME)]$(_D) uses `$(_M)$(COMPOSER_SETTINGS)$(_D)` files for persistent settings and definition of
$(_C)[Custom Targets]$(_D).  By default, they only apply to the directory they are in $(_E)(see
[COMPOSER_INCLUDE] in [Control Variables])$(_D).  A `$(_M)$(COMPOSER_SETTINGS)$(_D)` in the main
$(_C)[$(COMPOSER_BASENAME)]$(_D) directory will be global to all directories.  The targets and
settings in the most local file override all others $(_E)(see [Precedence Rules])$(_D).

The easiest way to create new `$(_M)$(COMPOSER_SETTINGS)$(_D)` and `$(_M)$(COMPOSER_YML)$(_D)` files is with
the $(_C)[$(EXAMPLE)]$(_D) and $(_C)[$(EXAMPLE)-yml]$(_D) targets $(_E)([Quick Start] example)$(_D):

$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)$(_D) >$(_M)$(COMPOSER_SETTINGS)$(_D)"	"$(_E)&&$(_D) $(_C)\$$EDITOR$(_D) $(_M)$(COMPOSER_SETTINGS)$(_D)")
$(shell $(COLUMN_2) "$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(EXAMPLE)-yml$(_D) >$(_M)$(COMPOSER_YML)$(_D)"	"$(_E)&&$(_D) $(_C)\$$EDITOR$(_D) $(_M)$(COMPOSER_YML)$(_D)")

All variable definitions must be in the `$(_N)override [variable] := [value]$(_D)` format
from the $(_C)[$(EXAMPLE)]$(_D) target.  Doing otherwise will result in unexpected behavior,
and is not supported.  The regular expression that is used to detect them:

$(CODEBLOCK)$(_N)$(call COMPOSER_REGEX_OVERRIDE)$(_D)

Variables can also be specified per-target, using $(_C)[GNU Make]$(_D) syntax:

$(CODEBLOCK)$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_toc := $(SPECIAL_VAL)$(_D)
$(CODEBLOCK)$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_toc :=$(_D)

In this case, there are multiple definitions that could apply to
`$(_M)$(OUT_README).$(EXTN_PRES)$(_D)`, due to the `$(_N)%$(_D)` wildcard.  Since the most specific target
match is used, the final value for $(_C)[c_toc]$(_D) would be empty.

Example configuration files:

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_DIR)/$(COMPOSER_SETTINGS))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_ART)/$(COMPOSER_YML))$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_ART)/$(OUT_README).$(PUBLISH).yml)$(_D)
$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_DIR)/$(OUT_README).$(PUBLISH).$(EXTN_HTML).yml)$(_D)
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-ORDERS
########################################

#WORK the file beats the directory, which beats the tree
#WORK the file beats the command line, which beats the environment
#WORKING
#	note about global/local variables, and config/$(MARKER)
#		add a link to this section at the top of both variable sections
#		denote each variable
#	$(COMPOSER_YML) and note that it is now an override for everything
#		except, a $(COMPOSER_SETTINGS) c_options --defaults...
#		hashes will overlap, and arrays will append
#	since $(COMPOSER_SETTINGS) is neither c_type or c_base specific, there is only a per-directory version
#		since $(COMPOSER_YML) is not c_type specific, there is only per-directory and c_base versions
#		all others (header, css, etc.) are directory, c_type and c_base applicable, so all three...

override define $(HELPOUT)-$(DOITALL)-ORDERS =
All processing in $(_C)[$(COMPOSER_BASENAME)]$(_D) is done in global-to-local order, so that the most
local file or value always takes precedence.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Configuration Files)

Both `$(_M)$(COMPOSER_SETTINGS)$(_D)` and `$(_M)$(COMPOSER_YML)$(_D)` files follow the model illustrated in
$(_C)[COMPOSER_INCLUDE]$(_D) under $(_C)[Control Variables]$(_D).  This means that the values in the
most local file override all others.

$(_F)
#WORKING:NOW:NOW:FIX############################################################
$(_D)

All values in `$(_M)$(COMPOSER_SETTINGS)$(_D)` take precedence over everything else, including
environment variables.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Header & CSS Files)

#WORK the same for all...

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_CUSTOM))-$(TYPE_LPDF).header$(_D)
$(CODEBLOCK)$(EXPAND)/$(_M).$(notdir $(COMPOSER_CUSTOM))-$(TYPE_LPDF).header$(_D)
$(CODEBLOCK)./$(_M)$(OUT_README).$(EXTN_LPDF).header$(_D)

#WORK the same for all...

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_CUSTOM))-$(TYPE_DEFAULT).css$(_D)
$(CODEBLOCK)$(EXPAND)/$(_M).$(notdir $(COMPOSER_CUSTOM))-$(TYPE_DEFAULT).css$(_D)
$(CODEBLOCK)./$(_M)$(OUT_README).$(EXTN_DEFAULT).css$(_D)

#WORK the $(_C)[c_css]$(_D) layering...

  1. $(_C)[c_site]$(_D) $(_E)$(MARKER)$(_D) $(_C)[Bootstrap]$(_D)
  1. $(_C)[c_css]$(_D)
#WORK comment 1. $(call COMPOSER_CONV,$(_H)[COMPOSER_DIR]$(_D)/$(_M),$(COMPOSER_CUSTOM))$(_D)-$(_C)[c_type]$(_D).css
  1. $(patsubst $(COMPOSER_ART)/%,$(_H)[COMPOSER_ART]$(_D)/$(_M)%,$(COMPOSER_CUSTOM))$(_D)-$(_C)[c_type]$(_D).css
  1. $(_C)[COMPOSER_INCLUDE]$(_D) $(_E)$(MARKER)$(_D) $(_D)$(EXPAND)/$(_M).$(notdir $(COMPOSER_CUSTOM))$(_D)-$(_C)[c_type]$(_D).css
  1. $(_H)[CURDIR]$(_D)/$(_C)[c_base]$(_D).`$(_M)<extension>$(_D)`.css
  1. $(_C)[c_site]$(_D) $(_E)$(MARKER)$(_D) `$(_M)$(COMPOSER_YML)$(_D)` $(_E)$(DIVIDE)$(_D) $(_C)[$(PUBLISH)-config]$(_D).$(_C)[css_overlay]$(_D)

The first four are core to $(_C)[$(COMPOSER_BASENAME)]$(_D), and are always included.
$(_C)[COMPOSER_INCLUDE]$(_D) and $(_H)[CURDIR]$(_D) files are optional, and only used if they exist.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Variables & Aliases)

Variable aliases, such as `$(_C)COMPOSER_DEBUGIT$(_D)`/`$(_E)c_debug$(_D)`/`$(_E)V$(_D)` are prioritized in
the order shown, with `$(_C)COMPOSER_*$(_D)` taking precedence over `$(_E)c_*$(_D)`, over the short
alias.

Full `$(_C)COMPOSER_*$(_D)` variable names should always be used in `$(_M)$(COMPOSER_SETTINGS)$(_D)` files,
to avoid being overwritten by recursive environment persistence.

$(call $(HELPOUT)-$(DOITALL)-SECTION,Pandoc Options)

#WORK
#	does not seem to be documented anywhere... test it, with examples here, regardless...
#	seems to be: yaml_metadata, --defaults, --metadata*, etc.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-DEPENDS
########################################

override define $(HELPOUT)-$(DOITALL)-DEPENDS =
If there are files or directories that have dependencies on other files or
directories being processed first, this can be done simply using $(_C)[GNU Make]$(_D)
syntax in `$(_M)$(COMPOSER_SETTINGS)$(_D)`:

$(CODEBLOCK)$(_M)$(OUT_LICENSE).$(EXTN_DEFAULT)$(_D): $(_E)$(OUT_README).$(EXTN_DEFAULT)$(_D)
$(CODEBLOCK)$(_M)$(SUBDIRS)-$(DOITALL)-$(notdir $(COMPOSER_ART))$(_D): $(_E)$(SUBDIRS)-$(DOITALL)-$(notdir $(PANDOC_DIR))$(_D)

This would require `$(_E)$(OUT_README).$(EXTN_DEFAULT)$(_D)` to be completed before `$(_M)$(OUT_LICENSE).$(EXTN_DEFAULT)$(_D)`, and for
`$(_E)$(notdir $(PANDOC_DIR))$(_D)` to be processed before `$(_M)$(notdir $(COMPOSER_ART))$(_D)`.  Directories need to be specified
with the `$(_C)$(SUBDIRS)-$(DOITALL)-$(_N)*$(_C)$(_D)` syntax in order to avoid conflicts with target names
$(_E)(see [Custom Targets])$(_D).

Chaining of dependencies can be as complex and layered as $(_C)[GNU Make]$(_D) will
support.  Note that if a file or directory is set to depend on a target, that
target will be run whenever the file or directory is called.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-CUSTOM
########################################

#WORK
# $(COMPOSER_TINYNAME)-note
# $(COMPOSER_TINYNAME)-makefile
# $(COMPOSER_TINYNAME)-make
# $(COMPOSER_TINYNAME)-mkdir
# $(COMPOSER_TINYNAME)-ln
# $(COMPOSER_TINYNAME)-cp
# $(COMPOSER_TINYNAME)-mv
# $(COMPOSER_TINYNAME)-rm
#WORK
# = Tooling Options
# command variables?  $(SED), $(PRINT), etc., etc.
# colors?  $(_F), etc.
# DO_HEREDOC?
# $($(DEBUGIT)-output)?
#WORK
# it's just basic shell scripting...
#	@command1
#	@command2
#	@if ; then ...
#	exits on fail = $(TRUE)
#	helper targets and variables
# migrate to *-target-[pre|post]
#	update "targets:" filter
#	sorted? use numbers, like udev, etc... 00-*, 10-*, etc.
# a note about $(COMPOSER_REGEX) matching for custom targets...

override define $(HELPOUT)-$(DOITALL)-CUSTOM =
If needed, custom targets can be defined inside a `$(_M)$(COMPOSER_SETTINGS)$(_D)` file $(_E)(see
[Configuration Settings])$(_D), using standard $(_C)[GNU Make]$(_D) syntax.  Naming them as
$(_C)[$(_N)*$(_C)-$(EXPORTS)]$(_D), $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) or $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) will include them in runs of the respective
targets.  Targets with any other names will need to be run manually, or included
in $(_C)[COMPOSER_TARGETS]$(_D).

#WORK ...or, via [Specifying Dependencies]

There are a few limitations when naming custom targets.  Targets starting with
the regular expression `$(_N)$(COMPOSER_REGEX_PREFIX)$(_D)` are hidden, and are skipped by auto-detection.
Additionally, there is a list of reserved targets in $(_C)[Reserved]$(_D), along with a
list of reserved variables.

Any included `$(_M)$(COMPOSER_SETTINGS)$(_D)` files are sourced early in the main $(_C)[$(COMPOSER_BASENAME)]$(_D)
`$(_M)$(MAKEFILE)$(_D)`, so matching targets and most variables will be overridden.  In the
case of conflicting targets, $(_C)[GNU Make]$(_D) will produce warning messages.
Variables will have their values changed silently.  Changing the values of
internal $(_C)[$(COMPOSER_BASENAME)]$(_D) variables is not recommended or supported.

A final note is that $(_C)[$(_N)*$(_C)-$(EXPORTS)]$(_D), $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) and $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D) targets are stripped from
$(_C)[COMPOSER_TARGETS]$(_D).  In cases where this results in an empty $(_C)[COMPOSER_TARGETS]$(_D),
there will be a message and no actions will be taken.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-VERSIONS
########################################

override define $(HELPOUT)-$(DOITALL)-VERSIONS =
There are a few internal variables used by $(_C)[$(UPGRADE)]$(_D) to select the repository
and binary versions of integrated components $(_E)(see [Requirements])$(_D).  These are
exposed for configuration, but only within `$(_M)$(COMPOSER_SETTINGS)$(_D)`:
$(foreach FILE,$(REPOSITORIES_LIST),\
$(if $($(FILE)_VER),\
$(call NEWLINE)  * `$(_C)$(FILE)_VER$(_D)` $(_E)(must be a binary version number)$(_D) \
$(call NEWLINE)  * `$(_C)$(FILE)_CMT$(_D)` $(_E)(defaults to `$(FILE)_VER`)$(_D) \
,\
$(call NEWLINE)  * `$(_C)$(FILE)_CMT$(_D)` \
))

Binaries for $(_C)[Pandoc]$(_D), $(_C)[YQ]$(_D) and $(_C)[Google Firebase]$(_D) are installed in their
respective directories.  By moving or removing them, or changing the version
numbers and foregoing all relevant variations of $(_C)[$(UPGRADE)]$(_D), the system versions
will be used instead.  This will work as long as the commit versions match, so
that supporting files are in alignment, particularly for $(_C)[Pandoc]$(_D).

It is possible that changing the versions will introduce incompatibilities with
$(_C)[$(COMPOSER_BASENAME)]$(_D), which are usually impacts to the prettification of output files
$(_E)(see [Document Formatting])$(_D).  Command-line options may also be affected.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-VARIABLES_FORMAT
########################################

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

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_logo)

#WORKING
# $(c_site)
# $(TYPE_PRES)

#WORKING document $(COMPOSER_ART)/images

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(COMPOSER_IMAGES))$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_icon)

#WORKING
# $(TYPE_HTML)
# $(TYPE_PRES)

$(call $(HELPOUT)-$(DOITALL)-SECTION,c_css)

#WORKING document $(COMPOSER_ART)/theme

$(CODEBLOCK)$(call COMPOSER_CONV,$(EXPAND)/$(_M),$(abspath $(dir $(call CSS_THEME,$(HELPOUT)))))$(_D)

  * By default, a $(_M)CSS$(_D) stylesheet from $(_C)[Markdown Viewer]$(_D) is used for $(_C)[HTML]$(_D) and
    $(_C)[EPUB]$(_D), and one of the $(_C)[Reveal.js]$(_D) themes is used for $(_C)[Reveal.js
    Presentations]$(_D).  This variable allows for selection of a different file in
    all cases.
  * The special value `$(_N)$(CSS_ALT)$(_D)` selects the alternate default stylesheet.  Using
    `$(_N)$(SPECIAL_VAL)$(_D)` reverts to the $(_C)[Pandoc]$(_D) default.
  * $(_C)[$(COMPOSER_BASENAME)]$(_D) includes several different $(_M)CSS$(_D) files, depending on the $(_C)[c_type]$(_D)
    of the file being built.  See $(_C)[Header & CSS Files]$(_D) under $(_C)[Precedence Rules]$(_D)
    for details on how they are layered together.

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
########################################

override define $(HELPOUT)-$(DOITALL)-VARIABLES_CONTROL =
$(call $(HELPOUT)-$(DOITALL)-SECTION,MAKEJOBS)

#WORK a small number of large directories will process faster than a large number of small ones, especially with $(PUBLISH)
#WORK windows subsystem for linux (increase memory...): /mnt/c/Users/*/.wslconfig
#	[wsl2]
#	processors=2
#	memory=2GB
#	swap=0

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

  * Provides more explicit details about what is happening at each step.  It
    generates a lot more output, and can be slower.  It will also be hard to
    read unless $(_C)[MAKEJOBS]$(_D) is set to `$(_N)$(MAKEJOBS_DEFAULT)$(_D)`.
  * Full tracing using `$(_N)$(SPECIAL_VAL)$(_D)` outputs complete $(_C)[GNU Make]$(_D) and $(_C)[GNU Bash]$(_D) debugging
    information.  This is extraordinarily verbose, and it is recommended to pipe
    it to a file for review.
  * This variable is repurposed in $(_C)[$(DEBUGIT)]$(_D) to pass a list of targets to test.

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
  * When using this option, care should be taken with variables that are
    generally specific to a particular directory or file, and are not meant to
    be applicable globally.  They will be propagated down the tree, which is
    generally not desired except in very specific cases.  Using
    $(_H)[COMPOSER_CURDIR]$(_D) to limit their scope is highly recommended, similar to
    $(_C)[$(EXAMPLE)]$(_D) $(_E)(see [Templates])$(_D).
  * This setting also causes `$(_M)$(COMPOSER_YML)$(_D)` and `$(_M).$(notdir $(COMPOSER_CUSTOM))$(_D)-$(_N)*$(_D)` files to be
    processed in an identical manner $(_E)(see [Configuration Files] and [Header &
    CSS Files] under [Precedence Rules])$(_D).

Example directory tree $(_E)(see [Recommended Workflow])$(_D):

$(CODEBLOCK)$(EXPAND)/$(_M).$(COMPOSER_BASENAME)$(_D)/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK)$(EXPAND)/$(_M).$(COMPOSER_BASENAME)$(_D)/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(EXPAND)/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK)$(EXPAND)/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(EXPAND)/tld/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK)$(EXPAND)/tld/$(_M)$(COMPOSER_SETTINGS)$(_D)
$(CODEBLOCK)$(EXPAND)/tld/sub/$(_M)$(MAKEFILE)$(_D)
$(CODEBLOCK)$(EXPAND)/tld/sub/$(_M)$(COMPOSER_SETTINGS)$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DEPENDS)

  * When doing $(_C)[$(DOITALL)-$(DOITALL)]$(_D), $(_C)[$(COMPOSER_BASENAME)]$(_D) will process the current directory before
    recursing into sub-directories.  This reverses that, and sub-directories
    will be processed first.
  * In the example directory tree in $(_C)[COMPOSER_INCLUDE]$(_D) above, the default would
    be: `$(_M)$(EXPAND)/$(_D)`, `$(_M)$(EXPAND)/tld$(_D)`, and then `$(_M)$(EXPAND)/tld/sub$(_D)`.  If the higher-level
    directories have dependencies on the sub-directories being run first, this
    will support that by doing them in reverse order, processing them from
    bottom to top.
  * This has no effect on $(_C)[$(INSTALL)]$(_D) or $(_C)[$(CLEANER)]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_KEEPING)

#WORK $(SPECIAL_VAL) deletes all...
#	COMPOSER_KEEPING test & document
#	$(CLEANER)-$(CLEANER) test & document
#	$(CLEANER)-$(CLEANER) only runs on $(DOITALL), so single files could go forever...?

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

#WORK
#	add a note that a per-target "override README.html :=" is probably best...
#	come to think of it, probably should just go back to not allowing an empty value...

#WORKING document!
# .$(TARGETS)
# COMPOSER_TARGETS
# COMPOSER_SUBDIRS
# COMPOSER_EXPORTS
# COMPOSER_IGNORES

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
  * An empty value triggers auto-detection.
  * Use $(_C)[$(CONFIGS)]$(_D) or $(_C)[$(TARGETS)]$(_D) to check the current value.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_SUBDIRS)

  * The list of sub-directories to recurse into with $(_C)[$(INSTALL)]$(_D), $(_C)[$(CLEANER)]$(_D), and
    $(_C)[$(DOITALL)]$(_D).  The behavior and configuration is identical to $(_C)[COMPOSER_TARGETS]$(_D)
    above, including auto-detection and the `$(_M)$(NOTHING)$(_D)` target.  Hidden directories
    that start with `$(_M).$(_D)` are skipped.
  * An empty value triggers auto-detection.
  * Use $(_C)[$(CONFIGS)]$(_D) or $(_C)[$(TARGETS)]$(_D) to check the current value.

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_EXPORTS)

#WORKING
#	this one will be complicated... maybe?
#	has, effectively, the same `$(_M)$(NOTHING)$(_D)` behavior as above...
#	also overridden by $(_C)[COMPOSER_IGNORES]$(_D)
#	document .$(TARGETS) token...
#	hidden variables...
#		$(_EXPORT_DIRECTORY)
#		$(_EXPORT_GIT_REPO)
#		$(_EXPORT_GIT_BNCH)
#		$(_EXPORT_FIRE_ACCT)
#		$(_EXPORT_FIRE_PROJ)

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_IGNORES)

#WORK either remove $(PUBLISH) here, or add it to the ones above...
#WORK also, there are also implications for $(PUBLISH)-library...

  * The list of $(_C)[COMPOSER_TARGETS]$(_D), $(_C)[COMPOSER_SUBDIRS]$(_D) and $(_C)[COMPOSER_EXPORTS]$(_D) to
    skip with $(_C)[$(EXPORTS)]$(_D), $(_C)[$(PUBLISH)]$(_D), $(_C)[$(INSTALL)]$(_D), $(_C)[$(CLEANER)]$(_D), and $(_C)[$(DOITALL)]$(_D).  This allows for
    selective auto-detection, when the list of items to process is larger than
    those to leave alone.
  * Use $(_C)[$(CONFIGS)]$(_D) to check the current value.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-VARIABLES_HELPER
########################################

#WORK
# other?
#	DATEMARK

override define $(HELPOUT)-$(DOITALL)-VARIABLES_HELPER =
$(_N)*These are internal variables only exposed within `$(COMPOSER_SETTINGS)` files.*$(_D)
$(_N)*See [Configuration Settings] and [Custom Targets] for more details.*$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,CURDIR)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_CURDIR)

#WORKING can also be used to detect first pass, using "ifeq", to prevent "warning: overriding recipe for target" warnings...

  * This is set to $(_H)[CURDIR]$(_D) when reading in a `$(_M)$(COMPOSER_SETTINGS)$(_D)` file in the
    $(_C)[GNU Make]$(_D) running directory, and is empty otherwise.  This provides a way
    to limit particular portions of the file to the local directory, regardless
    of whether $(_C)[COMPOSER_INCLUDE]$(_D) is set or not.
  * Uses for this are to limit the availability of targets to the local
    directory, or to prevent variable values from recursing down to
    sub-directories.
  * Generally speaking, it is best practice to completely encapsulate all
    `$(_M)$(COMPOSER_SETTINGS)$(_D)` files with this, except for the specific portions that need
    to be passed down, similar to $(_C)[$(EXAMPLE)]$(_D) $(_E)(see [Templates])$(_D).

Example usage in a `$(_M)$(COMPOSER_SETTINGS)$(_D)` file:

$(CODEBLOCK)$(_N)ifneq$(_D) ($(_E)$$(COMPOSER_CURDIR)$(_D),)
$(CODEBLOCK)$(CODEBLOCK)$(EXPAND)
$(CODEBLOCK)$(_N)endif$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DIR)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_ROOT)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_EXPORT)

#WORK hidden variables...

  * $(_H)[_EXPORT_DIRECTORY]$(_D)
  * $(_H)[_EXPORT_GIT_REPO]$(_D)
  * $(_H)[_EXPORT_GIT_BNCH]$(_D)
  * $(_H)[_EXPORT_FIRE_ACCT]$(_D)
  * $(_H)[_EXPORT_FIRE_PROJ]$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_LIBRARY)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_SRC)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_ART)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_DAT)

#WORK

$(call $(HELPOUT)-$(DOITALL)-SECTION,COMPOSER_TMP)

#WORK
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY
########################################

override define $(HELPOUT)-$(DOITALL)-TARGETS_PRIMARY =
$(call $(HELPOUT)-$(DOITALL)-SECTION,$(HELPOUT) / $(HELPOUT)-$(DOITALL))

  * Outputs all of the documentation for $(_C)[Composer]$(_D).  The `$(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT)$(_D)` has a few
    extra sections covering internal targets, along with reserved target and
    variable names, but is otherwise identical to the $(_C)[$(HELPOUT)-$(DOITALL)]$(_D) output.

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(EXAMPLE) / $(EXAMPLE)-yml / $(EXAMPLE)-md)

  * Prints useful templates for creating new files $(_E)(see [Templates])$(_D):
      * $(_C)[$(COMPOSER_BASENAME)]$(_D) `$(_M)$(COMPOSER_SETTINGS)$(_D)` $(_E)(see [Configuration Settings])$(_D)
      * $(_C)[$(COMPOSER_BASENAME)]$(_D) $(_C)[c_site]$(_D) and $(_C)[Pandoc]$(_D) `$(_M)$(COMPOSER_YML)$(_D)` $(_E)(see [Static Websites]
        and [Configuration Settings])$(_D)
      * $(_C)[Pandoc]$(_D) `$(_C)$(INPUT)$(_D)`

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(COMPOSER_PANDOC))

  * This is the very core of $(_C)[$(COMPOSER_BASENAME)]$(_D), and does the actual work of the
    $(_C)[Pandoc]$(_D) conversion.  Details are in the $(_C)[c_type / c_base / c_list]$(_D) section
    of $(_C)[Formatting Variables]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(PUBLISH) / $(PUBLISH)-$(DOITALL) / $(PUBLISH)-$(DOFORCE))

#WORKING $(PUBLISH) rebuilds indexes, force recursively

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(PUBLISH)-$(CLEANER))

#WORKING

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
    $(_C)[COMPOSER_LOG]$(_D) was last updated.  Acts as a quick reference to see if
    anything has changed.
  * Since the $(_C)[COMPOSER_LOG]$(_D) file is updated whenever $(_C)[Pandoc]$(_D) is executed, this
    target will primarily be useful when $(_C)[$(DOITALL)]$(_D) is the only target used to create
    files in the directory.
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL
########################################

#> update: $(DEBUGIT): targets list

override define $(HELPOUT)-$(DOITALL)-TARGETS_ADDITIONAL =
$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DISTRIB) / $(DISTRIB)-$(DOITALL) / $(UPGRADE) / $(UPGRADE)-$(DOITALL) / $(UPGRADE)-$(PRINTER) / $(UPGRADE)-\*)

  * Using the repository configuration $(_E)(see [Repository Versions])$(_D), these fetch
    and build all external components.
  * Simply doing $(_C)[$(UPGRADE)]$(_D) will fetch all source repositories and pre-built
    binaries.
  * The $(_C)[$(UPGRADE)-$(DOITALL)]$(_D) target additionally performs all relevant source code
    builds.  For some repositories, this is necessary to create the final output
    files used by $(_C)[$(COMPOSER_BASENAME)]$(_D), and in other cases this builds local binaries
    which replace the included ones.  Additional external tools may be required
    to perform these steps $(_E)(see [$(CHECKIT)-$(DOITALL)])$(_D).
  * To review the resulting differences between upstream sources and the local
    directories, use $(_C)[$(UPGRADE)-$(PRINTER)]$(_D).
  * Each component directory has a corresponding $(_C)[$(UPGRADE)-$(_N)*$(_C)]$(_D) target which
    performs the equivalent of $(_C)[$(UPGRADE)-$(DOITALL)]$(_D) for only that component.
  * Finally, $(_C)[$(DISTRIB)]$(_D) runs $(_C)[$(UPGRADE)-$(DOITALL)]$(_D) and $(_C)[$(CREATOR)]$(_D), which together turn the
    current directory into a functional clone of $(_C)[$(COMPOSER_BASENAME)]$(_D), including
    overwriting all supporting files.
  * Beyond this, $(_C)[$(DISTRIB)-$(DOITALL)]$(_D) also uses $(_C)[$(CREATOR)-$(DOITALL)]$(_D) and $(_C)[$(PUBLISH)-$(EXAMPLE)]$(_D) to
    build the `$(_M)$(OUT_README).$(_N)*$(_D)` files and create an example $(_C)[Static Websites]$(_D) in the
    `$(_M)$(notdir $(PUBLISH_ROOT))$(_D)` directory.
  * One of the unique features of $(_C)[$(COMPOSER_BASENAME)]$(_D) is that everything needed to
    compose itself is embedded in the `$(_M)$(MAKEFILE)$(_D)`, so it is fully self-contained.

Creating a development clone:

#WORK should create a "development/contributing/support" section, and reference this...
#	also: https://github.com/garybgenett/gary-os/blob/main/.vimrc

$(CODEBLOCK)$(_C)mkdir$(_D) $(_M)$(EXPAND)/$(COMPOSER_TINYNAME)$(_D)
$(CODEBLOCK)$(_C)cd$(_D) $(_M)$(EXPAND)/$(COMPOSER_TINYNAME)$(_D)
$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_N)-f $(EXPAND)/.$(COMPOSER_BASENAME)/$(MAKEFILE)$(_D) $(_M)$(DISTRIB)$(_D)

Note that some additional external tools may be required to perform the builds,
such as $(_C)[NPM]$(_D) $(_E)(see [$(CHECKIT)-$(DOITALL)])$(_D).

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

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CHECKIT) / $(CHECKIT)-$(DOITALL))

  * Use $(_C)[$(CHECKIT)]$(_D) to see the minimum list of required external components and
    their versions, in relation to the system installed versions.
  * Doing $(_C)[$(CHECKIT)-$(DOITALL)]$(_D) will show the complete list of tools that are used by
    $(_C)[$(COMPOSER_BASENAME)]$(_D), along with which targets they are needed by.

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CONFIGS) / $(CONFIGS)-$(DOITALL) / $(CONFIGS)-\* / $(CONFIGS)-yml / $(TARGETS))

  * The current values of all $(_C)[Composer Variables]$(_D) is output by $(_C)[$(CONFIGS)]$(_D), and
    $(_C)[$(CONFIGS)-$(DOITALL)]$(_D) will additionally output all environment variables.
  * Individual $(_C)[Composer Variables]$(_D) can be exported with $(_C)[$(CONFIGS)-$(_N)*$(_C)]$(_D).  This is
    useful for scripting in `$(_M)$(COMPOSER_SETTINGS)$(_D)` $(_E)(see [Custom Targets])$(_D).
  * A JSON version of the `$(_M)$(COMPOSER_YML)$(_D)` configuration is exported with
    $(_C)[$(CONFIGS)-yml]$(_D).  This is available for any external scripting, such as in
    `$(_M)$(COMPOSER_SETTINGS)$(_D)` $(_E)(see [Custom Targets])$(_D), and is parseable with $(_C)[YQ]$(_D).
  * A structured list of detected targets, $(_C)[$(_N)*$(_C)-$(EXPORTS)]$(_D), $(_C)[$(_N)*$(_C)-$(CLEANER)]$(_D) and $(_C)[$(_N)*$(_C)-$(DOITALL)]$(_D)
    targets, $(_C)[COMPOSER_TARGETS]$(_D), and $(_C)[COMPOSER_SUBDIRS]$(_D) is printed by $(_C)[$(TARGETS)]$(_D).
  * Together, $(_C)[$(CONFIGS)]$(_D) and $(_C)[$(TARGETS)]$(_D) reveal the entire internal state of
    $(_C)[$(COMPOSER_BASENAME)]$(_D).

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(DOSETUP) / $(DOSETUP)-$(DOFORCE))

#WORKING

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(CONVICT) / $(CONVICT)-$(DOITALL) / $(CONVICT)-$(PRINTER))

  * Using the directory structure in $(_C)[Recommended Workflow]$(_D), `$(_M)$(EXPAND)/$(_D)` is
    considered the top-level directory.  Meaning, it is the last directory
    before linking to $(_C)[$(COMPOSER_BASENAME)]$(_D).
  * If the top-level directory is a $(_N)[Git]$(_D) repository $(_E)(it has `<directory>.git`
    or `<directory>/.git`)$(_D), this target creates a commit of the current
    directory tree with the title format below.
  * For example, if it is run in the `$(_M)$(EXPAND)/tld$(_D)` directory, that entire tree would
    be in the commit, including `$(_M)$(EXPAND)/tld/sub$(_D)`.  The purpose of this is to create
    quick and easy checkpoints when working on documentation that does not
    necessarily fit in a process where there are specific atomic steps being
    accomplished.
  * When this target is run in a $(_C)[$(COMPOSER_BASENAME)]$(_D) directory, it uses itself as the
    top-level directory.  When calling $(_C)[$(COMPOSER_BASENAME)]$(_D) directly using `$(_N)-f$(_D)`, the
    current directory is used.
  * Using $(_C)[$(CONVICT)-$(DOITALL)]$(_D) automatically does the commit instead of opening the
    text editor in the `$(_C)$$EDITOR$(_D)` variable.
  * For the $(_C)[$(CONVICT)-$(PRINTER)]$(_D) target specifically, $(_C)[c_list]$(_D) is repurposed to select
    the limited list of files and/or directories that should be committed.  All
    selected files and directories must exist in the current directory or
    somewhere in the subdirectory tree below it.  There is no option to skip the
    `$(_C)$$EDITOR$(_D)` with this target.

Commit title format:

$(CODEBLOCK)$(_E)$(call COMPOSER_TIMESTAMP)$(_D)

Example using $(_C)[$(CONVICT)-$(PRINTER)]$(_D) with $(_C)[c_list]$(_D):

$(CODEBLOCK)$(_C)$(DOMAKE)$(_D) $(_M)$(CONVICT)-$(PRINTER)$(_D) $(_E)c_list="$(MAKEFILE) $(call COMPOSER_CONV,,$(COMPOSER_ART))"$(_D)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(EXPORTS) / $(EXPORTS)-$(DOITALL) / $(EXPORTS)-$(DOFORCE) / \*-$(EXPORTS))

#WORKING ... and then runs all $(_C)[$(_N)*$(_C)-$(EXPORTS)]$(_D) targets.
#	hidden variables...
#		$(_EXPORT_DIRECTORY)
#		$(_EXPORT_GIT_REPO)
#		$(_EXPORT_GIT_BNCH)
#		$(_EXPORT_FIRE_ACCT)
#		$(_EXPORT_FIRE_PROJ)

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(PUBLISH)-library)

#WORKING

$(call $(HELPOUT)-$(DOITALL)-SECTION,$(PUBLISH)-$(PRINTER) / $(PUBLISH)-$(PRINTER)-$(DOITALL) / $(PUBLISH)-$(PRINTER)-$(PRINTER) / $(PUBLISH)-$(PRINTER)-$(patsubst .%,%,$(NOTHING)) / $(PUBLISH)-$(PRINTER)-\*)

#WORKING
endef

########################################
### {{{3 $(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL
########################################

override define $(HELPOUT)-$(DOITALL)-TARGETS_INTERNAL =
$(_N)*None of these are intended to be run directly during normal use.*$(_D)
$(_N)*They are only listed here for completeness.*$(_D)

$(_S)[$(HELPOUT)-$(HELPOUT)]: #internal-targets$(_D)
$(_S)[.$(EXAMPLE)-$(INSTALL)]: #internal-targets$(_D)
$(_S)[.$(EXAMPLE)]: #internal-targets$(_D)
$(_S)[$(HEADERS)]: #internal-targets$(_D)
$(_S)[$(HEADERS)-$(EXAMPLE)]: #internal-targets$(_D)
$(_S)[$(HEADERS)-$(EXAMPLE)-$(DOITALL)]: #internal-targets$(_D)
$(_S)[$(MAKE_DB)]: #internal-targets$(_D)
$(_S)[$(LISTING)]: #internal-targets$(_D)
$(_S)[$(NOTHING)]: #internal-targets$(_D)
$(_S)[$(CREATOR)]: #internal-targets$(_D)
$(_S)[$(CREATOR)-$(DOITALL)]: #internal-targets$(_D)
$(_S)[$(TESTING)]: #internal-targets$(_D)
$(_S)[$(TESTING)-file]: #internal-targets$(_D)
$(_S)[$(TESTING)-dir]: #internal-targets$(_D)
$(_S)[$(TESTING)-$(PRINTER)]: #internal-targets$(_D)
$(_S)[$(CHECKIT)-$(HELPOUT)]: #internal-targets$(_D)
$(_S)[$(PUBLISH)-$(COMPOSER_SETTINGS)]: #internal-targets$(_D)
$(_S)[$(PUBLISH)-$(COMPOSER_YML)]: #internal-targets$(_D)
$(_S)[$(PUBLISH)-$(EXAMPLE)]: #internal-targets$(_D)
$(_S)[$(PUBLISH)-$(EXAMPLE)-$(TESTING)]: #internal-targets$(_D)
$(_S)[$(PUBLISH)-$(EXAMPLE)-$(CONFIGS)]: #internal-targets$(_D)
$(_S)[$(SUBDIRS)]: #internal-targets$(_D)
$(_S)[$(PRINTER)-$(PRINTER)]: #internal-targets$(_D)
endef

########################################
## {{{2 $(PUBLISH) Pages
########################################

#WORKING:NOW:NOW:DOCS
#	add a header/box to each which describes what to test for that page...
#	add a sitemap symlink test... maybe themes/index.html...?
#		they likely break when used across directories, when "composer_root" is used... document!

########################################
### {{{3 $(PUBLISH) Page: Main
########################################

override PUBLISH_PAGE_1_NAME		:= Introduction

override define PUBLISH_PAGE_1 =
---
title: $(PUBLISH_PAGE_1_NAME)
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
$(PUBLISH_CMD_BEG) box-begin 1 Introduction $(PUBLISH_CMD_END)

#WORKING:DOCS
#	introduction

$(call PUBLISH_PAGE_EXAMPLE_LAYOUT)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) box-begin 1 Example Pages $(PUBLISH_CMD_END)

The entire list of pages in this test site can be found in the [main sitemap].  To understand how the site is configured, and to see demonstrations of all the features, visit the following pages.  This list can be found in the `PAGES` menu on the top bar throughout the site.

[main sitemap]: $(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-sitemap))))

$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_SPECIAL),$(word 1,$(PUBLISH_FILES))) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) box-begin 1 Default Configuration $(PUBLISH_CMD_END)

$(call PUBLISH_PAGE_1_CONFIGS)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
endef

#WORKING:DOCS
#	integrate this in $(HELPOUT)
#	default css (see "themes" page)
#	note on example page about logo/icon

override define PUBLISH_PAGE_1_CONFIGS =
| $(PUBLISH)-config | defaults
|:---|:---------|
| header        | `$(PUBLISH_HEADER)`
| footer        | `$(PUBLISH_FOOTER)`
| css_overlay   | `$(PUBLISH_CSS_OVERLAY)`
| copy_protect  | `$(PUBLISH_COPY_PROTECT)`
| cols_break    | `$(PUBLISH_COLS_BREAK)`
| cols_sticky   | `[ $(PUBLISH_COLS_STICKY_L), $(PUBLISH_COLS_STICKY_C), $(PUBLISH_COLS_STICKY_R) ]`
| cols_resticky | `[ $(PUBLISH_COLS_RESTICKY_L), $(PUBLISH_COLS_RESTICKY_C), $(PUBLISH_COLS_RESTICKY_R) ]`
| cols_order    | `[ $(PUBLISH_COLS_ORDER_L), $(PUBLISH_COLS_ORDER_C), $(PUBLISH_COLS_ORDER_R) ]`
| cols_reorder  | `[ $(PUBLISH_COLS_REORDER_L), $(PUBLISH_COLS_REORDER_C), $(PUBLISH_COLS_REORDER_R) ]`
| cols_size     | `[ $(PUBLISH_COLS_SIZE_L), $(PUBLISH_COLS_SIZE_C), $(PUBLISH_COLS_SIZE_R) ]`
| cols_resize   | `[ $(PUBLISH_COLS_RESIZE_L), $(PUBLISH_COLS_RESIZE_C), $(PUBLISH_COLS_RESIZE_R) ]`
| metainfo      | `$(PUBLISH_METAINFO)`
| metainfo_null | `$(PUBLISH_METAINFO_NULL)`
| metalist $(DIVIDE) $(PUBLISH_CREATORS) | *title:* `$(PUBLISH_CREATORS_TITLE)` <br> *display:* `$(PUBLISH_CREATORS_PRINT)`
| metalist $(DIVIDE) $(PUBLISH_METALIST) | *title:* `$(PUBLISH_METALIST_TITLE)` <br> *display:* `$(PUBLISH_METALIST_PRINT)`
| readtime      | `$(PUBLISH_READTIME)`
| readtime_wpm  | `$(PUBLISH_READTIME_WPM)`

| $(PUBLISH)-library | defaults
|:---|:---------|
| folder           | `$(LIBRARY_FOLDER)`
| auto_update      | `$(LIBRARY_AUTO_UPDATE)`
| append           | `$(LIBRARY_APPEND)`
| digest_title     | `$(LIBRARY_DIGEST_TITLE)`
| digest_continue  | `$(LIBRARY_DIGEST_CONTINUE)`
| digest_permalink | `$(LIBRARY_DIGEST_PERMALINK)`
| digest_chars     | `$(LIBRARY_DIGEST_CHARS)`
| digest_count     | `$(LIBRARY_DIGEST_COUNT)`
| digest_expanded  | `$(LIBRARY_DIGEST_EXPANDED)`
| digest_spacer    | `$(LIBRARY_DIGEST_SPACER)`
| lists_expanded   | `$(LIBRARY_LISTS_EXPANDED)`
| lists_spacer     | `$(LIBRARY_LISTS_SPACER)`
| sitemap_title    | `$(LIBRARY_SITEMAP_TITLE)`
| sitemap_expanded | `$(LIBRARY_SITEMAP_EXPANDED)`
| sitemap_spacer   | `$(LIBRARY_SITEMAP_SPACER)`

*(For this test site, the library has been enabled as: `$(PUBLISH_LIBRARY)`)*
endef

#> update: $(PUBLISH) Pages

#WORKING:DOCS
#	README: `$(call COMPOSER_CONV,$(EXPAND)/,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH).yml`
#	PAGE_3: `$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_YML)`
#	PAGE_5: `$(PUBLISH_BOOTSTRAP_TREE)` / `$(word 5,$(PUBLISH_DIRS))`
#	PAGEDIR: `$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)`

override define PUBLISH_PAGE_1_INCLUDE =
[$(COMPOSER_BASENAME) $(OUT_README)]($(PUBLISH_OUT_README))
:   Created with [c_site]($(PUBLISH_OUT_README)#c_site), and configured to produce a navigable reference document.

----

[$(PUBLISH_PAGE_1_NAME)]($(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES)))
:   Main page, with information about this test site and how to use it.

[$(PUBLISH_PAGE_2_NAME)]($(PUBLISH_CMD_ROOT)/$(word 2,$(PUBLISH_FILES)))
:   An empty configuration, to demonstrate a simple page with no layout or elements.

[$(PUBLISH_PAGE_3_NAME)]($(PUBLISH_CMD_ROOT)/$(word 3,$(PUBLISH_FILES)))
:   All settings changed, showcasing the full flexibility of layout and behavior.

[$(PUBLISH_PAGE_4_NAME)]($(PUBLISH_CMD_ROOT)/$(word 4,$(PUBLISH_FILES)))
:   A [Pandoc]($(PUBLISH_OUT_README)#document-formatting) [markdown]($(PUBLISH_OUT_README)#pandoc-extensions) file, without any [$(COMPOSER_BASENAME)]($(PUBLISH_OUT_README)#overview) embedded elements.

[$(PUBLISH_PAGE_5_NAME)]($(PUBLISH_CMD_ROOT)/$(word 5,$(PUBLISH_FILES)))
:   A [markdown]($(PUBLISH_OUT_README)#pandoc-extensions) file with default [Bootstrap]($(PUBLISH_OUT_README)#static-websites) colors instead of [themes and overlays]($(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX).$(EXTN_HTML)).

----

[$(PUBLISH_PAGE_EXAMPLE_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_EXAMPLE).$(EXTN_HTML))
:   All documentation for [c_site]($(PUBLISH_OUT_README)#c_site) layout and embeddable page elements, with examples.

[$(PUBLISH_PAGE_PAGEDIR_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_PAGEDIR).$(EXTN_HTML))
:   A longer page assembled from a collection of files and their metadata, with instructions.

[$(PUBLISH_PAGE_TESTING_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_TESTING).$(EXTN_HTML))
:   A single file from the collection above, showing how to span metadata across contexts.

[$(PUBLISH_PAGE_SHOWDIR_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX).$(EXTN_HTML))
:   Gallery of included themes and overlays, for all [HTML]($(PUBLISH_OUT_README)#html)-based formats.

----

[$(PUBLISH_PAGE_LIBRARY_NAME)]($(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest)))))
:   Starting page for the library, which is a digest of the most recently dated files.

[$(PUBLISH_PAGE_LIBRARY_ALT_NAME)]($(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest)))))
:   Same as above, for a version of the library specific to the `$(word 3,$(PUBLISH_DIRS))` directory.

<!-- #$(MARKER)
[$(PUBLISH_PAGE_INCLUDE_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_INCLUDE).$(EXTN_HTML))
:   Demonstration of using the library digest include file.

[$(PUBLISH_PAGE_INCLUDE_ALT_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_INCLUDE_ALT).$(EXTN_HTML))
:   Same as above, for the version of the library specific to the `$(word 3,$(PUBLISH_DIRS))` directory.
#$(MARKER) -->
endef

########################################
### {{{3 $(PUBLISH) Page: Nothing
########################################

override PUBLISH_PAGE_2_NAME		:= Default Site

#>$(PUBLISH_CMD_BEG) metainfo $(MENU_SELF) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)
override define PUBLISH_PAGE_2 =
---
title: $(PUBLISH_PAGE_2_NAME)
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)

This is a default page, where all menus and settings are empty.  All aspects of `c_site` pages are configurable using `$(COMPOSER_YML)` files.

$(call PUBLISH_PAGE_EXAMPLE_LAYOUT)

In the layout, this page column is `c_list`, and the default `cols_size` for the center column is `$(PUBLISH_COLS_SIZE_C)` and `cols_resize` for the mobile view is `$(PUBLISH_COLS_RESIZE_C)`.  Since `nav-left` and `nav-right` are both empty, this column is positioned at the left edge.

In the absence of the `PAGES` menu, use the list below to navigate to the other example pages.

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_SPECIAL),$(word 1,$(PUBLISH_FILES))) $(PUBLISH_CMD_END)
endef

########################################
### {{{3 $(PUBLISH) Page: Config
########################################

override PUBLISH_PAGE_3_NAME		:= Configured Site

override define PUBLISH_PAGE_3_HEADER =
$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) Header $(PUBLISH_CMD_END)

This is a header include from the `$(COMPOSER_YML)` file.

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
endef

override define PUBLISH_PAGE_3_FOOTER =
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) Footer $(PUBLISH_CMD_END)

This is a footer include from the `$(COMPOSER_YML)` file.

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
endef

override define PUBLISH_PAGE_3_APPEND =
$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) Append $(PUBLISH_CMD_END)

This is an append include from the `$(COMPOSER_YML)` file.

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
endef

override define PUBLISH_PAGE_3 =
---
title: $(PUBLISH_PAGE_3_NAME)
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
$(PUBLISH_CMD_BEG) box-begin 1 #WORKING:DOCS $(PUBLISH_CMD_END)

#WORKING:DOCS

`$(PUBLISH_CMD_BEG) metainfo $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) metainfo $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) box-begin 1 Configuration Settings $(PUBLISH_CMD_END)

$(call PUBLISH_PAGE_3_CONFIGS)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
endef

override define PUBLISH_PAGE_3_CONFIGS =
| $(PUBLISH)-config | defaults | values
|:---|:------|:------|
| header        | `$(PUBLISH_HEADER)`        | `$(PUBLISH_HEADER_ALT)`
| footer        | `$(PUBLISH_FOOTER)`        | `$(PUBLISH_FOOTER_ALT)`
| css_overlay   | `$(PUBLISH_CSS_OVERLAY)`   | `$(PUBLISH_CSS_OVERLAY_ALT)`
| copy_protect  | `$(PUBLISH_COPY_PROTECT)`  | `$(PUBLISH_COPY_PROTECT_ALT)`
| cols_break    | `$(PUBLISH_COLS_BREAK)`    | `$(PUBLISH_COLS_BREAK_ALT)`
| cols_sticky   | `[ $(PUBLISH_COLS_STICKY_L), $(PUBLISH_COLS_STICKY_C), $(PUBLISH_COLS_STICKY_R) ]`       | `[ $(PUBLISH_COLS_STICKY_L_ALT), $(PUBLISH_COLS_STICKY_C_ALT), $(PUBLISH_COLS_STICKY_R_ALT) ]`
| cols_resticky | `[ $(PUBLISH_COLS_RESTICKY_L), $(PUBLISH_COLS_RESTICKY_C), $(PUBLISH_COLS_RESTICKY_R) ]` | `[ $(PUBLISH_COLS_RESTICKY_L_ALT), $(PUBLISH_COLS_RESTICKY_C_ALT), $(PUBLISH_COLS_RESTICKY_R_ALT) ]`
| cols_order    | `[ $(PUBLISH_COLS_ORDER_L), $(PUBLISH_COLS_ORDER_C), $(PUBLISH_COLS_ORDER_R) ]`          | `[ $(PUBLISH_COLS_ORDER_L_ALT), $(PUBLISH_COLS_ORDER_C_ALT), $(PUBLISH_COLS_ORDER_R_ALT) ]`
| cols_reorder  | `[ $(PUBLISH_COLS_REORDER_L), $(PUBLISH_COLS_REORDER_C), $(PUBLISH_COLS_REORDER_R) ]`    | `[ $(PUBLISH_COLS_REORDER_L_ALT), $(PUBLISH_COLS_REORDER_C_ALT), $(PUBLISH_COLS_REORDER_R_ALT) ]`
| cols_size     | `[ $(PUBLISH_COLS_SIZE_L), $(PUBLISH_COLS_SIZE_C), $(PUBLISH_COLS_SIZE_R) ]`             | `[ $(PUBLISH_COLS_SIZE_L_ALT), $(PUBLISH_COLS_SIZE_C_ALT), $(PUBLISH_COLS_SIZE_R_ALT) ]`
| cols_resize   | `[ $(PUBLISH_COLS_RESIZE_L), $(PUBLISH_COLS_RESIZE_C), $(PUBLISH_COLS_RESIZE_R) ]`       | `[ $(PUBLISH_COLS_RESIZE_L_ALT), $(PUBLISH_COLS_RESIZE_C_ALT), $(PUBLISH_COLS_RESIZE_R_ALT) ]`
| metainfo      | `$(PUBLISH_METAINFO)`      | `$(PUBLISH_METAINFO_ALT)`
| metainfo_null | `$(PUBLISH_METAINFO_NULL)` | `$(PUBLISH_METAINFO_NULL_ALT)`
| metalist $(DIVIDE) $(PUBLISH_CREATORS) | *title:* `$(PUBLISH_CREATORS_TITLE)` <br> *display:* `$(PUBLISH_CREATORS_PRINT)` | title: `$(PUBLISH_CREATORS_TITLE_ALT)` <br> display: `$(PUBLISH_CREATORS_PRINT_ALT)`
| metalist $(DIVIDE) $(PUBLISH_METALIST) | *title:* `$(PUBLISH_METALIST_TITLE)` <br> *display:* `$(PUBLISH_METALIST_PRINT)` | title: `$(PUBLISH_METALIST_TITLE_ALT)` <br> display: `$(PUBLISH_METALIST_PRINT_ALT)`
| readtime      | `$(PUBLISH_READTIME)`      | `$(PUBLISH_READTIME_ALT)`
| readtime_wpm  | `$(PUBLISH_READTIME_WPM)`  | `$(PUBLISH_READTIME_WPM_ALT)`

| $(PUBLISH)-library | defaults | values
|:---|:------|:------|
| folder           | `$(LIBRARY_FOLDER)`           | `$(PUBLISH_LIBRARY_ALT)`
| auto_update      | `$(LIBRARY_AUTO_UPDATE)`      | `$(LIBRARY_AUTO_UPDATE_ALT)`
| append           | `$(LIBRARY_APPEND)`           | `$(LIBRARY_APPEND_ALT)`
| digest_title     | `$(LIBRARY_DIGEST_TITLE)`     | `$(LIBRARY_DIGEST_TITLE_ALT)`
| digest_continue  | `$(LIBRARY_DIGEST_CONTINUE)`  | `$(LIBRARY_DIGEST_CONTINUE_ALT)`
| digest_permalink | `$(LIBRARY_DIGEST_PERMALINK)` | `$(LIBRARY_DIGEST_PERMALINK_ALT)`
| digest_chars     | `$(LIBRARY_DIGEST_CHARS)`     | `$(LIBRARY_DIGEST_CHARS_ALT)`
| digest_count     | `$(LIBRARY_DIGEST_COUNT)`     | `$(LIBRARY_DIGEST_COUNT_ALT)`
| digest_expanded  | `$(LIBRARY_DIGEST_EXPANDED)`  | `$(LIBRARY_DIGEST_EXPANDED_ALT)`
| digest_spacer    | `$(LIBRARY_DIGEST_SPACER)`    | `$(LIBRARY_DIGEST_SPACER_ALT)`
| lists_expanded   | `$(LIBRARY_LISTS_EXPANDED)`   | `$(LIBRARY_LISTS_EXPANDED_ALT)`
| lists_spacer     | `$(LIBRARY_LISTS_SPACER)`     | `$(LIBRARY_LISTS_SPACER_ALT)`
| sitemap_title    | `$(LIBRARY_SITEMAP_TITLE)`    | `$(LIBRARY_SITEMAP_TITLE_ALT)`
| sitemap_expanded | `$(LIBRARY_SITEMAP_EXPANDED)` | `$(LIBRARY_SITEMAP_EXPANDED_ALT)`
| sitemap_spacer   | `$(LIBRARY_SITEMAP_SPACER)`   | `$(LIBRARY_SITEMAP_SPACER_ALT)`

*(For this test site, the default library has been enabled as: `$(PUBLISH_LIBRARY)`)*
endef

########################################
### {{{3 $(PUBLISH) Page: Pandoc
########################################

override PUBLISH_PAGE_4_NAME		:= Pandoc Markdown

override define PUBLISH_PAGE_4_HEADER =
$(PUBLISH_CMD_BEG) metainfo box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) metainfo box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)`

#WORKING:DOCS

  * metainfo box
  * unformatted markdown file
  * markdown file footer

`$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
endef

########################################
### {{{3 $(PUBLISH) Page: Bootstrap
########################################

override PUBLISH_PAGE_5_NAME		:= Bootstrap Default

override define PUBLISH_PAGE_5_HEADER =
$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)`

#WORKING:DOCS

  * what notes go here?

`$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
endef

########################################
### {{{3 $(PUBLISH) Example: Elements
########################################

override PUBLISH_PAGE_EXAMPLE_NAME	:= Layout & Elements

override define PUBLISH_PAGE_EXAMPLE =
---
title: $(PUBLISH_PAGE_EXAMPLE_NAME)
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(PUBLISH_EXAMPLE)$(COMPOSER_EXT_SPECIAL) $(PUBLISH_CMD_END)
endef

#WORKING:DOCS
#	include in documentation as HEREDOC_*

override define PUBLISH_PAGE_EXAMPLE_LAYOUT =
| | | | |
|:---|:---|:---|---:|
| Top Bar    | `brand` (`homepage`) | `nav-top` | `info-top` / `search_*`
| Main Page  | `nav-left` | **`c_list`** | `nav-right`
| Bottom Bar | `copyright` | `nav-bottom` | `info-bottom` / *(`$(COMPOSER_TINYNAME)`)*
endef

#WORKING:DOCS

override define PUBLISH_PAGE_EXAMPLE_INCLUDE =
# Page Layout

$(call PUBLISH_PAGE_EXAMPLE_LAYOUT)

# Elements

## Folds

`$(PUBLISH_CMD_BEG) fold-begin 3 . $(SPECIAL_VAL) Open Fold $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) fold-begin 3 . $(SPECIAL_VAL) Open Fold $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) fold-begin 3 $(SPECIAL_VAL) $(SPECIAL_VAL) Closed Fold $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) fold-begin 3 $(SPECIAL_VAL) $(SPECIAL_VAL) Closed Fold $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) header 3 Non-Header Fold $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) fold-begin $(SPECIAL_VAL) . $(SPECIAL_VAL) Generic Fold $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) fold-begin $(SPECIAL_VAL) . $(SPECIAL_VAL) Generic Fold $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)

## Boxes

`$(PUBLISH_CMD_BEG) box-begin 3 Box $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-begin 3 Box $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) box-begin 3 Nested Box $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-begin 3 Nested Box $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) header 3 Non-Header Box $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) Generic Box $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) Generic Box $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

## Grids

`$(PUBLISH_CMD_BEG) row-begin $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) row-begin $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-begin col-6 $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) column-begin col-6 $(PUBLISH_CMD_END)`

#WORKING:DOCS
#	some clever content goes here

`$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-begin col-6 $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) column-begin col-6 $(PUBLISH_CMD_END)`

#WORKING:DOCS
#	some clever content goes here

`$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) row-end $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) row-end $(PUBLISH_CMD_END)`

#WORKING:DOCS
#	see another example in [Library] beloww...

## Displays

`$(PUBLISH_CMD_BEG) display $(patsubst <%>,{%},$(PUBLISH_CMD_ROOT))/$(PUBLISH_EXAMPLE).yml Example Banner $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) display $(PUBLISH_CMD_ROOT)/$(PUBLISH_EXAMPLE).yml Example Banner $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) display $(patsubst <%>,{%},$(PUBLISH_CMD_ROOT))/$(PUBLISH_EXAMPLE).yml Example Shelf $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) display $(PUBLISH_CMD_ROOT)/$(PUBLISH_EXAMPLE).yml Example Shelf $(PUBLISH_CMD_END)

# Tokens

## Header

$(PUBLISH_CMD_BEG) header 3 Non-Header $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) header 3 Non-Header $(PUBLISH_CMD_END)`

**This Is An Embedded Link Only -- There Is No HTML Header Here**

## Spacer

$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

## Break

#WORKING:DOCS need to demonstrate this, somehow...

## Icon

#WORKING:DOCS
#	icon list: $(foreach CSS_ICON,$(call CSS_ICONS),$(word 1,$(subst ;, ,$(CSS_ICON))))
#	note about PUBLISH_CMD_ROOT {} escaping

`$(PUBLISH_CMD_BEG) icon cc-by-nc-nd $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) icon cc-by-nc-nd $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) icon gpl $(patsubst <%>,{%},$(PUBLISH_CMD_ROOT))/../$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) icon gpl $(PUBLISH_CMD_ROOT)/../$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) icon github $(COMPOSER_REPOPAGE) $(COMPOSER_TECHNAME) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) icon github $(COMPOSER_REPOPAGE) $(COMPOSER_TECHNAME) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) icon icon-$(COMPOSER_ICON_VER).png $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) icon icon-$(COMPOSER_ICON_VER).png $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) icon icon-$(COMPOSER_ICON_VER).png author $(subst <,{,$(subst >,},$(PUBLISH_OUT_README))) Gary B. Genett $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) icon icon-$(COMPOSER_ICON_VER).png author $(PUBLISH_OUT_README) Gary B. Genett $(PUBLISH_CMD_END)

## Form

`$(PUBLISH_CMD_BEG) form sites $(COMPOSER_CNAME) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) form sites $(COMPOSER_CNAME) $(PUBLISH_CMD_END)

#WORKING:DOCS
#	this results in:

	<input type="hidden" name="sites" value="$(COMPOSER_CNAME)">

## Frame

#WORK these produce frames which potentially have their own scrollbars and/or player controls that can go fullscreen...
#WORK the example is the first youtube video ever posted...

`$(PUBLISH_CMD_BEG) frame $(PUBLISH_CMD_ROOT)/../$(OUT_README).$(EXTN_HTML) $(COMPOSER_TECHNAME) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) frame $(PUBLISH_CMD_ROOT)/../$(OUT_README).$(EXTN_HTML) $(COMPOSER_TECHNAME) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) frame youtube jNQXAC9IVRw $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) frame youtube jNQXAC9IVRw $(PUBLISH_CMD_END)

## Include

#WORKING:DOCS
#	note about PUBLISH_CMD_ROOT {} escaping

`$(PUBLISH_CMD_BEG) $(patsubst <%>,{%},$(PUBLISH_CMD_ROOT))/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_SPECIAL),$(word 1,$(PUBLISH_FILES))) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_SPECIAL),$(word 1,$(PUBLISH_FILES))) $(PUBLISH_CMD_END)

# Helpers

## Metainfo

`$(PUBLISH_CMD_BEG) metainfo $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) metainfo $(PUBLISH_CMD_END)

#WORKING:DOCS
#	demonstrated elsewhere...

  * `$(PUBLISH)-nav-left: { metainfo }` + `$(PUBLISH_CMD_BEG) metainfo $(PUBLISH_CMD_END)`
    * [$(PUBLISH_PAGE_1_NAME)]($(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES)))
    * [$(PUBLISH_PAGE_3_NAME)]($(PUBLISH_CMD_ROOT)/$(word 3,$(PUBLISH_FILES)))
  * `$(PUBLISH_CMD_BEG) metainfo $(MENU_SELF) box-begin 1 $(PUBLISH_CMD_END)`
    * [$(PUBLISH_PAGE_PAGEDIR_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_PAGEDIR).$(EXTN_HTML))
    * [$(PUBLISH_PAGE_TESTING_NAME)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_TESTING).$(EXTN_HTML))
  * `$(PUBLISH_CMD_BEG) metainfo box-begin $(SPECIAL_VAL) $(PUBLISH_CMD_END)`
    * [$(PUBLISH_PAGE_4_NAME)]($(PUBLISH_CMD_ROOT)/$(word 4,$(PUBLISH_FILES)))

## Contents

#WORKING:DOCS
#	this section is broken:

  * there is already a "CONTENTS" panel on the left, which is grabbing the `<id>` link
  * the "CONTENTS" helper on the left is also setting the argument for all the rest *(they will also stomp on each other)*
  * probably can fix this with `contents-\*` files in an `examples` sub-directory:
    * only use right pane in `$(COMPOSER_YML)` file
    * duplicates of this page, and use `#contents` to link to them

#WORKING:DOCS
#	notes:

  * no argument does `$(DEPTH_MAX)`
  * `$(SPECIAL_VAL)`
    * does `$(DEPTH_MAX)`
    * only does `header` links
    * trims from `<|>` to end of title *(primarily used internally for digest pages)*
  * placed at the "root" level creates a full bar using "h1"s as dropdowns

`$(PUBLISH_CMD_BEG) contents $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) contents $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) contents $(SPECIAL_VAL) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) contents $(SPECIAL_VAL) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) contents 1 $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) contents 1 $(PUBLISH_CMD_END)

## Metalist

#WORKING:DOCS
#	also, refer to [Library] below...

`$(PUBLISH_CMD_BEG) metalist $(PUBLISH_CREATORS) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) metalist $(PUBLISH_CREATORS) $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) metalist $(PUBLISH_METALIST) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) metalist $(PUBLISH_METALIST) $(PUBLISH_CMD_END)

## Read Time

`$(PUBLISH_CMD_BEG) readtime $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) readtime $(PUBLISH_CMD_END)

# Library

#WORKING:DOCS
#	another example of [Grids] elements...
#	also, refer to [Metalist] above...

`$(PUBLISH_CMD_BEG) row-begin $(PUBLISH_CMD_END)`

`$(PUBLISH_CMD_BEG) column-begin col-3/col-4/col-3 $(PUBLISH_CMD_END)`

`$(PUBLISH_CMD_BEG) library date/$(PUBLISH_CREATORS)/$(PUBLISH_METALIST) $(PUBLISH_CMD_END)`

$(PUBLISH_CMD_BEG) row-begin $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-begin col-3 $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) header 2 Dates $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) library date $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-begin col-4 $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) header 2 Authors $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) library $(PUBLISH_CREATORS) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-begin col-3 $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) header 2 Metalist $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) library $(PUBLISH_METALIST) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) row-end $(PUBLISH_CMD_END)

`$(PUBLISH_CMD_BEG) column-end $(PUBLISH_CMD_END)`

`$(PUBLISH_CMD_BEG) row-end $(PUBLISH_CMD_END)`
endef

override define PUBLISH_PAGE_EXAMPLE_DISPLAY =
"Example Banner":
  type:					banner
  tint:					dark
  auto:					$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1,null)
  time:					$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),3,null)
  list:
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/screenshot-v4.0.png
      link:				"#displays"
      name:				"Banner #1"
#$(MARKER)   $(MENU_SELF): |
#$(MARKER)       <p style="background-color: gray; color: black;">Lorem Ipsum</p>
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/screenshot-v3.0.png
      link:				"#displays"
      name:				"Banner #2"
      $(MENU_SELF): |
          <p style="background-color: gray; color: black;">Lorem Ipsum</p>
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/screenshot-v1.0.png
      link:				"#displays"
      name:				"Banner #3"
      $(MENU_SELF): |
          <p style="background-color: gray; color: black;">Lorem Ipsum</p>

"Example Shelf":
  type:					shelf
  tint:					null
  auto:					$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1,null)
  time:					$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),3,null)
  show:					$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),5,3)
  list:
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon-v1.0.png
      link:				"#displays"
      name:				"Shelf #1"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon.gpl.png
      link:				"#displays"
      name:				"Shelf #2"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon.cc-by-nc-nd.png
      link:				"#displays"
      name:				"Shelf #3"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon.copyright.svg
      link:				"#displays"
      name:				"Shelf #4"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon.github.svg
      link:				"#displays"
      name:				"Shelf #5"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon.menu.svg
      link:				"#displays"
      name:				"Shelf #6"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
    - file:				$(call COMPOSER_CONV,$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/,$(COMPOSER_IMAGES))/icon.search.svg
      link:				"#displays"
      name:				"Shelf #7"
      size:				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),1024px,null)
endef

########################################
### {{{3 $(PUBLISH) Example: Pages
########################################

#WORKING:DOCS
#	also needs a different name...?
override PUBLISH_PAGE_PAGEDIR_NAME	:= Metainfo Page

override define PUBLISH_PAGE_PAGEDIR_HEADER =
---
title: $(PUBLISH_PAGE_PAGEDIR_NAME)
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
endef

override define PUBLISH_PAGE_PAGEDIR_FOOTER =
endef

########################################
### {{{3 $(PUBLISH) Example: Testing
########################################

override PUBLISH_PAGE_TESTING_NAME	:= Metainfo File

#> update: $(PUBLISH)-library-sort-yq
#>title: Number 0$(word 1,$(1)) in $(word 2,$(1))
#>## $(word 2,$(1)) Lorem Ipsum
override define PUBLISH_PAGE_TESTING =
---
title: Page Number 0$(word 1,$(1))
date: $(word 3,$(1))
$(PUBLISH_CREATORS): [$(COMPOSER_COMPOSER), Author 1, Author 2, Author 3]
$(PUBLISH_METALIST): [Tag $(word 1,$(1)), Tag 1, Tag 2, Tag 3]
---
$(PUBLISH_CMD_BEG) metainfo $(MENU_SELF) box-begin 1 $(PUBLISH_CMD_END)

## $(word 2,$(1)) Lorem Ipsum #$(word 1,$(1))

$(call $(HELPOUT)-$(DOITALL)-WORKFLOW)
endef

########################################
### {{{3 $(PUBLISH) Example: Themes
########################################

override PUBLISH_PAGE_SHOWDIR_NAME	:= Themes & Overlays

override define PUBLISH_PAGE_SHOWDIR =
---
title: $(PUBLISH_PAGE_SHOWDIR_NAME)
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
$(PUBLISH_CMD_BEG) box-begin 1 $(PUBLISH_PAGE_SHOWDIR_NAME) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_SPECIAL) $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)

$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(PUBLISH_EXAMPLE)$(COMPOSER_EXT_SPECIAL) $(PUBLISH_CMD_END)
endef

#> update: FILE.*CSS_THEMES
override define PUBLISH_PAGE_SHOWDIR_INCLUDE =
$(strip \
$(foreach FILE,$(call CSS_THEMES),\
	$(eval override FTYPE := $(word 1,$(subst ;, ,$(FILE)))) \
	$(eval override THEME := $(word 2,$(subst ;, ,$(FILE)))) \
	$(eval override SFILE := $(word 3,$(subst ;, ,$(FILE)))) \
	$(eval override OVRLY := $(word 4,$(subst ;, ,$(FILE)))) \
	$(eval override TITLE := $(word 5,$(subst ;, ,$(FILE)))) \
	$(eval override DEFLT := $(word 6,$(subst ;, ,$(FILE)))) \
	$(eval override FEXTN := $(if $(filter $(FTYPE),$(TYPE_PRES)),$(EXTN_PRES),$(EXTN_HTML))) \
	$(if $(filter-out $(TOKEN),$(TITLE)),\
		<N>**$(subst $(TOKEN), ,$(TITLE))** \
		$(if $(filter [$(COMPOSER_BASENAME)],$(TITLE)),\
			*(Templates)* \
		) \
		<N><N> \
	) \
	$(if $(filter-out $(TOKEN),$(OVRLY)),\
		\t* [Theme: $(FTYPE).$(THEME) -- Overlay: $(OVRLY)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/$(FTYPE).$(THEME)+$(OVRLY).$(FEXTN)) \
		$(if $(filter-out $(TOKEN),$(DEFLT)),\
			**(default: `$(DEFLT)`)** \
		) \
		$(if $(filter $(FTYPE).$(THEME),$(PUBLISH).solar-light),\
			<N>\t\t\t\t* *(same as `$(PUBLISH).solar-dark`)* \
		) \
		$(if $(or \
			$(filter $(FTYPE).$(THEME),$(TYPE_HTML).$(CSS_ALT)) ,\
			$(filter $(FTYPE).$(THEME),$(TYPE_HTML).solar-$(CSS_ALT)) ,\
		),\
			<N>\t\t\t\t* *(automatic `prefers-color-scheme` color selection)* \
		) \
		<N> \
	) \
))
endef

########################################
### {{{3 $(PUBLISH) Include: Library
########################################

override PUBLISH_PAGE_LIBRARY_NAME	:= Default Library Page
override PUBLISH_PAGE_INCLUDE_NAME	:= Default Digest Page
override PUBLISH_PAGE_LIBRARY_ALT_NAME	:= Configured Library Page
override PUBLISH_PAGE_INCLUDE_ALT_NAME	:= Configured Digest Page

override define PUBLISH_PAGE_LIBRARY_EXAMPLE =
$(PUBLISH_CMD_BEG) box-begin $(SPECIAL_VAL) #WORKING:DOCS $(PUBLISH_CMD_END)

#WORKING:DOCS
: `$(patsubst ./%,%,$(word $(1),$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY$(2))/$(notdir $($(PUBLISH)-library-digest-src)))`
: `$(patsubst ./%,%,$(word $(1),$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY$(2))/$(notdir $($(PUBLISH)-library-sitemap-src)))`

  * Library Index Page: [$(patsubst ./%,%,$(word $(1),$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY$(2))/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest)))]($(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word $(1),$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY$(2))/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest))))))
  * Library Include Page: [$(PUBLISH_INCLUDE$(2)).$(EXTN_HTML)]($(PUBLISH_CMD_ROOT)/$(PUBLISH_INCLUDE$(2)).$(EXTN_HTML))

$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)
$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)
endef

override define PUBLISH_PAGE_LIBRARY =
$(call PUBLISH_PAGE_LIBRARY_EXAMPLE,1)
endef

override define PUBLISH_PAGE_LIBRARY_ALT =
$(call PUBLISH_PAGE_LIBRARY_EXAMPLE,3,_ALT)
endef

#>$(call PUBLISH_PAGE_LIBRARY$(2))
override define PUBLISH_PAGE_INCLUDE_EXAMPLE =
---
title: $(LIBRARY_DIGEST_TITLE$(2))
date: $(DATEMARK)
$(PUBLISH_CREATORS): $(COMPOSER_COMPOSER)
$(PUBLISH_METALIST): [ Main ]
---
$(PUBLISH_CMD_BEG) $(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word $(1),$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY$(2))/$(notdir $($(PUBLISH)-library-digest-src))) $(PUBLISH_CMD_END)
endef

override define PUBLISH_PAGE_INCLUDE =
$(call PUBLISH_PAGE_INCLUDE_EXAMPLE,1)
endef

override define PUBLISH_PAGE_INCLUDE_ALT =
$(call PUBLISH_PAGE_INCLUDE_EXAMPLE,3,_ALT)
endef

########################################
## {{{2 $(EXAMPLE)
########################################

.PHONY: $(EXAMPLE)-install
.PHONY: $(EXAMPLE)
.PHONY: $(EXAMPLE)-yml
.PHONY: $(EXAMPLE)-md
$(EXAMPLE)-install \
$(EXAMPLE) \
$(EXAMPLE)-yml \
$(EXAMPLE)-md \
:
	@$(call ENV_MAKE) $(call COMPOSER_OPTIONS_EXPORT) COMPOSER_DOCOLOR= .$(@)

#WORKING keep this?  can it be improved?  document!
.PHONY: $(EXAMPLE)-md-file
$(EXAMPLE)-md-file:
	@$(call ENV_MAKE) $(EXAMPLE)-md >$(CURDIR)/$(DATENAME)$(COMPOSER_EXT)
	@$(EDITOR) $(CURDIR)/$(DATENAME)$(COMPOSER_EXT)

########################################

.PHONY: .$(EXAMPLE)-$(INSTALL)
.$(EXAMPLE)-$(INSTALL):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN ,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
	@$(call $(EXAMPLE)-var-static,,COMPOSER_MY_PATH)
	@$(call $(EXAMPLE)-var-static,,COMPOSER_TEACHER)
	@$(call $(EXAMPLE)-var-static,,COMPOSER_TEACHER,1)

#> update: COMPOSER_OPTIONS
.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN ,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
#>	@$(call $(EXAMPLE)-print,,$(_S)########################################)
#>	@$(call $(EXAMPLE)-print,1,$(_H)$(MARKER) Global Variables)
#>	@$(ENDOLINE)
	@$(foreach FILE,$(COMPOSER_OPTIONS_GLOBAL),\
		$(call $(EXAMPLE)-var,1,$(FILE)); \
	)
	@$(ENDOLINE)
#>	@$(call $(EXAMPLE)-print,,$(_S)########################################)
	@$(call $(EXAMPLE)-print,,$(_N)ifneq$(_D) ($(_E)\$$(COMPOSER_CURDIR)$(_D),))
	@$(ENDOLINE)
#>	@$(call $(EXAMPLE)-print,,$(_S)########################################)
#>	@$(call $(EXAMPLE)-print,1,$(_H)$(MARKER) Local Variables)
#>	@$(ENDOLINE)
	@$(foreach FILE,$(COMPOSER_OPTIONS_LOCAL),\
		$(call $(EXAMPLE)-var,1,$(FILE)); \
	)
	@$(ENDOLINE)
#>	@$(call $(EXAMPLE)-print,,$(_S)########################################)
	@$(call $(EXAMPLE)-print,,$(_N)endif$(_D))

#WORK add *-$(DOITALL) to this, to get the commented/full version instead...?
.PHONY: .$(EXAMPLE)-yml
.$(EXAMPLE)-yml:
	@$(if $(COMPOSER_DOCOLOR),,$(call TITLE_LN ,$(DEPTH_MAX),$(_H)$(call COMPOSER_TIMESTAMP)))
#>	@$(ECHO) '$(call YQ_EVAL_DATA_FORMAT,$(COMPOSER_YML_DATA))'
	@$(ECHO) '$(strip $(call COMPOSER_YML_DATA_SKEL))' \
		| $(YQ_WRITE_OUT) 2>/dev/null \
			$(call YQ_WRITE_OUT_COLOR) \
		| $(SED) "s|^|$(if $(COMPOSER_DOCOLOR),$(CODEBLOCK))$(shell $(ECHO) "$(COMMENTED)")|g"

.PHONY: .$(EXAMPLE)-md
.$(EXAMPLE)-md:
	@$(call $(EXAMPLE)-print,,$(_S)---)
	@$(call $(EXAMPLE)-print,,$(_C)title$(_D): $(_N)\"$(_M)$(COMPOSER_HEADLINE)$(_N)\")
	@$(call $(EXAMPLE)-print,,$(_C)date$(_D): $(_M)$(DATEMARK))
	@$(foreach FILE,$(COMPOSER_YML_DATA_METALIST),\
		$(call $(EXAMPLE)-print,,$(_C)$(FILE)$(_D):); \
		if [ "$(FILE)" = "$(PUBLISH_CREATORS)" ]; then \
			FILE="$$($(GIT) config --get user.name 2>/dev/null || $(TRUE))"; \
			if [ -n "$${FILE}" ]; then	$(call $(EXAMPLE)-print,,  - $(_M)$${FILE}); \
				else			$(call $(EXAMPLE)-print,,  - $(_M)$${USER}); \
			fi; \
		else					$(call $(EXAMPLE)-print,,  - $(_M)$(COMPOSER_BASENAME)); \
		fi; \
		$(call NEWLINE) \
	)
	@$(call $(EXAMPLE)-print,,$(_S)---)
	@$(call $(EXAMPLE)-print,,$(COMPOSER_TAGLINE))

########################################

override define $(EXAMPLE)-print =
	$(PRINT) "$(if $(COMPOSER_DOCOLOR),$(CODEBLOCK))$(if $(1),$(COMMENTED))$(2)"
endef

override define $(EXAMPLE)-var-static =
	$(if $(3),\
		$(call $(EXAMPLE)-print,$(1),$(_N)include$(_D) $(_E)\$$($(2))$(_D)) ,\
		$(call $(EXAMPLE)-print,$(1),$(_N)override$(_D) $(_C)$(2)$(_D) :=$(if $($(2)), $(_M)$($(2)))) \
	)
endef

#> update: $(HEADERS)-run
override define $(EXAMPLE)-var =
	$(eval override OUT := $(strip \
		$(if $(filter c_list,$(2)),$(call COMPOSER_CONV,$(TOKEN)/,$(call c_list_var))$(if $(call c_list_var_source),$(_D) $(_S)\#$(MARKER)$(_D) $(_E)$(call c_list_var_source,,,1)) ,\
		$(if $(filter c_css,$(2)),$(call COMPOSER_CONV,$(TOKEN)/,$(call c_css_select,$(c_type))) ,\
		$(subst ",\",$(call COMPOSER_CONV,$(TOKEN)/,$($(2)))) \
		)) \
	)) \
	$(call $(EXAMPLE)-print,$(1),$(_N)override$(_D) $(_C)$(2)$(_D) :=$(if $(OUT), $(_M)$(subst $(TOKEN),\$$(COMPOSER_DIR),$(OUT))))
endef

################################################################################
# {{{1 Embedded Files
################################################################################

override DIST_LOGO_v1.0			:= iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAc0lEQVQ4y8VTQQ7AIAgrZA/z6fwMD8vcQCDspBcN0GIrAqcXNes0w1OQpBAsLjrujVdSwm4WPF7gE+MvW0gitqM/87pyRWLl0S4hJ6nMJwDEm3l9EgDAVRrWeFb+CVZfywU4lyRWt6bgxiB1JrEc5eOfEROp5CKUZInHTAAAAABJRU5ErkJggg==
override DIST_ICON_v1.0			:= $(DIST_LOGO_v1.0)
override DIST_SCREENSHOT_v1.0		:= iVBORw0KGgoAAAANSUhEUgAAAeQAAADjCAIAAADbvvCiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH3gUQBTsYVQy6lQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAVJ0lEQVR42u2d3basqA5G6Rr1RrVett9pnXc6F7Xb4eYnhBAQdM6L3dUuxYAQY5SPfz4hhBD+FwAAYEW+XvpFQwAArM/bvcTf39/vj5+fn559YBq/v79cCIANAuxPoxc27KbfKBR7Zn33t52/3r0W27U5QJOXfm00in5OuJ9r3FB3KXm0JyKyBlic4c5a/4h9bWQ0zltt6gfJjQAsxfvsKH9+fs5DtJRZ1uzT6qq+5TQ5iO/Oh+XnQs7njSxMj8oeUton6HLx0ZbWklObDfWKLpOv51XafO5R58bR1115BXk4gKdkQ87uoORx0r9mf5tz1nJknSaso9/VMg/7sztHv6N9SnvK57KVrGlVTb00NtuecjQ2l/5trbv+CgLc20u/m0ZsGqA5jpZqZJTuoAmmUguPo4TDJ2RF0six0wxNvdwTIL4NdQ6ZhfbxqinAfmkQecSen0Ojkbz+aMHCvcLPNIeDRwYImheM0VA/Yh93j+DrU0rJnJ6Ib/RXgxqb9QYcNjc5u9L+muSPpnDZpCgs2PquAzAwso5C5vM7otQLfB9Uq6/dovSivJvsWbJvqITn6Mj4asny2atZC8G/CCWnFmZtttXLKyaNaqG0OTUg/d9qOcqaAtwf/aSY1uipdZ+V46ael3X3sHm1JyeAp3npfxByavU1G8V3S9nMh9sAZmcdcNYAAFs4a1T3AAA2AGcNALCVs3afZsYWtly4BYDIGgAAZvPnBeO/tZkvbGHLRlsY2HAnPsd/PjxEs4U0CMDCzvpDZM0WImsAImu2sIXIGsAnsuYFIwDABjCDEQBggzQIkTUAwAbgrAEAcNYAAODBe2vr7yFLj7g+ADg768itROs0Rl+8HvtEW7LlpPsoEZae2cX3pY0AABAjfGdd8tSh5dPX7A/lb/3No+lPi8fXAACplzbmrOcErWb/xaIkAHAz3mlcvIinG2dMmiPOpmWOdYGDLpmjLDla+hYAoCHADo1pkFL64vdEupuQ+rAtoZvdobpWb2pzdkv6r+ao6pZsa5AGAQBVGqTkmMwZEtt7wugoQ+zZFIn7xrbfkDmKmtOb0PEnImsA0PNKfWW/E0mF0MYdtRQ/Pz/pJzEH9DYA6HXWhgB2gr9uLaEUVpfKaf3y5IvwsaBQd7IcANDDW5++OPugY+fqhI5zaiV67SanLLxeMEbl6Gsh52Q05WjaBwBAxfGCcUE0LxjT15KdEfSgEvprAQCP9tIrO+uNbhsAAEOdNXrWAACrO+uAkNP8kgEADDQ46+xCpU1CTiN837lA89vIdEoh4koAsFyArZzBmLrsy9cw1UwCVBrQcywAwGgv3bX4wBFKG0Ja/CAAgB7/6eZ6Tz3oRKn+RrRlWjUBAJwD7GBKg6RbUkkms0iTITzPyiRlzyuobxP+A8CCXtpfIjU9NlvaoK8s+HgDAG7JECEnAAAY4qznMz/DQE4DAPalQcjJxUuev1+esyRNdmWW6LxLLZEDAJBy2XRzF8/IDEYAuD2fa501AADonfWLhgAAWB+EnHY9OwDgrCu+KYjySZELmyzkFG0vnT2SoEqPEgSqwt8vY/nIBABm0DSDsTQ/MDtd8FohJ+HswvRFgxwVzhoAJnjprpx1dmFDZRB9lY+TbZ55pwEA0HNDIScXIrVuAIBreUe+qeqh0gkmqY+LIut0yzhXqDm7V8kAALOdtV7IKXoFJ2Q/zgmHUjkTIuL0RMqIPjoQHw0AF9Ir5PTzH6tlMPayGQBA5azdsxCOe47w1wAAe9Eg5HROldhy1uEKIafS5+FN9dKUAwAwDoScdj07ADwEhJwAALZx1gg5AQBsAEJO2AwA93LW2SxzdRLKjYWcWn008k8AYEcv5FT6U1YRSfg9IkotnXGCkFO/qQAAVS89MGeNkBMAgBcIORXvNK0fF/7+/mYD82M7AICZZiEnjY+rRtZ3FXKKmrGUGQcAMDprvZCTxl9HCQd5t9ERMUJOAHADeoWcls1gyDsg5AQAWzpr9yyE454j/PX8+gIA9NAg5BQUkkzKnPU9hJyytYh+480BwAWEnGbXghmMANAEQk4AANs4a4ScAAA2ACEneAr0Ftg+wP60dPdoPp5my4Th1/Sn9b2J+7G856QpYHsvbRNy0ggeTZu2jrNexFlv0eY4a9jUWRtz1umDpLxl8giZ81EgNlf7AAB44T/dvBTLrOOMlBrc55nr2Y+1NTokacnHx9el1kjP3lSOLEiSLed8oNLCVFQgPaR6Llv72Foe4C7ZEKuetTJnPUfPujUhICdzSkqEnVsi7WzZqpK3TcuR01A9Fv7+TWhXMO9vH9sVzJZDGgQ29dK9kXUaK2WFnKZFNzbjvZIAR0goxLZpm2hs9ipH02heClalW6mcH2vqM9G82aPls9cC4A5pEC+J1IeTPu+7NKZSanXa5VP2Fr23Hdfy9Ge4DS+z+whiSrQpNTE6rHax6sgDyLnmUJAEEWzQe5OqwWuqkWhMsn3NEvXDo/rytQDYOLIOCiGnVKRJsyVc/YKxKjVVEp+SswHm1jCkaM4P9Up//X38T9f5zVpoCMnTQ5TtfD7QJvs1uuUBFqVpUszQ2MpWrGYCjvtyt7BgbO7VWwAW9dJznDXOAgCgx1mjugcAsLqzDvcTciJTCQC3pMFZe83i8yX7GpCsBQDcMMBWzmA8/7VnFt+IyFq5HQBgUy/ttvjA4tJOAABb80qj4GnSpvhrAIA2Z32eEdOTWf5ORjh/zZpucTkRAMCj8JdIXU3aCQCAyBoAACY6637WlHYCALgHDTMYHb+z9vryWpDZ4/kAAO7Bp9VZ++LiT5nBCAA4awAAWMVZv2gIAID1QcgJAGCTAFupZ21e0zpaG3uEs1ZuBwDY1Eu/Ut/a5ByPhZqEo35O0O4AAAa6ctbZZfGUuh8EvwAAzc5aKeTUtGBr1VPjrwEA2pz10OnmCDkBAHTSLOQUBdfZ6Di7eou8DwAADIyseXMIADDPWTfh4ppJWAMA6HlHLnhEjJxmq12EswEAngNCTgAAS4OQEwDANs4aIScAgA1AyAkA4HbOOnKFpTeHpY0jHGj2m24+NQGAu3Go7lWngGcV9YS/yr99I2vldgCATb301Jz1OQrGnwIA6GkTcvKNiPHXAABtzto83fwQaSod9dUSQcgJAKCHZiGn1Bfr9zmXjKcGAJgXWQMAwDxnPQ4+2AAA6KdByOmsZN2UJylNXUHICQBACUJOAABLg5ATAMA2zhohJwCADcBZAwDgrAEAwNdZl7SZ2MKWHbcAEFkDAMBs/nwN8m+iQ/3LFrZsu4WBDXfic/znw0M0W0iDACzsrD9E1mwhsgYgsmYLW4isAXwia14wAgBsANPNAQA2SIMQWQMAbADOGgAAZw0AADhrAACcdRs7fjUl2Bwtx76m8amF65s9p//s2wh8fUj73DOyHnfl1p9YkVr4XXwnnSQyrZ1vMJCurUK211VNyu5wS6dma5/b9DHSIOEhffrG5+VqPvlaPKem79TZl9Yz/AZu343pPul9w31dxNSe4193mzVnF0r2renMktN6ado5u4OmfbzComz7VPtG1Of7e5S744hO1DQKzNeipxaac5X62Hdjkz3y0I4u9Aj/I9usHE1avhMZ05m7qZXnhFHPnOBSKuqgtCUtR046K20uPaHIv1tL7qmp0qpzIeaS03pp2rlkz1V9I1sLzdmjnWded3OfrKZBJl8Lzbmy+5Q0A/TtIzfOiFEp29w6mkr2fL30uym30nlrKh2ebs9uOW5Hmvi3yWZbfJfNGrceoqyppuRowXi54sJfvVrM0D62Fsv+1eXsco/6/tD0zNZayFe5OgoM19SxFhrDhMvUn9uNBsK4UWnoLT0X662p8CIp/POThaPNjjX1egpOa7pUYs7cYhfWYqjN1Z45cxQsWPLM65XaP25UTvaZrzT2jkxxPGtPUedkUPVRyCuGWr+mky10aeeht/+mbydKfV7/uF29XoNq19k3vodnH9In1GJcV5HvNONGpe1Erfa8S/efc9hfKlQWF44eEjtvcdlyouR9p83nPx0pJ30txtU0W3JkoWPJ8jOyssVaz94Z8uivjrxzqaYTrnu2DTX9sPRCT+4b6dvIQa9J9SVHSTxNHyttOQoZ6n80NldHUwPpC0aAJ/DkPq957QbrUH/BCAC3ZFwcDeNAzxoAYPXIOjCDEQBgC9qcdZOQSutrXJfcmaacdCbCUpQ+8jcYPHNlwplNOq4frtwHVrhei691OXnsTO6Hbc56nJCK77eQcpP9/MdVfc5lbshqCB+fTjsXrHm97jp2JgtLvRg564wTKjsiqtquta+1efHm2jdq6Uc13VwvpBKsMknVs0efUpolWryaUmOPIGojSPMEk7CUUNkmQR9lOytbvlXwKD171mbhobWnjwWFWI9G8iyYBLNKrbHU9Yp61HPGjpc/zNZd0z4hnL6z1ggnhXahmZKMiyxh0yMR1T99yCwsla2p3sIm2SbDY9cIKa6qJUIL9EgyaebvVROOyrqXJHs6t1Trtdr10vexW46daf4w3eev76zNwiUGt6gsTdOOXlIv1ejbbPM4wZpO8akmEQOXWe9pj1K2qlIgJZVJmP+8JYwdTd8QdC1WuF62lrzH2HH0h+a+966W0p9Bc1FPPz8Rd8obueQEU3smy0gNeiWraedOm3fMI9tadYQU1w2u16Zjx7c1DDeMlyats5R4UGfJEzzFZBmpmVenR8hphBSO8PjZ9Kbe8JmprL4m1FSwwZZwX+F63X7seLXGIaFlECKWZjAaXpuE8gIcoTHlX1r7o/P1gi0no3T90fsoWc4tq6QTdQXfdT2U9ujbOfvmLQpAzGt/GNpQDn/MrwHPbTKi5NLV2eJ6PWTsOPpDze05qtfXS/9JXQMMCpGWCsr6jbmr7NH86/XwcdHU1F8vjTYIjO2XN0tP3zjhfsvrtbK/1jf1p5oGAQCAy0HICQBgG15yuP5YuRyvuq8mfCPY8zTBI/2UmYc/sF8ooTPz1C6n08xUGuKsn5y9mizRAk/2hs+sZvWzwpn+59B3W3kNnZdXuz9BLufGdy8Ej9aJCZ4cDy1l1WoWvs/9/plyOWGkRIuL8E2wfuNZ6out9qwveBSdvakceSKc8strjSRT9LsqS2QWPPLqP16yTaEgEZWue9s5TrOTPKpiWJrxrhFgyraYlwcI4W8hp7TCD5HLqf7W7DlT+Mbr7He6gqXkYKkcjfSPzUKbLJpv+9iu4Ijea06DaNrHIAQml1O10D03omnDeMHcx8rljJNosbWJpv2zoki2WtxD8EhzB7KVo2m0kvrSiByjTfBoUP8xyza5tI9ZCCwtR9MTlLuN8wB7r27uJZdzuUSLY933yuQOEjxSSvwMGn7CiVrlHsfdL3fsP9PWk1qTrheM95DLuUSixSUDeLbZVovbCx5VDb5wdbfO+73t00Pf/jO/XtV9qr2upz9f21veGr+QvgfQv4Q8V6+0RfMsqSmnVLJ+uAo1Feo1+o49ru73uIJZS85vHZVhb7pzyUJDSJ4eomzn84HK9jFcQcf+I+e7SuOruo/SQmU2o7UNIzOuic1bhZyQy1E+c2ydX0LwaHee2f53rXX8gtEx3fPMr0eHxibz64K/4wrCUiDkBACwemQdEHICANiCVZx19Eo6+129Zk104Wt8eW311BhbLcZ9SD9I18bFwqGiSJfLCQUPbf6035a6q+2Tm0tGSk+vgFbera1vyIXZjipN3U5Lzr6orU4JHVGLcV/2aOoFI/rhuL7h/tXwIiMFbh5Z94wQ2UWuJlLqNTIBGCkPddaax6KQzLU3HCX4oBGeyPxdZEnzIfrrJfXKtmr2cbjVwpLMgtwa8rN2Tx8L3nJCsoXKK+jSNwbVdOZI0fQWcE6DaDSlstfSdpR+dIXuNYk1JVfTDqW62+ZHlLxb6WG5pFsW6YplH4cNFmbnYpSyMaWeI8+lkqc1tiZ8NG2YnZNiEwnx6hteqa1rR0pUU+VEf7A76zWf92W5HH1vMOjsTItuNDIu8m1ygqkXiiJ5teFqmShHC68dKXBBGmRZfy3vcIlU3qM44seqHCCRFCMFrnTWss5sSTbFa5W/aS7g3qtNzmmiXfz1tUJFg2xYcKTAkDSIIOwS/SnKnJbEeuSj+nuJoBWnX28i/L3QSVW+Mi05e4u65Os6pbiS4SF9QVGkziZyly4y9I2h4gSTR0q2t4A/rUJOd73H0sMAGCkre2mmm3dFoACMFJgDQk4AAKtH1oHIGgBgCzLO2mvWaes66DMxzLCqzsdTblm2TbyuMgCMCrA/Lc665+OkRXyWQUGtNDG6dcv9/B3OGmCOl36lY68690E5htd/EbGIhXztBABV6gvmhkRzIJph3PS1ZrbkkvZFv0tttbBHK7Jn0rNNQyd7daJWjcQwU9s0yhLCFgC4IA0iSJWXfgsKavJvOSOhSSCk4uilLVFqokd2XZOPNifrR6Rl0n/7kzl3WhoYYBcv/e5MXJRkzvu9kmaynCaSjSZbyjGsrFGpVJhLp65pGtacOPJN5pwfRIijAfZIgwxCKaK4WspbeROa7KlHkOp2Mg8C4HJevs6iVRdYs/GSD0UW9NQuK0aWhLfS0rKvPQmxAVaMrEuvlQxK9qUH7ZLY01CZG8FCvahN9qiS8I1QeJOnFmSAlEJOJeEtoRx5CwBMokfICSbnYS4vAQCu8tJMN98GEscATwYhJwCA1SPrMOJrkKb8L9HifLaYXAoAGZ/9UQ9y8279q3ytnG/dLhfstegabQ4wzUu/njmuVliF78IWI7IG2I7hzlr/0D3Tp4/zVpv6QXIjAIvzPjvKaCp2KbOs2afVedmWmtWIGaUTwTVyVK1fXkfN2FSyQdYqLVme8u4V6c8XjSpJcXFrgYdmQ0pyP5EnDQqRJnPOWo6s5dl0ss3y/lmxp6pVXiVr2rAkNdVqs+2Z5nLRKIP+OMD9vPS7aQxnZ1RfmEDwmg89ISviLofiJdzROh/Vt3E0olFIlAAEwVmXch3R2L52/FTzM4fB6+RkR5uxV/iJaBSAklfr4C/pQlw7Gbopo6KM+AzrNLo/FugNOGxuTfqXFEv6rxGiUQCjIusoZE7llqL4WiOBFCUc5d1kX1OVUhIkos7Fas5VzVoI/kXWy9YIMNlkrbxi0qVEowDgD+5CTpqYtLoIy7XsuBKKr82IRgGs5qXRBgnVJ3RsthlDaAzg5awDzhoAYAtnjUQqAMAG4KwBAHDWAACAswYAeAj/B20celP5v/1/AAAAAElFTkSuQmCC
override DIST_SCREENSHOT_v3.0		:= iVBORw0KGgoAAAANSUhEUgAAAeMAAADICAIAAABUCR4uAAABhGlDQ1BJQ0MgcHJvZmlsZQAAKJF9kT1Iw0AcxV9ba6VUOthBxCFDdWpBVMRRq1CECqFWaNXB5NIvaGJIUlwcBdeCgx+LVQcXZ10dXAVB8APE0clJ0UVK/F9SaBHjwXE/3t173L0D/M0aU82eMUDVLCObTgn5wooQekUQYfQiioTETH1WFDPwHF/38PH1LsmzvM/9OfqVoskAn0A8w3TDIl4nntq0dM77xDFWkRTic+KEQRckfuS67PIb57LDfp4ZM3LZOeIYsVDuYrmLWcVQiSeJ44qqUb4/77LCeYuzWquz9j35CyNFbXmJ6zSHkcYCFiFCgIw6qqjBQpJWjRQTWdpPefiHHL9ILplcVTByzGMDKiTHD/4Hv7s1SxPjblIkBQRfbPtjBAjtAq2GbX8f23brBAg8A1dax7/RBKY/SW90tPgREN0GLq47mrwHXO4Ag0+6ZEiOFKDpL5WA9zP6pgIwcAuEV93e2vs4fQBy1FXmBjg4BEbLlL3m8e6+7t7+PdPu7wc213KP0n9sFQAAAAlwSFlzAAAYJQAAGMMBG9cmzQAAAAd0SU1FB+YFCgYdDrfNAIIAAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAQfklEQVR42u2dW5LjKBBF6YreUddyWB7LqdnTfHhaI/NMXlYC50RHhytLQgiVr9MpuDJ/jPljAABAL18MAQDAQkrtbv8TIUKECBEtEXJqAADt/HoVqf95k3NjjDVEiBAhQkRFxJjbHUW+axAhQoSIxgg5NREiRIiQUxMhQoQIkb4IdxQBANTDyhcAAOWQUwMAoNQAAIBSAwCg1AAAsIpSO0EktaMTb/wIXg9d7BwbzsK9/6saWx2jAgAqyM6nHiHWTv1bv22m40DZc0oHB6UGWFOpG8Ra/9vdJXJh78UkzRN/Bvz8/BQjyDTAlnzF8rrsm1Sy+rGh2uASpQaX3ksS8QRXzuukbF9ufr22vdfpJcp3aQ4jU1W7OMzaLiDA2Tl1bWbtxNUGV1l/EEZcaw9T2lOl1G17PZ1TO8Hl0nMBAbbnd+IdZwvvY1uKfIArl7e3o7vYZt4LefvRH6tO1g4bou/v72JklExb2ZAov4AA+yn19W1/EZm+v3edjnezeAhB5wUEUEvlfOpOmW6b4mZLrdmOGYTCvea1ZqXfZNqqH64yku+F/gsIsCWXP/VMmXaxUkAqp8qkpcV28i3Le+hiVQsny/q8I0r6XCPTV8UjjJhpA6b/AgJsjlIvvb0Tqqaz+0xOzQUEQKl5o58CFxDgAKUGAIC/4NAEAIBSAwDAOKXm+ZJEiBAhojFCTg0AoJ1rPnXRdYkIESJEiDwSKTg0ESFChAiR5yPk1ESIECFCTk2ECBEiRPoi3FEEAFAPaxQBAJRDTg0AgFIDAABKDQCwN78ZAoVInhIAXAtAqSM44+zf52/IX7v3uYHRyGtj70f7/qyP6F6ZHoY73jsWPXSm5c8zVhf0PzklfFJMqs/yc7kep9u8wXUh5j0GHkBEdj61SWnl9fr1wvsx+quU5ubbL+7V03L+iBryuIE6qJzUhNLmc3Gx7Zufd4NSw7N8Vb6dfF1+ZaBhphxNb7Vhz3hE3yoJtShfaLnK8dcAK1Y/3Pv/NiVt0ZqGpAoBelJXk33CrHkvRLiY0jU/u7ZYcLDvW5r0o4Zd6THCDbUO4WONAZ5Sapt9qHRd3p0qMacqxVUZfWcufP+YOeHjJFX5zdSFwz+F4l7Cll324e/FpNiJX7uYNNtSql7VKwC9OXWobmFyfeXdmSJDm0SOEtbo/c/T6h5jT/ueLId5bnjQvCDaRJ6bOS+XSMybv3MAbJVTh2lyVKxhe8JkecjlT5U43JwCNH+yoJOvae9b61QmKG7ZtMlVRpygaCs/tMs26LIVBlef8hc7nCpluGmjDaAhpzZBTXKKOKYS7WtWSSpJr2on3Cs6TWWhrN8lEsx8xKTVzSYi0dTS1rdjB92ds+83OaMlDltzRzEzYpY7iqCV60kCK+aYGlesDCG6Ls5lJz80ZKkN9YcDYY0iqADXU6AOAKAcHJqgXH8AgGfBoYlv3MA1hb2UWuJ2lHFoyqx8KbomSW4nSvpjZG5QxbOQ+Ez1cKZD0x5EzwWnJ+iix6HpM5HU0YX9TJlJ1R4r005tD+X510Dt0K9u2+A+eGXhEBrr1MWstlmqPjmFY96xVE1EIaEG2Kb6IV1NLhEpiYvTJ+WYBZNhuqfWoWm5PodH5xMI5in1MIemTDnCZi36vG1G+TrNVL23/uhcU7O6Q5POPgd/wBVPQgBQkVOHOiWRrfC+X9TXqS07npTgZ5ynlGTxizo0Gd19pp4De+bUlDJOYJJD06J9tog1DKXxjuLYFLWqtbYEOfXcxafOoi1Broqs69DkFPdZ3hPL8k6YkFObokNTWIdtq8wK2xFOoI7KZSbvlhwr3OY+oUW+13CZPsGhqeia9Hifo+NsyaxhJjg0aeRwh6b+I87uc0P7rFGELnBogtqqC30GQKkBAOANHJo0cs43ZWoCAOOVusGPSeLQ1HbzcG8OcWjCtwhAxGyHpugL4Wty6oFKfdT5AmzGeIcm0AYTxQBWZ8pqctCs2n8/a+MRhQ5NADB+NXnb6o8Vnxe+XEK9hNsRAIR8JXLqdlL+SjP2gua6xwy3IxfIukuk5FxmgDaltsH/XWLdZs3B7cR1sYHThb39A4AhSt1Y4kCsP5kgV0X0OzQBgJDpDk0ZbyP8S2tl+gSHJgCIwGpyhfz8pSennpfLzz5TAECpQZFSA4CEL4YA8lC7AECpYWJNQN7OkGNx4QBmIa9+1Lp2XLcN7/+uX3k/Zva6/6oYMQIXkehe2pRaUpRwpYiwteIGr/HKRxBrgM8odbVDkwmMmfKeTZJtUr5OVXtF+yPU8VWU2ojvKPYr9UuaixGUGkBF9SPUwXC6nverPOG8PUk3MjMCU/2paue0Sssoh9Xv72/EGmCqUotWk78UsChwDROlhS0fi0sXN8Yfy8WLGwDwFFMcmjzBVeW+NPUJ4jO7/b9kz+60tf9LtuWjE0CTUktdT1MqnMmOhYIo3Mxb7hj9rfBAC2Xxn0xwyaYBdsupwwduzS5l5GvQ0f6sjouZPs+T6XtODQAamDWfWnhP7/N6urSCz+h66jZgg0wPvDkJANGc2oyyPM2LozW2zdepzR+q7ejasO+PYrmrdpVDk+hY9j+Nvl5cqh2m2xSyAT4Evh8KYY0iAKDUAAArge8HAIB2fjMECrkqCZkbdJJtAGATPu/QFPXiyGwjb2c/pX4fJemWALBxTt0yn/o1bzo/e7rKAKRzm11hZjPAyTzs0ARCmWYoAVBq87hDE2S/TADA0WhxaIquavE+GFZ0VgIAGKjUDzs0UacGAEjx9f4Nu3pB+Wt9tqehQtMPAACoUurB9Is1zxYAAHjxgEOTMNLWzpZ4rkx8dgGcxq/Xspd/GAlNsEYRAN7AoQkAQDk4NAEAoNQAAIBSAwCco9ThUnIiRIgQIfJ8hJwaAEA71yw9b5WKNUSIECFCREXkbZYe3zWIECFCRGOEnJoIESJEyKmJECFChEhfhDuKAADqYTU5AIByyKkBAFBqAABAqQEAUGoAAFCj1Jc5fRwniKR2dIYHK1ZRuBbdbH81nPvv33IdLnZb/tvhp985pF7fHJog5z73o6wODWLtxsmDO0hyUOpOQZmnVh/uf/RXxQ3mnfsQpQ5fQEVOXUayoCa/+3B4qmCTTK81bOHnlvyTzK72F+Jcss/Xr6ztUnM9WN6/Mn63KKP3RreVb31303cb5HipyH3NjreNrWwZYsl1fuDvF9nFPihdfSR6uVIy/fPzcz0xMoxUJXQvdXj9+JK8e8RTEG8vSeTV4NV+UY5Tr3vk794HSQ+jfQjPtCrjDscHPlX9aCiDRLf0nrbtZC0Xqx+1LR9Z/XDZ16mIE2zTEHGyi1ObU4fSENYEUv+n0tKqiCeRYQ06WqMoFqkllY3UGRV7WDV68h6mxoc69eScOvrlufbrtE2nW53CSuLcWvcYO3L3ZDlzka3s6GHu/NQT2e+paCZnvH51FSuqSgH9mbW3e6aHVR94A8eQusdkpe6XaYlOuOz7G1bABldyj/dmWC5oEJ17gWK2ZnmVjal7wSQq7yh2yrSr36ZzvofdeY6gq4zkr5WrPLTLNuiC5Lrn+1LPHcUqlbm+lWfqy15yPSoJzVczvIN6PRQeV7JZw0l5GxTHECbn1G0ybQX39MJt7PudrPAb9f0dn+/Gprm5S3z3cDXDkxl4E9w2Ntkfi+3Y1pu7DXcU7zIaTpa4K4inJuGPxXZSLdcWAaLthLocpuFR7U5VbFKyG24T3Ss8VrSHqTGEdjb30lv2juKMnHrecWfTk1P3Z7UPX2Wnveerz15HqdXoGSskF1dqPZoIjCFKDQAAEXBoAgDQztsdxcKir+aJH6wSrKd2AV71t9Str0a4Us77Vp5aHxju5W2Zasc7etu0h/yyRjgaHJrUKvVcLdv6rzq/Ui7zq+LKveb7ewMn0sGB4NB0Ikc5NGU0cTO3I0Cpx4m1iZk+mNgMDZfw8UgZfchbhsqB94w7nGCv5kuakum7NIeReTQvI0y5f3i/5TMAJlQ/GsogODQpq34c4tDkeQBFI6mih8m6OEl8lIpGzHlnKAAPHJqoe0wZuccdmsJcOMyLhbKYX8co2QXg40qNQxPUXNIHHZqKhQsciGAVcGhaO0Guihzo0PQx04kqjzqAmTk1Dk36ZBqHpjYxTc2DNoJJzanJ2sX8PWw56iKNCx1EwKHpnJx63nFn8xmHps/k1AAodfaLOiyr1AAoNQ5NAACqwaEJAEA7ODQpBYemrrN71KGp2DfviNw/hDI4NKlV6rlatvVf9bMOTcK+pZYvAoTg0HQiODQZTQ5N5NRQV/2oEGubjUh0IjozOhO5m0d429jKliGWXOcH/n6RXeyD0tVHopcrJdP986mbZTRa96iqvZA4w2erHw1lEByalFU/cGhKVUjMOIemYoFF0g5AR05tcGjas+6BQ5OwOjGkWNFspgoo9adkWqITODStDw5NAKPAoWntBLkqgkPTxGsR2E+//pE1w8dzahya9Mk0Dk1tYjrboSksmJC2Qxc4NJ2TU8877mzWcmhClAGlbtIVHJoWV+rFxocBApQaAOA0cGgCANAODk1KwaGp6+wUOzRl+sxEEUiCQ5NapZ6rZVv/VWt2aJL0GcADh6YTwaHJaHJoAiiCQxOqLRp4HJqqxPraOKy9pOoq4V4ArdWPhjIIDk3Kqh84NKUqJOazDk2SIgxAa05tcGjas+6BQ1OmqcyPRbEGeEKpcWiCmkt6pkMT5QsYCw5NayfIVREcmiZeC1eIpzybyL5hdE6NQ5M+mcahqU1Mpzo03T8eip5N9425owhJcGg6J6eed9zZrOXQVPtbgOOV2uDQtINSLz9iDBmg1AAAe4NDEwCAdnBoUgoOTV1nt6BDU9WpdR632Q1qyNGhBRya1Cr13Df81n/VKzo0tZ1dPjijBWruj4BD04ng0GS2c2giz0Wph4q1iZk+mNgMDZfw8UgZfchbhsqB94w7nGCv5kuakum7NIeRqQpYWyu4O4TcgxLXkfxemSN27hX2+XpNEr1g9aOhDIJDk7LqBw5Nea0MU+kGh6aqKorEoano35Q/r2IPw43Dc6f68SA4NFH3mDJyhzs0hUsTJcfKC3TVl4DXC4nnCWyq1Dg0Qc0lPdOhSSL312SS1Irz1LwU4bF43NdO4NC0doJcFcGhaeK1cCO3jBYiatv3zn1sD0FxTo1Dkz6ZxqGpTUynOjTlPzDuGbSXUHvbZFyc7o+JSXk/hV8ait8wwnOPOv+RrT8ADk3n5NTzjjub1R2aPnBcyUwPQKl16xmz9BZXashLMCqMUgMAwMPg0AQAoB0cmpSCQ1NnQeDiWYcmbr7BGHBoUqvUc7Vs679qPQ5NVJBhCDg0nQgOTWY7hybYm/o1ijZ4o9v69S+pmdGZyN08wtvGVrYMseQ6P/D3i+xiH5SuPhK9XCmZ7p9P3ZgJ2HjdozaVTs1xzlRaAFqrHw1lEByalFU/cGhKVUjMOIemYoFFWHIBaM2pDQ5Ne9Y9cGjKNJX5cUjanuozQKtS49AENZcUhyaAfnBoWjtBrorg0DTxWrgB+zYUxIGcepBM49A0U6ZxaGoT06kOTdFp1yn3JRPcUaQGAhFwaDonp5533Nng0AQoNQ5NoF2pAVBqHJoAAFSDQxMAAEoNAAAoNQAASg0AACg1AACk+Re1n+/TbyIf6gAAAABJRU5ErkJggg==
override DIST_SCREENSHOT_v4.0		:= $(DIST_SCREENSHOT_v3.0)

# https://www.gnu.org/graphics/license-logos.html
# https://creativecommons.org/licenses/by-nc-nd
override EXT_ICON_GPL			:= iVBORw0KGgoAAAANSUhEUgAAAFQAAAAqCAYAAAAtQ3xwAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA3XAAAN1wFCKJt4AAAAB3RJTUUH4ggXESE6PZEx2AAADGZJREFUaN7lm3mQVcUVxn9vZlBQHEQnIIKCEVAWWRVQBBwOoqJCNGDFJYmoWUSMGEVxiUTjhqkkqNEYozHKppZoMBgXbFBMBAUiiyC7gqJBwiI7OvDyR3+X6bnet8FgkUpXvbrz7ut7u/v02b7v9KTI0Rxg/H835y+NgWbAMUBr4CBgNTAVmAJ8ZUAqzxceDlwJpPeD9e0Cir+huaSBg4ErgHoS4M3AZP1WCrwMzDA4jwIEehEwZj9RmHHAhfvw/dv1OVTfXweeBl40WJNBPguBvgaLS/Ic5ML9yAJH74P5pIENwHigC9ASmAucYrAlj+dfBwYAdxXloZ0p4JT9RJi70t5fVWebAjwArAMuAxoBPYC2uYTpKv9sDLyR0+SneIfVGFgEHAj8E3gb2JTh2ZR8TkegXN9HANsCTUhqBwIdgDOB+TKxNPBj4Oig31yDtq56/OcSYCzQWeMCTAJ6WwHBWEJdbVDfAVlNvtw/0EALHmNwCZX3ShKEud5gk4Na2vHtBsP0TF2gdsIwFQaf6ZnPgQkGd+qZO2N9/6XrKqDhXghzKFAfGB7cu8fgZldVWEV4we7Kkv1MBZ5UP4ryGPy7uk4NBvsUWBn7rMALDeBICXxeTOFXJnxu1O/18UKdowm3SJjLGzHBFtr+AfQBfghcH9wfbD56A9R08FPJbAWwysFJ8RdJi88D2hBsRD5B6Wxdp+klvTL02yTNAWiid78V7PSxGZ67L3imGFig799J6PuurtOBcwsMOrcBS4G/x3673+AhB0docwcBB8T6bIhrpvNx5Xl8SlkRuYeiHP6htgTxFbBctwdl6L7UYKf+7q3re7o2y2DuW81re9QHg/f1/eSE/isjX1qAMHcCTYETlXKF7R2DIQ7uAj4ChiQI8wHz/jbUzC6KJyead227Wy4NbaYB5hlscV6DjsvQt8TBLyT8S6n0L5E7JosJA5wWaHQJ0DZBy6Jg9D5Qkcf85+ItaiLQKeH3UQ4+lHUktRXAdU4Boqef2234uNDCYGE8eOWaUJ/YwmvhA1JSO0Gf3Qmy+SADcEGGZ0Ife1HgXg4N/HGYcEfBYR3whcyNLJtVDmwEDkn4/Uvg91meX2MxQTufdfST1l8C3BrPBIpypANR/vlUEDhK8zS1sXrPAVn855wgawCYpmvdBCFUBGa3EVifZezH5YM3ZBAmCaYdto3RnF2QuRs8aj4lPAK4zEE78hWofmstE458SAcFjsgEFyhvDD+RA4+c/2GxXDJsH+j6I+A/wGZ975Uhx40jpqT2hHnsPQeosweZwESDOikfZHebc6+qEX4LsJiETKQoi3amJIiVwNbAJ+/eRYNWEnpk7m2AmTLN9yT11WmolfA5qKY0FOiuoBdp4ZAkHx0T6h0Jfcab15x/C70UCj/PNWUPPb+OhuLfj9dayRmUFMkivLzcvJbGMX2J86xLTeAWgykKWk2kpZ9oV/rgBZ9OYCGKnTehnnIR6de80JonTKtmKFCDtPM+OPLb8wz6O7hHrqmQ9hYw0GCZ88GrXLn0Njy42ByTTStgg8GSQoLSAF3/pp2pE/OfBwfR+/PgfU0UbCqCPLNlHouaocmenMMNhSjlFQl0u0Eb58ceViAV+CZwPjDA+Tw13sZEwTMYdyJwVRI8Lclg8sXylxG+BTgjS0IfCbSN3rnUYJfzJGzTPBf3dOCnM7XGwPxgEa8KRnbVWNML1Mx3gDK8izgw4fe/APNcVe28FVhnXwcIWYPSYWJdtgDLdK9Thr7rA5O4MZYVHJMjmu5Ovs2Tt4hYydTaxvzYBcB95qFoF5HAhbSTpeFJwnzQYGBagpQwTxPBnJF9K8kQkE4I0E/kP0/K8I5VAZt0tnZyor73yHNhjwV/N88hgLFa3LeAniaEhfedKaqnmcHkGFFSX3xEO4MdWX1SPCAFPu/l4KcWSobDD8CbWmAj7fTC4JmOeS7gpeDvNgnjVITuQC5pWmQRzo/baS8J5mgejUJham2tFWR7G8xxWV5UkoNhWhHcq2cJ5LNVTsYSMo18iOmQJwAotVhG4HzEXQU0lzCbAjXMkxMA7fdSIz8BrjaY4KpmEhFunyZrmEIOnjSVxPEFBG5aDM+KHJG3g6J7kfLPxXiz+EGe5MVLgpbZNr6fQEVd8ZijDWZp3mVkqPfkaFuAQVbp8+NyGAw8CLQxBadcpHMqwYd2VrRcA4ySkE5XLplPmyCG//oElzJCuWzxXhDEPUSbfVsQMVr8c4Fl5WpTgZEGL5CBndf7OgPtzaO4vFpRFkLkj0rQG4jaGi9/Nk7ml1aOOjsGJZ8Xfn5EKdUoLfwePBAwLWiLiOJdQmPzldzvFGx9VXB0FFVrOz8RctsURF+Ai4EXNWY6Rqqs1Vg3AGXmN+UFEuCfgxbOj7vd4KhChJlk8ikFojOkCcsVjOaIH7gcuF1R+Ssl//cqn6utaN9Sadcs4FTgdxLuAQoi/XQvLW19TCDhrxJGX7mKZZrDwxLuiGCqzxh8L0MOXVe5ZQ1tzmaVZrYmlC/izz6sNXY1mOkSBJ6rxYNSDZn2l+Ic12qRBpxgMMN55NDC4C5F9iMFCysU1efhSwhTJNxPhajGqG8bmXs34eE78EWytQbjnBdib2l7bUG/oQmBjAyweX0OJop4Ec556PuQNrGRwZrJAZ4vpBXF8s9SOf2opIpQxOXqcw2ekL3TwaOCfi9oY0oULJqLLC4HPgOeFXfYPiCHDwcGShtnirSe66CrzHmY3nGwAMZZsXk3cXuYc8Zyy1LnLe8V4BqDc6Lg1nMPHXzc5FvHSN94rlbIIgrtX0jbLC3faAUIMtDIhnI1pwJXAc8ZbK2Oc1zxoDSokIyg0AyiGltt4P6QLMmljUBdB90VvRcAKwwOMXhqm/xrdRyKi2voTvIrLe8v7UOgo2XxmcLfvxWc/lhM/hITXK7u04WpYOASfHEt/T8izDRwFL7GHgGKCByUCmjUUk7sgFeCiuo+O6aZ4n+0ua/nj81RyaMIlpQHtfRvvL2enw/a5wLKZ9w39u0cUkl/76nJ3yACN7p3k/lS7Tcl0JRSrE8Mrs3Rt4F4yahguNhgZHVovPOwe7b5XLrwKB9ow93K9zoBLSNhRto7KabJrhq0+MmqyXYaX6zbmMej5Xjioqvw9uZ4h8kZ/na53UdnCtic8GzlpEgbnU+sF1pVjW0ismE2cJbB9c7Dvf5KOa5Tv65Kt3YAPzPYHOx2Gb5fU6Gva4Xdb8fXtkcHBEUDAYBn0lAz5QmZ6cLo4wxmBHN7HLjYPEKL7vUXJ3AO8IQAyXB81WCCVZ4TGCqy/D3z/EJ0Xmug5tQdqG2ww/m5dwEWmS994ODngtUDtJYHtJ51wLWRQEfjhTVcmHuMhHk3XlNvEYIaKoh2k/rXEHlxnzKEueYFETHqqwUhPwTONkjp+HQNkS1jTeSK8+M9hy9d/wpf3liHZ8oXmQcdkfC+EKR9TLzovc4TOEVCbA2VIi0VsdJHEf9VfJlkEnC19r0x8GeRPt2ALwxaO9+3G76udKU4i+ERMSMA1E0EznxZy3FFgQmtxe/U+WKXemoyZXppdG7pIj3zmtib7Vp8PZEgkVm9hi+otZKvm637xXhhTzOYHZhjO5n+x0qFXjYPOz/VhEP/WSomrC+VVdLGIk2OlBU1FHdwqhL5MmnfQZpvxHL9Seu4ROTOAilDb6C7eev7TNC5OZUFzNGSR0vxuV8Cm4qcF0Rd8YPl5hPgNP602hPmSY9jpbkPCmfXk99qIhz8S6CZwXgJrY5IlmfFsHcBZspPtZJbe95B6+Ak6xXAo67ylMnjYo6OJuAtteE7gDMNehj0c5Ul79/oeqk0dATQX5t6un4bKfLmEGl/sfiEMm3KbOD72tyZOqfaQG6kP77C+5G0e7n+kaGjYPCaIu1kTeCDwGE3wh/YmhQgkq2KrDdK9St0vy/+pMevA/hWoUXfIl9WS+THBdKWdtLslb38jpTIf42QFiE/FRUG5wfvPlFs0tZAyGdooVFWMlpJ/zBgpPOPTpdWDpMCnCILrMCXsFdKaaYr28B5K5gPTDF4Rv55hgJoWyqPa3aKZFWiesqZwNtBpNuoHZ2hALNJO3W8fl+mkxsm4RRTec4THX1sr2A0E+//FkkrBss83jVF5xqefTpLiyqWu1mnZ3pRtfD3BzzTFVJ4j0iDtmu+43Ro4TCNNVN+r60UaCcwy2C9Ds6WivPtIFe0zXlTPlqucJYODQ8JqMHBQWnoKikA/wUHHajBXXDysQAAAABJRU5ErkJggg==
override EXT_ICON_CC			:= iVBORw0KGgoAAAANSUhEUgAAAFgAAAAfCAMAAABUFvrSAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAAEZ0FNQQAAsY58+1GTAAAAAXNSR0IB2cksfwAAAdRQTFRF////////////////8fHx7+/v4+Pj39/f1tXV09bS0tXS0tXR0dTR0dTQ0NTQ0NPPz9PPztLOztHNzdHNzdHMz8/PzdDMzNDMzNDLzM/Ly8/Ly8/Ky87Kys3Jyc3Jyc3IyMzIyMzHx8vHxsrGxsrFxcnFyMfHxcnExMnExMjDw8jDxMfDw8fCwsfCwcXAwMXAwMW/wMS/v8S+v8O+vsO+vsK9vcK9vcK8v7+/vMG8vMG7vMC8u8C7u8C6ur+6ur+5ub65ub64uL23t7y2urm5tru1tbq0tLqztLmzs7iysrixsrexsbewsLavsLWvr7Wur7SusLOvrrStrrOtr7KvrbOsrLKrr6+vq7GqrKurpqqmo6ijoqahn6OenqCdn5+fnp2dmpiZlpmWlZmUk5iTkZSRkZORkY+Pj4+PiYyJjIqLh4aHhIaEhIWEgoWChIGCf4F+gICAfX98fH98fnt8en15eXx5eHV2dnN0dXJzcHJvcHBwaGdoaGVmZmRkYGBgXV5dWldYUFFQUFBQQ0RDQEBAPj8+Pzs8NTY1MjMxMjExMDAwMS0uKioqKSopKSkpKCkoKCUmIx8gICAgHxscGxsbGRkZEBAQDg4ODQ4NDQwNAAAA6kQJngAAAAN0Uk5TAAoO5yEBUwAAA61JREFUeNq1lo132lQYxqPvKKVdli11AiUry0Q7OmRduwmyVUqx2K6t1c62TN3qx0o33dR0WnGorHx009SBYJex55/13ARIQHo62el7yLknT3J/ufd573sv3Ks4lOA4IBGPRS4GR3zykOR2Ot2eU7LPHxyPTMYTs/MfLi0vryT/fwAcEvFo6ELA5/WIAt/ncPQdFcRBry8wGooy8uLS8kpXZA7xaOi8/4wk8vcKNTaJWuEuf8Ijnw2+E40nri4sXlte2SqxB6Uts9+BCjjEQuf9sktI7ZkG7a0LTu9wMDQZn5lbWPq6DBQzmSJQvmX0unWwAg6RC37ZyecAaFklHFayGoDcude8Z0cjsenZ+c+fIW8nIrLn8UzvdeMFFHC4GDjjYlxNsZERaxpQPueUA+MTU4m5ErJEBLAHKLNOZV3Z2G5XjM6GAg5BnyTkANVOzbCpQE7w+IKh2PQm8r0NMOWxlUxu4c8viTaePk/3NBX9HSN0hYFHTospQLURtZLXT3j9YxPxJ7B80Y5SMlnC35VHv0H5FtebSvs7DOzz8HvQTlJL2DTs8YO+4LsxFNl9FsZki0gmUfzl50qlku7pNRUiquhRVxhYHrgHKNQWa8BdUQ5ciiJDuhOGFxmGyRC9lQaQ7rUo9KsedYWBh44XoNmIwvliUTGa20SkoSCc8o9NdAYT9aR3K5Xt9y1KIxpgia+xaYb1FVxc1Zssm3ztqGd49EonK4joyBfUy6b+aH8r3P3AbSIVVXu4uqZCta9W13Qv+ty+YOQvIzHGgM1UbVd2d5G+/uM/TeV3PSzJczmAMOupGIC63WHA4XwjGPkBeWpfbnminu+fPt84YlX+s9wOAE89MQskYy2Hb7bblbrDjQIxrbCdrCoqVNaYVkx92m1J15NXz1ozeRnUeGl49MrUB5+VADWbUc0t50b5QEVfbjlo1Fxuq0W9oSoKwpB/7L34zPxHP3W1bcoDKd2LTgXy9qXJ6dmFpS4OEXB4Uy9p+34lnbjaLXjktHiz0yaUEr0j4xPxmbnFaytdgXFfEh4CqmUbsuvbpvTdSx3TAB64j1k3epuiAY951328LBibzmMP244m/vWvmu8Y9QHjMhTjIkKrQqaig7HpFm5aD9OU4DK5oPrPgmnc076KAcYDSeRTjeN/nRclqw+NbdP6KWr5kEVpA+OPTzwDx/l+h6OfF8TBj3eA9hG3gtkQqdUc6ggGdu5cltwul1u6fGenNQ+dRvyCHh/Gv8JXDon7L5TqCTEIrBaKAAAAAElFTkSuQmCC

########################################
## {{{2 Heredoc Function
########################################

override define DO_HEREDOC =
	$(if $(2),$(eval $(call COMPOSER_NOCOLOR))) \
	$(ECHO) '$(subst ',<Q>,$(subst $(call NEWLINE),<N>,$(call $(1),$(3))))<N>' \
		| $(SED) \
			-e "s|<Q>|\'|g" \
			-e "s|<N>|\\n|g" \
	$(if $(and $(2),$(COMPOSER_DOCOLOR)),$(eval $(call COMPOSER_COLOR)))
endef

########################################
## {{{2 Heredoc: gitattributes
########################################

override define HEREDOC_GITATTRIBUTES =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Git Attributes
################################################################################

########################################
# https://github.com/github/linguist/blob/master/docs/overrides.md

/**					linguist-vendored

/$(MAKEFILE)				!linguist-vendored
/$(call COMPOSER_CONV,,$(COMPOSER_ART))/				!linguist-vendored

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: gitignore
########################################

override define HEREDOC_GITIGNORE =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Git Exclusions
################################################################################

########################################
# $(COMPOSER_BASENAME)

#$(MARKER) **/$(COMPOSER_SETTINGS)
#$(MARKER) **/$(COMPOSER_YML)

**/$(COMPOSER_LOG_DEFAULT)
**/$(patsubst $(CURDIR)/%,%,$(COMPOSER_TMP))/

########################################
# $(UPGRADE)

/$(call COMPOSER_CONV,,$(COMPOSER_SRC))/
**/.git
**/node_modules/
$(foreach FILE,$(REPOSITORIES_LIST),\
$(if $($(FILE)_BIN),$(call NEWLINE)/$(call COMPOSER_CONV,,$($(FILE)_DIR))/$(notdir $($(FILE)_DIR))-*) \
)

########################################
# $(DEBUGIT) / $(TESTING)

/.$(COMPOSER_BASENAME)-*
/$(COMPOSER_BASENAME)-*

########################################
# $(EXPORTS)

$(call FIREBASE_IGNORE)

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: composer_mk **
########################################

########################################
### {{{3 Heredoc: composer_mk
########################################

override define HEREDOC_COMPOSER_MK =
$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)$(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration$(_D)
$(_S)################################################################################$(_D)
$(_N)ifneq$(_D) ($(_E)$$(COMPOSER_CURDIR)$(_D),)
$(_S)################################################################################$(_D)

$(_S)########################################$(_D)
$(_S)#$(_D) $(_H)Settings$(_D)

$(_N)override$(_D) $(_C)COMPOSER_SUBDIRS$(_D)		:= $(_M)$(NOTHING)$(_D)

$(_S)########################################$(_D)
$(_S)#$(_D) $(_H)Defaults$(_D)

$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_logo		:= $(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/logo-$(COMPOSER_LOGO_VER).png$(_D)
$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_icon		:= $(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/icon-$(COMPOSER_ICON_VER).png$(_D)
$(_M)$(OUT_README).$(_N)%$(_D): $(_E)override c_toc		:= $(SPECIAL_VAL)$(_D)

$(_S)########################################$(_D)
$(_S)#$(_D) $(_H)Files$(_D)

$(_N)override$(_D) $(_C)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D)		:= $(_M)$(call COMPOSER_CONV,,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT)$(_D)
$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D): $(_E)override c_site	:= 1$(_D)
$(_M)$(OUT_README).$(PUBLISH).$(EXTN_HTML)$(_D): $(_E)override c_toc	:=$(_D)

$(_N)override$(_D) $(_C)$(OUT_README).$(EXTN_LPDF)$(_D)			:= $(_M)$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)$(_D)

$(_N)override$(_D) $(_C)$(OUT_README).$(EXTN_PRES)$(_D)		:= $(_M)$(call COMPOSER_CONV,,$(COMPOSER_ART))/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)$(_D)
$(_M)$(OUT_README).$(EXTN_PRES)$(_D): $(_E)override c_toc	:=$(_D)

$(_S)################################################################################$(_D)
$(_N)endif$(_D)
$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)End Of File$(_D)
$(_S)################################################################################$(_D)
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH))
################################################################################

override COMPOSER_INCLUDE		:= 1

override c_site				:= 1
override c_logo				:= $(call COMPOSER_CONV,$$(COMPOSER_DIR)/,$(COMPOSER_IMAGES))/logo-$(COMPOSER_LOGO_VER).png
override c_icon				:= $(call COMPOSER_CONV,$$(COMPOSER_DIR)/,$(COMPOSER_IMAGES))/icon-$(COMPOSER_ICON_VER).png

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(EXAMPLE))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH_EXAMPLE =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(EXAMPLE))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override COMPOSER_IGNORES		:= $(notdir $(PUBLISH_INCLUDE))$(COMPOSER_EXT_DEFAULT)

########################################

$(notdir $(PUBLISH_INCLUDE)).$(EXTN_HTML):			$$(COMPOSER_ROOT)/$(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)/$(notdir $($(PUBLISH)-library-digest-src)))
$(notdir $(PUBLISH_EXAMPLE)).$(EXTN_HTML):				$(PUBLISH_EXAMPLE).yml

################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(NOTHING))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH_NOTHING =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(NOTHING))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override c_logo				:=
override c_icon				:=

################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(CONFIGS))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH_CONFIGS =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(CONFIGS))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override COMPOSER_IGNORES		:= $(notdir $(PUBLISH_INCLUDE_ALT))$(COMPOSER_EXT_DEFAULT)

########################################

$(notdir $(PUBLISH_INCLUDE_ALT)).$(EXTN_HTML):			$$(COMPOSER_ROOT)/$(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)/$(notdir $($(PUBLISH)-library-digest-src)))

################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(PANDOC_DIR))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH_PANDOC_DIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(PANDOC_DIR)))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override COMPOSER_IGNORES		:= .github

################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(BOOTSTRAP_DIR))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH_BOOTSTRAP_DIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(BOOTSTRAP_DIR)))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override COMPOSER_INCLUDE		:=
override COMPOSER_IGNORES		:=

override c_css				:= $(SPECIAL_VAL)

################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

override define HEREDOC_COMPOSER_MK_PUBLISH_BOOTSTRAP_TREE =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(BOOTSTRAP_DIR)))
################################################################################
#$(MARKER) ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override COMPOSER_IGNORES		:= *$(COMPOSER_EXT_DEFAULT) *.$(EXTN_HTML)

################################################################################
#$(MARKER) endif
################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(PUBLISH_PAGEDIR))
########################################

override define HEREDOC_COMPOSER_MK_PUBLISH_PAGEDIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(PUBLISH_PAGEDIR)))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################
################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_mk ($(PUBLISH) $(PUBLISH_SHOWDIR))
########################################

#> update: FILE.*CSS_THEMES

override define HEREDOC_COMPOSER_MK_PUBLISH_SHOWDIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) GNU Make Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(PUBLISH_SHOWDIR)))
################################################################################
ifneq ($$(COMPOSER_CURDIR),)
################################################################################

override COMPOSER_KEEPING		:= $(PUBLISH_KEEPING)

override COMPOSER_TARGETS		:= $(PUBLISH_INDEX).$(EXTN_HTML)
override COMPOSER_IGNORES		:= $(call COMPOSER_CONV,,$(COMPOSER_ART)) $(PUBLISH_INDEX).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)

################################################################################$(foreach FILE,$(call CSS_THEMES),\
	$(eval override FTYPE := $(word 1,$(subst ;, ,$(FILE)))) \
	$(eval override THEME := $(word 2,$(subst ;, ,$(FILE)))) \
	$(eval override SFILE := $(word 3,$(subst ;, ,$(FILE)))) \
	$(eval override OVRLY := $(word 4,$(subst ;, ,$(FILE)))) \
	$(eval override TITLE := $(word 5,$(subst ;, ,$(FILE)))) \
	$(eval override DEFLT := $(word 6,$(subst ;, ,$(FILE)))) \
	$(eval override FEXTN := $(if $(filter $(FTYPE),$(TYPE_PRES)),$(EXTN_PRES),$(EXTN_HTML))) \
	$(if $(filter-out $(TOKEN),$(OVRLY)),\
		$(call NEWLINE)$(call NEWLINE)$(call HEREDOC_COMPOSER_MK_PUBLISH_SHOWDIR_TARGET,$(FTYPE),$(THEME),$(OVRLY),$(FEXTN)) \
	) \
)

################################################################################
endif
################################################################################
# End Of File
################################################################################
endef

#> update: $(1).$(2)+$(3).$(4)
override define HEREDOC_COMPOSER_MK_PUBLISH_SHOWDIR_TARGET =
override COMPOSER_TARGETS += $(1).$(2)+$(3).$(4)
override $(1).$(2)+$(3).$(4) := $(PUBLISH_INDEX)$(if $(filter $(TYPE_PRES),$(1)),.$(TYPE_PRES))$(COMPOSER_EXT_DEFAULT)
$(1).$(2)+$(3).$(4): override c_css := $(1).$(2)
endef

########################################
## {{{2 Heredoc: composer_yml **
########################################

########################################
### {{{3 Heredoc: composer_yml
########################################

#> update: $(PUBLISH) Pages

override define HEREDOC_COMPOSER_YML =
$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)$(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration$(_D)
$(_S)################################################################################$(_D)

$(_H)variables$(_D):

$(_S)########################################$(_D)
$(_S)#$(_D) $(_H)$(PUBLISH)$(_D)

  $(_C)title-prefix$(_D):				$(_M)EXAMPLE SITE$(_D)

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-config$(_D):

    $(_C)homepage$(_D):				$(_M)$(COMPOSER_HOMEPAGE)$(_D)
    $(_C)brand$(_D):				$(_M)LOGO / BRAND$(_D)
$(_S)#$(MARKER)$(_D) $(_C)copyright$(_D):				$(_M)COPYRIGHT$(_D)
    $(_C)copyright$(_D): $(_N)|$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon gpl$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon cc-by-nc-nd$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon copyright$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_M)COPYRIGHT$(_D)
$(_S)#$(MARKER)$(_D) $(_C)$(COMPOSER_TINYNAME)$(_D):				$(_M)$(PUBLISH_COMPOSER)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)search_name$(_D):			$(_M)SEARCH$(_D)
    $(_C)search_name$(_D): $(_N)|$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon search$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
    $(_C)search_site$(_D):			$(_M)https://duckduckgo.com$(_D)
    $(_C)search_call$(_D):			$(_M)q$(_D)
    $(_C)search_form$(_D): $(_N)|$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)sites $(COMPOSER_CNAME)$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)ia web$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)kae d$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)ko 1$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)kp -1$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)kv 1$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
      $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)form$(_D) $(_M)kz -1$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)header$(_D):				$(_M)$(PUBLISH_HEADER)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)footer$(_D):				$(_M)$(PUBLISH_FOOTER)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)css_overlay$(_D):			$(_M)$(PUBLISH_CSS_OVERLAY)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)copy_protect$(_D):			$(_M)$(PUBLISH_COPY_PROTECT)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)cols_break$(_D):				$(_M)$(PUBLISH_COLS_BREAK)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)cols_sticky$(_D):			$(_N)[$(_D) $(_M)$(PUBLISH_COLS_STICKY_L)$(_N),$(_D) $(_M)$(PUBLISH_COLS_STICKY_C)$(_N),$(_D) $(_M)$(PUBLISH_COLS_STICKY_R)$(_D) $(_N)]$(_D)
$(_S)#$(MARKER)$(_D) $(_C)cols_resticky$(_D):			$(_N)[$(_D) $(_M)$(PUBLISH_COLS_RESTICKY_L)$(_N),$(_D) $(_M)$(PUBLISH_COLS_RESTICKY_C)$(_N),$(_D) $(_M)$(PUBLISH_COLS_RESTICKY_R)$(_D) $(_N)]$(_D)
$(_S)#$(MARKER)$(_D) $(_C)cols_order$(_D):				$(_N)[$(_D) $(_M)$(PUBLISH_COLS_ORDER_L)$(_N),$(_D) $(_M)$(PUBLISH_COLS_ORDER_C)$(_N),$(_D) $(_M)$(PUBLISH_COLS_ORDER_R)$(_D) $(_N)]$(_D)
$(_S)#$(MARKER)$(_D) $(_C)cols_reorder$(_D):			$(_N)[$(_D) $(_M)$(PUBLISH_COLS_REORDER_L)$(_N),$(_D) $(_M)$(PUBLISH_COLS_REORDER_C)$(_N),$(_D) $(_M)$(PUBLISH_COLS_REORDER_R)$(_D) $(_N)]$(_D)
$(_S)#$(MARKER)$(_D) $(_C)cols_size$(_D):				$(_N)[$(_D) $(_M)$(PUBLISH_COLS_SIZE_L)$(_N),$(_D) $(_M)$(PUBLISH_COLS_SIZE_C)$(_N),$(_D) $(_M)$(PUBLISH_COLS_SIZE_R)$(_D) $(_N)]$(_D)
$(_S)#$(MARKER)$(_D) $(_C)cols_resize$(_D):			$(_N)[$(_D) $(_M)$(PUBLISH_COLS_RESIZE_L)$(_N),$(_D) $(_M)$(PUBLISH_COLS_RESIZE_C)$(_N),$(_D) $(_M)$(PUBLISH_COLS_RESIZE_R)$(_D) $(_N)]$(_D)

$(_S)#$(MARKER)$(_D) $(_C)metainfo$(_D):				$(_N)"$(_M)$(subst <|>,$(_N)<|>$(_M),$(PUBLISH_METAINFO))$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)metainfo_null$(_D):			$(_N)"$(_M)$(PUBLISH_METAINFO_NULL)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)metalist$(_D):
$(_S)#$(MARKER)$(_D)   $(_M)$(PUBLISH_CREATORS)$(_D):
$(_S)#$(MARKER)$(_D)     $(_C)title$(_D):				$(_N)"$(_M)$(PUBLISH_CREATORS_TITLE)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D)     $(_C)display$(_D):			$(_N)"$(_M)$(subst <|>,$(_N)<|>$(_M),$(PUBLISH_CREATORS_PRINT))$(_N)"$(_D)
$(_S)#$(MARKER)$(_D)   $(_M)$(PUBLISH_METALIST)$(_D):
$(_S)#$(MARKER)$(_D)     $(_C)title$(_D):				$(_N)"$(_M)$(PUBLISH_METALIST_TITLE)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D)     $(_C)display$(_D):			$(_N)"$(_M)$(subst <|>,$(_N)<|>$(_M),$(PUBLISH_METALIST_PRINT))$(_N)"$(_D)

$(_S)#$(MARKER)$(_D) $(_C)readtime$(_D):				$(_N)"$(_M)$(subst <|>,$(_N)<|>$(_M),$(PUBLISH_READTIME))$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)readtime_wpm$(_D):			$(_M)$(PUBLISH_READTIME_WPM)$(_D)

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-library$(_D):

    $(_C)folder$(_D):				$(_S)#$(MARKER)$(_D) $(_M)$(LIBRARY_FOLDER)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)auto_update$(_D):			$(_M)$(LIBRARY_AUTO_UPDATE)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)append$(_D):				$(_M)$(LIBRARY_APPEND)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)digest_title$(_D):			$(_N)"$(_M)$(LIBRARY_DIGEST_TITLE)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)digest_continue$(_D):			$(_N)"$(_M)$(LIBRARY_DIGEST_CONTINUE)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)digest_permalink$(_D):			$(_N)"$(_M)$(LIBRARY_DIGEST_PERMALINK)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)digest_chars$(_D):			$(_M)$(LIBRARY_DIGEST_CHARS)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)digest_count$(_D):			$(_M)$(LIBRARY_DIGEST_COUNT)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)digest_expanded$(_D):			$(_M)$(LIBRARY_DIGEST_EXPANDED)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)digest_spacer$(_D):			$(_M)$(LIBRARY_DIGEST_SPACER)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)lists_expanded$(_D):			$(_M)$(LIBRARY_LISTS_EXPANDED)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)lists_spacer$(_D):			$(_M)$(LIBRARY_LISTS_SPACER)$(_D)

$(_S)#$(MARKER)$(_D) $(_C)sitemap_title$(_D):			$(_N)"$(_M)$(LIBRARY_SITEMAP_TITLE)$(_N)"$(_D)
$(_S)#$(MARKER)$(_D) $(_C)sitemap_expanded$(_D):			$(_M)$(LIBRARY_SITEMAP_EXPANDED)$(_D)
$(_S)#$(MARKER)$(_D) $(_C)sitemap_spacer$(_D):			$(_M)$(LIBRARY_SITEMAP_SPACER)$(_D)

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-nav-top$(_D):

    $(_M)MENU$(_D):
      - $(_M)MAIN$(_D):				$(_E)$(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES))$(_D)
      - $(_M)PAGES$(_D):
        - $(_M)$(COMPOSER_BASENAME) $(OUT_README)$(_D):		$(_E)$(PUBLISH_OUT_README)$(_D)
        - $(_C)spacer$(_D)
        - $(_M)$(PUBLISH_PAGE_1_NAME)$(_D):
          - $(_C)$(MENU_SELF)$(_D):				$(_E)$(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES))$(_D)
          - $(_M)$(PUBLISH_PAGE_2_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(word 2,$(PUBLISH_FILES))$(_D)
          - $(_M)$(PUBLISH_PAGE_3_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(word 3,$(PUBLISH_FILES))$(_D)
          - $(_M)$(PUBLISH_PAGE_4_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(word 4,$(PUBLISH_FILES))$(_D)
          - $(_M)$(PUBLISH_PAGE_5_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(word 5,$(PUBLISH_FILES))$(_D)
        - $(_M)$(PUBLISH_PAGE_EXAMPLE_NAME)$(_D):
          - $(_C)$(MENU_SELF)$(_D):				$(_E)$(PUBLISH_CMD_ROOT)/$(PUBLISH_EXAMPLE).$(EXTN_HTML)$(_D)
          - $(_M)$(PUBLISH_PAGE_PAGEDIR_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(PUBLISH_PAGEDIR).$(EXTN_HTML)$(_D)
          - $(_M)$(PUBLISH_PAGE_TESTING_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(PUBLISH_TESTING).$(EXTN_HTML)$(_D)
          - $(_M)$(PUBLISH_PAGE_SHOWDIR_NAME)$(_D):		$(_E)$(PUBLISH_CMD_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX).$(EXTN_HTML)$(_D)
        - $(_M)$(PUBLISH_PAGE_LIBRARY_NAME)$(_D):
          - $(_C)$(MENU_SELF)$(_D):				$(_E)$(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest))))$(_D)
          - $(_M)$(PUBLISH_PAGE_LIBRARY_ALT_NAME)$(_D):	$(_E)$(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-digest))))$(_D)
$(_S)#$(MARKER)$(_D)       - $(_M)$(PUBLISH_PAGE_INCLUDE_NAME)$(_D):	$(_E)$(PUBLISH_CMD_ROOT)/$(PUBLISH_INCLUDE).$(EXTN_HTML)$(_D)
$(_S)#$(MARKER)$(_D)       - $(_M)$(PUBLISH_PAGE_INCLUDE_ALT_NAME)$(_D):	$(_E)$(PUBLISH_CMD_ROOT)/$(PUBLISH_INCLUDE_ALT).$(EXTN_HTML)$(_D)
    $(_M)CONTENTS$(_D):
      - $(_M)CONTENTS$(_D):
        - $(_C)contents$(_D)
$(_S)#$(MARKER)$(_D)     - $(_C)contents$(_D) $(_M)$(DEPTH_MAX)$(_D)
$(_S)#$(MARKER)$(_D)     - $(_C)contents$(_D) $(_M)$(SPECIAL_VAL)$(_D)
    $(_M)SPACE$(_D):
      - $(_C)spacer$(_D)
    $(_M)LIBRARY$(_D):
      - $(_M)DATES$(_D):
        - $(_C)library$(_D) $(_M)date$(_D)
      - $(_M)AUTHORS$(_D):
        - $(_C)library$(_D) $(_M)$(PUBLISH_CREATORS)$(_D)
      - $(_M)TAGS$(_D):
        - $(_C)library$(_D) $(_M)$(PUBLISH_METALIST)$(_D)

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-nav-bottom$(_D):

    $(_M)PATH$(_D):
      - $(_M)SITEMAP$(_D):			$(_E)$(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-sitemap))))$(_D)
    $(_M)INFO$(_D):
      - $(_C)metalist$(_D) $(_M)$(PUBLISH_CREATORS)$(_D)
      - $(_C)metalist$(_D) $(_M)$(PUBLISH_METALIST)$(_D)

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-nav-left$(_D):

    $(_M)BEGIN$(_D):
    $(_M)MENU$(_D):
      - $(_C)fold-begin$(_D) $(_M)$(SPECIAL_VAL) . $(SPECIAL_VAL) LEFT FOLD$(_D)
      - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
          * ITEM 1
          * ITEM 2
          * ITEM 3
      - $(_C)fold-end$(_D)
    $(_M)MIDDLE$(_D):
      - $(_C)spacer$(_D)
    $(_M)TEXT$(_D):
      - $(_C)box-begin$(_D) $(_M)$(SPECIAL_VAL) LEFT BOX$(_D)
      - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
          LEFT TEXT
      - $(_C)box-end$(_D)
    $(_M)SPACE$(_D):
      - $(_C)spacer$(_D)
    $(_M)CONTENTS$(_D):
      - $(_C)box-begin$(_D) $(_M)$(SPECIAL_VAL) CONTENTS$(_D)
      - $(_C)metainfo$(_D)
      - $(_C)contents$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)contents$(_D) $(_M)$(DEPTH_MAX)$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)contents$(_D) $(_M)$(SPECIAL_VAL)$(_D)
      - $(_C)metalist$(_D) $(_M)$(PUBLISH_CREATORS)$(_D)
      - $(_C)metalist$(_D) $(_M)$(PUBLISH_METALIST)$(_D)
      - $(_C)readtime$(_D)
      - $(_C)box-end$(_D)
    $(_M)END$(_D):

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-nav-right$(_D):

    $(_M)BEGIN$(_D):
    $(_M)MENU$(_D):
      - $(_C)fold-begin$(_D) $(_M)$(SPECIAL_VAL) . $(SPECIAL_VAL) RIGHT FOLD$(_D)
      - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
          * ITEM 1
          * ITEM 2
          * ITEM 3
      - $(_C)fold-end$(_D)
    $(_M)MIDDLE$(_D):
      - $(_C)spacer$(_D)
    $(_M)TEXT$(_D):
      - $(_C)box-begin$(_D) $(_M)$(SPECIAL_VAL) RIGHT BOX$(_D)
      - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
          RIGHT TEXT
      - $(_C)box-end$(_D)
    $(_M)SPACE$(_D):
      - $(_C)spacer$(_D)
    $(_M)LIBRARY$(_D):
      - $(_C)fold-begin group$(_D) $(_M)fold-library$(_D)
      - $(_C)fold-begin$(_D) $(_M)$(SPECIAL_VAL) $(SPECIAL_VAL) fold-library DATES$(_D)
      - $(_C)library$(_D) $(_M)date$(_D)
      - $(_C)fold-end$(_D)
      - $(_C)fold-begin$(_D) $(_M)$(SPECIAL_VAL) $(SPECIAL_VAL) fold-library AUTHORS$(_D)
      - $(_C)library$(_D) $(_M)$(PUBLISH_CREATORS)$(_D)
      - $(_C)fold-end$(_D)
      - $(_C)fold-begin$(_D) $(_M)$(SPECIAL_VAL) . fold-library TAGS$(_D)
      - $(_C)library$(_D) $(_M)$(PUBLISH_METALIST)$(_D)
      - $(_C)fold-end$(_D)
      - $(_C)fold-end group$(_D)
    $(_M)END$(_D):

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-info-top$(_D):

    $(_M)TEXT$(_D):
      - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
          TOP TEXT
    $(_M)INFO$(_D):
$(_S)#$(MARKER)$(_D)   - $(_C)metainfo$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)metalist$(_D) $(_M)$(PUBLISH_CREATORS)$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)metalist$(_D) $(_M)$(PUBLISH_METALIST)$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)readtime$(_D)
    $(_M)ICON$(_D):
      - $(_C)icon github$(_D) $(_M)$(COMPOSER_REPOPAGE) $(COMPOSER_TECHNAME)$(_D)
$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),   ,$(_S)#$(MARKER)$(_D))   - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),   ,$(_S)#$(MARKER)$(_D))       $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon gpl$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),   ,$(_S)#$(MARKER)$(_D))       $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon cc-by-nc-nd$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)
$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),   ,$(_S)#$(MARKER)$(_D))       $(_N)$(PUBLISH_CMD_BEG)$(_D) $(_C)icon copyright$(_D) $(_N)$(PUBLISH_CMD_END)$(_D)

$(_S)########################################$(_D)
  $(_H)$(PUBLISH)-info-bottom$(_D):

    $(_M)TEXT$(_D):
      - $(_C)$(MENU_SELF)$(_D): $(_N)|$(_D)
          BOTTOM TEXT
    $(_M)INFO$(_D):
$(_S)#$(MARKER)$(_D)   - $(_C)metainfo$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)metalist$(_D) $(_M)$(PUBLISH_CREATORS)$(_D)
$(_S)#$(MARKER)$(_D)   - $(_C)metalist$(_D) $(_M)$(PUBLISH_METALIST)$(_D)
      - $(_C)readtime$(_D)
    $(_M)ICON$(_D):

$(_S)################################################################################$(_D)
$(_S)#$(_D) $(_H)End Of File$(_D)
$(_S)################################################################################$(_D)
endef

########################################
### {{{3 Heredoc: composer_yml ($(OUT_README))
########################################

override define HEREDOC_COMPOSER_YML_README =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(OUT_README))
################################################################################

variables:

########################################

  $(PUBLISH)-config:

    homepage:				$(COMPOSER_HOMEPAGE)
    brand:				$(COMPOSER_TECHNAME)
    copyright: |
      $(PUBLISH_CMD_BEG) icon gpl $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT) $(PUBLISH_CMD_END)
      $(COPYRIGHT_SHORT)

    cols_break:				md
    cols_size:				[ 4, 8, $(SPECIAL_VAL) ]
    cols_resize:			[ $(SPECIAL_VAL), 12, $(SPECIAL_VAL) ]

########################################

  $(PUBLISH)-nav-top:
    MENU:
      - Top: $(OUT_README).$(PUBLISH).$(EXTN_HTML)
      - Formats:
        - Example Website: $(notdir $(PUBLISH_ROOT))/$(word 1,$(PUBLISH_FILES))
        - spacer$(foreach FILE,$(COMPOSER_TARGETS),$(call NEWLINE)        - $(FILE): $(FILE))
    SPACE:
      - spacer
    CONTENTS:
      - contents

  $(PUBLISH)-nav-left:
    MENU:
      - box-begin $(SPECIAL_VAL) Formats
      - $(MENU_SELF): |
          * [Example Website]($(notdir $(PUBLISH_ROOT))/$(word 1,$(PUBLISH_FILES)))
      - spacer
      - $(MENU_SELF): |$(foreach FILE,$(COMPOSER_TARGETS),$(call NEWLINE)          * [$(FILE)]($(FILE)))
      - box-end
    SPACE:
      - spacer
    CONTENTS:
      - box-begin $(SPECIAL_VAL) Contents
      - contents
      - box-end
    TAGLINE:
      - $(MENU_SELF): "$(COMPOSER_TAGLINE)"

  $(PUBLISH)-info-top:
    ICON:
      - icon github $(COMPOSER_REPOPAGE) $(COMPOSER_TECHNAME)

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(LIBRARY_FOLDER))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_LIBRARY =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(PUBLISH_LIBRARY))
################################################################################

variables:

########################################

  $(PUBLISH)-config:
    header:				$(1)
    footer:				null

########################################

  $(PUBLISH)-nav-top:
    CONTENTS:
      - CONTENTS:
        - contents $(SPECIAL_VAL)

  $(PUBLISH)-nav-left:
    CONTENTS:
      - box-begin $(SPECIAL_VAL) CONTENTS
      - contents $(SPECIAL_VAL)
      - box-end

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(TESTING))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_TESTING =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(TESTING))
################################################################################

variables:

########################################

  site-nav-top:
    CONTENTS:				null
    LIBRARY:				null

  site-nav-bottom:
    INFO:				null

  site-nav-left:
    CONTENTS:				null
    LIBRARY:				null

  site-nav-right:
    CONTENTS:				null
    LIBRARY:				null

  site-info-top:
    INFO:				null

  site-info-bottom:
    INFO:				null

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(EXAMPLE))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_EXAMPLE =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(EXAMPLE))
################################################################################

variables:

########################################

  $(PUBLISH)-library:
    folder:				$(PUBLISH_LIBRARY)
    auto_update:			$(if $(COMPOSER_DEBUGIT),null,$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(LIBRARY_AUTO_UPDATE_ALT),$(LIBRARY_AUTO_UPDATE)))

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(NOTHING))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_NOTHING =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(NOTHING))
################################################################################

$(call COMPOSER_YML_DATA_SKEL)

#>metalist: {
#>$(subst $(NEWLINE),$(NEWLINE)#>,$(call COMPOSER_YML_DATA_METALIST_SKEL))
#>}

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(CONFIGS))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_CONFIGS =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(CONFIGS))
################################################################################

variables:

########################################

  $(PUBLISH)-config:
    $(COMPOSER_TINYNAME):				$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COMPOSER_MOD),$(PUBLISH_COMPOSER_ALT))
    header:				$(PUBLISH_HEADER_ALT)
    footer:				$(PUBLISH_FOOTER_ALT)
    css_overlay:			$(PUBLISH_CSS_OVERLAY_ALT)
    copy_protect:			$(PUBLISH_COPY_PROTECT_ALT)
    cols_break:				$(PUBLISH_COLS_BREAK_ALT)
    cols_sticky:			[ $(PUBLISH_COLS_STICKY_L_ALT), $(PUBLISH_COLS_STICKY_C_ALT), $(PUBLISH_COLS_STICKY_R_ALT) ]
    cols_resticky:			[ $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_RESTICKY_L_MOD),$(PUBLISH_COLS_RESTICKY_L_ALT)), $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_RESTICKY_C_MOD),$(PUBLISH_COLS_RESTICKY_C_ALT)), $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_RESTICKY_R_MOD),$(PUBLISH_COLS_RESTICKY_R_ALT)) ]
    cols_order:				[ $(PUBLISH_COLS_ORDER_L_ALT), $(PUBLISH_COLS_ORDER_C_ALT), $(PUBLISH_COLS_ORDER_R_ALT) ]
    cols_reorder:			[ $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_REORDER_L_MOD),$(PUBLISH_COLS_REORDER_L_ALT)), $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_REORDER_C_MOD),$(PUBLISH_COLS_REORDER_C_ALT)), $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_REORDER_R_MOD),$(PUBLISH_COLS_REORDER_R_ALT)) ]
    cols_size:				[ $(PUBLISH_COLS_SIZE_L_ALT), $(PUBLISH_COLS_SIZE_C_ALT), $(PUBLISH_COLS_SIZE_R_ALT) ]
    cols_resize:			[ $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_RESIZE_L_MOD),$(PUBLISH_COLS_RESIZE_L_ALT)), $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_RESIZE_C_MOD),$(PUBLISH_COLS_RESIZE_C_ALT)), $(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_COLS_RESIZE_R_MOD),$(PUBLISH_COLS_RESIZE_R_ALT)) ]
    metainfo:				"$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_METAINFO_MOD),$(PUBLISH_METAINFO_ALT))"
    metainfo_null:			"$(PUBLISH_METAINFO_NULL_ALT)"
    metalist:
      $(PUBLISH_CREATORS):
        title:				"$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_CREATORS_TITLE_MOD),$(PUBLISH_CREATORS_TITLE_ALT))"
        display:			"$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_CREATORS_PRINT_MOD),$(PUBLISH_CREATORS_PRINT_ALT))"
      $(PUBLISH_METALIST):
        title:				"$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_METALIST_TITLE_MOD),$(PUBLISH_METALIST_TITLE_ALT))"
        display:			"$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(PUBLISH_METALIST_PRINT_MOD),$(PUBLISH_METALIST_PRINT_ALT))"
    readtime:				"$(PUBLISH_READTIME_ALT)"
    readtime_wpm:			$(PUBLISH_READTIME_WPM_ALT)

########################################

  $(PUBLISH)-library:
    folder:				$(PUBLISH_LIBRARY_ALT)
    auto_update:			$(if $(COMPOSER_DEBUGIT),null,$(LIBRARY_AUTO_UPDATE_ALT))
    append:				$(LIBRARY_APPEND_ALT)
    digest_title:			"$(LIBRARY_DIGEST_TITLE_ALT)"
    digest_continue:			"$(LIBRARY_DIGEST_CONTINUE_ALT)"
    digest_permalink:			"$(LIBRARY_DIGEST_PERMALINK_ALT)"
    digest_chars:			$(LIBRARY_DIGEST_CHARS_ALT)
    digest_count:			$(LIBRARY_DIGEST_COUNT_ALT)
    digest_expanded:			$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(LIBRARY_DIGEST_EXPANDED_MOD),$(LIBRARY_DIGEST_EXPANDED_ALT))
    digest_spacer:			$(LIBRARY_DIGEST_SPACER_ALT)
    lists_expanded:			$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(LIBRARY_LISTS_EXPANDED_MOD),$(LIBRARY_LISTS_EXPANDED_ALT))
    lists_spacer:			$(LIBRARY_LISTS_SPACER_ALT)
    sitemap_title:			"$(LIBRARY_SITEMAP_TITLE_ALT)"
    sitemap_expanded:			$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),$(LIBRARY_SITEMAP_EXPANDED_MOD),$(LIBRARY_SITEMAP_EXPANDED_ALT))
    sitemap_spacer:			$(LIBRARY_SITEMAP_SPACER_ALT)

########################################

  $(PUBLISH)-nav-top:
    LIBRARY:				null
    CHAINED:
      - CHAINED:
        - CHAINING:			$(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES))

  $(PUBLISH)-nav-bottom:
    PATH:
      - SITEMAP:			$(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)/$(notdir $(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-sitemap))))
    CHAINED:
      - CHAINED:			$(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES))

  $(PUBLISH)-nav-left:
    BEGIN:
      - row-begin
      - column-begin col-$(PUBLISH_COLS_BREAK_ALT)-2 col-6
    MIDDLE:
      - column-end
      - column-begin col-$(PUBLISH_COLS_BREAK_ALT)-2 col-6
    SPACE:
      - column-end
      - column-begin col-$(PUBLISH_COLS_BREAK_ALT)-6 col-10
    END:
      - column-end
      - row-end
    CHAINED:
      - $(MENU_SELF): '[CHAINED]($(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES)))'

  $(PUBLISH)-nav-right:
    BEGIN:
      - row-begin
      - column-begin col-$(PUBLISH_COLS_BREAK_ALT)-12 col-6
    MIDDLE:
      - spacer
    SPACE:
      - column-end
      - column-begin col-$(PUBLISH_COLS_BREAK_ALT)-12 col-6
    END:
      - column-end
      - row-end
    CHAINED:
      - $(MENU_SELF): '[CHAINED]($(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES)))'

  $(PUBLISH)-info-top:
    CHAINED:
      - $(MENU_SELF): '[CHAINED]($(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES)))'

  $(PUBLISH)-info-bottom:
    CHAINED:
      - $(MENU_SELF): '[CHAINED]($(PUBLISH_CMD_ROOT)/$(word 1,$(PUBLISH_FILES)))'

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(PANDOC_DIR))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_PANDOC_DIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(PANDOC_DIR)))
################################################################################

variables:

########################################

  $(PUBLISH)-config:
    header:				$(PUBLISH_CMD_ROOT)/$(word 4,$(PUBLISH_DIRS))/$(PUBLISH_FILE_HEADER)

########################################

  $(PUBLISH)-nav-top:
    CONTENTS:
      - CONTENTS:
        - contents 2

  $(PUBLISH)-nav-left:
    CONTENTS:
      - box-begin $(SPECIAL_VAL) CONTENTS
#$(MARKER)   - metainfo
      - contents 3
      - metalist $(PUBLISH_CREATORS)
      - metalist $(PUBLISH_METALIST)
      - readtime
      - box-end

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) $(BOOTSTRAP_DIR))
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_BOOTSTRAP_DIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(BOOTSTRAP_DIR)))
################################################################################

variables:

########################################

  $(PUBLISH)-config:
    header:				$(PUBLISH_CMD_ROOT)/$(word 5,$(PUBLISH_DIRS))/$(PUBLISH_FILE_HEADER)
    css_overlay:			null

################################################################################
# End Of File
################################################################################
endef

override define HEREDOC_COMPOSER_YML_PUBLISH_BOOTSTRAP_TREE =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) $(notdir $(BOOTSTRAP_DIR)))
################################################################################

variables: {}

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) pages)
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_PAGEDIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) pages)
################################################################################

variables: {}

################################################################################
# End Of File
################################################################################
endef

########################################
### {{{3 Heredoc: composer_yml ($(PUBLISH) themes)
########################################

override define HEREDOC_COMPOSER_YML_PUBLISH_SHOWDIR =
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) YAML Configuration ($(PUBLISH) $(DIVIDE) themes$(if $(1), $(MARKER) $(1)))
################################################################################

variables:

########################################

  $(PUBLISH)-config:
    css_overlay:			$(if $(1),$(1),$(PUBLISH_CSS_OVERLAY))

################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: custom_$(PUBLISH)_sh
########################################

override define HEREDOC_CUSTOM_PUBLISH_SH =
#!$(BASH)
# $(patsubst filetype=%,filetype=sh,$(patsubst foldlevel=%,foldlevel=2,$(subst \,\\,$(VIM_OPTIONS))))
################################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) $(notdir $(CUSTOM_PUBLISH_SH))
################################################################################

set -e

########################################
### {{{3 Globals
########################################
$(foreach FILE,$(PUBLISH_SH_GLOBAL),$(call NEWLINE)$(if $(filter $(TOKEN),$(FILE)),,$(FILE)="$($(FILE))"))

########################################
### {{{3 Variables
########################################
$(foreach FILE,$(PUBLISH_SH_LOCAL),$(call NEWLINE)$(if $(filter $(TOKEN),$(FILE)),,$(FILE)="$${$(FILE)}"))

################################################################################
### {{{3 Functions (Global)
################################################################################

########################################
#### {{{4 COMPOSER_YML_DATA_VAL
########################################

# 1 option

#>		| $${YQ_WRITE} ".variables.$(PUBLISH)-$${@}" 2>/dev/null
function COMPOSER_YML_DATA_VAL {
	$${ECHO} "$${COMPOSER_YML_DATA}" \\
		| $${YQ_WRITE} ".variables.$(PUBLISH)-$${@}" \\
		| $${SED} "/^null$$/d"
	return 0
}

########################################
#### {{{4 $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT
########################################

# 1 text

#> update: $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT
function $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT {
	$${ECHO} "$${@}" \\
	| $${TR} 'A-Z' 'a-z' \\
	| $${SED} \\
		-e "s|-|DASH|g" \\
		-e "s|_|UNDER|g" \\
	| $${SED} \\
		-e "s|[[:punct:]]||g" \\
		-e "s|[[:space:]]|-|g" \\
	| $${SED} \\
		-e "s|DASH|-|g" \\
		-e "s|UNDER|_|g"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-marker
########################################

# 1 name
# 2 action
# 3 text
#
function $(PUBLISH)-marker {
	$${ECHO} "<!-- $${1} $${DIVIDE} $${2} $${MARKER}$$(
		if [ -n "$${3}" ]; then
			$${ECHO} " $${@:3}" \\
			| $${SED} "s|$${COMPOSER_ROOT_REGEX}|$${EXPAND}|g"
		fi
	) -->\\n"
	return 0
}

########################################
#### {{{4 $(PUBLISH)-error
########################################

# 1 name
# 2 action
# 3 text
#
function $(PUBLISH)-error {
	$${ECHO} "$${MARKER} ERROR [$${0/#*\\/}] ($${1}):$$(
		if [ -n "$${2}" ]; then
			$${ECHO} " $${@:2}" \\
			| $${SED} "s|$${COMPOSER_ROOT_REGEX}|$${EXPAND}|g"
		fi
	)\\n" >&2
	return 0
}

########################################
#### {{{4 $(PUBLISH)-parse
########################################

# 1 icon || form

function $(PUBLISH)-parse {
	while read -r FILE; do
		if [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^$${PUBLISH_CMD_BEG} $${1}/p")" ]; then
#>			FILE="$$($${ECHO} "$${FILE}" | $${SED} "s|^$${PUBLISH_CMD_BEG} (.+) $${PUBLISH_CMD_END}$$|\\1|g")"
			FILE="$${FILE/#$${PUBLISH_CMD_BEG} }"
			FILE="$${FILE/% $${PUBLISH_CMD_END}}"
			$(PUBLISH)-$${FILE} || return 1
		else
			$${ECHO} "$${FILE}\\n" \\
			| $${SED} \\
				-e "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g" \\
				-e "s|$${COMPOSER_ROOT_REGEX}|$${COMPOSER_ROOT_PATH}|g"
		fi
	done
	return 0
}

################################################################################
### {{{3 Functions (Metadata)
################################################################################

########################################
#### {{{4 $(PUBLISH)-metainfo-block
########################################

#> update: YQ_WRITE.*title

# 1 $${SPECIAL_VAL} = library || file
# 2 $${SPECIAL_VAL} = metadata || text
# 3 file path

function $(PUBLISH)-metainfo-block {
	META=
	if [ "$${1}" = "$${SPECIAL_VAL}" ]; then
		META="$$(
			$${YQ_WRITE} ".\"$${3}\"" $${COMPOSER_LIBRARY_METADATA} 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
	elif [ "$$($${SED} -n "/^---$$/p" $${3})" ]; then
		META="$$(
			$${SED} -n "1,/^---$$/p" $${3}
		)"
	fi
#>	if [ -z "$${META}" ]; then
#>		return 0
#>	fi
	TITL="$$(
		$${ECHO} "$${META}" \\
		| $${YQ_WRITE} ".title" 2>/dev/null \\
		| $${SED} "/^null$$/d"
	)"
	if [ -z "$${TITL}" ]; then
		TITL="$$(
			$${ECHO} "$${META}" \\
			| $${YQ_WRITE} ".pagetitle" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
	fi
	if [ -z "$${TITL}" ]; then
		TITL="$$($${ECHO} "$${3}" | $${SED} "s|^.+[/]||g")"
	fi
	DATE="$$(
		$${ECHO} "$${META}" \\
		| $${YQ_WRITE} ".date" 2>/dev/null \\
		| $${SED} "s|[T][0-9]{2}[:][0-9]{2}[:][0-9]{2}.*$$||g" \\
		| $${SED} "/^null$$/d"
	)"
	TAGS=()
	NUM="0"; for FILE in $${COMPOSER_YML_DATA_METALIST}; do
		LIST="$$(
			$${ECHO} "$${META}" \\
			| $${YQ_WRITE} ".$${FILE}" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
		if [ -n "$${LIST}" ]; then
			JOIN="$$(
				$${ECHO} "$${LIST}" \\
				| $${YQ_WRITE} "join(\"$${TOKEN}\")" 2>/dev/null \\
				| $${SED} "/^null$$/d"
			)"
			if [ -n "$${JOIN}" ]; then
				LIST="$${JOIN}"
			fi
		fi
		TAGS[$${NUM}]="$${LIST}"
		NUM="$$($${EXPR} $${NUM} + 1)"
	done
	if [ "$${2}" = "$${SPECIAL_VAL}" ]; then
		$${ECHO} "---\\n"
		$${ECHO} "pagetitle: \"$${TITL}\"\\n"
		$${ECHO} "date: $${DATE}\\n"
		NUM="0"; for FILE in $${COMPOSER_YML_DATA_METALIST}; do
			$${ECHO} "$${FILE}:\\n"
			if [ -n "$${TAGS[$${NUM}]}" ]; then
				$${ECHO} "  - \"$${TAGS[$${NUM}]}\"\\n" \
					| $${SED} "s|$${TOKEN}|\"\\n  - \"|g"
			fi
			NUM="$$($${EXPR} $${NUM} + 1)"
		done
		$${ECHO} "---\\n"
	else
		META_TXT="$$(COMPOSER_YML_DATA_VAL config.metainfo)"
		NULL_TXT="$$(COMPOSER_YML_DATA_VAL config.metainfo_null)"
		if [ -z "$${TITL}" ]; then TITL="$${NULL_TXT}"; fi
		if [ -z "$${DATE}" ]; then DATE="$${NULL_TXT}"; fi
		$${ECHO} "$${META_TXT}" \\
			| eval $${SED} \\
				-e "\\"s|<[|]>|$$(	$${ECHO} "$${HTML_HIDE}"	| $${SED} "s|([$${SED_ESCAPE_LIST}])|\\\\\\\\\\\\1|g")|g\\"" \\
				-e "\\"s|<title>|$$(	$${ECHO} "$${TITL}"		| $${SED} "s|([$${SED_ESCAPE_LIST}])|\\\\\\\\\\\\1|g")|g\\"" \\
				-e "\\"s|<date>|$$(	$${ECHO} "$${DATE}"		| $${SED} "s|([$${SED_ESCAPE_LIST}])|\\\\\\\\\\\\1|g")|g\\"" \\
				$$(
					NUM="0"; for FILE in $${COMPOSER_YML_DATA_METALIST}; do
						SEP="$$($${ECHO} "$${META_TXT}" | $${SED} -n "s|^.*<$${FILE}[|]([^>]*)>.*$$|\\1|gp")"
						if [ -z "$${TAGS[$${NUM}]}" ]; then TAGS[$${NUM}]="$${NULL_TXT}"; fi
						if [ -z "$${SEP}" ]; then SEP=" "; fi
						$${ECHO} " -e \\"s|<$${FILE}[^>]*>|$$(
							$${ECHO} "$${TAGS[$${NUM}]}" \\
							| $${SED} "s|$${TOKEN}|$${SEP}|g" \\
							| $${SED} "s|([$${SED_ESCAPE_LIST}])|\\\\\\\\\\\\1|g"
						)|g\\""
						NUM="$$($${EXPR} $${NUM} + 1)"
					done
				)
	fi
	return 0
}

########################################
#### {{{4 $(PUBLISH)-library-shelf
########################################

#> update: title / date / metalist:*

# 1 menu || list
# 2 title || date || metalist:*

function $(PUBLISH)-menu-library	{ $(PUBLISH)-library-shelf menu $${@} || return 1; return 0; }
function $(PUBLISH)-list-library	{ $(PUBLISH)-library-shelf list $${@} || return 1; return 0; }
function $(PUBLISH)-library		{ $(PUBLISH)-library-shelf list $${@} || return 1; return 0; }

function $(PUBLISH)-library-shelf {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	if [ ! -f "$${COMPOSER_LIBRARY_INDEX}" ]; then
		$(PUBLISH)-error $${FUNCNAME} $${@} "$${MARKER} library index missing"
	else
		if [ "$${1}" = "list" ]; then
$${CAT} <<_EOF_
<table class="$${COMPOSER_TINYNAME}-table table table-borderless align-top">
_EOF_
		fi
		$${YQ_WRITE} ".$${2} | keys | .[]" $${COMPOSER_LIBRARY_INDEX} 2>/dev/null \\
			| $${SED} "/^null$$/d" \\
			| while read -r FILE; do
				HREF="$${COMPOSER_LIBRARY_PATH}/$${2}-$$(
					$(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${FILE}"
				).$(EXTN_HTML)"
				TOTL="$$(
					$${YQ_WRITE} ".$${2}.[\"$${FILE}\"] | length" $${COMPOSER_LIBRARY_INDEX} 2>/dev/null \\
					| $${SED} "/^null$$/d"
				)"
				if [ "$${1}" = "menu" ]; then
$${CAT} <<_EOF_
<li><a class="dropdown-item" href="$${HREF}">$${FILE} ($${TOTL})</a></li>
_EOF_
				else
$${CAT} <<_EOF_
<tr><td><a href="$${HREF}">$${FILE}</a></td><td class="text-end">$${TOTL}</td></tr>
_EOF_
				fi
			done
		if [ "$${1}" = "list" ]; then
$${CAT} <<_EOF_
</table>
_EOF_
		fi
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

################################################################################
### {{{3 Functions (Config)
################################################################################

########################################
#### {{{4 $(PUBLISH)-brand
########################################

# 1 c_logo

function $(PUBLISH)-brand {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<a class="navbar-brand" href="$$(COMPOSER_YML_DATA_VAL config.homepage)">
_EOF_
	BRND="$$(COMPOSER_YML_DATA_VAL config.brand)"
	if [ -s "$${1}" ]; then
		$${ECHO} "<img class=\"$${COMPOSER_TINYNAME}-logo\" src=\"$${1}\">\\n"
		if [ -n "$${BRND}" ]; then
			$${ECHO} "$${HTML_SPACE}\\n"
		fi
	else
		$(PUBLISH)-marker $${FUNCNAME} skip logo
	fi
	if [ -n "$${BRND}" ]; then
		$${ECHO} "$${BRND}\\n"
	fi
$${CAT} <<_EOF_
</a>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-copyright
########################################

# @ none

function $(PUBLISH)-copyright {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<p class="$${COMPOSER_TINYNAME}-link navbar-text me-3">
$$(
	COMPOSER_YML_DATA_VAL config.copyright \\
	| $(PUBLISH)-parse
)
</p>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-search
########################################

# @ none

function $(PUBLISH)-search {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	NAME="$$(COMPOSER_YML_DATA_VAL config.search_name)"
	if [ -n "$${NAME}" ]; then
$${CAT} <<_EOF_
<form class="nav-item d-flex form-inline" action="$$(COMPOSER_YML_DATA_VAL config.search_site)">
<input class="$${COMPOSER_TINYNAME}-form form-control form-control-sm me-1" type="text" name="$$(COMPOSER_YML_DATA_VAL config.search_call)">
<button type="submit" class="btn btn-sm">
$$(
	$${ECHO} "$${NAME}\\n" \\
	| $(PUBLISH)-parse
)
</button>
$$(
	COMPOSER_YML_DATA_VAL config.search_form \\
	| $(PUBLISH)-parse
)
</form>
_EOF_
	else
		$(PUBLISH)-marker $${FUNCNAME} skip search
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-top
########################################

# 1 $(PUBLISH)-nav-begin 2		$(PUBLISH)-brand 1 c_logo

# x $(PUBLISH)-nav-begin 1		top || bottom
# x $(PUBLISH)-nav-top-list 1		$(PUBLISH)-nav-top.[*]
# x $(PUBLISH)-nav-end 1		$(PUBLISH)-info-data 1 top || bottom

function $(PUBLISH)-nav-top {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	$(PUBLISH)-nav-begin "top" "$${1}"						|| return 1
$${CAT} <<_EOF_
<ul class="navbar-nav navbar-nav-scroll me-auto">
_EOF_
	if [ -n "$$(COMPOSER_YML_DATA_VAL nav-top)" ]; then
		COMPOSER_YML_DATA_VAL "nav-top | keys | .[]" \\
			| while read -r MENU; do
				$(PUBLISH)-nav-top-list "nav-top.[\"$${MENU}\"]"	|| return 1
			done
	else
		$(PUBLISH)-marker $${FUNCNAME} skip nav-top
	fi
$${CAT} <<_EOF_
</ul>
_EOF_
	$(PUBLISH)-nav-end "top"							|| return 1
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-top-list
########################################

# 1 $(PUBLISH)-nav-top.[*]

# x $(PUBLISH)-menu-library 1		title || date || metalist:*

function $(PUBLISH)-nav-top-list {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	COLS_BREAK="$$(COMPOSER_YML_DATA_VAL config.cols_break)"
	local ROOT="$$($${ECHO} "$${1}" | $${SED} -n "/^nav-top.[[][\\"][^]\\"]+[\\"][]]$$/p")"
	local SIZE="$$(COMPOSER_YML_DATA_VAL "$${1} | length")"
	local NUM="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
		$(PUBLISH)-marker $${FUNCNAME} start $${1}[$${NUM}]
#>		FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]")"
		FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]" 2>/dev/null)"
		if [ -z "$${FILE}" ]; then
			FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}]")"
		else
			LINK="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}].[\"$${FILE}\"]")"
		fi
		if [ -z "$${LINK}" ]; then
			LINK="#"
		fi
		if [ "$${FILE}" = "$${MENU_SELF}" ]; then
#>			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
			$${ECHO} ""
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^header/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^spacer/p")" ]; then
			$(PUBLISH)-nav-divider top$$(if [ -n "$${ROOT}" ]; then $${ECHO} "-menu"; fi) || return 1
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^icon/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^form/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metainfo/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^contents/p")" ]; then
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| if [ -n "$${ROOT}" ]; then
					$${SED} "s|^contents|contents-menu $${MENU_SELF}|g"
				else
					$${SED} "s|^contents|contents-menu|g"
				fi
			) $${PUBLISH_CMD_END}\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metalist/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^readtime/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^library/p")" ]; then
			$(PUBLISH)-menu-$${FILE} || return 1
		elif [ -n "$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}].[\"$${FILE}\"][0]")" ]; then
			LINK="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}].[\"$${FILE}\"][0].[\"$${MENU_SELF}\"]")"
			if [ -z "$${LINK}" ]; then
				LINK="#"
			fi
			if [ -n "$${ROOT}" ]; then
$${CAT} <<_EOF_
<li class="nav-item dropdown">
<a class="nav-link dropdown-toggle" href="$$(
	$${ECHO} "$${LINK}" \\
	| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
)" data-bs-toggle="dropdown">$${FILE}</a>
<ul class="$${COMPOSER_TINYNAME}-menu-$${COLS_BREAK} dropdown-menu">
_EOF_
			else
$${CAT} <<_EOF_
<li><a class="dropdown-item" href="$$(
	$${ECHO} "$${LINK}" \\
	| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a>
<ul class="$${COMPOSER_TINYNAME}-menu-list">
_EOF_
			fi
			$(PUBLISH)-nav-top-list "$${1}[$${NUM}].[\"$${FILE}\"]" || return 1
$${CAT} <<_EOF_
</ul></li>
_EOF_
		else
			if [ -n "$${ROOT}" ]; then
$${CAT} <<_EOF_
<li class="nav-item"><a class="nav-link" href="$$(
	$${ECHO} "$${LINK}" \\
	| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a></li>
_EOF_
			else
$${CAT} <<_EOF_
<li><a class="dropdown-item" href="$$(
	$${ECHO} "$${LINK}" \\
	| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a></li>
_EOF_
			fi
		fi
		$(PUBLISH)-marker $${FUNCNAME} finish $${1}[$${NUM}]
		NUM="$$($${EXPR} $${NUM} + 1)"
	done
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-bottom
########################################

# @ none

# x $(PUBLISH)-nav-begin 1		top || bottom
# x $(PUBLISH)-nav-begin 2		$(PUBLISH)-brand 1 c_logo
# x $(PUBLISH)-nav-bottom-list 1	$(PUBLISH)-nav-bottom.[*]
# x $(PUBLISH)-nav-end 1		$(PUBLISH)-info-data 1 top || bottom

function $(PUBLISH)-nav-bottom {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	$(PUBLISH)-nav-begin "bottom" ""						|| return 1
$${CAT} <<_EOF_
<ol class="$${COMPOSER_TINYNAME}-link nav-item breadcrumb me-auto">
_EOF_
	if [ -n "$$(COMPOSER_YML_DATA_VAL nav-bottom)" ]; then
$${CAT} <<_EOF_
<li class="breadcrumb-item">$${HTML_HIDE}</li>
_EOF_
		COMPOSER_YML_DATA_VAL "nav-bottom | keys | .[]" \\
			| while read -r MENU; do
				$(PUBLISH)-nav-bottom-list "nav-bottom.[\"$${MENU}\"]"	|| return 1
			done
$${CAT} <<_EOF_
<li class="breadcrumb-item">$${HTML_HIDE}</li>
_EOF_
	else
		$(PUBLISH)-marker $${FUNCNAME} skip nav-bottom
	fi
$${CAT} <<_EOF_
</ol>
_EOF_
	$(PUBLISH)-nav-end "bottom"							|| return 1
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-bottom-list
########################################

# 1 $(PUBLISH)-nav-bottom.[*]

function $(PUBLISH)-nav-bottom-list {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	local SIZE="$$(COMPOSER_YML_DATA_VAL "$${1} | length")"
	local NUM="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
		$(PUBLISH)-marker $${FUNCNAME} start $${1}[$${NUM}]
#>		FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]")"
		FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]" 2>/dev/null)"
		if [ -z "$${FILE}" ]; then
			FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}]")"
		else
			LINK="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}].[\"$${FILE}\"]")"
		fi
		if [ -z "$${LINK}" ]; then
			LINK="#"
		fi
		if [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^header/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^spacer/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^icon/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^form/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metainfo/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^contents/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metalist/p")" ]; then
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^metalist|metalist-menu|g"
			) $${PUBLISH_CMD_END}\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^readtime/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^library/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		else
$${CAT} <<_EOF_
<li class="breadcrumb-item"><a href="$$(
	$${ECHO} "$${LINK}" \\
	| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
)">$${FILE}</a></li>
_EOF_
		fi
		$(PUBLISH)-marker $${FUNCNAME} finish $${1}[$${NUM}]
		NUM="$$($${EXPR} $${NUM} + 1)"
	done
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-side
########################################

# 1 $(PUBLISH)-column-begin 1		left || center || right
# 1 $(PUBLISH)-nav-side-list 1		$(PUBLISH)-nav-left.[*] || $(PUBLISH)-nav-right.[*]

# x $(PUBLISH)-column-end

function $(PUBLISH)-nav-left	{ $(PUBLISH)-nav-side left $${@} || return 1; return 0; }
function $(PUBLISH)-nav-right	{ $(PUBLISH)-nav-side right $${@} || return 1; return 0; }

function $(PUBLISH)-nav-side {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	if [ -n "$$(COMPOSER_YML_DATA_VAL nav-$${1})" ]; then
		$(PUBLISH)-column-begin "$${1}"						|| return 1
		COMPOSER_YML_DATA_VAL "nav-$${1} | keys | .[]" \\
			| while read -r MENU; do
				$(PUBLISH)-nav-side-list "nav-$${1}.[\"$${MENU}\"]"	|| return 1
			done
		$(PUBLISH)-column-end							|| return 1
	else
		$(PUBLISH)-marker $${FUNCNAME} skip nav-$${1}
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-side-list
########################################

# 1 $(PUBLISH)-nav-left.[*] || $(PUBLISH)-nav-right.[*]

# x $(PUBLISH)-spacer
# x $(PUBLISH)-list-library 1		title || date || metalist:*
# x $(PUBLISH)-select 1+@		file path || function name + null || function arguments

function $(PUBLISH)-nav-side-list {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	local SIZE="$$(COMPOSER_YML_DATA_VAL "$${1} | length")"
	local NUM="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
		$(PUBLISH)-marker $${FUNCNAME} start $${1}[$${NUM}]
		FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}]")"
		if [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^header/p")" ]; then
			$(PUBLISH)-$${FILE} || return 1
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^spacer/p")" ]; then
			$(PUBLISH)-$${FILE} || return 1
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^icon/p")" ]; then
			$(PUBLISH)-$${FILE} || return 1
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^form/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metainfo/p")" ]; then
			$${ECHO} "\\n"
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^metainfo|metainfo-list|g"
			) $${PUBLISH_CMD_END}\\n"
			$${ECHO} "\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^contents/p")" ]; then
			$${ECHO} "\\n"
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^contents|contents-list|g"
			) $${PUBLISH_CMD_END}\\n"
			$${ECHO} "\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metalist/p")" ]; then
			$${ECHO} "\\n"
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^metalist|metalist-list|g"
			) $${PUBLISH_CMD_END}\\n"
			$${ECHO} "\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^readtime/p")" ]; then
			$${ECHO} "\\n"
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^readtime|readtime-list|g"
			) $${PUBLISH_CMD_END}\\n"
			$${ECHO} "\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^library/p")" ]; then
			$(PUBLISH)-list-$${FILE} || return 1
#>		elif [ "$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]")" = "$${MENU_SELF}" ]; then
		elif [ "$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]" 2>/dev/null)" = "$${MENU_SELF}" ]; then
			$${ECHO} "\\n"
			COMPOSER_YML_DATA_VAL "$${1}[$${NUM}].[\"$${MENU_SELF}\"]" \\
				| $${SED} "s|^|  |g" \\
				| $(PUBLISH)-parse
			$${ECHO} "\\n"
		else
			$(PUBLISH)-select $${FILE} || return 1
		fi
		$(PUBLISH)-marker $${FUNCNAME} finish $${1}[$${NUM}]
		NUM="$$($${EXPR} $${NUM} + 1)"
	done
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-info-data
########################################

# 1 top || bottom

# x $(PUBLISH)-info-data-list 1		$(PUBLISH)-info-$${1}.[*]

function $(PUBLISH)-info-data {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	if [ -n "$$(COMPOSER_YML_DATA_VAL info-$${1})" ]; then
		$(PUBLISH)-nav-divider $${1}-info || return 1
		COMPOSER_YML_DATA_VAL "info-$${1} | keys | .[]" \\
			| while read -r MENU; do
				$(PUBLISH)-info-data-list "info-$${1}.[\"$${MENU}\"]" || return 1
			done
	else
		$(PUBLISH)-marker $${FUNCNAME} skip info-$${1}
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-info-data-list
########################################

# 1 $(PUBLISH)-info-$${1}.[*]

function $(PUBLISH)-info-data-list {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	local SIZE="$$(COMPOSER_YML_DATA_VAL "$${1} | length")"
	local NUM="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
		$(PUBLISH)-marker $${FUNCNAME} start $${1}[$${NUM}]
$${CAT} <<_EOF_
<p class="$${COMPOSER_TINYNAME}-link navbar-text me-3">
_EOF_
		FILE="$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}]")"
		if [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^header/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^spacer/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^icon/p")" ]; then
			$(PUBLISH)-$${FILE} || return 1
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^form/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metainfo/p")" ]; then
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^metainfo|metainfo-list|g"
			) $${PUBLISH_CMD_END}\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^contents/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^metalist/p")" ]; then
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^metalist|metalist-list|g"
			) $${PUBLISH_CMD_END}\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^readtime/p")" ]; then
			$${ECHO} "$${PUBLISH_CMD_BEG} $$(
				$${ECHO} "$${FILE}" \\
				| $${SED} "s|^readtime|readtime-list|g"
			) $${PUBLISH_CMD_END}\\n"
		elif [ -n "$$($${ECHO} "$${FILE}" | $${SED} -n "/^library/p")" ]; then
			$(PUBLISH)-marker $${FUNCNAME} skip $${FILE}
#>		elif [ "$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]")" = "$${MENU_SELF}" ]; then
		elif [ "$$(COMPOSER_YML_DATA_VAL "$${1}[$${NUM}] | keys | .[]" 2>/dev/null)" = "$${MENU_SELF}" ]; then
#>			$${ECHO} "\\n"
#>				| $${SED} "s|^|  |g" \\
			COMPOSER_YML_DATA_VAL "$${1}[$${NUM}].[\"$${MENU_SELF}\"]" \\
				| $${SED} "/^$$/d" \\
				| $(PUBLISH)-parse
#>			$${ECHO} "\\n"
		else
			$(PUBLISH)-select $${FILE} || return 1
		fi
$${CAT} <<_EOF_
</p>
_EOF_
		$(PUBLISH)-marker $${FUNCNAME} finish $${1}[$${NUM}]
		NUM="$$($${EXPR} $${NUM} + 1)"
	done
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

################################################################################
### {{{3 Functions (Elements)
################################################################################

########################################
#### {{{4 $(PUBLISH)-nav-begin
########################################

# 1 top || bottom
# 2 $(PUBLISH)-brand 1			c_logo

function $(PUBLISH)-nav-begin {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<div class="$${COMPOSER_TINYNAME}-toggler collapsed" data-bs-toggle="collapse" data-bs-target="#navbar-fixed-$${1}"></div>
<nav class="navbar navbar-expand-$$(COMPOSER_YML_DATA_VAL config.cols_break) fixed-$${1}">
<div class="container-fluid">
<button type="button" class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbar-fixed-$${1}">
<span class="navbar-toggler-icon"></span>
</button>
_EOF_
	if [ "$${1}" = "top" ]; then
		$(PUBLISH)-brand "$${2}" || return 1
	else
		$(PUBLISH)-copyright || return 1
	fi
$${CAT} <<_EOF_
<div class="navbar-collapse collapse" id="navbar-fixed-$${1}">
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-divider
########################################

# 1 *-menu || * || *-info		* = top || bottom

function $(PUBLISH)-nav-divider {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	COLS_BREAK="$$(COMPOSER_YML_DATA_VAL config.cols_break)"
	if [ "$${1}" = "top-menu" ]; then
$${CAT} <<_EOF_
<li class="$${COMPOSER_TINYNAME}-menu-div nav-item nav-link d-$${COLS_BREAK}-block d-none">$${HTML_HIDE}</li>
<li class="nav-item d-$${COLS_BREAK}-none d-block"><hr class="dropdown-divider"></li>
_EOF_
	elif [ "$${1}" = "top" ]; then
$${CAT} <<_EOF_
<li><hr class="dropdown-divider"></li>
_EOF_
	elif {
		[ "$${1}" = "top-info" ] ||
		[ "$${1}" = "bottom-info" ];
	}; then
$${CAT} <<_EOF_
<p class="navbar-text d-$${COLS_BREAK}-none d-block"><hr class="dropdown-divider"></p>
_EOF_
	else
		$(PUBLISH)-marker $${FUNCNAME} skip nav-divider-$${1}
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-nav-end
########################################

# 1 $(PUBLISH)-info-data 1		top || bottom

function $(PUBLISH)-nav-end {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	$(PUBLISH)-info-data "$${1}" || return 1
	if [ "$${1}" = "top" ]; then
		$(PUBLISH)-search || return 1
	else
		if [ -n "$$(COMPOSER_YML_DATA_VAL config.$${COMPOSER_TINYNAME})" ]; then
$${CAT} <<_EOF_
<p class="$${COMPOSER_TINYNAME}-link navbar-text me-1">
$${DIVIDE}$${HTML_SPACE}<a href="$${COMPOSER_HOMEPAGE}">$${CREATED_TAGLINE}</a>
</p>
_EOF_
		fi
	fi
$${CAT} <<_EOF_
</div>
</div>
</nav>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-row-begin
########################################

# @ none

function $(PUBLISH)-row-begin {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<div class="container-fluid$$(
	if [ -n "$$(COMPOSER_YML_DATA_VAL config.copy_protect)" ]; then
		$${ECHO} " user-select-none"
	fi
)">
<div class="d-flex flex-row flex-wrap">
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-row-end
########################################

# @ none

function $(PUBLISH)-row-end {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
</div>
</div>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-column-begin
########################################

# 1 left || center || right

# @ options				$${@}

function $(PUBLISH)-column-begin {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<div class="d-flex flex-column$$(
	if	[ "$${1}" = "left" ] ||
		[ "$${1}" = "center" ] ||
		[ "$${1}" = "right" ];
	then
		NUM="1"
		if [ "$${1}" = "left" ]; then		NUM="0"
		elif [ "$${1}" = "right" ]; then	NUM="2"
		fi
		COLS_BREAK="$$(		COMPOSER_YML_DATA_VAL config.cols_break)"
		COLS_STICKY="$$(	COMPOSER_YML_DATA_VAL config.cols_sticky[$${NUM}])"
		COLS_RESTICKY="$$(	COMPOSER_YML_DATA_VAL config.cols_resticky[$${NUM}])"
		COLS_ORDER="$$(		COMPOSER_YML_DATA_VAL config.cols_order[$${NUM}])"
		COLS_REORDER="$$(	COMPOSER_YML_DATA_VAL config.cols_reorder[$${NUM}])"
		COLS_SIZE="$$(		COMPOSER_YML_DATA_VAL config.cols_size[$${NUM}])"
		COLS_RESIZE="$$(	COMPOSER_YML_DATA_VAL config.cols_resize[$${NUM}])"
		if	[ "$${COLS_STICKY}"	!= "$${SPECIAL_VAL}" ];
		then	$${ECHO} " $${COMPOSER_TINYNAME}-sticky d-$${COLS_BREAK}-sticky"
		else	$${ECHO} " d-$${COLS_BREAK}-static"
		fi
		if	[ "$${COLS_RESTICKY}"	!= "$${SPECIAL_VAL}" ];
		then	$${ECHO} " $${COMPOSER_TINYNAME}-sticky d-sticky"
		else	$${ECHO} " d-static"
		fi
		$${ECHO} " order-$${COLS_BREAK}-$${COLS_ORDER} order-$${COLS_REORDER}"
		$${ECHO} " col-$${COLS_BREAK}-$${COLS_SIZE} col-$${COLS_RESIZE}"
		if	[ "$${COLS_ORDER}"	!= "$${SPECIAL_VAL}" ] &&
			[ "$${COLS_SIZE}"	!= "$${SPECIAL_VAL}" ];
		then	$${ECHO} " d-$${COLS_BREAK}-block"
		else	$${ECHO} " d-$${COLS_BREAK}-none"
		fi
		if	[ "$${COLS_REORDER}"	!= "$${SPECIAL_VAL}" ] &&
			[ "$${COLS_RESIZE}"	!= "$${SPECIAL_VAL}" ];
		then	$${ECHO} " d-block"
		else	$${ECHO} " d-none"
		fi
	else
		if [ -n "$${1}" ]; then
			$${ECHO} " $${@}"
		fi
	fi
) p-2">
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-column-end
########################################

# @ none

function $(PUBLISH)-column-end {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
</div>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-fold-begin
########################################

# 1 "group"
# 2 id

# 1 header level			$${SPECIAL_VAL} = none
# 2 $${SPECIAL_VAL} = collapsed
# 3 id					$${SPECIAL_VAL} = none
# 4 title				$${@:4} = $${4}++

# x $(PUBLISH)-header 1			header level
# x $(PUBLISH)-header 2			title

function $(PUBLISH)-fold-begin {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	if [ "$${1}" = "group" ]; then
$${CAT} <<_EOF_
<div class="accordion" id="$${2}">
_EOF_
		$(PUBLISH)-marker $${FUNCNAME} finish $${@}
		return 0
	fi
	HLVL="$${1}"
	if [ "$${HLVL}" = "$${SPECIAL_VAL}" ]; then
		HLVL="$${DEPTH_MAX}"
	fi
$${CAT} <<_EOF_
<div class="accordion">
<div class="accordion-item">
<div class="accordion-header" id="$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:4}")">
<button class="accordion-button$$(
	if [ "$${2}" = "$${SPECIAL_VAL}" ]; then $${ECHO} " collapsed"; fi
)" type="button" data-bs-toggle="collapse" data-bs-target="#toggle-$$($${ECHO} "$${@:4}" | $${SED} "s|[^[:alnum:]_-]||g")">
_EOF_
	if [ "$${1}" != "$${SPECIAL_VAL}" ] && [ -n "$${4}" ]; then
		$(PUBLISH)-header $${1} $${@:4} || return 1
	fi
$${CAT} <<_EOF_
<h$${HLVL} class="$${COMPOSER_TINYNAME}-header">
$${@:4}
</h$${HLVL}>
</button>
</div>
<div id="toggle-$$($${ECHO} "$${@:4}" | $${SED} "s|[^[:alnum:]_-]||g")" class="accordion-collapse collapse$$(
	if [ "$${2}" != "$${SPECIAL_VAL}" ]; then $${ECHO} " show"; fi
)"$$(
	if [ "$${3}" != "$${SPECIAL_VAL}" ]; then $${ECHO} " data-bs-parent=\\"#$${3}\\""; fi
)>
<div class="accordion-body">
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-fold-end
########################################

# 1 "group"

function $(PUBLISH)-fold-end {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	if [ "$${1}" = "group" ]; then
$${CAT} <<_EOF_
</div>
_EOF_
	else
$${CAT} <<_EOF_
</div>
</div>
</div>
</div>
_EOF_
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-box-begin
########################################

# 1 header level			$${SPECIAL_VAL} = none
# 2 title				$${@:2} = $${2}++

# x $(PUBLISH)-header 1			header level
# x $(PUBLISH)-header 2			title

function $(PUBLISH)-box-begin {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	HLVL="$${1}"
	if [ "$${HLVL}" = "$${SPECIAL_VAL}" ]; then
		HLVL="$${DEPTH_MAX}"
	fi
$${CAT} <<_EOF_
<div class="card">
<div class="card-header" id="$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")">
_EOF_
	if [ "$${1}" != "$${SPECIAL_VAL}" ] && [ -n "$${2}" ]; then
		$(PUBLISH)-header $${1} $${@:2} || return 1
	fi
$${CAT} <<_EOF_
<h$${HLVL} class="$${COMPOSER_TINYNAME}-header">
$${@:2}
</h$${HLVL}>
</div>
<div class="card-body">
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-box-end
########################################

# @ none

function $(PUBLISH)-box-end {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
</div>
</div>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-display
########################################

# 1 file path
# 2 name				$${@:2} = $${2}++

function $(PUBLISH)-display {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	FILE="$$(
		$${ECHO} "$${1}" \\
		| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
	)"
	if [ ! -f "$${FILE}" ]; then
		$(PUBLISH)-error $${FUNCNAME} $${@} "$${MARKER} display file missing"
	else
		DISP="$${@:2}"
		local IMGS="$$($${YQ_WRITE} ".[\"$${DISP}\"]" $${FILE} 2>/dev/null)"
		TYPE="$$(
			$${ECHO} "$${IMGS}" \\
			| $${YQ_WRITE} ".[\"type\"]" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
		TINT="$$(
			$${ECHO} "$${IMGS}" \\
			| $${YQ_WRITE} ".[\"tint\"]" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
		AUTO="$$(
			$${ECHO} "$${IMGS}" \\
			| $${YQ_WRITE} ".[\"auto\"]" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
		TIME="$$(
			$${ECHO} "$${IMGS}" \\
			| $${YQ_WRITE} ".[\"time\"]" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
		SHOW="$$(
			$${ECHO} "$${IMGS}" \\
			| $${YQ_WRITE} ".[\"show\"]" 2>/dev/null \\
			| $${SED} "/^null$$/d"
		)"
		if [ -z "$${SHOW}" ]; then
			SHOW="1"
		fi
		COLS="$$($${EXPR} 12 / $${SHOW})"
		local SIZE="$$($${ECHO} "$${IMGS}" | $${YQ_WRITE} ".[\"list\"] | length" 2>/dev/null)"
$${CAT} <<_EOF_
<div class="carousel$$(
	if [ -n "$${TINT}" ]; then
		$${ECHO} " carousel-$${TINT}"
	fi
) slide" data-bs-ride="$$(
	if [ -n "$${AUTO}" ]; then
		$${ECHO} "carousel"
	else
		$${ECHO} "true"
	fi
)" id="$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")">
<div class="carousel-indicators">
_EOF_
		local NUM="0"; local SHW="0"; local SLD="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
			if [ "$${SHW}" -ge "$${SHOW}" ]; then
				SHW="0"
			fi
			if {
				[ "$${TYPE}" = "banner" ] ||
				{ [ "$${TYPE}" = "shelf" ] && [ "$${SHW}" = "0" ]; };
			}; then
$${CAT} <<_EOF_
<button type="button" data-bs-slide-to="$${SLD}" data-bs-target="#$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")"$$(
	if [ "$${NUM}" = "0" ]; then
		$${ECHO} " class=\"active\""
	fi
)></button>
_EOF_
				SLD="$$($${EXPR} $${SLD} + 1)"
			fi
			SHW="$$($${EXPR} $${SHW} + 1)"
			NUM="$$($${EXPR} $${NUM} + 1)"
		done
$${CAT} <<_EOF_
</div>
<div class="carousel-inner">
_EOF_
		local NUM="0"; local SHW="0"; local SLD="0"; while [ "$${NUM}" -lt "$${SIZE}" ]; do
			if [ "$${SHW}" -ge "$${SHOW}" ]; then
				SHW="0"
			fi
			FILE="$$(
				$${ECHO} "$${IMGS}" \\
				| $${YQ_WRITE} ".[\"list\"][$${NUM}].[\"file\"]" 2>/dev/null \\
				| $${SED} "/^null$$/d" \\
				| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g" \\
			)"
			LINK="$$(
				$${ECHO} "$${IMGS}" \\
				| $${YQ_WRITE} ".[\"list\"][$${NUM}].[\"link\"]" 2>/dev/null \\
				| $${SED} "/^null$$/d" \\
				| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g" \\
			)"
			NAME="$$(
				$${ECHO} "$${IMGS}" \\
				| $${YQ_WRITE} ".[\"list\"][$${NUM}].[\"name\"]" 2>/dev/null \\
				| $${SED} "/^null$$/d"
			)"
			WIDE="$$(
				$${ECHO} "$${IMGS}" \\
				| $${YQ_WRITE} ".[\"list\"][$${NUM}].[\"size\"]" 2>/dev/null \\
				| $${SED} "/^null$$/d"
			)"
			if [ -z "$${LINK}" ]; then
				LINK="#"
			fi
			if [ -z "$${NAME}" ]; then
				NAME="$${FILE/#*\\/}"
			fi
			if {	[ "$${TYPE}" = "banner" ] ||
				{ [ "$${TYPE}" = "shelf" ] && [ "$${SHW}" = "0" ]; };
			}; then
$${CAT} <<_EOF_
<div class="carousel-item$$(
	if [ "$${NUM}" = "0" ]; then
		$${ECHO} " active"
	fi
)"$$(
	if [ -n "$${TIME}" ]; then
		$${ECHO} " data-bs-interval=\"$${TIME}000\""
	fi
)>
_EOF_
			fi
			if [ "$${TYPE}" = "banner" ]; then
$${CAT} <<_EOF_
<a href="$${LINK}">
<img class="$${COMPOSER_TINYNAME}-display" alt="$${NAME}" src="$${FILE}">
<div class="carousel-caption d-block">
_EOF_
				$${ECHO} "\\n"
				$${ECHO} "$${IMGS}" \\
					| $${YQ_WRITE} ".[\"list\"][$${NUM}].[\"$${MENU_SELF}\"]" 2>/dev/null \\
					| $${SED} "/^null$$/d" \\
					| $${SED} "s|^|  |g" \\
					| $(PUBLISH)-parse
				$${ECHO} "\\n"
$${CAT} <<_EOF_
</div>
</a>
_EOF_
			elif [ "$${TYPE}" = "shelf" ]; then
				SLD="$$($${EXPR} $${SLD} + 1)"
				if [ "$${SHW}" = "0" ]; then
$${CAT} <<_EOF_
<div class="container-fluid">
<div class="d-flex flex-row ps-5 pe-5">
_EOF_
				fi
$${CAT} <<_EOF_
<div class="d-flex flex-column col-$${COLS} d-block p-2">
<div class="text-center">
<a href="$${LINK}">
<img class="$${COMPOSER_TINYNAME}-display-item"$$(
	if [ -n "$${WIDE}" ]; then
		$${ECHO} " style=\"width: $${WIDE}\""
	fi
) alt="$${NAME}" src="$${FILE}">
</a>
</div>
</div>
_EOF_
			fi
			SHW="$$($${EXPR} $${SHW} + 1)"
			NUM="$$($${EXPR} $${NUM} + 1)"
			if [ "$${TYPE}" = "shelf" ] && {
				[ "$${SHW}" -ge "$${SHOW}" ] ||
				[ "$${SLD}" -ge "$${SIZE}" ];
			}; then
$${CAT} <<_EOF_
</div>
</div>
_EOF_
			fi
			if {	[ "$${TYPE}" = "banner" ] ||
				{ [ "$${TYPE}" = "shelf" ] && {
					[ "$${SHW}" -ge "$${SHOW}" ] ||
					[ "$${SLD}" -ge "$${SIZE}" ];
				}; };
			}; then
$${CAT} <<_EOF_
</div>
_EOF_
			fi
		done
$${CAT} <<_EOF_
</div>
<button type="button" class="carousel-control-prev" data-bs-slide="prev" data-bs-target="#$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")">
<span class="carousel-control-prev-icon"></span>
</button>
<button type="button" class="carousel-control-next" data-bs-slide="next" data-bs-target="#$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")">
<span class="carousel-control-next-icon"></span>
</button>
</div>
_EOF_
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

################################################################################
### {{{3 Functions (Tokens)
################################################################################

########################################
#### {{{4 $(PUBLISH)-header
########################################

# 1 header level
# 2 title				$${@:2} = $${2}++

function $(PUBLISH)-header {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<div id="$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")">
</div>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-spacer
########################################

# @ none

function $(PUBLISH)-spacer {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	$${ECHO} "$${HTML_BREAK}\\n"
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-break
########################################

# @ none

function $(PUBLISH)-break {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	$${ECHO} ""
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-icon
########################################

# 1 icon				[token = $${@} -1]
# 2 link rel
# 3 link href
# 4 alt text				$${@:4} = $${4}++

function $(PUBLISH)-icon {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	ICON="$${1}"
	LREL="$${2}"
	LLOC="$${3}"
	TEXT="$${@:4}"
$(foreach CSS_ICON,$(call CSS_ICONS),\
$(eval override NAME := $(word 1,$(subst ;, ,$(CSS_ICON)))) \
$(eval override ICON := icon.$(NAME).$(word 2,$(subst ;, ,$(CSS_ICON)))) \
$(eval override LREL := $(subst $(TOKEN),,$(word 4,$(subst ;, ,$(CSS_ICON))))) \
$(eval override LLOC := $(subst $(TOKEN),,$(word 6,$(subst ;, ,$(CSS_ICON))))) \
$(eval override TEXT := $(subst $(TOKEN), ,$(word 5,$(subst ;, ,$(CSS_ICON))))) \
$(TOKEN)
	if [ "$${ICON}" = "$(NAME)" ]; then
		ICON="$(ICON)"
		LREL="$(LREL)"
		if [ -n "$${2}" ]; then LLOC="$${2}";	else LLOC="$(if $(or $(LLOC),$(TEXT)),$(LLOC),$${2})"; fi
		if [ -n "$${3}" ]; then TEXT="$${@:3}";	else TEXT="$(if $(or $(LLOC),$(TEXT)),$(TEXT),$${@:3})"; fi
	fi
)	if	[ -n "$${LREL}" ] &&
		[ -n "$${LLOC}" ]
	then
$${CAT} <<_EOF_
<a rel="$${LREL}" href="$$(
	$${ECHO} "$${LLOC}" \\
	| $${SED} \\
		-e "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g" \\
		-e "s|$${COMPOSER_ROOT_REGEX}|$${COMPOSER_ROOT_PATH}|g"
)">
_EOF_
	fi
$${CAT} <<_EOF_
<img class="$${COMPOSER_TINYNAME}-icon" alt="$${TEXT}" src="$$(
	if [ -f "$${COMPOSER_DIR}/$(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/$${ICON}" ]; then
		$${ECHO} "$${COMPOSER_DIR}/$(call COMPOSER_CONV,,$(COMPOSER_IMAGES))/$${ICON}"
	else
		$${ECHO} "$${ICON}"
	fi \\
	| $${SED} \\
		-e "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g" \\
		-e "s|$${COMPOSER_ROOT_REGEX}|$${COMPOSER_ROOT_PATH}|g"
)">
_EOF_
	if	[ -n "$${LREL}" ] &&
		[ -n "$${LLOC}" ]
	then
$${CAT} <<_EOF_
</a>
_EOF_
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-form
########################################

# 1 name
# 2 value

function $(PUBLISH)-form {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<input type="hidden" name="$${1}" value="$${2}">
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-frame
########################################

# 1 type				youtube || [...]
# 2 identifier				$${@:2} = $${2}++

# 1 url
# 2 name				$${@:2} = $${2}++

function $(PUBLISH)-frame {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
$${CAT} <<_EOF_
<iframe data-external="1" class="$${COMPOSER_TINYNAME}-frame$$(
	if [ "$${1}" = "youtube" ]; then
		$${ECHO} " $${COMPOSER_TINYNAME}-frame-youtube"
	fi
)" id="$$($(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT "$${@:2}")" $$(
	if [ "$${1}" = "youtube" ]; then
		$${ECHO} "title=\\"YouTube: $${@:2}\\""
		$${ECHO} "src=\\"https://www.youtube-nocookie.com/embed/$${@:2}\\""
	else
		$${ECHO} "title=\\"$${@:2}\\""
		$${ECHO} "src=\\"$${1}\\""
	fi
)>
</iframe>
_EOF_
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

################################################################################
### {{{3 Functions (Script)
################################################################################

########################################
#### {{{4 $(PUBLISH)-file
########################################

# 1 file path
# @ null

# x $(PUBLISH)-select 1+@		file path || function name + null || function arguments
# x $(PUBLISH)-*

function $(PUBLISH)-file {
	$(PUBLISH)-marker $${FUNCNAME} start $${@}
	FILE_PATH="$$(
		$${ECHO} "$${1}" \\
		| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
	)"
	META_BEG=
	META_BLD=
	META_END=
	if [ -n "$$($${SED} -n "/^$${PUBLISH_CMD_BEG} metainfo $${MENU_SELF}/p" $${FILE_PATH})" ]; then
		META_BEG="$$($${SED} -n "s|^($${PUBLISH_CMD_BEG} metainfo) $${MENU_SELF} (.*)($${PUBLISH_CMD_END})$$|\\1|gp" $${FILE_PATH} | $${HEAD} -n1)"
		META_BLD="$$($${SED} -n "s|^($${PUBLISH_CMD_BEG} metainfo) $${MENU_SELF} (.*)($${PUBLISH_CMD_END})$$|\\2|gp" $${FILE_PATH} | $${HEAD} -n1)"
		META_END="$$($${SED} -n "s|^($${PUBLISH_CMD_BEG} metainfo) $${MENU_SELF} (.*)($${PUBLISH_CMD_END})$$|\\3|gp" $${FILE_PATH} | $${HEAD} -n1)"
	fi
	if [ -n "$${META_BLD}" ]; then
		$${ECHO} "$${META_BEG}-start $${1} $${META_END}\\n"
		$(PUBLISH)-$${META_BLD} $$(
			$(PUBLISH)-metainfo-block . . $${FILE_PATH}
		) || return 1
	fi
	$${ECHO} "\\n"
	if [ -n "$$(
		$${SED} -n "1{/^---$$/p}" $${FILE_PATH}
	)" ]; then
		$${SED} "1,/^---$$/d" $${FILE_PATH}
	else
		$${CAT} $${FILE_PATH}
	fi \\
		| while IFS=$$'\\n' read -r FILE; do
			BUILD_CMD="$${FILE}"
#>			BUILD_CMD="$$($${ECHO} "$${FILE}" | $${SED} "s|^$${PUBLISH_CMD_BEG} (.+) $${PUBLISH_CMD_END}$$|\\1|g")"
			BUILD_CMD="$${BUILD_CMD/#$${PUBLISH_CMD_BEG} }"
			BUILD_CMD="$${BUILD_CMD/% $${PUBLISH_CMD_END}}"
			if [ "$${FILE}" = "$${PUBLISH_CMD_BEG} $${BUILD_CMD} $${PUBLISH_CMD_END}" ]; then
				$(PUBLISH)-select $${BUILD_CMD} || return 1
			else
				$${PRINTF} "%s\\n" "$${FILE}"
			fi \\
			| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
			if [ "$${PIPESTATUS[0]}" != "0" ]; then return 1; fi
		done \\
		|| return 1
	$${ECHO} "\\n"
	if [ -n "$${META_BLD}" ]; then
		$${ECHO} "$${META_BEG}-finish $${1} $${META_END}\\n"
		$(PUBLISH)-$$($${ECHO} "$${META_BLD}" | $${SED} "s|[-]begin|-end|g") || return 1
	fi
	$(PUBLISH)-marker $${FUNCNAME} finish $${@}
	return 0
}

########################################
#### {{{4 $(PUBLISH)-select
########################################

# 1 file path || function name
# @ null || function arguments

function $(PUBLISH)-select {
	ACTION="$$(
		$${ECHO} "$${1}" \\
		| $${SED} "s|$${PUBLISH_CMD_ROOT}|$${COMPOSER_ROOT_PATH}|g"
	)"; shift
	if
		[ "$${ACTION}" = "metainfo" ] ||
		[ "$${ACTION}" = "contents" ] ||
		[ "$${ACTION}" = "metalist" ] ||
		[ "$${ACTION}" = "readtime" ];
	then
		if [ "$${ACTION}" = "metainfo" ] && [ "$${1}" = "$${MENU_SELF}" ]; then
			shift
			$${ECHO} "$${PUBLISH_CMD_BEG} $${ACTION}-self$$(
				if [ -n "$${1}" ]; then
					$${ECHO} " $${@}"
				fi
			) $${PUBLISH_CMD_END}\\n"
		else
			$${ECHO} "$${PUBLISH_CMD_BEG} $${ACTION}-list$$(
				if [ -n "$${1}" ]; then
					$${ECHO} " $${@}"
				fi
			) $${PUBLISH_CMD_END}\\n"
		fi
	elif
		[ "$${ACTION}" = "metainfo-menu" ] || [ "$${ACTION}" = "metainfo-list" ] ||
		[ "$${ACTION}" = "contents-menu" ] || [ "$${ACTION}" = "contents-list" ] ||
		[ "$${ACTION}" = "metalist-menu" ] || [ "$${ACTION}" = "metalist-list" ] ||
		[ "$${ACTION}" = "readtime-menu" ] || [ "$${ACTION}" = "readtime-list" ];
	then
		$${ECHO} "$${PUBLISH_CMD_BEG} $${ACTION}$$(
			if [ -n "$${1}" ]; then
				$${ECHO} " $${@}"
			fi
		) $${PUBLISH_CMD_END}\\n"
	elif
		[ -f "$${ACTION}" ];
	then
		if ! $(PUBLISH)-file $${ACTION} $${@}; then
			$(PUBLISH)-error file $${ACTION} $${@}
			return 1
		fi
	else
		if ! $(PUBLISH)-$${ACTION} $${@}; then
			$(PUBLISH)-error function $${ACTION} $${@}
			return 1
		fi
	fi
	return 0
}

################################################################################
### {{{3 Main Script
################################################################################

# x $(PUBLISH)-select 1+@		file path || function name + null || function arguments

$(PUBLISH)-select $${@} || exit 1

exit 0
################################################################################
# }}}3
################################################################################
# End Of File
################################################################################
endef

########################################
## {{{2 Heredoc: custom_$(PUBLISH)_css **
########################################

#> validate: sed -nr "s|^.*[[:space:]]class[=]||gp" Makefile | sed -r "s|[[:space:]]+|\n|g" | sort -u

########################################
### {{{3 Heredoc: custom_$(PUBLISH)_css
########################################

override define HEREDOC_CUSTOM_PUBLISH_CSS_HACK =
	$(SED) -i \
		-e "s|([^-])background-color[:][^;]+[;]|\\1|g" \
		-e "s|([^-])color[:][^;]+[;]|\\1|g"
endef

override define HEREDOC_CUSTOM_PUBLISH_JS_PRE =
<script>
endef
override define HEREDOC_CUSTOM_PUBLISH_JS_POST =
</script>
endef

override define HEREDOC_CUSTOM_PUBLISH_CSS_PRE =
endef
override define HEREDOC_CUSTOM_PUBLISH_CSS_POST =
::-webkit-scrollbar-track {
	background-color:		transparent;
}
::-webkit-scrollbar-thumb {
	background-color:		rgba(var(--bs-secondary-rgb));
}
body {
	scrollbar-color:		rgba(var(--bs-secondary-rgb)) transparent;
}
endef

########################################
### {{{3 Heredoc: custom_$(PUBLISH)_css (Bootstrap)
########################################

override define HEREDOC_CUSTOM_PUBLISH_CSS =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Bootstrap CSS
############################################################################# */

:root {
	--bs-scroll-height:		60vh;
	--bs-breadcrumb-divider:	"/";
}

/* ################################## */

.navbar-toggler-icon {
	background-image:		url("$(shell $(REALPATH) $(abspath $(dir $(CUSTOM_PUBLISH_CSS))) $(COMPOSER_IMAGES))/icon.menu.svg");
}

.carousel-control-prev-icon {
	background-image:		url("$(shell $(REALPATH) $(abspath $(dir $(CUSTOM_PUBLISH_CSS))) $(COMPOSER_IMAGES))/icon.arrow-left.svg");
}
.carousel-control-next-icon {
	background-image:		url("$(shell $(REALPATH) $(abspath $(dir $(CUSTOM_PUBLISH_CSS))) $(COMPOSER_IMAGES))/icon.arrow-right.svg");
}

.accordion-button::after,
.accordion-button:not(.collapsed)::after {
	background-image:		url("$(shell $(REALPATH) $(abspath $(dir $(CUSTOM_PUBLISH_CSS))) $(COMPOSER_IMAGES))/icon.arrow-down.svg");
}

.navbar-toggler:focus,
.accordion-button:focus,
.btn:focus {
	box-shadow:			0 0 0 0.0rem rgba(var(--bs-black-rgb));
}

/* ################################## */

.breadcrumb-item a:hover,
.dropdown-item:hover,
.nav-link:hover,
.navbar-brand:hover {
	text-decoration:		none;
}

.breadcrumb,
.navbar-text {
	margin:				0px;
	padding:			0px;
}

/* ########################################################################## */

body {
	min-width:			100%;
	margin:				0px;
	padding:			0px;
	padding-top:			70px;
	padding-bottom:			70px;
}

.$(COMPOSER_TINYNAME)-sticky {
	max-height:			85vh;
	overflow:			auto;
}

/* ################################## */

::-webkit-scrollbar {
	height:				100px;
	width:				10px;
}
::-webkit-scrollbar-button {
	height:				0px;
	width:				0px;
}
::-webkit-scrollbar-track {
	border-radius:			10px;
}
::-webkit-scrollbar-thumb {
	border-radius:			10px;
}

body {
	scrollbar-width:		thin;
}

/* ################################## */

html {
	min-height:			100%;
	position:			relative;
}

.$(COMPOSER_TINYNAME)-toggler {
	z-index:			1;
	cursor:				pointer;
	position:			absolute;
	top:				0;
	bottom:				0;
	left:				0;
	right:				0;
}

.$(COMPOSER_TINYNAME)-toggler.collapsed {
	z-index:			-1;
}

/* ################################## */

@media (min-width: 1400px) {
	.dropdown:hover .$(COMPOSER_TINYNAME)-menu-xxl {
		display:		block;
#$(MARKER)		margin-top:		0;
	}
	.$(COMPOSER_TINYNAME)-menu-xxl {
		max-height:		var(--bs-scroll-height);
		overflow:		auto;
	}
}

@media (min-width: 1200px) {
	.dropdown:hover .$(COMPOSER_TINYNAME)-menu-xl {
		display:		block;
#$(MARKER)		margin-top:		0;
	}
	.$(COMPOSER_TINYNAME)-menu-xl {
		max-height:		var(--bs-scroll-height);
		overflow:		auto;
	}
}

@media (min-width: 992px) {
	.dropdown:hover .$(COMPOSER_TINYNAME)-menu-lg {
		display:		block;
#$(MARKER)		margin-top:		0;
	}
	.$(COMPOSER_TINYNAME)-menu-lg {
		max-height:		var(--bs-scroll-height);
		overflow:		auto;
	}
}

@media (min-width: 768px) {
	.dropdown:hover .$(COMPOSER_TINYNAME)-menu-md {
		display:		block;
#$(MARKER)		margin-top:		0;
	}
	.$(COMPOSER_TINYNAME)-menu-md {
		max-height:		var(--bs-scroll-height);
		overflow:		auto;
	}
}

@media (min-width: 576px) {
	.dropdown:hover .$(COMPOSER_TINYNAME)-menu-sm {
		display:		block;
#$(MARKER)		margin-top:		0;
	}
	.$(COMPOSER_TINYNAME)-menu-sm {
		max-height:		var(--bs-scroll-height);
		overflow:		auto;
	}
}

/* ################################## */

.$(COMPOSER_TINYNAME)-logo {
	height:				28px;
	width:				auto;
}

.$(COMPOSER_TINYNAME)-icon {
	height:				24px;
	width:				auto;
}

.$(COMPOSER_TINYNAME)-display {
	height:				auto;
	max-width:			100%;
}
.$(COMPOSER_TINYNAME)-display-item {
	height:				auto;
	max-width:			128px;
}

.$(COMPOSER_TINYNAME)-frame {
#${MARKER}	height:				auto;
	max-height:			70vh;
	height:				512px;
	max-width:			90%;
	width:				90%;
	frameborder:			0;
}
.$(COMPOSER_TINYNAME)-frame-youtube {
#${MARKER}	height:				315px;
#${MARKER}	width:				560px;
	height:				384px;
#${MARKER}	allow:				"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share;";
	allow:				"accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share;";
	allowfullscreen;
}

/* ################################## */

.$(COMPOSER_TINYNAME)-menu-div::before {
	content:			var(--bs-breadcrumb-divider);
}

.$(COMPOSER_TINYNAME)-menu-list {
	list-style:			none;
	list-style-type:		none;
	list-style-position:		none;
	list-style-image:		none;
}

.$(COMPOSER_TINYNAME)-header {
	font-size:			1.1rem;
	margin-top:			0px;
	margin-bottom:			0px;
}

.$(COMPOSER_TINYNAME)-table td,
.$(COMPOSER_TINYNAME)-table tr,
.$(COMPOSER_TINYNAME)-table {
	border:				0px;
}

.$(COMPOSER_TINYNAME)-link a,
.$(COMPOSER_TINYNAME)-link a:active,
.$(COMPOSER_TINYNAME)-link a:hover,
.$(COMPOSER_TINYNAME)-link a:link,
.$(COMPOSER_TINYNAME)-link a:visited {
	text-decoration:		none;
}

$(call HEREDOC_CUSTOM_HTML_CSS)

h1					{ font-size: 2rem; }
h2					{ font-size: 1.5rem; }
h3					{ font-size: 1.3rem; }
h4					{ font-size: 1.2rem; }
h5					{ font-size: 1.1rem; }
h6					{ font-size: 1rem; }

ul {
	margin-top:			0px;
}

/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
### {{{3 Heredoc: custom_$(PUBLISH)_css (Overlay)
########################################

override define HEREDOC_CUSTOM_PUBLISH_CSS_OVERLAY =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Bootstrap CSS ($(1))
############################################################################# */

/* HEREDOC_CUSTOM_PUBLISH_CSS_HACK */

/* ########################################################################## */

.$(COMPOSER_TINYNAME)-form {
	background-color:		rgba(var(--bs-$(1)-rgb));
	color:				rgba(var(--bs-secondary-rgb));
	border:				1px solid rgba(var(--bs-secondary-rgb));
}

.navbar,
.dropdown-menu,
.accordion-button,
.card-header {
	background-color:		rgba(var(--bs-$(1)-rgb));
}

.accordion-button:not(.collapsed) {
	background-color:		rgba(var(--bs-$(1)-rgb));
	color:				rgba(var(--bs-secondary-rgb));
}

.accordion-item,
.card {
	border:				1px solid rgba(var(--bs-secondary-rgb));
}

/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
### {{{3 Heredoc: custom_$(PUBLISH)_css (Theme)
########################################

override define HEREDOC_CUSTOM_PUBLISH_CSS_THEME =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Bootstrap CSS (Theme)
############################################################################# */

/* #$(MARKER) @import url("$(shell $(REALPATH) $(abspath $(dir $(call CUSTOM_PUBLISH_CSS_OVERLAY,custom))) $(call CUSTOM_PUBLISH_CSS_OVERLAY,$(TESTING)))"); */

/* ########################################################################## */

:root {
$(call HEREDOC_CUSTOM_HTML_CSS_SOLARIZED)

	/* colors */
	--$(COMPOSER_TINYNAME)-back:		#000000; // black;	// var(--solarized-dark3);
#$(MARKER)	--$(COMPOSER_TINYNAME)-menu:		#202020; // slategray;	// var(--solarized-dark2);
	--$(COMPOSER_TINYNAME)-menu:		#202020; // slategray;	// var(--solarized-bs-dark);
	--$(COMPOSER_TINYNAME)-line:		#404040; // darkgray;	// var(--solarized-dark1);
	--$(COMPOSER_TINYNAME)-text:		#c0c0c0; // white;	// var(--solarized-light1);
	--$(COMPOSER_TINYNAME)-link:		#c00000; // red;	// var(--solarized-red);
#$(MARKER)	--$(COMPOSER_TINYNAME)-done:		#800000; // darkred;	// var(--solarized-cyan);
	--$(COMPOSER_TINYNAME)-done:		#800000; // darkred;	// var(--solarized-orange);

	/* layout */
	--$(COMPOSER_TINYNAME)-font:		system-ui, sans-serif;
	--$(COMPOSER_TINYNAME)-body:		800px;
	--$(COMPOSER_TINYNAME)-lead:		1.0em;
	--$(COMPOSER_TINYNAME)-next:		0.5em;
	--$(COMPOSER_TINYNAME)-rule:		3px;
	--$(COMPOSER_TINYNAME)-bord:		1px;
	--$(COMPOSER_TINYNAME)-padd:		6px;
}

/* ################################## */

.$(COMPOSER_TINYNAME)-form {
#$(MARKER)	background-color:		var(--$(COMPOSER_TINYNAME)-back);
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-text);
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-line);
}

.$(COMPOSER_TINYNAME)-header {
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-text);
}

.$(COMPOSER_TINYNAME)-link a,
.$(COMPOSER_TINYNAME)-link a:active,
.$(COMPOSER_TINYNAME)-link a:hover,
.$(COMPOSER_TINYNAME)-link a:link,
.$(COMPOSER_TINYNAME)-link a:visited {
	color:				var(--$(COMPOSER_TINYNAME)-text);
}

/* ########################################################################## */

html,
body {
	background-color:		var(--$(COMPOSER_TINYNAME)-back);
	color:				var(--$(COMPOSER_TINYNAME)-text);
	font-family:			var(--$(COMPOSER_TINYNAME)-font);
}
body {
	max-width:			var(--$(COMPOSER_TINYNAME)-body);
}
::selection {
	background-color:		var(--$(COMPOSER_TINYNAME)-done);
	color:				var(--$(COMPOSER_TINYNAME)-back);
}

::-webkit-scrollbar-track {
#$(MARKER)	background-color:		var(--composer-menu);
	background-color:		var(--composer-back);
}
::-webkit-scrollbar-thumb {
	background-color:		var(--composer-line);
}
body {
#$(MARKER)	scrollbar-color:		var(--composer-line) var(--composer-menu);
	scrollbar-color:		var(--composer-line) var(--composer-back);
}

a,
a:active,
a:link {
	color:				var(--$(COMPOSER_TINYNAME)-link);
}
a:hover,
a:visited {
	color:				var(--$(COMPOSER_TINYNAME)-done);
}
a,
a:active,
a:link,
a:visited {
	text-decoration:		none;
}
a:hover {
	text-decoration:		underline;
}

/* ################################## */

h1:not(.$(COMPOSER_TINYNAME)-header),
h2:not(.$(COMPOSER_TINYNAME)-header),
h3:not(.$(COMPOSER_TINYNAME)-header),
h4:not(.$(COMPOSER_TINYNAME)-header),
h5:not(.$(COMPOSER_TINYNAME)-header),
h6:not(.$(COMPOSER_TINYNAME)-header) {
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-text);
	border-bottom:			var(--$(COMPOSER_TINYNAME)-rule) solid var(--$(COMPOSER_TINYNAME)-line);
	margin-top:			var(--$(COMPOSER_TINYNAME)-lead);
	margin-bottom:			var(--$(COMPOSER_TINYNAME)-next);
}
hr,
hr:not([size]) {
	background-color:		var(--$(COMPOSER_TINYNAME)-line);
	height:				var(--$(COMPOSER_TINYNAME)-bord);
	border:				0px;
	opacity:			1;
}

table {
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-line);
	border-collapse:		collapse;
	margin-top:			var(--$(COMPOSER_TINYNAME)-lead);
	margin-bottom:			0px;
}
th {
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-text);
}
td,
th {
	padding:			var(--$(COMPOSER_TINYNAME)-padd);
}
tbody tr:nth-child(even) {
#$(MARKER)	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	background-color:		var(--$(COMPOSER_TINYNAME)-back);
	color:				var(--$(COMPOSER_TINYNAME)-text);
}

code,
pre code,
pre {
	background-color:		var(--$(COMPOSER_TINYNAME)-back);
	color:				var(--$(COMPOSER_TINYNAME)-text);
	font:				monospace;
}
code,
pre {
#$(MARKER)	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-line);
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-done);
}
pre code {
	border:				0px;
	box-shadow:			0 0 0 0.0rem rgba(var(--$(COMPOSER_TINYNAME)-text));
}

/* ########################################################################## */

.accordion-body,
.card-body {
	background-color:		var(--$(COMPOSER_TINYNAME)-back);
	color:				var(--$(COMPOSER_TINYNAME)-text);
}

/* ################################## */

.accordion,
.accordion-button,
.accordion-button:not(.collapsed),
.accordion-header,
.accordion-item,
.breadcrumb,
.breadcrumb-item + .breadcrumb-item::before,
.breadcrumb-item a,
.breadcrumb-item a:active,
.breadcrumb-item a:link,
.breadcrumb-item a:visited,
.breadcrumb-item,
.breadcrumb-item::before,
.card,
.card-header,
.dropdown,
.dropdown-divider,
.dropdown-item,
.dropdown-item:active,
.dropdown-item:link,
.dropdown-item:visited,
.dropdown-menu,
.dropdown-toggle,
.nav-item,
.nav-link,
.nav-link:active,
.nav-link:link,
.nav-link:visited,
.navbar,
.navbar-brand,
.navbar-brand:active,
.navbar-brand:link,
.navbar-brand:visited,
.navbar-text,
.navbar-toggler,
.navbar-toggler-icon {
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-text);
}

.navbar-brand:hover {
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-text);
}

.$(COMPOSER_TINYNAME)-link a:hover,
.breadcrumb-item a:hover,
.dropdown-item:hover,
.nav-link:hover {
	background-color:		var(--$(COMPOSER_TINYNAME)-back);
	color:				var(--$(COMPOSER_TINYNAME)-link);
}

.btn,
.btn:hover,
.navbar-toggler,
.navbar-toggler-icon {
	background-color:		var(--$(COMPOSER_TINYNAME)-line);
	color:				var(--$(COMPOSER_TINYNAME)-back);
}

.accordion-button::after,
.accordion-button:not(.collapsed)::after {
	background-color:		var(--$(COMPOSER_TINYNAME)-menu);
	color:				var(--$(COMPOSER_TINYNAME)-back);
}

.breadcrumb-item + .breadcrumb-item::before {
	color:				var(--$(COMPOSER_TINYNAME)-line);
}

/* ################################## */

.$(COMPOSER_TINYNAME)-link a,
.breadcrumb-item a,
.dropdown-item,
.nav-link,
.navbar-brand {
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-menu);
}

.$(COMPOSER_TINYNAME)-link a:hover,
.breadcrumb-item a:hover,
.dropdown-item:hover,
.nav-link:hover {
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-line);
}

.btn,
.navbar-toggler {
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-back);
}

.dropdown-divider,
.dropdown-menu {
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-line);
}

.accordion-item,
.card {
	border:				var(--$(COMPOSER_TINYNAME)-bord) solid var(--$(COMPOSER_TINYNAME)-line);
}

.accordion-header,
.card-header {
	border:				0px;
}

/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
### {{{3 Heredoc: custom_$(PUBLISH)_css ($(TESTING))
########################################

override define HEREDOC_CUSTOM_PUBLISH_CSS_TESTING =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) Bootstrap CSS ($(TESTING))
############################################################################# */

a,
a:active,
a:hover,
a:link,
a:visited,
body,
code,
hr,
html,
pre,
table {
	background-color:		black;
	color:				white;
	border:				3px solid red;
}

::-webkit-scrollbar-track {
	background-color:		red;
}
::-webkit-scrollbar-thumb {
	background-color:		white;
}
body {
	scrollbar-color:		white red;
}

/* ################################## */

.$(COMPOSER_TINYNAME)-form,
.$(COMPOSER_TINYNAME)-link a,
.$(COMPOSER_TINYNAME)-link a:active,
.$(COMPOSER_TINYNAME)-link a:hover,
.$(COMPOSER_TINYNAME)-link a:link,
.$(COMPOSER_TINYNAME)-link a:visited {
	background-color:		white;
	color:				black;
	border:				3px solid red;
}

/* ########################################################################## */

.accordion,
.accordion-body,
.accordion-button,
.accordion-button::after,
.accordion-button:not(.collapsed),
.accordion-button:not(.collapsed)::after,
.accordion-header,
.accordion-item,
.breadcrumb,
.breadcrumb-item + .breadcrumb-item::before,
.breadcrumb-item a,
.breadcrumb-item a:active,
.breadcrumb-item a:hover,
.breadcrumb-item a:link,
.breadcrumb-item a:visited,
.breadcrumb-item,
.breadcrumb-item::before,
.btn,
.btn:hover,
.card,
.card-body,
.card-header,
.carousel,
.carousel-caption,
.carousel-control-next,
.carousel-control-next-icon,
.carousel-control-prev,
.carousel-control-prev-icon,
.carousel-dark,
.carousel-indicators,
.carousel-inner,
.carousel-item,
.carousel-light,
.dropdown,
.dropdown-divider,
.dropdown-item,
.dropdown-item:active,
.dropdown-item:hover,
.dropdown-item:link,
.dropdown-item:visited,
.dropdown-menu,
.dropdown-toggle,
.form-control,
.form-inline,
.nav-item,
.nav-link,
.nav-link:active,
.nav-link:hover,
.nav-link:link,
.nav-link:visited,
.navbar,
.navbar-brand,
.navbar-brand:active,
.navbar-brand:hover,
.navbar-brand:link,
.navbar-brand:visited,
.navbar-text,
.navbar-toggler,
.navbar-toggler-icon,
.table {
	background-color:		gray;
	color:				cyan;
	border:				3px solid green;
}

/* ################################## */

.$(TESTING) {
	background-color:		brown;
	color:				yellow;
	border:				3px solid blue;
}

/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
## {{{2 Heredoc: custom_html_css **
########################################

########################################
### {{{3 Heredoc: custom_html_css
########################################

override define HEREDOC_CUSTOM_HTML_CSS_SOLARIZED =
	/* dark background */
	--solarized-dark3:		#002b36;
	--solarized-dark2:		#073642;
	/* content */
	--solarized-dark1:		#586e75;
	--solarized-dark0:		#657b83;
	--solarized-light0:		#839496;
	--solarized-light1:		#93a1a1;
	/* light background */
	--solarized-light2:		#eee8d5;
	--solarized-light3:		#fdf6e3;
	/* accent */
	--solarized-yellow:		#b58900;
	--solarized-orange:		#cb4b16;
	--solarized-red:		#dc322f;
	--solarized-magenta:		#d33682;
	--solarized-violet:		#6c71c4;
	--solarized-blue:		#268bd2;
	--solarized-cyan:		#2aa198;
	--solarized-green:		#859900;
	/* normal */
	--solarized-bs-light:		rgba(var(--bs-light-rgb));
	--solarized-bs-dark:		rgba(var(--bs-dark-rgb));
endef

########################################
### {{{3 Heredoc: custom_html_css (Main)
########################################

override define HEREDOC_CUSTOM_HTML_CSS =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) HTML CSS
############################################################################# */

html {
	font-size:			14px;
}

$(if $(1),$(1),body),
table,
tr {
	text-rendering:			optimizeLegibility;
	vertical-align:			text-top;
	text-align:			left;
	word-wrap:			normal;
}

img,
video {
	height:				auto;
	max-width:			100%;
}

/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
### {{{3 Heredoc: custom_html_css (Water.css)
########################################

override define HEREDOC_CUSTOM_HTML_CSS_WATER_CSS_HACK =
	$(SED) -i \
		-e "/^a.href.=/,/^}/d" \
		-e "/^.+table-layout[:]/d"
endef

override define HEREDOC_CUSTOM_HTML_CSS_WATER_SRC_SOLAR =
$(eval override OVRLY := $(word 1,$(subst :, ,$(1))))
$(eval override PRFRS := $(word 2,$(subst :, ,$(1))))
@import '../variables-$(OVRLY).css'		$(if $(PRFRS), (prefers-color-scheme: $(OVRLY)));
@import '../variables-solarized-$(OVRLY).css'	$(if $(PRFRS), (prefers-color-scheme: $(OVRLY)));
@import '../parts/_core.css';
endef

override define HEREDOC_CUSTOM_HTML_CSS_WATER_VAR_OVERLAY =
.$(COMPOSER_TINYNAME)-form {
	background-color:		var(--background);
	color:				var(--text-main);
	border:				1px solid var(--border);
}
.navbar,
.dropdown-menu,
.accordion-button,
.card-header {
	background-color:		var(--background);
}
.accordion-item,
.card {
	border:				1px solid var(--border);
}
endef

override define HEREDOC_CUSTOM_HTML_CSS_WATER_VAR_SOLAR =
:root {
$(call HEREDOC_CUSTOM_HTML_CSS_SOLARIZED)

	/* colors */
	--background-body:		var(--solarized-$(1)3);
	--text-muted:			var(--solarized-$(1)0);
	--text-main:			var(--solarized-$(if $(filter light,$(1)),dark,light)0);
	--text-bright:			var(--solarized-$(if $(filter light,$(1)),dark,light)1);
	--links:			var(--solarized-yellow);
	/* layout */
	--background-alt:		var(--solarized-$(1)2);
	--background:			var(--solarized-$(1)2);
	--border:			var(--solarized-$(1)1);
	--focus:			var(--solarized-$(1)1);
	/* widgets */
	--button-base:			var(--solarized-$(1)1);
	--button-hover:			var(--solarized-$(1)1);
	--form-placeholder:		var(--solarized-$(if $(filter light,$(1)),dark,light)0);
	--form-text:			var(--solarized-$(if $(filter light,$(1)),dark,light)0);
	/* accents */
	--code:				var(--solarized-orange);
	--highlight:			var(--solarized-cyan);
	--selection:			var(--solarized-violet);
	--variable:			var(--solarized-cyan);
}

$(call HEREDOC_CUSTOM_HTML_CSS_WATER_VAR_OVERLAY)

.$(COMPOSER_TINYNAME)-header {
	color:				var(--solarized-green);
}
h1:not(.$(COMPOSER_TINYNAME)-header),
h2:not(.$(COMPOSER_TINYNAME)-header),
h3:not(.$(COMPOSER_TINYNAME)-header),
h4:not(.$(COMPOSER_TINYNAME)-header),
h5:not(.$(COMPOSER_TINYNAME)-header),
h6:not(.$(COMPOSER_TINYNAME)-header) {
	color:				var(--solarized-magenta);
}
endef

########################################
## {{{2 Heredoc: custom_pdf_latex
########################################

override define HEREDOC_CUSTOM_PDF_LATEX =
% ##############################################################################
% $(COMPOSER_TECHNAME) $(DIVIDE) $(DESC_LPDF) ($(PDF_LATEX_NAME))
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

% \\fancyhead[EL,OR]{\\nouppercase{\\firstleftmark}}
% \\fancyhead[OL,ER]{}
\\fancyhead[EL,OL]{\\nouppercase{\\firstleftmark}}
\\fancyhead[ER,OR]{}
\\renewcommand{\\headrulewidth}{0.1pt}

% \\fancyfoot[EL,OR]{\\nouppercase{\\thepage}}
% \\fancyfoot[OL,ER]{}
\\fancyfoot[EL,OL]{\\nouppercase{\\thepage}}
\\fancyfoot[ER,OR]{}
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
## {{{2 Heredoc: custom_revealjs_css
########################################

override define HEREDOC_CUSTOM_REVEALJS_CSS_HACK =
	$(SED) -i \
		"s|^(.+background[:].+url[(][\"])[^\"]+([\"].+)$$|\1$(abspath $(c_logo))\2|g"
endef

override define HEREDOC_CUSTOM_REVEALJS_CSS =
/* #############################################################################
# $(COMPOSER_TECHNAME) $(DIVIDE) $(DESC_PRES)
############################################################################# */

.reveal .slides {
	background:			url("$(shell $(REALPATH) $(abspath $(dir $(CUSTOM_REVEALJS_CSS))) $(COMPOSER_LOGO))");
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
}

.reveal dl,
.reveal ol,
.reveal ul,
.reveal table {
	display:			block;
	margin-left:			2em;
}

$(call HEREDOC_CUSTOM_HTML_CSS,.reveal *)
/* #############################################################################
# End Of File
############################################################################# */
endef

########################################
## {{{2 Heredoc: license
########################################

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
# {{{1 Composer Output
################################################################################

# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

#>override _D				:= \e[0;37m
override define COMPOSER_COLOR =
override SED_ESCAPE_CONTROL		:= [[:cntrl:]][[][0-9]+[DC]
override SED_ESCAPE_COLOR		:= [[:cntrl:]][[][0-9]{1,2}([;][0-9]{2})?m
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
override SED_ESCAPE_CONTROL		:=
override SED_ESCAPE_COLOR		:=
override _D				:=
override _H				:=
override _C				:=
override _M				:=
override _N				:=
override _E				:=
override _S				:=
override _F				:=
endef

.PHONY: $(HEADERS)-colors
$(HEADERS)-colors:
	@$(PRINT) "$(_D)_D = Default$(_D)"
	@$(PRINT) "$(_H)_H = Header$(_D)"
	@$(PRINT) "$(_C)_C = Configuration$(_D)"
	@$(PRINT) "$(_M)_M = Message$(_D)"
	@$(PRINT) "$(_N)_N = Notice$(_D)"
	@$(PRINT) "$(_E)_E = Extra$(_D)"
	@$(PRINT) "$(_S)_S = Syntax$(_D)"
	@$(PRINT) "$(_F)_F = Fail$(_D)"

ifneq ($(COMPOSER_DOCOLOR),)
$(eval $(call COMPOSER_COLOR))
else
$(eval $(call COMPOSER_NOCOLOR))
endif

########################################

override COMMENTED			:= $(_S)\#$(_D) $(NULL)
override CODEBLOCK			:= $(NULL)    $(NULL)
override ENDOLINE			:= $(ECHO) "$(_D)\n"
override LINERULE			:= $(ECHO) "$(_H)";	$(PRINTF)  "-%.0s" {1..$(COLUMNS)}	; $(ENDOLINE)
override HEADER_L			:= $(ECHO) "$(_S)";	$(PRINTF) "\#%.0s" {1..$(COLUMNS)}	; $(ENDOLINE)

# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
ifneq ($(COMPOSER_DOCOLOR),)
override TABLE_C2			:= $(PRINTF) "$(_D)$(COMMENTED)%b$(_D)\e[128D\e[22C%b$(_D)\n"
override TABLE_M2			:= $(PRINTF) "$(_D)| %b$(_D)\e[128D\e[22C| %b$(_D)\n"
override TABLE_M3			:= $(PRINTF) "$(_D)| %b$(_D)\e[128D\e[22C| %b$(_D)\e[128D\e[54C| %b$(_D)\n"
override COLUMN_2			:= $(PRINTF) "$(_D)%b$(_D)\e[128D\e[39C %b$(_D)\n"
override PRINT				:= $(PRINTF) "$(_D)%b$(_D)\n"
else
override TABLE_C2			:= $(PRINTF) "$(COMMENTED)%-20s%s\n"
override TABLE_M2			:= $(PRINTF) "| %-20s| %s\n"
override TABLE_M3			:= $(PRINTF) "| %-20s| %-30s| %s\n"
override COLUMN_2			:= $(PRINTF) "%-39s %s\n"
override PRINT				:= $(PRINTF) "%s\n"
endif

########################################

#>		if	[ "$(1)" = "-1" ]; \
#>		then	$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) fold-begin	1	1		$(SPECIAL_VAL) $(2) $(PUBLISH_CMD_END)$(_D)\n\n"; \
#.		else	$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) fold-begin	$(1)	$(SPECIAL_VAL)	$(SPECIAL_VAL) $(2) $(PUBLISH_CMD_END)$(_D)\n\n"; \
#>		fi;
override define TITLE_LN =
	if	[ "$(COMPOSER_DOITALL_$(HELPOUT))" = "$(PUBLISH)" ] && \
		[ "$(1)" != "-1" ] && \
		[ "$(1)" != "1" ] && \
		[ "$(1)" != "$(DEPTH_MAX)" ]; then \
		$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)$(_D)\n\n"; \
		$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) box-begin $(1) $(2) $(PUBLISH_CMD_END)$(_D)\n\n"; \
	else \
		ttl_len="`$(EXPR) length '$(2)'`"; \
		ttl_len="`$(EXPR) $(COLUMNS) - 2 - $(1) - $${ttl_len}`"; \
		if [ "$(1)" -le "0" ]; then ttl_len="`$(EXPR) $${ttl_len} - 1 + $(1)`"; fi; \
		if [ "$(1)" -gt "0" ] && [ "$(1)" -le "$(HEAD_MAIN)" ]; then \
			if [ "$(COMPOSER_DOITALL_$(HELPOUT))" = "$(PUBLISH)" ]; \
			then	$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)$(_D)\n\n"; \
			else	$(ENDOLINE); $(LINERULE); \
			fi; \
		fi; \
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

#>		$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)$(_D)\n\n";
override define TITLE_END =
	if [ "$(COMPOSER_DOITALL_$(HELPOUT))" = "$(PUBLISH)" ]; then \
		$(ECHO) "$(_D)\n$(_N)$(PUBLISH_CMD_BEG) box-end $(PUBLISH_CMD_END)$(_D)\n\n"; \
	fi
endef

########################################

override YQ_WRITE_OUT_COLOR := \
	$(if $(COMPOSER_DOCOLOR),\
		| $(SED) \
			$(foreach FILE,null true false,\
				-e "s|([[:space:]]+)[\"]?($(FILE))[\"]?($(SED_ESCAPE_COLOR))?($(SED_ESCAPE_COLOR))?($(SED_ESCAPE_COLOR))?$$|\1[_N]\2|g" \
			) \
			-e "s|([:]?)$$|[_D]\1|g" \
			$(foreach FILE,_D _N,\
				-e "s|[[]$(FILE)[]]|$(shell $(ECHO) "$($(FILE))")|g" \
			) \
	)

################################################################################
# {{{1 Composer Headers
################################################################################

########################################
## {{{2 .set_title
########################################

#> validate: grep -E "[.]set_title" Makefile
.PHONY: .set_title-%
.set_title-%:
ifeq ($(MAKELEVEL),0)
ifneq ($(COMPOSER_DOCOLOR),)
#>	@$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
#>	@$(ECHO) "\e]0;$(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(call $(HEADERS)-path-root,$(CURDIR))\a"
	@$(ECHO) "\e]0;$(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
endif
endif
	@$(ECHO) ""

########################################
## {{{2 $(HEADERS)
########################################

ifneq ($(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),)
override COMPOSER_DEBUGIT		:= $(SPECIAL_VAL)
override COMPOSER_DEBUGIT_ALL		:= $(SPECIAL_VAL)
endif

override $(HEADERS)-path-dir		= $(subst $(abspath $(dir $(COMPOSER_DIR))),$(EXPAND),$(1))
override $(HEADERS)-path-root		= $(subst $(abspath $(dir $(COMPOSER_ROOT))),$(EXPAND),$(1))
override $(HEADERS)-path-list := \
	COMPOSER_ROOT \
	CURDIR \
	MAKEFILE_LIST \
	COMPOSER_INCLUDES \
	COMPOSER_YML_LIST \
	COMPOSER_LIBRARY \

.PHONY: $(HEADERS)
$(HEADERS): .set_title-$(HEADERS)
$(HEADERS):
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(TARGETS)-$(HEADERS)

########################################
### {{{3 $(HEADERS)-$(EXAMPLE)
########################################

#> update: $(HEADERS)-$(EXAMPLE)

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
	@	$(eval override c_base := $(@)) \
		$(eval override c_list := $(@)$(COMPOSER_EXT_DEFAULT)) \
		$(call $(HEADERS)-$(COMPOSER_PANDOC),$(notdir $(PANDOC)),$(COMPOSER_DEBUGIT_ALL))
	@$(LINERULE)
	@$(call $(HEADERS)-note,$(CURDIR),$(TESTING),,$(if $(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),note))
	@$(call $(HEADERS)-dir,$(CURDIR),directory,$(if $(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),note))
	@$(call $(HEADERS)-file,$(CURDIR),creating,$(if $(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),note))
	@$(call $(HEADERS)-skip,$(CURDIR),skipping,$(if $(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),note))
	@$(call $(HEADERS)-rm,$(CURDIR),removing,$(if $(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),note))
ifneq ($(COMPOSER_RELEASE),)
ifneq ($(COMPOSER_DOITALL_$(HEADERS)-$(EXAMPLE)),)
	@$(LINERULE)
	@$(call $(COMPOSER_TINYNAME)-note,$(TESTING))
	@$(call $(COMPOSER_TINYNAME)-mkdir				,$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE))
	@$(TOUCH)							$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE)/$(MAKEFILE)
	@$(call $(COMPOSER_TINYNAME)-makefile				,$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE)/$(MAKEFILE),1)
	@$(call $(COMPOSER_TINYNAME)-make,COMPOSER_DEBUGIT= --directory $(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE) $(NOTHING))
	@$(call $(COMPOSER_TINYNAME)-cp					,$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE)/$(MAKEFILE),$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE)/$(MAKEFILE).$(TESTING))
	@$(call $(COMPOSER_TINYNAME)-mv					,$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE)/$(MAKEFILE),$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE)/$(MAKEFILE).$(TESTING))
	@$(call $(COMPOSER_TINYNAME)-rm					,$(CURDIR)/.$(COMPOSER_BASENAME).$(HEADERS)-$(EXAMPLE),1)
endif
endif
	@$(LINERULE)
	@$(call ENV_MAKE,,$(COMPOSER_DOCOLOR)) $(HEADERS)-colors

########################################
### {{{3 $(HEADERS)-%
########################################

#> update: COMPOSER_OPTIONS

#> validate: grep -oE "[$][(]HEADERS[)]-[^[:space:],]+" Makefile | sort -u

.PHONY: $(HEADERS)-%
$(HEADERS)-%:
	@$(call $(HEADERS),,$(*))

.PHONY: $(HEADERS)-run-%
$(HEADERS)-run-%:
	@$(call $(HEADERS)-run,,$(*))

#>	$(TABLE_C2) "$(_H)$(COMPOSER_FULLNAME)"	"[$(_N)$(call $(HEADERS)-path-root,$(COMPOSER_DIR))$(_D)]";
override define $(HEADERS) =
	$(HEADER_L); \
	$(TABLE_C2) "$(_H)$(COMPOSER_FULLNAME)"	"[$(_N)$(COMPOSER_DIR)$(_D)]"; \
	$(TABLE_C2) "---"			"---"; \
	$(foreach FILE,$($(HEADERS)-path-list),\
		$(TABLE_C2) "$(_E)$(FILE)"	"[$(_N)$(if $(filter COMPOSER_ROOT,$(FILE)),$(COMPOSER_ROOT),$(call $(HEADERS)-path-root,$($(FILE))))$(_D)]"; \
	) \
	$(TABLE_C2) "$(_E)MAKECMDGOALS"		"[$(_N)$(MAKECMDGOALS)$(_D)] ($(_M)$(strip $(if $(2),$(2),$(@))$(if $(COMPOSER_DOITALL_$(if $(2),$(2),$(@))),$(_D)-$(_E)$(COMPOSER_DOITALL_$(if $(2),$(2),$(@))))$(_D)))"; \
	$(TABLE_C2) "$(_E)MAKELEVEL"		"[$(_N)$(MAKELEVEL)$(_D)]"; \
	$(foreach FILE,$(if $(or $(COMPOSER_DEBUGIT),$(1)),$(COMPOSER_OPTIONS_MAKE)),\
		$(TABLE_C2) "$(_C)$(FILE)"	"[$(_M)$($(FILE))$(_D)]$(if $(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)), $(_H)$(MARKER))"; \
	) \
	$(HEADER_L)
endef

#> update: $(HEADERS)-run
#>	$(TABLE_M2) "$(_H)$(COMPOSER_FULLNAME)"	"$(_N)$(call $(HEADERS)-path-root,$(COMPOSER_DIR))";
override define $(HEADERS)-run =
	$(LINERULE); \
	$(TABLE_M2) "$(_H)$(COMPOSER_FULLNAME)"	"$(_N)$(COMPOSER_DIR)"; \
	$(TABLE_M2) ":---"			":---"; \
	$(foreach FILE,$($(HEADERS)-path-list),\
		$(TABLE_M2) "$(_E)$(FILE)"	"$(_N)$(if $(filter COMPOSER_ROOT,$(FILE)),$(COMPOSER_ROOT),$(call $(HEADERS)-path-root,$($(FILE))))"; \
	) \
	$(TABLE_M2) "$(_E)MAKECMDGOALS"		"$(_N)$(MAKECMDGOALS)$(_D) ($(_M)$(strip $(if $(2),$(2),$(@))$(if $(COMPOSER_DOITALL_$(if $(2),$(2),$(@))),$(_D)-$(_E)$(COMPOSER_DOITALL_$(if $(2),$(2),$(@))))$(_D)))"; \
	$(TABLE_M2) "$(_E)MAKELEVEL"		"$(_N)$(MAKELEVEL)"; \
	$(foreach FILE,$(if $(or $(COMPOSER_DEBUGIT),$(1)),$(COMPOSER_OPTIONS_PANDOC)),\
		$(eval override OUT := $(strip \
			$(if $(filter c_list,$(FILE)),$(call $(HEADERS)-path-root,$(call c_list_var))$(if $(call c_list_var_source),$(_D) $(_S)\#$(MARKER)$(_D) $(_E)$(call c_list_var_source,,,1)) ,\
			$(if $(filter c_css,$(FILE)),$(call $(HEADERS)-path-root,$(call c_css_select,$(c_type))) ,\
			$(subst ",\",$(call $(HEADERS)-path-root,$($(FILE)))) \
			)) \
		)) \
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$(OUT)$(if $(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)),$(_D)$(if $(OUT), )$(_H)$(MARKER))"; \
	) \
	$(LINERULE)
endef

override define $(HEADERS)-$(SUBDIRS) =
	if [ "$(MAKELEVEL)" = "0" ]; then \
		$(call $(HEADERS)); \
	fi; \
	if [ -n "$(COMPOSER_DOITALL_$(@))" ]; then \
		if [ -z "$(COMPOSER_DEBUGIT)" ]; then \
			$(call $(HEADERS)-dir,$(CURDIR)); \
		else \
			$(call $(HEADERS),1); \
		fi; \
	fi
endef
override define $(HEADERS)-$(COMPOSER_PANDOC) =
	if [ -z "$(COMPOSER_DEBUGIT)" ]; then \
		$(call $(HEADERS)-file,$(CURDIR),$(1)); \
	else \
		$(call $(HEADERS)-run,1,$(1)); \
		$(ECHO) "$(_H)$(MARKER)$(_D) $(_C)"; \
		$(call $(HEADERS)-$(COMPOSER_PANDOC)-PANDOC_OPTIONS,$(2)); \
		$(ECHO) "$(_D)\n"; \
	fi
endef
override define $(HEADERS)-$(COMPOSER_PANDOC)-PANDOC_OPTIONS =
	$(if $(1),\
		$(ECHO) "$(PANDOC) $(subst --,\\\\\n$(CODEBLOCK)--,$(subst ",\",$(subst \,\\\\,$(call PANDOC_OPTIONS)))) \\\\\n$(CODEBLOCK)$(subst $(NULL) , \\\\\n$(CODEBLOCK),$(call c_list_var))" ,\
		$(ECHO) "$(PANDOC) $(subst ",\",$(subst \,\\\\,$(call PANDOC_OPTIONS))) $(call c_list_var)" \
	)
endef

override define $(HEADERS)-action =
	$(if $(or $(5),$(filter $(MAKEJOBS),$(MAKEJOBS_DEFAULT))),$(LINERULE);) \
	$(PRINT) "$(_H)$(MARKER) $(if $(4),$(4),$(@))$(_D) $(DIVIDE) $(_M)$(call $(HEADERS)-path-root,$(1))$(if $(2),$(_D) ($(_E)$(2)$(_D)$(if $(3), $(MARKER) $(_E)$(3)$(_D))))"
endef
override define $(HEADERS)-note =
	$(TABLE_M2) "$(_M)$(MARKER) Processing" "$(_E)$(call $(HEADERS)-path-root,$(1))$(_D) $(DIVIDE) $(if $(4),$(_D)($(_H)$(4)$(_D)) )[$(_C)$(if $(3),$(3),$(@))$(_D)]$(if $(2), $(_C)$(call $(HEADERS)-path-root,$(2)))"
endef
override define $(HEADERS)-dir =
	$(TABLE_M2) "$(_C)$(MARKER) Directory" "$(_E)$(call $(HEADERS)-path-root,$(1))$(if $(2),$(_D) $(DIVIDE) $(if $(3),$(_D)($(_H)$(3)$(_D)) )$(_M)$(call $(HEADERS)-path-root,$(2)))"
endef
override define $(HEADERS)-file =
	$(TABLE_M2) "$(_H)$(MARKER) Creating" "$(_N)$(call $(HEADERS)-path-root,$(1))$(if $(2),$(_D) $(DIVIDE) $(if $(3),$(_D)($(_H)$(3)$(_D)) )$(_M)$(call $(HEADERS)-path-root,$(2)))"
endef
override define $(HEADERS)-skip =
	$(TABLE_M2) "$(_H)$(MARKER) Skipping" "$(_N)$(call $(HEADERS)-path-root,$(1))$(if $(2),$(_D) $(DIVIDE) $(if $(3),$(_D)($(_H)$(3)$(_D)) )$(_C)$(call $(HEADERS)-path-root,$(2)))"
endef
override define $(HEADERS)-rm =
	$(TABLE_M2) "$(_N)$(MARKER) Removing" "$(_N)$(call $(HEADERS)-path-root,$(1))$(if $(2),$(_D) $(DIVIDE) $(if $(3),$(_D)($(_H)$(3)$(_D)) )$(_M)$(call $(HEADERS)-path-root,$(2)))"
endef

################################################################################
# }}}1
################################################################################
# {{{1 Global Targets
################################################################################

########################################
## {{{2 .DEFAULT
########################################

.DEFAULT_GOAL := $(DOITALL)
ifneq ($(COMPOSER_RELEASE),)
.DEFAULT_GOAL := $(HELPOUT)
endif

.DEFAULT:
#>	@$(call $(HEADERS))
	@{ $(call $(HEADERS)); } >&2
	@{	$(LINERULE); \
		$(PRINT) "$(_H)$(MARKER) ERROR"; \
		$(ENDOLINE); \
		$(PRINT) "  * $(_N)Target '$(_C)$(@)$(_N)' is not defined"; \
		$(ENDOLINE); \
		$(PRINT) "$(_H)$(MARKER) DETAILS"; \
		$(ENDOLINE); \
		$(PRINT) "  * This may be the result of a missing input file"; \
		$(PRINT) "  * New targets can be defined in '$(_M)$(COMPOSER_SETTINGS)$(_D)'"; \
		$(PRINT) "  * Use '$(_C)$(TARGETS)$(_D)' to get a list of available targets"; \
		$(PRINT) "  * See '$(_C)$(HELPOUT)$(_D)' or '$(_C)$(HELPOUT)-$(DOITALL)$(_D)' for more information"; \
		$(LINERULE); \
	} >&2
	@exit 1

########################################
## {{{2 $(MAKE_DB)
########################################

.PHONY: $(MAKE_DB)
$(MAKE_DB):
	@$(call ENV_MAKE) $(call COMPOSER_OPTIONS_EXPORT) \
		--question \
		--print-data-base \
		--no-builtin-rules \
		--no-builtin-variables \
	|| $(TRUE)

########################################
## {{{2 $(LISTING)
########################################

.PHONY: $(LISTING)
$(LISTING):
	@$(call ENV_MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(MAKE_DB) \
		| $(SED) -n "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" \
		| $(SED) -n "/^$(COMPOSER_REGEX_PREFIX)?$(COMPOSER_REGEX)[:]+/p" \
		| $(SORT)

########################################
## {{{2 $(NOTHING)
########################################

#> validate: grep -E "[$][(]NOTHING[)][-]" Makefile
override NOTHING_IGNORES := \
	$(TARGETS) \
	$(SUBDIRS) \

#>	$(CONFIGS)-$(TARGETS) \
#>	$(CONFIGS)-$(SUBDIRS) \
#>	$(TARGETS)-$(EXPORTS) \
#>	$(TARGETS)-$(CLEANER) \
#>	$(TARGETS)-$(DOITALL) \
#>	$(NOTHING)-$(TARGETS)-$(HEADERS) \
#>	$(NOTHING)-$(TARGETS)-$(NOTHING)
#>	$(TARGETS) \
#>	$(NOTHING)-$(TARGETS) \
#>	$(NOTHING)-$(TARGETS)-$(SUBDIRS) \
#>	$(SUBDIRS) \
#>	$(NOTHING)-$(SUBDIRS) \
#>	$(MAKEFILE) \
#>	COMPOSER_LOG \
#>	COMPOSER_EXT \
#>	$(COMPOSER_LOG) \

.PHONY: $(NOTHING)
$(NOTHING): .set_title-$(NOTHING)
$(NOTHING):
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(TARGETS)-$(NOTHING)

#> update: $(HEADERS)-note.*$(NOTHING)

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
# {{{1 Release Targets
################################################################################

########################################
## {{{2 $(DISTRIB)
########################################

.PHONY: $(DISTRIB)
$(DISTRIB): .set_title-$(DISTRIB)
$(DISTRIB):
	@$(call $(HEADERS))
	@if [ "$(COMPOSER)" != "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(CP) $(COMPOSER) $(CURDIR)/$(MAKEFILE); \
	fi
	@$(CHMOD) $(CURDIR)/$(MAKEFILE)
	@$(MAKE) --makefile $(COMPOSER) $(UPGRADE)-$(DOITALL)
ifeq ($(COMPOSER_DOITALL_$(DISTRIB)),$(DOITALL))
	@$(MAKE) --makefile $(COMPOSER) $(CREATOR)-$(DOITALL)
	@$(MAKE) --makefile $(COMPOSER) $(PUBLISH)-$(EXAMPLE)
else
	@$(MAKE) --makefile $(COMPOSER) $(CREATOR)
endif

########################################
## {{{2 $(UPGRADE)
########################################

#> update: $(NOTHING)-%

.PHONY: $(UPGRADE)
$(UPGRADE): .set_title-$(UPGRADE)
$(UPGRADE):
	@$(call $(HEADERS))
ifeq ($(and \
	$(wildcard $(firstword $(GIT))) ,\
	$(wildcard $(firstword $(WGET))) ,\
	$(wildcard $(firstword $(TAR))) ,\
	$(wildcard $(firstword $(GZIP_BIN))) ,\
	$(wildcard $(firstword $(7Z))) ,\
	$(wildcard $(firstword $(NPM))) ,\
	$(wildcard $(firstword $(CURL))) \
),)
	@$(if $(wildcard $(firstword $(GIT))),,		$(MAKE) $(NOTHING)-git)
	@$(if $(wildcard $(firstword $(WGET))),,	$(MAKE) $(NOTHING)-wget)
	@$(if $(wildcard $(firstword $(TAR))),,		$(MAKE) $(NOTHING)-tar)
	@$(if $(wildcard $(firstword $(GZIP_BIN))),,	$(MAKE) $(NOTHING)-gzip)
	@$(if $(wildcard $(firstword $(7Z))),,		$(MAKE) $(NOTHING)-7z)
	@$(if $(wildcard $(firstword $(NPM))),,		$(MAKE) $(NOTHING)-npm)
	@$(if $(wildcard $(firstword $(CURL))),,	$(MAKE) $(NOTHING)-curl)
else
ifeq ($(COMPOSER_DOITALL_$(UPGRADE)),$(PRINTER))
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(call GIT_RUN_REPO,$($(FILE)_DIR),diff); \
		$(call NEWLINE) \
	)
else
	@$(MAKE) --makefile $(COMPOSER) \
		$(UPGRADE)-src \
		$(UPGRADE)-bin \
		$(if $(COMPOSER_DOITALL_$(UPGRADE)),\
			$(UPGRADE)-bld \
		)
endif
endif

override $(UPGRADE)-commands := \
	src \
	bin \
	bld \

########################################
### {{{3 $(UPGRADE)-$(NOTHING)
########################################

override define $(UPGRADE)-$(NOTHING) =
.PHONY: $(UPGRADE)-$(1)-$(2)
$(UPGRADE)-$(1)-$(2): $(NOTHING)-$(1)-$(2)
$(UPGRADE)-$(1)-$(2):
	@$$(ECHO) ""
endef

########################################
### {{{3 $(UPGRADE)-$(TARGETS)
########################################

override define $(UPGRADE)-$(TARGETS) =
.PHONY: $(UPGRADE)-$(1)
$(UPGRADE)-$(1): \
	$(foreach FILE,$(REPOSITORIES_LIST),\
		$(UPGRADE)-$(notdir $($(FILE)_DIR))-$(1) \
	)
$(UPGRADE)-$(1):
	@$$(ECHO) ""
endef

$(foreach FILE,$($(UPGRADE)-commands),\
	$(eval $(call $(UPGRADE)-$(TARGETS),$(FILE))) \
)

########################################
### {{{3 $(UPGRADE)-$(DOITALL)
########################################

override define $(UPGRADE)-$(DOITALL) =
.PHONY: $(UPGRADE)-$(notdir $($(1)_DIR))
$(UPGRADE)-$(notdir $($(1)_DIR)): \
	$(foreach FILE,$($(UPGRADE)-commands),\
		$(UPGRADE)-$(notdir $($(1)_DIR))-$(FILE) \
	)
$(UPGRADE)-$(notdir $($(1)_DIR)):
	@$$(ECHO) ""
endef

$(foreach FILE,$(REPOSITORIES_LIST),\
	$(eval $(call $(UPGRADE)-$(DOITALL),$(FILE))) \
)

########################################
### {{{3 $(UPGRADE)-src
########################################

override define $(UPGRADE)-src =
.PHONY: $(UPGRADE)-$(notdir $($(1)_DIR))-src
$(UPGRADE)-$(notdir $($(1)_DIR))-src:
	@$$(call GIT_REPO,$$(call COMPOSER_CONV,$$(CURDIR)/,$$($(1)_DIR)),$$($(1)_SRC),$$($(1)_CMT))
endef

$(foreach FILE,$(REPOSITORIES_LIST),\
	$(if $($(FILE)_CMT),\
		$(eval $(call $(UPGRADE)-src,$(FILE))) ,\
		$(eval $(call $(UPGRADE)-$(NOTHING),$(notdir $($(FILE)_DIR)),src)) \
	) \
)

########################################
### {{{3 $(UPGRADE)-bin
########################################

override define $(UPGRADE)-bin =
.PHONY: $(UPGRADE)-$(notdir $($(1)_DIR))-bin
$(UPGRADE)-$(notdir $($(1)_DIR))-bin: \
	$(foreach FILE,$(OS_VAR_LIST),\
		$(UPGRADE)-$(notdir $($(1)_DIR))-bin-$(OS_VAR_$(FILE)) \
	)
$(UPGRADE)-$(notdir $($(1)_DIR))-bin:
	@$$(ECHO) ""
endef

override define $(UPGRADE)-bin-os =
.PHONY: $(UPGRADE)-$(notdir $($(1)_DIR))-bin-$(OS_VAR_$(2))
#>$(UPGRADE)-$(notdir $($(1)_DIR))-bin-$(OS_VAR_$(2)): $(UPGRADE)-$(notdir $($(1)_DIR))-src
$(UPGRADE)-$(notdir $($(1)_DIR))-bin-$(OS_VAR_$(2)):
	@$$(call WGET_PACKAGE,$$(call COMPOSER_CONV,$$(CURDIR)/,$$($(1)_DIR)),$$($(1)_URL),$$($(1)_$(2)_SRC),$$($(1)_$(2)_DST),$$($(1)_$(2)_BIN),$$($(1)_$(2)_ZIP))
endef

$(foreach FILE,$(REPOSITORIES_LIST),\
	$(eval $(call $(UPGRADE)-bin,$(FILE))) \
	$(foreach VAR,$(OS_VAR_LIST),\
		$(if $($(FILE)_$(VAR)_SRC),\
			$(eval $(call $(UPGRADE)-bin-os,$(FILE),$(VAR))) ,\
			$(eval $(call $(UPGRADE)-$(NOTHING),$(notdir $($(FILE)_DIR)),bin-$(OS_VAR_$(VAR)))) \
		) \
	) \
)

########################################
### {{{3 $(UPGRADE)-bld
########################################

override define $(UPGRADE)-bld =
.PHONY: $(UPGRADE)-$(notdir $($(1)_DIR))-bld
$(UPGRADE)-$(notdir $($(1)_DIR))-bld: $(UPGRADE)-$(notdir $($(1)_DIR))-src
$(UPGRADE)-$(notdir $($(1)_DIR))-bld:
	@$$(MAKE) --makefile $(COMPOSER) $$(UPGRADE)-$$(notdir $$($(1)_DIR))-bld-fetch
	@$$(MAKE) --makefile $(COMPOSER) $$(UPGRADE)-$$(notdir $$($(1)_DIR))-bld-build
endef

override $(UPGRADE)-bld-list :=

override $(UPGRADE)-bld-list += BOOTLINT

.PHONY: $(UPGRADE)-$(notdir $(BOOTLINT_DIR))-bld-fetch
$(UPGRADE)-$(notdir $(BOOTLINT_DIR))-bld-fetch:
	@$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTLINT_DIR)))

.PHONY: $(UPGRADE)-$(notdir $(BOOTLINT_DIR))-bld-build
$(UPGRADE)-$(notdir $(BOOTLINT_DIR))-bld-build:
	@$(call $(HEADERS)-action,$(BOOTLINT_DIR),build)
	@$(LN)										$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTLINT_DIR))/src/cli-main.js \
											$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTLINT_DIR))/bootlint

override $(UPGRADE)-bld-list += WATERCSS

.PHONY: $(UPGRADE)-$(notdir $(WATERCSS_DIR))-bld-fetch
$(UPGRADE)-$(notdir $(WATERCSS_DIR))-bld-fetch:
	@$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR)))
	@$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR)),yarn)

.PHONY: $(UPGRADE)-$(notdir $(WATERCSS_DIR))-bld-build
$(UPGRADE)-$(notdir $(WATERCSS_DIR))-bld-build:
	@$(call $(HEADERS)-action,$(WATERCSS_DIR),build)
	@$(SED) -i \
		-e "/^dist[/]$$/d" \
		-e "/^out[/]$$/d" \
											$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/.gitignore
	@$(call HEREDOC_CUSTOM_HTML_CSS_WATER_CSS_HACK)					$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/parts/*.css
	@$(foreach FILE,light dark,\
		$(call DO_HEREDOC,HEREDOC_CUSTOM_HTML_CSS_WATER_SRC_SOLAR,,$(FILE))	>$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/builds/solarized-$(FILE).css; \
		$(call DO_HEREDOC,HEREDOC_CUSTOM_HTML_CSS_WATER_VAR_SOLAR,,$(FILE))	>$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/variables-solarized-$(FILE).css; \
		$(call NEWLINE) \
	)
	@$(CP)										$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/builds/water.css \
											$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/builds/water-all.css
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_HTML_CSS_WATER_VAR_OVERLAY)			>>$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/builds/water-all.css
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_HTML_CSS_WATER_SRC_SOLAR,,light)		>$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/builds/solarized-all.css
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_HTML_CSS_WATER_SRC_SOLAR,,dark:1)		>>$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR))/src/builds/solarized-all.css
	@$(call NPM_RUN,$(call COMPOSER_CONV,$(CURDIR)/,$(WATERCSS_DIR)),,yarn) build

override $(UPGRADE)-bld-list += MDVIEWER

.PHONY: $(UPGRADE)-$(notdir $(MDVIEWER_DIR))-bld-fetch
$(UPGRADE)-$(notdir $(MDVIEWER_DIR))-bld-fetch:
#>	@$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR)))
	@$(call MDVIEWER_MODULES) | while read -r FILE; do \
		$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR))/build/$${FILE}); \
	done

.PHONY: $(UPGRADE)-$(notdir $(MDVIEWER_DIR))-bld-build
$(UPGRADE)-$(notdir $(MDVIEWER_DIR))-bld-build:
	@$(call $(HEADERS)-action,$(MDVIEWER_DIR),build)
	@$(MKDIR)									$(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR))/vendor
	@$(LN)										$(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR))/$(MDVIEWER_MANIFEST) \
											$(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR))/manifest.json
	@$(call MDVIEWER_MODULES) | while read -r FILE; do \
		$(call NPM_BUILD,$(call COMPOSER_CONV,$(CURDIR)/,$(MDVIEWER_DIR))/build/$${FILE}); \
	done

override $(UPGRADE)-bld-list += FIREBASE

.PHONY: $(UPGRADE)-$(notdir $(FIREBASE_DIR))-bld-fetch
$(UPGRADE)-$(notdir $(FIREBASE_DIR))-bld-fetch:
#>	@$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(FIREBASE_DIR)))
	@$(call NPM_INSTALL,$(call COMPOSER_CONV,$(CURDIR)/,$(FIREBASE_DIR)),$(notdir $(FIREBASE_DIR))@$(FIREBASE_VER))

.PHONY: $(UPGRADE)-$(notdir $(FIREBASE_DIR))-bld-build
$(UPGRADE)-$(notdir $(FIREBASE_DIR))-bld-build: $(NOTHING)-$(notdir $(FIREBASE_DIR))-bld-build
$(UPGRADE)-$(notdir $(FIREBASE_DIR))-bld-build:
	@$(ECHO) ""

override $(UPGRADE)-bld-list +=

$(foreach FILE,$(REPOSITORIES_LIST),\
	$(eval $(call $(UPGRADE)-bld,$(FILE))) \
	$(if $(filter $(FILE),$($(UPGRADE)-bld-list)),,\
		$(eval $(call $(UPGRADE)-$(NOTHING),$(notdir $($(FILE)_DIR)),bld-fetch)) \
		$(eval $(call $(UPGRADE)-$(NOTHING),$(notdir $($(FILE)_DIR)),bld-build)) \
	) \
)

########################################
## {{{2 $(CREATOR)
########################################

#> update: TYPE_TARGETS

.PHONY: $(CREATOR)
$(CREATOR): .set_title-$(CREATOR)
$(CREATOR):
	@$(call $(HEADERS))
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_BASENAME) Directory)
endif
	@$(ECHO) "$(_S)"
	@$(MKDIR) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ART)) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES)) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT)) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(abspath $(dir $(BOOTSTRAP_DEF_JS)))) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(abspath $(dir $(COMPOSER_CUSTOM)))) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(abspath $(dir $(call CUSTOM_PUBLISH_CSS_OVERLAY,$(CREATOR))))) \
		$(call COMPOSER_CONV,$(CURDIR)/,$(abspath $(dir $(call CSS_THEME,$(CREATOR))))) \
		$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(CREATOR)) \
		$($(CREATOR)-$(TARGETS))

override $(CREATOR)-$(TARGETS) :=

########################################
#### {{{3 $(CREATOR)-$(CONFIGS)
########################################

ifneq ($(COMPOSER_RELEASE),)
ifneq ($(COMPOSER_DOITALL_$(CREATOR)),)
override $(CREATOR)-$(TARGETS) += $(CREATOR)-$(CONFIGS)
endif
endif

.PHONY: $(CREATOR)-$(CONFIGS)
$(CREATOR)-$(CONFIGS):
	@$(call $(HEADERS)-file,$(CURDIR),$(CONFIGS))
	@$(call DO_HEREDOC,HEREDOC_GITATTRIBUTES)	| $(SED) "s|[[:space:]]+$$||g" >$(CURDIR)/.gitattributes
	@$(call DO_HEREDOC,HEREDOC_GITIGNORE)		| $(SED) "s|[[:space:]]+$$||g" >$(CURDIR)/.gitignore
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK,1)	| $(SED) "s|[[:space:]]+$$||g" >$(CURDIR)/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(_E)"
	@$(RM) \
							$(CURDIR)/$(COMPOSER_YML) \
							$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

########################################
#### {{{3 $(CREATOR)-$(OUT_README)
########################################

override $(CREATOR)-$(TARGETS) += $(CREATOR)-$(OUT_README)

.PHONY: $(CREATOR)-$(OUT_README)
$(CREATOR)-$(OUT_README):
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_README)$(COMPOSER_EXT_DEFAULT))
	@$(call ENV_MAKE) --directory $(COMPOSER_DIR) $(HELPOUT)-$(HELPOUT) \
		| $(SED) -e "/^[#][>]/d" -e "s|[[:space:]]+$$||g" \
		>$(CURDIR)/$(OUT_README)$(COMPOSER_EXT_DEFAULT)

########################################
#### {{{3 $(CREATOR)-$(OUT_README).$(PUBLISH)
########################################

ifneq ($(COMPOSER_RELEASE),)
ifneq ($(COMPOSER_DOITALL_$(CREATOR)),)
override $(CREATOR)-$(TARGETS) += $(CREATOR)-$(OUT_README).$(PUBLISH)
endif
endif

.PHONY: $(CREATOR)-$(OUT_README).$(PUBLISH)
$(CREATOR)-$(OUT_README).$(PUBLISH):
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT))
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_README) \
		| $(SED) "s|[[:space:]]+$$||g" \
		>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH).yml
	@$(ECHO) "$(_E)"
	@$(LN)	$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH).yml \
		$(CURDIR)/$(OUT_README).$(PUBLISH).$(EXTN_HTML).yml \
		$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call ENV_MAKE) --directory $(COMPOSER_DIR) $(HELPOUT)-$(PUBLISH) \
		| $(SED) -e "/^[#][>]/d" -e "s|[[:space:]]+$$||g" \
		>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ART))/$(OUT_README).$(PUBLISH)$(COMPOSER_EXT_DEFAULT)

########################################
#### {{{3 $(CREATOR)-$(OUT_README).$(TYPE_PRES)
########################################

ifneq ($(COMPOSER_RELEASE),)
ifneq ($(COMPOSER_DOITALL_$(CREATOR)),)
override $(CREATOR)-$(TARGETS) += $(CREATOR)-$(OUT_README).$(TYPE_PRES)
endif
endif

.PHONY: $(CREATOR)-$(OUT_README).$(TYPE_PRES)
$(CREATOR)-$(OUT_README).$(TYPE_PRES):
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT))
	@$(call ENV_MAKE) --directory $(COMPOSER_DIR) $(HELPOUT)-$(TYPE_PRES) \
		| $(SED) -e "/^[#][>]/d" -e "s|[[:space:]]+$$||g" \
		>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ART))/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT)

########################################
#### {{{3 $(CREATOR)-$(OUT_LICENSE)
########################################

override $(CREATOR)-$(TARGETS) += $(CREATOR)-$(OUT_LICENSE)

.PHONY: $(CREATOR)-$(OUT_LICENSE)
$(CREATOR)-$(OUT_LICENSE):
	@$(call $(HEADERS)-file,$(CURDIR),$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT))
	@$(call DO_HEREDOC,HEREDOC_LICENSE) \
		| $(SED) -e "/^[#][>]/d" -e "s|[[:space:]]+$$||g" \
		>$(CURDIR)/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)

########################################
#### {{{3 $(CREATOR)-$(COMPOSER_ART)
########################################

override $(CREATOR)-$(TARGETS) += $(CREATOR)-.$(notdir $(COMPOSER_ART))

.PHONY: $(CREATOR)-.$(notdir $(COMPOSER_ART))
$(CREATOR)-.$(notdir $(COMPOSER_ART)):
	@$(call $(HEADERS)-file,$(CURDIR),$(call COMPOSER_CONV,,$(COMPOSER_ART)))
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML,1)			>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ART))/$(COMPOSER_YML)
	@$(ECHO) "$(_E)"
	@$(ECHO) ""							>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_LOGO))
	@$(ECHO) "$(DIST_LOGO_$(COMPOSER_LOGO_VER))"	| $(BASE64)	>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/logo-$(COMPOSER_LOGO_VER).png
	@$(ECHO) ""							>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_ICON))
#>	@$(ECHO) "$(DIST_ICON_$(COMPOSER_ICON_VER))"	| $(BASE64)	>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/icon-$(COMPOSER_ICON_VER).png
	@$(LN)								$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/logo-$(COMPOSER_LOGO_VER).png \
									$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/icon-$(COMPOSER_ICON_VER).png \
									$($(DEBUGIT)-output)
	@$(ECHO) "$(DIST_SCREENSHOT_v1.0)"		| $(BASE64)	>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/screenshot-v1.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v3.0)"		| $(BASE64)	>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/screenshot-v3.0.png
	@$(ECHO) "$(DIST_SCREENSHOT_v4.0)"		| $(BASE64)	>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/screenshot-v4.0.png
	@$(foreach CSS_ICON,$(call CSS_ICONS),\
		$(eval override NAME := $(word 1,$(subst ;, ,$(CSS_ICON)))) \
		$(eval override TYPE := $(word 2,$(subst ;, ,$(CSS_ICON)))) \
		$(eval override FILE := $(word 3,$(subst ;, ,$(CSS_ICON)))) \
		$(call NEWLINE) \
		if [ -f "$(FILE)" ]; then \
			$(LN) $(FILE)					$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/icon.$(NAME).$(TYPE) $($(DEBUGIT)-output); \
		else \
			$(ECHO) "$(FILE)"		| $(BASE64)	>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_IMAGES))/icon.$(NAME).$(TYPE); \
		fi; \
		$(call NEWLINE) \
	)
#> update: HEREDOC_CUSTOM_PUBLISH
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_SH)			| $(SED) -e "s|[[:space:]]+$$||g" -e "/$(TOKEN)$$/d" >$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PUBLISH_SH))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS)			>$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PUBLISH_CSS))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_OVERLAY,,light)	>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,light))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_OVERLAY,,dark)	>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,dark))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_THEME)		>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,custom))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_THEME)		| $(SED) "s|^(.*--$(COMPOSER_TINYNAME)-[^:]+[:][[:space:]]+).*(var[(]--solarized.+)$$|\1\2|g" \
									>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,custom-solar))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_TESTING)		>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,$(TESTING)))
#> update: HEREDOC_CUSTOM_PUBLISH
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_HTML_CSS)			>$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_HTML_CSS))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PDF_LATEX)			>$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PDF_LATEX))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_REVEALJS_CSS)			>$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_REVEALJS_CSS))
	@$(LN) $(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PUBLISH_CSS))	$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_CUSTOM))-$(PUBLISH).css $($(DEBUGIT)-output)
	@$(LN) $(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_HTML_CSS))	$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_CUSTOM))-$(TYPE_HTML).css $($(DEBUGIT)-output)
	@$(LN) $(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PDF_LATEX))	$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_CUSTOM))-$(TYPE_LPDF).header $($(DEBUGIT)-output)
	@$(LN) $(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_REVEALJS_CSS))	$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_CUSTOM))-$(TYPE_PRES).css $($(DEBUGIT)-output)
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_JS_PRE)		>$(call COMPOSER_CONV,$(CURDIR)/,$(patsubst %.js,%-pre.js,$(BOOTSTRAP_ART_JS)))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_JS_POST)		>$(call COMPOSER_CONV,$(CURDIR)/,$(patsubst %.js,%-post.js,$(BOOTSTRAP_ART_JS)))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_PRE)		>$(call COMPOSER_CONV,$(CURDIR)/,$(patsubst %.css,%-pre.css,$(BOOTSTRAP_ART_CSS)))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_POST)		>$(call COMPOSER_CONV,$(CURDIR)/,$(patsubst %.css,%-post.css,$(BOOTSTRAP_ART_CSS)))
	@$(LN) $(BOOTSTRAP_DIR_JS)					$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTSTRAP_DEF_JS)) $($(DEBUGIT)-output)
	@$(CP) $(BOOTSTRAP_DIR_JS)					$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTSTRAP_ART_JS)) $($(DEBUGIT)-output)
	@$(LN) $(BOOTSTRAP_DIR_CSS)					$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTSTRAP_DEF_CSS)) $($(DEBUGIT)-output)
	@$(CP) $(BOOTSTRAP_DIR_CSS)					$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTSTRAP_ART_CSS)) $($(DEBUGIT)-output)
	@$(call HEREDOC_CUSTOM_PUBLISH_CSS_HACK)			$(call COMPOSER_CONV,$(CURDIR)/,$(BOOTSTRAP_ART_CSS))
	@$(SED) -i 's&HEREDOC_CUSTOM_PUBLISH_CSS_HACK&$(strip \
		$(patsubst $(word 1,$(SED))%,$(notdir $(word 1,$(SED)))%,$(call HEREDOC_CUSTOM_PUBLISH_CSS_HACK)) \
		) $(call COMPOSER_CONV,$(EXPAND)/,$(BOOTSTRAP_ART_CSS))&g' \
									$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,light)) \
									$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,dark))
#> update: FILE.*CSS_THEMES
	@$(foreach FILE,$(call CSS_THEMES),$(if $(filter-out $(TOKEN);%,$(FILE)),\
		$(eval override FTYPE := $(word 1,$(subst ;, ,$(FILE)))) \
		$(eval override THEME := $(word 2,$(subst ;, ,$(FILE)))) \
		$(eval override SFILE := $(word 3,$(subst ;, ,$(FILE)))) \
		$(eval override OVRLY := $(word 4,$(subst ;, ,$(FILE)))) \
		$(eval override TITLE := $(word 5,$(subst ;, ,$(FILE)))) \
		$(eval override DEFLT := $(word 6,$(subst ;, ,$(FILE)))) \
		$(eval override FEXTN := $(if $(filter $(FTYPE),$(TYPE_PRES)),$(EXTN_PRES),$(EXTN_HTML))) \
		$(if $(filter $(SPECIAL_VAL),$(THEME)),\
			$(filter-out --relative,$(LN))			$(notdir $(SFILE)) ,\
			$(LN)						$(SFILE) \
		)							$(call COMPOSER_CONV,$(CURDIR)/,$(call CSS_THEME,$(FTYPE),$(THEME))) \
									$($(DEBUGIT)-output); \
		$(call NEWLINE) \
	))
	@$(foreach TYPE,$(TYPE_TARGETS_LIST),\
		$(foreach FILE,\
			template \
			reference \
			,\
			$(PANDOC_BIN) --verbose \
				--output="$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE)-default.$(TMPL_$(TYPE))" \
				$(if $(filter $(FILE),template),--print-default-template="$(TMPL_$(TYPE))" ,\
								--print-default-data-file="$(FILE).$(TMPL_$(TYPE))" \
				) 2>/dev/null || $(TRUE); \
			if	[   -f "$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE)-default.$(TMPL_$(TYPE))" ] && \
				[ ! -f "$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE).$(TMPL_$(TYPE))" ]; then \
				if [ "$(FILE).$(TMPL_$(TYPE))" = "template.$(TMPL_HTML)" ]; then \
					$(SED) "/IE 9/,/endif/d" \
						$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE)-default.$(TMPL_$(TYPE)) \
						>$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE).$(TMPL_$(TYPE)); \
				else \
					$(LN) \
						$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE)-default.$(TMPL_$(TYPE)) \
						$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(FILE).$(TMPL_$(TYPE)) \
						$($(DEBUGIT)-output); \
				fi; \
			fi; \
		) \
		$(call NEWLINE) \
	)
	@$(foreach FILE,\
		templates/styles.html \
		epub.css \
		,\
		$(PANDOC_BIN) --verbose \
			--output="$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(subst .,-default.,$(notdir $(FILE)))" \
			--print-default-data-file="$(FILE)" \
			2>/dev/null; \
			if	[   -f "$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(subst .,-default.,$(notdir $(FILE)))" ] && \
				[ ! -f "$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(notdir $(FILE))" ]; then \
				$(LN) \
					$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(subst .,-default.,$(notdir $(FILE))) \
					$(call COMPOSER_CONV,$(CURDIR)/,$(COMPOSER_DAT))/$(notdir $(FILE)) \
					$($(DEBUGIT)-output); \
			fi; \
		$(call NEWLINE) \
	)
	@$(ECHO) "$(_D)"

########################################
#### {{{3 $(CREATOR)-$(COMPOSER_BASENAME)
########################################

ifneq ($(COMPOSER_RELEASE),)
ifneq ($(COMPOSER_DOITALL_$(CREATOR)),)
override $(CREATOR)-$(TARGETS) += $(CREATOR)-$(COMPOSER_BASENAME)
endif
endif

.PHONY: $(CREATOR)-$(COMPOSER_BASENAME)
$(CREATOR)-$(COMPOSER_BASENAME): $(filter-out $(CREATOR)-$(COMPOSER_BASENAME),$($(CREATOR)-$(TARGETS)))
$(CREATOR)-$(COMPOSER_BASENAME):
ifeq ($(COMPOSER_DEBUGIT),)
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT)) $(CLEANER)
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT)) $(DOITALL)
else
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT)) $(OUT_README).$(PUBLISH).$(EXTN_HTML)
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT)) $(OUT_README).$(EXTN_HTML)
endif
	@$(ECHO) "$(_E)"
	@$(LN)	$(CURDIR)/$(OUT_README).$(PUBLISH).$(EXTN_HTML) \
		$(CURDIR)/$(PUBLISH_INDEX).$(EXTN_HTML) \
		$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

################################################################################
# {{{1 Debug Targets
################################################################################

########################################
## {{{2 $(DEBUGIT)
########################################

ifneq ($(filter $(DEBUGIT)-file,$(MAKECMDGOALS)),)
export override COMPOSER_DOITALL_$(DEBUGIT) := file
export override DEBUGIT_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(DEBUGIT))
endif
.PHONY: $(DEBUGIT)-file
$(DEBUGIT)-file: .set_title-$(DEBUGIT)-file
$(DEBUGIT)-file:
	@$(MAKE) $(HEADERS)-$(DEBUGIT)
	@$(MAKE) $(DEBUGIT)-$(HEADERS)
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) Printing to file$(_D) $(DIVIDE) $(_M)$(notdir $(DEBUGIT_FILE))"
	@$(PRINT) "$(_H)$(MARKER) This may take a few minutes..."
	@$(ENDOLINE)
	@$(ECHO) '# $(subst ','"'"',$(subst \,\\,$(VIM_OPTIONS)))\n' >$(DEBUGIT_FILE)
	@$(call ENV_MAKE,,,$(COMPOSER_DEBUGIT)) \
		COMPOSER_DOITALL_$(DEBUGIT)="$(COMPOSER_DOITALL_$(DEBUGIT))" \
		COMPOSER_DOITALL_$(TESTING)="$(DEBUGIT)" \
		$(DEBUGIT) 2>&1 \
		| $(TEE) --append $(DEBUGIT_FILE) \
		| $(SED) "s|^.*$$||g" \
		| $(TR) '\n' '.'
	@$(ENDOLINE)
	@$(TAIL) -n10 $(DEBUGIT_FILE)
	@$(LS) $(DEBUGIT_FILE)

#> update: $(NOTHING)-%
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
ifeq ($(and \
	$(wildcard $(firstword $(GIT))) ,\
	$(wildcard $(firstword $(DIFF))) ,\
	$(wildcard $(firstword $(RSYNC))) \
),)
$(if $(wildcard $(firstword $(GIT))),,		$(eval $(DEBUGIT): $(NOTHING)-git))
$(if $(wildcard $(firstword $(DIFF))),,		$(eval $(DEBUGIT): $(NOTHING)-diff))
$(if $(wildcard $(firstword $(RSYNC))),,	$(eval $(DEBUGIT): $(NOTHING)-rsync))
else
$(DEBUGIT): $(DEBUGIT)-CHECKIT
$(DEBUGIT): $(DEBUGIT)-CONFIGS
$(DEBUGIT): $(DEBUGIT)-TARGETS
$(DEBUGIT): $(DEBUGIT)-COMPOSER_DEBUGIT
ifneq ($(COMPOSER_DOITALL_$(DEBUGIT)),)
ifneq ($(COMPOSER_DOITALL_$(DEBUGIT)),$(TESTING))
$(DEBUGIT): $(DEBUGIT)-MARKER-TESTING
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
ifneq ($(COMPOSER_DOITALL_$(DEBUGIT)),)
$(DEBUGIT): $(DEBUGIT)-MARKER-FOOTER
endif
ifneq ($(COMPOSER_DOITALL_$(DEBUGIT)),$(TESTING))
$(DEBUGIT): $(HELPOUT)-FOOTER
endif
endif
$(DEBUGIT):
	@$(ECHO) ""

########################################
### {{{3 $(DEBUGIT)-$(@)
########################################

.PHONY: $(DEBUGIT)-$(HEADERS)
$(DEBUGIT)-$(HEADERS):
	@{	$(LINERULE); \
		$(PRINT) "$(_H)$(MARKER) DEBUGIT"; \
		$(ENDOLINE); \
		$(PRINT) "  * $(_N)This is the output of the '$(_C)$(DEBUGIT)$(_N)' target"; \
		$(ENDOLINE); \
		$(PRINT) "$(_H)$(MARKER) DETAILS"; \
		$(ENDOLINE); \
		$(PRINT) "  * It runs several targets and diagnostic commands"; \
		$(PRINT) "  * All information needed for troubleshooting is included"; \
		$(PRINT) "  * Use '$(_C)COMPOSER_DEBUGIT$(_D)' to test a list of targets $(_E)(they may be run)$(_D)"; \
		$(PRINT) "  * Use '$(_C)$(DEBUGIT)-file$(_D)' to create a text file with the results"; \
		$(LINERULE); \
	}

.PHONY: $(DEBUGIT)-%
$(DEBUGIT)-%:
	@if [ "$(*)" = "$(patsubst MARKER-%,%,$(*))" ]; then \
		$(call TITLE_LN ,1,$(call VIM_FOLDING) $(MARKER)[ $(*) $(DIVIDE) $($(*)) ]$(MARKER)); \
	fi
	@if [ "$(*)" != "$(patsubst MARKER-%,%,$(*))" ]; then \
		$(ENDOLINE); \
		$(LINERULE); \
		$(ENDOLINE); \
		$(PRINT) "# $(call VIM_FOLDING,,1) $(*)"; \
	elif [ "$(*)" = "COMPOSER_DEBUGIT" ]; then \
		$(MAKE) $(NOFAIL) COMPOSER_DEBUGIT="$(SPECIAL_VAL)" $($(*)) 2>&1 || $(TRUE); \
	else \
		for FILE in $($(*)); do \
			if [ -d "$${FILE}" ]; then \
				$(call TITLE_LN ,2,$(call VIM_FOLDING,2) $(MARKER)[ $(*) $(DIVIDE) $${FILE} ]$(MARKER)); \
				$(LS) --recursive $${FILE}; \
			elif [ -f "$${FILE}" ]; then \
				$(call TITLE_LN ,2,$(call VIM_FOLDING,2) $(MARKER)[ $(*) $(DIVIDE) $${FILE} ]$(MARKER)); \
				$(CAT) $${FILE}; \
			else \
				$(MAKE) $(NOFAIL) COMPOSER_DEBUGIT= $${FILE} 2>&1 || $(TRUE); \
			fi; \
		done; \
	fi

########################################
## {{{2 $(TESTING)
########################################

ifneq ($(filter $(TESTING)-file,$(MAKECMDGOALS)),)
export override COMPOSER_DOITALL_$(TESTING) := file
export override TESTING_FILE := $(CURDIR)/$(call OUTPUT_FILENAME,$(TESTING))
endif
.PHONY: $(TESTING)-file
$(TESTING)-file: .set_title-$(TESTING)-file
$(TESTING)-file:
	@$(MAKE) $(HEADERS)-$(TESTING)
	@$(MAKE) $(TESTING)-$(HEADERS)
	@$(ENDOLINE)
	@$(PRINT) "$(_H)$(MARKER) Printing to file$(_D) $(DIVIDE) $(_M)$(notdir $(TESTING_FILE))"
	@$(PRINT) "$(_H)$(MARKER) This may take a few minutes..."
	@$(ENDOLINE)
	@$(ECHO) '# $(subst ','"'"',$(subst \,\\,$(VIM_OPTIONS)))\n' >$(TESTING_FILE)
	@$(call ENV_MAKE,,,$(COMPOSER_DEBUGIT)) \
		COMPOSER_DOITALL_$(DEBUGIT)="$(TESTING)" \
		COMPOSER_DOITALL_$(TESTING)="$(COMPOSER_DOITALL_$(TESTING))" \
		$(TESTING) 2>&1 \
		| $(TEE) --append $(TESTING_FILE) \
		| $(SED) "s|^.*$$||g" \
		| $(TR) '\n' '.'
	@$(ENDOLINE)
	@$(TAIL) -n10 $(TESTING_FILE)
	@$(LS) $(TESTING_FILE)

#> update: $(NOTHING)-%
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
ifeq ($(and \
	$(wildcard $(firstword $(GIT))) ,\
	$(wildcard $(firstword $(DIFF))) ,\
	$(wildcard $(firstword $(RSYNC))) \
),)
$(if $(wildcard $(firstword $(GIT))),,		$(eval $(TESTING): $(NOTHING)-git))
$(if $(wildcard $(firstword $(DIFF))),,		$(eval $(TESTING): $(NOTHING)-diff))
$(if $(wildcard $(firstword $(RSYNC))),,	$(eval $(TESTING): $(NOTHING)-rsync))
else
$(TESTING): $(TESTING)-$(HEADERS)-CHECKIT
$(TESTING): $(TESTING)-$(HEADERS)-CONFIGS
#>ifneq ($(COMPOSER_DOITALL_$(TESTING)),)
#>ifneq ($(COMPOSER_DOITALL_$(TESTING)),$(DEBUGIT))
#>$(TESTING): $(DEBUGIT)-MARKER-DEBUGIT
#>$(TESTING): $(TESTING)-$(HEADERS)-DEBUGIT
#>endif
#>endif
$(TESTING): $(TESTING)-Think
$(TESTING): $(TESTING)-$(DISTRIB)
#>$(TESTING): $(TESTING)-heredoc
#>$(TESTING): $(TESTING)-speed
$(TESTING): $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING): $(TESTING)-$(TARGETS)
$(TESTING): $(TESTING)-$(INSTALL)
$(TESTING): $(TESTING)-$(CLEANER)-$(DOITALL)
$(TESTING): $(TESTING)-COMPOSER_INCLUDE
$(TESTING): $(TESTING)-COMPOSER_DEPENDS
$(TESTING): $(TESTING)-COMPOSER_EXPORTS
$(TESTING): $(TESTING)-COMPOSER_IGNORES
$(TESTING): $(TESTING)-CSS
$(TESTING): $(TESTING)-$(COMPOSER_LOG_DEFAULT)$(COMPOSER_EXT_DEFAULT)
$(TESTING): $(TESTING)-other
$(TESTING): $(TESTING)-$(EXAMPLE)
ifneq ($(COMPOSER_DOITALL_$(TESTING)),)
$(TESTING): $(DEBUGIT)-MARKER-FOOTER
endif
ifneq ($(COMPOSER_DOITALL_$(TESTING)),$(DEBUGIT))
$(TESTING): $(HELPOUT)-FOOTER
endif
endif
$(TESTING):
	@$(ECHO) ""

########################################
### {{{3 $(TESTING)-$(@)
########################################

.PHONY: $(TESTING)-$(HEADERS)
$(TESTING)-$(HEADERS):
	@{	$(LINERULE); \
		$(PRINT) "$(_H)$(MARKER) TESTING"; \
		$(ENDOLINE); \
		$(PRINT) "  * $(_N)This is the output of the '$(_C)$(TESTING)$(_N)' target"; \
		$(ENDOLINE); \
		$(PRINT) "$(_H)$(MARKER) DETAILS"; \
		$(ENDOLINE); \
		$(PRINT) "  * It runs test cases for all supported functionality $(_E)(some are interactive)$(_D)"; \
		$(PRINT) "  * All cases are run in the '$(_M)$(patsubst $(COMPOSER_DIR)/%,%,$(TESTING_DIR))$(_D)' directory"; \
		$(PRINT) "  * It has a dedicated '$(_M)$(TESTING_COMPOSER_DIR)$(_D)', and '$(_C)$(DOMAKE)$(_D)' can be run anywhere in the tree"; \
		$(PRINT) "  * Use '$(_C)$(TESTING)-file$(_D)' to create a text file with the results"; \
		$(LINERULE); \
	}

.PHONY: $(TESTING)-$(HEADERS)-%
$(TESTING)-$(HEADERS)-%:
	@$(call TITLE_LN ,1,$(call VIM_FOLDING) $(MARKER)[ $($(*)) ]$(MARKER))
	@$(MAKE) $($(*)) 2>&1

.PHONY: $(TESTING)-dir
$(TESTING)-dir: $(TESTING)-$(DISTRIB)
$(TESTING)-dir:
	@$(ECHO) ""

.PHONY: $(TESTING)-$(PRINTER)
$(TESTING)-$(PRINTER):
	@$(MAKE) $(LISTING) \
		| $(SED) -n "s|[:][ ]$(TESTING)-Think||gp" \
		| $(SORT)

########################################
### {{{3 $(TESTING)-%
########################################

override $(TESTING)-pwd			= $(abspath $(TESTING_DIR)/$(patsubst %-init,%,$(patsubst %-done,%,$(if $(1),$(1),$(@)))))
override $(TESTING)-log			= $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(TESTING_LOGFILE)
override $(TESTING)-make		= $(call $(INSTALL)-$(MAKEFILE),$(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/$(MAKEFILE),-$(INSTALL),$(2),1)
override $(TESTING)-run			= $(call ENV_MAKE,$(2),$(COMPOSER_DOCOLOR),,COMPOSER_DOITALL_$(TESTING)) --directory $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))

override define $(TESTING)-$(HEADERS) =
	$(call TITLE_LN ,1,$(call VIM_FOLDING) $(MARKER)[ $(patsubst $(TESTING)-%,%,$(@)) ]$(MARKER)); \
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
	$(call $(TESTING)-make,$(if $(1),$(1),$(@)),$(TESTING_COMPOSER_MAKEFILE)); \
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
			--delete-excluded \
			--filter="-_/$(TESTING_LOGFILE)" \
			--filter="P_/$(TESTING_LOGFILE)" \
			$(foreach VAR,$(OS_VAR_LIST),--filter="-_/$(PANDOC_$(VAR)_BIN)") \
			--filter="-_/test" \
			$(PANDOC_DIR)/ \
			$(call $(TESTING)-pwd,$(if $(1),$(1),$(@))); \
		$(call $(TESTING)-make,$(if $(1),$(1),$(@)),$(TESTING_COMPOSER_MAKEFILE)); \
	fi; \
	$(call $(TESTING)-run,$(if $(1),$(1),$(@)),$(TESTING_MAKEJOBS)) $(INSTALL)-$(DOFORCE)
endef

#> update: $(TESTING_DIR).*$(COMPOSER_ROOT)
override define $(TESTING)-init =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) INIT [$(@)]:"; \
	$(MKDIR) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@))); \
	$(ECHO) "" >$(call $(TESTING)-log,$(if $(1),$(1),$(@))); \
	if [ -n "$(COMPOSER_DEBUGIT)" ]; then \
		$(TOUCH) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/.$(DEBUGIT); \
	else \
		$(RM) $(call $(TESTING)-pwd,$(if $(1),$(1),$(@)))/.$(DEBUGIT); \
	fi; \
	if [ "$(@)" = "$(TESTING)-Think" ]; then \
		$(MKDIR) $(abspath $(dir $(TESTING_COMPOSER_MAKEFILE))); \
		$(CP) $(COMPOSER) $(TESTING_COMPOSER_MAKEFILE); \
	else \
		$(call $(TESTING)-make,$(if $(1),$(1),$(@)),$(TESTING_COMPOSER_MAKEFILE)); \
	fi; \
	$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),,COMPOSER_DOITALL_$(TESTING)) $(@)-init 2>&1 | $(TEE) $(call $(TESTING)-log,$(if $(1),$(1),$(@))); \
	if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
endef

override define $(TESTING)-done =
	$(ENDOLINE); \
	$(PRINT) "$(_M)$(MARKER) DONE [$(@)]"; \
	$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),,COMPOSER_DOITALL_$(TESTING)) $(@)-done 2>&1
endef

override define $(TESTING)-find =
	$(SED) -n "/$(1)/p" $(call $(TESTING)-log,$(if $(2),$(2),$(@))); \
	if [ $(if $(3),-n,-z) "$(shell $(SED) -n "/$(1)/p" $(call $(TESTING)-log,$(if $(2),$(2),$(@))) | $(SED) "s|[$$]|.|g")" ]; then \
		$(call $(TESTING)-fail); \
	fi
endef

override define $(TESTING)-count =
	$(SED) -n "/$(2)/p" $(call $(TESTING)-log,$(if $(3),$(3),$(@))); \
	$(SED) -n "/$(2)/p" $(call $(TESTING)-log,$(if $(3),$(3),$(@))) | $(WC); \
	if [ "$(shell $(SED) -n "/$(2)/p" $(call $(TESTING)-log,$(if $(3),$(3),$(@))) | $(WC))" != "$(1)" ]; then \
		$(call $(TESTING)-fail); \
	fi
endef

override define $(TESTING)-fail =
	$(ENDOLINE); \
	$(call $(HEADERS)-note,$(call $(TESTING)-pwd,$(if $(1),$(1),$(@))),FAILED!); \
	$(ENDOLINE); \
	if [ -z "$(COMPOSER_DOITALL_$(TESTING))" ]; then \
		exit 1; \
	fi
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
### {{{3 $(TESTING)-Think
########################################

#> update: $(TESTING)-Think

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
### {{{3 $(TESTING)-$(DISTRIB)
########################################

.PHONY: $(TESTING)-$(DISTRIB)
$(TESTING)-$(DISTRIB): $(TESTING)-Think
$(TESTING)-$(DISTRIB):
	@$(call $(TESTING)-$(HEADERS),\
		Install '$(_C)$(TESTING_COMPOSER_DIR)$(_D)' using '$(_C)$(DISTRIB)$(_D)' ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)
	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-$(DISTRIB)-init
$(TESTING)-$(DISTRIB)-init:
#>	@$(call $(TESTING)-run,$(TESTING_COMPOSER_DIR)) $(DISTRIB)
	@$(call $(TESTING)-run,$(TESTING_COMPOSER_DIR)) --makefile $(COMPOSER) $(DISTRIB)

.PHONY: $(TESTING)-$(DISTRIB)-done-env
$(TESTING)-$(DISTRIB)-done-env:
	@$(LS) $(sort \
		$(foreach FILE,$(REPOSITORIES_LIST),\
			$(foreach VAR,$(OS_VAR_LIST),\
				$(if $($(FILE)_$(VAR)_BIN),\
					$($(FILE)_DIR)/$($(FILE)_$(VAR)_BIN) \
				) \
			) \
			$($(FILE)_BIN) \
		) \
	)

.PHONY: $(TESTING)-$(DISTRIB)-done
$(TESTING)-$(DISTRIB)-done:
	@$(call $(TESTING)-run) $(@)-env

########################################
### {{{3 $(TESTING)-heredoc
########################################

.PHONY: $(TESTING)-heredoc
$(TESTING)-heredoc: $(TESTING)-Think
$(TESTING)-heredoc:
	@$(call $(TESTING)-$(HEADERS),\
		Export of all embedded files ,\
		\n\t * $(_H)Manual review of formatting and content$(_D) \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)
#>	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-heredoc-init
$(TESTING)-heredoc-init:
	@$(foreach FILE,$(shell \
		$(SED) -n "s|^.*define.+(HEREDOC[_][^[:space:]]+).*$$|\1|gp" $(COMPOSER) \
		),\
		$(call DO_HEREDOC ,$(FILE),1,$(notdir $(call $(TESTING)-pwd)))	>$(call $(TESTING)-pwd)/$(FILE).$(EXTN_TEXT); \
		$(call NEWLINE) \
	)
	@$(foreach FILE,$(shell \
		$(SED) -n "/^[#].*[ ]Embedded[ ]Files.*$$/,/[{][{][{]/p" $(COMPOSER) \
			| $(SED) -n "s|^override[[:space:]]+([^:=[:space:]]+).+$$|\1|gp" \
		),\
		$(ECHO) "$($(FILE))" | $(BASE64)				>$(call $(TESTING)-pwd)/$(FILE).png; \
		$(call NEWLINE) \
	)
	@$(SED) -n "s|^.+DO_HEREDOC[,]([^[:space:]]+).*$$|\1|gp" $(COMPOSER) \
		| $(SED) \
			-e "s|[)]$$||g" \
			-e "s|[,].*$$||g" \
		| $(SORT) \
		>$(call $(TESTING)-pwd)/.DO_HEREDOC.$(EXTN_TEXT)

.PHONY: $(TESTING)-heredoc-done
$(TESTING)-heredoc-done:
	@$(CAT) $(call $(TESTING)-pwd)/.DO_HEREDOC.$(EXTN_TEXT)

########################################
### {{{3 $(TESTING)-speed
########################################

#> uname -a
#>	Linux phoenix 5.10.154-gentoo.gary-os #1 SMP PREEMPT Mon Jan 2 10:51:39 -00 2023 x86_64 Intel(R) Core(TM) i9-10900K CPU @ 3.70GHz GenuineIntel GNU/Linux
#> grep -i -e "^model name" -e "^siblings" /proc/cpuinfo | head -n2
#>	model name: Intel(R) Core(TM) i9-10900K CPU @ 3.70GHz
#>	siblings: 20
#> grep -i "^memtotal" /proc/meminfo
#>	MemTotal: 65739512 kB

#> DEBUGIT=""
#>	Directories:		( 17 * 13 )		=   221
#>	Makefiles:		( . + 3 )		=   224
#>	Sources:		( 117 * 13 )		=  1521
#>	Outputs:		( . * 4 ) + ( 8 * 3 )	=  6108
#>				( . * 5 ) + ( 8 * 3 )	=  7629
#> DEBUGIT="1"
#>	Directories:		( . + ( 6 * 13 ) )	=   299
#>	Makefiles:		( . + ( 6 * 13 ) )	=   302
#>	Sources:		( 836 * 13 )		= 10868
#>	Outputs:		( . * 4 ) + ( 8 * 3 )	= 43496
#>				( . * 5 ) + ( 8 * 3 )	= 54364
#> MAKEJOBS: 20 / DEBUGIT: -
#>	install:		~ <1m
#>	all:			~  2m
#>	clean:			~ <1m
#>	site (null):		~  8m
#>	site (testing):		~ 12m
#>	site (showdir):		~ 21m
#>	site (example):		~ 25m
#> MAKEJOBS: 20 / DEBUGIT: 1
#>	install:		~  <1m
#>	all:			~   7m
#>	clean:			~   1m
#>	site (null):		~ 212m
#>	site (testing):		~ 223m
#>	site (showdir):		~ 249m
#>	site (example):		~ 276m

.PHONY: $(TESTING)-speed
$(TESTING)-speed: $(TESTING)-Think
$(TESTING)-speed:
	@$(call $(TESTING)-$(HEADERS),\
		Measure processing speed with a large directory \
		\n\t $(_N)$(MARKER) For performance testing and fun$(_D) \
		\n\t $(_N)$(MARKER) Tool to determine appropriate '$(_C)MAKEJOBS$(_N)' value for system$(_D) \
		,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
		\n\t * Test runs: \
		\n\t\t * '$(INSTALL)-$(DOFORCE)' \
		\n\t\t * '$(DOITALL)-$(DOITALL)' \
		\n\t\t * '$(CLEANER)-$(DOITALL)' \
		\n\t\t * '$(PUBLISH)-$(DOFORCE)' $(_E)(no configuration)$(_D) \
		\n\t\t * '$(PUBLISH)-$(DOFORCE)' $(_E)(HEREDOC_COMPOSER_YML + $(_N)*$(_E)_PUBLISH_TESTING)$(_D) \
		\n\t\t * '$(PUBLISH)-$(DOFORCE)' $(_E)(HEREDOC_COMPOSER_YML + $(_N)*$(_E)_PUBLISH_SHOWDIR)$(_D) \
		\n\t\t * '$(PUBLISH)-$(DOFORCE)' $(_E)(HEREDOC_COMPOSER_YML + $(_N)*$(_E)_PUBLISH_EXAMPLE)$(_D) \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)
	@$(call $(TESTING)-hold)

#> update: $(PUBLISH)-$(EXAMPLE)-$(INSTALL)
override define $(TESTING)-speed-init =
	if [ -z "$(1)" ]; then \
		$(call $(PUBLISH)-$(EXAMPLE)-$(INSTALL),$(call $(TESTING)-pwd),$(wildcard $(call $(TESTING)-pwd)/.$(DEBUGIT))); \
		$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_YML); \
	else \
		$(call DO_HEREDOC,HEREDOC_COMPOSER_YML,1) >$(call $(TESTING)-pwd)/$(COMPOSER_YML); \
	fi; \
	$(RM) --recursive $(call $(TESTING)-pwd)/$(PUBLISH_LIBRARY); \
	for TLD in {1..3}; do \
		if [ -z "$(1)" ]; then \
			$(call $(PUBLISH)-$(EXAMPLE)-$(INSTALL),$(call $(TESTING)-pwd)/tld$${TLD},$(wildcard $(call $(TESTING)-pwd)/.$(DEBUGIT))); \
			$(RM) $(call $(TESTING)-pwd)/tld$${TLD}/$(COMPOSER_YML); \
		else \
			$(call DO_HEREDOC,$(1)) >$(call $(TESTING)-pwd)/tld$${TLD}/$(COMPOSER_YML); \
		fi; \
		$(RM) --recursive $(call $(TESTING)-pwd)/tld$${TLD}/$(PUBLISH_LIBRARY); \
		for SUB in {1..3}; do \
			if [ -z "$(1)" ]; then \
				$(call $(PUBLISH)-$(EXAMPLE)-$(INSTALL),$(call $(TESTING)-pwd)/tld$${TLD}/sub$${SUB},$(wildcard $(call $(TESTING)-pwd)/.$(DEBUGIT))); \
			fi; \
			$(RM) --recursive $(call $(TESTING)-pwd)/tld$${TLD}/sub$${SUB}/$(PUBLISH_LIBRARY); \
		done; \
	done
endef

override define $(TESTING)-speed-init-$(PUBLISH) =
	$(call $(TESTING)-speed-init,$(1)); \
	FILE="$$($(SED) -n "/Creating.+[.]$(EXTN_HTML)/p" $(call $(TESTING)-log) | $(WC))"; \
	$(call $(HEADERS)-note,$(PUBLISH)-$(DOFORCE),$(if $(1),$(1),$(NOTHING)),$${FILE}); \
	$(CAT) \
		$(call $(TESTING)-pwd)/$(COMPOSER_YML) \
		$(call $(TESTING)-pwd)/tld*/$(COMPOSER_YML) \
		$(call $(TESTING)-pwd)/tld*/sub*/$(COMPOSER_YML) \
		|| $(TRUE); \
	time $(call $(TESTING)-run,,$(MAKEJOBS)) $(PUBLISH)-$(DOFORCE)
endef

.PHONY: $(TESTING)-speed-init
$(TESTING)-speed-init:
	@$(call $(TESTING)-speed-init)
	@$(ECHO) "override COMPOSER_INCLUDE := 1\n" >$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS)
	@time $(call $(TESTING)-run,,$(MAKEJOBS)) $(INSTALL)-$(DOFORCE)
#> $(PUBLISH) > $(CLEANER) > $(DOITALL)
#>	@time $(call $(TESTING)-run,,$(MAKEJOBS)) $(PUBLISH)-$(DOFORCE)
	@time $(call $(TESTING)-run,,$(MAKEJOBS)) $(DOITALL)-$(DOITALL)
	@time $(call $(TESTING)-run,,$(MAKEJOBS)) $(CLEANER)-$(DOITALL)
	@$(call $(TESTING)-speed-init-$(PUBLISH))
	@$(call $(TESTING)-speed-init-$(PUBLISH),HEREDOC_COMPOSER_YML_PUBLISH_TESTING)
#>	@$(call $(TESTING)-speed-init-$(PUBLISH),HEREDOC_COMPOSER_YML_PUBLISH_SHOWDIR)
	@$(call $(TESTING)-speed-init-$(PUBLISH),HEREDOC_COMPOSER_YML_PUBLISH_EXAMPLE)

.PHONY: $(TESTING)-speed-done
$(TESTING)-speed-done:
	@$(call $(TESTING)-find,MAKECMDGOALS)
	@$(call $(TESTING)-find,$(PUBLISH)-$(DOFORCE).+$(DIVIDE))
	@$(TABLE_M2) "$(_H)$(MARKER) Directories"	"$(_C)$(shell $(FIND_ALL) $(call $(TESTING)-pwd) \( -path \*/$(notdir $(COMPOSER_TMP)) -prune \) -o \( -path \*/$(PUBLISH_LIBRARY) -prune \) -o \( -type d -print \) | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) $(MAKEFILE)s"	"$(_C)$(shell $(SED) -n "/Creating.+$(MAKEFILE)/p" $(call $(TESTING)-log) | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Sources"		"$(_C)$(shell $(FIND_ALL) $(call $(TESTING)-pwd) \( -path \*/$(notdir $(COMPOSER_TMP)) -prune \) -o \( -path \*/$(PUBLISH_LIBRARY) -prune \) -o \( -type f -print \) | $(SED) -n "/[^/]+$(subst .,[.],$(COMPOSER_EXT_DEFAULT))$$/p" | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Outputs"		"$(_C)$(shell $(SED) -n "/Creating.+[.]$(EXTN_HTML)/p" $(call $(TESTING)-log) | $(WC))"
	@$(TABLE_M2) "$(_H)$(MARKER) Jobs"		"$(_C)$(MAKEJOBS)"
	@$(TABLE_M2) "$(_H)$(MARKER) Debug"		"$(_C)$(if $(wildcard $(call $(TESTING)-pwd)/.$(DEBUGIT)),1,-)"
#>	@$(call $(TESTING)-find,[0-9]s$$)
	@$(call $(TESTING)-find,^real)

########################################
### {{{3 $(TESTING)-$(COMPOSER_BASENAME)
########################################

#WORK COMPOSER_YML

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)
$(TESTING)-$(COMPOSER_BASENAME): $(TESTING)-Think
$(TESTING)-$(COMPOSER_BASENAME):
	@$(call $(TESTING)-$(HEADERS),\
		Basic '$(_C)$(COMPOSER_BASENAME)$(_D)' functionality ,\
		\n\t * Variable alias precedence \
		\n\t * Automatic input file detection \
		\n\t\t * Variable-defined '$(_C)c_list$(_D)' override $(_E)(plus wildcard)$(_D) \
		\n\t\t * Command-line '$(_C)c_list$(_D)' shortcut \
		\n\t * Expansion of '$(_C)c_margins$(_D)' variable \
		\n\t * Quoting in '$(_C)c_options$(_D)' variable \
		\n\t * Empty '$(_C)COMPOSER_TARGETS$(_D)' and '$(_C)COMPOSER_SUBDIRS$(_D)' values \
		\n\t\t * Use of '$(_C).$(TARGETS)$(_D)' targets \
		\n\t\t * Use of '$(_C)$(NOTHING)$(_D)' targets \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-init
$(TESTING)-$(COMPOSER_BASENAME)-init:
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	#> precedence
	@$(call $(TESTING)-run,,$(NOTHING)) MAKEJOBS="1000" c_jobs="100" J="10" $(CONFIGS)
	@$(call $(TESTING)-run,,$(NOTHING)) c_jobs="100" J="10" $(CONFIGS)
	@$(call $(TESTING)-run,,$(NOTHING)) J="10" $(CONFIGS)
	#> input
	@$(call $(TESTING)-run) $(OUT_README)$(COMPOSER_EXT_DEFAULT).$(EXTN_DEFAULT)
	@$(ECHO) "override $(OUT_README).* := $(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)\n"	>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override $(OUT_README).$(EXTN_DEFAULT) := $(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)\n"				>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) $(OUT_README).$(EXTN_LINT)
	@$(call $(TESTING)-run) $(OUT_MANUAL).$(EXTN_DEFAULT) c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT) $(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)"
	@$(SED) -n "/$(COMPOSER_LICENSE)/p" \
		$(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_DEFAULT) \
		$(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_LINT) \
		$(call $(TESTING)-pwd)/$(OUT_MANUAL).$(EXTN_DEFAULT)
	#> margins
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_margin= c_margin_top="1in" c_margin_bottom="2in" c_margin_left="3in" c_margin_right="4in" $(OUT_README).$(EXTN_LPDF)
	#> options
#WORK document these quoting options, somewhere...
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable='$(TESTING)=$(DEBUGIT)'" $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable='$(TESTING)=$(DEBUGIT)'" $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable=\"$(TESTING)=$(DEBUGIT)\"" $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options="--variable=\"$(TESTING)=$(DEBUGIT)\"" $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable="$(TESTING)=$(DEBUGIT)"' $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable="$(TESTING)=$(DEBUGIT)"' $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable='"'$(TESTING)=$(DEBUGIT)'" $(CONFIGS)
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_options='--variable='"'$(TESTING)=$(DEBUGIT)'" $(CLEANER) $(OUT_README).$(EXTN_DEFAULT)
	#> values
	@$(ECHO) "override COMPOSER_TARGETS := .$(TARGETS) $(notdir $(call $(TESTING)-pwd))\n"	>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_SUBDIRS := .$(TARGETS) $(notdir $(call $(TESTING)-pwd))\n"	>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CONFIGS)
	@$(ECHO) "override COMPOSER_TARGETS := $(NOTHING)\n"					>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_SUBDIRS := $(NOTHING)\n"					>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CONFIGS)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-$(COMPOSER_BASENAME)-done
$(TESTING)-$(COMPOSER_BASENAME)-done:
	#> precedence
	$(call $(TESTING)-count,1,MAKEJOBS.+1000)
	$(call $(TESTING)-count,1,MAKEJOBS.+100[^0])
	$(call $(TESTING)-count,1,MAKEJOBS.+10[^0])
	#> input
	$(call $(TESTING)-find,Creating.+$(OUT_README)$(COMPOSER_EXT_DEFAULT).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_LINT))
	$(call $(TESTING)-find,Creating.+$(OUT_MANUAL).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,4,$(COMPOSER_LICENSE))
	#> margins
	$(call $(TESTING)-count,17,\|.+c_margin)
	$(call $(TESTING)-find,c_margin_top.+1in)
	$(call $(TESTING)-find,c_margin_bottom.+2in)
	$(call $(TESTING)-find,c_margin_left.+3in)
	$(call $(TESTING)-find,c_margin_right.+4in)
	#> options
	$(call $(TESTING)-count,6,[\"]$(TESTING)=$(DEBUGIT)[\"])
	$(call $(TESTING)-count,6,[']$(TESTING)=$(DEBUGIT)['])
	#> values
	$(call $(TESTING)-count,16,COMPOSER_TARGETS.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,16,COMPOSER_SUBDIRS.+artifacts)
	$(call $(TESTING)-count,1,COMPOSER_TARGETS.+$(OUT_README).$(EXTN_DEFAULT) $(notdir $(call $(TESTING)-pwd)))
	$(call $(TESTING)-count,1,COMPOSER_SUBDIRS.+artifacts $(notdir $(call $(TESTING)-pwd)))
	$(call $(TESTING)-count,1,COMPOSER_TARGETS.+$(NOTHING))
	$(call $(TESTING)-count,1,COMPOSER_SUBDIRS.+$(NOTHING))
	$(call $(TESTING)-count,1,Processing.+$(NOTHING).+$(NOTHING)-$(TARGETS))
	$(call $(TESTING)-count,1,Processing.+$(NOTHING).+$(NOTHING)-$(SUBDIRS))

########################################
### {{{3 $(TESTING)-$(TARGETS)
########################################

#> update: TYPE_TARGETS

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
	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-$(TARGETS)-init
$(TESTING)-$(TARGETS)-init:
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).*.[x0-9].[x0-9].*
	@$(ECHO) "override c_list := $(OUT_README)$(COMPOSER_EXT_DEFAULT)\n"	>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_TARGETS :=\n"				>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(foreach TYPE,$(TYPE_TARGETS_LIST),\
		$(foreach TOC,x 0 1 2 3 4 5 6,\
			$(foreach LEVEL,x 0 1 2 3 4 5 6,\
				$(ECHO) "override COMPOSER_TARGETS += $(OUT_README).$(EXTN_$(TYPE)).$(TOC).$(LEVEL).$(EXTN_$(TYPE))\n"			>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(ECHO) "$(OUT_README).$(EXTN_$(TYPE)).$(TOC).$(LEVEL).$(EXTN_$(TYPE)): override c_toc := $(subst x,,$(TOC))\n"		>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(ECHO) "$(OUT_README).$(EXTN_$(TYPE)).$(TOC).$(LEVEL).$(EXTN_$(TYPE)): override c_level := $(subst x,,$(LEVEL))\n"	>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
				$(call NEWLINE) \
			) \
		) \
	)
#>				$(call $(TESTING)-run) $(OUT_README).$(EXTN_$(TYPE)).$(TOC).$(LEVEL).$(EXTN_$(TYPE)) || $(TRUE)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(NOFAIL) $(DOITALL) || $(TRUE)
	@$(LS) $(call $(TESTING)-pwd)/$(OUT_README).*.[x0-9].*

.PHONY: $(TESTING)-$(TARGETS)-done
$(TESTING)-$(TARGETS)-done:
	$(foreach TYPE,$(TYPE_TARGETS_LIST),\
		$(eval override COUNT := 64) \
		$(call $(TESTING)-count,$(COUNT), $(subst /,[/],$(call $(TESTING)-pwd))[/]$(OUT_README)[.]$(EXTN_$(TYPE))[.][x0-9][.][x0-9][.]$(EXTN_$(TYPE))); \
		$(call NEWLINE) \
	)

########################################
### {{{3 $(TESTING)-$(INSTALL)
########################################

#WORKING
#	this should test $(INSTALL) specifically, including $(DOFORCE) versus not
#	parallel/linear $(CLEANER)/$(DOITALL) should be below...

.PHONY: $(TESTING)-$(INSTALL)
$(TESTING)-$(INSTALL): $(TESTING)-Think
$(TESTING)-$(INSTALL):
	@$(call $(TESTING)-$(HEADERS),\
		Test '$(_C)$(INSTALL)$(_D)' in an existing directory ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
		\n\t * Missing '$(_C)$(MAKEFILE)$(_D)' detection \
		\n\t * Ensure threading is working properly \
		\n\t * Test runs: \
		\n\t\t * Parallel '$(INSTALL)-$(DOFORCE)' $(_E)(from '$(TESTING)-load')$(_D) \
		\n\t\t * Parallel '$(DOITALL)' \
		\n\t\t * Parallel '$(CLEANER)' \
		\n\t\t * Linear '$(INSTALL)' \
		\n\t\t * Linear '$(DOITALL)' \
		\n\t\t * Linear '$(CLEANER)' \
	)
	@$(call $(TESTING)-load)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)
	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-$(INSTALL)-init
$(TESTING)-$(INSTALL)-init:
	@$(RM) $(call $(TESTING)-pwd)/data/*/$(MAKEFILE)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(CLEANER)-$(DOITALL)
	@$(call $(TESTING)-run) $(INSTALL)-$(DOITALL)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run) $(CLEANER)-$(DOITALL)

.PHONY: $(TESTING)-$(INSTALL)-done
$(TESTING)-$(INSTALL)-done:
	$(call $(TESTING)-find,Processing.+$(NOTHING).+$(MAKEFILE))

########################################
### {{{3 $(TESTING)-$(CLEANER)-$(DOITALL)
########################################

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)
$(TESTING)-$(CLEANER)-$(DOITALL): $(TESTING)-Think
$(TESTING)-$(CLEANER)-$(DOITALL):
	@$(call $(TESTING)-$(HEADERS),\
		Test '$(_C)$(CLEANER)-$(DOITALL)$(_D)' and '$(_C)$(DOITALL)-$(DOITALL)$(_D)' behavior ,\
		\n\t * $(_H)Successful run $(DIVIDE) Manual review of output$(_D) \
		\n\t * Creation and deletion of files \
		\n\t * Verify '$(_N)*$(_C)-$(DOITALL)$(_D)' and '$(_N)*$(_C)-$(CLEANER)$(_D)' targets \
		\n\t\t * Also with parallel execution \
		\n\t * Empty '$(_C)COMPOSER_TARGETS$(_D)' detection \
	)
	@$(call $(TESTING)-load)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)
	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)-init
$(TESTING)-$(CLEANER)-$(DOITALL)-init:
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_KEEPING := $(SPECIAL_VAL)\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) '$(foreach FILE,1 2 3 4 5 6 7 8 9,\n.PHONY: $(patsubst _%,%,$(TESTING)-$(FILE)-$(EXPORTS))\n$(patsubst _%,%,$(TESTING))-$(FILE)-$(EXPORTS):\n\t@$$(PRINT) "$$(@): $$(CURDIR)"\n)' \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) '$(foreach FILE,1 2 3 4 5 6 7 8 9,\n.PHONY: $(patsubst _%,%,$(TESTING)-$(FILE)-$(CLEANER))\n$(patsubst _%,%,$(TESTING))-$(FILE)-$(CLEANER):\n\t@$$(PRINT) "$$(@): $$(CURDIR)"\n)' \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) '$(foreach FILE,1 2 3 4 5 6 7 8 9,\n.PHONY: $(patsubst _%,%,$(TESTING)-$(FILE)-$(DOITALL))\n$(patsubst _%,%,$(TESTING))-$(FILE)-$(DOITALL):\n\t@$$(PRINT) "$$(@): $$(CURDIR)"\n)' \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(MKDIR) $(call $(TESTING)-pwd)/data/$(notdir $(COMPOSER_TMP))
#>	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(EXPORTS) $(TESTING)-2-$(EXPORTS)" $(EXPORTS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(EXPORTS) $(TESTING)-2-$(EXPORTS)" $(CONFIGS)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(CLEANER) $(TESTING)-2-$(CLEANER)" $(CLEANER)
	@$(call $(TESTING)-run) --directory $(call $(TESTING)-pwd)/data COMPOSER_TARGETS="$(TESTING)-1-$(DOITALL) $(TESTING)-2-$(DOITALL)" $(DOITALL)
#> $(EXPORTS) > $(CLEANER) > $(DOITALL)
#>	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(EXPORTS)-$(DOITALL)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(DOITALL)-$(DOITALL)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) --directory $(call $(TESTING)-pwd)/data $(EXPORTS)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(CLEANER)-$(DOITALL)

.PHONY: $(TESTING)-$(CLEANER)-$(DOITALL)-done
$(TESTING)-$(CLEANER)-$(DOITALL)-done:
	$(call $(TESTING)-find,Creating.+changelog.html)
	$(call $(TESTING)-find,Creating.+getting-started.html)
	$(call $(TESTING)-find,Removing.+changelog.html)
	$(call $(TESTING)-find,Removing.+getting-started.html)
	$(call $(TESTING)-count,2,[[].*$(CLEANER).*[]].+$(COMPOSER_LOG_DEFAULT))
	$(call $(TESTING)-count,1,[[].*$(CLEANER).*[]].+$(notdir $(COMPOSER_TMP)))
	$(call $(TESTING)-count,1,$(NOTHING).+$(TARGETS)-$(EXPORTS))
	$(call $(TESTING)-count,1,$(NOTHING).+$(TARGETS)-$(CLEANER))
	$(call $(TESTING)-count,1,$(NOTHING).+$(TARGETS)-$(DOITALL))
#>	$(call $(TESTING)-count,4,$(patsubst _%,%,$(TESTING)-1-$(EXPORTS)))
	$(call $(TESTING)-count,2,$(patsubst _%,%,$(TESTING)-1-$(EXPORTS)))
	$(call $(TESTING)-count,4,$(patsubst _%,%,$(TESTING)-1-$(CLEANER)))
	$(call $(TESTING)-count,4,$(patsubst _%,%,$(TESTING)-1-$(DOITALL)))

########################################
### {{{3 $(TESTING)-COMPOSER_INCLUDE
########################################

#WORK COMPOSER_YML...?
#	handled sufficiently by $(PUBLISH)-$(EXAMPLE)...?
#	what happens if a page/post file variable conflicts with a $(COMPOSER_YML)?  --defaults wins?

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
		\n\t * Check '$(_C)COMPOSER_CURDIR$(_D)' variable \
	)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-COMPOSER_INCLUDE-init
$(TESTING)-COMPOSER_INCLUDE-init:
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-make)
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
	$(ECHO) "override COMPOSER_INCLUDE := $(1)\n"	>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(ECHO) "ifneq (\$$(COMPOSER_CURDIR),)\n"	>>$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(ECHO) "\$$(info COMPOSER_CURDIR)\n"		>>$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(ECHO) "endif\n"				>>$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(call $(TESTING)-run) $(CONFIGS) | $(SED) -n "/COMPOSER_INCLUDES/p"
endef

override define $(TESTING)-COMPOSER_INCLUDE-done =
	$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CONFIGS) $(OUT_README).$(EXTN_HTML); \
	$(SED) -i "/COMPOSER_DEPENDS/d"	$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
	$(RM)				$(call $(TESTING)-pwd)/$(COMPOSER_CSS); \
	$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CONFIGS) $(OUT_README).$(EXTN_HTML); \
	$(SED) -i "/COMPOSER_DEPENDS/d"	$(call $(TESTING)-pwd,/)/$(COMPOSER_SETTINGS); \
	$(RM)				$(call $(TESTING)-pwd,/)/$(COMPOSER_CSS); \
	$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CONFIGS) $(OUT_README).$(EXTN_HTML); \
	$(SED) -i "/COMPOSER_DEPENDS/d"	$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_SETTINGS); \
	$(RM)				$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))/$(COMPOSER_CSS); \
	$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(CONFIGS) $(OUT_README).$(EXTN_HTML); \
	$(call $(TESTING)-run,/) $(CONFIGS) | $(SED) -n "/COMPOSER_CURDIR/p"
endef

.PHONY: $(TESTING)-COMPOSER_INCLUDE-done
$(TESTING)-COMPOSER_INCLUDE-done:
	$(call $(TESTING)-count,2,COMPOSER_DEPENDS.+$(subst /,[/],$(patsubst $(COMPOSER_DIR)%,$(EXPAND)%,$(call $(TESTING)-pwd))$(SED_ESCAPE_COLOR)[]]))
	$(call $(TESTING)-count,2,--css.+$(subst /,[/],$(realpath $(call $(TESTING)-pwd))/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,1,COMPOSER_DEPENDS.+$(subst /,[/],$(patsubst $(COMPOSER_DIR)%,$(EXPAND)%,$(call $(TESTING)-pwd,/))$(SED_ESCAPE_COLOR)[]]))
	$(call $(TESTING)-count,4,--css.+$(subst /,[/],$(realpath $(call $(TESTING)-pwd,/))/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,3,COMPOSER_DEPENDS.+$(subst /,[/],$(patsubst $(COMPOSER_DIR)%,$(EXPAND)%,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)))$(SED_ESCAPE_COLOR)[]]))
	$(call $(TESTING)-count,6,--css.+$(subst /,[/],$(realpath $(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR)))/$(COMPOSER_CSS)))
	$(call $(TESTING)-count,20,--css.+$(COMPOSER_CSS))
	$(call $(TESTING)-count,2,^COMPOSER_CURDIR)

########################################
### {{{3 $(TESTING)-COMPOSER_DEPENDS
########################################

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
	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-init
$(TESTING)-COMPOSER_DEPENDS-init:
	@$(RM) $(call $(TESTING)-pwd)/data/*$(COMPOSER_EXT_DEFAULT)
	@$(RM) $(call $(TESTING)-pwd)/data/*.$(EXTN_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_README)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/data/$(OUT_LICENSE)$(COMPOSER_EXT_DEFAULT)
	@$(ECHO) "override COMPOSER_DEPENDS := 1\n" >$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(OUT_LICENSE).$(EXTN_DEFAULT): $(OUT_README).$(EXTN_DEFAULT)\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(SUBDIRS)-$(DOITALL)-docx: $(SUBDIRS)-$(DOITALL)-templates\n" >>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(sort \
		$(filter-out $(SUBDIRS)-$(DOITALL)-docx,\
		$(filter-out $(SUBDIRS)-$(DOITALL)-templates,\
		$(addprefix $(SUBDIRS)-$(DOITALL)-,\
		$(notdir \
		$(patsubst %/.,%,$(wildcard $(addsuffix /.,$(call $(TESTING)-pwd)/data/*))) \
		))))): $(SUBDIRS)-$(DOITALL)-docx\n" \
		>>$(call $(TESTING)-pwd)/data/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run,,$(TESTING_MAKEJOBS)) $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-COMPOSER_DEPENDS-done
$(TESTING)-COMPOSER_DEPENDS-done:
	$(call $(TESTING)-find,$(notdir $(call $(TESTING)-pwd))\/data)

########################################
### {{{3 $(TESTING)-COMPOSER_EXPORTS
########################################

.PHONY: $(TESTING)-COMPOSER_EXPORTS
$(TESTING)-COMPOSER_EXPORTS: $(TESTING)-Think
$(TESTING)-COMPOSER_EXPORTS:
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_EXPORTS$(_D)' behavior ,\
		\n\t * Verify '$(_C)COMPOSER_EXPORTS$(_D)' are included $(_E)(including wildcards)$(_D) \
		\n\t * Verify '$(_C)COMPOSER_IGNORES$(_D)' are skipped $(_E)(including wildcards)$(_D) \
		\n\t * Use '$(_C).$(TARGETS)$(_D)' \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

#WORKING:NOW see $(TESTING)-$(CLEANER)-$(DOITALL)
#		\n\t * Verify '$(_N)*$(_C)-$(EXPORTS)$(_D)' targets \
#	$(call $(TESTING)-count,1,$(NOTHING).+$(TARGETS)-$(EXPORTS))

.PHONY: $(TESTING)-COMPOSER_EXPORTS-init
$(TESTING)-COMPOSER_EXPORTS-init:
	@$(ECHO) ""													>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(DOITALL)
	@$(call $(TESTING)-run) $(EXPORTS)
	@$(LS) --recursive $(patsubst $(COMPOSER_ROOT)%,$(call $(TESTING)-pwd)%,$(COMPOSER_EXPORT))
	@$(ECHO) "override COMPOSER_EXPORTS := .$(TARGETS)\n"								>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_IGNORES := $(OUT_README)* $(patsubst $(COMPOSER_DIR)/%,%,$(COMPOSER_ART))\n"	>>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(EXPORTS)
	@$(LS) --recursive $(patsubst $(COMPOSER_ROOT)%,$(call $(TESTING)-pwd)%,$(COMPOSER_EXPORT))

.PHONY: $(TESTING)-COMPOSER_EXPORTS-done
$(TESTING)-COMPOSER_EXPORTS-done:
	$(call $(TESTING)-count,12,$(MARKER) $(EXPORTS))
	$(call $(TESTING)-count,1,deleting)
	$(call $(TESTING)-count,6,Removing)
	$(call $(TESTING)-find,\+\+\+.+$(OUT_README).$(EXTN_DEFAULT))
	$(call $(TESTING)-find,deleting.+$(OUT_README).$(EXTN_DEFAULT))

########################################
### {{{3 $(TESTING)-COMPOSER_IGNORES
########################################

.PHONY: $(TESTING)-COMPOSER_IGNORES
$(TESTING)-COMPOSER_IGNORES: $(TESTING)-Think
$(TESTING)-COMPOSER_IGNORES:
	@$(call $(TESTING)-$(HEADERS),\
		Validate '$(_C)COMPOSER_IGNORES$(_D)' behavior ,\
		\n\t * Verify '$(_C)COMPOSER_EXPORT$(_D)' is added \
		\n\t * Verify '$(_C)COMPOSER_IGNORES$(_D)' are skipped $(_E)(including wildcards)$(_D) \
		\n\t * Use '$(_C).$(TARGETS)$(_D)' \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-COMPOSER_IGNORES-init
$(TESTING)-COMPOSER_IGNORES-init:
	@$(ECHO) ""							>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(INSTALL)-$(DOFORCE)
	@$(call $(TESTING)-run) --directory $(patsubst $(COMPOSER_DIR)/%,$(call $(TESTING)-pwd)/%,$(COMPOSER_ART)) $(CONFIGS)
	@$(ECHO) "override COMPOSER_IGNORES := $(OUT_README)*\n"	>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CONFIGS)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)
	@$(ECHO) "override COMPOSER_IGNORES := .$(TARGETS)\n"		>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(DOITALL)-$(DOITALL)

.PHONY: $(TESTING)-COMPOSER_IGNORES-done
$(TESTING)-COMPOSER_IGNORES-done:
	$(call $(TESTING)-count,1,COMPOSER_IGNORES[^/].+$(patsubst $(COMPOSER_ROOT)/%,%,$(COMPOSER_EXPORT)))
	$(call $(TESTING)-count,1,COMPOSER_IGNORES.+$(OUT_README)[*])
	$(call $(TESTING)-find,Creating.+$(OUT_README).$(EXTN_DEFAULT),,1)
	$(call $(TESTING)-find,Creating.+$(OUT_LICENSE).$(EXTN_DEFAULT))
	$(call $(TESTING)-count,1,$(NOTHING).+$(CONFIGS)-$(TARGETS))
	$(call $(TESTING)-count,1,$(NOTHING).+$(CONFIGS)-$(SUBDIRS))

########################################
### {{{3 $(TESTING)-CSS
########################################

#WORK add a test for file.ext.yml, akin to 'header' selection

.PHONY: $(TESTING)-CSS
$(TESTING)-CSS: $(TESTING)-Think
$(TESTING)-CSS:
	@$(call $(TESTING)-$(HEADERS),\
		Use '$(_C)c_css$(_D)' to verify each method of setting variables ,\
		\n\t * Default: '$(_C)$(PUBLISH)$(_D)' $(_E)(and 'css_overlay' selection, with '$(notdir $(CUSTOM_PUBLISH_CSS))' overlay)$(_D) \
		\n\t * Default: '$(_C)$(TYPE_HTML)$(_D)' $(_E)(and 'template' selection, with '$(COMPOSER_BASENAME)' overlay)$(_D) \
		\n\t * Default: '$(_C)$(TYPE_PRES)$(_D)' \
		\n\t * Environment: '$(_C)$(CSS_ALT)$(_D)' alias $(_E)(and '$(TYPE_EPUB)' use of '$(TYPE_HTML)')$(_D) \
		\n\t * Environment: '$(_C)$(TYPE_PRES).$(CSS_ALT)$(_D)' alias $(_E)(and cross-type theme selection)$(_D) \
		\n\t * Environment: '$(_C)$(SPECIAL_VAL)$(_D)' Pandoc default \
		\n\t * File: '$(_C)$(COMPOSER_SETTINGS)$(_D)' $(_E)(precedence over everything, and direct file path)$(_D) \
		\n\t * File: '$(_C)$(COMPOSER_SETTINGS)$(_D)' per-target $(_E)(precedence over everything)$(_D) \
		\n\t * Default: '$(_C)$(TYPE_LPDF)$(_D)' $(_E)(solely for 'header' selection)$(_D) \
		\n\t * Default: '$(_C)$(TYPE_DOCX)$(_D)' $(_E)(solely for 'reference' selection)$(_D) \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-CSS-init
$(TESTING)-CSS-init:
	@$(RM) $(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)	>/dev/null
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_site="1" $(OUT_README).$(EXTN_HTML)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_HTML); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_HTML)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_PRES); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_PRES)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(CSS_ALT)" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(TYPE_PRES).$(CSS_ALT)" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override c_css := $(patsubst $(COMPOSER_DIR)%,$(call $(TESTING)-pwd,$(TESTING_COMPOSER_DIR))%,$(CUSTOM_PUBLISH_CSS))\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(ECHO) "$(OUT_README).$(EXTN_EPUB): override c_css := $(PUBLISH).$(CSS_ALT)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_EPUB); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" c_css="$(SPECIAL_VAL)" $(OUT_README).$(EXTN_EPUB)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_LPDF); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_LPDF)
	@$(RM) $(call $(TESTING)-pwd)/$(OUT_README).$(EXTN_DOCX); $(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(OUT_README).$(EXTN_DOCX)

.PHONY: $(TESTING)-CSS-done
$(TESTING)-CSS-done:
	$(call $(TESTING)-count,1,$(notdir $(call CSS_THEME,$(PUBLISH))));		$(call $(TESTING)-count,1,$(notdir $(WATERCSS_CSS_SOLAR_ALT)))
											$(call $(TESTING)-count,1,$(notdir $(call CUSTOM_PUBLISH_CSS_OVERLAY,dark)))
											$(call $(TESTING)-count,3,$(notdir $(CUSTOM_PUBLISH_CSS)))
											$(call $(TESTING)-count,1,$(notdir $(BOOTSTRAP_ART_JS)))
											$(call $(TESTING)-count,2,$(notdir $(BOOTSTRAP_ART_CSS)))
	$(call $(TESTING)-count,1,$(notdir $(call CSS_THEME,$(TYPE_HTML))));		$(call $(TESTING)-count,2,$(notdir $(WATERCSS_CSS_ALT)))
											$(call $(TESTING)-count,1,$(notdir $(COMPOSER_CUSTOM))-$(TYPE_HTML).css)
											$(call $(TESTING)-count,2,template.$(TMPL_HTML))
	$(call $(TESTING)-count,1,$(notdir $(call CSS_THEME,$(TYPE_PRES))));		$(call $(TESTING)-count,1,$(notdir $(REVEALJS_CSS_DARK)))
											$(call $(TESTING)-count,3,$(OUT_README).$(EXTN_PRES).[-0-9]+.css)
	$(call $(TESTING)-count,1,$(notdir $(call CSS_THEME,$(TYPE_HTML),$(CSS_ALT))));	$(call $(TESTING)-count,2,$(notdir $(WATERCSS_CSS_ALT)))
	$(call $(TESTING)-count,1,$(notdir $(call CSS_THEME,$(TYPE_PRES),$(CSS_ALT))));	$(call $(TESTING)-count,1,$(notdir $(REVEALJS_CSS_ALT)))
	$(call $(TESTING)-count,3,c_css[^/]+$$)
	$(call $(TESTING)-count,3,$(notdir $(CUSTOM_PUBLISH_CSS)))
	$(call $(TESTING)-count,1,$(notdir $(call CSS_THEME,$(PUBLISH),$(CSS_ALT))));	$(call $(TESTING)-count,2,$(notdir $(BOOTSWATCH_CSS_ALT)))
	$(call $(TESTING)-count,14,--css=)
	$(call $(TESTING)-count,1,$(notdir $(COMPOSER_CUSTOM))-$(TYPE_LPDF).header)
	$(call $(TESTING)-count,1,reference.$(TMPL_DOCX))

########################################
### {{{3 $(TESTING)-$(COMPOSER_LOG)$(COMPOSER_EXT)
########################################

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
	$(call $(TESTING)-find, $(patsubst .%,%,$(COMPOSER_LOG_DEFAULT))$(subst .,[.],$(COMPOSER_EXT_DEFAULT))[*]?$$)

########################################
### {{{3 $(TESTING)-other
########################################

.PHONY: $(TESTING)-other
$(TESTING)-other: $(TESTING)-Think
$(TESTING)-other:
	@$(call $(TESTING)-$(HEADERS),\
		Miscellaneous test cases ,\
		\n\t * Check binary files \
		\n\t * Repository versions variables \
		\n\t * Git export variables \
		\n\t * Pandoc '$(_C)c_type$(_D)' pass-through \
		\n\t * Git '$(_C)$(CONVICT)$(_D)' target \
	)
	@$(call $(TESTING)-mark)
	@$(call $(TESTING)-init)
	@$(call $(TESTING)-done)

.PHONY: $(TESTING)-other-init
$(TESTING)-other-init:
	#> binaries
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_BIN_BLD),\
			if [ -f "$($(FILE)_BIN_BLD)" ]; then \
				$(MV) $($(FILE)_BIN_BLD) $($(FILE)_BIN_BLD).$(COMPOSER_BASENAME); \
			fi \
		) \
	)
	#> versions
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(ECHO) "override $(FILE)_CMT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
		$(call NEWLINE) \
	)
	@$(call $(TESTING)-run) $(CHECKIT)-$(DOITALL)
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_VER),\
			$(ECHO) "override $(FILE)_VER := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS); \
			$(call NEWLINE) \
		) \
	)
	@$(call $(TESTING)-run) $(CHECKIT)-$(DOITALL)
	#> export
	@$(ECHO) "" >$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override _EXPORT_DIRECTORY := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override _EXPORT_GIT_REPO := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override _EXPORT_GIT_BNCH := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override _EXPORT_FIRE_ACCT := $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(ECHO) "override _EXPORT_FIRE_PROJ:= $(NOTHING)\n" >>$(call $(TESTING)-pwd)/$(COMPOSER_SETTINGS)
	@$(call $(TESTING)-run) $(CONFIGS)
	#> pandoc
	@$(call $(TESTING)-run) COMPOSER_DEBUGIT="1" $(COMPOSER_PANDOC) c_type="json" c_base="$(OUT_README)" c_list="$(OUT_README)$(COMPOSER_EXT_DEFAULT)"
	@$(CAT) $(call $(TESTING)-pwd)/$(OUT_README).json | $(SED) "s|[]][}][,].+$$||g"
	#> git
	@$(RM) --recursive $(call $(TESTING)-pwd)/.git
	@cd $(call $(TESTING)-pwd) \
		&& $(GIT) init \
		&& $(GIT) config --local user.name "$(COMPOSER_FULLNAME)" \
		&& $(GIT) config --local user.email "$(COMPOSER_BASENAME)@example.com"
	@$(call $(TESTING)-run) $(CONVICT)-$(DOITALL)
	@cd $(call $(TESTING)-pwd) \
		&& $(GIT) log

.PHONY: $(TESTING)-other-done-env
$(TESTING)-other-done-env:
	@$(ECHO) "$(_C)"
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_BIN),\
			$(ECHO) "$($(FILE)_NAME):\n"; \
			$(ECHO) "\tfile:\t$($(FILE))\n"; \
			$(ECHO) "\tbin:\t$($(FILE)_BIN)\n"; \
			$(if $($(FILE)_BIN_BLD),\
				$(ECHO) "\tbuild:\t$($(FILE)_BIN_BLD)\n"; \
			) \
		) \
		$(call NEWLINE) \
	)
	@$(ECHO) "$(_D)"
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_BIN),\
			if [ "$($(FILE))" != "$($(FILE)_BIN)" ]; then \
				$(call $(TESTING)-fail); \
			fi; \
			$(if $($(FILE)_BIN_BLD),\
				if [ ! -f "$($(FILE)_BIN_BLD).$(COMPOSER_BASENAME)" ]; then \
					$(call $(TESTING)-fail); \
				fi; \
			) \
		) \
		$(call NEWLINE) \
	)

.PHONY: $(TESTING)-other-done
$(TESTING)-other-done:
	#> binaries
	@$(call $(TESTING)-run) $(@)-env
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_BIN_BLD),\
			if [ -f "$($(FILE)_BIN_BLD).$(COMPOSER_BASENAME)" ]; then \
				$(MV) $($(FILE)_BIN_BLD).$(COMPOSER_BASENAME) $($(FILE)_BIN_BLD); \
			fi \
		) \
	)
	#> versions
	$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_VER),\
			$(call $(TESTING)-find,[(].*$($(FILE)_VER_COMPOSER).*[)]); \
			$(call NEWLINE) \
		) \
	)
	$(call $(TESTING)-count,28,$(subst .,[.],$(NOTHING)))
	$(foreach FILE,$(REPOSITORIES_LIST),\
		$(if $($(FILE)_BIN),\
			$(call $(TESTING)-count,$(if $(filter PANDOC,$(FILE)),2,1),$(subst /,[/],$(call COMPOSER_CONV,,$($(FILE)_BIN)))); \
			$(call NEWLINE) \
		) \
	)
	#> export
	$(call $(TESTING)-count,5,_EXPORT_)
	$(call $(TESTING)-count,28,$(subst .,[.],$(NOTHING)))
	#> pandoc
	$(call $(TESTING)-find,pandoc-api-version)
	#> git
	$(call $(TESTING)-find,create mode.+$(TESTING_LOGFILE))
	$(call $(TESTING)-find,$(COMPOSER_FULLNAME).+$(COMPOSER_BASENAME)@example.com)

########################################
### {{{3 $(TESTING)-$(EXAMPLE)
########################################

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
#>	@$(call $(TESTING)-hold)

.PHONY: $(TESTING)-$(EXAMPLE)-init
$(TESTING)-$(EXAMPLE)-init:
	@$(call $(TESTING)-run) COMPOSER_DOCOLOR= $(NOTHING)
	@$(call $(TESTING)-run) COMPOSER_DOCOLOR= $(NOTHING)-$(notdir $(call $(TESTING)-pwd))

.PHONY: $(TESTING)-$(EXAMPLE)-done
$(TESTING)-$(EXAMPLE)-done:
	$(call $(TESTING)-find,Processing.+$(NOTHING)$$)
	$(call $(TESTING)-find,Processing.+$(TESTING)-$(EXAMPLE)$$)

################################################################################
# {{{1 Information Targets
################################################################################

########################################
## {{{2 $(CHECKIT)
########################################

$(foreach FILE,$(REPOSITORIES_LIST),\
	$(eval override $(FILE)_CMT_DISPLAY := $($(FILE)_CMT)) \
	$(if $(filter-out $(patsubst v%,%,$($(FILE)_CMT)),$($(FILE)_VER)),\
		$(eval override $(FILE)_CMT_DISPLAY := $($(FILE)_CMT)$(_D) ($(_N)$($(FILE)_VER)$(_D))) \
	) \
)

#> update: Tooling Versions
.PHONY: $(CHECKIT)
$(CHECKIT): .set_title-$(CHECKIT)
$(CHECKIT):
	@$(call $(HEADERS))
	@$(TABLE_M3) "$(_H)Repository"					"$(_H)Commit"				"$(_H)License"
	@$(TABLE_M3) ":---"						":---"					":---"
	@$(foreach FILE,$(REPOSITORIES_LIST),\
		$(TABLE_M3) "$(_E)[$($(FILE)_NAME)]"			"$(_E)$($(FILE)_CMT_DISPLAY)"		"$(_N)$($(FILE)_LIC)"; \
		$(call NEWLINE) \
	)
	@$(ENDOLINE)
ifeq ($(COMPOSER_DOITALL_$(CHECKIT)),$(HELPOUT))
	@$(TABLE_M2) "$(_H)Project"					"$(_H)$(COMPOSER_BASENAME) Version"
	@$(TABLE_M2) ":---"						":---"
	@$(TABLE_M2) "$(_C)[GNU Bash]"					"$(_M)$(BASH_VER)"
	@$(TABLE_M2) "-- $(_C)[GNU Coreutils]"				"$(_M)$(COREUTILS_VER)"
	@$(TABLE_M2) "-- $(_C)[GNU Findutils]"				"$(_M)$(FINDUTILS_VER)"
	@$(TABLE_M2) "-- $(_C)[GNU Sed]"				"$(_M)$(SED_VER)"
	@$(TABLE_M2) "$(_C)[GNU Make]"					"$(_M)$(MAKE_VER)"
	@$(TABLE_M2) "-- $(_C)[Pandoc]"					"$(_M)$(PANDOC_VER_COMPOSER)"
	@$(TABLE_M2) "-- $(_C)[YQ]"					"$(_M)$(YQ_VER_COMPOSER)"
	@$(TABLE_M2) "-- $(_C)[$(PDF_LATEX_NAME)]$(_D) $(_C)[PDF]"	"$(_M)$(PDF_LATEX_VER)"
	@$(TABLE_M2) "$(_H)Supporting Tools:"				"$(_H)$(MARKER)"
	@$(TABLE_M2) "-- $(_E)[Git SCM]"				"$(_E)$(GIT_VER)"
	@$(TABLE_M2) "-- $(_E)[GNU Diffutils]"				"$(_E)$(DIFFUTILS_VER)"
	@$(TABLE_M2) "-- $(_E)[Rsync]"					"$(_E)$(RSYNC_VER)"
else
	@$(TABLE_M3) "$(_H)Project"					"$(_H)$(COMPOSER_BASENAME) Version"	"$(_H)System Version"
	@$(TABLE_M3) ":---"						":---"					":---"
	@$(TABLE_M3) "$(_C)[GNU Bash]"					"$(_M)$(BASH_VER)"			"$(_D)$$($(BASH) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_C)[GNU Coreutils]"				"$(_M)$(COREUTILS_VER)"			"$(_D)$$($(LS) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_C)[GNU Findutils]"				"$(_M)$(FINDUTILS_VER)"			"$(_D)$$($(FIND) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_C)[GNU Sed]"				"$(_M)$(SED_VER)"			"$(_D)$$($(SED) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_C)[GNU Make]"					"$(_M)$(MAKE_VER)"			"$(_D)$$($(REALMAKE) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_C)[Pandoc]"					"$(_M)$(PANDOC_VER_COMPOSER)"		"$(_D)$$($(PANDOC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_C)[YQ]"					"$(_M)$(YQ_VER_COMPOSER)"		"$(_D)$$($(YQ) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_C)[$(PDF_LATEX_NAME)]$(_D) $(_C)[PDF]"	"$(_M)$(PDF_LATEX_VER)"			"$(_D)$$($(PDF_LATEX) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_H)Supporting Tools:"				"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "-- $(_E)[Git SCM]"				"$(_E)$(GIT_VER)"			"$(_N)$$($(GIT) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_E)[GNU Diffutils]"				"$(_E)$(DIFFUTILS_VER)"			"$(_N)$$($(DIFF) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_E)[Rsync]"					"$(_E)$(RSYNC_VER)"			"$(_N)$$($(RSYNC) --version		2>/dev/null | $(HEAD) -n1)"
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(TABLE_M3) "$(_H)Target: $(UPGRADE)"				"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "-- $(_E)Wget"					"$(_E)$(WGET_VER)"			"$(_N)$$($(WGET) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_E)GNU Tar"					"$(_E)$(TAR_VER)"			"$(_N)$$($(TAR) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_E)GNU Gzip"					"$(_E)$(GZIP_VER)"			"$(_N)$$($(GZIP_BIN) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_E)7z"					"$(_E)$(7Z_VER)"			"$(_N)$$($(7Z)				2>/dev/null | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_M3) "-- $(_E)Node.js (npm)"				"$(_E)$(NPM_VER)"			"$(_N)$$($(NPM) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "-- $(_E)Curl"					"$(_E)$(CURL_VER)"			"$(_N)$$($(CURL) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_M3) "$(_H)Target: $(EXPORTS)"				"$(_H)$(MARKER)"			"$(_H)$(MARKER)"
	@$(TABLE_M3) "-- $(_E)[Google Firebase]"			"$(_E)$(FIREBASE_VER_COMPOSER)"		"$(_N)$$($(call FIREBASE_RUN) --version	2>/dev/null | $(HEAD) -n1)"
endif
	@$(ENDOLINE)
	@$(TABLE_M2) "$(_H)Project"					"$(_H)Location & Options"
	@$(TABLE_M2) ":---"						":---"
	@$(TABLE_M2) "$(_C)[GNU Bash]"					"$(_D)$(BASH)"
	@$(TABLE_M2) "-- $(_C)[GNU Coreutils]"				"$(_D)$(LS)"
	@$(TABLE_M2) "-- $(_C)[GNU Findutils]"				"$(_D)$(FIND)"
	@$(TABLE_M2) "-- $(_C)[GNU Sed]"				"$(_D)$(SED)"
	@$(TABLE_M2) "$(_C)[GNU Make]"					"$(_D)$(REALMAKE)$(if $(COMPOSER_DOITALL_$(CHECKIT)), $(_H)$(MAKEFLAGS))"
	@$(TABLE_M2) "-- $(_C)[Pandoc]"					"$(if $(filter $(PANDOC),$(PANDOC_BIN)),$(_M),$(_E))$(call $(HEADERS)-path-dir,$(PANDOC))"
	@$(TABLE_M2) "-- $(_C)[YQ]"					"$(if $(filter $(YQ),$(YQ_BIN)),$(_M),$(_E))$(call $(HEADERS)-path-dir,$(YQ))"
	@$(TABLE_M2) "-- $(_C)[$(PDF_LATEX_NAME)]$(_D) $(_C)[PDF]"	"$(_D)$(PDF_LATEX)"
	@$(TABLE_M2) "$(_H)Supporting Tools:"				"$(_H)$(MARKER)"
	@$(TABLE_M2) "-- $(_E)[Git SCM]"				"$(_N)$(GIT)"
	@$(TABLE_M2) "-- $(_E)[GNU Diffutils]"				"$(_N)$(DIFF)"
	@$(TABLE_M2) "-- $(_E)[Rsync]"					"$(_N)$(RSYNC)"
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(TABLE_M2) "$(_H)Target: $(UPGRADE)"				"$(_H)$(MARKER)"
	@$(TABLE_M2) "-- $(_E)Wget"					"$(_N)$(WGET)"
	@$(TABLE_M2) "-- $(_E)GNU Tar"					"$(_N)$(TAR)"
	@$(TABLE_M2) "-- $(_E)GNU Gzip"					"$(_N)$(GZIP_BIN)"
	@$(TABLE_M2) "-- $(_E)7z"					"$(_N)$(7Z)"
	@$(TABLE_M2) "-- $(_E)Node.js (npm)"				"$(_N)$(NPM)"
	@$(TABLE_M2) "-- $(_E)Curl"					"$(_N)$(CURL)"
	@$(TABLE_M2) "$(_H)Target: $(EXPORTS)"				"$(_H)$(MARKER)"
	@$(TABLE_M2) "-- $(_E)[Google Firebase]"			"$(if $(filter $(FIREBASE),$(FIREBASE_BIN)),$(_M),$(_E))$(call $(HEADERS)-path-dir,$(FIREBASE))"
endif
ifneq ($(COMPOSER_DOITALL_$(CHECKIT)),)
	@$(ENDOLINE)
	@$(PRINT) "$(_E)*$(OS_UNAME)*"
endif
endif

########################################
## {{{2 $(CONFIGS)
########################################

#> update: COMPOSER_OPTIONS
#> update: $(HEADERS)-run

.PHONY: $(CONFIGS)
$(CONFIGS): .set_title-$(CONFIGS)
$(CONFIGS):
	@$(call $(HEADERS))
	@$(call $(EXPORTS)-$(CONFIGS))
#>	@$(TABLE_M2) "$(_H)Variable"		"$(_H)Value"
#>	@$(TABLE_M2) ":---"			":---"
	@$(foreach FILE,$(COMPOSER_OPTIONS),\
		$(eval override OUT := $(strip \
			$(if $(filter c_list,$(FILE)),$(call $(HEADERS)-path-root,$(call c_list_var))$(if $(call c_list_var_source),$(_D) $(_S)\#$(MARKER)$(_D) $(_E)$(call c_list_var_source,,,1)) ,\
			$(if $(filter c_css,$(FILE)),$(call $(HEADERS)-path-root,$(call c_css_select,$(c_type))) ,\
			$(subst ",\",$(call $(HEADERS)-path-root,$($(FILE)))) \
			)) \
		)) \
		$(TABLE_M2) "$(_C)$(FILE)"	"$(_M)$(OUT)$(if $(filter $(FILE),$(COMPOSER_OPTIONS_GLOBAL)),$(_D)$(if $(OUT), )$(_H)$(MARKER))"; \
	)
ifneq ($(COMPOSER_YML_LIST),)
	@$(LINERULE)
#>		| $(YQ_WRITE_OUT) 2>/dev/null
	@$(ECHO) '$(call YQ_EVAL_DATA_FORMAT,$(COMPOSER_YML_DATA))' \
		| $(YQ_WRITE_OUT) \
			$(YQ_WRITE_OUT_COLOR)
endif
ifeq ($(COMPOSER_DOITALL_$(CONFIGS)),$(DOITALL))
	@$(LINERULE)
	@$(subst $(NULL) - , ,$(ENV)) | $(SORT)
	@$(LINERULE)
	@$(call ENV_MAKE) $(CONFIGS)-env
endif

.PHONY: $(CONFIGS)-env
$(CONFIGS)-env:
	@$(subst $(NULL) - , ,$(ENV)) | $(SORT)

.PHONY: $(CONFIGS)-%
$(CONFIGS)-%:
	@$(ECHO) "$($(*))\n" \
		| $(SED) \
			-e "s|[[:space:]]+|\n|g" \
			-e "/^$$/d" \

#>		| $(SORT)

.PHONY: $(CONFIGS)-yml
$(CONFIGS)-yml:
ifneq ($(COMPOSER_YML_LIST),)
#>	@$(ECHO) '$(call YQ_EVAL_DATA_FORMAT,$(COMPOSER_YML_DATA))' | $(YQ_WRITE) 2>/dev/null
	@$(ECHO) '$(call YQ_EVAL_DATA_FORMAT,$(COMPOSER_YML_DATA))' | $(YQ_WRITE)
else
	@$(ECHO) "{}\n"
endif

########################################
## {{{2 $(TARGETS)
########################################

.PHONY: $(TARGETS)
$(TARGETS): .set_title-$(TARGETS)
$(TARGETS):
	@$(call $(HEADERS))
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(TARGETS)-$(TARGETS)
	@$(LINERULE)
	@$(foreach FILE,\
		TARGETS \
		SUBDIRS \
		,\
		$(PRINT) "$(_H)$(MARKER) COMPOSER_$(FILE)"; \
		$(ECHO) "$(COMPOSER_$(FILE))" \
			| $(SED) "s|[ ]+|\n|g" \
			| $(SORT); \
		$(call NEWLINE) \
	)
	@$(LINERULE)
	@$(foreach FILE,\
		EXPORTS \
		CLEANER \
		DOITALL \
		,\
		$(PRINT) "$(_H)$(MARKER) *-$($(FILE))"; \
		$(call $(TARGETS)-$(PRINTER),,$($(FILE))) \
			| $(SED) "s|[ ]+|\n|g" \
			| $(SORT); \
		$(call NEWLINE) \
	)
	@$(LINERULE)
	@$(MAKE) $(PRINTER)-$(PRINTER)

########################################
### {{{3 $(TARGETS)-$(PRINTER)
########################################

#> $(TARGETS)-$(TARGETS) > $(TARGETS)-$(PRINTER)

#> update: TYPE_TARGETS
#> update: PANDOC_FILES
override define $(TARGETS)-$(PRINTER) =
	$(call ENV_MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(LISTING) | $(SED) \
		-e "/^$(MAKEFILE)[:]/d" \
		-e "/^$(COMPOSER_REGEX_PREFIX)/d" \
		$(foreach FILE,$(COMPOSER_RESERVED),-e "/^$(FILE)[:-]/d") \
		$(if $(COMPOSER_EXT),-e "/^[^:]+$(subst .,[.],$(COMPOSER_EXT))[:]/d") \
		$(if $(1),,\
			$(foreach TYPE,$(TYPE_TARGETS_LIST),\
				$(foreach FILE,$(call $(COMPOSER_PANDOC)-dependencies,$(TYPE_$(TYPE))),\
					-e "s|$(shell \
						$(ECHO) "$(FILE)" \
						| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
					)||g" \
				) \
			) \
		) \
		$(if $(2),\
			-e "s|[:]+.*$$||g" \
			| $(SED) -n "/[-]$(2)$$/p" \
		,\
			-e "/^[^:]+[-]$(EXPORTS)[:]+.*$$/d" \
			-e "/^[^:]+[-]$(CLEANER)[:]+.*$$/d" \
			-e "/^[^:]+[-]$(DOITALL)[:]+.*$$/d" \
			-e "s|[:]+[[:space:]]*$$||g" \
			-e "s|([=])+[[:space:]]*$$|\\1|g" \
			-e "s|[[:space:]]+|$(TOKEN)|g" \
		)
endef

########################################
### {{{3 $(TARGETS)-$(TARGETS)
########################################

#> $(TARGETS)-$(TARGETS) > $(TARGETS)-$(PRINTER)

override $(TARGETS)-$(TARGETS) :=
ifneq ($(filter $(TARGETS)-$(TARGETS),$(MAKECMDGOALS)),)
override $(TARGETS)-$(TARGETS) := $(sort $(shell $(call $(TARGETS)-$(PRINTER),$(COMPOSER_DEBUGIT))))
endif

.PHONY: $(TARGETS)-$(TARGETS)
$(TARGETS)-$(TARGETS):
	@$(foreach FILE,$(call $(HEADERS)-path-root,$($(TARGETS)-$(TARGETS))),\
		$(eval override NAME := $(word 1,$(subst :, ,$(filter $(FILE),$(subst :=,,$(FILE)))))) \
		$(eval override BASE := $(word 1,$(subst $(TOKEN), ,$(call PANDOC_FILES_SPLIT,$(NAME))))) \
		$(eval override EXTN := $(word 2,$(subst $(TOKEN), ,$(call PANDOC_FILES_SPLIT,$(NAME))))) \
		$(if $(COMPOSER_DEBUGIT),	$(ECHO) "$(_M)$(subst :\n,$(_D) $(DIVIDE)\n$(_C),$(subst $(TOKEN),\n\t,$(subst ",\",$(FILE))))"; ,\
						$(ECHO) "$(_M)$(subst : ,$(_D) $(DIVIDE) $(_C),$(subst $(TOKEN), ,$(subst ",\",$(FILE))))"; \
		) \
		$(if $(call c_list_var_source,$(BASE),$(EXTN)),\
		$(if $(COMPOSER_DEBUGIT),	$(ECHO) "$(_D)\n\t$(_S)#$(MARKER)$(_D) $(_E)$(call c_list_var_source,$(BASE),$(EXTN))"; ,\
						$(ECHO) "$(_D) $(_S)#$(MARKER)$(_D) $(_E)$(call c_list_var_source,$(BASE),$(EXTN))"; \
		)) \
		$(ENDOLINE); \
		$(call NEWLINE) \
	)
	@$(ECHO) ""

################################################################################
# {{{1 Repository Targets
################################################################################

########################################
## {{{2 $(DOSETUP)
########################################

#> update: $(NOTHING)-%

.PHONY: $(DOSETUP)
$(DOSETUP): .set_title-$(DOSETUP)
$(DOSETUP):
	@$(call $(HEADERS))
ifneq ($(or \
	$(COMPOSER_RELEASE) ,\
	$(filter $(COMPOSER),$(COMPOSER_DOSETUP_DIR)/$(MAKEFILE)) \
),)
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)--makefile $(EXPAND)/$(MAKEFILE),$(NOTHING))
else
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_DOSETUP_DIR)
ifeq ($(COMPOSER_DOITALL_$(DOSETUP)),$(DOFORCE))
	@$(foreach FILE,$(shell \
			$(FIND) $(COMPOSER_DOSETUP_DIR) -mindepth 1 -maxdepth 1 -type l 2>/dev/null \
			| $(SORT) \
		),\
		$(RM) $(FILE); \
		$(call NEWLINE) \
	)
endif
	@$(ECHO) "$(_D)"
	@$(foreach FILE,\
		$(COMPOSER) \
		$(COMPOSER_DIR)/.gitignore \
		$(COMPOSER_SRC) \
		$(COMPOSER_ART) \
		$(foreach FILE,$(REPOSITORIES_LIST),$($(FILE)_DIR)) \
		,\
		if [ ! -e "$(COMPOSER_DOSETUP_DIR)/$(notdir $(FILE))" ]; then \
			$(ECHO) "$(_E)"; \
			$(LN) $(FILE) $(COMPOSER_DOSETUP_DIR)/$(notdir $(FILE)); \
			$(ECHO) "$(_D)"; \
		fi; \
		$(call NEWLINE) \
	)
	@$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL),$(COMPOSER_DOSETUP_DIR)/$(MAKEFILE),$(filter $(DOFORCE),$(COMPOSER_DOITALL_$(DOSETUP))))
	@$(ECHO) "$(_M)"
	@$(CAT) $(CURDIR)/Makefile | $(SED) "/^$$/d"
	@$(ECHO) "$(_D)"
	@if [ ! -e "$(CURDIR)/.gitignore" ]; then \
		$(ECHO) "$(_E)"; \
		$(CP) $(COMPOSER_DOSETUP_DIR)/.gitignore $(CURDIR)/.gitignore; \
		$(ECHO) "$(_D)"; \
	fi
ifeq ($(wildcard $(firstword $(DIFF))),)
	@$(MAKE) $(NOTHING)-diff
else
	@$(ECHO) "$(_C)"
	@$(DIFF) $(COMPOSER_DOSETUP_DIR)/.gitignore $(CURDIR)/.gitignore 2>/dev/null || $(TRUE)
	@$(ECHO) "$(_D)"
endif
	@$(LS) $(COMPOSER_DOSETUP_DIR)
endif

########################################
## {{{2 $(CONVICT)
########################################

#> update: $(NOTHING)-%

override GIT_OPTS_CONVICT		:= --verbose $(if \
	$(filter $(PRINTER),$(COMPOSER_DOITALL_$(CONVICT))) ,\
	$(addprefix .$(patsubst $(COMPOSER_ROOT)%,%,$(CURDIR))/,$(c_list)) ,\
	$(addprefix .,$(patsubst $(COMPOSER_ROOT)%,%,$(CURDIR))/) \
)

.PHONY: $(CONVICT)
$(CONVICT): .set_title-$(CONVICT)
$(CONVICT):
	@$(call $(HEADERS))
ifeq ($(wildcard $(firstword $(GIT))),)
	@$(MAKE) $(NOTHING)-git
else
	@$(call GIT_RUN_COMPOSER,add --all $(GIT_OPTS_CONVICT))
	@$(call GIT_RUN_COMPOSER,commit \
		$(if $(filter $(DOITALL),$(COMPOSER_DOITALL_$(CONVICT))),,--edit) \
		--message='$(call COMPOSER_TIMESTAMP)' \
		$(GIT_OPTS_CONVICT) \
	)
endif

########################################
## {{{2 $(EXPORTS)
########################################

#> update: $(NOTHING)-%

.PHONY: $(EXPORTS)
$(EXPORTS): .set_title-$(EXPORTS)
$(EXPORTS):
	@$(call $(HEADERS))
	@$(call $(EXPORTS)-$(CONFIGS),1)
ifeq ($(and \
	$(wildcard $(firstword $(GIT))) ,\
	$(wildcard $(firstword $(RSYNC))) \
),)
	@$(MAKE) $(NOTHING)-git
	@$(MAKE) $(NOTHING)-rsync
else
ifneq ($(COMPOSER_DOITALL_$(EXPORTS)),$(DOFORCE))
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(EXPORTS)-$(TARGETS)
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(SUBDIRS)-$(TARGETS)-$(EXPORTS)
	@$(call $(HEADERS)-action,$(COMPOSER_EXPORT),empty,directories,,1)
	@while [ -n "$$($(FIND) $(COMPOSER_EXPORT) -type d -empty 2>/dev/null)" ]; do \
		$(FIND) $(COMPOSER_EXPORT) -type d -empty \
		| while read -r FILE; do \
			FILE="$$( \
				$(ECHO) "$${FILE}" \
				| $(SED) "s|^$(COMPOSER_EXPORT_REGEX)[/]||g" \
			)"; \
			$(call $(HEADERS)-rm,$(COMPOSER_EXPORT),$${FILE}); \
			$(ECHO) "$(_S)"; \
			$(RM) --dir $(COMPOSER_EXPORT)/$${FILE} $($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
		done; \
	done
	@$(call $(HEADERS)-action,$(COMPOSER_EXPORT),empty,files,,1)
	@$(LS) --directory $$($(FIND) $(COMPOSER_EXPORT) -empty) \
		| $(SED) \
			-e "s|$(COMPOSER_EXPORT_REGEX)[/]||g" \
			-e "/[.][/]$$/d"
endif
#>	$(_EXPORT_DIRECTORY)
ifneq ($(and \
	$(COMPOSER_DOITALL_$(EXPORTS)) ,\
	$(filter $(COMPOSER_ROOT)/%,$(COMPOSER_EXPORT)) \
),)
ifneq ($(and \
	$(_EXPORT_GIT_REPO) ,\
	$(_EXPORT_GIT_BNCH) \
),)
	@$(call GIT_RUN_COMPOSER,subtree split $(if $(COMPOSER_DEBUGIT),-d) --prefix "$(patsubst $(COMPOSER_ROOT)/%,%,$(COMPOSER_EXPORT))" --branch "$(_EXPORT_GIT_BNCH)") || $(TRUE)
	@$(call GIT_RUN_COMPOSER,log --max-count="$(GIT_LOG_COUNT)" --pretty=format:'$(GIT_LOG_FORMAT)' "$(_EXPORT_GIT_BNCH)")
	@$(ENDOLINE)
	@$(call GIT_RUN_COMPOSER,push --force "$(_EXPORT_GIT_REPO)" "$(_EXPORT_GIT_BNCH)")
else
	@$(MAKE) $(NOTHING)-$(EXPORTS)-git
endif
ifneq ($(and \
	$(_EXPORT_FIRE_ACCT) ,\
	$(_EXPORT_FIRE_PROJ) \
),)
ifeq ($(wildcard $(COMPOSER_ROOT)/firebase.json),)
	@$(call $(HEADERS)-action,$(COMPOSER_ROOT),firebase,init,,1)
	@$(call FIREBASE_RUN) \
		--interactive \
		login
	@$(call FIREBASE_RUN) \
		--account $(_EXPORT_FIRE_ACCT) \
		--project $(_EXPORT_FIRE_PROJ) \
		--interactive \
		init hosting
endif
	@$(call $(HEADERS)-action,$(COMPOSER_ROOT),firebase,,,1)
	@$(call FIREBASE_RUN) \
		--config $(COMPOSER_ROOT)/firebase.json \
		--account $(_EXPORT_FIRE_ACCT) \
		--project $(_EXPORT_FIRE_PROJ) \
		--non-interactive \
		projects:list
	@$(call FIREBASE_RUN) \
		--config $(COMPOSER_ROOT)/firebase.json \
		--public $(patsubst $(COMPOSER_ROOT)/%,%,$(COMPOSER_EXPORT)) \
		--account $(_EXPORT_FIRE_ACCT) \
		--project $(_EXPORT_FIRE_PROJ) \
		--non-interactive \
		deploy --only hosting
else
	@$(MAKE) $(NOTHING)-$(EXPORTS)-firebase
endif
endif
endif

########################################
### {{{3 $(EXPORTS)-$(CONFIGS)
########################################

#>		[ -n "$(_EXPORT_DIRECTORY)" ] ||
override define $(EXPORTS)-$(CONFIGS) =
	if	[ "$(COMPOSER_EXPORT)" != "$(COMPOSER_EXPORT_DEFAULT)" ] || \
		[ -n "$(_EXPORT_GIT_REPO)" ] || \
		[ -n "$(_EXPORT_GIT_BNCH)" ] || \
		[ -n "$(_EXPORT_FIRE_ACCT)" ] || \
		[ -n "$(_EXPORT_FIRE_PROJ)" ] || \
		[ -n "$(1)" ]; \
	then \
		$(foreach FILE,\
			_EXPORT_DIRECTORY \
			_EXPORT_GIT_REPO \
			_EXPORT_GIT_BNCH \
			_EXPORT_FIRE_ACCT \
			_EXPORT_FIRE_PROJ \
			,\
			$(TABLE_C2) "$(_C)$(FILE)" "[$(strip \
				$(if $(filter $(FILE),_EXPORT_DIRECTORY),\
					$(if $(filter $(COMPOSER_EXPORT),$(COMPOSER_EXPORT_DEFAULT)),	$(_H)$(COMPOSER_EXPORT) ,\
					$(if $(filter $(COMPOSER_ROOT)/%,$(COMPOSER_EXPORT)),		$(_H)$(COMPOSER_ROOT)$(_D)/$(_M)$(patsubst $(COMPOSER_ROOT)/%,%,$(COMPOSER_EXPORT)) ,\
													$(_E)$(COMPOSER_EXPORT) \
					)) \
				,\
					$(if $(filter $(COMPOSER_ROOT)/%,$(COMPOSER_EXPORT)),		$(_M)$($(FILE)) ,\
					$(_N)$($(FILE)) \
					) \
				) \
			)$(_D)]"; \
		) \
		$(HEADER_L); \
	fi
endef

########################################
### {{{3 $(EXPORTS)-%
########################################

#> $(EXPORTS)-$(TARGETS) > $(EXPORTS)-%

########################################
#### {{{4 $(EXPORTS)-tree
########################################

#>		-o \\\( -path \"$(1)/.*\" -prune \\\)
override define $(EXPORTS)-tree =
	$(call $(EXPORTS)-find,$(1)) \
		-o \\\( -type d -print \\\)
endef

########################################
#### {{{4 $(EXPORTS)-find
########################################

#>		-o \\\( -path $(COMPOSER_LIBRARY) -prune \\\)
#>			-o \( -path $(COMPOSER_LIBRARY) -prune \)
override define $(EXPORTS)-find =
	eval $(FIND_ALL) $(1) -regextype sed \
		\\\( -path $(COMPOSER_DIR) -prune \\\) \
		-o \\\( -path $(COMPOSER_TMP) -prune \\\) \
		-o \\\( -path \"\*/$(notdir $(COMPOSER_TMP))\" -prune \\\) \
		-o \\\( -path $(COMPOSER_EXPORT) -prune \\\) \
		$$(if [ -z "$(3)" ]; then $(FIND_ALL) $(1) \
			\( -path $(COMPOSER_DIR) -prune \) \
			-o \( -path $(COMPOSER_TMP) -prune \) \
			-o \( -path \"*/$(notdir $(COMPOSER_TMP))\" -prune \) \
			-o \( -path $(COMPOSER_EXPORT) -prune \) \
			-o \( -type d -print \) \
				| while read -r EDIR; do \
					$(call ENV_MAKE) --directory $${EDIR} $(CONFIGS)-COMPOSER_IGNORES 2>/dev/null \
						| $(SORT) \
						| while read -r EFIL; do \
							$(ECHO) " -o \\\( -regex \"$${EDIR}/$${EFIL/\*/[^/]*}\" $(if $(2),$(2) -print,-prune) \\\)"; \
						done; \
				done; \
		fi) \
		$(if $(2),-o \\\( -path /dev/null -print \\\))
endef

########################################
#### {{{4 $(EXPORTS)-libraries
########################################

override define $(EXPORTS)-libraries =
	if [ "$(1)" = "$(COMPOSER_ROOT)" ]; then \
		$(call $(EXPORTS)-library,$(COMPOSER_DIR),$(COMPOSER_ROOT)); \
	fi; \
	$(FIND_ALL) $(1) \
		\( -path $(2) -prune \) \
		-o \( -path $(COMPOSER_DIR) -prune \) \
		-o \( -path $(COMPOSER_TMP) -prune \) \
		-o \( -path "*/$(notdir $(COMPOSER_TMP))" -prune \) \
		-o \( -path "*/$(COMPOSER_YML)" -print \) \
			| $(SED) "s|[/]$(COMPOSER_YML)$$||g" \
			| while read -r LDIR; do \
				$(call $(EXPORTS)-library,$${LDIR}); \
			done
endef

########################################
#### {{{4 $(EXPORTS)-library
########################################

override define $(EXPORTS)-library =
	LFIL="$$( \
		$(YQ_WRITE) ".variables.$(PUBLISH)-library.folder" $(1)/$(COMPOSER_YML) 2>/dev/null \
		| $(SED) "/^null$$/d" \
	)"; \
	if [ -n "$${LFIL}" ]; then \
		$(ECHO) " -o \\\( -path $(if $(2),$(2),$(1))/$$( \
			$(ECHO) "$${LFIL}" \
			| $(SED) "s|^.*[/]([^/]+)$$|\1|g" \
		) -prune \\\)\n"; \
	fi
endef

########################################
#### {{{4 $(EXPORTS)-filter
########################################

#>		$(ECHO) " -o \\\( -path \"$(3)/.*\" -prune \\\)";
override define $(EXPORTS)-filter =
	if [ -z "$(1)" ]; then \
		$(ECHO) "-mindepth 1 -maxdepth 1 \\\( -type d -prune \\\)"; \
	fi; \
	$(ECHO) "$(sort $(foreach SAFE,$(patsubst $(3)/%,%,$(filter $(3)/%,$(2))),$(word 1,$(subst /, ,$(SAFE)))))" | $(TR) ' ' '\n' \
		| $(SORT) \
		| while read -r FILE; do \
			if [ -n "$(1)" ]; then	$(ECHO) "--filter=P_/$$( \
							$(ECHO) "$${FILE}" \
							| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
							| $(SED) "s|\[\*\]|*|g" \
						)\n"; \
			fi; \
		done; \
	$(call ENV_MAKE) --directory $(3) $(CONFIGS)-COMPOSER_IGNORES 2>/dev/null \
		| $(SORT) \
		| while read -r FILE; do \
			if [ -n "$(1)" ]; then	$(ECHO) "--filter=-_/$$( \
							$(ECHO) "$${FILE}" \
							| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
							| $(SED) "s|\[\*\]|*|g" \
						)\n"; \
			else			$(ECHO) " -o \\\( -path \"$(3)/$${FILE}\" -prune \\\)"; \
			fi; \
		done; \
	$(call ENV_MAKE) --directory $(3) $(CONFIGS)-COMPOSER_EXPORTS 2>/dev/null \
		| $(SORT) \
		| while read -r FILE; do \
			if [ -n "$(1)" ]; then	$(ECHO) "--filter=+_/$$( \
							$(ECHO) "$${FILE}" \
							| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
							| $(SED) "s|\[\*\]|*|g" \
						)\n"; \
			else			$(ECHO) " -o \\\( -path \"$(3)/$${FILE}\" -print \\\)"; \
			fi; \
		done; \
	if [ -n "$(1)" ]; then			$(ECHO) "--filter=-_/*"; \
	else					$(ECHO) " -o \\\( -path /dev/null -print \\\)"; \
						$(ECHO) " -o -prune"; \
	fi
endef

########################################
### {{{3 $(EXPORTS)-$(TARGETS)
########################################

#> $(EXPORTS)-$(TARGETS) > $(EXPORTS)-%

override $(EXPORTS)-$(TARGETS) :=
ifneq ($(or \
	$(filter $(EXPORTS)-$(TARGETS),$(MAKECMDGOALS)) ,\
	$(filter $(EXPORTS)-$(TARGETS)-%,$(MAKECMDGOALS)) ,\
),)
override $(EXPORTS)-$(TARGETS) := $(sort $(shell $(call $(EXPORTS)-tree,$(COMPOSER_ROOT))))
endif

.PHONY: $(EXPORTS)-$(TARGETS)
$(EXPORTS)-$(TARGETS): $(addprefix $(EXPORTS)-$(TARGETS)-,$($(EXPORTS)-$(TARGETS)))
$(EXPORTS)-$(TARGETS):
	@$(ECHO) ""

.PHONY: $(addprefix $(EXPORTS)-$(TARGETS)-,$($(EXPORTS)-$(TARGETS)))
$(addprefix $(EXPORTS)-$(TARGETS)-,$($(EXPORTS)-$(TARGETS))):
	@$(eval override $(@) := $(patsubst $(EXPORTS)-$(TARGETS)-%,%,$(@)))
	@$(call $(HEADERS)-action,$($(@)),,,$(EXPORTS))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_EXPORT)$(patsubst $(COMPOSER_ROOT)%,%,$($(@))) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(RSYNC) \
		--copy-links \
		--delete-excluded \
		$$($(call $(EXPORTS)-filter,1,$($(EXPORTS)-$(TARGETS)),$($(@)))) \
		$(COMPOSER_ROOT)$(patsubst $(COMPOSER_ROOT)%,%,$($(@)))/ \
		$(COMPOSER_EXPORT)$(patsubst $(COMPOSER_ROOT)%,%,$($(@)))

################################################################################
# {{{1 Composer Targets
################################################################################

########################################
## {{{2 $(PUBLISH)
########################################

.PHONY: $(PUBLISH)
$(PUBLISH): .set_title-$(PUBLISH)
$(PUBLISH):
	@$(call $(HEADERS))
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) c_site="1" $(DOITALL)

########################################
### {{{3 $(PUBLISH)-$(CLEANER)
########################################

.PHONY: $(PUBLISH)-$(CLEANER)
$(PUBLISH)-$(CLEANER): .set_title-$(PUBLISH)-$(CLEANER)
$(PUBLISH)-$(CLEANER):
ifeq ($(MAKELEVEL),0)
	@$(call $(HEADERS))
endif
	@$(MAKE) $(PUBLISH)-$(CLEANER)-$(TARGETS)
	@if	[ -n "$(COMPOSER_LIBRARY)" ] && \
		[ -d "$(COMPOSER_LIBRARY)" ] && \
		[ "$(CURDIR)" = "$(COMPOSER_LIBRARY_ROOT)" ]; \
	then \
		$(call $(HEADERS)-rm,$(COMPOSER_LIBRARY_ROOT),$(notdir $(COMPOSER_LIBRARY))); \
		$(ECHO) "$(_S)"; \
		$(RM) --recursive $(COMPOSER_LIBRARY) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi

#> update: WILDCARD_YML

.PHONY: $(PUBLISH)-$(CLEANER)-$(TARGETS)
#>$(PUBLISH)-$(CLEANER)-$(TARGETS): $(addprefix $(PUBLISH)-$(CLEANER)-,$($(PUBLISH)-cache))
#>$(PUBLISH)-$(CLEANER)-$(TARGETS): $(addprefix $(PUBLISH)-$(CLEANER)-,$($(PUBLISH)-caches))
#>$(PUBLISH)-$(CLEANER)-$(TARGETS): $(addprefix $(PUBLISH)-$(CLEANER)-,$(wildcard $($(PUBLISH)-cache-root)-*))
$(PUBLISH)-$(CLEANER)-$(TARGETS): $(addprefix $(PUBLISH)-$(CLEANER)-,$(wildcard $($(PUBLISH)-cache-root)*))
$(PUBLISH)-$(CLEANER)-$(TARGETS):
	@$(ECHO) ""

#>.PHONY: $(addprefix $(PUBLISH)-$(CLEANER)-,$($(PUBLISH)-cache))
#>.PHONY: $(addprefix $(PUBLISH)-$(CLEANER)-,$($(PUBLISH)-caches))
#>.PHONY: $(addprefix $(PUBLISH)-$(CLEANER)-,$(wildcard $($(PUBLISH)-cache-root)-*))
.PHONY: $(addprefix $(PUBLISH)-$(CLEANER)-,$(wildcard $($(PUBLISH)-cache-root)*))
#>$(addprefix $(PUBLISH)-$(CLEANER)-,$($(PUBLISH)-cache))
#>$(addprefix $(PUBLISH)-$(CLEANER)-,$($(PUBLISH)-caches))
#>$(addprefix $(PUBLISH)-$(CLEANER)-,$(wildcard $($(PUBLISH)-cache-root)-*))
$(addprefix $(PUBLISH)-$(CLEANER)-,$(wildcard $($(PUBLISH)-cache-root)*)) \
:
	@$(eval override $(@) := $(patsubst $(PUBLISH)-$(CLEANER)-%,%,$(@)))
	@if [ -f "$($(@))" ]; then \
		$(call $(HEADERS)-rm,$(abspath $(dir $($(@)))),$(notdir $($(@)))); \
		$(ECHO) "$(_S)"; \
		$(RM) $($(@)) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi

########################################
### {{{3 $(PUBLISH)-$(TARGETS)
########################################

override define $(PUBLISH)-$(TARGETS) =
	HEADER="$$($(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.header)" | $(SED) "s|$(PUBLISH_CMD_ROOT)|$(COMPOSER_ROOT)|g")"; \
	FOOTER="$$($(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.footer)" | $(SED) "s|$(PUBLISH_CMD_ROOT)|$(COMPOSER_ROOT)|g")"; \
	$(ECHO) "$(_E)"; \
	$(ECHO) "" >$(1); \
	$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $(patsubst $(COMPOSER_ROOT)%,$(EXPAND)%,$(1)) -->\n" $($(PUBLISH)-$(DEBUGIT)-output); \
	$(call PUBLISH_SH_RUN) metainfo-block . $(SPECIAL_VAL) $(word 1,$(c_list)) \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	$(call $(PUBLISH)-$(TARGETS)-cache,$(1),$($(PUBLISH)-caches-begin)); \
	if [ -n "$${HEADER}" ]; then $(call $(PUBLISH)-$(TARGETS)-file,$(1),$${HEADER}); fi; \
	$(call $(PUBLISH)-$(TARGETS)-file,$(1),$(c_list)); \
	if [ -n "$${FOOTER}" ]; then $(call $(PUBLISH)-$(TARGETS)-file,$(1),$${FOOTER}); fi; \
	$(call $(PUBLISH)-$(TARGETS)-cache,$(1),$($(PUBLISH)-caches-end)); \
	$(ECHO) "$(_D)"
endef

override define $(PUBLISH)-$(TARGETS)-cache =
	for FILE in $(2); do \
		$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $($(PUBLISH)-cache).$${FILE}.$(EXTN_HTML) -->\n" \
			| $(SED) "s|$(COMPOSER_ROOT_REGEX)|$(EXPAND)|g"; \
		$(CAT) $($(PUBLISH)-cache).$${FILE}.$(EXTN_HTML); \
	done \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
endef

override define $(PUBLISH)-$(TARGETS)-file =
	for FILE in $(2); do \
		$(ECHO) "<!-- $(PUBLISH)-$(TARGETS) $(MARKER) $${FILE} -->\n" \
			| $(SED) "s|$(COMPOSER_ROOT_REGEX)|$(EXPAND)|g"; \
		$(call PUBLISH_SH_RUN) $${FILE}; \
	done \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
endef

########################################
#### {{{4 $(PUBLISH)-$(TARGETS)-helpers
########################################

override define $(PUBLISH)-$(TARGETS)-helpers =
	$(eval override HELPER := $(if $(filter metalist-%,$(2)),metalist,$(2))) \
	$(eval override TAGGER := $(if $(filter metalist-%,$(2)),$(patsubst metalist-%,%,$(2)),$(NULL))) \
	$(eval override DOFILE := $(1).$(HELPER)$(if $(TAGGER),-$(TAGGER))) \
	MENU="$$($(SED) -n "s|^$(PUBLISH_CMD_BEG) ($(HELPER)-menu$(if $(TAGGER),$(NULL) $(TAGGER)).*) $(PUBLISH_CMD_END)$$|\1|gp" $(1) | $(HEAD) -n1)"; \
	LIST="$$($(SED) -n "s|^$(PUBLISH_CMD_BEG) ($(HELPER)-list$(if $(TAGGER),$(NULL) $(TAGGER)).*) $(PUBLISH_CMD_END)$$|\1|gp" $(1) | $(HEAD) -n1)"; \
	if	[ -n "$${MENU}" ] || \
		[ -n "$${LIST}" ]; \
	then \
		MENU="$$($(ECHO) "$${MENU}" | $(SED) "s|^$(HELPER)-menu[[:space:]]*||g")"; \
		LIST="$$($(ECHO) "$${LIST}" | $(SED) "s|^$(HELPER)-list[[:space:]]*||g")"; \
		$(call $(HEADERS)-note,$(1),$(patsubst metalist-%,metalist (%),$(2)),$(PUBLISH)); \
		$(ECHO) "$(_E)"; \
		$(ECHO) "" >$(DOFILE)-menu; \
		$(ECHO) "" >$(DOFILE)-list; \
		$(call $(PUBLISH)-$(TARGETS)-$(HELPER),$(1),$(TAGGER)); \
		$(PANDOC_MD_TO_HTML) $(DOFILE)-menu \
			>$(DOFILE)-menu.done; \
			if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
		$(call PUBLISH_SH_RUN) $(DOFILE)-list \
			| $(SED) "/[/]$$( \
					$(ECHO) "$(notdir $(DOFILE)-list)" \
					| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
				) -->$$/d" \
			>$(DOFILE)-list.done; \
			if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
		$(call $(PUBLISH)-$(TARGETS)-$(HELPER)-done,$(1),$(TAGGER)); \
		$(ECHO) "$(_S)"; \
		$(MV) $(DOFILE)-menu.done $(DOFILE)-menu $($(DEBUGIT)-output); \
		$(MV) $(DOFILE)-list.done $(DOFILE)-list $($(DEBUGIT)-output); \
		$(SED) -i "/^$(PUBLISH_CMD_BEG) $(HELPER)-menu$(if $(TAGGER),$(NULL) $(TAGGER)).* $(PUBLISH_CMD_END)$$/r $(DOFILE)-menu" $(1); \
		$(SED) -i "/^$(PUBLISH_CMD_BEG) $(HELPER)-list$(if $(TAGGER),$(NULL) $(TAGGER)).* $(PUBLISH_CMD_END)$$/r $(DOFILE)-list" $(1); \
		if [ -z "$(COMPOSER_DEBUGIT)" ]; then \
			$(RM) $(DOFILE)-menu $($(DEBUGIT)-output); \
			$(RM) $(DOFILE)-list $($(DEBUGIT)-output); \
		fi; \
		$(ECHO) "$(_D)"; \
	fi
endef

########################################
#### {{{4 $(PUBLISH)-$(TARGETS)-metainfo
########################################

override define $(PUBLISH)-$(TARGETS)-metainfo =
	if [ -n "$${LIST}" ]; then \
		$(ECHO) "$(PUBLISH_CMD_BEG) "				>>$(1).metainfo-list; \
		$(ECHO) "$${LIST} "					>>$(1).metainfo-list; \
	fi; \
	$(call PUBLISH_SH_RUN) metainfo-block . . $(1)			>>$(1).metainfo-list; \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi; \
	if [ -n "$${LIST}" ]; then $(ECHO) " $(PUBLISH_CMD_END)"	>>$(1).metainfo-list; fi; \
	$(ECHO) "\n"							>>$(1).metainfo-list
endef

override define $(PUBLISH)-$(TARGETS)-metainfo-done =
	$(ECHO) ""
endef

########################################
#### {{{4 $(PUBLISH)-$(TARGETS)-contents
########################################

#>			LIST_TXT="$${TXT}"; \
#>			if [ "$${LIST}" = "$(SPECIAL_VAL)" ]; then \
#>				LIST_TXT="$$( ... )"; \
#>			fi
override define $(PUBLISH)-$(TARGETS)-contents =
	PAST="$$( \
		$(filter-out --strip-comments,$(PANDOC_MD_TO_JSON)) $(1) \
		| $(YQ_WRITE) \
			"[.. | select(has(\"t\")) | select( \
				(.t == \"Header\") or \
				(select(.t == \"RawBlock\") | .c[1] | contains(\"<!-- $(PUBLISH)-header $(DIVIDE) start $(MARKER) \")) \
			) | .c]" \
			2>/dev/null \
		| $(SED) "s|\\\\|\\\\\\\\|g" \
	)"; \
	if [ -n "$(COMPOSER_DEBUGIT_ALL)" ]; then \
		$(ECHO) "$${PAST}"; \
	fi; \
	ROOT=; \
	if [ -n "$$($(ECHO) "$${MENU}" | $(SED) -n "/^$(MENU_SELF)/p")" ]; then \
		ROOT="$(MENU_SELF)"; \
		MENU="$${MENU/#$(MENU_SELF)}"; \
	fi; \
	if [ -z "$${MENU}" ]; then				MENU_MAX="$(DEPTH_MAX)"; \
		elif [ "$${MENU}" = "$(SPECIAL_VAL)" ]; then	MENU_MAX="$(DEPTH_MAX)"; \
		else						MENU_MAX="$${MENU}"; \
		fi; \
	if [ -z "$${LIST}" ]; then				LIST_MAX="$(DEPTH_MAX)"; \
		elif [ "$${LIST}" = "$(SPECIAL_VAL)" ]; then	LIST_MAX="$(DEPTH_MAX)"; \
		else						LIST_MAX="$${LIST}"; \
		fi; \
	CNT="$$($(ECHO) "$${PAST}" | $(YQ_WRITE) "length" 2>/dev/null)"; \
	NUM="0"; while [ "$${NUM}" -lt "$${CNT}" ]; do \
		MENU_HDR="$(SPECIAL_VAL)"; \
		LIST_HDR="$(SPECIAL_VAL)"; \
		LVL="$$($(ECHO) "$${PAST}" | $(YQ_WRITE) ".[$${NUM}][0]" 2>/dev/null)"; \
		if [ "$${LVL}" = "html" ]; then \
			LNK="$$($(ECHO) "$${PAST}" | $(YQ_WRITE) ".[$${NUM}][1]" 2>/dev/null)"; \
			LVL="$$($(ECHO) "$${LNK}" | $(SED) "s|^<!-- $(PUBLISH)-header $(DIVIDE) start $(MARKER) ([0-9]+) (.*) -->$$|\1|g")"; \
			TXT="$$($(ECHO) "$${LNK}" | $(SED) "s|^<!-- $(PUBLISH)-header $(DIVIDE) start $(MARKER) ([0-9]+) (.*) -->$$|\2|g")"; \
			LNK="$$($(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$${TXT}))"; \
		else \
			if [ "$${MENU}" = "$(SPECIAL_VAL)" ]; then MENU_HDR=; fi; \
			if [ "$${LIST}" = "$(SPECIAL_VAL)" ]; then LIST_HDR=; fi; \
			LNK="$$($(ECHO) "$${PAST}" | $(YQ_WRITE) ".[$${NUM}][1][0]" 2>/dev/null)"; \
			LEN="$$($(ECHO) "$${PAST}" | $(YQ_WRITE) ".[$${NUM}][2] | length" 2>/dev/null)"; \
			TXT=; STR="0"; while [ "$${STR}" -lt "$${LEN}" ]; do \
				TYP="$$( \
					$(ECHO) "$${PAST}" \
					| $(YQ_WRITE) ".[$${NUM}][2][$${STR}].[\"t\"]" 2>/dev/null \
				)"; \
				if [ "$${TYP}" = "Space" ]; then \
					TXT="$${TXT} "; \
				elif [ "$${TYP}" = "Code" ]; then \
					TXT="$${TXT}$$( \
						$(ECHO) "$${PAST}" \
						| $(YQ_WRITE) ".[$${NUM}][2][$${STR}].[\"c\"][1]" 2>/dev/null \
					)"; \
				elif [ "$${TYP}" = "Str" ]; then \
					TXT="$${TXT}$$( \
						$(ECHO) "$${PAST}" \
						| $(YQ_WRITE) ".[$${NUM}][2][$${STR}].[\"c\"]" 2>/dev/null \
					)"; \
				fi; \
				STR="$$($(EXPR) $${STR} + 1)"; \
			done; \
		fi; \
		$(ECHO) "$(MARKER) $${LVL}" $($(DEBUGIT)-output); \
		if [ -n "$${MENU_HDR}" ] && [ -n "$${TXT}" ] && [ "$${LVL}" -le "$${MENU_MAX}" ]; then \
			if [ "$${LVL}" = "1" ]; then	$(ECHO) "  *"				>>$(1).contents-menu; \
			elif [ "$${LVL}" = "2" ]; then	$(ECHO) "    *"				>>$(1).contents-menu; \
			elif [ "$${LVL}" = "3" ]; then	$(ECHO) "        *"			>>$(1).contents-menu; \
			elif [ "$${LVL}" = "4" ]; then	$(ECHO) "            *"			>>$(1).contents-menu; \
			elif [ "$${LVL}" = "5" ]; then	$(ECHO) "                *"		>>$(1).contents-menu; \
			elif [ "$${LVL}" = "6" ]; then	$(ECHO) "                    *"		>>$(1).contents-menu; \
			fi; \
			MENU_TXT="$$($(ECHO) "$${TXT}" | $(SED) "s|^(.*)$$( \
					$(ECHO) "$(HTML_HIDE)" \
					| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
				)(.*)$$|\1|g")"; \
			$(ECHO) " [$${MENU_TXT}](#$${LNK}){.dropdown-item}"			>>$(1).contents-menu; \
			$(ECHO) "\n"								>>$(1).contents-menu; \
			$(ECHO) " menu" $($(DEBUGIT)-output); \
		else \
			$(ECHO) "    -" $($(DEBUGIT)-output); \
		fi; \
		if [ -n "$${LIST_HDR}" ] && [ -n "$${TXT}" ] && [ "$${LVL}" -le "$${LIST_MAX}" ]; then \
			if [ "$${LVL}" = "1" ]; then	$(ECHO) "  *"				>>$(1).contents-list; \
			elif [ "$${LVL}" = "2" ]; then	$(ECHO) "    *"				>>$(1).contents-list; \
			elif [ "$${LVL}" = "3" ]; then	$(ECHO) "        *"			>>$(1).contents-list; \
			elif [ "$${LVL}" = "4" ]; then	$(ECHO) "            *"			>>$(1).contents-list; \
			elif [ "$${LVL}" = "5" ]; then	$(ECHO) "                *"		>>$(1).contents-list; \
			elif [ "$${LVL}" = "6" ]; then	$(ECHO) "                    *"		>>$(1).contents-list; \
			fi; \
			LIST_TXT="$$($(ECHO) "$${TXT}" | $(SED) "s|^(.*)$$( \
					$(ECHO) "$(HTML_HIDE)" \
					| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
				)(.*)$$|\1|g")"; \
			$(ECHO) " [$${LIST_TXT}](#$${LNK})"					>>$(1).contents-list; \
			$(ECHO) "\n"								>>$(1).contents-list; \
			$(ECHO) " list" $($(DEBUGIT)-output); \
		else \
			$(ECHO) "    -" $($(DEBUGIT)-output); \
		fi; \
		$(ECHO) " $(DIVIDE) $${TXT}\n" $($(DEBUGIT)-output); \
		NUM="$$($(EXPR) $${NUM} + 1)"; \
	done; \
	if [ -n "$${ROOT}" ]; then \
		$(SED) -i \
			-e "s|^  \* (.+)$$|\n\1\n|g" \
			-e "s|^    \* |  * |g" \
			-e "s|^    ||g" \
			$(1).contents-menu; \
	fi
endef

override define $(PUBLISH)-$(TARGETS)-contents-done =
	if [ -n "$${ROOT}" ]; then \
		if [ -n "$(COMPOSER_RELEASE)" ]; then \
			$(SED) -i "s|$(COMPOSER_BASENAME) ||g" $(1).contents-menu.done; \
		fi; \
		R_DD="<li class=\"nav-item dropdown\">"; \
		R_UL="<ul class=\"$(COMPOSER_TINYNAME)-menu-$(call COMPOSER_YML_DATA_VAL,config.cols_break) dropdown-menu\">"; \
		R_CL="class=\"nav-link dropdown-toggle\" data-bs-toggle=\"dropdown\""; \
		$(SED) -i "    N; s|^[<]p[>](.*)class[=][\"][^\"]+[\"](.*)[<][/]p[>]\n[<]ul[>]$$|</li>\n$${R_DD}\n\1$${R_CL}\2\n$${R_UL}|g" $(1).contents-menu.done; \
		$(SED) -i "1n; N; s|^[<]p[>](.*)class[=][\"][^\"]+[\"](.*)[<][/]p[>]\n[<]ul[>]$$|</li>\n$${R_DD}\n\1$${R_CL}\2\n$${R_UL}|g" $(1).contents-menu.done; \
		$(SED) -i "    N; s|^[<]p[>](.*)class[=][\"][^\"]+[\"](.*)[<][/]p[>]\n[<]ul[>]$$|</li>\n$${R_DD}\n\1$${R_CL}\2\n$${R_UL}|g" $(1).contents-menu.done; \
		$(SED) -i "1n; N; s|^[<]p[>](.*)class[=][\"][^\"]+[\"](.*)[<][/]p[>]\n[<]ul[>]$$|</li>\n$${R_DD}\n\1$${R_CL}\2\n$${R_UL}|g" $(1).contents-menu.done; \
		$(ECHO) "</li>\n\n" >>$(1).contents-menu.done; \
	fi; \
	$(SED) -i \
		-e "1d" \
		-e '$$d' \
		-e "s|^([<]ul)([>])$$|\1 class=\"$(COMPOSER_TINYNAME)-menu-list\"\2|g" \
		$(1).contents-menu.done
endef

########################################
#### {{{4 $(PUBLISH)-$(TARGETS)-metalist
########################################

override define $(PUBLISH)-$(TARGETS)-metalist =
	META="$(call COMPOSER_YML_DATA_VAL,config.metalist.[\"$(2)\"].display)"; \
	META_BEG="$$($(ECHO) "$${META}" | $(SED) "s|^(.*)[<][|][>](.*)[<][|][>](.*)$$|\1|g")"; \
	META_SEP="$$($(ECHO) "$${META}" | $(SED) "s|^(.*)[<][|][>](.*)[<][|][>](.*)$$|\2|g")"; \
	META_END="$$($(ECHO) "$${META}" | $(SED) "s|^(.*)[<][|][>](.*)[<][|][>](.*)$$|\3|g")"; \
	if [ -z "$${META_SEP}" ]; then \
		META_SEP=" "; \
	fi; \
	$(ECHO) "$${META_BEG}" >>$(1).metalist-$(2)-list; \
	for META in $(c_list); do \
		if [ -n "$$( \
			$(SED) -n "1{/^---$$/p}" $${META} \
		)" ]; then \
			$(SED) -n "1,/^---$$/p" $${META} \
			| $(YQ_WRITE_FILE) ".$(2)" \
			| $(SED) "s|^[-][ ]||g" \
			| $(SED) "/^null$$/d"; \
		fi; \
	done \
		| $(call $(PUBLISH)-library-sort-sh,$(2)) \
		| while read -r FILE; do \
			LINK="$(COMPOSER_LIBRARY_PATH)/$(2)-$$( \
					$(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$${FILE}) \
				).$(EXTN_HTML)"; \
			$(ECHO) "  * [$${FILE}]($${LINK}){.breadcrumb-item}\n"	>>$(1).metalist-$(2)-menu; \
			$(ECHO) "$${META_SEP}[$${FILE}]($${LINK})"		>>$(1).metalist-$(2)-list; \
		done; \
	$(ECHO) "$${META_END}\n" >>$(1).metalist-$(2)-list; \
	if [ ! -s "$(1).metalist-$(2)-menu" ]; then \
		$(ECHO) ""							>$(1).metalist-$(2)-list; \
	fi; \
	$(SED) -i "s|^($$( \
			$(ECHO) "$${META_BEG}" \
			| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
		))$$( \
			$(ECHO) "$${META_SEP}" \
			| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
		)|\1|g" \
		$(1).metalist-$(2)-list
endef

override define $(PUBLISH)-$(TARGETS)-metalist-done =
	$(SED) -i \
		-e "1d" \
		-e '$$d' \
		-e "s|^([<]li)([>][<]a .+)( class[=][\"].*breadcrumb-item.*[\"])(.+)$$|\1\3\2\4|g" \
		$(1).metalist-$(2)-menu.done
endef

########################################
#### {{{4 $(PUBLISH)-$(TARGETS)-readtime
########################################

override define $(PUBLISH)-$(TARGETS)-readtime =
	WORD="$$( \
		$(call PUBLISH_SH_RUN) $(c_list) \
		| $(PANDOC_MD_TO_TEXT) \
		| $(WC_WORD) \
	)"; \
	TIME="1"; \
	WPM="$(call COMPOSER_YML_DATA_VAL,config.readtime_wpm)"; \
	if [ "$${WORD}" -gt "$${WPM}" ]; then \
		TIME="$$($(EXPR) $${WORD} / $${WPM})"; \
	fi; \
	$(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.readtime)\n" \
		| $(SED) \
			-e "s|<word>|$${WORD}|g" \
			-e "s|<time>|$${TIME}|g" \
		>>$(1).readtime-list
endef

override define $(PUBLISH)-$(TARGETS)-readtime-done =
	$(SED) -i "/^$$/d" $(1).readtime-list.done
endef

########################################
### {{{3 $(PUBLISH)-cache
########################################

$($(PUBLISH)-cache): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH)-cache)
$($(PUBLISH)-cache): $($(PUBLISH)-caches)
$($(PUBLISH)-cache):
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$(@)

$($(PUBLISH)-caches): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH)-cache)
$($(PUBLISH)-caches):
	@$(eval $(@) := $(patsubst $($(PUBLISH)-cache).%.$(EXTN_HTML),%,$(@)))
#> update: WILDCARD_YML
	@$(call $(HEADERS)-note,$(abspath $(dir $($(PUBLISH)-cache))),$($(@)),$(PUBLISH)-cache,$(strip \
		$(if $(COMPOSER_YML_LIST_FILE),$(patsubst $($(PUBLISH)-cache-root)-%.$($(@)).$(EXTN_HTML),%,$(@)))))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_TMP) $($(DEBUGIT)-output)
	@$(ECHO) "$(_E)"
	@if [ "$($(@))" = "nav-top" ]; then \
		$(call PUBLISH_SH_RUN) "$($(@))" "$(c_logo)"; \
	elif [ "$($(@))" = "column-begin" ]; then \
		$(call PUBLISH_SH_RUN) "$($(@))" "center"; \
	else \
		$(call PUBLISH_SH_RUN) "$($(@))"; \
	fi \
		| $(TEE) $(@).$(COMPOSER_BASENAME) $($(PUBLISH)-$(DEBUGIT)-output); \
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
### {{{3 $(PUBLISH)-library
########################################

#> all		$(PUBLISH)-library
#> not sitemap	c_site="1" *.$(EXTN_HTML)	+ $(COMPOSER_LIBRARY_AUTO_UPDATE)
#> sitemap only	$(PUBLISH)-library-$(DOITALL)	+ $(COMPOSER_LIBRARY_AUTO_UPDATE)

.PHONY: $(PUBLISH)-library
$(PUBLISH)-library: .set_title-$(PUBLISH)-library
$(PUBLISH)-library:
ifeq ($(MAKELEVEL),0)
	@$(call $(HEADERS))
endif
ifneq ($(COMPOSER_LIBRARY),)
	@$(MAKE) \
		$(if $(COMPOSER_DOITALL_$(PUBLISH)-library),,COMPOSER_DOITALL_$(PUBLISH)-library="$(DOFORCE)") \
		c_site="1" \
		$(PUBLISH)-library-$(TARGETS)
else ifeq ($(filter $(DOITALL),$(COMPOSER_DOITALL_$(PUBLISH)-library)),)
	@$(MAKE) $(PUBLISH)-library-$(NOTHING)
endif
	@$(ECHO) ""

.PHONY: $(PUBLISH)-library-$(NOTHING)
$(PUBLISH)-library-$(NOTHING):
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_YML)$(_D) $(MARKER) $(_H)$(PUBLISH)-library.folder,$(NOTHING))

.PHONY: $(PUBLISH)-library-$(TARGETS)
$(PUBLISH)-library-$(TARGETS): $($(PUBLISH)-library)
$(PUBLISH)-library-$(TARGETS):
	@$(ECHO) ""

########################################
#### {{{4 $(PUBLISH)-library-$(@)
########################################

ifeq ($(filter $(DOITALL),$(COMPOSER_DOITALL_$(PUBLISH)-library)),)
$($(PUBLISH)-library): $($(PUBLISH)-library)-$(TARGETS)
endif
ifneq ($(or \
	$(filter $(DOFORCE),$(COMPOSER_DOITALL_$(PUBLISH)-library)) ,\
	$(and \
		$(filter $(DOITALL),$(COMPOSER_DOITALL_$(PUBLISH)-library)) ,\
		$(filter $(CURDIR),$(COMPOSER_LIBRARY_ROOT)) ,\
		$(COMPOSER_LIBRARY_AUTO_UPDATE) \
	) \
),)
$($(PUBLISH)-library): $($(PUBLISH)-library)-$(DOITALL)
endif
$($(PUBLISH)-library):
ifeq ($(filter $(DOITALL),$(COMPOSER_DOITALL_$(PUBLISH)-library)),)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$(@)
endif
	@$(ECHO) ""

$($(PUBLISH)-library)-$(TARGETS): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library)-$(TARGETS): $($(PUBLISH)-library-digest)
$($(PUBLISH)-library)-$(TARGETS):
	@$(MAKE) --directory $(COMPOSER_LIBRARY) c_site="1" $(DOITALL)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$(@)

$($(PUBLISH)-library)-$(DOITALL): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library)-$(DOITALL): $($(PUBLISH)-library-sitemap)
$($(PUBLISH)-library)-$(DOITALL):
	@$(MAKE) --directory $(COMPOSER_LIBRARY) c_site="1" $(DOITALL)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$(@)

$($(PUBLISH)-library-sitemap) \
$($(PUBLISH)-library-sitemap-src) \
	: \
	$($(PUBLISH)-library)-$(TARGETS)

########################################
#### {{{4 $(PUBLISH)-library-$(MAKEFILE)
########################################

#> update: COMPOSER_OPTIONS

$(COMPOSER_LIBRARY)/$(MAKEFILE): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH),,\
	$(COMPOSER_LIBRARY)/$(MAKEFILE) \
	$($(PUBLISH)-library-metadata) \
	$($(PUBLISH)-library-index) \
)
$(COMPOSER_LIBRARY)/$(MAKEFILE):
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_LIBRARY),$(PUBLISH)-library)
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_LIBRARY) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(foreach FILE,SETTINGS YML,\
		$(call $(HEADERS)-file,$(COMPOSER_LIBRARY),$(COMPOSER_$(FILE))); \
		$(call ENV_MAKE) --directory $(COMPOSER_LIBRARY_ROOT) c_site="1" $(PUBLISH)-$(COMPOSER_$(FILE)) \
			>$(COMPOSER_LIBRARY)/$(COMPOSER_$(FILE)); \
		$(call NEWLINE) \
	)
	@if	[ -z "$$($(call ENV_MAKE) --directory $(COMPOSER_LIBRARY_ROOT) c_site="1" $(CONFIGS)-COMPOSER_INCLUDE)" ] && \
		[ -f "$(COMPOSER_LIBRARY_ROOT)/$(COMPOSER_CSS_PUBLISH)" ]; \
	then \
		$(call $(HEADERS)-file,$(COMPOSER_LIBRARY),$(COMPOSER_CSS_PUBLISH)); \
		$(ECHO) "$(_E)"; \
		$(filter-out --relative,$(LN)) ../$(COMPOSER_CSS_PUBLISH) $(COMPOSER_LIBRARY)/$(COMPOSER_CSS_PUBLISH) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	elif [ -f "$(COMPOSER_LIBRARY)/$(COMPOSER_CSS_PUBLISH)" ]; then \
		$(call $(HEADERS)-rm,$(COMPOSER_LIBRARY),$(COMPOSER_CSS_PUBLISH)); \
		$(ECHO) "$(_S)"; \
		$(RM) $(COMPOSER_LIBRARY)/$(COMPOSER_CSS_PUBLISH) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi
	@$(call DO_HEREDOC,$(PUBLISH)-library-append-src) >$($(PUBLISH)-library-append)
	@$(call $(INSTALL)-$(MAKEFILE),$(COMPOSER_LIBRARY)/$(MAKEFILE),-$(INSTALL),,1)

.PHONY: $(PUBLISH)-$(COMPOSER_SETTINGS)
$(PUBLISH)-$(COMPOSER_SETTINGS):
	@$(foreach FILE,$(filter-out $(COMPOSER_OPTIONS_PUBLISH_ENV),$(COMPOSER_OPTIONS)),\
		$(if $(filter $(FILE)$(TOKEN)%,$(COMPOSER_OPTIONS_PUBLISH)),\
			$(ECHO) "override $(FILE) := $(word 2,$(subst $(TOKEN), ,$(filter $(FILE)$(TOKEN)%,$(COMPOSER_OPTIONS_PUBLISH))))\n"; ,\
			$(ECHO) "override $(FILE) := $(patsubst $(COMPOSER_ROOT)/%,\$$(COMPOSER_ROOT)/%,$($(FILE)))\n"; \
		) \
		$(call NEWLINE) \
	)
	@$(ECHO) "$(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$(notdir $($(PUBLISH)-library-digest))): $(notdir $($(PUBLISH)-library-digest-src))\n"
	@$(ECHO) "$(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$(notdir $($(PUBLISH)-library-sitemap))): $(notdir $($(PUBLISH)-library-sitemap-src))\n"

.PHONY: $(PUBLISH)-$(COMPOSER_YML)
$(PUBLISH)-$(COMPOSER_YML):
	@$(call YQ_EVAL_DATA,$(COMPOSER_YML_DATA),$(COMPOSER_LIBRARY).yml) \
		| $(YQ_WRITE_FILE) " \
			.variables.$(PUBLISH)-library.folder = null \
			| .variables.$(PUBLISH)-library.auto_update = null \
			" 2>/dev/null

#> update: $(PUBLISH)-library-sort-yq
#>	sort_by(.path) \
#>	| sort_by(.title) \
#>	| (sort_by(.date) | reverse)
override define $(PUBLISH)-library-sort-yq =
	sort_by(.date, .title, .path) | reverse
endef

override define $(PUBLISH)-library-sort-sh =
	if [ "$(1)" = "date" ]; then \
		$(SORT) --reverse; \
	else \
		$(SORT); \
	fi
endef

########################################
#### {{{4 $(PUBLISH)-library-metadata
########################################

#> update: YQ_WRITE.*title

$($(PUBLISH)-library-metadata): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH),,\
	$($(PUBLISH)-library-metadata) \
	$($(PUBLISH)-library-index) \
)
$($(PUBLISH)-library-metadata):
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_LIBRARY),$(PUBLISH)-metadata)
	@$(ECHO) "{" >$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_N)"
	@$(ECHO) "\".$(COMPOSER_BASENAME)\": { \".updated\": \"$(DATESTAMP)\" },\n" \
		| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
#>	@$(call $(EXPORTS)-find,$(COMPOSER_LIBRARY_ROOT),,$(SPECIAL_VAL))
	@$(call $(EXPORTS)-find,$(COMPOSER_LIBRARY_ROOT)) \
			$$($(call $(EXPORTS)-libraries,$(COMPOSER_LIBRARY_ROOT),$(COMPOSER_LIBRARY))) \
			-o \\\( -type f -name \"*$(COMPOSER_EXT)\" $(if $(wildcard $(@)),-newer $(@)) -print \\\) \
		| while read -r FILE; do \
			$(call $(HEADERS)-note,$(@),$$( \
					$(ECHO) "$${FILE}" \
					| $(SED) "s|^$(COMPOSER_LIBRARY_ROOT_REGEX)[/]||g" \
				),$(PUBLISH)-metadata); \
			if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
				else				$(ECHO) "$(_N)"; \
				fi; \
			$(ECHO) "\"$${FILE}\": " \
				| $(SED) "s|^([\"])$(COMPOSER_LIBRARY_ROOT_REGEX)[/]|\1|g" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output); \
			if [ -n "$$( \
				$(YQ_READ) $${FILE} 2>/dev/null \
					| $(YQ_WRITE) ".title" 2>/dev/null \
					| $(SED) "/^null$$/d" \
			)" ] || [ -n "$$( \
				$(YQ_READ) $${FILE} 2>/dev/null \
					| $(YQ_WRITE) ".pagetitle" 2>/dev/null \
					| $(SED) "/^null$$/d" \
			)" ]; then \
				$(YQ_READ) $${FILE} 2>/dev/null \
					| $(YQ_WRITE) ". += { \".$(COMPOSER_BASENAME)\": true }" 2>/dev/null; \
			else \
				$(ECHO) "{ \".$(COMPOSER_BASENAME)\": null }"; \
			fi \
				| $(YQ_WRITE) ". += { \"path\": \"$$( \
						$(ECHO) "$${FILE}" \
						| $(SED) "s|^$(COMPOSER_LIBRARY_ROOT_REGEX)[/]||g" \
					)\" }" 2>/dev/null \
				| $(YQ_WRITE) ". += { \".updated\": \"$(DATESTAMP)\" }" 2>/dev/null \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output); \
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
	@$(YQ_EVAL_FILES) \
			$(@).$(PRINTER) \
			$(@).$(COMPOSER_BASENAME) \
			2>/dev/null \
		| $(YQ_WRITE_FILE) "sort_keys(..)" 2>/dev/null \
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
#### {{{4 $(PUBLISH)-library-index
########################################

$($(PUBLISH)-library-index): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH),,\
	$($(PUBLISH)-library-index) \
)
$($(PUBLISH)-library-index):
#>		$(ECHO) "\n";
	@{	$(ECHO) "{"; \
		$(ECHO) "\".$(COMPOSER_BASENAME)\": {},\n"; \
		$(ECHO) '$(strip $(call COMPOSER_YML_DATA_METALIST_SKEL))'; \
		$(ECHO) "}"; \
	} >$(@).$(PRINTER)
	@$(ECHO) "{" >$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_N)"
	@$(ECHO) "\".$(COMPOSER_BASENAME)\": { \".updated\": \"$(DATESTAMP)\" },\n" \
		| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(foreach FILE,\
		title \
		date \
		$(COMPOSER_YML_DATA_METALIST) \
		,\
		$(call $(PUBLISH)-library-indexer,$(FILE)); \
		$(call NEWLINE) \
	)
	@$(ECHO) "}" >>$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_F)"
#>		| $(YQ_WRITE_FILE) "sort_keys(..)" 2>/dev/null
	@$(YQ_EVAL_FILES) \
			$(@).$(PRINTER) \
			$(@).$(COMPOSER_BASENAME) \
			2>/dev/null \
		| $(YQ_WRITE_FILE) 2>/dev/null \
		>$(@).$(PUBLISH); \
		if [ "$${PIPESTATUS[0]}" != "0" ]; then exit 1; fi
	@$(ECHO) "$(_D)"
	@if [ -s "$(@).$(PUBLISH)" ]; then \
		$(ECHO) "$(_S)"; \
		$(RM) $(@).$(PRINTER)		$($(DEBUGIT)-output); \
		$(RM) $(@).$(COMPOSER_BASENAME)	$($(DEBUGIT)-output); \
		$(MV) $(@).$(PUBLISH) $(@)	$($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	else \
		exit 1; \
	fi

########################################
##### {{{5 $(PUBLISH)-library-indexer
########################################

#> update: title / date / metalist:*

#>					elif [ "$(1)" = "date" ]; then		$(ECHO) "Date";
#>					else					$(ECHO) "Metalist ($(1))";
override define $(PUBLISH)-library-indexer =
	$(ECHO) "$(1): {\n" >>$(@).$(COMPOSER_BASENAME); \
	if [ "$(1)" = "title" ]; then \
		$(YQ_WRITE_FILE) ".[].[\".$(COMPOSER_BASENAME)\"]" $($(PUBLISH)-library-metadata) 2>/dev/null; \
	elif [ "$(1)" = "date" ]; then \
		$(YQ_WRITE_FILE) ".[].date" $($(PUBLISH)-library-metadata) 2>/dev/null \
		| $(SED) \
			-e "s|^([0-9]{4}).*$$|\1|g" \
			-e "s|^.*([0-9]{4})$$|\1|g"; \
	else \
		$(YQ_WRITE_FILE) ".[].$(1)" $($(PUBLISH)-library-metadata) 2>/dev/null \
		| $(SED) "s|^[-][ ]||g"; \
	fi \
		| $(call $(PUBLISH)-library-sort-sh,$(1)) \
		| while read -r FILE; do \
			$(call $(HEADERS)-note,$(@),$$( \
					if [ "$(1)" = "title" ]; then		$(ECHO) "Title"; \
					elif [ "$(1)" = "date" ]; then		$(ECHO) "Year"; \
					else					$(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.metalist.[\"$(1)\"].title)"; \
					fi \
				): $${FILE},$(PUBLISH)-index); \
			if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
				else				$(ECHO) "$(_N)"; \
				fi; \
			$(ECHO) "\"$${FILE}\": [\n" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output); \
			if [ "$(1)" = "title" ]; then \
				if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.\".$(COMPOSER_BASENAME)\" == null))"		$($(PUBLISH)-library-metadata) 2>/dev/null; \
					else				$(YQ_WRITE) "map(select(.\".$(COMPOSER_BASENAME)\" == $${FILE}))"	$($(PUBLISH)-library-metadata) 2>/dev/null; \
					fi; \
			elif [ "$(1)" = "date" ]; then \
				if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.date == null))"					$($(PUBLISH)-library-metadata) 2>/dev/null; \
					else				$(YQ_WRITE) "map(select(.date == \"$${FILE}*\" or .date == \"*$${FILE}\"))"	$($(PUBLISH)-library-metadata) 2>/dev/null; \
					fi; \
			else \
				if [ "$${FILE}" = "null" ]; then	$(YQ_WRITE) "map(select(.\"$(1)\" == null))"								$($(PUBLISH)-library-metadata) 2>/dev/null; \
					else				$(YQ_WRITE) "map(select((.\"$(1)\" == \"$${FILE}\") or (.\"$(1)\" | .[] | contains(\"$${FILE}\"))))"	$($(PUBLISH)-library-metadata) 2>/dev/null; \
					fi; \
			fi \
				| $(YQ_WRITE) "$(call $(PUBLISH)-library-sort-yq) | .[].path" 2>/dev/null \
				| $(SED) "/^null$$/d" \
				| $(SED) "s|$$|,|g" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output); \
			$(ECHO) "],\n" \
				| $(TEE) --append $(@).$(COMPOSER_BASENAME) $($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
		done; \
	$(ECHO) "$(_E)"; \
	$(ECHO) "},\n" >>$(@).$(COMPOSER_BASENAME); \
	$(ECHO) "$(_D)"
endef

########################################
#### {{{4 $(PUBLISH)-library-digest
########################################

#>		title
#>			| $(SED) "/^null$$/d"
override define $(PUBLISH)-library-digest-list =
	for TYPE in \
		date \
		$(COMPOSER_YML_DATA_METALIST) \
	; do \
		$(YQ_WRITE) ".$${TYPE} | keys | .[]" $($(PUBLISH)-library-index) 2>/dev/null \
			| $(SED) "/^null$$/d" \
			| while read -r FILE; do \
				OUTFILE="$(COMPOSER_LIBRARY)/$${TYPE}-$$( \
						$(call $(HELPOUT)-$(HELPOUT)-$(TARGETS)-FORMAT,$${FILE}) \
					)$(COMPOSER_EXT_DEFAULT)"; \
				if [ -n "$(1)" ]; then \
					if [ "$(1)" = "$${OUTFILE}.$(COMPOSER_BASENAME)" ]; then \
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

.PHONY: $(PUBLISH)-library-digest-files
$(PUBLISH)-library-digest-files: $($(PUBLISH)-library-digest-files)
$(PUBLISH)-library-digest-files:
	@$(ECHO) ""

########################################
##### {{{5 $(PUBLISH)-library-digest-file
########################################

$($(PUBLISH)-library-digest): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library-digest): $($(PUBLISH)-library-digest-src)
$($(PUBLISH)-library-digest): $($(PUBLISH)-library-digest-files)
$($(PUBLISH)-library-digest):
	@$(MAKE) c_site="1" $(PUBLISH)-library-digest-files
	@{	$(ECHO) "---\n"; \
		$(ECHO) "pagetitle: $(call COMPOSER_YML_DATA_VAL,library.digest_title)\n"; \
		$(ECHO) "date: $(DATEMARK)\n"; \
		$(ECHO) "---\n"; \
		$(ECHO) "$(PUBLISH_CMD_BEG) $(notdir $($(PUBLISH)-library-digest-src)) $(PUBLISH_CMD_END)\n"; \
	} >$(@)

########################################
##### {{{5 $(PUBLISH)-library-digest-src
########################################

$($(PUBLISH)-library-digest-src): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library-digest-src):
	@$(ECHO) "" >$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(PUBLISH_CMD_BEG) fold-begin group library-digest $(PUBLISH_CMD_END)\n" >>$(@).$(COMPOSER_BASENAME)
	@shopt -s lastpipe; \
		NUM="0"; \
		$(call $(PUBLISH)-library-digest-vars,digest); \
	$(YQ_WRITE) " \
			map(select(.title != null or .pagetitle != null)) \
			| $(call $(PUBLISH)-library-sort-yq) \
			| .[].path \
		" $($(PUBLISH)-library-metadata) 2>/dev/null \
		| $(HEAD) -n$${DIGEST_COUNT} \
	| while read -r FILE; do \
		$(call $(PUBLISH)-library-digest-create,$(@).$(COMPOSER_BASENAME)); \
		NUM="$$($(EXPR) $${NUM} + 1)"; \
	done
	@$(ECHO) "$(PUBLISH_CMD_BEG) fold-end group $(PUBLISH_CMD_END)\n" >>$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_S)"
	@$(MV) $(@).$(COMPOSER_BASENAME) $(@) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

########################################
##### {{{5 $(PUBLISH)-library-digest-files
########################################

#> update: title / date / metalist:*

#>					elif [ "$(TYPE)" = "date" ]; then	$(ECHO) "Date";
#>					else					$(ECHO) "Metalist ($(TYPE))";
$($(PUBLISH)-library-digest-files): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library-digest-files):
	@$(ECHO) "" >$(@).$(COMPOSER_BASENAME)
	@	$(eval override TYPE := $(shell $(call $(PUBLISH)-library-digest-list,$(@).$(COMPOSER_BASENAME)) | $(SED) "s|^(.+)$(TOKEN)(.+)$$|\1|g")) \
		$(eval override NAME := $(shell $(call $(PUBLISH)-library-digest-list,$(@).$(COMPOSER_BASENAME)) | $(SED) "s|^(.+)$(TOKEN)(.+)$$|\2|g")) \
		{	$(ECHO) "---\n"; \
			$(ECHO) "pagetitle: \"$$( \
					if [ "$(TYPE)" = "title" ]; then	$(ECHO) "Title"; \
					elif [ "$(TYPE)" = "date" ]; then	$(ECHO) "Year"; \
					else					$(ECHO) "$(call COMPOSER_YML_DATA_VAL,config.metalist.[\"$(TYPE)\"].title)"; \
					fi \
				): $(NAME)\"\n"; \
			$(ECHO) "date: $(DATEMARK)\n"; \
			$(ECHO) "---\n"; \
		} >>$(@).$(COMPOSER_BASENAME); \
	$(ECHO) "$(PUBLISH_CMD_BEG) fold-begin group library-digest $(PUBLISH_CMD_END)\n" >>$(@).$(COMPOSER_BASENAME); \
	shopt -s lastpipe; \
		NUM="0"; \
		$(call $(PUBLISH)-library-digest-vars,lists); \
	$(YQ_WRITE) ".[\"$(TYPE)\"].[\"$(NAME)\"] | .[]" $($(PUBLISH)-library-index) 2>/dev/null \
	| while read -r FILE; do \
		$(call $(PUBLISH)-library-digest-create,$(@).$(COMPOSER_BASENAME)); \
		NUM="$$($(EXPR) $${NUM} + 1)"; \
	done
	@$(ECHO) "$(PUBLISH_CMD_BEG) fold-end group $(PUBLISH_CMD_END)\n" >>$(@).$(COMPOSER_BASENAME)
	@$(ECHO) "$(_S)"
	@$(MV) $(@).$(COMPOSER_BASENAME) $(@) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

########################################
##### {{{5 $(PUBLISH)-library-digest-create
########################################

override define $(PUBLISH)-library-digest-vars =
	DIGEST_APPEND="$$( \
		$(ECHO) "$(call COMPOSER_YML_DATA_VAL,library.append)" \
		| $(SED) "s|$(PUBLISH_CMD_ROOT)|$(COMPOSER_ROOT)|g" \
	)"; \
	DIGEST_CONTINUE="$(call COMPOSER_YML_DATA_VAL,library.digest_continue)"; \
	DIGEST_PERMALINK="$(call COMPOSER_YML_DATA_VAL,library.digest_permalink)"; \
	DIGEST_CHARS="$(call COMPOSER_YML_DATA_VAL,library.digest_chars)"; \
	DIGEST_COUNT="$(call COMPOSER_YML_DATA_VAL,library.digest_count)"; \
	DIGEST_EXPANDED="$(call COMPOSER_YML_DATA_VAL,library.$(1)_expanded)"; \
	DIGEST_SPACER="$(call COMPOSER_YML_DATA_VAL,library.$(1)_spacer)"
endef

override define $(PUBLISH)-library-digest-create =
	$(call $(HEADERS)-note,$(patsubst %.$(COMPOSER_BASENAME),%,$(1)),$${FILE},$(PUBLISH)-digest); \
	if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
		else				$(ECHO) "$(_N)"; \
		fi; \
	if [ "$${NUM}" -gt "0" ] && [ -n "$${DIGEST_SPACER}" ]; then \
		$(ECHO) "$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	fi; \
	EXPAND="$(SPECIAL_VAL)"; \
	if [ -n "$${DIGEST_EXPANDED}" ]; then \
		if	[ "$${DIGEST_EXPANDED}" = "$(SPECIAL_VAL)" ] || \
			[ "$${NUM}" -lt "$${DIGEST_EXPANDED}" ]; \
		then \
			EXPAND="."; \
		fi; \
	fi; \
	$(ECHO) "$(PUBLISH_CMD_BEG) fold-begin 1 $${EXPAND} library-digest $$( \
			$(call PUBLISH_SH_RUN) metainfo-block $(SPECIAL_VAL) . $${FILE} \
		) $(PUBLISH_CMD_END)\n" \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	$(ECHO) "\n" \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	LEN="$$($(EXPR) $$( \
		$(CAT) \
			$(COMPOSER_LIBRARY_ROOT)/$${FILE} \
			$($(PUBLISH)-library-append) \
			$${DIGEST_APPEND} \
		| $(SED) "s|^$(PUBLISH_CMD_BEG) break $(PUBLISH_CMD_END)$$|$(COMPOSER_TINYNAME)$(DIVIDE)break|g" \
		| $(PANDOC_MD_TO_JSON) \
		| $(YQ_WRITE) ".blocks | length" 2>/dev/null \
	) - $$( \
		$(CAT) \
			$($(PUBLISH)-library-append) \
			$${DIGEST_APPEND} \
		| $(PANDOC_MD_TO_JSON) \
		| $(YQ_WRITE) ".blocks | length" 2>/dev/null \
	))" || $(TRUE); \
	SIZ="0"; BLK="0"; \
	while \
		[ "$${BLK}" -lt "$${LEN}" ] && \
		[ "$${SIZ}" -lt "$${DIGEST_CHARS}" ]; \
	do \
		TEXT="$$( \
			$(CAT) \
				$(COMPOSER_LIBRARY_ROOT)/$${FILE} \
				$($(PUBLISH)-library-append) \
				$${DIGEST_APPEND} \
			| $(SED) "s|^$(PUBLISH_CMD_BEG) break $(PUBLISH_CMD_END)$$|$(COMPOSER_TINYNAME)$(DIVIDE)break|g" \
			| $(SED) "s|$(PUBLISH_CMD_ROOT)|$(TOKEN)|g" \
			| $(PANDOC_MD_TO_JSON) \
			| $(YQ_WRITE) ".blocks |= pick([$${BLK}])" 2>/dev/null \
			| $(SED) "s|$(TOKEN)|$(PUBLISH_CMD_ROOT)|g" \
			| $(PANDOC_JSON_TO_LINT) \
		)"; \
		if [ "$${TEXT}" = "$(COMPOSER_TINYNAME)$(DIVIDE)break" ]; then \
			$(ECHO) "$(PUBLISH_CMD_BEG) break $(PUBLISH_CMD_END)\n" \
				| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
			$(ECHO) "\n" \
				| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
			break; \
		fi; \
		SIZ="$$( \
			$(EXPR) $${SIZ} + $$( \
				$(ECHO) "$${TEXT}\n" \
				| $(TEE) --append $(1) \
				| $(SED) "/^[[:space:]-]+$$/d" \
				| $(WC_CHAR) \
			) \
		)"; \
		$(ECHO) "\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		BLK="$$($(EXPR) $${BLK} + 1)"; \
	done; \
	if [ "$${BLK}" -lt "$${LEN}" ]; then \
		$(ECHO) "$${DIGEST_CONTINUE}" | $(SED) -e "s|^[\"]||g" -e "s|[\"]$$||g" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		$(ECHO) "\n\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	fi; \
	{	$(ECHO) "["; \
		$(ECHO) "$${DIGEST_PERMALINK}" | $(SED) -e "s|^[\"]||g" -e "s|[\"]$$||g"; \
		$(ECHO) "]("; \
		$(ECHO) "$(patsubst $(COMPOSER_ROOT)%,$(PUBLISH_CMD_ROOT)%,$(COMPOSER_LIBRARY_ROOT))/"; \
		$(ECHO) "$${FILE}" | $(SED) "s|$(subst .,[.],$(COMPOSER_EXT))$$|.$(EXTN_HTML)|g"; \
		$(ECHO) ")\n"; \
	} \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	$(ECHO) "\n" \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	$(ECHO) "$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)\n" \
		| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	$(ECHO) "$(_D)"
endef

########################################
#### {{{4 $(PUBLISH)-library-sitemap
########################################

$($(PUBLISH)-library-sitemap): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library-sitemap): $($(PUBLISH)-library-sitemap-src)
$($(PUBLISH)-library-sitemap):
	@$(call $(PUBLISH)-library-sitemap-file) >$(@)

override define $(PUBLISH)-library-sitemap-file =
	{	$(ECHO) "---\n"; \
		$(ECHO) "pagetitle: $(call COMPOSER_YML_DATA_VAL,library.sitemap_title)\n"; \
		$(ECHO) "date: $(DATEMARK)\n"; \
		$(ECHO) "---\n"; \
		$(ECHO) "$(PUBLISH_CMD_BEG) $(notdir $($(PUBLISH)-library-sitemap-src)) $(PUBLISH_CMD_END)\n"; \
	}
endef

########################################
##### {{{5 $(PUBLISH)-library-sitemap-src
########################################

override define $(PUBLISH)-library-sitemap-src-file =
	$(call $(PUBLISH)-library-sitemap-file) >$($(PUBLISH)-library-sitemap); \
	$(TOUCH) \
		$($(PUBLISH)-library-sitemap) \
		$(patsubst %$(COMPOSER_EXT_DEFAULT),%.$(EXTN_HTML),$($(PUBLISH)-library-sitemap))
endef

$($(PUBLISH)-library-sitemap-src): $(call $(COMPOSER_PANDOC)-dependencies,$(PUBLISH))
$($(PUBLISH)-library-sitemap-src):
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_LIBRARY),$(PUBLISH)-sitemap)
	@$(call $(PUBLISH)-library-sitemap-src-file)
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(PUBLISH)-library-sitemap-$(TARGETS)

#> $(PUBLISH)-library-sitemap-$(TARGETS) >> $(PUBLISH)-library-sitemap-$(PRINTER)
override $(PUBLISH)-library-sitemap-$(PRINTER) :=
ifneq ($(filter $(PUBLISH)-library-sitemap-$(TARGETS),$(MAKECMDGOALS)),)
override $(PUBLISH)-library-sitemap-$(PRINTER) := $(sort $(shell $(call $(EXPORTS)-tree,$(COMPOSER_LIBRARY_ROOT))))
endif

.PHONY: $(PUBLISH)-library-sitemap-$(TARGETS)
$(PUBLISH)-library-sitemap-$(TARGETS):
	@$(eval override $(@) := $($(PUBLISH)-library-sitemap-src))
	@$(ECHO) "" >$($(@)).$(COMPOSER_BASENAME)
	@$(eval override NUM := 0) \
		$(call $(PUBLISH)-library-sitemap-vars) \
		$(foreach FILE,$($(PUBLISH)-library-sitemap-$(PRINTER)),\
			$(call $(PUBLISH)-library-sitemap-create,$($(@)).$(COMPOSER_BASENAME)); \
			$(call NEWLINE) \
			$(eval override NUM := $(shell $(EXPR) $(NUM) + 1)) \
		)
	@$(ECHO) "" >$($(@)).$(PUBLISH)
	@$(ECHO) "$(PUBLISH_CMD_BEG) fold-begin group sitemap-list $(PUBLISH_CMD_END)\n" >>$($(@)).$(PUBLISH)
	@$(call $(PUBLISH)-library-sitemap-done,$($(@)).$(COMPOSER_BASENAME),$($(@)).$(PUBLISH))
	@$(ECHO) "$(PUBLISH_CMD_BEG) fold-end group $(PUBLISH_CMD_END)\n" >>$($(@)).$(PUBLISH)
	@$(ECHO) "$(_S)"
	@$(RM) $($(@)).$(COMPOSER_BASENAME)	$($(DEBUGIT)-output)
	@$(MV) $($(@)).$(PUBLISH) $($(@))	$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

########################################
##### {{{5 $(PUBLISH)-library-sitemap-create
########################################

override define $(PUBLISH)-library-sitemap-vars =
	$(eval override METAINFO_NULL := $(call COMPOSER_YML_DATA_VAL,config.metainfo_null)) \
	$(eval override SITEMAP_EXPANDED := $(call COMPOSER_YML_DATA_VAL,library.sitemap_expanded)) \
	$(eval override SITEMAP_SPACER := $(call COMPOSER_YML_DATA_VAL,library.sitemap_spacer))
endef

override define $(PUBLISH)-library-sitemap-done =
	$(filter-out --strip-comments,$(PANDOC_MD_TO_HTML)) $(1) >>$(2); \
	$(SED) -i "    N; s|^([<]table[[:space:]]+class[=].+)\n[<]table[>]$$|\1|g" $(2); \
	$(SED) -i "1n; N; s|^([<]table[[:space:]]+class[=].+)\n[<]table[>]$$|\1|g" $(2); \
	$(SED) -i "    N; s|^([<]table[[:space:]]+class[=].+)\n[<]table[>]$$|\1|g" $(2); \
	$(SED) -i "1n; N; s|^([<]table[[:space:]]+class[=].+)\n[<]table[>]$$|\1|g" $(2)
endef

#> update: TYPE_TARGETS
override define $(PUBLISH)-library-sitemap-create =
	$(call $(HEADERS)-note,$(patsubst %.$(COMPOSER_BASENAME),%,$(1)),$(patsubst $(COMPOSER_ROOT),/,$(patsubst $(COMPOSER_ROOT)/%,%,$(FILE))),$(PUBLISH)-sitemap); \
	if [ -n "$(COMPOSER_DEBUGIT)" ]; then	$(ECHO) "$(_E)"; \
		else				$(ECHO) "$(_N)"; \
		fi; \
	if [ "$(NUM)" -gt "0" ] && [ -n "$(SITEMAP_SPACER)" ]; then \
		$(ECHO) "$(PUBLISH_CMD_BEG) spacer $(PUBLISH_CMD_END)\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	fi; \
	EXPAND="$(SPECIAL_VAL)"; \
	if [ -n "$(SITEMAP_EXPANDED)" ]; then \
		if	[ "$(SITEMAP_EXPANDED)" = "$(SPECIAL_VAL)" ] || \
			[ "$(NUM)" -lt "$(SITEMAP_EXPANDED)" ]; \
		then \
			EXPAND="."; \
		fi; \
	fi; \
	shopt -s lastpipe; \
		PRINT=; \
	eval $(FIND) $(FILE) $$($(call $(EXPORTS)-filter,,$($(PUBLISH)-library-sitemap-$(PRINTER)),$(FILE))) \
		| $(SORT) \
	| while read -r FILE; do \
		if [ -z "$${PRINT}" ]; then \
			PRINT="$(SPECIAL_VAL)"; \
			$(ECHO) "$(PUBLISH_CMD_BEG) fold-begin 1 $${EXPAND} sitemap-list $$( \
					$(ECHO) "$(FILE)" \
					| $(SED) \
						-e "s|^$(COMPOSER_ROOT_REGEX)[/]||g" \
						-e "s|^$(COMPOSER_ROOT_REGEX)|/|g" \
				) $(PUBLISH_CMD_END)\n" \
				| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
			$(ECHO) "\n<table class=\"$(COMPOSER_TINYNAME)-table table table-borderless align-top\">\n" \
				| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
			$(ECHO) "\n|||\n|:---|:---|\n" \
				| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		fi; \
		INFO=; \
		$(foreach TYPE,$(TYPE_TARGETS_LIST),\
			if	[ "$${FILE/%\.$(EXTN_$(TYPE))/$(COMPOSER_EXT)}" != "$${FILE}" ] && \
				[ -f "$${FILE/%\.$(EXTN_$(TYPE))/$(COMPOSER_EXT)}" ]; \
			then \
				INFO="$${FILE/%\.$(EXTN_$(TYPE))/$(COMPOSER_EXT)}"; \
			fi; \
		) \
		if [ -f "$${INFO}" ]; then \
			INFO="$$($(call PUBLISH_SH_RUN) metainfo-block . . $${INFO})"; \
			if [ -n "$${INFO}" ]; then \
				$(ECHO) "$${INFO}"; \
			else \
				$(ECHO) "$(METAINFO_NULL)" | $(SED) -e "s|^[\"]||g" -e "s|[\"]$$||g"; \
			fi; \
		elif [ -L "$${FILE}" ]; then \
			INFO="$$($(word 1,$(REALPATH)) $${FILE})"; \
			$(ECHO) "["; \
			$(ECHO) "$${INFO}" | $(SED) "s|^$(COMPOSER_LIBRARY_ROOT_REGEX)[/]||g"; \
			$(ECHO) "]("; \
			$(ECHO) "$${INFO}" | $(SED) "s|^$(COMPOSER_ROOT_REGEX)|$(PUBLISH_CMD_ROOT)|g"; \
			$(ECHO) ")"; \
		else \
			$(ECHO) "--"; \
		fi \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		{	$(ECHO) "| ["; \
			$(ECHO) "$${FILE}" | $(SED) "s|^.*[/]([^/]+)$$|\1|g"; \
			$(ECHO) "]("; \
			$(ECHO) "$${FILE}" | $(SED) "s|^$(COMPOSER_ROOT_REGEX)|$(PUBLISH_CMD_ROOT)|g"; \
			$(ECHO) ") | "; \
		} \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		$(ECHO) "\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	done; \
	if [ -n "$${PRINT}" ]; then \
		$(ECHO) "\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
		$(ECHO) "$(PUBLISH_CMD_BEG) fold-end $(PUBLISH_CMD_END)\n" \
			| $(TEE) --append $(1) $($(PUBLISH)-$(DEBUGIT)-output); \
	fi; \
	$(ECHO) "$(_D)"
endef

########################################
### {{{3 $(PUBLISH)-$(PRINTER)
########################################

.PHONY: $(PUBLISH)-$(PRINTER)-%
$(PUBLISH)-$(PRINTER)-%:
	@$(MAKE) COMPOSER_DOITALL_$(PUBLISH)-$(PRINTER)="$(*)" $(PUBLISH)-$(PRINTER)

.PHONY: $(PUBLISH)-$(PRINTER)
$(PUBLISH)-$(PRINTER): .set_title-$(PUBLISH)-$(PRINTER)
$(PUBLISH)-$(PRINTER): override METACDIR := $(patsubst $(COMPOSER_LIBRARY_ROOT),,$(patsubst $(COMPOSER_LIBRARY_ROOT)/%,%/,$(CURDIR)))
$(PUBLISH)-$(PRINTER): override METAFILE := $(filter-out $(patsubst .%,%,$(NOTHING)) $(DOITALL) $(PRINTER),$(COMPOSER_DOITALL_$(PUBLISH)-$(PRINTER)))
$(PUBLISH)-$(PRINTER): override METACRGX = $(shell $(ECHO) "$(METACDIR)" | $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g")
$(PUBLISH)-$(PRINTER): override METAFRGX = $(shell $(ECHO) "$(METAFILE)" | $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g")
$(PUBLISH)-$(PRINTER): override METATEST = $(if $(METAFILE),(test(\"^$(METAFRGX)$$\") or test(\"[/]$(METAFRGX)$$\")),test(\"^$(METACRGX)\"))
$(PUBLISH)-$(PRINTER):
	@$(call $(HEADERS))
ifeq ($(COMPOSER_LIBRARY),)
	@$(MAKE) $(PUBLISH)-library-$(NOTHING)
else ifeq ($(and \
	$(wildcard $($(PUBLISH)-library-metadata)) ,\
	$(wildcard $($(PUBLISH)-library-index)) \
),)
	@$(if $(wildcard $($(PUBLISH)-library-metadata)),,	$(call $(HEADERS)-note,$(CURDIR),$(_H)$($(PUBLISH)-library-metadata),$(NOTHING)))
	@$(if $(wildcard $($(PUBLISH)-library-index)),,		$(call $(HEADERS)-note,$(CURDIR),$(_H)$($(PUBLISH)-library-index),$(NOTHING)))
else ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(PRINTER)),$(patsubst .%,%,$(NOTHING)))
#>		" $($(PUBLISH)-library-index) 2>/dev/null
	@$(YQ_WRITE_OUT) " \
			del(.\".$(COMPOSER_BASENAME)\") \
			| .[].[] |= with_entries(select(.value | $(METATEST))) \
			| .[].[] |= del(select(length == 0)) \
			| .[].[] |= [ (to_entries | .[].value) ] \
			| .[].[] |= sort_by(.) \
			| .[] |= .null \
		" $($(PUBLISH)-library-index) \
			$(YQ_WRITE_OUT_COLOR)
else ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(PRINTER)),)
#>		" $($(PUBLISH)-library-index) 2>/dev/null
	@$(YQ_WRITE_OUT) " \
			del(.\".$(COMPOSER_BASENAME)\") \
			| .[].[] |= with_entries(select(.value | $(METATEST))) \
			| .[].[] |= del(select(length == 0)) \
			| .[] |= [ (to_entries | .[].key) ] \
		" $($(PUBLISH)-library-index) \
			$(YQ_WRITE_OUT_COLOR)
ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(PRINTER)),$(PRINTER))
	@$(LINERULE)
	@$(PRINT) "$(_M)$(MARKER) $(call $(HEADERS)-path-root,$($(PUBLISH)-library-metadata))"
	@$(LINERULE)
#>		" $($(PUBLISH)-library-metadata) 2>/dev/null
	@$(YQ_WRITE_OUT) " \
			del(.\".$(COMPOSER_BASENAME)\") \
			| with_entries(select(.key | $(METATEST))) \
		" $($(PUBLISH)-library-metadata) \
			$(YQ_WRITE_OUT_COLOR)
	@$(LINERULE)
	@$(PRINT) "$(_M)$(MARKER) $(call $(HEADERS)-path-root,$($(PUBLISH)-library-index))"
	@$(LINERULE)
#>		" $($(PUBLISH)-library-index) 2>/dev/null
	@$(YQ_WRITE_OUT) " \
			del(.\".$(COMPOSER_BASENAME)\") \
			| .[].[] |= with_entries(select(.value | $(METATEST))) \
			| .[].[] |= del(select(length == 0)) \
			| .[].[] |= [ (to_entries | .[].value) ] \
			| .[].[] |= sort_by(.) \
		" $($(PUBLISH)-library-index) \
			$(YQ_WRITE_OUT_COLOR)
	@$(LINERULE)
	@$(PRINT) "$(_M)$(MARKER) COMPOSER_IGNORES"
	@$(LINERULE)
	@$(ECHO) "$(_N)"
	@$(call $(EXPORTS)-find,$(CURDIR),\
			-type f -name \"*$(COMPOSER_EXT)\" \
		) \
		$(if $(METAFILE),| $(SED) -n -e "/^$(METAFRGX)$$/p" -e "/[/]$(METAFRGX)$$/p") \
		| $(SED) "s|^$(CURDIR)[/]||g" \
		| $(SORT)
	@$(ECHO) "$(_D)"
endif
else
#>		" $($(PUBLISH)-library-index) 2>/dev/null
	@$(YQ_WRITE_OUT) " \
			del(.\".$(COMPOSER_BASENAME)\") \
			| .[].[] |= with_entries(select(.value | test(\"^$(METACRGX)[^/]+$$\"))) \
			| .[].[] |= del(select(length == 0)) \
			| .[] |= [ (to_entries | .[].key) ] \
		" $($(PUBLISH)-library-index) \
			$(YQ_WRITE_OUT_COLOR)
#>			" $($(PUBLISH)-library-metadata) 2>/dev/null;
#>			" $($(PUBLISH)-library-index) 2>/dev/null;
	@$(foreach FILE,$(filter-out $(subst *,%,$(COMPOSER_IGNORES)),$(COMPOSER_CONTENTS_EXT)),\
		$(LINERULE); \
		$(ECHO) "$(_M)$(MARKER) "; \
		$(LS) --color=none $(FILE); \
		$(ECHO) "$(_D)"; \
		$(ECHO) "$(_E)$(DIVIDE) $(call $(HEADERS)-path-root,$($(PUBLISH)-library-metadata))$(_D)\n"; \
		$(YQ_WRITE_OUT) " \
				del(.\".$(COMPOSER_BASENAME)\") \
				| .\"$(METACDIR)$(FILE)\" \
				| del(.\"path\") \
			" $($(PUBLISH)-library-metadata) \
				$(YQ_WRITE_OUT_COLOR); \
		$(ECHO) "$(_E)$(DIVIDE) $(call $(HEADERS)-path-root,$($(PUBLISH)-library-index))$(_D)\n"; \
		$(YQ_WRITE_OUT) " \
				del(.\".$(COMPOSER_BASENAME)\") \
				| .[].[] |= with_entries(select(.value | test(\"^$(METACRGX)$$( \
						$(ECHO) "$(FILE)" \
						| $(SED) "s|([$(SED_ESCAPE_LIST)])|[\1]|g" \
					)$$\"))) \
				| .[].[] |= del(select(length == 0)) \
				| .[] |= [ (to_entries | .[].key) ] \
				| .title |= (to_entries | .[0].value) \
			" $($(PUBLISH)-library-index) \
				$(YQ_WRITE_OUT_COLOR); \
		$(call NEWLINE) \
	)
	@$(if $(filter $(subst *,%,$(COMPOSER_IGNORES)),$(COMPOSER_CONTENTS_EXT)),$(LINERULE))
	@$(foreach FILE,$(filter $(subst *,%,$(COMPOSER_IGNORES)),$(COMPOSER_CONTENTS_EXT)),\
		$(PRINT) "$(_N)$(FILE)"; \
		$(call NEWLINE) \
	)
endif

########################################
### {{{3 $(PUBLISH)-$(EXAMPLE)
########################################

#WORKING:NOW once finalizing #WORK markers gets to here, do a final double-check of this list...

#> [ ! -f .$(PUBLISH)-$(INSTALL) ] && .$(PUBLISH)-$(INSTALL)
#>	[ -n $(COMPOSER_DEBUGIT) ] || --filter="-_/test/**"
#> $(PUBLISH)-$(EXAMPLE)-$(TESTING) == COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)
#>	[ $(MAKEJOBS) = $(MAKEJOBS_DEFAULT) ] && MAKEJOBS="$(TESTING_MAKEJOBS)"
#>	$(CONFIGS)
#>		$(COMPOSER_SETTINGS)
#>			$(*_MOD)
#>			$(word 3,$(PUBLISH_DIRS)) == COMPOSER_INCLUDE=""
#>			COMPOSER_DEPENDS="1"
#>		$(COMPOSER_YML)
#>			auto_update: $(LIBRARY_AUTO_UPDATE_ALT)
#>			$(PUBLISH)-info-top: ICON
#>		$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_CSS_PUBLISH)
#>		$(call DO_HEREDOC,PUBLISH_PAGE_EXAMPLE_DISPLAY)
#>	$(SHELL)
#>		$(PUBLISH_PAGEDIR)$(COMPOSER_EXT_DEFAULT)
#>		$(dir $(PUBLISH_EXAMPLE))/$(patsubst .%,%,$(NOTHING)).*
#>		$(PUBLISH)-$(DOFORCE) [x1]
#> $(PUBLISH)-$(EXAMPLE)-$(CONFIGS) == COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)
#>	$(SHELL)
#>		exit 0
#> $(COMPOSER_DEBUGIT)
#>	$(CONFIGS)
#>		$(COMPOSER_YML)
#>			auto_update: null
#>	$(SHELL)
#>		[ -n $(COMPOSER_RELEASE) ] && "#> update: HEREDOC_CUSTOM_PUBLISH"
#>		$(PUBLISH_DIRS_DEBUGIT)

$(PUBLISH_ROOT)/.$(PUBLISH)-$(INSTALL):
ifneq ($(wildcard $(firstword $(RSYNC))),)
	@$(call $(HEADERS),,$(PUBLISH)-$(EXAMPLE))
	@$(ECHO) "$(_S)"
	@$(MKDIR)				$(PUBLISH_ROOT) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(MAKE) --directory			$(PUBLISH_ROOT) --makefile $(COMPOSER) $(DOSETUP)-$(DOFORCE)
	@$(ECHO) "$(_S)"
	@$(foreach FILE,$(PUBLISH_DIRS_CONFIGS),\
		$(MKDIR)			$(PUBLISH_ROOT)/$(FILE) $($(DEBUGIT)-output); \
		$(call NEWLINE) \
	)
	@$(ECHO) "$(_D)"
	@$(call $(PUBLISH)-$(EXAMPLE)-$(INSTALL),$(PUBLISH_ROOT),$(COMPOSER_DEBUGIT))
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR)) \
		--directory $(PUBLISH_ROOT) \
		--makefile $(PUBLISH_ROOT)/.$(COMPOSER_BASENAME)/$(notdir $(COMPOSER)) \
		$(INSTALL)-$(DOFORCE)
	@$(ECHO) "$(call COMPOSER_TIMESTAMP)\n" >$(@)
endif
	@$(ECHO) ""

#> update: $(PUBLISH)-$(EXAMPLE)-$(INSTALL)
override define $(PUBLISH)-$(EXAMPLE)-$(INSTALL) =
	$(MKDIR) $(1); \
	if [ -z "$(2)" ]; then \
		$(RM) --recursive		$(1)/$(notdir $(PANDOC_DIR))/test; \
	fi; \
	$(RSYNC) \
		--delete-excluded \
		--prune-empty-dirs \
		--filter="-_/.**" \
		--filter="-_/**/.**" \
		--filter="-_/$(MAKEFILE)" \
		--filter="P_/$(MAKEFILE)" \
		--filter="-_/**/$(MAKEFILE)" \
		--filter="P_/**/$(MAKEFILE)" \
		\
		--filter="+_/**/" \
		$(if $(2),,--filter="-_/test/**") \
		--filter="+_/**$(COMPOSER_EXT_DEFAULT)" \
		--filter="-_/**" \
		$(PANDOC_DIR)/			$(1)/$(notdir $(PANDOC_DIR)); \
	$(RSYNC) $(PANDOC_DIR)/MANUAL.txt	$(1)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_DEFAULT),$(word 4,$(PUBLISH_FILES))); \
	$(RSYNC) \
		--delete-excluded \
		--prune-empty-dirs \
		--filter="-_/.**" \
		--filter="-_/**/.**" \
		--filter="-_/$(MAKEFILE)" \
		--filter="P_/$(MAKEFILE)" \
		--filter="-_/**/$(MAKEFILE)" \
		--filter="P_/**/$(MAKEFILE)" \
		\
		--filter="+_/site" \
		--filter="+_/site/content" \
		--filter="-_/site/content/docs/*/about" \
		--filter="-_/site/content/docs/*/examples" \
		--filter="-_/site/*" \
		--filter="-_/*" \
		$(BOOTSTRAP_DIR)/		$(1)/$(notdir $(BOOTSTRAP_DIR)); \
	$(SED) -i "s|^[#]{1}||g"		$(1)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_DEFAULT),$(word 5,$(PUBLISH_FILES))) \
						$(1)/$(word 5,$(PUBLISH_DIRS))/*$(COMPOSER_EXT_DEFAULT)
endef

#> update: $(NOTHING)-%

.PHONY: $(PUBLISH)-$(EXAMPLE)
$(PUBLISH)-$(EXAMPLE): .set_title-$(PUBLISH)-$(EXAMPLE)
$(PUBLISH)-$(EXAMPLE): $(PUBLISH_ROOT)/.$(PUBLISH)-$(INSTALL)
$(PUBLISH)-$(EXAMPLE):
ifeq ($(wildcard $(firstword $(RSYNC))),)
	@$(call $(HEADERS))
	@$(MAKE) $(NOTHING)-rsync
else
	@$(call $(HEADERS))
	@$(foreach FILE,$(PUBLISH_DIRS_CONFIGS),\
		$(call $(HEADERS)-note,$(PUBLISH_ROOT),$(FILE),,$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))); \
	)
	@$(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT),COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)) \
		$($(PUBLISH)-$(EXAMPLE)-$(TARGETS))
endif

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) :=

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_SETTINGS)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_SETTINGS)

.PHONY: $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_SETTINGS)
$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_SETTINGS):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/$(COMPOSER_SETTINGS))
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH)			>$(PUBLISH_ROOT)/.$(COMPOSER_BASENAME)/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_EXAMPLE)		>$(PUBLISH_ROOT)/$(word 1,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_NOTHING)		>$(PUBLISH_ROOT)/$(word 2,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_CONFIGS)		>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_PANDOC_DIR)	>$(PUBLISH_ROOT)/$(word 4,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_BOOTSTRAP_DIR)	>$(PUBLISH_ROOT)/$(word 5,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_BOOTSTRAP_TREE)	>$(PUBLISH_ROOT)/$(PUBLISH_BOOTSTRAP_TREE)/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_PAGEDIR)		>$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)/$(COMPOSER_SETTINGS)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_MK_PUBLISH_SHOWDIR)		>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(COMPOSER_SETTINGS)
	@$(SED) -i "s|[[:space:]]*$$||g"				$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(COMPOSER_SETTINGS)
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(TESTING))
	@$(ECHO) "override COMPOSER_INCLUDE :=\n"			>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(foreach FILE,$(PUBLISH_DIRS_CONFIGS),\
		$(ECHO) "override COMPOSER_DEPENDS := 1\n"		>>$(PUBLISH_ROOT)/$(FILE)/$(COMPOSER_SETTINGS); \
	)
endif

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)

.PHONY: $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML)
$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_YML):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/$(COMPOSER_YML))
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML,1)			>$(PUBLISH_ROOT)/.$(COMPOSER_BASENAME)/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_LIBRARY,,$(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)$(COMPOSER_EXT_SPECIAL))) \
									>$(PUBLISH_ROOT)/$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY).yml
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_LIBRARY,,$(PUBLISH_CMD_ROOT)/$(patsubst ./%,%,$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)$(COMPOSER_EXT_SPECIAL))) \
									>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT).yml
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_EXAMPLE)	>$(PUBLISH_ROOT)/$(word 1,$(PUBLISH_DIRS))/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_NOTHING)	>$(PUBLISH_ROOT)/$(word 2,$(PUBLISH_DIRS))/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_CONFIGS)	>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_PANDOC_DIR)	>$(PUBLISH_ROOT)/$(word 4,$(PUBLISH_DIRS))/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_BOOTSTRAP_DIR)	>$(PUBLISH_ROOT)/$(word 5,$(PUBLISH_DIRS))/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_BOOTSTRAP_TREE)	>$(PUBLISH_ROOT)/$(PUBLISH_BOOTSTRAP_TREE)/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_PAGEDIR)	>$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)/$(COMPOSER_YML)
	@$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_SHOWDIR)	>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(COMPOSER_YML)
	@$(SED) -i "s|[[:space:]]*$$||g"				$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(COMPOSER_YML)
	@$(ECHO) "$(_E)"
	@$(LN)								$(PUBLISH_ROOT)/$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY).yml \
									$(PUBLISH_ROOT)/$(PUBLISH_INCLUDE).$(EXTN_HTML).yml \
									$($(DEBUGIT)-output)
	@$(LN)								$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT).yml \
									$(PUBLISH_ROOT)/$(PUBLISH_INCLUDE_ALT).$(EXTN_HTML).yml \
									$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_CSS_PUBLISH)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_CSS_PUBLISH)

.PHONY: $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_CSS_PUBLISH)
$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_CSS_PUBLISH):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/$(COMPOSER_CSS_PUBLISH))
	@$(ECHO) "$(_S)"
	@$(RM)						$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_CSS_PUBLISH) $($(DEBUGIT)-output)
	@$(RM)						$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)/$(COMPOSER_CSS_PUBLISH) $($(DEBUGIT)-output)
	@$(MKDIR)					$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT) $($(DEBUGIT)-output)
	@$(ECHO) "$(_E)"
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(TESTING))
	@$(LN) $(call CSS_THEME,$(PUBLISH),custom)	$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_CSS_PUBLISH) $($(DEBUGIT)-output)
else
	@$(LN) $(call CSS_THEME,$(PUBLISH),custom)	$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)/$(COMPOSER_CSS_PUBLISH) $($(DEBUGIT)-output)
endif
	@$(ECHO) "$(_D)"

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_EXT_DEFAULT)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_EXT_DEFAULT)

.PHONY: $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_EXT_DEFAULT)
$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_EXT_DEFAULT):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/*$(COMPOSER_EXT_DEFAULT))
	@$(call DO_HEREDOC,PUBLISH_PAGE_1)			>$(PUBLISH_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_DEFAULT),$(word 1,$(PUBLISH_FILES)))
	@$(call DO_HEREDOC,PUBLISH_PAGE_1_INCLUDE)		>$(PUBLISH_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_SPECIAL),$(word 1,$(PUBLISH_FILES)))
	@$(call DO_HEREDOC,PUBLISH_PAGE_1)			>$(PUBLISH_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_DEFAULT),$(word 1,$(PUBLISH_FILES)))
	@$(call DO_HEREDOC,PUBLISH_PAGE_2)			>$(PUBLISH_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_DEFAULT),$(word 2,$(PUBLISH_FILES)))
	@$(call DO_HEREDOC,PUBLISH_PAGE_3)			>$(PUBLISH_ROOT)/$(patsubst %.$(EXTN_HTML),%$(COMPOSER_EXT_DEFAULT),$(word 3,$(PUBLISH_FILES)))
	@$(call DO_HEREDOC,PUBLISH_PAGE_3_HEADER)		>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_HEADER)
	@$(call DO_HEREDOC,PUBLISH_PAGE_3_FOOTER)		>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_FOOTER)
	@$(call DO_HEREDOC,PUBLISH_PAGE_3_APPEND)		>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(ECHO) "\n"						>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS,1)	>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(ECHO) "\n"						>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS_EXT,1)	>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(ECHO) "\n"						>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(call ENV_MAKE) $(HELPOUT)-$(HELPOUT)-$(TARGETS)	>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(SED) -i -e "/^[#][>]/d" -e "s|[[:space:]]+$$||g"	$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(SED) -i "/^[[][_]/d"					$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_FILE_APPEND)
	@$(call DO_HEREDOC,PUBLISH_PAGE_4_HEADER)		>$(PUBLISH_ROOT)/$(word 4,$(PUBLISH_DIRS))/$(PUBLISH_FILE_HEADER)
	@$(call DO_HEREDOC,PUBLISH_PAGE_5_HEADER)		>$(PUBLISH_ROOT)/$(word 5,$(PUBLISH_DIRS))/$(PUBLISH_FILE_HEADER)
	@$(call DO_HEREDOC,PUBLISH_PAGE_EXAMPLE)		>$(PUBLISH_ROOT)/$(PUBLISH_EXAMPLE)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,PUBLISH_PAGE_EXAMPLE_INCLUDE)	>$(PUBLISH_ROOT)/$(PUBLISH_EXAMPLE)$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,PUBLISH_PAGE_EXAMPLE_DISPLAY)	>$(PUBLISH_ROOT)/$(PUBLISH_EXAMPLE).yml
	@$(call DO_HEREDOC,PUBLISH_PAGE_PAGEDIR_HEADER)		>$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)-header$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,PUBLISH_PAGE_PAGEDIR_FOOTER)		>$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)-footer$(COMPOSER_EXT_SPECIAL)

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(PUBLISH_PAGEDIR)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_PAGEDIR))

.PHONY: $(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_PAGEDIR))
$(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_PAGEDIR)):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/$(PUBLISH_PAGEDIR))
	@$(ECHO) "ifneq (\$$(COMPOSER_CURDIR),)\n"					>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(ECHO) "override COMPOSER_TARGETS := .$(TARGETS)"				>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(TESTING))
	@$(ECHO) " $(notdir $(PUBLISH_PAGEDIR)).$(EXTN_HTML)"				>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
endif
	@$(ECHO) " $(notdir $(PUBLISH_PAGEDIR)).$(EXTN_LPDF)"				>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(ECHO) "\n"									>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
#>	@$(ECHO) 'override $(notdir $(PUBLISH_PAGEDIR)).$(EXTN_HTML) := \\\n'		>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(ECHO) 'override $(notdir $(PUBLISH_PAGEDIR)).* := \\\n'			>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(ECHO) '\t$(notdir $(PUBLISH_PAGEDIR))-header$(COMPOSER_EXT_SPECIAL) \\\n'	>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
#> update: $(PUBLISH)-library-sort-yq
#>	@$(foreach YEAR,202 203,
#>		$(eval override MARK := $(YEAR)$(NUM)-01-01)
#>		$(call DO_HEREDOC,PUBLISH_PAGE_TESTING,1,$(NUM) $(YEAR)$(NUM) $(MARK))
	@$(foreach YEAR,2022 2023 2024,\
		$(foreach NUM,0 1 2 3 4 5 6 7 8 9,\
		$(eval override MARK := $(YEAR)-01-01) \
		$(eval override FILE := $(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)/$(MARK)+$(EXAMPLE)_0$(NUM)$(COMPOSER_EXT_DEFAULT)) \
		$(call $(HEADERS)-file,$(abspath $(dir $(FILE))),$(notdir $(FILE))); \
		$(call DO_HEREDOC,PUBLISH_PAGE_TESTING,1,$(NUM) $(YEAR) $(MARK)) \
			| $(SED) \
				-e "s|$(SED_ESCAPE_CONTROL)||g" \
				-e "s|$(SED_ESCAPE_COLOR)||g" \
											>$(FILE); \
		$(ECHO) '\t$(notdir $(PUBLISH_PAGEDIR))/$(notdir $(FILE)) \\\n'		>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS); \
	))
	@$(ECHO) "\t$(notdir $(PUBLISH_PAGEDIR))-footer$(COMPOSER_EXT_SPECIAL)\n"	>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(ECHO) "endif\n"								>>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(COMPOSER_SETTINGS)
	@$(ECHO) "$(_E)"
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(TESTING))
	@$(RM)										$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)$(COMPOSER_EXT_DEFAULT) \
											$($(DEBUGIT)-output)
else
	@$(LN)										$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)-header$(COMPOSER_EXT_SPECIAL) \
											$(PUBLISH_ROOT)/$(PUBLISH_PAGEDIR)$(COMPOSER_EXT_DEFAULT) \
											$($(DEBUGIT)-output)
endif
	@$(ECHO) "$(_D)"

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(PUBLISH_SHOWDIR)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_SHOWDIR))

.PHONY: $(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_SHOWDIR))
$(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_SHOWDIR)):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/$(PUBLISH_SHOWDIR))
#> update: FILE.*CSS_THEMES
#>			$(filter-out --relative,$(LN))						$(call COMPOSER_CONV,,$(call CSS_THEME,$(FTYPE),$(THEME))) \
#>												$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(FTYPE).$(THEME)+$(OVRLY).$(FEXTN).css \
#>												$($(DEBUGIT)-output);
	@$(foreach FILE,$(call CSS_THEMES),\
		$(eval override FTYPE := $(word 1,$(subst ;, ,$(FILE)))) \
		$(eval override THEME := $(word 2,$(subst ;, ,$(FILE)))) \
		$(eval override SFILE := $(word 3,$(subst ;, ,$(FILE)))) \
		$(eval override OVRLY := $(word 4,$(subst ;, ,$(FILE)))) \
		$(eval override TITLE := $(word 5,$(subst ;, ,$(FILE)))) \
		$(eval override DEFLT := $(word 6,$(subst ;, ,$(FILE)))) \
		$(eval override FEXTN := $(if $(filter $(FTYPE),$(TYPE_PRES)),$(EXTN_PRES),$(EXTN_HTML))) \
		$(if $(filter-out $(TOKEN),$(OVRLY)),\
			$(call $(HEADERS)-file,$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR),$(FTYPE).$(THEME)$(_D) $(_C)($(OVRLY))); \
			$(ECHO) "$(_E)"; \
			$(call DO_HEREDOC,HEREDOC_COMPOSER_YML_PUBLISH_SHOWDIR,,$(OVRLY))	>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(COMPOSER_YML)-$(OVRLY); \
			$(LN)									$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(COMPOSER_YML)-$(OVRLY) \
												$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(FTYPE).$(THEME)+$(OVRLY).$(FEXTN).yml \
												$($(DEBUGIT)-output); \
			$(ECHO) "$(_D)"; \
			$(call NEWLINE) \
		) \
	)
	@$(call DO_HEREDOC,PUBLISH_PAGE_SHOWDIR)						>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,PUBLISH_PAGE_SHOWDIR_INCLUDE)					>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS,1)					>>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_SPECIAL)
	@$(ECHO) "\n"										>>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,$(HELPOUT)-$(DOITALL)-LINKS_EXT,1)					>>$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_SPECIAL)
	@$(SED) -i -e "s|[[:space:]]*$$||g" -e "s|\\t| |g"					$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX)$(COMPOSER_EXT_SPECIAL)
	@$(ECHO) "$(_E)"
	@if [ ! -e "$(patsubst $(COMPOSER_DIR)/%,$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/%,$(COMPOSER_ART))" ]; then \
		$(MKDIR)									$(abspath $(dir $(patsubst $(COMPOSER_DIR)/%,$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/%,$(COMPOSER_ART)))) \
												$($(DEBUGIT)-output); \
		$(LN)										$(COMPOSER_ART) \
												$(patsubst $(COMPOSER_DIR)/%,$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/%,$(COMPOSER_ART)) \
												$($(DEBUGIT)-output); \
	fi
	@$(filter-out --relative,$(LN))								$(call COMPOSER_CONV,,$(COMPOSER_ART))/$(OUT_README).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT) \
												$(PUBLISH_ROOT)/$(PUBLISH_SHOWDIR)/$(PUBLISH_INDEX).$(TYPE_PRES)$(COMPOSER_EXT_DEFAULT) \
												$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(PUBLISH_LIBRARY)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_LIBRARY))

.PHONY: $(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_LIBRARY))
$(PUBLISH)-$(EXAMPLE)-.$(notdir $(PUBLISH_LIBRARY)):
	@$(call $(HEADERS)-file,$(PUBLISH_ROOT),$(EXPAND)/$(PUBLISH_LIBRARY))
	@$(call DO_HEREDOC,PUBLISH_PAGE_LIBRARY)	>$(PUBLISH_ROOT)/$(word 1,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY)$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,PUBLISH_PAGE_LIBRARY_ALT)	>$(PUBLISH_ROOT)/$(word 3,$(PUBLISH_DIRS))/$(PUBLISH_LIBRARY_ALT)$(COMPOSER_EXT_SPECIAL)
	@$(call DO_HEREDOC,PUBLISH_PAGE_INCLUDE)	>$(PUBLISH_ROOT)/$(PUBLISH_INCLUDE)$(COMPOSER_EXT_DEFAULT)
	@$(call DO_HEREDOC,PUBLISH_PAGE_INCLUDE_ALT)	>$(PUBLISH_ROOT)/$(PUBLISH_INCLUDE_ALT)$(COMPOSER_EXT_DEFAULT)

########################################
#### {{{4 $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_BASENAME)
########################################

override $(PUBLISH)-$(EXAMPLE)-$(TARGETS) += $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_BASENAME)

.PHONY: $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_BASENAME)
$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_BASENAME): $(filter-out $(PUBLISH)-$(EXAMPLE)-$(COMPOSER_BASENAME),$($(PUBLISH)-$(EXAMPLE)-$(TARGETS)))
$(PUBLISH)-$(EXAMPLE)-$(COMPOSER_BASENAME):
ifneq ($(COMPOSER_RELEASE),)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-file,$(abspath $(dir $(CUSTOM_PUBLISH_SH))),$(notdir $(CUSTOM_PUBLISH_SH)),$(DEBUGIT))
#> update: HEREDOC_CUSTOM_PUBLISH
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_SH)			| $(SED) -e "s|[[:space:]]+$$||g" -e "/$(TOKEN)$$/d" >$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PUBLISH_SH))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS)			>$(call COMPOSER_CONV,$(CURDIR)/,$(CUSTOM_PUBLISH_CSS))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_OVERLAY,,light)	>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,light))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_OVERLAY,,dark)	>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,dark))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_THEME)		>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,custom))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_THEME)		| $(SED) "s|^(.*--$(COMPOSER_TINYNAME)-[^:]+[:][[:space:]]+).*(var[(]--solarized.+)$$|\1\2|g" \
									>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,custom-solar))
	@$(call DO_HEREDOC,HEREDOC_CUSTOM_PUBLISH_CSS_TESTING)		>$(call COMPOSER_CONV,$(CURDIR)/,$(call CUSTOM_PUBLISH_CSS_OVERLAY,$(TESTING)))
#> update: HEREDOC_CUSTOM_PUBLISH
endif
endif
ifneq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(CONFIGS))
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(TESTING))
	@$(ECHO) "$(_E)"
	@$(LN)	$(PUBLISH_ROOT)/$(PUBLISH_EXAMPLE)$(COMPOSER_EXT_DEFAULT) \
		$(abspath $(dir $(PUBLISH_ROOT)/$(PUBLISH_EXAMPLE)))/$(patsubst .%,%,$(NOTHING))$(COMPOSER_EXT_DEFAULT) \
		$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
ifneq ($(COMPOSER_DEBUGIT),)
	@$(foreach FILE,$(PUBLISH_DIRS_CONFIGS),\
		{	$(call TITLE_LN ,$(DEPTH_MAX),$(FILE)); \
			$(ECHO) "$(_M)"; $(CAT) $(PUBLISH_ROOT)/$(FILE)/$(COMPOSER_SETTINGS)		2>/dev/null || $(TRUE); \
			$(ECHO) "$(_C)"; $(CAT) $(PUBLISH_ROOT)/$(FILE)/$(COMPOSER_YML)			2>/dev/null || $(TRUE); \
			$(ECHO) "$(_E)"; $(CAT) $(PUBLISH_ROOT)/$(FILE)/$(PUBLISH_LIBRARY).yml		2>/dev/null || $(TRUE); \
			$(ECHO) "$(_E)"; $(CAT) $(PUBLISH_ROOT)/$(FILE)/$(PUBLISH_LIBRARY_ALT).yml	2>/dev/null || $(TRUE); \
			$(ECHO) "$(_D)"; \
		}; \
		$(call NEWLINE) \
	)
	@$(foreach FILE,$(PUBLISH_DIRS_DEBUGIT),\
		time $(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR),$(COMPOSER_DEBUGIT)) \
			--directory $(abspath $(dir $(PUBLISH_ROOT)/$(FILE))) \
			$(if $(filter %/$(DOITALL),$(FILE)),\
				$(DOITALL) ,\
				$(notdir $(FILE)) \
			); \
		$(call NEWLINE) \
	)
else
	@$(foreach FILE,\
		$(PUBLISH)-$(DOITALL) \
		$(PUBLISH)-$(DOFORCE) \
		$(if $(filter $(TESTING),$(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE))),,$(PUBLISH)-$(DOFORCE)) \
		,\
		time $(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR)) \
			--directory $(PUBLISH_ROOT) \
			$(FILE); \
		$(call NEWLINE) \
	)
	@time $(call ENV_MAKE,$(MAKEJOBS),$(COMPOSER_DOCOLOR)) \
		--directory $(PUBLISH_ROOT) \
		$(EXPORTS)
endif
ifeq ($(COMPOSER_DOITALL_$(PUBLISH)-$(EXAMPLE)),$(TESTING))
	@$(ECHO) "$(_S)"
	@$(RM)	$(abspath $(dir $(PUBLISH_ROOT)/$(PUBLISH_EXAMPLE)))/$(patsubst .%,%,$(NOTHING)).* \
		$($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
endif
	@$(ECHO) ""

########################################
## {{{2 $(INSTALL)
########################################

.PHONY: $(INSTALL)
$(INSTALL): .set_title-$(INSTALL)
$(INSTALL):
#>	@$(call $(HEADERS))
	@$(call $(HEADERS)-$(SUBDIRS))
ifneq ($(COMPOSER_RELEASE),)
	@$(call $(HEADERS)-note,$(CURDIR),$(_H)$(COMPOSER_BASENAME) Directory)
else
	@if	[ "$(MAKELEVEL)" = "0" ] || \
		[ "$(CURDIR)" = "$(COMPOSER_ROOT)" ] || \
		[ ! -f "$(CURDIR)/$(MAKEFILE)" ]; \
	then \
		if [ "$(CURDIR)" = "$(COMPOSER_ROOT)" ]; then \
			$(call $(HEADERS)-note,$(CURDIR),$(_H)Main $(MAKEFILE)); \
		fi; \
		$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$(MAKEFILE),-$(INSTALL),$(if $(filter $(CURDIR),$(COMPOSER_ROOT)),$(COMPOSER)),$(filter $(DOFORCE),$(COMPOSER_DOITALL_$(INSTALL)))); \
	fi
endif
ifneq ($(COMPOSER_DOITALL_$(INSTALL)),)
ifeq ($(COMPOSER_SUBDIRS),)
	@$(MAKE) $(NOTHING)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(SUBDIRS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_SUBDIRS)),)
	@$(MAKE) $(COMPOSER_SUBDIRS)
else
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(INSTALL)-$(TARGETS)
	@$(MAKE) $(SUBDIRS)-$(INSTALL)
endif
endif

.PHONY: $(INSTALL)-$(TARGETS)
$(INSTALL)-$(TARGETS): $(addprefix $(INSTALL)-,$(COMPOSER_SUBDIRS))
$(INSTALL)-$(TARGETS):
	@$(ECHO) ""

.PHONY: $(addprefix $(INSTALL)-,$(COMPOSER_SUBDIRS))
$(addprefix $(INSTALL)-,$(COMPOSER_SUBDIRS)):
	@$(eval override $(@) := $(patsubst $(INSTALL)-%,%,$(@)))
	@$(call $(INSTALL)-$(MAKEFILE),$(CURDIR)/$($(@))/$(MAKEFILE),-$(INSTALL),,$(filter $(DOFORCE),$(COMPOSER_DOITALL_$(INSTALL))))

override define $(INSTALL)-$(MAKEFILE) =
	if	[ -f "$(1)" ] && \
		[ -z "$(4)" ]; \
	then \
		$(call $(HEADERS)-skip,$(abspath $(dir $(1))),$(notdir $(1))); \
	else \
		$(call $(HEADERS)-file,$(abspath $(dir $(1))),$(notdir $(1))); \
		$(call ENV_MAKE) --directory $(abspath $(dir $(1))) --makefile $(COMPOSER) .$(EXAMPLE)$(2) >$(1); \
	fi; \
	if [ -n "$(3)" ]; then \
		$(SED) -i \
			"s|^($(call COMPOSER_REGEX_OVERRIDE,COMPOSER_TEACHER)).*$$|\1 \$$(abspath \$$(COMPOSER_MY_PATH)/`$(REALPATH) $(abspath $(dir $(1))) $(3)`)|g" \
			$(1); \
	fi
endef

########################################
## {{{2 $(CLEANER)
########################################

.PHONY: $(CLEANER)
$(CLEANER): .set_title-$(CLEANER)
$(CLEANER):
#>	@$(call $(HEADERS))
	@$(call $(HEADERS)-$(SUBDIRS))
	@$(call $(CLEANER)-$(CLEANER),$(SPECIAL_VAL))
#>ifneq ($(c_site),)
	@$(MAKE) c_site="1" $(PUBLISH)-$(CLEANER)
#>endif
ifeq ($(COMPOSER_TARGETS),)
	@$(MAKE) $(NOTHING)-$(TARGETS)
else ifeq ($(COMPOSER_TARGETS),$(NOTHING))
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(TARGETS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_TARGETS)),)
	@$(MAKE) $(COMPOSER_TARGETS)
else
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(CLEANER)-$(TARGETS)
endif
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(SUBDIRS)-$(TARGETS)-$(CLEANER)
ifneq ($(COMPOSER_DOITALL_$(CLEANER)),)
	@$(MAKE) $(SUBDIRS)-$(CLEANER)
endif

#> update: OUTPUT_FILENAME

.PHONY: $(CLEANER)-$(TARGETS)
$(CLEANER)-$(TARGETS): $(addprefix $(CLEANER)-,$(sort \
	$(COMPOSER_TARGETS) \
	$(wildcard $(COMPOSER_FILENAME).*) \
))
	@$(ECHO) ""

.PHONY: $(addprefix $(CLEANER)-,$(sort \
	$(COMPOSER_TARGETS) \
	$(wildcard $(COMPOSER_FILENAME).*) \
))
$(addprefix $(CLEANER)-,$(sort \
	$(COMPOSER_TARGETS) \
	$(wildcard $(COMPOSER_FILENAME).*) \
)):
	@$(eval override $(@) := $(patsubst $(CLEANER)-%,%,$(@)))
	@if	[ "$($(@))" != "$(NOTHING)" ] && \
		[ -f "$(CURDIR)/$($(@))" ]; \
	then \
		$(call $(HEADERS)-rm,$(CURDIR),$($(@))); \
		$(ECHO) "$(_S)"; \
		$(RM) $(CURDIR)/$($(@)) $($(DEBUGIT)-output); \
		$(ECHO) "$(_D)"; \
	fi

override define $(CLEANER)-$(CLEANER) =
	COMPOSER_KEEPING="$(if $(1),$(1),$(COMPOSER_KEEPING))"; \
	if	[ -n "$${COMPOSER_KEEPING}" ] && \
		[ -n "$(COMPOSER_LOG)" ] && \
		[ -f "$(CURDIR)/$(COMPOSER_LOG)" ]; \
	then \
		if [ "$${COMPOSER_KEEPING}" = "$(SPECIAL_VAL)" ]; then \
			$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_LOG),$(CLEANER)); \
			$(ECHO) "$(_S)"; \
			$(RM) $(CURDIR)/$(COMPOSER_LOG) $($(DEBUGIT)-output); \
		elif [ "$$($(CAT) $(CURDIR)/$(COMPOSER_LOG) | $(WC))" -gt "$${COMPOSER_KEEPING}" ]; then \
			$(call $(HEADERS)-note,$(CURDIR),$(COMPOSER_LOG),$(CLEANER)); \
			$(ECHO) "$(_S)"; \
			$(TAIL) -n$${COMPOSER_KEEPING} $(CURDIR)/$(COMPOSER_LOG) >$(CURDIR)/$(COMPOSER_LOG).$(@); \
			$(MV) $(CURDIR)/$(COMPOSER_LOG).$(@) $(CURDIR)/$(COMPOSER_LOG) $($(DEBUGIT)-output); \
		fi; \
		$(ECHO) "$(_D)"; \
	fi; \
	if	[ -n "$${COMPOSER_KEEPING}" ] && \
		[ -d "$(COMPOSER_TMP)" ]; \
	then \
		if [ "$${COMPOSER_KEEPING}" = "$(SPECIAL_VAL)" ]; then \
			$(call $(HEADERS)-note,$(CURDIR),$(notdir $(COMPOSER_TMP)),$(CLEANER)); \
			$(ECHO) "$(_S)"; \
			$(RM) --recursive $(COMPOSER_TMP) $($(DEBUGIT)-output); \
		elif [ "$$($(LS_TIME) $(COMPOSER_TMP)/{.[^.],}* 2>/dev/null | $(WC))" -gt "$${COMPOSER_KEEPING}" ]; then \
			$(call $(HEADERS)-note,$(CURDIR),$(notdir $(COMPOSER_TMP)),$(CLEANER)); \
			$(ECHO) "$(_S)"; \
			$(RM) --recursive $$( \
					$(LS_TIME) $(COMPOSER_TMP)/{.[^.],}* 2>/dev/null \
					| $(TAIL) -n+$$($(EXPR) $${COMPOSER_KEEPING} + 1) \
				) $($(DEBUGIT)-output); \
		fi; \
		$(ECHO) "$(_D)"; \
	fi
endef

########################################
## {{{2 $(DOITALL)
########################################

.PHONY: $(DOITALL)
$(DOITALL): .set_title-$(DOITALL)
$(DOITALL):
#>	@$(call $(HEADERS))
	@$(call $(HEADERS)-$(SUBDIRS))
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifneq ($(COMPOSER_DEPENDS),)
	@$(MAKE) $(SUBDIRS)-$(DOITALL)
endif
endif
ifeq ($(COMPOSER_TARGETS),)
	@$(MAKE) $(NOTHING)-$(TARGETS)
else ifeq ($(COMPOSER_TARGETS),$(NOTHING))
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(TARGETS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_TARGETS)),)
	@$(MAKE) $(COMPOSER_TARGETS)
else
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(DOITALL)-$(TARGETS)
endif
	@$(MAKE) $(call COMPOSER_OPTIONS_EXPORT) $(SUBDIRS)-$(TARGETS)-$(DOITALL)
	@$(call $(CLEANER)-$(CLEANER))
ifneq ($(COMPOSER_DOITALL_$(DOITALL)),)
ifeq ($(COMPOSER_DEPENDS),)
	@$(MAKE) $(SUBDIRS)-$(DOITALL)
endif
endif
#>ifneq ($(c_site),)
	@$(MAKE) c_site="1" $(PUBLISH)-library-$(DOITALL)
#>endif

.PHONY: $(DOITALL)-$(TARGETS)
$(DOITALL)-$(TARGETS): $(COMPOSER_TARGETS)
$(DOITALL)-$(TARGETS):
	@$(ECHO) ""

########################################
## {{{2 $(SUBDIRS)
########################################

.PHONY: $(SUBDIRS)
$(SUBDIRS): .set_title-$(SUBDIRS)
$(SUBDIRS):
	@$(MAKE) $(NOTHING)-$(NOTHING)-$(TARGETS)-$(SUBDIRS)

override define $(SUBDIRS)-$(EXAMPLE) =
.PHONY: $(SUBDIRS)-$(1)
ifeq ($(COMPOSER_SUBDIRS),)
$(SUBDIRS)-$(1): $(NOTHING)-$(SUBDIRS)
else ifeq ($(COMPOSER_SUBDIRS),$(NOTHING))
$(SUBDIRS)-$(1): $(NOTHING)-$(NOTHING)-$(SUBDIRS)
else ifeq ($(filter-out $(NOTHING)-%,$(COMPOSER_SUBDIRS)),)
$(SUBDIRS)-$(1): $(COMPOSER_SUBDIRS)
else
$(SUBDIRS)-$(1): $(addprefix $(SUBDIRS)-$(1)-,$(COMPOSER_SUBDIRS))
endif
$(SUBDIRS)-$(1):
	@$$(ECHO) ""

.PHONY: $(addprefix $(SUBDIRS)-$(1)-,$(COMPOSER_SUBDIRS))
$(addprefix $(SUBDIRS)-$(1)-,$(COMPOSER_SUBDIRS)):
	@$$(eval override $$(@) := $$(CURDIR)/$$(patsubst $$(SUBDIRS)-$(1)-%,%,$$(@)))
	@$$(if $$(wildcard $$($$(@))/$$(MAKEFILE)),\
		$$(MAKE) --directory $$($$(@)) $(1) ,\
		$$(MAKE) --directory $$($$(@)) --makefile $$(COMPOSER) $$(NOTHING)-$$(MAKEFILE) \
	)
endef

$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(INSTALL)))
$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(CLEANER)))
$(eval $(call $(SUBDIRS)-$(EXAMPLE),$(DOITALL)))

override define $(SUBDIRS)-$(TARGETS) =
.PHONY: $(SUBDIRS)-$(TARGETS)-$(1)
$(SUBDIRS)-$(TARGETS)-$(1):
	@$$(eval override $$(TARGETS)-$$(PRINTER)-$(1) := $$(shell $$(call $$(TARGETS)-$$(PRINTER),,$(1))))
	@if [ -n "$$($$(TARGETS)-$$(PRINTER)-$(1))" ]; then \
		$$(call $$(HEADERS)-action,*-$(1),,,$(1),1); \
		$$(MAKE) $$(call COMPOSER_OPTIONS_EXPORT) $$(addprefix $$(SUBDIRS)-$$(TARGETS)-$(1)-,$$($$(TARGETS)-$$(PRINTER)-$(1))); \
	fi

.PHONY: $(SUBDIRS)-$(TARGETS)-$(1)-%
$(SUBDIRS)-$(TARGETS)-$(1)-%:
	@$$(call $$(HEADERS)-note,$$(CURDIR),$$(*),$(1))
	@$$(MAKE) $$(call COMPOSER_OPTIONS_EXPORT) $$(*)
endef

$(eval $(call $(SUBDIRS)-$(TARGETS),$(EXPORTS)))
$(eval $(call $(SUBDIRS)-$(TARGETS),$(CLEANER)))
$(eval $(call $(SUBDIRS)-$(TARGETS),$(DOITALL)))

########################################
## {{{2 $(PRINTER)
########################################

.PHONY: $(PRINTER)
$(PRINTER): .set_title-$(PRINTER)
$(PRINTER):
	@$(call $(HEADERS))
	@$(MAKE) $(PRINTER)-$(PRINTER)

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
$(COMPOSER_LOG): $(if $(wildcard $(COMPOSER_LOG)),,\
	$(NOTHING)-$(COMPOSER_LOG) \
)
$(COMPOSER_LOG):
	@$(LS) --directory \
		$(COMPOSER_LOG) \
		$(?) \
		2>/dev/null \
		|| $(TRUE)

################################################################################
# {{{1 Pandoc Targets
################################################################################

########################################
## {{{2 $(COMPOSER_PANDOC)
########################################

.PHONY: $(COMPOSER_PANDOC)
ifneq ($(c_base),)
$(COMPOSER_PANDOC): $(c_base).$(EXTN_OUTPUT)
endif
$(COMPOSER_PANDOC):
	@$(call $(COMPOSER_PANDOC)-$(NOTHING))
ifneq ($(COMPOSER_DEBUGIT),)
	@$(call $(HEADERS)-note,$(+) $(MARKER) $(c_type),$(c_list))
endif

ifneq ($(c_base),)
$(c_base).$(EXTN_OUTPUT):
	@$(call $(COMPOSER_PANDOC)-$(NOTHING))
	@$(call $(HEADERS)-$(COMPOSER_PANDOC),$(@),$(COMPOSER_DEBUGIT))
	@$(eval override c_list := $(call c_list_var))
ifneq ($(PANDOC_OPTIONS_ERROR),)
	@$(PRINT) "$(_F)$(MARKER) ERROR [$(@)]: $(call PANDOC_OPTIONS_ERROR)" >&2
	@exit 1
endif
ifneq ($(and $(c_site),$(filter $(c_type),$(TYPE_HTML))),)
	@$(call $(HEADERS)-note,$(CURDIR),$(c_list)$(_D) $(MARKER) $(_E)$(call COMPOSER_TMP_FILE,1)$(COMPOSER_EXT_DEFAULT),$(PUBLISH))
	@$(eval override c_list_file := $(call COMPOSER_TMP_FILE)$(COMPOSER_EXT_DEFAULT))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_TMP) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
	@$(call $(PUBLISH)-$(TARGETS),$(c_list_file))
	@$(foreach FILE,$(PUBLISH_SH_HELPERS),\
		$(call $(PUBLISH)-$(TARGETS)-helpers,$(c_list_file),$(FILE)); \
		$(call NEWLINE) \
	)
#>ifneq ($(COMPOSER_DEBUGIT),)
#>	@$(call $(HEADERS)-$(COMPOSER_PANDOC),$(@),$(COMPOSER_DEBUGIT))
#>endif
endif
ifeq ($(c_type),$(TYPE_LPDF))
	@$(call $(HEADERS)-note,$(CURDIR),$(c_list)$(_D) $(MARKER) $(_E)$(call COMPOSER_TMP_FILE,1),$(TYPE_LPDF))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(call COMPOSER_TMP_FILE) $($(DEBUGIT)-output)
	@$(ECHO) "$(_D)"
endif
ifeq ($(c_type),$(TYPE_PRES))
ifneq ($(wildcard $(COMPOSER_CUSTOM)-$(c_type).css),)
	@$(call $(HEADERS)-note,$(CURDIR),$(c_list)$(_D) $(MARKER) $(_E)$(call COMPOSER_TMP_FILE,1).css,$(TYPE_PRES))
	@$(ECHO) "$(_S)"
	@$(MKDIR) $(COMPOSER_TMP) $($(DEBUGIT)-output)
#> update: PANDOC_FILES
	@$(CP) $(COMPOSER_CUSTOM)-$(c_type).css $(call COMPOSER_TMP_FILE).css $($(DEBUGIT)-output)
	@$(call HEREDOC_CUSTOM_REVEALJS_CSS_HACK) $(call COMPOSER_TMP_FILE).css
	@$(ECHO) "$(_D)"
endif
endif
	@$(ECHO) "$(_F)"
	@$(PANDOC) $(call PANDOC_OPTIONS) $(if $(c_list_file),$(c_list_file),$(c_list))
	@$(ECHO) "$(_D)"
ifeq ($(c_type),$(TYPE_HTML))
	@$(SED) -i "s|([>])[[:space:]]*([<][!])|\1\n\2|g" $(CURDIR)/$(@)
endif
ifneq ($(COMPOSER_KEEPING),$(SPECIAL_VAL))
ifneq ($(COMPOSER_LOG),)
	@$(call $(COMPOSER_PANDOC)-$(PRINTER)) >>$(CURDIR)/$(COMPOSER_LOG)
endif
endif
ifneq ($(COMPOSER_DEBUGIT),)
ifneq ($(and $(c_site),$(filter $(c_type),$(TYPE_HTML))),)
	@$(call $(HEADERS)-note,$(@) $(MARKER) $(c_type) ($(PUBLISH)),$(if $(c_list_file),$(c_list_file),$(c_list)),pandoc)
else
	@$(call $(HEADERS)-note,$(@) $(MARKER) $(c_type),$(if $(c_list_file),$(c_list_file),$(c_list)),pandoc)
endif
endif
endif

########################################
## {{{2 $(COMPOSER_EXT)
########################################

#> update: TYPE_TARGETS

override define TYPE_TARGETS_OPTIONS =
	$(if $(wildcard $(CURDIR)/$(MAKEFILE)),,--makefile $(COMPOSER)) \
	$(call COMPOSER_OPTIONS_EXPORT) \
	$(COMPOSER_PANDOC) \
	c_type="$(1)" c_base="$(*)" c_list="$(2)"
endef

override define TYPE_TARGETS =
%.$(2): %$(COMPOSER_EXT)
	@$$(MAKE) $$(call TYPE_TARGETS_OPTIONS,$(1),$$(*)$$(COMPOSER_EXT))
ifneq ($$(COMPOSER_DEBUGIT),)
	@$$(call $$(HEADERS)-note,$$(@) $$(MARKER) $(1),$$(c_list),extension)
endif

%.$(2): %
	@$$(MAKE) $$(call TYPE_TARGETS_OPTIONS,$(1),$$(*))
ifneq ($$(COMPOSER_DEBUGIT),)
	@$$(call $$(HEADERS)-note,$$(@) $$(MARKER) $(1),$$(c_list),wildcard)
endif

%.$(2): $(c_list)
	@$$(MAKE) $$(call TYPE_TARGETS_OPTIONS,$(1),$$(c_list))
ifneq ($$(COMPOSER_DEBUGIT),)
	@$$(call $$(HEADERS)-note,$$(@) $$(MARKER) $(1),$$(c_list),list)
endif
endef

$(foreach TYPE,$(TYPE_TARGETS_LIST),\
	$(eval $(call TYPE_TARGETS,$(TYPE_$(TYPE)),$(EXTN_$(TYPE)))) \
)

################################################################################
# }}}1
################################################################################
# End Of File
################################################################################
