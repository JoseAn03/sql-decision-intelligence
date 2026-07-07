# 🧠 SQL for Decision Intelligence

## De pregunta de negocio → query SQL optimizada → insight ejecutivo

Un portafolio de **consultas SQL progresivas** que demuestran cómo convertir datos crudos en decisiones de negocio. Desde SELECTs básicos hasta window functions, CTEs y optimización de performance.

---

## 📁 Estructura

```
sql-decision-intelligence/
├── data/
│   ├── rental_operations.db     ← Base DuckDB (4,642 reservas, 2,023 vuelos)
│   └── sql_export/              ← Export SQL para PostgreSQL/MySQL
├── queries/
│   ├── 01_basico.sql            ← SELECT, JOIN, GROUP BY, agregaciones
│   ├── 02_ctes_subqueries.sql   ← CTEs, subqueries, análisis comparativo
│   ├── 03_window_functions.sql  ← RANK, LAG, media móvil, percentiles
│   └── 04_optimizacion.sql      ← EXPLAIN, índices, tuning
└── README.md                    ← Esta documentación
```

---

## 📊 Las preguntas de negocio que responde

### Nivel 1: Básico — ¿Qué pasó?

| Pregunta | Query |
|----------|-------|
| ¿Cuál es el No-Show rate general? | `01_basico.sql` → 1.1 |
| ¿Quiénes son los top 5 clientes? | `01_basico.sql` → 1.2 |
| ¿Cómo va el revenue por marca cada mes? | `01_basico.sql` → 1.3 |
| ¿Qué canales tienen peor No-Show? | `01_basico.sql` → 1.4 |

### Nivel 2: CTEs y Subqueries — ¿Por qué pasó?

| Pregunta | Query |
|----------|-------|
| ¿Qué marcas están sobre el promedio de No-Show? | `02_ctes_subqueries.sql` → 2.1 |
| ¿Qué días hay más No-Shows? | `02_ctes_subqueries.sql` → 2.2 |
| ¿Los clientes VIP se comportan diferente? | `02_ctes_subqueries.sql` → 2.3 |

### Nivel 3: Window Functions — ¿Qué tendencia hay?

| Pregunta | Query | Técnica |
|----------|-------|---------|
| Ranking mensual por marca | `03_window_functions.sql` → 3.1 | `RANK() OVER(PARTITION BY)` |
| Media móvil 7d de No-Show | `03_window_functions.sql` → 3.2 | `AVG() OVER(ROWS BETWEEN)` |
| Segmentación de clientes (percentiles) | `03_window_functions.sql` → 3.3 | `PERCENTILE_CONT()` |
| Horas pico por marca | `03_window_functions.sql` → 3.4 | `ROW_NUMBER() + QUALIFY` |

### Nivel 4: Performance — ¿Qué tan rápido corre?

| Técnica | Query |
|---------|-------|
| EXPLAIN ANALYZE: subquery vs JOIN | `04_optimizacion.sql` → 4.1 |
| Índices: con vs sin | `04_optimizacion.sql` → 4.2 |
| Reporte ejecutivo en 1 query | `04_optimizacion.sql` → 4.3 |

---

## 🚀 Cómo ejecutar

### Con DuckDB (recomendado — sin instalación de servidor)

```bash
# Opción 1: Query directa
duckdb data/rental_operations.db -c "SELECT COUNT(*) FROM reservations;"

# Opción 2: Ejecutar archivo completo
duckdb data/rental_operations.db < queries/01_basico.sql

# Opción 3: Modo interactivo
duckdb data/rental_operations.db
```

### Con PostgreSQL / MySQL

```sql
-- Primero importar el schema:
psql -d rental_db < data/sql_export/schema.sql
psql -d rental_db < data/sql_export/load.sql

-- Luego ejecutar queries:
psql -d rental_db < queries/03_window_functions.sql
```

---

## 🧪 Técnicas SQL demostradas

| Técnica | Archivo | Línea |
|---------|---------|-------|
| `JOIN` multi-tabla | `01_basico.sql` | 1.2 |
| `CASE WHEN` en agregaciones | `01_basico.sql` | 1.1 |
| `HAVING` con agregación | `01_basico.sql` | 1.4 |
| `WITH` (CTE) | `02_ctes_subqueries.sql` | 2.1 |
| Subquery en `SELECT` | `02_ctes_subqueries.sql` | 2.1 |
| Subquery en `HAVING` | `02_ctes_subqueries.sql` | 2.1 |
| `RANK() OVER(PARTITION BY)` | `03_window_functions.sql` | 3.1 |
| `LAG()` para cambio vs mes anterior | `03_window_functions.sql` | 3.1 |
| `AVG() OVER(ROWS BETWEEN)` media móvil | `03_window_functions.sql` | 3.2 |
| `PERCENTILE_CONT()` para segmentación | `03_window_functions.sql` | 3.3 |
| `QUALIFY` para filtrar ventanas | `03_window_functions.sql` | 3.4 |
| `EXPLAIN ANALYZE` | `04_optimizacion.sql` | 4.1 |
| `CREATE INDEX` | `04_optimizacion.sql` | 4.2 |
| Subqueries múltiples en `SELECT` | `04_optimizacion.sql` | 4.3 |

---

## 📈 Para recruiters

Este proyecto demuestra:

✅ **SQL analítico**: paso de datos crudos a insights de negocio
✅ **Progresión técnica**: de queries básicas a window functions avanzadas
✅ **Optimización**: entendimiento de índices, EXPLAIN y performance
✅ **Documentación**: cada query explica QUÉ pregunta de negocio responde
✅ **Datos realistas**: 4,600+ reservas de operaciones aeroportuarias reales

---

<p align="center">
  <i>Hecho con 🦆 DuckDB + 🧠 SQL por José Andrés Sequeira</i>
</p>
