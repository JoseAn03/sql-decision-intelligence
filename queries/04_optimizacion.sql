-- ==========================================================
-- SQL for Decision Intelligence
-- Nivel 4: Optimización y Performance
-- ==========================================================

-- ─────────────────────────────────────────────────────────
-- 4.1 EXPLAIN: Comparación de approaches
-- ─────────────────────────────────────────────────────────
-- Enfoque lento: subquery correlacionada
EXPLAIN ANALYZE
SELECT r.*, 
    (SELECT brand_name FROM brands b WHERE b.brand_id = r.brand_id) AS marca
FROM reservations r
LIMIT 100;

-- Enfoque óptimo: JOIN
EXPLAIN ANALYZE
SELECT r.*, b.brand_name
FROM reservations r
JOIN brands b ON r.brand_id = b.brand_id
LIMIT 100;

-- ─────────────────────────────────────────────────────────
-- 4.2 Análisis de índices: sin índice vs con índice
-- ─────────────────────────────────────────────────────────
-- Sin índice (creamos tabla temporal sin índice)
CREATE TEMP TABLE reservas_no_index AS SELECT * FROM reservations;

EXPLAIN ANALYZE
SELECT * FROM reservas_no_index WHERE brand_id = 1;

EXPLAIN ANALYZE
SELECT * FROM reservations WHERE brand_id = 1;  -- con índice idx_res_brand

-- ─────────────────────────────────────────────────────────
-- 4.3 Query optimizada: Reporte ejecutivo en 1 sola query
-- ─────────────────────────────────────────────────────────
SELECT 
    'Resumen Ejecutivo' AS reporte,
    DATE('now') AS generado_en,
    (SELECT COUNT(*) FROM reservations) AS total_reservas,
    (SELECT ROUND(AVG(total_amount), 2) FROM reservations WHERE status IN ('activa','completada')) AS ticket_promedio,
    (SELECT ROUND(SUM(total_amount), 2) FROM reservations WHERE status IN ('activa','completada')) AS revenue_total,
    (SELECT ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT DATE(pickup_datetime)), 0) FROM reservations) AS avg_reservas_diarias,
    (SELECT ROUND(SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) FROM reservations) AS no_show_rate,
    (SELECT brand_name FROM (
        SELECT b.brand_name, SUM(r.total_amount) as rev
        FROM reservations r JOIN brands b ON r.brand_id = b.brand_id
        WHERE r.status IN ('activa','completada')
        GROUP BY b.brand_name ORDER BY rev DESC LIMIT 1
    )) AS marca_top_revenue,
    (SELECT agency_name FROM (
        SELECT a.agency_name, SUM(r.total_amount) as rev
        FROM reservations r JOIN agencies a ON r.agency_id = a.agency_id
        WHERE r.status IN ('activa','completada')
        GROUP BY a.agency_name ORDER BY rev DESC LIMIT 1
    )) AS canal_top_revenue;
