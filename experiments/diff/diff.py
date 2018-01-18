# -*- coding: utf-8 -*-

# https://developers.google.com/style/
# https://medium.com/massdigital/mass-gov-style-guide-e677ec4c0c57
# https://web.archive.org/web/20161018233042/https://help.apple.com/asg/mac/2013/ASG_2013.pdf
# http://www.cs.brandeis.edu//~shapird/publications/JDAmoves.pdf
# file:///Users/ophir/Documents/quizbowl/oligodendrocytes/experiments/diff/diff.html
# https://pdfs.semanticscholar.org/a9e5/4359c3198ebbb2d9767fbe6951886311837f.pdf

import difflib
import math
import diffvis
import packet_scanner


def rawhtml2arr(txts):
	return [x.split() for x in txts]

def arr2stripped(arrs):
	return [map(strip, wrap(x)) for x in arrs]

wrap  = lambda x: [u'_^'] + x + [u'_$']
strip = lambda s: s#s.strip(' .,!?-/"\'').lower()


def stripped2diff(strippeds):
	assert len(strippeds) == 2

	matcher = difflib.SequenceMatcher(None, *strippeds)
	opcodes = matcher.get_opcodes()

	mapping_ids = []
	for i in range(len(strippeds[0])):
		j, tag = transform(i, opcodes)
		mapping_ids.append([i, j, tag])

	return mapping_ids, opcodes

def diff2diffhtml(n, strippeds):
	mapping_ids, opcodes = stripped2diff(strippeds)
	return diffvis.render_html(n, strippeds[0], strippeds[1], mapping_ids, opcodes)

def rawhtml2diffhtml(n, txts):
	return diff2diffhtml(n, arr2stripped(rawhtml2arr(txts)))

def wholepacket(txtss):
	innerhtmls = ''
	for n, txts in enumerate(txtss):
		innerhtmls += rawhtml2diffhtml(n+1, txts)

	return diffvis.template.format(innerhtmls).encode('utf-8')


exs = [ex.split() for ex in [

u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many percussive Bs. A piece in this genre opens quietly with E-flat minor arpeggios before obsessive 16th-note ostinati. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo and agitated upward glissandi before a languid 5/8 section. Two movements, Foreboding and Death, survive of Janáček’s piece in this genre written after the murder of a worker, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement. A piece in this genre opens with a slow, two-octave A major arpeggio before Largo and Allegro sections alternate, while another opens by repeating G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo keyboard Beethoven pieces, such as <i>Tempest</i>, <i>Pathétique</i>, and <i>Moonlight</i>.",
u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many percussive Bs. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo and fast upward glissandi before a languid 5/8 section. An intermezzo titled Rückblick quotes Beethoven’s fate motif in a five-movement piece in this genre by Brahms. Two movements, Foreboding and Death, exist of Janáček’s piece in this genre, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement, like Liszt’s long B minor one in double-function form. A two-octave A major arpeggio and alternating Largo and Allegro sections open a piece in this genre called <i>Tempest</i>. Another opens by repeating G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo Beethoven pieces, such as <i>Pathétique</i> and <i>Moonlight</i>.",
u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many Bs. A piece in this genre ends in a soft A minor, F major, B major cadence. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo, fast glissandi, then a languid 5/8 section. Beethoven’s fate motif is quoted in the Rückblick intermezzo from Brahms’s five-movement piece in this genre. Two movements, Foreboding and Death, exist of Janáček’s piece in this genre, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement, like Liszt’s B minor one in double-function form. A two-octave A major arpeggio and alternating Largo and Allegro sections open a piece in this genre called <i>Tempest</i>. Another opens with repeated G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo Beethoven pieces, such as <i>Pathétique</i> and <i>Moonlight</i>.",
u"2. <b>This composer separated vowels with a “z” in “Three lovely birds from paradise.” He elided silent “e’s” in setting five animal fables in <i>Natural Histories</i>, angering listeners. This composer united the voice with a trio in <i>Madagascan Songs</i> and with orchestra in setting free verse Tristan Klingsor poems in <i>Shéhérazade</i>. A pedal on G persists in his “Kaddish” arrangement. Dancers with tambourines said “Ser-gei Dia-ghi-lev” to keep 5/4 time in the final (*)</b> bacchanale from his only Ballets Russes work. Flute passages depict a pantomimed myth and a wordless chorus, flute, clarinet, and harp glissandi depict sunrise over two shepherds in that ballet. This composer’s “piece with no music” alternates two C major themes among instruments over a crescendo snare drum ostinato until the E major climax. For 10 points, name this French composer of <i>Daphnis et Chloé</i> and <i>Boléro</i>.",
u"2. <b>This composer separated vowels with Z’s in “Three lovely birds from paradise” for chorus. He elided silent E’s in setting 5 animal fables in <i>Natural Histories</i>, angering listeners. This composer fused the voice with a trio in <i>Madagascan Songs</i> and with orchestra in setting free verse Tristan Klingsor poems in <i>Shéhérazade</i>. A pedal on G persists in his Kaddish setting. Dancers with tambourines said “Ser-gei Dia-ghi-lev” to keep 5/4 time in a final bacchanale or (*)</b> <i>danse générale</i> in his only Ballets Russes work. Flute passages depict a pantomimed myth, and wordless chorus, flute, clarinet, and harp glissandi depict sunrise over shepherds, in that ballet. This composer of <i>The Child and the Spells</i> and <i>The Spanish Hour</i> alternated two C major themes among instruments over a crescendo snare drum ostinato until the E major climax. For 10 points, name this composer of <i>Daphnis et Chloé</i> and <i>Boléro</i>.",
u"2. <b>This composer separated vowels with z’s in “Three lovely birds from paradise” for chorus. He elided silent e’s in setting 5 animal fables in <i>Natural Histories</i>, angering listeners. This composer used a trio in <i>Madagascan Songs</i>. He used an orchestra to set free verse Tristan Klingsor poems in <i>Shéhérazade</i>. He used melismas over a pedal on G in his <i>Kaddisch</i>. Dancers with tambourines said “Ser-gei Dia-ghi-lev” to keep 5/4 time in the final bacchanale or (*)</b> <i>danse générale</i> in his only Ballets Russes work. Flutes depict a pantomimed myth, and wordless chorus, flute, clarinet, and harp glissandi depict sunrise over shepherds, in that ballet by this composer of <i>La valse</i>. Until the E major climax, two C major themes alternate among instruments over a crescendo snare drum ostinato in a piece by him. For 10 points, name this composer of <i>Daphnis et Chloé</i> and <i>Boléro</i>.",
u'foo fo one bar         two i',
u'foo fo     bar three i two',
]]

