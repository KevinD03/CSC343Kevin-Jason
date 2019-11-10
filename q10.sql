-- Rainmakers

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q10 cascade;

create table q10(
	driver_id INTEGER,
	month CHAR(2),
	mileage_2014 FLOAT,
	billings_2014 FLOAT,
	mileage_2015 FLOAT,
	billings_2015 FLOAT,
	billings_increase FLOAT,
	mileage_increase FLOAT
);


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Months CASCADE;
DROP VIEW IF EXISTS DriverMonths CASCADE;
DROP VIEW IF EXISTS P1 CASCADE;
DROP VIEW IF EXISTS P2 CASCADE;
DROP VIEW IF EXISTS Mileage2014 CASCADE;
DROP VIEW IF EXISTS Billings2014 CASCADE;
DROP VIEW IF EXISTS Mileage2015 CASCADE;
DROP VIEW IF EXISTS Billings2015 CASCADE;
DROP VIEW IF EXISTS Final CASCADE;
DROP VIEW IF EXISTS Result CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Months as
SELECT to_char(DATE '2014-01-01' + (interval '1' month * generate_series(0,11)),
 'MM') as mo;

CREATE VIEW DriverMonths as
SELECT Driver.driver_id as driver_id, mo as month
FROM Driver, Months;

CREATE VIEW P1 AS
SELECT * FROM Place;

CREATE VIEW P2 AS
SELECT * FROM Place;

CREATE VIEW Mileage2014 AS
SELECT driver_id, to_char(Request.datetime, 'MM') as month, 
sum(P1.location<@>P2.location) as mileage_2014
FROM Dropoff JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id JOIN 
Request ON Dropoff.request_id = Request.request_id JOIN P1 ON 
Request.source = P1.name JOIN P2 ON Request.destination = P2.name
WHERE to_char(Request.datetime, 'YYYY') = '2014'
GROUP BY driver_id, to_char(Request.datetime, 'MM');

CREATE VIEW Billings2014 AS
SELECT driver_id, to_char(Request.datetime, 'MM') as month, sum(amount) 
as billings_2014
FROM Dropoff JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id 
JOIN billed ON billed.request_id = Dropoff.request_id JOIN Request 
ON Dropoff.request_id = Request.request_id
WHERE to_char(Request.datetime, 'YYYY') = '2014'
GROUP BY driver_id, to_char(Request.datetime, 'MM');

CREATE VIEW Mileage2015 AS
SELECT driver_id, to_char(Request.datetime, 'MM') as month, 
sum(P1.location<@>P2.location) as mileage_2015
FROM Dropoff JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id 
JOIN Request ON Dropoff.request_id = Request.request_id JOIN P1 
ON Request.source = P1.name JOIN P2 ON Request.destination = P2.name
WHERE to_char(Request.datetime, 'YYYY') = '2015'
GROUP BY driver_id, to_char(Request.datetime, 'MM');

CREATE VIEW Billings2015 AS
SELECT driver_id, to_char(Request.datetime, 'MM') as month, sum(amount) 
as billings_2015
FROM Dropoff JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id 
JOIN billed ON billed.request_id = Dropoff.request_id JOIN Request 
ON Dropoff.request_id = Request.request_id
WHERE to_char(Request.datetime, 'YYYY') = '2015'
GROUP BY driver_id, to_char(Request.datetime, 'MM');

CREATE VIEW Final AS
SELECT DriverMonths.driver_id as driver_id, DriverMonths.month 
as month, mileage_2014, billings_2014, mileage_2015, billings_2015
FROM DriverMonths LEFT JOIN Mileage2014 ON DriverMonths.driver_id = 
Mileage2014.driver_id and DriverMonths.month = Mileage2014.month LEFT JOIN 
Billings2014 ON DriverMonths.driver_id = Billings2014.driver_id 
and DriverMonths.month = Billings2014.month LEFT JOIN Billings2015 
ON DriverMonths.driver_id = Billings2015.driver_id and DriverMonths.month 
= Billings2015.month LEFT JOIN Mileage2015 ON DriverMonths.driver_id = 
Mileage2015.driver_id and DriverMonths.month = Mileage2015.month;

CREATE VIEW Result AS
SELECT driver_id, month, coalesce(sum(mileage_2014),0) as mileage_2014, 
coalesce(sum(billings_2014),0) as billings_2014, coalesce(sum(mileage_2015),0) 
as mileage_2015, coalesce(sum(billings_2015),0) as billings_2015, 
coalesce(sum(billings_2015) - sum(billings_2014),0) as billings_increase, 
coalesce(sum(mileage_2015) - sum(mileage_2014),0) as mileage_increase
FROM Final
GROUP BY driver_id, month;


-- Your query that answers the question goes below the "insert into" line:
insert into q10
SELECT * FROM Result;





