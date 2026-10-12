SELECT
    trigger_schema,
    trigger_name,
    event_object_schema,
    event_object_table,
    event_manipulation,
    action_timing,
    action_orientation,
    action_statement
FROM information_schema.triggers
ORDER BY event_object_table, trigger_name;
======================================================================
--Первый триггер
CREATE OR REPLACE FUNCTION trg_contract_check_player_age_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_birth_date  DATE;
    v_age_at_start INT;
BEGIN

    SELECT player_date_of_birth
      INTO v_birth_date
      FROM Players
     WHERE player_id = NEW.player_id;

    IF v_birth_date IS NULL THEN
        RAISE EXCEPTION 'Игрок с player_id=% не найден', NEW.player_id;
    END IF;

    v_age_at_start := DATE_PART('year', AGE(NEW.contract_start_date, v_birth_date));

    IF v_age_at_start < 16 THEN
        RAISE EXCEPTION
            'Игрок % (ДР: %) на дату начала контракта % имеет возраст % лет. Минимальный возраст - 16.',
            NEW.player_id, v_birth_date, NEW.contract_start_date, v_age_at_start;
    END IF;


    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_contract_check_player_age
BEFORE INSERT OR UPDATE OF player_id, contract_start_date
ON Contracts
FOR EACH ROW
EXECUTE FUNCTION trg_contract_check_player_age_fn();

INSERT INTO Contracts (contract_sign_date, contract_start_date, contract_end_date, player_id)
VALUES ('2026-10-07', '2026-11-01', '2029-06-30', 22);


=========================================

CREATE OR REPLACE FUNCTION trg_team_rating_recalc_fn()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Teams SET team_rating = team_rating + CASE
        WHEN NEW.home_score > NEW.away_score THEN 3
        WHEN NEW.home_score = NEW.away_score THEN 1
        ELSE 0 END
     WHERE team_id = NEW.home_team_id;

    UPDATE Teams SET team_rating = team_rating + CASE
        WHEN NEW.away_score > NEW.home_score THEN 3
        WHEN NEW.away_score = NEW.home_score THEN 1
        ELSE 0 END
     WHERE team_id = NEW.away_team_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_team_rating_recalc
AFTER INSERT ON Matches
FOR EACH ROW EXECUTE FUNCTION trg_team_rating_recalc_fn();

SELECT
    t.team_id,
    t.team_name,
    t.team_rating,
    c.club_name
FROM Teams t
JOIN Clubs c ON c.club_id = t.club_id
WHERE t.team_id IN (1, 2)
ORDER BY t.team_id;

INSERT INTO Matches (
    season,
    ticket_price,
    home_score,
    away_score,
    start_date_time,
    competition_id,
    home_team_id,
    away_team_id,
    stadium_id,
    match_type_id
)
VALUES (
    '2026/2027',
    1500.00,
    2,
    1, 
    '2026-10-20 19:10:00+03',
    1,  
    1, 
    2, 1, 1       
);

========================================================
--AUDIT TRIGGER

CREATE TABLE AuditLog (
    audit_id       BIGSERIAL    PRIMARY KEY,
    table_name     TEXT         NOT NULL,
    operation      CHAR(1)      NOT NULL CHECK (operation IN ('I','U','D')),
    row_pk         TEXT,
    old_values     JSONB,
    new_values     JSONB,
    changed_fields TEXT[],
    changed_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    changed_by     TEXT         NOT NULL DEFAULT current_user
);

CREATE OR REPLACE FUNCTION audit_trigger_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_old      JSONB;
    v_new      JSONB;
    v_pk       TEXT;
    v_changed  TEXT[];
    v_pk_col   TEXT := TG_ARGV[0];
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_new := to_jsonb(NEW);
        v_pk  := v_new ->> v_pk_col;

        INSERT INTO AuditLog(table_name, operation, row_pk, new_values)
        VALUES (TG_TABLE_NAME, 'I', v_pk, v_new);

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        v_old := to_jsonb(OLD);
        v_new := to_jsonb(NEW);
        v_pk  := v_new ->> v_pk_col;

        SELECT array_agg(key ORDER BY key)
          INTO v_changed
          FROM jsonb_each(v_new)
         WHERE v_new -> key IS DISTINCT FROM v_old -> key;

        IF v_changed IS NULL THEN
            RETURN NEW;
        END IF;

        INSERT INTO AuditLog(table_name, operation, row_pk,
                             old_values, new_values, changed_fields)
        VALUES (TG_TABLE_NAME, 'U', v_pk,
                v_old, v_new, v_changed);

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        v_old := to_jsonb(OLD);
        v_pk  := v_old ->> v_pk_col;

        INSERT INTO AuditLog(table_name, operation, row_pk, old_values)
        VALUES (TG_TABLE_NAME, 'D', v_pk, v_old);

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_audit_players
AFTER INSERT OR UPDATE OR DELETE ON Players
FOR EACH ROW EXECUTE FUNCTION audit_trigger_fn('player_id');

\x
SELECT * FROM AuditLog;
\x

плюсы триггеров: бизнес правила на уровне бд - независим от клиента, логика в одном месте(бд), аудит, каскадные операции, сложная валидация, сложные бизнес правила
минусы: скрытая логика, сложность отладки, производительность, рекурсия, не протестируешь как код

