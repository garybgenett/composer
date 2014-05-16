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

TYPE					?= html
BASE					?= README
LIST					?= $(BASE).$(MARKDOWN)

DCSS					?= $(COMPOSER_DIR)/$(COMPOSER_CSS)
NAME					?=
OPTS					?=

################################################################################

override COMPOSER_TARGET		:= compose
override RUNMAKE			:= $(MAKE) --makefile $(COMPOSER_SRC)
override COMPOSE			:= $(RUNMAKE) $(COMPOSER_TARGET)

override HELPOUT			:= help
override UPGRADE			:= update

ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		?= $(shell $(SED) -n "s/^([^\#.][^:]+)[:].*$$/\1/gp" $(COMPOSER_SRC))
else
override COMPOSER_TARGETS		?= $(BASE)
endif

########################################

override INPUT				:= markdown
override OUTPUT				:= $(TYPE)
override EXTENSION			:= $(TYPE)

override TYPE_HTML			:= html
override TYPE_SHOW			:= slidy
override TYPE_PRES			:= revealjs
override TYPE_LPDF			:= pdf
override TYPE_EPUB			:= epub

override SHOW_EXTN			:= $(TYPE_SHOW).$(TYPE_HTML)
override PRES_EXTN			:= $(TYPE_PRES).$(TYPE_HTML)

ifeq ($(TYPE),$(TYPE_HTML))
override OUTPUT				:= html5
endif
ifeq ($(TYPE),$(TYPE_SHOW))
override OUTPUT				:= slidy
override EXTENSION			:= $(SHOW_EXTN)
endif
ifeq ($(TYPE),$(TYPE_PRES))
override OUTPUT				:= revealjs
override EXTENSION			:= $(PRES_EXTN)
endif
ifeq ($(TYPE),$(TYPE_LPDF))
override OUTPUT				:= latex
endif

override HTML_DESC			:= HTML: HyperText Markup Language
override SHOW_DESC			:= HTML/JS Slideshow: W3C Slidy2
override PRES_DESC			:= HTML/JS Slideshow: Reveal.js
override LPDF_DESC			:= PDF: Portable Document Format
override EPUB_DESC			:= ePUB: Electronic Publication

########################################

# https://github.com/Thiht/markdown-viewer
override CSS_SRC			:= https://raw.githubusercontent.com/Thiht/markdown-viewer/master/chrome/skin/markdown-viewer.css
override CSS_DST			:= $(COMPOSER_DIR)/markdown-viewer.css

# https://github.com/hakimel/reveal.js
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DST			:= $(COMPOSER_DIR)/revealjs
override REVEALJS_CSS			:= $(REVEALJS_DST)/css/theme/default.css

# http://www.w3.org/Talks/Tools/Slidy2/Overview.html#%283%29
override SLIDY_FILES			:= scripts/slidy.js styles/slidy.css graphics/fold-dim.gif graphics/fold.gif graphics/nofold-dim.gif graphics/unfold-dim.gif graphics/unfold.gif
override SLIDY_SRC			:= http://www.w3.org/Talks/Tools/Slidy2
override SLIDY_DST			:= $(COMPOSER_DIR)/slidy
override SLIDY_CSS			:= $(SLIDY_DST)/styles/slidy.css

override SLIDE_LEVEL			:= 2

ifneq (,$(wildcard $(DCSS)))
override CSS				:= $(DCSS)
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

########################################

.DEFAULT_GOAL := $(HELPOUT)
.DEFAULT:
	$(RUNMAKE) $(HELPOUT)

########################################

override HELPLVL1 := printf "=%.0s" {1..40} ; echo
override HELPLVL2 := printf "=%.0s" {1..20} ; echo

override EXAMPLE_OUTPUT := Users_Guide
override EXAMPLE_SECOND := LICENSE
override EXAMPLE_TARGET := manual

