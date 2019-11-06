-- Lure them back

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q2 cascade;

create table q2(
    client_id INTEGER,
    name VARCHAR(45),
    email VARCHAR(40),
    billed INTEGER,
    decline INTEGER 
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS TotalBillBefore2014 CASCADE;
DROP VIEW IF EXISTS ClientBefore2014AtLeast500 CASCADE;
DROP VIEW IF EXISTS ClientNumIn2014 CASCADE;
DROP VIEW IF EXISTS ClientOneToTenIn2014 CASCADE;
DROP VIEW IF EXISTS ClientFewerRideIn2015 CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW TotalBillBefore2014 as
Select Client.client_id, surname, firstname, email, 
DATEPART(yy, Request.datatime) as year, sum(amount) as billed
From Client, (Billed Left Join Dropoff Left Join Request) as Successful_Bill
where Client.client_id = Successfull_Bill.client_id
Group by Client.client_id;


CREATE VIEW ClientBefore2014AtLeast500 as
Select client_id, surname, firstname, email, year, billed
From TotalBillBefore2014
Where billed >= 500;


CREATE VIEW ClientNumIn2014 as
Select Client.client_id, surname, firstname, email, billed, 
count(CLient.client_id) as rides
From ClientBefore2014AtLeast500 as Client, 
(Request Join Dropoff on Requset.request_id = Dropoff.requset_id) as Ride 
Where ClientBefore2014AtLeast500.client_id = Ride.client_id
Group by Client.client_id;


CREATE VIEW ClientOneToTenIn2014 as
Select client_id, surname, firstname, email, billed, rides
From ClientNumIn2014
Where rides > 0 and rides < 11;


CREATE VIEW ClientNumIn2015 as
Select Client.client_id, surname, firstname, email, billed, 
count(CLient.client_id) as rides
From ClientOneToTenIn2014 as Client, 
(Request Join Dropoff on Requset.request_id = Dropoff.requset_id) as Ride 
Where ClientOneToTenIn2014.client_id = Ride.client_id
Group by Client.client_id;


CREATE VIEW ClientFewerRideIn2015 as


-- Your query that answers the question goes below the "insert into" line:
insert into q2
Select * From Result;

