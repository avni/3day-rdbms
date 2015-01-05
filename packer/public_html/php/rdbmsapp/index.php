<html>
<head>
<title>PHP Select</title>
<style>
table{padding:10px}
th,td{padding:5px 20px 5px 0px; text-align:left}
</style>
</head>

<body>
<table>
<tr><th>Breed</th><th>Characteristics</th></tr>

<?php
include 'dbparams.php';

mysql_connect ($DB_HOST, $DB_USER, $DB_PASS); 
mysql_select_db ($DB_NAME);

// our basic query
$result = mysql_query ("select * from dog_breeds");

// loop through the results and print them to the page
if ($row = mysql_fetch_array($result)) {
do
{
	print "<tr><td>";
	print $row["breed_name"];
	print "</td><td>";
	print $row["characteristics"];
	print ("</td></tr>");
} while($row = mysql_fetch_array($result)); }

else {print "Sorry, no records were found!";}

?>
</table>
</body>
</html>
