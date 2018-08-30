generate_update_set <- function(df){
  print(names(df))
  return(paste(sapply(names(df), function(name) paste(name, "=", df[1,name])), collapse=','))
}