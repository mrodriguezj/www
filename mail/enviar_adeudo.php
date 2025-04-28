<?php
require_once __DIR__ . '/../api/config/Database.php';
require_once __DIR__ . '/env_loader.php';
require_once __DIR__ . '/../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Cargar variables del entorno
cargarEnv();

// Validar entrada
if (!isset($_POST['id_calendario']) || empty($_POST['id_calendario'])) {
    die('❌ ID de calendario no proporcionado.');
}

$id_calendario = intval($_POST['id_calendario']);

// Conexión a la base de datos
$database = new Database();
$db = $database->getConnection();

// Consulta SQL
$sql = "
SELECT
  cl.nombres,
  cl.apellido_paterno,
  cl.apellido_materno,
  cl.correo_electronico,
  cp.id_lote,
  cp.fecha_vencimiento,
  cp.monto_restante
FROM calendario_pagos cp
INNER JOIN propiedades p ON cp.id_lote = p.id_lote
INNER JOIN ventas v ON v.id_lote = p.id_lote
INNER JOIN clientes cl ON cl.id_cliente = v.id_cliente
WHERE cp.id_calendario = :id_calendario
LIMIT 1;
";

$stmt = $db->prepare($sql);
$stmt->bindParam(':id_calendario', $id_calendario, PDO::PARAM_INT);
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$result) {
    die('❌ No se encontraron datos.');
}

// Preparar datos
$nombre_cliente = trim($result['nombres'] . ' ' . $result['apellido_paterno'] . ' ' . $result['apellido_materno']);
$correo_cliente = $result['correo_electronico'];
$lote = $result['id_lote'];
$fecha_vencimiento = $result['fecha_vencimiento'];
$monto_pendiente = number_format($result['monto_restante'], 2);

// Calcular días de atraso
$hoy = new DateTime();
$fecha_vencimiento_obj = new DateTime($fecha_vencimiento);
$intervalo = $hoy->diff($fecha_vencimiento_obj);
$dias_atraso = $intervalo->invert ? $intervalo->days : 0;

// Definir destinatario real o de prueba
$destinatario = ($_ENV['MAIL_TEST_MODE'] === 'true')
    ? $_ENV['MAIL_TEST_ADDRESS']
    : $correo_cliente;

// Iniciar PHPMailer
$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = $_ENV['MAIL_HOST'];
    $mail->SMTPAuth   = true;
    $mail->Username   = $_ENV['MAIL_USERNAME'];
    $mail->Password   = $_ENV['MAIL_PASSWORD'];
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port       = $_ENV['MAIL_PORT'];
    $mail->CharSet    = 'UTF-8';
    $mail->Encoding   = 'base64';

    $mail->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);
    $mail->addAddress($destinatario, $nombre_cliente);
    $mail->addBCC($_ENV['MAIL_FROM_ADDRESS']); // Opcional copia interna de resguardo

    $mail->Subject = 'Recordatorio de Adeudo';

    // Cargar la plantilla correcta
    $htmlTemplate = file_get_contents(__DIR__ . '/plantillaRecordatorio.html');

    // Reemplazos en la plantilla
    $htmlTemplate = str_replace('[Nombre del Cliente]', $nombre_cliente, $htmlTemplate);
    $htmlTemplate = str_replace('[N.º de Lote]', $lote, $htmlTemplate);
    $htmlTemplate = str_replace('[Fecha de Vencimiento]', $fecha_vencimiento, $htmlTemplate);
    $htmlTemplate = str_replace('[Días de Atraso]', $dias_atraso, $htmlTemplate);
    $htmlTemplate = str_replace('[Monto Pendiente]', $monto_pendiente, $htmlTemplate);
    $htmlTemplate = str_replace('[Enlace de Pago]', 'https://fomentoqroo.com', $htmlTemplate);

    $mail->isHTML(true);
    $mail->Body    = $htmlTemplate;
    $mail->AltBody = "Hola $nombre_cliente, tienes un adeudo de $$monto_pendiente vencido el $fecha_vencimiento.";

    // Adjuntar PDF si se carga
    if (isset($_FILES['archivo_pdf']) && $_FILES['archivo_pdf']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['archivo_pdf']['tmp_name'];
        $fileName = $_FILES['archivo_pdf']['name'];
        if (mime_content_type($fileTmpPath) === 'application/pdf') {
            $mail->addAttachment($fileTmpPath, $fileName);
        }
    }

    $mail->send();
    echo '✅ Correo enviado exitosamente a ' . htmlspecialchars($destinatario);

} catch (Exception $e) {
    echo "❌ Error al enviar el correo: {$mail->ErrorInfo}";
}
