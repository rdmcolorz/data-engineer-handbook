-- DDL for actors_history_scd table: Create a DDL for an actors_history_scd table with the following features:
-- Implements type 2 dimension modeling (i.e., includes start_date and end_date fields).
-- Tracks quality_class and is_active status for each actor in the actors table.


drop table actors_history_scd;
create table actors_history_scd (
	actorid text,
	start_date integer,
	end_date integer,
	quality_class quality_class,
	is_active boolean,
	current_year integer
);