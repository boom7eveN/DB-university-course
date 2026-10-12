TRUNCATE TABLE 
    Contracts,
    Matches,
    MatchTypes,
    TrainingCamps,
    Players,
    Staff,
    StaffPositions,
    Teams,
    ClubOwners,
    Clubs,
    Competitions,
    Stadiums,
    TrainingBases,
    Addresses,
    Cities,
    Countries
RESTART IDENTITY CASCADE;

INSERT INTO Countries (country_name) 
VALUES ('Россия'),
       ('Англия');

INSERT INTO Cities (city_name, country_id) 
VALUES ('Москва', (SELECT country_id FROM Countries WHERE country_name = 'Россия')),
       ('Лондон', (SELECT country_id FROM Countries WHERE country_name = 'Англия'));

INSERT INTO Addresses (street, building_number, postal_code, city_id) 
VALUES ('Ленинградский проспект', '36', '125167', (SELECT city_id FROM Cities WHERE city_name = 'Москва')),
       ('Stadium Road', '75', 'SW6 1HS', (SELECT city_id FROM Cities WHERE city_name = 'Лондон')),
       ('Проспект Победы', '25', '119000', (SELECT city_id FROM Cities WHERE city_name = 'Москва')),
       ('Чистая улица', '10', '123456', (SELECT city_id FROM Cities WHERE city_name = 'Москва')),
       ('Улица-с-дефисами', '20', '123457', (SELECT city_id FROM Cities WHERE city_name = 'Москва')),
       ('Улица_с_подчеркиваниями', '30', '123458', (SELECT city_id FROM Cities WHERE city_name = 'Лондон')),
       ('Улица\с\обратными', '40', '123459', (SELECT city_id FROM Cities WHERE city_name = 'Лондон'));

INSERT INTO Stadiums (stadium_name, surface_type, capacity, address_id) 
VALUES ('Лужники', 'A', 81000, (SELECT address_id FROM Addresses WHERE street = 'Ленинградский проспект')),
       ('Стэмфорд Бридж', 'A', 40834, (SELECT address_id FROM Addresses WHERE street = 'Stadium Road'));

INSERT INTO TrainingBases (training_base_name, number_of_fields, address_id) 
VALUES ('База ЦСКА', 5, (SELECT address_id FROM Addresses WHERE street = 'Ленинградский проспект')),
       ('База без сборов', 1, (SELECT address_id FROM Addresses WHERE street = 'Ленинградский проспект')),
       ('Кобхэм', 6, (SELECT address_id FROM Addresses WHERE street = 'Stadium Road'));

INSERT INTO Competitions (competition_name, country_id, prize_fund, competition_start_date, competition_end_date) 
VALUES 
('Суперкубок России', (SELECT country_id FROM Countries WHERE country_name = 'Россия'), 500000.00, '2023-07-10', '2023-07-10'),
('Кубок Лиги', (SELECT country_id FROM Countries WHERE country_name = 'Россия'), 750000.00, '2023-08-01', '2024-02-28'),
('Чемпионат России', (SELECT country_id FROM Countries WHERE country_name = 'Россия'), 5000000.00, '2023-07-15', '2024-05-25'),
       ('Кубок России', (SELECT country_id FROM Countries WHERE country_name = 'Россия'), 1000000.00, '2023-07-20', '2024-05-15');

INSERT INTO Clubs (club_name, country_id) 
VALUES ('ЦСКА', (SELECT country_id FROM Countries WHERE country_name = 'Россия')),
       ('Челси', (SELECT country_id FROM Countries WHERE country_name = 'Англия'));

INSERT INTO ClubOwners (owner_first_name, owner_last_name, owner_middle_name, ownership_percentage, profit, club_id) 
VALUES ('Евгений', 'Гинер', 'Васильевич', 100.00, 15000000.00, (SELECT club_id FROM Clubs WHERE club_name = 'ЦСКА')),
       ('Роман', 'Абрамович', 'Аркадьевич', 100.00, 50000000.00, (SELECT club_id FROM Clubs WHERE club_name = 'Челси'));

