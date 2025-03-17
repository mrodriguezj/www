use u451524807_cobranza;

DELIMITER $$

CREATE PROCEDURE insertar_cliente (
    IN p_nombres VARCHAR(50), -- MAYÚSCULA
    IN p_apellido_paterno VARCHAR(50), -- MAYÚSCULA
    IN p_apellido_materno VARCHAR(50), -- MAYÚSCULA
    IN p_correo_electronico VARCHAR(100), -- MINÚSCULA
    IN p_telefono CHAR(10), -- NO APLICA
    IN p_curp CHAR(18), -- MAYÚSCULA
    IN p_rfc CHAR(13), -- MAYÚSCULA
    IN p_ine CHAR(18), -- MAYÚSCULA
    IN p_direccion VARCHAR(100), -- MAYÚSCULA
    IN p_estatus ENUM('Activo', 'Inactivo') -- NO APLICA
)
BEGIN
    DECLARE mensaje VARCHAR(255);

    -- Normalizar datos
    SET p_nombres = UPPER(p_nombres);
    SET p_apellido_paterno = UPPER(p_apellido_paterno);
    SET p_apellido_materno = UPPER(p_apellido_materno);
    SET p_correo_electronico = LOWER(p_correo_electronico);
    SET p_curp = UPPER(p_curp);
    SET p_rfc = UPPER(p_rfc);
    SET p_ine = UPPER(p_ine);
    SET p_direccion = UPPER(p_direccion);
    SET p_estatus = COALESCE(p_estatus, 'Activo'); -- Si no se especifica, será 'Activo'

    -- Validar existencia de datos únicos
    IF EXISTS (SELECT 1 FROM clientes WHERE correo_electronico = p_correo_electronico) THEN
        SET mensaje = 'Error: El correo electrónico ya está registrado.';
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE curp = p_curp) THEN
        SET mensaje = 'Error: La CURP ya está registrada.';
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE rfc = p_rfc) THEN
        SET mensaje = 'Error: El RFC ya está registrado.';
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE ine = p_ine) THEN
        SET mensaje = 'Error: La INE ya está registrada.';
    ELSE
        -- Insertar nuevo cliente
        INSERT INTO clientes (
            nombres, apellido_paterno, apellido_materno,
            correo_electronico, telefono, curp, rfc, ine, direccion, estatus
        ) VALUES (
            p_nombres, p_apellido_paterno, p_apellido_materno,
            p_correo_electronico, p_telefono, p_curp, p_rfc, p_ine, p_direccion, 
            p_estatus
        );

        SET mensaje = CONCAT('Cliente insertado correctamente con ID: ', LAST_INSERT_ID());
    END IF;

    -- Retornar mensaje
    SELECT mensaje AS resultado;
END$$

DELIMITER ;

CALL insertar_cliente(
    'Juan',
    'Pérez',
    'López',
    'Juan.Perez@Ejemplo.com', -- Se guardará como "juan.perez@ejemplo.com"
    '5551234567',
    'curp123456hdfLpN01', -- Se guardará como "CURP123456HDFLPN01"
    'rfc1234567pl9', -- Se guardará como "RFC1234567PL9"
    'ine12345678901230', -- Se guardará como "INE12345678901234"
    'Av. Reforma 123, cdmx', -- Se guardará como "AV. REFORMA 123, CDMX"
    NULL -- No envía estatus, por lo que quedará como 'Activo'
);

DELIMITER $$

CREATE PROCEDURE insertar_cliente (
    IN p_nombres VARCHAR(50),
    IN p_apellido_paterno VARCHAR(50),
    IN p_apellido_materno VARCHAR(50),
    IN p_correo_electronico VARCHAR(100),
    IN p_telefono CHAR(10),
    IN p_curp CHAR(18),
    IN p_rfc CHAR(13),
    IN p_ine CHAR(18),
    IN p_direccion VARCHAR(100),
    IN p_estatus ENUM('Activo', 'Inactivo')
)
BEGIN
    DECLARE mensaje VARCHAR(255);

    -- Validar si existen datos únicos duplicados
    IF EXISTS (SELECT 1 FROM clientes WHERE correo_electronico = p_correo_electronico) THEN
        SET mensaje = 'Error: El correo electrónico ya está registrado.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE curp = p_curp) THEN
        SET mensaje = 'Error: La CURP ya está registrada.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE rfc = p_rfc) THEN
        SET mensaje = 'Error: El RFC ya está registrado.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE ine = p_ine) THEN
        SET mensaje = 'Error: La INE ya está registrada.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    ELSE
        -- Insertar nuevo cliente
        INSERT INTO clientes (
            nombres, apellido_paterno, apellido_materno,
            correo_electronico, telefono, curp, rfc, ine, direccion, estatus
        ) VALUES (
            p_nombres, p_apellido_paterno, p_apellido_materno,
            p_correo_electronico, p_telefono, p_curp, p_rfc, p_ine, p_direccion, 
            COALESCE(p_estatus, 'Activo')
        );

        SET mensaje = 'Cliente registrado correctamente';
    END IF;

    -- Retornar mensaje
    SELECT mensaje AS resultado;
