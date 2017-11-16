var old_page_key = window.location.href;
var page_key = old_page_key.replace(/\.\w\.html/, '');

// polyfills
function arrayFrom(nl, f) {
	var arr = [];
	for (var i = 0, l = nl.length; i < l; i ++)
		arr.push( f(nl[i], i) );
	return arr;
}
if (!Element.prototype.matches)
	Element.prototype.matches = Element.prototype.msMatchesSelector ||
								Element.prototype.webkitMatchesSelector;
if (!Element.prototype.closest)
	Element.prototype.closest = function(s) {
		var el = this;
		if (!document.documentElement.contains(el)) return null;
		do {
			if (el.matches(s)) return el;
			el = el.parentElement;
		} while (el !== null);
		return null;
	};


// backwards compatibility with old key
try {
	if (window.localStorage[old_page_key]) {
		window.localStorage[page_key] = window.localStorage[old_page_key];
		delete window.localStorage[old_page_key];
	}
} catch (e) {}

function mapTU(f) {
	return arrayFrom(document.querySelectorAll('.tu'), f);
}

function setLocalStorage() {
	var all_marks = mapTU(function(p) { return p.marked.map(function(m) { return m.getAttribute('v'); }); });
	try {
		window.localStorage[page_key] = JSON.stringify(all_marks);
	} catch (e) {}
}
function getFromLocalStorage() {
	try {
		var a = window.localStorage[page_key];
		if (!a) return;
		var parsed = JSON.parse(a);

		mapTU(function(p, i) {
			p.marked = parsed[i].map(function(v) {
				var m = p.querySelector('m[v="' + v + '"]');
				if (m)
					m.className = 'toggle';
				return m;
			});
		});
	} catch (e) {}
}

function getPs() {
	// queue of toggled words
	mapTU(function(p) { p.marked = []; });
}

function setHandler() {
	document.body.addEventListener('click', doSomething, false);
	var w = document.getElementById('word');
	var l = document.getElementById('location');

	function toggleM(m) {
		var p = m.closest('p.tu');

		if (m.className === 'toggle') {
			m.removeAttribute('class');
			var index = p.marked.indexOf(m);
			if (index !== -1)
				p.marked.splice(index, 1);
		}
		else {
			if (p.marked.length === 2) {
				// dequeue oldest mark
				p.marked.shift().removeAttribute('class');
			}
			m.className = 'toggle';
			p.marked.push(m);
		}
	}

	function doSomething(e) {
		if (e.target !== e.currentTarget) {
			var m = e.target;

			if (m.tagName === 'M') {
				w.textContent = m.textContent;
				l.textContent = m.getAttribute('v');

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

		mapTU(function(p) { p.marked = []; });
		arrayFrom(
			document.querySelectorAll('m.toggle'),
			function(m) { m.removeAttribute('class'); }
		);

		w.textContent = 'none';
		l.textContent = '';

		try {
			delete window.localStorage[page_key];
		} catch (e) {}
	}

	function copyBuzzPoints() {
		var line_ending = (navigator.platform.indexOf('Win') !== -1) ? '\r\n' : '\n';
		var string = mapTU(function(p) {
			var marked_vs = p.marked.map(function(m) { return m.getAttribute('v'); });
			// sort by index (instead of by time)
			marked_vs.sort(function(v1, v2) {
				return parseInt(v1, 10) - parseInt(v2, 10);
			});
			if (marked_vs.length === 1)
				marked_vs.unshift('');
			return marked_vs.join('\t');
		}).join(line_ending);
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
		if (!lastM) {
			console.warn(p);
			return '';
		}
		return lastM.getAttribute('v');
	});
}

function showPrompt() {
	// :scope not supported in IE, but this code doesn't matter for moderators
	var pw = selectorLastM(function(p) { return p.querySelectorAll(':scope > b'); });
	var w  = selectorLastM(function(p) { return [p]; });
	var tab = pw.map(function(v, i) { return v + '\t' + w[i]; }).join('\n');
	window.prompt('', tab);
}

function loadNumber() {
	getPs();
	getFromLocalStorage();
	setHandler();

	if (window.location.search === '?q')
		showPrompt();
}
