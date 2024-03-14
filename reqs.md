## Requirements

### GNU coreutils, etc.
Provides modern GNU versions of common utilities, awk (gawk), sed (gsed).

You may want to alias grep to GNU grep or put it in your path higher than the old Mac built-ins.

```sh
brew install coreutils gawk gnu-sed
```

### [fibrio](https://github.com/ethantw/fibrio) (node.js module)
Server-side port of [findAndReplaceDOMText](https://github.com/padolsey/findAndReplaceDOMText).

Needed for splitting tossups into words.

```sh
npm install fibrio
```

### [Pandoc](https://github.com/jgm/pandoc/releases)
Document conversion Swiss army knife.

Needed for converting DOCX to HTML, Markdown, TXT.
Replaced obsolete `textutil` flow (Mac only) in 2022.

```sh
brew install pandoc
```

### [pxslcc](https://github.com/tmoertel/pxsl-tools)
Preprocessor for XML/XSL that provides a concise, intentation-based syntax.

Needed for settings.
Previously needed in general for obsolete XML (QBML) flow.

```sh
brew install ghc cabal-install wget
wget https://github.com/tmoertel/pxsl-tools/archive/master.zip
unzip master.zip 
cd pxsl-tools-master/
cabal install
make
cabal install
# add ~/.cabal/bin to path
```

### Python packages
```sh
pip install odictliteral
```

## Dependencies needed for checks only

### ack
Command-line tool for searching source code and text.

Running ack on UTF-8 files is not compatible as of Perl 5.30.
Need to find a replacement. Maybe ripgrep?
Need --sort=path.

```sh
brew install ack
```

### ripgrep (rg)
Slightly more modern than ack.

```sh
brew install ripgrep
```

### Python packages
```sh
pip install unidecode lemminflect
```

## Obsolete

### [drive](https://github.com/odeke-em/drive)
Command-line interface for pulling Google Drive files.

Replaced unmaintained `googlecl`, `skicka`, and `gdrive`.
Likely needs to be replaced again (probably with `rclone`)
due to recent OAuth changes on Google’s end.

```sh
go get -u github.com/odeke-em/drive/cmd/drive
```

### Saxon
Modern XSLT processor that implements XSLT 2.0 and 3.0.
(Simpler XSLT 1.0 transformers use xsltproc, a popular Mac and Linux built-in.)

Previously needed in general for obsolete XML (QBML) flow.

[Download JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

```sh
brew install saxon
```

### XeLaTeX
Modern TeX engine supporting Unicode and OpenType fonts.

Previously needed for obsolete LaTeX/PDF flow.

[Download](https://tug.org/mactex/)

### QPDF
Command-line PDF manipulator.

Previously needed for password-protecting PDF files.

```sh
brew install qpdf
```

## Experiments (abandoned)

### Python packages
```sh
pip install lxml python-levenshtein caverphone
```

### Stanford NLP parser
### Tregex
