-- Do drivers improve?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q4 cascade;

create table q4(
    type VARCHAR(9),
    number INTEGER,
    early FLOAT,
    late FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS DriverTenDays CASCADE;
DROP VIEW IF EXISTS DriverTenDaysDateRate CASCADE;
DROP VIEW IF EXISTS FirstFiveDayAverage CASCADE;
DROP VIEW IF EXISTS LastFiveDayAverage CASCADE;
DROP VIEW IF EXISTS FirstAndLastFiveDayAverageTrain CASCADE;
DROP VIEW IF EXISTS Final CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW DriverTenDays AS
SELECT driver_id, min(Request.datetime) as firstday, max(Request.datetime)
as lastday
FROM Pickup JOIN Dropoff ON Pickup.request_id = Dropoff.request_id JOIN Dispatch
ON Pickup.request_id = Dispatch.request_id JOIN Request ON Request.request_id = 
Pickup.request_id
GROUP BY driver_id
HAVING COUNT(DISTINCT to_char(Request.datetime, 'YY-MM-DD')) >= 10;

CREATE VIEW DriverTenDaysDateRate AS
SELECT DriverTenDays.driver_id as driver_id, Request.datetime 
as datetime, DriverRating.rating as rating
FROM DriverTenDays JOIN Dispatch ON DriverTenDays.driver_id = 
Dispatch.driver_id JOIN Request ON Dispatch.request_id = Request.request_id JOIN
Dropoff ON Dropoff.request_id = Request.request_id LEFT JOIN DriverRating ON
DriverRating.request_id = Dropoff.request_id;

CREATE VIEW FirstFiveDayAverage AS
SELECT driver_id, avg(rating) as first_five_average
FROM DriverTenDays NATURAL JOIN DriverTenDaysDateRate
WHERE datetime - firstday < interval '5 day' and datetime >= firstday
GROUP BY driver_id;

CREATE VIEW LastFiveDayAverage AS
SELECT driver_id, avg(rating) as last_five_average
FROM DriverTenDays NATURAL JOIN DriverTenDaysDateRate
WHERE  datetime - firstday >= interval '5 day'
GROUP BY driver_id;

CREATE VIEW FirstAndLastFiveDayAverageTrain AS
SELECT LastFiveDayAverage.driver_id as driver_id, first_five_average,
last_five_average, trained as type
FROM LastFiveDayAverage JOIN FirstFiveDayAverage ON LastFiveDayAverage.driver_id
= FirstFiveDayAverage.driver_id JOIN Driver ON Driver.driver_id = 
LastFiveDayAverage.driver_id;

CREATE VIEW Final AS
SELECT Case
		WHEN type Then 'trained'
		ELSE 'untrained'
        END as type, COUNT(driver_id) as number, avg(first_five_average) 
as early,
avg(last_five_average) as late
FROM FirstAndLastFiveDayAverageTrain
GROUP BY type;

-- Your query that answers the question goes below the "insert into" line:
insert into q4
Select * FROM Final;

