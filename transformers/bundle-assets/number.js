var FAR = findAndReplaceDOMText;
// http://velocityjs.org/blast/

function mapTU(f) {
	return Array.from(document.querySelectorAll('.tu'), f);
}

function hasSpanParent(el) {
	while (el = el.parentNode) {
		if ((el.nodeName === 'SPAN' && getComputedStyle(el).textDecorationLine !== 'underline')
			|| el.nodeName === 'RP' || el.nodeName === 'RT')
			return true;
		if (el.nodeName === 'P')
			return false;
	}
	return false;
}

function getPs() {
	var x = document.body.getElementsByClassName('tu');
	var j = 0;

	// using unnamed group to keep ^ and $ outside of | scope
	// TODO keep “” outside word? barely matters, but more aesthetic
	var no = /^(?:\(\*\)|[\/,\.?!'‘’"“”…–—-]+)$/;

	// TODO fix final punctuation kerning (foo</m>.)

	function replace(portion) {
		var tn = document.createTextNode(portion.text);

		// Don't count this as a word if:

		// it is part of a pronunciation guide (naively defined as being inside a span)
		// TODO more robust check
		if (hasSpanParent(portion.node))
			return tn;

		// it is a power mark (*) or only punctuation
		if (no.test(portion.text))
			return tn;

		var e = document.createElement('m');
		e.dataset.v = j ++;
		e.appendChild(tn);
		return e;
	}

	for (var i = 0; i < x.length; i ++) {
		var p = x[i];
		j = 0;

		FAR(p, {
			find: /[^  ]+/g,
			replace: replace
		});
	}
}

function setHandler() {
	document.body.addEventListener('click', doSomething, false);
	var w = document.getElementById('word');
	var l = document.getElementById('location');

	function toggleM(m) {
		if (m.dataset.toggle === 'true') {
			m.removeAttribute('data-toggle');
		}
		else {
			m.dataset.toggle = 'true';
		}
	}

	function doSomething(e) {
		if (e.target !== e.currentTarget) {
			var m = e.target;

			if (m.tagName === 'M') {
				w.textContent = m.textContent;
				l.textContent = m.dataset.v;

				toggleM(m);
			}
		}
		e.stopPropagation();
	}
}

function selectorLastM(selectF) {
	return mapTU(function(p) {
		var lastM = Array.from(
			selectF(p),
			function (b) { return Array.from(b.querySelectorAll('m')).pop(); }
		);
		lastM = lastM.filter(function(x) { return x; }).pop();
		return lastM.dataset.v;
	});
}

function showPrompt() {
	// :scope not supported in IE, but this code doesn't matter for moderators
	var pw = selectorLastM(function(p) { return p.querySelectorAll(':scope > b'); });
	var w  = selectorLastM(function(p) { return [p]; });
	var tab = pw.map(function(v, i) { return v + '\t' + w[i]; }).join('\n');
	window.prompt('', tab);
}

window.onload = function() {
	getPs();
	setHandler();

	if (window.location.search === '?q')
		showPrompt();
}
