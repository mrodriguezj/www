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


CREATE TABLE ventas (
    id_venta INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la venta.',

    id_lote INT UNSIGNED NOT NULL COMMENT 'Referencia a la propiedad adquirida.',
    id_cliente INT UNSIGNED NOT NULL COMMENT 'Referencia al cliente que compra la propiedad.',

    fecha_venta DATE NOT NULL COMMENT 'Fecha real en que se formalizó la venta.',
    fecha_captura TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha automática cuando se registra la venta en el sistema.',

    precio_lote DECIMAL(10,2) NOT NULL COMMENT 'Precio base de la propiedad según la tabla propiedades.',
    precio_lista DECIMAL(10,2) NOT NULL COMMENT 'Precio actualizado al momento de la venta.',
    descuento DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Descuento aplicado sobre el precio base.',
    autoriza_descuento ENUM('L. Ibarra', 'Ingeniero', 'No aplica') DEFAULT 'No aplica' COMMENT 'Persona que autorizó el descuento.',

    precio_venta DECIMAL(10,2) NOT NULL COMMENT 'Precio final después de aplicar el descuento.',
    monto_enganche DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Monto aportado por el cliente como pago inicial aparte del descuento.',
    fecha_pago_enganche DATE COMMENT 'Fecha pactada para pagar el enganche.',

    saldo_restante DECIMAL(10,2) NOT NULL COMMENT 'Cantidad restante a pagar después del enganche.',

    forma_de_pago ENUM('Contado', 'Financiamiento') NOT NULL COMMENT 'Método acordado de pago: "Contado" o "Financiamiento".',
    plazo_meses TINYINT UNSIGNED DEFAULT 0 COMMENT 'Número total de pagos programados en el calendario de pagos.',
    mensualidades DECIMAL(10,2) DEFAULT NULL COMMENT 'Monto a pagar mensualmente si la venta es financiada.',
    fecha_inicio_pago DATE COMMENT 'Fecha del primer pago (reglas: días 1-30, febrero siempre 28).',

    estatus_venta ENUM('Activa', 'Cancelada', 'Finalizada') DEFAULT 'Activa' COMMENT 'Estado actual del contrato.',
    observaciones TEXT COMMENT 'Campo libre para notas o comentarios adicionales.',

    -- Relaciones
    CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_lote FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);


CREATE TABLE calendario_pagos (
    id_calendario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del calendario de pagos.',

    id_lote INT UNSIGNED NOT NULL COMMENT 'Referencia a la propiedad adquirida.',
    numero_pago TINYINT UNSIGNED NOT NULL COMMENT 'Número secuencial de la mensualidad.',
    fecha_vencimiento DATE NOT NULL COMMENT 'Fecha límite programada para realizar el pago.',
    monto_programado DECIMAL(10,2) NOT NULL COMMENT 'Monto esperado para esta mensualidad.',

    categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad') NOT NULL COMMENT 'Tipo de pago programado.',
    estatus_pago ENUM('Pendiente', 'Pagado', 'Vencido', 'Parcial') DEFAULT 'Pendiente' COMMENT 'Estado actual del pago.',

    observaciones TEXT COMMENT 'Comentarios adicionales.',

    -- Relaciones
    CONSTRAINT fk_lote_calendario FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);


CREATE TABLE pagos_realizados (
    id_pago INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del pago realizado.',

    id_lote INT UNSIGNED NOT NULL COMMENT 'Referencia a la propiedad pagada.',
    fecha_pago DATE NOT NULL COMMENT 'Fecha en que se realizó el pago.',
    monto_pagado DECIMAL(10,2) NOT NULL COMMENT 'Monto total pagado en esta transacción.',

    categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad') NOT NULL COMMENT 'Categoría del pago realizado.',

    metodo_pago ENUM('Deposito', 'Efectivo', 'Transferencia') NOT NULL COMMENT 'Método utilizado para realizar el pago.',
    referencia_pago VARCHAR(50) COMMENT 'Folio o referencia bancaria del pago.',
    
    observaciones TEXT COMMENT 'Comentarios adicionales del pago.',

    -- Relaciones
    CONSTRAINT fk_lote_pagos FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);



