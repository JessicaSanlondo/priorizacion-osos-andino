# =====================================================
# Proyecto: Priorización espacial para conservación
# Ejercicio: P2 - Priorización del oso andino
# Autora: Jessica Sánchez Londoño
# Fecha: Marzo 2026
# =====================================================

# =====================================================
# LIBRERÍAS
# =====================================================

#Instlarlas antes de ejecutar
#install.packages("terra")
#install.packages("sf")
#install.packages("prioritizr")
#install.packages("Rsymphony")
#install.packages("rnaturalearth")

library(terra)
library(sf)
library(prioritizr)
library(Rsymphony)
library(rnaturalearth)

# =====================================================
# CARGAR DATOS
# =====================================================

beneficio <- rast("data/Beneficio_Neto_Total.tif")
oso <- rast("data/Tremarctos ornatus.tif")
huella <- rast("data/IHEH_2018.tif")
paramos <- st_read("data/Complejos de Paramos_Escala100k.shp")

# =====================================================
# PREPARACIÓN DE DATOS
# =====================================================

crs_ref <- crs(beneficio)

oso <- project(oso, crs_ref)
huella <- project(huella, crs_ref)
beneficio <- project(beneficio, crs_ref)

paramos <- st_transform(paramos, crs_ref)

huella <- resample(huella, oso)
beneficio <- resample(beneficio, oso)

paramos_raster <- rasterize(vect(paramos), oso)
paramos_raster <- ifel(!is.na(paramos_raster), 1, 0)

oso <- aggregate(oso, fact = 3)
huella <- aggregate(huella, fact = 3)
beneficio <- aggregate(beneficio, fact = 3)
paramos_raster <- aggregate(paramos_raster, fact = 3)

area <- !is.na(oso)

oso <- mask(oso, area)
huella <- mask(huella, area)
beneficio <- mask(beneficio, area)
paramos_raster <- mask(paramos_raster, area)

oso <- ifel(is.na(oso), 0, oso)
huella <- ifel(is.na(huella), max(values(huella), na.rm = TRUE), huella)
beneficio <- ifel(is.na(beneficio), 0, beneficio)

normalizar <- function(x) {
  max_val <- as.numeric(global(x, "max", na.rm = TRUE))
  x / max_val
}

oso <- normalizar(oso)
huella <- normalizar(huella)
beneficio <- normalizar(beneficio)

# =====================================================
# DEFINICIÓN DEL PROBLEMA DE PRIORIZACIÓN
# =====================================================

features <- rast(list(oso, paramos_raster))
names(features) <- c("oso", "paramos")

costos <- huella - beneficio
min_val <- as.numeric(global(costos, "min", na.rm = TRUE))
costos <- costos - min_val

p <- problem(costos, features) %>%
  add_min_set_objective() %>%
  add_relative_targets(c(0.3, 0.2)) %>% #*Ver comentario al final de esta sección
  add_binary_decisions() %>%
  add_rsymphony_solver()

print(p)

#*Targets de representación para los elementos de conservación.
# Se establece representar al menos 30% del hábitat potencial del oso andino
# y 20% de los ecosistemas de páramo. Estos valores se utilizan como referencia
# para el ejercicio y pueden ajustarse según los objetivos de conservación,
# disponibilidad de datos o criterios de manejo.

# =====================================================
# RESOLVER PROBLEMA
# =====================================================

solucion <- solve(p, force = TRUE)

# =====================================================
# VISUALIZACIÓN
# =====================================================

solucion_bin <- ifel(solucion == 1, 1, NA)

colombia <- ne_countries(country = "Colombia", returnclass = "sf")
colombia <- st_transform(colombia, crs(solucion))
colombia_vect <- vect(colombia)

ext_col <- ext(colombia_vect)
solucion_col <- crop(solucion_bin, ext_col)

plot(solucion_col,
     col = "darkgreen",
     main = "Áreas prioritarias seleccionadas",
     axes = TRUE)

plot(colombia_vect,
     add = TRUE,
     border = "black",
     lwd = 1.5)

legend("topright",
       legend = "Área prioritaria",
       fill = "darkgreen",
       border = "darkgreen",
       bty = "n")

# =====================================================
# VERIFICACIÓN DE TARGETS
# =====================================================

eval_target_coverage_summary(p, solucion)

# =====================================================
# MÉTRICAS DE RESULTADO
# =====================================================

celdas_seleccionadas <- global(solucion, "sum", na.rm = TRUE)
total_celdas <- global(!is.na(solucion), "sum", na.rm = TRUE)

porcentaje_area <- (celdas_seleccionadas / total_celdas) * 100
print("Porcentaje del área seleccionada:")
print(porcentaje_area)

area_pixel <- cellSize(solucion, unit = "km")
area_priorizada_km2 <- global(area_pixel * solucion, "sum", na.rm = TRUE)

print("Área total priorizada (km2):")
print(area_priorizada_km2)

# =====================================================
# EXPORTAR RESULTADO
# =====================================================

dir.create("outputs", showWarnings = FALSE)

writeRaster(
  solucion,
  "outputs/areas_prioritarias_oso.tif",
  overwrite = TRUE

)
