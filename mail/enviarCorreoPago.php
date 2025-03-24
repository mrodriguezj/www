<?php
require_once __DIR__ . '/../api/config/Database.php'; // Conexión a la base de datos
require_once __DIR__ . '/env_loader.php';             // Carga el archivo .env
require_once __DIR__ . '/../vendor/autoload.php';     // PHPMailer

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Cargar variables de entorno del .env
cargarEnv();

// Validar el parámetro POST recibido desde el formulario
if (!isset($_POST['id_calendario']) || empty($_POST['id_calendario'])) {
    die('❌ Debes proporcionar un ID de calendario válido.');
}

$id_calendario = intval($_POST['id_calendario']);

// Conexión a la base de datos
$database = new Database();
$db = $database->getConnection();

// Consulta SQL para obtener la información del pago
$sql = "
SELECT
    cp.id_calendario,
    cp.numero_pago,
    cp.fecha_vencimiento,
    cp.monto_programado,
    cp.monto_restante,
    cp.estatus_pago,
    
    pr.id_pago,
    pr.fecha_pago,
    pr.monto_pagado,

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
LIMIT 1
";

$stmt = $db->prepare($sql);
$stmt->bindParam(':id_calendario', $id_calendario, PDO::PARAM_INT);
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);

// Validación si se encontraron datos
if (!$result) {
    die('❌ No se encontraron datos para el ID de calendario proporcionado.');
}

// Datos extraídos de la consulta
$nombreCliente = $result['nombre_cliente'];
// $correoCliente = $result['correo_electronico']; // ✅ Línea comentada por pruebas (correo real del cliente)

// ✅ Correo definido manualmente para pruebas
$correoCliente = 'auxmrodriguez@gmail.com'; // Cambia este correo por el que deseas usar en pruebas

$cantidadPagada = number_format($result['monto_pagado'], 2);
$fechaPago = $result['fecha_pago'];
$metodoPago = 'Transferencia Bancaria'; // Puedes cambiarlo según tus datos
$referenciaPago = 'REF-' . $result['id_pago']; // Generación de referencia simple

// Crear instancia de PHPMailer
$mail = new PHPMailer(true);

try {
    // Configuración del servidor SMTP
    $mail->isSMTP();
    $mail->Host       = $_ENV['MAIL_HOST'];
    $mail->SMTPAuth   = true;
    $mail->Username   = $_ENV['MAIL_USERNAME'];
    $mail->Password   = $_ENV['MAIL_PASSWORD'];
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port       = $_ENV['MAIL_PORT'];

    // Codificación del mensaje
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // Configuración del remitente
    $mail->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);

    // ✅ Destinatarios
    // Línea original comentada para no enviar al cliente real en pruebas
    // $mail->addAddress($correoCliente, $nombreCliente); // Correo leído desde la base de datos

    // ✅ Línea para pruebas: colocar el correo manualmente
    $mail->addAddress($correoCliente, 'Prueba Manual');

    // Copia oculta (BCC) para control interno (opcional)
    $mail->addBCC('asistentefricsa@gmail.com', 'Control Interno');

    // Asunto del mensaje
    $mail->Subject = 'Confirmación de Pago - CobranzaWeb';

    // Leer y personalizar la plantilla HTML
    $htmlTemplate = file_get_contents(__DIR__ . '/plantillaResponsiva.html');
    $htmlTemplate = str_replace('[Nombre de la Empresa]', 'CobranzaWeb', $htmlTemplate);
    $htmlTemplate = str_replace('[Nombre del Cliente]', $nombreCliente, $htmlTemplate);
    $htmlTemplate = str_replace('[Cantidad Pagada]', '$' . $cantidadPagada, $htmlTemplate);
    $htmlTemplate = str_replace('[Fecha del Pago]', $fechaPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Método de Pago]', $metodoPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Número de Referencia]', $referenciaPago, $htmlTemplate);

    // Cuerpo del mensaje en HTML y texto plano alternativo
    $mail->isHTML(true);
    $mail->Body    = $htmlTemplate;
    $mail->AltBody = "Hola $nombreCliente, hemos recibido correctamente tu pago de $$cantidadPagada el $fechaPago. Método: $metodoPago. Referencia: $referenciaPago.";

    // ✅ Adjuntar el PDF si se subió en el formulario
    if (isset($_FILES['archivo_pdf']) && $_FILES['archivo_pdf']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['archivo_pdf']['tmp_name'];
        $fileName = $_FILES['archivo_pdf']['name'];
        $fileSize = $_FILES['archivo_pdf']['size'];
        $fileType = $_FILES['archivo_pdf']['type'];
        $fileNameCmps = explode(".", $fileName);
        $fileExtension = strtolower(end($fileNameCmps));

        $allowedfileExtensions = ['pdf'];
        if (in_array($fileExtension, $allowedfileExtensions) && $fileType === 'application/pdf') {
            // Adjuntamos el PDF al correo
            $mail->addAttachment($fileTmpPath, $fileName);
        } else {
            echo '❌ El archivo adjunto no es un PDF válido.';
            exit;
        }
    }

    // Enviar el correo
    $mail->send();

    echo '✅ Correo enviado correctamente a ' . $correoCliente;

    // (Opcional) Guardar en Enviados vía IMAP
    // require_once __DIR__ . '/imap_sent.php';

} catch (Exception $e) {
    echo "❌ Error al enviar el correo: {$mail->ErrorInfo}";
}
