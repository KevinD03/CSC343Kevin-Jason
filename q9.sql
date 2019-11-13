-- Consistent raters

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q9 cascade;

create table q9(
	client_id INTEGER,
	email VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Raters CASCADE;
DROP VIEW IF EXISTS InconsistentRaters CASCADE;
DROP VIEW IF EXISTS ConsistentRaters CASCADE;
DROP VIEW IF EXISTS Final CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Raters AS
SELECT client_id, driver_id, rating
FROM Dropoff JOIN Dispatch ON Dropoff.request_id = Dispatch.request_id
JOIN Request ON Request.request_id = Dropoff.request_id JOIN driverrating 
ON driverrating.request_id = Dropoff.request_id;

CREATE VIEW InconsistentRaters AS
SELECT client_id
FROM Raters
GROUP BY client_id, driver_id
HAVING sum(rating) = 0;

CREATE VIEW ConsistentRaters AS
(SELECT client_id FROM Raters) EXCEPT (SELECT * FROM InconsistentRaters);

CREATE VIEW Final AS
SELECT client.client_id as client_id, email
FROM ConsistentRaters JOIN client ON client.client_id = 
ConsistentRaters.client_id;

-- Your query that answers the question goes below the "insert into" line:
insert into q9
SELECT * FROM Final;





