create database  projectos;
use projectos;
create table if not exists Departments;
create table Departments (dept_id int, dept_name varchar (20));
insert into Departments (dept_id, dept_name) values (1, 'Sales');
insert into Departments (dept_id, dept_name) values (2, 'IT');
insert into Departments (dept_id, dept_name) values (3, 'Finance');
select * from Departments;
create table Chicason_management (emp_id int, Last_Name varchar (30), First_Name varchar (30),
 Gender varchar (15), Position varchar (30),dept_id int, Salary int, Hire_date date);
select * from Chicason_management;
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (100, 'Mark', 'Angela', 'Female', 'Salary Officer', 3, 500000, '11/12/2020');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (101, 'Ike', 'Basil', 'Male', 'Financial Advisor', 3, 560000, '4/11/2019');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (102, 'Onwe', 'Kampala', 'Female', 'Procurement Officer', 3, 450000, '9/10/2020');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (103, 'Bassey', 'Akpan', 'Male', 'Sales Engineer', 1, 470000, '3/7/2017');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (104, 'Ben', 'Sandra', 'Female', 'Sales Marketer', 1, 475000, '12/7/2018');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (105, 'Yahaya', 'Amad', 'Male', 'Software Engineer', 2, 870000, '30/10/2016');
insert into Chicason_management(emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (106, 'Israel', 'Anayo', 'Male', 'Developer', 2, 845000, '20/10/2020');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (107, 'Eke', 'Faith', 'Female', 'Sales Representative', 1, 490000, '30/11/2015');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (108, 'Daniel', 'Ifeoma', 'Female', 'Sales Representative', 1, 500000, '8/11/2015');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (109, 'Madu', 'Obika', 'Male', 'Data Analyst', 2, 600000, '9/11/2022');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (110, 'Hana', 'Manu', 'Male', 'Tecnician', 2, 490000, '30/11/2015');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (111, 'Onyeka', 'Gladys', 'Female', 'Marketer', 1, 380000, '30/11/2018');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (112, 'Gana', 'Aisha', 'Female', 'Database Manager', 2, 510000, '8/11/2021');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (113, 'Habib', 'Audu', 'Male', 'Network Manager', 2, 670000, '24/11/2022');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (114, 'Benjamin', 'Agnes', 'Female', 'IT Maintenance Engineer', 2, 644500, '24/11/2022');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (115, 'Amadi', 'Idris', 'Male', 'IT Instructor', 2, 670000, '24/11/2022');
insert into Chicason_management (emp_id, Last_Name, First_Name, Gender, Position, dept_id, Salary, Hire_date)
values (116, 'Amos', 'Ifeoma', 'Female', 'Sales Analyst', 1, 486000, '24/1/2023');
describe Chicason_management;
select * from Chicason_management;
select * from departments;
# 1. A query that displays the maximum salary from each department:
select c.position, d.dept_name, max(salary) as max_salary from Chicason_management c inner join Departments d on c.dept_id=d.dept_id group by dept_name;
# 2. A query that displays the maximum salary
select * from Chicason_management where salary = (select max(salary) from Chicason_management);
# 3. A query that displays the 8th highest salary
select salary from Chicason_management c1 where 7 =(select count(distinct salary)
 from Chicason_management c2 where c2.salary > c1.salary);
# 4. A query that displays the running total salary by department.
select *, sum(salary) over (partition by dept_name order by salary desc) as Salary_by_dept 
from chicason_management c inner join  departments d on c.dept_id=d.dept_id;
-- 5. A query that displays the sum and average of salary by department--
select dept_name, sum(salary) as Total_sum,avg(salary) as Avg_salary from chicason_management c
 inner join departments d on c.dept_id=d.dept_id group by dept_name;
 -- 6. A query that increments the salary of employees with more than five years stay in the company by 10%
   select *, (salary +(salary*10/100)) as Incremented_Salary,
   timestampdiff(year,hire_date,current_timestamp)
   as Years_Spent from Chicason_management c
  inner join departments d on c.dept_id=d.dept_id
  where timestampdiff(year,hire_date,current_timestamp)>=5;
