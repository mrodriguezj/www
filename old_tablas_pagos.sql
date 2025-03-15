-- u451524807_cobranza.historial_comisiones definition

CREATE TABLE `historial_comisiones` (
  `id_comision` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_pago` int(10) unsigned NOT NULL COMMENT 'Referencia al pago realizado',
  `id_lote` int(10) unsigned NOT NULL COMMENT 'Lote relacionado al pago',
  `porcentaje_comision` decimal(5,2) NOT NULL COMMENT 'Porcentaje de comisión aplicado al pago',
  `monto_comision` decimal(10,2) NOT NULL COMMENT 'Monto total de la comisión',
  `fecha_registro` timestamp NULL DEFAULT current_timestamp() COMMENT 'Fecha de creación de la comisión',
  PRIMARY KEY (`id_comision`),
  KEY `fk_pago_comision` (`id_pago`),
  KEY `fk_lote_comision` (`id_lote`),
  CONSTRAINT `fk_lote_comision` FOREIGN KEY (`id_lote`) REFERENCES `propiedades` (`id_lote`),
  CONSTRAINT `fk_pago_comision` FOREIGN KEY (`id_pago`) REFERENCES `pagos_realizados` (`id_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- u451524807_cobranza.pagos_anteriores_referencia definition

CREATE TABLE `pagos_anteriores_referencia` (
  `id_referencia` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la referencia.',
  `id_pago_actual` int(10) unsigned NOT NULL COMMENT 'Identificador del pago en el sistema actual.',
  `id_pago_anterior` int(10) unsigned NOT NULL COMMENT 'Identificador del pago en el sistema anterior.',
  `observaciones` text DEFAULT NULL COMMENT 'Notas u observaciones sobre la relación entre pagos.',
  PRIMARY KEY (`id_referencia`),
  KEY `fk_pago_actual` (`id_pago_actual`),
  CONSTRAINT `fk_pago_actual` FOREIGN KEY (`id_pago_actual`) REFERENCES `pagos_realizados` (`id_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- u451524807_cobranza.pagos_mensualidades_relacion definition

CREATE TABLE `pagos_mensualidades_relacion` (
  `id_relacion` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la relación.',
  `id_pago` int(10) unsigned NOT NULL COMMENT 'Referencia al pago realizado.',
  `id_calendario` int(10) unsigned NOT NULL COMMENT 'Referencia a la mensualidad cubierta.',
  `monto_asignado` decimal(10,2) NOT NULL COMMENT 'Monto asignado de este pago a la mensualidad.',
  PRIMARY KEY (`id_relacion`),
  KEY `fk_pago` (`id_pago`),
  KEY `fk_calendario` (`id_calendario`),
  CONSTRAINT `fk_calendario` FOREIGN KEY (`id_calendario`) REFERENCES `calendario_pagos` (`id_calendario`),
  CONSTRAINT `fk_pago` FOREIGN KEY (`id_pago`) REFERENCES `pagos_realizados` (`id_pago`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- u451524807_cobranza.pagos_realizados definition

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
  PRIMARY KEY (`id_pago`),
  KEY `fk_lote_pagos` (`id_lote`),
  CONSTRAINT `fk_lote_pagos` FOREIGN KEY (`id_lote`) REFERENCES `propiedades` (`id_lote`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;