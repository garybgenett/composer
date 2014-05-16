################################################################################
# Composer CMS :: Primary Makefile
################################################################################

override COMPOSER			:= $(abspath $(lastword $(MAKEFILE_LIST)))
override COMPOSER_SRC			:= $(abspath $(firstword $(MAKEFILE_LIST)))
override COMPOSER_DIR			:= $(abspath $(dir $(COMPOSER)))

override COMPOSER_FIND			= $(firstword $(wildcard $(abspath $(addsuffix /$(2),$(1)))))

################################################################################

override MAKEFILE			:= Makefile
override MAKEFLAGS			:=

override COMPOSER_STAMP			:= .composed
override COMPOSER_CSS			:= default.css
override MARKDOWN			:= md

########################################

override TYPE				?= html
override BASE				?= README
override LIST				?= $(BASE).$(MARKDOWN)

override DCSS_FILE			:= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override DCSS				?=
override NAME				?=
override OPTS				?=

################################################################################

override COMPOSER_TARGET		:= compose
override COMPOSER_PANDOC		:= pandoc
override RUNMAKE			:= $(MAKE) --makefile $(COMPOSER_SRC)
override COMPOSE			:= $(RUNMAKE) $(COMPOSER_TARGET)
override MAKEDOC			:= $(RUNMAKE) $(COMPOSER_PANDOC)

override HELPOUT			:= usage
override HELPALL			:= help
override UPGRADE			:= update

override COMPOSER_ALL_REGEX		:= ([a-zA-Z0-9][a-zA-Z0-9_.-]+)[:]

ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^$(COMPOSER_ALL_REGEX).*$$|\1|gp" $(COMPOSER_SRC))
else
override COMPOSER_TARGETS		?= $(BASE)
endif

########################################

override INPUT				:= markdown
override OUTPUT				:= $(TYPE)
override EXTENSION			:= $(TYPE)

override TYPE_HTML			:= html
override TYPE_LPDF			:= pdf
override TYPE_SHOW			:= slidy
override TYPE_PRES			:= revealjs
override TYPE_EPUB			:= epub

override SHOW_EXTN			:= $(TYPE_SHOW).$(TYPE_HTML)
override PRES_EXTN			:= $(TYPE_PRES).$(TYPE_HTML)

ifeq ($(TYPE),$(TYPE_HTML))
override OUTPUT				:= html5
endif
ifeq ($(TYPE),$(TYPE_LPDF))
override OUTPUT				:= latex
endif
ifeq ($(TYPE),$(TYPE_SHOW))
override OUTPUT				:= slidy
override EXTENSION			:= $(SHOW_EXTN)
endif
ifeq ($(TYPE),$(TYPE_PRES))
override OUTPUT				:= revealjs
override EXTENSION			:= $(PRES_EXTN)
endif

override HTML_DESC			:= HTML: HyperText Markup Language
override LPDF_DESC			:= PDF: Portable Document Format
override SHOW_DESC			:= HTML/JS Slideshow: W3C Slidy2
override PRES_DESC			:= HTML/JS Slideshow: Reveal.js
override EPUB_DESC			:= ePUB: Electronic Publication

########################################

# https://github.com/Thiht/markdown-viewer
override CSS_SRC			:= https://raw.githubusercontent.com/Thiht/markdown-viewer/master/chrome/skin/markdown-viewer.css
override CSS_DST			:= $(COMPOSER_DIR)/markdown-viewer.css

# https://github.com/hakimel/reveal.js
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DST			:= $(COMPOSER_DIR)/revealjs
#override REVEALJS_CSS			:= $(REVEALJS_DST)/css/theme/default.css
override REVEALJS_CSS			:= $(REVEALJS_DST).css

# http://www.w3.org/Talks/Tools/Slidy2/Overview.html#%283%29
override SLIDY_FILES			:= scripts/slidy.js styles/slidy.css graphics/fold-dim.gif graphics/fold.gif graphics/nofold-dim.gif graphics/unfold-dim.gif graphics/unfold.gif
override SLIDY_SRC			:= http://www.w3.org/Talks/Tools/Slidy2
override SLIDY_DST			:= $(COMPOSER_DIR)/slidy
override SLIDY_CSS			:= $(SLIDY_DST)/styles/slidy.css

override SLIDE_LEVEL			:= 2

ifneq ($(wildcard $(DCSS)),)
override CSS				:= $(DCSS)
else ifneq ($(wildcard $(DCSS_FILE)),)
override CSS				:= $(DCSS_FILE)
else ifeq ($(OUTPUT),revealjs)
override CSS				:= $(REVEALJS_CSS)
else ifeq ($(OUTPUT),slidy)
override CSS				:= $(SLIDY_CSS)
else
override CSS				:= $(CSS_DST)
endif

