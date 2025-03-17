use u451524807_cobranza;

-- Primero elimina las tablas hijas
DROP TABLE IF EXISTS pagos_mensualidades_relacion;
DROP TABLE IF EXISTS historial_comisiones;
DROP TABLE IF EXISTS pagos_anteriores_referencia;

-- Por último elimina la tabla principal de pagos
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

    registro_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora en que se registró el pago.',

    -- Relaciones
    CONSTRAINT fk_lote_pagos FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);

CREATE TABLE historial_comisiones (
    id_comision INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_pago INT UNSIGNED NOT NULL COMMENT 'Referencia al pago realizado',
    id_lote INT UNSIGNED NOT NULL COMMENT 'Lote relacionado al pago',

    porcentaje_comision DECIMAL(5,2) NOT NULL COMMENT 'Porcentaje de comisión aplicado al pago',
    monto_comision DECIMAL(10,2) NOT NULL COMMENT 'Monto total de la comisión',

    estatus_pago_comision ENUM('Pendiente', 'Pagado') NOT NULL DEFAULT 'Pendiente' COMMENT 'Estado del pago de la comisión',
    fecha_pago_comision TIMESTAMP NULL DEFAULT NULL COMMENT 'Fecha en que se pagó la comisión',

    CONSTRAINT fk_pago_comision FOREIGN KEY (id_pago) REFERENCES pagos_realizados(id_pago),
    CONSTRAINT fk_lote_comision FOREIGN KEY (id_lote) REFERENCES propiedades(id_lote)
);

CREATE TABLE pagos_anteriores_referencia (
    id_referencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la referencia.',

    id_pago INT UNSIGNED NOT NULL COMMENT 'Identificador del pago en el sistema actual.',
    id_pago_anterior INT UNSIGNED NOT NULL COMMENT 'Identificador del pago en el sistema anterior.',

    observaciones TEXT COMMENT 'Notas u observaciones sobre la relación entre pagos.',

    -- Relaciones
    CONSTRAINT fk_pago_actual FOREIGN KEY (id_pago) REFERENCES pagos_realizados(id_pago)
);

CREATE TABLE pagos_mensualidades_relacion (
    id_relacion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_pago INT UNSIGNED NOT NULL COMMENT 'Referencia al pago realizado',
    id_calendario INT UNSIGNED NOT NULL COMMENT 'Referencia al calendario de pagos afectado',
    monto_asignado DECIMAL(10,2) NOT NULL COMMENT 'Monto que se asignó a esa mensualidad',
    
    CONSTRAINT fk_pago_relacion FOREIGN KEY (id_pago) REFERENCES pagos_realizados(id_pago),
    CONSTRAINT fk_calendario_relacion FOREIGN KEY (id_calendario) REFERENCES calendario_pagos(id_calendario)
);

DELIMITER $$


DELIMITER $$

CREATE PROCEDURE registrar_pago (
    IN p_id_lote INT UNSIGNED,
    IN p_fecha_pago DATE,
    IN p_monto_pagado DECIMAL(10,2),
    IN p_categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad'),
    IN p_metodo_pago ENUM('Deposito', 'Efectivo', 'Transferencia'),
    IN p_referencia_pago VARCHAR(50),
    IN p_observaciones TEXT,
    IN p_porcentaje_comision DECIMAL(5,2)
)
BEGIN
    -- Declaración de variables locales
    DECLARE v_id_pago INT;
    DECLARE v_id_calendario INT DEFAULT NULL;
    DECLARE v_monto_restante DECIMAL(10,2);
    DECLARE v_monto_aplicado DECIMAL(10,2);
    DECLARE v_pago_restante DECIMAL(10,2);

    -- Manejo de errores: Rollback si algo falla
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Inicia la transacción para garantizar integridad de datos
    START TRANSACTION;

    -- 1️⃣ Registrar el pago en la tabla pagos_realizados
    INSERT INTO pagos_realizados (
        id_lote,
        fecha_pago,
        monto_pagado,
        categoria_pago,
        metodo_pago,
        referencia_pago,
        estatus_pago,
        observaciones
    ) VALUES (
        p_id_lote,
        p_fecha_pago,
        p_monto_pagado,
        p_categoria_pago,
        p_metodo_pago,
        p_referencia_pago,
        'Procesado', -- Valor por defecto al registrar un pago
        p_observaciones
    );

    -- Guarda el ID del pago insertado para usarlo en otras tablas
    SET v_id_pago = LAST_INSERT_ID();

    -- 2️⃣ Aplica el monto pagado a los registros pendientes en calendario_pagos
    SET v_pago_restante = p_monto_pagado;

    WHILE v_pago_restante > 0 DO

        -- Busca el siguiente calendario pendiente por pagar
        SELECT id_calendario, monto_restante
        INTO v_id_calendario, v_monto_restante
        FROM calendario_pagos
        WHERE id_lote = p_id_lote
            AND estatus_pago = 'Pendiente'
        ORDER BY fecha_vencimiento ASC
        LIMIT 1;

        -- Si no hay registros pendientes (el SELECT no devolvió nada)
        IF v_id_calendario IS NULL THEN
            SET v_pago_restante = 0; -- Sale del ciclo
        ELSE
            -- Si el pago cubre totalmente el monto pendiente
            IF v_pago_restante >= v_monto_restante THEN

                SET v_monto_aplicado = v_monto_restante;

                -- Marcar como pagado en calendario_pagos
                UPDATE calendario_pagos
                SET monto_restante = 0,
                    estatus_pago = 'Pagado'
                WHERE id_calendario = v_id_calendario;

            ELSE
                -- Solo cubre una parte del pago pendiente
                SET v_monto_aplicado = v_pago_restante;

                -- Actualiza el monto restante
                UPDATE calendario_pagos
                SET monto_restante = monto_restante - v_monto_aplicado
                WHERE id_calendario = v_id_calendario;

            END IF;

            -- Registra la relación del pago con el calendario afectado
            INSERT INTO pagos_mensualidades_relacion (
                id_pago,
                id_calendario,
                monto_asignado
            ) VALUES (
                v_id_pago,
                v_id_calendario,
                v_monto_aplicado
            );

            -- Descuenta el monto aplicado del restante del pago
            SET v_pago_restante = v_pago_restante - v_monto_aplicado;

        END IF;

    END WHILE;

    -- 3️⃣ Registrar la comisión generada de este pago en historial_comisiones
    INSERT INTO historial_comisiones (
        id_pago,
        id_lote,
        porcentaje_comision,
        monto_comision
        -- estatus_pago_comision y fecha_pago_comision usan valores por defecto
    ) VALUES (
        v_id_pago,
        p_id_lote,
        p_porcentaje_comision,
        ROUND(p_monto_pagado * (p_porcentaje_comision / 100), 2)
    );

    -- 4️⃣ Confirmar la transacción
    COMMIT;

END$$

DELIMITER ;



CALL registrar_pago(
    1,                         -- p_id_lote
    '2024-08-14',              -- p_fecha_pago
    59840.00,                  -- p_monto_pagado
    'Enganche',             -- p_categoria_pago
    'Transferencia',           -- p_metodo_pago
    '',            -- p_referencia_pago
    'Enganche desde SQL', -- p_observaciones
    50.00                       -- p_porcentaje_comision
);
