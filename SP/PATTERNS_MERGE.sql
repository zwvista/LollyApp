DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PATTERNS_MERGE`(IN `P_IDS` TEXT CHARSET utf8, IN `P_PATTERN` TEXT CHARSET utf8, IN `P_NOTE` TEXT CHARSET utf8, IN `P_TAGS` TEXT CHARSET utf8)
    NO SQL
BEGIN
    DECLARE n INT Default 0;
    DECLARE idstr TEXT CHARSET utf8;
    DECLARE id1 INT Default 0;
    simple_loop: LOOP
        SET n = n + 1;
        SET idstr = SPLIT_STR(P_IDS, ",", n);
        IF idstr = '' THEN
            LEAVE simple_loop;
        END IF;
        IF n = 1 THEN
            SET id1 = idstr;
            UPDATE PATTERNS SET PATTERN = P_PATTERN, NOTE = P_NOTE, TAGS = P_TAGS WHERE ID = idstr;
        ELSE
            DELETE FROM PATTERNS WHERE ID = idstr;
            UPDATE PATTERNSWEBPAGES SET PATTERNID = id1 WHERE PATTERNID = idstr;
        END IF;
    END LOOP simple_loop;
    SELECT '0' AS result;
END$$
DELIMITER ;