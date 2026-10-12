/*1.СДАЛ Выбрать все данные о футболистах. 
Результат отсортировать по фамилии в лексикографическом порядке, 
по имени и отчеству в порядке обратном лексикографическому.*/

SELECT * 
FROM Players
ORDER BY player_last_name, 
         player_first_name DESC, 
         player_middle_name DESC;

/*2.СДАЛ Выбрать фамилию и инициалы футболистов в одном
столбце, дату рождения в формате: год, число, название месяца,
дата рождения. Результат отсортировать по возрасту игроков в
порядке убывания.*/

SELECT 
    CONCAT(player_last_name, ' ', 
           LEFT(player_first_name, 1), '.', 
           COALESCE(LEFT(player_middle_name, 1) || '.', '')) AS Инициалы,
    CONCAT(EXTRACT(YEAR FROM player_date_of_birth), ' ',
           EXTRACT(DAY FROM player_date_of_birth), ' ',
           TO_CHAR(player_date_of_birth, 'Month'), ' ',
           player_date_of_birth) AS ДР
FROM Players
ORDER BY player_date_of_birth ASC;

/*3.СДАЛ Выбрать игроков с фамилией из трех или четырех букв.
Результат отсортировать по длине фамилии.*/

SELECT *
FROM Players
WHERE player_last_name LIKE '___' OR player_last_name LIKE '____'
ORDER BY LENGTH(player_last_name);

/*4.СДАЛ Выбрать названия улиц, которые не содержат символов
«-», «_», «\». */

SELECT street
FROM Addresses
WHERE street NOT LIKE '%@_%' ESCAPE '@' 
  AND street NOT LIKE '%-%' 
  AND street NOT LIKE '%@\%' ESCAPE '@';

/*5.СДАЛ Выбрать фамилии, имена, отчества футболистов, для которых не указана команда.*/

SELECT player_first_name, player_last_name, player_middle_name
FROM Players
WHERE team_id IS NULL;

/*6.СДАЛ Выбрать фамилии, имена, отчества игроков, возраст которых менее 26 лет.*/

SELECT player_first_name, player_last_name, player_middle_name 
FROM Players 
WHERE EXTRACT(YEAR FROM AGE(player_date_of_birth)) < 26;

/*7.СДАЛ Выбрать все данные об игроках, рожденных зимой.*/

SELECT *
FROM Players
WHERE EXTRACT(MONTH FROM player_date_of_birth) IN (12, 1, 2);

/*8.СДАЛ Выбрать фамилии, имена, отчества персонала, 
работающего на базах с id равным 3, 4, 5, 7 или 9. */

SELECT staff_last_name, staff_first_name, staff_middle_name
FROM Staff
WHERE staff_base_id IN (3, 4, 5, 7, 9);

/*9.СДАЛ Выбрать id и фамилии, имена, отчества персонала заглавными буквами 
с зарплатой от 20 000 до 45 000.*/

SELECT 
    staff_id, 
    UPPER(staff_last_name),
    UPPER(staff_first_name),
    UPPER(staff_middle_name)
FROM Staff
WHERE staff_salary BETWEEN 20000 AND 45000;

/*10.СДАЛ Выбрать данные игроков с двойной фамилией, принявших участие в матчах, проходивших весной и летом.*/

SELECT DISTINCT P.*
FROM Players P
JOIN Teams T ON P.team_id = T.team_id
JOIN Matches M ON T.team_id = M.home_team_id OR T.team_id = M.away_team_id
WHERE (P.player_last_name LIKE '%-%')
  AND EXTRACT(MONTH FROM M.start_date_time) BETWEEN 3 AND 8;

/*11.СДАЛ Выбрать минимальную прибыль.*/

SELECT MIN(profit) AS min_profit
FROM ClubOwners;

/*12.СДАЛ Выбрать среднюю продолжительность соревнований. */

SELECT AVG(AGE(competition_end_date, competition_start_date))
FROM Competitions;

/*13.СДАЛ Выбрать максимальную и минимальную зарплату обслуживающего персонала.*/

