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
override COMPOSER_CSS			:= composer.css
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
override INSTALL			:= install
override TESTOUT			:= test

override COMPOSER_ABSPATH		:= "'$$'"(abspath "'$$'"(dir "'$$'"(lastword "'$$'"(MAKEFILE_LIST))))
override COMPOSER_ALL_REGEX		:= ([a-zA-Z0-9][a-zA-Z0-9_.-]+)[:]
override COMPOSER_SUBDIRS		?=
override COMPOSER_DEPENDS		?=
override COMPOSER_TESTING		?=

ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^$(COMPOSER_ALL_REGEX).*$$|\1|gp" $(COMPOSER_SRC))
else
override COMPOSER_TARGETS		?= $(BASE)
endif
endif

########################################

override INPUT				:= markdown
override OUTPUT				:= $(TYPE)
override EXTENSION			:= $(TYPE)

override TYPE_HTML			:= html
override TYPE_LPDF			:= pdf
override TYPE_PRES			:= revealjs
override TYPE_SHOW			:= slidy
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

override CP				:= $(call COMPOSER_FIND,$(PATH_LIST),cp) -av
override MV				:= $(call COMPOSER_FIND,$(PATH_LIST),mv) -v
override RM				:= $(call COMPOSER_FIND,$(PATH_LIST),rm) -fv

override GIT				:= $(call COMPOSER_FIND,$(PATH_LIST),git)
override LS				:= $(call COMPOSER_FIND,$(PATH_LIST),ls) --color=auto --time-style=long-iso -asF -l
override SED				:= $(call COMPOSER_FIND,$(PATH_LIST),sed) -r
override TIMESTAMP			:= $(call COMPOSER_FIND,$(PATH_LIST),date) --rfc-2822 >

override MKDIR				= if [ ! -d "$(1)" ]; then $(call COMPOSER_FIND,$(PATH_LIST),mkdir) -v "$(1)"; fi

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
	HELP_SYSTEM \
	EXAMPLE_MAKEFILE \
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
	@$(HELPOUT1) "$(TYPE_PRES)"	"$(PRES_EXTN)"	"$(PRES_DESC)"
	@$(HELPOUT1) "$(TYPE_SHOW)"	"$(SHOW_EXTN)"	"$(SHOW_DESC)"
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
	@$(HELPOUT1) "$(COMPOSER_TARGET)"	"Main target used to build/format documents"
	@$(HELPOUT1) "$(COMPOSER_PANDOC)"	"Wrapper target which calls Pandoc directly (used internally)"
	@echo ""
	@echo "Installation Targets:"
	@$(HELPOUT1) "$(UPGRADE)"		"Download/update all 3rd party components (need to do this at least once)"
	@$(HELPOUT1) "$(INSTALL)"		"Recursively create '$(MAKEFILE)' files (non-destructive build system initialization)"
	@$(HELPOUT1) "$(TESTOUT)"		"Build example/test directory using all features and test/validate success"
	@echo ""
	@echo "Helper Targets:"
	@$(HELPOUT1) "all"			"Create all of the default output formats or configured targets"
	@$(HELPOUT1) "clean"			"Remove all of the default output files or configured targets"
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
	@echo "# Advanced, with manual enumeration of user-defined targets and per-target variables:"
	@echo "override COMPOSER_TARGETS ?= $(BASE) $(EXAMPLE_TARGET) $(EXAMPLE_SECOND).$(EXTENSION)"
	@echo "# include $(COMPOSER)"
	@echo ".PHONY: $(BASE) $(EXAMPLE_TARGET)"
	@echo "$(BASE): export OPTS := --table-of-contents --toc-depth=1"
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

