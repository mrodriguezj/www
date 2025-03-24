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

// ✅ Nueva consulta SQL con el método de pago incluido
$sql = "
SELECT
    cp.id_calendario,
    cp.numero_pago,
    cp.fecha_vencimiento,
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
GROUP BY cp.id_calendario
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
// $correoCliente = $result['correo_electronico']; // ✅ Línea comentada para pruebas (correo real)

// ✅ Correo definido manualmente para pruebas
$correoCliente = 'auxiliarfomento@outlook.com'; // Cámbialo para pruebas

$totalPagado = number_format($result['total_pagado'], 2);
$ultimaFechaPago = $result['ultima_fecha_pago'];
$montoRestante = number_format($result['monto_restante'], 2);
$estatusPago = $result['estatus_pago'];

// ✅ Método de pago obtenido dinámicamente (fallback por si viene vacío)
$metodoPago = !empty($result['metodo_pago']) ? $result['metodo_pago'] : 'No especificado';

// Crear instancia de PHPMailer
$mail = new PHPMailer(true);

try {
    // Configuración SMTP
    $mail->isSMTP();
    $mail->Host       = $_ENV['MAIL_HOST'];
    $mail->SMTPAuth   = true;
    $mail->Username   = $_ENV['MAIL_USERNAME'];
    $mail->Password   = $_ENV['MAIL_PASSWORD'];
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port       = $_ENV['MAIL_PORT'];

    // Codificación correcta
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // Configuración de remitente
    $mail->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);

    // ✅ Correo manual para pruebas
    $mail->addAddress($correoCliente, 'Prueba Manual');

    // Copia oculta para control interno
    $mail->addBCC('auxmrodriguez@gmail.com', 'Control Interno');

    // Asunto del correo
    $mail->Subject = 'Estado de Pago - CobranzaWeb';

    // Leer y personalizar la plantilla HTML
    $htmlTemplate = file_get_contents(__DIR__ . '/plantillaResponsiva.html');
    $htmlTemplate = str_replace('[Nombre de la Empresa]', 'CobranzaWeb', $htmlTemplate);
    $htmlTemplate = str_replace('[Nombre del Cliente]', $nombreCliente, $htmlTemplate);
    $htmlTemplate = str_replace('[Cantidad Pagada]', '' . $totalPagado, $htmlTemplate);
    $htmlTemplate = str_replace('[Fecha del Pago]', $ultimaFechaPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Monto Restante]', '$' . $montoRestante, $htmlTemplate);
    $htmlTemplate = str_replace('[Estatus Pago]', $estatusPago, $htmlTemplate);
    $htmlTemplate = str_replace('[Método de Pago]', $metodoPago, $htmlTemplate);

    // Cuerpo del mensaje en HTML y texto alternativo
    $mail->isHTML(true);
    $mail->Body    = $htmlTemplate;
    $mail->AltBody = "Hola $nombreCliente, tu pago total hasta la fecha es $$totalPagado. Último pago realizado el $ultimaFechaPago. Estatus: $estatusPago. Monto restante: $$montoRestante. Método de Pago: $metodoPago.";

    // ✅ Adjuntar PDF si se subió en el formulario
    if (isset($_FILES['archivo_pdf']) && $_FILES['archivo_pdf']['error'] === UPLOAD_ERR_OK) {

        $fileTmpPath = $_FILES['archivo_pdf']['tmp_name'];
        $fileName = $_FILES['archivo_pdf']['name'];
        $fileSize = $_FILES['archivo_pdf']['size'];
        $fileType = $_FILES['archivo_pdf']['type'];
        $fileNameCmps = explode(".", $fileName);
        $fileExtension = strtolower(end($fileNameCmps));

        $allowedfileExtensions = ['pdf'];

        // ✅ Verificar extensión y tipo MIME
        if (in_array($fileExtension, $allowedfileExtensions) && $fileType === 'application/pdf') {

            // ✅ Verificar tamaño (por ejemplo 5MB máximo)
            if ($fileSize > (5 * 1024 * 1024)) {
                echo '❌ El archivo excede el tamaño máximo permitido (5MB).';
                exit;
            }

            // ✅ Adjuntar el PDF al correo
            $mail->addAttachment($fileTmpPath, $fileName);
            echo "✅ Archivo PDF adjuntado correctamente: " . $fileName . "<br>";

        } else {
            echo '❌ El archivo adjunto no es un PDF válido.<br>';
            exit;
        }

    } else {
        echo '⚠️ No se adjuntó ningún archivo PDF.<br>';
    }

    // Enviar el correo
    $mail->send();

    echo '✅ Correo enviado correctamente a ' . $correoCliente;

} catch (Exception $e) {
    echo "❌ Error al enviar el correo: {$mail->ErrorInfo}";
}
