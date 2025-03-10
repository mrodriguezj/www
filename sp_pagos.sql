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


--2.0
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
    DECLARE v_id_pago INT;
    DECLARE v_monto_restante DECIMAL(10,2);
    DECLARE v_monto_aplicado DECIMAL(10,2);
    DECLARE v_pago_restante DECIMAL(10,2);
    DECLARE v_id_calendario_pago INT;

    -- Inicia transacción
    START TRANSACTION;

    -- 1️⃣ Registrar el pago en pagos_realizados
    INSERT INTO pagos_realizados (
        id_lote,
        fecha_pago,
        monto_pagado,
        categoria_pago,
        metodo_pago,
        referencia_pago,
        observaciones
    ) VALUES (
        p_id_lote,
        p_fecha_pago,
        p_monto_pagado,
        p_categoria_pago,
        p_metodo_pago,
        p_referencia_pago,
        p_observaciones
    );

    SET v_id_pago = LAST_INSERT_ID();

    -- 2️⃣ Aplicar el pago al calendario de pagos
    SET v_pago_restante = p_monto_pagado;

    -- Buscar pagos pendientes en calendario_pagos
    WHILE v_pago_restante > 0 DO

        SELECT id_calendario_pago, monto_restante
        INTO v_id_calendario_pago, v_monto_restante
        FROM calendario_pagos
        WHERE id_lote = p_id_lote AND estatus_pago = 'Pendiente'
        ORDER BY fecha_vencimiento ASC
        LIMIT 1;

        IF v_id_calendario_pago IS NULL THEN
            -- No hay más pagos pendientes
            LEAVE;
        END IF;

        IF v_pago_restante >= v_monto_restante THEN
            SET v_monto_aplicado = v_monto_restante;

            -- Actualiza calendario_pagos a Pagado
            UPDATE calendario_pagos
            SET monto_restante = 0, estatus_pago = 'Pagado'
            WHERE id_calendario_pago = v_id_calendario_pago;

        ELSE
            SET v_monto_aplicado = v_pago_restante;

            -- Actualiza monto_restante parcialmente
            UPDATE calendario_pagos
            SET monto_restante = monto_restante - v_monto_aplicado
            WHERE id_calendario_pago = v_id_calendario_pago;
        END IF;

        -- Registra el desglose en mensualidades_relacion
        INSERT INTO mensualidades_relacion (
            id_pago_realizado,
            id_calendario_pago,
            monto_aplicado
        ) VALUES (
            v_id_pago,
            v_id_calendario_pago,
            v_monto_aplicado
        );

        -- Disminuye lo que ya se aplicó
        SET v_pago_restante = v_pago_restante - v_monto_aplicado;

    END WHILE;

    -- 3️⃣ Registrar comisión
    INSERT INTO historial_comisiones (
        id_pago,
        id_lote,
        porcentaje_comision,
        monto_comision
    ) VALUES (
        v_id_pago,
        p_id_lote,
        p_porcentaje_comision,
        ROUND(p_monto_pagado * (p_porcentaje_comision / 100), 2)
    );

    -- Confirma la transacción
    COMMIT;
END$$

DELIMITER ;


--3.0

DROP PROCEDURE IF EXISTS registrar_pago;

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
    -- Declaración de variables
    DECLARE v_id_pago INT;
    DECLARE v_id_calendario_pago INT;
    DECLARE v_monto_restante DECIMAL(10,2);
    DECLARE v_monto_aplicado DECIMAL(10,2);
    DECLARE v_pago_restante DECIMAL(10,2);

    -- Iniciar transacción
    START TRANSACTION;

    -- 1️⃣ Registrar el pago en pagos_realizados
    INSERT INTO pagos_realizados (
        id_lote,
        fecha_pago,
        monto_pagado,
        categoria_pago,
        metodo_pago,
        referencia_pago,
        observaciones
    ) VALUES (
        p_id_lote,
        p_fecha_pago,
        p_monto_pagado,
        p_categoria_pago,
        p_metodo_pago,
        p_referencia_pago,
        p_observaciones
    );

    -- Obtener el id del nuevo pago registrado
    SET v_id_pago = LAST_INSERT_ID();

    -- 2️⃣ Aplicar el pago al calendario de pagos
    SET v_pago_restante = p_monto_pagado;

    -- Buscar y aplicar el pago a los registros pendientes
    WHILE v_pago_restante > 0 DO

        -- Obtener el siguiente pago pendiente en calendario_pagos
        SELECT id_calendario_pago, monto_restante
        INTO v_id_calendario_pago, v_monto_restante
        FROM calendario_pagos
        WHERE id_lote = p_id_lote
            AND estatus_pago = 'Pendiente'
        ORDER BY fecha_vencimiento ASC
        LIMIT 1;

        -- Si no hay pagos pendientes, salir del ciclo
        IF v_id_calendario_pago IS NULL THEN
            SET v_pago_restante = 0;

        ELSE
            -- Si el pago restante cubre todo el monto pendiente
            IF v_pago_restante >= v_monto_restante THEN

                SET v_monto_aplicado = v_monto_restante;

                -- Actualizar el calendario de pagos como pagado
                UPDATE calendario_pagos
                SET monto_restante = 0,
                    estatus_pago = 'Pagado'
                WHERE id_calendario_pago = v_id_calendario_pago;

            ELSE
                -- El pago solo cubre parcialmente
                SET v_monto_aplicado = v_pago_restante;

                -- Actualizar el monto restante
                UPDATE calendario_pagos
                SET monto_restante = monto_restante - v_monto_aplicado
                WHERE id_calendario_pago = v_id_calendario_pago;

            END IF;

            -- Registrar en la relación de pagos aplicados
            INSERT INTO mensualidades_relacion (
                id_pago_realizado,
                id_calendario_pago,
                monto_aplicado
            ) VALUES (
                v_id_pago,
                v_id_calendario_pago,
                v_monto_aplicado
            );

            -- Restar el monto ya aplicado al saldo restante del pago
            SET v_pago_restante = v_pago_restante - v_monto_aplicado;

        END IF;

    END WHILE;

    -- 3️⃣ Registrar la comisión en historial_comisiones
    INSERT INTO historial_comisiones (
        id_pago,
        id_lote,
        porcentaje_comision,
        monto_comision
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

--3.0

DROP PROCEDURE IF EXISTS registrar_pago;

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
    DECLARE v_id_calendario INT;
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
        observaciones
    ) VALUES (
        p_id_lote,
        p_fecha_pago,
        p_monto_pagado,
        p_categoria_pago,
        p_metodo_pago,
        p_referencia_pago,
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

        -- Si no hay registros pendientes, salir del ciclo
        IF v_id_calendario IS NULL THEN
            SET v_pago_restante = 0;

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
            INSERT INTO pagos_mensualidades_relacion  (
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
    ) VALUES (
        v_id_pago,
        p_id_lote,
        p_porcentaje_comision,
        ROUND(p_monto_pagado * (p_porcentaje_comision / 100), 2)
    );

    -- 4️⃣ Confirma la transacción
    COMMIT;

END$$

DELIMITER ;
