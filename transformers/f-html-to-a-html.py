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

# see e.g. https://hsquizbowl.org/forums/viewtopic.php?t=23031

# this code currently requires md.nowrap input




zz=1
ruby_tag_color = '\033[107m'*zz
contents_color = '\033[102;4m'*zz
bracket_color  = '\033[103;4m'*zz
space_color    = '\033[103;4m'*zz
reset_color    = '\033[0m'*zz

OR_p = 'or'
ACCEPT_p = 'accept'
PROMPT_p = 'prompt on'
ANTIPROMPT_p = 'anti-prompt on' # TODO regex: anti-?prompt
REJECT_p = 'do not accept or prompt on'
REJECT2_p = 'reject'
ACCEPT_f = lambda a: '<b>' in a and '<u>' in a
PROMPT_f = lambda a: '<b>' not in a and '<u>' in a
REJECT_f = lambda a: '<b>' not in a and '<u>' not in a and '“' in a
NOTE_f   = lambda a: not a.startswith('(“')

# TODO: <sub> <sup> in answerline. stretch of <b> but not <u> in answerline
#  <b><i><u>C</u></i><sub>T</sub></b>
# TODO: Hypothesis annotations on <details> hard to click

ANSWERLINE = '^<p class="(?:p1 )?answer">ANSWER: (.+?)</p>'
# ANSWERLINE = '(?<=^ANSWER: )(.+?)(?=$)'
ANSWERLINE3 = r'^(?P<canonical>.+?)(?: \\?\[(?P<brackets>(?:[^\\\]]|\\[^\]])+)\\?\])?(?: (?P<note>\((?!“|[a-z]).+?\)))?$'

def termformat(s):
	s = re.sub(r'\*\*(.+?)\*\*', '\033[1m\\1\033[22m', s)
	s = re.sub(r'\*(.+?)\*',     '\033[3m\\1\033[23m', s)
	s = re.sub(r'<b>(.+?)</b>',  '\033[1m\\1\033[22m', s)
	s = re.sub(r'<i>(.+?)</i>',  '\033[3m\\1\033[23m', s)
	s = re.sub(r'<u>(.+?)</u>',  '\033[4m\\1\033[24m', s)

	s = re.sub(r'<span class="af-reject">(.+?)</span>',     '\033[31m\\1\033[39m', s)

	s = re.sub(r'<span class="af-dnreveal">(.+?)</span>',   '\033[7m\\1\033[27m', s)
	s = re.sub(r'<span class="af-inplace">(.+?)</span>',    '\033[33m\\1\033[39m', s)
	s = re.sub(r'<span class="af-ask">(.+?)</span>',        '\033[34m\\1\033[39m', s)
	s = re.sub(r'<span class="af-until">(.+?)</span>',      '\033[32m\\1\033[39m', s)
	s = re.sub(r'<span class="af-directive">(.+?)</span>',  '\033[36m\\1\033[39m', s)
	return s

