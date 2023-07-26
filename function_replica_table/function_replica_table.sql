CREATE OR REPLACE FUNCTION replica_tabela(old_schema TEXT, old_table TEXT , new_schema TEXT, data_t_f BOOL)
RETURNS void  
LANGUAGE plpgsql
AS $$
DECLARE
    idx TEXT ;
    new_tb TEXT ;
    old_tb TEXT ;
    qu_fk TEXT ;
BEGIN
    new_tb := new_schema||'.'||old_table ;
    old_tb := old_schema||'.'||old_table ;
    EXECUTE 'CREATE SCHEMA IF NOT EXISTS '||new_schema ;
    EXECUTE 'DROP TABLE IF EXISTS '||new_tb;
    -- CRIAR TABELA E IMPORTAR DADOS
    IF data_t_f = TRUE
    THEN
        EXECUTE 'CREATE TABLE IF NOT EXISTS '||new_tb||' AS (SELECT * FROM '||old_tb||')' ;
    ELSE
        EXECUTE 'CREATE TABLE IF NOT EXISTS '||new_tb||' AS (SELECT * FROM '||old_tb||') WITH NO DATA' ;
    END IF ;
    -- COPIA PK DA TABELA ORIGINAL
    EXECUTE (
                SELECT
                    'ALTER TABLE '||new_tb||' ADD PRIMARY KEY ('||string_agg(DISTINCT b.column_name, ', ')||')'
                FROM
                    information_schema.table_constraints AS a
                        LEFT JOIN information_schema.constraint_column_usage AS b
                            ON a.constraint_name = b.constraint_name
                WHERE
                    a.constraint_type = 'PRIMARY KEY'
                    AND a.table_schema = old_schema
                    AND a.table_name = old_table						  
            ) ;
    -- COPIA FKs DA TABELA ORIGINAL
    FOR qu_fk IN (
                    SELECT DISTINCT
                        'ALTER TABLE '||new_tb||' ADD CONSTRAINT '||b.constraint_name||' FOREIGN KEY ('||string_agg(b.column_name, ', ')||') REFERENCES '||b.table_schema||'.'||b.table_name||' ('||string_agg(b.column_name, ', ')||')'
                    FROM information_schema.table_constraints AS a
                            LEFT JOIN information_schema.constraint_column_usage AS b
                                ON a.constraint_name = b.constraint_name
                    WHERE
                        a.constraint_type = 'FOREIGN KEY'
                        AND a.table_schema = old_schema
                        AND a.table_name = old_table
                    GROUP BY
                        b.constraint_name
                        , b.table_schema
                        , b.table_name
                )
    LOOP
        EXECUTE qu_fk ;
    END LOOP ;
    -- COPIA INDEX DA TABELA ORIGINAL
    FOR idx IN  (
                    SELECT DISTINCT
                        substring(indexdef FROM 1 FOR  position(' ON ' IN indexdef) + 3)||new_schema||substring(indexdef FROM position('.' IN indexdef) FOR length(indexdef) - (POSITION('.' IN indexdef) - 2)) 
                    FROM
                        pg_catalog.pg_indexes
                    WHERE
                        tablename = old_table
                        AND schemaname = old_schema
                        AND indexdef !~ 'UNIQUE'
                )
    LOOP
        EXECUTE idx;
    END LOOP ;
END ;
$$ ;
