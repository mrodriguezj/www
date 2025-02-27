use cobranza;

DELIMITER $$

CREATE PROCEDURE registrar_venta_y_generar_calendario (
    IN p_id_cliente INT UNSIGNED,
    IN p_id_lote INT UNSIGNED,
    IN p_fecha_venta DATE,
    IN p_precio_lote DECIMAL(10,2),
    IN p_precio_lista DECIMAL(10,2),
    IN p_descuento DECIMAL(10,2),
    IN p_autoriza_descuento ENUM('L. Ibarra', 'Ingeniero', 'No aplica'),
    IN p_precio_venta DECIMAL(10,2),
    IN p_monto_enganche DECIMAL(10,2),
    IN p_fecha_pago_enganche DATE,
    IN p_saldo_restante DECIMAL(10,2),
    IN p_forma_de_pago ENUM('Contado', 'Financiamiento'),
    IN p_plazo_meses TINYINT UNSIGNED,
    IN p_mensualidades DECIMAL(10,2),
    IN p_fecha_inicio_pago DATE
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE contador INT DEFAULT 1;
    DECLARE fecha_pago DATE;
    DECLARE dia_pago INT;

    -- Iniciar transacción
    START TRANSACTION;

    BEGIN
        -- 1️⃣ Insertar la venta
        INSERT INTO ventas (
            id_cliente, id_lote, fecha_venta, precio_lote, precio_lista, descuento, 
            autoriza_descuento, precio_venta, monto_enganche, fecha_pago_enganche, 
            saldo_restante, forma_de_pago, plazo_meses, mensualidades, fecha_inicio_pago
        ) VALUES (
            p_id_cliente, p_id_lote, p_fecha_venta, p_precio_lote, p_precio_lista, p_descuento,
            p_autoriza_descuento, p_precio_venta, p_monto_enganche, p_fecha_pago_enganche,
            p_saldo_restante, p_forma_de_pago, p_plazo_meses, p_mensualidades, p_fecha_inicio_pago
        );

        SET v_id_venta = LAST_INSERT_ID();

        -- 2️⃣ Actualizar la propiedad a "Vendido"
        UPDATE propiedades
        SET disponibilidad = 'Vendido'
        WHERE id_lote = p_id_lote;

        -- 3️⃣ Generar calendario de pagos

        -- 3.1 Registrar enganche si existe
        IF p_monto_enganche > 0 THEN
            INSERT INTO calendario_pagos (
                id_lote, numero_pago, fecha_vencimiento, monto_programado, categoria_pago, estatus_pago
            ) VALUES (
                p_id_lote, 0, p_fecha_pago_enganche, p_monto_enganche, 'Enganche', 'Pendiente'
            );
        END IF;

        -- 3.2 Forma de pago: Contado
        IF p_forma_de_pago = 'Contado' THEN
            INSERT INTO calendario_pagos (
                id_lote, numero_pago, fecha_vencimiento, monto_programado, categoria_pago, estatus_pago
            ) VALUES (
                p_id_lote, 1, p_fecha_inicio_pago, p_saldo_restante, 'Contado', 'Pendiente'
            );

        -- 3.3 Forma de pago: Financiamiento
        ELSEIF p_forma_de_pago = 'Financiamiento' THEN
            SET dia_pago = DAY(p_fecha_inicio_pago);

            WHILE contador <= p_plazo_meses DO
                -- Calcular la fecha de pago respetando meses y considerando febrero
                SET fecha_pago = DATE_ADD(p_fecha_inicio_pago, INTERVAL contador - 1 MONTH);
                
                IF MONTH(fecha_pago) = 2 AND dia_pago > 28 THEN
                    SET fecha_pago = DATE_FORMAT(CONCAT(YEAR(fecha_pago), '-02-28'), '%Y-%m-%d');
                ELSE
                    SET fecha_pago = DATE_FORMAT(CONCAT(YEAR(fecha_pago), '-', MONTH(fecha_pago), '-', LPAD(dia_pago, 2, '0')), '%Y-%m-%d');
                END IF;

                -- Insertar registro en calendario_pagos
                INSERT INTO calendario_pagos (
                    id_lote, numero_pago, fecha_vencimiento, monto_programado, categoria_pago, estatus_pago
                ) VALUES (
                    p_id_lote, contador, fecha_pago, p_mensualidades, 'Mensualidad', 'Pendiente'
                );

                SET contador = contador + 1;
            END WHILE;
        END IF;

        -- Confirmar transacción si todo fue exitoso
        COMMIT;

    END;

END$$

DELIMITER ;


--2.0

DELIMITER $$

CREATE PROCEDURE registrar_venta_y_generar_calendario (
    IN p_id_cliente INT UNSIGNED,
    IN p_id_lote INT UNSIGNED,
    IN p_fecha_venta DATE,
    IN p_precio_lote DECIMAL(10,2),
    IN p_precio_lista DECIMAL(10,2),
    IN p_descuento DECIMAL(10,2),
    IN p_autoriza_descuento ENUM('L. Ibarra', 'Ingeniero', 'No aplica'),
    IN p_precio_venta DECIMAL(10,2),
    IN p_monto_enganche DECIMAL(10,2),
    IN p_fecha_pago_enganche DATE,
    IN p_saldo_restante DECIMAL(10,2),
    IN p_forma_de_pago ENUM('Contado', 'Financiamiento'),
    IN p_plazo_meses TINYINT UNSIGNED,
    IN p_mensualidades DECIMAL(10,2),
    IN p_fecha_inicio_pago DATE
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE contador INT DEFAULT 1;
    DECLARE fecha_pago DATE;
    DECLARE dia_pago INT;

    -- Iniciar transacción
    START TRANSACTION;

    BEGIN
        -- 1️⃣ Insertar la venta
        INSERT INTO ventas (
            id_cliente, id_lote, fecha_venta, precio_lote, precio_lista, descuento, 
            autoriza_descuento, precio_venta, monto_enganche, fecha_pago_enganche, 
            saldo_restante, forma_de_pago, plazo_meses, mensualidades, fecha_inicio_pago
        ) VALUES (
            p_id_cliente, p_id_lote, p_fecha_venta, p_precio_lote, p_precio_lista, p_descuento,
            p_autoriza_descuento, p_precio_venta, p_monto_enganche, p_fecha_pago_enganche,
            p_saldo_restante, p_forma_de_pago, p_plazo_meses, p_mensualidades, p_fecha_inicio_pago
        );

        SET v_id_venta = LAST_INSERT_ID();
        SET dia_pago = DAY(p_fecha_inicio_pago);

        -- 2️⃣ Actualizar propiedad a "Vendido"
        UPDATE propiedades
        SET disponibilidad = 'Vendido'
        WHERE id_lote = p_id_lote;

        -- 3️⃣ Generar calendario de pagos

        -- Enganche (si existe)
        IF p_monto_enganche > 0 THEN
            INSERT INTO calendario_pagos (
                id_lote, numero_pago, fecha_vencimiento, monto_programado, monto_restante, categoria_pago, estatus_pago
            ) VALUES (
                p_id_lote, 0, p_fecha_pago_enganche, p_monto_enganche, p_monto_enganche, 'Enganche', 'Pendiente'
            );
        END IF;

        -- Contado
        IF p_forma_de_pago = 'Contado' THEN
            INSERT INTO calendario_pagos (
                id_lote, numero_pago, fecha_vencimiento, monto_programado, monto_restante, categoria_pago, estatus_pago
            ) VALUES (
                p_id_lote, 1, p_fecha_inicio_pago, p_saldo_restante, p_saldo_restante, 'Contado', 'Pendiente'
            );

        -- Financiamiento
        ELSEIF p_forma_de_pago = 'Financiamiento' THEN
            WHILE contador <= p_plazo_meses DO
                SET fecha_pago = DATE_ADD(p_fecha_inicio_pago, INTERVAL (contador - 1) MONTH);

                -- Ajuste para febrero si el día seleccionado es mayor al 28
                IF MONTH(fecha_pago) = 2 AND dia_pago > 28 THEN
                    SET fecha_pago = DATE_FORMAT(CONCAT(YEAR(fecha_pago), '-02-28'), '%Y-%m-%d');
                ELSE
                    SET fecha_pago = DATE_FORMAT(CONCAT(YEAR(fecha_pago), '-', MONTH(fecha_pago), '-', LPAD(dia_pago, 2, '0')), '%Y-%m-%d');
                END IF;

                -- Insertar mensualidades con monto_restante igual al monto_programado
                INSERT INTO calendario_pagos (
                    id_lote, numero_pago, fecha_vencimiento, monto_programado, monto_restante, categoria_pago, estatus_pago
                ) VALUES (
                    p_id_lote, contador, fecha_pago, p_mensualidades, p_mensualidades, 'Mensualidad', 'Pendiente'
                );

                SET contador = contador + 1;
            END WHILE;
        END IF;

        -- 4️⃣ Confirmar la transacción
        COMMIT;

    END;

END$$

DELIMITER ;
