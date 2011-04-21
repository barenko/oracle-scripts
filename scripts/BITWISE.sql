/*
    PERMUTA A E B
              --A=A B=B  
    A=A XOR B --A=X B=B
    B=A XOR B --A=X B=A
    A=A XOR B --A=B B=A
*/

DECLARE
    FUNCTION bitor( x IN integer, y IN integer ) 
    RETURN integer  AS
    BEGIN
        RETURN x + y - bitand(x,y);
    END;


    FUNCTION bitxor( x IN integer, y IN integer ) 
    RETURN integer  AS
    BEGIN
        RETURN bitor(x,y) - bitand(x,y);
    END;

BEGIN

dbms_output.put_line(bitand(10,12));
dbms_output.put_line(BITOR(12,10));
dbms_output.put_line(BITXOR(12,10));


dbms_output.put_line('Encript');
    declare
        a number;
        b number;
    begin
        a:= 247;
        b:=173;
        
        dbms_output.put_line('a: '||a||'   b:'||b);
        a := bitxor(a,b);
        dbms_output.put_line('a: '||a||'   b:'||b);
        b := bitxor(a,b);
        dbms_output.put_line('a: '||a||'   b:'||b);
        a := bitxor(a,b);
        dbms_output.put_line('a: '||a||'   b:'||b);
    end;


END;
