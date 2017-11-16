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
		newHTML = '<div><span class="arr">↑</span><span class="clm">Jump to the<br>next tossup</span></div>';
	else
		newHTML = '<div><span class="arr">↓</span><span class="clm">Jump to the<br>next bonus</span></div>';

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
