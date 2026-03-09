## Autora

Jessica Sánchez Londoño  
Ingeniera Ambiental  
Msc Ingeniería Ambiental

# Priorización espacial para conservación del oso andino

Este repositorio contiene el análisis de priorización espacial realizado para identificar áreas potenciales de conservación del **oso andino (*Tremarctos ornatus*)** y de los **ecosistemas de páramo** en Colombia.
El análisis se implementó en **R** utilizando el paquete `prioritizr`, que permite resolver problemas de planificación sistemática de la conservación mediante optimización espacial.

## Objetivo

Identificar un conjunto de áreas prioritarias que permita representar una proporción mínima de los elementos de conservación considerados, minimizando al mismo tiempo un costo espacial asociado a la huella humana y a un indicador de beneficio.

## Datos utilizados

- Hábitat potencial del oso andino (*Tremarctos ornatus*)
- Huella humana (IHEH 2018)
- Beneficio neto espacial
- Complejos de páramo de Colombia

## Metodología

El análisis se formuló como un problema de **minimum set** usando el paquete `prioritizr`.  
Se definieron **targets de representación relativos** para los elementos de conservación:

- 30 % del hábitat del oso andino  
- 20 % de los ecosistemas de páramo  

El modelo identifica el conjunto mínimo de áreas que cumple estos objetivos de conservación minimizando el costo espacial.

## Resultados

El resultado del análisis es un mapa raster de **áreas prioritarias de conservación**, que representa las celdas seleccionadas por el modelo para cumplir los objetivos de representación definidos.

## Estructura del repositorio

scripts/ → código del análisis
data/ → Leame indicando los archivos que deben de cargar
outputs/ → Imagen resultado


## Referencias

Margules, C. R., & Pressey, R. L. (2000). *Systematic conservation planning*. Nature, 405, 243–253.

Rodrigues, A. S. L. et al. (2004). *Effectiveness of the global protected area network in representing species diversity*. Nature.
