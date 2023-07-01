drop table if exists enemdu;
CREATE TABLE enemdu(
  area VARCHAR(10),
  ciudad VARCHAR(10),
  conglomerado INT,
  panelm INT,
  vivienda INT,
  hogar INT,
  via_principal INT,
  tipo_vivienda INT,
  material_techo INT,
  estado_techo INT,
  material_piso INT,
  estado_piso INT,
  material_paredes INT,
  estado_paredes INT,
  numero_cuartos INT,
  numero_dormitorios INT,
  num_cuartos_negocio INT,
  existe_cocina INT,
  material_cocinan INT,
  tipo_servicio_higienico INT,
  no_higienico_tipo VARCHAR(10),
  tipo_instalacion_sanitaria VARCHAR(10),
  obtencion_agua INT,
  tiene_medidor VARCHAR(10),
  obt_junta_agua VARCHAR(10),
  agua_recibida INT,
  servicio_ducha INT,
  tipo_alumbrado INT,
  eliminacion_basura INT,
  tenencia_vivienda INT,
  valor_pagaria_arriendo INT,
  arriendo_incluye_agua VARCHAR(10),
  arriendo_incluye_luz VARCHAR(10),
  relacion_propietario VARCHAR(10),
  tiene_vehiculo INT,
  numero_vehiculos VARCHAR(10),
  tiene_motos INT,
  numero_motos VARCHAR(10),
  abastecimiento_super VARCHAR(10),
  gasto_super VARCHAR(10),
  abastecimiento_extra VARCHAR(10),
  gasto_extra VARCHAR(10),
  abastecimiento_diesel VARCHAR(10),
  gasto_diesel VARCHAR(10),
  abastecimiento_ecopais VARCHAR(10),
  gasto_ecopais VARCHAR(10),
  abastecimiento_electricidad VARCHAR(10),
  gasto_electricidad VARCHAR(10),
  abastecimiento_gas VARCHAR(10),
  gasto_gas VARCHAR(10),
  estrato INT,
  factor_expansion VARCHAR(100),
  up_muestreo DOUBLE,
  id_vivienda VARCHAR(30),
  id_hogar VARCHAR(30),
  periodo INT,
  mes INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/enemdu.csv'
INTO TABLE enemdu
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES ;

-- Información complementaria a parroquias
DROP TABLE IF EXISTS informacion_ciudad;
CREATE TABLE informacion_ciudad (
  codigo_provincia VARCHAR(20),
  codigo_canton VARCHAR(20),
  codigo_parroquia VARCHAR(20),
  nombre_provincia varchar(40),
  nombre_canton VARCHAR(40),
  nombre_parroquia VARCHAR(100)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/postalitos.csv'
INTO TABLE informacion_ciudad
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE informacion_ciudad
    ADD COLUMN CODIGO_POSTAL VARCHAR(10);

UPDATE informacion_ciudad
SET CODIGO_POSTAL = CONCAT(IF(codigo_provincia like '0%', substring(codigo_provincia, 2), codigo_provincia), codigo_canton, codigo_parroquia);


-- Tabla con información adicional de ingreso percápita, empleo y desempleo
DROP TABLE IF EXISTS INGRESO_EMPLEO;
CREATE TABLE INGRESO_EMPLEO(
    CIUDAD VARCHAR(20),
    INGRESO_PERCAPITA DOUBLE NULL,
    EMPLEO VARCHAR(4),
    DESEMPLEO VARCHAR(4)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ingreso_empleo.csv'
INTO TABLE INGRESO_EMPLEO
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(CIUDAD, @INGRESO_PERCAPITA, EMPLEO, DESEMPLEO)
SET INGRESO_PERCAPITA = NULLIF(@INGRESO_PERCAPITA, '');


-- Tabla sobre la salud y educación
DROP TABLE IF EXISTS salud_educacion;

CREATE TABLE salud_educacion (
    CIUDAD VARCHAR(20),
    pensiones_jubilacion DOUBLE NULL,
    salud INT NULL,
    educacion VARCHAR(10) NULL
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/salud_educacion.csv'
INTO TABLE salud_educacion
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(CIUDAD, @ingreso_pensiones, @salud, @educacion)
SET pensiones_jubilacion = NULLIF(TRIM(@ingreso_pensiones), ''),
    salud = NULLIF(TRIM(@salud), ''),
    educacion = NULLIF(TRIM(@educacion), '');

drop table if exists habitaciones;

drop table if exists hogar_combustible;

drop table if exists combustible;

drop table if exists hogar_vivienda;

drop table if exists info_vivienda;

drop table if exists informacion_hogar;

drop table if exists materiales_construccion;

drop table if exists servicios_basicos;

drop table if exists servicios_higienicos;

drop table if exists vehiculo;

drop table if exists vivienda_ubicacion;

drop table if exists vivienda;

DROP TABLE IF EXISTS hogar_arriendo;

drop table if exists hogar;

DROP TABLE IF EXISTS VIVIENDA_UBICACION;
DROP TABLE IF EXISTS SALUD_EDUCACION_JUBILACION;
DROP TABLE IF EXISTS TASA_EMPLEO;
drop table if exists UBICACION;



 -- Tabla vivienda
DROP TABLE IF EXISTS vivienda;
CREATE TABLE vivienda AS SELECT DISTINCT E.id_vivienda
                         FROM ENEMDU E;
ALTER TABLE vivienda ADD PRIMARY KEY (id_vivienda);

-- Tabla info_vivienda
DROP TABLE IF EXISTS info_vivienda;
CREATE TABLE info_vivienda AS SELECT DISTINCT e.id_vivienda,
                              E.area,
                              E.via_principal,
                              E.tipo_vivienda,
                              E.tenencia_vivienda,
                              E.tipo_alumbrado,
                              E.servicio_ducha
                       FROM enemdu e;
ALTER TABLE info_vivienda ADD FOREIGN KEY (id_vivienda) REFERENCES vivienda(id_vivienda);

-- TABLA HOGAR
DROP TABLE IF EXISTS HOGAR;
CREATE TABLE HOGAR AS SELECT DISTINCT E.id_hogar
                                FROM enemdu E;
ALTER TABLE HOGAR ADD PRIMARY KEY (id_hogar);

-- Tabla hogar
DROP TABLE IF EXISTS  hogar_vivienda;
CREATE TABLE hogar_vivienda AS SELECT DISTINCT E.id_vivienda,
                                      E.id_hogar,
                                      E.hogar,
                                      E.periodo,
                                      E.valor_pagaria_arriendo
                      FROM enemdu e;
ALTER TABLE hogar_vivienda ADD FOREIGN KEY (id_vivienda) REFERENCES vivienda (id_vivienda),
    ADD FOREIGN KEY (id_hogar) REFERENCES HOGAR (id_hogar);


-- Tabla hogar_arriendo
DROP TABLE IF EXISTS hogar_arriendo;
CREATE TABLE hogar_arriendo AS SELECT DISTINCT E.id_hogar,
                                               e.relacion_propietario,
                                               e.arriendo_incluye_agua,
                                               e.arriendo_incluye_luz
                                   FROM enemdu E
                                    WHERE E.id_hogar IS NOT NULL AND
                                               trim(e.relacion_propietario)IS NOT NULL AND
                                               trim(e.arriendo_incluye_agua) IS NOT NULL AND
                                               trim(e.arriendo_incluye_luz) IS NOT NULL;

ALTER TABLE hogar_arriendo ADD FOREIGN KEY (id_hogar) REFERENCES hogar(id_hogar);
-- Tabla vehiculos
DROP TABLE IF EXISTS vehiculo;
CREATE TABLE VEHICULO AS SELECT DISTINCT E.id_hogar, E.numero_vehiculos, E.numero_motos
                          FROM enemdu E
                        WHERE E.numero_vehiculos >= 1;
ALTER TABLE VEHICULO ADD FOREIGN KEY (id_hogar ) REFERENCES hogar(id_hogar);

-- Tabla Combustible
DROP TABLE IF EXISTS COMBUSTIBLE;
CREATE TABLE COMBUSTIBLE (
    combustible varchar(20) PRIMARY KEY
);
INSERT INTO COMBUSTIBLE VALUES ('Gas'),('Electricidad'),
                                ('Extra'),
                                ('Ecopais'),
                                ('Diesel'),
                                ('Super');

-- Tabla hogar_combustible y poblado de datos
DROP TABLE IF EXISTS HOGAR_COMBUSTIBLE;
CREATE TABLE HOGAR_COMBUSTIBLE (
  id_hogar VARCHAR(30),
  COMBUSTIBLE VARCHAR(20),
  GASTO DOUBLE,
  FOREIGN KEY (COMBUSTIBLE) REFERENCES COMBUSTIBLE(COMBUSTIBLE),
  FOREIGN KEY (id_hogar) REFERENCES hogar(ID_HOGAR)
);

INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_electricidad, '1', 'Electricidad') AS COMBUSTIBLE,
       E.gasto_electricidad AS GASTO
FROM enemdu E
WHERE TRIM(E.gasto_electricidad) != '';

INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_electricidad, '1', 'Electricidad'),
       E.gasto_electricidad
FROM enemdu E
WHERE TRIM(E.gasto_electricidad) != '';


INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_diesel, '1', 'Diesel'),
       E.gasto_diesel
FROM enemdu E
WHERE TRIM(E.gasto_diesel) != '';

INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_ecopais, '1', 'Ecopais'),
       E.gasto_ecopais
