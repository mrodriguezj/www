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

    -- Inicia la transacción
    START TRANSACTION;

    -- 1️⃣ Registrar el pago en pagos_realizados
    INSERT INTO pagos_realizados (
        id_lote, fecha_pago, monto_pagado, categoria_pago, 
        metodo_pago, referencia_pago, estatus_pago, observaciones
    ) VALUES (
        p_id_lote, p_fecha_pago, p_monto_pagado, p_categoria_pago, 
        p_metodo_pago, p_referencia_pago, 'Procesado', p_observaciones
    );

    -- Obtener el ID del pago insertado
    SET v_id_pago = LAST_INSERT_ID();
    SET v_pago_restante = p_monto_pagado;

    -- 2️⃣ Buscar el primer calendario pendiente y pagarlo completamente antes de avanzar
    WHILE v_pago_restante > 0 DO

        -- 🔥 FIX: Aseguramos que el pago se asigna al `id_calendario` más antiguo con la misma fecha
        SELECT id_calendario, monto_restante
        INTO v_id_calendario, v_monto_restante
        FROM calendario_pagos
        WHERE id_lote = p_id_lote AND estatus_pago = 'Pendiente'
        ORDER BY fecha_vencimiento ASC, id_calendario ASC
        LIMIT 1;

        -- Si no hay más registros pendientes, salir del ciclo
        IF v_id_calendario IS NULL THEN
            SET v_pago_restante = 0;
        ELSE
            -- Mantener el mismo calendario hasta pagarlo completamente
            WHILE v_pago_restante > 0 AND v_monto_restante > 0 DO

                IF v_pago_restante >= v_monto_restante THEN
                    -- Se paga completamente el calendario actual
                    SET v_monto_aplicado = v_monto_restante;

                    UPDATE calendario_pagos
                    SET monto_restante = 0, estatus_pago = 'Pagado'
                    WHERE id_calendario = v_id_calendario;

                    -- Registrar la relación de pago
                    INSERT INTO pagos_mensualidades_relacion (id_pago, id_calendario, monto_asignado)
                    VALUES (v_id_pago, v_id_calendario, v_monto_aplicado);

                    -- Restar el monto aplicado
                    SET v_pago_restante = v_pago_restante - v_monto_aplicado;
                    SET v_monto_restante = 0; -- Se marca como completamente pagado

                ELSE
                    -- Pago parcial al calendario
                    SET v_monto_aplicado = v_pago_restante;

                    UPDATE calendario_pagos
                    SET monto_restante = monto_restante - v_monto_aplicado
                    WHERE id_calendario = v_id_calendario;

                    -- Registrar la relación de pago
                    INSERT INTO pagos_mensualidades_relacion (id_pago, id_calendario, monto_asignado)
                    VALUES (v_id_pago, v_id_calendario, v_monto_aplicado);

                    -- Agotar el pago actual
                    SET v_pago_restante = 0;
                    SET v_monto_restante = v_monto_restante - v_monto_aplicado;
                END IF;

            END WHILE;

        END IF;

    END WHILE;

    -- 3️⃣ Registrar la comisión generada por el pago
    INSERT INTO historial_comisiones (id_pago, id_lote, porcentaje_comision, monto_comision)
    VALUES (v_id_pago, p_id_lote, p_porcentaje_comision, ROUND(p_monto_pagado * (p_porcentaje_comision / 100), 2));

    -- 4️⃣ Confirmar la transacción
    COMMIT;

END$$

DELIMITER ;
