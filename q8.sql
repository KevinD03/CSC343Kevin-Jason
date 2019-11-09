-- Scratching backs?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q8 cascade;

create table q8(
	client_id INTEGER,
	reciprocals INTEGER,
	difference FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Reciprocal CASCADE;
DROP VIEW IF EXISTS ReciprocalClient CASCADE;
DROP VIEW IF EXISTS Final CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Reciprocal AS
SELECT driverrating.request_id as request_id, driverrating.rating as driverrating, clientrating.rating as clientrating
FROM driverrating, clientrating
WHERE driverrating.request_id = clientrating.request_id;

CREATE VIEW ReciprocalClient AS
SELECT client_id, driverrating, clientrating
FROM Reciprocal JOIN Request ON Request.request_id = Reciprocal.request_id;

CREATE VIEW Final AS
SELECT client_id, count(driverrating) as reciprocals, avg(driverrating - clientrating) as difference
FROM ReciprocalClient
GROUP BY client_id;

-- Your query that answers the question goes below the "insert into" line:
insert into q8
SELECT * FROM Final;






