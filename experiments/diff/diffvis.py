import cgi, json
import numpy as np

template = u'''<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" href="svgconnector.css">
</head>
<body>
<svg>
<defs>
<marker id="markerCircle" markerWidth="8" markerHeight="8" refx="5" refy="5">
<circle cx="5" cy="5" r="2.5"/>
</marker>
<marker id="markerArrow" markerWidth="13" markerHeight="13" refx="8.5" refy="6.5" orient="auto">
<path d="M2,4 L4,6.5 L2,9 L10,6.5 L2,4"/>
</marker>
</defs>
</svg>
{}
<script src="svgconnector.js"></script>
</body>
</html>'''

def render_html(n, s1, s2, mapping, opcodes):
	return u'''<h1>{}</h1>
<table>{}</table>
<svg>{}</svg>'''.format(n, render_words(s1, s2, n, 's1-','s2-', opcodes), render_mapping(mapping, n, 's1-', 's2-'))

def render_words(s1, s2, n, id_prefix1, id_prefix2, opcodes):
	rows = np.hstack(map(tds, render_opcode(n, s1, s2, id_prefix1, id_prefix2, opcode)) for opcode in opcodes)
	return '\n'.join(map(tr, rows))

def tr(l):
	return u'<tr>{}</tr>\n'.format(u''.join(l))

def tds(l):
	return [u'<td>{}</td>'.format(e) for e in l]

def sp(n, i, id_prefix):
	return '<span id="n{}{}{}">{}</span>'.format(n, id_prefix, i, i)

def w(w):
	return cgi.escape(w)
	return w

def render_opcode(n, s1, s2, id1, id2, opcode):
	tag, i1, i2, j1, j2 = opcode

	if tag == 'equal':
		return [
			[w(s1[i])   for i in xrange(i1, i2)],
			[sp(n, i, id1) for i in xrange(i1, i2)],
			[''         for i in xrange(i1, i2)],
			[sp(n, j, id2) for j in xrange(j1, j2)],
			[w(s2[j])   for j in xrange(j1, j2)]
		]
	elif tag == 'insert':
		return [
			[''         for i in xrange(j1, j2)],
			[''         for i in xrange(j1, j2)],
			[''         for i in xrange(j1, j2)],
			[sp(n, j, id2) for j in xrange(j1, j2)],
			[w(s2[j])   for j in xrange(j1, j2)]
		]
	elif tag == 'delete':
		return [
			[w(s1[i])   for i in xrange(i1, i2)],
			[sp(n, i, id1) for i in xrange(i1, i2)],
			[''         for j in xrange(i1, i2)],
			[''         for j in xrange(i1, i2)],
			[''         for j in xrange(i1, i2)]
		]
	elif tag == 'replace':
		d = max(i2 - i1, j2 - j1)
		return [
			[(w(s1[i])      if i < i2 else '') for i in xrange(i1, i1 + d)],
			[(sp(n, i, id1) if i < i2 else '') for i in xrange(i1, i1 + d)],
			[''                             for i in xrange(i1, i1 + d)],
			[(sp(n, j, id2) if j < j2 else '') for j in xrange(j1, j1 + d)],
			[(w(s2[j])      if j < j2 else '') for j in xrange(j1, j1 + d)]
		]

def render_mapping(mapping, n, id_prefix1, id_prefix2):
	return ''.join([render_line(n, id_prefix1, m[0], id_prefix2, m[1], m[2]) for m in mapping])

def render_line(n, id_prefix1, id1, id_prefix2, id2, tag):
	return (u'<g data-s="n{}{}{}" data-t="n{}{}{}" class="{}">'
		'<line x-marker-start="url(#markerCircle)" x-marker-end="url(#markerArrow)" />'
		'<tex>{}</tex></g>\n').format(n, id_prefix1, id1, n, id_prefix2, id2, tag, id1 - id2)
