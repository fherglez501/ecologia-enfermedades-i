# ==============================================================================
# Ecología de Enfermedades I
# 00_library.R — Gestión centralizada de paquetes
#
# Propósito:
# - mantener en un solo archivo las dependencias R utilizadas por el curso;
# - instalar/actualizar paquetes y sus dependencias mediante pak;
# - cargar los paquetes mediante pacman;
# - simplificar el encabezado de los scripts posteriores.
#
# IMPORTANTE:
# Este archivo debe actualizarse cuando una práctica incorpore un paquete nuevo.
# ==============================================================================


# 00. Gestores de paquetes -----------------------------------------------------

# pak resuelve e instala dependencias de forma rápida y consistente.
# pacman simplifica la carga conjunta de paquetes.

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}


# 01. Paquetes utilizados en el curso -----------------------------------------

paquetes <- c(
  "here",       # rutas reproducibles dentro del proyecto
  "tidyverse",  # manipulación, visualización e importación de datos
  "janitor",    # limpieza y estandarización de nombres/tablas
  "lubridate",  # manejo de fechas
  "epiR",       # epidemiología veterinaria y tamaño de muestra
  "presize",    # tamaño de muestra basado en precisión
  "sampling",   # muestreo probabilístico
  "pwr",        # potencia y tamaño de muestra
  "scales"      # escalas y etiquetas para gráficos
)


# 02. Instalar o actualizar ----------------------------------------------------

# upgrade = TRUE solicita a pak mantener actualizados tanto los paquetes
# declarados como sus dependencias compatibles.
# Si todo está actualizado, pak no reinstala innecesariamente.

pak::pak(
  paquetes,
  upgrade = TRUE,
  ask = FALSE
)


# 03. Cargar paquetes ----------------------------------------------------------

pacman::p_load(
  char = paquetes
)


# 04. Comprobación -------------------------------------------------------------

cat(
  "\nPaquetes del curso instalados y cargados correctamente.\n",
  "Raíz del proyecto: ", here::here(), "\n",
  "Paquetes declarados: ", length(paquetes), "\n\n",
  sep = ""
)

# Fin --------------------------------------------------------------------------
