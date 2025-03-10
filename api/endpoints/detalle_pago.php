<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Crear instancia y conexión
$database = new Database();
$conn = $database->getConnection();

// Obtener datos JSON
$data = json_decode(file_get_contents("php://input"));

// Validar parámetro id_pago
if (!isset($data->id_pago)) {
    echo json_encode(["error" => "Debe proporcionar el id_pago"]);
    exit;
}

$id_pago = $data->id_pago;

try {
    // Ejecutar procedimiento almacenado
    $stmt = $conn->prepare("CALL detalle_pago_por_id(?)");
    $stmt->execute([$id_pago]);

    // Multi-resultados: primer SELECT es pago principal
    $pago_principal = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Segundo resultado: mensualidades relacionadas
    $stmt->nextRowset();
    $relaciones = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "pago" => $pago_principal,
        "relaciones" => $relaciones
    ]);

} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta: " . $e->getMessage()]);
}
?>