def transform(i, opcodes):
	assert opcodes[0][1] <= i < opcodes[-1][2]
	opcode = next((opcode for opcode in reversed(opcodes) if opcode[1] <= i), 'a')
	tag, i1, i2, j1, j2 = opcode

	if tag == 'equal':
		j = j1 + (i - i1)
	elif tag == 'insert':
		j = i1
	elif tag == 'delete':
		j = j1
	elif tag == 'replace':
		j = min(j1 + (i - i1), j2)
		# j = max(j2 - (i2 - i), j1)

	assert opcodes[0][3] <= j < opcodes[-1][4]
	return j, tag

# print packet_scanner.get_question_html('2', 4, 'tossup', 19)
# print packet_scanner.get_question_html('2', 7, 'tossup', 2)

txtss = [[
u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many percussive Bs. A piece in this genre opens quietly with E-flat minor arpeggios before obsessive 16th-note ostinati. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo and agitated upward glissandi before a languid 5/8 section. Two movements, Foreboding and Death, survive of Janáček’s piece in this genre written after the murder of a worker, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement. A piece in this genre opens with a slow, two-octave A major arpeggio before Largo and Allegro sections alternate, while another opens by repeating G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo keyboard Beethoven pieces, such as <i>Tempest</i>, <i>Pathétique</i>, and <i>Moonlight</i>.",
u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many percussive Bs. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo and fast upward glissandi before a languid 5/8 section. An intermezzo titled Rückblick quotes Beethoven’s fate motif in a five-movement piece in this genre by Brahms. Two movements, Foreboding and Death, exist of Janáček’s piece in this genre, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement, like Liszt’s long B minor one in double-function form. A two-octave A major arpeggio and alternating Largo and Allegro sections open a piece in this genre called <i>Tempest</i>. Another opens by repeating G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo Beethoven pieces, such as <i>Pathétique</i> and <i>Moonlight</i>.",
],[
u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many percussive Bs. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo and fast upward glissandi before a languid 5/8 section. An intermezzo titled Rückblick quotes Beethoven’s fate motif in a five-movement piece in this genre by Brahms. Two movements, Foreboding and Death, exist of Janáček’s piece in this genre, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement, like Liszt’s long B minor one in double-function form. A two-octave A major arpeggio and alternating Largo and Allegro sections open a piece in this genre called <i>Tempest</i>. Another opens by repeating G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo Beethoven pieces, such as <i>Pathétique</i> and <i>Moonlight</i>.",
u"19. <b>Bartók’s 1926 piece in this genre opens with a low G-sharp octave, A–A-sharp dyad, and many Bs. A piece in this genre ends in a soft A minor, F major, B major cadence. A piece in this genre opens with a long trill on low E over a D-sharp–A tremolo, fast glissandi, then a languid 5/8 section. Beethoven’s fate motif is quoted in the Rückblick intermezzo from Brahms’s five-movement piece in this genre. Two movements, Foreboding and Death, exist of Janáček’s piece in this genre, <i>1. X. 1905</i>. Medtner’s <i>Night Wind</i> and all of (*)</b> Scriabin’s pieces in this genre after No. 5 have one movement, like Liszt’s B minor one in double-function form. A two-octave A major arpeggio and alternating Largo and Allegro sections open a piece in this genre called <i>Tempest</i>. Another opens with repeated G-sharp C-sharp E triplets on the sustain pedal. For 10 points, name this genre of 32 solo Beethoven pieces, such as <i>Pathétique</i> and <i>Moonlight</i>.",
]]

txtss = [[
	packet_scanner.get_question_html('', 2, 'tossup', n).decode('utf-8'),
	packet_scanner.get_question_html('3', 2, 'tossup', n).decode('utf-8')] for n in xrange(1, 15)]

print wholepacket(txtss)
