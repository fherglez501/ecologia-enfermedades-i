# ==============================================================================
# ESCUELA SUPERIOR DE MEDICINA VETERINARIA Y ZOOTECNIA
# Licenciatura en Administracion de la Fauna Silvestre
# Ecologia de Enfermedades I
#
# Laboratorio 3: Programacion del estimador Lincoln-Petersen
# Fecha: 2026-09-14
# Docente: MVZ, MSc. Jose Fernando Aguilera Gonzalez
#
# Objetivo:
# Programar y validar estimaciones de abundancia para poblaciones cerradas.
#
# Evidencia:
# Laboratorio 3: estimador y validacion.
# ==============================================================================


# 00. Preparacion --------------------------------------------------------------
# IMPORTANTE:
# Abra siempre "ecologia-enfermedades-i.Rproj".
# No utilice setwd(): el proyecto usa rutas relativas con here().
#
# El script maestro instala/actualiza y carga las dependencias del curso.

source(here::here("scripts", "00_library.R"))


# 01. Cargar escenarios --------------------------------------------------------

ruta_datos <- here(
  "data", "raw",
  "escenarios_captura_recaptura_lab03.csv"
)

if (!file.exists(ruta_datos)) {
  stop("No se encontro el archivo de datos del Laboratorio 3.")
}

escenarios <- read_csv(
  ruta_datos,
  show_col_types = FALSE
)

escenarios


# 02. Recordatorio biologico ---------------------------------------------------

# En un esquema simple de dos ocasiones:
#
# M = numero de individuos marcados y liberados en la primera ocasion
# C = numero total de individuos capturados en la segunda ocasion
# R = numero de individuos marcados que fueron recapturados
#
# Idea central:
# La proporcion de marcados en la segunda muestra se usa como aproximacion de
# la proporcion de marcados en toda la poblacion.
#
# M / N  ≈  R / C
#
# Despejando N:
# N_hat = (M * C) / R


# 03. Calculo manual: Lincoln-Petersen ----------------------------------------

# Utilizamos el escenario A.
M <- escenarios$m_marcados_1[1]
C <- escenarios$c_capturados_2[1]
R <- escenarios$r_recapturados[1]

M
C
R

N_lp_manual <- (M * C) / R
N_lp_manual

# INTERPRETACION:
# Este valor es una estimacion del numero de individuos presentes en la
# poblacion bajo los supuestos del modelo.


# 04. Correccion de Chapman ----------------------------------------------------

# El estimador Lincoln-Petersen puede presentar sesgo cuando el numero de
# recapturas es pequeno. Una correccion frecuente es el estimador de Chapman:
#
# N_chapman = ((M + 1) * (C + 1) / (R + 1)) - 1

N_chapman_manual <- ((M + 1) * (C + 1) / (R + 1)) - 1
N_chapman_manual

# Compare ambos estimadores.
N_lp_manual
N_chapman_manual


# 05. Varianza e intervalo de confianza aproximado ----------------------------

# Varianza aproximada del estimador de Chapman:
#
# Var(N) = ((M+1)(C+1)(M-R)(C-R)) / ((R+1)^2 (R+2))

var_chapman_manual <- (
  (M + 1) * (C + 1) * (M - R) * (C - R)
) / (
  ((R + 1)^2) * (R + 2)
)

se_chapman_manual <- sqrt(var_chapman_manual)

# Intervalo normal aproximado del 95 %
z_95 <- qnorm(0.975)

ic_inf_manual <- max(
  0,
  N_chapman_manual - z_95 * se_chapman_manual
)

ic_sup_manual <- N_chapman_manual + z_95 * se_chapman_manual

c(
  estimacion = N_chapman_manual,
  error_estandar = se_chapman_manual,
  IC95_inf = ic_inf_manual,
  IC95_sup = ic_sup_manual
)


# 06. Construir una funcion parametrizada -------------------------------------

estimador_lp <- function(M, C, R, conf_level = 0.95) {

  # Validaciones de entrada ----------------------------------------------------
  if (any(is.na(c(M, C, R)))) {
    stop("M, C y R no pueden contener NA.")
  }

  if (any(c(M, C, R) < 0)) {
    stop("M, C y R deben ser valores no negativos.")
  }

  if (M == 0 || C == 0) {
    stop("M y C deben ser mayores que cero.")
  }

  if (R == 0) {
    stop(
      paste0(
        "R = 0: el estimador Lincoln-Petersen no es calculable. ",
        "La ausencia de recapturas implica informacion insuficiente bajo este modelo."
      )
    )
  }

  if (R > min(M, C)) {
    stop("R no puede ser mayor que M ni que C.")
  }

  if (conf_level <= 0 || conf_level >= 1) {
    stop("conf_level debe estar entre 0 y 1.")
  }

  # Estimadores ---------------------------------------------------------------
  N_lp <- (M * C) / R

  N_chapman <- ((M + 1) * (C + 1) / (R + 1)) - 1

  # Incertidumbre -------------------------------------------------------------
  var_chapman <- (
    (M + 1) * (C + 1) * (M - R) * (C - R)
  ) / (
    ((R + 1)^2) * (R + 2)
  )

  se_chapman <- sqrt(var_chapman)

  alpha <- 1 - conf_level
  z <- qnorm(1 - alpha / 2)

  ic_inf <- max(0, N_chapman - z * se_chapman)
  ic_sup <- N_chapman + z * se_chapman

  tibble(
    M = M,
    C = C,
    R = R,
    N_LP = N_lp,
    N_Chapman = N_chapman,
    var_Chapman = var_chapman,
    SE_Chapman = se_chapman,
    IC_inf = ic_inf,
    IC_sup = ic_sup,
    conf_level = conf_level
  )
}


