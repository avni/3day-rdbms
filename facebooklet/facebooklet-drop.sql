--
-- facebooklet-drop.sql
--
-- by John Morgan, January 2011
--
-- clean up if desired
--

SET foreign_key_checks = 0;
DROP TRIGGER archive_defriending;
DROP TRIGGER friendship_key;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS status_updates;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS user_like_map;
DROP TABLE IF EXISTS group_memberships;
DROP TABLE IF EXISTS friendships;
DROP TABLE IF EXISTS defriends;
DROP TABLE IF EXISTS fbt_loader_status_phrases_1;
DROP TABLE IF EXISTS fbt_loader_status_phrases_2;
DROP TABLE IF EXISTS status_possibilities;
SET foreign_key_checks = 1;
