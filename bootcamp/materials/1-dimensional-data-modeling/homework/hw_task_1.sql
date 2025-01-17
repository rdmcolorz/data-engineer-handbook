-- DDL for actors table:
-- Create a DDL for an actors table with the following fields:

create type quality_class as enum (
	'star',
	'good',
	'average',
	'bad'
);

drop type film_meta cascade;
create type film_meta as (
	film text,
	votes int4,
	rating float4,
	filmid text
);


drop table actors;


create table actors (
	actorid text not null,
	films film_meta[] not null,
	quality_class quality_class,
	is_active boolean,
	current_year integer,
	primary key(actorid, current_year)
);