def mysub(match):
	if fake:
		# for html testing only
		answerline = match
	else:
		original_answerline = match.group(0)
		answerline = match.group(1)
	# answerline = answerline.replace('*','')

	answer_clauses = odict([])
	for k in ['canonical','or','accept','prompt','anti-prompt','reject','','note']:
		answer_clauses.setdefault(k, [])

	sys.stderr.write('\n')
	sys.stderr.write(ruby_tag_color + termformat(answerline) + reset_color + '\n')

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
				s = split_or_comma(clause[len(OR_p):].lstrip(),     ACCEPT_f)
				answer_clauses['or']     += s
			elif clause.startswith(ACCEPT_p):
				s = split_or_comma(clause[len(ACCEPT_p):].lstrip(), ACCEPT_f)
				answer_clauses['accept'] += s
				# accept either
			elif clause.startswith(PROMPT_p):
				s = split_or_comma(clause[len(PROMPT_p):].lstrip(), PROMPT_f)
				answer_clauses['prompt'] += s
			elif clause.startswith(ANTIPROMPT_p):
				s = split_or_comma(clause[len(ANTIPROMPT_p):].lstrip(), PROMPT_f)
				answer_clauses['anti-prompt'] += s
			elif clause.startswith(REJECT_p):
				s = split_or_comma(clause[len(REJECT_p):].lstrip(), REJECT_f)
				answer_clauses['reject'] += s
			elif clause.startswith(REJECT2_p):
				s = split_or_comma(clause[len(REJECT2_p):].lstrip(), REJECT_f)
				answer_clauses['reject'] += s
			else:
				answer_clauses[''] += clause
			# if any in result of split_or_comma is '' or contains one of the prefixes
	if note:
		answer_clauses['note'] = note

	# assertions
	try:
		a = answer_clauses['canonical']
		assert ACCEPT_f(a), a
		for a in answer_clauses['or'] + answer_clauses['accept']:
			assert ACCEPT_f(a), a
		for a in answer_clauses['prompt']:
			assert PROMPT_f(a), a
		for a in answer_clauses['anti-prompt']:
			assert PROMPT_f(a), a
		for a in answer_clauses['reject']:
			assert REJECT_f(a), a
		for a in answer_clauses['note']:
			assert NOTE_f(a), a
	except AssertionError as error:
		sys.stderr.write('\033[7;31m Assertion failed: \033[0m "' + str(error.args[0]) + '"\n')


	i = 0
	for k in answer_clauses:
		k_clauses = answer_clauses[k]
		if not isinstance(k_clauses, list): k_clauses = [k_clauses]

		for c in k_clauses:
			i += 1
			# print '%2d. %-12s %s' % (i, k, c)
			sys.stderr.write(' %-12s %s\n' % ( k, termformat(c) ))

	if fake:
		return answer_clauses
	else:
		note = answer_clauses.pop('note')
		html = '<details><summary>{oa}</summary>\n'.format(oa=original_answerline)
		html += '<div class="answer-fancy"><dl>\n'
		for k, clause in answer_clauses.items():
			if clause == []:
				continue
			if not isinstance(clause, list):
				clause = [clause]

			kk = k
			if kk == 'canonical':
				kk = 'ANSWER'
			if kk == 'prompt':
				kk = 'prompt on'
			if kk == 'anti-prompt':
				kk = 'anti-prompt on'
			
			html += '<dt class="af-{k}">{kk}:</dt>'.format(k=k, kk=kk)
			html += '<dd class="af-{k}"><ul>\n'.format(k=k)
			for c in clause:
				html += '<li>{c}</li>\n'.format(c=c)
			html += '</ul></dd>'
		html += '</dl>\n'
		if note:
			html += '<p class="af-note">{note}</p>\n'.format(note=note)
		html += '</div></details>\n'
		return html


def split_or_comma_unbalanced(text):
	# should serial "or" be required?
	return re.split(r', or |, | or ', text)

def split_or_comma(text, must_match):
	parts = []

	if re.search(
		re.sub(
			'\?P<[^>]+>',
			'',
			f'{IN_PLACE_OF_p}|{BY_ASKING_p}|{UNTIL_p}|{UNTIL_Y_p}|{BUT_p}|',
		) + r'such as|specific.*like',
		text
	):
		return [advanced(text)]


	matches = re.finditer(
		# TODO should (...) be an atomic unit?
		r'(?P<sep>, or | or |, )|(?P<c>((?:<(?P<tag>[^>]+)>(?:(?!</(?P=tag)>).)*?</(?P=tag)>|“[^”]+”)|(?!, or )(?!, (?! or |etc.))(?!(?<!word forms) or (?!word forms)).)+)',
		text
	)
	sys.stderr.write('__')
	must_join = ''
	last_sep = ''
	for match in matches:
		actual_match = match.group('c')
		sep = match.group('sep')

		if sep:
			if must_join:
				must_join += sep
			sys.stderr.write('%-62s %-20s %-8s %-40s %-8s' % (match.groupdict(), must_join, '', '', last_sep))

		if actual_match:
			must_matches = must_match(actual_match)
			if must_matches:
				actual_match = must_join + actual_match
				must_join = ''
			else:
				must_join += actual_match
				last_sep = ''
			sys.stderr.write('%-62s %-20s %-8s %-40s %-8s' % (match.groupdict(), 
				must_join, must_matches, actual_match, last_sep))

		if actual_match and not must_join:
			actual_match = advanced(actual_match)
			parts.append(actual_match)
	if must_join:
		must_join = advanced(must_join)
		parts.append(must_join)
	return parts

