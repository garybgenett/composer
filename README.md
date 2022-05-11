% Composer CMS: Content Make System
% Gary B. Genett
% v3.0 (2022-05-11)

# Composer CMS #################################################################

| ![Composer Icon]    | "Creating Made Simple."
| :---                | :---
| [Composer CMS v3.0] | [License: GPL]
| [Gary B. Genett]    | [composer@garybgenett.net]

[Composer]: https://github.com/garybgenett/composer
[License: GPL]: https://github.com/garybgenett/composer/blob/master/LICENSE.md
[Gary B. Genett]: http://www.garybgenett.net/projects/composer
[composer@garybgenett.net]: mailto:composer@garybgenett.net?subject=Composer%20CMS%20Submission&body=Thank%20you%20for%20sending%20a%20message%21

[Composer CMS v3.0]: https://github.com/garybgenett/composer/tree/v3.0
[Composer Icon]: artifacts/icon-v1.0.png
[Composer Screenshot]: artifacts/screenshot-v3.0.png

[GNU Make]: http://www.gnu.org/software/make
[Markdown]: http://daringfireball.net/projects/markdown
[GitHub]: https://github.com

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
[Git]: https://git-scm.com

## Overview ####################################################################

**[Composer] is a simple but powerful CMS based on [Pandoc], [Bootstrap] and
[GNU Make].**  It is a document and website build system that processes
directories or individual files in [Markdown] format.

Traditionally, CMS stands for Content Management System.  [Composer] is designed
to be a Content **Make** System.  Written content is vastly easier to manage as
plain text, which can be crafted with simple editors and tracked with revision
control.  However, professional documentation, publications, and websites
require formatting that is dynamic and feature-rich.

[Pandoc] is an extremely powerful document conversion tool, and is a widely used
standard for processing [Markdown] into other formats.  While it has reasonable
defaults, there are a large number of options, and additional tools are required
for some formats and features.

[Composer] consolidates all the necessary components, simplifies the options,
and prettifies the output formats, all in one place.  It also serves as a build
system, so that large repositories can be managed as documentation archives or
published as [Bootstrap Websites].

![Composer Icon]
![Composer Screenshot]

## Quick Start #################################################################

Use `make help` to get started:

    make [-f .../Makefile] [variables] <filename>.<extension>
    make [-f .../Makefile] [variables] <target>

Fetch the necessary binary components
(see [Repository Versions]):

    make _update-all

Create documents from source [Markdown] files
(see [Formatting Variables]):

    make README.html
    make Composer-v3.0.Manual.html c_list="README.md LICENSE.md"

Save a persistent configuration
(see [Recommended Workflow], [Configuration Settings] and [Special Targets]):

    make template >.composer.mk
    $EDITOR .composer.mk
        book-Composer-v3.0.Manual.html: README.md LICENSE.md
    make clean
    make all

Recursively install and build an entire directory tree
(see [Recommended Workflow]):

    cd .../documents
    mv .../composer .Composer
    make -f .Composer/Makefile install-all
    make all-all

See `help-all` for full details and additional targets.

## Principles ##################################################################

The guiding principles of [Composer]:

  * All source files in readable plain text
  * Professional output, suitable for publication
  * Minimal dependencies, and entirely command-line driven
  * Separate content and formatting; writing and publishing are independent
  * Inheritance and dependencies; global, tree, directory and file overrides
  * Fast; both to initiate commands and for processing to complete

Direct support for key document types (see [Document Formatting]):

  * [HTML] & [Bootstrap Websites]
  * [PDF]
  * [EPUB]
  * [Reveal.js Presentations]
  * [Microsoft Word & PowerPoint]

## Requirements ################################################################

[Composer] has almost no external dependencies.  All needed components are
integrated directly into the repository, including [Pandoc].  It does require a
minimal command-line environment based on [GNU] tools, which is standard for all
[GNU/Linux] systems.  The [Windows Subsystem for Linux] for Windows and
[MacPorts] for macOS both provide suitable environments.

The one large external requirement is [TeX Live], and it can be installed using
the package managers of each of the above systems.  It is only necessary for
creating [PDF] files.

Below are the versions of the components in the repository, and the tested
versions of external tools for this iteration of [Composer].  Use [check] to
validate your system.

| Repository          | Commit                        | License
| :---                | :---                          | :---
| [Pandoc]            | 2.18                          | GPL
| [YQ]                | v4.24.2                       | MIT
| [Bootstrap]         | v5.1.3                        | MIT
| [Markdown Viewer]   | 059f3192d4ebf5fa9776          | MIT
| [Reveal.js]         | 4.3.1                         | MIT

| Project             | Composer Version
| :---                | :---
| GNU Bash            | 5.0.18
| - GNU Coreutils     | 8.31
| - GNU Findutils     | 4.8.0
| - GNU Sed           | 4.8
| [GNU Make]          | 4.2.1
| - [Pandoc]          | 2.18
| - [YQ]              | 4.24.2
| - [TeX Live] (pdf)  | 2021 3.14159 2.6-1.40.22

[Markdown Viewer] is included both for its CSS stylesheets, and for real-time
rendering of [Markdown] files as they are being written.  To install, follow the
instructions in the `README.md`, and select the appropriate `manifest.*.json`
file for your browser.

The versions of the integrated repositories can be changed, if desired (see
[Repository Versions]).

--------------------------------------------------------------------------------

# Composer Operation ###########################################################

## Recommended Workflow ########################################################

The ideal workflow is to put [Composer] in a top-level `.Composer` for each
directory tree you want to manage, creating a structure similar to this:

    .../.Composer
    .../
    .../tld/
    .../tld/sub/

Then, it can be converted to a [Composer] documentation archive ([Quick Start]
example):

    make -f .Composer/Makefile install-all
    make all-all

If specific settings need to be used, either globally or per-directory,
`.composer.mk` files can be created (see [Configuration Settings], [Quick Start]
example):

    make template >.composer.mk
    $EDITOR .composer.mk

Custom targets can also be defined, using standard [GNU Make] syntax (see
[Custom Targets]).

[GNU Make] does not support file and directory names with spaces in them, and
neither does [Composer].  Documentation archives which have such files or
directories will produce unexpected results.

It is fully supported for input files to be symbolic links to files that reside
outside the documentation archive:

    cd .../tld
    ln -rs .../README.md ./
    make README.html

Finally, it is best practice to [install-force] after every [Composer] upgrade,
in case there are any changes to the `Makefile` template (see [Primary
Targets]).

The archive is ready, and each directory is both a part of the collective and
its own individual instance.  Targets can be run per-file, per-directory, or
recursively through an entire directory tree.  The most commonly used targets
are in [Primary Targets].

