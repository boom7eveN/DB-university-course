--sqlshell
--postgres:

CREATE ROLE admin WITH LOGIN PASSWORD 'admin' CREATEDB CREATEROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA public TO admin WITH GRANT OPTION;


--admin:

CREATE ROLE readonly_user;
CREATE ROLE analyst WITH LOGIN PASSWORD 'analyst';
CREATE ROLE hr WITH LOGIN PASSWORD 'hr';
CREATE ROLE sportdirector WITH LOGIN PASSWORD 'sportdirector';
CREATE ROLE accountant WITH LOGIN PASSWORD 'accountant';
CREATE ROLE seniorhr WITH LOGIN PASSWORD 'seniorhr';

GRANT readonly_user TO analyst;
GRANT readonly_user TO hr;
GRANT readonly_user TO sportdirector;

GRANT SELECT ON countries, cities, addresses TO readonly_user;
GRANT SELECT ON stadiums, trainingbases, competitions TO readonly_user;
GRANT SELECT ON clubs, clubowners, teams TO readonly_user;
GRANT SELECT ON trainingcamps, staffpositions, matchtypes TO readonly_user;
GRANT SELECT ON players, staff, contracts, matches TO readonly_user;

GRANT SELECT, INSERT, UPDATE, DELETE ON players TO hr;
GRANT SELECT, INSERT, UPDATE, DELETE ON staff TO hr;
GRANT SELECT, INSERT, UPDATE, DELETE ON contracts TO hr;

GRANT SELECT, INSERT, UPDATE, DELETE ON teams TO sportdirector;
GRANT SELECT, INSERT, UPDATE, DELETE ON matches TO sportdirector;
GRANT SELECT, INSERT, UPDATE, DELETE ON trainingcamps TO sportdirector;

GRANT SELECT ON clubowners, competitions TO accountant;
GRANT SELECT (salary) ON players TO accountant;
GRANT SELECT (staff_salary) ON staff TO accountant;
GRANT UPDATE (profit) ON clubowners TO accountant;

GRANT SELECT, INSERT, UPDATE, DELETE ON players TO seniorhr WITH GRANT OPTION;
GRANT hr TO seniorhr;