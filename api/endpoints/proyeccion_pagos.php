<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$database = new Database();
$conn = $database->getConnection();

// Captura el JSON de entrada
$data = json_decode(file_get_contents("php://input"));

// Validaciones básicas
if (!isset($data->fecha_inicio) || !isset($data->fecha_fin)) {
    echo json_encode(["error" => "Debe proporcionar fecha_inicio y fecha_fin"]);
    exit;
}

// Fechas y filtros básicos
$fecha_inicio = $data->fecha_inicio;
$fecha_fin = $data->fecha_fin;
$fecha_consulta = isset($data->fecha_consulta) ? $data->fecha_consulta : date('Y-m-d');

// Filtros opcionales
$estado_pago = isset($data->estado_pago) ? $data->estado_pago : '';
$cliente_nombre = isset($data->cliente_nombre) ? $data->cliente_nombre : '';

// Paginación
$pagina = isset($data->pagina) ? (int)$data->pagina : 1;
$registros_por_pagina = isset($data->registros_por_pagina) ? (int)$data->registros_por_pagina : 20;

$offset = ($pagina - 1) * $registros_por_pagina;

try {
    // Llamada al procedimiento almacenado
    $stmt = $conn->prepare("CALL proyeccion_pagos_por_rango_v2(?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        $fecha_inicio,
        $fecha_fin,
        $fecha_consulta,
        $estado_pago,
        $cliente_nombre,
        $registros_por_pagina,
        $offset
    ]);

    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Respuesta JSON
    echo json_encode([
        "pagina" => $pagina,
        "registros_por_pagina" => $registros_por_pagina,
        "resultados" => $resultados
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "error" => "Error en la consulta: " . $e->getMessage()
    ]);
}
?>
