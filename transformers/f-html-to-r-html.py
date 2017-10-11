#!/usr/bin/python
# -*- coding: utf-8 -*-

# http://mashimonator.weblike.jp/storage/library/20090118_001/demo/ruby2/index.html
# http://mashimonator.weblike.jp/library/2009/01/javascript-rubyjs.html
# https://web.archive.org/web/20120111135746/web.nickshanks.com/stylesheets/ruby.css
# https://gist.github.com/cyphr/6536814
# http://dev.sstatic.net/js/third-party/japanese-l-u.js

import sys
import re
import io
from unidecode import unidecode
from htmlparser import LastNParser

import codecs
sys.stdout = codecs.getwriter('utf8')(sys.stdout)

filename_in = sys.argv[1]
filename_out = filename_in.replace('.f.', '.r.')

with io.open(filename_in, 'r', encoding='utf-8') as file_in:
	contents = file_in.read()

if 0:
	# default
	use_tags = False
	use_paren_quote = True
if 1:
	# eft
	use_tags = True
	use_paren_quote = False

EXTRA_TAGS   = '<\/?b>'
EXTRA_TAGS   = '(?:<\/?b>|)'
PG_TAG_S     = '<span\ class=\"s\d\">'
PG_TAG_E     = '<\/span>'
QUOTE_S      = '(?:\"|“)?'
QUOTE_E      = '(?:\"|”)?'
SPACE        = u'[  ]'
SPACES       = SPACE + '+'
SPACEM       = SPACE + '*'
SPACE_NONBSP = u'[ ]'
SPACES_NONBSP= SPACE_NONBSP + '+'
LETTER       = '[^\]\)\s]'
WORD         = '[^\]\)\s]+'

if use_paren_quote:
	PG_BRACKET_S = u'[\(]“'
	PG_BRACKET_E = u'”[\)]'
	PG_MIDDLE    = u'[^”\)]+'
else:
	PG_BRACKET_S = '[\(\[]'
	PG_BRACKET_E = '[\)\]]'
	PG_MIDDLE    = '[^\)\]]+'

# PG_S  =                       PG_TAG_S + EXTRA_TAGS + PG_BRACKET_S
# PG_S2 = EXTRA_TAGS + SPACES + PG_TAG_S + EXTRA_TAGS + PG_BRACKET_S
# PG_SB = '(?:' + EXTRA_TAGS + '|)(?P<ss>' + SPACES + ')' + PG_TAG_S + EXTRA_TAGS + '(?P<sb>' + PG_BRACKET_S + ')'
# PG_SB = EXTRA_TAGS + '(?P<ss>' + SPACES + ')' + PG_TAG_S + EXTRA_TAGS + '(?P<sb>' + PG_BRACKET_S + ')'

# PG_M  = u'(?P<m>' + PG_MIDDLE + ')'
# PG_E  = PG_BRACKET_E + EXTRA_TAGS + PG_TAG_E
# PG_E2 = PG_BRACKET_E + EXTRA_TAGS + PG_TAG_E + '(?P<es>' + SPACEM + ')' + EXTRA_TAGS
# PG_EB = '(?P<eb>' + PG_BRACKET_E + ')' + EXTRA_TAGS + PG_TAG_E + '(?P<es>' + SPACEM + ')' + EXTRA_TAGS

# PG  = PG_S + PG_M + PG_E

if use_tags:
	PG_SB = u'(?P<ss>' + SPACES       + ')' + \
	                     PG_TAG_S + EXTRA_TAGS + \
	         '(?P<sb>' + PG_BRACKET_S + ')'
	PG_M  = u'(?P<m>'  + PG_MIDDLE    + ')'
	PG_EB = u'(?P<eb>' + PG_BRACKET_E + ')' + \
	                     EXTRA_TAGS + PG_TAG_E + \
	         '(?P<es>' + SPACEM       + ')'

	PGB = PG_SB + PG_M + PG_EB

else:
	PG_SB = u'(?P<ss>' + SPACES       + ')' + \
	         '(?P<sb>' + PG_BRACKET_S + ')'
	PG_M  = u'(?P<m>'  + PG_MIDDLE    + ')'
	PG_EB = u'(?P<eb>' + PG_BRACKET_E + ')' + \
	         '(?P<es>' + SPACEM       + ')'

	PGB = PG_SB + PG_M + PG_EB

# TODO eventually do something with ' or ': Pho [Fo or Fuh]
# TODO eventually boundary symbols like “”‘’ can be left out of rb
# TODO remove </b> <b> at end

