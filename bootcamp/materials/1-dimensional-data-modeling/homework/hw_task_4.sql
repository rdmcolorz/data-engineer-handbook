-- Backfill query for actors_history_scd: 
-- Write a "backfill" query that can populate the entire actors_history_scd table in a single query.

-- I want to see how the actors moive rating improve throughout the years, in this case using
-- quality_class to eval in that year


insert into actors_history_scd
with with_previous as (
	select
		actorid,
		actor,
		films,
		current_year,
		quality_class,
		is_active,
		lag(quality_class, 1) over (partition by actorid order by current_year) as previous_quality_class,
		lag(is_active, 1) over (partition by actorid order by current_year) as previous_is_active,
		max(year) as latest_year
	from actors a 
),
with_indicators as (
	select *,
		case when quality_class <> previous_quality_class then 1 
			when is_active <> previous_is_active then 1
			else 0
		end as change_indicator
	from with_previous
),
with_streaks as (
	select *,
		sum(change_indicator) over (partition by actorid order by current_year) as streak_identifier
	from with_indicators
)
select
	actorid,
	min(current_year) as start_date,
	max(current_year) as end_date,
	quality_class,
	is_active,
	2021 as current_year
from with_streaks
group by actorid, actor, streak_identifier, is_active, quality_class
order by actorid, streak_identifier;

