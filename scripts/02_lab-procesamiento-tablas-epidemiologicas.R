# ============================================================================== 
# Ecología de Enfermedades I
# Laboratorio 2 — Procesamiento de tablas epidemiológicas
# Semana 2 | 07 septiembre 2026
#
# Objetivo:
# Convertir datos crudos en una tabla epidemiológica ordenada y auditable.
#
# Evidencia:
# - base depurada;
# - tabla de auditoría;
# - resumen descriptivo por grupos;
# - información de la sesión de R.
#
# Docente: MVZ, MSc. José Fernando Aguilera González
# ============================================================================== 


# 00. Preparación --------------------------------------------------------------

# IMPORTANTE:
# Abra siempre "ecologia-enfermedades-i.Rproj".
# No utilice setwd(): el proyecto usa rutas relativas con here().

paquetes <- c("tidyverse", "janitor", "lubridate", "here")

faltantes <- paquetes[!paquetes %in% rownames(installed.packages())]

if (length(faltantes) > 0) {
  install.packages(faltantes)
}

library(tidyverse)
library(janitor)
library(lubridate)
library(here)

cat("Raíz del proyecto:\n", here(), "\n")


# 01. Localizar los archivos ---------------------------------------------------

ruta_datos <- here(
  "data", "raw", "surveillance_lab02.csv"
)

ruta_messy <- here(
  "data", "raw", "messy_site_coverage.csv"
)

ruta_tidy <- here(
  "data", "raw", "tidy_site_coverage.csv"
)

file.exists(ruta_datos)
file.exists(ruta_messy)
file.exists(ruta_tidy)


# 02. Datos ordenados: calentamiento -------------------------------------------

# Tres reglas:
# 1) cada VARIABLE ocupa una columna;
# 2) cada OBSERVACIÓN ocupa una fila;
# 3) cada VALOR ocupa una celda.

sitios_messy <- read_csv(
  ruta_messy,
  col_names = FALSE,
  show_col_types = FALSE
)

sitios_tidy <- read_csv(
  ruta_tidy,
  show_col_types = FALSE
) %>%
  clean_names()

dim(sitios_messy)
dim(sitios_tidy)

names(sitios_tidy)
glimpse(sitios_tidy)

# Pregunta:
# ¿Cuál de estas tablas cumple mejor las tres reglas de datos ordenados?


# 03. Importar la tabla epidemiológica -----------------------------------------

surv_raw <- read_csv(
  ruta_datos,
  na = c("", "NA"),
  show_col_types = FALSE
)

# ¿Qué acaba de ocurrir?
class(surv_raw)
dim(surv_raw)
names(surv_raw)
glimpse(surv_raw)

# Observe algunas categorías:
surv_raw %>%
  count(gender, sort = TRUE)

surv_raw %>%
  count(hospital, sort = TRUE)


# 04. Auditoría inicial ---------------------------------------------------------

# Antes de limpiar, primero describimos el problema.

auditoria_raw <- tibble(
  indicador = c(
    "filas",
    "columnas",
    "case_id únicos",
    "filas duplicadas exactas",
    "case_id duplicados",
    "edad faltante",
    "género Unknown",
    "peso negativo"
  ),
  valor = c(
    nrow(surv_raw),
    ncol(surv_raw),
    n_distinct(surv_raw$case_id),
    sum(duplicated(surv_raw)),
    sum(duplicated(surv_raw$case_id)),
    sum(is.na(surv_raw$age)),
    sum(surv_raw$gender == "Unknown", na.rm = TRUE),
    sum(surv_raw$`wt (kg)` < 0, na.rm = TRUE)
  )
)

auditoria_raw


# 05. clean_names(): estandarizar nombres -------------------------------------

surv <- surv_raw %>%
  clean_names()

names(surv)

# Observe el cambio:
# "onset date"     -> onset_date
# "date of report" -> date_of_report
# "wt (kg)"        -> wt_kg


# 06. select() y rename(): elegir variables -----------------------------------

surv <- surv %>%
  rename(
    date_onset = onset_date,
    date_report = date_of_report,
    district_res = adm3_name_res,
    district_det = adm3_name_det
  ) %>%
  select(
    -row_num
  )

names(surv)


# 07. distinct(): eliminar duplicados exactos ----------------------------------

nrow(surv)

surv <- surv %>%
  distinct()

nrow(surv)

# IMPORTANTE:
# distinct() elimina FILAS idénticas.
# No significa automáticamente "eliminar IDs duplicados".


# 08. mutate(): transformar variables ------------------------------------------

surv <- surv %>%

  # Fechas: character -> Date
  mutate(
    date_onset = mdy(date_onset),
    date_report = mdy(date_report)
  ) %>%

  # Estandarizar género y hospital
  mutate(
    gender = na_if(gender, "Unknown"),

    gender = recode(
      gender,
      "m" = "male",
      "f" = "female"
    ),

    hospital = recode(
      hospital,
      "Mitilary Hospital" = "Military Hospital",
      "Port" = "Port Hospital",
      "Port Hopital" = "Port Hospital",
      "St. Mark's Maternity Hospital (SMMH)" = "SMMH"
    )
  ) %>%

  # Peso negativo = dato anómalo.
  # Se convierte en NA; no se inventa un valor sustituto.
  mutate(
    wt_kg = if_else(
      wt_kg < 0,
      NA_real_,
      as.double(wt_kg)
    )
  ) %>%

  # Convertir edad a años
  mutate(
    age_years = case_when(
      age_unit == "months" ~ age / 12,
      age_unit == "years" ~ age,
      is.na(age_unit) ~ age,
      TRUE ~ NA_real_
    )
  ) %>%

  # Crear nuevas variables epidemiológicas
  mutate(
    report_delay_days = as.integer(
      date_report - date_onset
    ),

    district = coalesce(
      district_det,
      district_res
    ),

    case_def = case_when(
      lab_confirmed == TRUE ~ "Confirmed",
      epilink == "yes" & fever == "yes" ~ "Suspect",
      TRUE ~ "To investigate"
    )
  ) %>%

  # Banderas de control de calidad
  mutate(
    flag_negative_delay = report_delay_days < 0,
    flag_missing_age = is.na(age_years),
    flag_missing_gender = is.na(gender)
  )

