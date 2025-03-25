<?php
require_once __DIR__ . '/../api/config/Database.php';

header('Content-Type: application/json');

if (!isset($_GET['id_calendario']) || empty($_GET['id_calendario'])) {
    echo json_encode(['success' => false, 'message' => 'ID no proporcionado']);
    exit;
}

$id_calendario = intval($_GET['id_calendario']);

// Conexión a la base de datos
$database = new Database();
$db = $database->getConnection();

// Consulta ligera solo para mostrar lote, nombre y correo
$sql = "
SELECT
    cp.id_lote AS lote,
    CONCAT(cl.nombres, ' ', cl.apellido_paterno, ' ', cl.apellido_materno) AS nombre_cliente,
    cl.correo_electronico
FROM calendario_pagos cp
INNER JOIN propiedades p ON cp.id_lote = p.id_lote
INNER JOIN ventas ve ON ve.id_lote = p.id_lote
INNER JOIN clientes cl ON ve.id_cliente = cl.id_cliente
WHERE cp.id_calendario = :id_calendario
LIMIT 1
";

try {
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id_calendario', $id_calendario, PDO::PARAM_INT);
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode([
            'success' => true,
            'lote' => $result['lote'],
            'nombre_cliente' => $result['nombre_cliente'],
            'correo_electronico' => $result['correo_electronico']
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No se encontró información.']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error en la base de datos']);
}
