# Acerca de -------------------------------------------------------------------------

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

# 00. Preparación --------------------------------------------------------------
# IMPORTANTE:
# Abra siempre "ecologia-enfermedades-i.Rproj".
# No utilice setwd(): el proyecto usa rutas relativas con here().
#
# El script maestro instala/actualiza y carga las dependencias del curso.

source(here::here("scripts", "00_library.R"))


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

# P(no detectar) = (1 - p)^n
# Fórmula de probabilidad: representa la chance de que,
# al realizar "n" pruebas independientes con probabilidad de detección "p",
# ninguna de ellas detecte la enfermedad (es decir, todas fallen).

# n = ln(1 - NC) / ln(1 - p)
# Fórmula para calcular el tamaño de muestra necesario (n):
# NC = nivel de confianza deseado (probabilidad de detectar al menos un positivo)
# p  = prevalencia o probabilidad de detección en una sola prueba
# El resultado indica cuántas muestras se requieren para alcanzar la confianza NC
# de detectar la enfermedad, bajo el supuesto de independencia entre pruebas.

prev_diseno <- 0.10 # Prevalencia o probabilidad de detección
confianza <- 0.95 # Nivel de Confianza deseado

n_manual <- ceiling(
  log(1 - confianza) /log(1 - prev_diseno)
)

n_manual
# Resultado esperado: 29 individuos.


# 02.1 Definimos una tamaño de muestra hipotético -----------------------------

n_hipotetico <- 10

# Calculamos la probabilidad de NO detectar la enfermedad
# (1 - prev_diseno) es la probabilidad de que una sola muestra salga negativa
# Elevado a n_hipotetico = probabilidad de que todas las muestras sean negativas
prob_no_detectar <- (1 - prev_diseno)^n_hipotetico

# Calculamos la probabilidad de detectar al menos un positivo
# Es el complemento de la probabilidad de no detectar
prob_detectar <- 1 - prob_no_detectar

# Mostramos resultados
prob_no_detectar   # Probabilidad de que ninguna muestra detecte la enfermedad
prob_detectar      # Probabilidad de que al menos una muestra detecte la enfermedad

# 03. Función reusable: prevalencia + sensibilidad -----------------------------

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

n_deteccion(0.10, 1.00, 0.95) # 29
n_deteccion(0.10, 0.70, 0.95) # 42


# 04. Explorar múltiples escenarios -------------------------------------------

escenarios_resultados <- escenarios %>%
  mutate(
    p_efectiva = prevalencia_diseno * sensibilidad,
    n_minimo_binomial = n_deteccion(
      prev = prevalencia_diseno,
      sensibilidad = sensibilidad,
      confianza = confianza
    ),
    prob_no_detectar_si_n10 = (1 - p_efectiva)^10,
    prob_detectar_si_n10 = 1 - prob_no_detectar_si_n10
  ) %>%
  arrange(
    prevalencia_diseno,
    desc(sensibilidad)
  )

escenarios_resultados


# 05. Verificación con epiR -----------------------------------------------

# Parámetros:
# pstar = prevalencia mínima de diseño
# se    = sensibilidad de la prueba
# sp    = especificidad de la prueba
# ss.se = probabilidad de detección deseada (Nivel de Confianza)

pstar <- 0.10 # prevalencia mínima de diseño
se    <- 0.70 # sensibilidad de la prueba
sp    <- 1.00 # especificidad de la prueba
NC    <- 0.95 # nivel de confianza deseado


# A) Primero hacemos visible el razonamiento ------------------------------

# Aproximación binomial:
# probabilidad efectiva de detectar una unidad positiva = pstar * se

n <- ceiling(
  log(1 - NC) / log(1 - pstar * se)
)

n

# Resultado:
# 42


# B) Verificación con epiR: aproximación binomial -------------------------

# Al utilizar N = NA, epi.ssdetect() trabaja sin incorporar
# un tamaño poblacional finito conocido.

