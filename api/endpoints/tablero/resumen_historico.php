<?php
require_once __DIR__ . '/../../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    $stmt = $conn->prepare("CALL sp_obtener_resumen_historico()");
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => [
            "total_cobrado" => $result['total_cobrado'] ?? 0,
            "cartera_vencida" => $result['cartera_vencida'] ?? 0,
            "porcentaje_recuperacion" => round($result['porcentaje_recuperacion'], 2)
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
