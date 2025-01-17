-- Incremental query for actors_history_scd: 
-- Write an "incremental" query that combines the previous year's SCD data with new
-- incoming data from the actors table.



CREATE type actor_scd_type AS (
    quality_class quality_class,
    is_active boolean,
    start_date INTEGER,
    end_date INTEGER
);


WITH last_year_films_scd AS (
    SELECT * FROM actors_history_scd
    WHERE current_year = 2020
    AND end_date = 2020
),
historical_scd AS (
    select
    	actorid,
    	start_date,
       	end_date,
       	quality_class,
       	is_active
    FROM actors_history_scd
    where current_year = 2020
    	and end_date < 2020
),
this_year_films AS (
     SELECT * FROM actors
     WHERE current_year = 2021
),
unchanged_records AS (
	SELECT
    	ts.actorid,
    	ls.start_date,
	    ts.current_year as end_date,
	    ts.quality_class,
	    ts.is_active
FROM this_year_films ts
JOIN last_year_films_scd ls
	ON ls.actorid = ts.actorid
		 WHERE ts.quality_class = ls.quality_class
		 AND ts.is_active = ls.is_active
 ),
 changed_records AS (
    SELECT
        ts.actorid,
        UNNEST(ARRAY[
        	ROW(
	            ls.quality_class,
	            ls.is_active,
	            ls.start_date,
	            ls.end_date
	        )::actor_scd_type,
	        ROW(
                ts.quality_class,
                ts.is_active,
                ts.current_year,
                ts.current_year
            )::actor_scd_type
        ]) as records
    FROM this_year_films ts
    LEFT JOIN last_year_films_scd ls
    ON ls.actorid = ts.actorid
     WHERE (ts.quality_class <> ls.quality_class
      OR ts.is_active <> ls.is_active)
 ),
 unnested_changed_records AS (
     select
     	actorid,
        (records::actor_scd_type).start_date,
        (records::actor_scd_type).end_date,
        (records::actor_scd_type).quality_class,
        (records::actor_scd_type).is_active
        FROM changed_records
),
new_records AS (
     SELECT
    	ts.actorid,
        ts.current_year AS start_date,
        ts.current_year AS end_date,
        ts.quality_class,
        ts.is_active
     FROM this_year_films ts
     LEFT JOIN last_year_films_scd ls
         ON ts.actorid = ls.actorid
     WHERE ls.actorid IS NULL
 )
SELECT *, 2021 as current_year FROM (
      SELECT *
      FROM historical_scd
      UNION ALL
      SELECT *
      FROM unchanged_records
      UNION ALL
      SELECT *
      FROM unnested_changed_records
      UNION ALL
      SELECT *
      FROM new_records
 ) a