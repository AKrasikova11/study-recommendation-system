-- ==========================================================
-- файл: 06_final_checks.sql
--
-- назначение:
-- финальная проверка базы данных
-- после загрузки основных таблиц.
-- ==========================================================


-- ==========================================================
-- проверка результатов загрузки
-- ==========================================================

select count(*) as dictionary_rows
from dictionary;

select count(*) as tasks_rows
from tasks;

select count(*) as attempts_rows
from attempts;

select count(*)
from tasks t
left join dictionary d
    on t.pattern_id = d.pattern_id
where d.pattern_id is null;

select count(*)
from attempts a
left join tasks t
    on a.task_id = t.task_id
where t.task_id is null;


-- ==========================================================
-- ожидаемый результат
--
-- ✓ данные успешно загружены
-- ✓ связи между таблицами корректны
-- ✓ база данных готова к работе
-- ==========================================================