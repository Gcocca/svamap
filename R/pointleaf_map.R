##' Create a browsable points map
##' 
##' The function is built on the top of R "leaflet" and "mapview" packages.
##' Both packages bind the JavaScript library Leaflet.js
##' 
##' @title pointleaf_map
##' @import leaflet
##' @import htmlwidgets
##' @import mapview
##' @export
##' @param mapdata an object of class SpatialPointsDataFrame
##' @param values a vector of values of class "numeric" classifying the points
##' @param palette colors (HEX allowed) assigned to each of the corresponding classes (unique values of the argument 'values')
##' @param title the title of the legend
##' @param labels a vector of class "character" with labels to display in the legend
##' @param radius a numeric vector of radii for the circles (default to 5 pixels)
##' @param stroke whether to draw stroke along the borders of circles
##' @param opacity a numeric vector of opacity for the circles (default to 1, no opacity)
##' @param popup text to be showed in the popup when clicking a point
##' @param logo logo to put in the topleft corner of the map
##' @param src character specifying the source location of the logo ("local" for images from the disk, "remote" for web image sources)
##' @param url the url to show when clicking the logo
##' @param dir path where the map will be saved
##' @param disease name of the html file. The suffix "_map.html" will be added to the provided name
##' @param group split the mapdata in different groups (default to unique values of the argument 'values')
##' @param browse if TRUE it opens the map in a new page of the default browser
##' @return path to the map
##' @author Giampaolo Cocca
pointleaf_map <-  function(mapdata,
                           values, 
                           palette,
                           title = NULL,
                           labels,
                           radius = 5,
                           stroke = FALSE,
                           opacity = 1,
                           popup = NULL,
                           logo = "https://assets-cdn.github.com/images/modules/logos_page/GitHub-Logo.png",
                           src = "remote",
                           url = "https://github.com/",
                           dir = tempdir(),
                           disease = "myDisease",
                           group = values,
                           browse = FALSE) {
  
  # Exceptions
  stopifnot(class(mapdata) %in% c("SpatialPointsDataFrame"))
  
  if(missing(values)) {
    stop("Argument 'values' is missing with no default")
  }
  
  if(missing(palette)) {
    stop("Argument 'palette' is missing with no default")
  }
  
  if(missing(labels)) {
    stop("Argument 'labels' is missing with no default")
  }
  
  if(is.null(group)) {
    stop("Argument 'group' must be set or left to the default (i.e. 'values')")
  }
  
  if(class(values) != "numeric") {
    stop("Argument 'values' must be of class numeric")
  }
  
  if(class(labels) != "character") {
    stop("Argument 'labels' must be of class character")
  }
  
  if(length(unique(values)) != length(palette)){
    stop("values' and 'palette' must be of the same length!")
  }
  
  if(length(palette) != length(labels)){
    stop("'labels' and 'palette' must be of the same length!")
  }
  
  if(length(radius) != length(values) & length(radius) != 1){
    stop("'radius' must have length == 1 or same length of 'values'!")
  }
  
  if(length(opacity) != length(values) & length(opacity) != 1){
    stop("'opacity' must have length == 1 or same length of 'values'!")
  }
  
  # Build the leaflet map
  pal <- colorFactor(palette = palette,
                      domain = factor(values), na.color = NA)
  
  
  
  leaf <- leaflet(mapdata) 
  leaf <- addTiles(leaf)
  # Add logo SVA  
  leaf <- addLogo(map = leaf, img = logo, src="remote", position = "topleft", height= 43, width = 270, url = url)   
  leaf <- addProviderTiles(leaf, "OpenStreetMap.BlackAndWhite", group = "Vägkarta")
  leaf <- addProviderTiles(leaf, "Esri.WorldTopoMap", group = "Terräng")
  leaf <- addProviderTiles(leaf, "Esri.WorldImagery", group = "Flygfoto")
  leaf <- setMaxBounds(leaf, 4, 54, 31, 70)
  
  # Loop over the field and split the data. This is to create different layers to flag and unflag
  groups = unique(as.character(group))

  for(i in groups){
    
    group_data <- mapdata[group == i,]
    
    if(length(radius) == 1) {
      myradius <- radius
      
      }else{
        
        myradius <- radius[group == i]
      }

      if(length(opacity) == 1) {
        myopacity <- opacity
      
       }else{
       
           myopacity <- opacity[group == i]
       }

    leaf <- addCircleMarkers(leaf, 
                           data = group_data,
                           stroke = stroke,
                           color = "black",
                           weight = 1,
                           radius = myradius,
                           fillColor = ~pal(values[group == i]),
                           fillOpacity =  myopacity,
                           popup = popup[group == i],
                           group = i)
  
    }
  
  # "&nbsp" is used to escape whitespaces in html. Did that to move the legend title.
  leaf <- addLegend(leaf,
                    "bottomright",
                    values = values,
                    colors = palette,
                    title = paste0(paste0(rep("&nbsp", 7), collapse = ""),
                                   "<font color=\"red\"><sup>", "Last update ", as.character(Sys.time()), "</sup></font>","<br>",
                                   paste0(rep("&nbsp", 7), collapse = ""), title),
                    labels = labels,
                    opacity = 0.7)
  
  leaf <- addLayersControl(leaf, 
                           baseGroups = c("Vägkarta", "Terräng", "Flygfoto"),
                           overlayGroups = group,
                           options = layersControlOptions(collapsed = FALSE))
  
  # Path where to save the map
  myfile <- file.path(dir, paste0(disease, "_map.html"))
  
  # Save the map
  saveWidget(leaf, file = myfile, selfcontained = FALSE)
  
  # Read and write lines to add the support for reading the map from IE (change to IE Edge)
  lines <- readLines(myfile, skipNul = TRUE)
  
  header <- c("<!DOCTYPE html>",
              "<html>",
              "<head>",
              "<meta http-equiv=\"x-ua-compatible\" content=\"IE=edge\" >",
              "<meta charset=\"utf-8\"/>")
  
  newLines <- c(header, lines[length(header): max(length(lines))])
  
  writeLines(newLines, con = myfile)
  
  if(browse) {
    browseURL(paste0("file://", myfile))
  }
  
  return(myfile)
}
