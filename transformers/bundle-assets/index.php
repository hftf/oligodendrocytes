<!DOCTYPE html>
<html>
<head>
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-8654955-5"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());

gtag('config', 'UA-8654955-5');
</script>

<title>List of packets</title>
</head>
<body>
<p>Moderators must keep URLs and passwords a secret.<br />
Do not share them with any player, even after the tournament!</p>
<h2>List of packets</h2>
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
<!-- <p><a href="password-pdfs.zip">A zip of the packets as password-protected PDFs, intended for use as a backup only. Download at the beginning of the day.</a></p> -->
</body>
</html>
