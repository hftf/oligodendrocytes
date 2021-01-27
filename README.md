oligodendrocytes
================

Ophir's Library Implementing GOogle DocumENt Downloader to Re-Organize and Convert Yesterday's Tournament, Etc. into Standard formats

## Instructions (how to)

Will likely be superseded by a script (see `compile.sh`)

### Install dependencies

1. Install pandoc, pxslcc, saxon, skicka, and drive. See reqs.md for details.
qpdf, gnu coreutils? gsed brew install gnu-sed, ack, textutil (docx -> html, docx -> txt), python (unicodecsv, lxml, unidecode, slugify, python-levenshtein), node.js (fibrio: npm install)

### Add a tournament

1. Create the folder <code>tournaments/_name_/</code>.
2. Create the file <code>tournaments/_name_/settings.pxml</code>.
   * See <code>tournaments/sample/settings.pxml</code> for an example.
3. Replace the contents of `tournaments/current.txt` with <code>_name_</code>.
4. Run `make meta` to generate these files:
   * <code>tournaments/_name_/settings.xml</code>
   * <code>tournaments/_name_/vars.mk</code>

### Build the tournament

1. Run `make reset` to download the packets from Google Docs (requires `skicka`).
   * Or, place `.docx` files in <code>tournaments/_name_/packets/</code>.
2. Run `make htmls` to generate the web interface for each packet.
   * Or <code>make formats EXT=_format_</code>, where <code>_format_</code> can be:
     * `md`, `md.nowrap`, `txt`, etc.
   * Or run in parallel: `make -j4 most; make formats EXT=r.html; make htmls`.
3. Run `make check` and `make check2` to check for problems.
   If there are problems, revise and return to step 1.

### Deploy the tournament

1. Run `make answers` to extract the question metadata from the packets.
   * Copy the question metadata from <code>tournaments/_name_/packets/\*.answers</code>.
   * Paste the question metadata into the data spreadsheet.
2. Run `make words` to extract the word count metadata from the packets. Or:
   * In your browser, open each `.w.html` file with `?q` appended to the URL.
   * Copy the word count metadata from the pop-up prompts and concatenate.
   * Paste the word count metadata into the data spreadsheet.
3. [TODO] Run `make zips` to create the zips of the packets for use as a backup.
   * for now, cd and zip
4. [TODO] Run `make bundle` to compile the packets and assets into a bundle.
   * for now, csv passwords
   * for now, cp assets, cp bundle
   * fonts css not included
5. [TODO] Run `make upload` to upload a bundle to a web server.
   * for now, scp
