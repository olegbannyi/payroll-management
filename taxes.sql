create function TaxOwed(income float)
returns  float
deterministic
begin
    declare tax float(10,2);
    if income <= 10000 then set tax = income * 0.1;
    elseif  income <= 44725 and income > 10000 then set tax = 1100 + (income - 11000) * 0.12;
        elseif income <= 95375 and income > 44725 then set tax =  5147 + (income - 44725) * 0.22;
        elseif income <= 182100 and income > 95375 then set tax =  16290 + (income - 95375) * 0.24;
        elseif income <= 231250 and income > 182100 then set tax =  37104 + (income - 182100) * 0.32;
        elseif income <= 578125 and income > 231250 then set tax =  52832 + (income - 231250) * 0.35;
        else set tax =  174238.25 + (income - 578125) * 0.37;
    end if;
    return tax;
end;

select  TaxOwed(137164.8) as 'Philip Wilson',
    TaxOwed(89231.9) as 'Daisy Diamond';
