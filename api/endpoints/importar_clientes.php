<?php
require_once __DIR__ . '/../config/Database.php';

header("Content-Type: application/json");

$database = new Database();
$conn = $database->getConnection();

$csvFile = __DIR__ . '/clientesCSV.csv'; // Cambia la ruta según donde tengas el archivo

if (!file_exists($csvFile)) {
    echo json_encode(["error" => "Archivo CSV no encontrado"]);
    exit;
}

$row = 0;
$success = 0;
$errores = [];

if (($handle = fopen($csvFile, "r")) !== FALSE) {

    $headers = fgetcsv($handle, 1000, ","); // Leer cabeceras

    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $row++;

        // Mapeo de los campos en el mismo orden del CSV
        $nombres = $data[0];
        $apellido_paterno = $data[1];
        $apellido_materno = $data[2];
        $correo_electronico = $data[3];
        $telefono = $data[4];
        $curp = $data[5];
        $rfc = $data[6];
        $ine = $data[7];
        $direccion = $data[8];
        $estatus = isset($data[9]) ? $data[9] : 'Activo'; // Default si no viene

        try {
            $stmt = $conn->prepare("CALL cliente_csv(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $nombres,
                $apellido_paterno,
                $apellido_materno,
                $correo_electronico,
                $telefono,
                $curp,
                $rfc,
                $ine,
                $direccion,
                $estatus
            ]);

            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor(); // Esto evita el error de result sets pendientes

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
