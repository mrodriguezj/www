<?php
require_once __DIR__ . '/../../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$mes = $_GET['mes'] ?? null;
$anio = $_GET['anio'] ?? null;

if (!$mes || !$anio) {
    echo json_encode([
        "success" => false,
        "message" => "Mes y Año son requeridos"
    ]);
    exit;
}

$database = new Database();
$conn = $database->getConnection();

try {
    $stmt = $conn->prepare("CALL sp_obtener_proyeccion_periodo(:mes, :anio)");
    $stmt->bindParam(':mes', $mes, PDO::PARAM_INT);
    $stmt->bindParam(':anio', $anio, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => [
            "proyeccion_cobro" => $result['proyeccion_cobro'] ?? 0,
            "cartera_vencida_periodo" => $result['cartera_vencida_periodo'] ?? 0,
            "porcentaje_recuperacion_periodo" => round($result['porcentaje_recuperacion_periodo'], 2)
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
