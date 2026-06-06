-- ================================================================
-- CENTRALIZED HEALTHCARE INVENTORY & PRESCRIPTION MANAGEMENT SYSTEM
-- Punjab Government Dispensaries
-- Course  : UCS310 – Database Management Systems
-- Group   : 2C35 | Thapar Institute of Engineering & Technology
-- Members : Ridhi (1024030528), Tanishq Goyal (1024030531),
--           Saanjal Jain (1024030533)
-- Instructor : Dr. Simranjit Kaur | Session: Jan–May 2026
-- Database   : Oracle 19c / Oracle LiveSQL / Oracle XE
-- ================================================================
-- EXECUTION ORDER: Run this file top-to-bottom (single script)
-- ================================================================


-- ================================================================
-- SECTION 0 : CLEANUP
-- ================================================================

BEGIN EXECUTE IMMEDIATE 'DROP TABLE Inventory_Audit     CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Equipment_Usage     CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Transaction_Log     CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Prescription_Items  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Prescription        CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Visit               CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Medicine_Inventory  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Equipment_Inventory CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Medicine            CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Equipment           CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Pharmacist          CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Doctor              CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Staff               CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Patient             CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Supplier            CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Dispensary          CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE District            CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_district';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_dispensary';  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_patient';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_staff';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_supplier';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_medicine';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_equipment';   EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_med_inv';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_eq_inv';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_visit';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_presc';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_presc_item';  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_txn';         EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_eq_usage';    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_low_stock';                    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_expiry_alerts';                EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_patient_prescription_summary'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW v_dispensary_stock_summary';     EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_isa_role_check';        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_expired_issue';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_update_stock';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_pharmacist_only_issue'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_inventory';       EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE get_patient_history';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE dispense_prescription';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION fn_patient_age';            EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION fn_is_medicine_available';  EXCEPTION WHEN OTHERS THEN NULL; END;
/


-- ================================================================
-- SECTION 1 : SCHEMA (Tables + Sequences + Constraints)
-- ================================================================

-- 1.1 District
CREATE TABLE District (
    district_id   NUMBER(3)    CONSTRAINT pk_district PRIMARY KEY,
    name          VARCHAR2(50) CONSTRAINT nn_dist_name NOT NULL,
    division      VARCHAR2(30),
    population    NUMBER(10),
    CONSTRAINT uq_dist_name UNIQUE (name)
);

-- 1.2 Dispensary
CREATE TABLE Dispensary (
    dispensary_id  NUMBER(5)     CONSTRAINT pk_disp PRIMARY KEY,
    district_id    NUMBER(3)     CONSTRAINT nn_disp_dist NOT NULL,
    name           VARCHAR2(120) CONSTRAINT nn_disp_name NOT NULL,
    address        VARCHAR2(200),
    contact_no     VARCHAR2(15)  CONSTRAINT uq_disp_contact UNIQUE,
    email          VARCHAR2(100),
    tier           VARCHAR2(10),
    established_on DATE,
    CONSTRAINT fk_disp_dist FOREIGN KEY (district_id) REFERENCES District(district_id),
    CONSTRAINT chk_disp_tier CHECK (tier IN ('PHC','CHC','DISTRICT','CIVIL'))
);

-- 1.3 Supplier
CREATE TABLE Supplier (
    supplier_id    NUMBER(5)     CONSTRAINT pk_supplier PRIMARY KEY,
    name           VARCHAR2(120) CONSTRAINT nn_sup_name NOT NULL,
    contact_person VARCHAR2(100),
    phone          VARCHAR2(15)  CONSTRAINT nn_sup_phone NOT NULL,
    email          VARCHAR2(100),
    city           VARCHAR2(60),
    gstin          VARCHAR2(20)  CONSTRAINT uq_sup_gstin UNIQUE,
    rating         NUMBER(2,1),
    CONSTRAINT chk_sup_rating CHECK (rating BETWEEN 1.0 AND 5.0)
);

-- 1.4 Patient
CREATE TABLE Patient (
    patient_id    NUMBER(7)     CONSTRAINT pk_patient PRIMARY KEY,
    dispensary_id NUMBER(5)     CONSTRAINT nn_pat_disp NOT NULL,
    name          VARCHAR2(100) CONSTRAINT nn_pat_name NOT NULL,
    gender        CHAR(1),
    dob           DATE,
    blood_group   VARCHAR2(5),
    phone         VARCHAR2(15),
    address       VARCHAR2(200),
    aadhar_no     VARCHAR2(12)  CONSTRAINT uq_pat_aadhar UNIQUE,
    registered_on DATE          DEFAULT SYSDATE,
    CONSTRAINT fk_pat_disp   FOREIGN KEY (dispensary_id) REFERENCES Dispensary(dispensary_id),
    CONSTRAINT chk_pat_gender CHECK (gender IN ('M','F','O')),
    CONSTRAINT chk_blood_grp  CHECK (blood_group IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
);

-- 1.5 Staff (ISA Supertype)
CREATE TABLE Staff (
    staff_id      NUMBER(6)     CONSTRAINT pk_staff PRIMARY KEY,
    dispensary_id NUMBER(5)     CONSTRAINT nn_stf_disp NOT NULL,
    name          VARCHAR2(100) CONSTRAINT nn_stf_name NOT NULL,
    role          VARCHAR2(15)  CONSTRAINT nn_stf_role NOT NULL,
    phone         VARCHAR2(15),
    email         VARCHAR2(100) CONSTRAINT uq_stf_email UNIQUE,
    username      VARCHAR2(50)  CONSTRAINT uq_stf_user UNIQUE,
    join_date     DATE          DEFAULT SYSDATE,
    is_active     CHAR(1)       DEFAULT 'Y',
    CONSTRAINT fk_stf_disp   FOREIGN KEY (dispensary_id) REFERENCES Dispensary(dispensary_id),
    CONSTRAINT chk_stf_role  CHECK (role IN ('DOCTOR','PHARMACIST','ADMIN')),
    CONSTRAINT chk_stf_active CHECK (is_active IN ('Y','N'))
);

-- 1.6 Doctor (ISA Subtype of Staff)
CREATE TABLE Doctor (
    staff_id         NUMBER(6)    CONSTRAINT pk_doctor PRIMARY KEY,
    specialization   VARCHAR2(80) CONSTRAINT nn_doc_spec NOT NULL,
    license_no       VARCHAR2(30) CONSTRAINT uq_doc_lic UNIQUE,
    qualification    VARCHAR2(100),
    years_experience NUMBER(2),
    CONSTRAINT fk_doc_staff FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- 1.7 Pharmacist (ISA Subtype of Staff)
CREATE TABLE Pharmacist (
    staff_id      NUMBER(6)    CONSTRAINT pk_pharma PRIMARY KEY,
    license_no    VARCHAR2(30) CONSTRAINT uq_pha_lic UNIQUE,
    qualification VARCHAR2(100),
    CONSTRAINT fk_pha_staff FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- 1.8 Medicine
CREATE TABLE Medicine (
    medicine_id   NUMBER(7)     CONSTRAINT pk_medicine PRIMARY KEY,
    supplier_id   NUMBER(5),
    name          VARCHAR2(150) CONSTRAINT nn_med_name NOT NULL,
    generic_name  VARCHAR2(150),
    category      VARCHAR2(30)  CONSTRAINT nn_med_cat NOT NULL,
    form          VARCHAR2(20),
    strength      VARCHAR2(30),
    unit_price    NUMBER(10,2)  CONSTRAINT nn_med_price NOT NULL,
    reorder_level NUMBER(7)     DEFAULT 100,
    CONSTRAINT fk_med_sup  FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    CONSTRAINT chk_med_price CHECK (unit_price > 0),
    CONSTRAINT chk_med_cat  CHECK (category IN (
        'ANTIBIOTIC','ANALGESIC','ANTIPYRETIC','ANTIFUNGAL','ANTIVIRAL',
        'VITAMIN','CARDIAC','DIABETIC','ANTACID','ANTIHISTAMINE',
        'STEROID','ANTIHYPERTENSIVE','OTHER'))
);

-- 1.9 Equipment
CREATE TABLE Equipment (
    equipment_id     NUMBER(6)     CONSTRAINT pk_equipment PRIMARY KEY,
    supplier_id      NUMBER(5),
    name             VARCHAR2(150) CONSTRAINT nn_eq_name NOT NULL,
    type             VARCHAR2(40)  CONSTRAINT nn_eq_type NOT NULL,
    cost             NUMBER(12,2)  CONSTRAINT nn_eq_cost NOT NULL,
    maintenance_date DATE,
    warranty_expiry  DATE,
    CONSTRAINT fk_eq_sup  FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    CONSTRAINT chk_eq_cost CHECK (cost > 0),
    CONSTRAINT chk_eq_type CHECK (type IN ('DIAGNOSTIC','SURGICAL','LIFE_SUPPORT','MONITORING','CONSUMABLE'))
);

-- 1.10 Medicine_Inventory (batch-level stock per dispensary)
CREATE TABLE Medicine_Inventory (
    inventory_id     NUMBER(8)    CONSTRAINT pk_med_inv PRIMARY KEY,
    dispensary_id    NUMBER(5)    CONSTRAINT nn_mi_disp NOT NULL,
    medicine_id      NUMBER(7)    CONSTRAINT nn_mi_med  NOT NULL,
    batch_no         VARCHAR2(30) CONSTRAINT nn_mi_batch NOT NULL,
    quantity         NUMBER(10)   DEFAULT 0,
    manufacture_date DATE,
    expiry_date      DATE         CONSTRAINT nn_mi_exp NOT NULL,
    location_shelf   VARCHAR2(20),
    last_updated     DATE         DEFAULT SYSDATE,
    CONSTRAINT fk_mi_disp   FOREIGN KEY (dispensary_id) REFERENCES Dispensary(dispensary_id),
    CONSTRAINT fk_mi_med    FOREIGN KEY (medicine_id)   REFERENCES Medicine(medicine_id),
    CONSTRAINT uq_mi_batch  UNIQUE (dispensary_id, medicine_id, batch_no),
    CONSTRAINT chk_mi_qty   CHECK (quantity >= 0),
    CONSTRAINT chk_mi_expiry CHECK (expiry_date > manufacture_date)
);

-- 1.11 Equipment_Inventory (per dispensary)
CREATE TABLE Equipment_Inventory (
    eq_inventory_id NUMBER(7)    CONSTRAINT pk_eq_inv PRIMARY KEY,
    dispensary_id   NUMBER(5)    CONSTRAINT nn_ei_disp NOT NULL,
    equipment_id    NUMBER(6)    CONSTRAINT nn_ei_eq   NOT NULL,
    serial_no       VARCHAR2(40) CONSTRAINT uq_ei_serial UNIQUE,
    quantity        NUMBER(5)    DEFAULT 1,
    status          VARCHAR2(20) DEFAULT 'AVAILABLE',
    acquired_date   DATE,
    last_maintained DATE,
    CONSTRAINT fk_ei_disp FOREIGN KEY (dispensary_id) REFERENCES Dispensary(dispensary_id),
    CONSTRAINT fk_ei_eq   FOREIGN KEY (equipment_id)  REFERENCES Equipment(equipment_id),
    CONSTRAINT chk_ei_qty  CHECK (quantity >= 0),
    CONSTRAINT chk_ei_stat CHECK (status IN ('AVAILABLE','IN_USE','UNDER_MAINTENANCE','DECOMMISSIONED'))
);

-- 1.12 Visit
CREATE TABLE Visit (
    visit_id      NUMBER(8)    CONSTRAINT pk_visit PRIMARY KEY,
    patient_id    NUMBER(7)    CONSTRAINT nn_vis_pat  NOT NULL,
    staff_id      NUMBER(6)    CONSTRAINT nn_vis_doc  NOT NULL,
    dispensary_id NUMBER(5)    CONSTRAINT nn_vis_disp NOT NULL,
    visit_date    DATE         DEFAULT SYSDATE,
    symptoms      VARCHAR2(300),
    diagnosis     VARCHAR2(200),
    visit_type    VARCHAR2(15) DEFAULT 'OPD',
    CONSTRAINT fk_vis_pat  FOREIGN KEY (patient_id)    REFERENCES Patient(patient_id),
    CONSTRAINT fk_vis_doc  FOREIGN KEY (staff_id)      REFERENCES Staff(staff_id),
    CONSTRAINT fk_vis_disp FOREIGN KEY (dispensary_id) REFERENCES Dispensary(dispensary_id),
    CONSTRAINT chk_vis_type CHECK (visit_type IN ('OPD','IPD','EMERGENCY'))
);

-- 1.13 Prescription (one per visit — enforced by UNIQUE on visit_id)
CREATE TABLE Prescription (
    prescription_id NUMBER(8)    CONSTRAINT pk_presc PRIMARY KEY,
    visit_id        NUMBER(8)    CONSTRAINT nn_pr_vis NOT NULL,
    doctor_id       NUMBER(6)    CONSTRAINT nn_pr_doc NOT NULL,
    pharmacist_id   NUMBER(6),
    prescribed_on   DATE         DEFAULT SYSDATE,
    dispensed_on    DATE,
    status          VARCHAR2(15) DEFAULT 'PENDING',
    notes           VARCHAR2(300),
    CONSTRAINT fk_pr_visit  FOREIGN KEY (visit_id)      REFERENCES Visit(visit_id),
    CONSTRAINT fk_pr_doc    FOREIGN KEY (doctor_id)     REFERENCES Staff(staff_id),
    CONSTRAINT fk_pr_pharma FOREIGN KEY (pharmacist_id) REFERENCES Staff(staff_id),
    CONSTRAINT uq_pr_visit  UNIQUE (visit_id),
    CONSTRAINT chk_pr_stat  CHECK (status IN ('PENDING','DISPENSED','PARTIAL','CANCELLED'))
);

-- 1.14 Prescription_Items (M:N bridge: Prescription ↔ Medicine)
CREATE TABLE Prescription_Items (
    item_id         NUMBER(9)  CONSTRAINT pk_pi PRIMARY KEY,
    prescription_id NUMBER(8)  CONSTRAINT nn_pi_presc NOT NULL,
    medicine_id     NUMBER(7)  CONSTRAINT nn_pi_med   NOT NULL,
    dosage          VARCHAR2(50),
    duration_days   NUMBER(3),
    quantity_issued NUMBER(7)  DEFAULT 0,
    CONSTRAINT fk_pi_presc FOREIGN KEY (prescription_id) REFERENCES Prescription(prescription_id),
    CONSTRAINT fk_pi_med   FOREIGN KEY (medicine_id)     REFERENCES Medicine(medicine_id),
    CONSTRAINT chk_pi_qty  CHECK (quantity_issued >= 0),
    CONSTRAINT chk_pi_dur  CHECK (duration_days > 0)
);

-- 1.15 Transaction_Log (Ternary: Inventory + Staff + Event)
CREATE TABLE Transaction_Log (
    txn_id       NUMBER(10)   CONSTRAINT pk_txn PRIMARY KEY,
    inventory_id NUMBER(8)    CONSTRAINT nn_txn_inv  NOT NULL,
    staff_id     NUMBER(6)    CONSTRAINT nn_txn_stf  NOT NULL,
    txn_type     VARCHAR2(15) CONSTRAINT nn_txn_type NOT NULL,
    quantity     NUMBER(10)   CONSTRAINT nn_txn_qty  NOT NULL,
    txn_date     DATE         DEFAULT SYSDATE,
    ref_id       NUMBER(9),
    remarks      VARCHAR2(300),
    CONSTRAINT fk_txn_inv  FOREIGN KEY (inventory_id) REFERENCES Medicine_Inventory(inventory_id),
    CONSTRAINT fk_txn_stf  FOREIGN KEY (staff_id)     REFERENCES Staff(staff_id),
    CONSTRAINT chk_txn_type CHECK (txn_type IN ('STOCK_IN','ISSUE','RETURN','ADJUST','EXPIRED_REMOVE')),
    CONSTRAINT chk_txn_qty  CHECK (quantity > 0)
);

-- 1.16 Equipment_Usage
CREATE TABLE Equipment_Usage (
    usage_id        NUMBER(9)  CONSTRAINT pk_eq_usage PRIMARY KEY,
    eq_inventory_id NUMBER(7)  CONSTRAINT nn_eu_inv NOT NULL,
    staff_id        NUMBER(6)  CONSTRAINT nn_eu_stf NOT NULL,
    patient_id      NUMBER(7),
    date_used       DATE       DEFAULT SYSDATE,
    purpose         VARCHAR2(200),
    duration_mins   NUMBER(5),
    outcome         VARCHAR2(100),
    CONSTRAINT fk_eu_inv FOREIGN KEY (eq_inventory_id) REFERENCES Equipment_Inventory(eq_inventory_id),
    CONSTRAINT fk_eu_stf FOREIGN KEY (staff_id)        REFERENCES Staff(staff_id),
    CONSTRAINT fk_eu_pat FOREIGN KEY (patient_id)      REFERENCES Patient(patient_id)
);

-- 1.17 Inventory Audit Trail
CREATE TABLE Inventory_Audit (
    audit_id      NUMBER(12) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inventory_id  NUMBER(8),
    medicine_id   NUMBER(7),
    dispensary_id NUMBER(5),
    action        VARCHAR2(20),
    qty_before    NUMBER(10),
    qty_change    NUMBER(10),
    qty_after     NUMBER(10),
    performed_by  NUMBER(6),
    audit_ts      TIMESTAMP  DEFAULT SYSTIMESTAMP,
    remarks       VARCHAR2(300)
);

-- 1.18 Sequences
CREATE SEQUENCE seq_district    START WITH 1     INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_dispensary  START WITH 1     INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_patient     START WITH 1001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_staff       START WITH 101   INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_supplier    START WITH 201   INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_medicine    START WITH 3001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_equipment   START WITH 4001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_med_inv     START WITH 5001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_eq_inv      START WITH 6001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_visit       START WITH 7001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_presc       START WITH 8001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_presc_item  START WITH 9001  INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_txn         START WITH 10001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_eq_usage    START WITH 11001 INCREMENT BY 1 NOCACHE;


-- ================================================================
-- SECTION 2 : DATA (DML Inserts)
-- ================================================================

-- Districts
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Amritsar',         'Majha',  2490656);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Ludhiana',         'Malwa',  3487882);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Patiala',          'Malwa',  1895686);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Jalandhar',        'Doaba',  2193590);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Mohali',           'Malwa',   994628);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Gurdaspur',        'Majha',  1158473);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Hoshiarpur',       'Doaba',  1582793);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Bathinda',         'Malwa',  1388859);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Moga',             'Malwa',   992289);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Sangrur',          'Malwa',  1654408);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Fatehgarh Sahib',  'Malwa',   599814);
INSERT INTO District VALUES (seq_district.NEXTVAL, 'Kapurthala',       'Doaba',   817668);
COMMIT;

