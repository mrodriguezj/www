<?php
// Conexión a la base de datos
require_once __DIR__ . '/../config/Database.php'; // Ajusta si es necesario

// Configura cabeceras si es necesario
header("Content-Type: application/json");

$database = new Database();
$conn = $database->getConnection();

// Ruta al CSV (ajusta la ruta según tu entorno)
$csvFile = __DIR__ . '/mensualidadesCSV.csv';

// Abre el CSV
if (!file_exists($csvFile)) {
    die("❌ Archivo CSV no encontrado: $csvFile");
}

$handle = fopen($csvFile, 'r');

// Leer encabezados
$header = fgetcsv($handle);

$registro = 0;

while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
    $registro++;

    // Asignar valores
    $id_lote             = $data[0];
    $fecha_pago          = $data[1];
    $monto_pagado        = $data[2];
    $categoria_pago      = $data[3];
    $metodo_pago         = $data[4];
    $referencia_pago     = $data[5] ?: null;
    $observaciones       = $data[6] ?: null;
    $porcentaje_comision = $data[7];

    try {
        $stmt = $conn->prepare("CALL registrar_pago(
            :id_lote,
            :fecha_pago,
            :monto_pagado,
            :categoria_pago,
            :metodo_pago,
            :referencia_pago,
            :observaciones,
            :porcentaje_comision
        )");

        // Vincular parámetros
        $stmt->bindParam(':id_lote', $id_lote, PDO::PARAM_INT);
        $stmt->bindParam(':fecha_pago', $fecha_pago);
        $stmt->bindParam(':monto_pagado', $monto_pagado);
        $stmt->bindParam(':categoria_pago', $categoria_pago);
        $stmt->bindParam(':metodo_pago', $metodo_pago);
        $stmt->bindParam(':referencia_pago', $referencia_pago);
        $stmt->bindParam(':observaciones', $observaciones);
        $stmt->bindParam(':porcentaje_comision', $porcentaje_comision);

        $stmt->execute();

        echo "✅ Registro #$registro procesado correctamente (Lote: $id_lote, Fecha: $fecha_pago)\n";

    } catch (PDOException $e) {
        echo "❌ Error en el registro #$registro (Lote: $id_lote): " . $e->getMessage() . "\n";
    }
}

fclose($handle);

echo "\n🚀 Proceso completado. Se procesaron $registro registros.\n";
?>
