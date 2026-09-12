# Ecología de Enfermedades I

Repositorio docente de la asignatura **Ecología de Enfermedades I** de la Licenciatura en Administración de la Fauna Silvestre.

El repositorio integra **datos, scripts en R, dependencias centralizadas, guías docentes y presentaciones Quarto** para que las prácticas puedan reproducirse desde un mismo proyecto.

## Clonar el proyecto en RStudio

Si es la primera vez que utilizarás el repositorio:

1. Abrir **RStudio**.
2. Ir a **File → New Project → Version Control → Git**.
3. En **Repository URL** pegar:

```text
https://github.com/fherglez501/ecologia-enfermedades-i.git
```

4. Elegir la carpeta local.
5. Pulsar **Create Project**.

> No es necesario usar `setwd()`. El proyecto utiliza rutas relativas mediante `here()`.

## Si ya clonaste el repositorio

Antes de cada nuevo laboratorio, actualiza tu copia local:

```text
Git → Pull
```

En RStudio también puedes usar el botón **Pull** del panel Git.

---

## Biblioteca maestra de paquetes

A partir del script `02b`, la instalación, actualización y carga de paquetes se centraliza en:

```text
scripts/00_library.R
```

El archivo utiliza:

- `pak` para instalar y actualizar los paquetes declarados y sus dependencias;
- `pacman` para cargar conjuntamente las bibliotecas necesarias.

Los scripts posteriores comienzan con:

```r
source(here::here("scripts", "00_library.R"))
```

Esto permite introducir y reutilizar `source()` y evita repetir en cada práctica bloques de `install.packages()` y `library()`.

### Primera ejecución en una instalación nueva de R

Si `here` todavía no existe en la computadora, ejecute una sola vez desde la raíz del proyecto:

```r
source("scripts/00_library.R")
```

Después de esa primera preparación, los scripts pueden utilizar normalmente:

```r
source(here::here("scripts", "00_library.R"))
```

### Regla para prácticas futuras

Cuando una nueva práctica necesite un paquete adicional, se agrega **una sola vez** al vector `paquetes` de `scripts/00_library.R`. Los scripts individuales no deben volver a implementar su propio bloque de instalación y carga, salvo que exista una razón metodológica específica.

---

## Presentaciones Quarto

Las prácticas cuentan con presentaciones reproducibles en formato `.qmd`.

```text
presentations/lab02/lab02-procesamiento-tablas.qmd
presentations/muestreo/muestreo-calculos-r.qmd
presentations/lab03/lab03-lincoln-petersen.qmd
```

La identidad visual compartida está definida en:

```text
presentations/_assets/theme/esmvz.scss
```

Para renderizar una presentación, abra el archivo `.qmd` en RStudio y utilice **Render**, o ejecute desde terminal:

```bash
quarto render presentations/lab03/lab03-lincoln-petersen.qmd
```

Los resultados se generan en `_rendered/`, carpeta excluida del control de versiones.

---

## Módulo II — Diseño de muestreo y vigilancia con R

**Propósito:** convertir las decisiones metodológicas de **M2 — Diseño de Muestreo** en cálculos reproducibles de tamaño de muestra, precisión, detección imperfecta, potencia y selección probabilística de unidades.

Este bloque funciona como **puente metodológico** entre la discusión conceptual de diseño de muestreo y el Laboratorio 3. No sustituye ni renumera la secuencia formal de laboratorios.

Presentación:

```text
presentations/muestreo/muestreo-calculos-r.qmd
```

Script:

```text
scripts/02b_diseno-muestreo-vigilancia.R
```

Datos:

```text
data/raw/escenarios_muestreo_bd_m2.csv
```

El script desarrolla:

- cálculo manual del tamaño de muestra para detectar al menos un positivo;
- incorporación de sensibilidad diagnóstica;
- verificación mediante `epiR::epi.ssdetect()`;
- tamaño de muestra basado en precisión mediante `presize::prec_prop()`;
- prevalencia aparente y ajustada con `epiR::epi.prev()`;
- potencia para comparar dos proporciones mediante `pwr`;
- muestreo aleatorio simple y estratificado mediante `sampling`;
- comparación de distribuciones de 150 hisopos entre 20 humedales para discutir replicación espacial y pseudorreplicación.

Documentación metodológica:

```text
docs/integracion-m2-diseno-muestreo.md
```

---

## Laboratorio 2 — Procesamiento de tablas epidemiológicas

