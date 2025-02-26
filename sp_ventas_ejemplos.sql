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



CALL registrar_venta_y_generar_calendario (
    1,                  -- p_id_cliente
    3,                  -- p_id_lote
    '2024-03-01',       -- p_fecha_venta
    500000.00,          -- p_precio_lote
    550000.00,          -- p_precio_lista
    25000.00,           -- p_descuento
    'L. Ibarra',        -- p_autoriza_descuento
    525000.00,          -- p_precio_venta
    50000.00,           -- p_monto_enganche
    '2024-03-05',       -- p_fecha_pago_enganche
    475000.00,          -- p_saldo_restante
    'Financiamiento',   -- p_forma_de_pago
    10,                 -- p_plazo_meses
    47500.00,           -- p_mensualidades
    '2024-04-10'        -- p_fecha_inicio_pago
);


CALL registrar_venta_y_generar_calendario (
    2,                  -- p_id_cliente (Cliente asociado)
    5,                  -- p_id_lote (Propiedad a vender)
    '2024-03-02',       -- p_fecha_venta (Fecha de la venta)
    600000.00,          -- p_precio_lote (Precio base de la propiedad)
    620000.00,          -- p_precio_lista (Precio ajustado al momento de la venta)
    20000.00,           -- p_descuento (Descuento aplicado)
    'Ingeniero',        -- p_autoriza_descuento (Quién autorizó el descuento)
    600000.00,          -- p_precio_venta (Precio final después del descuento)
    60000.00,           -- p_monto_enganche (Monto del enganche aportado)
    '2024-03-10',       -- p_fecha_pago_enganche (Fecha pactada para el enganche)
    540000.00,          -- p_saldo_restante (Saldo restante después del enganche)
    'Financiamiento',   -- p_forma_de_pago (Forma de pago: Contado o Financiamiento)
    12,                 -- p_plazo_meses (Número de mensualidades)
    45000.00,           -- p_mensualidades (Monto mensual a pagar)
    '2024-04-15'        -- p_fecha_inicio_pago (Fecha del primer pago mensual)
);


CALL registrar_venta_y_generar_calendario (
    3,                  -- p_id_cliente (Cliente asociado)
    4,                  -- p_id_lote (Propiedad a vender)
    '2024-03-05',       -- p_fecha_venta (Fecha de la venta)
    450000.00,          -- p_precio_lote (Precio base de la propiedad)
    470000.00,          -- p_precio_lista (Precio ajustado al momento de la venta)
    20000.00,           -- p_descuento (Descuento aplicado)
    'L. Ibarra',        -- p_autoriza_descuento (Quién autorizó el descuento)
    450000.00,          -- p_precio_venta (Precio final después del descuento)
    0.00,               -- p_monto_enganche (Sin enganche para venta de contado)
    NULL,               -- p_fecha_pago_enganche (Sin enganche)
    450000.00,          -- p_saldo_restante (Saldo total a pagar de contado)
    'Contado',          -- p_forma_de_pago (Venta de contado)
    0,                  -- p_plazo_meses (No aplica para contado)
    NULL,               -- p_mensualidades (No aplica)
    '2024-03-10'        -- p_fecha_inicio_pago (Fecha del pago de contado)
);


CALL registrar_venta_y_generar_calendario (
    4,                  -- p_id_cliente (Cliente asociado)
    1,                  -- p_id_lote (Propiedad a vender)
    '2025-01-30',       -- p_fecha_venta (Fecha de la venta)
    700000.00,          -- p_precio_lote (Precio base de la propiedad)
    720000.00,          -- p_precio_lista (Precio ajustado al momento de la venta)
    20000.00,           -- p_descuento (Descuento aplicado)
    'Ingeniero',        -- p_autoriza_descuento (Quién autorizó el descuento)
    700000.00,          -- p_precio_venta (Precio final después del descuento)
    70000.00,           -- p_monto_enganche (Enganche acordado)
    '2025-02-05',       -- p_fecha_pago_enganche (Fecha pactada para el enganche)
    630000.00,          -- p_saldo_restante (Saldo restante después del enganche)
    'Financiamiento',   -- p_forma_de_pago (Financiamiento)
    24,                 -- p_plazo_meses (Número de mensualidades)
    26250.00,           -- p_mensualidades (Monto mensual a pagar)
    '2025-03-05'        -- p_fecha_inicio_pago (Fecha del primer pago mensual)
);

CALL registrar_venta_y_generar_calendario (
    5,                  -- p_id_cliente (Cliente asociado)
    2,                  -- p_id_lote (Propiedad a vender)
    '2025-01-15',       -- p_fecha_venta (Fecha de la venta)
    650000.00,          -- p_precio_lote (Precio base de la propiedad)
    670000.00,          -- p_precio_lista (Precio ajustado al momento de la venta)
    20000.00,           -- p_descuento (Descuento aplicado)
    'L. Ibarra',        -- p_autoriza_descuento (Quién autorizó el descuento)
    650000.00,          -- p_precio_venta (Precio final después del descuento)
    65000.00,           -- p_monto_enganche (Enganche acordado)
    '2025-01-20',       -- p_fecha_pago_enganche (Fecha pactada para el enganche)
    585000.00,          -- p_saldo_restante (Saldo restante después del enganche)
    'Financiamiento',   -- p_forma_de_pago (Financiamiento)
    24,                 -- p_plazo_meses (Número de mensualidades)
    24375.00,           -- p_mensualidades (Monto mensual a pagar)
    '2025-01-30'        -- p_fecha_inicio_pago (Fecha del primer pago mensual)
);