END$$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE insertar_cliente (
    IN p_nombres VARCHAR(50), -- MAYÚSCULA
    IN p_apellido_paterno VARCHAR(50), -- MAYÚSCULA
    IN p_apellido_materno VARCHAR(50), -- MAYÚSCULA
    IN p_correo_electronico VARCHAR(100), -- MINÚSCULA
    IN p_telefono CHAR(10), -- NO APLICA
    IN p_curp CHAR(18), -- MAYÚSCULA
    IN p_rfc CHAR(13), -- MAYÚSCULA
    IN p_ine CHAR(18), -- MAYÚSCULA
    IN p_direccion VARCHAR(100), -- MAYÚSCULA
    IN p_estatus ENUM('Activo', 'Inactivo') -- NO APLICA
)
BEGIN
    DECLARE mensaje VARCHAR(255);

    -- Normalizar datos
    SET p_nombres = UPPER(p_nombres);
    SET p_apellido_paterno = UPPER(p_apellido_paterno);
    SET p_apellido_materno = UPPER(p_apellido_materno);
    SET p_correo_electronico = LOWER(p_correo_electronico);
    SET p_curp = UPPER(p_curp);
    SET p_rfc = UPPER(p_rfc);
    SET p_ine = UPPER(p_ine);
    SET p_direccion = UPPER(p_direccion);
    SET p_estatus = COALESCE(p_estatus, 'Activo'); -- Si no se especifica, será 'Activo'

    -- Validar existencia de datos únicos
    IF EXISTS (SELECT 1 FROM clientes WHERE correo_electronico = p_correo_electronico) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El correo electrónico ya está registrado.';
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE curp = p_curp) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La CURP ya está registrada.';
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE rfc = p_rfc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El RFC ya está registrado.';
    ELSEIF EXISTS (SELECT 1 FROM clientes WHERE ine = p_ine) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La INE ya está registrada.';
    ELSE
        -- Insertar nuevo cliente con datos normalizados
        INSERT INTO clientes (
            nombres, apellido_paterno, apellido_materno,
            correo_electronico, telefono, curp, rfc, ine, direccion, estatus
        ) VALUES (
            p_nombres, p_apellido_paterno, p_apellido_materno,
            p_correo_electronico, p_telefono, p_curp, p_rfc, p_ine, p_direccion, p_estatus
        );

        SET mensaje = 'Cliente registrado correctamente';
    END IF;

    -- Retornar mensaje
    SELECT mensaje AS resultado;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE listar_clientes_activos()
BEGIN
    SELECT 
        id_cliente, 
        CONCAT(nombres, ' ', apellido_paterno, ' ', apellido_materno) AS nombre_completo
    FROM clientes
    WHERE estatus = 'Activo'
    ORDER BY nombres ASC;
END$$

DELIMITER ;

call listar_clientes_activos;

DELIMITER $$

CREATE PROCEDURE listar_lotes_disponibles()
BEGIN
    SELECT 
        id_lote,
        CONCAT('Lote ', id_lote, ' - ', calle, ' - ', desarrollo) AS descripcion,
        precio
    FROM propiedades
    WHERE disponibilidad = 'Disponible'
    ORDER BY id_lote ASC;
END$$

DELIMITER ;

CALL listar_lotes_disponibles;



DELIMITER $$

