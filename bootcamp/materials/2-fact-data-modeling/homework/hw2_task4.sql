-- A `datelist_int` generation query.
-- Convert the `device_activity_datelist` column into a `datelist_int` column 


with users as (
	select *
	from user_devices_cumulated udc 
	where last_date = date('2023-01-31')
),
series as (
	select * 
	from generate_series(date('2023-01-01'), date('2023-1-31'), interval '1 day') as series_date
),
placeholder_ints as (
	select
		case when dates_activity_datelist @> array [date(series_date)]
			then cast(pow(2, 32 - (last_date - date(series_date))) as bigint) else 0
		end as placeholder_int_value,
		*
	from users u
	cross join series s
)
select
	user_id,
	browser_type,
	cast(sum(placeholder_int_value) as bigint) as datelist_int,
	last_date
from placeholder_ints
group by user_id, browser_type, last_date;