-- altera sessão para garantir q não dará erro nos DML caso skip_unusable_indexes esteja false
alter session set skip_unusable_indexes = true;

--torna o indice inutilizável
Alter Index nome_do_indice unusable; 

--torna o indice utilizavel novamente (é necessário reconstruir)
alter index nome_do_indice rebuild online;
