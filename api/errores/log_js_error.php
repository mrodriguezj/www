<?php
require_once __DIR__ . '/error_logger.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

if (!$data || empty($data['mensaje'])) {
    http_response_code(400);
    echo json_encode(["error" => "Datos incompletos."]);
    exit;
}

// Formateo del mensaje para el log
$logMessage = "[" . date('Y-m-d H:i:s') . "] ERROR JS: " .
    "Mensaje: {$data['mensaje']} | " .
    "Archivo: {$data['archivo']} | Línea: {$data['linea']} | Columna: {$data['columna']} | " .
    "Navegador: {$data['navegador']} | URL: {$data['url']} | " .
    "Stack: " . ($data['stack'] ?? 'No disponible') . "\n";

// Registrar en el log de JS
file_put_contents(__DIR__ . '/../../logs/errores_js.log', $logMessage, FILE_APPEND);

echo json_encode(["status" => "Error registrado exitosamente."]);
