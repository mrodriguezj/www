<?php
require_once __DIR__ . '/../../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    $stmt = $conn->prepare("CALL sp_obtener_pagos_vencidos()");
    $stmt->execute();

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $results
    ]);

    $stmt->closeCursor();
    $conn = null;

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
