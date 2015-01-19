-- ==========================================================================
-- File:	facebooklet-loader.sql
-- Author:	John Morgan
-- Created:	2011-01-09
-- Description:	Procedure to populate the facebooklet tables
-- ==========================================================================

-- 1) put this script, facebooklet-model.sql, and facebooklet-drop.sql in a directory
-- 2) launch the mysql client from that directory
-- 3) execute: source facebooklet-drop.sql
-- 4) execute: source facebooklet-model.sql
-- 5) execute: source facebooklet-loader.sql
-- 6) execute: call fbt_loader_setup();
-- 7) execute: call fbt_loader();
-- 8) sit back and relax while this "high performance" code works its magic

-- if the procedure already exists, replace it with this version
drop procedure if exists fbt_loader_setup;
drop procedure if exists fbt_loader;

-- change the delimiter so we can still use semi-colons in our definition
delimiter //

create procedure fbt_loader_setup ()
begin
	-- set up example data

	-- add 400 users
	create temporary table first_names (first varchar(50));
	create temporary table last_names (last varchar(50));

	insert into first_names values
		('James'),('John'),('Robert'),('Michael'),('Mary'),('William'),('David'),
		('Richard'),('Charles'),('Joseph'),('Thomas'),('Patricia'),('Christopher'),
		('Linda'),('Barbara'),('Daniel'),('Paul'),('Mark'),('Elizabeth'),('Jennifer');

	insert into last_names values
		('Smith'),('Johnson'),('Williams'),('Jones'),('Brown'),('Davis'),('Miller'),
		('Wilson'),('Moore'),('Taylor'),('Anderson'),('Thomas'),('Jackson'),
		('White'),('Harris'),('Martin'),('Thompson'),('Garcia'),('Martinez'),('Robinson');

	insert into users (first_names,last_name,email,password_hash,creation_date) select
		first,last,concat(first,".",last,"@aol.com"),
		"5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8",
		from_unixtime(unix_timestamp('2009-01-01 00:00:00')+floor(rand()*31536000))
		from first_names, last_names;

	drop table first_names, last_names;

	-- add colleges as groups

	create temporary table temp_groups (title varchar(255));

	insert into temp_groups (title) values
		('Brown University'),('Columbia University'),('Cornell University'),
		('Dartmouth College'),('Harvard University'),('Princeton University'),
		('University of Pennsylvania'),('Yale University'),('Carnegie Mellon University'),
		('Duke University'),('Johns Hopkins University'),('New York University'),
		('Northwestern University'),('Tufts University'),('Washington University in St. Louis'),
		('Wellesley College'),('Williams College'),('Massachusetts Institute of Technology'),
		('California Institute of Technology'),('Franklin W. Olin College of Engineering');

	insert into groups (title,creation_date) select
		title, from_unixtime(unix_timestamp('2009-01-01 00:00:00')+floor(rand()*31536000))
		from temp_groups;

	drop table temp_groups;

	-- add movies as likes

	insert into likes (topic) values
		('The Shawshank Redemption'),('The Godfather'),('The Godfather: Part II'),
		('The Good, the Bad and the Ugly'),('Pulp Fiction'),('Inception'),('Schindler\'s List'),
		('12 Angry Men'),('One Flew Over the Cuckoo\'s Nest'),('The Dark Knight'),
		('Star Wars: Episode V - The Empire Strikes Back'),('The Lord of the Rings: The Return of the King'),
		('Seven Samurai'),('Star Wars: Episode IV - A New Hope'),('Fight Club'),('Goodfellas'),('Casablanca'),
		('City of God'),('The Lord of the Rings: The Fellowship of the Ring'),('Once Upon a Time in the West'),
		('Rear Window'),('Raiders of the Lost Ark'),('Psycho'),('The Matrix'),('The Usual Suspects'),
		('The Silence of the Lambs'),('Toy Story 3'),('Se7en'),('It\'s a Wonderful Life'),('Memento'),
		('The Lord of the Rings: The Two Towers'),('Sunset Blvd.'),('Forrest Gump'),('The Professional'),
		('Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb'),('Apocalypse Now'),
		('Citizen Kane'),('North by Northwest'),('American Beauty'),('American History X'),('Taxi Driver'),
		('Terminator 2: Judgment Day'),('Saving Private Ryan'),('Vertigo'),('Amelie'),('Alien'),('WALL-E'),
		('Black Swan'),('Spirited Away'),('The Shining');

	-- statuses

	create temporary table fbt_loader_status_phrases_1 (
       		status_prefix     varchar(100) not null
	);

	create temporary table fbt_loader_status_phrases_2 (
	       status_suffix     varchar(100) not null
	);

	insert into fbt_loader_status_phrases_1 (status_prefix) values
		('I am really enjoying'),
		('I am just arriving'),
		('I am just finishing'),
		('My mother would be proud of me for doing'),
		('My dog and I are leaving'),
		('My dog and I are walking'),
		('Just took the best photo while engaged in'),
		('Heard the best song just before leaving'),
		('Am really hoping to create'),
		('The weather here is making it difficult for continuing');

	insert into fbt_loader_status_phrases_2 (status_suffix) values
		('Chinese food in the bedroom'),
		('a portrait of of Pamela Anderson'),
		('research into whether Borat or Citizen Kane should be considered the greatest film'),
		('a very thoughtful film starring Pamela Anderson'),
		('a 1000-page literary biography of Pamela Anderson'),
		('a major motion picture about my own life'),
		('an exciting comprehensive two-page study of social life at MIT'),
		('a political system where I get to vote for the same folks every year or two'),
		('a relatively rat-free restaurant in Central Square'),
		('a road bike ride to a urology office in Burlington, Vermont');

	create temporary table status_possibilities as select status_prefix,status_suffix from
		fbt_loader_status_phrases_1,fbt_loader_status_phrases_2;
