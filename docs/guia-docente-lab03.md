# Guía docente — Laboratorio 3

## Sesión

**Fecha:** 14/09/2026  
**Tema:** Programación del estimador Lincoln–Petersen  
**Módulo:** II — Adquisición y Muestreo de Datos de Campo

## Propósito

Programar y validar estimaciones de abundancia para poblaciones cerradas utilizando:

- estimador Lincoln–Petersen;
- corrección de Chapman;
- varianza de Chapman;
- intervalo de confianza normal aproximado;
- validación de una función parametrizada;
- interpretación de los supuestos biológicos del modelo.

## Material de inicio

Antes de abrir el script, proyectar la presentación Quarto:

```text
presentations/lab03/lab03-lincoln-petersen.qmd
```

La presentación introduce la lógica M–C–R, la derivación proporcional, Chapman, incertidumbre, sensibilidad a las recapturas y supuestos ecológicos. El objetivo es que el código aparezca después como formalización de un procedimiento ya comprendido.

## Secuencia sugerida (110 min)

| Tiempo | Actividad |
|---:|---|
| 5 min | `Git Pull`, abrir `.Rproj` y comprobar archivos nuevos |
| 25 min | Presentación Quarto: fundamento de captura–recaptura, M–C–R, LP, Chapman e incertidumbre |
| 15 min | Cálculo manual con el escenario A y contraste LP vs. Chapman |
| 25 min | Construcción paso a paso de `estimador_lp()` |
| 15 min | Validación con varios escenarios e interpretación del intervalo |
| 15 min | Sensibilidad a `R`, supuestos y mecanismos de sesgo |
| 10 min | Exportar evidencia, `sessionInfo()` y pregunta de salida |

## Mensaje pedagógico central

La sesión no busca únicamente obtener un número. La competencia clave es comprender que una estimación de abundancia es válida solamente cuando el cálculo, la incertidumbre y los supuestos ecológicos son coherentes.

## Checkpoints de resultados

### Escenario A

- M = 50
- C = 60
- R = 15
- Lincoln–Petersen = **200.00**
- Chapman = **193.44**
- SE Chapman ≈ **33.55**
- IC95 aproximado ≈ **127.67–259.20**

### Escenario B

- M = 80
- C = 70
- R = 20
- Lincoln–Petersen = **280.00**
- Chapman ≈ **272.86**
- IC95 aproximado ≈ **190.21–355.51**

### Escenario C

- M = 40
- C = 45
- R = 5
- Lincoln–Petersen = **360.00**
- Chapman ≈ **313.33**
- IC95 aproximado ≈ **112.71–513.96**

Este escenario es especialmente útil para mostrar que pocas recapturas producen alta incertidumbre.

### Escenario D

- M = 100
- C = 100
- R = 50
- Lincoln–Petersen = **200.00**
- Chapman ≈ **199.02**
- IC95 aproximado ≈ **172.11–225.93**

## Supuestos a enfatizar

1. **Población cerrada** entre ambas ocasiones de captura.
2. **Las marcas no se pierden** y son reconocidas correctamente.
3. **El marcaje no altera** supervivencia ni comportamiento de captura.
4. Los individuos marcados tienen tiempo suficiente para **mezclarse** nuevamente con la población.
5. La capturabilidad de marcados y no marcados es compatible con el modelo.

## Decisiones metodológicas del script

- Si `R = 0`, la función detiene el cálculo porque Lincoln–Petersen no es calculable.
- Si `R > min(M, C)`, la función identifica un escenario imposible.
- El límite inferior del IC aproximado se trunca en cero porque una abundancia negativa carece de interpretación biológica.
- El IC implementado es una aproximación normal basada en la varianza de Chapman; debe explicarse como una aproximación didáctica, no como un procedimiento universal para todo diseño de captura–recaptura.

## Transición presentación → script

Al finalizar la presentación, evitar repetir toda la teoría. Usar una transición breve:

> Ya definimos qué significan M, C y R y qué supuestos sostienen la inferencia. Ahora convertiremos ese procedimiento en una función que valide las entradas, calcule la estimación y haga explícita su incertidumbre.

Abrir:

```text
scripts/03_lab-lincoln-petersen.R
```

## Evidencia mínima

El estudiante deberá conservar:

1. `scripts/03_lab-lincoln-petersen.R` ejecutado y comentado;
2. `outputs/tables/lab03_estimaciones.csv`;
3. `outputs/tables/lab03_supuestos.csv`;
4. `outputs/figures/lab03_estimaciones.png`;
5. `outputs/lab03_sessionInfo.txt`;
6. respuesta escrita a las preguntas de cierre.

## Pregunta de salida sugerida

> Dos estudios producen la misma estimación de abundancia, pero uno tiene 5 recapturas y el otro 50. ¿Por qué no deberíamos considerar ambas estimaciones igualmente informativas?

## Conexión con la sesión teórica

Este laboratorio da continuidad al diseño de muestreo trabajado el 10/09/2026. Permite mostrar que la estimación de abundancia no depende solo de una fórmula: la calidad de la inferencia depende del diseño de captura, la representatividad, la detectabilidad y el cumplimiento de los supuestos del modelo.
