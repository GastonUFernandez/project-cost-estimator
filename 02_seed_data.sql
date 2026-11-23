USE project_estimator_db;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE estimate_items;
TRUNCATE TABLE project_estimates;
TRUNCATE TABLE projects;
TRUNCATE TABLE employees;
TRUNCATE TABLE roles;
TRUNCATE TABLE categories;
TRUNCATE TABLE clients;
TRUNCATE TABLE client_categories;

SET FOREIGN_KEY_CHECKS = 1;



USE project_estimator_db;

-- 1. Categorías de clientes
INSERT INTO client_categories (name, description, default_margin_percentage, discount_percentage, active)
VALUES
    ('Enterprise', 'Grandes cuentas corporativas con requerimientos complejos', 30.00, 5.00, TRUE),
    ('PyME', 'Empresas medianas y startups en crecimiento', 25.00, 0.00, TRUE),
    ('Partner', 'Clientes recurrentes o aliados estratégicos', 20.00, 10.00, TRUE);
    
-- 2. Clientes
INSERT INTO clients (client_category_id, business_name, tax_id, contact_email, active)
VALUES
    (
        (SELECT id FROM client_categories WHERE name = 'Enterprise'),
        'Logística del Sur S.A.',
        '30-71234567-9',
        'compras@logisticadelsur.com.ar',
        TRUE
    ),
    (
        (SELECT id FROM client_categories WHERE name = 'PyME'),
        'Tienda Norte Hogar SRL',
        '30-70987654-3',
        'sistemas@tiendanorte.com.ar',
        TRUE
    );
    
-- 3. Categorías de trabajo
INSERT INTO categories (name, description, active)
VALUES
    ('Backend', 'Desarrollo de APIs, servicios de negocio y bases de datos', TRUE),
    ('QA', 'Pruebas funcionales, automatización y aseguramiento de calidad', TRUE),
    ('PM', 'Coordinación, planificación y seguimiento de entregas', TRUE);

-- 4. Puestos / Roles (costo interno vs tarifa por hora al cliente)
INSERT INTO roles (category_id, name, hourly_cost, hourly_rate, active)
VALUES
    ((SELECT id FROM categories WHERE name = 'Backend'), 'Backend Developer Jr', 18.00, 35.00, TRUE),
    ((SELECT id FROM categories WHERE name = 'Backend'), 'Backend Developer Ssr', 28.00, 52.00, TRUE),
    ((SELECT id FROM categories WHERE name = 'QA'), 'QA Engineer Manual & Automation', 16.00, 32.00, TRUE),
    ((SELECT id FROM categories WHERE name = 'PM'), 'Project Manager', 25.00, 48.00, TRUE);

-- 5. Empleados
INSERT INTO employees (role_id, full_name, email, active, hired_at)
VALUES
    ((SELECT id FROM roles WHERE name = 'Backend Developer Ssr'), 'Martín Pereyra', 'mpereyra@consultora.dev', TRUE, '2024-03-15'),
    ((SELECT id FROM roles WHERE name = 'Backend Developer Jr'), 'Lucía Giménez', 'lgimenez@consultora.dev', TRUE, '2025-08-01'),
    ((SELECT id FROM roles WHERE name = 'QA Engineer Manual & Automation'), 'Gastón Fernández', 'gfernandez@consultora.dev', TRUE, '2026-01-10'),
    ((SELECT id FROM roles WHERE name = 'Project Manager'), 'Diego Alarcón', 'dalarcon@consultora.dev', TRUE, '2023-11-05');

-- 6. Proyectos (Pedidos de clientes)
INSERT INTO projects (client_id, title, description, status)
VALUES
    (
        (SELECT id FROM clients WHERE business_name = 'Logística del Sur S.A.'),
        'Sistema de Tracking y Gestión de Flota',
        'API REST y panel web para monitoreo de envíos y control de choferes.',
        'APPROVED'
    ),
    (
        (SELECT id FROM clients WHERE business_name = 'Tienda Norte Hogar SRL'),
        'Módulo de Catálogo y Carrito B2B',
        'Integración de stock en tiempo real y cotizador mayorista.',
        'QUOTED'
    );

-- 7. Cotizaciones / Presupuestos
-- Proyecto 1: Logística del Sur S.A. (Enterprise: 30% margen, 5% descuento)
-- Proyecto 2: Tienda Norte Hogar SRL (PyME: 25% margen, 0% descuento)
INSERT INTO project_estimates (
    project_id, version, margin_percentage, applied_discount_percentage,
    total_hours, total_cost, final_price, status, issued_at
)
VALUES
    (
        (SELECT id FROM projects WHERE title = 'Sistema de Tracking y Gestión de Flota'),
        1, 30.00, 5.00, 120.00, 2660.00, 6224.40, 'APPROVED', '2026-11-15 10:00:00'
    ),
    (
        (SELECT id FROM projects WHERE title = 'Módulo de Catálogo y Carrito B2B'),
        1, 25.00, 0.00, 80.00, 1660.00, 4050.00, 'SENT', '2026-11-20 16:30:00'
    );

-- 8. Ítems de cada cotización (con costos y tarifas congeladas)
-- Ítems para Proyecto 1 (Sistema de Tracking y Gestión de Flota - v1)
INSERT INTO estimate_items (estimate_id, role_id, task_description, estimated_hours, applied_hourly_cost, applied_hourly_rate)
VALUES
    (
        (SELECT pe.id FROM project_estimates pe JOIN projects p ON pe.project_id = p.id WHERE p.title = 'Sistema de Tracking y Gestión de Flota' AND pe.version = 1),
        (SELECT id FROM roles WHERE name = 'Project Manager'),
        'Relevamiento funcional y planificación de sprints',
        20.00, 25.00, 48.00
    ),
    (
        (SELECT pe.id FROM project_estimates pe JOIN projects p ON pe.project_id = p.id WHERE p.title = 'Sistema de Tracking y Gestión de Flota' AND pe.version = 1),
        (SELECT id FROM roles WHERE name = 'Backend Developer Ssr'),
        'Desarrollo de API REST y geolocalización en Spring Boot',
        60.00, 28.00, 52.00
    ),
    (
        (SELECT pe.id FROM project_estimates pe JOIN projects p ON pe.project_id = p.id WHERE p.title = 'Sistema de Tracking y Gestión de Flota' AND pe.version = 1),
        (SELECT id FROM roles WHERE name = 'QA Engineer Manual & Automation'),
        'Pruebas funcionales, API testing y regresión automatizada',
        40.00, 16.00, 32.00
    );

-- Ítems para Proyecto 2 (Módulo de Catálogo y Carrito B2B - v1)
INSERT INTO estimate_items (estimate_id, role_id, task_description, estimated_hours, applied_hourly_cost, applied_hourly_rate)
VALUES
    (
        (SELECT pe.id FROM project_estimates pe JOIN projects p ON pe.project_id = p.id WHERE p.title = 'Módulo de Catálogo y Carrito B2B' AND pe.version = 1),
        (SELECT id FROM roles WHERE name = 'Backend Developer Jr'),
        'Endpoints de catálogo, filtros y carrito',
        50.00, 18.00, 35.00
    ),
    (
        (SELECT pe.id FROM project_estimates pe JOIN projects p ON pe.project_id = p.id WHERE p.title = 'Módulo de Catálogo y Carrito B2B' AND pe.version = 1),
        (SELECT id FROM roles WHERE name = 'QA Engineer Manual & Automation'),
        'Casos de prueba funcionales y validación de reglas de negocio',
        30.00, 16.00, 32.00
    ); 
    