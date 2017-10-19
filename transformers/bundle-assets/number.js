var FAR = findAndReplaceDOMText;
// http://velocityjs.org/blast/

var old_page_key = window.location.href;
var page_key = old_page_key.replace(/\.\w\.html/, '');

// backwards compatibility with old key
if (window.localStorage[old_page_key]) {
	window.localStorage[page_key] = window.localStorage[old_page_key];
	delete window.localStorage[old_page_key];
}

function mapTU(f) {
	return Array.from(document.querySelectorAll('.tu'), f);
}

function setLocalStorage() {
	var all_marks = mapTU(function(p) { return p.marked.map(function(v) { return v.dataset.v; }); });
	window.localStorage[page_key] = JSON.stringify(all_marks);
}
function getFromLocalStorage() {
	var a = window.localStorage[page_key];
	if (!a) return;
	var parsed = JSON.parse(a);

	mapTU(function(p, i) {
		p.marked = parsed[i].map(function(v) {
			var m = p.querySelector('m[data-v="' + v + '"]');
			m.dataset.toggle = 'true';
			return m;
		});
	});
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
	var j = 0, p;

	// using unnamed group to keep ^ and $ outside of | scope
	// TODO keep “” outside word? barely matters, but more aesthetic
	var no = /^(?:\(\*\)|[\/,\.?!'‘’"“”…–—-]+)$/;

	// TODO fix final punctuation kerning (foo</m>.)

	function replace(portion) {
		// Uses closure vars j, p, no
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
		e.p = p; // pointer to parent p
		e.dataset.v = j ++;
		e.appendChild(tn);
		return e;
	}

	for (var i = 0; i < x.length; i ++) {
		p = x[i];
		j = 0;

		p.marked = []; // queue of toggled words

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
		var p = m.p;

		if (m.dataset.toggle === 'true') {
			m.removeAttribute('data-toggle');
			var index = p.marked.indexOf(m);
			if (index !== -1)
				p.marked.splice(index, 1);
		}
		else {
			if (p.marked.length === 2) {
				// dequeue oldest mark
				p.marked.shift().removeAttribute('data-toggle');
			}
			m.dataset.toggle = 'true';
			p.marked.push(m);
		}
	}

	function doSomething(e) {
		if (e.target !== e.currentTarget) {
			var m = e.target;

			if (m.tagName === 'M') {
				w.textContent = m.textContent;
				l.textContent = m.dataset.v;

				toggleM(m);

				setLocalStorage();
			}
		}
		e.stopPropagation();
	}

	document.getElementById('reset').addEventListener('click', clearAllBuzzes, false);
	document.getElementById('copy').addEventListener('click', copyBuzzPoints, false);

	function clearAllBuzzes() {
		var really = window.confirm('Are you sure you want to clear all buzzes?');
		if (!really) return;

		delete window.localStorage[page_key];
		mapTU(function(p) { p.marked = []; });
		Array.from(
			document.querySelectorAll('m[data-toggle]'),
			function(m) { m.removeAttribute('data-toggle'); }
		);
	}

	function copyBuzzPoints() {
		var string = mapTU(function(p) {
			var marked_vs = p.marked.map(function(m) { return m.dataset.v; });
			// sort by index (instead of by time)
			marked_vs.sort(function(v1, v2) {
				return parseInt(v1, 10) - parseInt(v2, 10);
			});
			if (marked_vs.length === 1)
				marked_vs.unshift('');
			return marked_vs.join('\t');
		}).join('\n');
		clipboard.writeText(string);
		window.alert('The buzz points have been copied! Go to the scoresheet to paste them.');
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
	getFromLocalStorage();
	setHandler();

	if (window.location.search === '?q')
		showPrompt();
}
