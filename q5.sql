-- Bigger and smaller spenders

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q5 cascade;

create table q5(
	client_id INTEGER,
	months VARCHAR(7),      -- The handout called this "month", 
				-- which made more sense.
	total FLOAT,
	comparison VARCHAR(30)  -- This could have been lower.
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS RequestWithBill CASCADE;
DROP VIEW IF EXISTS RequsetWithAllBill CASCADE;
DROP VIEW IF EXISTS MonthAverage CASCADE;
DROP VIEW IF EXISTS ClientAndMonth CASCADE;
DROP VIEW IF EXISTS ClientMonthComb CASCADE;
DROP VIEW IF EXISTS ClientMonthCheck CASCADE;
DROP VIEW IF EXISTS ClientMonthBill CASCADE;
DROP VIEW IF EXISTS Report CASCADE;
-- Define views for your intermediate steps here:

CREATE VIEW RequestWithBill as
Select Request.request_id, 
Request.datetime as datetime, amount
From Request left join Billed on Request.request_id = Billed.request_id;

--Select * from RequestWithBill;

CREATE VIEW RequsetWithAllBill as
Select Request.client_id, Request.request_id, Request.datetime 
as datetime, amount
From Request,RequestWithBill
Where Request.request_id = RequestWithBill.request_id;

--Select * from RequsetWithAllBill;


CREATE VIEW MonthAverage as
Select Request.client_id, Request.datetime as datetime, 
avg(Billed.amount) as average
From Request, Billed
Where Request.request_id = Billed.request_id
Group by Request.client_id,datetime;

--Select * from MonthAverage;


CREATE VIEW ClientAndMonth as
Select Client.client_id, Request.request_id, Request.datetime as datetime
From Client, Request
Order by Client.client_id;

--Select * from ClientAndMonth;


CREATE VIEW ClientMonthComb as 
Select client_id, datetime, count(request_id) as orders
From ClientAndMonth
Group by client_id,datetime;

--Select * from ClientMonthComb;


CREATE VIEW ClientMonthCheck as 
Select client_id, datetime
From ClientMonthComb
Order by client_id;

--Select * from ClientMonthCheck;


CREATE VIEW ClientMonthBill as
Select  ClientMonthCheck.client_id, ClientMonthCheck.datetime, 
coalesce(sum(amount), 0) as total
From ClientMonthCheck left join RequsetWithAllBill 
on ClientMonthCheck.client_id = RequsetWithAllBill.client_id and 
ClientMonthCheck.datetime = RequsetWithAllBill.datetime
Group by ClientMonthCheck.client_id, ClientMonthCheck.datetime
Order By ClientMonthCheck.client_id;

--Select * from ClientMonthBill;


CREATE VIEW Report as 
Select Distinct ClientMonthBill.client_id, 
concat(extract(year from ClientMonthBill.datetime), ' ',
extract(month from ClientMonthBill.datetime)) as month,
total,
    Case
         When total < average Then 'below'
         Else 'at or above'
    End as comparison
From ClientMonthBill, MonthAverage 
where ClientMonthBill.datetime = MonthAverage.datetime;

--Select * from Report;

-- Your query that answers the question goes below the "insert into" line:
insert into q5
Select * from Report;
