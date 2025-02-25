<?php
// Llamada a tu módulo de captura de errores
require_once __DIR__ . '../../api/errores/error_logger.php';

// Error intencional: Llamar a una función no definida
noExisteFuncion(); 

// También puedes probar otros tipos de errores como:
// include('archivo_inexistente.php'); // Genera un warning
// echo $variableNoDefinida; // Aviso por variable no definida
?>