INSERT INTO Teams (team_name, team_rating, club_id) 
VALUES ('ЦСКА Основной состав', 85, (SELECT club_id FROM Clubs WHERE club_name = 'ЦСКА')),
       ('ЦСКА-Ю', 50, (SELECT club_id FROM Clubs WHERE club_name = 'ЦСКА')), 
       ('Челси Основной состав', 90, (SELECT club_id FROM Clubs WHERE club_name = 'Челси')),
	   ('Четырёх Соревнуемая', 90, (SELECT club_id FROM Clubs WHERE club_name = 'Челси')),
       ('ЦСКА Воронеж', 75, (SELECT club_id FROM Clubs WHERE club_name = 'ЦСКА'));

INSERT INTO TrainingCamps (camp_start_date, camp_end_date, team_id, training_base_id) 
VALUES ('2023-06-15', '2023-07-10', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 
        (SELECT training_base_id FROM TrainingBases WHERE training_base_name = 'База ЦСКА')),
       ('2023-07-01', '2023-07-25', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 
        (SELECT training_base_id FROM TrainingBases WHERE training_base_name = 'Кобхэм'));

INSERT INTO StaffPositions (staff_position_name) 
VALUES ('Главный тренер'),
       ('Тренер'),
       ('Врач'),
       ('Аналитик');

