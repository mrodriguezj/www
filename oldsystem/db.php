<?php
// api/db.php
$host = 'srv1281.hstgr.io';
$dbname = 'u451524807_inmuebles';
$username = 'u451524807_remote';
$password = 'Cxcb0naterr@2024+';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(["error" => "Error de conexión: " . $e->getMessage()]));
}
?>

