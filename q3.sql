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
DROP VIEW IF EXISTS DirverWorkTimePerDay CASCADE;
DROP VIEW IF EXISTSDirverBreakSumPerDay CASCADE;
DROP VIEW IF EXISTSDriverWorkMoreThree CASCADE;
DROP VIEW IF EXISTSBreakTimeInThreeDay CASCADE;
DROP VIEW IF EXISTSDriveBreakLaw CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW DirverWorkTimePerDay as
Select 
From Dispacth, Dropoff, Pickup

CREATE VIEW DirverBreakSumPerDay as


CREATE VIEW DriverWorkMoreThree as


CREATE VIEW BreakTimeInThreeDay as


CREATE VIEW DriveBreakLaw

-- Your query that answers the question goes below the "insert into" line:
insert into q3
