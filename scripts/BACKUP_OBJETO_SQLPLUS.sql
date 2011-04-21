spool object_source.sql


select line, text from user_source
where name = '&OBJECT_NAME'
order by line;


spool off;
/
