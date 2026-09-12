# ============================================================================== 
# Ecología de Enfermedades I
# Script 02b — Diseño de muestreo y vigilancia epidemiológica
# Módulo II | Diseño de muestreo
#
# Objetivo:
# Traducir una pregunta sanitaria en decisiones cuantitativas de diseño:
# - detectar presencia de un patógeno;
# - estimar prevalencia con una precisión definida;
# - incorporar sensibilidad y especificidad diagnóstica;
# - explorar potencia para comparar proporciones;
# - seleccionar unidades mediante muestreo probabilístico.
#
# Idea central:
# El tamaño de muestra es una consecuencia del objetivo inferencial.
# Un n grande no corrige por sí mismo sesgo, pseudorreplicación ni mala selección.
#
# Docente: MVZ, MSc. José Fernando Aguilera González
# ============================================================================== 


# 00. Preparación --------------------------------------------------------------

# Abra siempre "ecologia-enfermedades-i.Rproj".
# No utilice setwd(): el proyecto usa rutas relativas con here().

paquetes <- c(
  "tidyverse",
  "here",
  "epiR",
  "presize",
  "sampling",
  "pwr"
)

faltantes <- paquetes[!paquetes %in% rownames(installed.packages())]

if (length(faltantes) > 0) {
  install.packages(faltantes)
}

library(tidyverse)
library(here)
library(epiR)
library(presize)
library(sampling)
library(pwr)

cat("Raíz del proyecto:\n", here(), "\n")


# 01. Escenarios de diseño -----------------------------------------------------

ruta_escenarios <- here(
  "data",
  "raw",
  "escenarios_muestreo_bd_m2.csv"
)

if (!file.exists(ruta_escenarios)) {
  stop(
    "No se encontró data/raw/escenarios_muestreo_bd_m2.csv. ",
    "Ejecute Git Pull o verifique la estructura del proyecto."
  )
}

escenarios <- read_csv(
  ruta_escenarios,
  show_col_types = FALSE
)

glimpse(escenarios)
escenarios

# Cada fila representa una combinación de supuestos.
# Cambiar un supuesto puede cambiar el esfuerzo requerido.


# 02. Detectar presencia: cálculo transparente --------------------------------

# Pregunta:
# ¿Cuántos individuos debo muestrear para tener una confianza dada de detectar
# al menos un positivo si el patógeno está presente a una prevalencia mínima p?
#
# Supuestos iniciales:
# - unidades independientes;
# - prevalencia homogénea;
# - selección compatible con la inferencia;
# - detección perfecta (por ahora).
#
# P(no detectar) = (1 - p)^n
#
# Si deseamos confianza NC:
# n = ln(1 - NC) / ln(1 - p)

prev_diseno <- 0.10
confianza <- 0.95

n_manual <- ceiling(
  log(1 - confianza) /
    log(1 - prev_diseno)
)

n_manual
# Resultado esperado: 29 individuos.

# ¿Qué pasa si sólo muestreamos 10 individuos?
n_hipotetico <- 10

prob_no_detectar <- (1 - prev_diseno)^n_hipotetico
prob_detectar <- 1 - prob_no_detectar

prob_no_detectar
prob_detectar


# 03. Función reusable: prevalencia + sensibilidad -----------------------------

# Una prueba imperfecta reduce la probabilidad efectiva de observar un positivo.
# Aproximación didáctica:
# P(positivo observado) ≈ prevalencia de diseño × sensibilidad.

n_deteccion <- function(
    prev,
    sensibilidad = 1,
    confianza = 0.95
) {
  if (any(!is.finite(prev)) ||
      any(!is.finite(sensibilidad)) ||
      any(!is.finite(confianza))) {
    stop("Los argumentos deben ser numéricos finitos.")
  }

  if (any(prev <= 0 | prev >= 1)) {
    stop("prev debe estar entre 0 y 1, sin incluir los extremos.")
  }

  if (any(sensibilidad <= 0 | sensibilidad > 1)) {
    stop("sensibilidad debe estar en (0, 1].")
  }

  if (any(confianza <= 0 | confianza >= 1)) {
    stop("confianza debe estar entre 0 y 1, sin incluir los extremos.")
  }

  p_efectiva <- prev * sensibilidad

  n <- ifelse(
    p_efectiva >= 1,
    1,
    ceiling(
      log(1 - confianza) /
        log(1 - p_efectiva)
    )
  )

  as.integer(n)
}

# Detección perfecta
n_deteccion(
  prev = 0.10,
  sensibilidad = 1.00,
  confianza = 0.95
)
# 29