FROM enemdu E
WHERE TRIM(E.gasto_ecopais) != '';

INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_extra, '1', 'Extra'),
       E.gasto_extra
FROM enemdu E
WHERE TRIM(E.gasto_extra) != '';

INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_super, '1', 'Super'),
       E.gasto_super
FROM enemdu E
WHERE TRIM(E.gasto_super) != '';

INSERT INTO HOGAR_COMBUSTIBLE (id_hogar, COMBUSTIBLE, GASTO)
SELECT E.id_hogar,
       REPLACE(E.abastecimiento_gas, '1', 'Gas'),
       E.gasto_gas
FROM enemdu E
WHERE TRIM(E.gasto_gas) != '';


SELECT * FROM HOGAR_COMBUSTIBLE;

SELECT * FROM COMBUSTIBLE;

-- Tabla Materiales Construcción
DROP TABLE IF EXISTS MATERIALES_CONSTRUCCION;
CREATE TABLE MATERIALES_CONSTRUCCION AS SELECT DISTINCT E.id_vivienda,
                                               E.material_piso,
                                               E.material_paredes,
                                               E.material_techo,
                                               E.estado_techo,
                                               E.estado_piso,
                                               E.estado_paredes,
                                               E.relacion_propietario
                                            FROM enemdu E;
