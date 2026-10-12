DROP TABLE IF EXISTS cities_with_idx CASCADE;
DROP TABLE IF EXISTS cities_without_idx CASCADE;
DROP TABLE IF EXISTS countries_with_idx CASCADE;
DROP TABLE IF EXISTS countries_without_idx CASCADE;


CREATE TABLE countries_with_idx (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);
CREATE TABLE cities_with_idx (
    city_id SERIAL PRIMARY KEY,
    city_name TEXT NOT NULL,
    country_id INT NOT NULL,
    population INT DEFAULT 0
);
ALTER TABLE cities_with_idx 
ADD CONSTRAINT fk_cities_countries_idx 
FOREIGN KEY (country_id) REFERENCES countries_with_idx(country_id);
CREATE INDEX idx_cities_country_id ON cities_with_idx(country_id);
CREATE INDEX idx_cities_population ON cities_with_idx(population);

CREATE TABLE countries_without_idx (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);
CREATE TABLE cities_without_idx (
    city_id SERIAL PRIMARY KEY,
    city_name TEXT NOT NULL,
    country_id INT NOT NULL,
    population INT DEFAULT 0
);
ALTER TABLE cities_without_idx 
ADD CONSTRAINT fk_cities_countries_without_idx 
FOREIGN KEY (country_id) REFERENCES countries_without_idx(country_id);


INSERT INTO countries_with_idx (country_name)
SELECT 'Country_' || generate_series(1, 10000);

INSERT INTO cities_with_idx (city_name, country_id, population)
SELECT 
    'City_' || i,
    (random() * 9999 + 1)::int,  
    (random() * 1000000)::int   
FROM generate_series(1, 1000000) i;


INSERT INTO countries_without_idx (country_name)
SELECT 'Country_' || generate_series(1, 10000);

INSERT INTO cities_without_idx (city_name, country_id, population)
SELECT 
    'City_' || i,
    (random() * 9999 + 1)::int, 
    (random() * 1000000)::int    
FROM generate_series(1, 1000000) i;


ANALYZE;

-- ТЕСТ 1: Поиск по внешнему ключу 

-- С индексом
EXPLAIN ANALYZE
SELECT * FROM cities_with_idx 
WHERE country_id = 25;

-- БЕЗ индекса
EXPLAIN ANALYZE
SELECT * FROM cities_without_idx 
WHERE country_id = 25;

-- ТЕСТ 2: JOIN двух таблиц (индекс на внешнем ключе)

--INDEX НЕ ИСПОЛЬЗУЕТСЯ Т.К СЕЛЕКТИВНОСТЬ ВЫСОКАЯ
-- С индексом
EXPLAIN ANALYZE
SELECT c.country_name, ci.city_name, ci.population
FROM countries_with_idx c
JOIN cities_with_idx ci ON c.country_id = ci.country_id;

-- БЕЗ индекса
EXPLAIN ANALYZE
SELECT c.country_name, ci.city_name, ci.population
FROM countries_without_idx c
JOIN cities_without_idx ci ON c.country_id = ci.country_id;

--ИНДЕКС ИСПОЛЬЗУЕТСЯ Т.К СЕЛЕКТИВНОСТЬ НИЗКАЯ
-- С индексом
EXPLAIN ANALYZE
SELECT c.country_name, ci.city_name, ci.population
FROM countries_with_idx c
JOIN cities_with_idx ci ON c.country_id = ci.country_id
WHERE ci.country_id = 25;  

--БЕЗ индекса
EXPLAIN ANALYZE
SELECT c.country_name, ci.city_name, ci.population
FROM countries_without_idx c
JOIN cities_without_idx ci ON c.country_id = ci.country_id
WHERE ci.country_id = 25;  

-- ТЕСТ 3: Поиск по диапазону (индекс на population)

-- С индексом
EXPLAIN ANALYZE
SELECT * FROM cities_with_idx 
WHERE population BETWEEN 5000000 AND 7000000;

-- БЕЗ индекса
EXPLAIN ANALYZE
SELECT * FROM cities_without_idx 
WHERE population BETWEEN 5000000 AND 7000000;

-- ТЕСТ 4: Сортировка по полю

-- С индексом
EXPLAIN ANALYZE
SELECT * FROM cities_with_idx 
WHERE country_id = 30
ORDER BY population DESC;

-- БЕЗ индекса
EXPLAIN ANALYZE
SELECT * FROM cities_without_idx 
WHERE country_id = 30
ORDER BY population DESC;

--///////////////////////UPDATE TESTS///////////////////////////


INSERT INTO cities_with_idx (city_name, country_id, population)
SELECT 'Test_Idx_' || i, 7777, 1000
FROM generate_series(1, 100000) i;

INSERT INTO cities_without_idx (city_name, country_id, population)
SELECT 'Test_Without_Idx_' || i, 7777, 1000
FROM generate_series(1, 100000) i;

-- Обновляем статистику
ANALYZE;

-- ТЕСТ UPDATE 
-- С индексом
\timing on
UPDATE cities_with_idx 
SET population = 20002 
WHERE country_id = 7777;
\timing off

-- Без индекса 
\timing on
UPDATE cities_without_idx 
SET population = 20003
WHERE country_id = 7777;
\timing off

