# Ejecutar desde la raiz del proyecto: source("tests/test-lab03.R")
# No requiere paquetes externos. Las referencias usan qnorm(0.975).
source(file.path("scripts", "03a_funcion-lincoln-petersen.R"))

iguales <- function(actual, esperado, tol = 1e-7) {
  stopifnot(isTRUE(all.equal(as.numeric(actual), esperado, tolerance = tol)))
}
falla <- function(expr) {
  stopifnot(inherits(tryCatch(force(expr), error = identity), "error"))
}

# Resultados calculados independientemente para los cuatro escenarios sinteticos.
entradas <- rbind(c(50,60,15), c(80,70,20), c(40,45,5), c(100,100,50))
esperados <- rbind(
  c(200, 193.4375, 1125.87890625, 33.5541190653249, 127.672635098994, 259.202364901006),
  c(280, 272.857142857143, 1778.29313543599, 42.1698130827728, 190.205827980122, 355.508457734163),
  c(360, 313.333333333333, 10477.7777777778, 102.361016885227, 112.709426817392, 513.957239849275),
  c(200, 199.019607843137, 188.555437257859, 13.7315489751834, 172.106266399830, 225.932949286445)
)
campos <- c("N_LP", "N_Chapman", "var_Chapman", "SE_Chapman", "IC_inf", "IC_sup")
for (i in seq_len(nrow(entradas))) {
  r <- suppressWarnings(estimador_lp(entradas[i,1], entradas[i,2], entradas[i,3]))
  iguales(unlist(r[campos]), esperados[i,])
  iguales(r$U, sum(entradas[i,1:2]) - entradas[i,3])
}

# Ejemplo publicado: Mills (2013), recuadro 4.4, ballenas de 1991-1992.
ballenas <- estimador_lp(269, 398, 188)
iguales(ballenas$N_Chapman, 569)
iguales(ballenas$var_Chapman, 270)
stopifnot(round(ballenas$IC_inf) == 537, round(ballenas$IC_sup) == 601)

# El IC debe conservar el limite negativo y la alerta, sin recorte silencioso.
avisos <- character(0)
escaso <- withCallingHandlers(estimador_lp(50, 60, 1), warning = function(w) {
  avisos <<- c(avisos, conditionMessage(w))
  invokeRestart("muffleWarning")
})
stopifnot(escaso$IC_inf < 0, escaso$IC_inf < escaso$U,
          grepl("minimo observado", escaso$alerta), length(avisos) > 0)
iguales(escaso$IC_inf, -142.303375195540)
frontera <- suppressWarnings(estimador_lp(10, 10, 10))
stopifnot(frontera$var_Chapman == 0, grepl("frontera", frontera$alerta))

# Un nivel mayor ensancha el IC y no cambia la estimacion puntual.
r90 <- estimador_lp(50, 60, 15, conf_level = 0.90)
r99 <- estimador_lp(50, 60, 15, conf_level = 0.99)
stopifnot(r99$IC_inf < r90$IC_inf, r99$IC_sup > r90$IC_sup)
iguales(r90$N_Chapman, r99$N_Chapman)

# Entradas incompatibles o mal formadas deben provocar error.
for (x in list(NA_real_, NaN, Inf, -Inf, 50.5, "50", numeric(0), c(50,60), TRUE, 50+1i)) {
  falla(estimador_lp(x, 60, 15))
}
falla(estimador_lp(0, 60, 0))
falla(estimador_lp(50, 0, 0))
falla(estimador_lp(50, 60, -1))
falla(estimador_lp(50, 60, 0))
falla(estimador_lp(20, 15, 18))
for (nivel in list(0, 1, NA_real_, Inf, "0.95", c(.9,.95), numeric(0), TRUE)) {
  falla(estimador_lp(50, 60, 15, nivel))
}
cat("Comprobaciones del Laboratorio 3 completadas correctamente.\n")
