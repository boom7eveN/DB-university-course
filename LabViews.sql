--Sqlshell

--\c  football_clubs_network

--трансформация обычного вью(не обращается к вью,
--а сразу строит запрос подставляя код вью)
CREATE VIEW v_active_players AS
SELECT player_id, player_first_name, player_last_name, goals_scored
FROM Players
WHERE goals_scored > 5;

EXPLAIN ANALYZE SELECT * FROM v_active_players WHERE player_first_name LIKE '%н%';

-------------------------------------------------------
--нетрансформация обычного вью
CREATE OR REPLACE VIEW v_club_complex_analytics AS
SELECT 
    c.club_id,
    c.club_name,
    cnt.country_name,
    COUNT(DISTINCT t.team_id) as teams_count,
    COUNT(DISTINCT p.player_id) as total_players,
    SUM(COALESCE(p.goals_scored, 0)) as total_goals,
    AVG(COALESCE(p.goals_scored, 0)) as avg_goals_per_player,
    MAX(COALESCE(p.goals_scored, 0)) as top_scorer_goals,
    COUNT(DISTINCT co.owner_id) as owners_count,
    SUM(co.profit) as total_owners_profit,
    AVG(co.profit) as avg_owner_profit,
    AVG(t.team_rating) as avg_team_rating,
    RANK() OVER (ORDER BY SUM(COALESCE(p.goals_scored, 0)) DESC) as goals_rank,
    SUM(COALESCE(p.goals_scored, 0)) - (
        SELECT AVG(sub.total_goals) 
        FROM (
            SELECT SUM(COALESCE(p2.goals_scored, 0)) as total_goals
            FROM Clubs c2
            LEFT JOIN Teams t2 ON c2.club_id = t2.club_id
            LEFT JOIN Players p2 ON t2.team_id = p2.team_id
            GROUP BY c2.club_id
        ) sub
    ) as goals_vs_average
FROM Clubs c
LEFT JOIN Countries cnt ON c.country_id = cnt.country_id
LEFT JOIN Teams t ON c.club_id = t.club_id
LEFT JOIN Players p ON t.team_id = p.team_id
LEFT JOIN ClubOwners co ON c.club_id = co.club_id
GROUP BY 
    c.club_id, 
    c.club_name, 
    cnt.country_name;


EXPLAIN ANALYZE
SELECT 
    club_name,
    total_players,
    total_goals,
    avg_goals_per_player,
    goals_rank
FROM v_club_complex_analytics
WHERE total_goals > 50;

EXPLAIN ANALYZE SELECT club_name, total_players, total_goals, avg_goals_per_player, goals_rank FROM v_club_complex_analytics WHERE total_goals > 50;


--------------------------------------------------------------------
--плюсы материализ вида
CREATE MATERIALIZED VIEW mv_country_stats AS
SELECT 
    cnt.country_name,
    COUNT(DISTINCT c.club_id) as clubs_count,
    COUNT(t.team_id) as teams_count,
    COUNT(p.player_id) as players_count,
    SUM(COALESCE(p.goals_scored, 0)) as total_goals,
    AVG(COALESCE(p.goals_scored, 0)) as avg_goals
FROM Countries cnt
LEFT JOIN Clubs c ON cnt.country_id = c.country_id
LEFT JOIN Teams t ON c.club_id = t.club_id
LEFT JOIN Players p ON t.team_id = p.team_id
GROUP BY cnt.country_id, cnt.country_name;

EXPLAIN ANALYZE
SELECT country_name, teams_count, total_goals
FROM mv_country_stats
WHERE total_goals > 10;


EXPLAIN ANALYZE
SELECT 
    cnt.country_name,
    COUNT(t.team_id) as teams_count,
    SUM(COALESCE(p.goals_scored, 0)) as total_goals
FROM Countries cnt
LEFT JOIN Clubs c ON cnt.country_id = c.country_id
LEFT JOIN Teams t ON c.club_id = t.club_id
LEFT JOIN Players p ON t.team_id = p.team_id
GROUP BY cnt.country_id, cnt.country_name
HAVING SUM(COALESCE(p.goals_scored, 0)) > 10;
EXPLAIN ANALYZE SELECT cnt.country_name, COUNT(t.team_id) as teams_count, SUM(COALESCE(p.goals_scored, 0)) as total_goals FROM Countries cnt LEFT JOIN Clubs c ON cnt.country_id = c.country_id LEFT JOIN Teams t ON c.club_id = t.club_id LEFT JOIN Players p ON t.team_id = p.team_id GROUP BY cnt.country_id, cnt.country_name HAVING SUM(COALESCE(p.goals_scored, 0)) > 10;


--минус
DROP MATERIALIZED VIEW mv_teams_by_country;

CREATE MATERIALIZED VIEW mv_teams_by_country AS
SELECT 
    cnt.country_id,
    cnt.country_name,
    COUNT(t.team_id) as total_teams
FROM Countries cnt
LEFT JOIN Clubs c ON cnt.country_id = c.country_id
LEFT JOIN Teams t ON c.club_id = t.club_id
GROUP BY cnt.country_id, cnt.country_name
ORDER BY total_teams DESC;

SELECT * FROM mv_teams_by_country

--RUSSIA + 1
INSERT INTO Teams(team_name, team_rating, club_id) 
VALUES('MV_TEST', 1, 1); 

DELETE FROM Teams WHERE team_name = 'MV_TEST';

SELECT * FROM mv_teams_by_country;

REFRESH MATERIALIZED VIEW mv_teams_by_country;

SELECT * FROM mv_teams_by_country;

