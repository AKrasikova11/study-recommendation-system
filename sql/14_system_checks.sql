-- ==========================================================
-- Study Recommendation System
--
-- Файл: 14_system_checks.sql
--
-- Назначение:
-- Проверка корректности работы аналитических витрин
-- и рекомендательной системы после загрузки данных.
--
-- Рекомендуется запускать после:
--
-- • загрузки новых задач;
-- • загрузки новых попыток;
-- • изменения структуры базы;
-- • изменения логики витрин.
-- ==========================================================



-- ==========================================================
-- 1. Проверка количества записей
-- ==========================================================

select 'dictionary' as table_name, count(*) as rows_count
from dictionary
union all
select 'tasks', count(*)
from tasks
union all
select 'attempts', count(*)
from attempts
union all
select 'task_bank', count(*)
from task_bank;



-- ==========================================================
-- 2. Проверка базовой аналитической витрины
-- ==========================================================

select *
from vw_attempt_details
limit 20;



-- ==========================================================
-- 3. Проверка аналитики по паттернам
-- ==========================================================

select
    pattern,
    mastery_level,
    attempts_count,
    days_since_last_attempt
from vw_pattern_progress
order by
    mastery_level,
    pattern;



-- ==========================================================
-- 4. Проверка аналитики по подгруппам
-- ==========================================================

select
    subgroup_name,
    mastery_level,
    knowledge_risk,
    forgetting_risk,
    evidence_risk
from vw_learning_features
order by
    mastery_level;



-- ==========================================================
-- 5. Проверка рекомендаций
-- ==========================================================

select
    subgroup_name,
    priority_score,
    recommendation_level,
    recommendation_reason,
    target_difficulty
from vw_recommendation
order by
    priority_score desc;



-- ==========================================================
-- 6. Проверка рекомендованных задач
-- ==========================================================

select *
from vw_recommended_tasks
order by
    priority_score desc,
    subgroup_name,
    mastery_level;



-- ==========================================================
-- 7. Проверка отсутствия дублей
-- ==========================================================

select
    pattern_id,
    count(*) as recommendations_count
from vw_recommended_tasks
group by
    pattern_id
having
    count(*) > 1;



-- ==========================================================
-- 8. Проверка отсутствия рекомендаций без задач
-- ==========================================================

select *
from vw_recommended_tasks
where
    bank_task_code is null;



-- ==========================================================
-- 9. Проверка выбора сложности
-- ==========================================================

select
    subgroup_name,
    pattern,
    target_difficulty,
    difficulty,
    title
from vw_recommended_tasks
order by
    subgroup_name,
    mastery_level;



-- ==========================================================
-- 10. Проверка распределения рекомендаций
-- ==========================================================

select
    subgroup_name,
    count(*) as recommended_tasks
from vw_recommended_tasks
group by
    subgroup_name
order by
    recommended_tasks desc;


-- ==========================================================
-- 11. Проверка наполненности Task Bank
-- ==========================================================

select
    difficulty,
    count(*) as tasks_count
from task_bank
group by
    difficulty
order by
    difficulty;



-- ==========================================================
-- 12. Проверка покрытия паттернов
-- ==========================================================

select
    d.pattern,
    tb.pattern_id
from dictionary d
left join task_bank tb
    on d.pattern_id = tb.pattern_id
where
    tb.pattern_id is null
order by
    d.pattern;



-- ==========================================================
-- 13. Проверка распределения по предметным областям
-- ==========================================================

select
    domain_name,
    count(*) as recommendations
from vw_recommended_tasks
group by
    domain_name
order by
    recommendations desc;



-- ==========================================================
-- Конец проверки
-- ==========================================================