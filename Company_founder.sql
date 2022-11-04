select c.company_code, founder, 
count(distinct lead_manager_code), 
count(distinct senior_manager_code), 
count(distinct Manager_code), 
count(distinct employee_code) 
from company as c inner join employee as e on c.company_code = e.company_code 
group by c.company_code,founder 
order by c.company_code
