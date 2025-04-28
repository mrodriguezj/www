<?php
require_once __DIR__ . '/../../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

// Leer parámetros GET
$fecha_inicio = $_GET['fecha_inicio'] ?? null;
$fecha_fin = $_GET['fecha_fin'] ?? null;
$categoria_pago = $_GET['categoria_pago'] ?? null;
$metodo_pago = $_GET['metodo_pago'] ?? null;
$limit = $_GET['limit'] ?? 20;  // Valor por defecto: 20 registros
$offset = $_GET['offset'] ?? 0; // Comienza desde el 0

try {
    $stmt = $conn->prepare("CALL cobranza_efectuada(:fecha_inicio, :fecha_fin, :categoria_pago, :metodo_pago, :limit, :offset)");
    
    $stmt->execute([
        ':fecha_inicio' => $fecha_inicio,
        ':fecha_fin' => $fecha_fin,
        ':categoria_pago' => $categoria_pago,
        ':metodo_pago' => $metodo_pago,
        ':limit' => (int)$limit,
        ':offset' => (int)$offset
    ]);

    $pagos = $stmt->fetchAll();

    echo json_encode($pagos);

} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
