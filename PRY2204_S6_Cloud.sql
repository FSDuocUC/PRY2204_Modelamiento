-- ============================================================================
-- PROYECTO: Consultorio Médico Municipalidad Santa Gema (Semana 6)
-- BASE DE DATOS: Oracle Cloud
-- ============================================================================

-- ==========================================
-- ELIMINACIÓN DE OBJETOS ANTERIORES (Para pruebas limpias)
-- ==========================================
DROP TABLE PAGO CASCADE CONSTRAINTS;
DROP TABLE BANCO CASCADE CONSTRAINTS;
DROP TABLE DOSIS CASCADE CONSTRAINTS;
DROP TABLE RECETA CASCADE CONSTRAINTS;
DROP TABLE DIAGNOSTICO CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS;
DROP TABLE PACIENTE CASCADE CONSTRAINTS;
DROP TABLE DIGITADOR CASCADE CONSTRAINTS;
DROP TABLE MEDICO CASCADE CONSTRAINTS;
DROP TABLE ESPECIALIDAD CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;

-- ==========================================
-- CASO 1: CREACIÓN DE TABLAS (DDL)
-- ==========================================

-- 1. Especialidad
CREATE TABLE ESPECIALIDAD (
    id_especialidad NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_especialidad VARCHAR2(100) NOT NULL
);

-- 2. Comuna
CREATE TABLE COMUNA (
    id_comuna NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1101 INCREMENT BY 1) PRIMARY KEY,
    nombre_comuna VARCHAR2(100) NOT NULL
);

-- 3. Médico (Teléfono único y DV validado)
CREATE TABLE MEDICO (
    rut_med NUMBER(8) PRIMARY KEY,
    dv_med CHAR(1) NOT NULL,
    pnombre VARCHAR2(25) NOT NULL,
    snombre VARCHAR2(25),
    apellido VARCHAR2(25) NOT NULL,
    sapellido VARCHAR2(25),
    id_especialidad NUMBER NOT NULL,
    telefono_medico VARCHAR2(20) NOT NULL,
    CONSTRAINT uq_medico_telefono UNIQUE (telefono_medico),
    CONSTRAINT chk_dv_med CHECK (dv_med IN ('0','1','2','3','4','5','6','7','8','9','K','k')),
    CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad)
);

-- 4. Digitador (DV validado)
CREATE TABLE DIGITADOR (
    id_digitador NUMBER(20) PRIMARY KEY,
    pnombre VARCHAR2(25) NOT NULL,
    apellido VARCHAR2(25) NOT NULL,
    dv_digitador CHAR(1) DEFAULT '0' NOT NULL,
    CONSTRAINT chk_dv_digitador CHECK (dv_digitador IN ('0','1','2','3','4','5','6','7','8','9','K','k'))
);

-- 5. Paciente (Incluye columna 'edad' temporalmente para luego ser borrada en Caso 2)
CREATE TABLE PACIENTE (
    rut_pac VARCHAR2(25) PRIMARY KEY,
    dv_pac CHAR(1) NOT NULL,
    pnombre VARCHAR2(25) NOT NULL,
    snombre VARCHAR2(25),
    edad DATE NOT NULL, 
    telefono NUMBER(11),
    calle VARCHAR2(25) NOT NULL,
    numeracion NUMBER(5) NOT NULL,
    comuna NUMBER NOT NULL,
    ciudad NUMBER(5) NOT NULL,
    region NUMBER(5) NOT NULL,
    CONSTRAINT chk_dv_pac CHECK (dv_pac IN ('0','1','2','3','4','5','6','7','8','9','K','k')),
    CONSTRAINT fk_paciente_comuna FOREIGN KEY (comuna) REFERENCES COMUNA(id_comuna)
);

-- 6. Medicamento
CREATE TABLE MEDICAMENTO (
    cod_medicamento NUMBER(7) PRIMARY KEY,
    nombre VARCHAR2(25) NOT NULL,
    tipo_medicamento NUMBER(3) NOT NULL,
    via_administra NUMBER(3) NOT NULL,
    dosis_recomendada VARCHAR2(100) DEFAULT 'General' NOT NULL,
    stock NUMBER NOT NULL
);