**Welcome to [Composer].  Happy Making!**

## Document Formatting #########################################################

As outlined in [Overview] and [Principles], a primary goal of [Composer] is to
produce beautiful and professional output.  [Pandoc] does reasonably well at
this, and yet its primary focus is document conversion, not document formatting.
[Composer] fills this gap by specifically tuning a select list of the most
commonly used document formats.

Further options for each document type are in [Formatting Variables].  All
improvements not exposed as variables will apply to all documents created with a
given instance of [Composer].

Note that all the files referenced below are embedded in the 'Embedded Files'
and 'Heredoc' sections of the `Makefile`.  They are exported by the
[_release] target, and will be overwritten whenever it is run.

### HTML ###

In addition to being a helpful real-time rendering tool, [Markdown Viewer]
includes several CSS stylesheets that are much more visually appealing than the
[Pandoc] default, and which behave like normal webpages, so [Composer] uses them
for all [HTML]-based document types, including [EPUB].

Information on installing [Markdown Viewer] for use as a [Markdown] rendering
tool is in [Requirements].

### Bootstrap Websites ###

[Bootstrap] is a leading web development framework, capable of building static
webpages that behave dynamically.  Static sites are very easy and inexpensive to
host, and are extremely responsive compared to truly dynamic webpages.

[Composer] uses this framework to transform an archive of simple text files into
a modern website, with the appearance and behavior of dynamically indexed pages.

*(This feature is reserved for a future release as the [site] target, along with
[page] and [post] in [Special Targets].)*

### PDF ###

The default formatting for [PDF] is geared towards academic papers and the
typesetting of printed books, instead of documents that are intended to be
purely digital.

Internally, [Pandoc] first converts to LaTeX, and then uses [TeX Live] to
convert into the final [PDF].  [Composer] inserts customized LaTeX to modify the
final output:

    .../artifacts/pdf.latex

### EPUB ###

The [EPUB] format is essentially packaged [HTML], so [Composer] uses the same
[Markdown Viewer] CSS stylesheets for it.

### Reveal.js Presentations ###

The CSS for [Reveal.js] presentations has been modified to create a more
traditional and readable end result.  The customized version is at:

    .../artifacts/revealjs.css

It links in a default theme from the `.../revealjs/dist/theme` directory.  Edit
the location in the file, or use [c_css] to select a different theme.

It is set up so that a logo can be placed in the upper right hand corner on each
slide, for presentations that need to be branded.  Simply copy an image file to
the logo location:

    .../artifacts/logo.img

To have different logos for different directories (using [Recommended Workflow],
[Configuration Settings] and [Precedence Rules]):

    cd .../presentations
    cp .../logo.img ./
    ln -rs .../.Composer/artifacts/revealjs.css ./.composer.css
    echo 'override c_type := revealjs' >>./.composer.mk
    make all

### Microsoft Word & PowerPoint ###

The internal [Pandoc] templates for these are exported by [Composer], so they
are available for customization:

    .../artifacts/reference.docx
    .../artifacts/reference.pptx

They are not currently modified by [Composer].

## Configuration Settings ######################################################

[Composer] uses `.composer.mk` files for persistent settings and definition of
[Custom Targets].  By default, they only apply to the directory they are in (see
[COMPOSER_INCLUDE] in [Control Variables]).  The values in the most local file
override all others (see [Precedence Rules]).

The easiest way to create a new `.composer.mk` is with the [template] target
([Quick Start] example):

    make template >.composer.mk
    $EDITOR .composer.mk

All variable definitions must be in the `override [variable] := [value]` format
from the [template] target.  Doing otherwise will result in unexpected behavior,
and is not supported.  The regular expression that is used to detect them:

    override[[:space:]]+([^[:space:]]+)[[:space:]]+[:][=]

Variables can also be specified per-target, using [GNU Make] syntax (these are
the settings used to process the [Composer] `README.*` files):

    README.%: override c_css := css_alt
    README.%: override c_toc := 0
    README.epub: override c_css :=
    README.revealjs.html: override c_css :=
    README.revealjs.html: override c_toc :=

In this case, there are multiple definitions that could apply to
`README.revealjs.html`, due to the `%` wildcard.  Since the most specific target
match is used, the final values for both [c_css] and [c_toc] would be empty.

## Precedence Rules ############################################################

The order of precedence for `.composer.mk` files is global-to-local (see
[COMPOSER_INCLUDE] in [Control Variables]).  This means that the values in the
most local file override all others.

Variable aliases, such as `COMPOSER_DEBUGIT`/`c_debug`/`V` are prioritized in
the order shown, with `COMPOSER_*` taking precedence over `c_*`, over the short
alias.

Selection of the CSS file can be done using `.composer.css` or the [c_css]
variable, with `.composer.css` taking precedence (unless [c_css] comes from
`.composer.mk`).  The process for `.composer.css` files is identical to
`.composer.mk` (see [COMPOSER_INCLUDE] in [Control Variables]).

All values in `.composer.mk` take precedence over everything else, including
`.composer.css` and environment variables.

## Specifying Dependencies #####################################################

If there are files or directories that have dependencies on other files or
directories being processed first, this can be done simply using [GNU Make]
syntax in `.composer.mk`:

    LICENSE.html: README.html
    all-subdirs-artifacts: all-subdirs-bootstrap

This would require `README.html` to be completed before `LICENSE.html`, and for
`bootstrap` to be processed before `artifacts`.  Directories need to be
specified with the `all-subdirs-*` syntax in order to avoid conflicts with
target names (see [Custom Targets]).  Good examples of this are the internal
[docs] and [test] targets, which are common directory names.

Chaining of dependencies can be as complex and layered as [GNU Make] will
support.  Note that if a file or directory is set to depend on a target, that
target will be run whenever the file or directory is called.

## Custom Targets ##############################################################

If needed, custom targets can be defined inside a `.composer.mk` file (see
[Configuration Settings]), using standard [GNU Make] syntax.  Naming them as
[*-clean] or [*-all] will include them in runs of the respective targets.
Targets with any other names will need to be run manually, or included in
[COMPOSER_TARGETS] (see [Control Variables]).

There are a few limitations when naming custom targets.  Targets starting with
the regular expression `[_.]` are hidden, and are skipped by auto-detection.
Additionally, there is a list of reserved targets in [Reserved], along with a
list of reserved variables.

Any included `.composer.mk` files are sourced early in the main [Composer]
`Makefile`, so matching targets and most variables will be overridden.  In the
case of conflicting targets, [GNU Make] will produce warning messages.
Variables will have their values changed silently.  Changing the values of
internal [Composer] variables is not recommended or supported.

