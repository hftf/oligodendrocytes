#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from html.parser import HTMLParser
import re

# Character 	Treatment outside PG (orthographic)     	Treatment inside PG (phonetic)
#           	(SPACES, below)                         	(SPACES_NONBSP)

# SPACE ( ) 	separate word                           	separate word
# NDASH (–) 	separate word                           	same word
# NBSP  ( ) 	separate word, kept together visually   	same word
# NNBSP ( ) 	same word,     kept together visually   	same word

# This means that if you want to extract PGs, just counting the number of SPACEs in each
# is insufficient. SPACE, NDASH, and NBSP are used as word separators in running text.

# Examples:

# SPACE in orthographic (2 words),  SPACE in phonetic (2 words): 	 St. John (“SIN jun”)
# NBSP  in orthographic (2 words),  SPACE in phonetic (2 words): 	 St. John (“SIN jun”), Eamon de Valera (“EH-min deh vuh-LEH-ruh”)
# NNBSP in orthographic (1 word) ,  HYPH  in phonetic (1 word):  	 St. John (“SIN-jun”), Beaux Arts (“boh-ZARR”)
# NDASH in orthographic (2 words),  SPACE in phonetic (2 words): 	 Foo–Barr (“foo bar”)
# “I”   as orthographic (1 word) ,  NBSP  in phonetic (1 word):  	 Edward I (“the first”), Guigues IV (“GEEG the fourth”), Renaud-Barrault (“ruh-NO bah-RO”)

# Further documentation: https://minkowski.space/quizbowl/pronouncing-dictionary/writing-pgs.html#special

SPACES = u'[  –‒]+'

class UnbalancedError(Exception):
	pass

# TODO power marks (*)
# TODO handle 'foo</b> bar'

class LastNParser(HTMLParser):
	def __init__(self, contents):
		super().__init__(convert_charrefs=False)

		self.contents = contents
		self.end = len(contents)
		self.ls = []
		self.reset()
		self.feed(contents)

	def handle_starttag(self, tag, attrs):
		self.ls.append(('start', self.getpos()[1], tag, attrs ))

	def handle_endtag(self, tag):
		self.ls.append(('end',   self.getpos()[1], tag        ))

	def handle_data(self, data):
		self.ls.append(('data',  self.getpos()[1], data       ))

	def last_n_words(self, n):
		(x, y) = self.start_pos_of_nth_last_word(n)
		last_n_words = (self.contents[:x], self.contents[x:y], self.contents[y:])
		return last_n_words

	def start_pos_of_nth_last_word(self, n):
		ls = self.ls
		count = 0
		stack = [(self.end, '')]
		done  = False

		if n == 0:
			done = self.end

		for i, token in reversed(list(enumerate(ls))):
			if done:
				break

			if token[0] == 'end':
				stack.append(token[1:3])

			elif token[0] == 'start':
				if len(stack) == 1:
					# raise UnbalancedError(token[2], self.contents)
					# TODO deal with string that ends with start tag
					try:
						done = ls[i + 1][1]
					except IndexError:
						done = ''
					break
				elif stack[-1][1] == token[2]:
					stack.pop()
				else:
					raise UnbalancedError(token[2], self.contents)

			elif token[0] == 'data':
				# TODO need unicode flag?
				fi = re.finditer(SPACES, token[2])
				for matched_space in reversed(list(fi)):
					count += 1

					if count >= n:
						done = token[1] + matched_space.end()
						break

		if not done:
			done = 0

		return (done, stack[-1][0])

if 1 and __name__ == '__main__':
	zz=1
	colorCmd = '\033[107;4m'*zz
	resetCmd = '\033[0m'*zz

	tests = {
		u'One morning, when <i>Gregor Samsa</i>': (5, [0, 4, 13, 18, 28]),
		u'Luis Buñuel, <i>L’Âge d’Or</i> (“lodge dor”). For 10': (8, [0, 5, 13, 22, 31, 39, 46, 50]),
		u'power after overcoming Xiàng Yǔ’s</b> <span class="s2"><b>[shyong yoo’s]</b></span> <b>state of (*)</b> Chu.': (11, [0, 6, 12, 23, 29, 38, 66, 84, 93, 96, 104]),
		u'-1 0 1</i> 2</b>': (4, [0, 3, 5, 11]),
		u'-1 0 1</b> 2': (4, [0, 3, 5, 11]),
		u'-1 0</b> 1 2': (4, [0, 3, 9, 11]),
		u'-1 0 <b>1 2':  (4, [8, 8, 8, 10]),
		u'ANSWER: <span class="s1"><b><i>Laocoön</i></b></span> <i>word': (3, [57, 57, 57]),
		u'ANSWER: <span class="s1"><b><i>Laocoön</i></b></span> <i>': (3, [0, 0, 0]),
		u'Basin &amp; Range Niue (“n’YOO-ay”)': (5, [0, 6, 12, 18, 23]),
		u'foo &amp; bar &amp; baz': (5, [0, 4, 10, 14, 20]),
		u'I– (“I-minus”) with en-dash': (5, [0, 0, 3, 15, 20]),
		u'I− (“I-minus”) with minus symbol': (4, [0, 3, 15, 20, 26]),
		u'<p class="answer">ANSWER: <i>L’<b><u>Enfant</u></b></i>': (2, [18, 26]),
		u'foo of <i>bar</i> (“baz”)': (4, [0, 4, 7, 18]),
		u'<p>ANSWER: <strong><u>foo</u></strong> <strong><u>bar</u></strong>': (3, [3, 11, 39]),
		u'life of Foo (*)</b> Bar': (5, [0, 5, 8, 12, 20]),
	}
	for test, expected in tests.items():
		parser = LastNParser(test)
		poses = expected[1] + [len(test)]
		for i in range(expected[0] + 1):
			x,y,z = parser.last_n_words(i)
			print()
			print(i, colorCmd + x + resetCmd)
			print(i, ' '*len(x) + colorCmd + y + resetCmd)
			print(i, ' '*len(x+y) + colorCmd + z + resetCmd)

			pos = poses[-1 - i]

			same = test[pos:] == y+z
			try:
				assert same
			except AssertionError as error:
				print(same, pos, f'"{test[pos:]}"', f'"{y+z}"')
				raise error
			