# Detección imperfecta
n_deteccion(
  prev = 0.10,
  sensibilidad = 0.70,
  confianza = 0.95
)
# 42

# El mensaje metodológico es más importante que memorizar 29 o 42:
# esos números sólo son válidos bajo los supuestos utilizados.


# 04. Explorar múltiples escenarios -------------------------------------------

escenarios_resultados <- escenarios %>%
  mutate(
    p_efectiva = prevalencia_diseno * sensibilidad,
    n_minimo_binomial = n_deteccion(
      prev = prevalencia_diseno,
      sensibilidad = sensibilidad,
      confianza = confianza
    ),
    prob_no_detectar_si_n10 =
      (1 - p_efectiva)^10,
    prob_detectar_si_n10 =
      1 - prob_no_detectar_si_n10
  ) %>%
  arrange(
    prevalencia_diseno,
    desc(sensibilidad)
  )

escenarios_resultados

# Observe:
# - menor prevalencia de diseño -> mayor n;
# - menor sensibilidad -> mayor n;
# - un único "n correcto" no existe sin especificar los supuestos.


# 05. Verificación con epiR ----------------------------------------------------

# epiR permite formalizar el cálculo de vigilancia para detectar al menos un
# evento y considerar sensibilidad de la prueba y corrección por población finita.
#
# En la versión actual de epiR, la prevalencia de diseño se especifica con
# el argumento prev.

# A) Aproximación binomial: sin corrección por población finita.
epi_sin_fpc <- epiR::epi.ssdetect(
  N = 1000,
  prev = 0.10,
  se = 0.70,
  sp = 1.00,
  interpretation = "series",
  covar = c(0, 0),
  finite.correction = FALSE,
  nfractional = FALSE,
  conf.level = 0.95
)

epi_sin_fpc

# B) Misma pregunta, pero reconociendo que la población accesible es finita.
epi_con_fpc <- epiR::epi.ssdetect(
  N = 1000,
  prev = 0.10,
  se = 0.70,
  sp = 1.00,
  interpretation = "series",
  covar = c(0, 0),
  finite.correction = TRUE,
  nfractional = FALSE,
  conf.level = 0.95
)

epi_con_fpc

# Pregunta de interpretación:
# ¿Por qué el tamaño de la población puede importar cuando N no es muy grande?


# 06. Estimar prevalencia: precisión deseada ----------------------------------

# Detectar presencia y estimar prevalencia NO son el mismo objetivo.
# Para estimar una proporción necesitamos decidir cuánta incertidumbre aceptamos.
#
# presize::prec_prop() utiliza el ANCHO COMPLETO del intervalo de confianza.
# Por ejemplo, un margen de error de ±5 puntos porcentuales equivale a un ancho
# total de 0.10.

prev_esperada <- 0.10
margen_error <- 0.05
ancho_ic <- 2 * margen_error

precision_prev <- presize::prec_prop(
  p = prev_esperada,
  conf.width = ancho_ic,
  conf.level = 0.95,
  method = "wilson"
)

precision_prev

# Compare otros supuestos:
precision_05 <- presize::prec_prop(
  p = 0.05,
  conf.width = 0.10,
  conf.level = 0.95,
  method = "wilson"
)

precision_20 <- presize::prec_prop(
  p = 0.20,
  conf.width = 0.10,
  conf.level = 0.95,
  method = "wilson"
)

precision_05
precision_20

# Pregunta:
# ¿Por qué el n para ESTIMAR con precisión puede ser muy distinto del n para
# DETECTAR al menos un positivo?


# 07. Prevalencia aparente y prevalencia ajustada ------------------------------

# Ejemplo didáctico de la sesión:
# 18 positivos de 100 examinados.
# Sensibilidad = 0.90; especificidad = 0.95.

positivos <- 18
examinados <- 100
Se <- 0.90
Sp <- 0.95

prev_aparente <- positivos / examinados

# Corrección de Rogan–Gladen:
prev_ajustada_manual <-
  (prev_aparente + Sp - 1) /
  (Se + Sp - 1)

prev_aparente
prev_ajustada_manual

# Verificación con epiR, incluyendo incertidumbre:
prev_epi <- epiR::epi.prev(
  pos = positivos,
  tested = examinados,
  se = Se,
  sp = Sp,
  method = "wilson",
  units = 100,
  conf.level = 0.95
)

prev_epi

# Discusión:
# Una prevalencia observada no es automáticamente la prevalencia verdadera.
# La interpretación depende del desempeño diagnóstico.


