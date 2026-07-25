-- ==========================================================
-- Витрина: vw_recommendation
--
-- Назначение:
-- Формирует рекомендации по повторению на уровне
-- подгрупп.
--
-- Recommendation Score v1.0
--
-- Формула:
--   • Knowledge Risk  : 50%
--   • Forgetting Risk : 30%
--   • Evidence Risk   : 20%
--
-- Используется как источник данных для:
-- • vw_recommended_tasks
-- • Dashboard
-- ==========================================================

drop view if exists vw_recommendation cascade;

create view vw_recommendation as
with recommendation as (
    select
        domain_name,
        group_name,
        subgroup_name,
        mastery_level,
        knowledge_risk,
        forgetting_risk,
        evidence_risk,
        ------------------------------------------------------
        -- Итоговый приоритет повторения
        ------------------------------------------------------
        round(
              knowledge_risk * 0.50
            + forgetting_risk * 0.30
            + evidence_risk * 0.20
        ,2) as priority_score
    from vw_learning_features
)
select
    ----------------------------------------------------------
    -- Иерархия знаний
    ----------------------------------------------------------
    domain_name,
    group_name,
    subgroup_name,
    ----------------------------------------------------------
    -- Метрики обучения
    ----------------------------------------------------------
    mastery_level,
    knowledge_risk,
    forgetting_risk,
    evidence_risk,
    ----------------------------------------------------------
    -- Приоритет повторения
    ----------------------------------------------------------
    priority_score,
   	case
    ----------------------------------------------------------
    -- Низкий уровень освоения имеет абсолютный приоритет
    ----------------------------------------------------------
    	when mastery_level < 50 then 1
    ----------------------------------------------------------
    -- Остальные темы ранжируются по Priority Score
    ----------------------------------------------------------
    	when priority_score >= 55 then 1
    	when priority_score >= 35 then 2
    	when priority_score >= 20 then 3
    	else 4
	end as recommendation_priority,
    case
    ----------------------------------------------------------
    -- Низкий уровень освоения имеет абсолютный приоритет
    ----------------------------------------------------------
    	when mastery_level < 50 then '🔴 Срочно повторить'
    ----------------------------------------------------------
    -- Остальные темы ранжируются по Priority Score
    ----------------------------------------------------------
    	when priority_score >= 55 then '🔴 Срочно повторить'
    	when priority_score >= 35 then '🟠 Желательно повторить'
    	when priority_score >= 20 then '🟡 Можно повторить'
    	else '🟢 Повторение пока не требуется'
	end as recommendation_level,
    ----------------------------------------------------------
    -- Основная причина рекомендации
    ----------------------------------------------------------
    case
        when knowledge_risk >= forgetting_risk
	        and knowledge_risk >= evidence_risk
            then '📉 Недостаточное освоение'
        when forgetting_risk >= evidence_risk
            then '⏰ Давно не повторялась'
        else
            '❓ Недостаточно данных'
    end as recommendation_reason,
    ----------------------------------------------------------
    -- Рекомендуемая сложность следующей задачи
	----------------------------------------------------------
    case
        when mastery_level < 50 then 1
        when mastery_level < 75 then 2
        else 3
    end as target_difficulty
from recommendation
order by
    recommendation_priority,
    priority_score desc,
    domain_name,
    group_name,
    subgroup_name;



-- ==========================================================
-- Проверка
-- ==========================================================

select *
from vw_recommendation
order by
    priority_score desc,
    subgroup_name;


-- ==========================================================
-- Витрина: vw_recommended_tasks
--
-- Назначение:
-- Подбирает задачи из Task Bank для повторения
-- на основе рекомендаций системы.
--
-- Логика работы:
--
-- 1. Выбирает подгруппы, требующие повторения.
-- 2. Находит слабые паттерны внутри подгруппы.
-- 3. Подбирает задачи наиболее подходящей сложности.
-- 4. Если найдено несколько задач одинаковой сложности,
--    выбирает одну случайным образом.
--
-- Примечание:
-- В текущей версии используется Task Bank (Beta).
-- История решения задач Task Bank пока не учитывается.
-- ==========================================================

