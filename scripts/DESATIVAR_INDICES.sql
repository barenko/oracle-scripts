-- altera sess�o para garantir q n�o dar� erro nos DML caso skip_unusable_indexes esteja false
alter session set skip_unusable_indexes = true;

--torna o indice inutiliz�vel
Alter Index nome_do_indice unusable; 

--torna o indice utilizavel novamente (� necess�rio reconstruir)
alter index nome_do_indice rebuild online;
