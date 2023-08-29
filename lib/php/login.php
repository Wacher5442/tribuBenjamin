<?php
include "connection.php";
include "crypto.php";

$nom = decrypt($_POST['nom']);
$contact = decrypt($_POST['contact']);

try {
    if (isset($nom, $contact)) {
        $req = $db->prepare("SELECT * FROM members WHERE nom=? AND contact=?");
        $req->execute(array($nom, $contact));
        $exist = $req->rowCount();
        if ($exist == 1) {
            $array = $req->fetch();
            $msg = "Connection réussie";
            $succes = 1;
        } else {
            $msg = "Nom ou Contact incorrect";
            $succes = 0;
        }
    } else {
        $succes = 0;
        $msg = "Données eronées";
    }
} catch (\Throwable $th) {
    $succes = 0;
    $msg = "Error: " . $th->getMessage();
}
echo encrypt(json_encode([
    "data" => [
        $msg,
        $succes,
        $array
    ]
]));
