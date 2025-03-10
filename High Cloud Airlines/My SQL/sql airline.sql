use airline;
select * from maindata;

-- UPDATE Date column from year,month day
ALTER TABLE maindata ADD COLUMN Datee DATE;
SELECT STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-', `DAY`), '%Y-%m-%d') AS full_date FROM maindata;
-- 								OR
set SQL_SAFE_UPDATES=0;
UPDATE maindata 
SET Datee = STR_TO_DATE(CONCAT(`YEAR`, '-', `Month (#)`, '-', `DAY`), '%Y-%m-%d');

ALTER TABLE maindata ADD COLUMN Monthno INT,
					 ADD COLUMN Monthfullname VARCHAR(20),
                     ADD COLUMN Quarter VARCHAR(2),
                     ADD COLUMN YearMonth VARCHAR(10),
                     ADD COLUMN Weekdayno INT,
                     ADD COLUMN Weekdayname VARCHAR(10),
                     ADD COLUMN FinancialMonth VARCHAR(20),
                     ADD COLUMN FinancialQuarter VARCHAR(2);

UPDATE maindata
SET 
    Monthno = MONTH(Datee),
    Monthfullname = MONTHNAME(Datee),
    Quarter = CONCAT('Q', QUARTER(Datee)),
    YearMonth = DATE_FORMAT(Datee, '%Y-%b'),
    Weekdayno = WEEKDAY(Datee) + 1,  
    Weekdayname = DAYNAME(Datee),
    FinancialMonth = CASE 
        WHEN MONTH(Datee) >= 4 THEN CONCAT(YEAR(Datee), '-', LPAD(MONTH(Datee), 2, '0')) -- LPAD(string, length, pad_string)
        ELSE CONCAT(YEAR(Datee) - 1, '-', LPAD(MONTH(Datee), 2, '0'))
    END,
    FinancialQuarter = CASE 
        WHEN MONTH(Datee) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(Datee) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(Datee) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END;

SELECT Datee, Monthno, Monthfullname, Quarter, YearMonth, Weekdayno, Weekdayname, FinancialMonth, FinancialQuarter 
FROM maindata LIMIT 10;

-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

show columns from maindata;

ALTER TABLE maindata CHANGE COLUMN `# Transported Passengers` transported_passengers INT,
					 CHANGE COLUMN `# Available Seats` available_seats INT;

select year(Datee) as Yearr, month(Datee) as Monthh, quarter(Datee) as Quarterr,
	   (sum(transported_passengers) / sum(available_seats))*100 as Load_Factor_Percentage 
from maindata 
where transported_passengers > 0 and available_seats > 0 
group by year(Datee), month(Datee), quarter(Datee)
order by Yearr, Monthh, Quarterr;

-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)

ALTER TABLE maindata CHANGE COLUMN `Carrier Name` Carrier_Name text;

select Carrier_Name, sum(transported_passengers) as Total_TransportedPassengers , sum(available_seats) as Total_AvailableSeats,
	   (SUM(transported_passengers) / NULLIF(SUM(available_seats), 0) * 100) as Load_Factor_Percentage 
from maindata 
where transported_passengers > 0 and available_seats > 0 
group by Carrier_Name
order by Load_Factor_Percentage  ;


-- 4. Identify Top 10 Carrier Names based passengers preference 

select Carrier_Name, sum(transported_passengers) as Total_Transported_Passengers from maindata 
where transported_passengers > 0
group by Carrier_Name
order by Total_Transported_Passengers
limit 10;


-- 5. Display top Routes ( from-to City) based on Number of Flights 

select `From - To City` , `%Airline ID` as Number_of_Flights from maindata
limit 10; 		-- random 10 with whole ID number

select  `From - To City` , `From - To State`, count(`%Airline ID`) as Number_of_Flights from maindata
group by `From - To City`, `From - To State`
order by Number_of_Flights desc
limit 10; -- just count how many Airlines are there


-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.

select 
	case when dayofweek(Datee) in (1,7) then 'Weekend'
		 else 'Weekday'
	end as Week_Day_Type, sum(transported_passengers/available_seats)*100 as Load_Factor_Percentage
from maindata
where available_seats > 0
group by Week_Day_Type;

-- 7. Identify number of flights based on Distance group

select
	case
		when distance <=500 then 'Short Dist (0-500 km)'
        when distance between 501 and 1500 then 'Medium Distance (501-1500 km)'
        when distance > 1500 then 'Long Distance (1501+ km)'
	end as Distance_Group, count(`%Airline ID`) as No_of_Flights
from maindata
group by Distance_Group
order by Distance_Group;


# Total Number of Flights Per Airline

select Carrier_Name, count(*) as Total_Flights from maindata
group by Carrier_Name
order by Total_Flights desc;

# Most Popular Flight Routes
SELECT `From - To City`, Destination_City, COUNT(*) AS Total_Flights
FROM airline_maindata
GROUP BY Source_City, Destination_City
ORDER BY Total_Flights DESC
LIMIT 10;


