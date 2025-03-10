<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Crear instancia y conexión
$database = new Database();
$conn = $database->getConnection();

// Obtener datos JSON
$data = json_decode(file_get_contents("php://input"));

// Validar datos recibidos
if (!isset($data->fecha_inicio) || !isset($data->fecha_fin)) {
    echo json_encode(["error" => "Debe proporcionar fecha_inicio y fecha_fin"]);
    exit;
}

// Fechas recibidas
$fecha_inicio = $data->fecha_inicio;
$fecha_fin = $data->fecha_fin;
$fecha_consulta = isset($data->fecha_consulta) ? $data->fecha_consulta : date('Y-m-d');

try {
    // Ejecutar procedimiento almacenado
    $stmt = $conn->prepare("CALL proyeccion_pagos_por_rango(?, ?, ?)");
    $stmt->execute([$fecha_inicio, $fecha_fin, $fecha_consulta]);

    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "fecha_inicio" => $fecha_inicio,
        "fecha_fin" => $fecha_fin,
        "fecha_consulta" => $fecha_consulta,
        "resultados" => $resultados
    ]);

} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta: " . $e->getMessage()]);
}
?>
