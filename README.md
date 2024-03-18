oligodendrocytes
================

Ophir's Library Implementing GOogle DocumENt Downloader to Re-Organize and Convert Yesterday's Tournament, Etc. into Standard formats

## Instructions (how to)

Will hopefully be superseded by a script soon (see `compile.sh`)

### Install dependencies

1. See reqs.md for details.

### Add a tournament

1. Create the folder <code>tournaments/_name_/</code>.
2. Create the file <code>tournaments/_name_/settings.pxml</code>.
   * See <code>tournaments/sample/settings.pxml</code> for an example.
3. Replace the contents of `tournaments/current.txt` with <code>_name_</code>.
4. Run `make meta` to generate these files:
   * <code>tournaments/_name_/settings.xml</code>
   * <code>tournaments/_name_/vars.mk</code>

### Build the tournament

1. Run `make reset` to download the packets from Google Docs (requires `drive`).
   * Or, place `.docx` files in <code>tournaments/_name_/packets/</code>.
   * Due to recent changes on Google's end, `drive` no longer works.
2. Run `make htmls` to generate the web interface for each packet.
   * Or <code>make formats EXT=_format_</code>, where <code>_format_</code> can be:
     * `md`, `md.nowrap`, `txt`, `o.html`, `f.html`, `r.html`, `w.html`, `a.html`, etc.
   * Or run in parallel: `make -j4 most; make formats EXT=r.html; make htmls`.
3. To check for problems, run `make check`, `make check2`, and `make check3`.
   * If there are problems, revise and return to step 2.
   * Run `make checkcats` for a category balance report to find feng shui issues.
   * Run `make checkrevealed` to find potential answers revealed in question text.

### Deploy the tournament

1. Run `make answers` to extract the question metadata from the packets.
   * Copy the question metadata from <code>tournaments/_name_/packets/\*.answers</code>.
   * Paste the question metadata into the data spreadsheet.
2. Run `make words` to extract the word count metadata from the packets. Or:
   * In your browser, open each `.w.html` file with `?q` appended to the URL.
   * Copy the word count metadata from the pop-up prompts and concatenate.
   * Paste the word count metadata into the data spreadsheet.
3. Run `make zips` to create the zips of the original packets for use as a backup.
   * Obsolete and untested.
4. Run `make bundle` to compile the packets and assets into a bundle.
   * Note: `fonts.css` is not included.
5. Run `make upload` to upload a bundle to a web server.

## Project status

This project is a janky pile of scripts in many programming languages
hacked together incrementally over many years intended for personal use.
It makes many hardcoded assumptions about the computing environment (e.g. Mac OS, Python 2)
and about the formatting of quizbowl packets.
It is not polished, robust, or well-documented.

Using it may require advanced technical knowledge, familiarity with a command line, or debugging skills.
Use at your own risk. Please do not wait until the last minute to test it or to seek help.

### Project history

This project is a palimpsest.

It arose out of two primordial projects of mine
for representing and rendering quizbowl packets:
an XML/XSLT-based schema called QBML (May 2008)
and a LaTeX class called packet.cls (March 2013).

In February 2014, I hitched up a program
to fetch Docx packets from Google Docs
and pass them through a pipeline of formats –
HTML, QBML (XML), LaTeX – to produce nicely typeset PDFs.

I tried attaching a tooltip to each word of a tossup
to display its word number (in the final PDFs)
in my second attempt to enable the collection of buzz location data,
after a bare first prototype in HTML/JS (February 2012).

This misguided elaborate approach,
using `xsl:analyze-string` to [tokenize mixed content in XSLT]
(https://stackoverflow.com/questions/36354299/tokenize-mixed-content-in-xslt)
and produce intermediate "WQBML",
failed not only due to differences in PDF viewer abilities,
but because I was more worried about [restoring kerning]
(https://tex.stackexchange.com/questions/164158/restore-kerning-across-empty-groups).

Growing bored of typography-for-its-own-sake,
and annoyed at folly for not solving an actual problem well,
making it pretty, fiddling, isn't the job.

enjoy writing questions for practice and vanity in Markdown

Shift strategy
Oct 2015 abandon PDF, quite elegant incredibly simple client-side script (number.js) to do the valued work; build pipeline

approach Modern form
To overcome browser incompatibility,
(even simple!) was replaced with pre-computed
Oct 2017

rudimentary linter to check style and formatting, pronunciation guides

xml tex - too strict. docx > html > tweak w scripts gives flexibility at expense of strict error guarding


i do think some improvements to improve readability and typography, but very low priority. not paged document

note that docx conversion (pandoc) is lossy/philosophically opinionated by intent/structural.
textutil (Mac only) basically preserves everything in the docx but is not necessarily semantic

docx 

flow.tikz diagram here

> transformers
> SOURCE_EXT docx default
> chamfered = dependency of make check

O=original
F=formatted, wraps with a template with a header and footer
R=ruby, parses finds PGs (pronunciation guides) and converts to ruby
W=words adds tags around each word in tossups

## License

This project is currently not freely licensed (although you may inspect the source code).
Contact me for information about licensing.
