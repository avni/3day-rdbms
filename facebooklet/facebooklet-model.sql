--
-- facebooklet-model.sql
--
-- by John Morgan and Shimon Rura 
-- for http://philip.greenspun.com/teaching/three-day-rdbms/
--
-- January 2011
--
-- compatible with MySQL
--

CREATE TABLE users (
     user_id             INT PRIMARY KEY AUTO_INCREMENT,
     first_names         VARCHAR(255) NOT NULL,
     last_name           VARCHAR(255) NOT NULL,
-- due to MySQL's case-insensitive comparisons, this prevents
-- duplicates such as "foo@bar.com" and "FOO@BAR.COM"
     email               VARCHAR(255) NOT NULL UNIQUE,
     password_hash       CHAR(40) NOT NULL,
     creation_date       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_updates (
     status_id           INT PRIMARY KEY AUTO_INCREMENT,
     user_id             INT NOT NULL,
     creation_date       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     message             TEXT,
     url                 VARCHAR(255),
     photo               BLOB,
     mime_type           ENUM('image/jpeg','image/gif'),
     FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- add support for png images
ALTER TABLE status_updates MODIFY mime_type
ENUM('image/jpeg','image/gif','image/png');


CREATE TABLE likes (
     like_id             INT PRIMARY KEY AUTO_INCREMENT,
     topic               VARCHAR(255) NOT NULL UNIQUE
);


-- using alter to add a creation_date column to the likes table
ALTER TABLE likes ADD
creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- adding _map to the end of this table's name is one way
-- to signify that its purpose is mapping users to likes
CREATE TABLE user_like_map (
     user_id             INT NOT NULL,
     like_id             INT NOT NULL,
     PRIMARY KEY (user_id, like_id),
     FOREIGN KEY (user_id) REFERENCES users(user_id),
     FOREIGN KEY (like_id) REFERENCES likes(like_id)
);

-- the primary key index will make it fast to ask "show me what User 37 likes"
-- now we need an index to make it fast to ask "show me who likes Madonna"

CREATE INDEX user_likes_by_like_id ON user_like_map ( like_id );

CREATE TABLE groups (
     group_id            INT PRIMARY KEY AUTO_INCREMENT,
     title               VARCHAR(255) NOT NULL UNIQUE,
     is_university       BOOLEAN NOT NULL DEFAULT TRUE,
     creation_date       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_memberships (
     user_id             INT NOT NULL,
     group_id            INT NOT NULL,
     FOREIGN KEY (user_id) REFERENCES users(user_id),
     FOREIGN KEY (group_id) REFERENCES groups(group_id)
);



-- PG: I think we will need user_id_smaller and user_id_greater
--     and initiating_user_id and a trigger that checks that smaller < greater
--     and that initiating is one of the two. OR we need to have a trigger 
--     that creates a decimal number of the greater and smaller and then 
--     we have a unique constraint on that. Call that column unique_key or 
--     something, e.g., if users 37 and 9923 are friends, the unique key is 
--     9923.37
-- AG: I vote for the unique_key approach

CREATE TABLE friendships (
	unique_key        VARCHAR(21) NOT NULL,
from_user_id      INT NOT NULL,
to_user_id        INT NOT NULL,
creation_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
accepted          TIMESTAMP NULL, -- set this when to_user accepts
-- Note: TIMESTAMPs are special in mysql, and are NOT NULL by default.
-- We intend to use NULL values here to signify unaccepted friend reqs,
-- so we have to explicitly say so.
PRIMARY KEY (unique_key),
FOREIGN KEY (from_user_id) REFERENCES users(user_id),
FOREIGN KEY (to_user_id) REFERENCES users(user_id)
);

-- trigger to populate the unique_key
delimiter $$
create trigger friendship_key before insert on friendships
    for each row begin
        if new.from_user_id<new.to_user_id then
            set new.unique_key=
                concat(new.from_user_id,".",new.to_user_id);
        elseif new.to_user_id<new.from_user_id then
            set new.unique_key=
                concat(new.to_user_id,".",new.from_user_id);
        else
            signal sqlstate '45000'
                set message_text='user cannot friend self';
        end if;
    end;
$$
delimiter ;

CREATE TABLE defriends (
     -- mostly the same as friendships, plus heartbreak_date

     heartbreak_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     -- Note: in mysql, a default value may be specified only for the FIRST
     -- TIMESTAMP column in a table definition. That's why we list this
     -- column first and have removed DEFAULT CURRENT_TIMESTAMP from the
     -- creation_date column below.
     -- See http://dev.mysql.com/doc/refman/5.5/en/timestamp.html

     from_user_id        INT NOT NULL,
     to_user_id          INT NOT NULL,
     creation_date       TIMESTAMP NOT NULL, 
     accepted            TIMESTAMP NULL,
     UNIQUE(from_user_id, to_user_id),
     FOREIGN KEY (from_user_id) REFERENCES users(user_id),
     FOREIGN KEY (to_user_id) REFERENCES users(user_id)
);


-- Note: we need to override the mysql client's delimiter setting so it
-- doesn't send the whole statement when it reaches the ; inside of the 
-- BEGIN ... END block.
DELIMITER $$
CREATE TRIGGER archive_defriending BEFORE DELETE ON friendships 
    FOR EACH ROW BEGIN
        INSERT INTO defriends (from_user_id, to_user_id, 
                                   creation_date, accepted)
        VALUES (OLD.from_user_id, OLD.to_user_id, 
                OLD.creation_date, OLD.accepted);
    END $$
DELIMITER ;
