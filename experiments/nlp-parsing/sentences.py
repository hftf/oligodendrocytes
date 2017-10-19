# -*- coding: utf-8 -*-
import glob
import lxml.etree as et
import nltk # overhead ~ 0.4 sec
import re
import pprint

class Sentence:
	def __init__(self, i, text):
		self.i = i
		self.text = text
		self.len = len(text)
		words = text.split(' ')
		self.abbr = ' '.join(words[:3] + ['...'] + words[-3:] if len(words) > 7 else words)
		self.finals = re.findall('[^ ]+[.?!][^ ]*', text)

	def __repr__(self):
		return self.__unicode__().encode('utf-8')

	def __unicode__(self):
		return '<' + str(self.len) + '\t' + str(len(self.finals)) + ': ' + unicode(self.finals) + '>\n' + self.text + '\n'

class Tossup:
	def __init__(self, i, text):
		# print i, text
		self.i = i
		self.text = text
		sentences = Tokenizer.tokenize(text)
		# self.sentences = [Sentence(j, text) for j, text in enumerate(sentences)]
		# print i, '\033[101m \033[0m'.join(sentences)

	def __repr__(self):
		return self.__unicode__()

	def __unicode__(self):
		return '<Tossup ' + str(self.i) + ': ' + \
			str(len(self.sentences)) + ' sentences\n' + \
			"\n".join([unicode(i).encode('utf-8') for i in self.sentences]) + '>'

class Tokenizer:
	class myPLV(nltk.tokenize.punkt.PunktLanguageVars):
		re_boundary_realignment = re.compile(ur'["”\'’)\]}]+?(?:\s+|(?=--)|$)', re.MULTILINE)
		_re_word_start = ur"[^\(\"“\`{\[:;&\#\*@\)}\]\-,]"
		_re_non_word_chars = ur"(?:[?!)\"“”;}\]\*:@\'‘’\({\[])"

	pst = nltk.tokenize.punkt.PunktSentenceTokenizer(lang_vars = myPLV())

	@classmethod
	def tokenize(cls, text):
		return cls.pst.tokenize(text, realign_boundaries=True)


# qbmls = glob.glob('tournaments/speedchecks/packets/05.qbml')
qbmls = glob.glob('tournaments/stimpy/packets/01.md')

d = {}
l = []
for j, qbml in enumerate(qbmls):
	# doc = et.parse(qbml)
	# tossups = [(i.attrib['id'], i.xpath('string(./question)', smart_strings=False)) for i in doc.findall('//tossup')]
	tossups = 
	d[1 + j] = {}
	for (i, text) in tossups:
		o = Tossup(i, text)
		d[1 + j][i] = o
		# l.extend(o.sentences)

# l.sort(key=lambda x: len(x.text))
# pprint.pprint(l, width=140)

texts = ' '.join([s.text for q in d.values() for s in q.values()])

pt = nltk.tokenize.punkt.PunktTrainer(train_text=texts, lang_vars=Tokenizer.myPLV(), verbose=True)
params = pt.get_params()
