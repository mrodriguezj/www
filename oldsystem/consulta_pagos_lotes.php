<?php
// api/consulta_pagos_lotes.php
header("Content-Type: application/json");
require 'db.php'; // Conexión a la BD con PDO

// Validar que se recibió un ID de lote
if (!isset($_GET["id_lote"]) || !is_numeric($_GET["id_lote"])) {
    echo json_encode(["error" => "ID de lote inválido"]);
    exit;
}

$id_lote = intval($_GET["id_lote"]);

try {
    $stmt = $pdo->prepare("CALL consulta_pagos_lotes(?)");
    $stmt->execute([$id_lote]);
    $pagos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($pagos) {
        echo json_encode($pagos);
    } else {
        echo json_encode(["error" => "No se encontraron pagos para este lote"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta: " . $e->getMessage()]);
}
?>