SELECT 
    MAX(staff_salary) AS max_salary,
    MIN(staff_salary) AS min_salary
FROM Staff;

/*14.СДАЛ Выбрать среднюю цену билета на матчи, проходившие осенью,
и среднюю цену билета на матчи, проходившие весной. */

SELECT
	AVG(CASE WHEN EXTRACT(MONTH FROM start_date_time) IN (9,10,11) THEN ticket_price END),
	AVG(CASE WHEN EXTRACT(MONTH FROM start_date_time) IN (3,4,5) THEN ticket_price END)
FROM Matches;
	
/*СДАЛ 15. Для каждого года рождения вывести количество игроков, рожденных в этом году. */

SELECT EXTRACT(YEAR FROM player_date_of_birth), COUNT(player_id)
FROM Players
GROUP BY EXTRACT(YEAR FROM player_date_of_birth);

/*СДАЛ 16. Выбрать фамилию, имя, отчество футболиста, название команды. 
Результат отсортировать по команде, возрасту игрока, фамилии, имени, отчеству. */

SELECT P.player_last_name, P.player_first_name, P.player_middle_name, T.team_name
FROM Players P JOIN Teams T ON P.team_id = T.team_id
ORDER BY 4, player_date_of_birth DESC, 1, 2, 3; 

/*СДАЛ 17. Выбрать данные о стадионах, на которых проходили матчи, без повторений. */

SELECT DISTINCT S.*
FROM Stadiums S
JOIN Matches M ON S.stadium_id = M.stadium_id;

/*СДАЛ 18. Выбрать фамилию и инициалы игроков (в одном столбце), названия команд, название клуба, год, 
дату проведения матча,
название типа матча, название состязаний, стадион, счет матча. 
Результат отсортировать по типу матча, дате проведения. */

SELECT
    P.player_last_name || ' ' ||
    LEFT(P.player_first_name,1) || '. ' ||
    COALESCE(LEFT(P.player_middle_name,1) || '.', '') AS Инициалы,
    T.team_name,
    CL.club_name,
    EXTRACT(YEAR FROM M.start_date_time),
    M.start_date_time::DATE,              
    MT.match_type_name,
    CO.competition_name,
    S.stadium_name,
    M.home_score::TEXT || ':' || M.away_score::TEXT AS Счёт
FROM Players P
JOIN Teams T ON P.team_id = T.team_id
JOIN Clubs CL ON T.club_id = CL.club_id
JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
JOIN MatchTypes MT ON M.match_type_id = MT.match_type_id
JOIN Competitions CO ON M.competition_id = CO.competition_id
JOIN Stadiums S ON M.stadium_id = S.stadium_id
ORDER BY MT.match_type_name, M.start_date_time; 

/*СДАЛ-19. Выбрать название соревнования и количество матчей. */

SELECT C.competition_name, COUNT(M.*)
FROM Competitions C
JOIN Matches M ON M.competition_id = C.competition_id
GROUP BY C.competition_name, C.competition_id;

/*СДАЛ-20. Выбрать название команды и количество турниров, в которых она принимала участие. 
В результат должны войти только российские команды. */

SELECT T.team_name, COUNT(DISTINCT M.competition_id)
FROM Teams T 
JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
JOIN Clubs CL ON T.club_id = CL.club_id
JOIN Countries CO ON CL.country_id = CO.country_id
WHERE TRIM(CO.country_name) = 'Россия'
GROUP BY T.team_name, T.team_id;

/*СДАЛ 21. Выбрать для каждой команды название, название клуба и количество игроков. */

SELECT T.team_name, C.club_name, COUNT(P.player_id)
FROM Teams T
JOIN Clubs C ON (T.club_id = C.club_id)
JOIN Players P ON (T.team_id = P.team_id)
GROUP BY T.team_name, C.club_name;

/*СДАЛ 22. Выбрать названия команд, которые приняли участие в пяти и более матчах.
Результат отсортировать по количеству матчей.
НА БУДУЩЕЕ: что работает быстрее:  1 этот способ, 2 можно просто присоединить таблицу три раза а не два один раз для home,
другой раз для away без or(он замедляет),
3 либо выбрать все home id и away id в множество*/ 

