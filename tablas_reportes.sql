CREATE TABLE `clientes` (
  `id_cliente` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del cliente',
  `nombres` varchar(50) NOT NULL COMMENT 'Nombre(s) del cliente',
  `apellido_paterno` varchar(50) NOT NULL COMMENT 'Apellido paterno del cliente',
  `apellido_materno` varchar(50) DEFAULT NULL COMMENT 'Apellido materno del cliente',
  `correo_electronico` varchar(100) NOT NULL COMMENT 'Correo electrónico único',
  `telefono` char(10) NOT NULL COMMENT 'Teléfono a 10 dígitos',
  `curp` char(18) NOT NULL COMMENT 'CURP del cliente',
  `rfc` char(13) DEFAULT NULL COMMENT 'RFC del cliente',
  `ine` char(18) NOT NULL COMMENT 'Número de identificación oficial (INE)',
  `direccion` varchar(100) DEFAULT NULL COMMENT 'Dirección completa en una sola línea',
  `estatus` enum('Activo','Inactivo') DEFAULT 'Activo' COMMENT 'Estado del cliente',
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `correo_electronico` (`correo_electronico`),
  UNIQUE KEY `curp` (`curp`),
  UNIQUE KEY `rfc` (`rfc`),
  UNIQUE KEY `ine` (`ine`)
)


CREATE TABLE `ventas` (
  `id_venta` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la venta.',
  `id_lote` int(10) unsigned NOT NULL COMMENT 'Referencia a la propiedad adquirida.',
  `id_cliente` int(10) unsigned NOT NULL COMMENT 'Referencia al cliente que compra la propiedad.',
  `fecha_venta` date NOT NULL COMMENT 'Fecha real en que se formalizó la venta.',
  `fecha_captura` timestamp NULL DEFAULT current_timestamp() COMMENT 'Fecha automática cuando se registra la venta en el sistema.',
  `precio_lote` decimal(10,2) NOT NULL COMMENT 'Precio base de la propiedad según la tabla propiedades.',
  `precio_lista` decimal(10,2) NOT NULL COMMENT 'Precio actualizado al momento de la venta.',
  `descuento` decimal(10,2) DEFAULT 0.00 COMMENT 'Descuento aplicado sobre el precio base.',
  `autoriza_descuento` enum('L. Ibarra','Ingeniero','No aplica') DEFAULT 'No aplica' COMMENT 'Persona que autorizó el descuento.',
  `precio_venta` decimal(10,2) NOT NULL COMMENT 'Precio final después de aplicar el descuento.',
  `monto_enganche` decimal(10,2) DEFAULT 0.00 COMMENT 'Monto aportado por el cliente como pago inicial aparte del descuento.',
  `fecha_pago_enganche` date DEFAULT NULL COMMENT 'Fecha pactada para pagar el enganche.',
  `saldo_restante` decimal(10,2) NOT NULL COMMENT 'Cantidad restante a pagar después del enganche.',
  `forma_de_pago` enum('Contado','Financiamiento') NOT NULL COMMENT 'Método acordado de pago: "Contado" o "Financiamiento".',
  `plazo_meses` tinyint(3) unsigned DEFAULT 0 COMMENT 'Número total de pagos programados en el calendario de pagos.',
  `mensualidades` decimal(10,2) DEFAULT NULL COMMENT 'Monto a pagar mensualmente si la venta es financiada.',
  `fecha_inicio_pago` date DEFAULT NULL COMMENT 'Fecha del primer pago (reglas: días 1-30, febrero siempre 28).',
  `estatus_venta` enum('Activa','Cancelada','Finalizada') DEFAULT 'Activa' COMMENT 'Estado actual del contrato.',
  `observaciones` text DEFAULT NULL COMMENT 'Campo libre para notas o comentarios adicionales.',
  PRIMARY KEY (`id_venta`),
  KEY `fk_cliente` (`id_cliente`),
  KEY `fk_lote` (`id_lote`),
  CONSTRAINT `fk_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_lote` FOREIGN KEY (`id_lote`) REFERENCES `propiedades` (`id_lote`)
)


CREATE TABLE `propiedades` (
  `id_lote` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del lote',
  `dimensiones` decimal(8,2) NOT NULL COMMENT 'Dimensiones del lote en metros cuadrados',
  `precio` decimal(10,2) NOT NULL COMMENT 'Precio de la propiedad',
  `tipo` enum('Premium','Regular','Comercial') NOT NULL COMMENT 'Tipo de lote',
  `disponibilidad` enum('Disponible','Vendido','Reservado') NOT NULL COMMENT 'Estado de disponibilidad',
  `desarrollo` varchar(50) NOT NULL COMMENT 'Nombre del desarrollo o fraccionamiento',
  `etapa` tinyint(3) unsigned NOT NULL COMMENT 'Número de etapa (entero positivo y pequeño)',
  `calle` enum('Calle Colibri','Calle Quetzal','Calle Aguila','Calle Paloma','Avenida Ramal Norte') NOT NULL COMMENT 'Calle donde se ubica la propiedad',
  `observaciones` text DEFAULT NULL COMMENT 'Comentarios adicionales sobre la propiedad',
  PRIMARY KEY (`id_lote`)
)