CREATE PROCEDURE proyeccion_pagos_totales (
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_fecha_consulta DATE,
    IN p_estado VARCHAR(20),          -- 'Pagado', 'Pendiente', 'Vencido' o ''
    IN p_cliente_nombre VARCHAR(100)  -- Nombre del cliente (opcional)
)
BEGIN
    SELECT
        SUM(cp.monto_programado) AS total_programado,
        
        SUM(
            CASE
                WHEN cp.monto_restante = 0 THEN cp.monto_programado
                ELSE 0
            END
        ) AS total_cobrado,
        
        SUM(
            CASE
                WHEN cp.monto_restante > 0 AND cp.fecha_vencimiento >= p_fecha_consulta THEN cp.monto_restante
                ELSE 0
            END
        ) AS total_pendiente,
        
        SUM(
            CASE
                WHEN cp.monto_restante > 0 AND cp.fecha_vencimiento < p_fecha_consulta THEN cp.monto_restante
                ELSE 0
            END
        ) AS total_vencido

    FROM calendario_pagos cp
    INNER JOIN propiedades pr ON cp.id_lote = pr.id_lote
    INNER JOIN ventas ve ON ve.id_lote = pr.id_lote
    INNER JOIN clientes cl ON cl.id_cliente = ve.id_cliente

    WHERE cp.fecha_vencimiento BETWEEN p_fecha_inicio AND p_fecha_fin

    -- Filtro de estado
    AND (
        p_estado = '' OR
        (
            (p_estado = 'Pagado' AND cp.monto_restante = 0) OR
            (p_estado = 'Pendiente' AND cp.monto_restante > 0 AND cp.fecha_vencimiento >= p_fecha_consulta) OR
            (p_estado = 'Vencido' AND cp.monto_restante > 0 AND cp.fecha_vencimiento < p_fecha_consulta)
        )
    )

    -- Filtro por cliente (opcional)
    AND (
        p_cliente_nombre = '' OR
        cl.nombres LIKE CONCAT('%', p_cliente_nombre, '%')
    );
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE proyeccion_pagos_detalle (
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_fecha_consulta DATE,
    IN p_estado VARCHAR(20),          -- 'Pagado', 'Pendiente', 'Vencido' o ''
    IN p_cliente_nombre VARCHAR(100), -- Nombre del cliente (opcional)
    IN p_limit INT,                   -- Cantidad de registros por carga
    IN p_offset INT                   -- Offset para scroll infinito
)
BEGIN
    SELECT
        cp.id_calendario,
        pr.id_lote,
        cl.nombres AS cliente_nombre,
        
        -- Campo opcional para mostrar en frontend
        CONCAT(pr.calle, ' - Etapa ', pr.etapa) AS descripcion_lote,
        
        cp.fecha_vencimiento,
        cp.monto_programado,
        cp.monto_restante,
        cp.categoria_pago,

        CASE
            WHEN cp.monto_restante = 0 THEN 'Pagado'
            WHEN cp.fecha_vencimiento < p_fecha_consulta THEN 'Vencido'
            ELSE 'Pendiente'
        END AS estatus_pago,

        CASE
            WHEN cp.monto_restante = 0 THEN 0
            WHEN cp.fecha_vencimiento < p_fecha_consulta THEN DATEDIFF(p_fecha_consulta, cp.fecha_vencimiento)
            ELSE 0
        END AS dias_atraso

    FROM calendario_pagos cp
    INNER JOIN propiedades pr ON cp.id_lote = pr.id_lote
    INNER JOIN ventas ve ON ve.id_lote = pr.id_lote
    INNER JOIN clientes cl ON cl.id_cliente = ve.id_cliente

    WHERE cp.fecha_vencimiento BETWEEN p_fecha_inicio AND p_fecha_fin

    -- Filtro de estado
    AND (
        p_estado = '' OR
        (
            (p_estado = 'Pagado' AND cp.monto_restante = 0) OR
            (p_estado = 'Pendiente' AND cp.monto_restante > 0 AND cp.fecha_vencimiento >= p_fecha_consulta) OR
            (p_estado = 'Vencido' AND cp.monto_restante > 0 AND cp.fecha_vencimiento < p_fecha_consulta)
        )
    )

    -- Filtro por cliente (opcional)
    AND (
        p_cliente_nombre = '' OR
        cl.nombres LIKE CONCAT('%', p_cliente_nombre, '%')
    )

    ORDER BY cp.fecha_vencimiento ASC

    LIMIT p_limit OFFSET p_offset;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE reporte_pagos_mensualidades (
    IN p_cliente_nombre VARCHAR(100),   -- '%Juan%' o '' para todos
    IN p_fecha_pago_inicio DATE,        -- '2025-03-01' o NULL
    IN p_fecha_pago_fin DATE            -- '2025-03-31' o NULL
)
BEGIN
    SELECT
        cl.nombres AS cliente_nombre,
        
        -- Lote con ID para identificación clara
        pr.id_lote,

        -- (Opcional) descripción para contexto, lo puedes quitar en la proyección
        CONCAT(pr.calle, ' - Etapa ', pr.etapa) AS descripcion_lote,

        -- Datos del pago realizado
        pag.id_pago,
        pag.fecha_pago,
        pag.monto_pagado,
        pag.categoria_pago AS tipo_pago,
        pag.metodo_pago,
        pag.referencia_pago,

        -- Datos de la relación con la mensualidad
        pmr.monto_asignado,

        -- Datos de la mensualidad pagada
        cal.numero_pago,
        cal.fecha_vencimiento,
        cal.categoria_pago AS tipo_mensualidad

    FROM pagos_mensualidades_relacion pmr
    INNER JOIN pagos_realizados pag ON pmr.id_pago = pag.id_pago
    INNER JOIN calendario_pagos cal ON pmr.id_calendario = cal.id_calendario
    INNER JOIN propiedades pr ON pag.id_lote = pr.id_lote
    INNER JOIN ventas ve ON ve.id_lote = pr.id_lote
    INNER JOIN clientes cl ON cl.id_cliente = ve.id_cliente

    WHERE
        -- Filtro opcional por cliente (si viene)
        (p_cliente_nombre = '' OR cl.nombres LIKE CONCAT('%', p_cliente_nombre, '%'))

        -- Filtro opcional por rango de fecha de pago (si vienen ambos valores)
        AND (p_fecha_pago_inicio IS NULL OR pag.fecha_pago >= p_fecha_pago_inicio)
        AND (p_fecha_pago_fin IS NULL OR pag.fecha_pago <= p_fecha_pago_fin)

    ORDER BY pag.fecha_pago ASC, cal.numero_pago ASC;
