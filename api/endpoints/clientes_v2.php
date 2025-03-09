<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$database = new Database();
$conn = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->nombres) || !isset($data->apellido_paterno) || !isset($data->correo_electronico) || !isset($data->telefono)) {
    echo json_encode(["error" => "Datos incompletos"]);
    exit;
}

try {
    $stmt = $conn->prepare("CALL insertar_cliente(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        $data->nombres, 
        $data->apellido_paterno, 
        $data->apellido_materno,
        $data->correo_electronico, 
        $data->telefono, 
        $data->curp,
        $data->rfc, 
        $data->ine, 
        $data->direccion, 
        $data->estatus ?? 'Activo'
    ]);

    // Intentamos obtener el mensaje de salida de MySQL
    $response = $stmt->fetch(PDO::FETCH_ASSOC);

    if (isset($response['resultado']) && strpos($response['resultado'], 'Error') !== false) {
        echo json_encode(["error" => $response['resultado']]);
    } else {
        echo json_encode(["success" => "Cliente registrado correctamente."]);
    }

} catch (PDOException $e) {
    echo json_encode(["error" => "Error en la solicitud: " . $e->getMessage()]);
}
?>
