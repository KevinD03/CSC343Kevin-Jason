-- Frequent riders

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q6 cascade;

create table q6(
	client_id INTEGER,
	year CHAR(4),
	rides INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS YearWithRides CASCADE;
DROP VIEW IF EXISTS YearWithRidesConsiderAllClients CASCADE;
DROP VIEW IF EXISTS DropoffFormat CASCADE;
DROP VIEW IF EXISTS ClientYearRides CASCADE;
DROP VIEW IF EXISTS ClientYearRidesGroup CASCADE;
DROP VIEW IF EXISTS TopThree CASCADE;
DROP VIEW IF EXISTS BottomThree CASCADE;
DROP VIEW IF EXISTS Final CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW YearWithRides AS
SELECT DISTINCT to_char(Dropoff.datetime, 'YYYY') as year
FROM Dropoff;

CREATE VIEW YearWithRidesConsiderAllClients AS
SELECT year, client_id
FROM YearWithRides, Client;

CREATE VIEW DropoffFormat AS
SELECT to_char(Dropoff.datetime, 'YYYY') as year, request_id
FROM Dropoff;

CREATE VIEW ClientYearRides AS
SELECT YearWithRidesConsiderAllClients.year as year, 
YearWithRidesConsiderAllClients.client_id 
as client_id, DropoffFormat.request_id as request_id
FROM (DropoffFormat JOIN Request ON DropoffFormat.request_id 
= Request.request_id) RIGHT JOIN YearWithRidesConsiderAllClients ON 
YearWithRidesConsiderAllClients.client_id 
= Request.client_id AND YearWithRidesConsiderAllClients.year 
= DropoffFormat.year;

CREATE VIEW ClientYearRidesGroup AS
SELECT year, client_id, count(request_id) as rides
FROM ClientYearRides
GROUP BY year, client_id
ORDER BY year ASC, count(request_id) DESC;

CREATE VIEW TopThree as
SELECT *
FROM ClientYearRidesGroup t
WHERE (
	SELECT count(DISTINCT rides)
	FROM ClientYearRidesGroup
	WHERE year = t.year and rides >= t.rides) <= 3;

CREATE VIEW BottomThree as
SELECT *
FROM ClientYearRidesGroup t
WHERE (
	SELECT count(DISTINCT rides)
	FROM ClientYearRidesGroup
	WHERE year = t.year and rides <= t.rides) <= 3;

CREATE VIEW Final AS
(SELECT * FROM BottomThree) Union (SELECT * FROM TopThree);

-- Your query that answers the question goes below the "insert into" line:
insert into q6
Select client_id, year, rides FROM Final;




