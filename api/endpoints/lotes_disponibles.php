<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    $stmt = $conn->prepare("CALL listar_lotes_disponibles()");
    $stmt->execute();

    $rawLotes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Conversión explícita de campos DECIMAL / NUMERIC a float o int
    $lotes = array_map(function($lote) {
        return [
            'id_lote'     => (int)$lote['id_lote'],
            'descripcion' => $lote['descripcion'],
            'precio'      => (float)$lote['precio']  // ✅ Aquí convertimos el precio
        ];
    }, $rawLotes);

    echo json_encode($lotes);

} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta de lotes: " . $e->getMessage()]);
}
?>
