-- Months

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q1 cascade;

create table q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Rides CASCADE;
DROP VIEW IF EXISTS ClientWithRides CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Rides as
Select Request.request_id, Request.client_id, request.datetime
From Request Join Dropoff on Request.request_id = Dropoff.request_id;


CREATE VIEW ClientWithRides as
Select Client.client_id, email, request_id, 
to_char(datetime, 'YYYY-MM') as datetime
From Client Left Join Rides on Client.client_id = Rides.client_id;


-- Your query that answers the question goes below the "insert into" line:
--insert into q1
Select client_id, email, count(distinct datetime) as months
From ClientWithRides
Group by client_id, email;
