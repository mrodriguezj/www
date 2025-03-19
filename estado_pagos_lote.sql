SELECT 
    cp.id_calendario,
    cp.id_lote,
    cp.numero_pago,
    cp.fecha_vencimiento,
    cp.monto_programado,
    cp.monto_restante,
    cp.categoria_pago,
    cp.estatus_pago
FROM 
    calendario_pagos cp
WHERE 
    cp.id_lote = 92 -- Aquí colocas el ID del lote que quieras consultar
ORDER BY 
    cp.fecha_vencimiento ASC;
