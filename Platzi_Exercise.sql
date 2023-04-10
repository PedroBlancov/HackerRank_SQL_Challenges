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
