# Fuentes de datos

Los archivos de esta práctica proceden del material docente compartido para **Ecología de Enfermedades I** y del conjunto epidemiológico utilizado como material de aprendizaje.

## Archivos utilizados

- `surveillance_lab02.csv`: subconjunto docente derivado de `surveillance_linelist_20141201.csv`. Conserva ejemplos de faltantes, categorías inconsistentes, duplicados, pesos negativos y una anomalía temporal para trabajar auditoría y limpieza.
- `messy_site_coverage.csv`: ejemplo de tabla deliberadamente desordenada, derivado de `messy_data_examples.xlsx`.
- `tidy_site_coverage.csv`: versión ordenada del mismo ejemplo para comparación.
- `linelist_datadict_es.csv`: diccionario de variables en español del material fuente.

El subconjunto se utiliza para que la demostración sea ágil y reproducible durante la sesión. Los datos crudos incluidos en `data/raw/` no deben modificarse manualmente; toda transformación debe realizarse mediante código.

Las versiones CSV se incluyen para facilitar la clonación y mantener el repositorio liviano.
