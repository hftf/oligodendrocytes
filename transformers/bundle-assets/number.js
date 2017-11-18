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
	var all_marks = mapTU(function(p) { return p.marked.map(function(m) { return m.dataset.v; }); });
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

function getPs() {
	// queue of toggled words
	mapTU(function(p) { p.marked = []; });
}

function setHandler() {
	document.body.addEventListener('click', doSomething, false);
	var w = document.getElementById('word');
	var l = document.getElementById('location');

	function toggleM(m) {
		var p = m.closest('p.tu'); // TODO browser support

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

		w.textContent = 'none';
		l.textContent = '';
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

function loadNumber() {
	getPs();
	getFromLocalStorage();
	setHandler();

	if (window.location.search === '?q')
		showPrompt();
}
