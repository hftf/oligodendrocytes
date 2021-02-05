#!/usr/bin/python
# -*- coding: utf-8 -*-

from HTMLParser import HTMLParser
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
# “I”   as orthographic (1 word),   NBSP  in phonetic (1 word):  	 Edward I (“the first”), Guigues IV (“GEEG the fourth”), Renaud-Barrault (“ruh-NO bah-RO”)

# Further documentation: https://minkowski.space/quizbowl/pronouncing-dictionary/writing-pgs.html#special

SPACES = u'[  –‒]+'

class UnbalancedError(Exception):
	pass

# TODO power marks (*)
# TODO handle 'foo</b> bar'

class LastNParser(HTMLParser):
	def __init__(self, contents):
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

	# parser = LastNParser('One morning, when <i>Gregor Samsa</i>')
	test = u'Luis Buñuel, <i>L’Âge d’Or</i> (“lodge dor”). For 10'
	test = u'power after overcoming Xiàng Yǔ’s</b> <span class="s2"><b>[shyong yoo’s]</b></span> <b>state of (*)</b> Chu.'
	tests = [
		u'-1 0 1</i> 2</b>',
		u'-1 0 1</b> 2',
		u'-1 0</b> 1 2',
		u'-1 0 <b>1 2',
		u'ANSWER: <span class="s1"><b><i>Laocoön</i></b></span> <i>word',
		u'ANSWER: <span class="s1"><b><i>Laocoön</i></b></span> <i>'
	]
	for test in tests:
		parser = LastNParser(test)
		for i in range(3):
			x,y,z = parser.last_n_words(i)
			print
			print i, colorCmd + x + resetCmd
			print i, ' '*len(x) + colorCmd + y + resetCmd
			print i, ' '*len(x+y) + colorCmd + z + resetCmd
