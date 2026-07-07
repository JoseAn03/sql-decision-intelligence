-- ==========================================================
-- SQL for Decision Intelligence
-- Nivel 1: Queries Básicas de Negocio
-- ==========================================================
-- Objetivo: Responder preguntas de negocio usando
-- SELECT, WHERE, GROUP BY, JOIN, ORDER BY

-- ─────────────────────────────────────────────────────────
-- 1.1 ¿Cuál es el No-Show rate general?
-- ─────────────────────────────────────────────────────────
SELECT 
    ROUND(SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS no_show_rate,
    COUNT(*) AS total_reservas,
    SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) AS total_no_shows
FROM reservations;

-- ─────────────────────────────────────────────────────────
-- 1.2 Top 5 clientes por revenue
-- ─────────────────────────────────────────────────────────
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    COUNT(*) AS reservas,
    ROUND(SUM(r.total_amount), 2) AS total_gastado,
    ROUND(AVG(r.total_amount), 2) AS ticket_promedio
FROM reservations r
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.status IN ('activa', 'completada')
GROUP BY cliente
ORDER BY total_gastado DESC
LIMIT 5;

-- ─────────────────────────────────────────────────────────
-- 1.3 Revenue mensual por marca
-- ─────────────────────────────────────────────────────────
SELECT 
    b.brand_name,
    STRFTIME('%Y-%m', r.pickup_datetime) AS mes,
    COUNT(*) AS reservas,
    ROUND(SUM(r.total_amount), 2) AS revenue,
    ROUND(AVG(r.total_amount), 2) AS ticket_promedio
FROM reservations r
JOIN brands b ON r.brand_id = b.brand_id
WHERE r.status IN ('activa', 'completada')
GROUP BY b.brand_name, mes
ORDER BY mes, revenue DESC;

-- ─────────────────────────────────────────────────────────
-- 1.4 Canales con peor No-Show rate
-- ─────────────────────────────────────────────────────────
SELECT 
    a.agency_name,
    COUNT(*) AS total,
    SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS ns_rate,
    ROUND(SUM(CASE WHEN r.status = 'no_show' THEN r.total_amount ELSE 0 END), 2) AS perdida_estimada
FROM reservations r
JOIN agencies a ON r.agency_id = a.agency_id
GROUP BY a.agency_name
HAVING COUNT(*) > 20
ORDER BY ns_rate DESC;
