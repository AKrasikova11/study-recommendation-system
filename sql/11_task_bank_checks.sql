-- ==========================================================
-- файл: 11_task_bank_checks.sql
--
-- назначение:
-- финальная проверка таблицы task_bank
-- после загрузки данных.
-- ==========================================================


-- ==========================================================
-- проверка результатов загрузки
-- ==========================================================

select
    count(*) as task_bank_rows
from task_bank;


select
    count(*) as missing_patterns
from task_bank tb
left join dictionary d
    on tb.pattern_id = d.pattern_id
where d.pattern_id is null;


select
    difficulty,
    count(*) as task_count
from task_bank
group by difficulty
order by difficulty;


select
    d.domain_name,
    d.group_name,
    d.subgroup_name,
    d.pattern,
    count(tb.bank_task_id) as task_count
from dictionary d
left join task_bank tb
    on d.pattern_id = tb.pattern_id
group by
    d.domain_name,
    d.group_name,
    d.subgroup_name,
    d.pattern
order by
    d.domain_name,
    d.group_name,
    d.subgroup_name,
    d.pattern;


-- ==========================================================
-- ожидаемый результат
--
-- ✓ task_bank успешно загружена
-- ✓ отсутствуют нарушения ссылочной целостности
-- ✓ все задачи связаны с pattern_id
-- ✓ база данных готова к работе
-- ==========================================================