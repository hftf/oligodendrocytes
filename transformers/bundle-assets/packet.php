<?php

require_once('get_packet_data.php');

if (!isset($_GET['p'])) {
	die('Missing p parameter');
}

$packet_id = $_GET['p'];

$packet_data = get_packet_data();

$packet = $packet_data[$packet_id];
$packet_name = $packet['name'];
$packet_file = $packet['file'];
$packet_password = $packet['password'];

if (isset($_POST['password'])) {
	$password = $_POST['password'];

	if (strtolower($password) == strtolower($packet_password)) {
		header('Location: ' . $packet_file);
		// include($packet_file);
	}
	else {
		die('Incorrect password for ' . $packet_name);
	}
}
else {
?>
<html>
<body>
<form method="post" action="" autocomplete="off">
<p>Please enter the password for <?php echo $packet_name; ?>.</p>
<p>
<input type="text" name="password" value="" />
<input type="submit" name="submit" value="Submit" />
</p>
</form>
</body>
</html>
<?php
}
?>
