<?php
require_once __DIR__ . '/Database.php';

$database = new Database();
$conn = $database->getConnection();

if ($conn) {
    echo json_encode(["success" => "Conexion a la base de datos exitosa"]);
} else {
    echo json_encode(["error" => "No se pudo conectar a la base de datos"]);
}
?>
