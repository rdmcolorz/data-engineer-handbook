-- A DDL for an `user_devices_cumulated` table that has:
-- a `device_activity_datelist` which tracks a users active days by `browser_type`
-- data type here should look similar to `MAP<STRING, ARRAY[DATE]>`
-- or you could have `browser_type` as a column with multiple rows for each user (either way works, just be consistent!)


drop table user_devices_cumulated;
create table user_devices_cumulated (
	user_id bigint,
	browser_type text,
	dates_active date[],
	last_date date
);
