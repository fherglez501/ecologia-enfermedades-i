# Funcion del Laboratorio 3. Solo requiere R base.
# M = n1, C = n2, R = m2 en Mills (2013), pp. 61-62, ecuaciones 4.7-4.10.
# Ejecute la practica completa desde ecologia-enfermedades-i.Rproj.

estimador_lp <- function(M, C, R, conf_level = 0.95) {
  conteos <- list(M = M, C = C, R = R)
  valido <- vapply(conteos, function(x) {
    is.numeric(x) && !is.complex(x) && length(x) == 1L &&
      is.finite(x) && x == floor(x)
  }, logical(1))
  if (!all(valido)) {
    stop("M, C y R deben ser numeros escalares, enteros y finitos.")
  }
  if (M <= 0 || C <= 0 || R < 0 || R > min(M, C)) {
    stop("Conteos incompatibles: M y C > 0; 0 <= R <= min(M, C).")
  }
  nivel_valido <- is.numeric(conf_level) && !is.complex(conf_level) &&
    length(conf_level) == 1L && is.finite(conf_level) &&
    conf_level > 0 && conf_level < 1
  if (!nivel_valido) stop("conf_level debe ser un numero finito entre 0 y 1.")
  if (R == 0) {
    stop(paste("Sin recapturas: LP no esta definido.",
      "Chapman es finito, pero esta funcion no informa un IC normal",
      "sin traslape observado. Revise esfuerzo, marcas y supuestos."))
  }

  # Conversion a double para evitar desbordamiento de enteros de R.
  M <- as.double(M); C <- as.double(C); R <- as.double(R)
  U <- M + C - R                  # individuos diferentes observados
  N_lp <- M * C / R
  N_chapman <- (M + 1) * (C + 1) / (R + 1) - 1
  var_chapman <- (M + 1) * (C + 1) * (M - R) * (C - R) /
    ((R + 1)^2 * (R + 2))
  if (!all(is.finite(c(U, N_lp, N_chapman, var_chapman)))) {
    stop("El calculo excede el rango numerico. Revise los conteos.")
  }
  se_chapman <- sqrt(var_chapman)
  z <- qnorm((1 - conf_level) / 2, lower.tail = FALSE)
  ic_inf <- N_chapman - z * se_chapman
  ic_sup <- N_chapman + z * se_chapman

  # Se conserva el IC calculado. Recortarlo no repara su cobertura.
  alertas <- character(0)
  if (R < 10) alertas <- c(alertas, "Pocas recapturas: revisar el IC normal")
  if (ic_inf < U) alertas <- c(alertas, "IC inferior al minimo observado U")
  if (var_chapman == 0) alertas <- c(alertas, "Varianza nula: caso de frontera")
  # R < 10 es una alerta didactica, no un umbral universal de validez.
  # La ausencia de alertas tampoco demuestra cobertura ni valida el diseno.
  if (length(alertas)) warning(paste(alertas, collapse = "; "), call. = FALSE)

  data.frame(
    M = M, C = C, R = R, U = U,
    N_LP = N_lp, N_Chapman = N_chapman,
    var_Chapman = var_chapman, SE_Chapman = se_chapman,
    IC_inf = ic_inf, IC_sup = ic_sup, conf_level = conf_level,
    alerta = if (length(alertas)) paste(alertas, collapse = "; ") else "",
    stringsAsFactors = FALSE
  )
}
