-- ============================================================
--  HOSPITAL PATIENT ANALYTICS SYSTEM
--  Author : Maddisetty Bhagya Sri
--  Tools  : MySQL 8+ / PostgreSQL 14+
--  Purpose: End-to-end SQL project demonstrating schema design,
--           indexing, window functions, stored procedures, and
--           analytical reporting for a hospital database.
-- ============================================================


-- ─────────────────────────────────────────────
--  1. SCHEMA CREATION
-- ─────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- Departments
CREATE TABLE departments (
    dept_id      INT PRIMARY KEY AUTO_INCREMENT,
    dept_name    VARCHAR(100) NOT NULL,
    floor_no     INT,
    head_doctor  VARCHAR(100)
);

-- Doctors
CREATE TABLE doctors (
    doctor_id    INT PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    dept_id      INT,
    experience_yrs INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Patients
CREATE TABLE patients (
    patient_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(100) NOT NULL,
    age          INT,
    gender       ENUM('M','F','Other'),
    blood_group  VARCHAR(5),
    city         VARCHAR(80),
    registered_on DATE DEFAULT (CURRENT_DATE)
);

-- Admissions
CREATE TABLE admissions (
    admission_id  INT PRIMARY KEY AUTO_INCREMENT,
    patient_id    INT NOT NULL,
    doctor_id     INT NOT NULL,
    dept_id       INT NOT NULL,
    admit_date    DATE NOT NULL,
    discharge_date DATE,
    diagnosis     VARCHAR(200),
    bill_amount   DECIMAL(10,2),
    status        ENUM('Admitted','Discharged','Critical') DEFAULT 'Admitted',
    FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id)   REFERENCES doctors(doctor_id),
    FOREIGN KEY (dept_id)     REFERENCES departments(dept_id)
);

-- Medicines prescribed
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id    INT NOT NULL,
    medicine_name   VARCHAR(100),
    dosage          VARCHAR(50),
    duration_days   INT,
    FOREIGN KEY (admission_id) REFERENCES admissions(admission_id)
);


-- ─────────────────────────────────────────────
--  2. INDEXES FOR PERFORMANCE
-- ─────────────────────────────────────────────

-- Speed up patient lookups by city and blood group
CREATE INDEX idx_patient_city       ON patients(city);
CREATE INDEX idx_patient_blood      ON patients(blood_group);

-- Speed up admission queries by date range and status
CREATE INDEX idx_admit_date         ON admissions(admit_date);
CREATE INDEX idx_admit_status       ON admissions(status);

-- Composite index: doctor + admission date (common filter combo)
CREATE INDEX idx_doctor_admit       ON admissions(doctor_id, admit_date);


-- ─────────────────────────────────────────────
--  3. SAMPLE DATA
-- ─────────────────────────────────────────────

INSERT INTO departments (dept_name, floor_no, head_doctor) VALUES
('Cardiology',    2, 'Dr. Ramesh Iyer'),
('Neurology',     3, 'Dr. Priya Nair'),
('Oncology',      4, 'Dr. Suresh Menon'),
('Orthopedics',   1, 'Dr. Kavitha Rao'),
('General Medicine', 1, 'Dr. Anil Kumar');

INSERT INTO doctors (full_name, specialization, dept_id, experience_yrs) VALUES
('Dr. Ramesh Iyer',    'Cardiologist',      1, 18),
('Dr. Sita Devi',      'Cardiac Surgeon',   1, 12),
('Dr. Priya Nair',     'Neurologist',       2, 15),
('Dr. Kiran Babu',     'Neurosurgeon',      2,  9),
('Dr. Suresh Menon',   'Oncologist',        3, 20),
('Dr. Kavitha Rao',    'Orthopedic',        4, 11),
('Dr. Anil Kumar',     'General Physician', 5,  7),
('Dr. Meena Sharma',   'General Physician', 5,  5);

INSERT INTO patients (full_name, age, gender, blood_group, city, registered_on) VALUES
('Rajesh Verma',    45, 'M', 'O+',  'Hyderabad',  '2024-01-10'),
('Sunita Patel',    38, 'F', 'A+',  'Bangalore',  '2024-02-14'),
('Mohan Das',       62, 'M', 'B+',  'Chennai',    '2024-03-05'),
('Lakshmi Reddy',   29, 'F', 'AB+', 'Hyderabad',  '2024-03-20'),
('Arjun Singh',     55, 'M', 'O-',  'Delhi',      '2024-04-01'),
('Deepa Krishnan',  41, 'F', 'A-',  'Bangalore',  '2024-04-18'),
('Venkat Raju',     70, 'M', 'B-',  'Tirupati',   '2024-05-02'),
('Ananya Rao',      33, 'F', 'O+',  'Pune',       '2024-05-15'),
('Harish Nair',     48, 'M', 'A+',  'Kochi',      '2024-06-01'),
('Pooja Mehta',     27, 'F', 'AB-', 'Mumbai',     '2024-06-20');

