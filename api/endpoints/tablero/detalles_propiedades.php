<?php
require_once __DIR__ . '/../../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

$categoria = $_GET['categoria'] ?? '';

if (!$categoria) {
    echo json_encode(["success" => false, "message" => "Categoría no especificada"]);
    exit;
}

try {
    switch ($categoria) {

        case 'vendidas':
            $stmt = $conn->prepare("
                SELECT 
                    p.id_lote, 
                    p.tipo, 
                    v.fecha_venta
                FROM ventas v
                INNER JOIN propiedades p ON v.id_lote = p.id_lote
                WHERE p.disponibilidad = 'Vendido'
                ORDER BY v.fecha_venta DESC
            ");
            break;

        case 'disponibles':
        case 'reservadas':
            $disponibilidad = ($categoria === 'disponibles') ? 'Disponible' : 'Reservado';
            $stmt = $conn->prepare("
                SELECT 
                    id_lote, 
                    tipo
                FROM propiedades
                WHERE disponibilidad = :disponibilidad
                ORDER BY id_lote ASC
            ");
            $stmt->bindParam(':disponibilidad', $disponibilidad);
            break;

        default:
            echo json_encode(["success" => false, "message" => "Categoría no válida"]);
            exit;
    }

    $stmt->execute();
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "data" => $data
    ]);

    $stmt->closeCursor();
    $conn = null;

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error en el servidor: " . $e->getMessage()
    ]);
}
