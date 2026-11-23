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
    
    