INSERT INTO Staff (staff_first_name, staff_last_name, staff_middle_name, staff_gender, staff_date_of_birth, staff_salary, staff_position_id, team_id) 
VALUES ('Владимир', 'Федотов', 'Иванович', 'M', '1970-05-15', 250000.00, 
        (SELECT staff_position_id FROM StaffPositions WHERE staff_position_name = 'Главный тренер'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав')),
       ('Анна', 'Петрова', 'Сергеевна', 'F', '1990-03-15', 45000.00,
        (SELECT staff_position_id FROM StaffPositions WHERE staff_position_name = 'Аналитик'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав')),
       ('Иван', 'Сидоров', 'Алексеевич', 'M', '1988-07-22', 42000.00,
        (SELECT staff_position_id FROM StaffPositions WHERE staff_position_name = 'Тренер'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав')),
       ('Мария', 'Иванова', 'Петровна', 'F', '1985-06-20', 35000.00,
        (SELECT staff_position_id FROM StaffPositions WHERE staff_position_name = 'Врач'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав')),
       ('Алексей', 'Богатов', 'Викторович', 'M', '1975-01-10', 50000.00,
        (SELECT staff_position_id FROM StaffPositions WHERE staff_position_name = 'Главный тренер'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'));

INSERT INTO Players (player_first_name, player_last_name, player_middle_name, player_gender, goals_scored, goals_saved, player_date_of_birth, team_id, salary) 
VALUES 
('Иван', 'Иванов', 'Петрович', 'M', 10, 0, '1990-01-15', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 150000.00),
('Иван', 'Иванов', 'Петрович', 'M', 8, 0, '1991-03-20', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 120000.00),
('Иван', 'Иванов', 'Сергеевич', 'M', 5, 0, '1992-05-25', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 90000.00),
('Петр', 'Иванов', 'Александрович', 'M', 3, 0, '1993-07-30', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 200000.00),
('Игорь', 'Акинфеев', 'Владимирович', 'M', 0, 350, '1986-04-08', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 300000.00),
('Игорь', 'Акинфеев-Двойной', 'Владимирович', 'M', 0, 350, '1987-04-08', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 250000.00),
('Федор', 'Чалов', 'Дмитриевич', 'M', 85, 0, '1998-04-10', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 180000.00),
('Алексей', 'Безкомандный', NULL, 'M', 0, 0, '1995-08-15', NULL, 0.00),
('Дмитрий', 'Свободный', NULL, 'M', 0, 0, '1994-09-20', NULL, 0.00),
('Артем', 'Молодой', 'Олегович', 'M', 5, 0, '2000-01-15', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 50000.00),
('Дмитрий', 'Зимний', 'Игоревич', 'M', 10, 0, '1990-12-15', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 110000.00),
('Анна', 'Смирнова', 'Андреевна', 'F', 15, 0, '1995-04-15', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 220000.00),
('Ли', 'Сан', 'Минович', 'M', 10, 0, '1995-02-15', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 190000.00),
('Ива', 'Петр', NULL, 'M', 3, 0, '1990-01-01', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 80000.00),
('Сидр', 'Олег', NULL, 'M', 5, 0, '1991-02-01', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 170000.00),
('Петровский', 'Алексей', NULL, 'M', 7, 0, '1992-03-01', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 95000.00),
('Зимний', 'Игрок', NULL, 'M', 8, 0, '1995-12-15', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 85000.00),
('Летний', 'Игрок', NULL, 'M', 6, 0, '1995-07-15', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 160000.00),
('Иван', 'Иванов-Петров', 'Сергеевич', 'M', 12, 0, '1993-04-15', (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'), 130000.00),
('Петр', 'Сидоров Козлов', 'Алексеевич', 'M', 9, 0, '1994-05-20', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 210000.00),
('Сын', 'Абрамович', 'Алексеевич', 'M', 9, 0, '1998-05-20', (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'), 240000.00);

INSERT INTO Contracts (contract_sign_date, contract_start_date, contract_end_date, player_id, staff_id) 
VALUES ('2023-01-15', '2023-01-15', '2025-06-30', 
        (SELECT player_id FROM Players WHERE player_first_name = 'Игорь' AND player_last_name = 'Акинфеев'), 
        NULL),
       ('2023-02-20', '2023-02-20', '2024-06-30', 
        (SELECT player_id FROM Players WHERE player_first_name = 'Федор' AND player_last_name = 'Чалов'), 
        NULL),
       ('2023-01-10', '2023-01-10', '2025-06-30', 
        NULL,
        (SELECT staff_id FROM Staff WHERE staff_first_name = 'Владимир' AND staff_last_name = 'Федотов'));

INSERT INTO MatchTypes (match_type_name) 
VALUES ('Товарищеский'),
       ('Чемпионат'),
       ('Кубок');

INSERT INTO Matches (season, ticket_price, home_score, away_score, start_date_time, competition_id, home_team_id, away_team_id, stadium_id, match_type_id) 
VALUES ('2022/2023', 1500.00, 2, 1, '2023-05-15 19:00:00+03',
        (SELECT competition_id FROM Competitions WHERE competition_name = 'Чемпионат России'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'),
        (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
        (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Чемпионат')),
       ('2022/2023', 1800.00, 1, 1, '2023-03-10 17:30:00+03',
        (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'),
        (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
        (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
       ('2023/2024', 1700.00, 4, 0, '2023-11-10 18:00:00+03',
        (SELECT competition_id FROM Competitions WHERE competition_name = 'Чемпионат России'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'),
        (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
        (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Чемпионат')),
       ('2022/2023', 1200.00, 1, 2, '2023-04-15 15:00:00+03',
        (SELECT competition_id FROM Competitions WHERE competition_name = 'Чемпионат России'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'),
        (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
        (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Чемпионат')),
       ('2022/2023', 1300.00, 0, 0, '2023-10-20 16:00:00+03',
        (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
        (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
        (SELECT team_id FROM Teams WHERE team_name = 'Челси Основной состав'),
        (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
        (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
		('2023/2024', 1000.00, 1, 2, '2023-09-01 18:00:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Воронеж'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
 
('2023/2024', 1100.00, 0, 3, '2023-09-15 19:00:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Воронеж'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
 
('2023/2024', 1200.00, 2, 2, '2023-10-01 17:30:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Воронеж'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
 ('2023/2024', 1300.00, 1, 4, '2023-10-15 16:00:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Воронеж'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
 ('2023/2024', 1500.00, 2, 2, '2023-09-10 18:00:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Чемпионат России'),
 (SELECT team_id FROM Teams WHERE team_name = 'Четырёх Соревнуемая'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Чемпионат')),
 
('2023/2024', 1400.00, 1, 3, '2023-10-05 19:30:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок России'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT team_id FROM Teams WHERE team_name = 'Четырёх Соревнуемая'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
 
('2023/2024', 1800.00, 0, 1, '2023-07-15 20:00:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Суперкубок России'),
 (SELECT team_id FROM Teams WHERE team_name = 'Четырёх Соревнуемая'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок')),
 
('2023/2024', 1600.00, 2, 1, '2023-11-20 17:00:00+03',
 (SELECT competition_id FROM Competitions WHERE competition_name = 'Кубок Лиги'),
 (SELECT team_id FROM Teams WHERE team_name = 'Четырёх Соревнуемая'),
 (SELECT team_id FROM Teams WHERE team_name = 'ЦСКА Основной состав'),
 (SELECT stadium_id FROM Stadiums WHERE stadium_name = 'Лужники'),
 (SELECT match_type_id FROM MatchTypes WHERE match_type_name = 'Кубок'));