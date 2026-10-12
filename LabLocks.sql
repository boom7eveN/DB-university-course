\set AUTOCOMMIT off
\c football_clubs_network hr
\c football_clubs_network seniorhr

DEADLOCK
!HR
BEGIN;
UPDATE players SET salary = salary + 1000 WHERE player_id = 1;

!SENIORHR
BEGIN;
UPDATE players SET salary = salary + 1000 WHERE player_id = 2;

!HR
UPDATE players SET salary = salary + 1000 WHERE player_id = 2;

!SENIORHR
UPDATE players SET salary = salary + 1000 WHERE player_id = 1;

Откатится та кто сделала меньше работы, если обе сделали по ровну то откатится та которую субд начнёт проверять первую в графе

КОНФЛИКТЫ

!HR
BEGIN;
UPDATE players SET salary = salary + 1000 WHERE player_id = 1;

!SENIORHR
BEGIN;
UPDATE players SET salary = salary + 2000 WHERE player_id = 1;

!posgtgres
SELECT
    pid,
    usename,
    state,
    wait_event_type,
    wait_event,
    now() - xact_start    AS xact_age,
    now() - query_start   AS query_age,
    left(query, 70)       AS query
  FROM pg_stat_activity
 WHERE datname = 'football_clubs_network'
 ORDER BY xact_start;

SELECT
    l.pid,
    a.usename,
    l.locktype,
    l.relation::regclass AS relation,
    l.mode,
    l.granted,
    l.transactionid,
    a.state
  FROM pg_locks l
  JOIN pg_stat_activity a ON a.pid = l.pid
 WHERE a.datname = 'football_clubs_network'
   AND l.locktype IN ('transactionid', 'tuple', 'relation')
 ORDER BY l.pid;

Решения:
1) hr комитит свою
2) postgres прерывает сессию hr в целом - SELECT pg_terminate_backend(ТУТ ID);
3) postgres ломает транзакцию hr SELECT pg_cancel_backend(ТУТ ID);
3) Заврешить простой больше 10 минут
SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
 WHERE state = 'idle in transaction'
   AND now() - xact_start > interval '10 minutes'
   AND pid <> pg_backend_pid();

