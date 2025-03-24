<?php
require_once __DIR__ . '/env_loader.php';

// Cargar las variables del .env
cargarEnv();

// Datos de conexión IMAP desde el archivo .env
$imap_host       = $_ENV['IMAP_HOST']; // ejemplo: imap.hostinger.com
$imap_port       = $_ENV['IMAP_PORT']; // normalmente 993
$imap_user       = $_ENV['MAIL_USERNAME']; // mismo usuario del SMTP
$imap_pass       = $_ENV['MAIL_PASSWORD']; // mismo password
$sent_folder     = $_ENV['IMAP_SENT_FOLDER']; // ejemplo: INBOX.Sent

// Conexión al servidor IMAP
$mailbox = "{" . $imap_host . ":" . $imap_port . "/imap/ssl}" . $sent_folder;

$imap_stream = imap_open($mailbox, $imap_user, $imap_pass);

if (!$imap_stream) {
    echo "❌ Error de conexión IMAP: " . imap_last_error();
    exit;
}

// ⚠️ Aquí debería ir el contenido MIME del correo
// Como ejemplo básico ponemos un mensaje de prueba:
$email_mime = <<<EOD
From: {$_ENV['MAIL_FROM_NAME']} <{$_ENV['MAIL_FROM_ADDRESS']}>\r\n
To: cliente@correo.com\r\n
Subject: Correo guardado en Enviados\r\n
Date: " . date('r') . "\r\n
Content-Type: text/html; charset=UTF-8\r\n
\r\n
<h1>Este es un mensaje de prueba</h1><p>Guardado en la carpeta Enviados vía IMAP.</p>
EOD;

// Subir el mensaje a la carpeta "Sent"
$result = imap_append($imap_stream, $mailbox, $email_mime);

if ($result) {
    echo "✅ Mensaje copiado en '$sent_folder'.";
} else {
    echo "❌ Error al guardar en '$sent_folder': " . imap_last_error();
}

imap_close($imap_stream);
