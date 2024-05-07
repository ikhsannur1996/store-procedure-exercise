CREATE OR REPLACE PROCEDURE dwh.generate_employee()
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Step 1: Truncate and Insert into stg
    -- Description: Clear the staging table and populate it with data from the source table.
    CREATE TABLE IF NOT EXISTS stg.stg_employee_transaction AS SELECT *, CURRENT_TIMESTAMP AS last_update FROM public.employee_transaction;
    TRUNCATE TABLE stg.stg_employee_transaction;
    INSERT INTO stg.stg_employee_transaction 
    SELECT *, CURRENT_TIMESTAMP AS last_update FROM public.employee_transaction;
 
    -- Step 2: Insert or update into dim_department
    -- Description: Insert new department data into the department dimension if they don't already exist.
    --              Update existing department data if they already exist.
    CREATE TABLE IF NOT EXISTS dwh.dim_department AS SELECT DISTINCT src.department_id, src.department_name, CURRENT_TIMESTAMP AS last_update
    FROM stg.stg_employee_transaction AS src;
    
    TRUNCATE TABLE dwh.dim_department;
   
    INSERT INTO dwh.dim_department (department_id, department_name, last_update)
    SELECT DISTINCT src.department_id, src.department_name, CURRENT_TIMESTAMP AS last_update
    FROM stg.stg_employee_transaction AS src;
    
    -- Step 3: Insert or update into dim_education
    -- Description: Insert new education data into the education dimension if they don't already exist.
    --              Update existing education data if they already exist.
    CREATE TABLE IF NOT EXISTS dwh.dim_education AS SELECT DISTINCT src.education_id, src.education_level, CURRENT_TIMESTAMP AS last_update
    FROM stg.stg_employee_transaction AS src;
    
    TRUNCATE TABLE dwh.dim_education;
    
    INSERT INTO dwh.dim_education (education_id, education_level, last_update)
    SELECT DISTINCT src.education_id, src.education_level, CURRENT_TIMESTAMP AS last_update
    FROM stg.stg_employee_transaction AS src;
    
    -- Step 4: Insert or update into dim_employee
    -- Description: Insert new employee data into the employee dimension if they don't already exist.
    --              Update existing employee data if they already exist.
    CREATE TABLE IF NOT EXISTS dwh.dim_employee AS
    SELECT DISTINCT src.employee_id, src.first_name, src.last_name, src.birt_date, src.hire_date, src.gender, src.department_id, src.education_id, CURRENT_TIMESTAMP AS last_update
    FROM stg.stg_employee_transaction AS src;
    
    TRUNCATE TABLE dwh.dim_employee;
    
    INSERT INTO dwh.dim_employee (employee_id, first_name, last_name, birt_date, hire_date, gender, department_id, education_id, last_update)
    SELECT DISTINCT src.employee_id, src.first_name, src.last_name, src.birt_date, src.hire_date, src.gender, src.department_id, src.education_id, CURRENT_TIMESTAMP AS last_update
    FROM stg.stg_employee_transaction AS src;
    

    -- Step 5: Insert into fact_employee_performance
    -- Description: Insert new performance data into the fact table if they don't already exist.
    CREATE TABLE IF NOT EXISTS dwh.fact_employee_performance (
    performance_id INT PRIMARY KEY,
    employee_id INT,
    performance_score FLOAT,
    performance_date DATE,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
    
   
    INSERT INTO dwh.fact_employee_performance
        (performance_id, employee_id, performance_score, performance_date, last_update)
    SELECT
        src.performance_id, src.employee_id, src.performance_score, src.performance_date, CURRENT_TIMESTAMP AS last_update
    FROM
        stg.stg_employee_transaction AS src 
    WHERE NOT EXISTS (
        SELECT 1
        FROM fact_employee_performance AS fact
        WHERE 
            COALESCE(fact.performance_id, 0) = COALESCE(src.performance_id, 0) AND
            COALESCE(fact.employee_id, 0) = COALESCE(src.employee_id, 0) AND
            COALESCE(fact.performance_score, 0) = COALESCE(src.performance_score, 0) AND
            COALESCE(fact.performance_date, CURRENT_DATE) = COALESCE(src.performance_date, CURRENT_DATE)
    );

    -- Step 6: Truncate and Insert into dm_employee_transaction
    -- Description: Populate the data mart with the latest employee transactions.
    CREATE OR REPLACE VIEW dm.vw_dm_employee_transaction AS SELECT 
        f.performance_id,
        f.employee_id,
        f.performance_score,
        f.performance_date,
        e.first_name,
        e.last_name,
        e.birt_date,
        e.hire_date,
        e.gender,
        e.department_id,
        d.department_name,
        e.education_id,
        ed.education_level,
        f.last_update 
    FROM 
        fact_employee_performance f
    LEFT JOIN 
        dim_employee e ON f.employee_id = e.employee_id
    LEFT JOIN 
        dim_department d ON e.department_id = d.department_id
    LEFT JOIN 
        dim_education ed ON e.education_id = ed.education_id;
    
    CREATE TABLE IF NOT EXISTS dm.dm_employee_transaction AS
    SELECT * 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER (PARTITION BY performance_id ORDER BY last_update DESC) AS flag_unique
        FROM dm.vw_dm_employee_transaction
    ) AS ranked_data
    WHERE flag_unique = 1;
    
    TRUNCATE TABLE dm.dm_employee_transaction;

    INSERT INTO dm.dm_employee_transaction 
    SELECT * 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER (PARTITION BY performance_id ORDER BY last_update DESC) AS flag_unique
        FROM dm.vw_dm_employee_transaction
    ) AS ranked_data
    WHERE flag_unique = 1;

END;
$procedure$;
