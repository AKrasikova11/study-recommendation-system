-- ==========================================================
-- файл: 02_create_tables.sql
--
-- назначение:
-- создание основных таблиц проекта
-- и ограничений целостности.
--
-- создаются таблицы:
-- • dictionary
-- • tasks
-- • attempts
-- ==========================================================


-- ==========================================================
-- dictionary
-- ==========================================================

create table dictionary (
    pattern_id serial primary key,
    pattern text unique not null,
    domain_name text not null,
    group_name text not null,
    subgroup_name text not null,
    how_to_identify text,
    when_to_use text
);

-- ==========================================================
-- tasks
-- ==========================================================

create table tasks (
    task_id serial primary key,
    task_code text unique not null,
    pattern_id int not null,
    difficulty smallint not null,
    title text not null,
    prompt text not null,
    constraint fk_tasks_pattern
        foreign key (pattern_id)
        references dictionary(pattern_id),
    constraint chk_tasks_difficulty
        check (difficulty in (1, 2, 3))
);

-- ==========================================================
-- attempts
-- ==========================================================

create table attempts (
    attempt_id serial primary key,
    task_id int not null,
    attempt_date date not null,
    score numeric(4,2),
    comment text,
    constraint fk_attempts_task
        foreign key (task_id)
        references tasks(task_id),
    constraint chk_attempts_score
        check (score between 0 and 1)
);


-- ==========================================================
-- ожидаемый результат
--
-- ✓ созданы основные таблицы проекта
-- ✓ созданы первичные ключи
-- ✓ созданы внешние ключи
-- ✓ добавлены ограничения check
--
-- следующий шаг:
-- 03_create_raw_tables.sql
-- ==========================================================