override PANDOC				:= pandoc \
	--standalone \
	--self-contained \
	\
	--chapters \
	--listings \
	--normalize \
	--smart \
	\
	--slide-level $(SLIDE_LEVEL) \
	--variable "revealjs-url:$(REVEALJS_DST)" \
	--variable "slidy-url:$(SLIDY_DST)" \
	\
	--css "$(CSS)" \
	--title-prefix "$(NAME)" \
	--output "$(BASE).$(EXTENSION)" \
	--from "$(INPUT)" \
	--to "$(OUTPUT)" \
	\
	$(OPTS) \
	$(LIST)

########################################

override PATH_LIST			:= $(subst :, ,$(PATH))

override MV				:= $(call COMPOSER_FIND,$(PATH_LIST),mv) -v
override RM				:= $(call COMPOSER_FIND,$(PATH_LIST),rm) -fv

override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git)
override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) --color=auto --time-style=long-iso -asF -l
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r
override TIMESTAMP			:= $(call COMPOSER_FIND,$(PATH_LIST),date) --rfc-2822 >

override WGET				:= $(call COMPOSER_FIND,$(PATH_LIST),wget) --verbose --restrict-file-names=windows --server-response --timestamping
override WGET_FILE			= $(WGET) --directory-prefix="$(abspath $(dir $(1)))"

################################################################################

.NOTPARALLEL:
.ONESHELL:
.POSIX:

.DEFAULT_GOAL := $(HELPOUT)

########################################

override HELPLVL1 := printf "\#%.0s" {1..70}; echo
override HELPLVL2 := printf "\#%.0s" {1..40}; echo

override HELPOUT1 := printf "   %-10s %-25s %s\n"
override HELPOUT2 := printf "\# %-20s %s\n"

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
	HELP_TARGETS \
	HELP_COMMANDS \
	EXAMPLE_MAKEFILES \
	HELP_FOOTER

.PHONY: HELP_HEADER
HELP_HEADER:
	@$(HELPLVL1)
	@echo "# Composer CMS :: Primary Makefile"
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
	@$(HELPOUT1) "DCSS"	"Location of CSS file"		"[$(DCSS)] (overrides '$(COMPOSER_CSS)')"
	@$(HELPOUT1) "NAME"	"Document title prefix"		"[$(NAME)]"
	@$(HELPOUT1) "OPTS"	"Custom Pandoc options"		"[$(OPTS)]"
	@echo ""
	@echo "Pre-Defined Types:"
	@$(HELPOUT1) "[Type]"		"[Extension]"	"[Description]"
	@$(HELPOUT1) "$(TYPE_HTML)"	"$(TYPE_HTML)"	"$(HTML_DESC)"
	@$(HELPOUT1) "$(TYPE_LPDF)"	"$(TYPE_LPDF)"	"$(LPDF_DESC)"
	@$(HELPOUT1) "$(TYPE_SHOW)"	"$(SHOW_EXTN)"	"$(SHOW_DESC)"
	@$(HELPOUT1) "$(TYPE_PRES)"	"$(PRES_EXTN)"	"$(PRES_DESC)"
	@$(HELPOUT1) "$(TYPE_EPUB)"	"$(TYPE_EPUB)"	"$(EPUB_DESC)"
	@echo ""
	@echo "Any other types specified will be passed directly through to Pandoc."
	@echo ""

.PHONY: HELP_TARGETS
HELP_TARGETS:
	@$(HELPLVL2)
	@echo ""
	@echo "Primary Targets:"
	@$(HELPOUT1) "$(HELPOUT)"		"Basic help output"
	@$(HELPOUT1) "$(HELPALL)"		"Complete help output"
	@$(HELPOUT1) "$(UPGRADE)"		"Download/update all 3rd party components (need to do this at least once)"
	@$(HELPOUT1) "$(COMPOSER_TARGET)"	"Main target used to build/format documents"
	@$(HELPOUT1) "$(COMPOSER_PANDOC)"	"Helper target which calls Pandoc directly (for internal use only)"
	@echo ""
	@echo "Helper Targets:"
	@$(HELPOUT1) "all"			"Create all of the default output formats or specified targets"
	@$(HELPOUT1) "clean"			"Remove all of the default output files or specified targets"
	@$(HELPOUT1) "print"			"List all source files newer than the '$(COMPOSER_STAMP)' timestamp file"
	@echo ""

.PHONY: HELP_COMMANDS
HELP_COMMANDS:
	@$(HELPLVL1)
	@echo ""
	@echo "Command Examples:"
	@echo ""
	@echo "# Have the system do all the work:"
	@echo ""'$$'"(RUNMAKE) $(BASE).$(EXTENSION)"
	@echo ""
	@echo "# Be clear about what is wanted (or, for multiple or differently named input files):"
	@echo ""'$$'"(COMPOSE) LIST=\"$(BASE).$(MARKDOWN) $(EXAMPLE_SECOND).$(MARKDOWN)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
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
	@echo "# Simple, with filename targets and \"automagic\" detection of them:"
	@echo "# include $(COMPOSER)"
	@echo ".PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "$(BASE): # so \"clean\" will catch the below files"
	@echo "$(EXAMPLE_TARGET): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@echo "$(EXAMPLE_SECOND).$(EXTENSION):"
	@echo ""

