create database cobranza;

use cobranza;

CREATE TABLE propiedades (
    id_lote INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del lote',
    dimensiones DECIMAL(8,2) NOT NULL COMMENT 'Dimensiones del lote en metros cuadrados',
    precio DECIMAL(10,2) NOT NULL COMMENT 'Precio de la propiedad',
    tipo ENUM('Premium', 'Regular', 'Comercial') NOT NULL COMMENT 'Tipo de lote',
    disponibilidad ENUM('Disponible', 'Vendido', 'Reservado') NOT NULL COMMENT 'Estado de disponibilidad',
    desarrollo VARCHAR(50) NOT NULL COMMENT 'Nombre del desarrollo o fraccionamiento',
    etapa TINYINT UNSIGNED NOT NULL COMMENT 'Número de etapa (entero positivo y pequeño)',
    calle ENUM(
        'Calle Colibri',
        'Calle Quetzal',
        'Calle Aguila',
        'Calle Paloma',
        'Avenida Ramal Norte'
    ) NOT NULL COMMENT 'Calle donde se ubica la propiedad',
    observaciones TEXT COMMENT 'Comentarios adicionales sobre la propiedad'
);

CREATE TABLE clientes (
    id_cliente INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del cliente',
    nombres VARCHAR(50) NOT NULL COMMENT 'Nombre(s) del cliente',
    apellido_paterno VARCHAR(50) NOT NULL COMMENT 'Apellido paterno del cliente',
    apellido_materno VARCHAR(50) COMMENT 'Apellido materno del cliente',
    correo_electronico VARCHAR(100) NOT NULL UNIQUE COMMENT 'Correo electrónico único',
    telefono CHAR(10) NOT NULL COMMENT 'Teléfono a 10 dígitos',
    curp CHAR(18) NOT NULL UNIQUE COMMENT 'CURP del cliente',
    rfc CHAR(13) NOT NULL UNIQUE COMMENT 'RFC del cliente',
    ine CHAR(18) NOT NULL UNIQUE COMMENT 'Número de identificación oficial (INE)',
    direccion VARCHAR(100) COMMENT 'Dirección completa en una sola línea',
    estatus ENUM('Activo', 'Inactivo') DEFAULT 'Activo' COMMENT 'Estado del cliente'
);
