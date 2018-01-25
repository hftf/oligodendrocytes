#!/usr/bin/python
# -*- coding: utf-8 -*-

from HTMLParser import HTMLParser
import re

# TODO not sure if we should treat nbsp as same word, just like we do inside the PG
SPACES = u'[  ]+'

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
		return (self.contents[:x], self.contents[x:y], self.contents[y:])

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
					done = ls[i + 1][1]
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
	parser = LastNParser(test)
	for i in range(10):
		x,y,z = parser.last_n_words(i)
		print
		print i, colorCmd + x + resetCmd
		print i, ' '*len(x) + colorCmd + y + resetCmd
		print i, ' '*len(x+y) + colorCmd + z + resetCmd
