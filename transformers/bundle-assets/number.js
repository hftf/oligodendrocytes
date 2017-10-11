var FAR = findAndReplaceDOMText;
// http://velocityjs.org/blast/

function getPs() {
	var x = document.body.getElementsByClassName('tu');
	var j = 0;

	// using unnamed group to keep ^ and $ outside of | scope
	var no = /^(?:\(\*\)|[\/,\.“”]+)$/;

	// TODO fix final punctuation kerning (foo</m>.)

	function replace(portion) {
		var tn = document.createTextNode(portion.text);
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

window.onload = function() {
	getPs();
	setHandler();
	// prompt('',Array.from(document.querySelectorAll('.tu b')).map(v=>Array.from(v.querySelectorAll('m')).pop().dataset.v).join("\n"))
}
