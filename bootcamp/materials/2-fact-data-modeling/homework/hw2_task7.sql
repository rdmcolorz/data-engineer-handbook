-- A monthly, reduced fact table DDL `host_activity_reduced`
   -- month
   -- host
   -- hit_array - think COUNT(1)
   -- unique_visitors array -  think COUNT(DISTINCT user_id)

drop table host_activity_reduced;
create table host_activity_reduced(
	host text,
	month date,
	hit_array int[],
	unique_visitors text[]
);