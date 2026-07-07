-- ==========================================================
-- SQL for Decision Intelligence
-- Nivel 2: Subqueries y CTEs (Common Table Expressions)
-- ==========================================================

-- ─────────────────────────────────────────────────────────
-- 2.1 Marcas con No-Show superior al promedio general
-- ─────────────────────────────────────────────────────────
WITH promedio_general AS (
    SELECT ROUND(SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS avg_ns
    FROM reservations
)
SELECT 
    b.brand_name,
    COUNT(*) AS reservas,
    ROUND(SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS ns_rate,
    (SELECT avg_ns FROM promedio_general) AS promedio_empresa,
    ROUND(
        SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) 
        - (SELECT avg_ns FROM promedio_general), 
        1
    ) AS diferencia
FROM reservations r
JOIN brands b ON r.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING ns_rate > (SELECT avg_ns FROM promedio_general)
ORDER BY ns_rate DESC;

-- ─────────────────────────────────────────────────────────
-- 2.2 Días de la semana con más No-Shows
-- ─────────────────────────────────────────────────────────
WITH stats_diarias AS (
    SELECT 
        STRFTIME('%w', pickup_datetime) AS dia_num,
        CASE CAST(STRFTIME('%w', pickup_datetime) AS INTEGER)
            WHEN 0 THEN 'Domingo'
            WHEN 1 THEN 'Lunes'
            WHEN 2 THEN 'Martes'
            WHEN 3 THEN 'Miércoles'
            WHEN 4 THEN 'Jueves'
            WHEN 5 THEN 'Viernes'
            WHEN 6 THEN 'Sábado'
        END AS dia_semana,
        COUNT(*) AS total,
        SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) AS no_shows
    FROM reservations
    GROUP BY STRFTIME('%w', pickup_datetime)
)
SELECT 
    dia_semana,
    total,
    no_shows,
    ROUND(no_shows * 100.0 / total, 1) AS ns_rate,
    ROUND(AVG(no_shows * 100.0 / total) OVER(), 1) AS promedio_general,
    ROUND(no_shows * 100.0 / total - AVG(no_shows * 100.0 / total) OVER(), 1) AS vs_promedio
FROM stats_diarias
ORDER BY ns_rate DESC;

-- ─────────────────────────────────────────────────────────
-- 2.3 Clientes VIP vs Regulares: comportamiento
-- ─────────────────────────────────────────────────────────
SELECT 
    CASE WHEN c.is_vip THEN 'VIP' ELSE 'Regular' END AS tipo_cliente,
    COUNT(*) AS reservas,
    COUNT(DISTINCT r.customer_id) AS clientes_unicos,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT r.customer_id), 1) AS avg_reservas_por_cliente,
    ROUND(AVG(r.total_amount), 2) AS ticket_promedio,
    ROUND(AVG(r.rental_days), 1) AS duracion_promedio,
    ROUND(SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS ns_rate,
    ROUND(
        SUM(CASE WHEN r.status = 'no_show' THEN r.total_amount ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END), 0), 
        2
    ) AS perdida_promedio_por_no_show
FROM reservations r
JOIN customers c ON r.customer_id = c.customer_id
GROUP BY tipo_cliente;
