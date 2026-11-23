CREATE DATABASE IF NOT EXISTS project_estimator_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE project_estimator_db;

-- 1. Categorías de Clientes (Ej: PyME, Enterprise, Partner, ONG)
CREATE TABLE client_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255),
    default_margin_percentage DECIMAL(5, 2) NOT NULL DEFAULT 20.00,
    discount_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_client_cat_percentages
        CHECK (default_margin_percentage >= 0 AND discount_percentage >= 0 AND discount_percentage <= 100)
);

-- 2. Clientes
CREATE TABLE clients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_category_id BIGINT NOT NULL,
    business_name VARCHAR(150) NOT NULL,
    tax_id VARCHAR(20) NOT NULL UNIQUE,
    contact_email VARCHAR(120) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_clients_category
        FOREIGN KEY (client_category_id) REFERENCES client_categories(id)
        ON DELETE RESTRICT
);

-- 3. Categorías de trabajo (Ej: Backend, QA, UX/UI, Gestión)
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255),
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. Puestos / Roles por categoría con costo interno y tarifa al cliente
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    hourly_cost DECIMAL(10, 2) NOT NULL,
    hourly_rate DECIMAL(10, 2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_roles_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_role_name_per_category
        UNIQUE (category_id, name),
    CONSTRAINT chk_roles_positive_amounts
        CHECK (hourly_cost >= 0 AND hourly_rate >= hourly_cost)
);

-- 5. Empleados
CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_id BIGINT NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    hired_at DATE NOT NULL,
    CONSTRAINT fk_employees_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
        ON DELETE RESTRICT
);

-- 6. Proyectos (Pedidos de clientes)
CREATE TABLE projects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    status ENUM(
        'DRAFT',
        'IN_EVALUATION',
        'QUOTED',
        'APPROVED',
        'REJECTED',
        'IN_PROGRESS',
        'COMPLETED',
        'CANCELLED'
    ) NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_projects_client
        FOREIGN KEY (client_id) REFERENCES clients(id)
        ON DELETE RESTRICT
);

-- 7. Cotizaciones / Presupuestos versionados
CREATE TABLE project_estimates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    project_id BIGINT NOT NULL,
    version INT NOT NULL DEFAULT 1,
    margin_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    applied_discount_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    total_hours DECIMAL(8, 2) NOT NULL DEFAULT 0.00,
    total_cost DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    final_price DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status ENUM('DRAFT', 'SENT', 'APPROVED', 'REJECTED', 'SUPERSEDED') NOT NULL DEFAULT 'DRAFT',
    issued_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_estimates_project
        FOREIGN KEY (project_id) REFERENCES projects(id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_project_estimate_version
        UNIQUE (project_id, version),
    CONSTRAINT chk_estimate_non_negative
        CHECK (
            margin_percentage >= 0
            AND applied_discount_percentage >= 0
            AND applied_discount_percentage <= 100
            AND total_hours >= 0
            AND total_cost >= 0
            AND final_price >= 0
        )
);

-- 8. Ítems de cada cotización (desglose por puesto y horas)
CREATE TABLE estimate_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    estimate_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    task_description VARCHAR(255) NOT NULL,
    estimated_hours DECIMAL(7, 2) NOT NULL,
    applied_hourly_cost DECIMAL(10, 2) NOT NULL,
    applied_hourly_rate DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_items_estimate
        FOREIGN KEY (estimate_id) REFERENCES project_estimates(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_items_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_item_hours_positive
        CHECK (estimated_hours > 0 AND applied_hourly_cost >= 0 AND applied_hourly_rate >= 0)
);