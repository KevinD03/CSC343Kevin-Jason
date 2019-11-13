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
DROP VIEW IF EXISTS Final CASCADE;
DROP VIEW IF EXISTS Result CASCADE;
DROP VIEW IF EXISTS MileageBillings2014 CASCADE;
DROP VIEW IF EXISTS MileageBillings2015 CASCADE;

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

CREATE VIEW MileageBillings2014 AS
SELECT driver_id, to_char(Request.datetime, 'MM') as month, 
sum(P1.location<@>P2.location) as mileage_2014,
sum(amount+0.0) as billings_2014
FROM billed JOIN Dropoff ON billed.request_id = Dropoff.request_id JOIN Dispatch 
ON billed.request_id = Dispatch.request_id JOIN 
Request ON billed.request_id = Request.request_id JOIN P1 ON 
Request.source = P1.name JOIN P2 ON Request.destination = P2.name
WHERE to_char(Request.datetime, 'YYYY') = '2014'
GROUP BY driver_id, to_char(Request.datetime, 'MM');

CREATE VIEW MileageBillings2015 AS
SELECT driver_id, to_char(Request.datetime, 'MM') as month, 
sum(P1.location<@>P2.location) as mileage_2015,
sum(amount+0.0) as billings_2015
FROM billed JOIN Dropoff ON billed.request_id = Dropoff.request_id JOIN Dispatch 
ON billed.request_id = Dispatch.request_id JOIN 
Request ON billed.request_id = Request.request_id JOIN P1 ON 
Request.source = P1.name JOIN P2 ON Request.destination = P2.name
WHERE to_char(Request.datetime, 'YYYY') = '2015'
GROUP BY driver_id, to_char(Request.datetime, 'MM');

CREATE VIEW Final AS
SELECT DriverMonths.driver_id as driver_id, DriverMonths.month 
as month, coalesce(mileage_2014,0) as mileage_2014, coalesce(billings_2014,0) as billings_2014,
 coalesce(mileage_2015,0) as mileage_2015, coalesce(billings_2015,0) as billings_2015
FROM (DriverMonths LEFT JOIN MileageBillings2014 ON DriverMonths.driver_id = 
MileageBillings2014.driver_id and DriverMonths.month = MileageBillings2014.month)
LEFT JOIN MileageBillings2015 ON DriverMonths.driver_id = 
MileageBillings2015.driver_id and DriverMonths.month = MileageBillings2015.month;

CREATE VIEW Result AS
SELECT driver_id, month, mileage_2014, billings_2014, mileage_2015, billings_2015, 
billings_2015 - billings_2014 as billings_increase, 
mileage_2015 - mileage_2014 as mileage_increase
FROM Final;


-- Your query that answers the question goes below the "insert into" line:
insert into q10
SELECT * FROM Result;