A final note is that [*-clean] and [*-all] targets are stripped from
[COMPOSER_TARGETS].  In cases where this results in an empty [COMPOSER_TARGETS],
there will be a message and no actions will be taken.

## Repository Versions #########################################################

There are a few internal variables used by [_update] to select the repository
and binary versions of integrated components (see [Requirements]).  These are
exposed for configuration, but only within `.composer.mk`:

  * `PANDOC_VER` (must be a binary version number)
  * `PANDOC_CMT` (defaults to `PANDOC_VER`)
  * `YQ_VER` (must be a binary version number)
  * `YQ_CMT` (defaults to `YQ_VER`)
  * `BOOTSTRAP_CMT`
  * `MDVIEWER_CMT`
  * `REVEALJS_CMT`

Binaries for [Pandoc] and [YQ] are installed in their respective directories.
By moving or removing them, or changing the version number and foregoing
[_update-all] (see [Additional Targets]), the system versions will be used
instead.  This will work as long as the commit versions match, so that
supporting files are in alignment.

It is possible that changing the versions will introduce incompatibilities with
[Composer], which are usually impacts to the prettification of output files
(see [Document Formatting]).

--------------------------------------------------------------------------------

# Composer Variables ###########################################################

## Formatting Variables ########################################################

| Variable            | Purpose                       | Value
| :---                | :---                          | :---
| [c_type]    ~ T     | Desired output format         | html
| [c_base]    ~ B     | Base of output file           | README
| [c_list]    ~ L     | List of input files(s)        | README.md
| [c_lang]    ~ g     | Language for document headers | en-US
| [c_css]     ~ s     | Location of CSS file          | (`.composer.css`)
| [c_toc]     ~ c     | Table of contents depth       | 
| [c_level]   ~ l     | Chapter/slide header level    | 2
| [c_margin]  ~ m     | Size of margins ([PDF])       | 0.8in
| [c_options] ~ o     | Custom Pandoc options         | 

| Values: c_type      | Format                        | Extension
| :---                | :---                          | :---
| html                | HyperText Markup Language     | *.html
| pdf                 | Portable Document Format      | *.pdf
| epub                | Electronic Publication        | *.epub
| revealjs            | Reveal.js Presentation        | *.revealjs.html
| docx                | Microsoft Word                | *.docx
| pptx                | Microsoft PowerPoint          | *.pptx
| text                | Plain Text (well-formatted)   | *.txt
| markdown            | Pandoc Markdown (for testing) | *.md.txt

  * *Other [c_type] values will be passed directly to [Pandoc]*
  * *Special values for [c_css]:*
    * *`css_alt`                        ~ Use the alternate default stylesheet*
    * *`0`                              ~ Revert to the [Pandoc] default*
  * *Special value `0` for [c_toc]      ~ List all headers, and number sections*
  * *Special value `0` for [c_level]    ~ Varies by [c_type] (see [help-all])*
  * *An empty [c_margin] value enables individual margins:*
    * *`c_margin_top`    ~ `mt`*
    * *`c_margin_bottom` ~ `mb`*
    * *`c_margin_left`   ~ `ml`*
    * *`c_margin_right`  ~ `mr`*

### c_type / c_base / c_list ###

The [compose] target uses these variables to decide what to build and how.  The
output file is `[c_base].<extension>`, and is constructed from the [c_list] input
files, in order.  The `<extension>` is selected based on the [c_type] table
above.  Generally, it is not required to use the [compose] target directly for
supported [c_type] files, since it is run automatically based on what output
file `<extension>` is specified.

The automatic input file detection works by matching one of the following
([Quick Start] example):

    make README.html                    ~ README (empty [COMPOSER_EXT])
    make README.html                    ~ README.md
    make README.md.html                 ~ README.md
    make Composer-v3.0.Manual.html      c_list="README.md LICENSE.md"

Other values for [c_type], such as `json` or `man`, for example, can be passed
through to [Pandoc] manually:

    make compose c_type="json" c_base="README" c_list="README.md"
    make compose c_type="man" c_base="Composer-v3.0.Manual" c_list="README.md"

Any of the file types supported by [Pandoc] can be created this way.  The only
limitation is that the input files must be in [Markdown] format.

### c_lang ###

  * Primarily for [PDF], this specifies the language that the table of contents
    ([c_toc]) and chapter headings ([c_level]) will use.

### c_css ###

  * By default, a CSS stylesheet from [Markdown Viewer] is used for [HTML] and
    [EPUB], and one of the [Reveal.js] themes is used for [Reveal.js
    Presentations].  This variable allows for selection of a different file in
    all cases.
  * The special value `css_alt` selects the alternate default stylesheet.  Using
    `0` reverts to the [Pandoc] default.
  * This value can be overridden by the presence of `.composer.css` files.  See
    [Precedence Rules] for details.

### c_toc ###

  * Setting this to a value of `[1-6]` creates a table of contents at the
    beginning of the document.  The numerical value is how many header levels
    deep the table should go.  A value of `6` lists all header levels.
  * Using a value of `0` lists all header levels, and additionally numbers all
    the sections, for reference.

### c_level ###

  * This value has different effects, depending on the [c_type] of the output
    document.
  * For [HTML], any value enables `section-divs`, which wraps headings and their
    section content in `<section>` tags and attaches identifiers to them instead
    of the headings themselves.  This is for CSS styling, and is generally
    desired.
  * For [PDF], there are 3 top-level division types: `part`, `chapter`, and
    `section`.  This sets the top-level header to the specified type, which
    changes the way the document is presented.  Using `part` divides the
    document into "Parts", each starting with a stand-alone title page.  With
    this division type, each second-level heading starts a new "Chapter".  A
    `chapter` simply starts a new section on a new page, and lower-level
    headings continue as running portions within it.  Finally, `section` creates
    one long running document with no blank pages or section breaks (like a
    [HTML] page).  To set the desired value:
      * `part` ~ `0`
      * `chapter` ~ `2`
      * `section` ~ Any other value
  * For [EPUB], this creates chapter breaks at the specified level, starting the
    section on a new page.  The special `0` simply sets it to the default value
    of `2`.
  * For [Reveal.js Presentations], the top-level headings can persist on the
    screen when moving through slides in their sections, or they can rotate out
    as their own individual slides.  Setting to `0` enables persistent headings,
    and all other values use the default.
  * An empty value defers to the [Pandoc] defaults in all cases.

### c_margin ###

  * The default margins for [PDF] are formatted for typesetting of printed
    books, where there is a large amount of open space around the edges and the
    text on each page is shifted away from where the binding would be.  This is
    generally not what is desired in a purely digital [PDF] document.
  * This is one value for all the margins.  Setting it to an empty value exposes
    variables for each of the individual margins: `c_margin_top`,
    `c_margin_bottom`, `c_margin_left` and `c_margin_right`.

