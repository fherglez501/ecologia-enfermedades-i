# Ecología de Enfermedades I

Repositorio docente de la asignatura **Ecología de Enfermedades I** de la Licenciatura en Administración de la Fauna Silvestre.

## Laboratorio 2 — Procesamiento de tablas epidemiológicas

**Objetivo:** convertir datos crudos en una tabla epidemiológica ordenada y auditable mediante importación, inspección, limpieza, transformación, filtrado, agrupación y resumen descriptivo con R.

### Clonar en RStudio

1. Abrir **RStudio**.
2. Ir a **File → New Project → Version Control → Git**.
3. En **Repository URL** pegar:

```text
https://github.com/fherglez501/ecologia-enfermedades-i.git
```

4. Elegir la carpeta donde se guardará el proyecto.
5. Pulsar **Create Project**.
6. Abrir:

```text
scripts/02_lab-procesamiento-tablas-epidemiologicas.R
```

7. Ejecutar el script **por secciones** mientras se desarrolla la demostración.

> No es necesario usar `setwd()`. El proyecto utiliza rutas relativas mediante `here()`.

## Estructura actual

```text
ecologia-enfermedades-i/
├── ecologia-enfermedades-i.Rproj
├── README.md
├── scripts/
│   └── 02_lab-procesamiento-tablas-epidemiologicas.R
├── data/
│   ├── raw/
│   │   ├── surveillance_lab02.csv
│   │   ├── messy_site_coverage.csv
│   │   └── tidy_site_coverage.csv
│   ├── dictionaries/
│   │   └── linelist_datadict_es.csv
│   └── processed/
├── outputs/
│   └── tables/
└── docs/
    └── guia-docente-lab02.md
```

## Paquetes

El script verifica e instala, si es necesario:

- `tidyverse`
- `janitor`
- `lubridate`
- `here`

## Flujo de trabajo

```text
datos crudos
   ↓
importar
   ↓
inspeccionar y auditar
   ↓
limpiar
   ↓
transformar
   ↓
filtrar
   ↓
agrupar y resumir
   ↓
exportar
```

## Reglas de trabajo

- `data/raw/` se considera **inmutable** durante la práctica.
- Los productos derivados se guardan en `data/processed/` y `outputs/`.
- No corregir anomalías silenciosamente: identificarlas y documentarlas.
- No usar rutas absolutas.
- Cada estudiante trabaja sobre su **clon local**; no necesita permisos de escritura en este repositorio.

## Evidencia del Laboratorio 2

Al finalizar, cada estudiante debe contar al menos con:

1. el script ejecutado y comentado;
2. una base depurada;
3. una tabla de auditoría;
4. un resumen descriptivo por grupos;
5. `sessionInfo()` como registro de reproducibilidad.

## Docente

MVZ, MSc. José Fernando Aguilera González  
Ecología de Enfermedades I — 2026
