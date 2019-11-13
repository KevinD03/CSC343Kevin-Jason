-- Lure them back

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q2 cascade;

create table q2(
    client_id INTEGER,
    name VARCHAR(41),
    email VARCHAR(30),
    billed FLOAT,
    decline INTEGER 
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS TotalBillBefore2014 CASCADE;
DROP VIEW IF EXISTS ClientBefore2014AtLeast500 CASCADE;
DROP VIEW IF EXISTS ClientRideNum CASCADE;
DROP VIEW IF EXISTS ClientOneToTenIn2014 CASCADE;
DROP VIEW IF EXISTS ClientNumIn2015 CASCADE;
DROP VIEW IF EXISTS ClientFewerRideIn2015 CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW TotalBillBefore2014 as
Select Client.client_id, surname, firstname, email, sum(amount) as billed
From Client, ((Billed Left Join Dropoff 
        on Billed.request_id = Dropoff.request_id) 
        Left Join Request 
        on Billed.request_id = Request.request_id)
Where Client.client_id = Request.client_id 
and date_part('year', Request.datetime) < 2014
Group by Client.client_id;


CREATE VIEW ClientBefore2014AtLeast500 as
Select client_id, surname, firstname, email, billed
From TotalBillBefore2014
Where billed >= 500;

--Select * from ClientBefore2014AtLeast500;


CREATE VIEW ClientRideNum as
Select ClientBefore2014AtLeast500.client_id, 
count(ClientBefore2014AtLeast500.client_id) as rides
From ClientBefore2014AtLeast500, Request, Dropoff
Where ClientBefore2014AtLeast500.client_id = Request.client_id and
Dropoff.request_id = Request.request_id and
date_part('year', Request.datetime) = 2014
Group by ClientBefore2014AtLeast500.client_id;

--Select * from ClientRideNum;


CREATE VIEW ClientOneToTenIn2014 as
Select client_id, rides
From ClientRideNum
Where rides > 0 and rides < 11;

--Select * from ClientOneToTenIn2014;


CREATE VIEW ClientNumIn2015 as
Select ClientRideNum.client_id,
count(ClientRideNum.client_id) as rides
From ClientRideNum, Request, Dropoff
Where ClientRideNum.client_id = Request.client_id and 
Dropoff.request_id = Request.request_id and 
date_part('year', Request.datetime) = 2015
Group by ClientRideNum.client_id;


--Select * from ClientNumIn2015;


CREATE VIEW ClientFewerRideIn2015 as
Select C.client_id
From ClientOneToTenIn2014 C ,ClientNumIn2015 
Where C.client_id = ClientNumIn2015.client_id and
C.rides > ClientNumIn2015.rides;

--Select * from ClientFewerRideIn2015;

CREATE VIEW Merge as 
Select ClientFewerRideIn2015.client_id, surname, firstname, email, billed
From ClientFewerRideIn2015,TotalBillBefore2014
Where ClientFewerRideIn2015.client_id = TotalBillBefore2014.client_id;

Select * From Merge; 


-- Your query that answers the question goes below the "insert into" line:
insert into q2
Select Merge.client_id, 
concat(firstname, ' ', surname) as name, 
coalesce(email, 'unknown') as email, 
billed,
(ClientOneToTenIn2014.rides - ClientNumIn2015.rides) as decline
From Merge, ClientNumIn2015,ClientOneToTenIn2014
Where Merge.client_id = ClientNumIn2015.client_id and
ClientNumIn2015.client_id = ClientOneToTenIn2014.client_id;


