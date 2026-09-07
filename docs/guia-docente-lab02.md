# Guía docente — Laboratorio 2

## Propósito

Desarrollar el flujo:

**importar → auditar → limpiar → transformar → filtrar → agrupar → resumir → exportar**

El objetivo de la Semana 2 es **convertir datos crudos en una tabla epidemiológica ordenada y auditable**.

## Secuencia sugerida para la demostración

| Tiempo | Actividad |
|---:|---|
| 10 min | Clonar el repositorio y abrir `.Rproj` |
| 10 min | Comparar datos desordenados vs. ordenados |
| 15 min | Importar e inspeccionar `surveillance_lab02.csv` |
| 30 min | Limpieza y transformación con `dplyr` |
| 15 min | Auditoría de duplicados, faltantes y anomalías |
| 20 min | `group_by()` + `summarise()` |
| 10 min | Exportar evidencia y revisar `sessionInfo()` |

## Checkpoints docentes

Con el subconjunto incluido:

- tabla cruda: **79 filas y 14 columnas**;
- filas duplicadas exactas: **9**;
- después de `distinct()`: **70 filas**;
- pesos negativos iniciales: **1**;
- retrasos negativos reporte–inicio: **1**;
- género `Unknown` inicial: **3**;
- edades faltantes iniciales: **3**;
- definición de caso después de la transformación:
  - `Confirmed`: **58**
  - `Suspect`: **9**
  - `To investigate`: **3**.

## Puntos conceptuales

- `clean_names()` estandariza nombres, pero no resuelve problemas semánticos.
- `distinct()` elimina filas idénticas; no equivale a eliminar IDs repetidos.
- `NA` representa información ausente; no debe sustituirse con valores inventados.
- Los datos crudos deben mantenerse inmutables.
- `filter()` crea subconjuntos; no debería destruir la base maestra durante la exploración.
- `group_by()` + `summarise()` permite generar indicadores descriptivos por estratos epidemiológicos.
- `here()` hace que las mismas rutas funcionen en las computadoras de docente y estudiantes.

## Evidencia mínima

1. `scripts/02_lab-procesamiento-tablas-epidemiologicas.R`
2. `data/processed/surveillance_lab02_clean.csv`
3. `outputs/tables/lab02_auditoria.csv`
4. al menos un resumen por grupos;
5. `outputs/lab02_sessionInfo.txt`.

## Pregunta de salida

**¿Qué decisión de limpieza fue puramente técnica y cuál requirió un supuesto sobre el significado de los datos?**
