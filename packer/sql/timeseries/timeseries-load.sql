-- ==========================================================================
-- File:	populate-visits.sql
-- Author:	John Morgan
-- Created:	2011-01-08
-- Updated:	2015-01-17
-- Description:	Procedure to populate the ts_visits table with random data
-- ==========================================================================

create table ts_users (
	user_id	int not null primary key auto_increment,
	-- cannot be null, no numbers please
      -- in Oracle 11g we'd add CHECK ( regexp_like(name, '^([a-zA-Z ])+$') )
	name		varchar(100) not null, 
	-- can be null, but only numbers please (except in MySQL
	-- which doesn't respect CHECK constraints)
	telephone	varchar(20) check (upper(telephone) = lower(telephone))
);

create table ts_visits (
	visit_id		int not null primary key auto_increment,
	user_id	int not null,
	-- store visit time precise to the second
	visit_time	timestamp default current_timestamp,
	foreign key (user_id) references ts_users(user_id) on delete cascade
);

-- note: we use the prefix "ts_" to avoid interference with the
-- real Facebooklet data model
-- the ON DELETE CASCADE causes rows in this table to disappear when the 
-- corresponding user is deleted


-- if the procedure already exists, replace it with this version
drop procedure if exists populate_visits;

-- change the delimiter so we can still use semi-colons in our definition
delimiter //

-- inputs: number of visits to generate per user, the start timestamp, and the length of the timespan in seconds
create procedure populate_visits (in visits_per_user int, in start_date timestamp, in time_period_seconds int)
begin
	-- holds user_id from the cursor
	declare current_user_id int;

	-- cursor/outer loop control variables
	declare loop_done boolean;
	declare loop_counter int default 0;
	declare loop_rows int default 0;

	-- inner loop counter
	declare visit_counter int default 1;

	-- create the cursor
	declare user_cursor cursor for select user_id from ts_users;

	-- handle end of loop condition
	declare continue handler for not found set loop_done=true;

	-- create a temporary table for storing entries in
	create temporary table temp_visits (temp_user_id int, temp_visit_time timestamp);

	-- get the number of users
	open user_cursor;
 	select found_rows() into loop_rows;

	-- start the outer loop (iterating users)
	visits_loop: loop
		-- get the current_user_id
		fetch user_cursor into current_user_id;
		if loop_done then
			close user_cursor;
			leave visits_loop;
		end if;

		-- insert some visit data for this user into our temp table
		while visit_counter <= visits_per_user do
			insert into temp_visits (temp_user_id, temp_visit_time) values
				(current_user_id,
				-- make a random timestamp sometime between start_date and start_date+time_period_seconds
				from_unixtime(unix_timestamp(start_date)+floor(rand()*time_period_seconds)));
			set visit_counter=visit_counter+1;
		end while;

		-- increment the loop_counter and reset the visit_counter
		set loop_counter=loop_counter+1;
		set visit_counter=1;
	end loop visits_loop;

	-- sort the data by timestamp and insert it into the ts_visits table
	insert into ts_visits (user_id, visit_time) select temp_user_id, temp_visit_time from temp_visits order by temp_visit_time;

	-- drop the temporary table
	drop table temp_visits;
end//

-- set the delimeter back to the default
delimiter ;


-- add the users and populate with visit data
insert into ts_users (name) values ('moe'),('larry'),('curly');
-- add 40 visits per user for the time period starting 1/1/2014 and going for 365 days
call populate_visits (40, TIMESTAMP("2014-01-01"), (365*24*60*60));

