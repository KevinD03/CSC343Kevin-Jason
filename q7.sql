-- Ratings histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q7 cascade;

create table q7(
	driver_id INTEGER,
	r5 INTEGER,
	r4 INTEGER,
	r3 INTEGER,
	r2 INTEGER,
	r1 INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllDriver CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW AllDriver as 
Select Request.request_id, Dispatch.driver_id
From Dispatch, Request
Where Request.request_id = Dispatch.request_id;

--Select * from AllDriver;

CREATE VIEW AllDriverRating as 
Select AllDriver.driver_id, 
count(case when rating = 5 then rating end) as r5,
count(case when rating = 4 then rating end) as r4,
count(case when rating = 3 then rating end) as r3,
count(case when rating = 2 then rating end) as r2,
count(case when rating = 1 then rating end) as r1
From AllDriver Left join DriverRating on 
AllDriver.request_id = DriverRating.request_id
Group by AllDriver.driver_id;

--Select * from AllDriverRating;


CREATE VIEW AllDriverRatingWithNull as 
Select driver_id, 
case when r5 != 0 then r5 else null end as r5,
case when r4 != 0 then r4 else null end as r4,
case when r3 != 0 then r3 else null end as r3,
case when r2 != 0 then r2 else null end as r2,
case when r1 != 0 then r1 else null end as r1
From AllDriverRating;


--Select * from AllDriverRatingWithNull;


-- Your query that answers the question goes below the "insert into" line:
insert into q7
Select * from AllDriverRatingWithNull;
