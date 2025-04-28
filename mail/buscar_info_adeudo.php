<?php
require_once __DIR__ . '/../api/config/Database.php'; // Ajusta la ruta si es necesario

header('Content-Type: application/json');

if (!isset($_GET['id_calendario']) || empty($_GET['id_calendario'])) {
    echo json_encode(['success' => false, 'message' => 'ID de calendario no proporcionado.']);
    exit;
}

$id_calendario = intval($_GET['id_calendario']);

$database = new Database();
$db = $database->getConnection();

$sql = "
SELECT
  cl.nombres,
  cl.apellido_paterno,
  cl.apellido_materno,
  cl.correo_electronico,
  cp.id_lote,
  cp.fecha_vencimiento,
  cp.monto_restante
FROM calendario_pagos cp
INNER JOIN propiedades p ON cp.id_lote = p.id_lote
INNER JOIN ventas v ON v.id_lote = p.id_lote
INNER JOIN clientes cl ON cl.id_cliente = v.id_cliente
WHERE cp.id_calendario = :id_calendario
LIMIT 1;
";

try {
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id_calendario', $id_calendario, PDO::PARAM_INT);
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        $nombre_cliente = trim($result['nombres'] . ' ' . $result['apellido_paterno'] . ' ' . $result['apellido_materno']);
        $correo = $result['correo_electronico'];
        $lote = $result['id_lote'];
        $fecha_vencimiento = $result['fecha_vencimiento'];
        $monto_pendiente = number_format($result['monto_restante'], 2);

        // Calcular días de atraso
        $hoy = new DateTime();
        $fecha_vencimiento_obj = new DateTime($fecha_vencimiento);
        $intervalo = $hoy->diff($fecha_vencimiento_obj);
        $dias_atraso = $intervalo->invert ? $intervalo->days : 0; // Si está vencido, mostrar días; si no, 0

        echo json_encode([
            'success' => true,
            'nombre_cliente' => $nombre_cliente,
            'correo' => $correo,
            'lote' => $lote,
            'fecha_vencimiento' => $fecha_vencimiento,
            'monto_pendiente' => $monto_pendiente,
            'dias_atraso' => $dias_atraso
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No se encontró información para ese ID.']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error en la base de datos: ' . $e->getMessage()]);
}
