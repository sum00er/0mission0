
CREATE TABLE IF NOT EXISTS `mission` (
  `identifier` varchar(50) DEFAULT NULL,
  `mission_id` int(10) unsigned DEFAULT NULL,
  `max` int(10) unsigned DEFAULT NULL,
  `porgress` int(10) unsigned DEFAULT 0,
  `finish` tinyint(3) unsigned DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
