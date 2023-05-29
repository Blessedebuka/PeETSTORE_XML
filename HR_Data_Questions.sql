create database project;
USE PROJECT;
select * FROM HR;
-- QUESTIONS FROM THE DATASET--
-- 1. WHAT IS THE GENDER BREAKDOWN OF THE EMPLOYEES IN THE COMPANY?
select gender, count(*) as gender_count from hr 
where age >=18 and termdate = '0000-00-00'
group by gender;
-- 2. WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY?
select race, count(*) as race_count from hr 
where age >=18 and termdate = '0000-00-00'
group by race
order by count(*) desc;
-- 3. WHAT IS THE AGE DISTRIBUTION OF THE EMPLOYEES IN THE COMPANY?
select min(age) as youngest, 
max(age) as oldest from hr 
where age>=18 and termdate = '0000-00-00';
select
case
when age >=18 and age <=24 then '18-24'
when age >=25 and age <=34 then '25-34'
when age >=35 and age <=44 then '35-44'
when age >=45 and age <=54 then '45-54'
when age >=55 and age <=64 then '55-64'
else '65+'
end as age_group, count(*) as count
from hr
where age>=18 and termdate = '0000-00-00'
group by age_group
order by age_group;
-- 4. WHAT IS THE AGE DISTRIBUTION OF THE EMPLOYEES IN THE COMPANY by gender?
select
case
when age >=18 and age <=24 then '18-24'
when age >=25 and age <=34 then '25-34'
when age >=35 and age <=44 then '35-44'
when age >=45 and age <=54 then '45-54'
when age >=55 and age <=64 then '55-64'
else '65+'
end as age_group, gender, count(*) as count
from hr
where age>=18 and termdate = '0000-00-00'
group by age_group,gender
order by age_group, gender;
-- 5. HOW MANY EMPLOYEES WORK AT HEADQUARTERS VS REMOTE LOCATIONS?
select location, count(*) from hr 
where age>=18 and termdate = '0000-00-00'
group by location;
-- 6. WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT FOR EMPLOYEES WHO HAVE BEEN TERMINATED?
select 
round(avg(datediff(termdate, hire_date)) /365,1) as avg_length_of_employment
from hr 
where termdate <= curdate() and age >= 18 and termdate <> '0000-00-00';
-- 7. HOW DOES THE GENDER DISTRIBUTION VARY ACROSS DEPARTMENTS AND JOB TITLES?
select department, gender, count(*) as count from hr 
where age>=18 and termdate = '0000-00-00'
group by department, gender 
order by department;
 -- 8. WHAT IS THE DISTRIBUTION OF JOB TITLES ACROSS THE COMPANY?
 select jobtitle, count(*) as count from hr
 where age>=18 and termdate = '0000-00-00'
 group by jobtitle order by jobtitle desc;
 -- 9. WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?
 SELECT department, total_count,terminated_count,
 terminated_count/total_count as termination_rate
 from (select department, count(*) as total_count,
 sum(case when termdate <> '0000-00-00' and termdate <=curdate() then 1 else 0 end)
 as terminated_count FROM HR where age>=18
 group by department) as subquery order by termination_rate desc;
 -- 10. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATIONS BY CITY AND STATE?
select location_state, count(*) as count from hr
where age>=18 and termdate = '0000-00-00'
group by location_state order by count desc;
-- 11. HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERM DATE?
select year, hires, terminations, hires - terminations as net_change,
round((hires - terminations)/hires * 100,2) as net_change_percent from
(select year(hire_date) as year, count(*) as hires,
sum(case when termdate <> '0000-00-00' 
and termdate <= curdate() then 1 else 0 end) as terminations
from hr where age >=18
group by year(hire_date)) as sub_query
order by year asc;
-- 12. WHAT IS THE TENURE DISTRUBUTION FOR EACH DEPARTMENT?
select department, round(avg(datediff(termdate, hire_date)/365),0)
as avg_tenure from hr 
where termdate <= curdate() and termdate <> '0000-00-00' and age >=18
group by department;