ALTER TABLE MATERIALES_CONSTRUCCION ADD FOREIGN KEY (id_vivienda) REFERENCES vivienda(id_vivienda);

-- Creación de la tabla habitaciones
DROP TABLE IF EXISTS HABITACIONES;
CREATE TABLE HABITACIONES AS SELECT DISTINCT E.id_vivienda,
                                    E.numero_cuartos,
                                    E.numero_dormitorios,
                                    E.num_cuartos_negocio
                                 FROM enemdu E;
ALTER TABLE HABITACIONES ADD FOREIGN KEY (id_vivienda)REFERENCES vivienda (id_vivienda);

-- Creación de la tabla servicios_higienicos
DROP TABLE IF EXISTS SERVICIOS_HIGIENICOS;
CREATE TABLE SERVICIOS_HIGIENICOS AS SELECT DISTINCT E.id_vivienda,
                                                     E.tipo_instalacion_sanitaria,
                                                     E.eliminacion_basura,
                                                     E.tipo_servicio_higienico
                                         FROM enemdu E;
ALTER TABLE  SERVICIOS_HIGIENICOS ADD FOREIGN KEY (id_vivienda) REFERENCES vivienda(id_vivienda);

-- Creación de la tabla servicios_basicos

DROP TABLE IF EXISTS SERVICIOS_BASICOS;
CREATE TABLE SERVICIOS_BASICOS AS SELECT E.id_vivienda,
                                         E.obt_junta_agua,
                                         E.obtencion_agua,
                                         E.agua_recibida
                                      FROM enemdu E;
ALTER TABLE SERVICIOS_BASICOS ADD FOREIGN KEY (id_vivienda)REFERENCES vivienda(id_vivienda);

SELECT DISTINCT E.ciudad
    FROM enemdu E;


-- Creacion de la relación vivienda_ciudad
DROP TABLE IF EXISTS VIVIENDA_UBICACION cascade;
CREATE TABLE VIVIENDA_UBICACION AS SELECT E.ciudad, E.id_vivienda, e.periodo
                           FROM enemdu E;


-- Creación de la tabla ciudad
DROP TABLE IF EXISTS UBICACION;
CREATE TABLE UBICACION AS SELECT DISTINCT E.ciudad AS "CODIGO_POSTAL",
                                          I.nombre_provincia,
                                          I.nombre_canton,
                                          I.nombre_parroquia FROM enemdu E inner join informacion_ciudad I ON
    E.ciudad = I.CODIGO_POSTAL;
ALTER TABLE UBICACION ADD PRIMARY KEY(CODIGO_POSTAL);