end//


create procedure fbt_loader ()
begin
	-- holds user_id from the cursor
	declare current_user_id int;

	-- cursor/outer loop control variables
	declare loop_done boolean;
	declare loop_counter int default 0;
	declare loop_rows int default 0;

	-- inner loop variables
	declare friend_counter int default 1;
	declare friend_total int default 0;
	declare status_counter int default 1;
	declare status_total int default 0;

	-- create the cursor
	declare user_cursor cursor for select user_id from users;

	-- handle end of loop condition
	declare continue handler for not found set loop_done=true;

	-- get the number of users
	open user_cursor;
 	select found_rows() into loop_rows;

	-- start the outer loop (iterating users)
	users_loop: loop
		-- get the current_user_id
		fetch user_cursor into current_user_id;
		if loop_done then
			close user_cursor;
			leave users_loop;
		end if;

		-- note: using order by rand() because it is simple and we
		-- only have 20/50 groups/likes in our example data set
		-- performance is not great but this is only run once

		-- put people into groups
		-- 100% of people have at least 1 group (approx 50% have just one)
		insert into group_memberships (user_id, group_id) select
			current_user_id, group_id from groups order by rand() limit 1;

		if round(rand())=0 then
			-- 50% of people have at least 2 groups (approx 25% have just two)
			insert into group_memberships (user_id, group_id) select
				current_user_id, group_id from groups where group_id not in
				(select group_id from group_memberships where user_id=current_user_id)
				order by rand() limit 1;

			if round(rand())=0 then
				-- approx 25% of people have 3 groups
				insert into group_memberships (user_id, group_id) select
					current_user_id, group_id from groups where group_id not in
					(select group_id from group_memberships where user_id=current_user_id)
					order by rand() limit 1;
			end if;
		end if;

		-- give everyone 5 likes
		insert into user_like_map (user_id, like_id) select
			current_user_id, like_id from likes order by rand() limit 5;

		-- randomly generate between 1 and 5 friend requests from each user
		-- if each user does this everyone should have 2-10 friends in total
		set friend_total=round(rand()*4)+1;
		while friend_counter <= friend_total do
			insert into friendships (from_user_id, to_user_id, creation_date) select
				current_user_id, user_id,
				from_unixtime(unix_timestamp('2009-01-01 00:00:00')+floor(rand()*31536000))
				from users where (user_id<>current_user_id) and
				user_id not in (select from_user_id from friendships where to_user_id=current_user_id) and
				user_id not in (select to_user_id from friendships where from_user_id=current_user_id)
				order by rand() limit 1;
			set friend_counter=friend_counter+1;
		end while;

		-- accept friend requests after a random amount of time that's less than one week
		update friendships set accepted=from_unixtime(unix_timestamp(creation_date)+floor(rand()*604800));

		-- randomly generate between 2 and 5 statuses for each user
		set status_total=round(rand()*3)+2;
		while status_counter <= status_total do
			insert into status_updates (user_id, message, creation_date) select
				current_user_id, concat(status_prefix," ",status_suffix),
				from_unixtime(unix_timestamp('2010-01-01 00:00:00')+floor(rand()*31536000))
				from status_possibilities where concat(status_prefix," ",status_suffix) not in
				(select message from status_updates where user_id=current_user_id)
				order by rand() limit 1;
			set status_counter=status_counter+1;
		end while;

		-- increment the loop_counter and reset inner loop variables
		set loop_counter=loop_counter+1;
		set friend_counter=1;
		set status_counter=1;
	end loop users_loop;

	drop table fbt_loader_status_phrases_1,fbt_loader_status_phrases_2,status_possibilities;
end//

-- set the delimeter back to the default
delimiter ;