SELECT T.team_name
FROM Teams T JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
GROUP BY T.team_name, T.team_id
HAVING COUNT(M.match_id) >= 5
ORDER BY COUNT(M.match_id) DESC; 

/*СДАЛ 23. Выбрать названия команд, которые приняли участие только в одном соревновании и сыграли более трех матчей. */

SELECT T.team_name
FROM Teams T 
JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
JOIN Competitions C ON M.competition_id = C.competition_id
GROUP BY T.team_name, T.team_id
HAVING COUNT(M.match_id) > 3 AND COUNT(DISTINCT(C.competition_id)) = 1;

/*СДАЛ 24. Выбрать названия команд, состоящие из двух и более слов, принявшие участие в более чем трех соревнованиях. 
Результат отсортировать по названию команд в порядке обратном лексикографическому. */

SELECT T.team_name
FROM Teams T  JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
WHERE TRIM(T.team_name) LIKE '_% _%' 
GROUP BY T.team_id, T.team_name
HAVING COUNT(DISTINCT M.competition_id) > 3
ORDER BY T.team_name DESC;

/*СДАЛ 25. Выбрать фамилию и инициалы игроков; если количество забитых мячей равно 0, 
то во втором столбце результирующей таблицы вывести сообщение «Данных нет». */

SELECT 
    player_last_name || ' ' ||
    LEFT(player_first_name, 1) || '. ' ||
    COALESCE(LEFT(player_middle_name, 1) || '.', ''),
    CASE
        WHEN goals_scored = 0 THEN 'Данных нет'
        ELSE goals_scored::TEXT
    END
FROM Players;
	
/*СДАЛ 26. Выбрать название команды, название соревнования, 
количество матчей, которые были выиграны; количество матчей, которые были проиграны; 
количество матчей, сыгранных в ничью. */

SELECT 
    T.team_name, 
    C.competition_name, 
    COUNT(CASE 
        WHEN (T.team_id = M.home_team_id AND M.home_score > M.away_score) OR 
             (T.team_id = M.away_team_id AND M.away_score > M.home_score) THEN 1 
    END),
    COUNT(CASE 
        WHEN (T.team_id = M.home_team_id AND M.home_score < M.away_score) OR 
             (T.team_id = M.away_team_id AND M.away_score < M.home_score) THEN 1 
    END),
    COUNT(CASE 
        WHEN M.home_score = M.away_score THEN 1 
    END)
FROM Teams T
JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
JOIN Competitions C ON M.competition_id = C.competition_id
GROUP BY T.team_id, T.team_name, C.competition_id, C.competition_name;

/*СДАЛ 27. Выбрать фамилии, имена, отчества игроков старше 30 лет, принявших участие в трех и более матчах, 
учитывать только те матчи, которые состоялись на российских стадионах. */

SELECT P.player_last_name, P.player_first_name, P.player_middle_name
FROM Players P
JOIN Teams T ON P.team_id = T.team_id
JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
JOIN Stadiums S ON M.stadium_id = S.stadium_id
JOIN Addresses A ON S.address_id = A.address_id
JOIN Cities C ON A.city_id = C.city_id
JOIN Countries CO ON C.country_id = CO.country_id
WHERE EXTRACT(YEAR FROM AGE(P.player_date_of_birth)) > 30 AND CO.country_name = 'Россия'
GROUP BY P.player_id, P.player_last_name, P.player_first_name, P.player_middle_name
HAVING COUNT(M.match_id) >= 3;

/*СДАЛ 28. Выбрать все данные о самом молодом игроке. */

SELECT *
FROM Players
WHERE player_date_of_birth = (SELECT MAX(player_date_of_birth) 
                              FROM Players);

/*СДАЛ 29. Выбрать название команды, в которой играет самый старший игрок. */


SELECT T.team_name
FROM Teams T
JOIN Players P ON T.team_id = P.team_id
WHERE P.player_date_of_birth = (
    SELECT MIN(player_date_of_birth) 
    FROM Players
    WHERE team_id IS NOT NULL
);