.PHONY: HELP_SYSTEM
HELP_SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
HELP_SYSTEM:
	@$(HELPLVL1)
	@echo ""
	@echo "Completely recursive build system:"
	@echo ""
	@echo "# The top-level '$(MAKEFILE)' is the only one which needs a direct reference:"
	@echo "# (NOTE: This must be an absolute path.)"
	@echo "include $(COMPOSER)"
	@echo ""
	@echo "# All sub-directories then each start with:"
	@echo "override COMPOSER_ABSPATH := $(COMPOSER_ABSPATH)"
	@echo "override COMPOSER_TEACHER := "'$$'"(abspath "'$$'"(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo "override COMPOSER_SUBDIRS ?="
	@echo ".DEFAULT_GOAL := all"
	@echo ""
	@echo "# And end with:"
	@echo "include "'$$'"(COMPOSER_TEACHER)"
	@echo ""
	@echo "# Back in the top-level '$(MAKEFILE)', and in all sub-'$(MAKEFILE)' instances which recurse further down:"
	@echo "override COMPOSER_SUBDIRS ?= $(COMPOSER_SUBDIRS)"
	@echo "include [...]"
	@echo ""
	@echo "# Create a new '$(MAKEFILE)' using a helpful template:"
	@echo ""'$$'"(RUNMAKE) --quiet $(EXAMPLE) >$(MAKEFILE)"
	@echo ""
	@echo "# Or, recursively initialize the current directory tree:"
	@echo "# (NOTE: This is a non-destructive operation.)"
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
	@echo "### HEADERS"
	@echo ""
	@echo "# These two statements must be at the top of every file:"
	@echo "#"
	@echo "# (NOTE: The 'COMPOSER_TEACHER' variable can be modified for custom chaining, but with care.)"
	@echo ""
	@echo "override COMPOSER_ABSPATH := $(COMPOSER_ABSPATH)"
	@echo "override COMPOSER_TEACHER := "'$$'"(abspath "'$$'"(COMPOSER_ABSPATH)/../$(MAKEFILE))"
	@echo ""
	@echo "### DEFINITIONS"
	@echo ""
	@echo "# These statements are also required:"
	@echo "#  * Use '?=' declarations and define *before* the upstream 'include' statement"
	@echo "#  * They pass their values *up* the '$(MAKEFILE)' chain"
	@echo "#  * Should always be defined, even if empty, to prevent downward propagation of values"
	@echo "#"
	@echo "# (NOTE: List of 'all' targets is '$(COMPOSER_ALL_REGEX)' if 'COMPOSER_TARGETS' is empty.)"
	@echo ""
	@echo "override COMPOSER_TARGETS ?= $(BASE).$(EXTENSION) $(EXAMPLE_SECOND).$(EXTENSION)"
	@echo "override COMPOSER_SUBDIRS ?= $(COMPOSER_SUBDIRS)"
	@echo "override COMPOSER_DEPENDS ?= $(COMPOSER_DEPENDS)"
	@echo ""
	@echo "### VARIABLES"
	@echo ""
	@echo "# The option variables are not required, but are available for locally-scoped configuration:"
	@echo "#  * For proper inheritance, use '?=' declarations and define *before* the upstream 'include' statement"
	@echo "#  * They pass their values *down* the '$(MAKEFILE)' chain"
	@echo "#  * Do not need to be defined when empty, unless necessary to override upstream values"
	@echo "#"
	@echo "# To disable inheritance and/or insulate from environment variables:"
	@echo "#  * Replace 'override VAR ?=' with 'override VAR :='"
	@echo "#  * Define *after* the upstream 'include' statement"
	@echo "#"
	@echo "# (NOTE: Any settings here will apply to all children, unless 'override' is used downstream.)"
	@echo ""
	@echo "# Define the CSS template to use in this entire directory tree:"
	@echo "#  * Absolute path names should be used, so that children will be able to find it"
	@echo "#  * The '"'$$'"(COMPOSER_ABSPATH)' variable can be used to simplify this"
	@echo "#  * If not defined, the lowest-level '$(COMPOSER_CSS)' file will be used"
	@echo "#  * If not defined, and no '$(COMPOSER_CSS)' file can be found, will use default CSS file"
	@echo ""
	@echo ""'$$'"(eval override DCSS ?= "'$$'"(COMPOSER_ABSPATH)/$(COMPOSER_CSS))"
	@echo ""
	@echo "# All the other optional variables can also be made global in this directory scope:"
	@echo ""
	@echo "override NAME ?="
	@echo "override OPTS ?= --table-of-contents --toc-depth=2"
	@echo ""
	@echo "### INCLUDE"
	@echo ""
	@echo "# Necessary include statement:"
	@echo "#"
	@echo "# (NOTE: This must be after all references to '"'$$'"(COMPOSER_ABSPATH)' but before '.DEFAULT_GOAL'.)"
	@echo ""
	@echo "include "'$$'"(COMPOSER_TEACHER)"
	@echo ""
	@echo "# For recursion to work, a default target needs to be defined:"
	@echo "#  * Needs to be 'all' for directories which must recurse into sub-directories"
	@echo "#  * The 'subdirs' target can be used manually, if desired, so this can be changed to another value"
	@echo "#"
	@echo "# (NOTE: Recursion will cease if not 'all', unless 'subdirs' target is called.)"
	@echo ""
	@echo ".DEFAULT_GOAL := all"
	@echo ""
	@echo "### RECURSION"
	@echo ""
	@echo "# Dependencies can be specified, if needed:"
	@echo "#"
	@echo "# (NOTE: This defines the sub-directories which must be built before '$(firstword $(COMPOSER_SUBDIRS))'.)"
	@echo ""
	@echo "$(firstword $(COMPOSER_SUBDIRS)): $(wordlist 2,$(words $(COMPOSER_SUBDIRS)),$(COMPOSER_SUBDIRS))"
	@echo ""
	@echo "# For parent/child directory dependencies, set '"'$$'"(COMPOSER_DEPENDS)' to a non-empty value."
	@echo ""
	@echo "### MAKEFILE"
	@echo ""
	@echo "# This is where the rest of the file should be defined."
	@echo "#"
	@echo "# In this example, '"'$$'"(COMPOSER_TARGETS)' is used completely in lieu of any explicit targets."
	@echo ""

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(HELPLVL1)
	@echo "# Happy Hacking!"
	@$(HELPLVL1)