-- Dispensaries (Amritsar)
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'Civil Hospital Amritsar','Mall Road, Amritsar','01832220001','civ.asr@punjab.gov.in','CIVIL',DATE '1972-04-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'PHC Majitha','Majitha Village, Amritsar','01832220002','phc.majitha@punjab.gov.in','PHC',DATE '1985-06-15');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'CHC Rayya','Rayya Town, Amritsar','01832220003','chc.rayya@punjab.gov.in','CHC',DATE '1990-03-20');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'PHC Lopoke','Lopoke, Amritsar','01832220004','phc.lopoke@punjab.gov.in','PHC',DATE '1995-08-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'PHC Jandiala Guru','Jandiala Guru, Amritsar','01832220005','phc.jdg@punjab.gov.in','PHC',DATE '1998-11-10');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'CHC Baba Bakala','Baba Bakala, Amritsar','01832220006','chc.bb@punjab.gov.in','CHC',DATE '2001-02-14');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'PHC Attari','Attari Border Area, Amritsar','01832220007','phc.attari@punjab.gov.in','PHC',DATE '2003-07-22');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,1,'PHC Verka','Verka, Amritsar','01832220008','phc.verka@punjab.gov.in','PHC',DATE '2005-09-30');
-- Ludhiana
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'Civil Hospital Ludhiana','Ferozepur Road, Ludhiana','01612220001','civ.ldh@punjab.gov.in','CIVIL',DATE '1965-01-26');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'CHC Samrala','Samrala, Ludhiana','01612220002','chc.samrala@punjab.gov.in','CHC',DATE '1988-04-05');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'PHC Doraha','Doraha, Ludhiana','01612220003','phc.doraha@punjab.gov.in','PHC',DATE '1993-07-14');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'PHC Machhiwara','Machhiwara, Ludhiana','01612220004','phc.machi@punjab.gov.in','PHC',DATE '1996-10-02');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'CHC Raikot','Raikot, Ludhiana','01612220005','chc.raikot@punjab.gov.in','CHC',DATE '2000-05-18');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'PHC Payal','Payal, Ludhiana','01612220006','phc.payal@punjab.gov.in','PHC',DATE '2004-12-25');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'PHC Jagraon','Jagraon, Ludhiana','01612220007','phc.jagraon@punjab.gov.in','PHC',DATE '2007-03-08');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,2,'PHC Sidhwan Bet','Sidhwan Bet, Ludhiana','01612220008','phc.sidhwan@punjab.gov.in','PHC',DATE '2010-06-20');
-- Patiala
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'Civil Hospital Patiala','Leela Bhawan, Patiala','01752220001','civ.ptl@punjab.gov.in','CIVIL',DATE '1960-08-15');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'CHC Rajpura','Rajpura, Patiala','01752220002','chc.rajpura@punjab.gov.in','CHC',DATE '1987-09-10');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'PHC Nabha','Nabha, Patiala','01752220003','phc.nabha@punjab.gov.in','PHC',DATE '1992-04-23');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'PHC Samana','Samana, Patiala','01752220004','phc.samana@punjab.gov.in','PHC',DATE '1997-01-11');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'CHC Ghanaur','Ghanaur, Patiala','01752220005','chc.ghanaur@punjab.gov.in','CHC',DATE '2002-06-30');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'PHC Patran','Patran, Patiala','01752220006','phc.patran@punjab.gov.in','PHC',DATE '2006-08-12');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'PHC Shutrana','Shutrana, Patiala','01752220007','phc.shutrana@punjab.gov.in','PHC',DATE '2009-11-05');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,3,'PHC Sanour','Sanour, Patiala','01752220008','phc.sanour@punjab.gov.in','PHC',DATE '2012-02-18');
-- Jalandhar
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'Civil Hospital Jalandhar','B-Block, Jalandhar','01812220001','civ.jal@punjab.gov.in','CIVIL',DATE '1963-11-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'CHC Nakodar','Nakodar, Jalandhar','01812220002','chc.nakodar@punjab.gov.in','CHC',DATE '1989-03-25');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'PHC Phillaur','Phillaur, Jalandhar','01812220003','phc.phillaur@punjab.gov.in','PHC',DATE '1994-07-07');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'PHC Nurmahal','Nurmahal, Jalandhar','01812220004','phc.nurmahal@punjab.gov.in','PHC',DATE '1999-02-14');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'CHC Lohian Khas','Lohian Khas, Jalandhar','01812220005','chc.lohian@punjab.gov.in','CHC',DATE '2003-05-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'PHC Shahkot','Shahkot, Jalandhar','01812220006','phc.shahkot@punjab.gov.in','PHC',DATE '2007-09-19');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,4,'PHC Adampur','Adampur, Jalandhar','01812220007','phc.adampur@punjab.gov.in','PHC',DATE '2011-01-26');
-- Mohali
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,5,'Civil Hospital Mohali','Phase 6, Mohali','01722220001','civ.mohali@punjab.gov.in','CIVIL',DATE '1985-03-10');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,5,'PHC Kharar','Kharar, Mohali','01722220002','phc.kharar@punjab.gov.in','PHC',DATE '1991-06-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,5,'CHC Derabassi','Derabassi, Mohali','01722220003','chc.derabassi@punjab.gov.in','CHC',DATE '1997-08-15');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,5,'PHC Banur','Banur, Mohali','01722220004','phc.banur@punjab.gov.in','PHC',DATE '2002-04-22');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,5,'PHC Morinda','Morinda, Mohali','01722220005','phc.morinda@punjab.gov.in','PHC',DATE '2008-07-04');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,5,'PHC Kurali','Kurali, Mohali','01722220006','phc.kurali@punjab.gov.in','PHC',DATE '2013-01-15');
-- Gurdaspur
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,6,'Civil Hospital Gurdaspur','Court Road, Gurdaspur','01872220001','civ.gpb@punjab.gov.in','CIVIL',DATE '1970-09-05');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,6,'CHC Batala','Batala, Gurdaspur','01872220002','chc.batala@punjab.gov.in','CHC',DATE '1985-12-20');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,6,'PHC Dera Baba Nanak','Dera Baba Nanak, Gurdaspur','01872220003','phc.dbn@punjab.gov.in','PHC',DATE '1993-03-12');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,6,'PHC Dhariwal','Dhariwal, Gurdaspur','01872220004','phc.dhari@punjab.gov.in','PHC',DATE '1998-07-28');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,6,'PHC Qadian','Qadian, Gurdaspur','01872220005','phc.qadian@punjab.gov.in','PHC',DATE '2004-11-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,6,'PHC Fatehgarh Churian','Fatehgarh Churian, Gurdaspur','01872220006','phc.fgc@punjab.gov.in','PHC',DATE '2010-04-14');
-- Hoshiarpur
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,7,'Civil Hospital Hoshiarpur','Dasuya Road, Hoshiarpur','01882220001','civ.hsp@punjab.gov.in','CIVIL',DATE '1968-05-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,7,'CHC Dasuya','Dasuya, Hoshiarpur','01882220002','chc.dasuya@punjab.gov.in','CHC',DATE '1986-10-10');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,7,'PHC Mukerian','Mukerian, Hoshiarpur','01882220003','phc.mukerian@punjab.gov.in','PHC',DATE '1994-02-06');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,7,'PHC Garhshankar','Garhshankar, Hoshiarpur','01882220004','phc.garh@punjab.gov.in','PHC',DATE '1999-09-09');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,7,'PHC Tanda Urmur','Tanda, Hoshiarpur','01882220005','phc.tanda@punjab.gov.in','PHC',DATE '2005-03-21');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,7,'PHC Hajipur','Hajipur, Hoshiarpur','01882220006','phc.hajipur@punjab.gov.in','PHC',DATE '2011-07-17');
-- Bathinda
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,8,'Civil Hospital Bathinda','Goniana Road, Bathinda','01642220001','civ.bti@punjab.gov.in','CIVIL',DATE '1966-03-15');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,8,'CHC Rampura Phul','Rampura Phul, Bathinda','01642220002','chc.rampura@punjab.gov.in','CHC',DATE '1987-08-23');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,8,'PHC Talwandi Sabo','Talwandi Sabo, Bathinda','01642220003','phc.talwandi@punjab.gov.in','PHC',DATE '1993-11-11');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,8,'PHC Maur','Maur Mandi, Bathinda','01642220004','phc.maur@punjab.gov.in','PHC',DATE '1999-05-05');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,8,'PHC Nathana','Nathana, Bathinda','01642220005','phc.nathana@punjab.gov.in','PHC',DATE '2006-09-14');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,8,'PHC Goniana','Goniana Mandi, Bathinda','01642220006','phc.goniana@punjab.gov.in','PHC',DATE '2012-01-30');
-- Moga
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,9,'Civil Hospital Moga','Ferozepore Road, Moga','01632220001','civ.moga@punjab.gov.in','CIVIL',DATE '1974-07-04');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,9,'CHC Nihal Singh Wala','Nihal Singh Wala, Moga','01632220002','chc.nsw@punjab.gov.in','CHC',DATE '1990-03-08');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,9,'PHC Baghapurana','Baghapurana, Moga','01632220003','phc.bagha@punjab.gov.in','PHC',DATE '1996-06-21');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,9,'PHC Dharamkot','Dharamkot, Moga','01632220004','phc.dharamkot@punjab.gov.in','PHC',DATE '2001-10-10');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,9,'PHC Kot Ise Khan','Kot Ise Khan, Moga','01632220005','phc.kik@punjab.gov.in','PHC',DATE '2008-04-05');
-- Sangrur
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,10,'Civil Hospital Sangrur','Patiala Road, Sangrur','01672220001','civ.sgr@punjab.gov.in','CIVIL',DATE '1969-02-14');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,10,'CHC Sunam','Sunam, Sangrur','01672220002','chc.sunam@punjab.gov.in','CHC',DATE '1984-10-19');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,10,'PHC Malerkotla','Malerkotla, Sangrur','01672220003','phc.maler@punjab.gov.in','PHC',DATE '1992-07-30');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,10,'PHC Dhuri','Dhuri, Sangrur','01672220004','phc.dhuri@punjab.gov.in','PHC',DATE '1998-01-22');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,10,'PHC Lehragaga','Lehragaga, Sangrur','01672220005','phc.lehra@punjab.gov.in','PHC',DATE '2004-05-17');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,10,'PHC Moonak','Moonak, Sangrur','01672220006','phc.moonak@punjab.gov.in','PHC',DATE '2010-12-01');
-- Fatehgarh Sahib
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,11,'Civil Hospital Fatehgarh Sahib','Sirhind Road, Fatehgarh Sahib','01762220001','civ.fgs@punjab.gov.in','CIVIL',DATE '1980-11-23');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,11,'CHC Sirhind','Sirhind, Fatehgarh Sahib','01762220002','chc.sirhind@punjab.gov.in','CHC',DATE '1991-04-13');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,11,'PHC Amloh','Amloh, Fatehgarh Sahib','01762220003','phc.amloh@punjab.gov.in','PHC',DATE '1999-08-07');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,11,'PHC Bassi Pathana','Bassi Pathana, Fatehgarh Sahib','01762220004','phc.bassi@punjab.gov.in','PHC',DATE '2006-03-25');
-- Kapurthala
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,12,'Civil Hospital Kapurthala','Lawrence Road, Kapurthala','01822220001','civ.kpt@punjab.gov.in','CIVIL',DATE '1967-06-01');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,12,'CHC Phagwara','Phagwara, Kapurthala','01822220002','chc.phagwara@punjab.gov.in','CHC',DATE '1983-09-15');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,12,'PHC Sultanpur Lodhi','Sultanpur Lodhi, Kapurthala','01822220003','phc.slodhi@punjab.gov.in','PHC',DATE '1995-12-24');
INSERT INTO Dispensary VALUES (seq_dispensary.NEXTVAL,12,'PHC Dhilwan','Dhilwan, Kapurthala','01822220004','phc.dhilwan@punjab.gov.in','PHC',DATE '2003-07-11');
COMMIT;