DO_NOT_REVEAL_p = r'(?P<d>, but DO NOT REVEAL, )(?P<b>.+?)$'
IN_PLACE_OF_p   = r'(?P<d> in place of )(?P<b>“.+?”)$'
BY_ASKING_p     = r'(?P<d> by asking )(?P<b>.+?)$'
UNTIL_p         = r'(?P<d> (until|after|before) (read|mention(ed)?))'
UNTIL_Y_p       = r'(?P<d> (until|after|before) )(?P<b>.+?)(?P<d2> (is|are) (read|mention(ed)?))' # they are read, it is read
BUT_p           = r'(?P<d> (but|and) )(?P<b>accept|prompt|reject)(?P<d2> before(hand)?|after)$'
MISC_p          = r'(?P<d> \(in that order\))$'
# AND, OR
# TODO: until/after X is read: on hover, highlight part of question text
def advanced(clause):
	clause = re.sub(DO_NOT_REVEAL_p, r'<span class="af-directive">\g<d></span><span class="af-dnreveal">\g<b></span>', clause)
	clause = re.sub(IN_PLACE_OF_p,   r'<span class="af-directive">\g<d></span><span class="af-inplace">\g<b></span>', clause)
	clause = re.sub(BY_ASKING_p,     r'<span class="af-directive">\g<d></span><span class="af-ask">\g<b></span>', clause)
	clause = re.sub(UNTIL_p,         r'<span class="af-directive">\g<d></span>', clause)
	clause = re.sub(UNTIL_Y_p,       r'<span class="af-directive">\g<d></span><span class="af-until">\g<b></span><span class="af-directive">\g<d2></span>', clause)
	clause = re.sub(BUT_p,           r'<span class="af-directive">\g<d><span class="af-\g<b>">\g<b></span>\g<d2></span>', clause)
	clause = re.sub(MISC_p,          r'<span class="af-directive af-misc">\g<d></span>', clause)
	return clause

