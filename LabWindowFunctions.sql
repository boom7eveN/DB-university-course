--Хороший пример оконки
--41 Последние три матча для каждой команды
EXPLAIN ANALYZE
SELECT 
    T.team_id,
    T.team_name,
    M.match_id,
    M.start_date_time,
    C.competition_id,
    C.competition_name,
    C.competition_start_date,
    C.competition_end_date
FROM Teams T
LEFT JOIN Matches M ON T.team_id IN (M.home_team_id, M.away_team_id)
LEFT JOIN Competitions C ON M.competition_id = C.competition_id
WHERE (
    SELECT COUNT(*)
    FROM Matches M2
    WHERE (M2.home_team_id = T.team_id OR M2.away_team_id = T.team_id)
      AND M2.start_date_time > M.start_date_time
) < 3
ORDER BY T.team_id, M.start_date_time DESC;

EXPLAIN ANALYZE
SELECT * 
FROM (
    SELECT 
        T.team_id,
        T.team_name,
        M.match_id,
        M.start_date_time,
        ROW_NUMBER() OVER (PARTITION BY T.team_id ORDER BY M.start_date_time DESC) AS match_rank
    FROM Teams T
    LEFT JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
)
WHERE match_rank <= 3;

--Найти общее количество голов, забитых каждой командой
--хуже т.к sort для window
EXPLAIN ANALYZE
SELECT DISTINCT
    T.team_id,
    T.team_name,
    SUM(CASE 
        WHEN M.home_team_id = T.team_id THEN M.home_score
        WHEN M.away_team_id = T.team_id THEN M.away_score
    END) OVER (PARTITION BY T.team_id) AS total_goals
FROM Teams T
LEFT JOIN Matches M ON T.team_id IN (M.home_team_id, M.away_team_id);

--лучше т.к hash aggregate без sort
EXPLAIN ANALYZE
SELECT 
    T.team_id,
    T.team_name,
    SUM(CASE 
        WHEN M.home_team_id = T.team_id THEN M.home_score
        WHEN M.away_team_id = T.team_id THEN M.away_score
    END) AS total_goals
FROM Teams T
LEFT JOIN Matches M ON T.team_id IN (M.home_team_id, M.away_team_id)
GROUP BY T.team_id, T.team_name;
