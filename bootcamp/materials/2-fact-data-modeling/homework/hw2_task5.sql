-- A DDL for `hosts_cumulated` table 
-- a `host_activity_datelist` which logs to see which dates each host is experiencing any activity

drop table hosts_cumulated;
create table hosts_cumulated(
	host text,
	host_activity_datelist date[],
	last_date date
);