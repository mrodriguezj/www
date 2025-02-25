<?php
// Configuración general del log
ini_set('log_errors', 1);
ini_set('display_errors', 0); // No mostrar errores en pantalla para producción
ini_set('error_log', __DIR__ . '/../../logs/errores_php.log');

// Función personalizada para registrar mensajes
function registrarErrorPHP($mensaje) {
    $logMessage = "[" . date('Y-m-d H:i:s') . "] ERROR PHP: $mensaje\n";
    error_log($logMessage);
}

// Registrar excepciones no capturadas
set_exception_handler(function ($exception) {
    $mensaje = "Excepción: {$exception->getMessage()} en {$exception->getFile()} línea {$exception->getLine()}";
    registrarErrorPHP($mensaje);
});

// Registrar errores no manejados
set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    $mensaje = "Error [$errno]: $errstr en $errfile línea $errline";
    registrarErrorPHP($mensaje);
});

// Capturar errores fatales al cerrar el script
register_shutdown_function(function () {
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR, E_PARSE])) {
        $mensaje = "Fatal error: {$error['message']} en {$error['file']} línea {$error['line']}";
        registrarErrorPHP($mensaje);
    }
});
?>