CREATE TABLE `pagos_realizados` (
  `id_pago` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del pago realizado.',
  `id_lote` int(10) unsigned NOT NULL COMMENT 'Referencia a la propiedad pagada.',
  `fecha_pago` date NOT NULL COMMENT 'Fecha en que se realizó el pago.',
  `monto_pagado` decimal(10,2) NOT NULL COMMENT 'Monto total pagado en esta transacción.',
  `categoria_pago` enum('Enganche','Contado','Mensualidad','Anualidad') NOT NULL COMMENT 'Categoría del pago realizado.',
  `metodo_pago` enum('Deposito','Efectivo','Transferencia') NOT NULL COMMENT 'Método utilizado para realizar el pago.',
  `referencia_pago` varchar(50) DEFAULT NULL COMMENT 'Folio o referencia bancaria del pago.',
  `estatus_pago` enum('Procesado','Rechazado','Pendiente') DEFAULT 'Procesado' COMMENT 'Estado de validación del pago.',
  `observaciones` text DEFAULT NULL COMMENT 'Comentarios adicionales del pago.',
  `registro_pago` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora en que se registró el pago.',
  PRIMARY KEY (`id_pago`),
  KEY `fk_lote_pagos` (`id_lote`),
  CONSTRAINT `fk_lote_pagos` FOREIGN KEY (`id_lote`) REFERENCES `propiedades` (`id_lote`)
)


CREATE TABLE `calendario_pagos` (
  `id_calendario` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del registro en el calendario de pagos.',
  `id_lote` int(10) unsigned NOT NULL COMMENT 'Referencia a la propiedad asociada al pago.',
  `numero_pago` int(10) unsigned NOT NULL COMMENT 'Número de pago programado.',
  `fecha_vencimiento` date NOT NULL COMMENT 'Fecha en que se debe realizar el pago.',
  `monto_programado` decimal(10,2) NOT NULL COMMENT 'Monto total programado para el pago.',
  `monto_restante` decimal(10,2) NOT NULL COMMENT 'Monto restante por pagar en la mensualidad.',
  `categoria_pago` enum('Enganche','Contado','Mensualidad','Anualidad') NOT NULL COMMENT 'Tipo de pago programado.',
  `estatus_pago` enum('Pendiente','Parcial','Pagado','Vencido') DEFAULT 'Pendiente' COMMENT 'Estatus actual del pago.',
  PRIMARY KEY (`id_calendario`),
  KEY `fk_lote_calendario` (`id_lote`),
  CONSTRAINT `fk_lote_calendario` FOREIGN KEY (`id_lote`) REFERENCES `propiedades` (`id_lote`)
)


--PROCEDIMIENTOS

SHOW STATUS LIKE 'Threads_connected';

DELIMITER $$

CREATE PROCEDURE obtener_total_pagado()
BEGIN
    SELECT 
        IFNULL(SUM(monto_pagado), 0) AS total_pagado
    FROM pagos_realizados;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE obtener_cartera_vencida()
BEGIN
    SELECT 
        IFNULL(SUM(monto_restante), 0) AS cartera_vencida
    FROM calendario_pagos
    WHERE estatus_pago IN ('Pendiente', 'Vencido')
      AND fecha_vencimiento < CURDATE();
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE obtener_morosos()
BEGIN
    SELECT
        cl.id_cliente,
        CONCAT(cl.nombres, ' ', cl.apellido_paterno, ' ', IFNULL(cl.apellido_materno, '')) AS nombre_cliente,
        pr.id_lote,
        cp.id_calendario,
        cp.numero_pago,
        cp.categoria_pago,
        cp.fecha_vencimiento,
        cp.monto_programado,
        cp.monto_restante,
        cp.estatus_pago,
        DATEDIFF(CURDATE(), cp.fecha_vencimiento) AS dias_mora
    FROM calendario_pagos cp
    INNER JOIN propiedades pr ON cp.id_lote = pr.id_lote
    INNER JOIN ventas v ON pr.id_lote = v.id_lote
    INNER JOIN clientes cl ON v.id_cliente = cl.id_cliente
    WHERE cp.estatus_pago IN ('Pendiente', 'Vencido')
      AND cp.fecha_vencimiento < CURDATE()
    ORDER BY dias_mora DESC;
END$$

DELIMITER ;