/*СДАЛ NOT EXISTS 30. Выбрать названия команд, в которых нет самого молодого и самого старшего игрока. */

SELECT T.team_name 
FROM Teams T
WHERE NOT EXISTS (
    SELECT 1 
    FROM Players P 
    WHERE P.team_id = T.team_id 
      AND (P.player_date_of_birth = (SELECT MIN(player_date_of_birth) FROM Players)
        OR P.player_date_of_birth = (SELECT MAX(player_date_of_birth) FROM Players))
);

/*СДАЛ ADD '>= ALL' 31. Выбрать название клуба с наибольшим количеством команд. */

SELECT C.club_name
FROM Clubs C 
JOIN Teams T ON C.club_id = T.club_id
GROUP BY C.club_id, C.club_name
HAVING COUNT(T.team_id) >= ALL (SELECT COUNT(team_id) as team_count
                                FROM Teams TT
                                GROUP BY TT.club_id
                               );
                                         


/*СДАЛ ADD '>= ALL' 32. Выбрать названия команд, которые сыграли наибольшее количество матчей. */

SELECT T.team_name
FROM Teams T JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
GROUP BY T.team_id, T.team_name
HAVING COUNT(M.match_id) >= ALL(
									SELECT COUNT(MM.match_id) AS cnt_matches
        							FROM Teams TT
        						    JOIN Matches MM ON (TT.team_id = MM.home_team_id 
										   	     	 OR TT.team_id = MM.away_team_id)
                                    GROUP BY TT.team_id
								);

/*СДАЛ 33. Выбрать фамилию, имя, отчество игрока(ов), забившего наибольшее количество мячей, и фамилию, имя, отчество игрока, 
который стоит вторым по количеству забитых мячей. 
Результирующая таблица должна содержать один столбец с фамилией, именем, отчеством. */

SELECT full_name
FROM (
    SELECT 
        player_last_name || ' ' || player_first_name || COALESCE(' ' || player_middle_name, '') AS full_name,
        goals_scored,
        RANK() OVER (ORDER BY goals_scored DESC) AS rank
    FROM Players
) 
WHERE rank IN (1, 2)
ORDER BY rank;



/*СДАЛ 34. Выбрать все данные об игроках старше среднего возраста игроков. */

SELECT *
FROM Players
WHERE AGE(player_date_of_birth) > (SELECT AVG(AGE(player_date_of_birth))
                                  FROM Players);
ne
/*СДАЛ 35. Выбрать год, в который родилось больше всего людей по всей БД. */

EXPLAIN ANALYZE
WITH AllPeople AS (
	SELECT EXTRACT(YEAR FROM player_date_of_birth) AS YearValue
	FROM Players

	UNION ALL

	SELECT EXTRACT(YEAR FROM staff_date_of_birth) AS YearValue
	FROM Staff
)

SELECT YearValue, COUNT(*)
FROM AllPeople
GROUP BY YearValue
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM AllPeople
    GROUP BY YearValue
);

--

EXPLAIN ANALYZE
WITH AllPeople AS (
    SELECT EXTRACT(YEAR FROM player_date_of_birth) AS YearValue
    FROM Players
    UNION ALL
    SELECT EXTRACT(YEAR FROM staff_date_of_birth) AS YearValue
    FROM Staff
),
YearCounts AS (
    SELECT 
        YearValue, 
        COUNT(*) as people_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) as rank
    FROM AllPeople
    GROUP BY YearValue
)
SELECT YearValue, people_count
FROM YearCounts
WHERE rank = 1;

/*СДАЛ 36. Выбрать для каждой команды суммарный фонд оплаты труда. Учесть игроков, тренеров и др. */
EXPLAIN ANALYZE
SELECT 
    T.team_name,
    COALESCE(SUM(P.salary), 0) + COALESCE(SUM(S.staff_salary), 0)
FROM Teams T
LEFT JOIN Players P ON T.team_id = P.team_id
LEFT JOIN Staff S ON T.team_id = S.team_id
GROUP BY T.team_id, T.team_name;

