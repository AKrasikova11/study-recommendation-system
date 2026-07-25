-- ==========================================================
-- файл: 10_load_task_bank.sql
--
-- назначение:
-- загрузка данных из task_bank_raw
-- в основную таблицу task_bank.
-- ==========================================================


-- ==========================================================
-- загрузка task_bank
-- ==========================================================

insert into task_bank (
    bank_task_code,
    pattern_id,
    difficulty,
    source,
    title,
    task_description,
    solution_outline,
    common_mistakes
)
select
    tb.bank_task_code,
    d.pattern_id,
    tb.difficulty,
    tb.source,
    tb.title,
    tb.task_description,
    tb.solution_outline,
    tb.common_mistakes
from task_bank_raw tb
join dictionary d
    on tb.pattern = d.pattern
order by
    tb.bank_task_code;

-- ==========================================================
-- ожидаемый результат
--
-- ✓ task_bank заполнена
-- ✓ всем задачам сопоставлен pattern_id
--
-- следующий шаг:
-- 11_task_bank_checks.sql
-- ==========================================================