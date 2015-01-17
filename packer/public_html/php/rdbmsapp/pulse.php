{<?php
include 'dbparams.php';

mysql_connect ($DB_HOST, $DB_USER, $DB_PASS); 
mysql_select_db ($DB_NAME);

// variable to indicate any errors
$error = false;

// get user count
$result = mysql_query ("select count(*) from users");
if ($row = mysql_fetch_array($result)) {
    print '"users": '.$row[0].",";
}
else { $error = true; }

// get status count
$result = mysql_query ("select count(*) from status_updates");
if ($row = mysql_fetch_array($result)) {
    print '"statuses": '.$row[0].",";
}
else { $error = true; }

// get friendship count
$result = mysql_query ("select count(*) from friendships");
if ($row = mysql_fetch_array($result)) {
    print '"friendships": '.$row[0].",";
}
else { $error = true; }

if($error==false) {
    print '"error": "NONE"';
}
else {
    print '"error": "DATABASE"';
}

?>}