# 07. Validar la funcion con el calculo manual --------------------------------

resultado_A <- estimador_lp(
  M = M,
  C = C,
  R = R
)

resultado_A

# La salida debe coincidir con los calculos realizados manualmente.
stopifnot(
  isTRUE(all.equal(resultado_A$N_LP, N_lp_manual)),
  isTRUE(all.equal(resultado_A$N_Chapman, N_chapman_manual))
)

cat("\nValidacion correcta: funcion y calculo manual coinciden.\n")


# 08. Aplicar la funcion a varios escenarios ----------------------------------

resultados <- pmap_dfr(
  escenarios,
  function(escenario, sitio, m_marcados_1, c_capturados_2, r_recapturados) {

    estimador_lp(
      M = m_marcados_1,
      C = c_capturados_2,
      R = r_recapturados
    ) %>%
      mutate(
        escenario = escenario,
        sitio = sitio,
        .before = 1
      )
  }
)

resultados


# 09. Comparar Lincoln-Petersen y Chapman -------------------------------------

comparacion <- resultados %>%
  select(
    escenario,
    sitio,
    M,
    C,
    R,
    N_LP,
    N_Chapman,
    IC_inf,
    IC_sup
  ) %>%
  mutate(
    diferencia = N_LP - N_Chapman,
    amplitud_IC = IC_sup - IC_inf
  )

comparacion


# 10. Visualizacion de estimaciones e incertidumbre ---------------------------

grafico_estimaciones <- comparacion %>%
  ggplot(
    aes(
      x = reorder(sitio, N_Chapman),
      y = N_Chapman
    )
  ) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = IC_inf, ymax = IC_sup),
    width = 0.15
  ) +
  coord_flip() +
  labs(
    title = "Estimacion de abundancia por captura-recaptura",
    subtitle = "Estimador de Chapman e IC normal aproximado del 95 %",
    x = NULL,
    y = "Abundancia estimada"
  ) +
  theme_minimal(base_size = 12)

grafico_estimaciones


# 11. Sensibilidad al numero de recapturas ------------------------------------

sensibilidad <- tibble(
  M = 50,
  C = 60,
  R = 3:30
) %>%
  mutate(
    N_LP = (M * C) / R,
    N_Chapman = ((M + 1) * (C + 1) / (R + 1)) - 1
  )

sensibilidad

sensibilidad %>%
  ggplot(aes(x = R, y = N_Chapman)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Sensibilidad de la estimacion al numero de recapturas",
    subtitle = "M = 50; C = 60",
    x = "Individuos recapturados (R)",
    y = "N estimado (Chapman)"
  ) +
  theme_minimal(base_size = 12)


# 12. Supuestos del modelo -----------------------------------------------------

supuestos <- tribble(
  ~supuesto, ~pregunta_de_control,
  "Poblacion cerrada", "¿Hubo nacimientos, muertes, inmigracion o emigracion entre ocasiones?",
  "Marcas retenidas y reconocibles", "¿Se perdieron marcas o hubo errores de identificacion?",
  "Marcaje no altera al individuo", "¿La marca cambio supervivencia, conducta o capturabilidad?",
  "Mezcla entre ocasiones", "¿Los individuos marcados pudieron reincorporarse a la poblacion?",
  "Capturabilidad compatible con el modelo", "¿Marcados y no marcados tuvieron oportunidades comparables de captura?"
)

supuestos


# 13. Mini-casos de diagnostico ------------------------------------------------

# estimador_lp(M = 50, C = 60, R = 0)
# estimador_lp(M = 20, C = 15, R = 18)


# 14. Actividad del estudiante -------------------------------------------------

# ACTIVIDAD A
# Seleccione uno de los escenarios B, C o D y explique:
# 1. N estimado por Lincoln-Petersen.
# 2. N estimado por Chapman.
# 3. Intervalo de confianza.
# 4. Que tan precisa parece la estimacion.
# 5. Que supuesto seria mas vulnerable en un estudio real de fauna silvestre.

# ACTIVIDAD B
# Cree un escenario propio modificando M, C y R.
# mi_resultado <- estimador_lp(M = 70, C = 65, R = 18)

# ACTIVIDAD C
# Mantenga M y C constantes y reduzca R a la mitad.
# Compare el nuevo valor de N y la amplitud del intervalo de confianza.


# 15. Exportar evidencia -------------------------------------------------------

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
  comparacion,
  here("outputs", "tables", "lab03_estimaciones.csv")
)

write_csv(
  supuestos,
  here("outputs", "tables", "lab03_supuestos.csv")
)

ggsave(
  filename = here("outputs", "figures", "lab03_estimaciones.png"),
  plot = grafico_estimaciones,
  width = 8,
  height = 5,
  dpi = 300
)

capture.output(
  sessionInfo(),
  file = here("outputs", "lab03_sessionInfo.txt")
)


# 16. Cierre ------------------------------------------------------------------

cat("\n--- LABORATORIO 3 COMPLETADO ---\n")
cat("Se generaron estimaciones, IC, tabla de supuestos y figura.\n\n")

# Preguntas de cierre:
# 1. ¿Que representa biologicamente R?
# 2. ¿Por que N aumenta cuando R disminuye?
# 3. ¿Que problema intenta reducir la correccion de Chapman?
# 4. ¿Que significa un intervalo de confianza muy amplio?
# 5. ¿Que ocurre si se viola el supuesto de poblacion cerrada?
# 6. ¿Por que una estimacion numericamente correcta puede ser biologicamente invalida?

# Fin -------------------------------------------------------------------------
