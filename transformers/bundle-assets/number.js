var FAR = findAndReplaceDOMText;
// http://velocityjs.org/blast/

function hasSpanParent(el) {
	while (el = el.parentNode) {
		if (el.nodeName === 'SPAN' || el.nodeName === 'RP' || el.nodeName === 'RT')
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

	function doSomething(e) {
		if (e.target !== e.currentTarget) {
			var m = e.target;

			if (m.tagName === 'M') {
				w.textContent = m.textContent;
				l.textContent = m.dataset.v;
			}
		}
		e.stopPropagation();
	}
}

function showPrompt() {
	function qu(el, q) {
		return Array.from(el.querySelectorAll(q));
	}
	function getLastIfExists(q) {
		return function(el) {
			if (!el)
				return;
			var ms = qu(el, q);
			if (ms.length)
				return ms.pop();
		};
	}
	function getV(el) {
		if (el) return el.dataset.v;
	}
	var tus = qu(document, '.tu');
	var pw = tus.map(getLastIfExists('b m')).map(getV);
	var w = tus.map(getLastIfExists('m')).map(getV);
	var tab = pw.map((v, i) => v + '\t' + w[i]).join('\n');
	prompt('', tab);
}

window.onload = function() {
	getPs();
	setHandler();

	if (window.location.search === '?q')
		showPrompt();
}
