# >> HEADERS
override COMPOSER_ABSPATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
override COMPOSER_TEACHER := $(abspath $(COMPOSER_ABSPATH)/../Makefile)

# >> DEFINITIONS
override COMPOSER_TARGETS ?= $(foreach FILE,html pdf docx txt,resume.$(FILE))
override COMPOSER_SUBDIRS ?=
override COMPOSER_DEPENDS ?=

# >> VARIABLES
override LVL ?=

# >> INCLUDE
include $(COMPOSER_TEACHER)
.DEFAULT_GOAL := all