# 08. Comparar dos grupos: tamaño de muestra y potencia ------------------------

# Supongamos que queremos comparar una prevalencia de 10% frente a 20%.
# Aquí cambia la pregunta: ya no buscamos sólo detectar ni estimar una proporción,
# sino identificar una diferencia entre dos grupos.

p1 <- 0.10
p2 <- 0.20

h <- pwr::ES.h(
  p1 = p1,
  p2 = p2
)

potencia_dos_proporciones <- pwr::pwr.2p.test(
  h = h,
  n = NULL,
  sig.level = 0.05,
  power = 0.80,
  alternative = "two.sided"
)

potencia_dos_proporciones

n_por_grupo <- ceiling(
  potencia_dos_proporciones$n
)

n_por_grupo

# Este n es POR GRUPO y responde a una pregunta diferente.
# No debe sustituir los cálculos de vigilancia o precisión.


# 09. "¿Cuántas?" no responde "¿cuáles?" --------------------------------------

# Construimos un marco ficticio de 20 humedales para practicar selección.
# Los nombres son didácticos: no representan localidades reales.

marco_humedales <- tibble(
  site_id = sprintf("H%02d", 1:20),
  estrato_id = c(
    rep(1, 8),
    rep(2, 6),
    rep(3, 6)
  ),
  habitat = c(
    rep("bosque_nublado", 8),
    rep("pino_encino", 6),
    rep("humedal_abierto", 6)
  ),
  accesibilidad = c(
    "baja", "media", "baja", "alta",
    "media", "baja", "alta", "media",
    "media", "alta", "media", "baja",
    "alta", "media",
    "alta", "alta", "media", "baja",
    "media", "alta"
  ),
  capacidad_muestreo = c(
    10, 12, 8, 18, 15, 9, 20, 14,
    13, 18, 16, 9, 20, 15,
    25, 22, 18, 10, 16, 24
  )
)

marco_humedales

# 09.1 Muestreo aleatorio simple ----------------------------------------------

set.seed(20260912)

indicador_srs <- sampling::srswor(
  n = 10,
  N = nrow(marco_humedales)
)

muestra_srs <- marco_humedales[indicador_srs == 1, ] %>%
  mutate(
    prob_inclusion = 10 / nrow(marco_humedales),
    diseno = "aleatorio_simple"
  )

muestra_srs

# Revise qué estratos quedaron representados por azar.
muestra_srs %>%
  count(
    estrato_id,
    habitat,
    name = "sitios"
  )


# 09.2 Muestreo estratificado -------------------------------------------------

# Garantizamos representación mínima de los tres tipos de hábitat.
# El vector size corresponde a los estratos 1, 2 y 3.

marco_ordenado <- marco_humedales %>%
  arrange(
    estrato_id,
    site_id
  )

set.seed(20260912)

seleccion_estratificada <- sampling::strata(
  data = marco_ordenado,
  stratanames = "estrato_id",
  size = c(4, 3, 3),
  method = "srswor"
)

muestra_estratificada <- sampling::getdata(
  marco_ordenado,
  seleccion_estratificada
) %>%
  mutate(
    diseno = "estratificado"
  )

muestra_estratificada

muestra_estratificada %>%
  count(
    estrato_id,
    habitat,
    name = "sitios"
  )

# Pregunta:
# ¿Cuál de los dos diseños representa mejor el gradiente ambiental propuesto?
# La respuesta depende de la pregunta inferencial y del marco de muestreo.


# 10. Caso integrador: Bd, 20 humedales y 150 hisopos -------------------------

# Tres formas de distribuir el mismo esfuerzo total.
# Mismo número de hisopos no significa la misma inferencia regional.

disenos_bd <- tribble(
  ~diseno, ~sitios, ~individuos_por_sitio,
  "A", 5, 30,
  "B", 10, 15,
  "C", 15, 10
) %>%
  mutate(
    total_hisopos = sitios * individuos_por_sitio,
    cobertura_sitios = sitios / 20,
    p_efectiva_individuo = 0.10 * 0.70,
    prob_detectar_en_un_sitio =
      1 - (1 - p_efectiva_individuo)^individuos_por_sitio,
    prob_detectar_total_iid =
      1 - (1 - p_efectiva_individuo)^total_hisopos
  )

disenos_bd