/*СДАЛ 37. Для каждой команды вывести данные матча, принесшего максимальное количество очков. */--UPD: где выиграла
EXPLAIN ANALYZE
SELECT 
    T.team_name,
    CASE 
        WHEN M.home_team_id = T.team_id THEN 'Home' ELSE 'Away' END,
	M.*
FROM Teams T
JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
WHERE 
    (M.home_team_id = T.team_id AND M.home_score > M.away_score)
    OR 
    (M.away_team_id = T.team_id AND M.away_score > M.home_score);

/*СДАЛ 38.EXISTS Выбрать название и страну команды, которая ни разу не проиграла. */

EXPLAIN ANALYZE
SELECT T.team_name, C.country_name
FROM Teams T 
JOIN Clubs CL ON T.club_id = CL.club_id 
JOIN Countries C ON CL.country_id = C.country_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM Matches M 
    WHERE (M.home_team_id = T.team_id AND M.home_score < M.away_score)
       OR (M.away_team_id = T.team_id AND M.away_score < M.home_score)
);

EXPLAIN ANALYZE
SELECT T.team_name, C.country_name
FROM Teams T 
JOIN Clubs CL ON T.club_id = CL.club_id 
JOIN Countries C ON CL.country_id = C.country_id
LEFT JOIN Matches M ON 
    T.team_id IN (M.home_team_id, M.away_team_id)
GROUP BY T.team_id, T.team_name, C.country_name
HAVING 
    SUM(CASE 
        WHEN (M.home_team_id = T.team_id AND M.home_score < M.away_score) OR
             (M.away_team_id = T.team_id AND M.away_score < M.home_score)
        THEN 1 ELSE 0 
    END) = 0;


EXPLAIN ANALYZE
SELECT T.team_name, C.country_name
FROM Teams T 
JOIN Clubs CL ON T.club_id = CL.club_id 
JOIN Countries C ON CL.country_id = C.country_id
WHERE T.team_id NOT IN (
    SELECT home_team_id FROM Matches WHERE home_score < away_score
    UNION
    SELECT away_team_id FROM Matches WHERE away_score < home_score
);


/*СДАЛ 39.EXISTS Выбрать название тренировочной базы, на которой не проходили сборы. */

EXPLAIN ANALYZE
SELECT TB.training_base_name
FROM TrainingBases TB
WHERE NOT EXISTS (
    SELECT 1 
    FROM TrainingCamps TC 
    WHERE TC.training_base_id = TB.training_base_id
);

/*СДАЛ 40. Выбрать название команды, которая приняла участие во всех соревнованиях. */

EXPLAIN ANALYZE
SELECT T.team_name
FROM Teams T JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
JOIN Competitions C ON M.competition_id = C.competition_id
GROUP BY T.team_id, T.team_name
HAVING COUNT(DISTINCT C.competition_id) = (SELECT COUNT(*) FROM Competitions);




/*СДАЛ 41.Выбрать данные последних трех матчей для каждой команды. */

WITH TeamMatches AS (
    SELECT 
        T.team_id,
        T.team_name,
        M.match_id,
        M.start_date_time,
        C.competition_id,
        C.competition_name,
        C.competition_start_date,
        C.competition_end_date,
        ROW_NUMBER() OVER ( PARTITION BY T.team_id ORDER BY M.start_date_time DESC) AS match_rank
    FROM Teams T
    LEFT JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
    LEFT JOIN Competitions C ON M.competition_id = C.competition_id
)

SELECT 
    team_id,
    team_name,
    competition_id,
    competition_name,
    competition_start_date,
    competition_end_date,
    start_date_time
FROM TeamMatches
WHERE match_rank <= 3
ORDER BY team_id, match_rank;


/*СДАЛ 42. Выбрать название страны с максимальным количеством команд. */

