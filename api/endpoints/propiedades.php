<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");

$database = new Database();
$conn = $database->getConnection();

$csvFile = __DIR__ . '/propiedadesCSV.csv';

if (!file_exists($csvFile)) {
    echo json_encode(["error" => "Archivo CSV no encontrado"]);
    exit;
}

$row = 0;
$success = 0;
$errores = [];

if (($handle = fopen($csvFile, "r")) !== FALSE) {

    $headers = fgetcsv($handle, 1000, ",");

    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $row++;

        $dimensiones = $data[0];
        $precio = $data[1];
        $tipo = $data[2];
        $disponibilidad = $data[3];
        $desarrollo = $data[4];
        $etapa = $data[5];
        $calle = $data[6];
        $observaciones = isset($data[7]) ? $data[7] : '';

        try {
            $stmt = $conn->prepare("CALL insertar_propiedad(?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $dimensiones,
                $precio,
                $tipo,
                $disponibilidad,
                $desarrollo,
                $etapa,
                $calle,
                $observaciones
            ]);

            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            // **Cerrar el cursor para evitar el error 2014**
            $stmt->closeCursor();

            if (!$result || strpos($result['resultado'], 'Error') !== false) {
                $errorMsg = $result ? $result['resultado'] : 'Error desconocido al procesar la fila';
                $errores[] = "Fila $row: $errorMsg";
            } else {
                $success++;
            }

        } catch (PDOException $e) {
            $errores[] = "Fila $row: " . $e->getMessage();
        }
    }

    fclose($handle);

    echo json_encode([
        "total_registros_procesados" => $row,
        "insertados_correctamente" => $success,
        "errores" => $errores
    ]);

} else {
    echo json_encode(["error" => "No se pudo abrir el archivo CSV"]);
}
?>
