#connection <- odbc::dbConnect( odbc(), .connection_string= 'DRIVER={MySQL ODBC 5.2 ANSI Driver};PORT=1433;SERVER=orrecolabs.database.windows.net;DATABASE=orreco_labs;UID=orrecoadmin@orrecolabs;PWD=password123!')
#
#mydb = dbConnect(MySQL(), user='davidsmyth', password='password123!', dbname='davidsmyth$TestDB', host='davidsmyth.mysql.pythonanywhere-services.com')
#ToDo: allow selection of multiple rows to update multiple players

#x=dbConnect(dbDriver("MySQL"), user="mydb2967sd", password="pu7xun", dbname="mydb2967", host="mysql1.it.nuigalway.ie", port=3306)
library('RMySQL')
library('shiny')
#library('odbc')
#library('DBI')
library('DT')
library('rhandsontable')
source('helpers.r')
#attempt_db_connect
#run_sql
#

#connected<-FALSE

DRIVER= '{ODBC Driver 13 for SQL Server}'

shinyServer(function(session,input, output) {
  connected <- reactiveVal(FALSE)
  sql_query_result<-reactiveVal(data.frame())
  
  observeEvent(input$reset_database_connections,{
    #reset connections based on database type
    lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
    connected(FALSE)
    showNotification('All Database connections have been reset', type = 'message')
  })
  
  observeEvent(input$disconnect_from_db,{
    if(connected()){
      dbDisconnect(connection)
      connected(FALSE)
      showNotification('Successfully disconnected from the database', type = 'message')
    }
    else{
      showNotification('Not connected to a database yet!', type = 'warning')
    }
  })
  
  output$test_report <- renderUI({
    #create dependency on rerun tests to trigger this
    input$rerun_tests
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    if(connected()){
      setwd('/Users/davidsmyth/Documents/AzureDBSetup/azureDBSetupgithub/PythonUploadToAzure/AzureInterfaceCode')
      progress$set(value = 0.30, message='Running test scripts')
      system('python3 /Users/Documents/AzureDBSetup/azureDBSetupgithub/PythonUploadToAzure/database_test_code/uploadToDataBaseTestSuite.py')
      progress$set(value = 0.75, message='Reading in test output')
      reports <- list.files('/Users/Documents/AzureDBSetup/azureDBSetupgithub/PythonUploadToAzure/AzureInterfaceCode/reports/database_uploading_tests')
      progress$set(value = 0.9, message='Rendering HTML')
      setwd('/Users/Documents/AzureDBSetup/azureDBSetupgithub/PythonUploadToAzure/AzureInterfaceCode/reports/database_uploading_tests')
      return(HTML(paste(sapply(reports,includeHTML), collapse = '\n')))
    }
  })
  
  output$database_connection_indicator <- renderUI({
    print(input$connected)
    print(HTML(paste("<div style ='text-align:center; width:100%;color:",ifelse(connected(), 'green','#ce5a46'),";background-color: white;font-size: 16px; font-weight: bold; display: inline-block;'>",'Database is',ifelse(connected(),'connected','not connected'),icon(ifelse(connected(),'check','remove')),"</div>")))
    return(HTML(paste("<div style ='text-align:center; width:100%; color:",ifelse(connected(), 'green','#ce5a46'),";background-color: white;font-size: 16px; font-weight: bold; display: inline-block;'>",'Database is',ifelse(connected(),'connected','not connected'),icon(ifelse(connected(),'check','remove')),"</div>")))
  })
  
  #maybe should try and connect via python/c++? Not sure if this is worth looking into
  observeEvent(input$database_login,{
    print('attempting to connect with connection string: ')
    print(paste('DRIVER=','MySQL',';SERVER=',input$server_name,';PORT=1443;DATABASE=',input$database,';UID=',input$user_id,';PWD=',input$password, sep = ''))
    #connection <- odbc::dbConnect( odbc(), .connection_string= 'DRIVER={ODBC Driver 13 for SQL Server};PORT=1433;SERVER=orrecolabs.database.windows.net;DATABASE=orreco_labs;UID=orrecoadmin@orrecolabs;PWD=password123!')
    connection <<- tryCatch({
      dbConnect(dbDriver("MySQL"), user="mydb2967sd", password="pu7xun", dbname="mydb2967", host="mysql1.it.nuigalway.ie", port=3306)
    },
      error = function(e){
        print(paste('Error output: ',e))
        NA
    }
    )
    #print(paste('connection: ',connection))
    if(!is.na(connection)){
      print('no issues in making connection')
      connected(TRUE)
    }
    else{
      connected(FALSE)
    }
    print('connected: ')
    print(connected())
    showNotification(ifelse(connected(), 'Database was connected to successfully','Database connection attempt failed'))
  })
  #MySQL version
  update_tables <- observe({
    #gets all tables in database
    input$refresh_database_connection
    input$database_login
    if(connected()){
      print('updating select input tables')
      #dbClearResult(dbListResults(connection))
      res<-dbListTables(connection)
      print('res')
      print(res)
      updateSelectInput(session,'update_table', choices = res,
                        selected = res[1])
      updateSelectInput(session, 'data_summary_choose_table', choices = res, 
                        selected = res[1])
    }
  })
  
  #SQL Server Version
  # update_tables <- observe({
  #   input$refresh_database_connection
  #   input$database_login
  #   if(connected()){
  #     print('updating select input tables')
  #     res<-dbFetch(dbSendQuery(connection,"SELECT name FROM sys.objects WHERE [Type] = 'U'"),Inf)$name
  #     print('res')
  #     print(res)
  #     updateSelectInput(session,'update_table', choices = res,
  #                       selected = res[1])
  #     updateSelectInput(session, 'data_summary_choose_table', choices = res, 
  #                       selected = res[1])
  #   }
  # })
  
  output$table_summary <- renderDataTable({
    DT::datatable(input$data_summary_choose_table)
  })
  
  get_table_output_data <- reactive({
    return(data.frame(RMySQL::dbReadTable(connection, as.character(input$update_table))))
  })

  
  output$table_output <- DT::renderDataTable({
    #create dependencies on refresh database and connect to datbase buttons to update what the person sees
    input$refresh_database_connection
    input$database_login
    input$update_table_output_button
    input$data_summary_choose_table
    print('refreshing editable table')
    DT::datatable(dbFetch(dbSendQuery(connection, paste('SELECT * FROM',input$data_summary_choose_table)), Inf), 
          filter = 'top', rowname = FALSE,options = list(scrollX = TRUE,
          scrollY=TRUE,
          pageLength=30,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'pdf', 'print')
    ),selection = list(mode = 'single'),
    extensions = c('Buttons')
    )
  })
  
  #displays selected row for updating
  output$update_table_updated_values <- renderRHandsontable({
    row<-input$table_output_rows_selected
    print('row: ')
    print(row)
    validate(need(!is.null(row), 'No row selected'))
    print('the user selected row')
    print(row)
    id_column <- paste(input$update_table,'_id',sep='')
    print('identify row by ')
    print(id_column)
    id<-get_table_output_data()[row,id_column]
    print('sending query: ')
    print(paste('SELECT * FROM',input$update_table,'WHERE', id_column,'=',id))
    value<-dbSendQuery(connection, paste('SELECT * FROM',input$update_table,'WHERE', id_column,'=',id))
    res<-dbFetch(value, Inf)
    rhandsontable(res)
  })
  
  generate_update_set <- function(df){
    print(names(df))
    return(paste(sapply(names(df), function(name) paste(name, "=", df[1,name])), collapse=','))
  }
  
  update_table_row <- observeEvent(input$update_table_output_button,{
    row_data <- get_table_output_data()[input$table_output_rows_selected,
                                        paste(input$update_table,'_id',sep='')]
    updated_data <- data.frame(input$update_table_updated_values$data)
    names(updated_data)<- names(get_table_output_data())
    print('updated data')
    print(updated_data)
    update_statement = paste("UPDATE ",input$update_table, "SET",
    generate_update_set(updated_data),
    "WHERE",paste(input$update_table,'_id',sep=''),'=',row_data)
    print('update_statement')
    print(update_statement)
    db_exection_res <- dbExecute(connection, update_statement)
    showNotification(paste('Updated',db_exection_res,'rows'))
  })
  
  #if the user wants to query the database, let them
  observeEvent(input$run_SQL_query,{
    sql_to_run <- input$SQL
    print('attempting to run sql: ')
    print(sql_to_run)
    tryCatch({
        res<-dbSendQuery(connection, sql_to_run)
        display_table <- dbFetch(res,Inf)
        sql_query_result(display_table)
        print(display_table)
        dbClearResult(res)
        showNotification('Successfully executed query', type = 'message')
    },
    error = function(e) {
        print('could not execute query')
        showNotification(div(style= 'font-size: 32px;','Could not execute query'), type = 'error')
        sql_query_result(data.frame())
    })
    
  })
  
  output$SQL_result <- DT::renderDataTable({
    datatable(sql_query_result(),
                    options=list(scrollX = TRUE,
                    scrollY=TRUE,
                    pageLength=30,
                    dom = 'Bfrtip',
                    buttons = c('copy', 'csv', 'pdf', 'print')),
                    extensions = c('Buttons')
    )
  })
  
})



