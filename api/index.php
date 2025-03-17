<?php
require_once __DIR__ . '/config/Database.php';

// Permitir acceso CORS (opcional si ya lo tienes)
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Obtener el endpoint desde la URL
$request = $_GET['endpoint'] ?? '';

switch ($request) {
    
    case 'clientes_v2':
        require 'endpoints/clientes_v2.php';
        break;

    case 'clientes_listado':
        require 'endpoints/clientes_listado.php';
        break;

    case 'registrar_venta_y_generar_calendario':
        require 'endpoints/registrar_venta_y_generar_calendario.php';
        break;

    // Agregar futuros endpoints aquí...
    case 'lotes_disponibles':
        require 'endpoints/lotes_disponibles.php';
        break;

    case 'registrar_venta_y_generar_calendario':
        require 'endpoints/registrar_venta_y_generar_calendario.php';
        break;

    case 'registrar_pago':
        require 'endpoints/registrar_pago.php';
        break;

    case 'proyeccion_pagos_totales':
        require 'endpoints/proyeccion_pagos_totales.php';
        break;
    
    case 'detalle_pago':
        require 'endpoints/detalle_pago.php';
        break;

    case 'proyeccion_pagos_detalles':
        require 'endpoints/proyeccion_pagos_detalles.php';
        break;

    case 'totalPagado':
        require 'endpoints/totalPagado.php';
        break;

    case 'carteraVencida':
        require 'endpoints/carteraVencida.php';
        break;

    case 'morosos':
        require 'endpoints/morosos.php';
        break;

    default:
        echo json_encode(["error" => "Endpoint no válido"]);
        break;
}
?>