### c_options ###

  * In some cases, it may be desirable to add additional [Pandoc] options.
    Anything put in this variable will be passed directly to [Pandoc] as
    additional command-line arguments.

## Control Variables ###########################################################

| Variable            | Purpose                       | Value
| :---                | :---                          | :---
| [MAKEJOBS]          | Parallel processing threads   | 1 `(makejobs)`
| [COMPOSER_DOCOLOR]  | Enable title/color sequences  | `(boolean)`
| [COMPOSER_DEBUGIT]  | Use verbose output            | `(debugit)`
| [COMPOSER_INCLUDE]  | Include all: `.composer.mk`   | `(boolean)`
| [COMPOSER_DEPENDS]  | Sub-directories first: [all]  | `(boolean)`
| [COMPOSER_LOG]      | Timestamped command log       | .composed
| [COMPOSER_EXT]      | Markdown file extension       | .md
| [COMPOSER_TARGETS]  | See: [all]/[clean]            | [config]/[targets]
| [COMPOSER_SUBDIRS]  | See: [all]/[clean]/[install]  | [config]/[targets]
| [COMPOSER_IGNORES]  | See: [all]/[clean]/[install]  | [config]

  * *[MAKEJOBS]         ~ `c_jobs`  ~ `J`*
  * *[COMPOSER_DOCOLOR] ~ `c_color` ~ `C`*
  * *[COMPOSER_DEBUGIT] ~ `c_debug` ~ `V`*
  * *`(makejobs)` = empty is disabled / number of threads / `0` is no limit*
  * *`(debugit)`  = empty is disabled / any value enables / `0` is full tracing*
  * *`(boolean)`  = empty is disabled / any value enables*

### MAKEJOBS ###

  * By default, [Composer] progresses linearly, doing one task at a time.  If
    there are dependencies between items, this can be beneficial, since it
    ensures things will happen in a particular order.  The downside, however, is
    that it is very slow.
  * [Composer] supports [GNU Make] parallel execution, where multiple threads
    can be working through tasks independently.  Experiment with lower values
    first.  When recursing through large directories, each `make` that
    instantiates into a sub-directory has it's own jobs server, so the total
    number of threads running can proliferate rapidly.
  * This can drastically speed up execution, processing thousands of files and
    directories in minutes.  However, values that are too high can exhaust
    system resources.  With great power comes great responsibility.
  * A value of `0` does parallel execution with no thread limit.

### COMPOSER_DOCOLOR ###

  * [Composer] uses colors to make all output and [help] text easier to read.
    The escape sequences used to accomplish this can create mixed results when
    reading in an output file or a `$PAGER`, or just make it harder to read for
    some.
  * This is also used internally for targets like [debug-file] and [template],
    where plain text is required.

### COMPOSER_DEBUGIT ###

  * Provides more explicit details about what is happening at each step.
    Produces a lot more output, and can be slower.  It will also be hard to read
    unless [MAKEJOBS] is set to `1`.
  * Full tracing using `0` also displays [GNU Make] debugging output.
  * *When doing [debug], this is used to pass a list of targets to test (see
    [Additional Targets]).*

### COMPOSER_INCLUDE ###

  * On every run, [Composer] walks through the `MAKEFILE_LIST`, all the way back
    to the main `Makefile`, looking for `.composer.mk` files in each directory.
    By default, it only reads the one in its main directory and the current
    directory, in that order.  Enabling this causes all of them to be read.
  * In the example directory tree below, normally the `.composer.mk` in
    `.Composer` is read first, and then `tld/sub/.composer.mk`.  With this
    enabled, it will read all of them in order from top to bottom:
    `.Composer/.composer.mk`, `.composer.mk`, `tld/.composer.mk`, and finally
    `tld/sub/.composer.mk`.
  * This is why it is best practice to have a `.Composer` directory at the top
    level for each documentation archive (see [Recommended Workflow]).  Not only
    does it allow for strict version control of [Composer] per-archive, it also
    provides a mechanism for setting [Composer Variables] globally.
  * Care should be taken setting "Local" variables from [template] (see
    [Templates]) when using this option.  In that case, they will be propagated
    down the tree.  This may be desired in some cases, but it will require that
    each directory set these manually, which could require a lot of maintenance.
  * This setting also causes `.composer.css` files to be processed in an
    identical manner (see [Precedence Rules]).

Example directory tree (see [Recommended Workflow]):

    .../.Composer/Makefile
    .../.Composer/.composer.mk
    .../Makefile
    .../.composer.mk
    .../tld/Makefile
    .../tld/.composer.mk
    .../tld/sub/Makefile
    .../tld/sub/.composer.mk

### COMPOSER_DEPENDS ###

  * When doing [all-all], [Composer] will process the current directory before
    recursing into sub-directories.  This reverses that, and sub-directories
    will be processed first.
  * In the example directory tree in [COMPOSER_INCLUDE] above, the default would
    be: `.../`, `.../tld`, and then `.../tld/sub`.  If the higher-level
    directories have dependencies on the sub-directories being run first, this
    will support that by doing them in reverse order, processing them from
    bottom to top.
  * It should be noted that enabling this disables [MAKEJOBS], to ensure linear
    processing, and that it has no effect on [install] or [clean].

### COMPOSER_LOG ###

  * [Composer] appends to a `.composed` log file in the current directory
    whenever it executes [Pandoc].  This provides some accounting, and is used
    by [list] to determine which `*.md` files have been updated since the last
    time [Composer] was run.
  * This setting can change the name of the log file, or disable it completely
    (empty value).
  * It is removed each time [clean] is run.

### COMPOSER_EXT ###

  * The [Markdown] file extension [Composer] uses: `*.md`.  This is for
    auto-detection of files to add to [COMPOSER_TARGETS], files to output for
    [list], and other tasks.  This is a widely used standard, including
    [GitHub].  Another commonly used extension is: `*.markdown`.
  * In some cases, they do not have any extension, such as `README` and
    `LICENSE` in source code directories.  Setting this to an empty value causes
    them to be detected and output.  It also causes all other files to be
    processed, because it becomes the wildcard `*`, so use with care.  It is
    likely best to use [COMPOSER_TARGETS] to explicitly set the targets list in
    these situations.