INSERT INTO admissions (patient_id, doctor_id, dept_id, admit_date, discharge_date, diagnosis, bill_amount, status) VALUES
(1,  1, 1, '2024-01-15', '2024-01-22', 'Hypertension',          45000.00, 'Discharged'),
(2,  3, 2, '2024-02-20', '2024-03-01', 'Migraine',              38000.00, 'Discharged'),
(3,  5, 3, '2024-03-10', NULL,         'Lung Cancer Stage 2',   92000.00, 'Admitted'),
(4,  7, 5, '2024-03-25', '2024-03-28', 'Viral Fever',           12000.00, 'Discharged'),
(5,  2, 1, '2024-04-05', '2024-04-15', 'Coronary Artery Disease',78000.00,'Discharged'),
(6,  6, 4, '2024-04-20', '2024-05-02', 'Fracture - Left Femur', 55000.00, 'Discharged'),
(7,  1, 1, '2024-05-05', NULL,         'Heart Failure',         110000.00,'Critical'),
(8,  4, 2, '2024-05-18', '2024-05-25', 'Epilepsy',              47000.00, 'Discharged'),
(9,  5, 3, '2024-06-03', NULL,         'Colon Cancer Stage 1',  85000.00, 'Admitted'),
(10, 8, 5, '2024-06-22', '2024-06-24', 'Food Poisoning',         8500.00, 'Discharged'),
(1,  2, 1, '2024-07-10', '2024-07-18', 'Arrhythmia',            52000.00, 'Discharged'),
(3,  5, 3, '2024-08-01', NULL,         'Chemotherapy Cycle 2',  63000.00, 'Admitted');

INSERT INTO prescriptions (admission_id, medicine_name, dosage, duration_days) VALUES
(1,  'Amlodipine',    '5mg once daily',   30),
(1,  'Atorvastatin',  '10mg at night',    90),
(2,  'Sumatriptan',   '50mg as needed',   14),
(3,  'Carboplatin',   'IV per protocol',  21),
(4,  'Paracetamol',   '500mg TID',         5),
(5,  'Aspirin',       '75mg once daily',  60),
(6,  'Ibuprofen',     '400mg TID',        10),
(7,  'Digoxin',       '0.25mg once daily',30),
(7,  'Furosemide',    '40mg BD',          30),
(8,  'Levetiracetam', '500mg BD',        180),
(9,  'Oxaliplatin',   'IV per protocol',  21),
(10, 'ORS',           'As required',       3);


-- ─────────────────────────────────────────────
--  4. ANALYTICAL QUERIES
-- ─────────────────────────────────────────────

-- Q1: Total revenue and patient count per department
SELECT
    d.dept_name,
    COUNT(a.admission_id)          AS total_admissions,
    COUNT(DISTINCT a.patient_id)   AS unique_patients,
    SUM(a.bill_amount)             AS total_revenue,
    ROUND(AVG(a.bill_amount), 2)   AS avg_bill
FROM admissions a
JOIN departments d ON a.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total_revenue DESC;


-- Q2: Window function — rank doctors by revenue generated
SELECT
    doc.full_name,
    d.dept_name,
    SUM(a.bill_amount)  AS revenue_generated,
    RANK() OVER (
        PARTITION BY d.dept_name
        ORDER BY SUM(a.bill_amount) DESC
    ) AS rank_in_dept,
    RANK() OVER (
        ORDER BY SUM(a.bill_amount) DESC
    ) AS overall_rank
FROM admissions a
JOIN doctors     doc ON a.doctor_id = doc.doctor_id
JOIN departments d   ON a.dept_id   = d.dept_id
GROUP BY doc.full_name, d.dept_name;


-- Q3: Window function — running total of monthly revenue
SELECT
    DATE_FORMAT(admit_date, '%Y-%m')      AS month,
    SUM(bill_amount)                       AS monthly_revenue,
    SUM(SUM(bill_amount)) OVER (
        ORDER BY DATE_FORMAT(admit_date, '%Y-%m')
    )                                      AS running_total
FROM admissions
GROUP BY month
ORDER BY month;


-- Q4: Average length of stay per department (in days)
SELECT
    d.dept_name,
    ROUND(AVG(DATEDIFF(
        COALESCE(a.discharge_date, CURRENT_DATE), a.admit_date
    )), 1) AS avg_stay_days
FROM admissions a
JOIN departments d ON a.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY avg_stay_days DESC;


-- Q5: Patients with multiple admissions (repeat patients)
SELECT
    p.full_name,
    p.city,
    COUNT(a.admission_id)   AS total_visits,
    SUM(a.bill_amount)      AS lifetime_bill
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.full_name, p.city
HAVING COUNT(a.admission_id) > 1
ORDER BY total_visits DESC;


