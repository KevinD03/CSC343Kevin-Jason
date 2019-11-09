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
DROP VIEW IF EXISTS Mileage2014Source CASCADE;
DROP VIEW IF EXISTS Mileage2014Destination CASCADE;
DROP VIEW IF EXISTS Mileage2014 CASCADE;
DROP VIEW IF EXISTS Mileage2015Format CASCADE;
DROP VIEW IF EXISTS Mileage2015Source CASCADE;
DROP VIEW IF EXISTS Mileage2015Destination CASCADE;
DROP VIEW IF EXISTS Mileage2015 CASCADE;
DROP VIEW IF EXISTS Mileage2015Format CASCADE;
DROP VIEW IF EXISTS MileageFormat CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Mileage2014Source AS
SELECT Dropoff.request_id AS request_id, driver_id, to_char(Request.datetime, 'MM') as month_2014, Place.location as source
FROM Dropoff JOIN Request ON Dropoff.request_id = Request.request_id JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id JOIN place ON Request.source = place.name
WHERE to_char(Request.datetime, 'YYYY') = '2014'; 

CREATE VIEW Mileage2014Destination AS
SELECT Dropoff.request_id AS request_id, driver_id, to_char(Request.datetime, 'MM') as month_2014, Place.location as destination
FROM Dropoff JOIN Request ON Dropoff.request_id = Request.request_id JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id JOIN place ON Request.destination = place.name
WHERE to_char(Request.datetime, 'YYYY') = '2014';

CREATE VIEW Mileage2014 AS
SELECT source<@>destination as mileage, Mileage2014Source.request_id as request_id, Mileage2014Source.driver_id as driver_id, Mileage2014Source.month_2014 as month_2014
FROM Mileage2014Source, Mileage2014Destination
WHERE Mileage2014Source.request_id = Mileage2014Destination.request_id;

CREATE VIEW Mileage2014Format AS
SELECT driver_id, month_2014 as month,sum(mileage) as mileage_2014 
FROM Mileage2014
GROUP BY driver_id, month_2014;

CREATE VIEW Mileage2015Source AS
SELECT Dropoff.request_id AS request_id, driver_id, to_char(Request.datetime, 'MM') as month_2015, Place.location as source
FROM Dropoff JOIN Request ON Dropoff.request_id = Request.request_id JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id JOIN place ON Request.source = place.name
WHERE to_char(Request.datetime, 'YYYY') = '2015'; 

CREATE VIEW Mileage2015Destination AS
SELECT Dropoff.request_id AS request_id, driver_id, to_char(Request.datetime, 'MM') as month_2015, Place.location as destination
FROM Dropoff JOIN Request ON Dropoff.request_id = Request.request_id JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id JOIN place ON Request.destination = place.name
WHERE to_char(Request.datetime, 'YYYY') = '2015';

CREATE VIEW Mileage2015 AS
SELECT source<@>destination as mileage, Mileage2015Source.request_id as request_id, Mileage2015Source.driver_id as driver_id, Mileage2015Source.month_2015 as month_2015
FROM Mileage2015Source, Mileage2015Destination
WHERE Mileage2015Source.request_id = Mileage2015Destination.request_id;

CREATE VIEW Mileage2015Format AS
SELECT driver_id, month_2015 as month,sum(mileage) as mileage_2015 
FROM Mileage2015
GROUP BY driver_id, month_2015;

CREATE VIEW MileageFormat AS
SELECT *
FROM Mileage2015Format FULL JOIN Mileage2014Format ON Mileage2015Format.driver_id = Mileage2014Format.driver_id AND Mileage2015Format.month = Mileage2014Format.month;

SELECT * FROM MileageFormat;


-- Your query that answers the question goes below the "insert into" line:
-- insert into q10
