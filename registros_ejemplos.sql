use cobranza;

INSERT INTO propiedades (
    dimensiones,
    precio,
    tipo,
    disponibilidad,
    desarrollo,
    etapa,
    calle,
    observaciones
) VALUES
(150.75, 1200000.50, 'Premium', 'Disponible', 'Residencial Sol', 1, 'Calle Colibri', 'Propiedad con vista panorámica.'),
(200.25, 950000.00, 'Regular', 'Vendido', 'Villa Encanto', 2, 'Calle Aguila', 'Cerca de áreas verdes.'),
(175.60, 1350000.75, 'Comercial', 'Reservado', 'Plaza Norte', 1, 'Avenida Ramal Norte', 'Ubicación estratégica para negocios.'),
(220.10, 1600000.00, 'Premium', 'Disponible', 'Residencial Luna', 3, 'Calle Quetzal', 'Incluye acceso a casa club.'),
(185.80, 1100000.25, 'Regular', 'Disponible', 'Jardines del Valle', 2, 'Calle Paloma', 'Zona tranquila y familiar.');


INSERT INTO clientes (
    nombres,
    apellido_paterno,
    apellido_materno,
    correo_electronico,
    telefono,
    curp,
    rfc,
    ine,
    direccion,
    estatus
) VALUES
('Carlos', 'Hernández', 'Lopez', 'carlos.hernandez@example.com', '5512345678', 'HELC900101HDFRPR05', 'HELC900101ABC', 'INE12345678901234', 'Av. Reforma 123, CDMX', 'Activo'),
('María', 'González', 'Ramírez', 'maria.gonzalez@example.com', '5587654321', 'GORM850505MDFLZN08', 'GORM850505XYZ', 'INE23456789012345', 'Calle Juárez 456, Guadalajara', 'Activo'),
('Luis', 'Martínez', 'Sánchez', 'luis.martinez@example.com', '5543216789', 'MASL920303HDFRRL06', 'MASL920303LMN', 'INE34567890123456', 'Blvd. Colosio 789, Monterrey', 'Inactivo'),
('Ana', 'Fernández', 'Pérez', 'ana.fernandez@example.com', '5598765432', 'FEPA880202MDFLRS09', 'FEPA880202OPQ', 'INE45678901234567', 'Av. Universidad 234, Puebla', 'Activo'),
('Jorge', 'López', 'García', 'jorge.lopez@example.com', '5523456789', 'LOGJ870707HDFRRT02', 'LOGJ870707RST', 'INE56789012345678', 'Calle Insurgentes 567, Querétaro', 'Inactivo');