-- Q6: Subquery — patients billed above department average
SELECT
    p.full_name,
    d.dept_name,
    a.bill_amount,
    a.diagnosis
FROM admissions a
JOIN patients    p ON a.patient_id = p.patient_id
JOIN departments d ON a.dept_id   = d.dept_id
WHERE a.bill_amount > (
    SELECT AVG(a2.bill_amount)
    FROM admissions a2
    WHERE a2.dept_id = a.dept_id
)
ORDER BY d.dept_name, a.bill_amount DESC;


-- Q7: CTE — find currently admitted critical/long-stay patients
WITH active_admissions AS (
    SELECT
        a.admission_id,
        p.full_name,
        p.age,
        d.dept_name,
        doc.full_name          AS doctor,
        a.admit_date,
        a.status,
        DATEDIFF(CURRENT_DATE, a.admit_date) AS days_admitted,
        a.bill_amount
    FROM admissions a
    JOIN patients    p   ON a.patient_id = p.patient_id
    JOIN departments d   ON a.dept_id    = d.dept_id
    JOIN doctors     doc ON a.doctor_id  = doc.doctor_id
    WHERE a.discharge_date IS NULL
)
SELECT * FROM active_admissions
ORDER BY days_admitted DESC;


-- Q8: Prescription load per doctor (medicines per patient)
SELECT
    doc.full_name                          AS doctor,
    COUNT(DISTINCT a.patient_id)           AS patients_treated,
    COUNT(pr.prescription_id)              AS total_medicines_prescribed,
    ROUND(COUNT(pr.prescription_id) /
          NULLIF(COUNT(DISTINCT a.patient_id), 0), 1) AS medicines_per_patient
FROM doctors doc
JOIN admissions     a  ON doc.doctor_id    = a.doctor_id
JOIN prescriptions  pr ON a.admission_id   = pr.admission_id
GROUP BY doc.full_name
ORDER BY medicines_per_patient DESC;


-- ─────────────────────────────────────────────
--  5. STORED PROCEDURE
--     Get full patient report by patient_id
-- ─────────────────────────────────────────────

DELIMITER $$

CREATE PROCEDURE GetPatientReport(IN p_id INT)
BEGIN
    -- Basic patient info
    SELECT
        p.patient_id,
        p.full_name,
        p.age,
        p.gender,
        p.blood_group,
        p.city,
        p.registered_on
    FROM patients p
    WHERE p.patient_id = p_id;

    -- All admissions with doctor and dept
    SELECT
        a.admission_id,
        a.admit_date,
        a.discharge_date,
        a.diagnosis,
        a.status,
        a.bill_amount,
        doc.full_name  AS doctor,
        d.dept_name
    FROM admissions a
    JOIN doctors     doc ON a.doctor_id = doc.doctor_id
    JOIN departments d   ON a.dept_id   = d.dept_id
    WHERE a.patient_id = p_id
    ORDER BY a.admit_date DESC;

    -- Prescriptions across all admissions
    SELECT
        pr.medicine_name,
        pr.dosage,
        pr.duration_days,
        a.admit_date
    FROM prescriptions pr
    JOIN admissions a ON pr.admission_id = a.admission_id
    WHERE a.patient_id = p_id
    ORDER BY a.admit_date DESC;

    -- Summary stats
    SELECT
        COUNT(a.admission_id)    AS total_visits,
        SUM(a.bill_amount)       AS total_spent,
        ROUND(AVG(a.bill_amount),2) AS avg_bill_per_visit
    FROM admissions a
    WHERE a.patient_id = p_id;
END$$

DELIMITER ;

-- Usage: CALL GetPatientReport(1);


-- ─────────────────────────────────────────────
--  6. VIEW — Dashboard summary
-- ─────────────────────────────────────────────

CREATE OR REPLACE VIEW vw_hospital_dashboard AS
SELECT
    d.dept_name,
    COUNT(a.admission_id)                              AS total_admissions,
    SUM(CASE WHEN a.status = 'Admitted'   THEN 1 ELSE 0 END) AS currently_admitted,
    SUM(CASE WHEN a.status = 'Critical'   THEN 1 ELSE 0 END) AS critical_patients,
    SUM(CASE WHEN a.status = 'Discharged' THEN 1 ELSE 0 END) AS discharged,
    ROUND(SUM(a.bill_amount), 2)                       AS total_revenue,
    ROUND(AVG(DATEDIFF(
        COALESCE(a.discharge_date, CURRENT_DATE), a.admit_date
    )), 1)                                             AS avg_stay_days
FROM admissions a
JOIN departments d ON a.dept_id = d.dept_id
GROUP BY d.dept_name;

-- Usage: SELECT * FROM vw_hospital_dashboard;