fake_contents = u'''--
test aaa     <span class="s1"><b>[bbb]</b></span>      test
test aaa</b> <span class="s1"><b>[bbb]</b></span>   <b>test
test aaa</i> <span class="s1"><b>[bbb]</b></span>   <i>test
test aaa aaa <span class="s1"><b>[bbb bbb]</b></span>  test

test aaa    <span class="s1"> <b>[bbb]</b> </span>     test

<b>One morning, when <i>Gregor Samsa</i></b>  <span class="s1"><b>[SAM-sa]</b></span> <b>woke from troubled dreams,
<b>One morning, when <i>Gregor Samsa</i></b> <span class="s1"><b>[GREG-or SAM-sa]</b></span> <b>woke from troubled dreams,
<b>One morning, when <i>Gregor Samsa</i></b> <span class="s1"><b>[GREG-or SAM-sa]</b></span> <b>woke from troubled dreams,
to Diu</b> <span class="s2"><b>[dyew]</b></span><b>. (*)</b> Long-distance
strept<span class="s2"><b>avidin</b></span> <span class="s1">[strept-AVID-in]</span> (Biotin
[or <span class="s1"><b>ACh</b></span> <span class="s2">[A-C-H]</span>]</p>
<p class="p1 tu">8. <b>Mo17</b> <span class="s1"><b>[M-O-seventeen]</b></span><b>, W22,
<p class="p1">ANSWER: <span class="s2"><b>De Stijl</b></span> <span class="s1">[duh shteel]</span></p>
power after overcoming Xiàng Yǔ’s</b> <span class="s2"><b>[shyong yoo’s]</b></span> <b>state of (*)</b> Chu.
the “bergin</b> <span class="s1"><b>[BERG-in]</b></span> <b>boy” accidentally
<p class="p1 answer">ANSWER: J. M. <span class="s2"><b>Coetzee</b></span> <span class="s1">[coot-ZEE-uh or coot-zee]</span>
<p class="p1 answer">ANSWER: J. M. <span class="s2"><b>Coetzee</b></span> <span class="s1">[coot-ZEE-uh or coot-zee]</span>
Luis Buñuel, <i>L’Âge d’Or</i> <span class="s2"><b>[lodge dor]</b></span>. For 10
Luis Buñuel, <i>L’Âge d’Or</i> (“lodge dor”). For 10
'''

zz=0
ruby_tag_color = '\033[107;4m'*zz
contents_color = '\033[102;4m'*zz
bracket_color  = '\033[103;4m'*zz
space_color    = '\033[103;4m'*zz
resetCmd = '\033[0m'*zz

def html_span_to_ruby(contents):
	instances = re.finditer(PGB, contents)
	lastMatch = 0
	formattedText = ''

	for match in instances:
		start, end = match.span()
		# print [start, end, match.group('m'), match.group('es')]

		prev = contents[lastMatch : start]
		main = contents[start : end]

		a = 'nothing yet'

		ss = match.group('ss')
		sb = match.group('sb')
		b  = match.group('m')
		eb = match.group('eb')
		es = match.group('es')

		space_count = 1 + len(re.findall(SPACES_NONBSP, b))
		# print '(' + str(n) + ')    ' + colerCmd + b + resetCmd
		# fake_a = ' '.join(prev.replace('<span ', '<span~').rsplit(None, n)[-n:]).replace('<span~', '<span ')
		# print 'Faked: ' + fake_a

		last_newline_pos = prev.rfind('\n') + 1
		prev1 = prev[:last_newline_pos]
		prev2 = prev[last_newline_pos:]
		prev2a, a, closing_tags = real_a = LastNParser(prev2).last_n_words(space_count)
		# print 'Real:  ' + '***'.join(list(real_a))

		formattedText += (
			prev1 +
			prev2a +
			ruby_tag_color + '<ruby><rb>'   +
			contents_color + a              +
			ruby_tag_color + '</rb><rp>'    +
			space_color    + ss             +
			bracket_color  + sb             +
			ruby_tag_color + '</rp><rt>'    +
			contents_color + b              +
			ruby_tag_color + '</rt><rp>'    +
			bracket_color  + eb             +
			ruby_tag_color + '</rp></ruby>' +
			bracket_color  + closing_tags   +
			space_color    + es             +
			resetCmd
		)

		lastMatch = end
	formattedText += contents[lastMatch:]
	return formattedText

fake = False
if fake:
	out = html_span_to_ruby(fake_contents)
	# print out
else:
	out = html_span_to_ruby(contents)
sys.stdout.write(out)

	# with io.open(filename_out, 'w', encoding='utf-8') as file_out:
		# file_out.write(out)