epi_binomial <- epiR::epi.ssdetect(
  N = NA,                    # población infinita
  pstar = pstar,             # prevalencia mínima de diseño
  se = se,                   # sensibilidad de la prueba
  sp = sp,                   # especificidad de la prueba
  interpretation = "series", # interpretación de los resultados
  covar = c(0, 0),           # covarianza entre sensibilidad y especificidad
  nfractional = FALSE,       # si se permite un tamaño de muestra fraccionario
  ss.se = NC                 # probabilidad de detección deseada (Nivel de Confianza)
)

epi_binomial

# Tamaño de muestra:
epi_binomial$sample.size


# C) Verificación con epiR: población finita ------------------------------

# Ahora indicamos que la población está formada por 1000 individuos.
# epi.ssdetect() incorpora este tamaño poblacional en el cálculo.

epi_finita <- epiR::epi.ssdetect(
  N = 100,                   # tamaño poblacional finito
  pstar = pstar,             # prevalencia mínima de diseño
  se = se,                   # sensibilidad de la prueba
  sp = sp,                   # especificidad de la prueba
  interpretation = "series", # interpretación de los resultados
  covar = c(0, 0),           # covarianza entre sensibilidad y especificidad
  nfractional = FALSE,       # si se permite un tamaño de muestra fraccionario
  ss.se = NC                 # probabilidad de detección deseada (Nivel de Confianza
)

epi_finita

# Tamaño de muestra:
epi_finita$sample.size

# Interpretación --------------------------------------------------------

# N = NA:
# Se asume una población suficientemente grande o no especificada.
# El cálculo se aproxima mediante el modelo binomial y, con pstar = 0.10,
# Se = 0.70 y una probabilidad de detección deseada de 0.95,
# se requieren aproximadamente 42 individuos.

# N = 100:
# Aquí sí se conoce el tamaño total de la población.
# Al muestrear sin reemplazo una fracción importante de esos 100 individuos,
# cada unidad adicional aporta relativamente más información.
# Por ello, al incorporar la corrección por población finita,
# el tamaño de muestra requerido disminuye respecto al caso N = NA.

# Idea clave:
# N = NA  -> población grande/no especificada -> aproximación binomial.
# N = 100 -> población finita conocida        -> menor n requerido.
 
# En términos prácticos:
# cuando N = NA, calculamos cuántas muestras necesitamos como si la población
# fuera muy grande. Cuando N = 100, sabemos que sólo existen 100 unidades y,
# conforme muestreamos una proporción considerable de ellas, disminuye la
# incertidumbre más rápidamente. Por eso el tamaño de muestra necesario puede
# ser menor.

# 06. Estimar prevalencia: precisión deseada ----------------------------------

# presize::prec_prop() utiliza el ANCHO COMPLETO del intervalo de confianza.
# Un margen de error de ±5 puntos porcentuales equivale a un ancho de 0.10.

prev_esperada <- 0.10 # Prevalencia esperada
margen_error <- 0.05  # Margen de error deseado (±5 puntos porcentuales)
ancho_ic <- 2 * margen_error # Ancho total del intervalo de confianza

precision_prev <- presize::prec_prop(
  p = prev_esperada,
  conf.width = ancho_ic,
  conf.level = 0.95,
  method = "wilson"
)

precision_prev

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

# Interpretación ----------------------------------------------------------

# El objetivo ahora no es detectar al menos un positivo, sino estimar una
# prevalencia con una precisión previamente definida.

# Con un IC del 95% y un ancho total deseado de 0.10 (±5 puntos porcentuales):

# p = 0.05 -> n ≈ 82.92  -> se requieren 83 individuos.
# p = 0.10 -> n ≈ 140.97 -> se requieren 141 individuos.
# p = 0.20 -> n ≈ 244.15 -> se requieren 245 individuos.

# A medida que la prevalencia esperada aumenta hacia 0.50, también aumenta
# la variabilidad de una proporción y, por tanto, se necesita una muestra
# mayor para mantener la misma precisión absoluta.

# Idea clave:
# detectar presencia y estimar prevalencia responden preguntas diferentes.
# Para estimar prevalencia, n depende de la prevalencia esperada,
# el nivel de confianza y la precisión deseada.

# 07. Prevalencia aparente y prevalencia ajustada ------------------------------

