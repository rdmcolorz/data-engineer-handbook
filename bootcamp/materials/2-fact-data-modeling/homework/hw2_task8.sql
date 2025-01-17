-- An incremental query that loads `host_activity_reduced`
  -- day-by-day

with daily_agg as (
	select
		host,
		date(event_time) as date,
		count(1) as num_site_hits,
		count(distinct user_id) as unique_visitors
	from events e
	where date(event_time) = date('2023-1-3')
	group by host, date(event_time)
), yesterday_array as (
	select * from host_activity_reduced
	where month = date('2023-1-1')
)
insert into host_activity_reduced
select
	coalesce(d.host, y.host),
	coalesce(y.month, date_trunc('month', d.date)) as month,
	case
		when y.hit_array is not null
			then y.hit_array || array[coalesce(d.num_site_hits, 0)]
		when y.hit_array is null
			then array_fill(0, array[coalesce(date - month, 0)]) || array[coalesce(d.num_site_hits, 0)]
	end as hit_array,
	case
		when y.unique_visitors is not null
			then y.unique_visitors || array[coalesce(d.unique_visitors, 0)]
		when y.unique_visitors is null
			then array_fill(0, array[coalesce(date - month, 0)]) || array[coalesce(d.unique_visitors, 0)]
	end as unique_visitors
from daily_agg d
full outer join yesterday_array y
	on d.host = y.host
on conflict (host, month)
do
	update set (hit_array, unique_visitors) = (excluded.hit_array, excluded.unique_visitors);
