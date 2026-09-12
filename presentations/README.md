# Presentaciones Quarto — Ecología de Enfermedades I

Esta carpeta contiene las presentaciones teóricas que introducen cada práctica de laboratorio. El objetivo es mantener **teoría, código y datos dentro del mismo proyecto reproducible**.

## Identidad visual

El tema compartido está definido en:

```text
presentations/_assets/theme/esmvz.scss
```

Se construyó a partir de la identidad visual de las presentaciones docentes de Ecología de Enfermedades I:

- formato 16:9;
- tipografía principal `Google Sans`, con fallbacks seguros;
- verde oliva `#5A6E36` como color institucional;
- verde oscuro `#1A3D14` para énfasis conceptual;
- azul científico `#123A5A` para contraste;
- rojo `#8A3D35` para advertencias/comparaciones;
- gris `#5B5B5B` para texto principal;
- fondos blancos con paneles verde, azul y gris muy claros;
- títulos alineados a la izquierda y línea corta verde;
- fuentes y notas en gris/verde atenuado;
- tablas con encabezados alternados verde/azul.

> No se distribuyen archivos de fuentes. Si `Google Sans` no está instalada en un equipo, el tema usa automáticamente Aptos, Segoe UI o Arial.

## Presentaciones

```text
presentations/
├── _assets/
│   └── theme/
│       └── esmvz.scss
├── lab02/
│   └── lab02-procesamiento-tablas.qmd
└── lab03/
    └── lab03-lincoln-petersen.qmd
```

## Renderizar desde RStudio

Abra el proyecto `ecologia-enfermedades-i.Rproj`, después abra el archivo `.qmd` y utilice **Render**.

También puede renderizarse desde una terminal con Quarto:

```bash
quarto render presentations/lab03/lab03-lincoln-petersen.qmd
```

Los archivos renderizados se generan en `_rendered/` y no se versionan en Git.

## Uso durante la práctica

La secuencia recomendada es:

```text
Git Pull
   ↓
Presentación Quarto
   ↓
Fundamento teórico
   ↓
Abrir script R
   ↓
Demostración + ejecución por estudiantes
```

Las presentaciones explican **por qué y qué significa** el método; los scripts muestran **cómo implementarlo y validarlo**.
