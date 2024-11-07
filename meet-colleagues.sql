create procedure GetEmployeesByDept (in department varchar(45))
begin
    select e.first_name, e.last_name, j.title as job_title
    from employees e
    join  jobs j on e.job_id = j.id
    join  departments d on e.department_id = d.id
    where  d.name = department
    order by e.first_name;
end;

call GetEmployeesByDept("Office of Finance");
