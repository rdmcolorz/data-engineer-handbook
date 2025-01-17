-- A cumulative query to generate `device_activity_datelist` from `events`


with yesterday as (
	select * from user_devices_cumulated
	where last_date = date('2023-1-9')
), today as (
	select
		user_id,
		d.browser_type,
		date(cast(event_time as timestamp)) as date_active
	from events e
	left join devices d
		on e.device_id = d.device_id
	where date(cast(event_time as timestamp)) = date('2023-1-10')
		and user_id is not null
		and browser_type is not null
	group by user_id, browser_type, date(cast(event_time as timestamp))
)
insert into user_devices_cumulated
select
	coalesce(t.user_id, y.user_id) as user_id,
	coalesce(t.browser_type, y.browser_type) as browser_type,
	case when y.dates_activity_datelist is null
		then array[t.date_active]
		when t.date_active is null then y.dates_activity_datelist
		else array[t.date_active] || y.dates_activity_datelist 
	end as dates_activity_datelist,
	coalesce(t.date_active, y.last_date + interval '1 day') as last_date
from today t
full outer join yesterday y 
	on t.user_id = y.user_id
	and t.browser_type = y.browser_type;