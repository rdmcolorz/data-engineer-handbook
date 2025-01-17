-- Cumulative table generation query:
-- Write a query that populates the actors table one year at a time.


with last_year_films as (
	select *
	from actors
	where current_year = 1970
),
this_year_films AS (
	SELECT
		actorid,
		ARRAY_AGG(
			case when film is not null
				then row(
					film,
					votes,
					rating,
					filmid
				)::film_meta
			end
		) films,
		case
			when avg(rating) > 8 THEN 'star'
	        WHEN avg(rating) > 7 THEN 'good'
	        WHEN avg(rating) > 6 THEN 'average'
	    	else 'bad'
	    end::quality_class as quality_class,
		max(year) AS current_year,
		TRUE as is_active
	FROM actor_films
	WHERE YEAR = 1971
	GROUP BY actorid
)
insert into actors
select
	COALESCE(ly.actorid, ty.actorid) AS actorid,
	coalesce(ty.films, array[]::film_meta[]) as films,
	ty.quality_class,
	coalesce(ty.is_active, false) as is_active,
	1971 as current_year
from last_year_films ly
FULL OUTER JOIN this_year_films ty
	ON ly.actorid = ty.actorid;