INSERT INTO ubicacion (CODIGO_POSTAL, nombre_provincia, nombre_canton, nombre_parroquia)
VALUES
  ('11551', 'AZUAY', 'CAMILO PONCE ENRIQUEZ', 'El CARMEN DE PIJILI'),
  ('100300', 'IMBABURA', 'COTACACHI', 'GARCIA MORENO'),
  ('130400', 'MANABI', '24 DE MAYO', 'SUCRE'),
  ('230200', 'SANTO DOMINGO DE LOS TSACHILAS', 'SANTO DOMINGO', 'SANTO DOMINGO DE LOS COLORADOS'),
  ('10165', 'Pichincha', 'Quito', 'San Juan'),
  ('10952', 'Pichincha', 'Quito', 'La Magdalena'),
  ('11152', 'Pichincha', 'Quito', 'San Blas'),
  ('20153', 'Pichincha', 'Sangolquí', 'San Pedro'),
  ('20156', 'Pichincha', 'Sangolquí', 'Rumiñahui'),
  ('30354', 'Guayas', 'Guayaquil', 'Kennedy'),
  ('30451', 'Guayas', 'Guayaquil', 'Urdaneta'),
  ('40552', 'Los Rios', 'Quevedo', 'Quevedo'),
  ('50162', 'Manabí', 'Manta', 'Manta'),
  ('50553', 'Manabí', 'Manta', 'Tarqui'),
  ('50753', 'Manabí', 'Manta', 'San Mateo'),
  ('60755', 'Santa Elena', 'Salinas', 'Salinas'),
  ('70350', 'Azuay', 'Cuenca', 'Cuenca'),
  ('70953', 'Azuay', 'Cuenca', 'Yanuncay'),
  ('70955', 'Azuay', 'Cuenca', 'El Vecino'),
  ('71151', 'Azuay', 'Cuenca', 'Totoracocha'),
  ('71256', 'Azuay', 'Cuenca', 'Banos'),
  ('90350', 'Tungurahua', 'Ambato', 'Ambato'),
  ('91952', 'Tungurahua', 'Ambato', 'Atahualpa'),
  ('91953', 'Tungurahua', 'Ambato', 'Atocha'),
  ('92055', 'Tungurahua', 'Ambato', 'Ficoa'),
  ('92350', 'Tungurahua', 'Ambato', 'Huachi Grande'),
  ('92850', 'Tungurahua', 'Ambato', 'Quisapincha'),
  ('110153', 'Pichincha', 'Quito', 'Solanda'),
  ('110254', 'Pichincha', 'Quito', 'Chillogallo'),
  ('110455', 'Pichincha', 'Quito', 'Quitumbe'),
  ('111153', 'Pichincha', 'Quito', 'Carcelen'),
  ('111159', 'Pichincha', 'Quito', 'Pomasqui'),
  ('120155', 'Pichincha', 'Quito', 'Pifo'),
  ('131052', 'Pichincha', 'Quito', 'Calderon'),
  ('132150', 'Pichincha', 'Quito', 'Pomasqui'),
  ('140655', 'Pichincha', 'Quito', 'Puellaro'),
  ('150157', 'Pichincha', 'Quito', 'Tumbaco'),
  ('160152', 'Pichincha', 'Quito', 'Tababela'),
  ('160166', 'Pichincha', 'Quito', 'Yaruquí'),
  ('170450', 'Pichincha', 'Quito', 'Cumbaya'),
  ('170454', 'Pichincha', 'Quito', 'Capelo'),
  ('170751', 'Pichincha', 'Quito', 'Llano Chico'),
  ('180753', 'Pichincha', 'Quito', 'Cochapamba'),
  ('180758', 'Pichincha', 'Quito', 'Chilibulo'),
  ('180855', 'Pichincha', 'Quito', 'San Antonio'),
  ('210454', 'Guayas', 'Guayaquil', 'Ximena'),
  ('220254', 'Guayas', 'Guayaquil', 'Pascuales');;


ALTER TABLE VIVIENDA_UBICACION ADD FOREIGN KEY (ciudad) REFERENCES UBICACION(CODIGO_POSTAL),
    ADD FOREIGN KEY (id_vivienda)REFERENCES vivienda (id_vivienda);
-- Tabla ingreso_empleo
ALTER TABLE INGRESO_EMPLEO ADD COLUMN NOMBRE_CANTON VARCHAR(70);

UPDATE INGRESO_EMPLEO E
JOIN informacion_ciudad I ON E.CIUDAD = I.CODIGO_POSTAL
SET E.NOMBRE_CANTON = I.NOMBRE_CANTON;