EXPLAIN ANALYZE
SELECT CO.country_name
FROM Countries CO
JOIN Clubs CL ON CO.country_id = CL.country_id
JOIN Teams T ON T.club_id = CL.club_id
GROUP BY CO.country_name
HAVING COUNT(T.team_id) >= ALL (
    SELECT COUNT(T2.team_id)
    FROM Countries CO2
    JOIN Clubs CL2 ON CO2.country_id = CL2.country_id
    JOIN Teams T2 ON T2.club_id = CL2.club_id
    GROUP BY CO2.country_id
);

EXPLAIN ANALYZE
SELECT tcs.cn
FROM (SELECT 
        CO.country_name cn,
        COUNT(T.team_id) as tc,
        RANK() OVER (ORDER BY COUNT(T.team_id) DESC) as rank
    FROM Countries CO
    JOIN Clubs CL ON CO.country_id = CL.club_id
    JOIN Teams T ON T.club_id = CL.club_id
    GROUP BY CO.country_name) tcs
WHERE rank = 1;



/*СДАЛ 43. Выбрать фамилии, имена, отчества игроков, имеющих однофамильцев среди владельцев. */

EXPLAIN ANALYZE
SELECT 
    P.player_last_name, 
    P.player_first_name, 
    P.player_middle_name
FROM Players P
JOIN ClubOwners O ON  P.player_last_name = O.owner_last_name;

/*СДАЛ 44. Выбрать количество однофамильцев по всей БД. */--общее количество однофамильцев, если два ивановых три петрова -> 5

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


/* 45. Выбрать название команды, фамилию, имя, отчество тренера на сегодняшний день, 
количество игроков в команде на сегодняшний день, количество сыгранных матчей. 
Результата отсортировать по количеству сыгранных матчей в порядке убывания. 
В результирующую таблицу включить все команды, имеющиеся в БД. */

SELECT 
    T.team_name,
    S.staff_last_name,
    S.staff_first_name,
    S.staff_middle_name,
    COUNT(DISTINCT P.player_id),
    COUNT(DISTINCT M.match_id)
FROM 
    Teams T
LEFT JOIN (
    SELECT 
        C.team_id,
        S.staff_id,
        S.staff_first_name,
        S.staff_last_name, 
        S.staff_middle_name
    FROM Contracts C
    JOIN Staff S ON C.staff_id = S.staff_id
    JOIN StaffPositions SP ON S.staff_position_id = SP.staff_position_id
    WHERE C.staff_id IS NOT NULL
      AND SP.staff_position_name = 'Главный тренер'
      AND C.contract_start_date <= CURRENT_DATE
      AND (C.contract_end_date >= CURRENT_DATE OR C.contract_end_date IS NULL)
) S ON T.team_id = S.team_id
LEFT JOIN (
    SELECT P.player_id, C.team_id
    FROM Players P
    JOIN Contracts C ON P.player_id = C.player_id
    WHERE C.contract_start_date <= CURRENT_DATE
     AND (C.contract_end_date >= CURRENT_DATE OR C.contract_end_date IS NULL)
) P ON T.team_id = P.team_id
LEFT JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
GROUP BY 
    T.team_id, 
    T.team_name, 
    S.staff_first_name, 
    S.staff_last_name, 
    S.staff_middle_name
ORDER BY 
    COUNT(DISTINCT M.match_id) DESC;

--без подзапросов====================================
/* 45. Выбрать название команды, фамилию, имя, отчество тренера на сегодняшний день, 
количество игроков в команде на сегодняшний день, количество сыгранных матчей. 
Результата отсортировать по количеству сыгранных матчей в порядке убывания. 
В результирующую таблицу включить все команды, имеющиеся в БД. */

SELECT 
    T.team_name,
    S.staff_last_name,
    S.staff_first_name,
    S.staff_middle_name,
    COUNT(DISTINCT P.player_id),
    COUNT(DISTINCT M.match_id)
FROM 
    Teams T
LEFT JOIN Contracts C_coach ON T.team_id = C_coach.team_id 
                           AND C_coach.contract_start_date <= CURRENT_DATE
                           AND (C_coach.contract_end_date >= CURRENT_DATE OR C_coach.contract_end_date IS NULL)