-- 7. Diagnóstico
CREATE TABLE DIAGNOSTICO (
    cod_diagnostico NUMBER(3) PRIMARY KEY,
    nombre VARCHAR2(25) NOT NULL
);

-- 8. Receta (Validación de tipos de receta)
CREATE TABLE RECETA (
    cod_receta NUMBER(7) PRIMARY KEY,
    observaciones VARCHAR2(500),
    fecha_emision DATE NOT NULL,
    fecha_vencimiento VARCHAR2(25),
    id_digitador NUMBER(20) NOT NULL,
    pac_rut VARCHAR2(25) NOT NULL,
    id_diagnostico NUMBER(3) NOT NULL,
    med_rut NUMBER(8) NOT NULL,
    id_tipo_receta NUMBER(3) NOT NULL,
    tipo_receta_nombre VARCHAR2(30) NOT NULL,
    CONSTRAINT chk_tipo_receta_nom CHECK (tipo_receta_nombre IN ('DIGITAL', 'MAGISTRAL', 'RETENIDA', 'GENERAL', 'VETERINARIA', 'digital', 'magistral', 'retenida', 'general', 'veterinaria')),
    CONSTRAINT fk_receta_digitador FOREIGN KEY (id_digitador) REFERENCES DIGITADOR(id_digitador),
    CONSTRAINT fk_receta_paciente FOREIGN KEY (pac_rut) REFERENCES PACIENTE(rut_pac),
    CONSTRAINT fk_receta_diagnostico KEY (id_diagnostico) REFERENCES DIAGNOSTICO(cod_diagnostico),
    CONSTRAINT fk_receta_medico FOREIGN KEY (med_rut) REFERENCES MEDICO(rut_med)
);

-- 9. Dosis (Relación Muchos a Muchos)
CREATE TABLE DOSIS (
    id_medicamento NUMBER(7),
    id_receta NUMBER(7),
    descripcion_dosis VARCHAR2(25),
    CONSTRAINT dosis_pk PRIMARY KEY (id_medicamento, id_receta),
    CONSTRAINT fk_dosis_medicamento FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO(cod_medicamento),
    CONSTRAINT fk_dosis_receta FOREIGN KEY (id_receta) REFERENCES RECETA(cod_receta)
);

-- 10. Banco
CREATE TABLE BANCO (
    cod_banco NUMBER(2) PRIMARY KEY,
    nombre VARCHAR2(25) NOT NULL
);

-- 11. Pago
CREATE TABLE PAGO (
    cod_boleta NUMBER(6) PRIMARY KEY,
    id_receta NUMBER(7) NOT NULL,
    fecha_pago DATE NOT NULL,
    monto_total NUMBER NOT NULL,
    id_banco NUMBER(2),
    CONSTRAINT fk_pago_receta FOREIGN KEY (id_receta) REFERENCES RECETA(cod_receta),
    CONSTRAINT fk_pago_banco FOREIGN KEY (id_banco) REFERENCES BANCO(cod_banco)
);


-- ==========================================
-- CASO 2: MODIFICACIONES CON ALTER TABLE
-- ==========================================

-- 1. Precio unitario a Medicamento ($1.000 a $2.000.000)
ALTER TABLE MEDICAMENTO ADD precio_unitario NUMBER;
ALTER TABLE MEDICAMENTO ADD CONSTRAINT chk_precio_medicamento CHECK (precio_unitario BETWEEN 1000 AND 2000000);

-- 2. Restricción de métodos de pago
ALTER TABLE PAGO ADD tipo_metodo_pago VARCHAR2(20);
ALTER TABLE PAGO ADD CONSTRAINT chk_metodo_pago CHECK (tipo_metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA'));

-- 3. Eliminar edad y agregar fecha_nacimiento en Paciente
ALTER TABLE PACIENTE DROP COLUMN edad;
ALTER TABLE PACIENTE ADD fecha_nacimiento DATE;