# Bajo el supuesto simplificador IID, los tres diseños tienen el mismo número
# total de hisopos y una probabilidad total de detección muy similar.
# Sin embargo, NO tienen la misma replicación espacial ni la misma capacidad
# para describir heterogeneidad entre humedales.
#
# Preguntas para defender el diseño:
# 1. ¿La unidad primaria es el humedal o el individuo?
# 2. ¿Se busca presencia regional o prevalencia dentro de sitio?
# 3. ¿Qué variación espacial debe quedar representada?
# 4. ¿Qué se pierde al concentrar 150 hisopos en pocos sitios?


# 11. Visualizar cómo cambian los requerimientos -------------------------------

fig_escenarios <- escenarios_resultados %>%
  mutate(
    sensibilidad = factor(
      sensibilidad,
      levels = c(1.00, 0.90, 0.70),
      labels = c("Se = 1.00", "Se = 0.90", "Se = 0.70")
    )
  ) %>%
  ggplot(
    aes(
      x = prevalencia_diseno,
      y = n_minimo_binomial,
      group = sensibilidad,
      linetype = sensibilidad
    )
  ) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.8) +
  scale_x_continuous(
    labels = scales::label_percent()
  ) +
  labs(
    title = "Tamaño de muestra para detección",
    subtitle = "Confianza del 95% bajo distintos supuestos de prevalencia y sensibilidad",
    x = "Prevalencia de diseño",
    y = "n mínimo",
    linetype = "Sensibilidad"
  ) +
  theme_minimal(base_size = 12)

fig_escenarios


# 12. Exportar evidencia -------------------------------------------------------

dir.create(
  here("outputs", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  here("outputs", "figures"),
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  escenarios_resultados,
  here(
    "outputs",
    "tables",
    "m2_escenarios_deteccion.csv"
  )
)

write_csv(
  muestra_srs,
  here(
    "outputs",
    "tables",
    "m2_muestra_aleatoria_simple.csv"
  )
)

write_csv(
  muestra_estratificada,
  here(
    "outputs",
    "tables",
    "m2_muestra_estratificada.csv"
  )
)

write_csv(
  disenos_bd,
  here(
    "outputs",
    "tables",
    "m2_comparacion_diseno_bd.csv"
  )
)

ggsave(
  filename = here(
    "outputs",
    "figures",
    "m2_n_prevalencia_sensibilidad.png"
  ),
  plot = fig_escenarios,
  width = 8,
  height = 5,
  dpi = 300
)

capture.output(
  sessionInfo(),
  file = here(
    "outputs",
    "m2_sessionInfo.txt"
  )
)


# 13. Comprobación -------------------------------------------------------------

cat("\nSCRIPT 02b COMPLETADO\n")
cat("n para p = 10%, Se = 100%, NC = 95%:",
    n_deteccion(0.10, 1.00, 0.95), "\n")
cat("n para p = 10%, Se = 70%, NC = 95%:",
    n_deteccion(0.10, 0.70, 0.95), "\n")
cat("Sitios seleccionados por SRS:", nrow(muestra_srs), "\n")
cat("Sitios seleccionados por estratos:", nrow(muestra_estratificada), "\n")

list.files(
  here("outputs", "tables"),
  pattern = "^m2_"
)


# 14. Preguntas de cierre ------------------------------------------------------

# 1. ¿Por qué "detectar presencia" y "estimar prevalencia" requieren cálculos
#    distintos?
# 2. ¿Qué ocurre con n cuando disminuye la prevalencia mínima detectable?
# 3. ¿Qué ocurre con n cuando la sensibilidad diagnóstica disminuye?
# 4. ¿Por qué un diseño con 150 muestras puede seguir siendo pseudorreplicado?
# 5. ¿Qué ventaja tiene estratificar por hábitat frente a seleccionar sitios por
#    conveniencia?
# 6. ¿Cuál es la unidad independiente en la inferencia regional sobre Bd?
# 7. ¿Qué supuesto de este script sería el primero que cuestionaría en un sistema
#    real de fauna silvestre?


# Referencias conceptuales -----------------------------------------------------
# Foufopoulos, J., Wobeser, G. A., & McCallum, H. (2022).
#   Infectious Disease Ecology and Conservation. Oxford University Press.
# Fosgate, G. T. (2009). Practical sample size calculations for surveillance and
#   diagnostic investigations. Journal of Veterinary Diagnostic Investigation,
#   21, 3–14.
# Mosher, B. A., et al. (2017, 2019). Diseño, detección y modelos de ocupación
#   aplicados a patógenos de anfibios.
#
# Documentación de funciones:
# ?epiR::epi.ssdetect
# ?epiR::epi.prev
# ?presize::prec_prop
# ?sampling::srswor
# ?sampling::strata
# ?pwr::pwr.2p.test

# Fin --------------------------------------------------------------------------
