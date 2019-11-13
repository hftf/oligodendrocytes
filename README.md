oligodendrocytes
================

Ophir's Library Implementing GOogle DocumENt Downloader to Re-Organize and Convert Yesterday's Tournament, Etc. into Standard formats

---

## Instructions (how to)

Will likely be superseded by a script (see `compile.sh`)

### Add a tournament

1. Create the folder <code>tournaments/_name_/</code>.
2. Create the file <code>tournaments/_name_/settings.pxml</code>.
   * See <code>tournaments/sample/settings.pxml</code> for an example.
3. Replace the contents of `tournaments/current.txt` with <code>_name_</code>.

### Build the tournament

1. Run `make meta` to generate these files:
  * <code>tournaments/_name_/settings.xml</code>
  * <code>tournaments/_name_/vars.mk</code>
2. Run `make reset` to download the packets from Google Docs (requires `skicka`).
  * Or, place `.docx` files in <code>tournaments/_name_/packets/</code>.
3. Run `make htmls` to generate the web interface for each packet.
  * Or <code>make formats EXT=_format_</code>, where <code>_format_</code> can be:
    * `md`, `md.nowrap`, `txt`, etc.
  * Or run in parallel: `make -j4 most; make formats EXT=r.html; make htmls`.
4. [TODO] Run `make check` to check for problems.
   If there are problems, revise and return to step 2.
5. [TODO] Run `make answers` to extract the question metadata from the packets.
	* In your browser, open each `.w.html` file with `?q` appended to the URL.
  * Copy the word count metadata from the pop-up prompt.
  * Paste both the question and word count metadata into the data spreadsheet.
6. [TODO] Run `make bundle` to compile the packets and assets into a bundle.
7. [TODO] Run `make zips` to create the zips of the packets for use as a backup.
8. [TODO] Run `make upload` to upload a bundle to a web server.
