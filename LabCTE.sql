
--42. Страна с максимальным количеством команд
EXPLAIN ANALYZE
SELECT c.country_name, COUNT(*) AS team_count
FROM Countries c
JOIN Clubs cl ON c.country_id = cl.country_id
JOIN Teams t ON cl.club_id = t.club_id
GROUP BY c.country_id, c.country_name
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)  
    FROM Countries c2
    JOIN Clubs cl2 ON c2.country_id = cl2.country_id
    JOIN Teams t2 ON cl2.club_id = t2.club_id
    GROUP BY c2.country_id
);

--with cte

EXPLAIN ANALYZE
WITH CountryTeamCounts AS (
    SELECT c.country_id, c.country_name, COUNT(*) AS team_count
    FROM Countries c
    JOIN Clubs cl ON c.country_id = cl.country_id
    JOIN Teams t ON cl.club_id = t.club_id
    GROUP BY c.country_id, c.country_name
)
SELECT country_name, team_count
FROM CountryTeamCounts
WHERE team_count = (SELECT MAX(team_count) FROM CountryTeamCounts);
--=========================================================================================
--46. Выбрать количество однофамильцев по всей БД
--CTE не нужно:

EXPLAIN ANALYZE
WITH surnames AS (
	SELECT owner_last_name AS surname, 1 as cnt
	FROM ClubOwners

	UNION ALL

	SELECT player_last_name AS surname, 1 as cnt
	FROM Players

	UNION ALL

	SELECT staff_last_name AS surname, 1 as cnt
	FROM Staff
)

SELECT surname, COUNT(cnt)
FROM surnames
GROUP BY surname;

--the same
EXPLAIN ANALYZE
SELECT surname, COUNT(cnt)
FROM 
    (
    SELECT owner_last_name AS surname, 1 as cnt
	FROM ClubOwners

	UNION ALL

	SELECT player_last_name AS surname, 1 as cnt
	FROM Players

	UNION ALL

	SELECT staff_last_name AS surname, 1 as cnt
	FROM Staff
	)
GROUP BY surname;
