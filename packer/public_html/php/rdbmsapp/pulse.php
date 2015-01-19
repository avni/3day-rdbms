<?php

include 'dbparams.php';

mysql_connect ($DB_HOST, $DB_USER, $DB_PASS); 
mysql_select_db ($DB_NAME);

$api_response = array();
$api_response['error'] = null;

// get user count
$result = mysql_query ("select count(*) from users");
if ($row = mysql_fetch_array($result)) {
  $api_response['users'] = $row[0];
} else {
  $api_response['error'] = 'DATABASE';
}

// get status count
$result = mysql_query ("select count(*) from status_updates");
if ($row = mysql_fetch_array($result)) {
  $api_response['statuses'] = $row[0];
} else {
  $api_response['error'] = 'DATABASE';
}

// get friendship count
$result = mysql_query ("select count(*) from friendships");
if ($row = mysql_fetch_array($result)) {
  $api_response['friendships'] = $row[0];
} else {
  $api_response['error'] = 'DATABASE';
}

// return response
header('Content-Type: application/json');
print json_encode($api_response);
