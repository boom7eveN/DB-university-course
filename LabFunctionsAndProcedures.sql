CREATE OR REPLACE FUNCTION fn_avg_player_salary_invoker(p_team_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE v_avg NUMERIC;
BEGIN
    SELECT AVG(salary) INTO v_avg
      FROM Players
     WHERE team_id = p_team_id;
    RETURN COALESCE(v_avg, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION fn_avg_player_salary_invoker(INT) TO accountant;

CREATE OR REPLACE FUNCTION fn_avg_player_salary_definer(p_team_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE v_avg NUMERIC;
BEGIN
    SELECT AVG(salary) INTO v_avg
      FROM Players
     WHERE team_id = p_team_id;
    RETURN COALESCE(v_avg, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION fn_avg_player_salary_definer(INT) TO accountant;

SELECT player_id, team_id FROM Players;
SELECT fn_avg_player_salary_invoker(1);
SELECT fn_avg_player_salary_definer(1);
==================================================================
CREATE OR REPLACE FUNCTION fn_team_goals(p_team_id INT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COALESCE(SUM(goals_scored), 0)
      INTO v_total
      FROM Players
     WHERE team_id = p_team_id;
    RETURN v_total;
END;
$$;


EXPLAIN ANALYZE
SELECT t.team_id,
       t.team_name,
       (SELECT COALESCE(SUM(p.goals_scored), 0)
          FROM Players p
         WHERE p.team_id = t.team_id) AS total_goals
 FROM Teams t;

EXPLAIN ANALYZE
SELECT t.team_id,
       t.team_name,
       fn_team_goals(t.team_id) AS total_goals
 FROM Teams t;
===========================================================
CREATE OR REPLACE PROCEDURE public.pr_raise_salary(
    p_player_id INT,
    p_percent   NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Players
       SET salary = salary * (1 + p_percent / 100.0)
     WHERE player_id = p_player_id;
END;
$$;

SELECT player_id, player_last_name, salary
  FROM Players
 WHERE player_id = 1;

CALL public.pr_raise_salary(1, 10);

SELECT player_id, player_last_name, salary
  FROM Players
 WHERE player_id = 1;
