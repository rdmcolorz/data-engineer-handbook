-- The incremental query to generate `host_activity_datelist`

do $$
declare d date;
begin
for d in select generate_series(date('2022-12-31'), date('2023-1-30'), '1 day') loop
	with yesterday as (
		select * from hosts_cumulated
		where last_date = d
	), today as (
		select
			host,
			date(cast(event_time as timestamp)) as date_active
		from events e
		where date(cast(event_time as timestamp)) = d + interval '1 day'
			and host is not null
		group by host, date(cast(event_time as timestamp))
	)
	insert into hosts_cumulated
	select
		coalesce(t.host, y.host) as host,
		case when y.host_activity_datelist is null
			then array[t.date_active]
			when t.date_active is null then y.host_activity_datelist
			else array[t.date_active] || y.host_activity_datelist 
		end as host_activity_datelist,
		coalesce(t.date_active, y.last_date + interval '1 day') as last_date
	from today t
	full outer join yesterday y 
		on t.host = y.host;
end loop;
end $$


select * from hosts_cumulated;