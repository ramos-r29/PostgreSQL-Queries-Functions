# Function para replicar uma tabela copiando estrutura de dados, índices e chaves.
<p>O código da function foi escrito em PL/pgSQL e esta dentro deste diretório nomeado como funcion_replica_table.sql </p>
<p>O código da function pode ser acessado pelo link abaixo: </p>

https://github.com/ramos-r29/PostgreSQL-Queries-Functions/blob/main/function_replica_table/function_replica_table.sql

<p>Faça o download do código e execute utilizando o client psql ou copie e cole no cllient que utiliza.</p> 

<p>A funciotn recebe como entrada os parâmetros: </p>
<p> - old_schema: recebe dado do tipo TEXT sendo o nome do schema onde esta a tabela que deseja replicar </p>
<p> - old_table: recebe dado do tipo TEXT sendo o nome da tabela que deseja replicar</p>
<p> - new_schema: recebe dado do tipo TEXT sendo o nome do schema onde da tabela deve ser replicada </p> 
<p> - data_t_f: recebe dado do tipo BOOL onde se define se os dados contidos na tabela devem ser copiados ou não </p> 

<p>A function será criada no schema public.</p> 

<p>Exemplo de chamada da function :</p> 

```

SELECT * FROM public.replica_tabela('public', 'tb_test', 'my_new_schema', true) ; 

```
