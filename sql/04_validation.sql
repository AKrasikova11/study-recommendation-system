-- ==========================================================
-- файл: 04_validation.sql
--
-- назначение:
-- проверка данных после импорта
-- в raw-таблицы.
--
-- перед запуском убедитесь,
-- что данные импортированы из Excel.
-- ==========================================================


-- ==========================================================
-- проверка количества строк
-- ==========================================================

select count(*) as dictionary_rows
from dictionary_raw;

select count(*) as tasks_rows
from tasks_raw;

select count(*) as attempts_rows
from attempts_raw;


-- ==========================================================
-- dictionary_raw
-- ==========================================================

select
    pattern,
    count(*) as cnt
from dictionary_raw
group by pattern
having count(*) > 1;

select *
from dictionary_raw
where pattern is null
   or domain is null
   or "group" is null
   or subgroup is null;


-- ==========================================================
-- tasks_raw
-- ==========================================================

select
    task_code,
    count(*) as cnt
from tasks_raw
group by task_code
having count(*) > 1;

select *
from tasks_raw
where task_code is null
   or pattern is null
   or difficulty is null
   or title is null
   or prompt is null;

select distinct
    difficulty
from tasks_raw
order by difficulty;

select distinct
    t.pattern
from tasks_raw t
left join dictionary_raw d
    on t.pattern = d.pattern
where d.pattern is null;


-- ==========================================================
-- attempts_raw
-- ==========================================================

select *
from attempts_raw
where task_code is null
   or date is null
   or score is null;

select distinct
    a.task_code
from attempts_raw a
left join tasks_raw t
    on a.task_code = t.task_code
where t.task_code is null;

select distinct
    a.pattern
from attempts_raw a
left join dictionary_raw d
    on a.pattern = d.pattern
where d.pattern is null;

select
    score::numeric as score,
    count(*) as cnt
from attempts_raw
group by score::numeric
order by score::numeric;


-- ==========================================================
-- проверка связей
-- ==========================================================

select
    count(*) as missing_patterns
from tasks_raw t
left join dictionary_raw d
    on t.pattern = d.pattern
where d.pattern is null;

select
    count(*) as missing_tasks
from attempts_raw a
left join tasks_raw t
    on a.task_code = t.task_code
where t.task_code is null;

select
    count(*) as missing_dictionary
from attempts_raw a
left join dictionary_raw d
    on a.pattern = d.pattern
where d.pattern is null;


-- ==========================================================
-- ожидаемый результат
--
-- ✓ отсутствуют дубли
-- ✓ отсутствуют пропущенные значения
-- ✓ все связи корректны
-- ✓ данные готовы к загрузке
--
-- следующий шаг:
-- 05_load_main.sql
-- ==========================================================