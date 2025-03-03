<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$request = $_GET['endpoint'] ?? '';

switch ($request) {
    case 'clientes':
        require 'endpoints/clientes.php';
        break;
    default:
        echo json_encode(["error" => "Endpoint no válido"]);
}
?>