SELECT CIUDAD,
       AVG(I.INGRESO_PERCAPITA) AS "INGRESO_PERCAPITA", COUNT(if(I.EMPLEO = 1, 1, NULL)) AS "EMPLEO",
       COUNT(IF(I.DESEMPLEO = 1, 1, NULL)) AS "DESEMPLEO",
       (COUNT(if(I.EMPLEO = 1, 1, NULL))*100)/(COUNT(IF(I.DESEMPLEO = 1, 1, NULL))+ COUNT(if(I.EMPLEO = 1, 1, NULL))) AS "PORCENTAJE_EMPLEO",
       (COUNT(if(I.DESEMPLEO = 1, 1, NULL))*100)/(COUNT(IF(I.DESEMPLEO = 1, 1, NULL))+ COUNT(if(I.EMPLEO = 1, 1, NULL))) AS "PORCENTAJE_DESEMPLEO"
    FROM INGRESO_EMPLEO I
GROUP BY CIUDAD;

CREATE TABLE TASA_EMPLEO AS SELECT CIUDAD AS "CODIGO_POSTAL",
       AVG(I.INGRESO_PERCAPITA) AS "INGRESO_PERCAPITA",
       COUNT(if(I.EMPLEO = 1, 1, NULL)) AS "EMPLEO",
       COUNT(IF(I.DESEMPLEO = 1, 1, NULL)) AS "DESEMPLEO",
       COUNT(if(I.DESEMPLEO != 1 AND I.EMPLEO != 1, 1, NULL)) AS "NO_HAN_RESPONDIDO",
       (COUNT(if(I.EMPLEO = 1, 1, NULL))*100)/(COUNT(*)) AS "PORCENTAJE_EMPLEO",
       (COUNT(if(I.DESEMPLEO = 1, 1, NULL))*100)/(COUNT(*)) AS "PORCENTAJE_DESEMPLEO",
        (COUNT(if(I.DESEMPLEO != 1 AND I.EMPLEO != 1, 1, NULL))*100)/(COUNT(*)) AS "PORCENTAJE_OTRO"
    FROM INGRESO_EMPLEO I
GROUP BY CIUDAD;

ALTER TABLE  TASA_EMPLEO ADD PRIMARY KEY (CODIGO_POSTAL),
    ADD FOREIGN KEY (CODIGO_POSTAL) REFERENCES UBICACION(CODIGO_POSTAL);


-- Creación de la tabla educación y salud
ALTER TABLE salud_educacion ADD COLUMN NOMBRE_CANTON VARCHAR(70);
UPDATE salud_educacion S
JOIN informacion_ciudad I ON S.CIUDAD = I.CODIGO_POSTAL
SET S.NOMBRE_CANTON = I.NOMBRE_CANTON;


-- Tratamiento de valores atípicos o erráticos
UPDATE salud_educacion
SET salud = REPLACE(salud,99, 9);

UPDATE salud_educacion
SET educacion = REPLACE(educacion,99, 9);

CREATE TABLE SALUD_EDUCACION_JUBILACION AS SELECT  S.CIUDAD AS "CODIGO_POSTAL",
        IF(AVG(S.pensiones_jubilacion) IS NULL, 'no_registran_jubilacion', AVG(S.pensiones_jubilacion)) AS "PROMEDIO_JUBILACIONES_PARROQUIAS",
        COUNT(*) AS "PERSONAS_CON_JUBILACION",
        COUNT(IF(S.pensiones_jubilacion IS NOT NULL, 1, NULL))*100 / COUNT(*) AS "PORCENTAJE_PERSONAS_JUBILACION",
        AVG(S.salud) AS "CALIFICACION_SALUD",
        AVG(S.educacion) AS "CALIFICACION_EDUCACION"
FROM salud_educacion S
GROUP BY S.CIUDAD;
ALTER TABLE SALUD_EDUCACION_JUBILACION ADD PRIMARY KEY (CODIGO_POSTAL),
    ADD FOREIGN KEY (CODIGO_POSTAL) REFERENCES UBICACION(CODIGO_POSTAL);

-- Borramos las tablas de datos que ya no nos sirven

DROP TABLE IF EXISTS informacion_ciudad, salud_educacion, INGRESO_EMPLEO;

SELECT S.CODIGO_POSTAL
    FROM SALUD_EDUCACION_JUBILACION S
    WHERE S.CODIGO_POSTAL NOT IN (SELECT U.CODIGO_POSTAL
                                      FROM UBICACION U);






