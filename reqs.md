### ack

Running ack on UTF-8 files is not compatible as of Perl 5.30.
Need to find a replacement. Maybe ripgrep?
Need --sort=path.

### Pandoc
[Download](https://github.com/jgm/pandoc/releases)

### pxslcc

```
brew install ghc cabal-install wget
wget https://github.com/tmoertel/pxsl-tools/archive/master.zip
unzip master.zip 
cd pxsl-tools-master/
cabal install
make
cabal install
# add ~/.cabal/bin to path
```

### Saxon
[Download JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

```
brew install saxon
```

### drive

```
go get -u github.com/odeke-em/drive/cmd/drive
```

### XeLaTeX
[Download](https://tug.org/mactex/)

### Stanford NLP parser
### Tregex
