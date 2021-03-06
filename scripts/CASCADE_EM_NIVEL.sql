/*
    GERA SCRIPTS QUE ALTERAM AS CONSTRAINTS NA �RVORE DE RELACIONAMENTOS DA TABELA PAI (TABINI)
    E SUAS DESCENDENTES (FILHA, NETA, ETC) AT� ENCONTRAR A TABFIM.

    PRE-REQUISITO: POSSUIR A PACKAGE ALTER_CONSTRAINTS NA BASE.
    OBS1: LIGUE O DBMS_OUTPUT ANTES DE EXECUTAR O SCRIPT

    CRIADA POR RAFAEL CAETANO PINTO   2007/11/28

*/
DECLARE
----------------------------------------------------------------------------------
-- INSIRA A L�GICA DO NEG�CIO DENTRO DESSA PROCEDURE -----------------------------
--   OBS: N�O ALTERE A ASSINATURA DA MESMA           -----------------------------
----------------------------------------------------------------------------------
	PROCEDURE LOGICA_DO_PROCESSO(CURRENT_TABLE VARCHAR2) IS
		STMT VARCHAR2(4000);
	BEGIN
		--LOGICA UTILIZADA P/ UPDATE
		ALTER_CONSTRAINTS.DISABLE_ALL_TRIGGERS(CURRENT_TABLE);
		ALTER_CONSTRAINTS.disable_all_constraints(CURRENT_TABLE);

		STMT :='--UPDATE '||CURRENT_TABLE;
		DBMS_OUTPUT.put_line(STMT);

        ALTER_CONSTRAINTS.enable_all_constraints(CURRENT_TABLE);
		ALTER_CONSTRAINTS.ENABLE_ALL_TRIGGERS(CURRENT_TABLE);


/*  	--L�GICA UTILIZADA P/ DELETE  */
/*  		ALTER_CONSTRAINTS.DISABLE_ALL_TRIGGERS(CURRENT_TABLE);  */
/*  		--DBMS_OUTPUT.PUT_LINE(TABULATOR||CURRENT_TABLE);  */
/*  		FOR FK IN (SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' AND DELETE_RULE <> 'CASCADE' AND TABLE_NAME = CURRENT_TABLE)  */
/*  		LOOP  */
/*              ALTER_CONSTRAINTS.DROP_FK_CONSTRAINT(FK.CONSTRAINT_NAME);  */
/*              ALTER_CONSTRAINTS.CREATE_FK_CONSTRAINT(FK.CONSTRAINT_NAME);  */
/*              ALTER_CONSTRAINTS.CREATE_FK_CONSTRAINT_CASCADE(FK.CONSTRAINT_NAME);  */
/*          END LOOP;  */
/*  		ALTER_CONSTRAINTS.ENABLE_ALL_TRIGGERS(CURRENT_TABLE);  */
		DBMS_OUTPUT.put_line(CHR(13)||CHR(10));
		DBMS_OUTPUT.put_line(CHR(13)||CHR(10));
	END LOGICA_DO_PROCESSO;
----------------------------------------------------------------------------------
-- FIM DA L�GICA DO NEG�CIO ------------------------------------------------------
----------------------------------------------------------------------------------
	PROCEDURE CASCADE_EM_NIVEL(	P_TABELA_INICIAL 		VARCHAR2
								,P_TABELA_DESTINO		VARCHAR2
								,P_PROFUNDIDADE_MINIMA	INTEGER		DEFAULT 0
								,P_PROFUNDIDADE_MAXIMA	INTEGER 	DEFAULT 5
								
	)IS
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
				
	            IF P_BOUNDARY_DEPTH = 0 THEN --COLOCA A TABELA INICIAL NA MEM�RIA E IMPRIME O NOME DA TABELA INICIAL
					ITERATION_MEMORY(ITERATION_MEMORY_INDEX) := UPPER(P_INITIAL_TABLE);
					ITERATION_MEMORY_INDEX := ITERATION_MEMORY_INDEX+1;
	                DBMS_OUTPUT.PUT_LINE('----- '||UPPER(P_INITIAL_TABLE)||' -----------------------');
	                LOGICA_DO_PROCESSO(P_INITIAL_TABLE);
	            END IF;

	
	    		LOOP
	            	FETCH CCHILDREN INTO MCHILDREN;
	            	EXIT WHEN CCHILDREN%NOTFOUND;
	
					SELECT DECODE(MCHILDREN.CHILD_TABLE,
									P_FINAL_TABLE,RPAD(MCHILDREN.CHILD_TABLE,40,'<'),
									MCHILDREN.CHILD_TABLE) 
					INTO CURRENT_TABLE FROM DUAL;
					
					IF NOT EXISTS_IN_MEMORY(CURRENT_TABLE) THEN
						LOGICA_DO_PROCESSO(CURRENT_TABLE);
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

     CASCADE_EM_NIVEL('&TABELA_RAIZ','&TABELA_FOLHA',&PROFUNDIDADE_MINIMA,&PROFUNDIDADE_MAXIMA);

/*   EXEMPLO DE USO:
     --GERA SCRIPTS QUE ALTERAM AS CONSTRAINTS NA �RVORE DE RELACIONAMENTOS DA TABELA SYN_PRC_DEFINICAO AT� ENCONTRAR A TABELA SYN_CFGLIV_X_EST
     CASCADE_EM_NIVEL('SYN_PRC_DEFINICAO','SYN_CFGLIV_X_EST',8);

     --GERA SCRIPTS QUE ALTERAM AS CONSTRAINTS NA �RVORE DE RELACIONAMENTOS DA TABELA SYN_PRC_DEFINICAO
     CASCADE_EM_NIVEL('SYN_PRC_DEFINICAO',NULL,8);
*/
END;
/

