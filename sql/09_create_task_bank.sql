-- ==========================================================
-- файл: 09_create_task_bank.sql
--
-- назначение:
-- создание основной таблицы
-- банка задач.
-- ==========================================================


-- ==========================================================
-- task_bank
-- ==========================================================

create table task_bank (
    bank_task_id serial primary key,
    bank_task_code text unique not null,
    pattern_id int not null,
    difficulty smallint not null,
    source text,
    title text not null,
    task_description text not null,
    solution_outline text,
    common_mistakes text,
    constraint fk_task_bank_pattern
        foreign key (pattern_id)
        references dictionary(pattern_id),
    constraint chk_task_bank_difficulty
        check (difficulty in (1, 2, 3))
);


-- ==========================================================
-- ожидаемый результат
--
-- ✓ создана таблица task_bank
-- ✓ создан первичный ключ
-- ✓ создан внешний ключ
-- ✓ добавлено ограничение check
--
-- следующий шаг:
-- 10_load_task_bank.sql
-- ==========================================================