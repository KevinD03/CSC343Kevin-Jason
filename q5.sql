-- Bigger and smaller spenders

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q5 cascade;

create table q5(
	client_id INTEGER,
	months VARCHAR(7),      -- The handout called this "month", which made more sense.
	total FLOAT,
	comparison VARCHAR(30)  -- This could have been lower.
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS ClientAndMonth CASCADE;
DROP VIEW IF EXISTS ClientMonthComb CASCADE;
DROP VIEW IF EXISTS ClientMonthCheck CASCADE;
DROP VIEW IF EXISTS ClientAndMonthWithRides CASCADE;
DROP VIEW IF EXISTS ClientRideBill CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW ClientAndMonth as
Select Client.client_id, Request.request_id,
to_char(Request.datetime,'YYYY-MM') as datetime
From Client, Request
Order by Client.client_id;

Select * from ClientAndMonth;

CREATE VIEW ClientMonthComb as 
Select client_id, datetime, count(request_id) as orders
From ClientAndMonth
Group by client_id,datetime;

Select * from ClientMonthComb;

CREATE VIEW ClientMonthCheck as 
Select client_id, datetime
From ClientMonthComb;

Select * from ClientMonthCheck;

CREATE VIEW ClientAndMonthWithRides as
Select ClientMonthCheck.client_id, 
ClientMonthCheck.datetime, request_id
From ClientMonthCheck left join Request 
on ClientMonthCheck.client_id = Request.client_id
;

Select * from ClientAndMonthWithRides;


CREATE VIEW ClientRideBill as
Select client_id, datetime, sum(amount) as totalbill
From ClientAndMonthWithRides left join Billed on 
ClientAndMonthWithRides.request_id = Billed.request_id
Group by client_id, datetime
Order by client_id;


Select * from ClientRideBill;

-- Your query that answers the question goes below the "insert into" line:
--insert into q5
