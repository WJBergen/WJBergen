---
---Show the count of people in each department, division, section, location and center
---
select
	count(department) as dept_count
	, department
	, division
	, sectn
	, locatn
	, center_number
from heat5.heat5.profile
where custtype = 'internal'
group by 
	department
	, division
	, sectn
	, locatn
	, center_number
order by
	department
	, division
	, sectn
	, locatn
	, center_number
---
---Now show the total number of people from the above query 
---
select
	count(department) as dept_count
	, department
	, division
	, sectn
	, locatn
	, center_number
into	#hold1
from heat5.heat5.profile
where custtype = 'internal'
group by 
	department
	, division
	, sectn
	, locatn
	, center_number
order by
	department
	, division
	, sectn
	, locatn
	, center_number
---
---
---
select sum(dept_count) as Total_Number_of_Employees from #hold1
---
---
---
drop table #hold1
---
---
---
---
---Show the count of people in each department, division, section, location and center but 
---make each row a person and show the employee W id
---change made 12/14/2004
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---Rob wants this data sent to him so he can load it into a spreadsheet.  Because the heat
---column called user_id sometimes has a comma in it IT IS IMPERATIVE THAT THIS QUERY BE 
---RUN IN THE RESULTS TO GRID MODE FOR OUTPUT AND THEN THIS OUTPUT MUST BE SAVED IN 
---TAB DELIMITED FORMAT  <<<<<NOT>>>>> CSV FORMAT 
---
select	distinct
	count(department) as department_count
	, department
	, division
	, sectn
	, locatn
	, center_number
	, User_id
from heat5.heat5.profile
where custtype = 'internal'
group by 
	department
	, division
	, sectn
	, locatn
	, center_number
	, user_id
order by
	department
	, division
	, sectn
	, locatn
	, center_number
	, user_id




