<?php
$host = "localhost";
$dbname = "id20747350_banjamindb";
$user = "id20747350_benjamin";
$pass = "Webhost5442@";

try {
    $db = new PDO("mysql:host=$host; dbname=$dbname", $user, $pass);
    echo "connected";
} catch (\Throwable $th) {
    echo "Error: " . $th->getMessage();
}