### COMPOSER_TARGETS ###

  * The list of output files to create or delete with [clean] and [all].
    [Composer] does auto-detection using [c_type] and [COMPOSER_EXT], so this
    does not usually need to be set.  Hidden files that start with `.` are
    skipped.
  * Setting this manually disables auto-detection.  It can also include non-file
    targets added into a `.composer.mk` file (see [Custom Targets]).
  * The `.null` target is special, and when used as a value for
    [COMPOSER_TARGETS] or [COMPOSER_SUBDIRS] it will display a message and
    do nothing.  A side-effect of this target is that an actual file or
    directory named `.null` will never be created or removed by [Composer].
  * An empty value triggers auto-detection
  * Use [config] or [targets] to check the current value.

### COMPOSER_SUBDIRS ###

  * The list of sub-directories to recurse into with [install], [clean], and
    [all].  The behavior and configuration is identical to [COMPOSER_TARGETS]
    above, including auto-detection and the `.null` target.  Hidden directories
    that start with `.` are skipped.
  * An empty value triggers auto-detection
  * Use [config] or [targets] to check the current value.

### COMPOSER_IGNORES ###

  * The list of [COMPOSER_TARGETS] and [COMPOSER_SUBDIRS] to skip with
    [install], [clean], and [all].  This allows for selective auto-detection,
    when the list of items to process is larger than those to leave alone.
  * Use [config] to check the current value.

--------------------------------------------------------------------------------

# Composer Targets #############################################################

## Primary Targets #############################################################

| Target              | Purpose
| :---                | :---
| [help]              | Basic help overview (default)
| [help-all]          | Console version of `README.md` (mostly identical)
| [template]          | Print settings template: `.composer.mk`
| [compose]           | Document creation engine (see [Formatting Variables])
| [site]              | Recursively create [Bootstrap Websites]
| [install]           | Current directory initialization: `Makefile`
| [install-all]       | Do [install] recursively (no overwrite)
| [install-force]     | Recursively force overwrite of `Makefile` files
| [clean]             | Remove output files: [COMPOSER_TARGETS] :: [*-clean]
| [clean-all]         | Do [clean] recursively: [COMPOSER_SUBDIRS]
| [*-clean]           | Any targets named this way will also be run by [clean]
| [all]               | Create output files: [COMPOSER_TARGETS] :: [*-all]
| [all-all]           | Do [all] recursively: [COMPOSER_SUBDIRS]
| [*-all]             | Any targets named this way will also be run by [all]
| [list]              | Print updated files: `*.md` >> `.composed`

### help / help-all ###

  * Outputs all of the documentation for [Composer].  The `README.md` has a few
    extra sections covering internal targets, along with reserved target and
    variable names, but is otherwise identical to the [help-all] output.

### template ###

  * Prints a useful template for creating new `.composer.mk` files (see
    [Configuration Settings] and [Templates]).

### compose ###

  * This is the very core of [Composer], and does the actual work of the
    [Pandoc] conversion.  Details are in the [c_type / c_base / c_list] section
    of [Formatting Variables].

### site ###

  * *(This feature is reserved for a future release to create [Bootstrap
    Websites].  It will also include [page] and [post] from [Special Targets].)*

### install / install-all / install-force ###

  * Creates the necessary `Makefile` files to set up a directory or a directory
    tree as a [Composer] archive.  By default, it will not overwrite any
    existing files.
  * Doing a simple [install] will only create a file in the current directory,
    whereas [install-all] will recurse through the entire directory tree.  A
    full [install-force] is the same as [install-all], with the exception that
    it will overwrite all `Makefile` files.
  * The topmost directory will have the `Makefile` created for it modified to
    point to [Composer].

### clean / clean-all / \*-clean ###

  * Deletes all [COMPOSER_TARGETS] output files in the current directory, after
    first running all [*-clean] targets, including those for [Specials].
  * Doing [clean-all] does the same thing recursively, through all the
    [COMPOSER_SUBDIRS].

### all / all-all / \*-all ###

  * Creates all [COMPOSER_TARGETS] output files in the current directory, after
    first running all [*-all] targets, including those for [Specials].
  * Doing [all-all] does the same thing recursively, through all the
    [COMPOSER_SUBDIRS].

### list ###

  * Outputs all the [COMPOSER_EXT] files that have been modified since
    [COMPOSER_LOG] was last updated (see both in [Control Variables]).  Acts as
    a quick reference to see if anything has changed.
  * Since the [COMPOSER_LOG] file is updated whenever [Pandoc] is executed, this
    target will primarily be useful when [all] is the only target used to create
    files in the directory.

## Special Targets #############################################################

[Specials]: #special-targets
[Special]: #special-targets

There are a few targets considered [Specials], that have unique properties:

| Base Name           | Purpose
| :---                | :---
| [book]              | Concatenate a source list into a single output file
| [page]              | *(Reserved for the future [site] feature)*
| [post]              | *(Reserved for the future [site] feature)*

For each of these base names, there are a standard set of actual targets:

| Target              | Purpose
| :---                | :---
| %s-clean            | Called by [clean], removes all `%-*` files
| %s-all              | Called by [all], creates all `%-*` files
| %s                  | Main target, which is a wrapper to `%s-all`
| %-*                 | Target files will be processed according to the base

### book ###

An example [book] definition in a `.composer.mk` file ([Quick Start] example):

    book-Composer-v3.0.Manual.html: README.md LICENSE.md

This configures it so that `books` will create `Composer-v3.0.Manual.html` from
`README.md` and `LICENSE.md`, concatenated together in order.  The primary
purpose of this [Special] is to gather multiple source files in this manner, so
that larger works can be comprised of multiple files, such as a book with each
chapter in a separate file.

### page / post ###

*(Both [page] and [post] are reserved for the future [site] feature, which will
build website pages using [Bootstrap].)*

## Additional Targets ##########################################################

| Target              | Purpose
| :---                | :---
| [debug]             | Diagnostics, tests targets list in [COMPOSER_DEBUGIT]
| [debug-file]        | Export [debug] results to a plain text file
| [check]             | List system packages and versions (see [Requirements])
| [check-all]         | Complete [check] package list, and system information
| [config]            | Show values of all [Composer Variables]
| [config-all]        | Complete [config], including environment variables
| [targets]           | List all available targets for the current directory
| [_commit]           | Timestamped [Git] commit of the current directory tree
| [_commit-all]       | Automatic [_commit], without `$EDITOR` step
| [_release]          | Full upgrade to current release, repository preparation
| [_update]           | Update all included components (see [Requirements])
| [_update-all]       | Complete [_update], including binaries: [Pandoc], [YQ]

### debug / debug-file ###

  * This is the tool to use for any support issues.  Submit the output file to:
    [composer@garybgenett.net]
  * Internally, it also runs:
    * [test]
    * [check-all]
    * [config-all]
    * [targets]
  * If issues are occurring when running a particular set of targets, list them
    in [COMPOSER_DEBUGIT].
  * For general issues, run in the top-level directory (see [Recommended
    Workflow]).  For specific issues, run in the directory where the issue is
    occurring.

