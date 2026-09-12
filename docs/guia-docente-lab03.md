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

## Secuencia sugerida (110 min)

| Tiempo | Actividad |
|---:|---|
| 10 min | `Git Pull` y revisión de la estructura del repositorio |
| 15 min | Concepto M–C–R y derivación manual de Lincoln–Petersen |
| 15 min | Corrección de Chapman y comparación con LP |
| 15 min | Varianza, error estándar e intervalo de confianza |
| 25 min | Construcción paso a paso de `estimador_lp()` |
| 15 min | Validación de la función con varios escenarios |
| 10 min | Sensibilidad al número de recapturas |
| 5 min | Supuestos, interpretación y cierre |

## Mensaje pedagógico central

La sesión no busca únicamente obtener un número. La competencia clave es comprender que una estimación de abundancia es válida solamente cuando el cálculo y los supuestos ecológicos son coherentes.

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
