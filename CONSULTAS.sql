use u451524807_cobranza;

SELECT 
    pmp.id_relacion AS folio_pago,
    pr.id_pago,
    pr.fecha_pago,
    pr.monto_pagado AS monto_total_pago,
    pr.categoria_pago,
    pr.metodo_pago,
    pr.referencia_pago,
    pr.registro_pago AS fecha_registro,
    pr.observaciones,
    
    pmp.monto_asignado AS monto_aplicado_al_calendario,

    cp.id_calendario,
    cp.fecha_vencimiento,
    cp.estatus_pago AS estatus_calendario,
    
    prop.id_lote

FROM pagos_mensualidades_relacion pmp
INNER JOIN pagos_realizados pr
    ON pmp.id_pago = pr.id_pago
INNER JOIN calendario_pagos cp
    ON pmp.id_calendario = cp.id_calendario
INNER JOIN propiedades prop
    ON cp.id_lote = prop.id_lote

WHERE cp.id_calendario = 2714;





SHOW TABLE STATUS LIKE 'calendario_pagos';


SELECT DISTINCT id_lote
FROM calendario_pagos
WHERE id_lote NOT IN (
  SELECT id_lote FROM propiedades
);


SELECT
    id_calendario,
    id_lote,
    concepto_pago,
    monto_programado,
    monto_restante,
    estatus_pago,
    (monto_programado - monto_restante) AS monto_pagado
FROM
    calendario_pagos
WHERE
    monto_restante > 0 -- Deben algo
    AND monto_restante < 10 -- Solo pequeños saldos
ORDER BY
    monto_restante ASC; -- Del más pequeño al más grande
    
    
SELECT
    id_calendario,
    id_lote,
    categoria_pago,
    monto_programado,
    monto_restante,
    estatus_pago,
    (monto_programado - monto_restante) AS monto_pagado
FROM
    calendario_pagos
WHERE
    monto_restante > 0
    AND monto_restante < 10
ORDER BY
    monto_restante ASC;

