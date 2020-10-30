BEGIN
    DECLARE UWOLDCNT INT;
    DECLARE LWOLDWORD TEXT CHARSET utf8;
    DECLARE result TEXT;
    DECLARE NEW_WORDID INT;
    DECLARE LWNEWCNT INT;

    SELECT COUNT(*) INTO UWOLDCNT FROM UNITWORDS WHERE WORDID = P_WORDID;
    IF UWOLDCNT = 0 THEN
        -- non-existing word
        SET result = '0';
    ELSE
        SET NEW_WORDID = P_WORDID;
        SELECT WORD INTO LWOLDWORD FROM LANGWORDS WHERE ID = P_WORDID;
        IF CAST(LWOLDWORD AS CHAR CHARSET BINARY) = CAST(P_WORD AS CHAR CHARSET BINARY) THEN
            -- word intact
            UPDATE LANGWORDS SET NOTE = P_NOTE WHERE ID = P_WORDID;
            SET result = '1';
        ELSE
            -- word changed
            SELECT COUNT(*) INTO LWNEWCNT FROM LANGWORDS WHERE LANGID = P_LANGID AND CAST(WORD AS CHAR CHARSET BINARY) = CAST(P_WORD AS CHAR CHARSET BINARY);
            IF UWOLDCNT = 1 THEN
                -- exclusive
                IF LWNEWCNT = 0 THEN
                    /* new word */
                    UPDATE LANGWORDS SET WORD = P_WORD, NOTE = P_NOTE WHERE ID = P_WORDID;
                    SET result = '2';
                ELSE
                    -- existing word
                    DELETE FROM LANGWORDS WHERE ID = P_WORDID;
                    SELECT ID INTO NEW_WORDID FROM LANGWORDS WHERE LANGID = P_LANGID AND CAST(WORD AS CHAR CHARSET BINARY) = CAST(P_WORD AS CHAR CHARSET BINARY) LIMIT 1;
                    SET result = '3';
                END IF;
            ELSE
                -- non-exclusive
                IF LWNEWCNT = 0 THEN
                    /* new word */
                    INSERT LANGWORDS (LANGID, WORD, NOTE) VALUES (P_LANGID, P_WORD, P_NOTE);
                    SELECT LAST_INSERT_ID() INTO NEW_WORDID;
                    SET result = '4';
                ELSE
                    -- existing word
                    SELECT ID INTO NEW_WORDID FROM LANGWORDS WHERE LANGID = P_LANGID AND CAST(WORD AS CHAR CHARSET BINARY) = CAST(P_WORD AS CHAR CHARSET BINARY) LIMIT 1;
                    SET result = '5';
                END IF;
            END IF;
        END IF;
        UPDATE UNITWORDS SET UNIT = P_UNIT, PART = P_PART, SEQNUM = P_SEQNUM, WORDID = NEW_WORDID WHERE ID = P_ID;
        UPDATE WORDSPHRASES SET WORDID = NEW_WORDID WHERE WORDID = P_WORDID;
    END IF;
    SELECT result;
END