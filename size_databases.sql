SELECT 
  a.datname AS db_name
  , pg_size_pretty(pg_database_size(a.datname)) as db_size
FROM 
  pg_database AS a
ORDER BY pg_database_size(a.datname) DESC ;
