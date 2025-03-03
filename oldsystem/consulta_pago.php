<?php
// api/consulta_pago.php
header("Content-Type: application/json");
require 'db.php'; // Conexión a la base de datos

// Validar si se recibió un ID
if (!isset($_GET["id_pago"]) || !is_numeric($_GET["id_pago"])) {
    echo json_encode(["error" => "ID de pago inválido"]);
    exit;
}

$id_pago = intval($_GET["id_pago"]);

try {
    $stmt = $pdo->prepare("CALL consulta_pago_id(?)");
    $stmt->execute([$id_pago]);

    $pago = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($pago) {
        echo json_encode($pago);
    } else {
        echo json_encode(["error" => "No se encontró un pago con ese ID"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta: " . $e->getMessage()]);
}
?>
