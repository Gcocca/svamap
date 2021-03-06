library(svamap)
data(NUTS_20M)
pts <- read_point_data("/media/t/Falkenrapporter/E16-036 Grundrapport.csv")
polys <- svamap::match_to_county(pts, NUTS_20M, "NUTS_ID")$polygons
text <- ifelse(polys$count == 1, "negativt prov", "negativa prover")
polys$popup_text <- ifelse(is.na(polys$count), polys$name, paste0(polys$name, "<br>", polys$count, " ", text))
path_to_data <- svamap::write_data(polys)
svamap::write_page(path_to_data, "/media/ESS_webpages/CWD/", overwrite = TRUE, browse = FALSE)
