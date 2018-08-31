list_of_packages <- c('RSQLite','RODBC','RMySQL','RSQLServer','shiny','DT','rhandsontable')
new.packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
lapply(new.packages, install.packages)
