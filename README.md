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
3. Create `tournaments/current.txt` with <code>_name_</code> as its contents.
4. Run `make meta` to generate these files:
   * <code>tournaments/_name_/settings.xml</code>
   * <code>tournaments/_name_/vars.mk</code>

### Build the tournament

1. Run `make reset` to download the packets from Google Docs (requires `drive`).
   * Or, place `.docx` files in <code>tournaments/_name_/packets/</code>.
   * Due to recent changes on Google's end, `drive` may no longer work.
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
   * Create <code>tournaments/_name_/passwords.csv</code> with header `id,password,file,name` and a row for each packet like `A,agonyclite,A.a.html,Packet A`. This is used for rudimentary server-side password protection; nothing is encrypted or obfuscated.
5. Run `make upload` to upload a bundle to a web server.
   * Important: Only upload to a location protected by a master password. For Apache servers, you can set up `.htaccess` and `.htpasswd`.

## Project status

This project is a janky pile of scripts in many programming languages
hacked together incrementally over many years intended for personal use.
It makes many hardcoded assumptions about the computing environment
(e.g. Mac OS, Python 2, command-line tools)
and about the formatting of quizbowl packets.
It is not polished, robust, or well-documented.

Using it may require advanced technical knowledge, familiarity with a command line, or debugging skills.
It is not intended for those seeking an immediate off-the-shelf, out-of-the-box, plug-and-play solution.
Use at your own risk. Please do not wait until the last minute to test it or to seek help.

### Project history

This project is a [palimpsest](https://en.wikipedia.org/wiki/Archimedes_Palimpsest).

It arose out of two primordial projects of mine
for representing and rendering quizbowl packets:
an XML/XSLT-based schema called QBML (May 2008)
and a LaTeX class called `packet.cls` (March 2013).

In February 2014, I hitched up a program
to fetch Docx packets from Google Docs
and pass them through a pipeline of formats –
HTML, QBML (XML), LaTeX – to produce nicely typeset PDFs.

I attached a tooltip to each word of a tossup
to display its word number in the final PDFs.
This was my second attempt to enable the collection of buzz location data,
after a bare first prototype in HTML/JS (February 2012).

This misguided elaborate approach,
using `xsl:analyze-string` to [tokenize mixed content in XSLT][1],
failed not only due to differences in PDF viewer abilities,
but because I was more worried about [restoring kerning][2].

[1]: https://stackoverflow.com/questions/36354299/tokenize-mixed-content-in-xslt
[2]: https://tex.stackexchange.com/questions/164158/restore-kerning-across-empty-groups

Growing bored of typography-for-its-own-sake,
and annoyed at the folly of not solving an actual problem well,
I quit fiddling around making text pretty
and instead started to enjoy writing questions for practice and vanity in plain Markdown,
which produced output like [this](https://minkowski.space/quizbowl/2016-questions.pdf).

For the next shift in strategy, I abandoned bloated PDF in favor of elegant HTML
accompanied by an incredibly simple script (`number.js`)
to do the valued word-numbering work on the client side.

To overcome browser incompatibility and wasted computation,
that script (though simple!) was soon replaced
with a build pipeline that pre-calculated clickable words (October 2017).
In parallel, I've worked on a rudimentary linter to check formatting and other issues.

For cross-platform Docx conversion, I swapped out `textutil` (Mac-only built-in) for Pandoc.
The former basically preserves everything in the Docx but is not necessarily semantic,
whereas Pandoc is structure-oriented but lossy and a bit version-unstable.

Ten years in, I'm convinced that HTML is the proper archival and machine format for quizbowl packets.
HTML is simple, flexible, forgiving, ubiquitous, and easy to parse.
A pipeline of Docx to HTML incrementally tweaked by a small suite of modular scripts
gives reasonable power and control (as intermediate files can be inspected),
while perhaps coming at the expense of strict semantic or error-guarding needs.

I do think some improvements to readability and typography are worth it,
especially when they can be incorporated in HTML,
but they have very low priority,
and I believe everything involving LaTeX and PDF is a messy waste of time for quizbowl's needs.

I probably also should have been using a virtual machine or a docker container,
but I never really expected anyone else to use this
and I still don't know how to use those.

## Pipeline diagrams
TODO

<!-- flow.tikz diagram here

> transformers
> SOURCE_EXT docx default
> chamfered = dependency of make check
-->

### Glossary of file extensions

<dl>
<dt>O
<dd>original, after Docx to HTML conversion
<dt>F
<dd>formatted, wraps packet with a header and footer
<dt>R
<dd>ruby, finds PGs (pronunciation guides) and wraps in <code>&lt;ruby></code> tags
<dt>W
<dd>words, wraps each word in tossups with <code>&lt;m></code> tag
<dt>A
<dd>annotated, parses answerline directives for fancy display
</dl>

## License

This project is currently not freely licensed (although you may inspect the source code).
Contact me for information about licensing.

There is a trade-off in that permissive licensing
helps prevent inefficient reinventing of the wheel,
but doesn't necessarily lead to any progress in the tech.
Thus it may be prudent to encourage people to make something better
rather than merely rely on previous makeshift work.

## Name

This project's name is a contrived backronym –
a word chosen for its fitting letters and not for a relevant meaning –
ever the popular trope.
But, if biologists are interested in an anatomical analogy, then here is a folk etymology:

As far as I understand, [oligodendrocytes](https://en.wikipedia.org/wiki/Oligodendrocyte) are cells
that support the axons of neurons in the central nervous system.
They have a nucleus with a few protuberances radiating outwards.
You may imagine this shape as representing a central
[single source of truth](https://en.wikipedia.org/wiki/Single_source_of_truth) document
with branches for converting into different formats.