-- Suppliers
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Sun Pharmaceutical Industries','Rajesh Mehta','9988001100','rajesh@sunpharma.com','Mumbai','27AAECS4813K1Z4',4.8);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Cipla Ltd','Deepa Nair','9988001101','deepa@cipla.com','Mumbai','27AAACL0015G1ZJ',4.7);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Dr. Reddy''s Laboratories','Srinivas Rao','9988001102','srinivas@drl.com','Hyderabad','36AAACR3161A1ZN',4.6);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Zydus Lifesciences','Pankaj Shah','9988001103','pankaj@zydus.com','Ahmedabad','24AADCZ0056Q1ZY',4.5);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Lupin Ltd','Anita Desai','9988001104','anita@lupinpharma.com','Mumbai','27AAACL2450G1Z5',4.7);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Alkem Laboratories','Ravi Kumar','9988001105','ravi@alkem.com','Mumbai','27AABCA2917G1Z4',4.3);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Mankind Pharma','Suresh Gupta','9988001106','suresh@mankind.in','Delhi','07AABCM5555K1Z2',4.4);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Torrent Pharmaceuticals','Hemal Patel','9988001107','hemal@torrentpharma.com','Ahmedabad','24AAACT1000D1ZS',4.6);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Abbott India Ltd','Priya Thomas','9988001108','priya@abbott.com','Mumbai','27AAACA4376A1Z5',4.8);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'GlaxoSmithKline India','Kiran Bhat','9988001109','kiran@gsk.com','Mumbai','27AACCS5421K1ZA',4.5);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Medicus Healthcare Pvt Ltd','Gurpreet Singh','9876540011','gurpreet@medicus.in','Chandigarh','04AABCM1023F1ZK',4.2);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Punjab Medical Supplies','Harjinder Kaur','9876540012','harjinder@pms.in','Ludhiana','03AABCP5561B1ZL',4.0);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Healthkart Medical Pvt Ltd','Navneet Sharma','9876540013','navneet@healthkart.in','Mohali','03AABCH3421G1ZW',4.1);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'MediEquip India Pvt Ltd','Vikram Bose','9988001114','vikram@mediequip.in','Delhi','07AABCM6432H1Z3',4.7);
INSERT INTO Supplier VALUES (seq_supplier.NEXTVAL,'Siemens Healthineers India','Ananya Roy','9988001115','ananya@siemens.com','Bengaluru','29AAZCS2010N1ZZ',4.9);
COMMIT;

