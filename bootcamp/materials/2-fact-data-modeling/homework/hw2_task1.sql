-- A query to deduplicate `game_details` from Day 1 so there's no duplicates

with deduped as (
	select 
		gd.*,
		row_number() over(partition by gd.game_id, gd.team_id, gd.player_id) as row_number 
	from game_details gd 
)
select *
from deduped
where row_number = 1;