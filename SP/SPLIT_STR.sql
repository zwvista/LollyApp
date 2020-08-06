﻿DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `SPLIT_STR`(`x` TEXT CHARSET utf8, `delim` VARCHAR(12) CHARSET utf8, `pos` INT) RETURNS text CHARSET utf8
RETURN REPLACE(SUBSTRING( SUBSTRING_INDEX(x, delim, pos), CHAR_LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1), delim, '')$$
DELIMITER ;