.PHONY: EXAMPLE_MAKEFILE_2
EXAMPLE_MAKEFILE_2:
	@echo "# Advanced, with user-defined targets and manual enumeration of them:"
	@echo "COMPOSER_TARGETS := $(BASE) $(EXAMPLE_TARGET)"
	@echo "# include $(COMPOSER)"
	@echo ".PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "$(BASE): $(BASE).$(EXTENSION)"
	@echo "$(EXAMPLE_TARGET): $(BASE).$(MARKDOWN) $(EXAMPLE_SECOND).$(MARKDOWN)"
	@echo "	"'$$'"(COMPOSE) LIST=\""'$$'"(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@echo "	"'$$'"(COMPOSE) LIST=\""'$$'"(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_LPDF)\""
	@echo "$(EXAMPLE_TARGET)-clean:"
	@echo "	"'$$'"(RM) $(EXAMPLE_OUTPUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@echo ""

.PHONY: EXAMPLE_MAKEFILES_FOOTER
EXAMPLE_MAKEFILES_FOOTER:
	@echo "# Then, from the command line:"
	@echo "make clean && make all"
	@echo ""

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(HELPLVL1)
	@echo "# Happy Hacking!"
	@$(HELPLVL1)

########################################

.PHONY: $(UPGRADE)
$(UPGRADE):
	$(call WGET_FILE,$(CSS_DST)) "$(CSS_SRC)"
	if [ ! -d "$(REVEALJS_DST)" ]; then
		$(GIT) clone "$(REVEALJS_SRC)" "$(REVEALJS_DST)"
		$(MV) "$(REVEALJS_DST)/.git" "$(REVEALJS_DST).git"
	else
		$(GIT) --git-dir="$(REVEALJS_DST).git" --work-tree="$(REVEALJS_DST)" pull
	fi
	$(foreach FILE,$(SLIDY_FILES),\
		$(call WGET_FILE,$(SLIDY_DST)/$(FILE)) "$(SLIDY_SRC)/$(FILE)"
	)

########################################

.PHONY: all
ifneq ($(COMPOSER_TARGETS),$(BASE))
all: \
	$(COMPOSER_TARGETS)
else
all: \
	$(BASE).$(TYPE_HTML) \
	$(BASE).$(TYPE_LPDF) \
	$(BASE).$(SHOW_EXTN) \
	$(BASE).$(PRES_EXTN) \
	$(BASE).$(TYPE_EPUB)
endif

.PHONY: clean
.PHONY: $(addsuffix -clean,$(COMPOSER_TARGETS))
clean: $(addsuffix -clean,$(COMPOSER_TARGETS))
	$(foreach FILE,$(COMPOSER_TARGETS),\
		$(RM) \
			"$(FILE)" \
			"$(FILE).$(TYPE_HTML)" \
			"$(FILE).$(TYPE_LPDF)" \
			"$(FILE).$(SHOW_EXTN)" \
			"$(FILE).$(PRES_EXTN)" \
			"$(FILE).$(TYPE_EPUB)"
	)
	$(RM) $(COMPOSER_STAMP)

.PHONY: settings
settings:
	@$(HELPLVL2)
	@$(HELPOUT2) "CURDIR: [$(CURDIR)]"
	@$(HELPOUT2) "TYPE:   [$(TYPE)]"
	@$(HELPOUT2) "BASE:   [$(BASE)]"
	@$(HELPOUT2) "LIST:   [$(LIST)]"
	@$(HELPOUT2) "CSS:    [$(CSS)]"
	@$(HELPOUT2) "DCSS:   [$(DCSS)]"
	@$(HELPOUT2) "NAME:   [$(NAME)]"
	@$(HELPOUT2) "OPTS:   [$(OPTS)]"
	@$(HELPLVL2)

.PHONY: print
print: $(COMPOSER_STAMP)
$(COMPOSER_STAMP): *.$(MARKDOWN)
	@$(LS) $(?)

########################################

.PHONY: $(COMPOSER_TARGET)
$(COMPOSER_TARGET): $(BASE).$(EXTENSION)

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): settings $(LIST)
	$(PANDOC)
	$(TIMESTAMP) $(COMPOSER_STAMP)

$(BASE).$(EXTENSION): $(LIST)
	$(MAKEDOC) TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(^)"

%.$(TYPE_HTML): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_HTML)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_LPDF): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_LPDF)" BASE="$(*)" LIST="$(^)"

%.$(SHOW_EXTN): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)"

%.$(PRES_EXTN): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_EPUB): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)"

################################################################################
# End Of File
################################################################################