For example:

    make COMPOSER_DEBUGIT="books README.html" debug-file

### check / check-all / config / config-all / targets ###

  * Useful targets for validating tooling and configurations.
  * Use [check] to see the list of components and their versions, in relation to
    the system installed versions.  Doing [check-all] will show the complete
    list of tools that are used by [Composer].
  * The current values of all [Composer Variables] is output by [config], and
    [config-all] will additionally output all environment variables.
  * A structured list of detected targets, available [Specials], [*-clean] and
    [*-all] targets, [COMPOSER_TARGETS], and [COMPOSER_SUBDIRS] is printed by
    [targets].
  * Together, [config] and [targets] reveal the entire internal state of
    [Composer].

### \_commit / \_commit-all ###

  * Using the directory structure in [Recommended Workflow], `.../` is
    considered the top-level directory.  Meaning, it is the last directory
    before linking to [Composer].
  * If the top-level directory is a [Git] repository (it has `<directory>.git`
    or `<directory>/.git`), this target creates a commit of the current
    directory tree with the title format below.
  * For example, if it is run in the `.../tld` directory, that entire tree would
    be in the commit, including `.../tld/sub`.  The purpose of this is to create
    quick and easy checkpoints when working on documentation that does not
    necessarily fit in a process where there are specific atomic steps being
    accomplished.
  * When this target is run in a [Composer] directory, it uses itself as the
    top-level directory.

Commit title format:

    [Composer CMS v3.0 :: 2022-05-11T12:26:31-07:00]

### \_release / \_update / \_update-all ###

  * Using the repository configuration (see [Repository Versions]), these fetch
    and install all external components.
  * The [_update-all] target also fetches the [Pandoc] and [YQ] binaries,
    whereas [_update] only fetches the repositories.
  * In addition to doing [_update-all], [_release] performs the steps necessary
    to turn the current directory into a complete clone of [Composer].
  * If `rsync` is installed, [_release] can be used to rapidly replicate
    [Composer], like below.
  * One of the unique features of [Composer] is that everything needed to
    compose itself is embedded in the `Makefile`.

Rapid cloning (requires `rsync`):

    mkdir .../clone
    cd .../clone
    make -f .../.Composer/Makefile _release

## Internal Targets ############################################################

| Target              | Purpose
| :---                | :---
| [help-force]        | Complete `README.md` content (similar to [help-all])
| [.template-install] | The `Makefile` used by [install] (see [Templates])
| [.template]         | The `.composer.mk` used by [template] (see [Templates])
| [docs]              | Extracts embedded files from `Makefile`, and does [all]
| [headers]           | Series of targets that handle all informational output
| [headers-template]  | For testing default [headers] output
| [headers-template-all]| For testing complete [headers] output
| [.make_database]    | Complete contents of [GNU Make] internal state
| [.all_targets]      | Extracted list of all targets from [.make_database]
| [.null]             | Placeholder to specify or detect empty values
| [test]              | Test suite, validates all supported features
| [test-file]         | Export [test] results to a plain text file
| [check-force]       | Minimized [check] output (used for [Requirements])
| [subdirs]           | Expands [COMPOSER_SUBDIRS] into `*-subdirs-*` targets

[help-force]: #internal-targets
[.template-install]: #internal-targets
[.template]: #internal-targets
[docs]: #internal-targets
[headers]: #internal-targets
[headers-template]: #internal-targets
[headers-template-all]: #internal-targets
[.make_database]: #internal-targets
[.all_targets]: #internal-targets
[.null]: #internal-targets
[test]: #internal-targets
[test-file]: #internal-targets
[check-force]: #internal-targets
[subdirs]: #internal-targets

*(None of these are intended to be run directly during normal use, and are only
documented for completeness.)*

--------------------------------------------------------------------------------

# Reference ####################################################################

[Composer Variables]: #composer-variables
[Formatting Variables]: #formatting-variables
[Control Variables]: #control-variables
[Composer Targets]: #composer-targets
[Primary Targets]: #primary-targets
[Special Targets]: #special-targets
[Additional Targets]: #additional-targets
[Internal Targets]: #internal-targets
[Command Examples]: #command-examples
[Composer CMS]: #composer-cms
[Overview]: #overview
[Quick Start]: #quick-start
[Principles]: #principles
[Requirements]: #requirements
[Composer Operation]: #composer-operation
[Recommended Workflow]: #recommended-workflow
[Document Formatting]: #document-formatting
[Configuration Settings]: #configuration-settings
[Precedence Rules]: #precedence-rules
[Specifying Dependencies]: #specifying-dependencies
[Custom Targets]: #custom-targets
[Repository Versions]: #repository-versions
[Reference]: #reference
[Templates]: #templates
[Reserved]: #reserved

[HTML]: #html
[Bootstrap Websites]: #bootstrap-websites
[PDF]: #pdf
[EPUB]: #epub
[Reveal.js Presentations]: #revealjs-presentations
[Microsoft Word & PowerPoint]: #microsoft-word--powerpoint
[c_lang]: #c_lang
[c_css]: #c_css
[c_toc]: #c_toc
[c_level]: #c_level
[c_margin]: #c_margin
[c_options]: #c_options
[MAKEJOBS]: #makejobs
[COMPOSER_DOCOLOR]: #composer_docolor
[COMPOSER_DEBUGIT]: #composer_debugit
[COMPOSER_INCLUDE]: #composer_include
[COMPOSER_DEPENDS]: #composer_depends
[COMPOSER_LOG]: #composer_log
[COMPOSER_EXT]: #composer_ext
[COMPOSER_TARGETS]: #composer_targets
[COMPOSER_SUBDIRS]: #composer_subdirs
[COMPOSER_IGNORES]: #composer_ignores
[template]: #template
[compose]: #compose
[site]: #site
[list]: #list
[book]: #book

[c_type / c_base / c_list]: #c_type--c_base--c_list
[help / help-all]: #help--help-all
[install / install-all / install-force]: #install--install-all--install-force
[clean / clean-all / *-clean]: #clean--clean-all---clean
[all / all-all / *-all]: #all--all-all---all
[page / post]: #page--post
[debug / debug-file]: #debug--debug-file
[check / check-all / config / config-all / targets]: #check--check-all--config--config-all--targets
[_commit / _commit-all]: #_commit--_commit-all
[_release / _update / _update-all]: #_release--_update--_update-all

