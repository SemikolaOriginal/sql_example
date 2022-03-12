-- Adminer 4.3.1 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';

DROP DATABASE IF EXISTS `DB`;
CREATE DATABASE `DB` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `DB`;

DELIMITER ;;

CREATE PROCEDURE `AddActivityToSchedule`(IN `date` date, IN `timeslot` int unsigned, IN `classroom` int unsigned, IN `hid` int unsigned, IN `cid` int unsigned, IN `sid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM TIMESLOTS WHERE IMESLOTS.tsid = timeslot) 
AND classroom > 0
AND EXISTS (SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid)
AND EXISTS (SELECT * FROM CLASSLIST WHERE CLASSLIST.cid = cid)
AND EXISTS (SELECT * FROM SUBJECTS WHERE SUBJECTS.sid = sid) THEN

INSERT INTO SCHEDULE (SCHEDULE.date, SCHEDULE.timeslot, SCHEDULE.classroom, SCHEDULE.hid, SCHEDULE.cid, SCHEDULE.sid)
VALUES (date, timeslot, classroom, hid, cid, sid);

END IF;

END;;

CREATE PROCEDURE `AddHumanAddress`(IN `hid` int unsigned, IN `address` varchar(256))
BEGIN

IF EXISTS (SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid) THEN

INSERT INTO ADDRESSES (ADDRESSES.hid, ADDRESSES.address)
VALUES (hid, address);

END IF;

END;;

CREATE PROCEDURE `AddHumanEmail`(IN `hid` int unsigned, IN `email` varchar(256))
BEGIN 

IF EXISTS(SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid) THEN

INSERT INTO EMAILS(EMAILS.hid, EMAILS.email)
VALUES (hid, email);

END IF;

END;;

CREATE PROCEDURE `AddHumanPhonenumber`(IN `hid` int unsigned, IN `phonenumber` varchar(20))
BEGIN

IF EXISTS(SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid) THEN

INSERT INTO PHONENUMBERS (PHONENUMBERS.hid, PHONENUMBERS.phonenumber)
VALUES (hid, phonenumbers);

END IF;

END;;

CREATE PROCEDURE `AddNewClass`(IN `design_number` int unsigned, IN `design_symbol` char(1), IN `crthid` int unsigned)
BEGIN
	IF design_number > 0 
	AND design_symbol != '' 
	AND EXISTS(SELECT PEOPLES.hid FROM PEOPLES WHERE PEOPLES.hid = crthid) THEN

		INSERT INTO CLASSLIST (CLASSLIST.design_number, CLASSLIST.design_symbol, CLASSLIST.crthid)
		VALUES (design_number, design_symbol, crthid);
	
	END IF;
END;;

CREATE PROCEDURE `AddNewHuman`(
	IN `name` varchar(50),
	IN `surname` varchar(50),
	IN `patronymic` varchar(50),
	IN `birthdate` date,
	IN `gender` enum('m','f'),
	IN `phid1` int,
	IN `phid2` int,
	IN `phonenumber` varchar(20),
	IN `address` varchar(256),
	IN `email` varchar(256)


)
    COMMENT 'Добавление нового человека в список PEOPLES'
BEGIN
	IF name != '' AND surname != '' THEN

		INSERT INTO PEOPLES (PEOPLES.name, PEOPLES.surname, PEOPLES.patronymic, PEOPLES.birthdate, PEOPLES.gender, PEOPLES.phid1, PEOPLES.phid2)
		VALUES (name, surname, patronymic, birthdate, gender, phid1, phid2);
	
		IF phonenumber != '' THEN 
			INSERT INTO PHONENUMBERS (PHONENUMBERS.hid, PHONENUMBERS.phonenumber)
			VALUES (LAST_INSERT_ID(), phonenumber);
		END IF;
	
		IF address != '' THEN 
			INSERT INTO ADDRESSES (ADDRESSES.hid, ADDRESSES.address)
			VALUES (LAST_INSERT_ID(), address);
		END IF;
	
		IF email != '' THEN 
			INSERT INTO EMAILS (EMAILS.hid, EMAILS.email)
			VALUES (LAST_INSERT_ID(), email);
		END IF;
	
	END IF;
END;;

CREATE PROCEDURE `AddNewSubject`(IN `name` varchar(50), IN `other_info` varchar(50))
BEGIN

IF NOT EXISTS (SELECT * FROM SUBJECTS WHERE SUBJECTS.name = name) THEN

INSERT INTO SUBJECTS (SUBJECTS.name, SUBJECTS.other_info)
VALUES (name, other_info);

END IF;

END;;

CREATE PROCEDURE `AddStudentToClass`(IN `cid` int unsigned, IN `hid` int unsigned)
BEGIN

IF EXISTS(SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid) 
AND EXISTS(SELECT * FROM CLASSLIST WHERE CLASSLIST.cid = cid) THEN

INSERT INTO CLASSES (CLASSES.cid, CLASSES.hid)
VALUES (cid, hid);

END IF;

END;;

CREATE PROCEDURE `BindSubjectToClass`(IN `cid` int unsigned, IN `sid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM CLASSLIST WHERE CLASSLIST.cid = cid) 
AND EXISTS (SELECT * FROM SUBJECTS WHERE SUBJECTS.sid = sid) THEN

