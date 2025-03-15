<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

try {
    // Conectar a la base de datos
    $database = new Database();
    $conn = $database->getConnection();

    $input = json_decode(file_get_contents("php://input"), true);

    // Validar datos obligatorios
    if (!isset(
        $input['id_lote'],
        $input['fecha_pago'],
        $input['monto_pagado'],
        $input['categoria_pago'],
        $input['metodo_pago'],
        $input['porcentaje_comision']
    )) {
        echo json_encode(["error" => "Datos incompletos."]);
        exit;
    }

    // Capturar variables del JSON recibido
    $id_lote = $input['id_lote'];
    $fecha_pago = $input['fecha_pago'];
    $monto_pagado = $input['monto_pagado'];
    $categoria_pago = $input['categoria_pago'];
    $metodo_pago = $input['metodo_pago'];
    $referencia_pago = !empty($input['referencia_pago']) ? $input['referencia_pago'] : null;
    $observaciones = !empty($input['observaciones']) ? $input['observaciones'] : null;
    $porcentaje_comision = $input['porcentaje_comision'];

    // Preparar el llamado al procedimiento almacenado
    $stmt = $conn->prepare("
        CALL registrar_pago(
            :id_lote,
            :fecha_pago,
            :monto_pagado,
            :categoria_pago,
            :metodo_pago,
            :referencia_pago,
            :observaciones,
            :porcentaje_comision
        )
    ");

    // Vincular parámetros
    $stmt->bindParam(':id_lote', $id_lote, PDO::PARAM_INT);
    $stmt->bindParam(':fecha_pago', $fecha_pago);
    $stmt->bindParam(':monto_pagado', $monto_pagado);
    $stmt->bindParam(':categoria_pago', $categoria_pago);
    $stmt->bindParam(':metodo_pago', $metodo_pago);
    $stmt->bindParam(':referencia_pago', $referencia_pago);
    $stmt->bindParam(':observaciones', $observaciones);
    $stmt->bindParam(':porcentaje_comision', $porcentaje_comision);

    // Ejecutar el procedimiento
    $stmt->execute();

    echo json_encode([
        "success" => true,
        "message" => "Pago registrado correctamente."
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Error en la ejecución: " . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Error general: " . $e->getMessage()
    ]);
}
?>
