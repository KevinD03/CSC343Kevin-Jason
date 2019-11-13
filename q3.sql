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
DROP VIEW IF EXISTS DirverWorkTimePerDay CASCADE;
DROP VIEW IF EXISTS DirverBreakPerDay CASCADE;
DROP VIEW IF EXISTS OneTripBreak CASCADE;
DROP VIEW IF EXISTS ActualBreakTime CASCADE;
DROP VIEW IF EXISTS DriverBreakLawOneDay CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW DirverWorkTimePerDay as
Select Dispatch.request_id, driver_id, 
to_char(Pickup.datetime, 'YYYY-MM-DD') as pickuptime,
sum(Dropoff.datetime::timestamp - Pickup.datetime::timestamp) as worktime
From Dispatch, Dropoff, Pickup
Where Dispatch.request_id = Pickup.request_id and 
Pickup.request_id = Dropoff.request_id and 
Dropoff.datetime::timestamp::date = Pickup.datetime::timestamp::date
Group by Dispatch.request_id, driver_id, pickuptime;

--Select * from DirverWorkTimePerDay;


CREATE VIEW DirverBreakPerDay as
Select Dispatch.request_id, driver_id, 
sum(Pickup.datetime::timestamp - Dropoff.datetime::timestamp) as onebreak
From Dropoff, Pickup, Dispatch, Request
Where Request.request_id = Dispatch.request_id and
Request.request_id = Pickup.request_id and
Dropoff.datetime::timestamp::date = Pickup.datetime::timestamp::date and
Dropoff.datetime::timestamp < Pickup.datetime::timestamp and 
(Pickup.datetime::timestamp - 
Dropoff.datetime::timestamp) < INTERVAL'00:15:00'
Group by Dispatch.request_id, driver_id;

--Select * from DirverBreakPerDay;


CREATE VIEW OneTripBreak as 
Select Dispatch.request_id, driver_id, interval'00:00:00' as onebreak
From Request, Dropoff, Pickup, Dispatch
Where Request.request_id = Dispatch.request_id and
Request.request_id = Pickup.request_id and
Dropoff.datetime::timestamp::date = Pickup.datetime::timestamp::date
Group by driver_id, dispatch.request_id
Having count(Dropoff.request_id) = 1;

--Select * from OneTripBreak;


CREATE VIEW ActualBreakTime  as
(Select * From OneTripBreak)
UNION
(Select * From DirverBreakPerDay);

--Select * from ActualBreakTime;


CREATE VIEW DriverBreakLawOneDay as
Select ActualBreakTime.driver_id, 
       date(DirverWorkTimePerDay.pickuptime) as start, 
       DirverWorkTimePerDay.worktime as driving, 
       ActualBreakTime.onebreak as breaks
From ActualBreakTime, DirverWorkTimePerDay
Where ActualBreaKTime.driver_id = ActualBreakTime.driver_id and 
DirverWorkTimePerDay.worktime > interval'12:00:00';

--Select * from DriverBreakLawOneDay;


CREATE VIEW DriverBreakLaw as 
Select D1.driver_id, 
       D1.start as start, 
       D1.driving + D2.driving + D3.driving as driving, 
       D1.breaks + D2.breaks + D3.breaks as breaks
From DriverBreakLawOneDay as D1,
    DriverBreakLawOneDay as D2,
    DriverBreakLawOneDay as D3
Where D1.start + 1 = D2.start and D2.start + 1 = D3.start;

-- Your query that answers the question goes below the "insert into" line:
insert into q3
Select * From DriverBreakLaw;