########################################

override TEST_DIRECTORIES := \
	$(COMPOSER_DIR)/test_dir \
	$(COMPOSER_DIR)/test_dir/subdir1 \
	$(COMPOSER_DIR)/test_dir/subdir1/example1 \
	$(COMPOSER_DIR)/test_dir/subdir2 \
	$(COMPOSER_DIR)/test_dir/subdir2/example2
override TEST_DIR_CSSDST := $(word 4,$(TEST_DIRECTORIES))
override TEST_DIR_DEPEND := $(word 2,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_1 := $(word 3,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_2 := $(word 5,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_F := $(word 1,$(TEST_DIRECTORIES))
override TEST_DEPEND_SUB := example1
override TEST_FULLMK_SUB := subdir1 subdir2
override TEST_IMAGES_WLD := *.png

.PHONY: $(TESTOUT)
$(TESTOUT):
	$(foreach FILE,$(TEST_DIRECTORIES),\
		$(call MKDIR,$(FILE)) && \
			$(CP) \
				"$(COMPOSER_DIR)/$(BASE).$(MARKDOWN)" \
				"$(COMPOSER_DIR)/$(EXAMPLE_SECOND).$(MARKDOWN)" \
				"$(COMPOSER_DIR)/"$(TEST_IMAGES_WLD) \
				"$(FILE)"
	)
	$(CP) "$(CSS_DST)" "$(TEST_DIR_CSSDST)/$(COMPOSER_CSS)"
	$(RUNMAKE) --directory "$(COMPOSER_DIR)/test_dir" $(INSTALL)
ifneq ($(COMPOSER_TESTING),0)
	$(RUNMAKE) --quiet COMPOSER_SUBDIRS="$(TEST_DEPEND_SUB)" COMPOSER_DEPENDS="1" $(EXAMPLE) >"$(TEST_DIR_DEPEND)/$(MAKEFILE)"
	$(RUNMAKE) --quiet EXAMPLE_MAKEFILE_1 >"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	$(RUNMAKE) --quiet EXAMPLE_MAKEFILE_2 >"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	$(RUNMAKE) --quiet COMPOSER_TARGETS="" COMPOSER_SUBDIRS="" $(EXAMPLE) >>"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	$(RUNMAKE) --quiet COMPOSER_TARGETS="" COMPOSER_SUBDIRS="" $(EXAMPLE) >>"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	$(RUNMAKE) --quiet COMPOSER_SUBDIRS="$(TEST_FULLMK_SUB)" EXAMPLE_MAKEFILE_FULL >"$(TEST_DIR_MAKE_F)/$(MAKEFILE)"
endif
	$(MAKE) --directory "$(COMPOSER_DIR)/test_dir"
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
	@$(SED) --in-place "s|^(include[ ]).+$$|\1$(COMPOSER)|g" "$(CURDIR)/$(MAKEFILE)"

.PHONY: $(INSTALL)-dir
$(INSTALL)-dir:
	if [ -f "$(CURDIR)/$(MAKEFILE)" ]; then
		@echo "[SKIPPING] $(CURDIR)/$(MAKEFILE)"
	else
		@echo "[CREATING] $(CURDIR)/$(MAKEFILE)"
		$(RUNMAKE) --quiet \
			COMPOSER_TARGETS="$(sort $(subst .$(MARKDOWN),.$(TYPE_HTML),$(wildcard *.$(MARKDOWN))))" \
			COMPOSER_SUBDIRS="$(sort $(subst /,,$(wildcard */)))" \
			COMPOSER_DEPENDS="$(COMPOSER_DEPENDS)" \
			$(EXAMPLE) >"$(CURDIR)/$(MAKEFILE)"
	fi
	$(foreach FILE,$(sort $(subst /,,$(wildcard */))),\
		$(RUNMAKE) --quiet --directory "$(CURDIR)/$(FILE)" $(INSTALL)-dir
	)

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
	@$(HELPOUT2) "CSS:"	"[$(CSS)]"
	@$(HELPOUT2) "DCSS:"	"[$(DCSS)]"
	@$(HELPOUT2) "NAME:"	"[$(NAME)]"
	@$(HELPOUT2) "OPTS:"	"[$(OPTS)]"
	@$(HELPLVL1)

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

.PHONY: subdirs $(COMPOSER_SUBDIRS)
subdirs: $(COMPOSER_SUBDIRS)
$(COMPOSER_SUBDIRS):
	$(MAKE) --directory "$(CURDIR)/$(@)"

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

%.$(PRES_EXTN): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"

%.$(SHOW_EXTN): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_EPUB): %.$(MARKDOWN)
	$(MAKEDOC) TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)"

################################################################################
# End Of File
################################################################################
