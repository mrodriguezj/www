<?php
require_once __DIR__ . '/../error_logger.php';

// Provocar un error para probar
echo $undefinedVariable; // Notará un warning
throw new Exception("Excepción de prueba"); // Excepción registrada