LEFT JOIN Staff S ON C_coach.staff_id = S.staff_id
LEFT JOIN StaffPositions SP ON S.staff_position_id = SP.staff_position_id 
                           AND SP.staff_position_name = 'Главный тренер'
LEFT JOIN Contracts C_player ON T.team_id = C_player.team_id
                            AND C_player.contract_start_date <= CURRENT_DATE
                            AND (C_player.contract_end_date >= CURRENT_DATE OR C_player.contract_end_date IS NULL)
LEFT JOIN Players P ON C_player.player_id = P.player_id
LEFT JOIN Matches M ON (T.team_id = M.home_team_id OR T.team_id = M.away_team_id)
                   AND M.start_date_time <= CURRENT_TIMESTAMP
GROUP BY 
    T.team_id, 
    T.team_name, 
    S.staff_first_name, 
    S.staff_last_name, 
    S.staff_middle_name
ORDER BY 
    COUNT(DISTINCT M.match_id) DESC;
	
/* 46. Выбрать тренеров, которые работали с командами из более чем двух стран. */

EXPLAIN ANALYZE
SELECT S.staff_id, S.staff_first_name, S.staff_last_name, S.staff_middle_name
FROM Staff S
JOIN StaffPositions SP ON SP.staff_position_id = S.staff_position_id
JOIN Contracts C ON S.staff_id = C.staff_id
JOIN Teams T ON C.team_id = T.team_id
JOIN Clubs CL ON CL.club_id = T.club_id
WHERE SP.staff_position_name = 'Главный тренер'
GROUP BY S.staff_id, S.staff_first_name, S.staff_last_name, S.staff_middle_name
HAVING COUNT(DISTINCT CL.country_id) > 2;

EXPLAIN ANALYZE
SELECT S.staff_id, S.staff_first_name, S.staff_last_name, S.staff_middle_name
FROM Staff S
JOIN StaffPositions SP ON SP.staff_position_id = S.staff_position_id
WHERE SP.staff_position_name = 'Главный тренер'
  AND (
      SELECT COUNT(DISTINCT CL.country_id)
      FROM Contracts C
      JOIN Teams T ON C.team_id = T.team_id
      JOIN Clubs CL ON CL.club_id = T.club_id
      WHERE C.staff_id = S.staff_id
  ) > 2;

EXPLAIN ANALYZE
WITH StaffCountryCounts AS (
    SELECT 
        C.staff_id,
        COUNT(DISTINCT CL.country_id) as country_count
    FROM Contracts C
    JOIN Teams T ON C.team_id = T.team_id
    JOIN Clubs CL ON CL.club_id = T.club_id
    GROUP BY C.staff_id
    HAVING COUNT(DISTINCT CL.country_id) > 2
)
SELECT S.staff_id, S.staff_first_name, S.staff_last_name, S.staff_middle_name
FROM Staff S
JOIN StaffPositions SP ON SP.staff_position_id = S.staff_position_id
WHERE SP.staff_position_name = 'Главный тренер'
  AND EXISTS (
      SELECT 1
      FROM StaffCountryCounts SCC
      WHERE SCC.staff_id = S.staff_id
  );


/*СДАЛ 47. Выбрать дату матча, стадион, название команд-участниц, фамилию и инициалы тренера, 
баллы для всех матчей, общее количество матчей, сыгранных до текущего матча 
каждой из команд-участниц какого-то конкретного турнира (конкретное значение подставьте сами). */
EXPLAIN ANALYZE
SELECT 
    M.start_date_time, 
    S.stadium_name, 
    HT.team_name AS home_team, 
    AWT.team_name AS away_team,
    CONCAT(HC.staff_last_name, ' ', 
           LEFT(HC.staff_first_name, 1) || '.', ' ', 
           COALESCE(LEFT(HC.staff_middle_name, 1) || '.', '')) AS home_coach,
    CONCAT(AC.staff_last_name, ' ', 
           LEFT(AC.staff_first_name, 1) || '.', ' ', 
           COALESCE(LEFT(AC.staff_middle_name, 1) || '.', '')) AS away_coach,
    M.home_score,
    M.away_score,
    (SELECT COUNT(*) FROM Matches M2 
     WHERE (M2.home_team_id = HT.team_id OR M2.away_team_id = HT.team_id) 
       AND M2.start_date_time < M.start_date_time) AS home_team_previous_matches,
    (SELECT COUNT(*) FROM Matches M2 
     WHERE (M2.home_team_id = AWT.team_id OR M2.away_team_id = AWT.team_id) 
       AND M2.start_date_time < M.start_date_time) AS away_team_previous_matches