**Fecha:** 07/09/2026  
**Objetivo:** convertir datos crudos en una tabla epidemiológica ordenada y auditable mediante importación, inspección, limpieza, transformación, filtrado, agrupación y resumen descriptivo con R.

Presentación:

```text
presentations/lab02/lab02-procesamiento-tablas.qmd
```

Script:

```text
scripts/02_lab-procesamiento-tablas-epidemiologicas.R
```

> Este script se conserva con su bloque original de paquetes como antecedente pedagógico. La biblioteca maestra se adopta a partir de `02b`.

---

## Laboratorio 3 — Estimador Lincoln–Petersen

**Fecha:** 14/09/2026  
**Tema:** estimación del tamaño poblacional, corrección de Chapman e intervalos de confianza.

**Objetivo:** programar y validar estimaciones de abundancia para poblaciones cerradas.

Presentación:

```text
presentations/lab03/lab03-lincoln-petersen.qmd
```

Script:

```text
scripts/03_lab-lincoln-petersen.R
```

Datos:

```text
data/raw/escenarios_captura_recaptura_lab03.csv
```

Guía docente:

```text
docs/guia-docente-lab03.md
```

### Secuencia para estudiantes

Quienes ya trabajaron el Laboratorio 2 no necesitan volver a clonar el proyecto:

1. abrir `ecologia-enfermedades-i.Rproj`;
2. ejecutar **Git → Pull**;
3. abrir la presentación correspondiente;
4. seguir el fundamento teórico;
5. abrir el script R;
6. ejecutar la sección `00. Preparación`, que carga `scripts/00_library.R`;
7. continuar la demostración por secciones.

---

## Estructura actual

```text
ecologia-enfermedades-i/
├── ecologia-enfermedades-i.Rproj
├── _quarto.yml
├── README.md
├── presentations/
│   ├── README.md
│   ├── _assets/
│   │   └── theme/
│   │       └── esmvz.scss
│   ├── lab02/
│   │   └── lab02-procesamiento-tablas.qmd
│   ├── muestreo/
│   │   └── muestreo-calculos-r.qmd
│   └── lab03/
│       └── lab03-lincoln-petersen.qmd
├── scripts/
│   ├── 00_library.R
│   ├── 02_lab-procesamiento-tablas-epidemiologicas.R
│   ├── 02b_diseno-muestreo-vigilancia.R
│   └── 03_lab-lincoln-petersen.R
├── data/
│   ├── raw/
│   │   ├── surveillance_lab02.csv
│   │   ├── messy_site_coverage.csv
│   │   ├── tidy_site_coverage.csv
│   │   ├── escenarios_muestreo_bd_m2.csv
│   │   └── escenarios_captura_recaptura_lab03.csv
│   ├── dictionaries/
│   │   └── linelist_datadict_es.csv
│   └── processed/
├── outputs/
│   ├── tables/
│   └── figures/
└── docs/
    ├── guia-docente-lab02.md
    ├── integracion-m2-diseno-muestreo.md
    └── guia-docente-lab03.md
```

## Software y paquetes utilizados

### Software

- R
- RStudio
- Git
- Quarto

### Gestión de paquetes

- `pak` — resolución, instalación y actualización de dependencias;
- `pacman` — carga conjunta de bibliotecas.

### Paquetes analíticos utilizados hasta el momento

El vector maestro contiene actualmente:

```r
paquetes <- c(
  "here",
  "tidyverse",
  "janitor",
  "lubridate",
  "epiR",
  "presize",
  "sampling",
  "pwr",
  "scales"
)
```

`scales` se declara explícitamente porque el script `02b` utiliza `scales::label_percent()`, aunque también pueda instalarse como dependencia de otros paquetes.

## Principios de reproducibilidad

- `data/raw/` se considera **inmutable** durante las prácticas.
- Los productos derivados se guardan en `data/processed/` y `outputs/`.
- No corregir anomalías silenciosamente: identificarlas y documentarlas.
- No usar rutas absolutas.
- Cada estudiante trabaja sobre su **clon local**.
- Antes de cada laboratorio se recomienda ejecutar **Pull**.
- Las presentaciones se mantienen como código fuente Quarto bajo el mismo control de versiones que los scripts.
- Las dependencias de R se declaran centralmente en `scripts/00_library.R`.
- El tamaño de muestra debe justificarse a partir del objetivo inferencial y no como una cifra aislada.

## Docente

MVZ, MSc. José Fernando Aguilera González  
Ecología de Enfermedades I — 2026
