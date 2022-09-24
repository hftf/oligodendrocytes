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
	showStatus();
}
function showStatus() {
	var all_marks;
	try {
		all_marks = JSON.parse(window.localStorage[page_key]);
	} catch (e) {
		all_marks = [];
	}

	var numBuzzes = all_marks.reduce(function(acc, el) { return acc + el.length; }, 0);
	var numTUWithBuzzes = all_marks.reduce(function(acc, el) { return acc + (el.length > 0); }, 0);
	var message = numBuzzes + ' buzz' +
		(numBuzzes == 1 ? ' has' : 'es on ' + numTUWithBuzzes + ' tossup' + (numTUWithBuzzes == 1 ? '' : 's') + ' have') +
		' been stored in your browser’s localStorage';
	
	try {
		var s = document.getElementById('status');
		s.textContent = numBuzzes + ' stored';
		s.setAttribute('title', message);
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
	showStatus();
}

function getPs() {
	// queue of toggled words
	mapTU(function(p, i) {
		p.marked = [];
		p.last = (i >= 19); // at least 20th TU (0-indexed)
	});
}

function setHandler() {
	document.body.addEventListener('click', doSomething, false);
	var w = document.getElementById('word');
	var l = document.getElementById('location');

	function toggleM(m, p) {
		// TODO check p.marked instead of class (word may have multiple parts):
		// <i><m v="101" class="toggle">n</m></i><m v="101">-plus-one</m>
		// right now it's possible to click the same word twice

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

				var p = m.closest('p.tu');
				toggleM(m, p);

				setLocalStorage();
				dirty(true + p.last);
			}
		}
		e.stopPropagation();
	}

	try {
		document.getElementById('reset').addEventListener('click', clearAllBuzzes, false);
		document.getElementById('copy').addEventListener('click', copyBuzzPoints, false);
	} catch (e) {}

	window.addEventListener('beforeunload', function (event) {
		if (window.dirty) {
			document.getElementById('copy').className = 'blink';

			event.preventDefault();
			event.returnValue = '';
		}
	});

	function clearAllBuzzes(e) {
		var really = window.confirm('Are you sure you want to clear all buzzes?');
		if (!really) return;

		mapTU(function(p) { p.marked = []; });
		arrayFrom(
			document.querySelectorAll('m.toggle'),
			function(m) { m.removeAttribute('class'); }
		);

		w.textContent = '';
		l.textContent = 'none';

		try {
			delete window.localStorage[page_key];
		} catch (e) {}

		showStatus();
		dirty(false);
		e.preventDefault();
	}

	function copyBuzzPoints(e) {
		var line_ending = (navigator.platform.indexOf('Win') !== -1) ? '\r\n' : '\n';
		var string = mapTU(function(p) {
			// TODO need null check here
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
		window.alert('The buzz points have been copied! Go to the right side of the scoresheet to paste them.');
		dirty(false);
		e.preventDefault();
	}

	function dirty(newDirty) {
		window.dirty = newDirty;
		if (!newDirty) {
			document.getElementById('copy').className = '';
		}
		else if (newDirty >= 2) {
			document.getElementById('copy').className = 'blink';
		}
	}

	document.getElementById('customize').addEventListener('click', function(e) {
			document.getElementById('style-switcher').showModal();
			e.preventDefault();
		}, false);

	var dialog = document.querySelector('dialog');
	dialog.addEventListener('click',
		function(event) {
			// this works because <dialog> immediately contains <form>,
			// so any click in the dialog proper will at least target the form
			if (event.target === dialog)
				dialog.close();
		}
	);

	// TODO (move elsewhere):
	// 2 pgs at once
	// localstorage
	// ipa chart
	arrayFrom(
		document.querySelectorAll('.style-switcher input[type=radio]'),
		function(a) {
			a.addEventListener('click', styleSwitcher, false);
		}
	);

	function styleSwitcher(e) {
		main.classList.remove(this.dataset.unclass);
		main.classList.add(this.value);
	}

	arrayFrom(
		document.querySelectorAll('button.af-toggle'),
		function(a) {
			a.addEventListener('click', toggleAllDetails, false);
		}
	);

	function toggleAllDetails(e) {
		var toggle = e.target.value === 'true';
		arrayFrom(
			document.querySelectorAll('.tu + details'),
			function(a) {
				a.open = toggle;
			}
		);
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
	var setHasPowers = true, tab;

	// :scope not supported in IE, but this code doesn't matter for moderators
	var pw = selectorLastM(function(p) { return p.querySelectorAll(':scope > b, :scope > strong'); });
	var w  = selectorLastM(function(p) { return [p]; });

	if (setHasPowers) {
		tab = pw.map(function(v, i) { return v + '\t' + w[i]; }).join('\n');
	} else {
		tab = w.map(function(v, i) { return v; }).join('\n');
	}
	window.prompt('', tab);
}

function loadNumber() {
	getPs();
	getFromLocalStorage();
	setHandler();

	if (window.location.search === '?q')
		showPrompt();
}
