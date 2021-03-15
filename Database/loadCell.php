<?php
$servername = "mysql:host=https://crashing-lands.000webhostapp.com;dbname=id12800521_smartweighingscale";
$username = "id12800521_user";
$password = "!oadCellpsw";

try{
    $db = new PDO ($servername,$username,$password)
    echo "Connected";
}
catch(PDOException $e){
    $error = $e -> getMessage();
    echo $error;
}
    
php>
