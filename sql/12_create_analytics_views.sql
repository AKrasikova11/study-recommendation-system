-- ==========================================================
-- Study Recommendation System
-- Файл: 12_create_analytics_views.sql
--
-- Назначение:
-- Создание аналитических витрин проекта.
--
-- Витрины:
-- 1. vw_attempt_details
-- 2. vw_learning_progress
-- 3. vw_learning_features
-- ==========================================================



-- ==========================================================
-- Витрина: vw_attempt_details
--
-- Назначение:
-- Объединяет таблицы attempts, tasks и dictionary.
-- Используется как базовая витрина для дальнейшей аналитики.
-- ==========================================================

drop view if exists vw_attempt_details cascade;

create view vw_attempt_details as
select
    a.attempt_id,
    a.attempt_date,
    a.score,
    a.comment,
    t.task_id,
    t.task_code,
    t.title,
    t.difficulty,
    d.pattern_id,
    d.pattern,
    d.domain_name,
    d.group_name,
    d.subgroup_name
from attempts a
join tasks t
    on a.task_id = t.task_id
join dictionary d
    on t.pattern_id = d.pattern_id;



-- ==========================================================
-- Проверка
-- ==========================================================

select *
from vw_attempt_details
limit 20;


-- ==========================================================
-- Витрина: vw_pattern_progress
--
-- Назначение:
-- Показывает агрегированную статистику обучения
-- по каждому паттерну.
--
-- Используется как промежуточная витрина между
-- попытками пользователя и аналитикой по подгруппам.
--
-- На основе данной витрины строятся:
-- • vw_learning_progress
-- • Recommendation Engine
-- ==========================================================

drop view if exists vw_pattern_progress cascade;

create view vw_pattern_progress as
select
    ----------------------------------------------------------
    -- Иерархия знаний
    ----------------------------------------------------------
    domain_name,
    group_name,
    subgroup_name,
    pattern_id,
    pattern,
    ----------------------------------------------------------
    -- Статистика задач и попыток
    ----------------------------------------------------------
    count(distinct task_id) as tasks_count,
    count(*) as attempts_count,
    sum(
        case
            when score >= 0.75 then 1
            else 0
        end
    ) as successful_attempts,
    ----------------------------------------------------------
    -- Основные показатели
    ----------------------------------------------------------
    round(avg(score), 2) as avg_score,
    round(avg(score) * 100, 2) as mastery_level,
    round((1 - avg(score)) * 100, 2) as knowledge_risk,
    max(score) as best_score,
    ----------------------------------------------------------
    -- История обучения
    ----------------------------------------------------------
    min(attempt_date) as first_attempt,
    max(attempt_date) as last_attempt,
    current_date - max(attempt_date) as days_since_last_attempt
from vw_attempt_details
group by
    domain_name,
    group_name,
    subgroup_name,
    pattern_id,
    pattern;


-- ==========================================================
-- Проверка
-- ==========================================================

select *
from vw_pattern_progress
order by
    domain_name,
    group_name,
    subgroup_name,
    mastery_level,
    pattern;


-- ==========================================================
-- Проверка распределения паттернов
-- ==========================================================

select
    subgroup_name,
    pattern,
    mastery_level,
    attempts_count,
    days_since_last_attempt
from vw_pattern_progress
order by
    subgroup_name,
    mastery_level;
    
    
-- ==========================================================
-- Витрина: vw_learning_progress
--
-- Назначение:
-- Показывает агрегированную статистику обучения
-- по каждой подгруппе.
--
-- Витрина агрегирует данные уровня PATTERN
-- до уровня SUBGROUP.
--
-- Используется для:
-- • аналитики прогресса;
-- • построения дашбордов;
-- • подготовки Recommendation Engine.
-- ==========================================================

drop view if exists vw_learning_progress cascade;

create view vw_learning_progress as
select
    domain_name,
    group_name,
    subgroup_name,
    sum(tasks_count) as tasks_count,
    sum(attempts_count) as attempts_count,
    sum(successful_attempts) as successful_attempts,
    round(
        sum(avg_score * attempts_count)
        /
        sum(attempts_count)
    , 2) as avg_score,
    max(best_score) as best_score,
    min(first_attempt) as first_attempt,
    max(last_attempt) as last_attempt,
    current_date - max(last_attempt) as days_since_last_attempt
from vw_pattern_progress
group by
    domain_name,
    group_name,
    subgroup_name;


-- ==========================================================
-- Проверка
-- ==========================================================

select *
from vw_learning_progress
order by
    domain_name,
    group_name,
    subgroup_name;



-- ==========================================================
-- Витрина: vw_learning_features
--
-- Назначение:
-- Подготавливает признаки (features),
-- используемые рекомендательной системой.
--
-- В данной витрине не принимаются решения.
-- Здесь рассчитываются показатели, которые
-- используются для вычисления Recommendation Score.
-- ==========================================================

drop view if exists vw_learning_features cascade;

create view vw_learning_features as
with learning_features as (
    select
        domain_name,
        group_name,
        subgroup_name,
        tasks_count,
        attempts_count,
        successful_attempts,
        avg_score,
        best_score,
        first_attempt,
        last_attempt,
        days_since_last_attempt,
        ------------------------------------------------------
        -- Уровень освоения темы
        ------------------------------------------------------
        round(avg_score * 100, 2) as mastery_level,
        ------------------------------------------------------
        -- Риск недостаточного знания
        ------------------------------------------------------
        round((1 - avg_score) * 100, 2) as knowledge_risk,
        ------------------------------------------------------
        -- Риск забывания
        ------------------------------------------------------
        case
            when days_since_last_attempt <= 3 then 0
            when days_since_last_attempt <= 7 then 20
            when days_since_last_attempt <= 10 then 40
            when days_since_last_attempt <= 14 then 70
            else 100
        end as forgetting_risk,
        ------------------------------------------------------
        -- Достоверность оценки знаний
        ------------------------------------------------------
        case
            when attempts_count between 1 and 3 then 20
            when attempts_count between 4 and 5 then 40
            when attempts_count between 6 and 7 then 60
            when attempts_count between 8 and 9 then 80
            else 100
        end as confidence_score
    from vw_learning_progress
)
select
    domain_name,
    group_name,
    subgroup_name,
    tasks_count,
    attempts_count,
    successful_attempts,
    avg_score,
    best_score,
    first_attempt,
    last_attempt,
    days_since_last_attempt,
    mastery_level,
    knowledge_risk,
    forgetting_risk,
    confidence_score,
    ----------------------------------------------------------
    -- Риск недостаточности данных
    ----------------------------------------------------------
    100 - confidence_score as evidence_risk
from learning_features;



-- ==========================================================
-- Проверка
-- ==========================================================

select *
from vw_learning_features
order by
    domain_name,
    group_name,
    subgroup_name;