glimpse(surv)


# 09. filter(): seleccionar registros ------------------------------------------

# Ejemplo 1: casos confirmados
confirmados <- surv %>%
  filter(case_def == "Confirmed")

nrow(confirmados)

# Ejemplo 2: registros con peso disponible
con_peso <- surv %>%
  filter(!is.na(wt_kg))

nrow(con_peso)

# Ejemplo 3: registros que requieren revisión
revision <- surv %>%
  filter(
    flag_negative_delay |
      flag_missing_age |
      flag_missing_gender
  )

revision


# 10. arrange(): ordenar --------------------------------------------------------

surv %>%
  arrange(desc(age_years)) %>%
  select(
    case_id,
    gender,
    age_years,
    case_def,
    district
  ) %>%
  slice_head(n = 10)


# 11. group_by() + summarise(): resumir ----------------------------------------

# Resumen por género
resumen_genero <- surv %>%
  group_by(gender) %>%
  summarise(
    n = n(),
    confirmados = sum(lab_confirmed, na.rm = TRUE),
    proporcion_confirmados = mean(
      lab_confirmed,
      na.rm = TRUE
    ),
    edad_media = mean(
      age_years,
      na.rm = TRUE
    ),
    retraso_mediano_dias = median(
      report_delay_days,
      na.rm = TRUE
    ),
    .groups = "drop"
  )

resumen_genero


# Resumen por definición de caso
resumen_caso <- surv %>%
  count(
    case_def,
    name = "n"
  ) %>%
  mutate(
    porcentaje = 100 * n / sum(n)
  ) %>%
  arrange(desc(n))

resumen_caso


# Resumen por distrito
resumen_distrito <- surv %>%
  group_by(district) %>%
  summarise(
    n = n(),
    confirmados = sum(
      lab_confirmed,
      na.rm = TRUE
    ),
    edad_media = mean(
      age_years,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  arrange(desc(n))

resumen_distrito


# 12. Auditoría final -----------------------------------------------------------

auditoria_clean <- tibble(
  indicador = c(
    "filas",
    "columnas",
    "case_id únicos",
    "filas duplicadas exactas",
    "case_id duplicados",
    "peso negativo restante",
    "retraso negativo",
    "edad faltante",
    "género faltante"
  ),
  valor = c(
    nrow(surv),
    ncol(surv),
    n_distinct(surv$case_id),
    sum(duplicated(surv)),
    sum(duplicated(surv$case_id)),
    sum(surv$wt_kg < 0, na.rm = TRUE),
    sum(surv$flag_negative_delay, na.rm = TRUE),
    sum(surv$flag_missing_age),
    sum(surv$flag_missing_gender)
  )
)

auditoria <- bind_rows(
  auditoria_raw %>%
    mutate(etapa = "raw"),
  auditoria_clean %>%
    mutate(etapa = "clean")
) %>%
  select(etapa, everything())

auditoria


# 13. Exportar la evidencia -----------------------------------------------------

dir.create(
  here("data", "processed"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  here("outputs", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)

# Base depurada
write_csv(
  surv,
  here(
    "data",
    "processed",
    "surveillance_lab02_clean.csv"
  ),
  na = ""
)

# Auditoría
write_csv(
  auditoria,
  here(
    "outputs",
    "tables",
    "lab02_auditoria.csv"
  )
)

# Resúmenes
write_csv(
  resumen_genero,
  here(
    "outputs",
    "tables",
    "lab02_resumen_genero.csv"
  )
)

write_csv(
  resumen_caso,
  here(
    "outputs",
    "tables",
    "lab02_resumen_caso.csv"
  )
)

write_csv(
  resumen_distrito,
  here(
    "outputs",
    "tables",
    "lab02_resumen_distrito.csv"
  )
)

# Información de la sesión
capture.output(
  sessionInfo(),
  file = here(
    "outputs",
    "lab02_sessionInfo.txt"
  )
)


# 14. Comprobación --------------------------------------------------------------

cat("\nLABORATORIO 2 COMPLETADO\n")
cat("Filas crudas:", nrow(surv_raw), "\n")
cat("Filas depuradas:", nrow(surv), "\n")
cat("Casos confirmados:", nrow(confirmados), "\n")

list.files(
  here("outputs", "tables")
)


# 15. Preguntas de cierre -------------------------------------------------------

# 1. ¿Qué diferencia existe entre limpiar un nombre y limpiar un valor?
# 2. ¿Por qué distinct() no equivale a eliminar case_id duplicados?
# 3. ¿Por qué se convirtió un peso negativo en NA y no en un valor "corregido"?
# 4. ¿Qué ventaja tiene group_by() + summarise() para vigilancia epidemiológica?
# 5. ¿Qué problema resuelve here() cuando diferentes personas clonan el proyecto?
# 6. Identifique una limitación de calidad de datos que permanezca sin resolver.

# Fin --------------------------------------------------------------------------
