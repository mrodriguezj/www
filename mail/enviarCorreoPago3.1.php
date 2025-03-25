<?php
require_once __DIR__ . '/../api/config/Database.php';
require_once __DIR__ . '/env_loader.php';
require_once __DIR__ . '/../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Cargar variables de entorno
cargarEnv();

// Validar ID recibido
if (!isset($_POST['id_calendario']) || empty($_POST['id_calendario'])) {
    die('❌ Debes proporcionar un ID de calendario válido.');
}

$id_calendario = intval($_POST['id_calendario']);

// Conexión
$database = new Database();
$db = $database->getConnection();

// Consulta actualizada
$sql = "
SELECT
    cp.id_calendario,
    cp.id_lote AS lote,
    cp.numero_pago,
    cp.fecha_vencimiento,
    cp.categoria_pago,
    cp.monto_programado,
    cp.monto_restante,
    cp.estatus_pago,

    SUM(pr.monto_pagado) AS total_pagado,
    MAX(pr.fecha_pago) AS ultima_fecha_pago,
    MAX(pr.metodo_pago) AS metodo_pago,

    cl.id_cliente,
    CONCAT(cl.nombres, ' ', cl.apellido_paterno, ' ', cl.apellido_materno) AS nombre_cliente,
    cl.correo_electronico
FROM calendario_pagos cp
INNER JOIN pagos_mensualidades_relacion pmr ON pmr.id_calendario = cp.id_calendario
INNER JOIN pagos_realizados pr ON pr.id_pago = pmr.id_pago
INNER JOIN propiedades p ON cp.id_lote = p.id_lote
INNER JOIN ventas ve ON ve.id_lote = p.id_lote
INNER JOIN clientes cl ON ve.id_cliente = cl.id_cliente
WHERE cp.id_calendario = :id_calendario
GROUP BY
    cp.id_calendario,
    cp.id_lote,
    cp.numero_pago,
    cp.fecha_vencimiento,
    cp.categoria_pago,
    cp.monto_programado,
    cp.monto_restante,
    cp.estatus_pago,
    cl.id_cliente,
    cl.nombres,
    cl.apellido_paterno,
    cl.apellido_materno,
    cl.correo_electronico
";

$stmt = $db->prepare($sql);
$stmt->bindParam(':id_calendario', $id_calendario, PDO::PARAM_INT);
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);

// Validar resultado
if (!$result) {
    die('❌ No se encontraron datos para el ID proporcionado.');
}

// Variables desde consulta
$nombreCliente = $result['nombre_cliente'];
//$correoCliente = 'auxmrodriguez@gmail.com'; // 🔧 Dirección manual para pruebas
$correoCliente = $result['correo_electronico'];
$lote = $result['lote'];
$categoriaPago = $result['categoria_pago'] ?? 'Sin categoría';
$montoProgramado = number_format($result['monto_programado'], 2);
$fechaVencimiento = $result['fecha_vencimiento'];
$ultimaFechaPago = $result['ultima_fecha_pago'];
$metodoPago = $result['metodo_pago'] ?? 'No especificado';
$estatusPago = $result['estatus_pago'];
$montoRestante = number_format($result['monto_restante'], 2);
$totalPagado = number_format($result['total_pagado'], 2);

// Crear instancia de PHPMailer
$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = $_ENV['MAIL_HOST'];
    $mail->SMTPAuth   = true;
    $mail->Username   = $_ENV['MAIL_USERNAME'];
    $mail->Password   = $_ENV['MAIL_PASSWORD'];
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port       = $_ENV['MAIL_PORT'];
    $mail->CharSet    = 'UTF-8';
    $mail->Encoding   = 'base64';

    $mail->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);
    $mail->addAddress($correoCliente, 'Prueba Manual');
    $mail->addBCC('auxmrodriguez@gmail.com');
    $mail->addBCC('lcaamal@fomentoqroo.com');
    $mail->addBCC('auxiliarfomento@outlook.com');

    $mail->Subject = 'Confirmación de Pago - Bonaterra';

    // Leer y reemplazar plantilla
    $htmlTemplate = file_get_contents(__DIR__ . '/plantillaResponsiva.html');

    $htmlTemplate = str_replace('[Nombre del Cliente]', $nombreCliente, $htmlTemplate);
    $htmlTemplate = str_replace('[Cantidad Pagada]', $totalPagado, $htmlTemplate);
    $htmlTemplate = str_replace('[Lote]', $lote, $htmlTemplate);
    $htmlTemplate = str_replace('[Categoría de Pago]', $categoriaPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Monto de Pago]', $montoProgramado, $htmlTemplate);
    $htmlTemplate = str_replace('[Fecha de Vencimiento]', $fechaVencimiento, $htmlTemplate);
    $htmlTemplate = str_replace('[Fecha del Pago]', $ultimaFechaPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Método de Pago]', $metodoPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Estatus Pago]', $estatusPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Monto Restante]', $montoRestante, $htmlTemplate);

    $mail->isHTML(true);
    $mail->Body    = $htmlTemplate;
    $mail->AltBody = "Hola $nombreCliente, confirmamos tu pago por $$totalPagado. Categoría: $categoriaPago. Lote: $lote. Fecha de pago: $ultimaFechaPago. Estatus: $estatusPago. Monto restante: $$montoRestante.";

    // Adjuntar PDF si existe
    if (isset($_FILES['archivo_pdf']) && $_FILES['archivo_pdf']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['archivo_pdf']['tmp_name'];
        $fileName = $_FILES['archivo_pdf']['name'];
        $fileSize = $_FILES['archivo_pdf']['size'];
        $fileType = $_FILES['archivo_pdf']['type'];
        $fileNameCmps = explode(".", $fileName);
        $fileExtension = strtolower(end($fileNameCmps));

        $allowedfileExtensions = ['pdf'];
        if (in_array($fileExtension, $allowedfileExtensions) && $fileType === 'application/pdf') {
            if ($fileSize > (5 * 1024 * 1024)) {
                die('❌ El archivo excede el tamaño permitido (5MB).');
            }
            $mail->addAttachment($fileTmpPath, $fileName);
            echo "✅ PDF adjunto: $fileName<br>";
        } else {
            die('❌ El archivo no es un PDF válido.');
        }
    } else {
        echo '⚠️ No se adjuntó archivo PDF.<br>';
    }

    $mail->send();
    echo '✅ Correo enviado correctamente a ' . $correoCliente;

} catch (Exception $e) {
    echo "❌ Error al enviar el correo: {$mail->ErrorInfo}";
}
