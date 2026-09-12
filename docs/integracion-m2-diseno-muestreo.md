# Integración M2 — Diseño de muestreo y vigilancia con R

Este bloque complementa la presentación **M2 — Diseño de Muestreo** y funciona como puente entre la discusión conceptual y los laboratorios posteriores.

## Archivos nuevos

```text
scripts/02b_diseno-muestreo-vigilancia.R
data/raw/escenarios_muestreo_bd_m2.csv
presentations/muestreo/muestreo-calculos-r.qmd
```

## Objetivo didáctico

El material no pretende enseñar una única fórmula de tamaño de muestra. Busca que el estudiante identifique primero el **objetivo inferencial** y después seleccione una herramienta apropiada.

El script distingue cuatro preguntas:

1. **Detectar presencia:** ¿cuántas unidades necesito para tener alta probabilidad de detectar al menos un positivo?
2. **Estimar prevalencia:** ¿cuántas unidades necesito para alcanzar una precisión determinada?
3. **Comparar grupos:** ¿cuántas observaciones por grupo necesito para una potencia estadística determinada?
4. **Seleccionar unidades:** una vez definido `n`, ¿qué mecanismo probabilístico usaré para elegir las unidades reales?

## Paquetes incorporados

```r
c(
  "tidyverse",
  "here",
  "epiR",
  "presize",
  "sampling",
  "pwr"
)
```

Funciones clave:

```text
epiR::epi.ssdetect()    detección de al menos un evento
presize::prec_prop()    precisión para una proporción

epiR::epi.prev()        prevalencia aparente y ajustada
pwr::pwr.2p.test()      potencia para comparar dos proporciones
sampling::srswor()      muestreo aleatorio simple
sampling::strata()      muestreo estratificado
```

## Productos generados por el script

```text
outputs/tables/m2_escenarios_deteccion.csv
outputs/tables/m2_muestra_aleatoria_simple.csv
outputs/tables/m2_muestra_estratificada.csv
outputs/tables/m2_comparacion_diseno_bd.csv
outputs/figures/m2_n_prevalencia_sensibilidad.png
outputs/m2_sessionInfo.txt
```

## Estructura actualizada

```text
ecologia-enfermedades-i/
├── presentations/
│   ├── lab02/
│   ├── lab03/
│   └── muestreo/
│       └── muestreo-calculos-r.qmd
├── scripts/
│   ├── 02_lab-procesamiento-tablas-epidemiologicas.R
│   ├── 02b_diseno-muestreo-vigilancia.R
│   └── 03_lab-lincoln-petersen.R
├── data/
│   └── raw/
│       └── escenarios_muestreo_bd_m2.csv
└── outputs/
    ├── tables/
    └── figures/
```

## Secuencia sugerida para estudiantes

```text
M2 Diseño de Muestreo
        ↓
02b_diseno-muestreo-vigilancia.R
        ↓
Laboratorio 3 — Lincoln–Petersen
        ↓
modelos posteriores de detección / ocupación
```

La intención es que el script 02b sea un **puente metodológico**, no un laboratorio adicional que compita con la secuencia formal del curso.
