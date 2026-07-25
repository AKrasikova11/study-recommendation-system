-- ==========================================================
-- файл: 08_task_bank_validation.sql
--
-- назначение:
-- проверка качества и полноты
-- банка задач.
--
-- используется после загрузки данных
-- в task_bank_raw.
-- ==========================================================


-- ==========================================================
-- проверка количества строк
-- ==========================================================

select
    count(*) as task_bank_rows
from task_bank_raw;


-- ==========================================================
-- task_bank_raw
-- ==========================================================

select
    bank_task_code
from task_bank_raw
group by bank_task_code
having count(*) > 1;

select *
from task_bank_raw
where bank_task_code is null
   or pattern is null
   or difficulty is null
   or title is null
   or task_description is null;

select *
from task_bank_raw
where difficulty not in (1, 2, 3)
   or difficulty is null;

select
    tb.pattern,
    tb.domain,
    tb."group",
    tb.subgroup
from task_bank_raw tb
left join dictionary d
    on d.pattern = tb.pattern
where d.pattern is null
order by
    tb.pattern,
    tb.domain,
    tb."group",
    tb.subgroup;


-- ==========================================================
-- покрытие словаря
-- ==========================================================

select
    d.pattern,
    d.domain_name,
    d.group_name,
    d.subgroup_name
from dictionary d
left join task_bank_raw tb
    on d.pattern = tb.pattern
where tb.pattern is null
order by
    d.pattern,
    d.domain_name,
    d.group_name,
    d.subgroup_name;

select
    pattern,
    count(*) as task_count
from task_bank_raw
group by pattern
order by
    task_count desc,
    pattern;

select
    d.domain_name,
    d.group_name,
    d.subgroup_name,
    d.pattern,
    count(tb.bank_task_code) as task_count
from dictionary d
left join task_bank_raw tb
    on d.pattern = tb.pattern
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
-- качество банка задач
-- ==========================================================

select
    bank_task_code,
    title
from task_bank_raw
where solution_outline is null
   or trim(solution_outline) = '';

select
    bank_task_code,
    title
from task_bank_raw
where common_mistakes is null
   or trim(common_mistakes) = '';


-- ==========================================================
-- ожидаемый результат
--
-- ✓ отсутствуют дубли bank_task_code
-- ✓ отсутствуют неизвестные pattern
-- ✓ все обязательные поля заполнены
-- ✓ difficulty принимает значения только 1–3
-- ✓ определены паттерны без задач
-- ✓ определено покрытие словаря
--
-- следующий шаг:
-- 09_create_task_bank.sql
-- ==========================================================