# -*- coding: utf-8 -*-

import sys, re, nltk

class Tokenizer:
	class myPLV(nltk.tokenize.punkt.PunktLanguageVars):
		re_boundary_realignment = re.compile(ur'["”\'’)\]}]+?(?:\s+|(?=--)|$)', re.MULTILINE)
		_re_word_start = ur"[^\(\"“\`{\[:;&\#\*@\)}\]\-,]"
		_re_non_word_chars = ur"(?:[?!)\"“”;}\]\*:@\'‘’\({\[])"

	pst = nltk.tokenize.punkt.PunktSentenceTokenizer(lang_vars = myPLV())

	@classmethod
	def tokenize(cls, text):
		return cls.pst.tokenize(text, realign_boundaries=True)

text = sys.stdin.read()
sents = Tokenizer.tokenize(text)
for s in sents:
	print s