-- Staff (ISA Supertype) — trigger will create Doctor/Pharmacist sub-rows automatically
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 1,'Dr. Harpreet Singh',   'DOCTOR',    '9876511101','harpreet.singh@civ.asr.gov.in','dr.harpreet', DATE '2015-04-01','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 1,'Dr. Mandeep Kaur',     'DOCTOR',    '9876511102','mandeep.kaur@civ.asr.gov.in','dr.mandeep',   DATE '2017-08-15','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 1,'Balwinder Phull',      'PHARMACIST','9876511103','balwinder.p@civ.asr.gov.in','ph.balwinder',  DATE '2018-01-10','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 1,'Navneet Dhaliwal',     'ADMIN',     '9876511104','navneet.d@civ.asr.gov.in','adm.navneet',    DATE '2019-06-01','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 9,'Dr. Gurdeep Brar',     'DOCTOR',    '9876511105','gurdeep.brar@civ.ldh.gov.in','dr.gurdeep',   DATE '2014-03-20','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 9,'Dr. Ramandeep Sidhu',  'DOCTOR',    '9876511106','ramandeep.s@civ.ldh.gov.in','dr.ramandeep',  DATE '2016-11-05','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 9,'Sukhjit Bains',        'PHARMACIST','9876511107','sukhjit.b@civ.ldh.gov.in','ph.sukhjit',     DATE '2015-07-22','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 9,'Amarjot Gill',         'ADMIN',     '9876511108','amarjot.g@civ.ldh.gov.in','adm.amarjot',    DATE '2020-02-14','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,17,'Dr. Prabhjot Sandhu',  'DOCTOR',    '9876511109','prabhjot.s@civ.ptl.gov.in','dr.prabhjot',   DATE '2013-09-01','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,17,'Dr. Kiranjit Bhullar', 'DOCTOR',    '9876511110','kiranjit.b@civ.ptl.gov.in','dr.kiranjit',   DATE '2018-05-30','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,17,'Simranjit Dhindsa',    'PHARMACIST','9876511111','simranjit.d@civ.ptl.gov.in','ph.simranjit',  DATE '2016-12-01','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,17,'Lakhvir Grewal',       'ADMIN',     '9876511112','lakhvir.g@civ.ptl.gov.in','adm.lakhvir',    DATE '2021-07-19','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,24,'Dr. Tejinder Maan',    'DOCTOR',    '9876511113','tejinder.m@civ.jal.gov.in','dr.tejinder',   DATE '2012-06-15','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,24,'Dr. Amandeep Toor',    'DOCTOR',    '9876511114','amandeep.t@civ.jal.gov.in','dr.amandeep',   DATE '2019-03-25','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,24,'Gurjinder Sohal',      'PHARMACIST','9876511115','gurjinder.s@civ.jal.gov.in','ph.gurjinder',  DATE '2017-10-08','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,31,'Dr. Seema Arora',      'DOCTOR',    '9876511116','seema.arora@civ.mohali.gov.in','dr.seema',   DATE '2016-08-01','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,31,'Paramjit Randhawa',    'PHARMACIST','9876511117','paramjit.r@civ.mohali.gov.in','ph.paramjit', DATE '2019-01-15','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,37,'Dr. Kulwant Dhami',    'DOCTOR',    '9876511118','kulwant.d@civ.gpb.gov.in','dr.kulwant',     DATE '2014-05-20','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,37,'Sukhdev Basra',        'PHARMACIST','9876511119','sukhdev.b@civ.gpb.gov.in','ph.sukhdev',     DATE '2018-09-03','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,43,'Dr. Inderpal Cheema',  'DOCTOR',    '9876511120','inderpal.c@civ.hsp.gov.in','dr.inderpal',   DATE '2015-11-11','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,43,'Baldeep Thind',        'PHARMACIST','9876511121','baldeep.t@civ.hsp.gov.in','ph.baldeep',     DATE '2020-04-07','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,49,'Dr. Ravinder Hothi',   'DOCTOR',    '9876511122','ravinder.h@civ.bti.gov.in','dr.ravinder',   DATE '2013-07-04','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL,49,'Narinder Kahlon',      'PHARMACIST','9876511123','narinder.k@civ.bti.gov.in','ph.narinder',   DATE '2017-06-20','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 2,'Dr. Amrit Bajwa',      'DOCTOR',    '9876511124','amrit.bajwa@phc.majitha.gov.in','dr.amrit',  DATE '2020-01-10','Y');
INSERT INTO Staff VALUES (seq_staff.NEXTVAL, 2,'Dilnawaz Bhatia',      'PHARMACIST','9876511125','dilnawaz.b@phc.majitha.gov.in','ph.dilnawaz',DATE '2021-03-15','Y');
COMMIT;

-- Update Doctor sub-rows with real details (trigger inserted defaults)
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2015-1101', qualification='MBBS, MD (Medicine)', years_experience=10 WHERE staff_id=101;
UPDATE Doctor SET specialization='Gynaecology',      license_no='PMC-2017-1102', qualification='MBBS, MS (Gynaec)',    years_experience=8  WHERE staff_id=102;
UPDATE Doctor SET specialization='Cardiology',       license_no='PMC-2014-1105', qualification='MBBS, DM (Cardiology)',years_experience=11 WHERE staff_id=105;
UPDATE Doctor SET specialization='Orthopaedics',     license_no='PMC-2016-1106', qualification='MBBS, MS (Ortho)',     years_experience=9  WHERE staff_id=106;
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2013-1109', qualification='MBBS, MD (Medicine)', years_experience=12 WHERE staff_id=109;
UPDATE Doctor SET specialization='Paediatrics',      license_no='PMC-2018-1110', qualification='MBBS, MD (Paeds)',     years_experience=7  WHERE staff_id=110;
UPDATE Doctor SET specialization='Surgery',          license_no='PMC-2012-1113', qualification='MBBS, MS (General Surgery)', years_experience=14 WHERE staff_id=113;
UPDATE Doctor SET specialization='ENT',              license_no='PMC-2019-1114', qualification='MBBS, MS (ENT)',       years_experience=6  WHERE staff_id=114;
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2016-1116', qualification='MBBS, MD (Medicine)', years_experience=9  WHERE staff_id=116;
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2014-1118', qualification='MBBS, MD (Medicine)', years_experience=11 WHERE staff_id=118;
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2015-1120', qualification='MBBS, MD (Medicine)', years_experience=10 WHERE staff_id=120;
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2013-1122', qualification='MBBS, MD (Medicine)', years_experience=12 WHERE staff_id=122;
UPDATE Doctor SET specialization='General Medicine', license_no='PMC-2020-1124', qualification='MBBS',                years_experience=5  WHERE staff_id=124;

-- Update Pharmacist sub-rows with real details
UPDATE Pharmacist SET license_no='PSPC-2018-1103', qualification='B.Pharm, M.Pharm' WHERE staff_id=103;
UPDATE Pharmacist SET license_no='PSPC-2015-1107', qualification='B.Pharm'           WHERE staff_id=107;
UPDATE Pharmacist SET license_no='PSPC-2016-1111', qualification='B.Pharm, M.Pharm' WHERE staff_id=111;
UPDATE Pharmacist SET license_no='PSPC-2017-1115', qualification='B.Pharm'           WHERE staff_id=115;
UPDATE Pharmacist SET license_no='PSPC-2019-1117', qualification='B.Pharm, M.Pharm' WHERE staff_id=117;
UPDATE Pharmacist SET license_no='PSPC-2018-1119', qualification='B.Pharm'           WHERE staff_id=119;
UPDATE Pharmacist SET license_no='PSPC-2020-1121', qualification='D.Pharm'           WHERE staff_id=121;
UPDATE Pharmacist SET license_no='PSPC-2017-1123', qualification='B.Pharm'           WHERE staff_id=123;
UPDATE Pharmacist SET license_no='PSPC-2021-1125', qualification='B.Pharm'           WHERE staff_id=125;
COMMIT;

-- Medicines
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,201,'Paracetamol 500mg',        'Acetaminophen',       'ANTIPYRETIC',     'tablet',  '500mg',   1.50, 500);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,201,'Amoxicillin 500mg',        'Amoxicillin',         'ANTIBIOTIC',      'capsule', '500mg',   8.00, 300);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,202,'Ibuprofen 400mg',          'Ibuprofen',           'ANALGESIC',       'tablet',  '400mg',   4.50, 300);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,202,'Metformin 500mg',          'Metformin HCl',       'DIABETIC',        'tablet',  '500mg',   3.20, 400);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,203,'Ciprofloxacin 500mg',      'Ciprofloxacin',       'ANTIBIOTIC',      'tablet',  '500mg',  12.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,203,'Atorvastatin 10mg',        'Atorvastatin',        'CARDIAC',         'tablet',  '10mg',   18.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,204,'Omeprazole 20mg',          'Omeprazole',          'ANTACID',         'capsule', '20mg',    6.50, 250);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,204,'Amlodipine 5mg',           'Amlodipine Besylate', 'ANTIHYPERTENSIVE','tablet',  '5mg',     9.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,205,'Azithromycin 500mg',       'Azithromycin',        'ANTIBIOTIC',      'tablet',  '500mg',  22.00, 150);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,205,'Cetirizine 10mg',          'Cetirizine HCl',      'ANTIHISTAMINE',   'tablet',  '10mg',    3.80, 300);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,206,'Fluconazole 150mg',        'Fluconazole',         'ANTIFUNGAL',      'capsule', '150mg',  35.00, 100);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,206,'Losartan 50mg',            'Losartan Potassium',  'ANTIHYPERTENSIVE','tablet',  '50mg',   14.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,207,'Metronidazole 400mg',      'Metronidazole',       'ANTIBIOTIC',      'tablet',  '400mg',   4.20, 250);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,207,'Salbutamol Inhaler 100mcg','Salbutamol',          'OTHER',           'inhaler', '100mcg', 95.00,  80);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,208,'Vitamin D3 60000 IU',      'Cholecalciferol',     'VITAMIN',         'capsule', '60000IU',28.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,208,'Iron + Folic Acid',        'Ferrous Sulphate+FA', 'VITAMIN',         'tablet',  NULL,      2.80, 500);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,209,'Insulin Glargine 100U/ml', 'Insulin Glargine',    'DIABETIC',        'injection','100U/ml',340.00,80);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,209,'Pantoprazole 40mg',        'Pantoprazole Sodium', 'ANTACID',         'tablet',  '40mg',    8.50, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,210,'Doxycycline 100mg',        'Doxycycline Hyclate', 'ANTIBIOTIC',      'capsule', '100mg',  10.00, 150);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,210,'Prednisolone 5mg',         'Prednisolone',        'STEROID',         'tablet',  '5mg',     4.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,201,'Clopidogrel 75mg',         'Clopidogrel',         'CARDIAC',         'tablet',  '75mg',   16.50, 150);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,202,'Metoprolol 50mg',          'Metoprolol Tartrate', 'CARDIAC',         'tablet',  '50mg',   11.00, 150);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,203,'Ranitidine 150mg',         'Ranitidine HCl',      'ANTACID',         'tablet',  '150mg',   5.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,204,'Levocetirizine 5mg',       'Levocetirizine',      'ANTIHISTAMINE',   'tablet',  '5mg',     6.00, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,205,'Clotrimazole Cream 1%',    'Clotrimazole',        'ANTIFUNGAL',      'cream',   '1%',     28.00,  80);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,205,'ORS Powder Sachet',        'ORS',                 'OTHER',           'powder',  NULL,      4.50, 400);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,206,'Enalapril 5mg',            'Enalapril Maleate',   'ANTIHYPERTENSIVE','tablet',  '5mg',     7.50, 200);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,206,'Glipizide 5mg',            'Glipizide',           'DIABETIC',        'tablet',  '5mg',     9.50, 150);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,207,'Ondansetron 4mg',          'Ondansetron HCl',     'OTHER',           'tablet',  '4mg',    12.00, 150);
INSERT INTO Medicine VALUES (seq_medicine.NEXTVAL,208,'Diclofenac 75mg Inj',      'Diclofenac Sodium',   'ANALGESIC',       'injection','75mg',  18.00, 100);
COMMIT;

-- Equipment
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,214,'ECG Machine 12-Lead',     'DIAGNOSTIC',    95000, DATE '2025-06-15', DATE '2028-04-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,214,'Digital X-Ray Machine',   'DIAGNOSTIC',   850000, DATE '2025-09-01', DATE '2030-01-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Ventilator ICU Grade',    'LIFE_SUPPORT',  480000, DATE '2025-03-20', DATE '2029-06-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Syringe Infusion Pump',   'MONITORING',    38000, DATE '2025-12-01', DATE '2027-12-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Defibrillator AED',       'LIFE_SUPPORT',  165000, DATE '2026-02-10', DATE '2029-02-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,214,'Pulse Oximeter',          'MONITORING',    3200,  DATE '2026-01-15', DATE '2027-01-15');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,214,'Digital BP Monitor',      'DIAGNOSTIC',    4800,  DATE '2026-03-01', DATE '2028-03-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Foetal Doppler',          'DIAGNOSTIC',    12500, DATE '2025-11-10', DATE '2027-11-10');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Oxygen Concentrator 5L', 'LIFE_SUPPORT',  42000, DATE '2025-08-20', DATE '2028-08-20');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,214,'Glucometer',              'DIAGNOSTIC',    2400,  DATE '2026-04-01', DATE '2027-04-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,214,'Ultrasound Machine',      'DIAGNOSTIC',   320000, DATE '2025-07-01', DATE '2030-07-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Suction Machine',         'SURGICAL',      28000, DATE '2025-10-15', DATE '2028-10-15');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Autoclave Sterilizer',    'SURGICAL',      55000, DATE '2025-05-01', DATE '2029-05-01');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Patient Monitor 5 Para',  'MONITORING',   125000, DATE '2025-04-20', DATE '2030-04-20');
INSERT INTO Equipment VALUES (seq_equipment.NEXTVAL,215,'Neonatal Incubator',      'LIFE_SUPPORT',  210000, DATE '2025-12-20', DATE '2030-12-20');
COMMIT;

