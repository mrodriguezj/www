<?php
require 'vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

$key = "mi_clave_secreta";
$payload = [
    'iss' => 'http://localhost',   // Emisor
    'aud' => 'http://localhost',   // Audiencia
    'iat' => time(),               // Tiempo de emisión
    'nbf' => time(),               // No antes de
    'exp' => time() + 3600         // Expira en 1 hora
];

// Generar token
$jwt = JWT::encode($payload, $key, 'HS256');
echo "Token generado: " . $jwt . "<br>";

// Decodificar token
$decoded = JWT::decode($jwt, new Key($key, 'HS256'));
echo "Token decodificado:<br>";
print_r($decoded);
?>