END$$

DELIMITER ;

CALL reporte_pagos_mensualidades('Nanci', NULL, NULL);

DELIMITER $$

CREATE PROCEDURE reporte_pagos_mensualidades (
    IN p_cliente_nombre VARCHAR(100),   -- '%Juan%' o '' para todos
    IN p_fecha_pago_inicio DATE,        -- '2025-03-01' o NULL
    IN p_fecha_pago_fin DATE,           -- '2025-03-31' o NULL
    IN p_id_lote INT                    -- ID específico o 0 para todos
)
BEGIN
    SELECT
        cl.nombres AS cliente_nombre,
        
        -- Lote con ID como referencia principal
        pr.id_lote,

        -- (Opcional) descripción para referencia
        CONCAT(pr.calle, ' - Etapa ', pr.etapa) AS descripcion_lote,

        -- Datos del pago realizado
        pag.id_pago,
        pag.fecha_pago,
        pag.monto_pagado,
        pag.categoria_pago AS tipo_pago,
        pag.metodo_pago,
        pag.referencia_pago,

        -- Datos de la relación con la mensualidad
        pmr.monto_asignado,

        -- Datos de la mensualidad pagada
        cal.numero_pago,
        cal.fecha_vencimiento,
        cal.categoria_pago AS tipo_mensualidad

    FROM pagos_mensualidades_relacion pmr
    INNER JOIN pagos_realizados pag ON pmr.id_pago = pag.id_pago
    INNER JOIN calendario_pagos cal ON pmr.id_calendario = cal.id_calendario
    INNER JOIN propiedades pr ON pag.id_lote = pr.id_lote
    INNER JOIN ventas ve ON ve.id_lote = pr.id_lote
    INNER JOIN clientes cl ON cl.id_cliente = ve.id_cliente

    WHERE
        -- Filtro por cliente (opcional)
        (p_cliente_nombre = '' OR cl.nombres LIKE CONCAT('%', p_cliente_nombre, '%'))

        -- Filtro por fecha de pago (opcional)
        AND (p_fecha_pago_inicio IS NULL OR pag.fecha_pago >= p_fecha_pago_inicio)
        AND (p_fecha_pago_fin IS NULL OR pag.fecha_pago <= p_fecha_pago_fin)

        -- Filtro por id_lote (opcional)
        AND (p_id_lote = 0 OR pr.id_lote = p_id_lote)

    ORDER BY pag.fecha_pago ASC, cal.numero_pago ASC;
