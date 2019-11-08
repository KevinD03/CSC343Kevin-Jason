-- Months

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q3 cascade;

create table q3(
    driver_id INTEGER,
    start DATE,
    driving INTERVAL,
    breaks INTERVAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS DirverWorkWithTime CASCADE;
DROP VIEW IF EXISTS DirverWorkTimePerDay CASCADE;
DROP VIEW IF EXISTS DirverBreakPerDay CASCADE;
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

Select * from DirverWorkTimePerDay;

CREATE VIEW DirverBreakPerDay as
Select Dispatch.request_id, driver_id, 
min(Pickup.datetime - Dropoff.datetime) as onebreak
From Dropoff, Pickup, Dispatch
Where Dispatch.request_id = Pickup.request_id and
Pickup.request_id != Dropoff.request_id and
Dropoff.datetime < Pickup.datetime
Group by Dispatch.request_id, driver_id;

Select * from DirverBreakPerDay;


CREATE VIEW ActualBreakTime as 
Select DirverBreakPerDay.request_id, driver_id, '00:00:00' as onebreak
From DirverBreakPerDay, Dropoff, Pickup
Where DirverBreakPerDay.request_id = Dropoff.request_id and
Dropoff.request_id = Pickup.request_id
Group by driver_id, DirverBreakPerDay.request_id,
Having
to_char(Pickup.datetime, 'YYYY-MM-DD') = to_char(Dropoff.datetime, 'YYYY-MM-DD')
and count(Pickup.request_id) = count(Dropoff.request_id) 
and count(Dropoff.request_id) = 1;

Select * from ActualBreakTime;



CREATE VIEW TotalDriverBreakPerDay as
Select request_id, driver_id, 
sum(Pickup.datetime - Dropoff.datetime) as break
From DirverBreakSumPerDay
Where Pickup.request_id != Dropoff.request_id and
Dropoff.datetime < Pickup.datetime
Group by request_id, driver_id;

Select * from TotalDriverBreakPerDay;


--CREATE VIEW DriverOneTripPerDay as



--CREATE VIEW DriverWorkMoreThree as


--CREATE VIEW BreakTimeInThreeDay as


--CREATE VIEW DriveBreakLaw as 

-- Your query that answers the question goes below the "insert into" line:
--insert into q3