INSERT INTO SUBJECTLIST (SUBJECTLIST.cid, SUBJECTLIST.sid)
VALUES (cid, sid);

END IF;

END;;

CREATE PROCEDURE `BindTeacherToSubject`(IN `hid` int unsigned, IN `sid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid) 
AND EXISTS (SELECT * FROM SUBJECTS WHERE SUBJECTS.sid = sid) THEN

INSERT INTO TEACHERS (TEACHERS.hid, TEACHERS.sid)
VALUES (hid, sid);

END IF;

END;;

CREATE PROCEDURE `DeleteActivityFromSchedule`(IN `idx` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) THEN

DELETE FROM SCHEDULE
WHERE SCHEDULE.idx = idx;

END IF;

END;;

CREATE PROCEDURE `DeleteHumanById`(IN `hid` int unsigned)
BEGIN
	DELETE FROM PEOPLES WHERE PEOPLES.hid = hid;
END;;

CREATE PROCEDURE `GetHumanFullname`(IN `hid` int unsigned)
BEGIN
	SELECT CONCAT(PEOPLES.Surname, ' ', PEOPLES.Name, ' ', PEOPLES.Patronymic) 
	FROM PEOPLES 
	WHERE PEOPLES.hid = hid;
END;;

CREATE PROCEDURE `GetTeacherInfo`(IN `hid` int unsigned)
BEGIN
	SELECT PEOPLES.surname, PEOPLES.name, PEOPLES.patronymic, PEOPLES.birthdate, PHONENUMBERS.phonenumber, EMAILS.email, ADDRESSES.address
	FROM PEOPLES
	INNER JOIN TEACHERS
	ON (TEACHERS.hid = hid AND PEOPLES.hid = hid)
	LEFT JOIN PHONENUMBERS
	ON (TEACHERS.hid = hid AND PHONENUMBERS.hid = hid)
	LEFT JOIN EMAILS
	ON (TEACHERS.hid = hid AND EMAILS.hid = hid)
	LEFT JOIN ADDRESSES
	ON (TEACHERS.hid = hid AND ADDRESSES.hid = hid)	;
END;;

CREATE PROCEDURE `RemoveHumanAddress`(IN `hid` int unsigned, IN `address` varchar(256))
BEGIN

IF EXISTS (SELECT * FROM ADDRESSES WHERE ADDRESSES.hid = hid AND ADDRESSES.address = address) THEN

DELETE FROM ADDRESSES 
WHERE ADDRESSES.hid = hid AND ADDRESSES.address = address;

END IF;

END;;

CREATE PROCEDURE `RemoveHumanEmail`(IN `hid` int unsigned, IN `email` varchar(25))
BEGIN

IF EXISTS(SELECT * FROM EMAILS WHERE EMAILS.hid = hid AND EMAILS.email = email) THEN

DELETE FROM EMAILS
WHERE EMAILS.hid = hid AND EMAILS.email = email;

END IF;

END;;

CREATE PROCEDURE `RemoveHumanPhonenumber`(IN `hid` int unsigned, IN `phonenumber` varchar(20))
BEGIN

IF EXISTS(SELECT * FROM PHONENUMBERS WHERE PHONENUMBERS.hid = hid AND PHONENUMBERS.phonenumber = phonenumbers) THEN

DELETE FROM PHONENUMBERS
WHERE PHONENUMBERS.hid = hid AND PHONENUMBERS.phonenumber = phonenumbers;

END IF;

END;;

CREATE PROCEDURE `RemoveStudentToClass`(IN `cid` int unsigned, IN `hid` int unsigned)
BEGIN

IF EXISTS(SELECT * FROM CLASSES WHERE CLASSES.cid = cid AND CLASSES.hid = hid) THEN

DELETE FROM CLASSES 
WHERE CLASSES.cid = cid AND CLASSES.hid = hid;

END IF;

END;;

CREATE PROCEDURE `TIMESLOTS`(IN `start_time` time, IN `end_time` time, IN `other_info` varchar(50))
BEGIN

IF NOT EXISTS (SELECT * FROM TIMESLOTS WHERE TIMESLOTS.start_time = start_time
AND TIMESLOTS.end_time = end_time) THEN

INSERT INTO TIMESLOTS (TIMESLOTS.start_time, TIMESLOTS.end_time, TIMESLOTS.other_info)
VALUES (start_time, end_time, other_info);

END IF;

END;;

CREATE PROCEDURE `UnbindSubjectFromClass`(IN `cid` int unsigned, IN `sid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SUBJECTLIST WHERE SUBJECTLIST.cid = cid AND SUBJECTLIST.sid = sid) THEN

