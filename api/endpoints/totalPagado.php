<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    $stmt = $conn->prepare("CALL obtener_total_pagado()");
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "total_pagado" => $result['total_pagado'] ?? 0
    ]);

    $stmt->closeCursor();
    $conn = null;

} catch (PDOException $e) {
    echo json_encode([
        "error" => true,
        "message" => "Error: " . $e->getMessage()
    ]);
}
