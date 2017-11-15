function initialScrolls() {
	scr = bon = bonuses.offsetTop - main.offsetTop; // TODO getElementById
}
function swap() {
	tmp = window.pageYOffset;
	window.scroll(0, scr);
	scr = tmp;
}
function setHandler2() {
	toggle.onclick = swap;
}

function loadScroll() {
	initialScrolls();
	setHandler2();
}