[c_type]: #c_type--c_base--c_list
[c_base]: #c_type--c_base--c_list
[c_list]: #c_type--c_base--c_list
[help]: #help--help-all
[help-all]: #help--help-all
[install]: #install--install-all--install-force
[install-all]: #install--install-all--install-force
[install-force]: #install--install-all--install-force
[clean]: #clean--clean-all---clean
[clean-all]: #clean--clean-all---clean
[*-clean]: #clean--clean-all---clean
[all]: #all--all-all---all
[all-all]: #all--all-all---all
[*-all]: #all--all-all---all
[page]: #page--post
[post]: #page--post
[debug]: #debug--debug-file
[debug-file]: #debug--debug-file
[check]: #check--check-all--config--config-all--targets
[check-all]: #check--check-all--config--config-all--targets
[config]: #check--check-all--config--config-all--targets
[config-all]: #check--check-all--config--config-all--targets
[targets]: #check--check-all--config--config-all--targets
[_commit]: #_commit--_commit-all
[_commit-all]: #_commit--_commit-all
[_release]: #_release--_update--_update-all
[_update]: #_release--_update--_update-all
[_update-all]: #_release--_update--_update-all

## Templates ###################################################################

The [install] target `Makefile` template (for reference only):

    override COMPOSER_MY_PATH := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
    override COMPOSER_TEACHER := $(abspath $(dir $(COMPOSER_MY_PATH)))/Makefile
    include $(COMPOSER_TEACHER)

Use the [template] target to create `.composer.mk` files:

    # >> Global
    # override MAKEJOBS := 1
    # override COMPOSER_DOCOLOR :=
    # override COMPOSER_DEBUGIT :=
    # override COMPOSER_INCLUDE :=
    # override COMPOSER_DEPENDS :=
    # override COMPOSER_LOG := .composed
    # override COMPOSER_EXT := .md
    # override c_type := html
    # override c_lang := en-US
    # override c_css :=
    # override c_toc :=
    # override c_level := 2
    # override c_margin := 0.8in
    # override c_margin_top :=
    # override c_margin_bottom :=
    # override c_margin_left :=
    # override c_margin_right :=
    # override c_options :=
    # >> Local
    # override COMPOSER_TARGETS := README.html README.pdf README.epub README.revealjs.html README.docx
    # override COMPOSER_SUBDIRS :=
    # override COMPOSER_IGNORES :=
    # override c_base := README
    # override c_list := README.md
    # >> Special
    # book-Composer.book.html: README.md LICENSE.md
    # page-Composer.page.html: README.md LICENSE.md
    # post-Composer.post.html: README.md LICENSE.md

## Reserved ####################################################################

Reserved target names, including use as prefixes:

    .all_targets
    .make_database
    .null
    all
    book
    books
    check
    clean
    compose
    config
    debug
    docs
    headers
    help
    install
    list
    page
    pages
    post
    posts
    site
    subdirs
    targets
    template
    test
    _commit
    _release
    _update

