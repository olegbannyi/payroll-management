create procedure EmployeeTotalPay(
    in first_name varchar(45),
    in last_name varchar(45),
    in total_hours int,
    in normal_hours int,
    in overtime_rate float(3.2),
    in max_overtime_pay float(10,2),
    out total_pay float(10,2)
)
begin
    declare job_type varchar(45);
    declare job_hourly_rate float(5,2);
    declare overtime_hours int;
    declare overtime_pay float(10,2);

    select type, hourly_rate into job_type, job_hourly_rate 
        from jobs
        join employees on jobs.id = employees.job_id
        where employees.first_name = first_name and employees.last_name = last_name;

    if job_type = 'Part Time' then
        set total_pay = total_hours * job_hourly_rate;
    else
        set overtime_hours = if(total_hours > normal_hours, total_hours - normal_hours, 0);
        set total_hours = if(total_hours > normal_hours, normal_hours, total_hours); 
        set overtime_pay = overtime_hours * job_hourly_rate * overtime_rate;
        set overtime_pay = if(overtime_pay > max_overtime_pay, max_overtime_pay, overtime_pay);
        set total_pay = (total_hours * job_hourly_rate) + overtime_pay;
    end if;
end;

set @filip_total_pay = 0.0;
set @deisy_total_pay = 0.0;

call  EmployeeTotalPay('Philip', 'Wilson', 2160, 260*8, 1.5, 6000.0, @filip_total_pay);
call  EmployeeTotalPay('Daisy', 'Diamond', 2100, 260*8, 1.5, 6000.0, @deisy_total_pay);

select round(@filip_total_pay, 2) as 'Philip Wilson', round(@deisy_total_pay, 2) as 'Daisy Diamond';
select * from jobs where id in (60, 110);
