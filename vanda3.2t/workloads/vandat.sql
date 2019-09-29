\set aid random(1, 100000 * :scale)    
\set bid random(1, 1 * :scale)    
\set tid random(1, 10 * :scale)    
\set delta random(-50000, 50000)    
BEGIN;    
UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;    
END;  
