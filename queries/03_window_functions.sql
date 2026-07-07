-- ==========================================================
-- SQL for Decision Intelligence
-- Nivel 3: Window Functions
-- ==========================================================

-- ─────────────────────────────────────────────────────────
-- 3.1 Ranking de revenue por marca (cada mes)
-- ─────────────────────────────────────────────────────────
SELECT 
    STRFTIME('%Y-%m', r.pickup_datetime) AS mes,
    b.brand_name,
    ROUND(SUM(r.total_amount), 2) AS revenue,
    RANK() OVER (PARTITION BY STRFTIME('%Y-%m', r.pickup_datetime) 
                 ORDER BY SUM(r.total_amount) DESC) AS rank_mensual,
    ROUND(
        SUM(r.total_amount) - LAG(SUM(r.total_amount)) OVER (
            PARTITION BY b.brand_name 
            ORDER BY STRFTIME('%Y-%m', r.pickup_datetime)
        ), 2
    ) AS cambio_vs_mes_anterior,
    ROUND(
        (SUM(r.total_amount) - LAG(SUM(r.total_amount)) OVER (
            PARTITION BY b.brand_name 
            ORDER BY STRFTIME('%Y-%m', r.pickup_datetime)
        )) * 100.0 / NULLIF(LAG(SUM(r.total_amount)) OVER (
            PARTITION BY b.brand_name 
            ORDER BY STRFTIME('%Y-%m', r.pickup_datetime)
        ), 0), 1
    ) AS crecimiento_pct
FROM reservations r
JOIN brands b ON r.brand_id = b.brand_id
WHERE r.status IN ('activa', 'completada')
GROUP BY mes, b.brand_name
ORDER BY mes, rank_mensual;

-- ─────────────────────────────────────────────────────────
-- 3.2 Tendencia de No-Show: media móvil 7 días
-- ─────────────────────────────────────────────────────────
WITH daily_ns AS (
    SELECT 
        DATE(pickup_datetime) AS fecha,
        COUNT(*) AS total,
        SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) AS no_shows,
        ROUND(SUM(CASE WHEN status = 'no_show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS ns_rate
    FROM reservations
    GROUP BY DATE(pickup_datetime)
)
SELECT 
    fecha,
    total,
    no_shows,
    ns_rate,
    ROUND(AVG(ns_rate) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS media_movil_7d,
    ROUND(AVG(ns_rate) OVER (ORDER BY fecha ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 1) AS media_movil_30d,
    CASE 
        WHEN ns_rate > AVG(ns_rate) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) * 1.3 
        THEN '⚠️ ALERTA'
        ELSE '✅ Normal'
    END AS estado
FROM daily_ns
ORDER BY fecha;

-- ─────────────────────────────────────────────────────────
-- 3.3 Customer Lifetime Value (CLV) por percentil
-- ─────────────────────────────────────────────────────────
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS cliente,
        COUNT(*) AS num_reservas,
        ROUND(SUM(r.total_amount), 2) AS total_gastado,
        ROUND(AVG(r.total_amount), 2) AS ticket_promedio,
        ROUND(AVG(r.rental_days), 1) AS avg_duracion,
        JULIANDAY(MAX(r.pickup_datetime)) - JULIANDAY(MIN(r.pickup_datetime)) AS dias_activo
    FROM reservations r
    JOIN customers c ON r.customer_id = c.customer_id
    WHERE r.status IN ('activa', 'completada')
    GROUP BY c.customer_id, cliente
)
SELECT 
    cliente,
    num_reservas,
    total_gastado,
    ticket_promedio,
    avg_duracion,
    CASE 
        WHEN total_gastado >= PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_gastado) OVER() THEN '🟢 Top 10%'
        WHEN total_gastado >= PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_gastado) OVER() THEN '🔵 Top 25%'
        WHEN total_gastado >= PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_gastado) OVER() THEN '🟡 Medio'
        ELSE '⚪ Ocasional'
    END AS segmento,
    ROUND(total_gastado * 1.0 / NULLIF(num_reservas, 0), 2) AS valor_por_reserva
FROM customer_stats
ORDER BY total_gastado DESC
LIMIT 20;

-- ─────────────────────────────────────────────────────────
-- 3.4 Horas pico: diferencia por marca
-- ─────────────────────────────────────────────────────────
SELECT 
    b.brand_name,
    EXTRACT(HOUR FROM r.pickup_datetime) AS hora,
    COUNT(*) AS reservas,
    ROW_NUMBER() OVER (PARTITION BY b.brand_name ORDER BY COUNT(*) DESC) AS rank_hora,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY b.brand_name), 1) AS porcentaje_diario
FROM reservations r
JOIN brands b ON r.brand_id = b.brand_id
WHERE r.status IN ('activa', 'completada')
GROUP BY b.brand_name, hora
QUALIFY rank_hora <= 3
ORDER BY b.brand_name, reservas DESC;