-- Medicine Inventory (batch-level; some intentionally expired for trigger demos)
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3001,'BSUN240101',2400,DATE '2023-07-01',DATE '2026-07-01','Shelf-A1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3002,'BCIP240101', 800,DATE '2023-08-15',DATE '2026-08-15','Shelf-A2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3003,'BZYD240101',1200,DATE '2023-09-01',DATE '2026-09-01','Shelf-A3',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3004,'BLUP240101', 900,DATE '2023-10-01',DATE '2026-10-01','Shelf-B1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3005,'BCIP240102', 500,DATE '2023-11-01',DATE '2026-11-01','Shelf-B2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3006,'BDRL240101', 600,DATE '2023-12-01',DATE '2026-12-01','Shelf-B3',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3007,'BALK240101', 700,DATE '2024-01-01',DATE '2027-01-01','Shelf-C1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3008,'BMAN240101', 650,DATE '2024-01-15',DATE '2027-01-15','Shelf-C2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3017,'BAbbott2401', 120,DATE '2024-02-01',DATE '2027-02-01','Fridge-1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3009,'BTORR240101', 380,DATE '2024-02-15',DATE '2026-02-15','Shelf-D1',SYSDATE);
-- Expired batches (intentional — for trigger/constraint demos)
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3010,'BEXP230101',  80,DATE '2022-01-01',DATE '2024-01-01','Shelf-D2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 1,3011,'BEXP230201',  45,DATE '2022-03-01',DATE '2024-03-01','Shelf-D3',SYSDATE);
-- Civil Ludhiana (dispensary 9)
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 9,3001,'BSUN240201',1800,DATE '2023-07-01',DATE '2026-07-01','Shelf-A1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 9,3004,'BLUP240201', 750,DATE '2023-10-01',DATE '2026-10-01','Shelf-A2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 9,3006,'BDRL240201', 550,DATE '2023-12-01',DATE '2026-12-01','Shelf-B1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 9,3008,'BMAN240201', 620,DATE '2024-01-15',DATE '2027-01-15','Shelf-B2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 9,3012,'BZYD240201', 310,DATE '2024-02-01',DATE '2027-02-01','Shelf-C1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 9,3013,'BALK240201', 480,DATE '2024-01-01',DATE '2027-01-01','Shelf-C2',SYSDATE);
-- Civil Patiala (dispensary 17)
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,17,3001,'BSUN240301',2000,DATE '2023-07-01',DATE '2026-07-01','Shelf-A1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,17,3002,'BCIP240301', 700,DATE '2023-08-15',DATE '2026-08-15','Shelf-A2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,17,3004,'BLUP240301', 820,DATE '2023-10-01',DATE '2026-10-01','Shelf-B1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,17,3017,'BABB240301', 100,DATE '2024-02-01',DATE '2027-02-01','Fridge-1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,17,3020,'BZKD240301', 280,DATE '2024-03-01',DATE '2027-03-01','Shelf-C1',SYSDATE);
-- Civil Jalandhar (dispensary 24) — low stock scenario
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,24,3001,'BSUN240401',1600,DATE '2023-07-01',DATE '2026-07-01','Shelf-A1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,24,3005,'BCIP240401',  30,DATE '2023-11-01',DATE '2026-11-01','Shelf-A2',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,24,3008,'BMAN240401',  50,DATE '2024-01-15',DATE '2027-01-15','Shelf-B1',SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL,24,3014,'BSUN240402', 250,DATE '2024-03-01',DATE '2027-03-01','Shelf-B2',SYSDATE);
-- PHC Majitha (dispensary 2)
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 2,3001,'BSUN240501', 400,DATE '2023-07-01',DATE '2026-07-01','Shelf-1', SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 2,3003,'BZYD240501', 200,DATE '2023-09-01',DATE '2026-09-01','Shelf-2', SYSDATE);
INSERT INTO Medicine_Inventory VALUES (seq_med_inv.NEXTVAL, 2,3007,'BALK240501', 180,DATE '2024-01-01',DATE '2027-01-01','Shelf-3', SYSDATE);
COMMIT;

-- Equipment Inventory
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4001,'ECG-ASR-001',    1,'AVAILABLE',          DATE '2023-01-15',DATE '2025-06-15');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4002,'XRAY-ASR-001',   1,'AVAILABLE',          DATE '2022-06-01',DATE '2025-09-01');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4003,'VENT-ASR-001',   2,'AVAILABLE',          DATE '2023-03-10',DATE '2025-03-20');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4004,'SYMP-ASR-001',   4,'AVAILABLE',          DATE '2023-08-01',DATE '2025-12-01');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4005,'DEFIB-ASR-001',  1,'UNDER_MAINTENANCE',   DATE '2022-02-15',DATE '2026-02-10');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4006,'OXIM-ASR-001',   8,'AVAILABLE',          DATE '2024-01-10',DATE '2026-01-15');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4007,'BPMO-ASR-001',   6,'AVAILABLE',          DATE '2024-02-01',DATE '2026-03-01');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4011,'USGM-ASR-001',   1,'AVAILABLE',          DATE '2023-05-01',DATE '2025-07-01');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 1,4014,'PMON-ASR-001',   3,'AVAILABLE',          DATE '2023-06-01',DATE '2025-04-20');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 9,4001,'ECG-LDH-001',    1,'AVAILABLE',          DATE '2023-04-01',DATE '2025-06-15');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 9,4002,'XRAY-LDH-001',   1,'UNDER_MAINTENANCE',   DATE '2022-08-01',DATE '2025-09-01');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 9,4003,'VENT-LDH-001',   3,'AVAILABLE',          DATE '2023-01-15',DATE '2025-03-20');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 9,4005,'DEFIB-LDH-001',  2,'AVAILABLE',          DATE '2023-05-20',DATE '2026-02-10');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL, 9,4009,'OXYC-LDH-001',   4,'AVAILABLE',          DATE '2023-09-10',DATE '2025-08-20');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL,17,4001,'ECG-PTL-001',    2,'AVAILABLE',          DATE '2023-07-10',DATE '2025-06-15');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL,17,4003,'VENT-PTL-001',   2,'AVAILABLE',          DATE '2023-11-01',DATE '2025-03-20');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL,17,4008,'FDOP-PTL-001',   2,'AVAILABLE',          DATE '2024-01-05',DATE '2025-11-10');
INSERT INTO Equipment_Inventory VALUES (seq_eq_inv.NEXTVAL,17,4015,'NINC-PTL-001',   2,'AVAILABLE',          DATE '2024-03-01',DATE '2025-12-20');
COMMIT;

-- Patients
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Gurpreet Singh',   'M',DATE '1978-04-12','B+', '9876001001','House 42, Majitha Rd, Amritsar',   '123456780001',DATE '2024-01-05');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Harjinder Kaur',   'F',DATE '1985-09-23','O+', '9876001002','Street 5, Ranjit Ave, Amritsar',    '123456780002',DATE '2024-01-06');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Amarjit Dhaliwal', 'M',DATE '1960-03-17','A+', '9876001003','VPO Rayya, Amritsar',               '123456780003',DATE '2024-01-08');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Simran Brar',      'F',DATE '1995-11-30','AB-','9876001004','Kot Khalsa, Amritsar',              '123456780004',DATE '2024-01-10');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Kulwant Sidhu',    'M',DATE '1972-06-05','O-', '9876001005','Tarn Taran Rd, Amritsar',           '123456780005',DATE '2024-01-11');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Navdeep Bhullar',  'M',DATE '1989-08-14','A-', '9876001006','Sultanwind, Amritsar',              '123456780006',DATE '2024-01-15');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Parminder Grewal', 'F',DATE '1968-02-28','B-', '9876001007','Loharka Rd, Amritsar',              '123456780007',DATE '2024-01-18');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Ranjit Maan',      'M',DATE '1955-07-07','O+', '9876001008','Golden Temple Area, Amritsar',      '123456780008',DATE '2024-01-20');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Sukhwinder Cheema','M',DATE '1980-05-19','B+', '9876001009','Model Town, Ludhiana',              '123456780009',DATE '2024-01-07');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Manjit Sohal',     'F',DATE '1975-12-03','A+', '9876001010','Haibowal Kalan, Ludhiana',          '123456780010',DATE '2024-01-09');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Ravinder Gill',    'M',DATE '1963-03-25','O+', '9876001011','Sherpur Chowk, Ludhiana',           '123456780011',DATE '2024-01-12');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Kiranjit Sandhu',  'F',DATE '1990-10-08','AB+','9876001012','Dugri Phase 1, Ludhiana',           '123456780012',DATE '2024-01-14');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Dilbag Randhawa',  'M',DATE '1948-01-20','B+', '9876001013','Dhandari Kalan, Ludhiana',          '123456780013',DATE '2024-01-16');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Gurleen Atwal',    'F',DATE '2000-06-15','A+', '9876001014','Salem Tabri, Ludhiana',             '123456780014',DATE '2024-01-22');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Tejpal Phull',     'M',DATE '1970-09-09','O+', '9876001015','Leela Bhawan, Patiala',             '123456780015',DATE '2024-01-06');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Jasleen Dhindsa',  'F',DATE '1993-04-24','B+', '9876001016','New Lal Bagh, Patiala',             '123456780016',DATE '2024-01-08');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Balbir Dhillon',   'M',DATE '1952-11-11','A-', '9876001017','Rajpura Rd, Patiala',               '123456780017',DATE '2024-01-10');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Rupinder Bajwa',   'F',DATE '1986-07-17','O+', '9876001018','Sirhind Rd, Patiala',               '123456780018',DATE '2024-01-13');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Satnam Toor',      'M',DATE '1940-03-30','B+', '9876001019','Tripuri, Patiala',                  '123456780019',DATE '2024-01-17');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Harpuneet Basra',  'F',DATE '1998-12-22','O-', '9876001020','Nabha Rd, Patiala',                 '123456780020',DATE '2024-01-19');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Lakhwinder Hothi', 'M',DATE '1965-08-30','A+', '9876001021','Model Town, Jalandhar',             '123456780021',DATE '2024-01-05');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Poonam Chhabra',   'F',DATE '1982-05-15','B+', '9876001022','Guru Nanak Colony, Jalandhar',      '123456780022',DATE '2024-01-07');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Joginder Bains',   'M',DATE '1957-01-01','AB+','9876001023','Nakodar Chowk, Jalandhar',          '123456780023',DATE '2024-01-09');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Supreet Kahlon',   'F',DATE '1975-10-04','O+', '9876001024','Rama Mandi, Jalandhar',             '123456780024',DATE '2024-01-11');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 2,'Dilbag Virk',      'M',DATE '1971-04-18','B-', '9876001025','VPO Majitha, Amritsar',             '123456780025',DATE '2024-01-06');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 2,'Gurmeet Kang',     'F',DATE '1988-09-09','O+', '9876001026','Fatehpur, Amritsar',                '123456780026',DATE '2024-01-08');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,31,'Amanjot Sekhon',   'M',DATE '1983-07-23','A+', '9876001027','Phase 7, Mohali',                   '123456780027',DATE '2024-01-10');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,31,'Navjot Aulakh',    'F',DATE '1991-03-14','B+', '9876001028','Sector 68, Mohali',                 '123456780028',DATE '2024-01-12');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,31,'Harish Kumar',     'M',DATE '1945-11-05','O+', '9876001029','Kharar, Mohali',                    '123456780029',DATE '2024-01-14');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,37,'Gurmail Pannu',    'M',DATE '1968-06-20','A+', '9876001030','Civil Lines, Gurdaspur',            '123456780030',DATE '2024-01-05');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,37,'Amanpreet Natt',   'F',DATE '1996-02-11','B+', '9876001031','Dera Baba Nanak, Gurdaspur',        '123456780031',DATE '2024-01-07');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,43,'Karnail Chahal',   'M',DATE '1973-08-08','O+', '9876001032','Jalandhar Rd, Hoshiarpur',          '123456780032',DATE '2024-01-06');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,43,'Sukhmandeep Walia','F',DATE '1987-05-19','AB+','9876001033','Dasuya, Hoshiarpur',                '123456780033',DATE '2024-01-09');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,49,'Inderjit Padda',   'M',DATE '1960-12-25','B+', '9876001034','Goniana Rd, Bathinda',              '123456780034',DATE '2024-01-08');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,49,'Satwinderjit Mann','F',DATE '1979-04-30','A+', '9876001035','Talwandi Sabo, Bathinda',           '123456780035',DATE '2024-01-10');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Rajwinder Kalsi',  'M',DATE '2002-09-12','O+', '9876001036','Green Ave, Amritsar',               '123456780036',DATE '2024-02-01');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Gurpreet Malhotra','F',DATE '1940-01-08','B+', '9876001037','Batala Rd, Amritsar',               '123456780037',DATE '2024-02-03');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Varinder Sran',    'M',DATE '1967-05-22','A-', '9876001038','Focal Point, Ludhiana',             '123456780038',DATE '2024-02-02');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Diljit Hayer',     'M',DATE '1974-10-17','O+', '9876001039','Sarabha Nagar, Ludhiana',           '123456780039',DATE '2024-02-04');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Gurcharanjit Litt','M',DATE '1988-06-03','B+', '9876001040','Urban Estate, Patiala',             '123456780040',DATE '2024-02-05');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Harleen Nagra',    'F',DATE '1997-11-28','O+', '9876001041','Bahadurgarh, Patiala',              '123456780041',DATE '2024-02-06');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Manmohan Bhatia',  'M',DATE '1953-03-03','A+', '9876001042','Nakodar, Jalandhar',                '123456780042',DATE '2024-02-07');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Gurpreet Nanda',   'F',DATE '1990-08-16','B-', '9876001043','Adampur, Jalandhar',                '123456780043',DATE '2024-02-08');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Amrik Gill',       'M',DATE '1946-07-04','AB+','9876001044','Majitha, Amritsar',                 '123456780044',DATE '2024-02-10');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Palwinder Thind',  'F',DATE '1969-09-01','O+', '9876001045','Jagraon, Ludhiana',                 '123456780045',DATE '2024-02-12');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Navkiran Bedi',    'F',DATE '2001-01-15','A+', '9876001046','Sanour, Patiala',                   '123456780046',DATE '2024-02-13');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,24,'Surjit Ghotra',    'M',DATE '1976-12-12','B+', '9876001047','Phillaur, Jalandhar',               '123456780047',DATE '2024-02-15');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 1,'Deepti Sahota',    'F',DATE '1984-08-20','O+', '9876001048','Shastri Nagar, Amritsar',           '123456780048',DATE '2024-02-18');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL, 9,'Bikramjit Hundal', 'M',DATE '1991-02-07','A+', '9876001049','Dugri, Ludhiana',                   '123456780049',DATE '2024-02-20');
INSERT INTO Patient VALUES (seq_patient.NEXTVAL,17,'Rajinderpal Kundi','M',DATE '1959-06-14','B-', '9876001050','Rajpura, Patiala',                  '123456780050',DATE '2024-02-22');
COMMIT;