positivos <- 18
examinados <- 100
Se <- 0.90
Sp <- 0.95

prev_aparente <- positivos / examinados

prev_ajustada_manual <-
  (prev_aparente + Sp - 1) /
  (Se + Sp - 1)

prev_aparente
prev_ajustada_manual

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

# Interpretación ----------------------------------------------------------

# La prevalencia aparente corresponde directamente a los resultados observados:
# 18 positivos de 100 individuos -> 18%.

# Al considerar que la prueba no es perfecta (Se = 0.90; Sp = 0.95),
# epi.prev() ajusta la estimación por errores de clasificación.

# Prevalencia aparente:
# 18.0% (IC 95%: 11.7% - 26.7%)

# Prevalencia verdadera ajustada:
# 15.3% (IC 95%: 7.9% - 25.5%)

# En este ejemplo, la prevalencia ajustada es menor que la aparente porque
# parte de los resultados positivos pueden corresponder a falsos positivos
# debido a que la especificidad es menor que 1.

# epi.prev() estima aproximadamente:
# 14 verdaderos positivos,
# 4 falsos positivos,
# 81 verdaderos negativos y
# 1 falso negativo.

# Idea clave:
# prevalencia aparente = proporción observada de pruebas positivas.
# prevalencia verdadera = estimación corregida por sensibilidad y especificidad

# NOTA: aquí conviene remarcar algo importante: los 18 positivos son observados,
# mientras que los valores de true.positive, false.positive, etc., son
# estimaciones derivadas del desempeño diagnóstico de la prueba, 
# no individuos cuya condición verdadera hayamos confirmado directamente.

# 08. Comparar dos grupos: tamaño de muestra y potencia ------------------------

p1 <- 0.10
p2 <- 0.20

h <- pwr::ES.h(
  p1 = p1, # proporción del grupo 1
  p2 = p2  # proporción del grupo 2
)

# El tamaño del efecto (h de Cohen) se calcula como:
# h = 2*asin(sqrt(p1)) - 2*asin(sqrt(p2))
#
# Esta transformación expresa la diferencia entre ambas proporciones
# en una escala estandarizada que utiliza pwr::pwr.2p.test().

# # IMPORTANTE:
# pwr::ES.h() no utiliza directamente la diferencia p1 - p2.
# Primero transforma ambas proporciones mediante la función arcoseno-raíz.
#
# h = 2*asin(sqrt(p1)) - 2*asin(sqrt(p2))
#
# El resultado h representa el tamaño del efecto utilizado para
# calcular la potencia y el tamaño de muestra al comparar dos proporciones.

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

# Interpretación ----------------------------------------------------------

# El objetivo ahora es comparar dos proporciones entre grupos independientes:
# Grupo 1: p1 = 0.10 (10%)
# Grupo 2: p2 = 0.20 (20%)

# La diferencia que queremos ser capaces de detectar es de 10 puntos
# porcentuales (0.20 - 0.10 = 0.10).

# pwr::ES.h() transforma esta diferencia en un tamaño de efecto:
# h ≈ -0.284.

# Con una prueba bilateral, un nivel de significancia de 0.05
# y una potencia estadística de 0.80, se requieren:

# n ≈ 194.91 individuos por grupo
# -> redondeando hacia arriba: 195 individuos por grupo.

# Tamaño de muestra total:
# 195 + 195 = 390 individuos.

# Interpretación:
# Si las prevalencias reales fueran 10% y 20%, respectivamente,
# un estudio con 195 individuos por grupo tendría aproximadamente
# 80% de probabilidad de detectar estadísticamente esa diferencia,
# utilizando un alfa de α= 0.05 y una prueba bilateral.

# Idea clave:
# al comparar grupos, el tamaño de muestra depende de la magnitud
# de la diferencia que queremos detectar, del nivel de significancia
# y de la potencia estadística deseada.

# Detectar presencia  -> probabilidad de detección.
# Estimar prevalencia -> precisión del intervalo de confianza.
# Comparar grupos     -> potencia para detectar una diferencia.

