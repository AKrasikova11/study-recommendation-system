-- ==========================================================
-- файл: 03_create_raw_tables.sql
--
-- назначение:
-- создание staging-таблиц
-- для импорта данных из Excel/CSV.
--
-- данные в raw-таблицах используются
-- только перед загрузкой в основные таблицы.
-- ==========================================================


-- ==========================================================
-- dictionary_raw
-- ==========================================================

create table dictionary_raw (
    pattern text,
    domain text,
    "group" text,
    subgroup text,
    how_to_identify text,
    when_to_use text
);

-- ==========================================================
-- tasks_raw
-- ==========================================================

create table tasks_raw (
    task_code text,
    domain text,
    pattern text,
    pattern_group text,
    pattern_subgroup text,
    difficulty int,
    title text,
    prompt text
);

-- ==========================================================
-- attempts_raw
-- ==========================================================

create table attempts_raw (
    date text,
    task_code text,
    domain text,
    pattern_group text,
    score text,
    comment text,
    pattern text,
    subgroup text
);


-- ==========================================================
-- ожидаемый результат
--
-- ✓ созданы dictionary_raw
-- ✓ созданы tasks_raw
-- ✓ созданы attempts_raw
--
-- следующий шаг:
-- импортировать данные из Excel
-- ==========================================================