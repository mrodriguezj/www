DROP TABLE IF EXISTS calendario_pagos;

CREATE TABLE calendario_pagos (
    id_calendario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del registro en el calendario de pagos.',
    id_lote INT UNSIGNED NOT NULL COMMENT 'Referencia a la propiedad asociada al pago.',
    numero_pago INT UNSIGNED NOT NULL COMMENT 'Número de pago programado.',
    fecha_vencimiento DATE NOT NULL COMMENT 'Fecha en que se debe realizar el pago.',
    monto_programado DECIMAL(10,2) NOT NULL COMMENT 'Monto total programado para el pago.',
    monto_restante DECIMAL(10,2) NOT NULL COMMENT 'Monto restante por pagar en la mensualidad.',
    categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad') NOT NULL COMMENT 'Tipo de pago programado.',
    estatus_pago ENUM('Pendiente', 'Parcial', 'Pagado', 'Vencido') DEFAULT 'Pendiente' COMMENT 'Estatus actual del pago.',

    -- Relaciones
    CONSTRAINT fk_lote_calendario FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);



DROP TABLE IF EXISTS pagos_realizados;

CREATE TABLE pagos_realizados (
    id_pago INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del pago realizado.',
    id_lote INT UNSIGNED NOT NULL COMMENT 'Referencia a la propiedad pagada.',
    fecha_pago DATE NOT NULL COMMENT 'Fecha en que se realizó el pago.',
    monto_pagado DECIMAL(10,2) NOT NULL COMMENT 'Monto total pagado en esta transacción.',
    categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad') NOT NULL COMMENT 'Categoría del pago realizado.',
    metodo_pago ENUM('Deposito', 'Efectivo', 'Transferencia') NOT NULL COMMENT 'Método utilizado para realizar el pago.',
    referencia_pago VARCHAR(50) COMMENT 'Folio o referencia bancaria del pago.',
    estatus_pago ENUM('Procesado', 'Rechazado', 'Pendiente') DEFAULT 'Procesado' COMMENT 'Estado de validación del pago.',
    observaciones TEXT COMMENT 'Comentarios adicionales del pago.',

    -- Relaciones
    CONSTRAINT fk_lote_pagos FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);


DROP TABLE IF EXISTS pagos_mensualidades_relacion;

CREATE TABLE pagos_mensualidades_relacion (
    id_relacion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la relación.',
    id_pago INT UNSIGNED NOT NULL COMMENT 'Referencia al pago realizado.',
    id_calendario INT UNSIGNED NOT NULL COMMENT 'Referencia a la mensualidad cubierta.',
    monto_asignado DECIMAL(10,2) NOT NULL COMMENT 'Monto asignado de este pago a la mensualidad.',

    -- Relaciones
    CONSTRAINT fk_pago FOREIGN KEY (id_pago) REFERENCES pagos_realizados(id_pago),
    CONSTRAINT fk_calendario FOREIGN KEY (id_calendario) REFERENCES calendario_pagos(id_calendario)
);

DROP TABLE IF EXISTS pagos_anteriores_referencia;

CREATE TABLE pagos_anteriores_referencia (
    id_referencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la referencia.',
    id_pago_actual INT UNSIGNED NOT NULL COMMENT 'Identificador del pago en el sistema actual.',
    id_pago_anterior INT UNSIGNED NOT NULL COMMENT 'Identificador del pago en el sistema anterior.',
    observaciones TEXT COMMENT 'Notas u observaciones sobre la relación entre pagos.',

    -- Relaciones
    CONSTRAINT fk_pago_actual FOREIGN KEY (id_pago_actual) REFERENCES pagos_realizados(id_pago)
);
