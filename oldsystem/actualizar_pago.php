<?php
header("Content-Type: application/json");
require 'db.php'; // Conexión a la BD con PDO

// Obtener el cuerpo de la solicitud en JSON
$data = json_decode(file_get_contents("php://input"), true);

// Verificar que todos los parámetros requeridos están presentes
if (!isset($data["id_pago"], $data["id_lote"], $data["concepto"], $data["monto"], $data["fecha_pago"], $data["metodo_pago"], $data["banco"], $data["periodo_pago"], $data["observaciones"])) {
    echo json_encode(["error" => "Faltan datos obligatorios"]);
    exit;
}

// Asignar valores
$id_pago = intval($data["id_pago"]);
$id_lote = intval($data["id_lote"]); // NUEVO PARAMETRO
$concepto = $data["concepto"];
$monto = floatval($data["monto"]);
$fecha_pago = $data["fecha_pago"];
$metodo_pago = $data["metodo_pago"];
$folio_pago = $data["folio_pago"] ?? null;
$banco = $data["banco"];
$periodo_pago = $data["periodo_pago"];
$observaciones = $data["observaciones"] ?? null;

try {
    // Llamar al procedimiento almacenado con los 10 parámetros correctos
    $stmt = $pdo->prepare("CALL actualizar_pago(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$id_pago, $id_lote, $concepto, $monto, $fecha_pago, $metodo_pago, $folio_pago, $banco, $periodo_pago, $observaciones]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => "Pago actualizado exitosamente"]);
    } else {
        echo json_encode(["error" => "No se encontró el pago o no se realizaron cambios"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la actualización: " . $e->getMessage()]);
}
?>
