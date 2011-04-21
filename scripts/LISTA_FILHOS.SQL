/*
	Dada uma tabela, lista todas as tabelas filhas e os id's referenciados
*/
select
-- 		select em cascata
--		uc.constraint_name nome_constraint,'select '||uc.table_name||'.* from '||uc.table_name||' where '||uc.table_name||'.'||ucc.column_name||' in(select '||ucr.table_name||'.'||uccr.column_name||' from '||ucr.table_name||' where );'

/*		modo normal*/
		uc.constraint_name nome_constraint,
        uc.table_name tabela_Filha,
        ucc.column_name coluna_Filha,
        ucr.table_name tabela_Referenciada,
        uccr.column_name coluna_Referenciada
/**/
from user_constraints uc
inner join user_constraints ucr on ucr.constraint_name = uc.r_constraint_name
inner join user_cons_columns ucc on  ucc.constraint_name  = uc.constraint_name and uc.table_name = ucc.table_name
inner join user_cons_columns uccr on uccr.constraint_name = ucr.constraint_name and ucr.table_name = uccr.table_name and uccr.position = ucc.position
where ucr.table_name = upper('&tabela') --Coloque o nome da tabela aqui
and ucr.constraint_type in( 'P','U')
-- 		select em cascata
--		order by nome_constraint

--		modo normal
order by tabela_filha, nome_constraint, coluna_filha



--Lista o mapeamento da base
/*
SELECT DISTINCT
        UT.TABLE_NAME TABELA,
        UCC.COLUMN_NAME COLUNA,
        UCF.TABLE_NAME TABELA_FILHA,
        UCCF.COLUMN_NAME COLUNA_FILHA
FROM USER_TABLES UT
LEFT JOIN USER_CONSTRAINTS UCF ON UT.TABLE_NAME = UCF.TABLE_NAME
LEFT JOIN USER_CONSTRAINTS UC ON UC.CONSTRAINT_NAME = UCF.R_CONSTRAINT_NAME
LEFT JOIN USER_CONS_COLUMNS UCCF ON  UCCF.CONSTRAINT_NAME  = UCF.CONSTRAINT_NAME AND UCF.TABLE_NAME = UCCF.TABLE_NAME
LEFT JOIN USER_CONS_COLUMNS UCC ON UCC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME AND UC.TABLE_NAME = UCC.TABLE_NAME AND UCC.POSITION = UCCF.POSITION
WHERE 
UC.CONSTRAINT_TYPE = 'P' OR 
(UC.CONSTRAINT_TYPE IS NULL AND UCF.CONSTRAINT_TYPE IS NULL) 
OR (UC.CONSTRAINT_NAME = UCF.R_CONSTRAINT_NAME AND UC.CONSTRAINT_TYPE = 'U')
ORDER BY TABELA,TABELA_FILHA, COLUNA, COLUNA_FILHA
*/