DELETE FROM SUBJECTLIST
WHERE SUBJECTLIST.cid = cid AND SUBJECTLIST.sid = sid;

END IF;

END;;

CREATE PROCEDURE `UnbindTeacherFromSubject`(IN `hid` int unsigned, IN `sid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM TEACHERS WHERE TEACHERS.hid = hid AND TEACHERS.sid = sid) THEN

DELETE FROM TEACHERS 
WHERE TEACHERS.hid = hid AND TEACHERS.sid = sid;

END IF;

END;;

CREATE PROCEDURE `UpdateClassInActivityInSchedule`(IN `idx` int unsigned, IN `cid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) 
AND EXISTS (SELECT * FROM CLASSLIST WHERE CLASSLIST.cid = cid) THEN

UPDATE SCHEDULE
SET SCHEDULE.cid = cid
WHERE SCHEDULE.idx = idx;

END IF;

END;;

CREATE PROCEDURE `UpdateClassroomInActivityInSchedule`(IN `idx` int unsigned, IN `classroom` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) 
AND classroom > 0 THEN

UPDATE SCHEDULE
SET SCHEDULE.classroom = classroom
WHERE SCHEDULE.idx = idx;

END IF;

END;;

CREATE PROCEDURE `UpdateDateInActivityInSchedule`(IN `idx` int unsigned, IN `date` date)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) THEN

UPDATE SCHEDULE
SET SCHEDULE.date = date
WHERE SCHEDULE.idx = idx;

END IF;

END;;

CREATE PROCEDURE `UpdateHumanBirthdate`(IN `hid` int unsigned, IN `birthdate` date)
BEGIN
	IF EXISTS(SELECT PEOPLES.hid FROM PEOPLES WHERE PEOPLES.hid = hid) THEN
	
		UPDATE PEOPLES 
		SET PEOPLES.birthdate = birthdate
		WHERE PEOPLES.hid = hid;
	
	END IF;
END;;

CREATE PROCEDURE `UpdateHumanNSP`(IN `hid` int unsigned, IN `name` varchar(50), IN `surname` varchar(50), IN `patronymic` varchar(50))
BEGIN
	IF EXISTS(SELECT PEOPLES.hid FROM PEOPLES WHERE PEOPLES.hid = hid) THEN
	
		UPDATE PEOPLES 
		SET PEOPLES.name = name, PEOPLES.surname = surname, PEOPLES.patronymic = patronymic
		WHERE PEOPLES.hid = hid;
	
	END IF;
