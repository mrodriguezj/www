DELIMITER $$

CREATE PROCEDURE insertar_propiedad (
    IN p_dimensiones DECIMAL(8,2),
    IN p_precio DECIMAL(10,2),
    IN p_tipo ENUM('Premium', 'Regular', 'Comercial'),
    IN p_disponibilidad ENUM('Disponible', 'Vendido', 'Reservado'),
    IN p_desarrollo VARCHAR(50),
    IN p_etapa TINYINT UNSIGNED,
    IN p_calle ENUM('Calle Colibri', 'Calle Quetzal', 'Calle Aguila', 'Calle Paloma', 'Avenida Ramal Norte'),
    IN p_observaciones TEXT
)
BEGIN
    -- Insertar nueva propiedad
    INSERT INTO propiedades (
        dimensiones, precio, tipo, disponibilidad,
        desarrollo, etapa, calle, observaciones
    ) VALUES (
        p_dimensiones, p_precio, p_tipo, p_disponibilidad,
        p_desarrollo, p_etapa, p_calle, p_observaciones
    );

    -- Retornar mensaje de éxito con el ID generado
    SELECT CONCAT('Propiedad insertada correctamente con ID: ', LAST_INSERT_ID()) AS resultado;
END$$

DELIMITER ;



CALL insertar_propiedad(
    120.50,                 -- dimensiones
    350000.00,              -- precio
    'Premium',              -- tipo
    'Disponible',           -- disponibilidad
    'Residencial Sol',      -- desarrollo
    2,                      -- etapa
    'Calle Colibri',        -- calle
    'Propiedad con excelente ubicación.' -- observaciones
);