END$$

DELIMITER ;

CALL reporte_pagos_mensualidades('', NULL, NULL, 2);

SET FOREIGN_KEY_CHECKS = 0;

truncate table ventas;
truncate table propiedades;
truncate table pagos_realizados;
truncate table pagos_mensualidades_relacion;
truncate table pagos_anteriores_referencia;
truncate table historial_comisiones;
truncate table comisiones_ventas;
truncate table calendario_pagos;
truncate table clientes;

SET FOREIGN_KEY_CHECKS = 1;

show table status;



DELIMITER $$

DELIMITER $$

CREATE PROCEDURE insertar_propiedad (
    IN p_dimensiones DECIMAL(8,2),
    IN p_precio DECIMAL(10,2),
    IN p_tipo VARCHAR(20),
    IN p_disponibilidad VARCHAR(20),
    IN p_desarrollo VARCHAR(50),
    IN p_etapa TINYINT UNSIGNED,
    IN p_calle VARCHAR(50),
    IN p_observaciones TEXT
)
BEGIN
    -- Validación ENUM tipo
    IF p_tipo NOT IN ('Premium', 'Regular', 'Comercial') THEN
        SELECT 'Error: Tipo de lote inválido.' AS resultado;
    ELSEIF p_disponibilidad NOT IN ('Disponible', 'Vendido', 'Reservado') THEN
        SELECT 'Error: Disponibilidad inválida.' AS resultado;
    ELSEIF p_calle NOT IN (
        'Calle Colibri',
        'Calle Quetzal',
        'Calle Aguila',
        'Calle Paloma',
        'Avenida Ramal Norte'
    ) THEN
        SELECT 'Error: Calle inválida.' AS resultado;
    ELSE
        INSERT INTO propiedades (
            dimensiones, precio, tipo, disponibilidad, desarrollo, etapa, calle, observaciones
        ) VALUES (
            p_dimensiones, p_precio, p_tipo, p_disponibilidad, p_desarrollo, p_etapa, p_calle, p_observaciones
        );

        SELECT CONCAT('Propiedad insertada correctamente con ID: ', LAST_INSERT_ID()) AS resultado;
    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insertar_pago_especial (
    IN p_id_lote INT,
    IN p_fecha_vencimiento DATE,
    IN p_monto_programado DECIMAL(10,2),
    IN p_categoria_pago ENUM('Enganche', 'Contado', 'Mensualidad', 'Anualidad')
)
BEGIN
    DECLARE mensaje VARCHAR(255);
    DECLARE nuevo_numero_pago INT;

    -- Verificar que el lote exista
    IF NOT EXISTS (SELECT 1 FROM propiedades WHERE id_lote = p_id_lote) THEN
        SELECT 'Error: El lote no existe.' AS resultado;
    ELSE
        -- Obtener el siguiente número de pago consecutivo para el lote
        SELECT IFNULL(MAX(numero_pago), 0) + 1
        INTO nuevo_numero_pago
        FROM calendario_pagos
        WHERE id_lote = p_id_lote;

        -- Insertar el pago especial
        INSERT INTO calendario_pagos (
            id_lote, numero_pago, fecha_vencimiento,
            monto_programado, monto_restante,
            categoria_pago, estatus_pago
        ) VALUES (
            p_id_lote,
            nuevo_numero_pago,
            p_fecha_vencimiento,
            p_monto_programado,
            p_monto_programado,
            p_categoria_pago,
            'Pendiente'
        );

        SET mensaje = CONCAT('Pago especial agregado correctamente. ID Calendario: ', LAST_INSERT_ID(), '. Número de pago asignado: ', nuevo_numero_pago);
        SELECT mensaje AS resultado;
    END IF;
END$$

DELIMITER ;


CALL insertar_pago_especial(
    6,                      -- id_lote
    '2025-03-20',            -- fecha_vencimiento
    81750.00,                -- monto_programado
    'Mensualidad'              -- categoria_pago
);



DELIMITER $$

