\set AUTOCOMMIT off
\c football_clubs_network hr
\c football_clubs_network seniorhr
====================================================================
---НЕПОВТОРЯЕМОЕ ЧТЕНИЕ-------------------------
!HR
BEGIN; 
SELECT player_id, salary, xmin, xmax FROM players WHERE player_id = 1;


!SENIORHR
BEGIN;
UPDATE players SET salary = salary + 10000 WHERE player_id = 1;
SELECT player_id, salary, xmin, xmax FROM players WHERE player_id = 1;
COMMIT;

!HR
SELECT player_id, salary, xmin, xmax FROM players WHERE player_id = 1;
COMMIT;


====================================================================

--ФАНТОМНОЕ ЧТЕНИЕ

!HR
BEGIN; 
SELECT COUNT(*) AS cnt, SUM(salary) AS total FROM players WHERE team_id = 1;

!SENIORHR
BEGIN;

INSERT INTO players (player_first_name, player_last_name, player_middle_name, player_gender, goals_scored, goals_saved, player_date_of_birth, team_id, salary) VALUES ('Пётр', 'Петров', 'Сергеевич', 'M', 0, 0, '1995-07-15', 1, 90000);

SELECT player_id, player_first_name, player_last_name, salary, xmin, xmax FROM players WHERE team_id = 1;
COMMIT;

!HR
SELECT COUNT(*) AS cnt, SUM(salary) AS total FROM players WHERE team_id = 1; COMMIT;


====================================================================
====================================================================
---ОШИБКА СЕРИАЛИЗАЦИИ

!HR
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT player_id, salary, xmin, xmax FROM players WHERE player_id = 1;

!SENIORHR
BEGIN ISOLATION LEVEL SERIALIZABLE;
UPDATE players SET salary = salary + 10000 WHERE player_id = 1;
SELECT player_id, salary, xmin, xmax FROM players WHERE player_id = 1;
COMMIT;

!HR
UPDATE players SET salary = salary + 5000 WHERE player_id = 1;

ROLLBACK;


