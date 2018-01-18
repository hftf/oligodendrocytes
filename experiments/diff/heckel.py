
def _diff_heckel(text_a, text_b):
	"""Two-way diff based on the algorithm by P. Heckel.
	@param [in] text_a Array of lines of first text.
	@param [in] text_b Array of lines of second text.
	@returns TODO
	"""
	d    = [];
	uniq = [(len(text_a), len(text_b))]
	(freq, ap, bp) = ({}, {}, {})
	for i in range(len(text_a)):
		s = text_a[i]
		freq[s] = freq.get(s, 0) + 2;
		ap  [s] = i;
	for i in range(len(text_b)):
		s = text_b[i]
		freq[s] = freq.get(s, 0) + 3;
		bp  [s] = i;
	for s, x in freq.items():
		if x == 5: uniq.append((ap[s], bp[s]))
	(freq, ap, bp) = ({}, {}, {})
	uniq.sort(key=lambda x: x[0])
	(a1, b1) = (0, 0)
	while a1 < len(text_a) and b1 < len(text_b):
		if text_a[a1] != text_b[b1]: break
		a1 += 1
		b1 += 1
	for a_uniq, b_uniq in uniq:
		if a_uniq < a1 or b_uniq < b1: continue
		(a0, b0) = (a1, b1)
		(a1, b1) = (a_uniq - 1, b_uniq - 1)
		while a0 <= a1 and b0 <= b1:
			if text_a[a1] != text_b[b1]: break
			a1 -= 1
			b1 -= 1
		if a0 <= a1 and b0 <= b1:
			d.append(('c', a0 + 1, a1 + 1, b0 + 1, b1 + 1))
		elif a0 <= a1:
			d.append(('d', a0 + 1, a1 + 1, b0 + 1, b0))
		elif b0 <= b1:
			d.append(('a', a0 + 1, a0, b0 + 1, b1 + 1))
		(a1, b1) = (a_uniq + 1, b_uniq + 1)
		while a1 < len(text_a) and b1 < len(text_b):
			if text_a[a1] != text_b[b1]: break
			a1 += 1
			b1 += 1
	return d

x = ['a', 'd', 'b', 'b', 'b', 'c']
y = ['c', 'b', 'b', 'b', 'a', 'd']

print _diff_heckel(x,y)
