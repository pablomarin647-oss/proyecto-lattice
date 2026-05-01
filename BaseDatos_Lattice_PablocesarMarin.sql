DROP DATABASE IF EXISTS mi_basededatos;
CREATE DATABASE mi_basededatos;
USE mi_basededatos;

-- tipo_sistema
CREATE TABLE tipo_sistema (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT
) ENGINE=InnoDB;

-- sistema
CREATE TABLE sistema (
    id_sistema INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    modelo VARCHAR(100),
    estado VARCHAR(50),
    id_tipo INT,
    FOREIGN KEY (id_tipo) REFERENCES tipo_sistema(id_tipo) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- operacion
CREATE TABLE operacion (
    id_operacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    zona_geografica VARCHAR(200),
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR(50)
) ENGINE=InnoDB;

-- amenaza
CREATE TABLE amenaza (
    id_amenaza INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(100),
    nivel_peligro VARCHAR(50)
) ENGINE=InnoDB;

-- deteccion
CREATE TABLE deteccion (
    id_deteccion INT AUTO_INCREMENT PRIMARY KEY,
    id_sistema INT,
    id_operacion INT,
    id_amenaza INT,
    latitud DECIMAL(10,6),
    longitud DECIMAL(10,6),
    fecha_hora DATETIME,
    confirmada BOOLEAN,
    FOREIGN KEY (id_sistema) REFERENCES sistema(id_sistema) ON DELETE RESTRICT,
    FOREIGN KEY (id_operacion) REFERENCES operacion(id_operacion) ON DELETE RESTRICT,
    FOREIGN KEY (id_amenaza) REFERENCES amenaza(id_amenaza) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- unidad_militar
CREATE TABLE unidad_militar (
    id_unidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
) ENGINE=InnoDB;

-- soldado
CREATE TABLE soldado (
    id_soldado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    rango VARCHAR(50),
    id_unidad INT,
    FOREIGN KEY (id_unidad) REFERENCES unidad_militar(id_unidad) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- eagleeye
CREATE TABLE eagleeye (
    id_casco INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(100),
    estado VARCHAR(50)
) ENGINE=InnoDB;

-- asignacion_eagleeye
CREATE TABLE asignacion_eagleeye (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_soldado INT,
    id_casco INT,
    fecha_asignacion DATE,
    activo BOOLEAN,
    FOREIGN KEY (id_soldado) REFERENCES soldado(id_soldado) ON DELETE RESTRICT,
    FOREIGN KEY (id_casco) REFERENCES eagleeye(id_casco) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- mision
CREATE TABLE mision (
    id_mision INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(100),
    objetivo TEXT,
    resultado VARCHAR(50),
    estado VARCHAR(50),
    id_operacion INT,
    FOREIGN KEY (id_operacion) REFERENCES operacion(id_operacion) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- asignacion_sistema_mision
CREATE TABLE asignacion_sistema_mision (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_mision INT,
    id_sistema INT,
    rol VARCHAR(100),
    FOREIGN KEY (id_mision) REFERENCES mision(id_mision) ON DELETE RESTRICT,
    FOREIGN KEY (id_sistema) REFERENCES sistema(id_sistema) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- intercepcion
CREATE TABLE intercepcion (
    id_intercepcion INT AUTO_INCREMENT PRIMARY KEY,
    id_deteccion INT,
    resultado VARCHAR(50),
    municion_usada INT,
    FOREIGN KEY (id_deteccion) REFERENCES deteccion(id_deteccion) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- tipo_sistema
INSERT INTO tipo_sistema (nombre, descripcion) VALUES
('Sensor ISR', 'Sistema de reconocimiento'),
('Efector', 'Sistema de ataque'),
('Interfaz', 'Interfaz de usuario'),
('C4', 'Centro de comando'),
('Ataque', 'Plataforma ofensiva');

-- sistema
INSERT INTO sistema (nombre, modelo, estado, id_tipo) VALUES
('Sentry', 'S-100', 'Activo', 1),
('Omen', 'VTOL-X', 'Activo', 2),
('Roadrunner', 'RR-9', 'Activo', 2),
('Fury', 'YFQ-44A', 'Activo', 5),
('Menace-I', 'MN-1', 'Activo', 4);

-- operacion
INSERT INTO operacion (nombre, zona_geografica, fecha_inicio, fecha_fin, estado) VALUES
('Sombra de Acero', 'Pacifico', '2026-01-01', NULL, 'Activa');

-- amenaza
INSERT INTO amenaza (tipo, nivel_peligro) VALUES
('Dron enemigo', 'Alto'),
('Misil', 'Critico');

-- unidad_militar
INSERT INTO unidad_militar (nombre) VALUES
('Unidad A'),
('Unidad B');

-- soldado
INSERT INTO soldado (nombre, rango, id_unidad) VALUES
('Juan Perez', 'Teniente', 1),
('Carlos Ruiz', 'Sargento', 2);

-- eagleeye
INSERT INTO eagleeye (codigo, estado) VALUES
('EE-001', 'Activo'),
('EE-002', 'Activo');

-- asignacion_eagleeye
INSERT INTO asignacion_eagleeye (id_soldado, id_casco, fecha_asignacion, activo) VALUES
(1, 1, '2026-01-05', TRUE),
(2, 2, '2026-01-06', TRUE);

-- mision
INSERT INTO mision (tipo, objetivo, resultado, estado, id_operacion) VALUES
('Reconocimiento', 'Explorar zona', 'Exitoso', 'Completada', 1);

-- asignacion_sistema_mision
INSERT INTO asignacion_sistema_mision (id_mision, id_sistema, rol) VALUES
(1, 1, 'Vigilancia');

-- deteccion
INSERT INTO deteccion (id_sistema, id_operacion, id_amenaza, latitud, longitud, fecha_hora, confirmada) VALUES
(1, 1, 1, 10.123456, -75.123456, '2026-01-10 10:00:00', TRUE);

-- intercepcion
INSERT INTO intercepcion (id_deteccion, resultado, municion_usada) VALUES
(1, 'Exitosa', 5);

-- CONSULTA 1
SELECT s.nombre, s.modelo, s.estado, t.nombre AS tipo
FROM sistema s
INNER JOIN tipo_sistema t ON s.id_tipo = t.id_tipo;

-- CONSULTA 2
SELECT o.nombre, COUNT(d.id_deteccion) AS total_detecciones,
SUM(d.confirmada = TRUE) AS confirmadas
FROM operacion o
LEFT JOIN deteccion d ON o.id_operacion = d.id_operacion
GROUP BY o.nombre;

-- CONSULTA 3
SELECT s.nombre, s.rango, u.nombre AS unidad, e.codigo
FROM soldado s
INNER JOIN unidad_militar u ON s.id_unidad = u.id_unidad
INNER JOIN asignacion_eagleeye a ON s.id_soldado = a.id_soldado
INNER JOIN eagleeye e ON a.id_casco = e.id_casco
WHERE a.activo = TRUE;

-- CONSULTA 4
SELECT d.id_deteccion, a.tipo, a.nivel_peligro, d.latitud, d.longitud
FROM deteccion d
INNER JOIN amenaza a ON d.id_amenaza = a.id_amenaza
WHERE d.confirmada = TRUE
AND a.nivel_peligro IN ('Alto', 'Critico');

-- CONSULTA 5
SELECT resultado, COUNT(*) AS total
FROM intercepcion
GROUP BY resultado;

-- CONSULTA 6
SELECT m.tipo, s.nombre, asm.rol
FROM mision m
INNER JOIN asignacion_sistema_mision asm ON m.id_mision = asm.id_mision
INNER JOIN sistema s ON asm.id_sistema = s.id_sistema;

-- CONSULTA 7
SELECT s.nombre, COUNT(d.id_deteccion) AS total
FROM sistema s
INNER JOIN deteccion d ON s.id_sistema = d.id_sistema
GROUP BY s.nombre
HAVING COUNT(d.id_deteccion) > 1;

-- CONSULTA 8
SELECT * 
FROM deteccion
WHERE confirmada = FALSE;

-- CONSULTA 9
SELECT o.nombre, COUNT(m.id_mision) AS total_misiones
FROM operacion o
LEFT JOIN mision m ON o.id_operacion = m.id_operacion
GROUP BY o.nombre;

-- CONSULTA 10
SELECT i.id_intercepcion, s.nombre AS sistema, a.tipo AS amenaza, o.nombre AS operacion
FROM intercepcion i
INNER JOIN deteccion d ON i.id_deteccion = d.id_deteccion
INNER JOIN sistema s ON d.id_sistema = s.id_sistema
INNER JOIN amenaza a ON d.id_amenaza = a.id_amenaza
INNER JOIN operacion o ON d.id_operacion = o.id_operacion;

