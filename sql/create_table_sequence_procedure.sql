CREATE SEQUENCE SEQ1
    START WITH -1
    INCREMENT BY -1
    MAXVALUE -1
    MINVALUE -9223372036854775808
;

commit;

create table t1 ( c1 int, c2 int primary key )
    sharding by range (c2)
    shard s1 values less than ( MAXVALUE ) at cluster group g1;

commit;

CREATE OR REPLACE PROCEDURE PROC1 
AS    
BEGIN                            
    FOR i IN 1..1000000 LOOP      
        INSERT INTO t1 (c1, c2)  
        VALUES (i, SEQ1.NEXTVAL);
      COMMIT;

      IF MOD(i,10000) = 0 THEN
        DBMS_LOCK.SLEEP(1);
      END IF;

    END LOOP;                    
END;    
/
commit;
