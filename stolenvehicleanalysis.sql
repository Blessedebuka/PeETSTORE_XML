select * FROM make_details;
SELECT * FROM locations;
SELECT * FROM stolen_vehicles;
ALTER TABLE stolen_vehicles rename column ï»¿vehicle_id to vehicle_id;
-- ----- OBJECTIVE 1------
-- Q1. FIND THE NO OF VEHICLES STOLEN EACH YEAR
SELECT count(vehicle_id) NO_OF_VEHICLES, year(DATE_STOLEN)
FROM stolen_vehicles group by year(DATE_STOLEN)
ORDER BY NO_OF_VEHICLES DESC;
select YEAR(DATE_STOLEN) FROM stolen_vehicles;
SELECT max(DATE_STOLEN), min(DATE_STOLEN) FROM stolen_vehicles;
-- SET SQL_SAFE_UPDATES =0;
-- update stolen_vehicles SET DATE_STOLEN = date(str_to_date(DATE_STOLEN, '%m/%d/%Y'));
-- ALTER TABLE stolen_vehicles modify column date_stolen date;
-- Q2. FIND THE NO OF VEHICLES STOLEN EACH MONTH
SELECT count(vehicle_id) NO_OF_VEHICLES, MONTHNAME(DATE_STOLEN)
FROM stolen_vehicles group by MONTHNAME(DATE_STOLEN)
ORDER BY NO_OF_VEHICLES DESC;
-- Q3. FIND THE NO OF VEHICLES STOLEN EACH DAY OF THE WEEK.
SELECT count(vehicle_id) NO_OF_VEHICLES, DAYNAME(DATE_STOLEN)
FROM stolen_vehicles group by DAYNAME(DATE_STOLEN)
ORDER BY NO_OF_VEHICLES DESC;
-- ------OBJECTIVE 2------------------
-- Q1. Find the vehicle types that are most often stolen
SELECT COUNT(date_stolen) AS MOST_OFTEN_STOLEN, vehicle_type FROM stolen_vehicles
group by vehicle_type ORDER BY MOST_OFTEN_STOLEN DESC;
-- Q2. Find the vehicle types that are least often stolen
SELECT COUNT(date_stolen) AS MOST_OFTEN_STOLEN, vehicle_type FROM stolen_vehicles
group by vehicle_type ORDER BY MOST_OFTEN_STOLEN ASC;
-- Q3. For each vehicle type, find the average age of the cars that are stolen
SELECT * FROM stolen_vehicles;
SELECT vehicle_type, CAST(AVG(year(date_stolen)-model_year) AS DECIMAL (10,2)) AS
CAR_AGE FROM stolen_vehicles group by vehicle_type;
-- Q4. For each vehicle type, find the percent of vehicles stolen that are luxury versus standard
select j.vehicle_type, sum(j.luxury)/SUM(j.all_cars)*100 as percent_stolen_vehicles
from -- YOU CAN EQUALLY USE COUNT(LUXURY) INSTEAD OF SUM(ALL_CARS)
(SELECT vehicle_type,
CASE WHEN make_type = 'Luxury' THEN 1 else 0 end as luxury, 1 all_cars
FROM stolen_vehicles SV LEFT JOIN make_details MD ON
SV.make_id=MD.vehicle_id)j group by j.vehicle_type order by percent_stolen_vehicles desc;
-- Q5. Create a table where the rows represent the top 10 vehicle types,
-- the columns represent the top 7 vehicle colors (plus 1 column for all other colors)
-- and the values are the number of vehicles stolen.
select vehicle_type, count(VEHICLE_ID) AS NO_STOLEN, SUM(CASE WHEN
color = 'SILVER' THEN 1 ELSE 0 end) AS SILVER,
SUM(case WHEN COLOR = 'WHITE' THEN 1 ELSE 0 END) AS WHITE,
SUM(case WHEN COLOR = 'BLUE' THEN 1 ELSE 0 END) AS BLUE,
SUM(case WHEN COLOR = 'BLACK' THEN 1 ELSE 0 END) AS BLACK,
SUM(case WHEN COLOR = 'RED' THEN 1 ELSE 0 END) AS RED,
SUM(case WHEN COLOR = 'GREY' THEN 1 ELSE 0 END) AS GREY,
SUM(case WHEN COLOR = 'GREEN' THEN 1 ELSE 0 END) AS GREEN,
SUM(CASE WHEN COLOR not in ('SILVER', 'WHITE','BLUE','BLACK','RED','GREEN')
THEN 1 ELSE 0 END) AS OTHER FROM stolen_vehicles GROUP BY
vehicle_type ORDER BY NO_STOLEN DESC LIMIT 10;
-- group by vehicle_type,
-- CASE WHEN color = 'SILVER' THEN 1 ELSE 0 end,
-- case WHEN COLOR = 'WHITE' THEN 1 ELSE 0 END,
-- case WHEN COLOR = 'BLUE' THEN 1 ELSE 0 END,
-- case WHEN COLOR = 'BLACK' THEN 1 ELSE 0 END,
-- case WHEN COLOR = 'RED' THEN 1 ELSE 0 END,
-- case WHEN COLOR = 'GREY' THEN 1 ELSE 0 END,
-- case WHEN COLOR = 'GREEN' THEN 1 ELSE 0 END,
-- CASE WHEN COLOR not in ('SILVER', 'WHITE','BLUE','BLACK','RED','GREEN')
-- THEN 1 ELSE 0 END
-- order by NO_STOLEN DESC limit 10;