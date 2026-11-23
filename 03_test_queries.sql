USE project_estimator_db;

-- ============================================================================
-- 1. CONTEO DE REGISTROS POR TABLA (Verificación post-seed)
-- ============================================================================
SELECT 'client_categories' AS tabla, COUNT(*) AS total FROM client_categories
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'roles', COUNT(*) FROM roles
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'projects', COUNT(*) FROM projects
UNION ALL SELECT 'project_estimates', COUNT(*) FROM project_estimates
UNION ALL SELECT 'estimate_items', COUNT(*) FROM estimate_items;

-- ============================================================================
-- 2. AUDITORÍA DE CÁLCULOS POR COTIZACIÓN (Ítems vs. Cabecera)
-- ============================================================================
SELECT
    p.title AS proyecto,
    c.business_name AS cliente,
    cc.name AS categoria_cliente,
    pe.version,
    pe.status AS estado_cotizacion,
    SUM(ei.estimated_hours) AS horas_items,
    pe.total_hours AS horas_cabecera,
    SUM(ei.estimated_hours * ei.applied_hourly_cost) AS costo_calculado,
    pe.total_cost AS costo_cabecera,
    ROUND(
        SUM(ei.estimated_hours * ei.applied_hourly_rate)
        * (1 + pe.margin_percentage / 100)
        * (1 - pe.applied_discount_percentage / 100),
        2
    ) AS precio_calculado,
    pe.final_price AS precio_cabecera
FROM project_estimates pe
JOIN projects p ON pe.project_id = p.id
JOIN clients c ON p.client_id = c.id
JOIN client_categories cc ON c.client_category_id = cc.id
JOIN estimate_items ei ON ei.estimate_id = pe.id
GROUP BY
    pe.id, p.title, c.business_name, cc.name,
    pe.version, pe.status, pe.total_hours, pe.total_cost,
    pe.margin_percentage, pe.applied_discount_percentage, pe.final_price;

-- ============================================================================
-- 3. PRUEBA DE CONGELAMIENTO HISTÓRICO DE TARIFAS
-- ============================================================================
-- Consultamos el id de 'Backend Developer Ssr'
SELECT id, name, hourly_cost, hourly_rate
FROM roles
WHERE name = 'Backend Developer Ssr';

-- Simulamos un cambio de tarifa en el catálogo (ajustá el id si en tu tabla es distinto de 2)
UPDATE roles
SET hourly_rate = 70.00
WHERE id = 2;

-- Verificamos que la cotización ya emitida conserve su tarifa congelada ($52.00)
SELECT
    p.title AS proyecto,
    pe.version,
    ei.task_description,
    ei.applied_hourly_rate AS tarifa_congelada,
    r.hourly_rate AS tarifa_actual_catalogo
FROM estimate_items ei
JOIN project_estimates pe ON ei.estimate_id = pe.id
JOIN projects p ON pe.project_id = p.id
JOIN roles r ON ei.role_id = r.id
WHERE r.id = 2;

-- Restauramos la tarifa original del catálogo
UPDATE roles
SET hourly_rate = 52.00
WHERE id = 2;

-- ============================================================================
-- 4. PRUEBAS NEGATIVAS DE INTEGRIDAD (Deben fallar por CHECK / UNIQUE)
-- ============================================================================
-- Caso 4A: Tarifa al cliente menor al costo interno -> debe fallar por chk_roles_positive_amounts
-- INSERT INTO roles (category_id, name, hourly_cost, hourly_rate, active)
-- VALUES ((SELECT id FROM categories WHERE name = 'QA'), 'Rol Costo Mayor', 30.00, 20.00, TRUE);

-- Caso 4B: Versión duplicada para el mismo proyecto -> debe fallar por uq_project_estimate_version
-- INSERT INTO project_estimates (
--     project_id, version, margin_percentage, applied_discount_percentage,
--     total_hours, total_cost, final_price, status
-- )
-- VALUES (
--     (SELECT id FROM projects WHERE title = 'Módulo de Catálogo y Carrito B2B'),
--     1, 25.00, 0.00, 10.00, 200.00, 250.00, 'DRAFT'
-- );