CREATE PROCEDURE reprogramar_calendario_pagos_especial (
    IN p_id_lote INT
)
BEGIN
    DECLARE v_fecha_base DATE;
    DECLARE v_numero_pago INT DEFAULT 2;
    DECLARE v_mes INT;
    DECLARE v_anio INT;
    DECLARE v_dia_pago INT;
    DECLARE v_fecha_vencimiento DATE;
    DECLARE v_total_pagos INT DEFAULT 72;

    -- Verifica que el lote exista
    IF NOT EXISTS (SELECT 1 FROM propiedades WHERE id_lote = p_id_lote) THEN
        SELECT 'Error: El lote no existe.' AS resultado;
    ELSE
        -- Obtener la fecha del primer pago para usar como base
        SELECT fecha_vencimiento INTO v_fecha_base
        FROM calendario_pagos
        WHERE id_lote = p_id_lote AND numero_pago = 1;

        -- Si no existe el pago 1, no hace nada
        IF v_fecha_base IS NULL THEN
            SELECT 'Error: No se encontró el primer pago para este lote.' AS resultado;
        ELSE
            -- Bucle para reprogramar desde el pago 2 hasta el 72
            WHILE v_numero_pago <= v_total_pagos DO

                -- Obtener el año y mes según el pago a actualizar
                SET v_mes = MONTH(DATE_ADD(v_fecha_base, INTERVAL (v_numero_pago - 1) MONTH));
                SET v_anio = YEAR(DATE_ADD(v_fecha_base, INTERVAL (v_numero_pago - 1) MONTH));

                -- Si el mes es febrero (mes 2), día de pago es 28
                IF v_mes = 2 THEN
                    SET v_dia_pago = 28;
                ELSE
                    SET v_dia_pago = 30;
                END IF;

                -- Generar la nueva fecha de vencimiento
                SET v_fecha_vencimiento = STR_TO_DATE(CONCAT(v_anio, '-', v_mes, '-', v_dia_pago), '%Y-%m-%d');

                -- Actualizar el calendario de pagos
                UPDATE calendario_pagos
                SET fecha_vencimiento = v_fecha_vencimiento
                WHERE id_lote = p_id_lote AND numero_pago = v_numero_pago;

                -- Incrementa al siguiente pago
                SET v_numero_pago = v_numero_pago + 1;

            END WHILE;

            SELECT CONCAT('Reprogramación completada para el lote ID: ', p_id_lote) AS resultado;

        END IF;
    END IF;

END$$

DELIMITER ;


CALL reprogramar_calendario_pagos_especial(106);


SELECT
    numero_pago,
    fecha_vencimiento,
    monto_programado,
    monto_restante,
    categoria_pago,
    estatus_pago
FROM calendario_pagos
WHERE id_lote = 5 -- Cambia aquí el ID de lote que desees verificar
ORDER BY numero_pago ASC;


SELECT DISTINCT id_lote
FROM calendario_pagos
WHERE numero_pago = 1
  AND fecha_vencimiento = '2025-02-28';


SELECT NOW() AS fecha_hora_actual;

SELECT @@session.time_zone AS zona_horaria_sesion;

SELECT NOW(), CURRENT_TIMESTAMP, UTC_TIMESTAMP;


SELECT id_calendario, estatus_pago, monto_restante
FROM calendario_pagos
WHERE id_calendario IN (153, 154);



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

        -- Buscar el siguiente calendario pendiente por pagar
        SELECT id_calendario, monto_restante
        INTO v_id_calendario, v_monto_restante
        FROM calendario_pagos
        WHERE id_lote = p_id_lote AND estatus_pago = 'Pendiente'
        ORDER BY fecha_vencimiento ASC
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




SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE pagos_mensualidades_relacion;
TRUNCATE TABLE historial_comisiones;
TRUNCATE TABLE pagos_anteriores_referencia;
TRUNCATE TABLE pagos_realizados;
TRUNCATE TABLE calendario_pagos;

SET FOREIGN_KEY_CHECKS = 1;


SELECT id_calendario, monto_restante
INTO v_id_calendario, v_monto_restante
FROM calendario_pagos
WHERE id_lote = p_id_lote AND estatus_pago = 'Pendiente'
ORDER BY fecha_vencimiento ASC
LIMIT 1;


DELIMITER $$ --4.0

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

