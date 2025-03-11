<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Crear conexión a la BD
$database = new Database();
$conn = $database->getConnection();

// Leer parámetros
$data = json_decode(file_get_contents("php://input"));

// Validar parámetros requeridos
if (!isset($data->fecha_inicio) || !isset($data->fecha_fin)) {
    echo json_encode(["error" => "Debe proporcionar fecha_inicio y fecha_fin"]);
    exit;
}

$fecha_inicio = $data->fecha_inicio;
$fecha_fin = $data->fecha_fin;
$fecha_consulta = isset($data->fecha_consulta) ? $data->fecha_consulta : date('Y-m-d');

$estado_pago = isset($data->estado_pago) ? $data->estado_pago : '';
$cliente_nombre = isset($data->cliente_nombre) ? $data->cliente_nombre : '';

try {
    // Ejecutar procedimiento
    $stmt = $conn->prepare("CALL proyeccion_pagos_totales(?, ?, ?, ?, ?)");
    $stmt->execute([
        $fecha_inicio,
        $fecha_fin,
        $fecha_consulta,
        $estado_pago,
        $cliente_nombre
    ]);

    $totales = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "resumen" => $totales
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "error" => "Error en la consulta de totales: " . $e->getMessage()
    ]);
}
?>
