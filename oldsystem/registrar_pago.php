<?php
header("Content-Type: application/json");
require 'db.php';

// 🔹 Establecer zona horaria y obtener la fecha/hora correcta
date_default_timezone_set("America/Mexico_City");
$fecha_registro = date("Y-m-d H:i:s"); // Obtener la fecha y hora actual en la zona horaria correcta

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data["id_lote"], $data["concepto"], $data["monto"], $data["fecha_pago"], $data["metodo_pago"], $data["banco"], $data["periodo_pago"])) {
    echo json_encode(["error" => "Faltan datos obligatorios"]);
    exit;
}

$id_lote = intval($data["id_lote"]);
$concepto = $data["concepto"];
$monto = floatval($data["monto"]);
$fecha_pago = $data["fecha_pago"];
$metodo_pago = $data["metodo_pago"];
$folio_pago = $data["folio_pago"] ?? null;
$banco = $data["banco"];
$periodo_pago = $data["periodo_pago"];
$observaciones = $data["observaciones"] ?? null;

try {
    // 🔹 Ahora enviamos 10 parámetros, incluyendo `fecha_registro`
    $stmt = $pdo->prepare("CALL sp_registrar_pago(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$id_lote, $concepto, $monto, $fecha_pago, $metodo_pago, $folio_pago, $banco, $periodo_pago, $observaciones, $fecha_registro]);

    echo json_encode(["success" => "Pago registrado correctamente"]);
} catch (PDOException $e) {
    echo json_encode(["error" => "Error en el registro: " . $e->getMessage()]);
}
?>
