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
            COALESCE(p_estatus, 'Activo') -- Si no se especifica estatus, será 'Activo'
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
    'juan.perez@ejemplo.com',
    '5551234567',
    'CURP123456HDFLPN01',
    'RFC1234567PL9',
    'INE12345678901234',
    'Av. Reforma 123, CDMX',
    'Activo'
);
