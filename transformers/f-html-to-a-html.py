#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import re
import io
from unidecode import unidecode
from collections import OrderedDict
from odictliteral import odict
import pprint

import codecs
sys.stdout.reconfigure(encoding='utf8')
sys.stderr.reconfigure(encoding='utf8')

# this code currently requires md.nowrap input

fake = False
try:
	filename_in = sys.argv[1]
	filename_out = filename_in.replace('.f.', '.a.')
except IndexError as error:
	fake = True

if not fake:
	try:
		with io.open(filename_in, 'r', encoding='utf-8') as file_in:
			contents = file_in.read()
			sys.stderr.write('\n\n' + filename_in + '\n\n')

			out = html_fancy_answerline(contents)
	except IOError as error:
		fake = True



zz=1
ruby_tag_color = '\033[107m'*zz
contents_color = '\033[102;4m'*zz
bracket_color  = '\033[103;4m'*zz
space_color    = '\033[103;4m'*zz
reset_color    = '\033[0m'*zz

OR_p = 'or '
ACCEPT_p = 'accept '
PROMPT_p = 'prompt on '
REJECT_p = 'do not accept or prompt on '
REJECT2_p = 'reject '


# ANSWERLINE = '<p class="p1 answer">ANSWER: (.+?)</p>'
ANSWERLINE = '(?<=^ANSWER: )(.+?)(?=$)'
ANSWERLINE3 = r'^(?P<canonical>.+?)(?: \\?\[(?P<brackets>(?:[^\\\]]|\\[^\]])+)\\?\])?(?: \((?P<note>(?!“).+?)\))?$'

def mysub(match):
	# answerline = match.group(0)
	answerline = match
	# answerline = answerline.replace('*','')
	answerline = re.sub(r'\*\*(.+?)\*\*', '\033[4m\\1\033[24m', answerline)
	answerline = re.sub(r'\*(.+?)\*', '\033[3m\\1\033[23m', answerline)

	answer_clauses = odict([])
	for k in ['canonical','or','accept','prompt','reject','note']:
		answer_clauses.setdefault(k, [])

	print
	print(ruby_tag_color + answerline + reset_color)

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
			print(' %-12s %s' % ( k, c))
	return answer_clauses

def split_or_comma(text):
	# false positive: "accept sine of x, with any letter in place of x, such as theta"
	# should serial "or" be required?
	return re.split(', or |, | or ', text)

def html_fancy_answerline(contents):
	# return re.sub(ANSWERLINE, mysub, contents, flags=re.M)

	temp = re.sub(ANSWERLINE, '\\1', contents, flags=re.M)
	return mysub(temp)


# sys.stdout.write(out)

if fake:
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
	#######

	tests = {
		# PG
		'ANSWER: <u>word</u> (“pronunciation-guide”)':
		odict[
			'canonical': 'ANSWER: <u>word</u> (“pronunciation-guide”)',
			'or':     [],
			'accept': [],
			'prompt': [],
			'reject': [],
			'note':   []
		]
	}

	for (test, expected) in tests.items():
		actual = html_fancy_answerline(test)
		print()
		print('test:     %s'  % test)
		print('expected: %s'  % expected)
		print('actual:   %s'  % actual)
		print(expected == actual)

	# <u>grass</u> \[prompt on <u>leaf</u>, <u>leaves</u>, <u>sprout</u>s, or <u>spear</u>s\]
	# <u>OSIRIS-REx</u> \[or the <u>Origins, Spectral Interpretation, Resource Identification, Security, Regolith Explorer</u> spacecraft\]

	# warn if a directive doesn't have a bold, underline, or quotation marks

	# until/after X is read: on hover, highlight part of question text
