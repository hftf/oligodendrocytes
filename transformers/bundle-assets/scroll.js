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
	var newHTML;
	if (window.pageYOffset > scr)
		newHTML = '↑ Up to next tossup';
	else
		newHTML = '↓ Down to next bonus';

	if (toggle.innerHTML != newHTML)
		toggle.innerHTML = newHTML;
}

function loadScroll() {
	initialScrolls();

	// button: set click handler, initial label
	toggle.onclick = swap;
	label();

	// scroll handler
	/*var didScroll = false;
	window.onscroll = function() { didScroll = true; };
	setInterval(function() {
		if (didScroll) {
			didScroll = false;
			label();
		}
	}, 400);*/
}
