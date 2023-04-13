SELECT * FROM venue LIMIT 10;
SELECT COUNT(0) FROM venue;
SELECT COUNT(*) FROM listing;
SELECT COUNT(*) FROM cartesian_venue;

SELECT venueid, venuename, venuecity, venuestate, venueseats
FROM venue
LIMIT 10;

CREATE TABLE cartesian_venue as(
SELECT venueid, venuename, venuecity, venuestate, venueseats
FROM venue, listing);

SELECT *
FROM cartesian_venue
LIMIT 10;

CREATE TABLE encoding_venue (
nameraw varchar(100) encode raw,
namebytedict varchar(100) encode bytedict,
namelzo varchar(100) encode lzo,
namerunlength varchar(100) encode runlength,
nametext255 varchar(100) encode text255,
nametext32k varchar(100) encode text32k,
namezstd varchar(100) encode zstd
);

INSERT INTO encoding_venue 
(
SELECT venuename, venuename, venuename, venuename, venuename, venuename, venuename
FROM cartesian_venue 
);

SELECT * FROM encoding_venue LIMIT 10;

SELECT COUNT(0)
FROM encoding_venue;
------------------------------------------------------------------
-- Homework
select distinct venueseats from venue;

create table encoding_venue_seats (
	venue_seats_raw integer encode raw,
	venue_seats_az64 integer encode az64,
	venue_seats_bytedict integer encode bytedict,
	venue_seats_lzo integer encode lzo,
	venue_seats_runlength integer encode runlength,
	venue_seats_mostly8 integer encode mostly8,
	venue_seats_mostly16 integer encode mostly16,
	venue_seats_mostly32 bigint encode mostly32,
	venue_seats_zstd integer encode zstd
)

insert into encoding_venue_seats (
	select venueseats, venueseats, venueseats, venueseats, 
			venueseats, venueseats, venueseats, venueseats,
			venueseats
	from cartesian_venue
)

select * from encoding_venue_seats limit 20;
select count(0) from encoding_venue_seats ;
-- Review the encoding size

-- Check identifier of the table - 110055
select * from stv_tbl_perm where name = 'encoding_venue_seats';

select col, max(blocknum) 
from pg_catalog.stv_blocklist 
where tbl = 110055 and col <= 8
group by col;


analyze compression cartesian_venue;

-- Result zstd is the most properly algorithm to compress seats data
