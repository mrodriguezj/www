<?php
require_once __DIR__ . '/../config/Database.php';

// Configurar la zona horaria si aplica
date_default_timezone_set('America/Mexico_City');

// Conexión a la base de datos
$database = new Database();
$conn = $database->getConnection();

try {
    // Actualizar pagos que ya deberían estar vencidos
    $sql = "
        UPDATE calendario_pagos
        SET estatus_pago = 'Vencido'
        WHERE estatus_pago = 'Pendiente'
          AND fecha_vencimiento < CURDATE()
          AND monto_restante > 0
    ";

    $stmt = $conn->prepare($sql);
    $stmt->execute();

    // Mostrar resultado en consola/log
    echo date('[Y-m-d H:i:s]') . " Actualización completada. Registros afectados: " . $stmt->rowCount() . PHP_EOL;

} catch (PDOException $e) {
    echo date('[Y-m-d H:i:s]') . " Error en la actualización: " . $e->getMessage() . PHP_EOL;
}
?>
