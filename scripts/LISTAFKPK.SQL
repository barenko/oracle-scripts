/*
	Select que lista as foreign key de uma tabela mostrando a primary key que é referenciada.
*/
select  uc.constraint_name nome_constraint,
        uc.table_name tabela_filha,
        ucc.column_name coluna_filha,
        ucr.table_name tabela_referenciada,
        uccr.column_name coluna_referenciada
from user_constraints uc
inner join user_constraints ucr on ucr.constraint_name = uc.r_constraint_name
inner join user_cons_columns ucc on  ucc.constraint_name  = uc.constraint_name and uc.table_name = ucc.table_name
inner join user_cons_columns uccr on uccr.constraint_name = ucr.constraint_name and ucr.table_name = uccr.table_name and uccr.position = ucc.position
where uc.table_name = UPPER('&tabela') --Coloque o nome da tabela aqui
and uc.constraint_type = 'R' -- fk reference
order by tabela_referenciada, coluna_filha

