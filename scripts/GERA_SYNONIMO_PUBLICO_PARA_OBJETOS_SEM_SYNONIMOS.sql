select
      ('CREATE PUBLIC SYNONYM ' || OBJECT_NAME || ' FOR ' ||
               OWNER || '.' || OBJECT_NAME || ';')
From all_objects o1
where
     o1.owner = 'SAUDE' 
     AND O1.OBJECT_TYPE IN ('TABLE','VIEW','SEQUENCE','PROCEDURE','FUNCTION') 
     AND SUBSTR(O1.OBJECT_NAME,1,2) NOT IN ('SM','EV')
     AND NOT EXISTS(
         SELECT 1 FROM all_objects o2
         WHERE
              O2.OBJECT_TYPE = UPPER('Synonym') AND
              O2.OBJECT_NAME = O1.OBJECT_NAME
     ) 
     AND TRUNC(CREATED) = TRUNC(SYSDATE)
