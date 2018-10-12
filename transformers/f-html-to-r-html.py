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

import Levenshtein
from caverphone import caverphone


import codecs
sys.stdout = codecs.getwriter('utf8')(sys.stdout)
sys.stderr = codecs.getwriter('utf8')(sys.stderr)

filename_in = sys.argv[1]
filename_out = filename_in.replace('.f.', '.r.')

with io.open(filename_in, 'r', encoding='utf-8') as file_in:
	contents = file_in.read()
	sys.stderr.write('\n\n' + filename_in + '\n\n')

if 1:
	# default
	use_tags = False
	use_paren_quote = True
if 0:
	# eft
	use_tags = True
	use_paren_quote = False

EXTRA_TAGS   = '(?:<\/?b>|)'
PG_TAG_S     = '<span\ class=\"s\d\">'
PG_TAG_E     = '<\/span>'
SPACE        = u'[  ]'
SPACES       = SPACE + '+'
SPACEM       = SPACE + '*'
SPACE_NONBSP = u'[ ]'
SPACES_NONBSP= SPACE_NONBSP + '+'

if use_paren_quote:
	QUOTE_S = u'“'
	QUOTE_E = u'”'
	PG_BRACKET_S = u'[\(]' + QUOTE_S
	PG_BRACKET_E = QUOTE_E + u'[\)]'
	PG_MIDDLE    = u'[^\)]+'
else:
	QUOTE_S = u''
	QUOTE_E = u''
	PG_BRACKET_S = '[\(\[]'
	PG_BRACKET_E = '[\)\]]'
	PG_MIDDLE    = '[^\)\]]+'

PG_OR = QUOTE_E + ur' or ' + QUOTE_S
PG_BRACKET_INSTRUCTION = '[\[\(]' + u'(?P<in>emphasize[^\]\)]*|pause|read slowly[^\]\)]*)' + '[\]\)]'

if use_tags:
	PG_SB = u'(?P<ss>' + SPACES       + ')' + \
	                     PG_TAG_S + EXTRA_TAGS + \
	         '(?P<sb>' + PG_BRACKET_S + ')'
	PG_M  = u'(?P<m>'  + PG_MIDDLE    + ')'
	PG_EB = u'(?P<eb>' + PG_BRACKET_E + ')' + \
	                     EXTRA_TAGS + PG_TAG_E + \
	         '(?P<es>' + SPACEM       + ')'

	PGB = PG_SB + PG_M + PG_EB

	PG_BRACKET_INSTRUCTION = PG_TAG_S + EXTRA_TAGS + PG_BRACKET_INSTRUCTION + EXTRA_TAGS + PG_TAG_E + '\s'

