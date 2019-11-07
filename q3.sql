-- Months

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q1 cascade;

create table q3(
    driver integer,
    start date,
    driving interval,
    breaks interval
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS DirverWorkWithTime CASCADE;
DROP VIEW IF EXISTS DirverWorkTimePerDay CASCADE;
DROP VIEW IF EXISTS DirverBreakSumPerDay CASCADE;
DROP VIEW IF EXISTS DriverWorkMoreThree CASCADE;
DROP VIEW IF EXISTS BreakTimeInThreeDay CASCADE;
DROP VIEW IF EXISTS DriveBreakLaw CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW DirverWorkTimePerDay as
Select Dispatch.request_id, driver_id, 
to_char(Pickup.datetime, 'YYYY-MM-DD') as pickuptime,
sum(Dropoff.datetime - Pickup.datetime) as worktime
From Dispatch, Dropoff, Pickup
Where Dispatch.request_id = Pickup.request_id and 
Pickup.request_id = Dropoff.request_id
Group by Dispatch.request_id, driver_id, pickuptime;


CREATE VIEW DirverBreakSumPerDay as
Select Dispatch.request_id, driver_id, 
sum(Pickup.datetime - Dropoff.datetime) as break
From Dropoff, Pickup
Where Pickup.request_id != Dropoff.request_id and
Dropoff.datetime < Pickup.datetime
Group by Dispatch.request_id, driver_id;

Select * from DirverBreakSumPerDay;




CREATE VIEW DriverOneTripPerDay as



--CREATE VIEW DriverWorkMoreThree as


--CREATE VIEW BreakTimeInThreeDay as


--CREATE VIEW DriveBreakLaw as 

-- Your query that answers the question goes below the "insert into" line:
--insert into q3