.PHONY: $(HELPOUT)
$(HELPOUT):
	@$(HELPLVL1)
	@echo "Composer CMS :: Primary Makefile"
	@$(HELPLVL1)
	@echo ""
	@echo "Usage:"
	@echo "	$(RUNMAKE) [variables] <filename>.<extension>"
	@echo "	$(COMPOSE) [variables]"
	@echo ""
	@$(HELPLVL2)
	@echo ""
	@echo "Variables:"
	@echo "	TYPE	Desired output format	[$(TYPE)]"
	@echo "	BASE	Base of output file(s)	[$(BASE)]"
	@echo "	LIST	List of input files(s)	[$(LIST)]"
	@echo ""
	@echo "Optional Variables:"
	@echo "	DCSS	Location of CSS file	[$(DCSS)]"
	@echo "	NAME	Document title prefix	[$(NAME)]"
	@echo "	OPTS	Custom Pandoc options	[$(OPTS)]"
	@echo ""
	@echo "Pre-Defined Types:"
	@echo "	[Type]		[Extension]	[Description]"
	@echo "	$(TYPE_HTML)		$(TYPE_HTML)		$(HTML_DESC)"
	@echo "	$(TYPE_SHOW)		$(SHOW_EXTN)	$(SHOW_DESC)"
	@echo "	$(TYPE_PRES)	$(PRES_EXTN)	$(PRES_DESC)"
	@echo "	$(TYPE_LPDF)		$(TYPE_LPDF)		$(LPDF_DESC)"
	@echo "	$(TYPE_EPUB)		$(TYPE_EPUB)		$(EPUB_DESC)"
	@echo ""
	@echo "Any other types specified will be passed directly through to Pandoc."
	@echo ""
	@$(HELPLVL2)
	@echo ""
	@echo "Primary Targets:"
	@echo "	$(HELPOUT)	This help/usage output"
	@echo "	$(UPGRADE)	Download/update all 3rd party components (need to do this at least once)"
	@echo "	$(COMPOSER_TARGET)	Main target used to build/format documents"
	@echo ""
	@echo "Helper Targets:"
	@echo "	all	Create all of the default output formats or specified targets"
	@echo "	clean	Remove all of the default output files or specified targets"
	@echo "	print	List all source files newer than the '$(COMPOSER_STAMP)' timestamp file"
	@echo ""
	@$(HELPLVL2)
	@echo ""
	@echo "Command Examples:"
	@echo ""
	@echo "	Have Composer do all the work for you:"
	@echo "		$(RUNMAKE) $(BASE).$(EXTENSION)"
	@echo ""
	@echo "	Be clear about what you want (or, for multiple or differently named input files):"
	@echo "		$(COMPOSE) LIST=\"$(BASE).$(MARKDOWN) $(EXAMPLE_SECOND).$(MARKDOWN)\" BASE=$(EXAMPLE_OUTPUT) TYPE=$(TYPE_HTML)"
	@echo ""
	@echo "Makefile Examples:"
	@echo ""
	@echo "	Simple, with filename targets and automagic detection of them:"
	@echo "		include $(COMPOSER)"
	@echo "		.PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "		$(BASE): # so \"clean\" will catch the below files"
	@echo "		$(EXAMPLE_TARGET): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@echo "		$(EXAMPLE_SECOND).$(EXTENSION):"
	@echo ""
	@echo "	Advanced, with user-defined targets and manual enumeration of them:"
	@echo "		COMPOSER_TARGETS := $(BASE) $(EXAMPLE_TARGET)"
	@echo "		include $(COMPOSER)"
	@echo "		.PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "		$(BASE): $(BASE).$(EXTENSION)"
	@echo "		$(EXAMPLE_TARGET): $(BASE).$(MARKDOWN) $(EXAMPLE_SECOND).$(MARKDOWN)"
	@echo "			"'$$'"(COMPOSE) LIST=\""'$$'"(^)\" BASE=$(EXAMPLE_OUTPUT) TYPE=$(TYPE_HTML)"
	@echo "			"'$$'"(COMPOSE) LIST=\""'$$'"(^)\" BASE=$(EXAMPLE_OUTPUT) TYPE=$(TYPE_LPDF)"
	@echo "		$(EXAMPLE_TARGET)-clean:"
	@echo "			"'$$'"(RM) $(EXAMPLE_OUTPUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@echo ""
	@echo "	Then, from the command line:"
	@echo "		make clean && make all"
	@echo ""
	@$(HELPLVL1)
	@echo "Happy Hacking!"
	@$(HELPLVL1)

########################################

.PHONY: $(UPGRADE)
$(UPGRADE):
	$(call WGET_FILE,$(CSS_DST)) "$(CSS_SRC)"
	if [ ! -d "$(REVEALJS_DST)" ] ; then \
		$(GIT) clone "$(REVEALJS_SRC)" "$(REVEALJS_DST)" ; \
		$(MV) "$(REVEALJS_DST)/.git" "$(REVEALJS_DST).git" ; \
	else \
		$(GIT) --git-dir="$(realpath $(REVEALJS_DST).git)" --work-tree="$(realpath $(REVEALJS_DST))" pull ; \
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
	$(BASE).$(SHOW_EXTN) \
	$(BASE).$(PRES_EXTN) \
	$(BASE).$(TYPE_LPDF) \
	$(BASE).$(TYPE_EPUB)
endif

.PHONY: clean
.PHONY: $(addsuffix -clean,$(COMPOSER_TARGETS))
clean: $(addsuffix -clean,$(COMPOSER_TARGETS))
	$(foreach FILE,$(COMPOSER_TARGETS),\
		$(RM) \
			"$(FILE)" \
			"$(FILE).$(TYPE_HTML)" \
			"$(FILE).$(SHOW_EXTN)" \
			"$(FILE).$(PRES_EXTN)" \
			"$(FILE).$(TYPE_LPDF)" \
			"$(FILE).$(TYPE_EPUB)"
	)
	$(RM) $(COMPOSER_STAMP)

.PHONY: print
print: $(COMPOSER_STAMP)
$(COMPOSER_STAMP): *.$(MARKDOWN)
	@$(LS) $(?)

########################################

.PHONY: $(COMPOSER_TARGET)
$(COMPOSER_TARGET): $(BASE).$(EXTENSION)
	$(TIMESTAMP) $(COMPOSER_STAMP)

$(BASE).$(EXTENSION): $(LIST)
	$(PANDOC)

%.$(TYPE_HTML): %.$(MARKDOWN)
	$(COMPOSE) TYPE="$(TYPE_HTML)" BASE="$(*)" LIST="$(^)" DCSS="$(DCSS)" NAME="$(NAME)" OPTS="$(OPTS)"

%.$(SHOW_EXTN): %.$(MARKDOWN)
	$(COMPOSE) TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)" DCSS="$(DCSS)" NAME="$(NAME)" OPTS="$(OPTS)"

%.$(PRES_EXTN): %.$(MARKDOWN)
	$(COMPOSE) TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)" DCSS="$(DCSS)" NAME="$(NAME)" OPTS="$(OPTS)"

%.$(TYPE_LPDF): %.$(MARKDOWN)
	$(COMPOSE) TYPE="$(TYPE_LPDF)" BASE="$(*)" LIST="$(^)" DCSS="$(DCSS)" NAME="$(NAME)" OPTS="$(OPTS)"

%.$(TYPE_EPUB): %.$(MARKDOWN)
	$(COMPOSE) TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)" DCSS="$(DCSS)" NAME="$(NAME)" OPTS="$(OPTS)"

################################################################################
# End Of File
################################################################################
