<?php
header("Content-Type: application/json");
require 'db.php';

$id_lote = $_GET['id_lote'] ?? null;
$fecha_inicio = $_GET['fecha_inicio'] ?? null;
$num_eventos = $_GET['num_eventos'] ?? null;

if (!$id_lote || !$fecha_inicio || !$num_eventos) {
    echo json_encode(["error" => "Faltan parámetros"]);
    exit;
}

try {
    $stmt = $pdo->prepare("CALL sp_estado_cuenta(?, ?, ?)");
    $stmt->execute([$id_lote, $fecha_inicio, $num_eventos]);
    $estadoCuenta = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($estadoCuenta);
} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta: " . $e->getMessage()]);
}
?>
