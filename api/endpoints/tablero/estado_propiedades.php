<?php
require_once __DIR__ . '/../../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    $stmt = $conn->prepare("CALL sp_obtener_estado_propiedades()");
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => [
            "vendidas" => $result['vendidas'] ?? 0,
            "disponibles" => $result['disponibles'] ?? 0,
            "reservadas" => $result['reservadas'] ?? 0
        ]
    ]);

    $stmt->closeCursor();
    $conn = null;

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
