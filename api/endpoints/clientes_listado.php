<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    // Llamamos el procedimiento almacenado
    $stmt = $conn->prepare("CALL listar_clientes_activos()");
    $stmt->execute();

    $clientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($clientes);

} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la consulta de clientes: " . $e->getMessage()]);
}
?>
