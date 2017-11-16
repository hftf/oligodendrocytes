function initialScrolls() {
	scr = bon = bonuses.offsetTop - main.offsetTop; // TODO getElementById
}
function swap() {
	tmp = window.pageYOffset;
	window.scroll(0, scr);
	scr = tmp;
	label();
}
function label() {
	toggle.className = (window.pageYOffset > scr) ? 'up' : 'down';
}

function loadScroll() {
	initialScrolls();

	// button: set click handler, initial label
	toggle.onclick = swap;

	// scroll handler
	/*var didScroll = false;
	window.onscroll = function() { didScroll = true; };
	setInterval(function() {
		if (didScroll) {
			didScroll = false;
			label();
		}
	}, 400);*/

	window.onkeydown = function (e) {
		if (e.keyCode === 74) { // J
			swap();
		}
	};
}