drop view if exists vw_recommended_tasks cascade;

create view vw_recommended_tasks as
----------------------------------------------------------
-- Параметры алгоритма
----------------------------------------------------------
with params as (
    select
        10::numeric as mastery_threshold
),
----------------------------------------------------------
-- Минимальный уровень освоения в каждой подгруппе
----------------------------------------------------------
min_mastery as (
    select
        domain_name,
        group_name,
        subgroup_name,
        min(mastery_level) as min_mastery
    from vw_pattern_progress
    group by
        domain_name,
        group_name,
        subgroup_name
),
----------------------------------------------------------
-- Слабые паттерны
----------------------------------------------------------
weak_patterns as (
    select
        r.domain_name,
        r.group_name,
        r.subgroup_name,
        r.priority_score,
        r.recommendation_priority,
        r.recommendation_level,
        r.recommendation_reason,
        r.target_difficulty,
        p.pattern_id,
        p.pattern,
        p.mastery_level,
        p.avg_score,
        p.days_since_last_attempt
    from vw_recommendation r
    join vw_pattern_progress p
        on r.domain_name = p.domain_name
       and r.group_name = p.group_name
       and r.subgroup_name = p.subgroup_name
    join min_mastery m
        on p.domain_name = m.domain_name
       and p.group_name = m.group_name
       and p.subgroup_name = m.subgroup_name
    cross join params
    where
        (
            --------------------------------------------------
            -- Плохо освоенный паттерн
            --------------------------------------------------
            p.mastery_level < 50
            --------------------------------------------------
            -- Или один из самых слабых паттернов подгруппы
            --------------------------------------------------
            or p.mastery_level <=
               m.min_mastery + params.mastery_threshold
        )
),
----------------------------------------------------------
-- Подбор задач
----------------------------------------------------------
recommended_tasks as (
    select
        wp.*,
        tb.bank_task_code,
        tb.title,
        tb.task_description,
        tb.difficulty,
        tb.source,
        row_number() over (
            partition by
                wp.pattern_id
            order by
                --------------------------------------------------
                -- Ближайшая сложность
                --------------------------------------------------
                abs(
                    tb.difficulty -
                    wp.target_difficulty
                ),
                --------------------------------------------------
                -- Если подходит несколько задач —
                -- выбираем случайную
                --------------------------------------------------
                random()
        ) as task_rank
    from weak_patterns wp
    left join task_bank tb
        on tb.pattern_id = wp.pattern_id
)
----------------------------------------------------------
-- Финальный результат
----------------------------------------------------------
select
    ----------------------------------------------------------
    -- Иерархия знаний
    ----------------------------------------------------------
    domain_name,
    group_name,
    subgroup_name,
    ----------------------------------------------------------
    -- Рекомендация
    ----------------------------------------------------------
    priority_score,
    recommendation_priority,
    recommendation_level,
    recommendation_reason,
    target_difficulty,
    ----------------------------------------------------------
    -- Паттерн
    ----------------------------------------------------------
    pattern_id,
    pattern,
    mastery_level,
    ----------------------------------------------------------
    -- Задача
    ----------------------------------------------------------
    bank_task_code,
    title,
    task_description,
    difficulty,
    source,
    ----------------------------------------------------------
    -- Комментарий
    ----------------------------------------------------------
    case
        when bank_task_code is null then
            'Task Bank (Beta): задачи по данному паттерну пока отсутствуют.'
        when difficulty = target_difficulty then
            'Оптимальная сложность.'
        else
            'Выбрана ближайшая доступная сложность.'
    end as recommendation_comment
from recommended_tasks
where
    task_rank = 1
order by
    priority_score desc,
    subgroup_name,
    mastery_level,
    pattern;



-- ==========================================================
-- Проверка
-- ==========================================================
select *
from vw_recommended_tasks
order by
    priority_score desc,
    subgroup_name,
    mastery_level;