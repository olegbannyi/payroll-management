CREATE TABLE IF NoT exists EmployeesHRS (
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    hours_worked INT
);

INSERT INTO EmployeesHRS (first_name, last_name, hours_worked)
VALUES 
('Dixie', 'Herda', 2095),
('Stephen', 'West', 2091),
('Philip', 'Wilson', 2160),
('Robin', 'Walker', 2083),
('Antoinette', 'Matava', 2115),
('Courtney', 'Walker', 2206),
('Gladys', 'Bosch', 900);

DELIMITER //
CREATE FUNCTION GetPay(
        first_name VARCHAR(45), 
        last_name VARCHAR(45), 
        hours_worked INT,
        param VARCHAR(20)) 
    RETURNS float(10,2)
BEGIN
    DECLARE normal_pay decimal(10,2);
    DECLARE overtime_pay decimal(10,2);
    DECLARE total_pay decimal(10,2);
    
    CALL EmployeeTotalPay(first_name, last_name, hours_worked, 2080, 1.5, 6000, normal_pay, overtime_pay, total_pay);
    
    CASE param
        WHEN 'normal_pay' THEN
            RETURN normal_pay;
        WHEN 'overtime_pay' THEN
            RETURN overtime_pay;
        WHEN 'total_pay' THEN
            RETURN total_pay;
        ELSE
            RETURN 0.0;
    END CASE;
END //
DELIMITER ;

CREATE FUNCTION TaxOwed(taxable_income FLOAT(10,1)) RETURNS FLOAT(10,1)
BEGIN
    DECLARE tax_owed FLOAT(10,1);

    IF taxable_income <= 11000 THEN
        SET tax_owed = taxable_income * 0.10;
    ELSEIF taxable_income <= 44725 THEN
        SET tax_owed = 1100 + (taxable_income - 11000) * 0.12;
    ELSEIF taxable_income <= 95375 THEN
        SET tax_owed = 5147 + (taxable_income - 44725) * 0.22;
    ELSEIF taxable_income <= 182100 THEN
        SET tax_owed = 16290 + (taxable_income - 95375) * 0.24;
    ELSEIF taxable_income <= 231250 THEN
        SET tax_owed = 37104 + (taxable_income - 182100) * 0.32;
    ELSEIF taxable_income <= 578125 THEN
        SET tax_owed = 52832 + (taxable_income - 231250) * 0.35;
    ELSE
        SET tax_owed = 174238.25 + (taxable_income - 578125) * 0.37;
    END IF;

    RETURN tax_owed;
END;


DELIMITER //
CREATE PROCEDURE EmployeeTotalPay(
    IN first_name VARCHAR(45), 
    IN last_name VARCHAR(45), 
    IN total_hours INT, 
    IN normal_hours INT, 
    IN overtime_rate decimal(5,2), 
    IN max_overtime_pay decimal(10,2), 
    OUT normal_pay decimal(10,2),
    OUT overtime_pay decimal(10,2),
    OUT total_pay decimal(10,2)
        )
BEGIN
    DECLARE hourly_rate decimal(10,2);
    DECLARE over_time_hours INT;
    
    SELECT j.hourly_rate INTO hourly_rate
    FROM employees e
    JOIN jobs j ON e.job_id = j.id
    WHERE e.first_name = first_name AND e.last_name = last_name;

    SET over_time_hours = GREATEST(total_hours - normal_hours,0);
    SET normal_pay = normal_hours * hourly_rate;
    SET overtime_pay = LEAST(over_time_hours * hourly_rate * overtime_rate, max_overtime_pay);
    SET total_pay = normal_pay + overtime_pay;
END //
DELIMITER ;

  
DELIMITER //
CREATE PROCEDURE PayrollReport(IN dept_name VARCHAR(45))
    BEGIN
    SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_names, 
        GetPay(e.first_name, e.last_name, h.hours_worked, 'normal_pay') AS base_pay, 
        GetPay(e.first_name, e.last_name, h.hours_worked, 'overtime_pay') AS overtime_pay, 
        GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay') AS total_pay,
        TaxOwed(GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay')) AS tax_owed,
        GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay') - TaxOwed(GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay')) AS net_income
     FROM employees e
        JOIN departments d ON e.department_id = d.id
        JOIN EmployeesHRS h ON e.first_name = h.first_name AND e.last_name = h.last_name
     WHERE d.name = dept_name
     ORDER BY net_income DESC;
    END //
DELIMITER ;

CALL PayrollReport("City Ethics Commission");
