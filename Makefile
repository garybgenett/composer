#!/usr/bin/make --makefile
################################################################################
# Composer CMS :: Primary Makefile
################################################################################
#
#TODO : portability
# Every attempt has been made to make this as portable as possible:
#	http://www.gnu.org/software/make/manual/make.html#toc-Features-of-GNU-make
#	http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Make
#	http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
#
# Please report any cross-platform issues, or issues with other versions of Make.
#
################################################################################

#WORKING:NOW: document, somehow, all the places "composer" is used personally, for debugging/testing...
#WORKING:NOW: switch from hexo to bootstrap: https://getbootstrap.com/docs
#WORKING
# - double-check all usage of $(BUILD_ENV); some are probably fine as $(BUILD_ENV_PANDOC), which could maybe use a better name
# - double-check all usage of $(shell ...); minimize runs to when needed, to keep performance reasonable
# - all the extra explicit quoting is not bringing any value, and is instead making the code complex (e.g. subst); it should be cleaned up
# _ selectively add "-u / --update" option to "$(CP) / $(MV)"
# _ make sure all commands are using their variable counterparts
# _ trim down the "ifeq($BUILD_PLAT,Msys)" to only the things which are necessary
# _ try to consolidate all "ifeq($BUILD_PLAT,...)" statements, so that all the builds are as similar as possible
# _ add "licenses" or "info" option, to display list of included programs and licenses
# _ make sure all referenced programs are included (goal is composer should function as a chroot)
# _ update COMPOSER_ALL_REGEX :: will impact ALL_TARGETS variable
# _ make all network operations non-blocking (i.e. use "|| true" on "curl, git, cabal update, etc.") {make sure to keep "patch" commands right after "untar"}
# _ template inherit & archive target
# _ double-check all $SED statements, for consistency
# _ double-check "if*eq" stanzas for consistent definition of default value
# _ double-check "if*eq" stanzas for missing "else"
# _ double-check "if*eq" stanzas for "$(if $(and $(or $(filter $(filter-out" possibilities
# _ double-check "$(if $(and $(or $(filter $(filter-out" statements, for consistency
# _ can "if*eq" stanzas be properly nested, with tabs, so that they are more readable?
# _ comments, comments, comments (& formatting :)
# _ define build target dependencies; enabling parallel make?
# _ remove recursion and "$(RUNMAKE)"; opt for "include" tree instead?
# _ test native fetch/build without bootstrap, just for fun
# _ add a version number checklist
#	DEBIAN_*, whenever ifneq ($(BUILD_FETCH),)
#	FUNTOO_*, when FUNTOO_DATE
#	MAKE_*_VERSION, every $(RELEASE)-prep
#	DYNAMIC_LIBRARY_LIST, every $(RELEASE)-prep
#	PERL_MODULES_LIST, when CURL_VER
#	GHC_CABAL_VER, when GHC_VER
#	GHC_LIBRARIES_INIT_LIST, when GHC_VER
#	CABAL_LIBRARIES_GHC_LIST, when GHC_VER
#	CABAL_LIBRARIES_INIT_LIST, when CABAL_VER_INIT
#	CABAL_LIBRARIES_LIST, when CABAL_VER
#	PANDOC_LIBRARIES_LIST, when PANDOC_VER (or PANDOC_CMT?)
#	etc., more?
# _ document COMPOSER_TESTING uses
#	$(TESTING): empty, 0, 1, -1 (document -1?)
#	$(BUILDIT)-cabal[-init]: empty, non-empty
#	$(BUILDIT)-pandoc: empty, 0, 1, -1
#	$(CHECKIT): empty, non-empty
#	HEXO_WORK_INIT: empty, non-empty
# _ 2017-08-01 what is up with the '$(call NEWLINE)$(ECHO);' business?  didn't seem necessary when used for business documents...
# _ 2017-08-03 no $(DIFF)?  must do DIFFUTILS after FINDUTILS...
# _ 2018-01-17 consider doing a '$(CHMOD) -R ./.[a-z]*/ ./*/' in '$(DISTRIB)'...
#WORKING

#WORKING
# linking/libraries
#	http://www.freegamedev.net/wiki/Portable_binaries
#	https://stackoverflow.com/questions/10539857/statically-link-gmp-to-an-haskell-application-using-ghc-llvm
#	https://stackoverflow.com/questions/7832112/how-to-selectively-link-certain-system-libraries-statically-into-haskell-program
#	https://stackoverflow.com/questions/8657908/deploying-yesod-to-heroku-cant-build-statically/8658468#8658468
#	https://stackoverflow.com/questions/2558166/using-ghc-cabal-with-gmp-installed-in-user-space
#	http://www.insanecoding.blogspot.com/2012/07/creating-portable-linux-binaries.html
#	https://enchildfone.wordpress.com/2010/03/23/a-description-of-rpath-origin-ld_library_path-and-portable-linux-binaries
#WORKING

#TODO : new features
# http://make.mad-scientist.net/constructed-include-files
# http://www.html5rocks.com/en/tutorials/webcomponents/imports
# http://filoxus.blogspot.com/2008/01/how-to-insert-watermark-in-latex.html
# https://gist.github.com/ryangray/1882525
# https://gist.github.com/Dashed/6714393
# https://www.w3.org/community/markdown/wiki/MarkdownImplementations
#TODO

#TODO
# bash/less/vim
#	add needed files to bindir
#	does the right bash get run with shell-msys?  when in COMPOSER_ABODE?  when in bindir?
# mingw for windows?
#	re-verify all sed and other build hackery, for both linux and windows
# double-check all "thanks" comments; some are things you should have known
# double-check all licenses
#TODO

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
#	try building non-BUILD_DIST version
# test install in basic debian, with no devel packages
# test install in fresh cygwin
#	hack setup.bat
#	try "build" without networking available
#	try building 64-bit version
# test re-entry of builds
# do a "diff -qr" of build chroot after completion
#BUILD TEST

#OTHER NOTES
# dependencies/credits list
#	add msys/mingw-w64 project
#	add all libraries/utilities
#	replace wget with curl project
# now need zip/unzip in path
#	add zip/unzip [ -x ... ] checks and message (read ENTER) if not
# markdown-viewer xpi package
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
override COMPOSER_INCLUDE		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/$(COMPOSER_SETTINGS))

ifneq ($(wildcard $(COMPOSER_INCLUDE)),)
include $(COMPOSER_INCLUDE)
override MAKEFILE_LIST			:= $(filter-out $(COMPOSER_INCLUDE),$(MAKEFILE_LIST))
endif

########################################

override COMPOSER			:= $(abspath $(lastword $(MAKEFILE_LIST)))
override COMPOSER_SRC			:= $(abspath $(firstword $(MAKEFILE_LIST)))
override COMPOSER_DIR			:= $(abspath $(dir $(COMPOSER)))

override COMPOSER_FIND			= $(firstword $(wildcard $(abspath $(addsuffix /$(2),$(1)))))

# prevent "chicken and egg" errors with all "$(shell)" calls between here and the "$(PATH_LIST)" section
override CP				:= "$(call COMPOSER_FIND,$(subst :, ,$(PATH)),cp)" -afv
override SED				:= "$(call COMPOSER_FIND,$(subst :, ,$(PATH)),sed)" -r
override UNAME				:= "$(call COMPOSER_FIND,$(subst :, ,$(PATH)),uname)"

########################################

override COMPOSER_VERSION_CURRENT	:= v2.0.final
override COMPOSER_BASENAME		:= Composer
override COMPOSER_FULLNAME		:= $(COMPOSER_BASENAME) CMS $(COMPOSER_VERSION_CURRENT)

ifneq ($(wildcard $(COMPOSER_DIR).git),)
override COMPOSER_GITREPO		?= $(COMPOSER_DIR).git
else ifneq ($(wildcard $(COMPOSER_DIR)/.git),)
override COMPOSER_GITREPO		?= $(COMPOSER_DIR)/.git
else
override COMPOSER_GITREPO		?= https://github.com/garybgenett/composer.git
endif

override COMPOSER_VERSION		?= $(COMPOSER_VERSION_CURRENT)
override COMPOSER_ESCAPES		?= 1

################################################################################

override MAKEFILE			:= Makefile
override MAKEFLAGS			:= --no-builtin-rules --no-builtin-variables --jobs=1

override COMPOSER_STAMP			?= .composed
override COMPOSER_CSS			?= composer.css

override COMPOSER_EXT			?= md
override COMPOSER_ART			:= artifacts
override COMPOSER_IMG			:= png
override COMPOSER_FILES			?=
#>	$(MAKEFILE) \
#>	*.$(COMPOSER_EXT) \
#>	*.$(COMPOSER_IMG) \
#>	*.css

########################################

# have to keep these around for a bit, after changing the names of them
$(if $(DCSS),$(eval override		CSS ?= $(DCSS)))
$(if $(NAME),$(eval override		TTL ?= $(NAME)))
$(if $(OPTS),$(eval override		OPT ?= $(OPTS)))

# provide long aliases for option variables
$(if $(c_debug),$(eval override		COMPOSER_DEBUGIT ?= $(c_debug)))
$(if $(c_type),$(eval override		TYPE ?= $(c_type)))
$(if $(c_base),$(eval override		BASE ?= $(c_base)))
$(if $(c_list),$(eval override		LIST ?= $(c_list)))
$(if $(c_css),$(eval override		CSS ?= $(c_css)))
$(if $(c_title),$(eval override		TTL ?= $(c_title)))
$(if $(c_contents),$(eval override	TOC ?= $(c_contents)))
$(if $(c_level),$(eval override		LVL ?= $(c_level)))
$(if $(c_margin),$(eval override	MGN ?= $(c_margin)))
$(if $(c_font),$(eval override		FNT ?= $(c_font)))
$(if $(c_options),$(eval override	OPT ?= $(c_options)))

# provide short aliases for option variables
$(if $(V),$(eval override		COMPOSER_DEBUGIT ?= $(V)))
$(if $(T),$(eval override		TYPE ?= $(T)))
$(if $(B),$(eval override		BASE ?= $(B)))
$(if $(L),$(eval override		LIST ?= $(L)))
$(if $(s),$(eval override		CSS ?= $(s)))
$(if $(t),$(eval override		TTL ?= $(t)))
$(if $(c),$(eval override		TOC ?= $(c)))
$(if $(l),$(eval override		LVL ?= $(l)))
$(if $(m),$(eval override		MGN ?= $(m)))
$(if $(f),$(eval override		FNT ?= $(f)))
$(if $(o),$(eval override		OPT ?= $(o)))

# set defaults values if not defined
override TYPE				?= html
override BASE				?= README
override LIST				?= $(BASE).$(COMPOSER_EXT)

override CSS				?= $(call COMPOSER_FIND,$(dir $(MAKEFILE_LIST)),$(COMPOSER_CSS))
override TTL				?=
override TOC				?=
override LVL				?= 2
override MGN				?= 0.8in
override FNT				?= 10pt
override OPT				?=

################################################################################

override ~				:= "'$$'"
override MARKER				:= >>
override DIVIDE				:= ::
override NULL				:=
override define NEWLINE			=
$(NULL)
$(NULL)
endef

########################################

override COMPOSER_TARGET		:= compose
override COMPOSER_PANDOC		:= pandoc
override RUNMAKE			:= $(MAKE) --makefile "$(COMPOSER_SRC)"
override COMPOSE			:= $(RUNMAKE) $(COMPOSER_TARGET)
override MAKEDOC			:= $(RUNMAKE) $(COMPOSER_PANDOC)

override MAKE_DB			:= .make_database
override LISTING			:= .all_targets
override LISTING_VAR			:= .ALL_TARGETS

override NOTHING			:= NULL

override HELPOUT			:= usage
override HELPALL			:= help

override DEBUGIT			:= debug
override TARGETS			:= targets

override EXAMPLE			:= template
override TESTING			:= test
override INSTALL			:= install
override REPLICA			:= clone
override UPGRADE			:= update

override ALLOFIT			:= world
override FETCHIT			:= fetch
override FETCHGO			:= $(FETCHIT)first
override FETCHNO			:= no$(FETCHIT)
override STRAPIT			:= bootstrap
override BUILDIT			:= build
override CHECKIT			:= check
override TIMERIT			:= times
override SHELLIT			:= shell

override CONVICT			:= _commit
override RELEASE			:= _release
override DISTRIB			:= _dist

override DOITALL			:= all
override CLEANER			:= clean
override WHOWHAT			:= whoami
override SETTING			:= settings
override SUBDIRS			:= subdirs
override PRINTER			:= print

override COMPOSER_ABSPATH		:= $(~)(abspath $(~)(dir $(~)(lastword $(~)(MAKEFILE_LIST))))
override COMPOSER_TEACHER		:= $(~)(abspath $(~)(COMPOSER_ABSPATH)/../$(MAKEFILE))
override COMPOSER_ALL_REGEX		:= [a-zA-Z0-9][a-zA-Z0-9_.-]+
override COMPOSER_CMT_REGEX		:=            [a-zA-Z0-9_.-]{10}

ifeq ($(COMPOSER_TARGETS),)
ifneq ($(COMPOSER),$(COMPOSER_SRC))
override COMPOSER_TARGETS		:= $(shell $(SED) -n "s|^($(COMPOSER_ALL_REGEX))[:].*$$|\1|gp" "$(COMPOSER_SRC)")
else
override COMPOSER_TARGETS		?= $(BASE)
endif
endif

override COMPOSER_SUBDIRS		?=
override COMPOSER_DEPENDS		?=
override COMPOSER_DEBUGIT		?=
override COMPOSER_TESTING		?=

override TESTING_DIR			:= $(COMPOSER_DIR)/$(TESTING).dir

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
override TYPE_TEXT			:= text
override TYPE_LINT			:= $(INPUT)

#WORKING: synchronize with the above, and replace throughout...
#WORKING: then start using these in makefiles instead of plain "html, pdf, docx, etc.", both in here and personal archives...
override EXTN_PRES			:= $(TYPE_PRES).$(TYPE_HTML)
override EXTN_SHOW			:= $(TYPE_SHOW).$(TYPE_HTML)
override EXTN_TEXT			:= txt
override EXTN_LINT			:= $(COMPOSER_EXT).out

ifeq ($(TYPE),$(TYPE_HTML))
override OUTPUT				:= html5
else ifeq ($(TYPE),$(TYPE_LPDF))
override OUTPUT				:= latex
else ifeq ($(TYPE),$(TYPE_PRES))
override OUTPUT				:= revealjs
override EXTENSION			:= $(EXTN_PRES)
else ifeq ($(TYPE),$(TYPE_SHOW))
override OUTPUT				:= slidy
override EXTENSION			:= $(EXTN_SHOW)
else ifeq ($(TYPE),$(TYPE_TEXT))
override OUTPUT				:= plain
override EXTENSION			:= $(EXTN_TEXT)
else ifeq ($(TYPE),$(TYPE_LINT))
override EXTENSION			:= $(EXTN_LINT)
endif

override HTML_DESC			:= HTML: HyperText Markup Language
override LPDF_DESC			:= PDF: Portable Document Format
override PRES_DESC			:= HTML/JS Presentation: Reveal.js
override SHOW_DESC			:= HTML/JS Slideshow: W3C Slidy2
override DOCX_DESC			:= DocX: Microsoft Office Open XML
override EPUB_DESC			:= ePUB: Electronic Publication
override TEXT_DESC			:= Plain Text (well-formatted)
override LINT_DESC			:= Pandoc Markdown (for testing)

########################################

#WORK
# https://stackoverflow.com/questions/3828606/vim-markdown-folding
# https://gist.github.com/vim-voom/1035030
# http://vimcasts.org/episodes/writing-a-custom-fold-expression
# https://pygospasprofession.wordpress.com/2013/07/10/markdown-and-vim
# http://www.macworld.com/article/1161549/forget_fancy_formatting_why_plain_text_is_best.html
#WORK
# https://github.com/nelstrom/vim-markdown-folding
# https://github.com/tpope/vim-markdown
# https://github.com/hallison/vim-markdown
# https://github.com/plasticboy/vim-markdown
#WORK
# https://github.com/jgm/yst
# http://hackage.haskell.org/package/gitit
#WORK
# https://github.com/jbt/markdown-editor/blob/master/LICENSE (license: ISC)
# https://github.com/jbt/markdown-editor
override MDEDITOR_CMT			:= d4561e977360186c931f3efe91ca43cc5fda6143
override MDEDITOR_SRC			:= https://github.com/jbt/markdown-editor.git
override MDEDITOR_DST			:= $(COMPOSER_DIR)/markdown-editor

# https://github.com/simov/markdown-viewer/blob/master/LICENSE (license: MIT)
# https://github.com/simov/markdown-viewer
override MDVIEWER_CMT			:= 4e9e49819d9b183c1aea6fc17c40501b6e89bfc3
override MDVIEWER_SRC			:= https://github.com/simov/markdown-viewer.git
override MDVIEWER_DST			:= $(COMPOSER_DIR)/markdown-viewer
#>>>override MDVIEWER_CSS		:= $(MDVIEWER_DST)/themes/screen.css
#>>>override MDVIEWER_CSS		:= $(MDVIEWER_DST)/themes/markdown-alt.css
#>>>override MDVIEWER_CSS		:= $(MDVIEWER_DST)/themes/markedapp-byword.css
#>>>override MDVIEWER_CSS		:= $(MDVIEWER_DST)/themes/markdown9.css
override MDVIEWER_CSS			:= $(MDVIEWER_DST)/themes/markdown7.css
#>>>override MDVIEWER_CSS_ALT			:= $(MDVIEWER_DST)/themes/solarized-dark.css
override MDVIEWER_CSS_ALT		:= $(MDVIEWER_DST)/themes/solarized-light.css

#WORK: this can go, completely; remove from rest of file, especially $(UPGRADE)
#WORK (license: WORK)
#WORK
override MARKDOWN_CMT			:= e6cae3923202fa6da01f52143bf71f0f4865d0f9
override MARKDOWN_SRC			:= https://github.com/markdowncss/markdowncss.github.io.git
override MARKDOWN_DST			:= $(COMPOSER_DIR)/markdown-css
override MARKDOWN_CSS			:= $(MARKDOWN_DST)/WORK.css

# https://github.com/hakimel/reveal.js/blob/master/LICENSE (license: BSD)
# https://github.com/hakimel/reveal.js
override REVEALJS_CMT			:= 3.1.0
override REVEALJS_SRC			:= https://github.com/hakimel/reveal.js.git
override REVEALJS_DST			:= $(COMPOSER_DIR)/revealjs
#>override REVEALJS_CSS			:= $(REVEALJS_DST)/css/theme/black.css
override REVEALJS_CSS			:= $(COMPOSER_DIR)/$(COMPOSER_ART)/revealjs.css

# http://www.w3.org/Consortium/Legal/copyright-software (license: MIT)
# http://www.w3.org/Talks/Tools/Slidy2/Overview.html#%286%29
override W3CSLIDY_SRC			:= http://www.w3.org/Talks/Tools/Slidy2/slidy.zip
override W3CSLIDY_DST			:= $(COMPOSER_DIR)/slidy/Slidy2
override W3CSLIDY_CSS			:= $(W3CSLIDY_DST)/styles/slidy.css

override _CSS				:= $(MDVIEWER_CSS)
#WORK : document!
ifeq ($(CSS),css_alt)
override _CSS				:= $(MDVIEWER_CSS_ALT)
else ifneq ($(wildcard $(CSS)),)
override _CSS				:= $(CSS)
else ifeq ($(OUTPUT),revealjs)
override _CSS				:= $(REVEALJS_CSS)
else ifeq ($(OUTPUT),slidy)
override _CSS				:= $(W3CSLIDY_CSS)
endif

#WORKING
#	pandoc --from docx --to markdown --extract-media=README.markdown.files --track-changes=all --output=README.markdown README.docx ; vdiff README.md.out README.markdown
#	--from "docx" --track-changes="all"
#	--from "docx|epub" --extract-media="[...]"
#WORKING
#	--default-image-extension="png"?
#	--highlight-style="kate"?
#	--incremental?
#
#	--include-in-header="[...]" --include-before-body="[...]" --include-after-body="[...]"
#	--email-obfuscation="[...]"
#	--epub-metadata="[...]" --epub-cover-image="[...]" --epub-embed-font="[...]"
#
#WORKING : add a way to add additional arguments, like: --variable=fontsize=28pt
#	--variable="fontsize=[...]"
#	--variable="theme=[...]"
#	--variable="transition=[...]"
#	--variable="links-as-notes=[...]"
#	--variable="lof=[...]"
#	--variable="lot=[...]"
#WORKING
#	implicit_header_references
#	fenced_code_attributes
#WORKING : http://10.255.255.254/zactive/coding/composer/Pandoc_Manual.html#fenced-code-blocks
#WORKING : document effects of $TOC and $LVL!
#WORK --chapters has been removed. Use --top-level-division=chapter instead.
#WORK --epub-stylesheet has been removed. Use --css instead.
#WORK --latex-engine has been removed.  Use --pdf-engine instead.
#WORK --normalize has been removed.  Normalization is now automatic.
#WORK --smart/-S has been removed.  Use +smart or -smart extension instead.
override PANDOC_EXTENSIONS		:= +smart
override PANDOC_OPTIONS			:= $(strip \
	\
	--self-contained \
	--standalone \
	\
	--title-prefix="$(TTL)" \
	--output="$(BASE).$(EXTENSION)" \
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
	--columns="80" \
	--css="$(_CSS)" \
	\
	--pdf-engine="pdflatex" \
	--variable="geometry=margin=$(MGN)" \
	--variable="fontsize=$(FNT)" \
	--variable="revealjs-url=$(REVEALJS_DST)" \
	--variable="slidy-url=$(W3CSLIDY_DST)" \
	\
	--listings \
	\
	$(OPT) \
	$(LIST) \
)
#WORK	--latex-engine="pdflatex" => https://github.com/wkhtmltopdf/wkhtmltopdf

#>	--latex-engine="pdflatex" \
#>	--latex-engine="xelatex" \
#>	--variable="geometry=top=$(MGN)" \
#>	--variable="geometry=bottom=$(MGN)" \
#>	--variable="geometry=left=$(MGN)" \
#>	--variable="geometry=right=$(MGN)" \

########################################

#WORKING:NOW : need some default content
override SITE_SOURCE			?= $(TESTING_DIR)
override SITE_PUBLIC			?= $(SITE_SOURCE)/.public
override SITE_SEARCH			?= 1

#WORKING:NOW : need sensible defaults
override SITE_TITLE			?= "$(COMPOSER_FULLNAME): Hexo"
override SITE_SUBTITLE			?= a simple proof of concept
override SITE_DESCRIPTION		?= a brief summary
override SITE_EXCERPT			?= Please expand on that...
override SITE_AUTHOR			?= Gary B. Genett
override SITE_LANGUAGE			?= en
override SITE_TIMEZONE			?= US/Pacific

#WORKING:NOW : need sensible defaults
override SITE_GOOGLEPLUS		?= https://plus.google.com/$(COMPOSER_BASENAME)
override SITE_FACEBOOK			?= https://www.facebook.com/$(COMPOSER_BASENAME)
override SITE_LINKEDIN			?= https://www.linkedin.com/$(COMPOSER_BASENAME)
override SITE_TWITTER			?= https://twitter.com/$(COMPOSER_BASENAME)
override SITE_GITHUB			?= https://github.com/$(COMPOSER_BASENAME)

#WORKING:NOW : need sensible defaults
override SITE_GIT_REPO			?= git@github.com:garybgenett/garybgenett.net.git
override SITE_ANALYTICS_ID		?=
override SITE_URL			?= http://0.0.0.0:4000
override SITE_ROOT			?=
override SITE_SIDEBAR			?= right
override SITE_PERMALINK			?= :year/:month/:day/:title/
override SITE_DATE_FORMAT		?= YYYY-MM-DD
override SITE_TIME_FORMAT		?= HH:mm:ss
override SITE_FEED_TYPE			?= atom
override SITE_PER_PAGE			?= 10

override SITE_SIZE_BANNER		?= 128px
override SITE_SIZE_LOGO			?= 32px
override SITE_SIZE_SUBTITLE		?= 16px
override SITE_SIZE_MOBLE_NAV		?= 256px

#WORKING:NOW : need to fix color of search/share boxes
override SITE_COLOR_BACKGROUND		?= \#202020
override SITE_COLOR_BACKGROUND_BLOCK	?= \#404040
override SITE_COLOR_BACKGROUND_FOOTER	?= \#000000
override SITE_COLOR_BACKGROUND_MOBILE	?= \#000000
override SITE_COLOR_BACKGROUND_WIDGET	?= \#404040
override SITE_COLOR_BORDER		?= \#808080
override SITE_COLOR_BORDER_WIDGET	?= \#808080
override SITE_COLOR_SHADOW_BLOCK	?= \#004000
override SITE_COLOR_SHADOW_TEXT		?= \#004000
override SITE_COLOR_TEXT_DEFAULT	?= \#f0f0f0
override SITE_COLOR_TEXT_GREY		?= \#808080
override SITE_COLOR_TEXT_LINK		?= \#00f000
override SITE_COLOR_TEXT_SIDEBAR	?= \#000000

#WORKING:NOW : need sensible defaults
override SITE_WIDGETS_ARCHIVES		?= Archives
override SITE_WIDGETS_CATEGORIES	?= Categories
override SITE_WIDGETS_RECENTS		?= Recents
override SITE_WIDGETS_TAGS		?= Tags
override SITE_WIDGETS_TAGS_CLOUD	?= Tag Cloud
override SITE_WIDGETS			?= \
	recent_posts \
	tagcloud \
	tag \
	category \
	archive

#WORKING:NOW : need sensible defaults
override SITE_MENU			?= \
	Home| \
	Testing|Test-page \
	$(SITE_WIDGETS_ARCHIVES)|archives

#WORKING:NOW : need sensible defaults
#WORKING:NOW : need to establish what, exactly, this does
override SITE_SKIPS			?= \
	CNAME

override SITE_FOOTER_APPEND		?= \
	<br /><br /> \
	<a rel=\"author\" href=\"http://www.garybgenett.net\">					<img src=\"http://www.garybgenett.net/favicon.png\"					alt=\"Gary B. Genett\"	style=\"border:0; width:31px; height:31px;\"/></a> \
	<a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-nd/3.0/us/\">	<img src=\"http://i.creativecommons.org/l/by-nc-nd/3.0/us/88x31.png\"			alt=\"CC License\"	style=\"border:0; width:88px; height:31px;\"/></a> \
	<a href=\"http://validator.w3.org/check/referer\">					<img src=\"http://www.w3.org/Icons/valid-xhtml11-blue\"					alt=\"Valid HTML\"	style=\"border:0; width:88px; height:31px;\"/></a> \
	<a href=\"http://jigsaw.w3.org/css-validator/check/referer\">				<img src=\"http://www.w3.org/Icons/valid-css2-blue\"					alt=\"Valid CSS\"	style=\"border:0; width:88px; height:31px;\"/></a> \
	<br /> \
	<a href=\"https://github.com/garybgenett/composer\">					<img src=\"https://raw.githubusercontent.com/garybgenett/composer/devel/icon.png\"	alt=\"Composer\"	style=\"border:0; width:31px; height:31px;\"/></a> \
	<a href=\"http://www.vim.org\">								<img src=\"http://www.vim.org/images/vim_small.gif\"					alt=\"Vim\"		style=\"border:0; width:31px; height:31px;\"/></a> \
	<a href=\"http://git-scm.com\">								<img src=\"https://git.wiki.kernel.org/images-git/d/df/FrontPage%24git-logo.png\"	alt=\"Git\"		style=\"border:0; width:72px; height:27px;\"/></a>

# https://github.com/hexojs/hexo/blob/master/LICENSE (license: custom = as-is)
# https://github.com/hexojs/hexo
override HEXO_ROOT			:= $(COMPOSER_DIR)/hexo
override HEXO_MODULES			:= $(HEXO_ROOT)/node_modules
#> https://github.com/hexojs/hexo/issues/1705
#>	https://github.com/hexojs/hexo/commit/58971dc460c79debbb68f93a98911660d5585fc3
override HEXO_VER			:= 3.2.0-beta.2
override HEXO_CMT			:= 58971dc460c79debbb68f93a98911660d5585fc3
#>override HEXO_VER			:= 3.1.1
#>override HEXO_CMT			:= $(HEXO_VER)
override HEXO_SRC			:= git://github.com/hexojs/hexo.git
override HEXO_DST			:= $(HEXO_MODULES)/hexo
# https://github.com/hexojs/hexo-theme-landscape/blob/master/LICENSE (license: custom = as-is)
# https://github.com/hexojs/hexo-theme-landscape
override HEXO_THEME			:= landscape
override HEXO_THEME_CMT			:= ec0e2ce1690eb993ce664f4fb6b91df47a106848
override HEXO_THEME_SRC			:= git://github.com/hexojs/hexo-theme-landscape.git
override HEXO_THEME_DST			:= $(HEXO_ROOT)/themes/$(HEXO_THEME)

override HEXO_MODULES_LIST		:= \
	hexo|$(HEXO_VER) \
	hexo-cli|0.1.9 \
	hexo-util|0.3.0 \
	\
	hexo-generator-archive|0.1.4 \
	hexo-generator-category|0.1.3 \
	hexo-generator-index|0.2.0 \
	hexo-generator-tag|0.1.2 \
	hexo-renderer-ejs|0.1.1 \
	hexo-renderer-marked|0.2.8 \
	hexo-renderer-stylus|0.3.0 \
	hexo-server|0.1.3 \
	\
	hexo-deployer-git|0.0.4 \
	hexo-generator-feed|1.0.3 \
	hexo-generator-sitemap|1.0.1 \
	hexo-pagination|0.0.2

override HEXO_CLI			= cd "$(HEXO_ROOT)"	&& $(BUILD_ENV_PANDOC) $(NODE) "$(HEXO_DST)/bin/hexo" $(1) --debug $(2)
override HEXO_NPM			= cd "$(HEXO_ROOT)"	&& $(BUILD_ENV_PANDOC) $(NODE) $(NPM) --global --cache "$(COMPOSER_STORE)/npm" $(1)

override define HEREDOC_HEXO_CONFIG	=
title:		$(SITE_TITLE)
subtitle:	$(SITE_SUBTITLE)
description:	$(SITE_DESCRIPTION)
author:		$(SITE_AUTHOR)
language:	$(SITE_LANGUAGE)
timezone:	$(SITE_TIMEZONE)

url:		$(SITE_URL)$(SITE_ROOT)
root:		$(SITE_ROOT)/
permalink:	$(SITE_PERMALINK)
date_format:	$(SITE_DATE_FORMAT)
time_format:	$(SITE_TIME_FORMAT)
per_page:	$(SITE_PER_PAGE)

theme:		$(HEXO_THEME)
#WORKING:NOW source_dir:	$(SITE_SOURCE)
#WORKING:NOW public_dir:	$(SITE_PUBLIC)
skip_render: $(foreach FILE,$(SITE_SKIPS),$(NEWLINE)	- $(FILE))

sitemap:
	path:	$(SITE_ROOT)/sitemap.xml

feed:
	path:	$(SITE_ROOT)/$(SITE_FEED_TYPE).xml
	type:	$(SITE_FEED_TYPE)
	limit:	$(SITE_PER_PAGE)

deploy:
	repo:	$(SITE_GIT_REPO)
	type:	git
endef

override define HEREDOC_HEXO_THEME	=
favicon:	$(SITE_ROOT)/favicon.png
rss:		$(SITE_ROOT)/$(SITE_FEED_TYPE).xml

url_googleplus:	$(SITE_GOOGLEPLUS)
url_facebook:	$(SITE_FACEBOOK)
url_linkedin:	$(SITE_LINKEDIN)
url_twitter:	$(SITE_TWITTER)
url_github:	$(SITE_GITHUB)

excerpt_link:	$(SITE_EXCERPT)
sidebar:	$(SITE_SIDEBAR)
fancybox:	true

menu: $(foreach FILE,$(SITE_MENU),$(NEWLINE)	$(subst |,: ,$(FILE)))

widgets: $(foreach FILE,$(SITE_WIDGETS),$(NEWLINE)	- $(FILE))

google_analytics:
	siteid:	$(SITE_ANALYTICS_ID)
	enable:	true
endef

override SITE_SEARCH_SCRIPT		:= <script>function search_submit() { window.location.href = \"https://duckduckgo.com?kp=-1\&kz=-1\&kv=1\&kae=d\&ko=1\&q=site:\1 + config.url + \1 \" + document.search_form.q.value; }</script>
override SITE_SEARCH_FORM		:= action=\"javascript:search_submit();\" name=\"search_form\"

#WORKING:NOW : http://jr0cket.co.uk/hexo/
# http://navaneeth.me/font-awesome-icons-css-content-values
#>override SITE_SOCIAL_ICON_googleplus	:= f0d5
#>override SITE_SOCIAL_ICON_facebook	:= f09a
#>override SITE_SOCIAL_ICON_linkedin	:= f0e1
#>override SITE_SOCIAL_ICON_twitter	:= f099
#>override SITE_SOCIAL_ICON_github	:= f09b
#>override SITE_SOCIAL_ICON_rss		:= f09e
override SITE_SOCIAL_ICON_googleplus	:= f0d4
override SITE_SOCIAL_ICON_facebook	:= f082
override SITE_SOCIAL_ICON_linkedin	:= f08c
override SITE_SOCIAL_ICON_twitter	:= f081
override SITE_SOCIAL_ICON_github	:= f092
override SITE_SOCIAL_ICON_rss		:= f143
override SITE_SOCIAL_ICON		:= $(foreach FILE,googleplus facebook linkedin twitter github,\n\#nav-$(FILE)-link\n\t\&:before\n\t\tcontent: \"\\\\$(call SITE_SOCIAL_ICON_$(FILE))\"\n\n)
override SITE_SOCIAL_LINK		:= $(foreach FILE,googleplus facebook linkedin twitter github,<% if (theme.url_$(FILE)){ %><a id=\"nav-$(FILE)-link\" class=\"nav-icon\" href=\"<%- theme.url_$(FILE) %>\" target=\"_blank\"></a><% } %>)

override define HEXO_PACKAGE_JSON	=
	$(SED) -i \
		$(foreach FILE,$(HEXO_MODULES_LIST),\
			-e "s|([\"]$(word 1,$(subst |, ,$(FILE)))[\"][:][ ][\"]).*([\"])|\1$(word 2,$(subst |, ,$(FILE)))\2|g" \
		) \
		-e "s|([\"]dependencies[\"][:][ ][{])$$|\1$(foreach FILE,$(HEXO_MODULES_LIST),\
			\n\"$(word 1,$(subst |, ,$(FILE)))\": \"$(word 2,$(subst |, ,$(FILE)))\", \
		)|g" \
		"$(1)"
endef

.PHONY: HEXO_WORK_INIT
HEXO_WORK_INIT: .set_title-HEXO_WORK_INIT
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_1)
	@$(call GIT_REPO,$(HEXO_DST),$(HEXO_SRC),$(HEXO_CMT))
	@$(call GIT_REPO,$(HEXO_THEME_DST),$(HEXO_THEME_SRC),$(HEXO_THEME_CMT))
	@$(call HEXO_PACKAGE_JSON,$(HEXO_DST)/package.json)
	@$(CP) "$(HEXO_DST)/package.json" "$(HEXO_ROOT)/package.json"
ifneq ($(COMPOSER_TESTING),)
	@$(ECHO) "$(_C)"; \
		$(SED) -n \
			"/dependencies/,/}/p" \
			"$(HEXO_MODULES)/hexo-cli/assets/package.json"; \
		$(ECHO) "$(_D)"
	@$(call GIT_RUN,$(HEXO_DST),-c core.pager= diff "./package.json")
	@$(call HEXO_NPM,outdated $(shell \
		$(SED) -n "/dependencies/,/}/p" "$(HEXO_DST)/package.json" \
		| $(SED) -e "/[Dd]ependencies/d" -e "/}/d" -e "s|[:].*$$||g" -e "s|[\"]||g" \
	))
else
	@$(SED) -i \
		-e "s|\^||g" \
		"$(HEXO_ROOT)/package.json"
	@$(call HEXO_NPM,install)
	@$(call HEXO_NPM,update)
	@$(call HEXO_NPM,prune)
	@$(call HEXO_CLI,init)
	@$(CP) "$(HEXO_MODULES)/hexo-cli/assets/package.json" "$(HEXO_ROOT)/package.json"
	@$(call HEXO_PACKAGE_JSON,$(HEXO_ROOT)/package.json)
ifneq ($(SITE_SEARCH),)
	@$(SED) -i \
		-e "s|(.)([<]form[ ])action[=][\"][^\"]+[\"][ ]method[=][\"][^\"]+[\"]|\1$(SITE_SEARCH_SCRIPT)\2$(SITE_SEARCH_FORM)|g" \
		-e "/sitesearch/d" \
		"$(HEXO_DST)/lib/plugins/helper/search_form.js"
endif
#WORKING:NOW
	@$(LN) "$(HEXO_THEME_DST)/languages/default.yml" "$(HEXO_THEME_DST)/languages/en.yml"
#WORKING:NOW
endif

.PHONY: HEXO_WORK_DONE
HEXO_WORK_DONE: .set_title-HEXO_WORK_DONE
	@$(call GIT_RUN,$(HEXO_THEME_DST),reset --hard)
	@$(call DO_HEREDOC,$(call HEREDOC_HEXO_CONFIG))	>"$(HEXO_ROOT)/_config.yml"
	@$(call DO_HEREDOC,$(call HEREDOC_HEXO_THEME))	>"$(HEXO_THEME_DST)/_config.yml"
	@$(SED) -i \
		-e "s|^(banner-url[ ][=]).*$$|\1							\"$(SITE_ROOT)/banner.jpg\"|g" \
		$(if $(SITE_SIZE_BANNER),-e "s|^(banner-height[ ][=]).*$$|\1				$(SITE_SIZE_BANNER)|g") \
		$(if $(SITE_SIZE_LOGO),-e "s|^(logo-size[ ][=]).*$$|\1					$(SITE_SIZE_LOGO)|g") \
		$(if $(SITE_SIZE_SUBTITLE),-e "s|^(subtitle-size[ ][=]).*$$|\1				$(SITE_SIZE_SUBTITLE)|g") \
		$(if $(SITE_SIZE_MOBILE_NAV),-e "s|^(mobile-nav-width[ ][=]).*$$|\1			$(SITE_SIZE_MOBILE_NAV)|g") \
		$(if $(SITE_COLOR_BACKGROUND),-e "s|^(color-background[ ][=]).*$$|\1			$(SITE_COLOR_BACKGROUND)|g") \
		$(if $(SITE_COLOR_BACKGROUND_FOOTER),-e "s|^(color-footer-background[ ][=]).*$$|\1	$(SITE_COLOR_BACKGROUND_FOOTER)|g") \
		$(if $(SITE_COLOR_BACKGROUND_MOBILE),-e "s|^(color-mobile-nav-background[ ][=]).*$$|\1	$(SITE_COLOR_BACKGROUND_MOBILE)|g") \
		$(if $(SITE_COLOR_BACKGROUND_WIDGET),-e "s|^(color-widget-background[ ][=]).*$$|\1	$(SITE_COLOR_BACKGROUND_WIDGET)|g") \
		$(if $(SITE_COLOR_BORDER),-e "s|^(color-border[ ][=]).*$$|\1				$(SITE_COLOR_BORDER)|g") \
		$(if $(SITE_COLOR_BORDER_WIDGET),-e "s|^(color-widget-border[ ][=]).*$$|\1		$(SITE_COLOR_BORDER_WIDGET)|g") \
		$(if $(SITE_COLOR_TEXT_DEFAULT),-e "s|^(color-default[ ][=]).*$$|\1			$(SITE_COLOR_TEXT_DEFAULT)|g") \
		$(if $(SITE_COLOR_TEXT_GREY),-e "s|^(color-grey[ ][=]).*$$|\1				$(SITE_COLOR_TEXT_GREY)|g") \
		$(if $(SITE_COLOR_TEXT_LINK),-e "s|^(color-link[ ][=]).*$$|\1				$(SITE_COLOR_TEXT_LINK)|g") \
		$(if $(SITE_COLOR_TEXT_SIDEBAR),-e "s|^(color-sidebar-text[ ][=]).*$$|\1		$(SITE_COLOR_TEXT_SIDEBAR)|g") \
		"$(HEXO_THEME_DST)/source/css/_variables.styl"
	@$(SED) -i \
		-e "s|NULL|NULL|g" \
		$(if $(SITE_COLOR_BACKGROUND_BLOCK),-e "s|(background[:]).*$$|\1			$(SITE_COLOR_BACKGROUND_BLOCK)|g") \
		$(if $(SITE_COLOR_SHADOW_BLOCK),-e "s|(box[-]shadow[:][ ]1px[ ]2px[ ]3px[ ]).*$$|\1	$(SITE_COLOR_SHADOW_BLOCK)|g") \
		$(if $(SITE_COLOR_SHADOW_TEXT),-e "s|(text[-]shadow[:][ ]0[ ]1px[ ]).*$$|\1		$(SITE_COLOR_SHADOW_TEXT)|g") \
		"$(HEXO_THEME_DST)/source/css/_extend.styl"
	@$(SED) -i \
		$(if $(SITE_COLOR_BACKGROUND_BLOCK),-e "s|(background[:][ ])[#].*$$|\1			$(SITE_COLOR_BACKGROUND_BLOCK)|g") \
		"$(HEXO_THEME_DST)/source/css/_partial/header.styl" \
		"$(HEXO_THEME_DST)/source/css/_partial/article.styl"
	@$(SED) -i \
		-e "s|NULL|NULL|g" \
		$(if $(SITE_COLOR_SHADOW_TEXT),-e "s|(text[-]shadow[:][ ]0[ ]1px[ ]).*$$|\1		$(SITE_COLOR_SHADOW_TEXT)|g") \
		"$(HEXO_THEME_DST)/source/css/_partial/sidebar-aside.styl"
	@$(SED) -i \
		-e "s|NULL|NULL|g" \
		$(if $(SITE_WIDGETS_ARCHIVES),-e "s|Archives|						$(SITE_WIDGETS_ARCHIVES)|g") \
		$(if $(SITE_WIDGETS_CATEGORIES),-e "s|Categories|					$(SITE_WIDGETS_CATEGORIES)|g") \
		$(if $(SITE_WIDGETS_RECENTS),-e "s|Recent Posts|					$(SITE_WIDGETS_RECENTS)|g") \
		$(if $(SITE_WIDGETS_TAGS),-e "s|Tags|							$(SITE_WIDGETS_TAGS)|g") \
		$(if $(SITE_WIDGETS_TAGS_CLOUD),-e "s|Tag Cloud|					$(SITE_WIDGETS_TAGS_CLOUD)|g") \
		"$(HEXO_THEME_DST)/languages/default.yml"
	@$(SED) -i \
		-e "s|^([#]nav[-]rss[-]link)$$|$(SITE_SOCIAL_ICON)\1|g" \
		-e "s|f09e|$(SITE_SOCIAL_ICON_rss)|g" \
		"$(HEXO_THEME_DST)/source/css/_partial/header.styl"
	@$(SED) -i \
		-e "s|([<]nav[ ]id[=][\"]sub-nav[\"][>]).*$$|\1$(SITE_SOCIAL_LINK)|g" \
		"$(HEXO_THEME_DST)/layout/_partial/header.ejs"
	@$(SED) -i \
		-e "s|(Hexo[<][/]a[>])$$|\1$(SITE_FOOTER_APPEND)|g" \
		"$(HEXO_THEME_DST)/layout/_partial/footer.ejs"
#WORKING:NOW
	@$(RSYNC) --filter="-_/$(subst $(SITE_SOURCE),,$(SITE_PUBLIC))" --copy-links --delete "$(SITE_SOURCE)/" "$(HEXO_ROOT)/source"
#WORKING:NOW
#	@$(RM) -r "$(HEXO_ROOT)/public"
#	@ln -fsv "$(SITE_PUBLIC)" "$(HEXO_ROOT)/public"
#WORKING:NOW
	@$(call HEXO_CLI,clean)
#WORKING:NOW
	@$(call HEXO_CLI,generate)
#WORKING:NOW
	@$(RSYNC) --filter="-_/$(subst $(SITE_PUBLIC),,$(SITE_SOURCE))" --copy-links --delete "$(HEXO_ROOT)/public/" "$(SITE_PUBLIC)/"
#WORKING:NOW

#WORKING:NOW : server & deploy
.PHONY: HEXO_WORK_%
HEXO_WORK_%: .set_title-HEXO_WORK_%
	@$(call HEXO_CLI,$(*))

########################################

override COMPOSER_OTHER			?= $(COMPOSER_DIR)
override COMPOSER_ABODE			?= $(abspath $(COMPOSER_OTHER)/.home)
override COMPOSER_STORE			?= $(abspath $(COMPOSER_OTHER)/.sources)
override COMPOSER_TRASH			?= $(abspath $(COMPOSER_OTHER)/.tmp)
override COMPOSER_BUILD			?= $(abspath $(COMPOSER_OTHER)/build)

override BUILD_BRANCH			:= composer_$(BUILDIT)
override BUILD_LDLIB			:= $(COMPOSER_ABODE)/$(STRAPIT)
override BUILD_STRAP			:= $(COMPOSER_BUILD)/$(STRAPIT)
#WORKING : BUILD_FSFILE and BUILD_BINDIR are both probably overused at this point; need to reconcile with "macports/bin" at the least
override BUILD_FSFILE			:= etc/fstab
override BUILD_BINDIR			:= usr/bin

override BUILD_FETCH			?= 1
override BUILD_JOBS			?= 9
override BUILD_DIST			?=
override BUILD_PORT			?=

#>override BUILD_PLAT			:= Linux
#>override BUILD_ARCH			:= x86_64
override BUILD_PLAT			?= $(shell $(UNAME) -o)
override BUILD_ARCH			?= $(shell $(UNAME) -m)

override IS_CYGWIN			:=
ifeq ($(BUILD_PLAT),Cygwin)
override IS_CYGWIN			:= 1
endif

ifeq ($(BUILD_PLAT),GNU/Linux)
override BUILD_PLAT			:= Linux
else ifeq ($(BUILD_PLAT),Cygwin)
override BUILD_PLAT			:= Msys
endif

override BUILD_BITS			:= 32
ifeq ($(BUILD_ARCH),x86_64)
override BUILD_BITS			:= 64
endif

override COMPOSER_PROGS			?= $(abspath $(COMPOSER_OTHER)/bin/$(BUILD_PLAT))
override COMPOSER_PROGS_USE		?= 0

# thanks for the 'LANG' fix below: https://stackoverflow.com/questions/23370392/failed-installing-dependencies-with-cabal
#	found by: https://github.com/faylang/fay/issues/261
override LANG				?= en_US.UTF-8
override TERM				?= ansi
override CHOST				:=
override CFLAGS				:= -I$(COMPOSER_ABODE)/include -L$(COMPOSER_ABODE)/lib
override CPPFLAGS			:= -I$(COMPOSER_ABODE)/include
override LDFLAGS			:=                             -L$(COMPOSER_ABODE)/lib
override GHCFLAGS			:=	$(foreach FILE,$(CFLAGS),-optc$(FILE)) \
						$(foreach FILE,$(CPPFLAGS),-optP$(FILE)) \
						$(foreach FILE,$(LDFLAGS),-optl$(FILE))

#WORK : these belong in the sections below, but need to be here, so BUILD_PATH can be below to avoid all kinds of "chicken and egg" situations
override MACPORTS_DST			:= $(COMPOSER_ABODE)/macports
override MSYS_DST			:= $(COMPOSER_ABODE)/msys$(BUILD_BITS)

#WORKING : some kind of note about how BUILD_PATH is related to COMPOSER_BAT and COMPOSER_SH
override BUILD_PATH_MINGW		:=
override BUILD_PATH_SHELL		:=
ifeq ($(COMPOSER_PROGS_USE),1)
override BUILD_PATH			:= $(COMPOSER_ABODE)/.coreutils
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_PROGS)/$(BUILD_BINDIR)
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_ABODE)/$(BUILD_BINDIR)
else
override BUILD_PATH			:= $(COMPOSER_ABODE)/$(BUILD_BINDIR)
endif
override BUILD_PATH			:= $(BUILD_PATH):$(BUILD_STRAP)/$(BUILD_BINDIR)
ifeq ($(BUILD_PLAT),Darwin)
#WORKING:MACP
override BUILD_PATH			:= $(BUILD_PATH):$(MACPORTS_DST)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(MACPORTS_DST)/libexec/gnubin
endif
ifeq ($(BUILD_PLAT),Msys)
override BUILD_PATH_MINGW		:=               $(MSYS_DST)/mingw$(BUILD_BITS)/bin
override BUILD_PATH			:= $(BUILD_PATH):$(MSYS_DST)/$(BUILD_BINDIR)
endif
override BUILD_PATH			:= $(BUILD_PATH):$(PATH)
ifneq ($(COMPOSER_PROGS_USE),1)
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_ABODE)/.coreutils
override BUILD_PATH			:= $(BUILD_PATH):$(COMPOSER_PROGS)/$(BUILD_BINDIR)
endif
override BUILD_PATH_SHELL		:= $(BUILD_PATH)
ifeq ($(COMPOSER_PROGS_USE),0)
override BUILD_PATH			:= $(PATH)
endif
ifneq ($(IS_CYGWIN),)
override BUILD_PATH			:= $(PATH)
endif

#WORKING:NOW # thanks for the 'mfpmath' fix below: http://cboard.cprogramming.com/c-programming/151085-unknown-type-name-__m128-not-enabled.html
#WORKING:NOW : $(BUILD_PLAT),Darwin CFLAGS options
ifneq ($(BUILD_DIST),)
override BUILD_PORT			:= 1
ifeq ($(BUILD_PLAT),Linux)
override BUILD_PLAT			:= Linux
override BUILD_ARCH			:= i686
override BUILD_BITS			:= 32
override CHOST				:= $(BUILD_ARCH)-pc-linux-gnu
else ifeq ($(BUILD_PLAT),Darwin)
override BUILD_PLAT			:= Darwin
#WORKING:MACP
override BUILD_ARCH			:= x86_64
override BUILD_BITS			:= 64
override CHOST				:= $(BUILD_ARCH)-apple-darwin
else ifeq ($(BUILD_PLAT),Msys)
override BUILD_PLAT			:= Msys
override BUILD_ARCH			:= i686
override BUILD_BITS			:= 32
override CHOST				:= $(BUILD_ARCH)-pc-msys$(BUILD_BITS)
endif
#WORKING:MACP override CFLAGS_MOPTS			:= -m$(BUILD_BITS) -march=$(BUILD_ARCH) -mtune=generic -O1
override CFLAGS_MOPTS			:= $(if $(filter-out $(BUILD_PLAT),Darwin),-m$(BUILD_BITS) -march=$(BUILD_ARCH)) -mtune=generic -O1
override CFLAGS				:= $(CFLAGS) $(CFLAGS_MOPTS)
#WORKING:MACP $(if $(filter $(BUILD_PLAT),Darwin),-arch=$(BUILD_ARCH))
override GHCFLAGS			:= $(GHCFLAGS) \
						$(foreach FILE,$(CFLAGS_MOPTS),-optc$(FILE)) \
						$(foreach FILE,$(CFLAGS_MOPTS),-opta$(FILE))
endif

override LDLIB_LIBRARY_PATH		:= $(BUILD_LDLIB)/lib
override LDLIB_RUN_PATH			:= -Wl,-rpath,$(LDLIB_LIBRARY_PATH)
ifeq ($(BUILD_PLAT),Msys)
override LDLIB_RUN_PATH			:=
endif

override CFLAGS_LDLIB			:= -I$(BUILD_LDLIB)/include -L$(BUILD_LDLIB)/lib $(LDLIB_RUN_PATH)
override CPPFLAGS_LDLIB			:= -I$(BUILD_LDLIB)/include
override LDFLAGS_LDLIB			:=                          -L$(BUILD_LDLIB)/lib $(LDLIB_RUN_PATH)
override GHCFLAGS_LDLIB			:=	$(foreach FILE,$(CFLAGS_LDLIB),-optc$(FILE)) \
						$(foreach FILE,$(CPPFLAGS_LDLIB),-optP$(FILE)) \
						$(foreach FILE,$(LDFLAGS_LDLIB),-optl$(FILE))

override CFLAGS_LDLIB			:= $(CFLAGS_LDLIB) $(CFLAGS)
override CPPFLAGS_LDLIB			:= $(CPPFLAGS_LDLIB) $(CPPFLAGS)
override LDFLAGS_LDLIB			:= $(LDFLAGS_LDLIB) $(LDFLAGS)
override GHCFLAGS_LDLIB			:= $(GHCFLAGS_LDLIB) $(GHCFLAGS)

#WORKING:NOW : http://trac.haskell.org/haskell-platform/report/1?format=rss&USER=anonymous
#	http://trac.haskell.org/haskell-platform/ticket/216
#	"$(BUILD_PLAT),Darwin" doesn't like the "libiconv" that we build
#WORKING:NOW

#WORKING:NOW :: reverse this; should default to not having, and manually add in for the two cases where it is needed
override GHCFLAGS_SYSLIB_SUBST		= $(1)
ifeq ($(BUILD_PLAT),Darwin)
override GHCFLAGS			:= -optc-L/usr/lib -optl-L/usr/lib $(GHCFLAGS)
override GHCFLAGS_LDLIB			:= -optc-L/usr/lib -optl-L/usr/lib $(GHCFLAGS_LDLIB)
override GHCFLAGS_SYSLIB_SUBST		= $(if $(2),\
	$(subst --gcc-option="",,\
	$(subst --ld-option="",,\
	$(subst --ghc-option="",,\
	$(subst --ghc-option="-optc",,\
	$(subst --ghc-option="-optl",,\
	$(subst $(LDLIB_RUN_PATH),,\
	$(subst -optc-L/usr/lib,,\
	$(subst -optl-L/usr/lib,,\
	$(1))))))))),\
	$(1))
endif

#WORK : document licenses!
ifneq ($(BUILD_PLAT),Msys)
ifneq ($(BUILD_PORT),)
# prevent "chicken and egg" error, since this is before the "$(PATH_LIST)" section
override CC				:= "$(call COMPOSER_FIND,$(subst :, ,$(BUILD_PATH)),gcc)"
override LIBGCC				:=
ifneq ($(word 1,$(CC)),"")
override LIBGCC				:= \
	-static-libgcc \
	-static-libstdc++ \
	$(foreach FILE,gcc gcc_eh,-L$(dir $(shell $(CC) -print-file-name=lib$(FILE).a)) -l$(FILE))
override CFLAGS				:= $(CFLAGS) $(LIBGCC)
override LDFLAGS			:= $(LDFLAGS) $(LIBGCC)
override GHCFLAGS			:= $(GHCFLAGS) $(foreach FILE,$(LIBGCC),-optc$(FILE) -optl$(FILE)) $(patsubst -static-%,,$(LIBGCC))
endif
endif
endif

ifeq ($(BUILD_PLAT),Linux)
override GHC_PLAT			:= unknown-linux-deb7
else ifeq ($(BUILD_PLAT),Darwin)
ifeq ($(BUILD_ARCH),x86_64)
override GHC_PLAT			:= apple-darwin
else
override GHC_PLAT			:= apple-ios
endif
else ifeq ($(BUILD_PLAT),Msys)
override GHC_PLAT			:= unknown-mingw32
endif

override MSYS_ARCH			:= $(BUILD_ARCH)
override GHC_ARCH			:= $(BUILD_ARCH)
ifeq ($(BUILD_ARCH),i686)
override GHC_ARCH			:= i386
else ifeq ($(BUILD_ARCH),i386)
override MSYS_ARCH			:= i686
endif

# https://www.debian.org
# https://tracker.debian.org/debootstrap
# https://packages.debian.org/search?suite=stable&keywords=build-essential
# https://packages.debian.org/search?suite=stable&keywords=make
override DEBIAN_CMT			:= 1.0.66
override DEBIAN_SRC			:= git://anonscm.debian.org/d-i/debootstrap.git
override DEBIAN_ARCH			:= i386
override DEBIAN_SUITE			:= stable
override DEBIAN_LINUX_VERSION		:= 3.16.7
override DEBIAN_GLIBC_VERSION		:= 2.19
override DEBIAN_GCC_VERSION		:= 4.9.2
override DEBIAN_BINUTILS_VERSION	:= 2.25
override DEBIAN_MAKE_VERSION		:= 4.0

# http://www.funtoo.org
# http://www.funtoo.org/Generic_64
# http://www.funtoo.org/Generic_32
# http://www.funtoo.org/Core2_64
# http://www.funtoo.org/I686
override FUNTOO_DATE			:= 2015-07-15
override FUNTOO_TYPE			:= funtoo-stable
override FUNTOO_ARCH			:= x86-$(BUILD_BITS)bit
override FUNTOO_SARC			:= generic_$(BUILD_BITS)
#>override FUNTOO_SARC			:= core2_64
#>ifneq ($(BUILD_BITS),64)
#>override FUNTOO_SARC			:= i686
#>endif
override FUNTOO_SRC			:= http://build.funtoo.org/$(FUNTOO_TYPE)/$(FUNTOO_ARCH)/$(FUNTOO_SARC)/$(FUNTOO_DATE)/stage3-$(FUNTOO_SARC)-$(FUNTOO_TYPE)-$(FUNTOO_DATE).tar.xz
override FUNTOO_LINUX_VERSION		:= 3.19.3
override FUNTOO_GLIBC_VERSION		:= 2.20
override FUNTOO_GCC_VERSION		:= 4.9.2
override FUNTOO_BINUTILS_VERSION	:= 2.25
override FUNTOO_MAKE_VERSION		:= 4.1

# https://en.wikipedia.org/wiki/Linux_kernel#Maintenance
# https://en.wikipedia.org/wiki/GNU_C_Library#Version_history
override LINUX_MIN_VERSION		:= $(DEBIAN_LINUX_VERSION)
override LINUX_CUR_VERSION		:= $(FUNTOO_LINUX_VERSION)
override GLIBC_MIN_VERSION		:= $(DEBIAN_GLIBC_VERSION)
override GLIBC_CUR_VERSION		:= $(FUNTOO_GLIBC_VERSION)
override GCC_MIN_VERSION		:= $(DEBIAN_GCC_VERSION)
override GCC_CUR_VERSION		:= $(FUNTOO_GCC_VERSION)
override BINUTILS_MIN_VERSION		:= $(DEBIAN_BINUTILS_VERSION)
override BINUTILS_CUR_VERSION		:= $(FUNTOO_BINUTILS_VERSION)
#WORKING:NOW : roll over on 3.82?  remove from DEBIAN build in $(RELEASE)?
#>override MAKE_MIN_VERSION		:= $(DEBIAN_MAKE_VERSION)
override MAKE_MIN_VERSION		:= 3.82
#>override MAKE_CUR_VERSION		:= $(FUNTOO_MAKE_VERSION)
override MAKE_CUR_VERSION		:= 4.1

# https://www.macports.org (license: BSD)
# https://www.macports.org/install.php#source
# https://guide.macports.org/index.html#installing.macports.source.multiple
override MACPORTS_VER			:= 2.3.4
override MACPORTS_SRC			:= https://distfiles.macports.org/MacPorts/MacPorts-$(MACPORTS_VER).tar.gz
override MACPORTS_SRC_DST		:= $(COMPOSER_ABODE)/macports/MacPorts-$(MACPORTS_VER)
#WORK : this belongs here, but is above; see comment
#>override MACPORTS_DST			:= $(COMPOSER_ABODE)/macports

# http://sourceforge.net/p/msys2/code/ci/master/tree/COPYING3 (license: GPL, LGPL)
# http://sourceforge.net/projects/msys2
# http://sourceforge.net/p/msys2/wiki/MSYS2%20installation
# https://www.archlinux.org/groups
override MSYS_VER			:= 20150512
override MSYS_SRC			:= http://sourceforge.net/projects/msys2/files/Base/$(MSYS_ARCH)/msys2-base-$(MSYS_ARCH)-$(MSYS_VER).tar.xz
#WORK : this belongs here, but is above; see comment
#>override MSYS_DST			:= $(COMPOSER_ABODE)/msys$(BUILD_BITS)
#WORK : mintty - installed before bash?  cygwin-console-helper?
#WORK : cygpath - installed before bash?

# https://savannah.gnu.org/projects/config (license: GPL)
# http://git.savannah.gnu.org/cgit/config.git
override GNU_CFG_CMT			:=
override GNU_CFG_SRC			:= http://git.savannah.gnu.org/r/config.git
override GNU_CFG_FILE_SRC		:= http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=
override GNU_CFG_FILE_GUS		:= config.guess
override GNU_CFG_FILE_SUB		:= config.sub
override GNU_CFG_DST			:= $(COMPOSER_BUILD)/gnu-config

# https://www.gnu.org/software/gettext (license: GPL, LGPL)
# https://www.gnu.org/software/gettext
#WORK : re-verify this, on both 32 and 64
# version ">= 0.19" conflicts with "pkg-config" version "== 0.28":
#	make[2]: Entering directory `/Linux64/build/make/po'
#	*** error: gettext infrastructure mismatch: using a Makefile.in.in from gettext version 0.18 but the autoconf macros are from gettext version 0.19
#	make[2]: *** [check-macro-version] Error 1
#WORK : override GETTEXT_VER			:= 0.19.3
override GETTEXT_VER			:= 0.18.3.2
override GETTEXT_SRC			:= https://ftp.gnu.org/pub/gnu/gettext/gettext-$(GETTEXT_VER).tar.gz
override GETTEXT_DST			:= $(COMPOSER_BUILD)/gettext-$(GETTEXT_VER)
# https://www.gnu.org/software/libiconv (license: GPL, LGPL)
# https://www.gnu.org/software/libiconv
override LIBICONV_VER			:= 1.14
override LIBICONV_SRC			:= https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(LIBICONV_VER).tar.gz
override LIBICONV_DST			:= $(COMPOSER_BUILD)/libiconv-$(LIBICONV_VER)
# http://www.freedesktop.org/wiki/Software/pkg-config (license: GPL)
# http://www.freedesktop.org/wiki/Software/pkg-config
override PKGCONFIG_VER			:= 0.28
override PKGCONFIG_SRC			:= http://pkgconfig.freedesktop.org/releases/pkg-config-$(PKGCONFIG_VER).tar.gz
override PKGCONFIG_DST			:= $(COMPOSER_BUILD)/pkg-config-$(PKGCONFIG_VER)
# http://www.zlib.net/zlib_license.html (license: custom = as-is)
# http://www.zlib.net
override ZLIB_VER			:= 1.2.8
override ZLIB_SRC			:= http://www.zlib.net/zlib-$(ZLIB_VER).tar.xz
override ZLIB_DST			:= $(COMPOSER_BUILD)/zlib-$(ZLIB_VER)
# https://gmplib.org (license: GPL, LGPL)
# https://gmplib.org
override GMP_VER			:= 6.0.0a
override GMP_SRC			:= https://gmplib.org/download/gmp/gmp-$(GMP_VER).tar.xz
override GMP_DST			:= $(COMPOSER_BUILD)/gmp-$(subst a,,$(GMP_VER))
# https://www.gnu.org/software/ncurses (license: custom = as-is)
# https://www.gnu.org/software/ncurses
override NCURSES_VER			:= 5.9
override NCURSES_SRC			:= https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz
override NCURSES_DST			:= $(COMPOSER_BUILD)/ncurses-$(NCURSES_VER)
# https://www.openssl.org/source/license.html (license: BSD)
# https://www.openssl.org
override OPENSSL_VER			:= 1.0.1j
override OPENSSL_SRC			:= https://www.openssl.org/source/openssl-$(OPENSSL_VER).tar.gz
override OPENSSL_DST			:= $(COMPOSER_BUILD)/openssl-$(OPENSSL_VER)
# http://www.gnu.org.ua/software/gdbm (license: GPL)
# http://www.gnu.org.ua/software/gdbm/download.html
override GDBM_VER			:= 1.11
override GDBM_SRC			:= https://ftp.gnu.org/gnu/gdbm/gdbm-$(GDBM_VER).tar.gz
override GDBM_DST			:= $(COMPOSER_BUILD)/gdbm-$(GDBM_VER)
# http://sourceforge.net/projects/expat (license: MIT)
# http://expat.sourceforge.net
override EXPAT_VER			:= 2.1.0
override EXPAT_SRC			:= http://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)/expat-$(EXPAT_VER).tar.gz
override EXPAT_DST			:= $(COMPOSER_BUILD)/expat-$(EXPAT_VER)
#WORKING:MACP
# http://www.libpng.org/pub/png/src/libpng-LICENSE.txt (license: custom = BSD)
# http://www.libpng.org/pub/png/libpng.html
override PNG_VER			:= 1.6.21
override PNG_SRC			:= http://sourceforge.net/projects/libpng/files/libpng$(subst $(NULL) $(NULL),,$(wordlist 1,2,$(subst ., ,$(PNG_VER))))/$(PNG_VER)/libpng-$(PNG_VER).tar.xz
override PNG_DST			:= $(COMPOSER_BUILD)/libpng-$(PNG_VER)
# http://www.freetype.org/license.html (license: custom = BSD, GPL)
# http://www.freetype.org/download.html
override FREETYPE_VER			:= 2.5.3
override FREETYPE_SRC			:= http://download.savannah.gnu.org/releases/freetype/freetype-$(FREETYPE_VER).tar.gz
override FREETYPE_DST			:= $(COMPOSER_BUILD)/freetype-$(FREETYPE_VER)
# http://www.freedesktop.org/software/fontconfig/fontconfig-devel/ln12.html (license: custom = as-is)
# http://www.freedesktop.org/wiki/Software/fontconfig
override FONTCONFIG_VER			:= 2.11.1
override FONTCONFIG_SRC			:= http://www.freedesktop.org/software/fontconfig/release/fontconfig-$(FONTCONFIG_VER).tar.gz
override FONTCONFIG_DST			:= $(COMPOSER_BUILD)/fontconfig-$(FONTCONFIG_VER)

# https://www.gnu.org/software/coreutils (license: GPL)
# https://www.gnu.org/software/coreutils
override COREUTILS_VER			:= 8.23
override COREUTILS_SRC			:= https://ftp.gnu.org/gnu/coreutils/coreutils-$(COREUTILS_VER).tar.xz
override COREUTILS_DST			:= $(COMPOSER_BUILD)/coreutils-$(COREUTILS_VER)
# https://www.gnu.org/software/findutils (license: GPL)
# https://www.gnu.org/software/findutils
override FINDUTILS_VER			:= 4.4.2
override FINDUTILS_SRC			:= https://ftp.gnu.org/gnu/findutils/findutils-$(FINDUTILS_VER).tar.gz
override FINDUTILS_DST			:= $(COMPOSER_BUILD)/findutils-$(FINDUTILS_VER)
# https://savannah.gnu.org/projects/patch (license: GPL)
# https://savannah.gnu.org/projects/patch
override PATCH_VER			:= 2.7
override PATCH_SRC			:= https://ftp.gnu.org/gnu/patch/patch-$(PATCH_VER).tar.xz
override PATCH_DST			:= $(COMPOSER_BUILD)/patch-$(PATCH_VER)
# https://savannah.gnu.org/projects/sed (license: GPL)
# https://savannah.gnu.org/projects/sed
override SED_VER			:= 4.2
override SED_SRC			:= https://ftp.gnu.org/gnu/sed/sed-$(SED_VER).tar.gz
override SED_DST			:= $(COMPOSER_BUILD)/sed-$(SED_VER)
# http://www.bzip.org (license: custom = BSD)
# http://www.bzip.org
override BZIP_VER			:= 1.0.6
override BZIP_SRC			:= http://www.bzip.org/$(BZIP_VER)/bzip2-$(BZIP_VER).tar.gz
override BZIP_DST			:= $(COMPOSER_BUILD)/bzip2-$(BZIP_VER)
# https://www.gnu.org/software/gzip (license: GPL)
# https://www.gnu.org/software/gzip
override GZIP_VER			:= 1.6
override GZIP_SRC			:= https://ftp.gnu.org/gnu/gzip/gzip-$(GZIP_VER).tar.gz
override GZIP_DST			:= $(COMPOSER_BUILD)/gzip-$(GZIP_VER)
# http://www.tukaani.org/xz (license: custom = GPL, public-domain)
# http://www.tukaani.org/xz
override XZ_VER				:= 5.2.0
override XZ_SRC				:= http://www.tukaani.org/xz/xz-$(XZ_VER).tar.gz
override XZ_DST				:= $(COMPOSER_BUILD)/xz-$(XZ_VER)
# https://www.gnu.org/software/tar (license: GPL)
# https://www.gnu.org/software/tar
override TAR_VER			:= 1.28
override TAR_SRC			:= https://ftp.gnu.org/gnu/tar/tar-$(TAR_VER).tar.xz
override TAR_DST			:= $(COMPOSER_BUILD)/tar-$(TAR_VER)
# http://dev.perl.org/licenses (license: custom = GPL, Artistic)
# https://www.perl.org/get.html
override PERL_VER			:= 5.20.1
override PERL_SRC			:= http://www.cpan.org/src/5.0/perl-$(PERL_VER).tar.gz
override PERL_DST			:= $(COMPOSER_BUILD)/perl-$(PERL_VER)
# https://docs.python.org/2/license.html (license: custom = PSF)
# https://www.python.org/downloads
override PYTHON_VER			:= 2.7.10
override PYTHON_SRC			:= https://www.python.org/ftp/python/$(PYTHON_VER)/Python-$(PYTHON_VER).tar.xz
override PYTHON_DST			:= $(COMPOSER_BUILD)/Python-$(PYTHON_VER)

# https://www.gnu.org/software/bash (license: GPL)
# https://www.gnu.org/software/bash
override BASH_VER			:= 4.3.30
override BASH_SRC			:= https://ftp.gnu.org/pub/gnu/bash/bash-$(BASH_VER).tar.gz
override BASH_DST			:= $(COMPOSER_BUILD)/bash-$(BASH_VER)
# http://www.greenwoodsoftware.com/less (license: GPL)
# http://www.greenwoodsoftware.com/less
override LESS_VER			:= 458
override LESS_SRC			:= http://www.greenwoodsoftware.com/less/less-$(LESS_VER).tar.gz
override LESS_DST			:= $(COMPOSER_BUILD)/less-$(LESS_VER)
# http://www.vim.org/about.php (license: custom = GPL)
# http://www.vim.org
override VIM_VER			:= 7.4
override VIM_SRC			:= http://ftp.vim.org/pub/vim/unix/vim-$(VIM_VER).tar.bz2
override VIM_DST			:= $(COMPOSER_BUILD)/vim$(subst .,,$(VIM_VER))

# https://www.gnu.org/software/make/manual/make.html#GNU-Free-Documentation-License (license: GPL)
# https://www.gnu.org/software/make/manual/make.html
# https://www.gnu.org/software/make
# https://savannah.gnu.org/projects/make
override MAKE_VER			:= $(MAKE_MIN_VERSION)
override MAKE_CMT			:= $(MAKE_CUR_VERSION)
override MAKE_SRC_INIT			:= http://ftp.gnu.org/gnu/make/make-$(MAKE_VER).tar.gz
override MAKE_SRC			:= http://git.savannah.gnu.org/r/make.git
override MAKE_DST_INIT			:= $(COMPOSER_BUILD)/make-$(MAKE_VER)
override MAKE_DST			:= $(COMPOSER_BUILD)/make
# http://www.info-zip.org/license.html (license: BSD)
# http://www.info-zip.org
override IZIP_VER			:= 3.0
override UZIP_VER			:= 6.0
override IZIP_SRC			:= http://sourceforge.net/projects/infozip/files/Zip%203.x%20%28latest%29/$(IZIP_VER)/zip$(subst .,,$(IZIP_VER)).tar.gz
override UZIP_SRC			:= http://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/UnZip%20$(UZIP_VER)/unzip$(subst .,,$(UZIP_VER)).tar.gz
override IZIP_DST			:= $(COMPOSER_BUILD)/zip$(subst .,,$(IZIP_VER))
override UZIP_DST			:= $(COMPOSER_BUILD)/unzip$(subst .,,$(UZIP_VER))
# https://curl.haxx.se/docs/copyright.html (license: MIT)
# https://curl.haxx.se/download.html
# https://curl.haxx.se/dev/source.html
override CURL_VER			:= 7.39.0
override CURL_SRC			:= https://curl.haxx.se/download/curl-$(CURL_VER).tar.gz
override CURL_DST			:= $(COMPOSER_BUILD)/curl-$(CURL_VER)
# https://github.com/git/git/blob/master/COPYING (license: GPL, LGPL)
# http://git-scm.com
override GIT_VER			:= 2.2.0
override GIT_SRC			:= https://www.kernel.org/pub/software/scm/git/git-$(GIT_VER).tar.xz
override GIT_DST			:= $(COMPOSER_BUILD)/git-$(GIT_VER)
# https://rsync.samba.org (license: GPL)
# https://rsync.samba.org
override RSYNC_VER			:= 3.1.2
override RSYNC_SRC			:= https://download.samba.org/pub/rsync/src/rsync-$(RSYNC_VER).tar.gz
override RSYNC_DST			:= $(COMPOSER_BUILD)/rsync-$(RSYNC_VER)
# https://nodejs.org/download (license: MIT)
# https://nodejs.org/download
#WORKoverride NODE_VER			:= 5.12.0
override NODE_VER			:= 10.6.0
override NODE_CMT			:= v$(NODE_VER)
override NODE_SRC			:= git://github.com/nodejs/node.git
override NODE_DST			:= $(COMPOSER_BUILD)/node
override NODE_MODULES			:= usr/lib/node_modules

# https://www.tug.org/texlive/LICENSE.TL (license: custom = libre)
# https://www.tug.org/texlive
# https://www.tug.org/texlive/build.html
# ftp://ftp.tug.org/historic/systems/texlive
# http://www.slackbuilds.org/repository/14.0/office/texlive/
#WORKING:NOW : now a new version is available; might cause all kinds of dependency ruckus
override TEX_YEAR			:= 2015
override TEX_TEXMF_VER			:= $(TEX_YEAR)0523
override TEX_VER			:= $(TEX_YEAR)0521
override TEX_VER_PDF			:= 1.40.16
#WORKING:NOW
#override TEX_YEAR			:= 2014
#override TEX_TEXMF_VER			:= $(TEX_YEAR)0525
#override TEX_VER			:= $(TEX_YEAR)0525
#override TEX_VER_PDF			:= 1.40.15
#WORKING:NOW
override TEX_TEXMF_SRC			:= ftp://ftp.tug.org/historic/systems/texlive/$(TEX_YEAR)/texlive-$(TEX_TEXMF_VER)-texmf.tar.xz
override TEX_SRC			:= ftp://ftp.tug.org/historic/systems/texlive/$(TEX_YEAR)/texlive-$(TEX_VER)-source.tar.xz
override TEX_TEXMF_DST			:= $(COMPOSER_BUILD)/texlive-$(TEX_TEXMF_VER)-texmf
override TEX_DST			:= $(COMPOSER_BUILD)/texlive-$(TEX_VER)-source

#WORK : url scrub
# https://www.haskell.org/ghc/license (license: BSD)
# https://www.haskell.org/ghc/download
# https://github.com/ghc/ghc
# https://ghc.haskell.org/trac/ghc/wiki/Building
# https://ghc.haskell.org/trac/ghc/wiki/Building/Using
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Tools
# https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Windows
# https://www.haskell.org/haskellwiki/Windows
# https://www.haskell.org/ghc/dist/latest/docs/html/users_guide/options-phases.html
# https://ghc.haskell.org/trac/ghc/wiki/Building/GettingTheSources
# https://ghc.haskell.org/trac/ghc/wiki/Building/QuickStart
# https://ghc.haskell.org/trac/ghc/wiki/Building/Compiling32on64
# http://urchin.earth.li/~ian/sec-porting-ghc.html
#WORK : ultimately, trying to track post-db19c665ec5055c2193b2174519866045aeff09a to ANTIQUATE GIT_SUBMODULE_GHC / GHC_BRANCH
#	https://github.com/ghc/ghc/commits/db19c665ec5055c2193b2174519866045aeff09a
#	https://github.com/ghc/ghc/commits/master/.gitmodules
#	https://github.com/ghc/ghc/commits/master/configure.ac
#	https://github.com/ghc/ghc/commits/master/libraries/base/base.cabal
#	https://github.com/ghc/ghc/commits/27a642cc3a448c5b9bb0774d413f27aef0c63379
override GHC_VER_INIT			:= 7.8.3
override GHC_VER			:= $(GHC_VER_INIT)
override GHC_CABAL_VER			:= 1.18.1.3
override GHC_CMT			:= ghc-$(GHC_VER)-release
override GHC_BRANCH			:= ghc-$(GHC_VER)
override GHC_SRC_INIT			:= https://www.haskell.org/ghc/dist/$(GHC_VER_INIT)/ghc-$(GHC_VER_INIT)-$(GHC_ARCH)-$(GHC_PLAT).tar.xz
override GHC_SRC			:= https://git.haskell.org/ghc.git
override GHC_DST_INIT			:= $(COMPOSER_BUILD)/ghc-$(GHC_VER_INIT)
override GHC_DST			:= $(COMPOSER_BUILD)/ghc

# https://www.haskell.org/cabal/download.html
# https://hackage.haskell.org/package/cabal-install
# https://github.com/ghc/packages-Cabal
override CABAL_VER_INIT			:= 1.20.0.0
override CABAL_VER			:= $(CABAL_VER_INIT)
override CABAL_CMT			:= Cabal-$(CABAL_VER)-release
override CABAL_SRC_INIT			:= https://www.haskell.org/cabal/release/cabal-install-$(CABAL_VER_INIT)/cabal-install-$(CABAL_VER_INIT).tar.gz
override CABAL_SRC			:= https://git.haskell.org/packages/Cabal.git
override CABAL_DST_INIT			:= $(COMPOSER_BUILD)/cabal-install-$(CABAL_VER_INIT)
override CABAL_DST			:= $(COMPOSER_BUILD)/cabal

# https://hackage.haskell.org
override HACKAGE_URL			= https://hackage.haskell.org/package/$(1)/$(1).tar.gz

# https://github.com/jgm/pandoc/blob/master/COPYING (license: GPL)
# http://johnmacfarlane.net/pandoc/code.html
# http://johnmacfarlane.net/pandoc/installing.html
# https://github.com/jgm/pandoc/blob/master/INSTALL
# https://github.com/jgm/pandoc/wiki/Installing-the-development-version-of-pandoc
override PANDOC_VER			:= 1.13.2
override PANDOC_CMT			:= $(PANDOC_VER)
override PANDOC_TYPE_VER		:= 1.12.4
override PANDOC_TYPE_CMT		:= $(PANDOC_TYPE_VER)
override PANDOC_MATH_VER		:= 0.8.0.1
override PANDOC_MATH_CMT		:= $(PANDOC_MATH_VER)
override PANDOC_HIGH_VER		:= 0.5.11.1
override PANDOC_HIGH_CMT		:= $(PANDOC_HIGH_VER)
override PANDOC_CITE_VER		:= 0.5
override PANDOC_CITE_CMT		:= $(PANDOC_CITE_VER)
override PANDOC_SRC			:= https://github.com/jgm/pandoc.git
override PANDOC_TYPE_SRC		:= https://github.com/jgm/pandoc-types.git
override PANDOC_MATH_SRC		:= https://github.com/jgm/texmath.git
override PANDOC_HIGH_SRC		:= https://github.com/jgm/highlighting-kate.git
override PANDOC_CITE_SRC		:= https://github.com/jgm/pandoc-citeproc.git
override PANDOC_DST			:= $(COMPOSER_BUILD)/pandoc
override PANDOC_TYPE_DST		:= $(COMPOSER_BUILD)/pandoc-types
override PANDOC_MATH_DST		:= $(COMPOSER_BUILD)/pandoc-texmath
override PANDOC_HIGH_DST		:= $(COMPOSER_BUILD)/pandoc-highlighting
override PANDOC_CITE_DST		:= $(COMPOSER_BUILD)/pandoc-citeproc
override PANDOC_DIRECTORIES		:= \
	"$(PANDOC_TYPE_DST)" \
	"$(PANDOC_MATH_DST)" \
	"$(PANDOC_HIGH_DST)" \
	"$(PANDOC_CITE_DST)" \
	"$(PANDOC_DST)"

override DEBIAN_PACKAGES_LIST		:= \
	automake \
	build-essential \
	gcc-multilib \
	libtool \
	locales-all \
	texinfo \
	\
	curl \
	rsync

#WORKING:MACP
override MACPORTS_PACKAGES_LIST		:= \
	autoconf \
	automake \
	gcc49 +universal \
	gmake \
	\
	coreutils \
	curl \
	gsed \
	rsync

override PACMAN_BASE_LIST		:= \
	msys2-runtime \
	msys2-runtime-devel \
	pacman

#>	mingw-w64-i686-toolchain
#>	mingw-w64-x86_64-toolchain
override PACMAN_PACKAGES_LIST		:= \
	base-devel \
	mingw-w64-i686-gcc \
	mingw-w64-x86_64-gcc \
	msys2-devel \
	\
	curl \
	make \
	rsync

#TODO : is cygwin-console-helper really needed?
#TODO : probably not all these dlls are needed
#TODO : double-check source/licensing of included dlls
# this list should be mirrored to "$(PATH_LIST)" and "$(CHECKIT)" sections
override MSYS_BINARY_LIST		:= \
	mintty cygwin-console-helper \
	cygpath
ifeq ($(BUILD_BITS),64)
override MSYS_BINARY_LIST		:= \
	$(MSYS_BINARY_LIST) \
	\
	msys-2.0.dll \
	msys-gcc_s-seh-1.dll \
	msys-ssp-0.dll \
	msys-stdc++-6.dll
else
override MSYS_BINARY_LIST		:= \
	$(MSYS_BINARY_LIST) \
	\
	msys-2.0.dll \
	msys-gcc_s-1.dll \
	msys-ssp-0.dll \
	msys-stdc++-6.dll
endif

# this list should be mirrored to "$(PATH_LIST)" and "$(CHECKIT)" sections
override BUILD_BINARY_LIST		:= \
	coreutils \
	find \
	patch \
	sed \
	bzip2 \
	gzip \
	xz \
	tar \
	perl \
	python \
	\
	bash sh \
	less \
	vim \
	\
	make \
	zip \
	unzip \
	curl \
	git \
	rsync \
	node npm \
	\
	pandoc \
	pandoc-citeproc \
	\
	tex \
	pdflatex \
	\
	ghc ghc-pkg \
	cabal haddock
# these are not included in the final distribution
override BUILD_BINARY_LIST		:= \
	$(filter-out perl,\
	$(filter-out python,\
	$(filter-out ghc,\
	$(filter-out ghc-pkg,\
	$(filter-out cabal,\
	$(filter-out haddock,\
	$(BUILD_BINARY_LIST)))))))

override DYNAMIC_LIBRARY_LIST		:= \
	ld-linux-x86-64.so.2 \
	linux-vdso.so.1 \
	\
	libc.so.6 \
	libdl.so.2 \
	libm.so.6 \
	libpthread.so.0 \
	librt.so.1 \
	libutil.so.1 \
	\
	libgcc_s.so.1 \
	libstdc++.so.6

#	ld-linux.so.2 \
#	linux-gate.so.1 \
#	\
#	libcrypt.so.1 \
#	libnsl.so.1 \

ifeq ($(BUILD_PLAT),Darwin)
override DYNAMIC_LIBRARY_LIST		:= \
	Library/Frameworks/AppKit.framework/Versions/C/AppKit \
	Library/Frameworks/Cocoa.framework/Versions/A/Cocoa \
	Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation \
	Library/Frameworks/CoreServices.framework/Versions/A/CoreServices \
	Library/Frameworks/Foundation.framework/Versions/C/Foundation \
	lib/libSystem.B.dylib \
	lib/libobjc.A.dylib
else ifeq ($(BUILD_PLAT),Msys)
override DYNAMIC_LIBRARY_LIST		:= \
	$(MSYS_BINARY_LIST) \
	\
	ADVAPI32.DLL \
	ADVAPI32.dll \
	COMCTL32.DLL \
	COMDLG32.DLL \
	CRYPT32.DLL \
	CRYPTBASE.dll \
	DNSAPI.dll \
	GDI32.dll \
	IMM32.DLL \
	KERNELBASE.dll \
	LPK.dll \
	MSASN1.dll \
	MSCTF.dll \
	NSI.dll \
	RPCRT4.dll \
	SHELL32.DLL \
	SHELL32.dll \
	SHLWAPI.dll \
	SspiCli.dll \
	USER32.dll \
	USERENV.dll \
	USP10.dll \
	WINMM.DLL \
	WINSPOOL.DRV \
	WS2_32.dll \
	WSOCK32.DLL \
	kernel32.dll \
	msvcrt.dll \
	ntdll.dll \
	ole32.dll \
	profapi.dll \
	sechost.dll
endif

override PERL_MODULES_LIST		:= \
	Encode-Locale-1.03|https://cpan.metacpan.org/authors/id/G/GA/GAAS/Encode-Locale-1.03.tar.gz \
	HTTP-Date-6.02|https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Date-6.02.tar.gz \
	HTTP-Message-6.06|https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Message-6.06.tar.gz \
	Net-HTTP-6.07|https://cpan.metacpan.org/authors/id/M/MS/MSCHILLI/Net-HTTP-6.07.tar.gz \
	URI-1.65|https://cpan.metacpan.org/authors/id/E/ET/ETHER/URI-1.65.tar.gz \
	libwww-perl-6.08|https://cpan.metacpan.org/authors/id/M/MS/MSCHILLI/libwww-perl-6.08.tar.gz

#WORKING : double-check texlive directory list against list of modules in pandoc manual
#WORKING : Production of a PDF requires that a LaTeX engine be installed (see --latex-engine, below), and assumes that the following LaTeX packages are available: amssymb, amsmath, ifxetex, ifluatex, listings (if the --listings option is used), fancyvrb, longtable, booktabs, url, graphicx, hyperref, ulem, babel (if the lang variable is set), fontspec (if xelatex or lualatex is used as the LaTeX engine), xltxtra and xunicode (if xelatex is used).
#	fancyvrb	tex/latex/fancyvrb \
#	longtable	tex/latex/hyper \
#	ulem		tex/generic/ulem \
#	babel		tex/generic/babel \
#	fontspec	tex/latex/fontspec \
#	xltxtra		tex/latex/xltxtra \
#	xunicode	tex/xelatex/xunicode \
#
override TEXLIVE_DIRECTORY_LIST		:= \
	fonts/enc/dvips/lm \
	fonts/map/pdftex/updmap \
	fonts/tfm/jknappen/ec \
	fonts/tfm/public/amsfonts/symbols \
	fonts/tfm/public/lm \
	fonts/type1/public/lm \
	tex/generic/ifxetex \
	tex/generic/oberdiek \
	tex/latex/amsfonts \
	tex/latex/amsmath \
	tex/latex/base \
	tex/latex/booktabs \
	tex/latex/geometry \
	tex/latex/graphics \
	tex/latex/hyperref \
	tex/latex/latexconfig \
	tex/latex/listings \
	tex/latex/lm \
	tex/latex/oberdiek \
	tex/latex/pdftex-def \
	tex/latex/tools \
	tex/latex/url

override GHC_LIBRARIES_INIT_LIST	:= \
	ghc|$(GHC_VER) \
	Cabal|$(GHC_CABAL_VER) \
	Win32|2.3.0.2 \
	array|0.5.0.0 \
	base|4.7.0.1 \
	bench-bytestring|0.1.0.0 \
	bin-package-db|0.0.0.0 \
	binary|0.7.1.0 \
	bytestring-tests|0.0.0.0 \
	bytestring|0.10.4.0 \
	cabal-install|1.18.0.3 \
	compareSizes|0.1.0.0 \
	containers|0.5.5.1 \
	deepseq|1.3.0.2 \
	directory|1.2.1.0 \
	dll-split|0.1 \
	dph-base|0.8.0.1 \
	dph-builbot|0.8.0.1 \
	dph-event-seer|0.8.0.1 \
	dph-examples|0.8.0.1 \
	dph-lifted-base|0.8.0.1 \
	dph-lifted-boxed|0.8.0.1 \
	dph-lifted-copy|0.8.0.1 \
	dph-lifted-vseg|0.8.0.1 \
	dph-plugin|0.8.1 \
	dph-prim-interface|0.8.0.1 \
	dph-prim-par|0.8.0.1 \
	dph-prim-seq|0.8.0.1 \
	filepath|1.3.0.2 \
	ghc-cabal|0.1 \
	ghc-pkg|6.9 \
	ghc-prim|0.3.1.0 \
	ghc-pwd|0.1 \
	ghctags|0.1 \
	haddock|2.14.3 \
	haskeline|0.7.1.2 \
	haskell2010|1.1.2.0 \
	haskell98|2.0.0.3 \
	hoopl|3.10.0.1 \
	hpc-bin|0.67 \
	hpc|0.6.0.1 \
	hsc2hs|0.67 \
	integer-gmp|0.5.1.0 \
	integer-simple|0.1.1.0 \
	mkUserGuidePart|0.1 \
	old-locale|1.0.0.6 \
	old-time|1.1.0.2 \
	pretty|1.1.1.1 \
	primitive|0.5.2.1 \
	process|1.2.0.0 \
	random|1.0.1.1 \
	rts|1.0 \
	runghc|7.8.3 \
	template-haskell|2.9.0.0 \
	terminfo|0.4.0.0 \
	time|1.4.2 \
	transformers|0.3.0.0 \
	unix|2.7.0.1 \
	vector-benchmarks|0.10.0.1 \
	vector-tests|0.10.0.1 \
	vector|0.10.9.1 \
	xhtml|3000.2.1

override CABAL_LIBRARIES_INIT_LIST	:= \
	Cabal|$(CABAL_VER) \
	HTTP|4000.2.12 \
	deepseq|1.3.0.2 \
	mtl|2.1.3.1 \
	network|2.4.2.3 \
	parsec|3.1.5 \
	random|1.0.1.1 \
	stm|2.4.3 \
	text|1.1.0.1 \
	time|1.4.2 \
	transformers|0.3.0.0 \
	zlib|0.5.4.1
override CABAL_LIBRARIES_LIST		:= \
	$(CABAL_LIBRARIES_INIT_LIST)

override CABAL_LIBRARIES_GHC_LIST	:= \
	QuickCheck|2.7.6 \
	primitive|0.5.4.0 \
	tf-random|0.5 \
	\
	alex|3.1.4 \
	happy|1.19.5

override PANDOC_LIBRARIES_LIST_REQUIRED	:= \
	$(filter-out deepseq|%,\
	$(filter-out primitive|%,\
	$(filter-out random|%,\
	$(filter-out time|%,\
	$(filter-out transformers|%,\
	$(filter-out vector|%,\
	$(GHC_LIBRARIES_INIT_LIST))))))) \
	$(CABAL_LIBRARIES_LIST) \
	$(CABAL_LIBRARIES_GHC_LIST)

override PANDOC_LIBRARIES_LIST		:= \
	Diff|0.3.0 \
	HUnit|1.2.5.2 \
	JuicyPixels|3.2.3 \
	List|0.5.2 \
	SHA|1.6.4.1 \
	aeson-pretty|0.7.2 \
	aeson|0.7.0.6 \
	ansi-terminal|0.6.2.1 \
	ansi-wl-pprint|0.6.7.1 \
	asn1-encoding|0.9.0 \
	asn1-parse|0.9.0 \
	asn1-types|0.3.0 \
	async|2.0.2 \
	attoparsec|0.11.3.4 \
	base64-bytestring|1.0.0.1 \
	blaze-builder|0.3.3.4 \
	blaze-html|0.7.1.0 \
	blaze-markup|0.6.3.0 \
	byteable|0.1.1 \
	case-insensitive|1.2.0.4 \
	cereal|0.4.1.1 \
	cipher-aes|0.2.10 \
	cipher-des|0.0.6 \
	cipher-rc4|0.1.4 \
	clock|0.4.1.3 \
	cmdargs|0.10.12 \
	conduit|1.2.4 \
	connection|0.2.4 \
	cookie|0.4.1.4 \
	crypto-cipher-types|0.0.9 \
	crypto-numbers|0.2.7 \
	crypto-pubkey-types|0.4.3 \
	crypto-pubkey|0.2.8 \
	crypto-random|0.0.9 \
	cryptohash|0.11.6 \
	data-default-class|0.0.1 \
	data-default-instances-base|0.0.1 \
	data-default-instances-containers|0.0.1 \
	data-default-instances-dlist|0.0.1 \
	data-default-instances-old-locale|0.0.1 \
	data-default|0.5.3 \
	deepseq-generics|0.1.1.2 \
	digest|0.0.1.2 \
	dlist|0.7.1.1 \
	enclosed-exceptions|1.0.1 \
	exceptions|0.8.0.2 \
	executable-path|0.0.3 \
	extensible-exceptions|0.1.1.4 \
	haddock-library|1.1.1 \
	hashable|1.2.3.2 \
	hexpat|0.20.9 \
	hostname|1.0 \
	hourglass|0.2.8 \
	hs-bibutils|5.5 \
	hslua|0.3.13 \
	http-client-tls|0.2.2 \
	http-client|0.4.9 \
	http-types|0.8.6 \
	lifted-base|0.2.3.6 \
	mime-types|0.1.0.6 \
	mmorph|1.0.4 \
	monad-control|1.0.0.4 \
	nats|1 \
	network-uri|2.6.0.1 \
	pem|0.2.2 \
	publicsuffixlist|0.1 \
	regex-base|0.93.2 \
	regex-pcre-builtin|0.94.4.8.8.35 \
	regex-posix|0.95.2 \
	resourcet|1.1.4.1 \
	rfc5051|0.1.0.3 \
	scientific|0.3.3.8 \
	securemem|0.1.7 \
	semigroups|0.16.2.2 \
	socks|0.5.4 \
	split|0.2.2 \
	streaming-commons|0.1.10.0 \
	syb|0.4.4 \
	tagsoup|0.13.3 \
	temporary|1.2.0.3 \
	test-framework-hunit|0.3.0.1 \
	test-framework-quickcheck2|0.3.0.3 \
	test-framework|0.8.1.1 \
	tls|1.2.16 \
	transformers-base|0.4.4 \
	transformers-compat|0.4.0.4 \
	unordered-containers|0.2.5.1 \
	utf8-string|1 \
	vector|0.10.12.2 \
	void|0.7 \
	x509-store|1.5.0 \
	x509-system|1.5.0 \
	x509-validation|1.5.1 \
	x509|1.5.0.1 \
	xml|1.3.14 \
	yaml|0.8.10.1 \
	zip-archive|0.2.3.7
# if "$(COMPOSER_TESTING)" is empty or -1, then we want these packages in the list
ifneq ($(or $(if $(COMPOSER_TESTING),,1),$(filter -1,$(COMPOSER_TESTING))),)
override PANDOC_LIBRARIES_LIST		:= \
	$(PANDOC_LIBRARIES_LIST) \
	\
	hxt-charproperties|9.2.0.1 \
	hxt-regex-xmlschema|9.2.0.1 \
	hxt-unicode|9.0.2.4 \
	hxt|9.3.1.15 \
	\
	HTTP|4000.2.19 \
	network|2.6.0.2 \
	\
	vault|0.3.0.4 \
	wai|3.0.2.2 \
	\
	auto-update|0.1.2.1 \
	byteorder|1.0.4 \
	easy-file|0.2.0 \
	fast-logger|2.2.3 \
	stringsearch|0.3.6.5 \
	unix-compat|0.4.1.4 \
	unix-time|0.3.4 \
	wai-extra|3.0.4.1 \
	wai-logger|2.2.3 \
	word8|0.1.1 \
	\
	hsb2hs|0.2 \
	preprocessor-tools|1.0.1
endif

override PANDOC_FLAGS			:= \
	make-pandoc-man-pages \
	embed_data_files \
	network-uri \
	https \
	trypandoc

########################################

# this list should be mirrored from "$(MSYS_BINARY_LIST)" and "$(BUILD_BINARY_LIST)"

override PATH_LIST			:= $(subst :, ,$(BUILD_PATH))

ifneq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_BINDIR)/bash),)
ifeq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_BINDIR)/sh),)
$(info $(shell $(CP) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/bash" "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/sh"))
endif
endif

ifeq ($(MAKESHELL),)
override MAKESHELL			:= $(call COMPOSER_FIND,$(PATH_LIST),sh)
endif
ifneq ($(MAKESHELL),)
override SHELL				:= $(MAKESHELL)
export MAKESHELL
endif

override AUTORECONF			:= "$(call COMPOSER_FIND,$(PATH_LIST),autoreconf)" --force --install -I$(COMPOSER_ABODE)/share/aclocal
override LDD				:= "$(call COMPOSER_FIND,$(PATH_LIST),ldd)"
override CC				:= "$(call COMPOSER_FIND,$(PATH_LIST),gcc)"
override CXX				:= "$(call COMPOSER_FIND,$(PATH_LIST),g++)"
override CPP				:= "$(call COMPOSER_FIND,$(PATH_LIST),cpp)"
override LD				:= "$(call COMPOSER_FIND,$(PATH_LIST),ld)"
override MOUNT				:= "$(call COMPOSER_FIND,$(PATH_LIST),mount)"
override UMOUNT				:= "$(call COMPOSER_FIND,$(PATH_LIST),umount)"
ifeq ($(BUILD_PLAT),Darwin)
override LDD				:= "$(call COMPOSER_FIND,$(PATH_LIST),otool)" -L
endif

#WORKING:MACP
#override PORTS_ENV			:= "$(MACPORTS_DST)/$(BUILD_BINDIR)/env" - PATH="$(MACPORTS_DST)/$(BUILD_BINDIR)"
override PORTS_ENV			:=
override PORTS				:= "$(MACPORTS_DST)/bin/port" -v -f

override WINDOWS_ACL			:= "$(call COMPOSER_FIND,/c/Windows/SysWOW64 /c/Windows/System32 /c/Windows/System,icacls)"
override PACMAN_ENV			:= "$(MSYS_DST)/$(BUILD_BINDIR)/env" - PATH="$(MSYS_DST)/$(BUILD_BINDIR)"
override PACMAN_DB_UPGRADE		:= "$(MSYS_DST)/$(BUILD_BINDIR)/pacman-db-upgrade"
override PACMAN_DB			:= "$(MSYS_DST)/$(BUILD_BINDIR)/pacman" --query
override PACMAN				:= "$(MSYS_DST)/$(BUILD_BINDIR)/pacman" --verbose --noconfirm --sync --needed

override MINTTY				:= "$(call COMPOSER_FIND,$(PATH_LIST),mintty)"
override CYGWIN_CONSOLE_HELPER		:= "$(call COMPOSER_FIND,$(PATH_LIST),cygwin-console-helper)"
override CYGPATH			:= "$(call COMPOSER_FIND,$(PATH_LIST),cygpath)" --absolute --mixed

override COREUTILS_PATH			:=  $(call COMPOSER_FIND,$(PATH_LIST),coreutils)
override COREUTILS			:= "$(COREUTILS_PATH)"
override define COREUTILS_INSTALL	=
	"$(1)" --coreutils-prog=ginstall -dv "$(2)"; \
	"$(1)" --help | $(SED) -n "s|^[ ]([[][ ])|\1|gp" | $(SED) "s|[ ]|\n|g" | while read FILE; do \
		"$(1)" --coreutils-prog=echo -en "#!$(1) --coreutils-prog-shebang=$${FILE}\n" >"$(2)/$${FILE}"; \
		"$(1)" --coreutils-prog=chmod -v 755 "$(2)/$${FILE}"; \
	done; \
	"$(1)" --coreutils-prog=echo -en "#!$(1) --coreutils-prog-shebang=ginstall\n" >"$(2)/install"; \
	"$(1)" --coreutils-prog=chmod -v 755 "$(2)/install"
endef
override define COREUTILS_UNINSTALL	=
	"$(1)" --help | $(SED) -n "s|^[ ]([[][ ])|\1|gp" | $(SED) "s|[ ]|\n|g" | while read FILE; do \
		if [ -f "$(2)/$${FILE}" ]; then \
			"$(1)" --coreutils-prog=rm -fv "$(2)/$${FILE}"; \
		fi; \
	done; \
	"$(1)" --coreutils-prog=rm -fv "$(2)/install"
endef
ifneq ($(COREUTILS_PATH),)
ifneq ($(wildcard $(COMPOSER_ABODE)/.coreutils.null),)
ifneq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_BINDIR)/coreutils),)
ifneq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_BINDIR)/ls),)
$(info $(shell $(call COREUTILS_UNINSTALL,$(COREUTILS_PATH),$(COMPOSER_ABODE)/$(BUILD_BINDIR))))
endif
endif
ifneq ($(wildcard $(COMPOSER_PROGS)/$(BUILD_BINDIR)/coreutils),)
ifneq ($(wildcard $(COMPOSER_ABODE)/.coreutils/ls),)
$(info $(shell $(COREUTILS) --coreutils-prog=rm -fv -r "$(COMPOSER_ABODE)/.coreutils"))
endif
endif
else ifeq ($(IS_CYGWIN),)
ifneq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_BINDIR)/coreutils),)
ifeq ($(BUILD_PLAT),Msys)
ifneq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_BINDIR)/ls),)
$(info $(shell $(call COREUTILS_UNINSTALL,$(COREUTILS_PATH),$(COMPOSER_ABODE)/$(BUILD_BINDIR))))
endif
else
ifeq ($(shell "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/ls" "$(COMPOSER_DIR)" 2>/dev/null),)
$(info $(shell $(call COREUTILS_INSTALL,$(COMPOSER_ABODE)/$(BUILD_BINDIR)/coreutils,$(COMPOSER_ABODE)/$(BUILD_BINDIR))))
endif
endif
endif
ifneq ($(wildcard $(COMPOSER_PROGS)/$(BUILD_BINDIR)/coreutils),)
ifeq ($(shell "$(COMPOSER_ABODE)/.coreutils/ls" "$(COMPOSER_DIR)" 2>/dev/null),)
$(info $(shell $(call COREUTILS_INSTALL,$(COMPOSER_PROGS)/$(BUILD_BINDIR)/coreutils,$(COMPOSER_ABODE)/.coreutils)))
endif
endif
endif
endif
override BASE64				:= "$(call COMPOSER_FIND,$(PATH_LIST),base64)" -w0
override CAT				:= "$(call COMPOSER_FIND,$(PATH_LIST),cat)"
override CHMOD				:= "$(call COMPOSER_FIND,$(PATH_LIST),chmod)" -v 755
override CHROOT				:= "$(call COMPOSER_FIND,$(PATH_LIST),chroot)"
override CP				:= "$(call COMPOSER_FIND,$(PATH_LIST),cp)" -afv
override CUT				:= "$(call COMPOSER_FIND,$(PATH_LIST),cut)"
override DATE				:= "$(call COMPOSER_FIND,$(PATH_LIST),date)" --iso
override DATESTAMP			:= "$(call COMPOSER_FIND,$(PATH_LIST),date)" --rfc-2822
override DIRCOLORS			:= "$(call COMPOSER_FIND,$(PATH_LIST),dircolors)"
override ECHO				:= "$(call COMPOSER_FIND,$(PATH_LIST),echo)" -en
override ENV				:= "$(call COMPOSER_FIND,$(PATH_LIST),env)"
override HEAD				:= "$(call COMPOSER_FIND,$(PATH_LIST),head)"
override LS				:= "$(call COMPOSER_FIND,$(PATH_LIST),ls)" --color=auto --time-style=long-iso -asF -l
override MKDIR				:= "$(call COMPOSER_FIND,$(PATH_LIST),install)" -dv
override MV				:= "$(call COMPOSER_FIND,$(PATH_LIST),mv)" -fv
override PRINTF				:= "$(call COMPOSER_FIND,$(PATH_LIST),printf)"
override RM				:= "$(call COMPOSER_FIND,$(PATH_LIST),rm)" -fv
override SORT				:= "$(call COMPOSER_FIND,$(PATH_LIST),sort)" -u
override TAIL				:= "$(call COMPOSER_FIND,$(PATH_LIST),tail)"
override TRUE				:= "$(call COMPOSER_FIND,$(PATH_LIST),true)"
override UNAME				:= "$(call COMPOSER_FIND,$(PATH_LIST),uname)"

override FIND				:= "$(call COMPOSER_FIND,$(PATH_LIST),find)"
override PATCH				:= "$(call COMPOSER_FIND,$(PATH_LIST),patch)"
override SED				:= "$(call COMPOSER_FIND,$(PATH_LIST),sed)" -r
override BZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),bzip2)"
override GZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),gzip)"
override XZ				:= "$(call COMPOSER_FIND,$(PATH_LIST),xz)"
override TAR				:= "$(call COMPOSER_FIND,$(PATH_LIST),tar)" -vvx
override PERL				:= "$(call COMPOSER_FIND,$(PATH_LIST),perl)"
override PYTHON				:= "$(call COMPOSER_FIND,$(PATH_LIST),python)"
#WORK : gsed for macports?

override BASH				:= "$(call COMPOSER_FIND,$(PATH_LIST),bash)"
override SH				:= "$(SHELL)"
override LESS				:= "$(call COMPOSER_FIND,$(PATH_LIST),less)" -rX
override VIM				:= "$(call COMPOSER_FIND,$(PATH_LIST),vim)" -u "$${HOME}/.vimrc" -i NONE -p

override MAKE				:= "$(call COMPOSER_FIND,$(PATH_LIST),make)"
override ZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),zip)"
override UNZIP				:= "$(call COMPOSER_FIND,$(PATH_LIST),unzip)"
override CURL				:= "$(call COMPOSER_FIND,$(PATH_LIST),curl)" --verbose --location --remote-time
override GIT_PATH			:=  $(call COMPOSER_FIND,$(PATH_LIST),git)
override GIT				:= "$(GIT_PATH)"
override RSYNC				:= "$(call COMPOSER_FIND,$(PATH_LIST),rsync)" -vv --archive --itemize-changes --progress
override NODE				:= "$(call COMPOSER_FIND,$(PATH_LIST),node)"
override NPM				:= "$(call COMPOSER_FIND,$(PATH_LIST),npm)"
#WORK override NPM_JS				:= "$(COMPOSER_ABODE)/$(NODE_MODULES)/npm/bin/npm-cli.js"
#WORK override NPM_RUN			= $(BUILD_ENV) $(NODE) $(NPM_JS) --cache "$(COMPOSER_STORE)/npm" --global --verbose
override NPM_RUN			= $(BUILD_ENV) $(NPM) --cache "$(COMPOSER_STORE)/npm" --verbose
ifeq ($(BUILD_PLAT),Darwin)
ifeq ($(word 1,$(MAKE)),"")
#WORKING:MACP : does this work?  do the same for tar, sed, etc.?
#ifneq ($(MAKE),"$(COMPOSER_ABODE)/$(BUILD_BINDIR)/make")
#ifneq ($(MAKE),"$(COMPOSER_PROGS)/$(BUILD_BINDIR)/make")
override MAKE				:= "$(call COMPOSER_FIND,$(PATH_LIST),gmake)"
#endif
#endif
endif
endif

override PANDOC_PATH			:=  $(call COMPOSER_FIND,$(PATH_LIST),pandoc)
override PANDOC				:= "$(PANDOC_PATH)"
override PANDOC_CITEPROC		:= "$(call COMPOSER_FIND,$(PATH_LIST),pandoc-citeproc)"
override TEX				:= "$(call COMPOSER_FIND,$(PATH_LIST),tex)"
override PDFLATEX_PATH			:=  $(call COMPOSER_FIND,$(PATH_LIST),pdflatex)
override PDFLATEX			:= "$(PDFLATEX_PATH)"
override GHC_PATH			:=  $(call COMPOSER_FIND,$(PATH_LIST),ghc)
override GHC				:= "$(GHC_PATH)"
override GHC_PKG			:= "$(call COMPOSER_FIND,$(PATH_LIST),ghc-pkg)"
override CABAL				:= "$(call COMPOSER_FIND,$(PATH_LIST),cabal)"
override HADDOCK			:= "$(call COMPOSER_FIND,$(PATH_LIST),haddock)"
ifneq ($(COMPOSER_TESTING),)
override GHC_BIN			:= "$(or $(wildcard $(COMPOSER_ABODE)/usr/lib/ghc-$(GHC_VER)/bin/ghc),$(wildcard $(BUILD_STRAP)/usr/lib/ghc-$(GHC_VER_INIT)/bin/ghc))"
override GHC_PKG_BIN			:= "$(or $(wildcard $(COMPOSER_ABODE)/usr/lib/ghc-$(GHC_VER)/bin/ghc-pkg),$(wildcard $(BUILD_STRAP)/usr/lib/ghc-$(GHC_VER_INIT)/bin/ghc-pkg))"
override CABAL_BIN			:=
override HADDOCK_BIN			:= "$(or $(wildcard $(COMPOSER_ABODE)/usr/lib/ghc-$(GHC_VER)/bin/haddock),$(wildcard $(BUILD_STRAP)/usr/lib/ghc-$(GHC_VER_INIT)/bin/haddock))"
endif

override define DO_PATCH		=
	cd "$(2)" && $(PATCH) -p$(1) <"$(COMPOSER_STORE)/$(notdir $(3))"
endef
#WORKING:NOW : remove/replace "$(RM) -r" and comments throughout
#WORKING:NOW : comment; idempotent idempotency
override define DO_UNTAR_CLEAN		=
	if [ -d "$(1)" ]; then \
		$(RM) -r "$(1)"; \
	fi; \
	$(call DO_UNTAR,$(1),$(2),$(3))
endef
override define DO_UNTAR		=
	if [ ! -d "$(1)" ]; then \
		$(MKDIR) "$(abspath $(dir $(1)))"; \
		$(TAR) -C "$(abspath $(dir $(1)))" -f "$(COMPOSER_STORE)/$(notdir $(2))" --exclude "$(3)"; \
	fi
endef
override define DO_UNZIP		=
	$(UNZIP) -ou -d "$(abspath $(dir $(1)))" "$(COMPOSER_STORE)/$(notdir $(2))"
endef

override define CURL_FILE		=
	$(MKDIR) "$(COMPOSER_STORE)"; \
	if [ ! -f "$(COMPOSER_STORE)/$(notdir $(1))" ]; then \
		$(CURL) --time-cond "$(COMPOSER_STORE)/$(notdir $(1))" --output "$(COMPOSER_STORE)/$(notdir $(1))" "$(1)"; \
	fi
endef
override define CURL_FILE_GNU_CFG	=
	$(MKDIR) "$(GNU_CFG_DST)"; \
	if [ ! -f "$(GNU_CFG_DST)/$(1)" ]; then \
		$(CURL) --time-cond "$(GNU_CFG_DST)/$(1)" --output "$(GNU_CFG_DST)/$(1)" "$(GNU_CFG_FILE_SRC)$(1)"; \
	fi
endef

override GIT_EXEC			:=
ifeq ($(GIT_PATH),$(COMPOSER_ABODE)/$(BUILD_BINDIR)/git)
override GIT_EXEC			:= $(wildcard $(COMPOSER_ABODE)/libexec/git-core)
else ifeq ($(GIT_PATH),$(COMPOSER_PROGS)/$(BUILD_BINDIR)/git)
override GIT_EXEC			:= $(wildcard $(COMPOSER_PROGS)/git-core)
endif
ifneq ($(GIT_EXEC),)
override GIT				:= $(GIT) --exec-path="$(GIT_EXEC)"
endif

override REPLICA_GIT_DIR		:= $(COMPOSER_STORE)/$(COMPOSER_BASENAME).git
override REPLICA_GIT			:= cd "$(CURDIR)" && $(GIT) --git-dir="$(REPLICA_GIT_DIR)"
override COMPOSER_GIT_RUN		= cd "$(1)" && $(GIT) --git-dir="$(COMPOSER_GITREPO)" --work-tree="$(1)" $(2)
override GIT_RUN			= cd "$(1)" && $(GIT) --git-dir="$(COMPOSER_STORE)/$(notdir $(1)).git" --work-tree="$(1)" $(2)
override GIT_REPO			= $(call DO_GIT_REPO,$(1),$(2),$(3),$(4),$(COMPOSER_STORE)/$(notdir $(1)).git)
#WORKING:NOW : split GIT functions into FETCH/NOFETCH; make offline build completely possible
override define DO_GIT_REPO		=
	$(MKDIR) "$(COMPOSER_STORE)"; \
	$(MKDIR) "$(1)"; \
	if [ ! -d "$(5)" ] && [ -d "$(1).git"  ]; then $(MV) "$(1).git"  "$(5)"; fi; \
	if [ ! -d "$(5)" ] && [ -d "$(1)/.git" ]; then $(MV) "$(1)/.git" "$(5)"; fi; \
	if [ ! -d "$(5)" ]; then \
		$(call GIT_RUN,$(1),init); \
		$(call GIT_RUN,$(1),remote add origin "$(2)"); \
	fi; \
	$(ECHO) "gitdir: $(5)" >"$(1)/.git"; \
	$(call GIT_RUN,$(1),config --local --replace-all core.worktree "$(1)"); \
	$(call GIT_RUN,$(1),fetch --all); \
	if [ -n "$(3)" ] && [ -n "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force -B $(4) $(3)); fi; \
	if [ -n "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force -B $(BUILD_BRANCH) $(3)); fi; \
	if [ -z "$(3)" ] && [ -z "$(4)" ]; then $(call GIT_RUN,$(1),checkout --force master); fi; \
	$(call GIT_RUN,$(1),reset --hard); \
	if [ -f "$(1)/.gitmodules" ]; then \
		$(call GIT_RUN,$(1),submodule update --init --recursive --force); \
	fi
endef
#ANTIQUATE
override GIT_SUBMODULE_GHC		= $(call DO_GIT_SUBMODULE_GHC,$(1),$(COMPOSER_STORE)/$(notdir $(1)).git)
override define DO_GIT_SUBMODULE_GHC	=
	$(ECHO) "gitdir: $(2)" >"$(1)/.git"; \
	$(SED) -i \
		-e "s|^([.][ ]+[-][ ]+ghc[.]git)|#\1|g" \
		"$(1)/packages"; \
	$(SED) -i \
		-e "s|[-]d([ ][^ ]+[.]git)|-f\1|g" \
		"$(1)/sync-all"; \
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all get; \
	cd "$(1)" && $(FIND) ./ -mindepth 2 -type d -name ".git" 2>/dev/null | $(SORT) | $(SED) -e "s|^[.][/]||g" -e "s|[/][.]git$$||g" | while read FILE; do \
		$(MKDIR) "$(2)/modules/$${FILE}"; \
		$(RM) -r "$(2)/modules/$${FILE}"; \
		$(MV) "$(1)/$${FILE}/.git" "$(2)/modules/$${FILE}"; \
	done; \
	cd "$(2)" && $(FIND) ./modules -type f -name "index" 2>/dev/null | $(SORT) | $(SED) -e "s|^[.][/]modules[/]||g" -e "s|[/]index$$||g" | while read FILE; do \
		$(MKDIR) "$(1)/$${FILE}"; \
		$(ECHO) "gitdir: $(2)/modules/$${FILE}" >"$(1)/$${FILE}/.git"; \
		cd "$(1)/$${FILE}" && $(GIT) --git-dir="$(2)/modules/$${FILE}" config --local --replace-all core.worktree "$(1)/$${FILE}"; \
	done; \
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all fetch --all && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all checkout --force -B $(GHC_BRANCH) $(GHC_CMT) && \
		$(BUILD_ENV_MINGW) $(PERL) ./sync-all reset --hard; \
	$(call GIT_RUN,$(1),show $(GHC_CMT)) | $(SED) -n "/\|/p" | while read FILE; do \
		cd "$(1)/$${FILE/%|*}" && $(GIT) --git-dir="$(2)/modules/$${FILE/%|*}" --work-tree="$(1)/$${FILE/%|*}" reset --hard $${FILE/#*|}; \
	done
endef
#ANTIQUATE

override HACKAGE_PULL			= $(call CURL_FILE,$(call HACKAGE_URL,$(1)))			$(call NEWLINE)$(ECHO)
override HACKAGE_PREP			= $(call DO_UNTAR_CLEAN,$(2)/$(1),$(call HACKAGE_URL,$(1)))	$(call NEWLINE)$(ECHO)
override DO_GHC_PKG			= $(BUILD_ENV_MINGW) $(GHC_PKG) --verbose --global --force
override DO_CABAL			= $(BUILD_ENV_MINGW) $(CABAL) --verbose
override CABAL_INFO			= $(DO_CABAL) info
override CABAL_INSTALL			= $(DO_CABAL) install \
	$(call CABAL_OPTIONS$(1),$(2)) \
	--jobs$(if $(BUILD_JOBS),=$(BUILD_JOBS)) \
	--reinstall \
	--force-reinstalls
#>	--avoid-reinstalls
#>	--allow-newer
override CABAL_OPTIONS_TOOLS		:= \
	--with-gcc=$(CC) \
	--with-ld=$(LD) \
	--with-ghc=$(GHC)
ifeq ($(BUILD_PLAT),Msys)
override CABAL_OPTIONS_TOOLS		:= \
	--with-gcc="$(MSYS_DST)/mingw$(BUILD_BITS)/bin/gcc" \
	--with-ld="$(MSYS_DST)/mingw$(BUILD_BITS)/bin/ld" \
	--with-ghc=$(GHC)
endif
override CABAL_OPTIONS			= \
	--prefix="$(1)" \
	--bindir="$(1)/$(BUILD_BINDIR)" \
	$(CABAL_OPTIONS_TOOLS) \
	$(foreach FILE,$(CFLAGS),--gcc-option="$(FILE)") \
	$(foreach FILE,$(LDFLAGS),--ld-option="$(FILE)") \
	$(foreach FILE,$(GHCFLAGS) -static,--ghc-option="$(FILE)") \
	--extra-include-dirs="$(COMPOSER_ABODE)/include" \
	--extra-lib-dirs="$(COMPOSER_ABODE)/lib" \
	--disable-executable-dynamic \
	--disable-shared \
	--global
override CABAL_OPTIONS_LDLIB		= \
	--prefix="$(1)" \
	--bindir="$(1)/$(BUILD_BINDIR)" \
	$(CABAL_OPTIONS_TOOLS) \
	$(foreach FILE,$(CFLAGS_LDLIB),--gcc-option="$(FILE)") \
	$(foreach FILE,$(LDFLAGS_LDLIB),--ld-option="$(FILE)") \
	$(foreach FILE,$(GHCFLAGS_LDLIB),--ghc-option="$(FILE)") \
	--extra-include-dirs="$(BUILD_LDLIB)/include" \
	--extra-lib-dirs="$(BUILD_LDLIB)/lib" \
	--extra-include-dirs="$(COMPOSER_ABODE)/include" \
	--extra-lib-dirs="$(COMPOSER_ABODE)/lib" \
	--global

ifeq ($(wildcard $(CURL_CA_BUNDLE)),)
override CURL_CA_BUNDLE			:=
ifneq ($(wildcard $(COMPOSER_ABODE)/ca-bundle.crt),)
override CURL_CA_BUNDLE			:= $(COMPOSER_ABODE)/ca-bundle.crt
else ifneq ($(wildcard $(COMPOSER_PROGS)/ca-bundle.crt),)
override CURL_CA_BUNDLE			:= $(COMPOSER_PROGS)/ca-bundle.crt
endif
endif
ifneq ($(CURL_CA_BUNDLE),)
export CURL_CA_BUNDLE
endif

override TEXMFDIST			:=
override TEXMFVAR			:=
ifeq ($(PDFLATEX_PATH),$(COMPOSER_ABODE)/$(BUILD_BINDIR)/pdflatex)
override TEXMFDIST			:= $(wildcard $(COMPOSER_ABODE)/texmf-dist)
else ifeq ($(PDFLATEX_PATH),$(COMPOSER_PROGS)/$(BUILD_BINDIR)/pdflatex)
override TEXMFDIST			:= $(wildcard $(COMPOSER_PROGS)/texmf-dist)
endif
ifneq ($(TEXMFDIST),)
override TEXMFVAR			:= $(subst -dist,-var,$(TEXMFDIST))
endif

override PANDOC_DATA			:=
ifeq ($(PANDOC_PATH),$(COMPOSER_ABODE)/$(BUILD_BINDIR)/pandoc)
override PANDOC_DATA			:= $(wildcard $(COMPOSER_ABODE)/.pandoc)
#>else ifeq ($(PANDOC_PATH),$(COMPOSER_PROGS)/$(BUILD_BINDIR)/pandoc)
else
override PANDOC_DATA			:= $(wildcard $(COMPOSER_PROGS)/pandoc)
endif
ifneq ($(PANDOC_DATA),)
ifneq ($(wildcard $(PANDOC_DATA)/data/reference.$(OUTPUT)),)
override PANDOC_OPTIONS			:= --template="$(PANDOC_DATA)/data/reference.$(OUTPUT)" $(PANDOC_OPTIONS)
else ifneq ($(wildcard $(PANDOC_DATA)/data/templates/default.$(OUTPUT)),)
override PANDOC_OPTIONS			:= --template="$(PANDOC_DATA)/data/templates/default.$(OUTPUT)" $(PANDOC_OPTIONS)
endif
override PANDOC_OPTIONS			:= --data-dir="$(PANDOC_DATA)" $(PANDOC_OPTIONS)
endif

#WORK : better spot for this?
ifeq ($(wildcard $(COMPOSER_TRASH)),)
$(info $(shell $(MKDIR) "$(COMPOSER_TRASH)"))
endif

override BUILD_ENV_PANDOC		:= $(ENV) - \
	LC_ALL="$(LANG)" \
	LANG="$(LANG)" \
	TERM="$(TERM)" \
	\
	USER="$(USER)" \
	HOME="$(COMPOSER_ABODE)" \
	PATH="$(BUILD_PATH)" \
	CURL_CA_BUNDLE="$(CURL_CA_BUNDLE)" \
	TEXMFDIST="$(TEXMFDIST)" \
	TEXMFVAR="$(TEXMFVAR)" \
	TMPDIR="$(COMPOSER_TRASH)"
ifeq ($(BUILD_PLAT),Msys)
# see "$(BUILD_PLAT),Msys" paths comment in "$(BUILDIT)-ghc"
override BUILD_ENV_PANDOC		:= $(BUILD_ENV_PANDOC) \
	MSYSTEM="MSYS$(BUILD_BITS)" \
	HOMEPATH="$(COMPOSER_ABODE)" \
	TMP="$(COMPOSER_TRASH)"
endif
override BUILD_ENV			:= $(BUILD_ENV_PANDOC) \
	CC=$(CC) \
	CXX=$(CXX) \
	CPP=$(CPP) \
	LD=$(LD) \
	CHOST="$(CHOST)" \
	CFLAGS="$(CFLAGS)" \
	CXXFLAGS="$(CFLAGS)" \
	CPPFLAGS="$(CPPFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	GHCFLAGS="$(GHCFLAGS)" \
	$(if $(filter $(BUILD_PLAT),Darwin),LD_LIBRARY_PATH="$(LDLIB_LIBRARY_PATH)")
override BUILD_ENV_MINGW		:= $(BUILD_ENV)
ifeq ($(BUILD_PLAT),Msys)
override BUILD_ENV_MINGW		:= $(BUILD_ENV) \
	MSYSTEM="MINGW$(BUILD_BITS)" \
	CC="$(MSYS_DST)/mingw$(BUILD_BITS)/bin/gcc" \
	CXX="$(MSYS_DST)/mingw$(BUILD_BITS)/bin/g++" \
	CPP="$(MSYS_DST)/mingw$(BUILD_BITS)/bin/cpp" \
	LD="$(MSYS_DST)/mingw$(BUILD_BITS)/bin/ld" \
	PATH="$(BUILD_PATH_MINGW):$(BUILD_PATH)"
endif

# thanks for the 'newline' fix below: https://stackoverflow.com/questions/649246/is-it-possible-to-create-a-multi-line-string-variable-in-a-makefile
#	also to: https://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
override define DO_HEREDOC		=
	$(ECHO) -E '$(subst $(call NEWLINE),[N],$(1))[N]' | $(SED) \
			-e "s|[[]B[]]|\\\\|g" \
			-e "s|[[]N[]]|\\n|g" \
			-e "s|[[]Q[]]|\'|g"
endef

override define GNU_CFG_INSTALL		=
	$(CP) "$(GNU_CFG_DST)/$(GNU_CFG_FILE_GUS)" "$(1)/"; \
	$(CP) "$(GNU_CFG_DST)/$(GNU_CFG_FILE_SUB)" "$(1)/"
endef
override define AUTOTOOLS_BUILD		=
	cd "$(1)" && \
		$(BUILD_ENV) $(3) FORCE_UNSAFE_CONFIGURE="1" $(SH) ./configure \
			--host="$(CHOST)" \
			--target="$(CHOST)" \
			--prefix="$(2)" \
			--bindir="$(2)/$(BUILD_BINDIR)" \
			$(4) && \
		$(BUILD_ENV) $(3) $(MAKE) $(5) && \
		$(BUILD_ENV) $(3) $(MAKE) install
endef
override define AUTOTOOLS_BUILD_MINGW	=
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) $(3) FORCE_UNSAFE_CONFIGURE="1" $(SH) ./configure \
			--host="$(CHOST)" \
			--target="$(CHOST)" \
			--prefix="$(2)" \
			--bindir="$(2)/$(BUILD_BINDIR)" \
			$(4) && \
		$(BUILD_ENV_MINGW) $(3) $(MAKE) $(5) && \
		$(BUILD_ENV_MINGW) $(3) $(MAKE) install
endef
override AUTOTOOLS_BUILD_NOTARGET	= $(patsubst --host="%",,$(patsubst --target="%",,$(AUTOTOOLS_BUILD)))
override AUTOTOOLS_BUILD_NOOPTION	= $(patsubst --host="%",,$(patsubst --target="%",,$(patsubst --bindir="%",,$(AUTOTOOLS_BUILD))))
override AUTOTOOLS_BUILD_NOOPTION_MINGW	= $(patsubst --host="%",,$(patsubst --target="%",,$(patsubst --bindir="%",,$(AUTOTOOLS_BUILD_MINGW))))
override BUILD_COMPLETE			= $(MKDIR) "$(COMPOSER_ABODE)/.$(BUILDIT)"; $(DATESTAMP) >"$(COMPOSER_ABODE)/.$(BUILDIT)/$(@)$(1)"
override BUILD_COMPLETE_TIMERIT		= if [ -f "$(COMPOSER_ABODE)/.$(BUILDIT)/$(1)" ]; then $(CAT) "$(COMPOSER_ABODE)/.$(BUILDIT)/$(1)"; fi
override BUILD_COMPLETE_TIMERIT_FILES	= $(FIND) "$(COMPOSER_ABODE)/.$(BUILDIT)" 2>/dev/null | $(SORT) | $(SED) -e "s|^$(COMPOSER_ABODE)/.$(BUILDIT)[/]?||g"

################################################################################

#WORK : move these to top of file?

.NOTPARALLEL:
.POSIX:
.SUFFIXES:

#>.ONESHELL:
.SHELLFLAGS: -e

########################################

# http://en.wikipedia.org/wiki/ANSI_escape_code
# http://ascii-table.com/ansi-escape-sequences.php
#	default	= light gray
#	header	= light green
#	core	= cyan
#	mark	= yellow
#	note	= red
#	extra	= magenta
#	syntax	= dark blue
ifneq ($(COMPOSER_ESCAPES),)
override [	:= \[
override ]	:= \]
override _D	:= \e[0;37m
override _H	:= \e[0;32m
override _C	:= \e[0;36m
override _M	:= \e[0;33m
override _N	:= \e[0;31m
override _E	:= \e[0;35m
override _S	:= \e[0;34m
else
override [	:=
override ]	:=
override _D	:=
override _H	:=
override _C	:=
override _M	:=
override _N	:=
override _E	:=
override _S	:=
endif

########################################

override INDENTING	:= $(NULL) $(NULL) $(NULL)
override COMMENTED	:= $(_S)\#$(_D) $(NULL)

override HEADER_L	:= $(ECHO) "$(_H)$(INDENTING)";	$(PRINTF)  "~%.0s" {1..70}; $(ECHO) "$(_D)\n"
override HEADER_1	:= $(ECHO) "$(_S)";		$(PRINTF) "\#%.0s" {1..72}; $(ECHO) "$(_D)\n"
override HEADER_2	:= $(ECHO) "$(_S)";		$(PRINTF) "\#%.0s" {1..36}; $(ECHO) "$(_D)\n"
ifneq ($(COMPOSER_ESCAPES),)
override TABLE_C2	:= $(PRINTF) "$(COMMENTED)%b\e[128D\e[22C%b$(_D)\n"
override TABLE_I3	:= $(PRINTF) "$(INDENTING)%b\e[128D\e[22C%b\e[128D\e[52C%b$(_D)\n"
override ESCAPE		:= $(PRINTF) "%b$(_D)\n"
else
override TABLE_C2	:= $(PRINTF) "$(COMMENTED)%-20s%s\n"
override TABLE_I3	:= $(PRINTF) "$(INDENTING)%-20s%-30s%s\n"
override ESCAPE		:= $(PRINTF) "%s\n"
endif

override EXAMPLE_SECOND	:= LICENSE
override EXAMPLE_TARGET	:= manual
override EXAMPLE_OUTPUT	:= Users_Guide

########################################

# thanks for the 'regex' fix below: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
#	also to: https://stackoverflow.com/questions/9691508/how-can-i-use-macros-to-generate-multiple-makefile-targets-rules-inside-foreach
#	also to: https://stackoverflow.com/questions/3063507/list-goals-targets-in-gnu-make
#	also to: http://backreference.org/2010/05/31/working-with-blocks-in-sed

.PHONY: $(MAKE_DB)
$(MAKE_DB):
	@$(RUNMAKE) \
		--silent \
		--question \
		--print-data-base \
		--no-builtin-rules \
		--no-builtin-variables \
		: 2>/dev/null | $(CAT)

.PHONY: $(LISTING)
$(LISTING):
	@$(RUNMAKE) --silent $(MAKE_DB) 2>/dev/null | \
		$(SED) -n -e "/^[#][ ]Files$$/,/^[#][ ]Finished[ ]Make[ ]data[ ]base/p" | \
		$(SED) -n -e "/^$(COMPOSER_ALL_REGEX)[:]/p" | \
		$(SORT)

#WORK : document!?
override $(LISTING_VAR) := \
	HELP[_] \
	EXAMPLE[_] \
	$(COMPOSER_TARGET)[:] \
	$(COMPOSER_PANDOC)[:] \
	$(NOTHING)[:] \
	$(HELPOUT)[:] \
	$(HELPALL)[:] \
	$(DEBUGIT)[:] \
	$(TARGETS)[:] \
	$(EXAMPLE)[:] \
	$(TESTING)[:] \
	$(INSTALL)[:-] \
	$(REPLICA)[:] \
	$(UPGRADE)[:] \
	$(ALLOFIT)[:-] \
	$(FETCHIT)[:-] \
	$(FETCHGO)[:-] \
	$(FETCHNO)[:-] \
	$(STRAPIT)[:-] \
	$(BUILDIT)[:-] \
	$(CHECKIT)[:] \
	$(TIMERIT)[:] \
	$(SHELLIT)[:-] \
	$(DOITALL)[:] \
	$(CLEANER)[:] \
	$(WHOWHAT)[:] \
	$(SETTING)[:] \
	$(SUBDIRS)[:] \
	$(PRINTER)[:]

.set_title-%:
ifneq ($(COMPOSER_ESCAPES),)
	@$(ECHO) "\e]0;$(MARKER) $(COMPOSER_FULLNAME) ($(*)) $(DIVIDE) $(CURDIR)\a"
else
	@$(ECHO) ""
endif

########################################

.DEFAULT_GOAL := $(HELPOUT)
.DEFAULT:
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_1)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) ERROR:"
	@$(TABLE_C2) "$(_N)Target '$(_C)$(@)$(_N)' is not defined."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "You either need to define this target, or call a target which is already defined."
	@$(TABLE_C2) "Use '$(_M)$(TARGETS)$(_D)' to get a list of available targets for this '$(MAKEFILE)'."
	@$(TABLE_C2) "Or, review the output of '$(_M)$(HELPOUT)$(_D)' and/or '$(_M)$(HELPALL)$(_D)' for more information."
	@$(HEADER_1)
	@exit 1

########################################

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
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(COMPOSER_FULLNAME)"
	@$(HEADER_1)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Usage:"
	@$(TABLE_I3) '$(_C)RUNMAKE$(_D) := $(_E)$(RUNMAKE)'
	@$(TABLE_I3) '$(_C)COMPOSE$(_D) := $(_E)$(COMPOSE)'
	@$(TABLE_I3) "$(_M)$(~)(RUNMAKE) [variables] <filename>.<extension>"
	@$(TABLE_I3) "$(_M)$(~)(COMPOSE) <variables>"
	@$(ECHO) "\n"

.PHONY: HELP_OPTIONS
HELP_OPTIONS:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Variables:"
	@$(TABLE_I3) "$(_C)TYPE$(_D) $(_E)(T, c_type)$(_D)"	"Desired output format"			"[$(_M)$(TYPE)$(_D)]"
	@$(TABLE_I3) "$(_C)BASE$(_D) $(_E)(B, c_base)$(_D)"	"Base of output file(s)"		"[$(_M)$(BASE)$(_D)]"
	@$(TABLE_I3) "$(_C)LIST$(_D) $(_E)(L, c_list)$(_D)"	"List of input files(s)"		"[$(_M)$(LIST)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Optional Variables:"
	@$(TABLE_I3) "$(_C)CSS$(_D) $(_E)(s, c_css)$(_D)"	"Location of CSS file"			"[$(_M)$(CSS)$(_D)] $(_N)(overrides '$(COMPOSER_CSS)')"
	@$(TABLE_I3) "$(_C)TTL$(_D) $(_E)(t, c_title)$(_D)"	"Document title prefix"			"[$(_M)$(TTL)$(_D)]"
	@$(TABLE_I3) "$(_C)TOC$(_D) $(_E)(c, c_contents)$(_D)"	"Table of contents depth"		"[$(_M)$(TOC)$(_D)]"
	@$(TABLE_I3) "$(_C)LVL$(_D) $(_E)(l, c_level)$(_D)"	"Chapter/slide header level"		"[$(_M)$(LVL)$(_D)]"
	@$(TABLE_I3) "$(_C)MGN$(_D) $(_E)(m, c_margin)$(_D)"	"Margin size ('$(TYPE_LPDF)' only)"	"[$(_M)$(MGN)$(_D)]"
	@$(TABLE_I3) "$(_C)FNT$(_D) $(_E)(f, c_font)$(_D)"	"Font size ('$(TYPE_LPDF)' only)"	"[$(_M)$(FNT)$(_D)]"
	@$(TABLE_I3) "$(_C)OPT$(_D) $(_E)(o, c_options)$(_D)"	"Custom Pandoc options"			"[$(_M)$(OPT)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Pre-Defined '$(_C)TYPE$(_H)' Values:"
	@$(TABLE_I3) "$(_C)$(TYPE_HTML)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_HTML)$(_D)"	"$(HTML_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_LPDF)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_LPDF)$(_D)"	"$(LPDF_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_PRES)$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_PRES)$(_D)"	"$(PRES_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_SHOW)$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_SHOW)$(_D)"	"$(SHOW_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_DOCX)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_DOCX)$(_D)"	"$(DOCX_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_EPUB)$(_D)"	"$(_N)*$(_D).$(_E)$(TYPE_EPUB)$(_D)"	"$(EPUB_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_TEXT)$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_TEXT)$(_D)"	"$(TEXT_DESC)"
	@$(TABLE_I3) "$(_C)$(TYPE_LINT)$(_D)"	"$(_N)*$(_D).$(_E)$(EXTN_LINT)$(_D)"	"$(LINT_DESC)"
	@$(TABLE_I3) "$(_M)Any other types specified will be passed directly through to Pandoc."
	@$(ECHO) "\n"

.PHONY: HELP_OPTIONS_SUB
HELP_OPTIONS_SUB:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "Following is the complete list of exposed/configurable variables:"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_GITREPO$(_D)"	"Source repository"		"[$(_M)$(COMPOSER_GITREPO)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_VERSION$(_D)"	"Version for cloning"		"[$(_M)$(COMPOSER_VERSION)$(_D)] $(_N)(valid: any Git tag or commit)"
	@$(TABLE_I3) "$(_C)COMPOSER_ESCAPES$(_D)"	"Enable color/title sequences"	"[$(_M)$(COMPOSER_ESCAPES)$(_D)] $(_N)(valid: empty or 1)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)File Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_STAMP$(_D)"		"Timestamp file"		"[$(_M)$(COMPOSER_STAMP)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_CSS$(_D)"		"Default CSS file"		"[$(_M)$(COMPOSER_CSS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_EXT$(_D)"		"Markdown file extension"	"[$(_M)$(COMPOSER_EXT)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_FILES$(_D)"		"List for '$(REPLICA)' target"	"[$(_M)$(COMPOSER_FILES)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Recursion Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_TARGETS$(_D)"	"Target list for '$(DOITALL)'"	"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_SUBDIRS$(_D)"	"Sub-directories list"		"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_DEPENDS$(_D)"	"Sub-directory dependency"	"[$(_M)$(COMPOSER_DEPENDS)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)COMPOSER_DEBUGIT$(_D)"	"Modifies '$(DEBUGIT)' target"	"[$(_M)$(COMPOSER_DEBUGIT)$(_D)] $(_N)(valid: any target) $(_E)(V, c_debug)"
	@$(TABLE_I3) "$(_C)COMPOSER_TESTING$(_D)"	"Modifies '$(TESTING)' target"	"[$(_M)$(COMPOSER_TESTING)$(_D)] $(_N)(valid: empty, 0 or 1)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Location Options:"
	@$(TABLE_I3) "$(_C)COMPOSER_OTHER$(_D)"		"Root of below directories"	"[$(_M)$(COMPOSER_OTHER)$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_ABODE$(_D)"		"Install/binary directory"	"[$(_M)$(subst $(COMPOSER_OTHER),$(~)(COMPOSER_OTHER),$(COMPOSER_ABODE))$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_STORE$(_D)"		"Source files directory"	"[$(_M)$(subst $(COMPOSER_OTHER),$(~)(COMPOSER_OTHER),$(COMPOSER_STORE))$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_TRASH$(_D)"		"Temporary directory"		"[$(_M)$(subst $(COMPOSER_OTHER),$(~)(COMPOSER_OTHER),$(COMPOSER_TRASH))$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_BUILD$(_D)"		"Build directory"		"[$(_M)$(subst $(COMPOSER_OTHER),$(~)(COMPOSER_OTHER),$(COMPOSER_BUILD))$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_PROGS$(_D)"		"Built binaries directory"	"[$(_M)$(subst $(COMPOSER_OTHER),$(~)(COMPOSER_OTHER),$(COMPOSER_PROGS))$(_D)]"
	@$(TABLE_I3) "$(_C)COMPOSER_PROGS_USE$(_D)"	"Prefer repository binaries"	"[$(_M)$(COMPOSER_PROGS_USE)$(_D)] $(_N)(valid: empty, 0 or 1)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Build Options:"
	@$(TABLE_I3) "$(_C)BUILD_FETCH$(_D)"		"Controls network usage"	"[$(_M)$(BUILD_FETCH)$(_D)] $(_N)(valid: empty, 0 or 1)"
	@$(TABLE_I3) "$(_C)BUILD_JOBS$(_D)"		"Thread count for large builds"	"[$(_M)$(BUILD_JOBS)$(_D)] $(_N)(valid: empty or [0-9]+) $(_E)(ideally = # CPUs/cores +1)"
	@$(TABLE_I3) "$(_C)BUILD_DIST$(_D)"		"Build generic binaries"	"[$(_M)$(BUILD_DIST)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)BUILD_PORT$(_D)"		"Build portable binaries"	"[$(_M)$(BUILD_PORT)$(_D)] $(_N)(valid: empty or 1)"
	@$(TABLE_I3) "$(_C)BUILD_PLAT$(_D)"		"Overrides 'uname -o'"		"[$(_M)$(BUILD_PLAT)$(_D)]"
	@$(TABLE_I3) "$(_C)BUILD_ARCH$(_D)"		"Overrides 'uname -m'"		"[$(_M)$(BUILD_ARCH)$(_D)] $(_E)($(BUILD_BITS)-bit)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Environment Options:"
	@$(TABLE_I3) "$(_C)MAKESHELL$(_D)"		"Shell script interpreter"	"[$(_M)$(SHELL)$(_D)]"
	@$(TABLE_I3) "$(_C)LANG$(_D)"			"Locale default language"	"[$(_M)$(LANG)$(_D)] $(_N)(NOTE: use UTF-8)"
	@$(TABLE_I3) "$(_C)TERM$(_D)"			"Terminfo terminal type"	"[$(_M)$(TERM)$(_D)]"
	@$(TABLE_I3) "$(_C)PATH$(_D)"			"Binary directories list"	"[$(_M)$(BUILD_PATH)$(_D)]"
	@$(TABLE_I3) "$(_C)CURL_CA_BUNDLE$(_D)"		"SSL certificate bundle"	"[$(_M)$(CURL_CA_BUNDLE)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "All of these can be set on the command line or in the environment."
	@$(ECHO) "\n"
	@$(ESCAPE) "To set them permanently, add them to the settings file (you may have to create it):"
	@$(TABLE_I3) "$(_M)$(COMPOSER_INCLUDE)"
	@$(ECHO) "\n"
	@$(ESCAPE) "All of these change the fundamental operation of $(COMPOSER_BASENAME), and should be used with care."
	@$(ECHO) "\n"

.PHONY: HELP_TARGETS
HELP_TARGETS:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Primary Targets:"
	@$(TABLE_I3) "$(_C)$(HELPOUT)$(_D)"		"Basic help output (default)"
	@$(TABLE_I3) "$(_C)$(HELPALL)$(_D)"		"Complete help output"
	@$(TABLE_I3) "$(_C)$(COMPOSER_TARGET)$(_D)"	"Main target used to build/format documents"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Helper Targets:"
	@$(TABLE_I3) "$(_C)$(DOITALL)$(_D)"		"Create all of the default output formats or configured targets"
	@$(TABLE_I3) "$(_C)$(CLEANER)$(_D)"		"Remove all of the default output files or configured targets"
	@$(TABLE_I3) "$(_C)$(PRINTER)$(_D)"		"List all source files newer than the '$(COMPOSER_STAMP)' timestamp file"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Diagnostic Targets:"
	@$(TABLE_I3) "$(_C)$(DEBUGIT)$(_D)"		"Runs several key sub-targets and commands, to provide all helpful information in one place"
	@$(TABLE_I3) "$(_C)$(TARGETS)$(_D)"		"Parse '$(MAKEFILE)' for all potential targets (for verification and/or troubleshooting)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Installation Targets:"
	@$(TABLE_I3) "$(_C)$(EXAMPLE)$(_D)"		"Print out example/template '$(MAKEFILE)' (helpful shortcut for creating recursive files)"
	@$(TABLE_I3) "$(_C)$(TESTING)$(_D)"		"Build example/test directory using all features and test/validate success"
	@$(TABLE_I3) "$(_C)$(INSTALL)$(_D)"		"Recursively create '$(MAKEFILE)' files (non-destructive build system initialization)"
	@$(TABLE_I3) "$(_C)$(REPLICA)$(_D)"		"Clone key components into current directory (for inclusion in content repositories)"
	@$(TABLE_I3) "$(_C)$(UPGRADE)$(_D)"		"Download/update all 3rd party components (need to do this at least once)"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Compilation Targets:"
	@$(TABLE_I3) "$(_C)$(ALLOFIT)$(_D)"		"Complete build with additional wrapping: $(FETCHIT), $(STRAPIT), $(BUILDIT), $(CHECKIT) & $(TIMERIT)"
	@$(TABLE_I3) "$(_C)$(FETCHIT)$(_D)"		"Download/update and prepare all source repositories and archives"
	@$(TABLE_I3) "$(_C)$(STRAPIT)$(_D)"		"Build/compile specific versions of essential libraries and tools"
	@$(TABLE_I3) "$(_C)$(BUILDIT)$(_D)"		"Build/compile specific versions of core tools necessary for $(COMPOSER_BASENAME) operation"
	@$(TABLE_I3) "$(_C)$(CHECKIT)$(_D)"		"Diagnostic version information (for verification and/or troubleshooting)"
	@$(TABLE_I3) "$(_C)$(TIMERIT)$(_D)"		"Lists all '$(BUILDIT)' targets and their completion timestamps"
	@$(TABLE_I3) "$(_C)$(SHELLIT)$(_D)"		"Launches into $(COMPOSER_BASENAME) sub-shell environment"
#WORKING:MACP $(SHELLIT)-macports?
	@$(TABLE_I3) "$(_C)$(SHELLIT)-msys$(_D)"	"Launches MSYS2 shell (for Windows) into $(COMPOSER_BASENAME) sub-shell environment"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Wildcard Targets:"
	@$(TABLE_I3) "$(_C)$(REPLICA)-$(_N)%$(_D)"	"$(_E)$(REPLICA) COMPOSER_VERSION=$(_N)*$(_D)"	""
	@$(ECHO) "\n"

.PHONY: HELP_TARGETS_SUB
HELP_TARGETS_SUB:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "These are all the rest of the sub-targets used by the main targets above:"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Dynamic Sub-Targets:"
	@$(TABLE_I3) "$(_C)$(DOITALL)$(_D)"		"$(_E)$(~)(COMPOSER_TARGETS)$(_D)"		"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(TABLE_I3) "$(_C)$(CLEANER)$(_D)"		"$(_E)$(~)(COMPOSER_TARGETS)-$(CLEANER)$(_D)"	"[$(_M)$(addsuffix -$(CLEANER),$(COMPOSER_TARGETS))$(_D)]"
	@$(TABLE_I3) "$(_C)$(SUBDIRS)$(_D)"		"$(_E)$(~)(COMPOSER_SUBDIRS)$(_D)"		"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Hidden Sub-Targets:"
	@$(TABLE_I3) "$(_C)$(_N)%$(_D)"			"$(_E).set_title-$(_N)*$(_D)"			"Set window title to current target using escape sequence"
	@$(TABLE_I3) "$(_C)$(DEBUGIT)$(_D)"		"$(_E)$(MAKE_DB)$(_D)"				"Output internal Make database, based on current '$(MAKEFILE)'"
	@$(TABLE_I3) "$(_C)$(TARGETS)$(_D)"		"$(_E)$(LISTING)$(_D)"				"Dynamically parse and print all potential targets"
	@$(TABLE_I3) "$(_C)$(EXAMPLE)$(_D)"		"$(_E).$(EXAMPLE)$(_D)"				"Prints raw template, with escape sequences"
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Static Sub-Targets:"
	@$(TABLE_I3) "$(_C)$(COMPOSER_TARGET)$(_D)"	"$(_E)$(COMPOSER_PANDOC)$(_D)"			"Wrapper target which calls Pandoc directly"
	@$(TABLE_I3) "$(_E)$(COMPOSER_PANDOC)$(_D)"	"$(_E)$(SETTING)$(_D)"				"Prints marker and variable values, for readability"
	@$(TABLE_I3) "$(_C)$(DOITALL)$(_D)"		"$(_E)$(WHOWHAT)$(_D)"				"Prints marker and variable values, for readability"
	@$(TABLE_I3) ""					"$(_E)$(SUBDIRS)$(_D)"				"Aggregates/runs the 'COMPOSER_SUBDIRS' targets"
	@$(TABLE_I3) "$(_C)$(INSTALL)$(_D)"		"$(_E)$(INSTALL)-dir$(_D)"			"Per-directory engine which does all the work"
	@$(TABLE_I3) "$(_C)$(ALLOFIT)$(_D)"		"$(_E)$(ALLOFIT)-check$(_D)"			"Tries to proactively prevent common errors"
#WORKING:NOW
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-macports-init$(_D)"		"Installs/initializes MacPorts environment (for Mac OS X)"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-macports$(_D)"			"Installs/updates MacPorts packages"
#WORKING:NOW
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-msys-init$(_D)"		"Installs/initializes MSYS2/MinGW-w64 environment (for Windows)"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-msys$(_D)"			"Installs/updates MSYS2/MinGW-w64 packages"
#WORKING:NOW
	@$(TABLE_I3) ""					"$(_E)$(ALLOFIT)-bindir$(_D)"			"Copies compiled binaries to repository binaries directory"
#WORK : ALLOFIT could maybe stand to be documented more completely...
	@$(TABLE_I3) "$(_C)$(STRAPIT)$(_D)"		"$(_E)$(BUILDIT)-gnu-init$(_D)"			"Fetches current Gnu.org configuration files/scripts"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-group-libs$(_D)"		"Build/compile of necessary libraries from source archives"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-group-util$(_D)"		"Build/compile of necessary utilities from source archives"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-group-tool$(_D)"		"Build/compile of helpful tools from source archives"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-group-core$(_D)"		"Build/compile of core tools from source archives"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-group-init$(_D)"		"Build/compile of WORKING:NOW from source archives"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-group-libs$(_D)"	"$(_E)$(BUILDIT)-libiconv-init$(_D)"		"Build/compile of Libiconv (before Gettext) from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-gettext$(_D)"			"Build/compile of Gettext from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-libiconv$(_D)"			"Build/compile of Libiconv (after Gettext) from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-pkgconfig$(_D)"		"Build/compile of Pkg-config from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-zlib$(_D)"			"Build/compile of Zlib from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-gmp$(_D)"			"Build/compile of GMP from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-ncurses$(_D)"			"Build/compile of Ncurses from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-openssl$(_D)"			"Build/compile of OpenSSL from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-gdbm$(_D)"			"Build/compile of GNU DBM from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-expat$(_D)"			"Build/compile of Expat from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-png$(_D)"			"Build/compile of LibPNG from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-freetype$(_D)"			"Build/compile of FreeType from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-fontconfig$(_D)"		"Build/compile of Fontconfig from source archive"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-group-util$(_D)"	"$(_E)$(BUILDIT)-coreutils$(_D)"		"Build/compile of GNU Coreutils from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-findutils$(_D)"		"Build/compile of GNU Findutils from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-patch$(_D)"			"Build/compile of GNU Patch from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-sed$(_D)"			"Build/compile of GNU Sed from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-bzip$(_D)"			"Build/compile of Bzip2 from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-gzip$(_D)"			"Build/compile of Gzip from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-xz$(_D)"			"Build/compile of XZ Utils from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-tar$(_D)"			"Build/compile of GNU Tar from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-perl$(_D)"			"Build/compile of Perl from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-python$(_D)"			"Build/compile of Python from source archive"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-perl$(_D)"	"$(_E)$(BUILDIT)-perl-modules$(_D)"		"Build/compile of Perl modules from source archives"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-group-tool$(_D)"	"$(_E)$(BUILDIT)-bash$(_D)"			"Build/compile of GNU Bash from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-less$(_D)"			"Build/compile of Less from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-vim$(_D)"			"Build/compile of Vim from source archive"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-group-core$(_D)"	"$(_E)$(BUILDIT)-make-init$(_D)"		"Build/compile of GNU Make from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-infozip$(_D)"			"Build/compile of Info-ZIP from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-curl$(_D)"			"Build/compile of cURL from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-git$(_D)"			"Build/compile of Git from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-rsync$(_D)"			"Build/compile of Rsync from source archive"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-group-init$(_D)"	"$(_E)$(BUILDIT)-ghc-init$(_D)"			"Build/complie of GHC from source archive"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-cabal-init$(_D)"		"Build/complie of Cabal from source archive"
	@$(TABLE_I3) "$(_C)$(BUILDIT)$(_D)"		"$(_E)$(BUILDIT)-gnu$(_D)"			"Fetches current Gnu.org configuration files/scripts"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-make$(_D)"			"Build/compile of GNU Make from source repository"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-node$(_D)"			"Build/compile of Node.js from source repository"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-texlive$(_D)"			"Build/compile of TeX Live from source archives"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-ghc$(_D)"			"Build/compile of GHC from source repository"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-cabal$(_D)"			"Build/compile of Cabal from source repository"
	@$(TABLE_I3) ""					"$(_E)$(BUILDIT)-pandoc$(_D)"			"Build/compile of Pandoc(-CiteProc) from source repository"
	@$(TABLE_I3) "$(_E)$(BUILDIT)-texlive$(_D)"	"$(_E)$(BUILDIT)-texlive-fmtutil$(_D)"		"Build/install TeX Live format files"
	@$(TABLE_I3) "$(_C)$(SHELLIT)[-msys]$(_D)"	"$(_E)$(SHELLIT)-bashrc$(_D)"			"Initializes GNU Bash configuration file"
	@$(TABLE_I3) ""					"$(_E)$(SHELLIT)-vimrc$(_D)"			"Initializes Vim configuration file"
	@$(ECHO) "\n"
	@$(ESCAPE) "These do not need to be used directly during normal use, and are only documented for completeness."
	@$(ECHO) "\n"

.PHONY: HELP_COMMANDS
HELP_COMMANDS:
	@$(HEADER_1)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Command Examples:"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Have the system do all the work:"
	@$(ESCAPE) "$(_M)$(~)(RUNMAKE) $(BASE).$(EXTENSION)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Be clear about what is wanted (or, for multiple or differently named input files):"
	@$(ESCAPE) "$(_M)$(~)(COMPOSE) LIST=\"$(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
#WORKING:NOW: add "make all COMPOSER_TARGETS=[...]" example
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILES
EXAMPLE_MAKEFILES: \
	EXAMPLE_MAKEFILES_HEADER \
	EXAMPLE_MAKEFILE_1 \
	EXAMPLE_MAKEFILE_2 \
	EXAMPLE_MAKEFILES_FOOTER

.PHONY: EXAMPLE_MAKEFILES_HEADER
EXAMPLE_MAKEFILES_HEADER:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Calling from children '$(MAKEFILE)' files:"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE_1
EXAMPLE_MAKEFILE_1:
	@$(TABLE_C2) "$(_E)Simple, with filename targets and \"automagic\" detection of them:"
	@$(TABLE_C2) "$(_S)include $(COMPOSER)"
	@$(ESCAPE) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TARGET)"
	@$(ESCAPE) "$(_C)$(BASE)$(_D): $(_N)# so \"$(CLEANER)\" will catch the below files"
	@$(ESCAPE) "$(_C)$(EXAMPLE_TARGET)$(_D): $(BASE).$(TYPE_HTML) $(BASE).$(TYPE_LPDF)"
	@$(ESCAPE) "$(_C)$(EXAMPLE_SECOND).$(EXTENSION)$(_D):"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE_2
EXAMPLE_MAKEFILE_2:
	@$(TABLE_C2) "$(_E)Advanced, with manual enumeration of user-defined targets and per-target variables:"
	@$(ESCAPE) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE) $(EXAMPLE_TARGET) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(TABLE_C2) "$(_S)include $(COMPOSER)"
	@$(ESCAPE) "$(_C).PHONY$(_D): $(BASE) $(EXAMPLE_TARGET)"
	@$(ESCAPE) "$(_C)$(BASE)$(_D): export TOC := 1"
	@$(ESCAPE) "$(_C)$(BASE)$(_D): $(BASE).$(EXTENSION)"
	@$(ESCAPE) "$(_C)$(EXAMPLE_TARGET)$(_D): $(BASE).$(COMPOSER_EXT) $(EXAMPLE_SECOND).$(COMPOSER_EXT)"
	@$(ESCAPE) "	$(~)(COMPOSE) --silent LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_HTML)\""
	@$(ESCAPE) "	$(~)(COMPOSE) --silent LIST=\"$(~)(^)\" BASE=\"$(EXAMPLE_OUTPUT)\" TYPE=\"$(TYPE_LPDF)\""
	@$(ESCAPE) "$(_C)$(EXAMPLE_TARGET)-$(CLEANER)$(_D):"
	@$(ESCAPE) "	$(~)(RM) $(EXAMPLE_OUTPUT).{$(TYPE_HTML),$(TYPE_LPDF)}"
	@$(ECHO) "#WORK : document this version of '$(CLEANER)'?\n"
	@$(ECHO) "#WORK : 2017-07-31 : nope, this should be $(CLEANER): $(notdir $(RELEASE_MAN_DST))-clean, and skip the TYPE business\n"
	@$(ECHO) "#WORK : make $(RELEASE)-debug\n"
	@$(ESCAPE) "$(_C)$(CLEANER)$(_D): COMPOSER_TARGETS += $(notdir $(RELEASE_MAN_DST))"
	@$(ESCAPE) "$(_C)$(CLEANER)$(_D): TYPE := latex"
	@$(ESCAPE) "$(_C)$(notdir $(RELEASE_MAN_DST)):"
	@$(ESCAPE) "	$(~)(CP) \"$(COMPOSER_DIR)/$(notdir $(RELEASE_MAN_DST)).\"* ./"
	@$(ECHO) "#WORK\n"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILES_FOOTER
EXAMPLE_MAKEFILES_FOOTER:
	@$(TABLE_C2) "$(_E)Then, from the command line:"
	@$(ESCAPE) "$(_M)make $(CLEANER) && make $(DOITALL)"
	@$(ECHO) "\n"

.PHONY: HELP_SYSTEM
HELP_SYSTEM: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
HELP_SYSTEM:
	@$(HEADER_1)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Completely recursive build system:"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)The top-level '$(MAKEFILE)' is the only one which needs a direct reference:"
	@$(TABLE_C2) "$(_N)(NOTE: This must be an absolute path.)"
	@$(ESCAPE) "include $(COMPOSER)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)All sub-directories then each start with:"
	@$(ESCAPE) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(ESCAPE) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(COMPOSER_TEACHER)"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?="
	@$(ESCAPE) "$(_C).DEFAULT_GOAL$(_D) := $(_C)$(DOITALL)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)And end with:"
	@$(ESCAPE) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Back in the top-level '$(MAKEFILE)', and in all sub-'$(MAKEFILE)' instances which recurse further down:"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(ESCAPE) "include [...]"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Create a new '$(MAKEFILE)' using a helpful template:"
	@$(ESCAPE) "$(_M)$(~)(RUNMAKE) COMPOSER_TARGETS=\"$(BASE).$(EXTENSION)\" $(EXAMPLE) >$(MAKEFILE)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_E)Or, recursively initialize the current directory tree:"
	@$(TABLE_C2) "$(_N)(NOTE: This is a non-destructive operation.)"
	@$(ESCAPE) "$(_M)$(~)(RUNMAKE) $(INSTALL)"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE
EXAMPLE_MAKEFILE: \
	EXAMPLE_MAKEFILE_HEADER \
	EXAMPLE_MAKEFILE_FULL \
	EXAMPLE_MAKEFILE_TEMPLATE

.PHONY: EXAMPLE_MAKEFILE_HEADER
EXAMPLE_MAKEFILE_HEADER:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)Finally, a completely recursive '$(MAKEFILE)' example:"
	@$(ECHO) "\n"

.PHONY: EXAMPLE_MAKEFILE_FULL
EXAMPLE_MAKEFILE_FULL: export COMPOSER_SUBDIRS = $(TEST_FULLMK_SUB)
EXAMPLE_MAKEFILE_FULL:
	@$(TABLE_C2) "$(_H)$(MARKER) HEADERS"
	@$(TABLE_C2) "$(_E)These two statements must be at the top of every file:"
	@$(TABLE_C2) "$(_N)(NOTE: The 'COMPOSER_TEACHER' variable can be modified for custom chaining, but with care.)"
	@$(ESCAPE) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(ESCAPE) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(COMPOSER_TEACHER)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) DEFINITIONS"
	@$(TABLE_C2) "$(_E)These statements are also required:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Use '?=' declarations and define *before* the upstream 'include' statement"
	@$(TABLE_C2) "$(_E)$(INDENTING)* They pass their values *up* the '$(MAKEFILE)' chain"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Should always be defined, even if empty, to prevent downward propagation of values"
	@$(TABLE_C2) "$(_N)(NOTE: List of '$(DOITALL)' targets is '$(COMPOSER_ALL_REGEX)' if '$(~)(COMPOSER_TARGETS)' is empty.)"
	@$(ESCAPE) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(BASE).$(EXTENSION) $(EXAMPLE_SECOND).$(EXTENSION)"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(ESCAPE) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) VARIABLES"
	@$(TABLE_C2) "$(_E)The option variables are not required, but are available for locally-scoped configuration:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* For proper inheritance, use '?=' declarations and define *before* the upstream 'include' statement"
	@$(TABLE_C2) "$(_E)$(INDENTING)* They pass their values *down* the '$(MAKEFILE)' chain"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Do not need to be defined when empty, unless necessary to override upstream values"
	@$(TABLE_C2) "$(_E)To disable inheritance and/or insulate from environment variables:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Replace 'override VAR ?=' with 'override VAR :='"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Define *after* the upstream 'include' statement"
	@$(TABLE_C2) "$(_N)(NOTE: Any settings here will apply to all children, unless 'override' is used downstream.)"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)Define the CSS template to use in this entire directory tree:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Absolute path names should be used, so that children will be able to find it"
	@$(TABLE_C2) "$(_E)$(INDENTING)$(INDENTING)* The 'COMPOSER_ABSPATH' variable can be used to simplify this"
	@$(TABLE_C2) "$(_E)$(INDENTING)* If not defined, the lowest-level '$(COMPOSER_CSS)' file will be used"
	@$(TABLE_C2) "$(_E)$(INDENTING)* If not defined, and no '$(COMPOSER_CSS)' file can be found, will use default CSS file"
	@$(ESCAPE) "$(~)(eval override $(_C)CSS$(_D) ?= $(_C)$(~)(COMPOSER_ABSPATH)/$(COMPOSER_CSS)$(_D))"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)All the other optional variables can also be made global in this directory scope:"
	@$(ESCAPE) "override $(_C)TTL$(_D) ?="
	@$(ESCAPE) "override $(_C)TOC$(_D) ?= $(_C)2"
	@$(ESCAPE) "override $(_C)LVL$(_D) ?= $(_C)$(LVL)"
	@$(ESCAPE) "override $(_C)MGN$(_D) ?= $(_C)$(MGN)"
	@$(ESCAPE) "override $(_C)FNT$(_D) ?= $(_C)$(FNT)"
	@$(ESCAPE) "override $(_C)OPT$(_D) ?="
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) INCLUDE"
	@$(TABLE_C2) "$(_E)Necessary include statement:"
	@$(TABLE_C2) "$(_N)(NOTE: This must be after all references to 'COMPOSER_ABSPATH' but before '.DEFAULT_GOAL'.)"
	@$(ESCAPE) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(TABLE_C2) ""
	@$(TABLE_C2) "$(_E)For recursion to work, a default target needs to be defined:"
	@$(TABLE_C2) "$(_E)$(INDENTING)* Needs to be '$(DOITALL)' for directories which must recurse into sub-directories"
	@$(TABLE_C2) "$(_E)$(INDENTING)* The '$(SUBDIRS)' target can be used manually, if desired, so this can be changed to another value"
	@$(TABLE_C2) "$(_N)(NOTE: Recursion will cease if not '$(DOITALL)', unless '$(SUBDIRS)' target is called.)"
	@$(ESCAPE) "$(_C).DEFAULT_GOAL$(_D) := $(_C)$(DOITALL)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) RECURSION"
	@$(TABLE_C2) "$(_E)Dependencies can be specified, if needed:"
	@$(TABLE_C2) "$(_N)(NOTE: This defines the sub-directories which must be built before '$(firstword $(COMPOSER_SUBDIRS))'.)"
	@$(TABLE_C2) "$(_N)(NOTE: For parent/child directory dependencies, set 'COMPOSER_DEPENDS' to a non-empty value.)"
	@$(ESCAPE) "$(_C)$(firstword $(COMPOSER_SUBDIRS))$(_D): $(_C)$(wordlist 2,$(words $(COMPOSER_SUBDIRS)),$(COMPOSER_SUBDIRS))"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) MAKEFILE"
	@$(TABLE_C2) "$(_E)This is where the rest of the file should be defined."
	@$(TABLE_C2) "$(_N)(NOTE: In this example, 'COMPOSER_TARGETS' is used completely in lieu of any explicit targets.)"
	@$(ECHO) "\n"

.PHONY: .$(EXAMPLE)
.$(EXAMPLE):
	@$(TABLE_C2) "$(_H)$(MARKER) HEADERS"
	@$(ESCAPE) "override $(_C)COMPOSER_ABSPATH$(_D) := $(_C)$(COMPOSER_ABSPATH)"
	@$(ESCAPE) "override $(_C)COMPOSER_TEACHER$(_D) := $(_C)$(COMPOSER_TEACHER)"
#WORKING:NOW : first step towards templatized includes?
#WORKING:NOW : why this, again?  2017-07-31
#WORKING:NOW : 2017-08-01 oh, because COMPOSER_ABSPATH gets reset to the unexpanded variable when this core Makefile gets included below
#WORKING:NOW : 2017-08-01 should probably do COMPOSER_ABSPATH/COMPOSER_CURDIR and COMPOSER_TEACHER/COMPOSER_MASTER instead (and maybe replace all CURDIR with before?  probably not, but think it over once more...)
	@$(ESCAPE) "override $(_C)COMPOSER_FULLDIR$(_D) := $(~)(COMPOSER_ABSPATH)"
	@$(ECHO) "\n"
#WORKING:NOW : templatized includes : replace from here to INCLUDE with seamless include of COMPOSER_SETTINGS, akin to COMPOSER_INCLUDE
#WORKING:NOW : template then needs to be the below instead, and there needs to be a new template-something for the default
#WORKING:NOW : implications?  will only be able to send input into composer, not use variables set by it...  others?
#WORKING:NOW 2017-07-31
#WORKING:NOW : .composer.settings.mk = before include
#WORKING:NOW : .composer.mk = after include
#WORKING:NOW : will require note about some of the above hacking options for inheritance in VARIABLES...  elsewhere?
	@$(TABLE_C2) "$(_H)$(MARKER) DEFINITIONS"
	@$(ESCAPE) "override $(_C)COMPOSER_TARGETS$(_D) ?= $(_C)$(COMPOSER_TARGETS)"
	@$(ESCAPE) "override $(_C)COMPOSER_SUBDIRS$(_D) ?= $(_C)$(COMPOSER_SUBDIRS)"
	@$(ESCAPE) "override $(_C)COMPOSER_DEPENDS$(_D) ?= $(_C)$(COMPOSER_DEPENDS)"
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) VARIABLES"
	@$(TABLE_C2) "$(_E)$(~)(eval override CSS ?= $(~)(COMPOSER_ABSPATH)/$(COMPOSER_CSS))"
	@$(TABLE_C2) "$(_E)override TTL ?="
	@$(TABLE_C2) "$(_E)override TOC ?="
	@$(TABLE_C2) "$(_E)override LVL ?="
	@$(TABLE_C2) "$(_E)override MGN ?="
	@$(TABLE_C2) "$(_E)override FNT ?="
	@$(TABLE_C2) "$(_E)override OPT ?="
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) INCLUDE"
	@$(ESCAPE) "include $(_C)$(~)(COMPOSER_TEACHER)"
	@$(ESCAPE) "$(_C).DEFAULT_GOAL$(_D) := $(_C)$(DOITALL)"
#WORKING:NOW : templatized includes : remove from here down
	@$(ECHO) "\n"
	@$(TABLE_C2) "$(_H)$(MARKER) MAKEFILE"
	@$(TABLE_C2) "$(_N)(Contents of file go here.)"

.PHONY: EXAMPLE_MAKEFILE_TEMPLATE
EXAMPLE_MAKEFILE_TEMPLATE:
	@$(HEADER_2)
	@$(ECHO) "\n"
	@$(ESCAPE) "$(_H)With the current settings, the output of '$(EXAMPLE)' would be:"
	@$(ECHO) "\n"
	@$(RUNMAKE) --silent .$(EXAMPLE)
	@$(ECHO) "\n"

.PHONY: HELP_FOOTER
HELP_FOOTER:
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)Happy Hacking!"
	@$(HEADER_1)

########################################

.PHONY: $(DEBUGIT)
$(DEBUGIT): .set_title-$(DEBUGIT)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_DEBUGIT$(_D)"	"[$(_M)$(COMPOSER_DEBUGIT)$(_D)]"
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) DEBUG:"
	@$(TABLE_C2) "$(_N)This is the output of the '$(_C)debug$(_N)' target."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "This target runs several key sub-targets and diagnostic commands."
	@$(TABLE_C2) "The goal is to provide all needed troubleshooting information in one place."
	@$(TABLE_C2) "Set the '$(_M)COMPOSER_DEBUGIT$(_D)' variable to troubleshoot a particular list of targets $(_E)(they may be run)$(_D)."
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,HELP_HEADER HELP_OPTIONS HELP_OPTIONS_SUB)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H) Diagnostics"
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,$(CHECKIT))
	@$(ECHO) "\n"
	@$(HEADER_2)
	@$(call DEBUGIT_TARGET,$(TIMERIT))
	@$(ECHO) "\n"
	@$(HEADER_2)
	@$(call DEBUGIT_TARGET,$(TARGETS))
	@$(ECHO) "\n"
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H) Targets Debug"
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,--debug="a" --just-print $(COMPOSER_DEBUGIT))
	@$(ECHO) "\n"
	@$(foreach FILE,$(MAKEFILE_LIST),\
		$(call DEBUGIT_CONTENTS,$(FILE)); \
		$(ECHO) "\n"; \
	)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H) Make Database Dump"
	@$(HEADER_1)
	@$(call DEBUGIT_TARGET,$(MAKE_DB))
	@$(call DEBUGIT_LISTING,NULL,DIR)
	@$(call DEBUGIT_LISTING,DIR,OTHER)
	@$(call DEBUGIT_LISTING,OTHER,ABODE)
	@$(call DEBUGIT_LISTING,OTHER,STORE)
	@$(call DEBUGIT_LISTING,OTHER,BUILD)
	@$(call DEBUGIT_LISTING,OTHER,PROGS)
	@$(RUNMAKE) --silent HELP_FOOTER

override define DEBUGIT_TARGET =
	$(ECHO) "\n"; \
	$(RUNMAKE) --silent $(1)
endef
override define DEBUGIT_LISTING =
	if [ "$(COMPOSER_$(2))" == "$(subst $(COMPOSER_$(1)),,$(COMPOSER_$(2)))" ]; then \
		$(HEADER_1); \
		$(TABLE_C2) "$(_H) Directory Listing: COMPOSER_$(2)"; \
		$(HEADER_1); \
		$(ECHO) "\n"; \
		$(LS) -R "$(COMPOSER_$(2))"; \
		$(ECHO) "\n"; \
	fi
endef
override define DEBUGIT_CONTENTS =
	if [ -f "$(1)" ]; then \
		$(HEADER_L); \
		$(TABLE_I3) "$(_H)$(MARKER) $(_M)$(1)"; \
		$(HEADER_L); \
		$(CAT) "$(1)"; \
	fi
endef

.PHONY: $(TARGETS)
$(TARGETS): .set_title-$(TARGETS)
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_H)Targets$(_D) $(DIVIDE) $(_M)$(COMPOSER_SRC)"
	@$(HEADER_L)
	@$(ECHO) "$(_C)"
	@$(RUNMAKE) --silent $(LISTING) | $(SED) \
		$(foreach FILE,$($(LISTING_VAR)),\
			-e "/^$(FILE)/d" \
		) \
		-e "/^[^:]*[.]$(COMPOSER_EXT)[:]/d" \
		-e "/^$$/d"
	@$(HEADER_L)
	@$(TABLE_I3) "$(_H)$(MARKER) $(DOITALL)"; $(ECHO) "$(COMPOSER_TARGETS)"					| $(SED) "s|[ ]|\n|g" | $(SORT)
#WORK : 2017-07-31 : this should report "$(CLEANER): [...]" additions, as well, using similar "$(LISTING)" hack above...
	@$(TABLE_I3) "$(_H)$(MARKER) $(CLEANER)"; $(ECHO) "$(addsuffix -$(CLEANER),$(COMPOSER_TARGETS))"	| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(TABLE_I3) "$(_H)$(MARKER) $(SUBDIRS)"; $(ECHO) "$(COMPOSER_SUBDIRS)"					| $(SED) "s|[ ]|\n|g" | $(SORT)
	@$(HEADER_L)
	@$(RUNMAKE) --silent $(PRINTER)

########################################

.PHONY: $(EXAMPLE)
$(EXAMPLE):
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= .$(EXAMPLE)

override TEST_DIRECTORIES	:= \
	$(TESTING_DIR) \
	$(TESTING_DIR)/subdir1 \
	$(TESTING_DIR)/subdir1/example1 \
	$(TESTING_DIR)/subdir2 \
	$(TESTING_DIR)/subdir2/example2
override TEST_DIR_CSSDST	:= $(word 4,$(TEST_DIRECTORIES))
override TEST_DIR_DEPEND	:= $(word 2,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_1	:= $(word 3,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_2	:= $(word 5,$(TEST_DIRECTORIES))
override TEST_DIR_MAKE_F	:= $(word 1,$(TEST_DIRECTORIES))
override TEST_DEPEND_SUB	:= example1
override TEST_FULLMK_SUB	:= subdir1 subdir2

.PHONY: $(TESTING)
$(TESTING): .set_title-$(TESTING)
	@$(foreach FILE,$(TEST_DIRECTORIES),\
		$(MKDIR) "$(FILE)"; \
		$(CP) \
			"$(COMPOSER_DIR)/"*.$(COMPOSER_EXT) \
			"$(COMPOSER_DIR)/"*.$(COMPOSER_IMG) \
			"$(FILE)/"; \
	)
	@$(CP) "$(MDVIEWER_CSS)" "$(TEST_DIR_CSSDST)/$(COMPOSER_CSS)"
	@$(RUNMAKE) --directory "$(TESTING_DIR)" $(INSTALL)
ifneq ($(COMPOSER_TESTING),0)
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_SUBDIRS="$(TEST_DEPEND_SUB)" COMPOSER_DEPENDS="1" $(EXAMPLE) >"$(TEST_DIR_DEPEND)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= EXAMPLE_MAKEFILE_1 >"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= EXAMPLE_MAKEFILE_2 >"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_TARGETS= COMPOSER_SUBDIRS= $(EXAMPLE) >>"$(TEST_DIR_MAKE_1)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_TARGETS= COMPOSER_SUBDIRS= $(EXAMPLE) >>"$(TEST_DIR_MAKE_2)/$(MAKEFILE)"
	@$(RUNMAKE) --silent COMPOSER_ESCAPES= COMPOSER_SUBDIRS="$(TEST_FULLMK_SUB)" EXAMPLE_MAKEFILE_FULL >"$(TEST_DIR_MAKE_F)/$(MAKEFILE)"
endif
	@$(MKDIR) "$(TESTING_DIR)/$(COMPOSER_BASENAME)"
#WORKING:NOW	@$(RUNMAKE) --directory "$(TESTING_DIR)/$(COMPOSER_BASENAME)" $(REPLICA)
ifeq ($(COMPOSER_TESTING),-1)
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1\$$(COMPOSER_ABSPATH)/$(COMPOSER_BASENAME)/$(MAKEFILE)|g" "$(TESTING_DIR)/$(MAKEFILE)"
endif
	@$(MAKE) --directory "$(TESTING_DIR)"
ifneq ($(COMPOSER_TESTING),)
	@$(foreach FILE,$(TEST_DIRECTORIES),\
		$(ECHO) "\n"; \
		$(call DEBUGIT_CONTENTS,$(FILE)/$(MAKEFILE)); \
	)
endif

.PHONY: $(INSTALL)
$(INSTALL): .set_title-$(INSTALL)
$(INSTALL): $(INSTALL)-dir
	@$(SED) -i "s|^(override[ ]COMPOSER_TEACHER[ ][:][=][ ]).+$$|\1$(COMPOSER)|g" "$(CURDIR)/$(MAKEFILE)"

.PHONY: $(INSTALL)-dir
$(INSTALL)-dir:
	@if [ -f "$(CURDIR)/$(MAKEFILE)" ]; then \
		$(TABLE_I3) "$(_H)$(MARKER) $(_N)Skipping$(_D) $(DIVIDE) $(_E)$(CURDIR)/$(MAKEFILE)"; \
	else \
		$(TABLE_I3) "$(_H)$(MARKER) $(_H)Creating$(_D) $(DIVIDE) $(_M)$(CURDIR)/$(MAKEFILE)"; \
		$(RUNMAKE) --silent \
			COMPOSER_ESCAPES= \
			COMPOSER_TARGETS="$(sort $(subst .$(COMPOSER_EXT),.$(TYPE_HTML),$(wildcard *.$(COMPOSER_EXT))))" \
			COMPOSER_SUBDIRS="$(sort $(subst /,,$(wildcard */)))" \
			COMPOSER_DEPENDS="$(COMPOSER_DEPENDS)" \
			$(EXAMPLE) >"$(CURDIR)/$(MAKEFILE)"; \
	fi
	@$(foreach FILE,$(sort $(subst /,,$(wildcard */))),\
		$(RUNMAKE) --silent --directory "$(CURDIR)/$(FILE)" $(INSTALL)-dir; \
	)

$(REPLICA)-%:
	@$(RUNMAKE) --silent --directory "$(CURDIR)" \
		COMPOSER_VERSION="$(*)" \
		$(REPLICA)

.PHONY: $(REPLICA)
$(REPLICA): .set_title-$(REPLICA)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_VERSION$(_D)"	"[$(_M)$(COMPOSER_VERSION)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_FILES$(_D)"		"[$(_M)$(COMPOSER_FILES)$(_D)]"
	@$(HEADER_1)
	@if [ ! -d "$(REPLICA_GIT_DIR)" ]; then \
		$(MKDIR) "$(abspath $(dir $(REPLICA_GIT_DIR)))"; \
		$(REPLICA_GIT) init --bare; \
		$(REPLICA_GIT) remote add origin "$(COMPOSER_GITREPO)"; \
	fi
	@$(REPLICA_GIT) remote remove origin
	@$(REPLICA_GIT) remote add origin "$(COMPOSER_GITREPO)"
	@$(REPLICA_GIT) fetch --all
	@$(ECHO) "$(_C)"
	@$(REPLICA_GIT) archive \
		--format="tar" \
		--prefix= \
		"$(COMPOSER_VERSION)" \
		$(foreach FILE,$(COMPOSER_FILES),"$(FILE)") \
		| \
		$(TAR) -C "$(CURDIR)" -f -
	@$(ECHO) "$(_E)"
	@if [ -f "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" ] && \
	    [ "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" != "$(CURDIR)/$(COMPOSER_SETTINGS)" ]; then \
		$(CP) "$(COMPOSER_DIR)/$(COMPOSER_SETTINGS)" "$(CURDIR)/$(COMPOSER_SETTINGS)"; \
	fi
	@$(DATESTAMP) >"$(CURDIR)/.$(COMPOSER_BASENAME).$(REPLICA)"
	@$(ECHO) "$(_D)"

.PHONY: $(UPGRADE)
$(UPGRADE): .set_title-$(UPGRADE)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_1)
	@$(call GIT_REPO,$(MDEDITOR_DST),$(MDEDITOR_SRC),$(MDEDITOR_CMT))
	@$(call GIT_REPO,$(MDVIEWER_DST),$(MDVIEWER_SRC),$(MDVIEWER_CMT))
#WORK	@$(call GIT_REPO,$(MARKDOWN_DST),$(MARKDOWN_SRC),$(MARKDOWN_CMT))
	@$(ECHO) "$(_C)"
#WORK
#	@cd "$(MDVIEWER_DST)" && \
#		$(NPM_RUN) install && \
#		$(NPM_RUN) run-script build:prism && \
#		$(NPM_RUN) run-script build:mdc
#WORK
#WORK: big problem! will not be able to run $(UPGRADE) out of $(COMPOSER_PROGS) now...
#	@if [ -f "$(COMPOSER_STORE)/phantomjs-"*".tar.bz2" ]; then \
#		$(foreach FILE,\
#			"$(MARKDOWN_DST)/node_modules/phantomjs/phantomjs" \
#			"$(MARKDOWN_DST)/node_modules/a11y/node_modules/phantomjs/phantomjs" \
#			"$(MARKDOWN_DST)/node_modules/uncss/node_modules/phantomjs/phantomjs" \
#			,\
#			$(MKDIR) $(FILE); \
#			$(RSYNC) "$(COMPOSER_STORE)/phantomjs-"*".tar.bz2" $(FILE)/; \
#		) \
#	fi
#	@cd "$(MARKDOWN_DST)" && \
#		$(NPM_RUN) update && \
#		$(NPM_RUN) install
#	@if [ -f "$(MARKDOWN_DST)/node_modules/phantomjs/phantomjs/phantomjs-"*".tar.bz2" ]; then \
#		$(MKDIR) "$(COMPOSER_STORE)"; \
#		$(RSYNC) "$(MARKDOWN_DST)/node_modules/phantomjs/phantomjs/phantomjs-"*".tar.bz2" "$(COMPOSER_STORE)/"; \
#	fi
#	@cd "$(MARKDOWN_DST)" && \
#		$(BUILD_ENV) "$(MARKDOWN_DST)/node_modules/gulp/bin/gulp.js"
#WORK
	@$(ECHO) "$(_D)"
	@$(call GIT_REPO,$(REVEALJS_DST),$(REVEALJS_SRC),$(REVEALJS_CMT))
	@$(call CURL_FILE,$(W3CSLIDY_SRC))
	@$(ECHO) "$(_E)"
	@$(call DO_UNZIP,$(W3CSLIDY_DST),$(W3CSLIDY_SRC))
	@$(ECHO) "$(_D)"

#WORK: totally experimental targets for using markdown-editor
.PHONY: WORK_MDEDITOR_EDIT
override MDEDITOR_EDIT_PERL = use strict; use warnings;
override MDEDITOR_EDIT_PERL += use MIME::Base64;
override MDEDITOR_EDIT_PERL += use IO::Compress::RawDeflate qw(rawdeflate);
override MDEDITOR_EDIT_PERL += my $$input = "$(LIST)";
override MDEDITOR_EDIT_PERL += my $$output;
override MDEDITOR_EDIT_PERL += rawdeflate "$(LIST)" => \$${output};
override MDEDITOR_EDIT_PERL += $$output = encode_base64($${output}, "");
override MDEDITOR_EDIT_PERL += print "file://$(MDEDITOR_DST)/index.html\#$${output}\n";
WORK_MDEDITOR_EDIT: $(LIST)
#>	@$(ECHO) "$(LIST)\n"
	@$(ENV) $(PERL) -e '$(MDEDITOR_EDIT_PERL)'

.PHONY: WORK_MDEDITOR_READ
override MDEDITOR_READ_PERL = use strict; use warnings;
override MDEDITOR_READ_PERL += use MIME::Base64;
override MDEDITOR_READ_PERL += use IO::Uncompress::RawInflate qw(rawinflate);
override MDEDITOR_READ_PERL += my $$input = <STDIN>;
override MDEDITOR_READ_PERL += my $$output;
override MDEDITOR_READ_PERL += $$input = decode_base64($${input});
override MDEDITOR_READ_PERL += rawinflate \$${input} => \$${output};
override MDEDITOR_READ_PERL += print "$${output}\n";
WORK_MDEDITOR_READ:
#>	@$(ECHO) "$(LIST)\n"
	@$(ECHO) "$(LIST)" | $(ENV) $(PERL) -e '$(MDEDITOR_READ_PERL)'

%.edit: %
	@$(RUNMAKE) --silent WORK_MDEDITOR_EDIT TYPE="" BASE="" LIST="$(^)"

%.read:
	@$(RUNMAKE) --silent WORK_MDEDITOR_READ TYPE="" BASE="" LIST="$(*)"
#WORK: totally experimental targets for using markdown-editor

########################################

override ALLOFIT_CURL	:= $(subst ",,$(word 1,$(CURL)))
override ALLOFIT_GIT	:= $(subst ",,$(word 1,$(GIT)))
#> syntax highlighting fix: ")")

#WORKING : spell out requirements and build types in documentation
#	reqs	= curl and/or git (and make w/ toolchain)
#	types	= curl/git and BUILD_FETCH=* | curl and BUILD_FETCH=1

.PHONY: $(ALLOFIT)
$(ALLOFIT): .set_title-$(ALLOFIT)
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(ALLOFIT)-check
ifneq ($(and $(ALLOFIT_CURL),$(ALLOFIT_GIT)),)
ifneq ($(BUILD_FETCH),)
	$(RUNMAKE) $(FETCHIT)
endif
ifneq ($(BUILD_FETCH),0)
	$(RUNMAKE) $(FETCHNO)-$(STRAPIT)
	$(RUNMAKE) $(FETCHNO)-$(BUILDIT)
endif
else ifneq ($(ALLOFIT_CURL),)
ifeq ($(BUILD_FETCH),1)
	#WORKING : NOTICE "don't have git; will download/build, then download/build"
	$(RUNMAKE) $(FETCHGO)-$(STRAPIT)
	$(RUNMAKE) $(FETCHGO)-$(BUILDIT)
else
	#WORKING : ERROR "need git, or BUILD_FETCH=1"
endif
else
	#WORKING : ERROR "need curl"
endif
ifneq ($(BUILD_FETCH),0)
	$(RUNMAKE) $(ALLOFIT)-bindir
	$(RUNMAKE) $(CHECKIT)
endif
	@$(call BUILD_COMPLETE,--)
	$(RUNMAKE) $(TIMERIT)

#WORK : document!
$(FETCHGO)-%:
	$(RUNMAKE) $(FETCHIT)-$(*)
	$(RUNMAKE) $(FETCHNO)-$(*)

#WORK : document!
$(FETCHIT)-%:
	$(RUNMAKE) $(BUILDIT)-$(*) BUILD_FETCH="0"

#WORK : document!
$(FETCHNO)-%:
	$(RUNMAKE) $(BUILDIT)-$(*) BUILD_FETCH=

override define FETCHIT_TARGET =
.PHONY: $(FETCHIT)-$(1)
$(FETCHIT)-$(1):
	$(RUNMAKE) $(1) BUILD_FETCH="0"

.PHONY: $(FETCHNO)-$(1)
$(FETCHNO)-$(1):
	$(RUNMAKE) $(1) BUILD_FETCH=
endef
$(foreach FILE,\
	$(STRAPIT) \
	$(BUILDIT) \
	,\
	$(eval $(call FETCHIT_TARGET,$(FILE))) \
)

#WORK : document! $(FETCHIT)-$(STRAPIT) $(FETCHIT)-$(BUILDIT)
.PHONY: $(FETCHIT)
$(FETCHIT): .set_title-$(FETCHIT)
$(FETCHIT): $(FETCHIT)-$(STRAPIT)
$(FETCHIT): $(FETCHIT)-$(BUILDIT)
$(FETCHIT):
	@$(LS) \
		"$(COMPOSER_STORE)" \
		"$(COMPOSER_BUILD)"

.PHONY: $(STRAPIT)
$(STRAPIT): .set_title-$(STRAPIT)
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-gnu-init
	$(RUNMAKE) $(BUILDIT)-group-libs
	$(RUNMAKE) $(BUILDIT)-group-util
	$(RUNMAKE) $(BUILDIT)-group-tool
	$(RUNMAKE) $(BUILDIT)-group-core
	$(RUNMAKE) $(BUILDIT)-group-init
	@$(call BUILD_COMPLETE,--)

.PHONY: $(BUILDIT)
$(BUILDIT): .set_title-$(BUILDIT)
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-gnu
	$(RUNMAKE) $(BUILDIT)-make
	$(RUNMAKE) $(BUILDIT)-node
	$(RUNMAKE) $(BUILDIT)-texlive
	$(RUNMAKE) $(BUILDIT)-ghc
	$(RUNMAKE) $(BUILDIT)-cabal
	$(RUNMAKE) $(BUILDIT)-pandoc
	@$(call BUILD_COMPLETE,--)

override CHECK_FAILED		:=
override CHECK_MSYS		:=
override CHECK_SHELL		:=
ifeq ($(BUILD_PLAT),Msys)
ifeq ($(MSYSTEM),)
override CHECK_FAILED		:= 1
override CHECK_MSYS		:= 1
endif
endif
ifeq ($(shell $(SHELL) --version | $(SED) -n "/GNU[ ]bash/p"),)
override CHECK_FAILED		:= 1
override CHECK_SHELL		:= 1
endif

.PHONY: $(ALLOFIT)-check
$(ALLOFIT)-check: .set_title-$(ALLOFIT)-check
ifneq ($(CHECK_MSYS),)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) ERROR:"
	@$(TABLE_C2) "$(_N)Must use MSYS2 on Windows systems."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "This appears to be a Windows system, but the '$(_C)MSYSTEM$(_D)' variable is not set."
	@$(TABLE_C2) "You should run the '$(_M)$(BUILDIT)-msys$(_D)' target to install the MSYS2 environment."
	@$(TABLE_C2) "Then you can run the '$(_M)$(SHELLIT)-msys$(_D)' target for the MSYS2 environment and try '$(_C)$(ALLOFIT)$(_D)' again."
	@$(HEADER_1)
endif
ifneq ($(CHECK_SHELL),)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) ERROR:"
	@$(TABLE_C2) "$(_N)Shell script interpreter does not appear to be GNU Bash."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_H)$(MARKER) DETAILS:"
	@$(TABLE_C2) "The current value of the '$(_C)SHELL$(_D)' variable is: $(_M)$(SHELL)"
	@$(TABLE_C2) "It is reporting this version information:"
	@$(ECHO) "\n"
	@$(SHELL) --version
	@$(ECHO) "\n"
	@$(TABLE_C2) "It may be that this interpreter will work just fine, but it is not recommended."
	@$(TABLE_C2) "Please set '$(_C)MAKESHELL$(_D)' to the path of a GNU Bash shell."
	@$(HEADER_1)
endif
ifneq ($(CHECK_FAILED),)
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) NOTES:"
	@$(TABLE_C2) "This message was produced by $(_H)$(COMPOSER_FULLNAME)$(_D)."
	@$(TABLE_C2) "If you know the above to be incorrect, you can remove the check from the '$(_C)$(~)(ALLOFIT)-check$(_D)' target in:"
	@$(TABLE_C2) "$(INDENTING)$(_M)$(COMPOSER)"
	@$(HEADER_1)
	@exit 1
endif
	@$(call BUILD_COMPLETE)

.PHONY: $(ALLOFIT)-bindir
$(ALLOFIT)-bindir: .set_title-$(ALLOFIT)-bindir
	$(MKDIR) "$(COMPOSER_PROGS)/$(BUILD_BINDIR)"
#WORKING:NOW : need to sort out all $(BUILD_FSFILE) entries; this one is to make COMPOSER_SH work correctly
	$(MKDIR) "$(dir $(COMPOSER_PROGS)/$(BUILD_FSFILE))"
	$(DATESTAMP) >"$(COMPOSER_PROGS)/$(BUILD_FSFILE)"
#WORKING:NOW : and another hack to make $(BUILD_PLAT),Darwin COMPOSER_SH work correctly
	$(MKDIR) "$(dir $(COMPOSER_ABODE)/$(BUILD_FSFILE))"
	$(DATESTAMP) >"$(COMPOSER_ABODE)/$(BUILD_FSFILE)"
#WORKING:NOW
ifeq ($(BUILD_PLAT),Msys)
	$(call ALLOFIT_BINDIR_MSYS_MISC,$(COMPOSER_ABODE))
	$(call ALLOFIT_BINDIR_MSYS_MISC,$(COMPOSER_PROGS))
#WORK : probably need this for linux, too
	$(MKDIR) "$(COMPOSER_PROGS)/share"
	$(CP) "$(COMPOSER_ABODE)/share/"{locale,terminfo} "$(COMPOSER_PROGS)/share/"
#WORK
	$(foreach FILE,$(MSYS_BINARY_LIST),\
		$(CP) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/$(FILE)"	"$(COMPOSER_PROGS)/$(BUILD_BINDIR)/"; \
	)
endif
	$(foreach FILE,$(BUILD_BINARY_LIST),\
		$(CP) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/$(FILE)"	"$(COMPOSER_PROGS)/$(BUILD_BINDIR)/"; \
	)
	$(CP) "$(COMPOSER_ABODE)/ca-bundle.crt"				"$(COMPOSER_PROGS)/"
	$(CP) "$(COMPOSER_ABODE)/libexec/git-core"			"$(COMPOSER_PROGS)/"
#WORKING:NPM :: rm -frv .home ; mv -v .home.BAK .home ; make world-bindir ; mv -v .home .home.BAK ; /bin/Linux/usr/bin/make HEXO_WORK_INIT
	$(MKDIR)							"$(COMPOSER_PROGS)/$(dir $(NODE_MODULES))"
	$(CP) "$(COMPOSER_ABODE)/$(NODE_MODULES)"			"$(COMPOSER_PROGS)/$(dir $(NODE_MODULES))/"
	$(SED) -i "s|^([#][!]).+(node)$$|\1/usr/bin/env \2|g"		"$(COMPOSER_PROGS)/$(NODE_MODULES)/npm/bin/npm-cli.js"
	$(RM)								"$(COMPOSER_PROGS)/$(BUILD_BINDIR)/npm"
	$(call DO_HEREDOC,$(call HEREDOC_NPM_CLI))			>"$(COMPOSER_PROGS)/$(BUILD_BINDIR)/npm"
	$(CHMOD)							"$(COMPOSER_PROGS)/$(BUILD_BINDIR)/npm"
	$(foreach FILE,$(TEXLIVE_DIRECTORY_LIST),\
		$(MKDIR)						"$(COMPOSER_PROGS)/texmf-dist/$(FILE)"; \
		$(CP) "$(COMPOSER_ABODE)/texmf-dist/$(FILE)/"*		"$(COMPOSER_PROGS)/texmf-dist/$(FILE)/"; \
	)
	$(MKDIR)							"$(COMPOSER_PROGS)/texmf-dist/web2c"
	$(CP) "$(COMPOSER_ABODE)/texmf-dist/web2c/texmf.cnf"		"$(COMPOSER_PROGS)/texmf-dist/web2c/"
	$(CP) "$(COMPOSER_ABODE)/texmf-dist/ls-R"			"$(COMPOSER_PROGS)/texmf-dist/"
	$(MKDIR)							"$(COMPOSER_PROGS)/texmf-var/web2c/pdftex"
	$(CP) "$(COMPOSER_ABODE)/texmf-var/web2c/pdftex/pdflatex.fmt"	"$(COMPOSER_PROGS)/texmf-var/web2c/pdftex/"
	$(MKDIR)							"$(COMPOSER_PROGS)/pandoc"
	$(CP) "$(COMPOSER_ABODE)/.pandoc/"*				"$(COMPOSER_PROGS)/pandoc/"
	@$(call BUILD_COMPLETE)

override define ALLOFIT_BINDIR_MSYS_MISC =
$(call DO_HEREDOC,$(call HEREDOC_MSYS_SHELL_BAT)) >"$(1)/msys2_shell.bat"
$(CHMOD) "$(1)/msys2_shell.bat"
$(MKDIR) "$(1)/tmp"
$(ECHO) >"$(1)/tmp/.null"
$(MKDIR) "$(1)/etc"
$(CP) "$(MSYS_DST)/etc/"{bash.bashrc,fstab} "$(1)/etc/"
endef

override define HEREDOC_MSYS_SHELL_BAT =
@echo off
if not defined MSYSTEM set MSYSTEM=MSYS$(BUILD_BITS)
set _CMS=%~dp0
set _BIN=$(BUILD_BINDIR)
set _ICO=%_CMS%/../$(COMPOSER_ART)/icon.ico
if not exist %_ICO% set _ICO=%_CMS%/../../$(COMPOSER_ART)/icon.ico
set _OPT=
set _OPT=%_OPT% --title "$(MARKER) $(COMPOSER_FULLNAME) $(DIVIDE) MSYS2 Shell"
set _OPT=%_OPT% --icon "%_ICO%"
set _OPT=%_OPT% --exec "/%_BIN%/bash"
start /b %_CMS%/%_BIN%/mintty %_OPT%
::#>set /p ENTER="Hit ENTER to proceed."
:: end of file
endef

override define HEREDOC_NPM_CLI =
#!/usr/bin/env bash
"$$(dirname $${0})/../../$(NODE_MODULES)/npm/bin/npm-cli.js" "$${@}"
# end of file
endef

#WORK : better location?
#WORK : document!
#WORK : $(BUILDIT) comes from BUILD_COMPLETE macros below
override BUILD_CLEAN_DIRS := $(sort \
	$(foreach FILE,\
		$(filter-out $(COMPOSER_ABODE)/.%,\
		$(filter-out $(COMPOSER_ABODE)/macports%,\
		$(filter-out $(COMPOSER_ABODE)/msys%,\
		$(wildcard $(COMPOSER_ABODE)/*)))),"$(FILE)") \
	"$(COMPOSER_ABODE)/.$(BUILDIT)" \
	"$(COMPOSER_ABODE)/.cabal" \
	"$(COMPOSER_ABODE)/.coreutils" \
	"$(COMPOSER_ABODE)/.pandoc" \
	"$(COMPOSER_TRASH)" \
	"$(COMPOSER_BUILD)" \
	"$(COMPOSER_PROGS)" \
)
#WORKING:MACP : need to figure out how "$(COMPOSER_PROGS)" works with "Composer.terminal" and "$(BUILDIT)-macports"; document!
.PHONY: $(BUILDIT)-$(CLEANER)
$(BUILDIT)-$(CLEANER): .set_title-$(BUILDIT)-$(CLEANER)
	@$(LS) -d $(BUILD_CLEAN_DIRS) 2>/dev/null || $(TRUE)
	@$(RM) -r $(BUILD_CLEAN_DIRS)

.PHONY: $(BUILDIT)-gnu-init
$(BUILDIT)-gnu-init: .set_title-$(BUILDIT)-gnu-init
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE_GNU_CFG,$(GNU_CFG_FILE_GUS))
	$(call CURL_FILE_GNU_CFG,$(GNU_CFG_FILE_SUB))
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-gnu
$(BUILDIT)-gnu: .set_title-$(BUILDIT)-gnu
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(GNU_CFG_DST),$(GNU_CFG_SRC),$(GNU_CFG_CMT))
	@$(call BUILD_COMPLETE)
endif

#WORK : document!
#WORK : somewhere, there should be a note about how "$(ALLOFIT)" process has java prompts and perl socket requests
#WORKING:MACP
# cd /.composer ; rsync root@me.garybgenett.net:/.g/_data/zactive/coding/composer/Makefile /.composer/Makefile ; gmake build-clean ; rm /.composer/.home/macports ; gmake build-gnu-init build-make-init
# [xcode install]
# (composer/macports) g/make BUILD_PLAT=Darwin build-gnu-init build-make-init
# ./.home/usr/bin/make BUILD_PLAT=Darwin build-macports-init
# sudo ./.home/usr/bin/make BUILD_PLAT=Darwin build-macports
# ./.home/macports/bin/make BUILD_PLAT=Darwin world
#WORKING:MACP
.PHONY: $(BUILDIT)-macports-init
$(BUILDIT)-macports-init: .set_title-$(BUILDIT)-macports-init
	$(call CURL_FILE,$(MACPORTS_SRC))
	$(call CURL_FILE,$(MAKE_SRC_INIT))
	$(call DO_UNTAR,$(MACPORTS_SRC_DST),$(MACPORTS_SRC))
	$(call DO_UNTAR_CLEAN,$(MAKE_DST_INIT),$(MAKE_SRC_INIT))
	$(MKDIR) "$(MACPORTS_DST)/$(BUILD_BINDIR)"
	$(call AUTOTOOLS_BUILD,$(MACPORTS_SRC_DST),$(MACPORTS_DST),\
		PATH="/usr/bin:/bin:/usr/sbin:/sbin" \
		CC="/usr/bin/gcc"	CFLAGS="-I/usr/include -L/usr/lib" \
		CPP=""			CPPFLAGS="-I/usr/include" \
		LD="/usr/bin/ld"	LDFLAGS="-L/usr/lib" \
		,\
		--with-applications-dir="$(MACPORTS_DST)/.applications" \
		--with-frameworks-dir="$(MACPORTS_DST)/.frameworks" \
		--with-install-user="$(USER)" \
		--with-macports-user="$(USER)" \
		--with-no-root-privileges \
	)
	@$(call BUILD_COMPLETE)

#WORK : document!
.PHONY: $(BUILDIT)-macports
$(BUILDIT)-macports: .set_title-$(BUILDIT)-macports
#WORKING:MACP
	$(PORTS_ENV) $(PORTS) selfupdate
	$(PORTS_ENV) $(PORTS) upgrade outdated || $(TRUE)
	$(PORTS_ENV) $(PORTS) install $(MACPORTS_PACKAGES_LIST)
	$(PORTS_ENV) $(PORTS) select --set gcc mp-$(filter gcc%,$(MACPORTS_PACKAGES_LIST))
	$(PORTS_ENV) $(PORTS) list installed >"$(MACPORTS_DST)/.packages.txt"
#WORKING:MACP : do $(CHECKIT) to make sure build-required binaries are coming from macports
#WORKING:MACP : do $(LN) to bin/g* or macports/libexec/gnubin/* for any that are not
	$(CP) "$(MACPORTS_DST)/bin/gmake" "$(MACPORTS_DST)/bin/make"
#WORKING:NOW : and another hack to make $(BUILD_PLAT),Darwin COMPOSER_SH work correctly
	$(MKDIR) "$(dir $(MACPORTS_DST)/$(BUILD_FSFILE))"
	$(DATESTAMP) >"$(MACPORTS_DST)/$(BUILD_FSFILE)"
	@$(call BUILD_COMPLETE)

#WORKING:NOW : fix and re-document all of this!
#WORKING:NOW : add this to $(ALLOFIT)-check as $(ALLOFIT)-msys, as a check of $MSYSTEM and whether root (/$(BUILD_BINDIR)/pacman); update locations and documentation
#	* [Composer.bat]
#		* .composer_root
#		* $(RUNMAKE) COMPOSER_PROGS_USE=0 $(BUILDIT)-msys-init
#WORKING
.PHONY: $(BUILDIT)-msys-init
$(BUILDIT)-msys-init: .set_title-$(BUILDIT)-msys-init
	$(call CURL_FILE,$(MSYS_SRC))
	$(call DO_UNTAR,$(MSYS_DST),$(MSYS_SRC))
	@$(HEADER_1)
	@$(TABLE_C2) "We need to initialize the MSYS2 environment."
	@$(TABLE_C2) "To do this, we will pause here to open an initial shell window."
	@$(TABLE_C2) "Once the shell window gets to a command prompt, simply type '$(_M)exit$(_D)' and hit $(_M)ENTER$(_D) to return."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_N)Hit $(_C)ENTER$(_N) to proceed."
	@$(HEADER_1)
	@read -s -n1 ENTER
	@$(RUNMAKE) --silent COMPOSER_PROGS_USE=0 $(SHELLIT)-msys
	@$(HEADER_1)
	@$(TABLE_C2) "The shell window has been launched."
	@$(TABLE_C2) "It should have processed to a command prompt, after which you typed '$(_M)exit$(_D)' and hit $(_M)ENTER$(_D)."
	@$(TABLE_C2) "If everything was successful $(_E)(no errors above)$(_D), you can continue with the build process."
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_N)Hit $(_C)ENTER$(_N) to proceed, or $(_C)CTRL-C$(_N) to quit."
	@$(HEADER_1)
	@read -s -n1 ENTER
	@$(call MSYS_REBASE)
	@$(RUNMAKE) --silent COMPOSER_PROGS_USE=0 $(SHELLIT)-msys
	@$(HEADER_1)
	@$(TABLE_C2) "WORKING:NOW : .composer_root"
	@$(TABLE_C2) "WORKING:NOW : $(PACMAN) make"
	@$(TABLE_C2)
	@$(TABLE_C2) "$(_N)Hit $(_C)ENTER$(_N) to proceed, or $(_C)CTRL-C$(_N) to quit."
	@$(HEADER_1)
	@read -s -n1 ENTER
	@$(call MSYS_REBASE)
	@$(HEADER_1)
	@$(TABLE_C2) "WORKING:NOW : $(COMPOSER_BASENAME).bat"
	@$(TABLE_C2) "WORKING:NOW : .composer_root"
	@$(TABLE_C2) "WORKING:NOW : $(MAKE) $(BUILDIT)-$(CLEANER)"
	@$(TABLE_C2) "WORKING:NOW : $(MAKE) $(BUILDIT)-msys"
	@$(TABLE_C2) "WORKING:NOW : SAFE TO CLOSE THIS WINDOW; READY TO GO!"
	@$(TABLE_C2) "WORKING:NOW : STILL NEED TO FIX THE EXTRA NEEDED REBASE AFTER PACMAN_BASE_LIST!"
	@$(HEADER_1)
	@$(call BUILD_COMPLETE)

.PHONY: $(BUILDIT)-msys
$(BUILDIT)-msys: .set_title-$(BUILDIT)-msys
	$(PACMAN_ENV) $(PACMAN) --refresh
	$(PACMAN_ENV) $(PACMAN) $(PACMAN_BASE_LIST)
	$(call MSYS_REBASE)
	$(PACMAN_ENV) $(PACMAN_DB_UPGRADE)
	$(PACMAN_ENV) $(PACMAN) --sysupgrade $(PACMAN_PACKAGES_LIST)
	$(PACMAN_ENV) $(PACMAN) --clean
	$(PACMAN_ENV) $(PACMAN_DB)		>"$(MSYS_DST)/.packages.txt"
	$(PACMAN_ENV) $(PACMAN_DB) --groups	>"$(MSYS_DST)/.packages.groups.txt"
	$(PACMAN_ENV) $(PACMAN_DB) --info	>"$(MSYS_DST)/.packages.info.txt"
	$(MKDIR) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)"
#WORKING:NOW : darg, $(BUILDIT)-$(CLEANER) removes this; either needs to not do that, or replace it afterwards
	$(foreach FILE,$(MSYS_BINARY_LIST),\
		$(CP) "$(MSYS_DST)/$(BUILD_BINDIR)/$(FILE)" "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/"; \
	)
	@$(call BUILD_COMPLETE)

override define MSYS_REBASE =
	cd "$(MSYS_DST)" && \
		$(WINDOWS_ACL) ./autorebase.bat /grant:r $(USERNAME):f && \
		./autorebase.bat
endef

.PHONY: $(BUILDIT)-group-libs
$(BUILDIT)-group-libs:  .set_title-$(BUILDIT)-group-libs
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-libiconv-init
	$(RUNMAKE) $(BUILDIT)-gettext
	$(RUNMAKE) $(BUILDIT)-libiconv
	$(RUNMAKE) $(BUILDIT)-pkgconfig
	$(RUNMAKE) $(BUILDIT)-zlib
	$(RUNMAKE) $(BUILDIT)-gmp
	$(RUNMAKE) $(BUILDIT)-ncurses
	$(RUNMAKE) $(BUILDIT)-openssl
	$(RUNMAKE) $(BUILDIT)-gdbm
	$(RUNMAKE) $(BUILDIT)-expat
	$(RUNMAKE) $(BUILDIT)-png
	# need the "bzip" headers/library for "freetype"
	$(RUNMAKE) $(BUILDIT)-bzip
	$(RUNMAKE) $(BUILDIT)-freetype
	$(RUNMAKE) $(BUILDIT)-fontconfig
	@$(call BUILD_COMPLETE,--)

.PHONY: $(BUILDIT)-libiconv-init
$(BUILDIT)-libiconv-init: .set_title-$(BUILDIT)-libiconv-init
ifneq ($(BUILD_FETCH),)
	$(call LIBICONV_PULL)
endif
ifneq ($(BUILD_FETCH),0)
	$(call LIBICONV_BUILD,$(COMPOSER_ABODE),\
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-gettext
# thanks for the 'dispatch/object' fix below: https://stackoverflow.com/questions/27976312/how-to-cope-with-non-gcc-compatible-code-in-os-x-yosemite-core-headers
#	also to: https://hamelot.co.uk/programming/osx-gcc-dispatch_block_t-has-not-been-declared-invalid-typedef
$(BUILDIT)-gettext: .set_title-$(BUILDIT)-gettext
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(GETTEXT_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(GETTEXT_DST),$(GETTEXT_SRC))
ifeq ($(BUILD_PLAT),Darwin)
	# see "$(BUILDIT)-pkgconfig" for a duplication of this fix
	$(MKDIR) "$(COMPOSER_ABODE)/include/dispatch"
	$(SED) \
		-e "s|^(typedef[ ]void[ ][(][\^]dispatch[_]block[_]t[)][(]void[)][;])$$|#ifdef __clang__\n\1\n#else\ntypedef void\* dispatch_block_t\;\n#endif|g" \
		"/usr/include/dispatch/object.h" \
		>"$(COMPOSER_ABODE)/include/dispatch/object.h"
endif
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(GETTEXT_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(GETTEXT_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
ifeq ($(BUILD_PLAT),Darwin)
	$(RM) -r "$(COMPOSER_ABODE)/include/dispatch/object.h"
endif
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-libiconv
$(BUILDIT)-libiconv: .set_title-$(BUILDIT)-libiconv
ifneq ($(BUILD_FETCH),)
	$(call LIBICONV_PULL)
endif
ifneq ($(BUILD_FETCH),0)
	$(call LIBICONV_BUILD,$(COMPOSER_ABODE),\
		--disable-shared \
		--enable-static \
	)
	# GHC compiler requires dynamic Iconv library (libiconv.so, libcharset.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call LIBICONV_BUILD,$(BUILD_LDLIB),\
		--enable-shared \
		--enable-static \
	)
endif
	@$(call BUILD_COMPLETE)
endif

# thanks for the patch below: https://gist.github.com/paulczar/5493708
#	https://savannah.gnu.org/bugs/?43212
override LIBICONV_PATCH := https://gist.githubusercontent.com/paulczar/5493708/raw/169f5cb3c11351ad839cf35c454ae55a508625c3/gistfile1.txt
override define LIBICONV_PULL =
	$(call CURL_FILE,$(LIBICONV_SRC))
	$(call CURL_FILE,$(LIBICONV_PATCH))
endef
override define LIBICONV_BUILD =
	# start with fresh source directory, due to circular dependency with "gettext"
	# start with fresh source directory, due to dual static/dynamic builds
	$(RM) -r "$(LIBICONV_DST)"
	$(call DO_UNTAR_CLEAN,$(LIBICONV_DST),$(LIBICONV_SRC))
	# "$(BUILD_PLAT),Linux" requires some patching; "$(BUILD_PLAT),Msys" doesn't build with this patch
	if [ "$(BUILD_PLAT)" == "Linux" ]; then \
		$(call DO_PATCH,0,$(LIBICONV_DST),$(LIBICONV_PATCH)); \
	fi
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(LIBICONV_DST)/build-aux)
	$(call GNU_CFG_INSTALL,$(LIBICONV_DST)/libcharset/build-aux)
	$(call AUTOTOOLS_BUILD,$(LIBICONV_DST),$(1),,\
		$(2) \
	)
endef

.PHONY: $(BUILDIT)-pkgconfig
$(BUILDIT)-pkgconfig: .set_title-$(BUILDIT)-pkgconfig
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(PKGCONFIG_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(PKGCONFIG_DST),$(PKGCONFIG_SRC))
ifeq ($(BUILD_PLAT),Darwin)
	# see "$(BUILDIT)-gettext" for a duplication of this fix (with source links)
	$(MKDIR) "$(COMPOSER_ABODE)/include/dispatch"
	$(SED) \
		-e "s|^(typedef[ ]void[ ][(][\^]dispatch[_]block[_]t[)][(]void[)][;])$$|#ifdef __clang__\n\1\n#else\ntypedef void\* dispatch_block_t\;\n#endif|g" \
		"/usr/include/dispatch/object.h" \
		>"$(COMPOSER_ABODE)/include/dispatch/object.h"
endif
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(PKGCONFIG_DST))
	$(call GNU_CFG_INSTALL,$(PKGCONFIG_DST)/glib)
	$(call AUTOTOOLS_BUILD,$(PKGCONFIG_DST)/glib,$(COMPOSER_ABODE),,\
		--with-libiconv="gnu" \
	)
#WORK : could this be better?  why not just -I$(PKGCONFIG_DST)/glib/glib?
#WORK : does the internal glib really not work, for that matter?
	$(CP) "$(PKGCONFIG_DST)/glib/glib/glib.h"	"$(PKGCONFIG_DST)/glib/"
	$(CP) "$(PKGCONFIG_DST)/glib/glib/glibconfig.h"	"$(PKGCONFIG_DST)/glib/"
	$(CP) "$(PKGCONFIG_DST)/glib/glib/libglib-"*.la	"$(PKGCONFIG_DST)/glib/glib/libglib.la"
	$(call AUTOTOOLS_BUILD,$(PKGCONFIG_DST),$(COMPOSER_ABODE),\
		GLIB_CFLAGS="$(CFLAGS) -I$(PKGCONFIG_DST)/glib -L$(PKGCONFIG_DST)/glib/glib" \
		GLIB_LIBS="-lglib" \
		,\
		--disable-host-tool \
		--without-internal-glib \
	)
ifeq ($(BUILD_PLAT),Darwin)
	$(RM) -r "$(COMPOSER_ABODE)/include/dispatch/object.h"
endif
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-zlib
$(BUILDIT)-zlib: .set_title-$(BUILDIT)-zlib
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(ZLIB_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call ZLIB_BUILD,$(COMPOSER_ABODE),\
		--static \
	)
	# GHC compiler requires dynamic Zlib library (libz.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call ZLIB_BUILD,$(BUILD_LDLIB))
endif
	@$(call BUILD_COMPLETE)
endif

override define ZLIB_BUILD =
	# start with fresh source directory, due to dual static/dynamic builds
	$(RM) -r "$(ZLIB_DST)"
	$(call DO_UNTAR_CLEAN,$(ZLIB_DST),$(ZLIB_SRC))
	$(call AUTOTOOLS_BUILD_NOOPTION,$(ZLIB_DST),$(1),,\
		$(if $(filter $(BUILD_BITS),64),--64) \
		$(2) \
	)
endef

.PHONY: $(BUILDIT)-gmp
$(BUILDIT)-gmp: .set_title-$(BUILDIT)-gmp
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(GMP_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call GMP_BUILD,$(COMPOSER_ABODE),\
		--disable-shared \
		--enable-static \
	)
	# GHC compiler requires dynamic GMP library (libgmp.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call GMP_BUILD,$(BUILD_LDLIB),\
		--enable-shared \
		--enable-static \
	)
endif
	@$(call BUILD_COMPLETE)
endif

override define GMP_BUILD =
	# start with fresh source directory, due to dual static/dynamic builds
	$(RM) -r "$(GMP_DST)"
	$(call DO_UNTAR_CLEAN,$(GMP_DST),$(GMP_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(GMP_DST))
	$(call AUTOTOOLS_BUILD,$(GMP_DST),$(1),\
		ABI="$(BUILD_BITS)" \
		,\
		--disable-assembly \
		$(2) \
	)
endef

.PHONY: $(BUILDIT)-ncurses
$(BUILDIT)-ncurses: .set_title-$(BUILDIT)-ncurses
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(NCURSES_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call NCURSES_BUILD,$(COMPOSER_ABODE),,\
		--without-shared \
	)
	# GHC compiler requires dynamic Ncurses library (libtinfo.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call NCURSES_BUILD,$(BUILD_LDLIB),\
		CFLAGS="$(subst -L$(COMPOSER_ABODE)/lib,,$(CFLAGS))" \
		,\
		--with-shared \
	)
endif
	@$(call BUILD_COMPLETE)
endif

override define NCURSES_BUILD =
	# start with fresh source directory, due to dual static/dynamic builds
	$(RM) -r "$(NCURSES_DST)"
	$(call DO_UNTAR_CLEAN,$(NCURSES_DST),$(NCURSES_SRC))
	# "$(BUILD_PLAT),Darwin" requires some patching
	$(SED) -i \
		-e "s|[-]no[-]cpp[-]precomp||g" \
		"$(NCURSES_DST)/configure" \
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(NCURSES_DST))
#WORKING : if vim/less have rendering issues, it could be that they require true --disable-widec libraries
	# "$(BUILD_PLAT),Msys" doesn't build with wide character support enabled
	$(call AUTOTOOLS_BUILD,$(NCURSES_DST),$(1),$(2),\
		$(if $(filter-out $(BUILD_PLAT),Msys),--enable-widec) \
		--enable-overwrite \
		--with-termlib \
		--without-gpm \
		$(3) \
	)
	$(foreach FILE,\
		libform \
		libmenu \
		libncurses \
		libncurses++ \
		libpanel \
		libtinfo \
		,\
		$(foreach LIBEXT,a so dylib,\
			if [ -f "$(1)/lib/$(FILE)w.$(LIBEXT)" ]; then $(CP) "$(1)/lib/$(FILE)w.$(LIBEXT)" "$(1)/lib/$(FILE).$(LIBEXT)" ; fi; \
		)
	)
endef

# thanks for the 'x86_64' fix below: http://openssl.6102.n7.nabble.com/compile-openssl-1-0-1e-failed-on-Ubuntu-12-10-x64-td44699.html
override OPENSSL_BUILD_TYPE :=
ifeq ($(BUILD_BITS),64)
ifeq ($(BUILD_PLAT),Linux)
override OPENSSL_BUILD_TYPE := linux-x86_$(BUILD_BITS)
else ifeq ($(BUILD_PLAT),Darwin)
override OPENSSL_BUILD_TYPE := darwin$(BUILD_BITS)-$(BUILD_ARCH)-cc
else ifeq ($(BUILD_PLAT),Msys)
override OPENSSL_BUILD_TYPE := linux-x86_$(BUILD_BITS)
endif
else
ifeq ($(BUILD_PLAT),Linux)
override OPENSSL_BUILD_TYPE := linux-generic$(BUILD_BITS)
else ifeq ($(BUILD_PLAT),Darwin)
#WORKING:MACP
override OPENSSL_BUILD_TYPE := darwin-$(subst i686,i386,$(BUILD_ARCH))-cc
else ifeq ($(BUILD_PLAT),Msys)
override OPENSSL_BUILD_TYPE := linux-generic$(BUILD_BITS)
endif
endif

.PHONY: $(BUILDIT)-openssl
$(BUILDIT)-openssl: .set_title-$(BUILDIT)-openssl
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(OPENSSL_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call OPENSSL_BUILD,$(COMPOSER_ABODE),,\
		no-shared \
		no-dso \
		no-asm \
	)
	# Python interpreter requires dynamic OpenSSL library (libssl.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call OPENSSL_BUILD,$(BUILD_LDLIB),,\
		shared \
	)
endif
	@$(call BUILD_COMPLETE)
endif

override define OPENSSL_BUILD =
	# start with fresh source directory, due to dual static/dynamic builds
	$(RM) -r "$(OPENSSL_DST)"
	$(call DO_UNTAR_CLEAN,$(OPENSSL_DST),$(OPENSSL_SRC))
	$(RM) -r "$(COMPOSER_ABODE)/ssl/man/man3"
	# "$(BUILD_PLAT),Darwin" is case-insensitive, so 'Configure' is already 'configure'
	# "$(BUILD_PLAT),Msys" is case-insensitive, so 'Configure' is already 'configure'
	if [ "$(BUILD_PLAT)" = "Linux" ]; then \
		$(CP) "$(OPENSSL_DST)/Configure" "$(OPENSSL_DST)/configure"; \
	elif [ ! -f "$(OPENSSL_DST)/configure" ]; then \
		$(CP) "$(OPENSSL_DST)/config" "$(OPENSSL_DST)/configure"; \
	fi
	$(SED) -i \
		-e "s|(TERMIO)([^S])|\1S\2|g" \
		-e "s|(termio)([^s])|\1s\2|g" \
		"$(OPENSSL_DST)/configure" \
		"$(OPENSSL_DST)/crypto/ui/ui_openssl.c"
	$(SED) -i \
		-e "s|([(]INSTALLTOP[)][/])bin|\1$(BUILD_BINDIR)|g" \
		"$(OPENSSL_DST)/Makefile.org" \
		"$(OPENSSL_DST)/apps/Makefile" \
		"$(OPENSSL_DST)/tools/Makefile"
	$(call AUTOTOOLS_BUILD_NOOPTION,$(OPENSSL_DST),$(1),$(2),\
		$(OPENSSL_BUILD_TYPE) \
		$(3) \
	)
endef

.PHONY: $(BUILDIT)-gdbm
$(BUILDIT)-gdbm: .set_title-$(BUILDIT)-gdbm
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(GDBM_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call GDBM_BUILD,$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
	# Perl requires dynamic GDBM library (libgdbm.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call GDBM_BUILD,$(BUILD_LDLIB),,\
		--enable-shared \
		--enable-static \
	)
endif
	@$(call BUILD_COMPLETE)
endif

override define GDBM_BUILD =
	$(call DO_UNTAR_CLEAN,$(GDBM_DST),$(GDBM_SRC))
	$(call AUTOTOOLS_BUILD,$(GDBM_DST),$(1),$(2),$(3))
endef

.PHONY: $(BUILDIT)-expat
$(BUILDIT)-expat: .set_title-$(BUILDIT)-expat
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(EXPAT_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(EXPAT_DST),$(EXPAT_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(EXPAT_DST)/conftools)
	$(call AUTOTOOLS_BUILD,$(EXPAT_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

#WORKING:MACP
$(BUILDIT)-png: .set_title-$(BUILDIT)-png
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(PNG_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(PNG_DST),$(PNG_SRC))
	$(call AUTOTOOLS_BUILD,$(PNG_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-freetype
$(BUILDIT)-freetype: .set_title-$(BUILDIT)-freetype
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(FREETYPE_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(FREETYPE_DST),$(FREETYPE_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(FREETYPE_DST)/builds/unix)
	$(call AUTOTOOLS_BUILD,$(FREETYPE_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-fontconfig
$(BUILDIT)-fontconfig: .set_title-$(BUILDIT)-fontconfig
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(FONTCONFIG_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(FONTCONFIG_DST),$(FONTCONFIG_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(FONTCONFIG_DST))
	$(call AUTOTOOLS_BUILD,$(FONTCONFIG_DST),$(COMPOSER_ABODE),\
		FREETYPE_CFLAGS="$(CFLAGS) -I$(COMPOSER_ABODE)/include/freetype2" \
		FREETYPE_LIBS="$(shell "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/freetype-config" --libs --static)" \
		,\
		--disable-docs \
		--enable-iconv \
		--with-libiconv-includes="$(COMPOSER_ABODE)/include" \
		--with-libiconv-lib="$(COMPOSER_ABODE)/lib" \
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-group-util
$(BUILDIT)-group-util: .set_title-$(BUILDIT)-group-util
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-coreutils
	$(RUNMAKE) $(BUILDIT)-findutils
	$(RUNMAKE) $(BUILDIT)-patch
	$(RUNMAKE) $(BUILDIT)-sed
	$(RUNMAKE) $(BUILDIT)-bzip
	$(RUNMAKE) $(BUILDIT)-gzip
	$(RUNMAKE) $(BUILDIT)-xz
	$(RUNMAKE) $(BUILDIT)-tar
	$(RUNMAKE) $(BUILDIT)-perl
	$(RUNMAKE) $(BUILDIT)-python
	@$(call BUILD_COMPLETE,--)

.PHONY: $(BUILDIT)-coreutils
$(BUILDIT)-coreutils: .set_title-$(BUILDIT)-coreutils
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(COREUTILS_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(COREUTILS_DST),$(COREUTILS_SRC))
#WORKING : if linux coreutils has buffering issues, it could be that this should be msys-specific
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling "stdbuf" which requires "libstdbuf.so"
	$(SED) -i \
		-e "s|(stdbuf[_]supported[=])yes|\1no|g" \
		"$(COREUTILS_DST)/configure"
	$(call AUTOTOOLS_BUILD,$(COREUTILS_DST),$(COMPOSER_ABODE),,\
		--enable-single-binary="shebangs" \
		--disable-acl \
		--disable-libcap \
		--disable-xattr \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-findutils
$(BUILDIT)-findutils: .set_title-$(BUILDIT)-findutils
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(FINDUTILS_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(FINDUTILS_DST),$(FINDUTILS_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(FINDUTILS_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(FINDUTILS_DST),$(COMPOSER_ABODE))
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-patch
$(BUILDIT)-patch: .set_title-$(BUILDIT)-patch
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(PATCH_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(PATCH_DST),$(PATCH_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(PATCH_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(PATCH_DST),$(COMPOSER_ABODE),,\
		--disable-xattr \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-sed
$(BUILDIT)-sed: .set_title-$(BUILDIT)-sed
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(SED_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(SED_DST),$(SED_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(SED_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(SED_DST),$(COMPOSER_ABODE),,\
		--disable-acl \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-bzip
$(BUILDIT)-bzip: .set_title-$(BUILDIT)-bzip
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(BZIP_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call BZIP_BUILD,$(COMPOSER_ABODE))
	# Python interpreter requires dynamic Bzip2 library (libbz2.so)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" can't build dynamic libraries, so disabling
	$(call BZIP_BUILD,$(BUILD_LDLIB),,,--makefile "Makefile-libbz2_so")
	$(MKDIR) "$(BUILD_LDLIB)/lib"
	$(foreach LIBEXT,so dylib,\
		if [ -f "$(BUILD_LDLIB)/lib/libbz2.$(LIBEXT)" ]; then $(CP) "$(BZIP_DST)/libbz2.$(LIBEXT)"* "$(BUILD_LDIB)/lib/" ; fi; \
	)
endif
	@$(call BUILD_COMPLETE)
endif

# thanks for the 'install_name' fix below: https://stackoverflow.com/questions/4580789/cmake-mac-os-x-ld-unknown-option-soname
override define BZIP_BUILD =
	# start with fresh source directory, due to dual static/dynamic builds
	$(RM) -r "$(BZIP_DST)"
	$(call DO_UNTAR_CLEAN,$(BZIP_DST),$(BZIP_SRC))
	$(ECHO) >"$(BZIP_DST)/configure"
	$(CHMOD) "$(BZIP_DST)/configure"
	$(SED) -i \
		-e "s|^(PREFIX[=]).+$$|\1$(1)|g" \
		-e "s|([(]PREFIX[)][/])bin|\1$(BUILD_BINDIR)|g" \
		"$(BZIP_DST)/Makefile"
	# "$(BUILD_PLAT),Darwin" requires some patching
	if [ "$(BUILD_PLAT)" == "Darwin" ]; then \
		$(SED) -i \
			-e "s|soname|install_name|g" \
			"$(BZIP_DST)/Makefile-libbz2_so"; \
	fi
	$(call AUTOTOOLS_BUILD_NOOPTION,$(BZIP_DST),$(1),$(2),$(3),$(4))
endef

.PHONY: $(BUILDIT)-gzip
$(BUILDIT)-gzip: .set_title-$(BUILDIT)-gzip
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(GZIP_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(GZIP_DST),$(GZIP_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(GZIP_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(GZIP_DST),$(COMPOSER_ABODE))
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-xz
$(BUILDIT)-xz: .set_title-$(BUILDIT)-xz
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(XZ_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(XZ_DST),$(XZ_SRC))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(XZ_DST)/build-aux)
	$(call AUTOTOOLS_BUILD,$(XZ_DST),$(COMPOSER_ABODE),,\
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-tar
# thanks for the patch below: https://lists.gnu.org/archive/html/bug-tar/2014-08/msg00003.html
override TAR_PATCH := https://lists.gnu.org/archive/html/bug-tar/2014-08/txtB_H8f4It7m.txt
$(BUILDIT)-tar: .set_title-$(BUILDIT)-tar
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(TAR_SRC))
	$(call CURL_FILE,$(TAR_PATCH))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(TAR_DST),$(TAR_SRC))
ifeq ($(BUILD_PLAT),Darwin)
	# "$(BUILD_PLAT),Darwin" requires some patching
	$(call DO_PATCH,1,$(TAR_DST),$(TAR_PATCH))
	$(SED) -i \
		-e "s|1[.]14|1.15|g" \
		"$(TAR_DST)/aclocal.m4" \
		"$(TAR_DST)/configure"
endif
	$(call AUTOTOOLS_BUILD,$(TAR_DST),$(COMPOSER_ABODE),,\
		--disable-acl \
		--without-posix-acls \
		--without-xattrs \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-perl
# thanks for the patch below: https://github.com/Alexpux/MSYS2-packages/tree/master/perl
override PERL_PATCH := https://raw.githubusercontent.com/Alexpux/MSYS2-packages/15d99549ca9db0e71d7053999f577e7443d1653e/perl/perl-5.20.0-msys2.patch
$(BUILDIT)-perl: .set_title-$(BUILDIT)-perl
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(PERL_SRC))
	$(call CURL_FILE,$(PERL_PATCH))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(PERL_DST),$(PERL_SRC))
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" requires some patching
	if [ ! -f "$(PERL_DST)/Configure.perl" ]; then \
		$(SED) -i \
			-e "s|[ ][-]Wl[,][-][-]image[-]base[,]0x52000000||g" \
			"$(PERL_DST)/Makefile.SH"; \
		$(call DO_PATCH,1,$(PERL_DST),$(PERL_PATCH)); \
	fi
	# "$(BUILD_PLAT),Msys" does not have "/proc" filesystem or symlinks
	$(SED) -i \
		-e "s|^(case[ ][\"])[$$]d_readlink|\1NULL|g" \
		"$(PERL_DST)/Configure"
	$(SED) -i \
		-e "s|[$$]issymlink|test -f|g" \
		"$(PERL_DST)/Makefile.SH"
endif
	# "$(BUILD_PLAT),Msys" is case-insensitive, so 'Configure' is already 'configure'
	if [ ! -f "$(PERL_DST)/Configure.perl" ]; then \
		$(MV) "$(PERL_DST)/Configure" "$(PERL_DST)/Configure.perl"; \
		$(CP) "$(PERL_DST)/configure.gnu" "$(PERL_DST)/configure"; \
		$(SED) -i \
			-e "s|(Configure)([^.])|\1.perl\2|g" \
			"$(PERL_DST)/Configure.perl" \
			"$(PERL_DST)/MANIFEST" \
			"$(PERL_DST)/configure"; \
	fi
#WORKING:MACP : https://stackoverflow.com/questions/9191346/perl-cross-compilation-make
#WORKING:MACP : http://www.fixunix.com/redhat/522962-compile-32-bit-perl-64bit-redhat-linux.html
#	$(SED) -i \
#		-e "s|([-]Dcc[=].[$$]CC)([^ ])|-Dusecrosscompile -Dtargetarch=$(BUILD_PLAT) -Dtargethost=127.0.0.1 \1 -m$(BUILD_BITS)\2|g" \
#		"$(PERL_DST)/configure"
	$(SED) -i \
		-e "s|^(set[ ]dflt[ ]bin[ ])bin$$|\1$(BUILD_BINDIR)|g" \
		-e "s|(prefix[/])bin([ ])|\1$(BUILD_BINDIR)\2|g" \
		"$(PERL_DST)/Configure.perl"
	$(call AUTOTOOLS_BUILD_NOOPTION,$(PERL_DST),$(COMPOSER_ABODE),\
		$(if $(filter $(BUILD_PLAT),Linux),LDFLAGS="$(LDFLAGS_LDLIB)") \
		$(if $(filter $(BUILD_PLAT),Darwin),LDFLAGS="$(subst $(LDLIB_RUN_PATH),,$(LDFLAGS_LDLIB))") \
	)
	@$(call BUILD_COMPLETE)
endif
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-perl-modules

.PHONY: $(BUILDIT)-perl-modules
$(BUILDIT)-perl-modules: .set_title-$(BUILDIT)-perl-modules
ifneq ($(BUILD_FETCH),)
	$(foreach FILE,$(PERL_MODULES_LIST),\
		$(call PERL_MODULES_PULL,$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
	)
endif
ifneq ($(BUILD_FETCH),0)
	$(foreach FILE,$(PERL_MODULES_LIST),\
		$(call PERL_MODULES_BUILD,$(word 1,$(subst |, ,$(FILE))),$(word 2,$(subst |, ,$(FILE)))); \
	)
	@$(call BUILD_COMPLETE)
endif

override define PERL_MODULES_PULL =
	$(call CURL_FILE,$(2))
endef
override define PERL_MODULES_BUILD =
	$(call DO_UNTAR_CLEAN,$(PERL_DST).libs/$(1),$(2)); \
	cd "$(PERL_DST).libs/$(1)" && \
		export PERL="$(PERL)" && \
		$(BUILD_ENV) $(PERL) ./Makefile.PL PREFIX="$(COMPOSER_ABODE)" && \
		$(BUILD_ENV) $(MAKE) && \
		$(BUILD_ENV) $(MAKE) install
endef

# thanks for the 'with-ensurepip' fix below: https://stackoverflow.com/questions/45132886/modulenotfounderror-no-module-named-pyexpat
# thanks for the 'clang' fix below: https://github.com/joyent/node/issues/9182
# thanks for the 'universalsdk' fix below: https://bugs.python.org/issue1099
#	also to: http://article.gmane.org/gmane.comp.python.general/685151
# thanks for the patch below: https://github.com/Alexpux/MSYS2-packages/tree/master/python2
override PYTHON_PATCHES := \
	https://raw.githubusercontent.com/Alexpux/MSYS2-packages/7f9cc5b2b3e57fa037403192d4ac565f50fcb25c/python2/0010-ctypes-util-find_library.patch \
	https://raw.githubusercontent.com/Alexpux/MSYS2-packages/7f9cc5b2b3e57fa037403192d4ac565f50fcb25c/python2/0100-no-libm.patch \
	https://raw.githubusercontent.com/Alexpux/MSYS2-packages/7f9cc5b2b3e57fa037403192d4ac565f50fcb25c/python2/0200-msys2.patch
.PHONY: $(BUILDIT)-python
$(BUILDIT)-python: .set_title-$(BUILDIT)-python
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(PYTHON_SRC))
	$(foreach FILE,$(PYTHON_PATCHES),\
		$(call CURL_FILE,$(FILE)) $(call NEWLINE)$(ECHO); \
	)
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(PYTHON_DST),$(PYTHON_SRC))
#WORKING:NOW
#ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" requires some patching
	$(foreach FILE,$(PYTHON_PATCHES),\
		$(call DO_PATCH,1,$(PYTHON_DST),$(FILE)) $(call NEWLINE)$(ECHO); \
	)
#endif
	$(call AUTOTOOLS_BUILD,$(PYTHON_DST),$(COMPOSER_ABODE),\
		$(if $(filter $(BUILD_PLAT),Darwin),CC="/usr/bin/clang" CFLAGS="$(subst $(LIBGCC),,$(CFLAGS))" LDFLAGS="$(subst $(LIBGCC),,$(LDFLAGS))") \
		$(if $(filter $(BUILD_PLAT),Linux),LDFLAGS="$(LDFLAGS_LDLIB)") \
		$(if $(filter $(BUILD_PLAT),Darwin),LDFLAGS="$(subst $(LDLIB_RUN_PATH),,$(LDFLAGS_LDLIB))") \
		,\
		--build="$(CHOST)" \
		$(if $(filter $(BUILD_PLAT),DARWIN),--enable-universalsdk="/") \
		--with-ensurepip="no" \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-group-tool
$(BUILDIT)-group-tool: .set_title-$(BUILDIT)-group-tool
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-bash
	$(RUNMAKE) $(BUILDIT)-less
	$(RUNMAKE) $(BUILDIT)-vim
	@$(call BUILD_COMPLETE,--)

.PHONY: $(BUILDIT)-bash
# thanks for the patch below: https://github.com/Alexpux/MSYS2-packages/tree/master/bash
override BASH_PATCH := https://raw.githubusercontent.com/Alexpux/MSYS2-packages/1e222b0ba41eec723c9060ff528399d45be5d2a1/bash/0004-bash-4.3-deprecations.patch
# thanks for the 'sigsetjmp' fix below: https://www.mail-archive.com/cygwin@cygwin.com/msg137488.html
# thanks for the 'malloc' fix below: http://www.linuxfromscratch.org/lfs/view/stable/chapter05/bash.html
$(BUILDIT)-bash: .set_title-$(BUILDIT)-bash
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(BASH_SRC))
	$(call CURL_FILE,$(BASH_PATCH))
endif
ifneq ($(BUILD_FETCH),0)
	# "$(BUILD_PLAT),Msys" does not support symlinks, so we have to exclude some files
	$(call DO_UNTAR_CLEAN,$(BASH_DST),$(BASH_SRC),$(notdir $(BASH_DST))/ChangeLog)
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(BASH_DST)/support)
#WORKING:NOW :: why does $(BUILD_PLAT),Darwin keep linking against system libncurses?
#ifeq ($(BUILD_PLAT),Darwin)
#	# "$(BUILD_PLAT),Darwin" requires some patching
#	$(SED) -i \
#		-e "s|([\"])([-]lncurses)|\1-L$(BUILD_LDLIB)/lib \2|g" \
#		"$(BASH_DST)/configure"
#else
#WORKING:NOW
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" requires some patching
	$(call DO_PATCH,1,$(BASH_DST),$(BASH_PATCH))
endif
	$(call AUTOTOOLS_BUILD,$(BASH_DST),$(COMPOSER_ABODE),\
		$(if $(filter $(BUILD_PLAT),Msys),bash_cv_func_sigsetjmp="missing") \
		,\
		$(if $(filter-out $(BUILD_PLAT),Darwin),--enable-static-link) \
		--without-bash-malloc \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-less
$(BUILDIT)-less: .set_title-$(BUILDIT)-less
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(LESS_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(LESS_DST),$(LESS_SRC))
	$(call AUTOTOOLS_BUILD,$(LESS_DST),$(COMPOSER_ABODE))
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-vim
override VIM_PATCH_URL	:= http://ftp.vim.org/pub/vim/patches/$(VIM_VER)
override VIM_PATCHES	:= \
	for FILE in {1..9};	do echo $(VIM_PATCH_URL)/$(VIM_VER).00$${FILE};	done; \
	for FILE in {10..99};	do echo $(VIM_PATCH_URL)/$(VIM_VER).0$${FILE};	done; \
	for FILE in {100..781};	do echo $(VIM_PATCH_URL)/$(VIM_VER).$${FILE};	done;
# thanks for the 'clang' fix below: https://stackoverflow.com/questions/29678215/compiling-vim-on-os-x-10-10-3-does-not-work
# thanks for the 'EXTRA_DEFS' fix below: http://vim.1045645.n5.nabble.com/Conflicting-definitions-for-tgoto-etc-when-cross-building-td1210909.html
$(BUILDIT)-vim: .set_title-$(BUILDIT)-vim
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(VIM_SRC))
	$(foreach FILE,$(shell $(VIM_PATCHES)),\
		$(call CURL_FILE,$(FILE)) $(call NEWLINE)$(ECHO); \
	)
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(VIM_DST),$(VIM_SRC))
	$(foreach FILE,$(shell $(VIM_PATCHES)),\
		$(call DO_PATCH,0,$(VIM_DST),$(FILE)) $(call NEWLINE)$(ECHO); \
	)
	$(call AUTOTOOLS_BUILD,$(VIM_DST),$(COMPOSER_ABODE),\
		$(if $(filter $(BUILD_PLAT),Darwin),CC="/usr/bin/clang" CFLAGS="$(subst $(LIBGCC),,$(CFLAGS))" LDFLAGS="$(subst $(LIBGCC),,$(LDFLAGS))") \
		EXTRA_DEFS="$(CFLAGS)" \
		,\
		--with-features="huge" \
		--enable-multibyte \
		--disable-acl \
		--disable-gpm \
		--disable-gui \
		--without-x \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-group-core
$(BUILDIT)-group-core: .set_title-$(BUILDIT)-group-core
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-make-init
	$(RUNMAKE) $(BUILDIT)-infozip
	$(RUNMAKE) $(BUILDIT)-curl
	$(RUNMAKE) $(BUILDIT)-git
	$(RUNMAKE) $(BUILDIT)-rsync
	@$(call BUILD_COMPLETE,--)

.PHONY: $(BUILDIT)-make-init
$(BUILDIT)-make-init: .set_title-$(BUILDIT)-make-init
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(MAKE_SRC_INIT))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(MAKE_DST_INIT),$(MAKE_SRC_INIT))
	# "$(BUILD_PLAT),Msys" requires "GNU_CFG_INSTALL"
	$(call GNU_CFG_INSTALL,$(MAKE_DST_INIT)/config)
	$(call MAKE_BUILD,$(MAKE_DST_INIT))
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" doesn't play nice with older versions
	$(RM) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/make"
endif
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-make
$(BUILDIT)-make: .set_title-$(BUILDIT)-make
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(MAKE_DST),$(MAKE_SRC),$(MAKE_CMT))
endif
ifneq ($(BUILD_FETCH),0)
#WORKING : separate network and placement into fetch/nofetch
#WORKING : should archive the results of "$(MAKE) update" below, similar to "CURL_CA_BUNDLE"
	cd "$(MAKE_DST)" && \
		$(BUILD_ENV) $(PERL) $(AUTORECONF) && \
		$(BUILD_ENV) $(SH) ./configure && \
		$(BUILD_ENV) $(MAKE) update || $(TRUE)
	$(call MAKE_BUILD,$(MAKE_DST))
	@$(call BUILD_COMPLETE)
endif

override define MAKE_BUILD =
	$(call AUTOTOOLS_BUILD,$(1),$(COMPOSER_ABODE),,\
		--without-guile \
	)
endef

.PHONY: $(BUILDIT)-infozip
$(BUILDIT)-infozip: .set_title-$(BUILDIT)-infozip
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(IZIP_SRC))
	$(call CURL_FILE,$(UZIP_SRC))
	$(call CURL_FILE,$(BZIP_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(IZIP_DST),$(IZIP_SRC))
	$(call DO_UNTAR_CLEAN,$(UZIP_DST),$(UZIP_SRC))
	$(call DO_UNTAR_CLEAN,$(BZIP_DST),$(BZIP_SRC))
	$(MKDIR) \
		"$(IZIP_DST)/bzip2" \
		"$(UZIP_DST)/bzip2"
	$(CP) "$(BZIP_DST)/"* "$(IZIP_DST)/bzip2/"
	$(CP) "$(BZIP_DST)/"* "$(UZIP_DST)/bzip2/"
	$(SED) -i \
		-e "s|^(prefix[ ][=][ ]).+$$|\1$(COMPOSER_ABODE)|g" \
		-e "s|([(]prefix[)][/])bin|\1$(BUILD_BINDIR)|g" \
		"$(IZIP_DST)/unix/Makefile" \
		"$(UZIP_DST)/unix/Makefile"
	cd "$(IZIP_DST)" && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile generic && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile install
	cd "$(UZIP_DST)" && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile generic && \
		$(BUILD_ENV) $(MAKE) --makefile ./unix/Makefile install
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-curl
# thanks for the 'CURL_CA_BUNDLE' fix below: https://curl.haxx.se/mail/lib-2006-11/0276.html
#	also to: http://comments.gmane.org/gmane.comp.web.curl.library/29555
$(BUILDIT)-curl: .set_title-$(BUILDIT)-curl
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(CURL_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(CURL_DST),$(CURL_SRC))
	# don't unlink the "certdata.txt" file after downloading and processing it
	$(SED) -i \
		-e "s|([ ][-]b[ ][-]l)[ ][-]u|\1|g" \
		"$(CURL_DST)/Makefile.in" \
		"$(CURL_DST)/Makefile"
	$(SED) -i \
		-e "s|^([#]define[ ]CURL_CA_BUNDLE[ ]).*$$|\1getenv(\"CURL_CA_BUNDLE\")|g" \
		"$(CURL_DST)/configure"
#WORK : would be nice to double-check:
#	* this works from bootstrap
#	* perl-lwp works if curl fails
#	* curl works on re-entry
#WORK
#WORKING : separate network and placement into fetch/nofetch
	cd "$(CURL_DST)" && \
		$(BUILD_ENV) $(MAKE) CURL_CA_BUNDLE="$(CURL_CA_BUNDLE)" ca-bundle && \
		$(MKDIR) "$(COMPOSER_STORE)" && \
		$(MKDIR) "$(COMPOSER_ABODE)" && \
		$(MV) "$(CURL_DST)/certdata.txt" "$(COMPOSER_STORE)/" && \
		$(MV) "$(CURL_DST)/lib/ca-bundle.crt" "$(COMPOSER_ABODE)/"
	$(call AUTOTOOLS_BUILD,$(CURL_DST),$(COMPOSER_ABODE),,\
		--with-ca-bundle="./ca-bundle.crt" \
		--disable-ldap \
		--without-libidn \
		--without-libssh2 \
		--disable-shared \
		--enable-static \
	)
	@$(call BUILD_COMPLETE)
endif

#WORKING : git is installing perl modules in ".home/lib64" directory, using native perl rather than built one

.PHONY: $(BUILDIT)-git
# thanks for the 'curl' fix below: https://curl.haxx.se/mail/lib-2007-05/0155.html
#	also to: http://www.makelinux.net/alp/021
# thanks for the 'librt' fix below: https://stackoverflow.com/questions/2418157/ubuntu-linux-c-error-undefined-reference-to-clock-gettime-and-clock-settim
# thanks for the 'framework' fix below: https://stackoverflow.com/questions/30896892/using-go-1-5-buildmode-c-archive-with-net-http-server-linked-from-c
#	also to: https://github.com/golang/go/issues/11258
# thanks for the 'APPLE_COMMON_CRYPTO' fix below: http://git.661346.n2.nabble.com/Deprecation-warnings-under-XCode-tt7622053.html#a7622092
$(BUILDIT)-git: .set_title-$(BUILDIT)-git
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(GIT_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(GIT_DST),$(GIT_SRC))
	$(SED) -i \
		-e "s|([-]lcurl)(.[^-])|\1 -lssl -lcrypto -lz $(if $(filter-out $(BUILD_PLAT),Darwin),-lrt)\2|g" \
		"$(GIT_DST)/configure"
	$(SED) -i \
		-e "s|([-]lcurl)$$|\1 -lssl -lcrypto -lz $(if $(filter-out $(BUILD_PLAT),Darwin),-lrt)|g" \
		"$(GIT_DST)/Makefile"
	$(call AUTOTOOLS_BUILD,$(GIT_DST),$(COMPOSER_ABODE),\
		$(if $(filter $(BUILD_PLAT),Darwin),CFLAGS="$(CFLAGS) -framework CoreFoundation") \
		NO_APPLE_COMMON_CRYPTO="1" \
		,\
		--without-tcltk \
	)
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-rsync
$(BUILDIT)-rsync: .set_title-$(BUILDIT)-rsync
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(RSYNC_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(RSYNC_DST),$(RSYNC_SRC))
	$(call AUTOTOOLS_BUILD,$(RSYNC_DST),$(COMPOSER_ABODE),,\
		--disable-acl-support \
		--disable-xattr-support \
		--with-included-popt \
	)
	@$(call BUILD_COMPLETE)
endif

# thanks for the 'clang' fix below: https://github.com/joyent/node/issues/9182
.PHONY: $(BUILDIT)-node
$(BUILDIT)-node: .set_title-$(BUILDIT)-node
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(NODE_DST),$(NODE_SRC),$(NODE_CMT))
endif
ifneq ($(BUILD_FETCH),0)
	$(call NODE_BUILD,$(NODE_DST),$(COMPOSER_ABODE)/usr,\
		$(if $(filter $(BUILD_PLAT),Darwin),CC="/usr/bin/clang" CFLAGS="$(subst $(LIBGCC),,$(CFLAGS))" LDFLAGS="$(subst $(LIBGCC),,$(LDFLAGS))") \
		$(if $(filter-out $(BUILD_PLAT),Msys),LDFLAGS="$(LDFLAGS_LDLIB)") \
	)
	@$(call BUILD_COMPLETE)
endif

#WORKING:NOW:create PYTHON_BUILD akin to AUTOTOOLS_BUILD, and use instead
override define NODE_BUILD =
	cd "$(1)" && \
		$(BUILD_ENV_MINGW) PYTHON="$(PYTHON)" PYTHONPATH="$(COMPOSER_ABODE)/lib/python2.7" $(3) ./configure --prefix="$(2)" && \
		$(BUILD_ENV_MINGW) PYTHON="$(PYTHON)" PYTHONPATH="$(COMPOSER_ABODE)/lib/python2.7" $(3) $(MAKE) && \
		$(BUILD_ENV_MINGW) PYTHON="$(PYTHON)" PYTHONPATH="$(COMPOSER_ABODE)/lib/python2.7" $(3) $(MAKE) install
endef

.PHONY: $(BUILDIT)-texlive
# thanks for the 'luajittex' fix below: http://permalink.gmane.org/gmane.comp.tex.texlive.build/2351
#	also to: http://permalink.gmane.org/gmane.comp.tex.texlive.build/2332
$(BUILDIT)-texlive: .set_title-$(BUILDIT)-texlive
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(TEX_TEXMF_SRC))
	$(call CURL_FILE,$(TEX_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(TEX_TEXMF_DST),$(TEX_TEXMF_SRC))
	$(call DO_UNTAR_CLEAN,$(TEX_DST),$(TEX_SRC))
ifeq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" is not detected, so default to "linux" settings
	$(CP) \
		"$(TEX_DST)/libs/icu/icu-"*"/source/config/mh-linux" \
		"$(TEX_DST)/libs/icu/icu-"*"/source/config/mh-unknown"
	# "$(BUILD_PLAT),Msys" doesn't seem to build these files
	$(SED) -i \
		-e "s|allcm[:]allec||g" \
		-e "s|fmtutil[:]mktexfmt||g" \
		-e "s|kpsetool[:]kpsexpand||g" \
		-e "s|kpsetool[:]kpsepath||g" \
		"$(TEX_DST)/texk/texlive/tl_scripts/Makefile.in"
endif
	# dear texlive, please don't remove the destination directory before installing to it...
	$(SED) -i \
		-e "s|^([ ]*rm[ ][-]rf[ ][$$]TL[_]WORKDIR[ ]).+$$|\1|g" \
		"$(TEX_DST)/Build"
	# make sure we link in all the right libraries
	$(SED) -i \
		-e "s|(kpse_cv_fontconfig_libs[=]).*$$|\1\"-lfontconfig -lexpat -liconv -L$(TEX_DST)/Work/libs/freetype2 $(shell "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/freetype-config" --libs --static)\"|g" \
		"$(TEX_DST)/texk/web2c/configure"
	# "$(BUILD_PLAT)$(BUILD_BITS),Msys64" requires "--disable-luajittex" in order to build
	cd "$(TEX_DST)" && $(BUILD_ENV) \
		TL_INSTALL_DEST="$(COMPOSER_ABODE)" \
		TL_CONFIGURE_ARGS="--bindir=\"$(COMPOSER_ABODE)/$(BUILD_BINDIR)\"" \
		TL_MAKE_FLAGS="--jobs$(if $(BUILD_JOBS),=$(BUILD_JOBS))" \
		$(SH) ./Build \
		--disable-multiplatform \
		--without-ln-s \
		--without-x \
		--disable-luajittex \
		--disable-shared \
		--enable-static
#ANTIQUATE
#>	$(call AUTOTOOLS_BUILD_NOTARGET,$(TEX_DST),$(COMPOSER_ABODE),,\
#>		--enable-build-in-source-tree \
#>		--disable-multiplatform \
#>		--without-ln-s \
#>		--without-x \
#>		--disable-luajittex \
#>		--disable-shared \
#>		--enable-static \
#>		,\
#>		--jobs$(if $(BUILD_JOBS),=$(BUILD_JOBS)) \
#>	)
#ANTIQUATE
	$(CP) "$(TEX_TEXMF_DST)/"*				"$(COMPOSER_ABODE)/"
#WORKING:MACP
	$(CP) "$(TEX_DST)/texk/tests/TeXLive"			"$(COMPOSER_ABODE)/lib/perl$(word 1,$(subst ., ,$(PERL_VER)))/site_perl/$(PERL_VER)/"
	$(RM)							"$(COMPOSER_ABODE)/$(BUILD_BINDIR)/pdflatex"
	$(CP) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/pdftex"	"$(COMPOSER_ABODE)/$(BUILD_BINDIR)/pdflatex"
	@$(call BUILD_COMPLETE)
endif
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-texlive-fmtutil

.PHONY: $(BUILDIT)-texlive-fmtutil
$(BUILDIT)-texlive-fmtutil: .set_title-$(BUILDIT)-texlive-fmtutil
ifneq ($(BUILD_FETCH),0)
	# the "--no-error-if-no-engine" option goes with "--disable-luajittex" above
	$(BUILD_ENV) fmtutil \
		--no-error-if-no-engine="luajittex" \
		--all
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-group-init
$(BUILDIT)-group-init: .set_title-$(BUILDIT)-group-init
	@$(call BUILD_COMPLETE,++)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-ghc-init
	$(RUNMAKE) $(BUILDIT)-cabal-init
	@$(call BUILD_COMPLETE,--)

.PHONY: $(BUILDIT)-ghc-init
$(BUILDIT)-ghc-init: .set_title-$(BUILDIT)-ghc-init
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(GHC_SRC_INIT))
endif
ifneq ($(BUILD_FETCH),0)
	$(call DO_UNTAR_CLEAN,$(GHC_DST_INIT),$(GHC_SRC_INIT))
ifeq ($(BUILD_PLAT),Msys)
	$(MKDIR) "$(BUILD_STRAP)/usr"
	$(CP) "$(GHC_DST_INIT)/"* "$(BUILD_STRAP)/usr/"
else
ifeq ($(BUILD_PLAT),Linux)
	$(MKDIR) "$(BUILD_LDLIB)/lib"
	$(CP) -L "$(BUILD_LDLIB)/lib/libtinfo.so" "$(BUILD_LDLIB)/lib/libtinfo.so.5"
endif
	$(call AUTOTOOLS_BUILD_NOOPTION_MINGW,$(GHC_DST_INIT),$(BUILD_STRAP)/usr,,,\
		show \
	)
endif
	@$(call BUILD_COMPLETE)
endif

.PHONY: $(BUILDIT)-ghc
# thanks for the 'removeFiles' fix below: https://ghc.haskell.org/trac/ghc/ticket/7712
$(BUILDIT)-ghc: .set_title-$(BUILDIT)-ghc
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(GHC_DST),$(GHC_SRC),$(GHC_CMT),$(GHC_BRANCH))
	$(call GIT_SUBMODULE_GHC,$(GHC_DST))
endif
ifneq ($(BUILD_FETCH),0)
ifneq ($(COMPOSER_TESTING),)
	$(ECHO) "$(_C)"; \
		$(foreach FILE,$(wildcard \
			$(GHC_DST)/libraries/*/*/*.cabal \
			$(GHC_DST)/libraries/*/*.cabal \
			$(GHC_DST)/utils/*/*.cabal \
			$(GHC_DST)/rts/package.conf.in \
			),\
			$(ECHO) "$(notdir $(subst .cabal,,$(subst /package.conf.in,,$(FILE))))|"; \
			$(SED) -n \
				-e "s|^[Vv]ersion[:][[:space:]]+||gp" \
				"$(FILE)"; \
		) \
	$(ECHO) "$(_D)"
else
	cd "$(GHC_DST)" && \
		$(BUILD_ENV_MINGW) $(PERL) ./boot
	# expose "$(BUILD_PLAT),Msys" paths as environment variables
	#	https://www.haskell.org/ghc/dist/latest/docs/html/libraries/Win32-2.3.0.2/System-Win32-Shell.html
	#	$(GHC_DST)/libraries/directory/System/Directory.hs [getEnv]
	#		findExecutable			Win32.searchPath Nothing binary ('.':exeExtension)	PATH
	#		getHomeDirectory		Win32.cSIDL_PROFILE | Win32.cSIDL_WINDOWS		HOME
	#		getAppUserDataDirectory		Win32.cSIDL_APPDATA					HOME
	#		getUserDocumentsDirectory	Win32.cSIDL_PERSONAL					HOME
	#		getTemporaryDirectory		Win32.getTemporaryDirectory (TMP, TEMP, USERPROFILE)	TMPDIR
	# using 'USERPROFILE' causes 'cabal.exe: illegal operation'
#WORKING:NOW : this does not seem to work for 7.8
# "inplace/bin/ghc-stage1.exe" -hisuf hi -osuf  o -hcsuf hc -static  -optc-I/c/.composer/.home/bootstrap/include -optc-L/c/.composer/.home/bootstrap/lib -optP-I/c/.composer/.home/bootstrap/include -optl-L/c/.composer/.home/bootstrap/lib -optc-I/c/.composer/.home/include -optc-L/c/.composer/.home/lib -optP-I/c/.composer/.home/include -optl-L/c/.composer/.home/lib -optc-m32 -optc-march=i686 -optc-mtune=generic -optc-O1 -opta-m32 -opta-march=i686 -opta-mtune=generic -opta-O1    -package-name directory-1.2.1.0 -hide-all-packages -i -ilibraries/directory/. -ilibraries/directory/dist-install/build -ilibraries/directory/dist-install/build/autogen -Ilibraries/directory/dist-install/build -Ilibraries/directory/dist-install/build/autogen -Ilibraries/directory/include    -optP-include -optPlibraries/directory/dist-install/build/autogen/cabal_macros.h -package Win32-2.3.0.2 -package base-4.7.0.1 -package filepath-1.3.0.2 -package time-1.4.2 -Wall -XHaskell2010 -O2  -no-user-package-db -rtsopts      -odir libraries/directory/dist-install/build -hidir libraries/directory/dist-install/build -stubdir libraries/directory/dist-install/build -split-objs  -c libraries/directory/./System/Directory.hs -o libraries/directory/dist-install/build/System/Directory.o
# libraries\directory\System\Directory.hs:1096:18:
#     Not in scope: `getEnv'
# libraries\directory\System\Directory.hs:1100:23:
#     Not in scope: `getEnv'
# libraries\directory\System\Directory.hs:1139:10:
#     Not in scope: `getEnv'
# libraries\directory\System\Directory.hs:1171:5:
#     Not in scope: `getEnv'
# libraries/directory/ghc.mk:4: recipe for target 'libraries/directory/dist-install/build/System/Directory.o' failed
# make[1]: *** [libraries/directory/dist-install/build/System/Directory.o] Error 1
# Makefile:64: recipe for target 'all' failed
# make: *** [all] Error 2
# /c/.composer/Makefile:3732: recipe for target 'build-ghc' failed
# make[1]: *** [build-ghc] Error 2
# make[1]: Leaving directory '/c/.composer'
# Makefile:2593: recipe for target 'nofetch-ghc' failed
# make: *** [nofetch-ghc] Error 2
#WORKING
#	$(SED) -i \
#		-e "s|Win32[.]sHGetFolderPath[ ]nullPtr[ ]Win32[.]cSIDL_PROFILE[ ]nullPtr[ ]0|getEnv \"HOMEPATH\"|g" \
#		-e "s|Win32[.]sHGetFolderPath[ ]nullPtr[ ]Win32[.]cSIDL_WINDOWS[ ]nullPtr[ ]0|getEnv \"HOMEPATH\"|g" \
#		-e "s|Win32[.]sHGetFolderPath[ ]nullPtr[ ]Win32[.]cSIDL_APPDATA[ ]nullPtr[ ]0|getEnv \"HOMEPATH\"|g" \
#		-e "s|Win32[.]sHGetFolderPath[ ]nullPtr[ ]Win32[.]cSIDL_PERSONAL[ ]nullPtr[ ]0|getEnv \"HOMEPATH\"|g" \
#		-e "s|([^.])(.)([:]appName[)])|\1\2:\2.\2\3|g" \
#		"$(GHC_DST)/libraries/directory/System/Directory.hs"
#WORKING
	# "$(BUILD_PLAT),Msys" fails if we don't have these calls quoted
	$(SED) -i \
		-e "s|(call[ ]removeFiles[,])([$$][(]GHCII[_]SCRIPT[)])|\1\"\2\"|g" \
		"$(GHC_DST)/driver/ghci/ghc.mk"
	$(SED) -i \
		-e "s|(call[ ]removeFiles[,])([$$][(]DESTDIR[)][$$][(]bindir[)][/]ghc.exe)|\1\"\2\"|g" \
		"$(GHC_DST)/ghc/ghc.mk"
#ANTIQUATE
#>	$(SED) -i \
#>		-e "s|$(GHC_CABAL_VER)|$(CABAL_VER)|g" \
#>		"$(GHC_DST)/libraries/Cabal/Cabal/Cabal.cabal" \
#>		"$(GHC_DST)/libraries/Cabal/Cabal/Makefile"
#>	$(SED) -i \
#>		-e "s|([ ]+Cabal[ ]+)[>][=][^,]+|\1==$(CABAL_VER)|g" \
#>		"$(GHC_DST)/libraries/Cabal/cabal-install/cabal-install.cabal" \
#>		"$(GHC_DST)/libraries/bin-package-db/bin-package-db.cabal" \
#>		"$(GHC_DST)/utils/ghc-cabal/ghc-cabal.cabal"
#ANTIQUATE
	$(SED) -i \
		-e "s|(RELEASE[=])NO|\1YES|g" \
		-e "s|([\"][$$]WithGhc[\"][ ])([$$]GHC[_]LDFLAGS[ ][-]v0)|\1$(GHCFLAGS) \2|g" \
		"$(GHC_DST)/configure"
	$(call DO_HEREDOC,$(call HEREDOC_GHC_BUILD_MK)) >"$(GHC_DST)/mk/build.mk"
	$(call AUTOTOOLS_BUILD_NOOPTION_MINGW,$(GHC_DST),$(COMPOSER_ABODE)/usr,,,\
		--jobs$(if $(BUILD_JOBS),=$(BUILD_JOBS)) \
	)
	@$(call BUILD_COMPLETE)
endif
endif

override define HEREDOC_GHC_BUILD_MK =
override SRC_CC_OPTS	:= $(CFLAGS_LDLIB)
override SRC_CPP_OPTS	:= $(CPPFLAGS_LDLIB)
override SRC_LD_OPTS	:= $(LDFLAGS_LDLIB)
override SRC_HC_OPTS	:= $(if $(filter $(BUILD_PLAT),Darwin),$(subst -optl$(LDLIB_RUN_PATH),,$(GHCFLAGS_LDLIB)),$(GHCFLAGS_LDLIB))
endef

.PHONY: $(BUILDIT)-cabal-init
$(BUILDIT)-cabal-init: .set_title-$(BUILDIT)-cabal-init
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(CABAL_SRC_INIT))
	$(call CABAL_PULL,$(CABAL_LIBRARIES_INIT_LIST))
endif
ifneq ($(BUILD_FETCH),0)
ifneq ($(COMPOSER_TESTING),)
	$(call CABAL_COMPOSER_TESTING,$(CABAL_DST_INIT))
else
	$(call DO_UNTAR_CLEAN,$(CABAL_DST_INIT),$(CABAL_SRC_INIT))
	$(call CABAL_PREP,$(CABAL_DST_INIT),$(CABAL_LIBRARIES_INIT_LIST))
	$(call CABAL_BUILD,$(CABAL_DST_INIT),$(BUILD_STRAP))
	@$(call BUILD_COMPLETE)
endif
endif
ifeq ($(COMPOSER_TESTING),)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-cabal-init-libs
endif

.PHONY: $(BUILDIT)-cabal
$(BUILDIT)-cabal: .set_title-$(BUILDIT)-cabal
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(CABAL_DST),$(CABAL_SRC),$(CABAL_CMT))
	$(call CABAL_PULL,$(CABAL_LIBRARIES_LIST))
endif
ifneq ($(BUILD_FETCH),0)
ifneq ($(COMPOSER_TESTING),)
	$(call CABAL_COMPOSER_TESTING,$(CABAL_DST)/cabal-install)
else
	$(RM) -r "$(CABAL_DST)/cabal-install/Cabal-$(CABAL_VER_INIT)"
	$(CP) "$(CABAL_DST)/Cabal" "$(CABAL_DST)/cabal-install/Cabal-$(CABAL_VER_INIT)"
	$(call CABAL_PREP,$(CABAL_DST)/cabal-install,$(CABAL_LIBRARIES_LIST),GHCFLAGS_SYSLIB_SUBST_TRUE)
	$(call CABAL_BUILD,$(CABAL_DST)/cabal-install,$(COMPOSER_ABODE))
	@$(call BUILD_COMPLETE)
endif
endif
ifeq ($(COMPOSER_TESTING),)
	# call recursively instead of using dependencies, so that environment variables update
	$(RUNMAKE) $(BUILDIT)-cabal-libs
endif

#WORK : document!
.PHONY: $(BUILDIT)-cabal-init-libs
$(BUILDIT)-cabal-init-libs: .set_title-$(BUILDIT)-cabal-init-libs
ifneq ($(BUILD_FETCH),)
	$(call CABAL_BUILD_GHC_LIBRARIES_PULL)
endif
ifneq ($(BUILD_FETCH),0)
	$(call CABAL_BUILD_GHC_LIBRARIES_BUILD,$(CABAL_DST_INIT).libs,$(BUILD_STRAP))
	@$(call BUILD_COMPLETE)
endif

#WORK : document!
.PHONY: $(BUILDIT)-cabal-libs
$(BUILDIT)-cabal-libs: .set_title-$(BUILDIT)-cabal-libs
ifneq ($(BUILD_FETCH),)
	$(call CABAL_BUILD_GHC_LIBRARIES_PULL)
endif
ifneq ($(BUILD_FETCH),0)
	$(call CABAL_BUILD_GHC_LIBRARIES_BUILD,$(CABAL_DST).libs,$(COMPOSER_ABODE),GHCFLAGS_SYSLIB_SUBST_TRUE)
	@$(call BUILD_COMPLETE)
endif

override define CABAL_PULL =
	$(foreach FILE,$(subst |,-,$(1)), \
		$(call HACKAGE_PULL,$(FILE)); \
	)
endef
override define CABAL_COMPOSER_TESTING =
	$(ECHO) "$(_C)"; \
		$(SED) -n \
			-e "s|^([A-Z_]+)[_]VER[=][\"]([^\"]+)[\"].+REGEXP.+$$|\1=\2|gp" \
			"$(1)/bootstrap.sh"; \
	$(ECHO) "$(_D)"
endef
override define CABAL_PREP =
	$(foreach FILE,$(subst |,-,$(2)), \
		$(call HACKAGE_PREP,$(FILE),$(1)); \
	)
	$(call CABAL_NETWORK_FIX,$(1))
	# exert control over how packages are built and installed
	$(SED) -i \
		-e "s|^(CABAL[_]VER[=][\"])[^\"]+([\"])|\1$(CABAL_VER_INIT)\2|g" \
		-e "s|^([ ]+fetch[_]pkg[ ][$$][{]PKG[}])|#\1|g" \
		-e "s|^([ ]+unpack[_]pkg[ ][$$][{]PKG[}])|#\1|g" \
		-e "s|([{]GHC[}][ ])([-][-]make[ ])|\1$(call GHCFLAGS_SYSLIB_SUBST,$(GHCFLAGS),$(3)) \2|g" \
		"$(1)/bootstrap.sh"
	$(SED) -i \
		-e "s|(ghc[-]options[:][[:space:]]+)([-]Wall)|\1$(call GHCFLAGS_SYSLIB_SUBST,$(GHCFLAGS),$(3)) \2|g" \
		"$(1)/cabal-install.cabal"
endef
# thanks for the 'getnameinfo' fix below: https://www.mail-archive.com/haskell-cafe@haskell.org/msg60731.html
override define CABAL_NETWORK_FIX =
	# "$(BUILD_PLAT),Msys" requires some patching
	$(SED) -i \
		-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" \
		-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" \
		-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" \
		"$(1)/network-"*"/include/HsNet.h"
endef
#ANTIQUATE
#>$(call DO_HEREDOC,$(call HEREDOC_CABAL_BOOTSTRAP,$(1))) >"$(1)/bootstrap.patch.sh"; \
#>$(CHMOD) "$(1)/bootstrap.patch.sh"; \
#>$(SED) -i \
#>	-e "s|^(.+[{]GZIP[}].+)$$|\1\n\"$(1)/bootstrap.patch.sh\"|g" \
#>	"$(1)/bootstrap.sh"; \
#>
#>override define HEREDOC_CABAL_BOOTSTRAP =
#>#!$(SHELL)
#>[ -f "$(1)/network-"*"/include/HsNet.h" ] && $(SED) -i [B]
#>	-e "s|(return[ ])(getnameinfo)|\1hsnet_\2|g" [B]
#>	-e "s|(return[ ])(getaddrinfo)|\1hsnet_\2|g" [B]
#>	-e "s|^([ ]+)(freeaddrinfo)|\1hsnet_\2|g" [B]
#>	"$(1)/network-"*"/include/HsNet.h" || exit 1
#>exit 0
#>endef
#ANTIQUATE
override define CABAL_BUILD =
	cd "$(1)" && $(BUILD_ENV_MINGW) \
		PREFIX="$(2)" \
		CFLAGS="$(CFLAGS_LDLIB)" \
		CPPFLAGS="$(CPPFLAGS_LDLIB)" \
		LDFLAGS="$(LDFLAGS_LDLIB)" \
		GHCFLAGS="$(GHCFLAGS_LDLIB)" \
		EXTRA_CONFIGURE_OPTS="$(subst ",,$(call CABAL_OPTIONS_LDLIB,$(2)))" \
		$(SH) ./bootstrap.sh --global
endef
#> syntax highlighting fix: )"
override define CABAL_BUILD_GHC_LIBRARIES_PULL =
	$(foreach FILE,$(subst |,-,$(CABAL_LIBRARIES_GHC_LIST)),\
		$(call HACKAGE_PULL,$(FILE)); \
	)
endef
override define CABAL_BUILD_GHC_LIBRARIES_BUILD =
	$(foreach FILE,$(subst |,-,$(CABAL_LIBRARIES_GHC_LIST)),\
		$(call HACKAGE_PREP,$(FILE),$(1)); \
	)
	$(call GHCFLAGS_SYSLIB_SUBST,$(call CABAL_INSTALL,_LDLIB,$(2)),$(3)) \
		$(foreach FILE,$(subst |,-,$(CABAL_LIBRARIES_GHC_LIST)),\
			"$(1)/$(FILE)" \
		)
endef

override PANDOC_LIBRARIES_LIST_REQUESTED := $(sort $(subst |,-,\
	$(PANDOC_LIBRARIES_LIST_REQUIRED) \
))
override PANDOC_LIBRARIES_LIST_PACKAGEDB := $(strip $(shell \
	$(filter-out --verbose,$(DO_GHC_PKG)) list 2>/dev/null | \
	$(SED) \
		-e "/package[.]conf[.]d/d" \
		-e "s|[{()}]||g" \
))
override PANDOC_LIBRARIES_LIST_NOTLISTED := $(filter-out \
	$(PANDOC_LIBRARIES_LIST_PACKAGEDB) \
	,\
	$(PANDOC_LIBRARIES_LIST_REQUESTED) \
)
override PANDOC_LIBRARIES_LIST_UNINSTALL := $(filter-out \
	$(PANDOC_LIBRARIES_LIST_REQUESTED) \
	,\
	$(PANDOC_LIBRARIES_LIST_PACKAGEDB) \
)

.PHONY: $(BUILDIT)-pandoc
$(BUILDIT)-pandoc: .set_title-$(BUILDIT)-pandoc
ifeq ($(COMPOSER_TESTING),-1)
ifneq ($(word 1,$(GHC_PKG)),"")
	@$(foreach FILE,\
		REQUESTED \
		PACKAGEDB \
		NOTLISTED \
		UNINSTALL \
		,\
		$(ESCAPE) "$(_C)$(FILE): $(_M)$(PANDOC_LIBRARIES_LIST_$(FILE))"; \
	)
ifneq ($(PANDOC_LIBRARIES_LIST_UNINSTALL),)
	@$(ECHO) "$(subst $(NULL) ,\n,$(PANDOC_LIBRARIES_LIST_UNINSTALL))\n" | while read FILE; do \
		$(DO_GHC_PKG) unregister $${FILE}; \
	done
endif
endif
else
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(PANDOC_DST),$(PANDOC_SRC),$(PANDOC_CMT))
	$(call GIT_REPO,$(PANDOC_TYPE_DST),$(PANDOC_TYPE_SRC),$(PANDOC_TYPE_CMT))
	$(call GIT_REPO,$(PANDOC_MATH_DST),$(PANDOC_MATH_SRC),$(PANDOC_MATH_CMT))
	$(call GIT_REPO,$(PANDOC_HIGH_DST),$(PANDOC_HIGH_SRC),$(PANDOC_HIGH_CMT))
	$(call GIT_REPO,$(PANDOC_CITE_DST),$(PANDOC_CITE_SRC),$(PANDOC_CITE_CMT))
#ANTIQUATE
#>	# make sure GHC looks for libraries in the right place
#>	if [ -f "$(COMPOSER_ABODE)/.cabal/config" ]; then \
#>		$(SED) -i \
#>			-e "s|(gcc[-]options[:]).*$$|\1 $(CFLAGS)|g" \
#>			-e "s|(ld[-]options[:]).*$$|\1 $(LDFLAGS)|g" \
#>			-e "s|(ghc[-]options[:]).*$$|\1 $(GHCFLAGS)|g" \
#>			"$(COMPOSER_ABODE)/.cabal/config"; \
#>	fi
#>	$(SED) -i \
#>		-e "s|(Ghc[-]Options[:][ ]+)([-]rtsopts)|\1$(GHCFLAGS) \2|g" \
#>		-e "s|(ghc[-]options[:][ ]+)([-]funbox[-]strict[-]fields)|\1$(GHCFLAGS) \2|g" \
#>		"$(PANDOC_CITE_DST)/pandoc-citeproc.cabal" \
#>		"$(PANDOC_DST)/pandoc.cabal"
#ANTIQUATE
	$(foreach FILE,$(subst |,-,$(PANDOC_LIBRARIES_LIST)),\
		$(call HACKAGE_PULL,$(FILE)); \
	)
ifneq ($(COMPOSER_TESTING),)
ifneq ($(word 1,$(CABAL)),"")
#WORKING : is "$APPDATA/cabal" fixed?  what about "$APPDATA/ghc"?  if they linger, should we warn or clean them up?
	$(DO_CABAL) update
	$(ECHO) "$(_C)"; \
		$(call GHCFLAGS_SYSLIB_SUBST,$(call CABAL_INSTALL,_LDLIB,$(COMPOSER_ABODE)),GHCFLAGS_SYSLIB_SUBST_TRUE) \
			$(foreach FILE,$(PANDOC_LIBRARIES_LIST_REQUIRED),--constraint="$(subst |,==,$(FILE))") \
			--only-dependencies \
			--enable-tests \
			--dry-run \
			$(PANDOC_DIRECTORIES); \
	$(ECHO) "$(_D)"
	$(ECHO) "$(_C)"; \
		$(call GHCFLAGS_SYSLIB_SUBST,$(call CABAL_INSTALL,_LDLIB,$(COMPOSER_ABODE)),GHCFLAGS_SYSLIB_SUBST_TRUE) \
			--dry-run \
			$(subst |,-,$(PANDOC_LIBRARIES_LIST)); \
	$(ECHO) "$(_D)"
	$(RM) -r "$(COMPOSER_ABODE)/.cabal/packages"
endif
endif
endif
ifneq ($(BUILD_FETCH),0)
	@$(ESCAPE) "\n$(_H)$(MARKER) Dependencies"
ifneq ($(COMPOSER_TESTING),0)
	$(foreach FILE,$(subst |,-,$(PANDOC_LIBRARIES_LIST)),\
		$(call HACKAGE_PREP,$(FILE),$(PANDOC_DST).libs); \
	)
	$(call CABAL_NETWORK_FIX,$(PANDOC_DST).libs)
	$(call GHCFLAGS_SYSLIB_SUBST,$(call CABAL_INSTALL,_LDLIB,$(COMPOSER_ABODE)),GHCFLAGS_SYSLIB_SUBST_TRUE) \
		$(foreach FILE,$(subst |,-,$(PANDOC_LIBRARIES_LIST)),\
			"$(PANDOC_DST).libs/$(FILE)" \
		)
endif
	$(SED) -i \
		-e "/cabal[ ]install[ ]HXT/d" \
		-e "s|(ghc[ ])([-][-]make[ ])|$(subst ",\",$(GHC)) $(call GHCFLAGS_SYSLIB_SUBST,$(GHCFLAGS),GHCFLAGS_SYSLIB_SUBST_TRUE) \2|g" \
		"$(PANDOC_HIGH_DST)/Makefile"
	cd "$(PANDOC_HIGH_DST)" && \
		$(BUILD_ENV_MINGW) $(MAKE) prep
	@$(ESCAPE) "\n$(_H)$(MARKER) Install"
	$(call GHCFLAGS_SYSLIB_SUBST,$(call CABAL_INSTALL,,$(COMPOSER_ABODE)),GHCFLAGS_SYSLIB_SUBST_TRUE) \
		--flags="$(PANDOC_FLAGS)" \
		--enable-tests \
		$(PANDOC_DIRECTORIES)
ifneq ($(BUILD_PLAT),Msys)
	# "$(BUILD_PLAT),Msys" hangs when running "test-pandoc*"
	@$(ESCAPE) "\n$(_H)$(MARKER) Test"
	$(foreach FILE,$(PANDOC_DIRECTORIES),\
		cd $(FILE) && \
			$(DO_CABAL) test || $(TRUE); \
	)
endif
	$(RM) -r "$(COMPOSER_ABODE)/.pandoc"
	$(MKDIR) "$(COMPOSER_ABODE)/.pandoc"
ifeq ($(BUILD_PLAT),Msys)
	$(CP) "$(COMPOSER_ABODE)/"*-*-ghc-$(GHC_VER)/pandoc-$(PANDOC_VER)/* "$(COMPOSER_ABODE)/.pandoc/"
else
	$(CP) "$(COMPOSER_ABODE)/share/"*-*-ghc-$(GHC_VER)/pandoc-$(PANDOC_VER)/* "$(COMPOSER_ABODE)/.pandoc/"
endif
	$(SED) -i \
		-e "s|(reveal[.])min[.]|\1|g" \
		"$(COMPOSER_ABODE)/.pandoc/data/templates/default.revealjs"
	@$(call BUILD_COMPLETE)
	@$(ECHO) "$(_E)\n"
	@$(TAIL) -n6 $(PANDOC_DST)*/dist/test/*-test-*.log || $(TRUE)
	@$(ECHO) "$(_M)\n"
	@$(BUILD_ENV) "$(COMPOSER_ABODE)/$(BUILD_BINDIR)/pandoc" --version
	@$(ECHO) "$(_D)"
endif
endif
#> syntax highlighting fix: )"

# this list should be mirrored from "$(MSYS_BINARY_LIST)" and "$(BUILD_BINARY_LIST)"
# for some reason, "$(BZIP)" hangs with the "--version" argument, so we'll use "--help" instead
# "$(BZIP)" and "$(LESS)" use those environment variables as additional arguments, so they need to be empty
#WORKING:NOW
# "$(LDD)", "$(GHC)" and "$(CABAL)" require "$(WORKING)" to find libraries, so we wrap them in "$(BUILD_ENV)"
# VERIFY WHETHER THIS IS TRUE!
#WORKING:NOW
# should only show tooling versions, and hide "$(BUILDIT)" versions and paths behind "$(COMPOSER_DEBUGIT)"
# maybe paths should be wholesale: 1. splicing them will be tricky, 2. it's only relevant when debugging, and 3. we're moving towards a default of "$(COMPOSER_PROGS)" anyway
# also need to update "$(DEBUGIT)" target, then, in this case
#WORKING:NOW
.PHONY: $(CHECKIT)
$(CHECKIT): .set_title-$(CHECKIT)
$(CHECKIT): override GLIBC_VERSIONS		:= $(GLIBC_CUR_VERSION)[$(LINUX_CUR_VERSION)] $(_D)($(_H)>=$(GLIBC_MIN_VERSION)[$(LINUX_MIN_VERSION)]$(_D))
$(CHECKIT): override GCC_VERSIONS		:= $(GCC_CUR_VERSION) $(_D)($(_H)>=$(GCC_MIN_VERSION)$(_D))
$(CHECKIT): override BINUTILS_VERSIONS		:= $(BINUTILS_CUR_VERSION) $(_D)($(_H)>=$(BINUTILS_MIN_VERSION)$(_D))
$(CHECKIT): override MAKE_VERSIONS		:= $(MAKE_CUR_VERSION) $(_D)($(_H)>=$(MAKE_MIN_VERSION)$(_D))
$(CHECKIT): override NODE_VERSIONS		:= $(NODE_VER) $(_D)($(_H)$(strip		$(if $(filter v$(NODE_VER),$(NODE_CMT)),		=,$(shell $(ECHO) "$(NODE_CMT)"		| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override PANDOC_VERSIONS		:= $(PANDOC_VER) $(_D)($(_H)$(strip		$(if $(filter $(PANDOC_VER),$(PANDOC_CMT)),		=,$(shell $(ECHO) "$(PANDOC_CMT)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override PANDOC_TYPE_VERSIONS	:= $(PANDOC_TYPE_VER) $(_D)($(_H)$(strip	$(if $(filter $(PANDOC_TYPE_VER),$(PANDOC_TYPE_CMT)),	=,$(shell $(ECHO) "$(PANDOC_TYPE_CMT)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override PANDOC_MATH_VERSIONS	:= $(PANDOC_MATH_VER) $(_D)($(_H)$(strip	$(if $(filter $(PANDOC_MATH_VER),$(PANDOC_MATH_CMT)),	=,$(shell $(ECHO) "$(PANDOC_MATH_CMT)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override PANDOC_HIGH_VERSIONS	:= $(PANDOC_HIGH_VER) $(_D)($(_H)$(strip	$(if $(filter $(PANDOC_HIGH_VER),$(PANDOC_HIGH_CMT)),	=,$(shell $(ECHO) "$(PANDOC_HIGH_CMT)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override PANDOC_CITE_VERSIONS	:= $(PANDOC_CITE_VER) $(_D)($(_H)$(strip	$(if $(filter $(PANDOC_CITE_VER),$(PANDOC_CITE_CMT)),	=,$(shell $(ECHO) "$(PANDOC_CITE_CMT)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override TEX_VERSIONS		:= $(TEX_VER) $(_D)($(_H)$(strip		$(if $(filter $(TEX_VER),$(TEX_TEXMF_VER)),		=,$(shell $(ECHO) "$(TEX_TEXMF_VER)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override GHC_VERSIONS		:= $(GHC_VER) $(_D)($(_H)$(strip		$(if $(filter ghc-$(GHC_VER)-release,$(GHC_CMT)),	=,$(shell $(ECHO) "$(GHC_CMT)"		| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override CABAL_VERSIONS		:= $(CABAL_VER) $(_D)($(_H)$(strip		$(if $(filter Cabal-$(CABAL_VER)-release,$(CABAL_CMT)),	=,$(shell $(ECHO) "$(CABAL_CMT)"	| $(SED) "s|^($(COMPOSER_CMT_REGEX)).*$$|\1[...]|g")	))$(_D))
$(CHECKIT): override CABAL_VERSIONS_LIB		:= $(CABAL_VER) $(_D)($(_H)$(strip		$(if $(filter $(CABAL_VER),$(GHC_CABAL_VER)),		=,$(_E)+=$(GHC_CABAL_VER)									))$(_D))
$(CHECKIT):
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_H)Project"			"$(COMPOSER_BASENAME) Version"	"Current Version(s)"
	@$(HEADER_L)
ifeq ($(BUILD_PLAT),Msys)
	@$(TABLE_I3) "$(MARKER) $(_E)MSYS2"		"$(_E)$(MSYS_VER)"		"$(_N)$(shell $(PACMAN) --version		2>/dev/null | $(SED) -n "s|^.*(Pacman[ ].*)$$|\1|gp")"
	@$(TABLE_I3) "- $(_E)MinTTY"			"$(_E)*"			"$(_N)$(shell $(MINTTY) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Cygpath"			"$(_E)*"			"$(_N)$(shell $(CYGPATH) --version		2>/dev/null | $(HEAD) -n1)"
endif
#WORKING:NOW : LDD to 2>&1 for darwin; does it break linux/msys?
#WORKING:NOW : LDD needs different title, and version, for darwin; same with BINUTILS?
	@$(TABLE_I3) "$(MARKER) $(_E)GNU C Library"	"$(_E)$(GLIBC_VERSIONS)"	"$(_N)$(shell $(LDD) --version			2>&1        | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU C Compiler"		"$(_E)$(GCC_VERSIONS)"		"$(_N)$(shell $(CC) --version			2>/dev/null | $(HEAD) -n1) $(_S)[$(shell $(CXX) --version 2>/dev/null | $(HEAD) -n1)]"
	@$(TABLE_I3) "- $(_E)GNU Linker"		"$(_E)$(BINUTILS_VERSIONS)"	"$(_N)$(shell $(LD) --version			2>/dev/null | $(HEAD) -n1) $(_S)[$(shell $(CPP) --version 2>/dev/null | $(HEAD) -n1)]"
	@$(TABLE_I3) "$(MARKER) $(_E)GNU Coreutils"	"$(_E)$(COREUTILS_VER)"		"$(_N)$(shell $(LS) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Findutils"		"$(_E)$(FINDUTILS_VER)"		"$(_N)$(shell $(FIND) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Patch"			"$(_E)$(PATCH_VER)"		"$(_N)$(shell $(PATCH) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Sed"			"$(_E)$(SED_VER)"		"$(_N)$(shell $(SED) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Bzip2"			"$(_E)$(BZIP_VER)"		"$(_N)$(shell BZIP= $(BZIP) --help		2>&1        | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Gzip"			"$(_E)$(GZIP_VER)"		"$(_N)$(shell $(GZIP) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)XZ Utils"			"$(_E)$(XZ_VER)"		"$(_N)$(shell $(XZ) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)GNU Tar"			"$(_E)$(TAR_VER)"		"$(_N)$(shell $(TAR) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_E)Perl"			"$(_E)$(PERL_VER)"		"$(_N)$(shell $(PERL) --version			2>/dev/null | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_I3) "- $(_E)Python"			"$(_E)$(PYTHON_VER)"		"$(_N)$(shell $(PYTHON) --version		2>&1        | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)GNU Bash"			"$(_M)$(BASH_VER)"		"$(_D)$(shell $(BASH) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Less"			"$(_M)$(LESS_VER)"		"$(_D)$(shell LESS= $(LESS) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Vim"			"$(_M)$(VIM_VER)"		"$(_D)$(shell $(VIM) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)GNU Make"			"$(_M)$(MAKE_VERSIONS)"		"$(_D)$(shell $(MAKE) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Info-ZIP (Zip)"		"$(_M)$(IZIP_VER)"		"$(_D)$(shell $(ZIP) --version			2>/dev/null | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_I3) "- $(_C)Info-ZIP (UnZip)"		"$(_M)$(UZIP_VER)"		"$(_D)$(shell $(UNZIP) --version		2>&1        | $(HEAD) -n2 | $(TAIL) -n1)"
	@$(TABLE_I3) "- $(_C)cURL"			"$(_M)$(CURL_VER)"		"$(_D)$(shell $(CURL) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Git SCM"			"$(_M)$(GIT_VER)"		"$(_D)$(shell $(GIT) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Rsync"			"$(_M)$(RSYNC_VER)"		"$(_D)$(shell $(RSYNC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Node.js"			"$(_M)$(NODE_VERSIONS)"		"$(_D)$(shell $(NODE) --version			2>/dev/null | $(HEAD) -n1) $(_S)[$(shell $(NPM) --version 2>/dev/null | $(HEAD) -n1)]"
	@$(TABLE_I3) "$(_C)Pandoc"			"$(_M)$(PANDOC_VERSIONS)"	"$(_D)$(shell $(PANDOC) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Types"			"$(_M)$(PANDOC_TYPE_VERSIONS)"	"$(_D)$(shell $(CABAL_INFO) pandoc-types	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)TeXMath"			"$(_M)$(PANDOC_MATH_VERSIONS)"	"$(_D)$(shell $(CABAL_INFO) texmath		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)Highlighting-Kate"		"$(_M)$(PANDOC_HIGH_VERSIONS)"	"$(_D)$(shell $(CABAL_INFO) highlighting-kate	2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(TABLE_I3) "- $(_C)CiteProc"			"$(_M)$(PANDOC_CITE_VERSIONS)"	"$(_D)$(shell $(PANDOC_CITEPROC) --version	2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)TeX Live (Metafont)"		"$(_M)$(TEX_VERSIONS)"		"$(_D)$(shell $(TEX) --version			2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)PDFLaTeX"			"$(_M)$(TEX_VER_PDF)"		"$(_D)$(shell $(PDFLATEX) --version		2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "$(_C)GHC"				"$(_M)$(GHC_VERSIONS)"		"$(_D)$(shell $(BUILD_ENV) $(GHC) --version	2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Cabal"			"$(_M)$(CABAL_VERSIONS)"	"$(_D)$(shell $(BUILD_ENV) $(CABAL) --version	2>/dev/null | $(HEAD) -n1)"
	@$(TABLE_I3) "- $(_C)Library"			"$(_M)$(CABAL_VERSIONS_LIB)"	"$(_D)$(shell $(CABAL_INFO) Cabal		2>/dev/null | $(SED) -n "s|^.*installed[:][ ](.+)$$|\1|gp")"
	@$(HEADER_L)
ifeq ($(BUILD_PLAT),Msys)
	@$(TABLE_I3) "$(MARKER) $(_E)MSYS2"		"$(_N)$(subst ",,$(word 1,$(PACMAN)))"
	@$(TABLE_I3) "- $(_E)MinTTY"			"$(_N)$(subst ",,$(word 1,$(MINTTY))) $(_S)($(subst ",,$(word 1,$(CYGWIN_CONSOLE_HELPER))))"
	@$(TABLE_I3) "- $(_E)Cygpath"			"$(_N)$(subst ",,$(word 1,$(CYGPATH)))"
endif
	@$(TABLE_I3) "$(MARKER) $(_E)GNU C Library"	"$(_N)$(subst ",,$(word 1,$(LDD)))"
	@$(TABLE_I3) "- $(_E)GNU C Compiler"		"$(_N)$(subst ",,$(word 1,$(CC))) $(_S)($(subst ",,$(word 1,$(CXX))))"
	@$(TABLE_I3) "- $(_E)GNU Linker"		"$(_N)$(subst ",,$(word 1,$(LD))) $(_S)($(subst ",,$(word 1,$(CPP))))"
	@$(TABLE_I3) "$(MARKER) $(_E)GNU Coreutils"	"$(_N)$(subst ",,$(word 1,$(COREUTILS)))"
	@$(TABLE_I3) "- $(_E)GNU Find"			"$(_N)$(subst ",,$(word 1,$(FIND)))"
	@$(TABLE_I3) "- $(_E)GNU Patch"			"$(_N)$(subst ",,$(word 1,$(PATCH)))"
	@$(TABLE_I3) "- $(_E)GNU Sed"			"$(_N)$(subst ",,$(word 1,$(SED)))"
	@$(TABLE_I3) "- $(_E)Bzip2"			"$(_N)$(subst ",,$(word 1,$(BZIP)))"
	@$(TABLE_I3) "- $(_E)Gzip"			"$(_N)$(subst ",,$(word 1,$(GZIP)))"
	@$(TABLE_I3) "- $(_E)XZ Utils"			"$(_N)$(subst ",,$(word 1,$(XZ)))"
	@$(TABLE_I3) "- $(_E)GNU Tar"			"$(_N)$(subst ",,$(word 1,$(TAR)))"
	@$(TABLE_I3) "- $(_E)Perl"			"$(_N)$(subst ",,$(word 1,$(PERL)))"
	@$(TABLE_I3) "- $(_E)Python"			"$(_N)$(subst ",,$(word 1,$(PYTHON)))"
	@$(TABLE_I3) "$(_C)GNU Bash"			"$(_D)$(subst ",,$(word 1,$(BASH))) $(_S)($(subst ",,$(word 1,$(SH))))"
	@$(TABLE_I3) "- $(_C)Less"			"$(_D)$(subst ",,$(word 1,$(LESS)))"
	@$(TABLE_I3) "- $(_C)Vim"			"$(_D)$(subst ",,$(word 1,$(VIM)))"
	@$(TABLE_I3) "$(_C)GNU Make"			"$(_D)$(subst ",,$(word 1,$(MAKE)))"
	@$(TABLE_I3) "- $(_C)Info-ZIP (Zip)"		"$(_D)$(subst ",,$(word 1,$(ZIP)))"
	@$(TABLE_I3) "- $(_C)Info-ZIP (UnZip)"		"$(_D)$(subst ",,$(word 1,$(UNZIP)))"
	@$(TABLE_I3) "- $(_C)cURL"			"$(_D)$(subst ",,$(word 1,$(CURL)))"
	@$(TABLE_I3) "- $(_C)Git SCM"			"$(_D)$(subst ",,$(word 1,$(GIT)))"
	@$(TABLE_I3) "- $(_C)Rsync"			"$(_D)$(subst ",,$(word 1,$(RSYNC)))"
	@$(TABLE_I3) "- $(_C)Node.js"			"$(_D)$(subst ",,$(word 1,$(NODE))) $(_S)($(subst ",,$(word 1,$(NPM))))"
	@$(TABLE_I3) "$(_C)Pandoc"			"$(_D)$(subst ",,$(word 1,$(PANDOC)))"
	@$(TABLE_I3) "- $(_C)Types"			"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)TeXMath"			"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)Highlighting-Kate"		"$(_E)(no binary to report)"
	@$(TABLE_I3) "- $(_C)CiteProc"			"$(_D)$(subst ",,$(word 1,$(PANDOC_CITEPROC)))"
	@$(TABLE_I3) "$(_C)TeX Live"			"$(_D)$(subst ",,$(word 1,$(TEX)))"
	@$(TABLE_I3) "- $(_C)PDFLaTeX"			"$(_D)$(subst ",,$(word 1,$(PDFLATEX)))"
	@$(TABLE_I3) "$(_C)GHC"				"$(_D)$(subst ",,$(word 1,$(GHC))) $(_S)($(subst ",,$(word 1,$(GHC_PKG))))"
	@$(TABLE_I3) "- $(_C)Cabal"			"$(_D)$(subst ",,$(word 1,$(CABAL))) $(_S)($(subst ",,$(word 1,$(HADDOCK))))"
	@$(TABLE_I3) "- $(_C)Library"			"$(_E)(no binary to report)"
	@$(HEADER_L)
	@$(foreach FILE,$(BUILD_BINARY_LIST_LDD),$(call CHECKIT_LIBRARY_LOCATE,$(FILE)))
	@$(foreach FILE,$(BUILD_BINARY_LIST_LDD),$(call CHECKIT_LIBRARY_LINKED,$(FILE)))
	@$(HEADER_L)
#> syntax highlighting fix: )")")")")")")")")")")")")")")")")")")")")")")")")")")")")")")")")"

# thanks for the 'filter' fix below: https://stackoverflow.com/questions/27326499/gnu-make-check-if-element-exists-in-list-array
$(CHECKIT): override BUILD_BINARY_LIST_CHECK := \
	$(word 1,$(MINTTY)) $(word 1,$(CYGWIN_CONSOLE_HELPER)) \
	$(word 1,$(CYGPATH)) \
	\
	$(word 1,$(COREUTILS)) \
	$(word 1,$(FIND)) \
	$(word 1,$(PATCH)) \
	$(word 1,$(SED)) \
	$(word 1,$(BZIP)) \
	$(word 1,$(GZIP)) \
	$(word 1,$(XZ)) \
	$(word 1,$(TAR)) \
	$(word 1,$(PERL)) \
	$(word 1,$(PYTHON)) \
	\
	$(word 1,$(BASH)) $(word 1,$(SH)) \
	$(word 1,$(LESS)) \
	$(word 1,$(VIM)) \
	\
	$(word 1,$(MAKE)) \
	$(word 1,$(ZIP)) \
	$(word 1,$(UNZIP)) \
	$(word 1,$(CURL)) \
	$(word 1,$(GIT)) \
	$(word 1,$(RSYNC)) \
	$(word 1,$(NODE)) $(word 1,$(NPM)) \
	\
	$(word 1,$(PANDOC)) \
	$(word 1,$(PANDOC_CITEPROC)) \
	\
	$(word 1,$(TEX)) \
	$(word 1,$(PDFLATEX)) \
	\
	$(word 1,$(GHC)) $(word 1,$(GHC_PKG)) \
	$(word 1,$(CABAL)) $(word 1,$(HADDOCK))
ifneq ($(COMPOSER_TESTING),)
$(CHECKIT): override BUILD_BINARY_LIST_CHECK := \
	$(BUILD_BINARY_LIST_CHECK) \
	$(word 1,$(GHC_BIN)) $(word 1,$(GHC_PKG_BIN)) \
	$(word 1,$(CABAL_BIN)) $(word 1,$(HADDOCK_BIN))
endif
$(CHECKIT): override BUILD_BINARY_LIST_LDD := $(shell \
	$(BUILD_ENV) $(LDD) $(BUILD_BINARY_LIST_CHECK) 2>/dev/null \
	| $(SED) \
		-e "/not[ ]a[ ]dynamic[ ]executable/d" \
		-e "/^[:/]/d" \
		-e "s|^([\t])[/][^/]+[/]|\1|g" \
		-e "s|[ ][=][>][ ]|NULL|g" \
		-e "s|[ ].0x[a-f0-9]+.$$||g" \
		-e "s|[ ].compatibility[ ]version[ ].+$$||g" \
	| $(SORT) \
)
override define CHECKIT_LIBRARY_LOCATE =
	if [ -n "$(filter $(word 1,$(subst NULL, ,$(1))),$(DYNAMIC_LIBRARY_LIST))" ]; then \
		$(TABLE_I3) "* $(_E)$(word 1,$(subst NULL, ,$(1)))" "$(_N)$(word 2,$(subst NULL, ,$(1)))"; \
	else \
		$(TABLE_I3) "$(_C)$(word 1,$(subst NULL, ,$(1)))" "$(_D)$(word 2,$(subst NULL, ,$(1)))"; \
	fi
	$(NULL)
endef
override define CHECKIT_LIBRARY_LINKED =
	if [ -z "$(filter $(word 1,$(subst NULL, ,$(1))),$(DYNAMIC_LIBRARY_LIST))" ]; then \
		$(TABLE_I3) "$(MARKER) $(_M)$(word 1,$(subst NULL, ,$(1)))$(_D):"; \
		$(foreach FILE,$(BUILD_BINARY_LIST_CHECK),\
			if [ -n "$(shell $(LDD) $(FILE) 2>/dev/null | $(SED) -n "/$(subst /,[/],$(subst +,[+],$(word 1,$(subst NULL, ,$(1)))))/p")" ]; then \
				$(TABLE_I3) "" "$(subst ",,$(FILE))"; \
			fi; \
		) \
	fi
	$(NULL)
endef
#> syntax highlighting fix: ")

.PHONY: $(TIMERIT)
$(TIMERIT): .set_title-$(TIMERIT)
$(TIMERIT): override BUILD_COMPLETE_TIMERITS_FILES	:= $(shell $(call BUILD_COMPLETE_TIMERIT_FILES))
$(TIMERIT): override BUILD_COMPLETE_TIMERITS		:=
ifeq ($(BUILD_PLAT),Msys)
$(TIMERIT): override BUILD_COMPLETE_TIMERITS		:= \
	$(BUILDIT)-msys-init \
	$(BUILDIT)-msys
endif
$(TIMERIT): override BUILD_COMPLETE_TIMERITS		:= \
	$(ALLOFIT)++ \
	$(ALLOFIT)-check \
	$(BUILD_COMPLETE_TIMERITS) \
	$(STRAPIT)++ \
		$(BUILDIT)-gnu-init \
		$(BUILDIT)-group-libs++ \
			$(BUILDIT)-libiconv-init \
			$(BUILDIT)-gettext \
			$(BUILDIT)-libiconv \
			$(BUILDIT)-pkgconfig \
			$(BUILDIT)-zlib \
			$(BUILDIT)-gmp \
			$(BUILDIT)-ncurses \
			$(BUILDIT)-openssl \
			$(BUILDIT)-gdbm \
			$(BUILDIT)-expat \
			$(BUILDIT)-png \
			$(BUILDIT)-freetype \
			$(BUILDIT)-fontconfig \
		$(BUILDIT)-group-libs-- \
		$(BUILDIT)-group-util++ \
			$(BUILDIT)-coreutils \
			$(BUILDIT)-findutils \
			$(BUILDIT)-patch \
			$(BUILDIT)-sed \
			$(BUILDIT)-bzip \
			$(BUILDIT)-gzip \
			$(BUILDIT)-xz \
			$(BUILDIT)-tar \
			$(BUILDIT)-perl \
			$(BUILDIT)-perl-modules \
			$(BUILDIT)-python \
		$(BUILDIT)-group-util-- \
		$(BUILDIT)-group-tool++ \
			$(BUILDIT)-bash \
			$(BUILDIT)-less \
			$(BUILDIT)-vim \
		$(BUILDIT)-group-tool-- \
		$(BUILDIT)-group-core++ \
			$(BUILDIT)-make-init \
			$(BUILDIT)-infozip \
			$(BUILDIT)-curl \
			$(BUILDIT)-git \
			$(BUILDIT)-rsync \
		$(BUILDIT)-group-core-- \
		$(BUILDIT)-group-init++ \
			$(BUILDIT)-ghc-init \
			$(BUILDIT)-cabal-init \
			$(BUILDIT)-cabal-init-libs \
		$(BUILDIT)-group-init-- \
	$(STRAPIT)-- \
	$(BUILDIT)++ \
		$(BUILDIT)-gnu \
		$(BUILDIT)-make \
		$(BUILDIT)-node \
		$(BUILDIT)-texlive \
		$(BUILDIT)-texlive-fmtutil \
		$(BUILDIT)-ghc \
		$(BUILDIT)-cabal \
		$(BUILDIT)-cabal-libs \
		$(BUILDIT)-pandoc \
	$(BUILDIT)-- \
	$(ALLOFIT)-bindir \
	$(ALLOFIT)--
$(TIMERIT):
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_H)Meta-Target" "Build Target" "Time Completed"
	@$(HEADER_L)
	@$(foreach FILE,$(BUILD_COMPLETE_TIMERITS_FILES),\
		$(if $(filter $(FILE),$(BUILD_COMPLETE_TIMERITS)),,\
			$(TABLE_I3) "$(DIVIDE) $(_N)$(FILE)" "" "$(_S)$(shell $(call BUILD_COMPLETE_TIMERIT,$(FILE)))"; \
		) \
	)
	@$(foreach FILE,$(BUILD_COMPLETE_TIMERITS),\
		$(if $(filter %++,$(FILE)),\
			$(TABLE_I3) "$(_C)$(FILE)" "" "$(_H)$(shell $(call BUILD_COMPLETE_TIMERIT,$(FILE)))"; \
		,$(if $(filter %--,$(FILE)),\
			$(TABLE_I3) "$(_E)$(FILE)" "" "$(_N)$(shell $(call BUILD_COMPLETE_TIMERIT,$(FILE)))"; \
		,\
			$(TABLE_I3) "" "$(_M)$(FILE)" "$(_D)$(shell $(call BUILD_COMPLETE_TIMERIT,$(FILE)))"; \
		)) \
	)
	@$(HEADER_L)

.PHONY: $(SHELLIT)
$(SHELLIT): .set_title-$(SHELLIT)
$(SHELLIT): $(SHELLIT)-bashrc $(SHELLIT)-vimrc
	@$(BUILD_ENV) $(BASH) || $(TRUE)

#WORKING:NOW : this set of if/then needs to be re-evaluated; it is confusing
#WORKING:NOW : also, where is the $(COMPOSER_ABODE)/$(BUILD_FSFILE) coming from?  when is this ever true?
override MSYS_SHELL_DIR := $(COMPOSER_PROGS)
ifneq ($(COMPOSER_PROGS_USE),1)
ifneq ($(wildcard $(MSYS_DST)/$(BUILD_FSFILE)),)
override MSYS_SHELL_DIR := $(MSYS_DST)
endif
ifneq ($(COMPOSER_PROGS_USE),0)
ifneq ($(wildcard $(COMPOSER_ABODE)/$(BUILD_FSFILE)),)
override MSYS_SHELL_DIR := $(COMPOSER_ABODE)
endif
endif
endif

.PHONY: $(SHELLIT)-msys
$(SHELLIT)-msys: .set_title-$(SHELLIT)-msys
$(SHELLIT)-msys: $(SHELLIT)-bashrc $(SHELLIT)-vimrc
	@cd "$(MSYS_SHELL_DIR)" && \
		$(WINDOWS_ACL) ./msys2_shell.bat /grant:r $(USERNAME):f && \
		$(BUILD_ENV) ./msys2_shell.bat

.PHONY: $(SHELLIT)-bashrc
$(SHELLIT)-bashrc:
	@$(MKDIR) "$(COMPOSER_ABODE)"
	@$(call DO_HEREDOC,$(call HEREDOC_BASH_PROFILE))	>"$(COMPOSER_ABODE)/.bash_profile"
	@$(call DO_HEREDOC,$(call HEREDOC_BASHRC))		>"$(COMPOSER_ABODE)/.bashrc"
	@if [ ! -f "$(COMPOSER_ABODE)/.bashrc.custom" ]; then \
		$(ECHO) >"$(COMPOSER_ABODE)/.bashrc.custom"; \
	fi

.PHONY: $(SHELLIT)-vimrc
$(SHELLIT)-vimrc:
	@$(MKDIR) "$(COMPOSER_ABODE)"
	@$(call DO_HEREDOC,$(call HEREDOC_VIMRC))		>"$(COMPOSER_ABODE)/.vimrc"
	@if [ ! -f "$(COMPOSER_ABODE)/.vimrc.custom" ]; then \
		$(ECHO) >"$(COMPOSER_ABODE)/.vimrc.custom"; \
	fi

override define HEREDOC_BASH_PROFILE =
source "$(COMPOSER_ABODE)/.bashrc"
endef

override HEREDOC_BASHRC_CMD = $(notdir $(subst ",,$(word 1,$(1)))) $(subst ",[B]",$(filter-out $(word 1,$(1)),$(1)))
#> syntax highlighting fix: "))
override define HEREDOC_BASHRC =
# bashrc
umask 022
unalias -a
set -o vi
eval $$($(call HEREDOC_BASHRC_CMD,$(DIRCOLORS)) 2>/dev/null)
#
export LANG="$(LANG)"
export LC_ALL="$${LANG}"
export LC_COLLATE="C"
export LC_ALL=
#
#WORK : where the hell did this hackery come from?  if [ "$${HOME}" != "/" ]; then export HOME="$${HOME}/"; fi
#
if [ -f "$${HOME}/.bash_history" ]; then $(call HEREDOC_BASHRC_CMD,$(RM)) "$${HOME}/.bash_history"; fi
$(call HEREDOC_BASHRC_CMD,$(MKDIR)) "$${HOME}/.bash_history"
export HISTFILE="$${HOME}/.bash_history/$$(date +%Y-%m)"
export HISTSIZE="$$(( (2**31)-1 ))"
export HISTFILESIZE="$${HISTSIZE}"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S "
export HISTCONTROL=
export HISTIGNORE=
#
export CDPATH=".:$(COMPOSER_DIR):$(COMPOSER_OTHER):$(COMPOSER_ABODE):$(COMPOSER_STORE):$(COMPOSER_BUILD)"
export PATH="$(BUILD_PATH_SHELL)"
#
export PROMPT_DIRTRIM="1"
export PS1=
export PS1="$${PS1}$([)\e]0;$(MARKER) $(COMPOSER_FULLNAME) $(DIVIDE) \w\a$(])\n"					# title escape, new line (for spacing)
export PS1="$${PS1}$([)$(_H)$(])$(MARKER) $(COMPOSER_FULLNAME)$([)$(_D)$(]) $(DIVIDE) $([)$(_C)$(])\D{%FT%T%z}\n"	# title, date (iso format)
export PS1="$${PS1}$([)$(_C)$(])[\#/\!] ($([)$(_M)$(])\u@\h \w$([)$(_C)$(]))\\$$ $([)$(_D)$(])"				# history counters, username@hostname, directory, prompt
#
export PAGER="$(call HEREDOC_BASHRC_CMD,$(LESS))"
export EDITOR="$(call HEREDOC_BASHRC_CMD,$(VIM))"
unset VISUAL
#
alias .git="$(call HEREDOC_BASHRC_CMD,$(GIT)) --git-dir=\"$(REPLICA_GIT_DIR)\" --work-tree=\"$(COMPOSER_DIR)\""
alias git="$(call HEREDOC_BASHRC_CMD,$(GIT))"
alias ll="$(call HEREDOC_BASHRC_CMD,$(LS))"
alias less="$${PAGER}"
alias more="$${PAGER}"
alias vi="$${EDITOR}"
#
alias .cms=".composer"
alias .c=".compose"
alias .composer_root="cd [B]"$(COMPOSER_DIR)[B]""
alias .composer_other="cd [B]"$(COMPOSER_OTHER)[B]""
alias .composer="$(subst ",[B]",$(RUNMAKE))"
alias .compose="$(subst ",[B]",$(COMPOSE))"
alias .env="$(call HEREDOC_BASHRC_CMD,$(BUILD_ENV))"
alias .env_mingw="$(call HEREDOC_BASHRC_CMD,$(BUILD_ENV_MINGW))"
alias .env_pandoc="$(call HEREDOC_BASHRC_CMD,$(BUILD_ENV_PANDOC))"
alias .path="$(call HEREDOC_BASHRC_CMD,$(ECHO)) \"$${PATH}\n\" | $(call HEREDOC_BASHRC_CMD,$(SED)) \"s|[:]|\n|g\""
#
source "$${HOME}/.bashrc.custom"
# end of file
endef

override define HEREDOC_VIMRC =
" vimrc
"TODO
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
source $${HOME}/.vimrc.custom
" end of file
endef
#> syntax highlighting fix: "

########################################

#WORK
# this all works great, but something more elegant needs to be done with it
# exactly how long can the HEREDOCs get before the shell can't handle it?
#	should the README be broken up into sections throughout the Makefile anyway?
# document targets!
# document variables!
#WORK

# tricky hack which assumes "$(COMPOSER_OTHER)" is a subdirectory of "$(RELEASE_DIR)"
override RELEASE_DIR		?= $(abspath $(dir $(COMPOSER_OTHER)))
override RELEASE_TARGET		?= $(notdir $(COMPOSER_OTHER))

# if this is true, neither "$(RELEASE_DIR)" nor "$(COMPOSER_OTHER)" has been changed; use a default
ifeq ($(RELEASE_DIR),$(abspath $(dir $(COMPOSER_DIR))))
override RELEASE_DIR		:= $(COMPOSER_DIR)/$(RELEASE)
endif
override RELEASE_DIR_NATIVE	:= $(RELEASE_DIR)/.Native
override RELEASE_MAN_SRC	:= $(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))/pandoc/README
override RELEASE_MAN_DST	:= $(CURDIR)/Pandoc_Manual

override RELEASE_CHROOT_MOUNTS	:= dev/pts proc
override RELEASE_CHROOT		:= $(ENV) - \
	HOME="$(subst $(COMPOSER_OTHER),,$(COMPOSER_ABODE))" \
	PATH="$(PATH)" \
	$(CHROOT) \
	"$(RELEASE_DIR)/$(RELEASE_TARGET)"

.PHONY: $(CONVICT)
$(CONVICT): .set_title-$(CONVICT)
	@$(call COMPOSER_GIT_RUN,$(CURDIR),add --verbose --all ./)
	@$(call COMPOSER_GIT_RUN,$(CURDIR),commit --verbose --all --edit --message="[$(COMPOSER_FULLNAME) $(DIVIDE) $(shell $(DATESTAMP))]")

.PHONY: $(RELEASE)
$(RELEASE): .set_title-$(RELEASE)
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_H)Build"			"Target"		"Options"
	@$(HEADER_L)
	@$(TABLE_I3) "$(MARKER) $(_E)Development"	""			""
	@$(TABLE_I3) "- $(_E)Linux$(_N)"		"$(RELEASE)-config"	"$(_M)RELEASE_DIR=\"$(RELEASE_DIR)\""
	@$(TABLE_I3) "- $(_E)x86_64$(_N)"		"$(ALLOFIT)"		"$(_N)COMPOSER_OTHER=\"$(RELEASE_DIR_NATIVE)\""
	@$(TABLE_I3) "$(_C)Distribution"		""			""
	@$(TABLE_I3) "- $(_C)Linux$(_D)"		"$(RELEASE)-dist"	"BUILD_DIST=\"1\" RELEASE_TARGET=\"Linux\""
	@$(TABLE_I3) "- $(_C)Darwin$(_D)"		"$(ALLOFIT)"		"BUILD_DIST=\"1\""
	@$(TABLE_I3) "- $(_C)Msys$(_D)"			"$(ALLOFIT)"		"BUILD_DIST=\"1\""
	@$(TABLE_I3) "$(_C)Testing"			""			""
#>	@$(TABLE_I3) "- $(_C)Linux$(_D)"		"$(RELEASE)-test"	"BUILD_ARCH=\"x86_64\" RELEASE_TARGET=\"_linux_64\""
	@$(TABLE_I3) "- $(_C)Linux$(_D)"		"$(RELEASE)-test"	"BUILD_ARCH=\"i686\" RELEASE_TARGET=\"_linux_32\""
#>	@$(TABLE_I3) "- $(_C)Darwin$(_D)"		"$(ALLOFIT)"		"BUILD_ARCH=\"x86_64\""
#>	@$(TABLE_I3) "- $(_C)Darwin$(_D)"		"$(ALLOFIT)"		"BUILD_ARCH=\"i686\""
#>	@$(TABLE_I3) "- $(_C)Msys$(_D)"			"$(ALLOFIT)"		"BUILD_ARCH=\"x86_64\""
#>	@$(TABLE_I3) "- $(_C)Msys$(_D)"			"$(ALLOFIT)"		"BUILD_ARCH=\"i686\""
	@$(TABLE_I3) "$(MARKER) $(_E)Release"		""			""
	@$(TABLE_I3) "- $(_E)Darwin$(_N)"		"$(~)(CP)"		"$(RELEASE_DIR)/Darwin"
#>	@$(TABLE_I3) "- $(_E)Darwin (x86_64)$(_N)"	"$(~)(CP)"		"$(RELEASE_DIR)/_darwin_64"
#>	@$(TABLE_I3) "- $(_E)Darwin (i686)$(_N)"	"$(~)(CP)"		"$(RELEASE_DIR)/_darwin_32"
	@$(TABLE_I3) "- $(_E)Msys$(_N)"			"$(~)(CP)"		"$(RELEASE_DIR)/Msys"
#>	@$(TABLE_I3) "- $(_E)Msys (x86_64)$(_N)"	"$(~)(CP)"		"$(RELEASE_DIR)/_msys_64"
#>	@$(TABLE_I3) "- $(_E)Msys (i686)$(_N)"		"$(~)(CP)"		"$(RELEASE_DIR)/_msys_32"
	@$(TABLE_I3) "*$(_N)"				"$(RELEASE)-prep"	""
	@$(TABLE_I3) "*$(_N)"				"$(RELEASE)-debug"	"$(_S)(repeat until successful)"
	@$(TABLE_I3) "*$(_N)"				"$(TESTING)"		"COMPOSER_TESTING=\"0\" $(_S)(repeat until successful)"
	@$(TABLE_I3) "*$(_N)"				"$(TESTING)"		"COMPOSER_TESTING=\"1\" $(_S)(repeat until successful)"
	@$(TABLE_I3) "*$(_N)"				"$(RELEASE)-prep"	"$(_S)(final sanity checks)"
	@$(TABLE_I3) "*$(_N)"				"$(CONVICT)"		"$(_M)COMPOSER_GITREPO=\"$(COMPOSER_GITREPO)\""
	@$(HEADER_L)
	@$(LS) \
		"$(RELEASE_DIR)" \
		"$(RELEASE_DIR_NATIVE)"
	@$(HEADER_L)

.PHONY: $(RELEASE)-config
$(RELEASE)-config: .set_title-$(RELEASE)-config
	@$(DATESTAMP) >"$(CURDIR)/.$(COMPOSER_BASENAME).$(RELEASE)"
	@$(MKDIR) "$(RELEASE_DIR)/Linux"
	@$(MKDIR) "$(RELEASE_DIR)/Darwin"
	@$(MKDIR) "$(RELEASE_DIR)/Msys"
	@$(ECHO) "override COMPOSER_OTHER ?= $(RELEASE_DIR_NATIVE)\n"	>"$(CURDIR)/$(COMPOSER_SETTINGS)"
	@$(ECHO) "override BUILD_DIST := 1\n"				>"$(RELEASE_DIR)/Linux/$(COMPOSER_SETTINGS)"
	@$(ECHO) "override BUILD_DIST := 1\n"				>"$(RELEASE_DIR)/Darwin/$(COMPOSER_SETTINGS)"
	@$(ECHO) "override BUILD_DIST := 1\n"				>"$(RELEASE_DIR)/Msys/$(COMPOSER_SETTINGS)"
	@$(call DEBUGIT_CONTENTS,$(CURDIR)/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/Linux/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/_linux_64/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/_linux_32/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/Darwin/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/_darwin_64/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/_darwin_32/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/Msys/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/_msys_64/$(COMPOSER_SETTINGS))
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/_msys_32/$(COMPOSER_SETTINGS))
	@$(HEADER_L)

.PHONY: $(RELEASE)-dist
$(RELEASE)-dist: override COMPOSER_STORE := $(subst $(COMPOSER_OTHER),$(RELEASE_DIR),$(COMPOSER_STORE))
$(RELEASE)-dist: .set_title-$(RELEASE)-dist
ifneq ($(BUILD_FETCH),)
	$(call GIT_REPO,$(RELEASE_DIR)/.debootstrap,$(DEBIAN_SRC),$(DEBIAN_CMT))
	$(MKDIR) "$(COMPOSER_STORE)/.debootstrap.apt"
	$(MKDIR) "$(RELEASE_DIR)/$(RELEASE_TARGET)/var/cache/apt/"
	$(CP) "$(COMPOSER_STORE)/.debootstrap.apt/"* "$(RELEASE_DIR)/$(RELEASE_TARGET)/var/cache/apt/" || $(TRUE)
	if [ ! -d "$(RELEASE_DIR)/$(RELEASE_TARGET)/boot" ]; then \
		cd "$(RELEASE_DIR)/.debootstrap" && \
			$(MAKE) devices.tar.gz && \
			DEBOOTSTRAP_DIR="$(RELEASE_DIR)/.debootstrap" $(SH) ./debootstrap \
				--verbose \
				--keep-debootstrap-dir \
				--arch="$(DEBIAN_ARCH)" \
				--include="$(DEBIAN_PACKAGES_LIST)" \
				"$(DEBIAN_SUITE)" \
				"$(RELEASE_DIR)/$(RELEASE_TARGET)"; \
		$(RM) "$(RELEASE_DIR)/$(RELEASE_TARGET)/bin/sh"; \
		$(CP) "$(RELEASE_DIR)/$(RELEASE_TARGET)/bin/bash" "$(RELEASE_DIR)/$(RELEASE_TARGET)/bin/sh"; \
		$(call CURL_FILE,$(MAKE_SRC_INIT)); \
		$(call DO_UNTAR_CLEAN,$(RELEASE_DIR)/$(RELEASE_TARGET)/$(notdir $(MAKE_DST_INIT)),$(MAKE_SRC_INIT)); \
		$(RELEASE_CHROOT) /bin/sh -c \
			"cd \"/$(notdir $(MAKE_DST_INIT))\" && \
				./configure --prefix=\"/usr\" && \
				make && \
				make install"; \
	fi
	$(CP) "$(RELEASE_DIR)/$(RELEASE_TARGET)/var/cache/apt/"* "$(COMPOSER_STORE)/.debootstrap.apt/" || $(TRUE)
endif
ifneq ($(BUILD_FETCH),0)
	@$(HEADER_1)
	@$(ECHO) "$(_E)"
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list >"$(RELEASE_DIR)/$(RELEASE_TARGET)/.packages.txt"
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list linux-libc-dev	2>/dev/null | $(TAIL) -n1
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list libc-bin	2>/dev/null | $(TAIL) -n1
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list gcc		2>/dev/null | $(TAIL) -n1
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list g++		2>/dev/null | $(TAIL) -n1
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list binutils	2>/dev/null | $(TAIL) -n1
	@$(RELEASE_CHROOT) /usr/bin/dpkg --list make		2>/dev/null | $(TAIL) -n1
	@$(ECHO) "$(_D)"
	@$(HEADER_1)
	@$(RUNMAKE) $(RELEASE)-chroot
endif

.PHONY: $(RELEASE)-test
$(RELEASE)-test: override COMPOSER_STORE := $(subst $(COMPOSER_OTHER),$(RELEASE_DIR),$(COMPOSER_STORE))
$(RELEASE)-test: .set_title-$(RELEASE)-test
ifneq ($(BUILD_FETCH),)
	$(call CURL_FILE,$(FUNTOO_SRC))
	$(call DO_UNTAR,$(RELEASE_DIR)/$(RELEASE_TARGET)/boot,$(FUNTOO_SRC))
endif
ifneq ($(BUILD_FETCH),0)
	@$(HEADER_1)
	@$(ECHO) "$(_E)"
	@$(RELEASE_CHROOT) /bin/bash -c "\
		cd /var/db/pkg ; \
		/usr/bin/find ./ -mindepth 2 -maxdepth 2 -type d | \
		/bin/sed -r 's|[.][/]||g' | \
		/usr/bin/sort \
		" >"$(RELEASE_DIR)/$(RELEASE_TARGET)/.packages.txt"
	@$(RELEASE_CHROOT) /bin/ls /var/db/pkg/sys-kernel	2>/dev/null | $(HEAD) -n1
	@$(RELEASE_CHROOT) /usr/bin/ldd --version		2>/dev/null | $(HEAD) -n1
	@$(RELEASE_CHROOT) /usr/bin/gcc --version		2>/dev/null | $(HEAD) -n1
	@$(RELEASE_CHROOT) /usr/bin/g++ --version		2>/dev/null | $(HEAD) -n1
	@$(RELEASE_CHROOT) /usr/bin/ld --version		2>/dev/null | $(HEAD) -n1
	@$(RELEASE_CHROOT) /usr/bin/make --version		2>/dev/null | $(HEAD) -n1
	@$(ECHO) "$(_D)"
	@$(HEADER_1)
	@$(RUNMAKE) $(RELEASE)-chroot
endif

#WORKING : ideally, would archive/restore ".Native/.sources" directory when "chroot"ing

.PHONY: $(RELEASE)-chroot
$(RELEASE)-chroot: .set_title-$(RELEASE)-chroot
	@$(MKDIR) "$(RELEASE_DIR)/$(RELEASE_TARGET)"
	@$(DATESTAMP) >"$(RELEASE_DIR)/$(RELEASE_TARGET)/.$(COMPOSER_BASENAME).$(RELEASE).$(RELEASE_TARGET)"
	@$(CP) "$(COMPOSER)" "$(RELEASE_DIR)/$(RELEASE_TARGET)/"
	@if [ ! -f "$(RELEASE_DIR)/$(RELEASE_TARGET)/$(COMPOSER_SETTINGS)" ]; then \
		$(ECHO) "override BUILD_PLAT := $(BUILD_PLAT)\n"  >"$(RELEASE_DIR)/$(RELEASE_TARGET)/$(COMPOSER_SETTINGS)"; \
		$(ECHO) "override BUILD_ARCH := $(BUILD_ARCH)\n" >>"$(RELEASE_DIR)/$(RELEASE_TARGET)/$(COMPOSER_SETTINGS)"; \
	fi
	@$(call DEBUGIT_CONTENTS,$(RELEASE_DIR)/$(RELEASE_TARGET)/$(COMPOSER_SETTINGS))
	@$(HEADER_L)
	@$(ECHO) "\n"
	@$(TABLE_I3) "$(_C)# cd / ; make $(BUILDIT)-$(CLEANER) && make $(ALLOFIT) && make $(DISTRIB)"
	@$(ECHO) "\n"
	@$(foreach FILE,$(RELEASE_CHROOT_MOUNTS),$(UMOUNT) $(RELEASE_DIR)/$(RELEASE_TARGET)/$(FILE) || $(TRUE);)
	@$(foreach FILE,$(RELEASE_CHROOT_MOUNTS),$(MOUNT) --bind /$(FILE) $(RELEASE_DIR)/$(RELEASE_TARGET)/$(FILE);)
	$(RELEASE_CHROOT) /bin/bash -o vi
	@$(foreach FILE,$(RELEASE_CHROOT_MOUNTS),$(UMOUNT) $(RELEASE_DIR)/$(RELEASE_TARGET)/$(FILE);)

.PHONY: $(RELEASE)-prep
$(RELEASE)-prep: .set_title-$(RELEASE)-prep
	@$(RUNMAKE) COMPOSER_PROGS_USE="0" BUILD_DIST="1" BUILD_PLAT="Msys"	COMPOSER_OTHER="$(RELEASE_DIR)/Msys"	$(DISTRIB)
	@$(RUNMAKE) COMPOSER_PROGS_USE="0" BUILD_DIST="1" BUILD_PLAT="Darwin"	COMPOSER_OTHER="$(RELEASE_DIR)/Darwin"	$(DISTRIB)
	@$(RUNMAKE) COMPOSER_PROGS_USE="1" BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_OTHER="$(RELEASE_DIR)/Linux"	$(DISTRIB)
#WORK : should this go somewhere else?
#WORK : test git commands after "make update"
	@$(FIND) "$(CURDIR)" | $(SED) -n "/[/][.]git$$/p" | while read FILE; do \
		$(RM) "$${FILE}"; \
	done
	@$(RM) "$(RELEASE_MAN_DST)."*
	@$(RUNMAKE) COMPOSER_PROGS_USE="1" BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_OTHER="$(CURDIR)"		$(COMPOSER_TARGET) \
		BASE="$(RELEASE_MAN_DST)" LIST="$(RELEASE_MAN_SRC)" TYPE="html" TOC="3"

.PHONY: $(RELEASE)-debug
$(RELEASE)-debug: .set_title-$(RELEASE)-debug
	@$(RM) "$(RELEASE_MAN_DST)."*
	@$(CP) "$(RELEASE_MAN_SRC)" "$(RELEASE_MAN_DST).$(COMPOSER_EXT)"
	# fix multi-line footnotes and copyright symbols, so "pdflatex" doesn't choke on them
#WORK : fixed?  not in PANDOC_VER = 1.13.2
	@$(SED) -i \
		-e "1459d; 1461d; 1463d; 1465d; 1467d; 1470d;" \
		-e "2770d; 2775d;" \
		-e "s|(rights[:][ ])\xc2\xa9|\1\(C\)|g" \
		"$(RELEASE_MAN_DST).$(COMPOSER_EXT)"
	# debug "pdflatex" conversion of the Pandoc manual
	@$(RM) "$(RELEASE_MAN_DST).latex"
	@$(RUNMAKE) COMPOSER_PROGS_USE="1" BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_OTHER="$(CURDIR)"		$(COMPOSER_TARGET) \
		BASE="$(RELEASE_MAN_DST)" TYPE="latex"
	@$(BUILD_ENV) $(PDFLATEX) "$(RELEASE_MAN_DST).latex"
	# test conversion of the full Pandoc manual syntax into our primary document types
	@$(RM) "$(RELEASE_MAN_DST).pdf"
	@$(RUNMAKE) COMPOSER_PROGS_USE="1" BUILD_DIST="1" BUILD_PLAT="Linux"	COMPOSER_OTHER="$(CURDIR)"		$(DOITALL) \
		BASE="$(RELEASE_MAN_DST)"

override DIST_ICO		:= AAABAAEAEBACAAEAAQCwAAAAFgAAACgAAAAQAAAAIAAAAAEAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAGA8AAAwZgAAGMIAAAzAAAAGwAAADMAAABjAAAAwwgAAYGYAAAA8AAAAAAAAAAAAAAAAAAD//wAA//8AAA+BAAAHAAAAAgAAAIAAAADAGAAA4B8AAMAfAACAGAAAAgAAAAYAAAAPAAAA/4EAAP//AAD//wAA
override DIST_ICON		:= iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAc0lEQVQ4y8VTQQ7AIAgrZA/z6fwMD8vcQCDspBcN0GIrAqcXNes0w1OQpBAsLjrujVdSwm4WPF7gE+MvW0gitqM/87pyRWLl0S4hJ6nMJwDEm3l9EgDAVRrWeFb+CVZfywU4lyRWt6bgxiB1JrEc5eOfEROp5CKUZInHTAAAAABJRU5ErkJggg==
override DIST_SCREENSHOT	:= iVBORw0KGgoAAAANSUhEUgAAAeQAAADjCAIAAADbvvCiAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH3gUQBTsYVQy6lQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAVJ0lEQVR42u2d3basqA5G6Rr1RrVett9pnXc6F7Xb4eYnhBAQdM6L3dUuxYAQY5SPfz4hhBD+FwAAYEW+XvpFQwAArM/bvcTf39/vj5+fn559YBq/v79cCIANAuxPoxc27KbfKBR7Zn33t52/3r0W27U5QJOXfm00in5OuJ9r3FB3KXm0JyKyBlic4c5a/4h9bWQ0zltt6gfJjQAsxfvsKH9+fs5DtJRZ1uzT6qq+5TQ5iO/Oh+XnQs7njSxMj8oeUton6HLx0ZbWklObDfWKLpOv51XafO5R58bR1115BXk4gKdkQ87uoORx0r9mf5tz1nJknSaso9/VMg/7sztHv6N9SnvK57KVrGlVTb00NtuecjQ2l/5trbv+CgLc20u/m0ZsGqA5jpZqZJTuoAmmUguPo4TDJ2RF0six0wxNvdwTIL4NdQ6ZhfbxqinAfmkQecSen0Ojkbz+aMHCvcLPNIeDRwYImheM0VA/Yh93j+DrU0rJnJ6Ib/RXgxqb9QYcNjc5u9L+muSPpnDZpCgs2PquAzAwso5C5vM7otQLfB9Uq6/dovSivJvsWbJvqITn6Mj4asny2atZC8G/CCWnFmZtttXLKyaNaqG0OTUg/d9qOcqaAtwf/aSY1uipdZ+V46ael3X3sHm1JyeAp3npfxByavU1G8V3S9nMh9sAZmcdcNYAAFs4a1T3AAA2AGcNALCVs3afZsYWtly4BYDIGgAAZvPnBeO/tZkvbGHLRlsY2HAnPsd/PjxEs4U0CMDCzvpDZM0WImsAImu2sIXIGsAnsuYFIwDABjCDEQBggzQIkTUAwAbgrAEAcNYAAODBe2vr7yFLj7g+ADg768itROs0Rl+8HvtEW7LlpPsoEZae2cX3pY0AABAjfGdd8tSh5dPX7A/lb/3No+lPi8fXAACplzbmrOcErWb/xaIkAHAz3mlcvIinG2dMmiPOpmWOdYGDLpmjLDla+hYAoCHADo1pkFL64vdEupuQ+rAtoZvdobpWb2pzdkv6r+ao6pZsa5AGAQBVGqTkmMwZEtt7wugoQ+zZFIn7xrbfkDmKmtOb0PEnImsA0PNKfWW/E0mF0MYdtRQ/Pz/pJzEH9DYA6HXWhgB2gr9uLaEUVpfKaf3y5IvwsaBQd7IcANDDW5++OPugY+fqhI5zaiV67SanLLxeMEbl6Gsh52Q05WjaBwBAxfGCcUE0LxjT15KdEfSgEvprAQCP9tIrO+uNbhsAAEOdNXrWAACrO+uAkNP8kgEADDQ46+xCpU1CTiN837lA89vIdEoh4koAsFyArZzBmLrsy9cw1UwCVBrQcywAwGgv3bX4wBFKG0Ja/CAAgB7/6eZ6Tz3oRKn+RrRlWjUBAJwD7GBKg6RbUkkms0iTITzPyiRlzyuobxP+A8CCXtpfIjU9NlvaoK8s+HgDAG7JECEnAAAY4qznMz/DQE4DAPalQcjJxUuev1+esyRNdmWW6LxLLZEDAJBy2XRzF8/IDEYAuD2fa501AADonfWLhgAAWB+EnHY9OwDgrCu+KYjySZELmyzkFG0vnT2SoEqPEgSqwt8vY/nIBABm0DSDsTQ/MDtd8FohJ+HswvRFgxwVzhoAJnjprpx1dmFDZRB9lY+TbZ55pwEA0HNDIScXIrVuAIBreUe+qeqh0gkmqY+LIut0yzhXqDm7V8kAALOdtV7IKXoFJ2Q/zgmHUjkTIuL0RMqIPjoQHw0AF9Ir5PTzH6tlMPayGQBA5azdsxCOe47w1wAAe9Eg5HROldhy1uEKIafS5+FN9dKUAwAwDoScdj07ADwEhJwAALZx1gg5AQBsAEJO2AwA93LW2SxzdRLKjYWcWn008k8AYEcv5FT6U1YRSfg9IkotnXGCkFO/qQAAVS89MGeNkBMAgBcIORXvNK0fF/7+/mYD82M7AICZZiEnjY+rRtZ3FXKKmrGUGQcAMDprvZCTxl9HCQd5t9ERMUJOAHADeoWcls1gyDsg5AQAWzpr9yyE454j/PX8+gIA9NAg5BQUkkzKnPU9hJyytYh+480BwAWEnGbXghmMANAEQk4AANs4a4ScAAA2ACEneAr0Ftg+wP60dPdoPp5my4Th1/Sn9b2J+7G856QpYHsvbRNy0ggeTZu2jrNexFlv0eY4a9jUWRtz1umDpLxl8giZ81EgNlf7AAB44T/dvBTLrOOMlBrc55nr2Y+1NTokacnHx9el1kjP3lSOLEiSLed8oNLCVFQgPaR6Llv72Foe4C7ZEKuetTJnPUfPujUhICdzSkqEnVsi7WzZqpK3TcuR01A9Fv7+TWhXMO9vH9sVzJZDGgQ29dK9kXUaK2WFnKZFNzbjvZIAR0goxLZpm2hs9ipH02heClalW6mcH2vqM9G82aPls9cC4A5pEC+J1IeTPu+7NKZSanXa5VP2Fr23Hdfy9Ge4DS+z+whiSrQpNTE6rHax6sgDyLnmUJAEEWzQe5OqwWuqkWhMsn3NEvXDo/rytQDYOLIOCiGnVKRJsyVc/YKxKjVVEp+SswHm1jCkaM4P9Up//X38T9f5zVpoCMnTQ5TtfD7QJvs1uuUBFqVpUszQ2MpWrGYCjvtyt7BgbO7VWwAW9dJznDXOAgCgx1mjugcAsLqzDvcTciJTCQC3pMFZe83i8yX7GpCsBQDcMMBWzmA8/7VnFt+IyFq5HQBgUy/ttvjA4tJOAABb80qj4GnSpvhrAIA2Z32eEdOTWf5ORjh/zZpucTkRAMCj8JdIXU3aCQCAyBoAACY6637WlHYCALgHDTMYHb+z9vryWpDZ4/kAAO7Bp9VZ++LiT5nBCAA4awAAWMVZv2gIAID1QcgJAGCTAFupZ21e0zpaG3uEs1ZuBwDY1Eu/Ut/a5ByPhZqEo35O0O4AAAa6ctbZZfGUuh8EvwAAzc5aKeTUtGBr1VPjrwEA2pz10OnmCDkBAHTSLOQUBdfZ6Di7eou8DwAADIyseXMIADDPWTfh4ppJWAMA6HlHLnhEjJxmq12EswEAngNCTgAAS4OQEwDANs4aIScAgA1AyAkA4HbOOnKFpTeHpY0jHGj2m24+NQGAu3Go7lWngGcV9YS/yr99I2vldgCATb301Jz1OQrGnwIA6GkTcvKNiPHXAABtzto83fwQaSod9dUSQcgJAKCHZiGn1Bfr9zmXjKcGAJgXWQMAwDxnPQ4+2AAA6KdByOmsZN2UJylNXUHICQBACUJOAABLg5ATAMA2zhohJwCADcBZAwDgrAEAwNdZl7SZ2MKWHbcAEFkDAMBs/nwN8m+iQ/3LFrZsu4WBDXfic/znw0M0W0iDACzsrD9E1mwhsgYgsmYLW4isAXwia14wAgBsANPNAQA2SIMQWQMAbADOGgAAZw0AADhrAACcdRs7fjUl2Bwtx76m8amF65s9p//s2wh8fUj73DOyHnfl1p9YkVr4XXwnnSQyrZ1vMJCurUK211VNyu5wS6dma5/b9DHSIOEhffrG5+VqPvlaPKem79TZl9Yz/AZu343pPul9w31dxNSe4193mzVnF0r2renMktN6ado5u4OmfbzComz7VPtG1Of7e5S744hO1DQKzNeipxaac5X62Hdjkz3y0I4u9Aj/I9usHE1avhMZ05m7qZXnhFHPnOBSKuqgtCUtR046K20uPaHIv1tL7qmp0qpzIeaS03pp2rlkz1V9I1sLzdmjnWded3OfrKZBJl8Lzbmy+5Q0A/TtIzfOiFEp29w6mkr2fL30uym30nlrKh2ebs9uOW5Hmvi3yWZbfJfNGrceoqyppuRowXi54sJfvVrM0D62Fsv+1eXsco/6/tD0zNZayFe5OgoM19SxFhrDhMvUn9uNBsK4UWnoLT0X662p8CIp/POThaPNjjX1egpOa7pUYs7cYhfWYqjN1Z45cxQsWPLM65XaP25UTvaZrzT2jkxxPGtPUedkUPVRyCuGWr+mky10aeeht/+mbydKfV7/uF29XoNq19k3vodnH9In1GJcV5HvNONGpe1Erfa8S/efc9hfKlQWF44eEjtvcdlyouR9p83nPx0pJ30txtU0W3JkoWPJ8jOyssVaz94Z8uivjrxzqaYTrnu2DTX9sPRCT+4b6dvIQa9J9SVHSTxNHyttOQoZ6n80NldHUwPpC0aAJ/DkPq957QbrUH/BCAC3ZFwcDeNAzxoAYPXIOjCDEQBgC9qcdZOQSutrXJfcmaacdCbCUpQ+8jcYPHNlwplNOq4frtwHVrhei691OXnsTO6Hbc56nJCK77eQcpP9/MdVfc5lbshqCB+fTjsXrHm97jp2JgtLvRg564wTKjsiqtquta+1efHm2jdq6Uc13VwvpBKsMknVs0efUpolWryaUmOPIGojSPMEk7CUUNkmQR9lOytbvlXwKD171mbhobWnjwWFWI9G8iyYBLNKrbHU9Yp61HPGjpc/zNZd0z4hnL6z1ggnhXahmZKMiyxh0yMR1T99yCwsla2p3sIm2SbDY9cIKa6qJUIL9EgyaebvVROOyrqXJHs6t1Trtdr10vexW46daf4w3eev76zNwiUGt6gsTdOOXlIv1ejbbPM4wZpO8akmEQOXWe9pj1K2qlIgJZVJmP+8JYwdTd8QdC1WuF62lrzH2HH0h+a+966W0p9Bc1FPPz8Rd8obueQEU3smy0gNeiWraedOm3fMI9tadYQU1w2u16Zjx7c1DDeMlyats5R4UGfJEzzFZBmpmVenR8hphBSO8PjZ9Kbe8JmprL4m1FSwwZZwX+F63X7seLXGIaFlECKWZjAaXpuE8gIcoTHlX1r7o/P1gi0no3T90fsoWc4tq6QTdQXfdT2U9ujbOfvmLQpAzGt/GNpQDn/MrwHPbTKi5NLV2eJ6PWTsOPpDze05qtfXS/9JXQMMCpGWCsr6jbmr7NH86/XwcdHU1F8vjTYIjO2XN0tP3zjhfsvrtbK/1jf1p5oGAQCAy0HICQBgG15yuP5YuRyvuq8mfCPY8zTBI/2UmYc/sF8ooTPz1C6n08xUGuKsn5y9mizRAk/2hs+sZvWzwpn+59B3W3kNnZdXuz9BLufGdy8Ej9aJCZ4cDy1l1WoWvs/9/plyOWGkRIuL8E2wfuNZ6out9qwveBSdvakceSKc8strjSRT9LsqS2QWPPLqP16yTaEgEZWue9s5TrOTPKpiWJrxrhFgyraYlwcI4W8hp7TCD5HLqf7W7DlT+Mbr7He6gqXkYKkcjfSPzUKbLJpv+9iu4Ijea06DaNrHIAQml1O10D03omnDeMHcx8rljJNosbWJpv2zoki2WtxD8EhzB7KVo2m0kvrSiByjTfBoUP8xyza5tI9ZCCwtR9MTlLuN8wB7r27uJZdzuUSLY933yuQOEjxSSvwMGn7CiVrlHsfdL3fsP9PWk1qTrheM95DLuUSixSUDeLbZVovbCx5VDb5wdbfO+73t00Pf/jO/XtV9qr2upz9f21veGr+QvgfQv4Q8V6+0RfMsqSmnVLJ+uAo1Feo1+o49ru73uIJZS85vHZVhb7pzyUJDSJ4eomzn84HK9jFcQcf+I+e7SuOruo/SQmU2o7UNIzOuic1bhZyQy1E+c2ydX0LwaHee2f53rXX8gtEx3fPMr0eHxibz64K/4wrCUiDkBACwemQdEHICANiCVZx19Eo6+129Zk104Wt8eW311BhbLcZ9SD9I18bFwqGiSJfLCQUPbf6035a6q+2Tm0tGSk+vgFbera1vyIXZjipN3U5Lzr6orU4JHVGLcV/2aOoFI/rhuL7h/tXwIiMFbh5Z94wQ2UWuJlLqNTIBGCkPddaax6KQzLU3HCX4oBGeyPxdZEnzIfrrJfXKtmr2cbjVwpLMgtwa8rN2Tx8L3nJCsoXKK+jSNwbVdOZI0fQWcE6DaDSlstfSdpR+dIXuNYk1JVfTDqW62+ZHlLxb6WG5pFsW6YplH4cNFmbnYpSyMaWeI8+lkqc1tiZ8NG2YnZNiEwnx6hteqa1rR0pUU+VEf7A76zWf92W5HH1vMOjsTItuNDIu8m1ygqkXiiJ5teFqmShHC68dKXBBGmRZfy3vcIlU3qM44seqHCCRFCMFrnTWss5sSTbFa5W/aS7g3qtNzmmiXfz1tUJFg2xYcKTAkDSIIOwS/SnKnJbEeuSj+nuJoBWnX28i/L3QSVW+Mi05e4u65Os6pbiS4SF9QVGkziZyly4y9I2h4gSTR0q2t4A/rUJOd73H0sMAGCkre2mmm3dFoACMFJgDQk4AAKtH1oHIGgBgCzLO2mvWaes66DMxzLCqzsdTblm2TbyuMgCMCrA/Lc665+OkRXyWQUGtNDG6dcv9/B3OGmCOl36lY68690E5htd/EbGIhXztBABV6gvmhkRzIJph3PS1ZrbkkvZFv0tttbBHK7Jn0rNNQyd7daJWjcQwU9s0yhLCFgC4IA0iSJWXfgsKavJvOSOhSSCk4uilLVFqokd2XZOPNifrR6Rl0n/7kzl3WhoYYBcv/e5MXJRkzvu9kmaynCaSjSZbyjGsrFGpVJhLp65pGtacOPJN5pwfRIijAfZIgwxCKaK4WspbeROa7KlHkOp2Mg8C4HJevs6iVRdYs/GSD0UW9NQuK0aWhLfS0rKvPQmxAVaMrEuvlQxK9qUH7ZLY01CZG8FCvahN9qiS8I1QeJOnFmSAlEJOJeEtoRx5CwBMokfICSbnYS4vAQCu8tJMN98GEscATwYhJwCA1SPrMOJrkKb8L9HifLaYXAoAGZ/9UQ9y8279q3ytnG/dLhfstegabQ4wzUu/njmuVliF78IWI7IG2I7hzlr/0D3Tp4/zVpv6QXIjAIvzPjvKaCp2KbOs2afVedmWmtWIGaUTwTVyVK1fXkfN2FSyQdYqLVme8u4V6c8XjSpJcXFrgYdmQ0pyP5EnDQqRJnPOWo6s5dl0ss3y/lmxp6pVXiVr2rAkNdVqs+2Z5nLRKIP+OMD9vPS7aQxnZ1RfmEDwmg89ISviLofiJdzROh/Vt3E0olFIlAAEwVmXch3R2L52/FTzM4fB6+RkR5uxV/iJaBSAklfr4C/pQlw7Gbopo6KM+AzrNLo/FugNOGxuTfqXFEv6rxGiUQCjIusoZE7llqL4WiOBFCUc5d1kX1OVUhIkos7Fas5VzVoI/kXWy9YIMNlkrbxi0qVEowDgD+5CTpqYtLoIy7XsuBKKr82IRgGs5qXRBgnVJ3RsthlDaAzg5awDzhoAYAtnjUQqAMAG4KwBAHDWAACAswYAeAj/B20celP5v/1/AAAAAElFTkSuQmCC

.PHONY: $(DISTRIB)
$(DISTRIB): .set_title-$(DISTRIB)
	@if [ "$(COMPOSER)" !=						"$(abspath $(CURDIR)/$(MAKEFILE))" ]; then \
		$(CP) "$(COMPOSER)"					"$(abspath $(CURDIR)/$(MAKEFILE))"; \
	fi
	@if [ -d "$(COMPOSER_PROGS)" ] && \
	    [ "$(COMPOSER_PROGS)" !=					"$(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))" ]; then \
		$(MKDIR)						"$(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))"; \
		$(CP) "$(COMPOSER_PROGS)/"*				"$(subst $(COMPOSER_OTHER),$(CURDIR),$(COMPOSER_PROGS))/"; \
	fi
	@if [ "$(COMPOSER_PROGS_USE)" !=				"0" ]; then \
		$(MKDIR)						"$(CURDIR)/$(COMPOSER_ART)"; \
		$(ECHO) "$(DIST_ICO)"		| $(BASE64) -d		>"$(CURDIR)/$(COMPOSER_ART)/icon.ico"; \
		$(ECHO) "$(DIST_ICON)"		| $(BASE64) -d		>"$(CURDIR)/$(COMPOSER_ART)/icon.png"; \
		$(ECHO) "$(DIST_SCREENSHOT)"	| $(BASE64) -d		>"$(CURDIR)/$(COMPOSER_ART)/screenshot.png"; \
		$(call DO_HEREDOC,$(call HEREDOC_DISTRIB_GITIGNORE))	>"$(CURDIR)/.gitignore"; \
		$(call DO_HEREDOC,$(call HEREDOC_DISTRIB_COMPOSER_BAT))	>"$(CURDIR)/$(COMPOSER_BASENAME).bat"; \
		$(call DO_HEREDOC,$(call HEREDOC_DISTRIB_COMPOSER_SH))	>"$(CURDIR)/$(COMPOSER_BASENAME).command"; \
		$(call DO_HEREDOC,$(call HEREDOC_DISTRIB_LICENSE))	>"$(CURDIR)/LICENSE.$(COMPOSER_EXT)"; \
		$(call DO_HEREDOC,$(call HEREDOC_DISTRIB_README))	>"$(CURDIR)/README.$(COMPOSER_EXT)"; \
		$(call DO_HEREDOC,$(call HEREDOC_DISTRIB_REVEALJS_CSS))	>"$(CURDIR)/$(COMPOSER_ART)/revealjs.css"; \
		$(CHMOD) \
			"$(CURDIR)/$(MAKEFILE)" \
			"$(CURDIR)/$(COMPOSER_BASENAME).bat" \
			"$(CURDIR)/$(COMPOSER_BASENAME).command"; \
		$(RUNMAKE) --directory "$(CURDIR)" $(UPGRADE); \
		$(RUNMAKE) --directory "$(CURDIR)" $(DOITALL); \
	fi

override define HEREDOC_DISTRIB_GITIGNORE =
# $(COMPOSER_BASENAME)
/.$(COMPOSER_BASENAME).*
/$(COMPOSER_SETTINGS)
/$(RELEASE)

# $(COMPOSER_TARGET)
/$(COMPOSER_STAMP)
/$(COMPOSER_CSS)

# $(TESTING)
$(subst $(COMPOSER_DIR),,$(TESTING_DIR))/
#WORKING:NOW
$(subst $(COMPOSER_DIR),,$(TESTING_DIR)).hexo/
$(subst $(COMPOSER_DIR),,$(TESTING)).public/
$(subst $(COMPOSER_DIR),,$(TESTING)).source/

# $(UPGRADE) && $(BUILDIT)
$(subst $(COMPOSER_OTHER),,$(COMPOSER_ABODE))/
$(subst $(COMPOSER_OTHER),,$(COMPOSER_STORE))/
$(subst $(COMPOSER_OTHER),,$(COMPOSER_TRASH))/
$(subst $(COMPOSER_OTHER),,$(COMPOSER_BUILD))/

# WORKING:NOW HEXO_WORK
$(subst $(COMPOSER_DIR),,$(HEXO_DST))/_config.yml
$(subst $(COMPOSER_DIR),,$(HEXO_DST))/db.json
$(subst $(COMPOSER_DIR),,$(HEXO_DST))/debug.log
$(subst $(COMPOSER_DIR),,$(HEXO_DST))/public
$(subst $(COMPOSER_DIR),,$(HEXO_DST))/source
$(subst $(COMPOSER_DIR),,$(HEXO_THEME_DST))/_config.yml
endef

override define HEREDOC_DISTRIB_COMPOSER_BAT =
@echo off
set _CMS=%~dp0
set _SYS=Msys
set _MAK=make
set _TAB=$(BUILD_FSFILE)
set _BIN=$(BUILD_BINDIR)
set _ABD=$(subst $(COMPOSER_OTHER),%_CMS%,$(COMPOSER_ABODE))
set _PRG=$(subst $(COMPOSER_OTHER),%_CMS%,$(COMPOSER_PROGS))
if exist %_ABD%/%_TAB%				goto dir_home
if exist %_ABD%/macports/%_TAB%			goto dir_port
if exist %_ABD%/msys$(BUILD_BITS)/%_TAB%	goto dir_msys
if exist %_CMS%/bin/%_SYS%/%_TAB%		goto dir_prog
::WORKING:MACP
goto do_make
:dir_home
set PATH=%_ABD%/%_BIN%;%PATH%
set _OPT=
goto do_make
:dir_port
set PATH=%_ABD%/macports/bin;%_ABD%/macports/libexec/gnubin;%PATH%
set _OPT=0
goto do_make
:dir_msys
set PATH=%_ABD%/msys$(BUILD_BITS)/%_BIN%;%PATH%
set _OPT=0
goto do_make
:dir_prog
set PATH=%_CMS%/bin/%_SYS%/%_BIN%;%PATH%
set _OPT=1
goto do_make
:do_make
start /b %_MAK% --makefile $(MAKEFILE) --debug="a" COMPOSER_PROGS_USE="%_OPT%" BUILD_PLAT="%_SYS%" BUILD_ARCH= shell-msys
::#>set /p ENTER="Hit ENTER to proceed."
:: end of file
endef

override define HEREDOC_DISTRIB_COMPOSER_SH =
# sh
_CMS="$${PWD}"; [ "$${TERM_PROGRAM}" == "Apple_Terminal" ] && _CMS="$$(dirname $${0})" && cd "$${_CMS}"
_SYS="Linux"; [ "$${TERM_PROGRAM}" == "Apple_Terminal" ] && _SYS="Darwin"; [ -n "$${MSYSTEM}" ] && _SYS="Msys"
_MAK="make";
_TAB="$(BUILD_FSFILE)"
_BIN="$(BUILD_BINDIR)"
_ABD="$(subst $(COMPOSER_OTHER),$${_CMS},$(COMPOSER_ABODE))"
#WORKING:MACP : need to convert to $${_SYS}, since $(BUILD_PLAT),Linux and $(BUILD_PLAT),Darwin are both using this (same with COMPOSER_BAT above)
_PRG="$(subst $(COMPOSER_OTHER),$${_CMS},$(COMPOSER_PROGS))"
if [ -e "$${_ABD}/$${_TAB}" ]; then
PATH="$${_ABD}/$${_BIN}:$${PATH}"
_OPT=
elif [ -e "$${_ABD}/macports/$${_TAB}" ]; then
PATH="$${_ABD}/macports/bin:$${_ABD}/macports/libexec/gnubin:$${PATH}"
_OPT="0"
elif [ -e "$${_ABD}/msys$(BUILD_BITS)/$${_TAB}" ]; then
PATH="$${_ABD}/msys$(BUILD_BITS)/$${_BIN}:$${PATH}"
_OPT="0"
elif [ -e "$${_CMS}/bin/$${_SYS}/$${_TAB}" ]; then
PATH="$${_CMS}/bin/$${_SYS}/$${_BIN}:$${PATH}"
_OPT="1"
fi
$${_MAK} --makefile $(MAKEFILE) --debug="a" COMPOSER_PROGS_USE="$${_OPT}" BUILD_PLAT="$${_SYS}" BUILD_ARCH= shell
# end of file
endef

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

override define HEREDOC_DISTRIB_README =
% Composer CMS: User Guide & Example File
% Gary B. Genett
% $(COMPOSER_VERSION) ($(shell $(DATE)))

Composer CMS
------------------------------------------------------------------------

![Composer Icon]($(COMPOSER_ART)/icon.png "Composer Icon")
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

![Composer Screenshot]($(COMPOSER_ART)/screenshot.png "Composer Screenshot")

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
a wrapping engine based on it[Q]s years of history as one of the most
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
    * Recursion handling and the `$$(COMPOSER_ABSPATH)` variable may be
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
          to define it[Q]s own behavior (i.e. no inheritance).
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

override define HEREDOC_DISTRIB_REVEALJS_CSS =
@import url("../revealjs/css/theme/black.css");

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

########################################

.PHONY: $(DOITALL)
$(DOITALL): .set_title-$(DOITALL)
ifeq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(WHOWHAT)
else
$(DOITALL): $(WHOWHAT) $(SUBDIRS)
endif
ifneq ($(COMPOSER_TARGETS),$(BASE))
$(DOITALL): \
	$(COMPOSER_TARGETS)
else
$(DOITALL): \
	$(BASE).$(TYPE_HTML) \
	$(BASE).$(TYPE_LPDF) \
	$(BASE).$(EXTN_PRES) \
	$(BASE).$(EXTN_SHOW) \
	$(BASE).$(TYPE_DOCX) \
	$(BASE).$(TYPE_EPUB)
#>	$(BASE).$(EXTN_TEXT)
#>	$(BASE).$(EXTN_LINT)
endif
ifeq ($(COMPOSER_DEPENDS),)
$(DOITALL): $(SUBDIRS)
endif

.PHONY: $(CLEANER)
$(CLEANER): .set_title-$(CLEANER)
.PHONY: $(addsuffix -$(CLEANER),$(COMPOSER_TARGETS))
$(CLEANER): $(addsuffix -$(CLEANER),$(COMPOSER_TARGETS))
	@$(foreach FILE,$(COMPOSER_TARGETS),\
		$(RM) \
			"$(FILE)" \
			"$(FILE).$(TYPE)" \
			"$(FILE).$(TYPE_HTML)" \
			"$(FILE).$(TYPE_LPDF)" \
			"$(FILE).$(EXTN_PRES)" \
			"$(FILE).$(EXTN_SHOW)" \
			"$(FILE).$(TYPE_DOCX)" \
			"$(FILE).$(TYPE_EPUB)" \
			"$(FILE).$(EXTN_TEXT)" \
			"$(FILE).$(EXTN_LINT)"; \
	)
	@$(RM) $(COMPOSER_STAMP)

#WORK : hackish reuse of COMPOSER_DEBUGIT?  document!

.PHONY: $(WHOWHAT)
$(WHOWHAT):
ifeq ($(COMPOSER_DEBUGIT),)
	@$(TABLE_I3) "$(_H)$(MARKER) $(_C)Directory$(_D):" "$(_E)$(CURDIR)"
else
	@$(HEADER_1)
	@$(TABLE_C2) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_C2) "$(_E)MAKEFILE_LIST$(_D)"		"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_C2) "$(_E)CURDIR$(_D)"			"[$(_N)$(CURDIR)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_TARGETS$(_D)"	"[$(_M)$(COMPOSER_TARGETS)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_SUBDIRS$(_D)"	"[$(_M)$(COMPOSER_SUBDIRS)$(_D)]"
	@$(TABLE_C2) "$(_C)COMPOSER_DEPENDS$(_D)"	"[$(_M)$(COMPOSER_DEPENDS)$(_D)]"
	@$(HEADER_2)
	@$(TABLE_C2) "$(_C)TYPE$(_D)"	"[$(_M)$(TYPE)$(_D)]"
	@$(TABLE_C2) "$(_C)BASE$(_D)"	"[$(_M)$(BASE)$(_D)]"
	@$(TABLE_C2) "$(_C)LIST$(_D)"	"[$(_M)$(LIST)$(_D)]"
	@$(TABLE_C2) "$(_C)_CSS$(_D)"	"[$(_M)$(_CSS)$(_D)]"
	@$(TABLE_C2) "$(_C)CSS$(_D)"	"[$(_M)$(CSS)$(_D)]"
	@$(TABLE_C2) "$(_C)TTL$(_D)"	"[$(_M)$(TTL)$(_D)]"
	@$(TABLE_C2) "$(_C)TOC$(_D)"	"[$(_M)$(TOC)$(_D)]"
	@$(TABLE_C2) "$(_C)LVL$(_D)"	"[$(_M)$(LVL)$(_D)]"
	@$(TABLE_C2) "$(_C)MGN$(_D)"	"[$(_M)$(MGN)$(_D)]"
	@$(TABLE_C2) "$(_C)FNT$(_D)"	"[$(_M)$(FNT)$(_D)]"
	@$(TABLE_C2) "$(_C)OPT$(_D)"	"[$(_M)$(OPT)$(_D)]"
	@$(HEADER_1)
endif

.PHONY: $(SETTING)
$(SETTING):
ifeq ($(COMPOSER_DEBUGIT),)
	@$(TABLE_I3) "$(_H)$(MARKER) $(_H)Creating$(_D):" "$(_N)$(CURDIR)$(_D) $(DIVIDE) $(_M)$(BASE).$(EXTENSION)"
else
	@$(HEADER_L)
	@$(TABLE_I3) "$(_H)$(MARKER) $(COMPOSER_FULLNAME)$(_D) $(DIVIDE) $(_N)$(COMPOSER)"
	@$(TABLE_I3) "$(_E)MAKEFILE_LIST$(_D)"	"[$(_N)$(MAKEFILE_LIST)$(_D)]"
	@$(TABLE_I3) "$(_E)CURDIR$(_D)"		"[$(_N)$(CURDIR)$(_D)]"
	@$(HEADER_L)
	@$(TABLE_I3) "$(_C)TYPE$(_D)"	"[$(_M)$(TYPE)$(_D)]"
	@$(TABLE_I3) "$(_C)BASE$(_D)"	"[$(_M)$(BASE)$(_D)]"
	@$(TABLE_I3) "$(_C)LIST$(_D)"	"[$(_M)$(LIST)$(_D)]"
	@$(TABLE_I3) "$(_C)_CSS$(_D)"	"[$(_M)$(_CSS)$(_D)]"
	@$(TABLE_I3) "$(_C)CSS$(_D)"	"[$(_M)$(CSS)$(_D)]"
	@$(TABLE_I3) "$(_C)TTL$(_D)"	"[$(_M)$(TTL)$(_D)]"
	@$(TABLE_I3) "$(_C)TOC$(_D)"	"[$(_M)$(TOC)$(_D)]"
	@$(TABLE_I3) "$(_C)LVL$(_D)"	"[$(_M)$(LVL)$(_D)]"
	@$(TABLE_I3) "$(_C)MGN$(_D)"	"[$(_M)$(MGN)$(_D)]"
	@$(TABLE_I3) "$(_C)FNT$(_D)"	"[$(_M)$(FNT)$(_D)]"
	@$(TABLE_I3) "$(_C)OPT$(_D)"	"[$(_M)$(OPT)$(_D)]"
	@$(HEADER_L)
endif

.PHONY: $(SUBDIRS) $(COMPOSER_SUBDIRS)
$(SUBDIRS): $(COMPOSER_SUBDIRS)
#WORKING:NOW some use of $(COMPOSER_DEBUGIT) to toggle --silent, here?
$(COMPOSER_SUBDIRS):
	@$(MAKE) --silent --directory "$(CURDIR)/$(@)"

.PHONY: $(PRINTER)
$(PRINTER): .set_title-$(PRINTER)
$(PRINTER): $(COMPOSER_STAMP)
$(COMPOSER_STAMP): *.$(COMPOSER_EXT)
	@$(LS) $(?)

########################################

#WORK : document!
.PHONY: $(NOTHING)
$(NOTHING):
	@$(ECHO) "\n"
	@$(TABLE_I3) "$(_N)WARNING:"
	@$(ECHO) "\n"
	@$(TABLE_I3) "$(_N)The '$(NOTHING)' target has been called.  There is nothing to do in this directory."
	@$(ECHO) "\n"

override MSYS_SED_FIXES	:= -e "s|[:]|;|g" -e "s|[/]([a-z])[/]|\1:\\\\\\\\|g" -e "s|[/]|\\\\\\\\|g"
override OPTIONS_ENV	:= $(subst $(ENV) - ,,$(BUILD_ENV_PANDOC))
override OPTIONS_DOC	:= $(PANDOC_OPTIONS)
ifeq ($(BUILD_PLAT),Msys)
override OPTIONS_ENV	:= $(subst $(TEXMFDIST),$(shell		$(ECHO) '$(TEXMFDIST)'		| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_ENV))
override OPTIONS_ENV	:= $(subst $(TEXMFVAR),$(shell		$(ECHO) '$(TEXMFVAR)'		| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_ENV))
override OPTIONS_DOC	:= $(subst $(_CSS),$(shell		$(ECHO) '$(_CSS)'		| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_DOC))
override OPTIONS_DOC	:= $(subst $(REVEALJS_DST),$(shell	$(ECHO) '$(REVEALJS_DST)'	| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_DOC))
override OPTIONS_DOC	:= $(subst $(W3CSLIDY_DST),$(shell	$(ECHO) '$(W3CSLIDY_DST)'	| $(SED) $(MSYS_SED_FIXES)),$(OPTIONS_DOC))
endif

.PHONY: $(COMPOSER_TARGET)
$(COMPOSER_TARGET): .set_title-$(COMPOSER_TARGET)
$(COMPOSER_TARGET): $(BASE).$(EXTENSION)

.PHONY: $(COMPOSER_PANDOC)
$(COMPOSER_PANDOC): $(LIST) $(SETTING)
ifneq ($(COMPOSER_DEBUGIT),)
	@$(TABLE_I3) "$(_H)Shell:"		'$(_D)$(ENV)'
	@$(TABLE_I3) "$(_H)Environment:"	'$(_D)$(OPTIONS_ENV)'
	@$(TABLE_I3) "$(_H)Pandoc:"		'$(_D)$(PANDOC)'
	@$(TABLE_I3) "$(_H)Options:"		'$(_D)$(OPTIONS_DOC)'
endif
	@$(ECHO) "$(_N)"
	@$(ENV) - $(OPTIONS_ENV) $(PANDOC) $(OPTIONS_DOC)
	@$(ECHO) "$(_D)"
	@$(DATESTAMP) >"$(CURDIR)/$(COMPOSER_STAMP)"

$(BASE).$(EXTENSION): $(LIST)
	@$(MAKEDOC) --silent TYPE="$(TYPE)" BASE="$(BASE)" LIST="$(LIST)"

#WORKING:NOW: dual targets

%.$(TYPE_HTML): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_HTML)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_HTML): %
	@$(COMPOSE) --silent TYPE="$(TYPE_HTML)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(TYPE_LPDF): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_LPDF)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_LPDF): %
	@$(COMPOSE) --silent TYPE="$(TYPE_LPDF)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(EXTN_PRES): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"

%.$(EXTN_PRES): %
	@$(COMPOSE) --silent TYPE="$(TYPE_PRES)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(EXTN_SHOW): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)"

%.$(EXTN_SHOW): %
	@$(COMPOSE) --silent TYPE="$(TYPE_SHOW)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(TYPE_DOCX): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_DOCX)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_DOCX): %
	@$(COMPOSE) --silent TYPE="$(TYPE_DOCX)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(TYPE_EPUB): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)"

%.$(TYPE_EPUB): %
	@$(COMPOSE) --silent TYPE="$(TYPE_EPUB)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(EXTN_TEXT): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_TEXT)" BASE="$(*)" LIST="$(^)"

%.$(EXTN_TEXT): %
	@$(COMPOSE) --silent TYPE="$(TYPE_TEXT)" BASE="$(*)" LIST="$(^)"

#WORKING:NOW: dual targets

%.$(EXTN_LINT): %.$(COMPOSER_EXT)
	@$(COMPOSE) --silent TYPE="$(TYPE_LINT)" BASE="$(*)" LIST="$(^)"

%.$(EXTN_LINT): %
	@$(COMPOSE) --silent TYPE="$(TYPE_LINT)" BASE="$(*)" LIST="$(^)"

################################################################################
# End Of File
################################################################################
