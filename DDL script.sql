DROP TABLE IF EXISTS Contracts;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS MatchTypes;
DROP TABLE IF EXISTS TrainingCamps;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS StaffPositions;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS ClubOwners;
DROP TABLE IF EXISTS Clubs;
DROP TABLE IF EXISTS Competitions;
DROP TABLE IF EXISTS Stadiums;
DROP TABLE IF EXISTS TrainingBases;
DROP TABLE IF EXISTS Addresses;
DROP TABLE IF EXISTS Cities;
DROP TABLE IF EXISTS Countries;

CREATE TABLE Countries (
    country_id SERIAL,
    country_name TEXT NOT NULL
);

ALTER TABLE Countries 
ADD CONSTRAINT PK_Countries 
    PRIMARY KEY (country_id);

ALTER TABLE Countries 
ADD CONSTRAINT U_Countries_country_name
    UNIQUE(country_name);

CREATE TABLE Cities (
    city_id SERIAL,
    city_name TEXT NOT NULL,
    country_id INT NOT NULL
);

ALTER TABLE Cities 
ADD CONSTRAINT PK_Cities 
    PRIMARY KEY (city_id);

CREATE TABLE Addresses (
    address_id SERIAL,
    street TEXT NOT NULL,
    building_number TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    city_id INT NOT NULL
);

ALTER TABLE Addresses 
ADD CONSTRAINT PK_Addresses 
    PRIMARY KEY (address_id);

CREATE TABLE Stadiums (
    stadium_id SERIAL,
    stadium_name TEXT NOT NULL,
    surface_type CHAR(1) NOT NULL,
    capacity INT NOT NULL,
    address_id INT NOT NULL
);

ALTER TABLE Stadiums 
ADD CONSTRAINT PK_Stadiums 
    PRIMARY KEY (stadium_id);

ALTER TABLE Stadiums 
ADD CONSTRAINT CH_Stadiums_surface_type
    CHECK (surface_type IN ('N', 'A'));

ALTER TABLE Stadiums 
ADD CONSTRAINT CH_Stadiums_capacity
    CHECK (capacity > 0);

CREATE TABLE TrainingBases (
    training_base_id SERIAL,
    training_base_name TEXT NOT NULL,
    number_of_fields INT NOT NULL,
    address_id INT NOT NULL
);

ALTER TABLE TrainingBases 
ADD CONSTRAINT PK_TrainingBases 
    PRIMARY KEY (training_base_id);

ALTER TABLE TrainingBases 
ADD CONSTRAINT CH_TrainingBases_number_of_fields
    CHECK (number_of_fields > 0);

CREATE TABLE Competitions (
    competition_id SERIAL,
    competition_name TEXT NOT NULL,
    country_id INT NOT NULL,
    prize_fund DECIMAL(10,2) NOT NULL,
    competition_start_date DATE NOT NULL,
    competition_end_date DATE NOT NULL
);

ALTER TABLE Competitions 
ADD CONSTRAINT PK_Competitions 
    PRIMARY KEY (competition_id);

ALTER TABLE Competitions 
ADD CONSTRAINT CH_Competitions_dates
    CHECK (competition_end_date >= competition_start_date);

CREATE TABLE Clubs (
    club_id SERIAL,
    club_name TEXT NOT NULL,
    country_id INT NOT NULL
);

ALTER TABLE Clubs 
ADD CONSTRAINT PK_Clubs 
    PRIMARY KEY (club_id);

