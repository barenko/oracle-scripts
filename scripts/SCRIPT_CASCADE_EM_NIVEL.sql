/*
    GERA SCRIPTS P/ CRIAR SCRIPT PARA REMOVER REGISTROS DA TABELA PAI (TABINI) E SEUS FILHOS POR CASCADE.

    PRE-REQUISITO: POSSUIR A PACKAGE ALTER_CONSTRAINTS NA BASE.
    OBS1: LIGUE O DBMS_OUTPUT ANTES DE EXECUTAR O SCRIPT


	OPCOES DO TIPO DE COMANDO:
		ENABLE TRIGGERS			COMANDO DE HABILITACAO DE TRIGGERS
		DISABLE TRIGGERS		COMANDO DE DESABILITACAO DE TRIGGERS
		DROP FK					COMANDO DE EXCLUSAO DE FK
		ADD FK					COMANDO DE CRIACAO DA FK COM AS MESMAS CARACTERISTICAS DA BASE
		CASCADE FK				COMANDO DE CRIACAO DE FK COM CASCADE
		
		
	
    CRIADA POR RAFAEL CAETANO PINTO   2007/11/28

*/
DECLARE
	PROCEDURE CASCADE_EM_NIVEL(	P_TABELA_INICIAL 		VARCHAR2
								,P_PROFUNDIDADE_MAXIMA	INTEGER 	DEFAULT 5
								,P_TIPO_COMANDO			VARCHAR2
								
	)IS
		P_TABELA_DESTINO		VARCHAR2(32) := NULL; --MANTER NULO P/ UTILIZAR CASCADES/TRIGGERS AT� O FIM DA �RVORE
		P_PROFUNDIDADE_MINIMA	INTEGER	:= P_PROFUNDIDADE_MAXIMA;
		IS_FOUND 		BOOLEAN := FALSE;
		V_DEPTH			INTEGER := P_PROFUNDIDADE_MINIMA;
		
		TYPE MEMORY	IS TABLE OF VARCHAR2(32) INDEX BY BINARY_INTEGER;
					
		ITERATION_MEMORY 		MEMORY;
		ITERATION_MEMORY_INDEX	INTEGER := 0;
		
		FUNCTION EXISTS_IN_MEMORY(ELEMENT VARCHAR2) RETURN BOOLEAN
		IS
		BEGIN
			FOR I IN 0..ITERATION_MEMORY.COUNT()-1
			LOOP
				IF ITERATION_MEMORY(I) = ELEMENT THEN
					RETURN TRUE;
				END IF;
			END LOOP;
			RETURN FALSE;
		END;
		
	    PROCEDURE FIND_CHILD(	P_INITIAL_TABLE 	VARCHAR2
						        ,P_FINAL_TABLE 		VARCHAR2
	       						,P_BOUNDARY_DEPTH 	INTEGER
	    )IS
	        CURSOR CCHILDREN(C_PARENT_TABLE VARCHAR2)
	        IS
	            SELECT DISTINCT
	                    UC.TABLE_NAME 	CHILD_TABLE
	                    ,UCR.TABLE_NAME PARENT_TABLE
	            FROM USER_CONSTRAINTS UC
	            INNER JOIN USER_CONSTRAINTS UCR ON UCR.CONSTRAINT_NAME = UC.R_CONSTRAINT_NAME
	            WHERE UCR.TABLE_NAME = UPPER(C_PARENT_TABLE)
	            AND UCR.CONSTRAINT_TYPE IN('P','U')
	            ORDER BY CHILD_TABLE;
	
	        MCHILDREN 	CCHILDREN%ROWTYPE;
	        TABULATOR 		VARCHAR2(128);
	        CURRENT_TABLE 	VARCHAR2(40);
	    BEGIN
	            OPEN CCHILDREN(P_INITIAL_TABLE);
	
	            SELECT LPAD('+- ', 3*(P_BOUNDARY_DEPTH)+3,'|  ') 
				INTO TABULATOR FROM DUAL;
				
	            IF P_BOUNDARY_DEPTH = 0 THEN --COLOCA A TABELA INICIAL NA MEM�RIA
					ITERATION_MEMORY(ITERATION_MEMORY_INDEX) := UPPER(P_INITIAL_TABLE);
					ITERATION_MEMORY_INDEX := ITERATION_MEMORY_INDEX+1;
	            END IF;

	
	    		LOOP
	            	FETCH CCHILDREN INTO MCHILDREN;
	            	EXIT WHEN CCHILDREN%NOTFOUND;
	
					SELECT DECODE(MCHILDREN.CHILD_TABLE,
									P_FINAL_TABLE,RPAD(MCHILDREN.CHILD_TABLE,40,'<'),
									MCHILDREN.CHILD_TABLE) 
					INTO CURRENT_TABLE FROM DUAL;
					
					--DBMS_OUTPUT.PUT_LINE(TABULATOR||CURRENT_TABLE);

					IF NOT EXISTS_IN_MEMORY(CURRENT_TABLE) THEN
						IF P_TIPO_COMANDO = 'DISABLE TRIGGERS' THEN
							ALTER_CONSTRAINTS.DISABLE_ALL_TRIGGERS(CURRENT_TABLE);
						ELSIF P_TIPO_COMANDO = 'ENABLE TRIGGERS' THEN
							ALTER_CONSTRAINTS.ENABLE_ALL_TRIGGERS(CURRENT_TABLE);
						ELSIF P_TIPO_COMANDO IN('DROP FK','ADD FK','CASCADE FK') THEN
							FOR FK IN (SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' AND DELETE_RULE <> 'CASCADE' AND TABLE_NAME = CURRENT_TABLE)
							LOOP
		                        IF P_TIPO_COMANDO = 'DROP FK' THEN
								ALTER_CONSTRAINTS.DROP_FK_CONSTRAINT(FK.CONSTRAINT_NAME);
		                        ELSIF P_TIPO_COMANDO = 'ADD FK' THEN
								ALTER_CONSTRAINTS.CREATE_FK_CONSTRAINT(FK.CONSTRAINT_NAME);
		                        ELSIF P_TIPO_COMANDO = 'CASCADE FK' THEN
		                        ALTER_CONSTRAINTS.FK_CONSTRAINT_CASCADE(FK.CONSTRAINT_NAME);
		                        END IF;
		                    END LOOP;
						END IF;
					END IF;
	                IF NOT EXISTS_IN_MEMORY(MCHILDREN.CHILD_TABLE)  -- EVITA LOOPS DE AUTO-RELACIONAMENTO
	                   AND P_BOUNDARY_DEPTH < V_DEPTH --LIMITA OS N�VEIS DA �RVORE, PRINCIPALMENTE P/ EVITAR LOOPS COM RELACIONAMENTOS CICLICOS
	                   AND (MCHILDREN.CHILD_TABLE <> UPPER(P_FINAL_TABLE) OR P_FINAL_TABLE IS NULL)--EXECUTA AT� ENCONTRAR A TABELA DESTINO
	                THEN
						ITERATION_MEMORY(ITERATION_MEMORY_INDEX) := MCHILDREN.CHILD_TABLE;
						ITERATION_MEMORY_INDEX := ITERATION_MEMORY_INDEX+1;

	            	    FIND_CHILD(MCHILDREN.CHILD_TABLE,P_FINAL_TABLE,P_BOUNDARY_DEPTH+1);
	            	END IF;
	            	
	            	IF MCHILDREN.CHILD_TABLE = UPPER(P_FINAL_TABLE) AND P_FINAL_TABLE IS NOT NULL THEN
	            		IS_FOUND := TRUE;
	            	END IF;
	            END LOOP;
	
	            CLOSE CCHILDREN;
	    END FIND_CHILD;
	BEGIN
		
		WHILE IS_FOUND = FALSE AND V_DEPTH <= P_PROFUNDIDADE_MAXIMA
		LOOP
			ITERATION_MEMORY.DELETE;
			ITERATION_MEMORY_INDEX :=0;
			DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||'--- ITERA��O EM N�VEL '||TO_CHAR(V_DEPTH+1)||' -------------------------');
			FIND_CHILD(P_TABELA_INICIAL,P_TABELA_DESTINO,0);
			V_DEPTH := V_DEPTH+1;
		END LOOP;

	END CASCADE_EM_NIVEL;
BEGIN
     CASCADE_EM_NIVEL('TABELA1',6,'DISABLE TRIGGERS');
     CASCADE_EM_NIVEL('TABELA1',6,'DROP FK');
     CASCADE_EM_NIVEL('TABELA1',6,'CASCADE FK');
     DBMS_OUTPUT.PUT_LINE('DELETE FROM TABELA1;'); --COMANDO DE EXCLUS�O
     CASCADE_EM_NIVEL('TABELA1',6,'DROP FK');
     CASCADE_EM_NIVEL('TABELA1',6,'ADD FK');
     CASCADE_EM_NIVEL('TABELA1',6,'ENABLE TRIGGERS');

END;
/
