DELIMITER $$

CREATE PROCEDURE registrar_pago (
    IN p_id_lote INT UNSIGNED,
    IN p_fecha_pago DATE,
    IN p_monto_pagado DECIMAL(10,2),
    IN p_categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad'),
    IN p_metodo_pago ENUM('Deposito', 'Efectivo', 'Transferencia'),
    IN p_referencia_pago VARCHAR(50),
    IN p_observaciones TEXT,
    IN p_id_pago_anterior INT UNSIGNED
)
BEGIN
    DECLARE v_id_pago INT;
    DECLARE v_monto_restante DECIMAL(10,2);
    DECLARE v_id_calendario INT;
    DECLARE v_monto_programado DECIMAL(10,2);
    DECLARE v_monto_pagado_mensualidad DECIMAL(10,2);
    DECLARE done INT DEFAULT 0;

    DECLARE mensualidades_cursor CURSOR FOR
        SELECT id_calendario, monto_restante
        FROM calendario_pagos
        WHERE id_lote = p_id_lote AND estatus_pago IN ('Pendiente', 'Parcial')
        ORDER BY fecha_vencimiento ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Iniciar la transacción
    START TRANSACTION;

    BEGIN
        -- Insertar el pago
        INSERT INTO pagos_realizados (
            id_lote, fecha_pago, monto_pagado, categoria_pago, metodo_pago, referencia_pago, observaciones
        ) VALUES (
            p_id_lote, p_fecha_pago, p_monto_pagado, p_categoria_pago, p_metodo_pago, p_referencia_pago, p_observaciones
        );

        SET v_id_pago = LAST_INSERT_ID();
        SET v_monto_restante = p_monto_pagado;

        -- Referencia al sistema anterior (si aplica)
        IF p_id_pago_anterior IS NOT NULL THEN
            INSERT INTO pagos_anteriores_referencia (id_pago_actual, id_pago_anterior, observaciones)
            VALUES (v_id_pago, p_id_pago_anterior, 'Referencia de pago migrado.');
        END IF;

        -- Distribuir el monto pagado en las mensualidades
        OPEN mensualidades_cursor;

        mensualidades_loop: LOOP
            FETCH mensualidades_cursor INTO v_id_calendario, v_monto_programado;

            IF done = 1 OR v_monto_restante <= 0 THEN
                LEAVE mensualidades_loop;
            END IF;

            SET v_monto_pagado_mensualidad = 
                CASE 
                    WHEN v_monto_restante >= v_monto_programado THEN v_monto_programado
                    ELSE v_monto_restante
                END;

            -- Insertar la relación en pagos_mensualidades_relacion
            INSERT INTO pagos_mensualidades_relacion (id_pago, id_calendario, monto_asignado)
            VALUES (v_id_pago, v_id_calendario, v_monto_pagado_mensualidad);

            -- Actualizar calendario con saldo restante
            UPDATE calendario_pagos
            SET 
                monto_restante = monto_restante - v_monto_pagado_mensualidad,
                estatus_pago = CASE
                    WHEN (monto_restante - v_monto_pagado_mensualidad) <= 0 THEN 'Pagado'
                    ELSE 'Parcial'
                END
            WHERE id_calendario = v_id_calendario;

            SET v_monto_restante = v_monto_restante - v_monto_pagado_mensualidad;

        END LOOP;

        CLOSE mensualidades_cursor;

        -- Confirmar la transacción
        COMMIT;

    END;

END$$

DELIMITER ;
