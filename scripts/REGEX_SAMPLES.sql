/*
    regex
    
    REGEXP_LIKE(source_string, pattern [, match_parameter])
    
        source_string supports character datatypes 
        (CHAR, VARCHAR2, CLOB, NCHAR, NVARCHAR2, and NCLOB but not LONG). 
        The pattern parameter is another name for the regular expression. 
        match_parameter allows optional parameters such as handling the 
        newline character, retaining multiline formatting, and providing 
        control over case-sensitivity.



    REGEXP_INSTR(source_string, pattern
        [, start_position
        [, occurrence
        [, return_option
        [, match_parameter]]]])   
        
        This function looks for a pattern and returns the first position of the pattern. 
        Optionally, you can indicate the start_position you want to begin the search. 
        The occurrence parameter defaults to 1 unless you indicate that you are looking 
        for a subsequent occurrence. The default value of the return_option is 0, which 
        returns the starting position of the pattern; a value of 1 returns the starting 
        position of the next character following the match.


    REGEXP_SUBSTR(source_string, pattern
        [, position [, occurrence
        [, match_parameter]]])
        
        The REGEXP_SUBSTR function returns the substring that matches the pattern.
        
        
        
    REGEXP_REPLACE(source_string, pattern
        [, replace_string [, position
        [,occurrence, [match_parameter]]]])
        
        This function replaces the matching pattern with a specified 
        replace_string, allowing complex search-and-replace operations.      
*/

-- RETORNA TODOS OS CFOPS QUE POSSUAM O PADRÃO PASSADO
SELECT CFOP_CODIGO
  FROM COR_DOF
 WHERE REGEXP_LIKE(CFOP_CODIGO, '[^[:digit:]]') --PEGA CONJUNTOS QUE TENHAM CARACTERES DIFERENTES DE NÚMEROS
 
 
 --RETORNA A PRIMEIRA POSIÇÃO DO PRIMEIRO PADRÃO LOCALIZADO. PEGA 'Smith'
 SELECT REGEXP_INSTR('Joe Smith, 10045 Berry Lane, San Joseph, CA 91234',
 '[[:alpha:]]{5}')--PEGA CONJUNTOS COM 5 LETRAS
       AS rx_instr
  FROM dual

 --RETONRA A PRIMEIRA POSIÇÃO DO PADRÃO LOCALIZADO, PEGA '10045'
 SELECT REGEXP_INSTR('Joe Smith, 10045 Berry Lane, San Joseph, CA 91234-1234',
       ' [[:digit:]]{5}(-[[:digit:]]{4})?')--PEGA CONJUNTOS DE 5 DIGITOS TENDO OU NÃO UM SUFIXO COM SINAL DE MENOS E OUTRO CONJUNTO DE 4 DIGITOS
    AS starts_at
  FROM dual


--PEGA ', second field ,'
SELECT REGEXP_SUBSTR('first field, second field , third field',
', [^,]*,')--PADRÃO: PEGA O QUE ESTÁ ENTRE VIRGULAS, INCLUINDO AS VIRGULAS
FROM dual


--SUBSTITUI 3 DE ONDE ENCONTRAR O PADRÃO 2 DE 1
SELECT REGEXP_REPLACE('Joe   Smith',
       '[ ]{2,}', ' ') --PADRÃO: PEGA CONJUNTOS DE 2 OU + ESPAÇOS EM BRANCO
       AS RX_REPLACE
FROM dual

--REORGANIZA NOMES
SELECT REGEXP_REPLACE(
       'Ellen Hildi Smith',
       '(.*) (.*) (.*)', '\3, \1 \2')--PEGA 3 CONJUNTOS SEPARADOS POR ESPAÇO E OS RE-POSICIONA COLOCANDO O ÚLTIMO EM PRIMEIRO SEPARADO POR VIRGULA
FROM dual

--verifica palavras repetidas
SELECT REGEXP_SUBSTR(
       'The final test is is the implementation',
       '([[:alnum:]]+)([[:space:]]+)\1') AS substr --pega o conjunto A separado por espaços do conjunto B onde o conjunto A e B são iguais
FROM dual

--Exemplo de constraint check utilizando regex
ALTER TABLE students
  ADD CONSTRAINT stud_ssn_ck CHECK
  (REGEXP_LIKE(ssn,
  '^([[:digit:]]{3}-[[:digit:]]{2}-[[:digit:]]{4}|[[:digit:]]{9})$'))
  
  


