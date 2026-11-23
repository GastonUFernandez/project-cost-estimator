USE project_estimator_db;

-- 1. Categorías de clientes
INSERT INTO client_categories (name, description, default_margin_percentage, discount_percentage, active)
VALUES
    ('Enterprise', 'Grandes cuentas corporativas con requerimientos complejos', 30.00, 5.00, TRUE),
    ('PyME', 'Empresas medianas y startups en crecimiento', 25.00, 0.00, TRUE),
    ('Partner', 'Clientes recurrentes o aliados estratégicos', 20.00, 10.00, TRUE);
    
    