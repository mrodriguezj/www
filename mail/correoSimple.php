<?php
require_once __DIR__ . '/env_loader.php';        // Cargar variables del .env
require_once __DIR__ . '/../vendor/autoload.php'; // Cargar PHPMailer

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Cargar variables de entorno desde el archivo .env
cargarEnv();

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

    // ✅ Declarar codificación correctamente
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // Configuración del remitente y destinatario
    $mail->setFrom($_ENV['MAIL_FROM_ADDRESS'], $_ENV['MAIL_FROM_NAME']);
    $mail->addAddress('auxmrodriguez@gmail.com', 'Auxiliar');
    $mail->addBCC('auxiliarfomento@outlook.com');

    // Contenido del correo
    $mail->isHTML(true);
    $mail->Subject = 'Correo de prueba con PHP puro y .env 5';
    $mail->Body    = '<p>¡Hola!</p><p>Enviado con PHP puro, sin frameworks.</p>';
    $mail->AltBody = 'Este es el mensaje alternativo en texto plano.';

    // Enviar el correo
    $mail->send();
    echo '✅ Correo enviado correctamente.<br>';

    // ✅ Llamada al script que guarda el correo en la carpeta "Enviados"
    // Debe llamarse SOLO si el correo se envió con éxito
    require_once __DIR__ . '/imap_sent.php';

} catch (Exception $e) {
    echo "❌ No se pudo enviar el correo. Error: {$mail->ErrorInfo}";
}