show variables like 'secure_file_priv';

DROP PROCEDURE IF EXISTS export_data_to_csv;
DELIMITER //

CREATE PROCEDURE export_data_to_csv()
BEGIN
    SELECT 'id_vivienda', 'id_hogar', 'periodo', 'valor_pagaria_arriendo',
           'material_piso', 'material_paredes', 'material_techo', 'estado_techo', 'estado_piso', 'estado_paredes', 'relacion_propietario',
           'numero_motos', 'numero_vehiculos',
           'numero_cuartos', 'numero_dormitorios', 'num_cuartos_negocio',
           'area', 'via_principal', 'tipo_vivienda', 'tenencia_vivienda', 'tipo_alumbrado', 'servicio_ducha',
           'COMBUSTIBLE', 'GASTO',
           'ciudad',
           'nombre_provincia', 'nombre_canton', 'nombre_parroquia',
           'PROMEDIO_JUBILACIONES_PARROQUIAS', 'PERSONAS_CON_JUBILACION', 'PORCENTAJE_PERSONAS_JUBILACION', 'CALIFICACION_SALUD', 'CALIFICACION_EDUCACION',
           'INGRESO_PERCAPITA', 'EMPLEO', 'DESEMPLEO', 'NO_HAN_RESPONDIDO', 'PORCENTAJE_EMPLEO', 'PORCENTAJE_DESEMPLEO', 'PORCENTAJE_OTRO'
    UNION ALL
    SELECT HV.id_vivienda, HV.id_hogar, HV.periodo, HV.valor_pagaria_arriendo,
           mc.material_piso, mc.material_paredes, mc.material_techo, mc.estado_techo, mc.estado_piso, mc.estado_paredes, mc.relacion_propietario,
           V.numero_motos, v.numero_vehiculos,
           H2.numero_cuartos, H2.numero_dormitorios, H2.num_cuartos_negocio,
           IV.area, IV.via_principal, IV.tipo_vivienda, IV.tenencia_vivienda, IV.tipo_alumbrado, IV.servicio_ducha,
           HC.COMBUSTIBLE, HC.GASTO,
           VU.ciudad,
           U.nombre_provincia, U.nombre_canton, U.nombre_parroquia,
           SEJ.PROMEDIO_JUBILACIONES_PARROQUIAS, SEJ.PERSONAS_CON_JUBILACION, SEJ.PORCENTAJE_PERSONAS_JUBILACION, SEJ.CALIFICACION_SALUD, SEJ.CALIFICACION_EDUCACION,
           TE.INGRESO_PERCAPITA, TE.EMPLEO, TE.DESEMPLEO, TE.NO_HAN_RESPONDIDO, TE.PORCENTAJE_EMPLEO, TE.PORCENTAJE_DESEMPLEO, TE.PORCENTAJE_OTRO
    FROM hogar_vivienda HV
        LEFT JOIN HOGAR H on HV.id_hogar = H.id_hogar
        LEFT JOIN MATERIALES_CONSTRUCCION MC on HV.id_vivienda = MC.id_vivienda
        LEFT JOIN VEHICULO V on H.id_hogar = V.id_hogar
        LEFT JOIN HABITACIONES H2 on HV.id_vivienda = H2.id_vivienda
        LEFT JOIN SERVICIOS_BASICOS SB on HV.id_vivienda = SB.id_vivienda
        LEFT JOIN SERVICIOS_HIGIENICOS SH on HV.id_vivienda = SH.id_vivienda
        LEFT JOIN vivienda VI ON HV.id_vivienda = VI.id_vivienda
        LEFT JOIN info_vivienda IV on VI.id_vivienda = IV.id_vivienda
        LEFT JOIN hogar_arriendo HA ON H.id_hogar = HA.id_hogar
        LEFT JOIN HOGAR_COMBUSTIBLE HC on H.id_hogar = HC.id_hogar
        LEFT JOIN VIVIENDA_UBICACION VU on VI.id_vivienda = VU.id_vivienda
        LEFT JOIN UBICACION U ON VU.ciudad = U.CODIGO_POSTAL
        LEFT JOIN SALUD_EDUCACION_JUBILACION SEJ on U.CODIGO_POSTAL = SEJ.CODIGO_POSTAL
        LEFT JOIN TASA_EMPLEO TE on U.CODIGO_POSTAL = TE.CODIGO_POSTAL
    INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/TABLA.CSV'
    FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';
END //

DELIMITER ;

CALL export_data_to_csv();















