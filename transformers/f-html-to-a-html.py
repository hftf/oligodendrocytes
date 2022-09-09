#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import re
import io
from unidecode import unidecode
from collections import OrderedDict
import pprint

import codecs
sys.stdout = codecs.getwriter('utf8')(sys.stdout)
sys.stderr = codecs.getwriter('utf8')(sys.stderr)

# this code currently requires md.nowrap input
filename_in = sys.argv[1]
filename_out = filename_in.replace('.f.', '.a.')

with io.open(filename_in, 'r', encoding='utf-8') as file_in:
	contents = file_in.read()
	sys.stderr.write('\n\n' + filename_in + '\n\n')

zz=1
ruby_tag_color = '\033[107m'*zz
contents_color = '\033[102;4m'*zz
bracket_color  = '\033[103;4m'*zz
space_color    = '\033[103;4m'*zz
reset_color    = '\033[0m'*zz

fake_contents = u'''--
'''
	# AND, OR
	# accept either underlined name. accept in either order
	# or:
	# 	..., equivalents, other answers, alternative names
	# accept, but do not reveal:
	# prompt on:
	# in place of "", accept:
	# until "" is read, accept:
	# after "" is read, accept:
	# reject (do not accept):
	# by asking:
	# but accept after
	# accept drugs or medication for treating seizures or epilepsy]
	# need to deal with ', etc.'

	# TODO PG should not be parsed as note; see Harari
	# TODO allow nbsp to prevent splitting on "or" or ","
	# [equivalents] such as
	# fix serial comma "X, Y, or Z" -> [X, Y, "or Z"]

	# click on which answer was given by team
	# extra button to click on for discretionary accepts/prompts

	# PG <u>Rijksmuseum</u> (“rikes-museum”)
	# <u>grass</u> \[prompt on <u>leaf</u>, <u>leaves</u>, <u>sprout</u>s, or <u>spear</u>s\]
	# <u>OSIRIS-REx</u> \[or the <u>Origins, Spectral Interpretation, Resource Identification, Security, Regolith Explorer</u> spacecraft\]

	# warn if a directive doesn't have a bold, underline, or quotation marks

	# until/after X is read: on hover, highlight part of question text

OR_p = 'or '
ACCEPT_p = 'accept '
PROMPT_p = 'prompt on '
REJECT_p = 'do not accept or prompt on '
REJECT2_p = 'reject '


# ANSWERLINE = '<p class="p1 answer">ANSWER: (.+?)</p>'
ANSWERLINE = '(?<=^ANSWER: )(.+?)(?=$)'
ANSWERLINE3 = r'^(?P<canonical>.+?)(?: \\?\[(?P<brackets>(?:[^\\\]]|\\[^\]])+)\\?\])?(?: \((?P<note>(?!“).+?)\))?$'

def mysub(match):
	answerline = match.group(0)
	# answerline = answerline.replace('*','')
	answerline = re.sub(r'\*\*(.+?)\*\*', '\033[4m\\1\033[24m', answerline)
	answerline = re.sub(r'\*(.+?)\*', '\033[3m\\1\033[23m', answerline)

	answer_clauses = OrderedDict()
	for k in ['canonical','or','accept','prompt','reject','note']:
		answer_clauses.setdefault(k, [])

	print
	print ruby_tag_color + answerline + reset_color

	m3 = re.match(ANSWERLINE3, answerline)
	if not m3:
		raise Exception('Failed to match answerline using regex ANSWERLINE3')

	canonical, brackets, note = m3.groups()

	answer_clauses['canonical'] = canonical
	if brackets:
		brackets_split = re.split(r'; ', brackets)
		for clause in brackets_split:
			# print clause
			if   clause.startswith(OR_p):
				answer_clauses['or']     += ( split_or_comma(clause[len(OR_p):]) )
			elif clause.startswith(ACCEPT_p):
				answer_clauses['accept'] += ( split_or_comma(clause[len(ACCEPT_p):]) )
				# accept either
			elif clause.startswith(PROMPT_p):
				answer_clauses['prompt'] += ( split_or_comma(clause[len(PROMPT_p):]) )
			elif clause.startswith(REJECT_p):
				answer_clauses['reject'] += ( split_or_comma(clause[len(REJECT_p):]) )
			elif clause.startswith(REJECT2_p):
				answer_clauses['reject'] += ( split_or_comma(clause[len(REJECT2_p):]) )

			# but DO NOT REVEAL
			# until, before, after
			#    until read vs. until "" is read
			# by asking (saying)

			# if any in result of split_or_comma is '' or contains one of the prefixes
	if note:
		answer_clauses['note'] = note

	i = 0
	for k in answer_clauses:
		k_clauses = answer_clauses[k]
		if not isinstance(k_clauses, list): k_clauses = [k_clauses]

		for c in k_clauses:
			i += 1
			# print '%2d. %-12s %s' % (i, k, c)
			print ' %-12s %s' % ( k, c)
	return 'foo'

def split_or_comma(text):
	# false positive: "accept sine of x, with any letter in place of x, such as theta"
	# should serial "or" be required?
	return re.split(', or |, | or ', text)

def html_fancy_answerline(contents):
	return re.sub(ANSWERLINE, mysub, contents, flags=re.M)

	instances = re.finditer(ANSWERLINE, contents)
	lastMatch = 0
	formattedText = ''

	for match in instances:
		start, end = match.span()

		prev = contents[lastMatch : start]
		main = contents[start : end]
		print main

		# ss = match.group('ss')
		# sb = match.group('sb')
		# b  = match.group('m')
		# eb = match.group('eb')
		# es = match.group('es')

		last_newline_pos = prev.rfind('\n') + 1
		prev1 = prev[:last_newline_pos]
		prev2 = prev[last_newline_pos:]
		# prev2a, a, closing_tags = real_a = LastNParser(prev2).last_n_words(b_word_count)
		# print [prev2, b_word_count]
		# print [prev2a, a, closing_tags]

		# ap = ' '*(41-len(a))
		# bp = ' '*(41-len(b))
		# def h(a):
		# 	return a
		# ruby_tuples = [
		# 	(             '' , h('<ruby>')       ),
		# 	( ruby_tag_color , h('<rb>')         ),
		# 	( contents_color , a              ),
		# 	( ruby_tag_color , h('</rb>')        ),
		# 	( reset_color+ap , ''             ),
		# 	( ruby_tag_color , h('<rp>')         ),
		# 	(    space_color , ss             ),
		# 	(  bracket_color , sb             ),
		# 	( ruby_tag_color , h('</rp><rt>')    ),
		# 	( contents_color , b              ),
		# 	( ruby_tag_color , h('</rt><rp>')    ),
		# 	(  bracket_color , eb             ),
		# 	( ruby_tag_color , h('</rp>')        ),
		# 	( reset_color+bp , h('</ruby>')      ),
		# 	(  bracket_color , closing_tags   ),
		# 	(    space_color , es             ),
		# 	(    reset_color , ''             ),
		# ]
		# ruby_str       = ''.join([txt     for clr,txt in ruby_tuples])
		# ruby_str_color = ''.join([clr+txt for clr,txt in ruby_tuples])

		# formattedText += (
		# 	prev1 +
		# 	prev2a +
		# 	ruby_str
		# )
		# sys.stderr.write(ruby_str_color + "\n")

		lastMatch = end
	formattedText += contents[lastMatch:]
	return formattedText

fake = False
if fake:
	out = html_fancy_answerline(fake_contents)
else:
	out = html_fancy_answerline(contents)
# sys.stdout.write(out)
