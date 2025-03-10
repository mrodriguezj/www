<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$database = new Database();
$conn = $database->getConnection();

try {
    $input = json_decode(file_get_contents("php://input"), true);

    $fecha_venta = isset($input['fecha_venta']) ? $input['fecha_venta'] : date("Y-m-d");

    $id_cliente = $input['id_cliente'];
    $id_lote = $input['id_lote'];
    $precio_lote = $input['precio_lote'];
    $precio_lista = $input['precio_lista'];
    $descuento = $input['descuento'];
    $autoriza_descuento = $input['autoriza_descuento'];
    $precio_venta = $input['precio_venta'];
    $monto_enganche = $input['monto_enganche'];
    $fecha_pago_enganche = $input['fecha_pago_enganche'];
    $saldo_restante = $input['saldo_restante'];
    $forma_de_pago = $input['forma_de_pago'];
    $plazo_meses = $input['plazo_meses'];
    $mensualidades = $input['mensualidades'];
    $fecha_inicio_pago = $input['fecha_inicio_pago'];
    $observaciones = $input['observaciones'];

    $stmt = $conn->prepare("CALL registrar_venta_y_generar_calendario(
        :id_cliente,
        :id_lote,
        :fecha_venta,
        :precio_lote,
        :precio_lista,
        :descuento,
        :autoriza_descuento,
        :precio_venta,
        :monto_enganche,
        :fecha_pago_enganche,
        :saldo_restante,
        :forma_de_pago,
        :plazo_meses,
        :mensualidades,
        :fecha_inicio_pago,
        :observaciones
    )");

    $stmt->bindParam(':id_cliente', $id_cliente, PDO::PARAM_INT);
    $stmt->bindParam(':id_lote', $id_lote, PDO::PARAM_INT);
    $stmt->bindParam(':fecha_venta', $fecha_venta);
    $stmt->bindParam(':precio_lote', $precio_lote);
    $stmt->bindParam(':precio_lista', $precio_lista);
    $stmt->bindParam(':descuento', $descuento);
    $stmt->bindParam(':autoriza_descuento', $autoriza_descuento);
    $stmt->bindParam(':precio_venta', $precio_venta);
    $stmt->bindParam(':monto_enganche', $monto_enganche);
    $stmt->bindParam(':fecha_pago_enganche', $fecha_pago_enganche);
    $stmt->bindParam(':saldo_restante', $saldo_restante);
    $stmt->bindParam(':forma_de_pago', $forma_de_pago);
    $stmt->bindParam(':plazo_meses', $plazo_meses, PDO::PARAM_INT);
    $stmt->bindParam(':mensualidades', $mensualidades);
    $stmt->bindParam(':fecha_inicio_pago', $fecha_inicio_pago);
    $stmt->bindParam(':observaciones', $observaciones);

    $stmt->execute();

    echo json_encode([
        "success" => true,
        "message" => "Venta registrada correctamente"
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "error" => "Error en la ejecución: " . $e->getMessage()
    ]);
}