Reserved variable names:

    ~
    7Z
    7Z_VER
    BASE64
    BASH
    BASH_VER
    BOOTSTRAP_CMT
    BOOTSTRAP_DIR
    BOOTSTRAP_LIC
    BOOTSTRAP_SRC
    CAT
    CHECKIT
    CHMOD
    CLEANER
    CODEBLOCK
    COLUMNS
    COLUMN_2
    COMMENTED
    COMPOSER
    COMPOSER_ART
    COMPOSER_BASENAME
    COMPOSER_COMPOSER
    COMPOSER_CONTENTS
    COMPOSER_CONTENTS_DIRS
    COMPOSER_CONTENTS_FILES
    COMPOSER_CSS
    COMPOSER_DEBUGIT
    COMPOSER_DEBUGIT_ALL
    COMPOSER_DEPENDS
    COMPOSER_DIR
    COMPOSER_DOCOLOR
    COMPOSER_DOITALL_check
    COMPOSER_DOITALL_clean
    COMPOSER_DOITALL_config
    COMPOSER_DOITALL__commit
    COMPOSER_DOITALL_debug
    COMPOSER_DOITALL_all
    COMPOSER_DOITALL_install
    COMPOSER_DOITALL_test
    COMPOSER_DOITALL__update
    COMPOSER_EXPORTED
    COMPOSER_EXPORTED_NOT
    COMPOSER_EXT
    COMPOSER_EXT_DEFAULT
    COMPOSER_FILENAME
    COMPOSER_FIND
    COMPOSER_FULLNAME
    COMPOSER_HEADLINE
    COMPOSER_IGNORES
    COMPOSER_INCLUDE
    COMPOSER_INCLUDES
    COMPOSER_INCLUDES_LIST
    COMPOSER_LICENSE
    COMPOSER_LOG
    COMPOSER_LOG_DEFAULT
    COMPOSER_MY_PATH
    COMPOSER_NOTHING
    COMPOSER_OPTIONS
    COMPOSER_PANDOC
    COMPOSER_PKG
    COMPOSER_REGEX
    COMPOSER_REGEX_DEFINE
    COMPOSER_REGEX_EVAL
    COMPOSER_REGEX_OVERRIDE
    COMPOSER_REGEX_PREFIX
    COMPOSER_RELEASE
    COMPOSER_RESERVED
    COMPOSER_RESERVED_SPECIAL
    COMPOSER_RESERVED_SPECIAL_TARGETS
    COMPOSER_ROOT
    COMPOSER_SETTINGS
    COMPOSER_SRC
    COMPOSER_SUBDIRS
    COMPOSER_TAGLINE
    COMPOSER_TARGETS
    COMPOSER_TEACHER
    COMPOSER_TECHNAME
    COMPOSER_TIMESTAMP
    COMPOSER_TMP
    COMPOSER_VERSION
    CONFIGS
    CONVICT
    COREUTILS_VER
    CP
    CREATOR
    CSS_ALT
    DATE
    DATEMARK
    DATENAME
    DATESTAMP
    DEBUGIT
    DEPTH_DEFAULT
    DEPTH_MAX
    DESC_DOCX
    DESC_EPUB
    DESC_HTML
    DESC_LINT
    DESC_LPDF
    DESC_PPTX
    DESC_PRES
    DESC_TEXT
    DIFF
    DIFFUTILS_VER
    DISTRIB
    DIST_ICON_v1.0
    DIST_SCREENSHOT_v1.0
    DIST_SCREENSHOT_v3.0
    DIVIDE
    DOFORCE
    DOITALL
    DOMAKE
    DO_BOOK
    DO_HEREDOC
    DO_PAGE
    DO_POST
    ECHO
    ENDOLINE
    ENV
    EXAMPLE
    EXPR
    EXTENSION
    EXTN_DEFAULT
    EXTN_DOCX
    EXTN_EPUB
    EXTN_HTML
    EXTN_LINT
    EXTN_LPDF
    EXTN_PPTX
    EXTN_PRES
    EXTN_TEXT
    FIND
    FINDUTILS_VER
    GIT
    GIT_OPTS_CONVICT
    GIT_REPO
    GIT_REPO_DO
    GIT_RUN
    GIT_RUN_COMPOSER
    GIT_VER
    GZIP_BIN
    GZIP_VER
    HEAD
    HEADERS
    HEADER_L
    HEAD_MAIN
    HELPOUT
    HEREDOC_GITATTRIBUTES
    HEREDOC_GITIGNORE
    HEREDOC_LICENSE
    HEREDOC_REVEALJS_CSS
    HEREDOC_TEX_PDF_TEMPLATE
    HEREDOC_docs_.composer.mk
    INPUT
    INSTALL
    LESS_BIN
    LESS_VER
    LINERULE
    LISTING
    LN
    LS
    MAKEFILE
    MAKEFILE_LIST
    MAKEFLAGS
    MAKEJOBS
    MAKEJOBS_DEFAULT
    MAKEJOBS_OPTS
    MAKE_DB
    MAKE_OPTIONS
    MAKE_VER
    MARKER
    MDVIEWER_CMT
    MDVIEWER_CSS
    MDVIEWER_CSS_ALT
    MDVIEWER_DIR
    MDVIEWER_LIC
    MDVIEWER_SRC
    MKDIR
    MV
    NEWLINE
    NOTHING
    NOTHING_IGNORES
    NULL
    OS_TYPE
    OS_UNAME
    OUTPUT
    OUTPUT_FILENAME
    OUT_LICENSE
    OUT_MANUAL
    OUT_README
    PANDOC
    PANDOC_BIN
    PANDOC_CMT
    PANDOC_CMT_DISPLAY
    PANDOC_DIR
    PANDOC_EXTENSIONS
    PANDOC_LIC
    PANDOC_LNX_BIN
    PANDOC_LNX_DST
    PANDOC_LNX_SRC
    PANDOC_MAC_BIN
    PANDOC_MAC_DST
    PANDOC_MAC_SRC
    PANDOC_OPTIONS
    PANDOC_OPTIONS_DATA
    PANDOC_OPTIONS_ERROR
    PANDOC_SRC
    PANDOC_TEX_PDF
    PANDOC_URL
    PANDOC_VER
    PANDOC_WIN_BIN
    PANDOC_WIN_DST
    PANDOC_WIN_SRC
    PATH_LIST
    PRINT
    PRINTER
    PRINTF
    PUBLISH
    READ_ALIASES
    REALMAKE
    REALPATH
    REVEALJS_CMT
    REVEALJS_CSS
    REVEALJS_CSS_THEME
    REVEALJS_DIR
    REVEALJS_LIC
    REVEALJS_LOGO
    REVEALJS_SRC
    RM
    RSYNC
    RSYNC_VER
    RUNMAKE
    SED
    SED_VER
    SHELL
    SORT
    SOURCE_INCLUDES
    SPECIAL_VAL
    SUBDIRS
    TABLE_C2
    TABLE_M2
    TABLE_M3
    TAIL
    TAR
    TARGETS
    TAR_VER
    TEE
    TESTING
    TESTING_COMPOSER_DIR
    TESTING_COMPOSER_MAKEFILE
    TESTING_DIR
    TESTING_ENV
    TESTING_LOGFILE
    TEX_PDF
    TEX_PDF_TEMPLATE
    TEX_PDF_VER
    TITLE_LN
    TMPL_DOCX
    TMPL_EPUB
    TMPL_HTML
    TMPL_LINT
    TMPL_LPDF
    TMPL_PPTX
    TMPL_PRES
    TMPL_TEXT
    TOKEN
    TR
    TRUE
    TYPE_DEFAULT
    TYPE_DOCX
    TYPE_DO_BOOK
    TYPE_DO_PAGE
    TYPE_DO_POST
    TYPE_EPUB
    TYPE_HTML
    TYPE_LINT
    TYPE_LPDF
    TYPE_PPTX
    TYPE_PRES
    TYPE_TARGETS
    TYPE_TEXT
    UNAME
    UPGRADE
    VIM_FOLDING
    VIM_OPTIONS
    WC
    WGET
    WGET_PACKAGE
    WGET_PACKAGE_DO
    WGET_VER
    XARGS
    YQ
    YQ_BIN
    YQ_CMT
    YQ_CMT_DISPLAY
    YQ_DIR
    YQ_LIC
    YQ_LNX_BIN
    YQ_LNX_DST
    YQ_LNX_SRC
    YQ_MAC_BIN
    YQ_MAC_DST
    YQ_MAC_SRC
    YQ_SRC
    YQ_URL
    YQ_VER
    YQ_WIN_BIN
    YQ_WIN_DST
    YQ_WIN_SRC
    c_base
    c_css
    c_css_select
    c_lang
    c_level
    c_list
    c_margin
    c_margin_bottom
    c_margin_left
    c_margin_right
    c_margin_top
    c_options
    c_toc
    c_type
    template-print
    template-var
    template-var-static
    headers
    headers-dir
    headers-file
    headers-list
    headers-note
    headers-release
    headers-rm
    headers-run
    headers-skip
    headers-vars
    headers-compose
    headers-subdirs
    help-force-targets-FORMAT
    help-force-targets-SECTIONS
    help-force-targets-TITLES
    help-all-CUSTOM
    help-all-DEPENDS
    help-all-FORMAT
    help-all-GOALS
    help-all-LINKS
    help-all-LINKS_EXT
    help-all-ORDERS
    help-all-OVERVIEW
    help-all-REQUIRE
    help-all-REQUIRE_POST
    help-all-SECTION
    help-all-SETTINGS
    help-all-TARGETS_ADDITIONAL
    help-all-TARGETS_INTERNAL
    help-all-TARGETS_PRIMARY
    help-all-TARGETS_SPECIALS
    help-all-TITLE
    help-all-VARIABLES_CONTROL
    help-all-VARIABLES_FORMAT
    help-all-VERSIONS
    help-all-WORKFLOW
    install-Makefile
    subdirs-template
    targets-list
    test-COMPOSER_INCLUDE-done
    test-COMPOSER_INCLUDE-init
    test-count
    test-done
    test-fail
    test-find
    test-hold
    test-init
    test-load
    test-log
    test-make
    test-mark
    test-pwd
    test-run
    test-speed-init
    test-speed-init-load
    test-headers
    _C
    _D
    _E
    _F
    _H
    _M
    _N
    _S

--------------------------------------------------------------------------------

*Happy Making!*
