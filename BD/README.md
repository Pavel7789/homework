# Домашнее задание "Базы данных". Ярмощук Павел


#проверка статуса - sudo systemctl status postgresql
#старт - sudo systemctl start postgresql
#
#
#выход - /q или Ctrl+D
старт dbeaver - dbeaver

Задание 1
Опишите не менее семи таблиц, из которых состоит база данных. Определите:

какие данные хранятся в этих таблицах,
какой тип данных у столбцов в этих таблицах, если данные хранятся в PostgreSQL.
Начертите схему полученной модели данных. Можете использовать онлайн-редактор: https://app.diagrams.net/

Этапы реализации:

Внимательно изучите предоставленный вам файл с данными и подумайте, как можно сгруппировать данные по смыслу.
Разбейте исходный файл на несколько таблиц и определите список столбцов в каждой из них.
Для каждого столбца подберите подходящий тип данных из PostgreSQL.
Для каждой таблицы определите первичный ключ (PRIMARY KEY).
Определите типы связей между таблицами.
Начертите схему модели данных. На схеме должны быть чётко отображены:
все таблицы с их названиями,
все столбцы с указанием типов данных,
первичные ключи (они должны быть явно выделены),
линии, показывающие связи между таблицами.
Результатом выполнения задания должен стать скриншот получившейся схемы базы данных.

Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению. Вы можете их выполнить, если хотите глубже и шире разобраться в материале.

Задание 2*
Разверните СУБД Postgres на своей хостовой машине, на виртуальной машине или в контейнере docker.
Опишите схему, полученную в предыдущем задании, с помощью скрипта SQL.
Создайте в вашей полученной СУБД новую базу данных и выполните полученный ранее скрипт для создания вашей модели данных.
В качестве решения приложите SQL скрипт и скриншот диаграммы.

Для написания и редактирования sql удобно использовать специальный инструмент dbeaver.


Решение 2

CREATE TABLE department_types (
    department_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    branch_address TEXT NOT NULL UNIQUE
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(200) NOT NULL UNIQUE,
    department_type_id INTEGER NOT NULL,
    CONSTRAINT fk_departments_type
        FOREIGN KEY (department_type_id)
        REFERENCES department_types(department_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE employees (
    employee_id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    salary NUMERIC(12, 2) NOT NULL CHECK (salary >= 0),
    position_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    hire_date DATE NOT NULL,
    branch_id INTEGER NOT NULL,
    CONSTRAINT fk_employees_position
        FOREIGN KEY (position_id)
        REFERENCES positions(position_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_employees_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(250) NOT NULL UNIQUE
);

CREATE TABLE employee_projects (
    employee_id BIGINT NOT NULL,
    project_id INTEGER NOT NULL,
    assigned_at TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY (employee_id, project_id),
    CONSTRAINT fk_employee_projects_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_employee_projects_project
        FOREIGN KEY (project_id)
        REFERENCES projects(project_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

