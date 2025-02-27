-- Procedimiento: Reporte de pagos realizados por lote
-- Devuelve todos los pagos que se han aplicado a un lote específico.

DELIMITER $$

CREATE PROCEDURE reporte_pagos_realizados (
    IN p_id_lote INT UNSIGNED
)
BEGIN
    SELECT 
        pr.id_pago,
        pr.fecha_pago,
        pr.monto_pagado,
        pr.categoria_pago,
        pr.metodo_pago,
        pr.referencia_pago,
        pr.observaciones
    FROM pagos_realizados pr
    WHERE pr.id_lote = p_id_lote
    ORDER BY pr.fecha_pago ASC;
END$$

DELIMITER ;

CALL reporte_pagos_realizados(1);


-- Procedimiento: Reporte de mensualidades pendientes por lote
-- Muestra las mensualidades que aún tienen saldo pendiente.

DELIMITER $$

CREATE PROCEDURE reporte_mensualidades_pendientes (
    IN p_id_lote INT UNSIGNED
)
BEGIN
    SELECT 
        cp.id_calendario,
        cp.fecha_vencimiento,
        cp.monto_programado,
        cp.monto_restante,
        cp.estatus_pago
    FROM calendario_pagos cp
    WHERE cp.id_lote = p_id_lote AND cp.monto_restante > 0
    ORDER BY cp.fecha_vencimiento ASC;
END$$

DELIMITER ;

CALL reporte_mensualidades_pendientes(1);


-- Procedimiento: Reporte de estado de cuenta de un lote
-- Muestra un historial de pagos realizados y mensualidades pendientes en un solo reporte.

DELIMITER $$

CREATE PROCEDURE reporte_estado_cuenta (
    IN p_id_lote INT UNSIGNED
)
BEGIN
    SELECT 
        'Pago Realizado' AS tipo_registro,
        pr.fecha_pago,
        pr.monto_pagado AS monto,
        pr.metodo_pago,
        pr.observaciones
    FROM pagos_realizados pr
    WHERE pr.id_lote = p_id_lote

    UNION ALL

    SELECT 
        'Mensualidad Pendiente' AS tipo_registro,
        cp.fecha_vencimiento AS fecha_pago,
        cp.monto_restante AS monto,
        NULL AS metodo_pago,
        'Pago pendiente' AS observaciones
    FROM calendario_pagos cp
    WHERE cp.id_lote = p_id_lote AND cp.monto_restante > 0
    ORDER BY fecha_pago ASC;
END$$

DELIMITER ;

CALL reporte_estado_cuenta(1);


-- Procedimiento: Reporte de cobranza mensual
-- Compara el estimado de cobranza contra lo realmente cobrado cada mes.

DELIMITER $$

CREATE PROCEDURE reporte_cobranza_mensual (
    IN p_year INT
)
BEGIN
    SELECT 
        DATE_FORMAT(cp.fecha_vencimiento, '%Y-%m') AS mes,
        SUM(cp.monto_programado) AS estimado_cobranza,
        COALESCE((SELECT SUM(pr.monto_pagado)
                  FROM pagos_realizados pr
                  WHERE DATE_FORMAT(pr.fecha_pago, '%Y-%m') = DATE_FORMAT(cp.fecha_vencimiento, '%Y-%m')), 0) AS cobrado_real,
        (SUM(cp.monto_programado) - 
         COALESCE((SELECT SUM(pr.monto_pagado)
                   FROM pagos_realizados pr
                   WHERE DATE_FORMAT(pr.fecha_pago, '%Y-%m') = DATE_FORMAT(cp.fecha_vencimiento, '%Y-%m')), 0)) AS diferencia
    FROM calendario_pagos cp
    WHERE YEAR(cp.fecha_vencimiento) = p_year
    GROUP BY mes
    ORDER BY mes ASC;
END$$

DELIMITER ;

CALL reporte_cobranza_mensual(2025);