END;;

CREATE PROCEDURE `UpdateHumanParent1`(IN `hid` int unsigned, IN `phid` int unsigned)
BEGIN
	IF EXISTS(SELECT PEOPLES.hid FROM PEOPLES WHERE PEOPLES.hid = hid) THEN
	
		UPDATE PEOPLES 
		SET PEOPLES.phid1 = phid
		WHERE PEOPLES.hid = hid;
	
	END IF;
END;;

CREATE PROCEDURE `UpdateHumanParent2`(IN `hid` int unsigned, IN `phid` int unsigned)
BEGIN
	IF EXISTS(SELECT PEOPLES.hid FROM PEOPLES WHERE PEOPLES.hid = hid) THEN
	
		UPDATE PEOPLES 
		SET PEOPLES.phid2 = phid
		WHERE PEOPLES.hid = hid;
	
	END IF;
END;;

CREATE PROCEDURE `UpdateSubjectInActivityInSchedule`(IN `idx` int unsigned, IN `sid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) 
AND EXISTS (SELECT * FROM SUBJECTS WHERE SUBJECTS.sid = sid) THEN

UPDATE SCHEDULE
SET SCHEDULE.sid = sid
WHERE SCHEDULE.idx = idx;

END IF;

END;;

CREATE PROCEDURE `UpdateTeacherInActivityInSchedule`(IN `idx` int unsigned, IN `hid` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) 
AND EXISTS (SELECT * FROM PEOPLES WHERE PEOPLES.hid = hid) THEN

UPDATE SCHEDULE
SET SCHEDULE.hid = hid
WHERE SCHEDULE.idx = idx;

END IF;

END;;

CREATE PROCEDURE `UpdateTimeslotInActivityInSchedule`(IN `idx` int unsigned, IN `timeslot` int unsigned)
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.idx = idx) 
AND EXISTS (SELECT * FROM TIMESLOTS WHERE TIMESLOTS.tsid = timeslot) THEN

UPDATE SCHEDULE
SET SCHEDULE.timeslot = timeslot
WHERE SCHEDULE.idx = idx;

END IF;

END;;

DELIMITER ;

DROP TABLE IF EXISTS `ADDRESSES`;
CREATE TABLE `ADDRESSES` (
  `hid` int(11) unsigned DEFAULT NULL,
  `address` varchar(256) DEFAULT NULL,
  KEY `hid` (`hid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `CLASSES`;
CREATE TABLE `CLASSES` (
  `cid` int(11) unsigned DEFAULT NULL,
  `hid` int(11) unsigned DEFAULT NULL,
  KEY `cid` (`cid`),
  KEY `hid` (`hid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `CLASSLIST`;
CREATE TABLE `CLASSLIST` (
  `cid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `design_number` int(11) unsigned NOT NULL DEFAULT '0',
  `design_symbol` char(1) NOT NULL DEFAULT '0',
  `crthid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'classroom teacher (crt) human identificator (hid)',
  PRIMARY KEY (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;

CREATE TRIGGER `CLASSLIST_ad` AFTER DELETE ON `CLASSLIST` FOR EACH ROW
BEGIN
	DELETE FROM CLASSES WHERE CLASSES.cid = old.cid;
	DELETE FROM SUBJECTLIST WHERE SUBJECTLIST.cid = old.cid;
	
	IF EXISTS(SELECT * FROM SCHEDULE WHERE SCHEDULE.cid = old.cid) THEN
		UPDATE SCHEDULE
		SET SCHEDULE.cid = NULL
		WHERE SCHEDULE.cid = old.cid;
	END IF;
	
END;;

DELIMITER ;

DROP TABLE IF EXISTS `EMAILS`;
CREATE TABLE `EMAILS` (
  `hid` int(11) unsigned DEFAULT NULL,
  `email` varchar(256) DEFAULT NULL,
  KEY `hid` (`hid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `PEOPLES`;
CREATE TABLE `PEOPLES` (
  `hid` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'human identificator (hid)',
  `name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `patronymic` varchar(50) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `gender` enum('m','f') DEFAULT NULL,
  `phid1` int(11) unsigned DEFAULT NULL,
  `phid2` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`hid`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;


DELIMITER ;;

CREATE TRIGGER `PEOPLES_ad` AFTER DELETE ON `PEOPLES` FOR EACH ROW
BEGIN
	DELETE FROM ADDRESSES WHERE hid = old.hid;
	DELETE FROM EMAILS WHERE hid = old.hid;
	DELETE FROM PHONENUMBERS WHERE hid = old.hid;
	DELETE FROM TEACHERS WHERE hid = old.hid;
	DELETE FROM CLASSES WHERE hid = old.hid;

	UPDATE SCHEDULE SET hid = NULL WHERE hid = old.hid;
	UPDATE CLASSLIST SET crthid = NULL WHERE crthid = old.hid;
	IF EXISTS(SELECT * FROM PEOPLES WHERE phid1 = old.hid) THEN
		UPDATE PEOPLES SET phid1 = NULL WHERE phid1 = old.hid;
	END IF;
	IF EXISTS(SELECT * FROM PEOPLES WHERE phid2 = old.hid) THEN
		UPDATE PEOPLES SET phid2 = NULL WHERE phid2 = old.hid;
	END IF;
END;;

DELIMITER ;

DROP TABLE IF EXISTS `PHONENUMBERS`;
CREATE TABLE `PHONENUMBERS` (
  `hid` int(11) unsigned DEFAULT NULL,
  `phonenumber` varchar(20) DEFAULT NULL,
  KEY `hid` (`hid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `schedule`;
CREATE TABLE `schedule` (
  `idx` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `timeslot` tinyint(3) unsigned DEFAULT NULL,
  `classroom` int(10) unsigned DEFAULT NULL,
  `hid` int(10) unsigned DEFAULT NULL,
  `cid` int(10) unsigned DEFAULT NULL,
  `sid` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SUBJECTLIST`;
CREATE TABLE `SUBJECTLIST` (
  `cid` int(11) unsigned DEFAULT NULL,
  `sid` int(11) unsigned DEFAULT NULL,
  KEY `cid` (`cid`),
  KEY `sid` (`sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects` (
  `sid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT '',
  `other_info` varchar(50) DEFAULT '',
  PRIMARY KEY (`sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;

CREATE TRIGGER `subjects_ad` AFTER DELETE ON `subjects` FOR EACH ROW
BEGIN

DELETE FROM TEACHERS
WHERE TEACHERS.sid = old.sid;

DELETE FROM SUBJECTLIST
WHERE SUBJECTLIST.sid = old.sid;

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.sid = old.sid) THEN

UPDATE SCHEDULE
SET SCHEDULE.sid = NULL
WHERE SCHEDULE.sid = old.sid;

END IF;

END;;

DELIMITER ;

DROP TABLE IF EXISTS `TEACHERS`;
CREATE TABLE `TEACHERS` (
  `hid` int(11) unsigned DEFAULT NULL,
  `sid` int(11) unsigned DEFAULT NULL,
  KEY `hid` (`hid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `timeslots`;
CREATE TABLE `timeslots` (
  `tsid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `start_time` time NOT NULL DEFAULT '00:00:00',
  `end_time` time NOT NULL DEFAULT '00:00:00',
  `other_info` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`tsid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;

CREATE TRIGGER `timeslots_ad` AFTER DELETE ON `timeslots` FOR EACH ROW
BEGIN

IF EXISTS (SELECT * FROM SCHEDULE WHERE SCHEDULE.timeslot = old.tsid) THEN

UPDATE SCHEDULE 
SET SCHEDULE.timeslot = NULL
WHERE SCHEDULE.timeslot = old.tsid;

END IF;

END;;

DELIMITER ;

-- 2022-03-06 06:08:29
