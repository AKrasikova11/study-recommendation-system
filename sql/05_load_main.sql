-- ==========================================================
-- файл: 05_load_main.sql
--
-- назначение:
-- загрузка данных из raw-таблиц
-- в основные таблицы проекта.
--
-- порядок загрузки:
-- 1. dictionary
-- 2. tasks
-- 3. attempts
--
-- перед запуском рекомендуется выполнить
-- 04_validation.sql.
-- ==========================================================


-- ==========================================================
-- загрузка dictionary
-- ==========================================================

insert into dictionary (
    pattern,
    domain_name,
    group_name,
    subgroup_name,
    how_to_identify,
    when_to_use
)
select
    pattern,
    domain,
    "group",
    subgroup,
    how_to_identify,
    when_to_use
from dictionary_raw;

-- ==========================================================
-- загрузка tasks
-- ==========================================================

insert into tasks (
    task_code,
    pattern_id,
    difficulty,
    title,
    prompt
)
select
    t.task_code,
    d.pattern_id,
    t.difficulty,
    t.title,
    t.prompt
from tasks_raw t
join dictionary d
    on t.pattern = d.pattern;

-- ==========================================================
-- загрузка attempts
-- ==========================================================

insert into attempts (
    task_id,
    attempt_date,
    score,
    comment
)
select
    t.task_id,
    a.date::date,
    a.score::numeric(4,2),
    a.comment
from attempts_raw a
join tasks t
    on a.task_code = t.task_code;


-- ==========================================================
-- ожидаемый результат
--
-- ✓ dictionary заполнена
-- ✓ tasks заполнена
-- ✓ attempts заполнена
--
-- следующий шаг:
-- 06_final_checks.sql
-- ==========================================================