-- Visits
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1001,101,1, DATE '2024-01-15','Fever, headache, body ache',      'Viral fever',            'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1002,101,1, DATE '2024-01-16','Sore throat, cough',              'Upper respiratory infection','OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1003,101,1, DATE '2024-01-17','Chest pain, breathlessness',      'Hypertension',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1004,102,1, DATE '2024-01-18','Abdominal pain, nausea',          'Gastritis',              'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1005,101,1, DATE '2024-01-19','Joint pain, stiffness',           'Arthritis',              'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1006,101,1, DATE '2024-01-20','Dizziness, fatigue',              'Anaemia',                'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1007,102,1, DATE '2024-01-21','Skin itching, rash',              'Allergic dermatitis',    'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1008,101,1, DATE '2024-01-22','Cough, mucus',                    'Bronchitis',             'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1009,105,9, DATE '2024-01-15','Chest pain, palpitations',        'Cardiac arrhythmia',     'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1010,105,9, DATE '2024-01-16','High BP, headache',               'Hypertension',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1011,106,9, DATE '2024-01-17','Knee pain, swelling',             'Osteoarthritis',         'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1012,105,9, DATE '2024-01-18','Diabetes follow-up',              'Type 2 DM',              'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1013,106,9, DATE '2024-01-19','Back pain, injury',               'Lumbar sprain',          'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1014,105,9, DATE '2024-01-20','Breathlessness, cough',           'COPD',                   'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1015,109,17,DATE '2024-01-15','Fever, rash',                     'Typhoid fever',          'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1016,110,17,DATE '2024-01-16','Child fever, vomiting',           'Gastroenteritis',        'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1017,109,17,DATE '2024-01-17','Chest tightness',                 'Asthma',                 'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1018,110,17,DATE '2024-01-18','High blood sugar',                'Type 2 DM uncontrolled', 'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1019,109,17,DATE '2024-01-19','Fungal infection foot',           'Tinea pedis',            'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1020,110,17,DATE '2024-01-20','Pregnancy check 3rd trimester',   'Normal pregnancy',       'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1021,113,24,DATE '2024-01-15','Chest pain',                      'Angina',                 'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1022,113,24,DATE '2024-01-16','Abdominal pain',                  'Peptic ulcer',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1023,114,24,DATE '2024-01-17','Ear pain, discharge',             'Otitis media',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1024,113,24,DATE '2024-01-18','Hypertension follow-up',          'Hypertension',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1025,124,2, DATE '2024-01-15','Fever, cold',                     'Viral URTI',             'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1026,124,2, DATE '2024-01-16','Stomach ache',                    'Gastritis',              'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1036,101,1, DATE '2024-02-01','Diabetes check',                  'Type 2 DM',              'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1037,101,1, DATE '2024-02-02','Fever',                           'Viral fever',            'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1038,105,9, DATE '2024-02-01','BP elevated',                     'Hypertension',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1039,105,9, DATE '2024-02-02','Cough, cold',                     'Viral URTI',             'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1040,109,17,DATE '2024-02-03','Rash, itching',                   'Allergic reaction',      'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1041,109,17,DATE '2024-02-04','Fever',                           'Malaria suspected',      'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1042,113,24,DATE '2024-02-05','Joint pain',                      'Gout',                   'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1043,113,24,DATE '2024-02-06','High BP',                         'Hypertension',           'OPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1044,101,1, DATE '2024-02-10','Chest infection',                 'Pneumonia',              'IPD');
INSERT INTO Visit VALUES (seq_visit.NEXTVAL,1045,101,1, DATE '2024-02-12','RTA injuries',                    'Multiple trauma',        'EMERGENCY');
COMMIT;

-- Prescriptions and Items
INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7001,101,103,DATE '2024-01-15',DATE '2024-01-15','DISPENSED','Viral fever treatment');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8001,3001,'1 tablet TDS x 5 days', 5, 15);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8001,3010,'1 tablet BD x 5 days',  5, 10);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7002,101,103,DATE '2024-01-16',DATE '2024-01-16','DISPENSED','URTI with secondary infection');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8002,3002,'1 capsule TDS x 7 days', 7, 21);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8002,3001,'1 tablet TDS x 5 days',  5, 15);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8002,3010,'1 tablet SOS',            3,  3);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7003,101,103,DATE '2024-01-17',DATE '2024-01-17','DISPENSED','HTN management');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8003,3008,'1 tablet OD',30, 30);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8003,3012,'1 tablet OD',30, 30);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7004,102,103,DATE '2024-01-18',DATE '2024-01-18','DISPENSED','Gastritis');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8004,3007,'1 capsule BD before meals',14, 28);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8004,3001,'SOS for pain',              5,  5);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7009,105,107,DATE '2024-01-15',DATE '2024-01-15','DISPENSED','Cardiac arrhythmia');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8005,3006,'1 tablet OD night',  30, 30);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8005,3021,'1 tablet OD morning',30, 30);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7012,105,107,DATE '2024-01-18',DATE '2024-01-18','DISPENSED','Type 2 DM control');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8006,3004,'1 tablet BD with meals',30, 60);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7015,109,111,DATE '2024-01-15',DATE '2024-01-15','DISPENSED','Typhoid fever');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8007,3009,'1 tablet OD x 5 days', 5,  5);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8007,3001,'1 tablet TDS x 5 days',5, 15);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7017,109,111,DATE '2024-01-17',DATE '2024-01-17','DISPENSED','Asthma acute');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8008,3014,'2 puffs SOS',        NULL, 1);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8008,3020,'1 tablet OD x 5 days',5,  5);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7019,109,111,DATE '2024-01-19',DATE '2024-01-19','DISPENSED','Tinea pedis');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8009,3011,'Apply BD x 14 days',  14, 2);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8009,3011,'1 capsule x 1 dose',   1, 1);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7021,113,115,DATE '2024-01-15',DATE '2024-01-15','DISPENSED','Angina pectoris');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8010,3022,'1 tablet OD',30, 30);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8010,3006,'1 tablet OD',30, 30);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7027,101,103,DATE '2024-02-01',DATE '2024-02-01','DISPENSED','DM follow-up');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8011,3004,'1 tablet BD',30, 60);
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8011,3028,'1 tablet OD',30, 30);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7028,101,103,DATE '2024-02-02',DATE '2024-02-02','DISPENSED','Fever');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8012,3001,'1 tablet TDS',5, 15);

INSERT INTO Prescription VALUES (seq_presc.NEXTVAL,7033,113,115,DATE '2024-02-05',NULL,'PENDING','Joint pain, gout');
INSERT INTO Prescription_Items VALUES (seq_presc_item.NEXTVAL,8013,3003,'1 tablet TDS x 5 days',5, NULL);
COMMIT;