FROM Matches M
JOIN Stadiums S ON M.stadium_id = S.stadium_id
JOIN Teams HT ON M.home_team_id = HT.team_id
JOIN Teams AWT ON M.away_team_id = AWT.team_id
LEFT JOIN Staff HC ON HT.team_id = HC.team_id AND HC.staff_position_id = 1
LEFT JOIN Staff AC ON AWT.team_id = AC.team_id AND AC.staff_position_id = 1
WHERE M.competition_id = 4;



/*СДАЛ 48. Выбрать названия всех стран и количество команд в стране. Если страна не имеет команды, то вывести ноль. */

SELECT CO.country_name, COALESCE(COUNT(T.team_id),0)
FROM Countries CO 
LEFT JOIN Clubs C ON C.country_id = CO.country_id
LEFT JOIN Teams T ON T.club_id = C.club_id
GROUP BY CO.country_name;




/*СДАЛ 49. Выбрать фамилии, имена, отчества владельцев клубов, имеющих две команды. */
EXPLAIN ANALYZE
SELECT 
    owner_first_name,
    owner_last_name,
    owner_middle_name 
FROM ClubOwners CO
JOIN Clubs CL ON CO.club_id = CL.club_id
JOIN Teams T ON CL.club_id = T.club_id
GROUP BY CO.owner_id, owner_first_name, owner_last_name, owner_middle_name
HAVING COUNT(T.team_id) = 2;


EXPLAIN ANALYZE
SELECT 
    CO1.owner_first_name,
    CO1.owner_last_name,
    CO1.owner_middle_name 
FROM ClubOwners CO1
JOIN Clubs CL ON CO1.club_id = CL.club_id
JOIN Teams T1 ON CL.club_id = T1.club_id
JOIN Teams T2 ON CL.club_id = T2.club_id AND T1.team_id < T2.team_id
LEFT JOIN Teams T3 ON CL.club_id = T3.club_id AND T3.team_id NOT IN (T1.team_id, T2.team_id)
WHERE T3.team_id IS NULL;




/*СДАЛ 50. Выбрать название чемпионата, в котором приняли участие как минимум 
по две команды от каждой страны – участницы. */

SELECT C.competition_name
FROM Competitions C
WHERE 2 <= ALL (
    SELECT COUNT(DISTINCT T.team_id)
    FROM Matches M
    JOIN Teams T ON (M.home_team_id = T.team_id OR M.away_team_id = T.team_id)
    JOIN Clubs CL ON T.club_id = CL.club_id
    WHERE M.competition_id = C.competition_id
    GROUP BY CL.country_id
);


/*СДАЛ 51. Выбрать месяцы, в которых нет дней рождений футболистов. */
----без generate_series а генерации по станд через рекурс

WITH RECURSIVE Месяцы (month_num) AS (
    SELECT 1
   
    UNION ALL
    
    SELECT month_num + 1
    FROM Месяцы
    WHERE month_num < 12
)

SELECT month_num
FROM Месяцы m
WHERE NOT EXISTS (
    SELECT 1 
    FROM Players p 
    WHERE EXTRACT(MONTH FROM p.player_date_of_birth) = m.month_num
)
ORDER BY month_num;

SELECT DISTINCT EXTRACT(MONTH FROM player_date_of_birth)
FROM Players
ORDER BY 1;

--==============================ЛАБА 3 CTE================================================
--==============================ЛАБА 3 CTE================================================
--==============================ЛАБА 3 CTE================================================
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
