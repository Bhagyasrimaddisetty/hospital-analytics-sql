# Hospital Patient Analytics System
A relational database project built with MySQL demonstrating production-level SQL skills including schema design, indexing strategy, window functions, CTEs, stored procedures, and dashboard views.
## Tech Stack
- MySQL 8+ / PostgreSQL 14+
## Database Schema
5 normalized tables: Departments, Doctors, Patients, Admissions, Prescriptions
- Foreign key constraints across all tables
- 6 strategic indexes (composite + single-column) for query optimization
## Features
- Window Functions: RANK() OVER PARTITION BY for doctor revenue ranking; running monthly totals with SUM() OVER
- CTEs: Active patient dashboard with real-time stay duration
- Subqueries: Patients billed above department average
- Stored Procedure: GetPatientReport() returns full patient history, admissions, prescriptions, and billing summary
- Dashboard VIEW: vw_hospital_dashboard for department-level KPIs
- Analytical Queries: Revenue per department, average stay, repeat patients, prescription load per doctor
## How to Run
1. Open MySQL Workbench or any MySQL client
2. Run: source hospital_analytics.sql
3. Try: CALL GetPatientReport(1);
4. Try: SELECT * FROM vw_hospital_dashboard;
## Sample Insights Generated
- Department-wise revenue and average billing
- Doctor performance ranking within and across departments
- Running total of monthly hospital revenue
- Currently admitted and critical patient report
- Repeat patient lifetime billing analysis
## Author
Maddisetty Bhagya Sri | github.com/Bhagyasrimaddisetty