-- Transaction Log
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5001,103,'STOCK_IN', 2400,DATE '2024-01-02',NULL,'Initial stocking Paracetamol batch BSUN240101');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5002,103,'STOCK_IN',  800,DATE '2024-01-02',NULL,'Initial stocking Amoxicillin batch BCIP240101');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5003,103,'STOCK_IN', 1200,DATE '2024-01-02',NULL,'Initial stocking Ibuprofen batch BZYD240101');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5004,103,'STOCK_IN',  900,DATE '2024-01-02',NULL,'Initial stocking Metformin batch BLUP240101');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5005,103,'STOCK_IN',  500,DATE '2024-01-02',NULL,'Initial stocking Ciprofloxacin batch BCIP240102');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5006,103,'STOCK_IN',  600,DATE '2024-01-02',NULL,'Initial stocking Atorvastatin batch BDRL240101');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5001,103,'ISSUE',      15,DATE '2024-01-15',9001,'Issued per Prescription 8001 – Viral fever');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5002,103,'ISSUE',      21,DATE '2024-01-16',9004,'Issued per Prescription 8002 – URTI');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5001,103,'ISSUE',      15,DATE '2024-01-16',9005,'Issued per Prescription 8002');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5008,103,'ISSUE',      30,DATE '2024-01-17',9008,'Issued Amlodipine Prescription 8003');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5006,103,'ISSUE',      30,DATE '2024-01-17',9014,'Issued Atorvastatin Prescription 8005');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5004,103,'ISSUE',      60,DATE '2024-01-18',9016,'Issued Metformin Prescription 8006');
INSERT INTO Transaction_Log VALUES (seq_txn.NEXTVAL,5004,103,'ISSUE',      60,DATE '2024-02-01',9021,'Issued Metformin Prescription 8011');
COMMIT;

-- Equipment Usage
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6001,101,1009,DATE '2024-01-15','ECG for cardiac evaluation',     25,'Normal sinus rhythm');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6001,101,1010,DATE '2024-01-16','ECG – BP monitoring patient',    20,'Left ventricular hypertrophy');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6002,101,1003,DATE '2024-01-17','Chest X-ray for HTN',            15,'Cardiomegaly noted');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6003,101,1044,DATE '2024-02-10','Ventilator IPD pneumonia',      720,'Patient stabilised');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6006,101,1009,DATE '2024-01-15','Pulse oximetry monitoring',      30,'SpO2 98%');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6007,101,1010,DATE '2024-01-16','BP monitoring',                  10,'BP 150/90');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6009,101,1044,DATE '2024-02-10','Patient monitoring IPD',        480,'Stable HR and SpO2');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6010,105,1009,DATE '2024-01-15','ECG Ludhiana cardiac patient',   25,'Atrial fibrillation');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6012,105,1014,DATE '2024-01-20','Ventilator COPD exacerbation',  360,'Patient improved');
INSERT INTO Equipment_Usage VALUES (seq_eq_usage.NEXTVAL,6015,109,1020,DATE '2024-01-20','Foetal Doppler antenatal check', 20,'Normal foetal heart rate');
COMMIT;


-- ================================================================
-- SECTION 3 : LOGIC (Triggers, Procedures, Functions)
-- ================================================================

-- TRIGGER 1: ISA Role Integrity
-- Automatically creates Doctor/Pharmacist child row on Staff insert
CREATE OR REPLACE TRIGGER trg_isa_role_check
AFTER INSERT ON Staff
FOR EACH ROW
BEGIN
    IF :NEW.role = 'DOCTOR' THEN
        INSERT INTO Doctor (staff_id, specialization, license_no, qualification, years_experience)
        VALUES (:NEW.staff_id, 'General Practice', NULL, NULL, 0);
    ELSIF :NEW.role = 'PHARMACIST' THEN
        INSERT INTO Pharmacist (staff_id, license_no, qualification)
        VALUES (:NEW.staff_id, NULL, NULL);
    END IF;
END;
/

-- TRIGGER 2: Block Expired Medicine Issue
CREATE OR REPLACE TRIGGER trg_no_expired_issue
BEFORE INSERT ON Transaction_Log
FOR EACH ROW
DECLARE
    v_expiry   DATE;
    v_med_name VARCHAR2(150);
BEGIN
    IF :NEW.txn_type = 'ISSUE' THEN
        SELECT mi.expiry_date, m.name
        INTO   v_expiry, v_med_name
        FROM   Medicine_Inventory mi
        JOIN   Medicine            m ON m.medicine_id = mi.medicine_id
        WHERE  mi.inventory_id = :NEW.inventory_id;

        IF v_expiry < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'ISSUE BLOCKED: Medicine "' || v_med_name ||
                '" (Inventory ID ' || :NEW.inventory_id ||
                ') expired on ' || TO_CHAR(v_expiry, 'DD-MON-YYYY') || '.'
            );
        END IF;
    END IF;
END;
/

-- TRIGGER 3: Auto-Update Stock on Transaction
CREATE OR REPLACE TRIGGER trg_update_stock
AFTER INSERT ON Transaction_Log
FOR EACH ROW
BEGIN
    CASE :NEW.txn_type
        WHEN 'STOCK_IN' THEN
            UPDATE Medicine_Inventory
            SET quantity = quantity + :NEW.quantity, last_updated = SYSDATE
            WHERE inventory_id = :NEW.inventory_id;
        WHEN 'ISSUE' THEN
            UPDATE Medicine_Inventory
            SET quantity = quantity - :NEW.quantity, last_updated = SYSDATE
            WHERE inventory_id = :NEW.inventory_id;
        WHEN 'RETURN' THEN
            UPDATE Medicine_Inventory
            SET quantity = quantity + :NEW.quantity, last_updated = SYSDATE
            WHERE inventory_id = :NEW.inventory_id;
        WHEN 'EXPIRED_REMOVE' THEN
            UPDATE Medicine_Inventory
            SET quantity = quantity - :NEW.quantity, last_updated = SYSDATE
            WHERE inventory_id = :NEW.inventory_id;
        WHEN 'ADJUST' THEN
            UPDATE Medicine_Inventory
            SET quantity = :NEW.quantity, last_updated = SYSDATE
            WHERE inventory_id = :NEW.inventory_id;
    END CASE;
END;
/

-- TRIGGER 4: Pharmacist-Only Medicine Issue (role-based access control)
CREATE OR REPLACE TRIGGER trg_pharmacist_only_issue
BEFORE INSERT ON Transaction_Log
FOR EACH ROW
DECLARE
    v_role VARCHAR2(15);
BEGIN
    IF :NEW.txn_type = 'ISSUE' THEN
        SELECT role INTO v_role
        FROM   Staff
        WHERE  staff_id = :NEW.staff_id;

        IF v_role != 'PHARMACIST' THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'ACCESS DENIED: Only a PHARMACIST can issue medicines. ' ||
                'Staff ID ' || :NEW.staff_id || ' has role ' || v_role || '.'
            );
        END IF;
    END IF;
END;
/

-- TRIGGER 5: Inventory Audit Trail
CREATE OR REPLACE TRIGGER trg_audit_inventory
AFTER INSERT ON Transaction_Log
FOR EACH ROW
DECLARE
    v_qty_before    NUMBER;
    v_qty_after     NUMBER;
    v_medicine_id   NUMBER;
    v_dispensary_id NUMBER;
BEGIN
    SELECT quantity, medicine_id, dispensary_id
    INTO   v_qty_before, v_medicine_id, v_dispensary_id
    FROM   Medicine_Inventory
    WHERE  inventory_id = :NEW.inventory_id;

    CASE :NEW.txn_type
        WHEN 'STOCK_IN'       THEN v_qty_after := v_qty_before + :NEW.quantity;
        WHEN 'ISSUE'          THEN v_qty_after := v_qty_before - :NEW.quantity;
        WHEN 'RETURN'         THEN v_qty_after := v_qty_before + :NEW.quantity;
        WHEN 'EXPIRED_REMOVE' THEN v_qty_after := v_qty_before - :NEW.quantity;
        WHEN 'ADJUST'         THEN v_qty_after := :NEW.quantity;
        ELSE v_qty_after := v_qty_before;
    END CASE;

    INSERT INTO Inventory_Audit
        (inventory_id, medicine_id, dispensary_id, action,
         qty_before, qty_change, qty_after, performed_by, remarks)
    VALUES
        (:NEW.inventory_id, v_medicine_id, v_dispensary_id, :NEW.txn_type,
         v_qty_before, :NEW.quantity, v_qty_after, :NEW.staff_id, :NEW.remarks);
END;
/

-- PROCEDURE 1: Patient History Report
CREATE OR REPLACE PROCEDURE get_patient_history (p_patient_id IN NUMBER)
IS
    v_patient_name VARCHAR2(100);
    v_dob          DATE;

    CURSOR cur_visits IS
        SELECT v.visit_id, v.visit_date, v.visit_type, v.diagnosis,
               s.name AS doctor_name, d.name AS dispensary_name
        FROM   Visit      v
        JOIN   Staff      s ON s.staff_id      = v.staff_id
        JOIN   Dispensary d ON d.dispensary_id = v.dispensary_id
        WHERE  v.patient_id = p_patient_id
        ORDER  BY v.visit_date;

    CURSOR cur_presc_items (p_visit_id NUMBER) IS
        SELECT m.name AS medicine, pi.dosage, pi.duration_days, pi.quantity_issued
        FROM   Prescription      pr
        JOIN   Prescription_Items pi ON pi.prescription_id = pr.prescription_id
        JOIN   Medicine           m  ON m.medicine_id      = pi.medicine_id
        WHERE  pr.visit_id = p_visit_id;
BEGIN
    SELECT name, dob INTO v_patient_name, v_dob
    FROM   Patient WHERE patient_id = p_patient_id;

    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE(' PATIENT HISTORY: ' || v_patient_name ||
                         ' (ID: ' || p_patient_id || ')');
    DBMS_OUTPUT.PUT_LINE(' DOB: ' || TO_CHAR(v_dob,'DD-MON-YYYY') ||
                         '  Age: ' || FLOOR(MONTHS_BETWEEN(SYSDATE,v_dob)/12) || ' yrs');
    DBMS_OUTPUT.PUT_LINE('======================================================');

    FOR v_rec IN cur_visits LOOP
        DBMS_OUTPUT.PUT_LINE(
            CHR(10) || '  Visit #' || v_rec.visit_id || '  [' || v_rec.visit_type || ']' ||
            '  ' || TO_CHAR(v_rec.visit_date,'DD-MON-YYYY') || '  at ' || v_rec.dispensary_name
        );
        DBMS_OUTPUT.PUT_LINE('  Doctor: ' || v_rec.doctor_name);
        DBMS_OUTPUT.PUT_LINE('  Diagnosis: ' || NVL(v_rec.diagnosis,'Not recorded'));
        FOR p_rec IN cur_presc_items(v_rec.visit_id) LOOP
            DBMS_OUTPUT.PUT_LINE(
                '    - ' || p_rec.medicine ||
                ' | Dosage: '     || NVL(p_rec.dosage,'N/A') ||
                ' | Days: '       || NVL(TO_CHAR(p_rec.duration_days),'N/A') ||
                ' | Qty Issued: ' || NVL(TO_CHAR(p_rec.quantity_issued),'Pending')
            );
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '======================================================');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No patient found with ID ' || p_patient_id);
END get_patient_history;
/

-- PROCEDURE 2: Dispense Prescription (transactional workflow)
CREATE OR REPLACE PROCEDURE dispense_prescription (
    p_prescription_id IN NUMBER,
    p_pharmacist_id   IN NUMBER
)
IS
    v_presc_status  VARCHAR2(15);
    v_visit_id      NUMBER;
    v_dispensary_id NUMBER;
    v_inv_id        NUMBER;
    v_stock_qty     NUMBER;
    v_needed_qty    NUMBER;
    v_txn_id        NUMBER;

    CURSOR cur_items IS
        SELECT pi.item_id, pi.medicine_id,
               NVL(pi.quantity_issued, pi.duration_days) AS needed
        FROM   Prescription_Items pi
        WHERE  pi.prescription_id = p_prescription_id
          AND  NVL(pi.quantity_issued, 0) = 0;