# 09. "¿Cuántas?" no responde "¿cuáles?" --------------------------------------

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
  # simple random sampling without replacement
  n = 10, # número de sitios a seleccionar
  N = nrow(marco_humedales) # número total de sitios en el marco muestral
)

muestra_srs <- marco_humedales[indicador_srs == 1, ] %>%
  mutate(
    prob_inclusion = 10 / nrow(marco_humedales),
    diseno = "aleatorio_simple"
  )

muestra_srs

muestra_srs %>%
  count(
    estrato_id,
    habitat,
    name = "sitios"
  )

# Interpretación ----------------------------------------------------------

# El marco muestral contiene 20 humedales distribuidos en tres estratos:
# 8 sitios de bosque nublado,
# 6 sitios de pino-encino y
# 6 sitios de humedal abierto.

# Se seleccionaron 10 sitios mediante muestreo aleatorio simple sin reemplazo
# (SRSWOR). Por tanto, cada sitio tuvo la misma probabilidad de inclusión:

# probabilidad de inclusión = n / N = 10 / 20 = 0.50

# La muestra obtenida contiene:
# 5 sitios de bosque nublado,
# 3 sitios de pino-encino y
# 2 sitios de humedal abierto.

# Esta distribución NO fue impuesta por el diseño.
# Es simplemente el resultado particular de una selección aleatoria simple.

# Aunque el marco contiene información sobre hábitat, accesibilidad y
# capacidad de muestreo, ninguna de estas variables influyó en la selección:
# todos los sitios tuvieron la misma probabilidad de ser elegidos.

# Idea clave:
# en un muestreo aleatorio simple, la selección es probabilística y equitativa,
# pero no garantiza que cada hábitat quede representado proporcionalmente
# en una muestra concreta.

# 09.2 Muestreo estratificado -------------------------------------------------

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

# Interpretación ----------------------------------------------------------

# La población se dividió previamente en tres estratos definidos por hábitat:
# Estrato 1: bosque nublado   -> 8 sitios
# Estrato 2: pino-encino      -> 6 sitios
# Estrato 3: humedal abierto  -> 6 sitios

# Se seleccionaron 10 sitios mediante muestreo aleatorio estratificado
# sin reemplazo, asignando:
# 4 sitios al bosque nublado,
# 3 sitios al pino-encino y
# 3 sitios al humedal abierto.

# Esta asignación es proporcional al tamaño de cada estrato:
# 8/20 = 40% -> 4 de 10
# 6/20 = 30% -> 3 de 10
# 6/20 = 30% -> 3 de 10

# Dentro de cada estrato, los sitios fueron seleccionados aleatoriamente
# mediante muestreo aleatorio simple sin reemplazo.

# La probabilidad de inclusión es la misma en los tres estratos:
# Estrato 1: 4/8 = 0.50
# Estrato 2: 3/6 = 0.50
# Estrato 3: 3/6 = 0.50

# Por tanto, todos los sitios del marco tuvieron una probabilidad
# de inclusión de 0.50.

# A diferencia del muestreo aleatorio simple global, aquí la representación
# de los tres hábitats está controlada por el diseño y no depende únicamente
# del resultado aleatorio de una muestra particular.

# Idea clave:
# el muestreo estratificado garantiza representación de cada estrato
# y mantiene la selección aleatoria dentro de ellos.

# 10. Caso integrador: Bd, 20 humedales y 150 hisopos -------------------------

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
  here("outputs", "tables", "m2_escenarios_deteccion.csv")
)

write_csv(
  muestra_srs,
  here("outputs", "tables", "m2_muestra_aleatoria_simple.csv")
)

write_csv(
  muestra_estratificada,
  here("outputs", "tables", "m2_muestra_estratificada.csv")
)

write_csv(
  disenos_bd,
  here("outputs", "tables", "m2_comparacion_diseno_bd.csv")
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
  file = here("outputs", "m2_sessionInfo.txt")
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
#
# Documentación de funciones:
# ??epiR::epi.ssdetect
# ??epiR::epi.prev
# ??presize::prec_prop
# ??sampling::srswor
# ??sampling::strata
# ??pwr::Es.h
# ??pwr::pwr.2p.test

# Fin --------------------------------------------------------------------------