CREATE TABLE ClubOwners (
    owner_id SERIAL,
    owner_first_name TEXT NOT NULL,
    owner_last_name TEXT NOT NULL,
    owner_middle_name TEXT,
    ownership_percentage DECIMAL(5,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    club_id INT NOT NULL
);

ALTER TABLE ClubOwners 
ADD CONSTRAINT PK_ClubOwners 
    PRIMARY KEY (owner_id);

ALTER TABLE ClubOwners 
ADD CONSTRAINT CH_ClubOwners_ownership_percentage
    CHECK (ownership_percentage BETWEEN 0 AND 100);

CREATE TABLE Teams (
    team_id SERIAL,
    team_name TEXT NOT NULL,
    team_rating SMALLINT NOT NULL,
    club_id INT NOT NULL
);

ALTER TABLE Teams 
ADD CONSTRAINT PK_Teams 
    PRIMARY KEY (team_id);

ALTER TABLE Teams 
ADD CONSTRAINT CH_Teams_team_rating
    CHECK (team_rating > 0);

CREATE TABLE TrainingCamps (
    camp_id SERIAL,
    camp_start_date DATE NOT NULL,
    camp_end_date DATE NOT NULL,
    team_id INT NOT NULL,
    training_base_id INT NOT NULL
);

ALTER TABLE TrainingCamps 
ADD CONSTRAINT PK_TrainingCamps 
    PRIMARY KEY (camp_id);

ALTER TABLE TrainingCamps 
ADD CONSTRAINT CH_TrainingCamps_dates
    CHECK (camp_end_date >= camp_start_date);

CREATE TABLE Players (
    player_id SERIAL,
    player_first_name TEXT NOT NULL,
    player_last_name TEXT NOT NULL,
    player_middle_name TEXT,
    player_gender CHAR(1) NOT NULL,
    goals_scored SMALLINT DEFAULT 0 NOT NULL,
    goals_saved SMALLINT DEFAULT 0 NOT NULL,
    player_date_of_birth DATE NOT NULL,
    team_id INT
);

ALTER TABLE Players 
ADD CONSTRAINT PK_Players 
    PRIMARY KEY (player_id);

ALTER TABLE Players 
ADD CONSTRAINT CH_Players_gender
    CHECK (player_gender IN ('M', 'F'));

ALTER TABLE Players 
ADD CONSTRAINT CH_Players_goals_scored
    CHECK (goals_scored >= 0);

ALTER TABLE Players 
ADD CONSTRAINT CH_Players_goals_saved
    CHECK (goals_saved >= 0);

CREATE TABLE StaffPositions (
    staff_position_id SERIAL,
    staff_position_name TEXT NOT NULL
);

ALTER TABLE StaffPositions 
ADD CONSTRAINT PK_StaffPositions 
    PRIMARY KEY (staff_position_id);

ALTER TABLE StaffPositions 
ADD CONSTRAINT U_Countries_staff_position_name
    UNIQUE(staff_position_name);

CREATE TABLE Staff (
    staff_id SERIAL,
    staff_first_name TEXT NOT NULL,
    staff_last_name TEXT NOT NULL,
    staff_middle_name TEXT,
    staff_gender CHAR(1) NOT NULL,
    staff_date_of_birth DATE NOT NULL,
    staff_salary DECIMAL(10,2) NOT NULL,
    staff_position_id INT NOT NULL,
    team_id INT NOT NULL
);

ALTER TABLE Staff 
ADD CONSTRAINT PK_Staff 
    PRIMARY KEY (staff_id);

ALTER TABLE Staff 
ADD CONSTRAINT CH_Staff_gender
    CHECK (staff_gender IN ('M', 'F'));

ALTER TABLE Staff 
ADD CONSTRAINT CH_Staff_salary
    CHECK (staff_salary > 0);

CREATE TABLE Contracts (
    contract_id SERIAL,
    contract_sign_date DATE NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    player_id INT,
    staff_id INT
);

ALTER TABLE Contracts 
ADD CONSTRAINT PK_Contracts 
    PRIMARY KEY (contract_id);

ALTER TABLE Contracts 
ADD CONSTRAINT CH_Contracts_playerid_staffid 
    CHECK (
        (player_id IS NULL AND staff_id IS NOT NULL) OR 
        (player_id IS NOT NULL AND staff_id IS NULL)
);

ALTER TABLE Contracts 
ADD CONSTRAINT CH_Contracts_dates
    CHECK (contract_end_date >= contract_start_date);

CREATE TABLE MatchTypes (
    match_type_id SERIAL,
    match_type_name TEXT NOT NULL
);

ALTER TABLE MatchTypes 
ADD CONSTRAINT PK_MatchTypes 
    PRIMARY KEY (match_type_id);

ALTER TABLE MatchTypes 
ADD CONSTRAINT U_MatchTypes_match_type_name
    UNIQUE(match_type_name);

CREATE TABLE Matches (
    match_id SERIAL,
    season TEXT NOT NULL, --XXXX/XXXX
    ticket_price DECIMAL(10,2) NOT NULL,
    home_score SMALLINT DEFAULT 0 NOT NULL,
    away_score SMALLINT DEFAULT 0 NOT NULL,
    start_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    competition_id INT NOT NULL,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    stadium_id INT NOT NULL,
    match_type_id INT NOT NULL
);

ALTER TABLE Matches 
ADD CONSTRAINT PK_Matches 
    PRIMARY KEY (match_id);

ALTER TABLE Matches 
ADD CONSTRAINT CH_Matches_different_teams 
    CHECK (home_team_id <> away_team_id);

ALTER TABLE Matches 
ADD CONSTRAINT CH_Matches_home_score
    CHECK (home_score >= 0);

ALTER TABLE Matches 
ADD CONSTRAINT CH_Matches_away_score
    CHECK (away_score >= 0);

ALTER TABLE Matches 
ADD CONSTRAINT CH_Matches_ticket_price
    CHECK (ticket_price >= 0);

ALTER TABLE Matches 
ADD CONSTRAINT CH_Matches_season_format
    CHECK (season ~ '^\d{4}/\d{4}$');

ALTER TABLE Matches 
ADD CONSTRAINT CH_Matches_start_date_time
    CHECK (start_date_time >= '1900-01-01'::timestamp);

/*==============================================================================**/

ALTER TABLE Cities 
ADD CONSTRAINT FK_Cities_Countries 
    FOREIGN KEY (country_id) REFERENCES Countries(country_id);

ALTER TABLE Addresses 
ADD CONSTRAINT FK_Addresses_Cities 
    FOREIGN KEY (city_id) REFERENCES Cities(city_id);

ALTER TABLE Stadiums 
ADD CONSTRAINT FK_Stadiums_Addresses 
    FOREIGN KEY (address_id) REFERENCES Addresses(address_id);

ALTER TABLE TrainingBases 
ADD CONSTRAINT FK_TrainingBases_Addresses 
    FOREIGN KEY (address_id) REFERENCES Addresses(address_id);

ALTER TABLE Competitions 
ADD CONSTRAINT FK_Competitions_Countries 
    FOREIGN KEY (country_id) REFERENCES Countries(country_id);

ALTER TABLE Clubs 
ADD CONSTRAINT FK_Clubs_Countries 
    FOREIGN KEY (country_id) REFERENCES Countries(country_id);

ALTER TABLE ClubOwners 
ADD CONSTRAINT FK_ClubOwners_Clubs 
    FOREIGN KEY (club_id) REFERENCES Clubs(club_id);

ALTER TABLE Teams 
ADD CONSTRAINT FK_Teams_Clubs 
    FOREIGN KEY (club_id) REFERENCES Clubs(club_id);

ALTER TABLE TrainingCamps 
ADD CONSTRAINT FK_TrainingCamps_Teams 
    FOREIGN KEY (team_id) REFERENCES Teams(team_id);

ALTER TABLE TrainingCamps 
ADD CONSTRAINT FK_TrainingCamps_TrainingBases 
    FOREIGN KEY (training_base_id) REFERENCES TrainingBases(training_base_id);

ALTER TABLE Players 
ADD CONSTRAINT FK_Players_Teams 
    FOREIGN KEY (team_id) REFERENCES Teams(team_id);

ALTER TABLE Staff 
ADD CONSTRAINT FK_Staff_StaffPositions 
    FOREIGN KEY (staff_position_id) REFERENCES StaffPositions(staff_position_id);

ALTER TABLE Staff 
ADD CONSTRAINT FK_Staff_Teams 
    FOREIGN KEY (team_id) REFERENCES Teams(team_id);

ALTER TABLE Contracts 
ADD CONSTRAINT FK_Contracts_Players 
    FOREIGN KEY (player_id) REFERENCES Players(player_id);

ALTER TABLE Contracts 
ADD CONSTRAINT FK_Contracts_Staff 
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id);




