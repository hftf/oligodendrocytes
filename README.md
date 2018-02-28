oligodendrocytes
================

Ophir's Library Implementing GOogle DocumENt Downloader to Re-Organize and Convert Yesterday's Tournament, Etc. into Standard formats

---

### Instructions

Will likely be superseded by a script (see `compile.sh`)

#### Add a tournament

1. Create the folder <code>tournaments/_name_/</code>.
2. Create the file <code>tournaments/_name_/settings.pxml</code>.
3. Create the file <code>tournaments/_name_/order.txt</code>.
4. Replace the contents of `tournaments/current.txt` with <code>_name_</code>.

#### Build

1. Run `make meta` to generate these files:
  * <code>tournaments/_name_/settings.xml</code>
  * <code>tournaments/_name_/vars.mk</code>
  * <code>tournaments/_name_/defs.mk</code>
  * <code>tournaments/_name_/metadata.xsl</code>
  * <code>tournaments/metadata.xsl</code>
2. Run `make reset` to download the packets from Google Docs (requires `skicka`).
  * Or, place `.docx` files in <code>tournaments/_name_/packets/</code>.
3. Run `make htmls` to generate the web interface for each packet.
  * Or <code>make formats EXT=_format_</code>, where <code>_format_</code> can be:
    * `md`, `md.nowrap`, `txt`, etc.
