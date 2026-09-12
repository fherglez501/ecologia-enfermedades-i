# Ecología de Enfermedades I

Repositorio docente de la asignatura **Ecología de Enfermedades I** de la Licenciatura en Administración de la Fauna Silvestre.

El repositorio integra **datos, scripts en R, guías docentes y presentaciones Quarto** para que cada laboratorio pueda reproducirse desde un mismo proyecto.

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

## Presentaciones Quarto

Cada práctica cuenta con una presentación teórica reproducible en formato `.qmd`.

```text
presentations/lab02/lab02-procesamiento-tablas.qmd
presentations/lab03/lab03-lincoln-petersen.qmd
```

La identidad visual compartida está definida en:

```text
presentations/_assets/theme/esmvz.scss
```

El tema conserva la línea visual de las presentaciones docentes: formato 16:9, Google Sans cuando está disponible, verde oliva, verde oscuro, azul científico, rojo de advertencia, fondos claros, tarjetas, tablas y jerarquías tipográficas consistentes.

Para renderizar una presentación:

1. abrir el archivo `.qmd` en RStudio;
2. pulsar **Render**.

O desde terminal:

```bash
quarto render presentations/lab03/lab03-lincoln-petersen.qmd
```

Los resultados se generan en `_rendered/`, carpeta excluida del control de versiones. Consulte `presentations/README.md` para detalles del sistema visual y flujo de trabajo.

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

Evidencia principal:

- base depurada;
- auditoría de calidad;
- resumen descriptivo por grupos;
- registro de `sessionInfo()`.

---

## Laboratorio 3 — Estimador Lincoln–Petersen

**Fecha:** 14/09/2026  
**Tema:** estimación del tamaño poblacional, corrección de Chapman e intervalos de confianza.

**Objetivo:** programar y validar estimaciones de abundancia para poblaciones cerradas.

Presentación:

```text
presentations/lab03/lab03-lincoln-petersen.qmd
```

Durante la práctica se desarrollará:

- cálculo manual de Lincoln–Petersen;
- corrección de Chapman;
- varianza y error estándar;
- intervalo de confianza aproximado;
- construcción de una función parametrizada en R;
- validación del cálculo;
- comparación de escenarios con distinto número de recapturas;
- revisión de los supuestos ecológicos del modelo.

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

Quienes ya trabajaron el Laboratorio 2 **no necesitan volver a clonar** el proyecto:

1. abrir `ecologia-enfermedades-i.Rproj`;
2. ejecutar **Git → Pull**;
3. abrir la presentación Quarto del laboratorio;
4. seguir el fundamento teórico;
5. abrir `scripts/03_lab-lincoln-petersen.R`;
6. seguir la demostración por secciones.

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
│   └── lab03/
│       └── lab03-lincoln-petersen.qmd
├── scripts/
│   ├── 02_lab-procesamiento-tablas-epidemiologicas.R
│   └── 03_lab-lincoln-petersen.R
├── data/
│   ├── raw/
│   │   ├── surveillance_lab02.csv
│   │   ├── messy_site_coverage.csv
│   │   ├── tidy_site_coverage.csv
│   │   └── escenarios_captura_recaptura_lab03.csv
│   ├── dictionaries/
│   │   └── linelist_datadict_es.csv
│   └── processed/
├── outputs/
│   ├── tables/
│   └── figures/
└── docs/
    ├── guia-docente-lab02.md
    └── guia-docente-lab03.md
```

## Software y paquetes utilizados

### Software

- R
- RStudio
- Git
- Quarto

### Paquetes R

Los scripts verifican e instalan, cuando es necesario:

- `tidyverse`
- `janitor`
- `lubridate`
- `here`

## Principios de reproducibilidad

- `data/raw/` se considera **inmutable** durante las prácticas.
- Los productos derivados se guardan en `data/processed/` y `outputs/`.
- No corregir anomalías silenciosamente: identificarlas y documentarlas.
- No usar rutas absolutas.
- Cada estudiante trabaja sobre su **clon local**; no necesita permisos de escritura en este repositorio.
- Antes de cada laboratorio se recomienda ejecutar **Pull** para obtener la versión más reciente.
- Las presentaciones se mantienen como código fuente Quarto, bajo el mismo control de versiones que los scripts.

## Docente

MVZ, MSc. José Fernando Aguilera González  
Ecología de Enfermedades I — 2026
