<?php
// Conexión a la base de datos
$conexion = new mysqli("localhost", "root", "", "cobranza");

// Verificar conexión
if ($conexion->connect_error) {
    die("Conexión fallida: " . $conexion->connect_error);
}

// Consulta estándar
$sql = "SELECT id, nombre, precio FROM productos";
$resultado = $conexion->query($sql);

// Convertir resultados a un arreglo
$productos = [];
while ($fila = $resultado->fetch_assoc()) {
    $productos[] = $fila;
}

// Devolver como JSON
header('Content-Type: application/json');
echo json_encode($productos);

// Cerrar conexión
$conexion->close();
?>
