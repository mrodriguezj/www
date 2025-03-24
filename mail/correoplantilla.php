<?php
require_once __DIR__ . '/env_loader.php';        // Cargar el archivo .env
require_once __DIR__ . '/../vendor/autoload.php'; // Cargar PHPMailer

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Cargar variables de entorno
cargarEnv();

$mail = new PHPMailer(true);

try {
    // Configuración básica del servidor SMTP
    $mail->isSMTP();
    $mail->Host       = $_ENV['MAIL_HOST'];
    $mail->SMTPAuth   = true;
    $mail->Username   = $_ENV['MAIL_USERNAME'];
    $mail->Password   = $_ENV['MAIL_PASSWORD'];
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port       = $_ENV['MAIL_PORT'];

    // ✅ Codificación correcta para evitar símbolos raros
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // Remitente y destinatarios
    $mail->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);
    $mail->addAddress('rodriguezjmisael@icloud.com', 'Misael'); // Cambia esto al destinatario
    $mail->addBCC('auxiliarfomento@outlook.com', 'Control Interno'); // CCO para control
    $mail->addAttachment(__DIR__ . '/archivos/B000337.pdf', 'Comprobante_Pago.pdf');


    // Asunto del correo
    $mail->Subject = 'Confirmación de Pago Recibido Bonaterra';

    // Cargar la plantilla HTML
    $htmlTemplate = file_get_contents(__DIR__ . '/plantillaResponsiva.html');

    // Personalización de datos (simple con str_replace)
    $htmlTemplate = str_replace('[Nombre del Cliente]', 'Juan Pérez', $htmlTemplate);
    $htmlTemplate = str_replace('[Cantidad Pagada]', '1,200.00', $htmlTemplate);
    $htmlTemplate = str_replace('[Fecha del Pago]', '23/03/2025', $htmlTemplate);
    $htmlTemplate = str_replace('[Método de Pago]', 'Transferencia Bancaria', $htmlTemplate);
    $htmlTemplate = str_replace('[Número de Referencia]', 'ABC123456', $htmlTemplate);

    // Cuerpo HTML y alternativo
    $mail->isHTML(true);
    $mail->Body    = $htmlTemplate;
    $mail->AltBody = 'Hola Juan Pérez, hemos recibido correctamente tu pago de $1,200.00 el 23/03/2025. Método de pago: Transferencia Bancaria. Referencia: ABC123456.';

    // Enviar el correo
    $mail->send();
    echo '✅ Correo de confirmación enviado correctamente.<br>';

    // ✅ Guardar en la bandeja "Enviados" (si es necesario)
    //require_once __DIR__ . '/imap_sent.php';

} catch (Exception $e) {
    echo "❌ Error al enviar el correo: {$mail->ErrorInfo}";
}
