-- Start of DDL Script for Package Body CAI.RANDOMIZE
-- Generated 27-nov-2007 22:47:08 from CAI@XE

CREATE OR REPLACE 
PACKAGE RANDOMIZE as
  MAX_RANDOM_VALUE float := 2147483648;


  function boolean_random return boolean;
  function float_random(min_value float default 0, max_value float default MAX_RANDOM_VALUE) return float;
  function integer_random(min_value integer default 0, max_value integer default MAX_RANDOM_VALUE) return integer;
  function number_random(min_value number default 0, max_value number default MAX_RANDOM_VALUE) return number;
  function char_random(min_value in char default 'A', max_value in char default 'z') return char;
  function alfa_random(min_length integer default 0, max_length in integer default 4000, domain varchar2 default 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ') return varchar2;
end randomize;
/

CREATE OR REPLACE 
PACKAGE BODY RANDOMIZE as
    
    function float_random(min_value float default 0, max_value float default MAX_RANDOM_VALUE) return float is
    begin
        return mod(abs(dbms_random.random)/(MAX_RANDOM_VALUE/max_value),max_value-min_value) + min_value;
    end float_random;

    function integer_random(min_value integer default 0, max_value integer default MAX_RANDOM_VALUE) return integer is
    begin
        return mod(abs(dbms_random.random)/(MAX_RANDOM_VALUE/max_value),max_value-min_value) + min_value;
    end integer_random;
    
    function number_random(min_value number default 0, max_value number default MAX_RANDOM_VALUE) return number is
    begin
        return mod(abs(dbms_random.random)/(MAX_RANDOM_VALUE/max_value),max_value-min_value) + min_value;
    end number_random;

    function boolean_random return boolean is
    begin
        if round(mod(abs(dbms_random.random)/(2147483648),2)) = 0 then
            return false;
        else 
            return true;
        end if;
    end boolean_random;

    function char_random(min_value in char default 'A', max_value in char default 'z') return char is
        aux integer :=0;
        v_min_value char(1) := substr(min_value,1,1);
        v_max_value char(1) := substr(max_value,1,1);
    begin
        aux := mod(abs(dbms_random.random)/(MAX_RANDOM_VALUE/ascii(v_max_value)),ascii(v_max_value)-ascii(v_min_value)-(96-91)) + ascii(v_min_value);
        
        if aux >= 91 then
            aux := aux + (96-91);
        end if;
        return chr(aux);
    end char_random;

    function alfa_random(min_length integer default 0, max_length in integer default 4000, domain varchar2 default 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ') return varchar2 is
        aux integer :=0;
        answer varchar2(4000);
        v_max_length integer := integer_random(min_length,max_length);
    begin
        if v_max_length = 0 then
            return null;
        end if;    

        for i in min_length..v_max_length
        loop
            answer := answer||substr(domain,integer_random(0,length(domain)-1),1);
        end loop;

        return answer;
    end alfa_random;
end randomize;
/


-- End of DDL Script for Package Body CAI.RANDOMIZE