else:
	PG_SB = u'(?P<ss>' + SPACES       + ')' + \
	         '(?P<sb>' + PG_BRACKET_S + ')'
	PG_M  = u'(?P<m>'  + PG_MIDDLE    + ')'
	PG_EB = u'(?P<eb>' + PG_BRACKET_E + ')' + \
	         '(?P<es>' + SPACEM       + ')'

	PGB = PG_SB + PG_M + PG_EB

	PG_BRACKET_INSTRUCTION = PG_BRACKET_INSTRUCTION + '\s'


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
Luis Buñuel, <i>L’Âge–d’Or</i> (“lodge dor”). For 10
Luis Buñuel, <i>foo</i> (“foo” or “fu”). For 10
foo [read slowly] bar [emphasize] baz
is nicknamed “Kegelstatt” (“KAY-gull-shtott”). Haydn
is nicknamed “Kegelstatt (“KAY-gull-shtott”).” Haydn
space, grapheme 2 words: St. John (“SIN jun”)
nbsp,  grapheme 2 words: St. John (“SIN jun”)
nnbsp, grapheme 1 word:  St. John (“SIN-jun”)
The Professor (*)</b> One-Word (“two words”). This
The Professor</b> (*) One-Word (“two words”). This
The Professor a</b> c One-Word (“two words”). This
solo <span class="s1"><b>(read slowly)</b></span> <span class="s2"></span>long
'''

zz=1
ruby_tag_color = '\033[107;4m'*zz
contents_color = '\033[102;4m'*zz
bracket_color  = '\033[103;4m'*zz
space_color    = '\033[103;4m'*zz
reset_color    = '\033[0m'*zz

def wrap_caps(b):
	return re.sub('[A-Z]{2,}', '<span class="pg-stress">\g<0></span>', b)

def middot(b):
	return re.sub('-', u'·', b)

def word_count(b):
	b_first_or_pos = re.search(PG_OR, b)
	if b_first_or_pos:
		b = b[:b_first_or_pos.start()]
	space_count = 1 + len(re.findall(SPACES_NONBSP, b))
	return space_count

def bracket_instruction(b):
	return re.sub(PG_BRACKET_INSTRUCTION, u'<small class="bracket-instruction">(\g<in>)</small> ', b)

def rp_or(b):
	return re.sub(PG_OR, ' <span class="pg-or">or</span> ', b)
	# TODO eventually do something like:
	# <ruby> <rb>...</rb> <rp>(</rp>
	#  <rt><span>“</span> ... <span>”</span><span> or </span> ...
	# or completely dispense with all rendered “”

	# <rp> doesn't work because another <rb> is implied:
	# return re.sub(PG_OR, '</rt><rp>\g<0></rp><rt>', b)

def html_span_to_ruby(contents):
	contents = bracket_instruction(contents)

	instances = re.finditer(PGB, contents)
	lastMatch = 0
	formattedText = ''

	for match in instances:
		start, end = match.span()

		prev = contents[lastMatch : start]
		main = contents[start : end]

		a = 'nothing yet'

		ss = match.group('ss')
		sb = match.group('sb')
		b  = match.group('m')
		eb = match.group('eb')
		es = match.group('es')

		b_word_count = word_count(b)

		# b = b_middot = middot(b)
		b = b_rp_or = rp_or(b)
		# b = b_wrap_caps = wrap_caps(b)

		last_newline_pos = prev.rfind('\n') + 1
		prev1 = prev[:last_newline_pos]
		prev2 = prev[last_newline_pos:]
		prev2a, a, closing_tags = real_a = LastNParser(prev2).last_n_words(b_word_count)

		# for caver stuff only
		a_stripped = unidecode(re.sub('<[^<]+?>', '', a))
		a_phonetic = caverphone(a_stripped)
		b_stripped = unidecode(re.sub('<[^<]+?>', '', b))
		b_phonetic = caverphone(b_stripped)
		distance = Levenshtein.distance(a_phonetic, b_phonetic)
		ratio = Levenshtein.ratio(a_phonetic, b_phonetic)
		# sys.stderr.write( '%-20s\t%-12s\t%-36s\t%-12s\t%2d\t%0.2f\n' % (a_stripped, a_phonetic, b_stripped, b_phonetic, distance, ratio) )

		ap = ' '*(41-len(a))
		bp = ' '*(41-len(b))
		def h(a):
			return a
		ruby_tuples = [
			(             '' , h('<ruby>')       ),
			( ruby_tag_color , h('<rb>')         ),
			( contents_color , a              ),
			( ruby_tag_color , h('</rb>')        ),
			( reset_color+ap , ''             ),
			( ruby_tag_color , h('<rp>')         ),
			(    space_color , ss             ),
			(  bracket_color , sb             ),
			( ruby_tag_color , h('</rp><rt>')    ),
			( contents_color , b              ),
			( ruby_tag_color , h('</rt><rp>')    ),
			(  bracket_color , eb             ),
			( ruby_tag_color , h('</rp>')        ),
			( reset_color+bp , h('</ruby>')      ),
			(  bracket_color , closing_tags   ),
			(    space_color , es             ),
			(    reset_color , ''             ),
		]
		ruby_str       = ''.join([txt     for clr,txt in ruby_tuples])
		ruby_str_color = ''.join([clr+txt for clr,txt in ruby_tuples])

		formattedText += (
			prev1 +
			prev2a +
			ruby_str
		)
		sys.stderr.write(ruby_str_color + "\n")

		lastMatch = end
	formattedText += contents[lastMatch:]
	return formattedText

fake = False
if fake:
	out = html_span_to_ruby(fake_contents)
else:
	out = html_span_to_ruby(contents)
sys.stdout.write(out)
