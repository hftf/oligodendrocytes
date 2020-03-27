<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-8654955-5"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());

gtag('config', 'UA-8654955-5');
</script>
<style>
body { text-decoration-skip-ink: none; }
.parts span { color: #999; }
.parts kbd {
	padding: 0.2em 0.6em;
	background-color: #ffffed;
	border: 1px solid #d9d9d9;
}
kbd.key {
	display: inline-block;
	font-size: 0.8em;
	margin: auto 3px;
	padding: 0.2em 0.6em;
	font-family: sans-serif;
	line-height: 1.4;
	color: #222;
	background-color: #eee;
	border: 1px solid #999;
	border-radius: 3px;
	box-shadow: 1px 0px 1px 0 #eee, 0 2px 0 2px #ccc, 0 2px 0 3px #999;
}
</style>

<title>List of packets</title>
</head>
<body>
<p>Moderators must keep URLs and passwords a secret.<br />
Do not share them with any player, even after the tournament!</p>
<h2>List of packets</h2>
<!-- <p>Version 2018-xx-xx &middot; <a href="../../packets/html/">Version 2018-xx-yy</a></p>
<p>This site will eventually be disabled; it is not intended to be a permanent packet archive.</p> -->
<ul>
<?php

require_once('get_packet_data.php');

$packet_data = get_packet_data();

foreach ($packet_data as $packet) {
	echo '<li><a href="packet.php?p=' . $packet['id'] . '"><b>' . $packet['name'] . '</b></a></li>' . "\n";
}

?>
</ul>
<p>Please make sure to use a <strong>modern, up-to-date browser</strong> (such as Google Chrome; do not use Internet Explorer) to view the online packets.</p>
<?php if (file_exists('password-pdfs.zip')) { ?>
<p><a href="password-pdfs.zip">A zip of the packets as password-protected PDFs, intended for use as a backup only. Download at the beginning of the day.</a></p>
<?php } ?>
<hr />
<h2>Tips</h2>
<ol>
<li><p class="parts">Enter bonus parts as a string of three digits (<kbd>0</kbd> or <kbd>1</kbd>) in the yellow <u>Parts</u> column (e.g. <kbd>111</kbd> = 30 points, <kbd>000</kbd> = 0 points). The other columns (<span>1</span>, <span>2</span>, and <span>3</span> are hidden) will automatically be filled out.</p>
<p><img src="bonus.png" width="352" /></p></li>
<li><p>The buzz point data is saved in your browser. If you forgot to paste in the buzz points, you can just go back to the packet later and export them.<br />
If you have a problem exporting, leave the tab open and try to salvage the data later.</p></li>
<li><p>To easily jump between tossups and bonuses, press <kbd class="key">J</kbd> or click the button at the bottom of the page.</p></li>
<li><p>Use the <u>Notes</u> columns for: Recording in-game events, such as negs or protests, or mistakes in the packet.<br />
Insert a <u>comment</u> for: Notifying me of anomalies, such as thrown out or misaligned questions, that affect the scoresheet’s correctness. Explain your situation as clearly as possible.</p></li>
<li><details><summary><i>Optional:</i> How to annotate the online packets (click to expand)</summary>
<p>Annotations can be useful for alerting the editors, and other moderators around the world, about an issue in the packets.<br />
If you would like to annotate the online packets, you will need a <a href="https://web.hypothes.is/">Hypothesis</a> account.</p>
<ol>
<li>Join the tournament’s private annotation group using the invitation link provided by the TD.</li>
<li>Select the tournament’s private annotation group in the annotation sidebar. <em>Do not make any public annotations.</em></li>
<li>After the tournament, you will be asked to delete your annotations.</li>
</ol>
<p>Read more annotation instructions <a href="http://minkowski.space/quizbowl/manuals/scorekeeping/moderator.html#hypothesis">here</a> (see list item 2 under “Annotations”).</p>
</details></li>
</ol>
<hr />
<p>Email quizbowl@ophir.li if you have any issues.</p>
</body>
</html>