def html_fancy_answerline(contents):
	if fake:
		temp = re.sub(ANSWERLINE, '\\1', contents, flags=re.M)
		return mysub(temp)
	else:
		return re.sub(ANSWERLINE, mysub, contents, flags=re.M)



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
			sys.stdout.write(out)
	except IOError as error:
		fake = True

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
		'ANSWER: <b><u>word</u></b> (“pronunciation-guide”)':
		odict[
			'canonical': 'ANSWER: <b><u>word</u></b> (“pronunciation-guide”)',
			'or':     [],
			'accept': [],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# PROMPT
		r'ANSWER: <b><u>gs</u></b> \[prompt on <u>lf</u>, <u>ls</u>, <u>st</u>s, or <u>sr</u>s\]':
		odict[
			'canonical': 'ANSWER: <b><u>gs</u></b>',
			'or':     [],
			'accept': [],
			'prompt': ['<u>lf</u>', '<u>ls</u>', '<u>st</u>s', '<u>sr</u>s'],
			'reject': [],
			'':       [],
			'note':   []
		],
		# comma in tag
		r'ANSWER: <b><u>abcd</u></b> \[or the <b><u>a, b, c d</u></b> e\]':
		odict[
			'canonical': 'ANSWER: <b><u>abcd</u></b>',
			'or':     ['the <b><u>a, b, c d</u></b> e'],
			'accept': [],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# see SUCH AS
		r'ANSWER: <b><u>foo</u></b> \[accept sine of x, with any letter in place of x, such as theta\]':
		odict[
			'canonical': 'ANSWER: <b><u>foo</u></b>',
			'or':     [],
			'accept': ['sine of x, with any letter in place of x, such as theta'],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# SUCH AS
		'ANSWER: <b><u>a</u></b> [accept word forms or equivalents such as <b><u>b</u></b> or <b><u>c</u></b> d]':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b>',
			'or':     [],
			'accept': ['word forms or equivalents such as <b><u>b</u></b> or <b><u>c</u></b> d'],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# not NOTE or PG
		'ANSWER: <b><u>a</u></b> (in b)':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b> (in b)',
			'or':     [],
			'accept': [],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		'ANSWER: <b><u>a</u></b> [accept <b><u>a b c</u></b> (in that order)]':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b>',
			'or':     [],
			'accept': ['<b><u>a b c</u></b> (in that order)'],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# OR IN PLACE OF
		'ANSWER: <b><u>a</u></b> [accept <b><u>b</u></b> or <b><u>c</u></b> in place of “a”]':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b>',
			'or':     [],
			'accept': ['<b><u>b</u></b> or <b><u>c</u></b> in place of “a”'],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# OR BY ASKING
		'ANSWER: <b><u>a</u></b> [prompt on <u>b</u> or <u>c</u> by asking “a”]':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b>',
			'or':     [],
			'accept': [],
			'prompt': ['<u>b</u> or <u>c</u> by asking “a”'],
			'reject': [],
			'':       [],
			'note':   []
		],
		# a OR b c (a c OR b c)
		'ANSWER: <b><u>a</u></b> [accept a or b <b><u>c</u></b>; accept a, b or c <b><u>d</u></b>; accept a, b, or fail]':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b>',
			'or':     [],
			'accept': ['a or b <b><u>c</u></b>', 'a, b or c <b><u>d</u></b>', 'a, b, or fail'],
			'prompt': [],
			'reject': [],
			'':       [],
			'note':   []
		],
		# LIKE
		#  TODO: both for the assert
		'ANSWER: <b><u>a</u></b> [prompt on specific xs like <u>a</u> or <u>b</u> that do not mention <b><u>c</u></b>]':
		odict[
			'canonical': 'ANSWER: <b><u>a</u></b>',
			'or':     [],
			'accept': [],
			'prompt': ['specific xs like <u>a</u> or <u>b</u> that do not mention <b><u>c</u></b>'],
			'reject': [],
			'':       [],
			'note':   []
		],
		# accept heart failure with preserved or reduced ejection fraction or HFpEF or HFrEF
		# accept end rhyme or other forms
		# accept body of Christ after “John” is read but reject before
		# ANSWER: anointing the statue [accept bathing or washing the statue with any of water, sandalwood, vermillion, turmeric, milk, sugarcane juice, or saffron] 
	}

	for (test, expected) in tests.items():
		actual = html_fancy_answerline(test)
		sys.stderr.write('\n')
		sys.stderr.write('test:     %s\n'  % test)
		sys.stderr.write('expected: %s\n'  % expected)
		sys.stderr.write('actual:   %s\n'  % actual)
		sys.stderr.write('Test result: \033[7m' + str(expected == actual) + '\033[0m\n')

# equivalents, synonyms, word forms
# ANSWER: anointing the statue [accept bathing or washing the statue with any of water, sandalwood, vermillion, turmeric, milk, sugarcane juice, or saffron]
# reject the specific phrases “no-slip” or “no-slip condition”]
# reject answers like “initiation to the Vodou priesthood” or “becoming a mambo” or “becoming a houngan”]
# garlic OR onions OR leeks OR scallions OR shallots [accept any two answers]
# Poland [or Republic of Poland or Rzeczpospolita Polska; the film in the third sentence is Ida]
# Southern Ocean [or Antarctic Ocean until “Antarctic” is read; accept Southern Ocean Carbon and Climate Observations and Modeling; anti-prompt on Weddell Sea by asking “what larger body of water is that a part of?”]
# Master letters [prompt on letters; prompt on, but DO NOT REVEAL, descriptions of letters written by Emily Dickinson]
# anointing the statue [accept bathing or washing the statue with any of water, sandalwood, vermillion, turmeric, milk, sugarcane juice, or saffron]
# Amazon Web Services [or AWS; prompt on Amazon; prompt on descriptions like Amazon cloud hosting or Amazon web hosting]