ALTER TABLE Matches 
ADD CONSTRAINT FK_Matches_Competitions 
    FOREIGN KEY (competition_id) REFERENCES Competitions(competition_id);

ALTER TABLE Matches 
ADD CONSTRAINT FK_Matches_HomeTeams 
    FOREIGN KEY (home_team_id) REFERENCES Teams(team_id);

ALTER TABLE Matches 
ADD CONSTRAINT FK_Matches_AwayTeams 
    FOREIGN KEY (away_team_id) REFERENCES Teams(team_id);

ALTER TABLE Matches 
ADD CONSTRAINT FK_Matches_Stadiums 
    FOREIGN KEY (stadium_id) REFERENCES Stadiums(stadium_id);

ALTER TABLE Matches
ADD CONSTRAINT FK_Matches_MatchTypes 
    FOREIGN KEY (match_type_id) REFERENCES MatchTypes(match_type_id);


ALTER TABLE Players 
ADD COLUMN salary DECIMAL(10,2) NOT NULL DEFAULT 0;

ALTER TABLE Players 
ADD CONSTRAINT CH_Players_salary
    CHECK (salary >= 0);

ALTER TABLE Contracts ADD COLUMN team_id INT;

ALTER TABLE Contracts 
ADD CONSTRAINT FK_Contracts_Team
    FOREIGN KEY (team_id) REFERENCES Teams(team_id);