BEGIN
    SELECT status, visit_id INTO v_presc_status, v_visit_id
    FROM   Prescription WHERE prescription_id = p_prescription_id;

    IF v_presc_status IN ('DISPENSED','CANCELLED') THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: Prescription ' || p_prescription_id ||
                             ' is already ' || v_presc_status || '.');
        RETURN;
    END IF;

    SELECT dispensary_id INTO v_dispensary_id FROM Visit WHERE visit_id = v_visit_id;
    UPDATE Prescription SET pharmacist_id = p_pharmacist_id
    WHERE  prescription_id = p_prescription_id;

    FOR item IN cur_items LOOP
        v_needed_qty := NVL(item.needed, 1);

        BEGIN
            SELECT inventory_id, quantity INTO v_inv_id, v_stock_qty
            FROM   Medicine_Inventory
            WHERE  dispensary_id = v_dispensary_id
              AND  medicine_id   = item.medicine_id
              AND  expiry_date   > SYSDATE
              AND  quantity      > 0
            ORDER  BY expiry_date
            FETCH FIRST 1 ROWS ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('  SKIP – No stock for medicine_id ' || item.medicine_id);
                UPDATE Prescription SET status = 'PARTIAL'
                WHERE  prescription_id = p_prescription_id;
                CONTINUE;
        END;

        IF v_stock_qty < v_needed_qty THEN
            v_needed_qty := v_stock_qty;
        END IF;

        SELECT seq_txn.NEXTVAL INTO v_txn_id FROM DUAL;
        INSERT INTO Transaction_Log
            (txn_id, inventory_id, staff_id, txn_type, quantity, txn_date, ref_id, remarks)
        VALUES
            (v_txn_id, v_inv_id, p_pharmacist_id, 'ISSUE',
             v_needed_qty, SYSDATE, item.item_id,
             'Dispensed via dispense_prescription() – Presc#' || p_prescription_id);

        UPDATE Prescription_Items SET quantity_issued = v_needed_qty
        WHERE  item_id = item.item_id;

        DBMS_OUTPUT.PUT_LINE('  OK – Issued ' || v_needed_qty ||
                             ' units for medicine_id ' || item.medicine_id);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Prescription ' || p_prescription_id || ' processing complete.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Prescription ID ' || p_prescription_id || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
END dispense_prescription;
/

-- FUNCTION 1: Patient Age (derived attribute)
CREATE OR REPLACE FUNCTION fn_patient_age (p_patient_id IN NUMBER)
RETURN NUMBER
IS
    v_dob DATE;
BEGIN
    SELECT dob INTO v_dob FROM Patient WHERE patient_id = p_patient_id;
    RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, v_dob) / 12);
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
END fn_patient_age;
/

-- FUNCTION 2: Medicine Availability Check
CREATE OR REPLACE FUNCTION fn_is_medicine_available (
    p_dispensary_id IN NUMBER,
    p_medicine_id   IN NUMBER
)
RETURN NUMBER
IS
    v_total_qty NUMBER;
BEGIN
    SELECT NVL(SUM(quantity), 0) INTO v_total_qty
    FROM   Medicine_Inventory
    WHERE  dispensary_id = p_dispensary_id
      AND  medicine_id   = p_medicine_id
      AND  expiry_date   > SYSDATE;

    RETURN CASE WHEN v_total_qty > 0 THEN 1 ELSE 0 END;
EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END fn_is_medicine_available;
/


-- ================================================================
-- SECTION 4 : VIEWS (Essential only – max 4)
-- ================================================================

-- VIEW 1: Low stock alert (< 100 units, non-expired)
CREATE OR REPLACE VIEW v_low_stock AS
SELECT
    mi.inventory_id,
    d.name      AS dispensary_name,
    m.name      AS medicine_name,
    m.category,
    mi.batch_no,
    mi.quantity AS current_qty,
    mi.expiry_date,
    mi.location_shelf
FROM   Medicine_Inventory mi
JOIN   Medicine   m ON m.medicine_id   = mi.medicine_id
JOIN   Dispensary d ON d.dispensary_id = mi.dispensary_id
WHERE  mi.quantity    < 100
  AND  mi.expiry_date > SYSDATE
ORDER  BY mi.quantity;

-- VIEW 2: Medicines expiring within 60 days
CREATE OR REPLACE VIEW v_expiry_alerts AS
SELECT
    mi.inventory_id,
    d.name                             AS dispensary_name,
    m.name                             AS medicine_name,
    mi.batch_no,
    mi.quantity,
    mi.expiry_date,
    mi.expiry_date - TRUNC(SYSDATE)    AS days_to_expiry
FROM   Medicine_Inventory mi
JOIN   Medicine   m ON m.medicine_id   = mi.medicine_id
JOIN   Dispensary d ON d.dispensary_id = mi.dispensary_id
WHERE  mi.expiry_date BETWEEN SYSDATE AND ADD_MONTHS(SYSDATE, 2)
  AND  mi.quantity > 0
ORDER  BY mi.expiry_date;

-- VIEW 3: Patient prescription summary (multi-table reporting view)
CREATE OR REPLACE VIEW v_patient_prescription_summary AS
SELECT
    pr.prescription_id,
    p.patient_id,
    p.name                                       AS patient_name,
    FLOOR(MONTHS_BETWEEN(SYSDATE, p.dob) / 12)  AS patient_age,
    s.name                                       AS doctor_name,
    doc.specialization,
    d.name                                       AS dispensary_name,
    pr.prescribed_on,
    pr.dispensed_on,
    pr.status                                    AS prescription_status,
    COUNT(pi.item_id)                            AS total_medicines
FROM   Prescription      pr
JOIN   Visit             v   ON v.visit_id        = pr.visit_id
JOIN   Patient           p   ON p.patient_id      = v.patient_id
JOIN   Staff             s   ON s.staff_id        = pr.doctor_id
JOIN   Doctor            doc ON doc.staff_id      = pr.doctor_id
JOIN   Dispensary        d   ON d.dispensary_id   = v.dispensary_id
LEFT JOIN Prescription_Items pi ON pi.prescription_id = pr.prescription_id
GROUP  BY pr.prescription_id, p.patient_id, p.name, p.dob,
          s.name, doc.specialization, d.name,
          pr.prescribed_on, pr.dispensed_on, pr.status;

-- VIEW 4: Dispensary stock summary (per-entity aggregation)
CREATE OR REPLACE VIEW v_dispensary_stock_summary AS
SELECT
    d.dispensary_id,
    d.name                                        AS dispensary_name,
    d.tier,
    COUNT(mi.inventory_id)                        AS total_batches,
    SUM(mi.quantity)                              AS total_units,
    SUM(mi.quantity * m.unit_price)               AS stock_value_inr,
    COUNT(CASE WHEN mi.quantity < 100 THEN 1 END) AS low_stock_batches,
    COUNT(CASE WHEN mi.expiry_date < ADD_MONTHS(SYSDATE,2)
               AND  mi.quantity > 0 THEN 1 END)  AS expiring_soon_batches
FROM   Dispensary         d
LEFT JOIN Medicine_Inventory mi ON mi.dispensary_id = d.dispensary_id
LEFT JOIN Medicine           m  ON m.medicine_id    = mi.medicine_id
GROUP  BY d.dispensary_id, d.name, d.tier
ORDER  BY stock_value_inr DESC NULLS LAST;


-- ================================================================
-- SECTION 5 : INDEXES (Minimal, high-impact only)
-- ================================================================

CREATE INDEX idx_mi_disp_med  ON Medicine_Inventory(dispensary_id, medicine_id);
CREATE INDEX idx_mi_expiry    ON Medicine_Inventory(expiry_date);
CREATE INDEX idx_visit_patient ON Visit(patient_id);
CREATE INDEX idx_presc_status  ON Prescription(status);


-- ================================================================
-- SECTION 6 : REQUIRED QUERIES
-- ================================================================

-- Q1: JOIN — Prescription details with patient, doctor, dispensary
SELECT pr.prescription_id,
       p.name       AS patient_name,
       s.name       AS doctor_name,
       d.name       AS dispensary_name,
       pr.prescribed_on,
       pr.status
FROM   Prescription pr
JOIN   Visit        v  ON v.visit_id       = pr.visit_id
JOIN   Patient      p  ON p.patient_id     = v.patient_id
JOIN   Staff        s  ON s.staff_id       = pr.doctor_id
JOIN   Dispensary   d  ON d.dispensary_id  = v.dispensary_id
ORDER  BY pr.prescribed_on DESC;

-- Q2: Nested Subquery — Patients who have at least one PENDING prescription
SELECT p.patient_id, p.name, p.phone
FROM   Patient p
WHERE  p.patient_id IN (
    SELECT v.patient_id
    FROM   Visit v
    JOIN   Prescription pr ON pr.visit_id = v.visit_id
    WHERE  pr.status = 'PENDING'
);

-- Q3: Correlated Subquery — Medicines where stock at dispensary 1
--     is below their reorder level
SELECT m.medicine_id, m.name, m.category, m.reorder_level,
       (SELECT NVL(SUM(mi2.quantity),0)
        FROM   Medicine_Inventory mi2
        WHERE  mi2.medicine_id   = m.medicine_id
          AND  mi2.dispensary_id = 1
          AND  mi2.expiry_date   > SYSDATE) AS current_stock
FROM   Medicine m
WHERE  (SELECT NVL(SUM(mi3.quantity),0)
        FROM   Medicine_Inventory mi3
        WHERE  mi3.medicine_id   = m.medicine_id
          AND  mi3.dispensary_id = 1
          AND  mi3.expiry_date   > SYSDATE) < m.reorder_level;

-- Q4: GROUP BY + HAVING — Doctors with more than 3 visits
SELECT s.staff_id,
       s.name           AS doctor_name,
       doc.specialization,
       COUNT(v.visit_id) AS total_visits
FROM   Staff   s
JOIN   Doctor  doc ON doc.staff_id = s.staff_id
JOIN   Visit   v   ON v.staff_id   = s.staff_id
GROUP  BY s.staff_id, s.name, doc.specialization
HAVING COUNT(v.visit_id) > 3
ORDER  BY total_visits DESC;

-- Q5: View usage — Low stock medicines across all dispensaries
SELECT dispensary_name, medicine_name, batch_no,
       current_qty, expiry_date
FROM   v_low_stock;

-- Q6: View usage — Pending prescriptions (not yet dispensed)
SELECT prescription_id, patient_name, doctor_name,
       dispensary_name, prescribed_on
FROM   v_patient_prescription_summary
WHERE  prescription_status = 'PENDING'
ORDER  BY prescribed_on;

-- Q7: Function usage — Check medicine availability
SELECT m.medicine_id, m.name,
       fn_is_medicine_available(1, m.medicine_id) AS available_at_disp_1
FROM   Medicine m
ORDER  BY m.name;

-- Q8: Function usage — Patient ages
SELECT patient_id, name, fn_patient_age(patient_id) AS age
FROM   Patient
ORDER  BY age DESC;

-- Q9: View usage — Dispensary stock summary
SELECT dispensary_name, tier, total_batches, total_units,
       ROUND(stock_value_inr, 2) AS stock_value_inr,
       low_stock_batches, expiring_soon_batches
FROM   v_dispensary_stock_summary;

-- Q10: Transaction log — last 30 days (JOIN across 4 tables)
SELECT tl.txn_id,
       d.name  AS dispensary,
       m.name  AS medicine,
       tl.txn_type,
       tl.quantity,
       tl.txn_date,
       s.name  AS performed_by
FROM   Transaction_Log    tl
JOIN   Medicine_Inventory mi ON mi.inventory_id = tl.inventory_id
JOIN   Medicine           m  ON m.medicine_id   = mi.medicine_id
JOIN   Dispensary         d  ON d.dispensary_id = mi.dispensary_id
JOIN   Staff              s  ON s.staff_id      = tl.staff_id
WHERE  tl.txn_date >= SYSDATE - 30
ORDER  BY tl.txn_date DESC;


-- ================================================================
-- END OF SCRIPT
-- ================================================================
