#code to connect to test DB
#ToDo: allow selection of multiple rows to update multiple players

#x=dbConnect(dbDriver("MySQL"), user="mydb2967sd", password="pu7xun", dbname="mydb2967", host="mysql1.it.nuigalway.ie", port=3306)
#x=dbConnect(dbDriver("SQLServer"), user="SA", password="password123!", dbname="testDB", host="localhost", port=1433)
#x = odbcDriverConnect(connection = "DRIVER={ODBC Driver 13 for SQL Server};PORT=1433;SERVER=localhost;DATABASE=testDB;UID=SA;PWD=")
#x <- RSQLite::dbConnect(dbDriver('SQLite'), dbname="testDB.db")
#query <- dbListTables(x)
#fetch(query)


library('RSQLite')
library('RODBC')
library('RMySQL')
library('shiny')
library('DT')
library('rhandsontable')
source('../Utils/helpers.r')




shinyServer(function(session,input, output) {
  
  connected <- reactiveVal(FALSE)
  sql_query_result<-reactiveVal(data.frame())
  
  #observeEvent(input$database_type){
  #retitle and update default logins
  #  update
  #}
  
  observeEvent(input$reset_database_connections,{
    #reset connections based on database type MySQL version
    if(input$database_type == 'MySQL'){
      lapply(dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
    }
    else if(input$database_type == 'SQLServer'){
      lapply(dbListConnections( dbDriver( drv = "SQLServer")), dbDisconnect)
    }
    connected(FALSE)
    showNotification('All Database connections have been reset', type = 'message')
  })
  
  observeEvent(input$disconnect_from_db,{
    if(connected()){
      #DBI method
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
      #Your code to run and display test goes here!
      # change directory to where your database tests are located
      # setwd('')
      # progress$set(value = 0.30, message='Running test scripts')
      
      #edit this line to call the database test scripts, which should generate a html output
      # system('python3 ')
      # progress$set(value = 0.75, message='Reading in test output')
      
      # reserve a section that shows the html files containing the tests
      # reports <- list.files('')
      # progress$set(value = 0.9, message='Rendering HTML')
      # setwd('')
      # #return(HTML(paste(sapply(reports,includeHTML), collapse = '\n')))
      return(HTML("Run your application's database tests and direct the output here!"))
    }
    else{
      return(HTML("Run your application's database tests and direct the output here!"))
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
    connection <<- tryCatch({
      if(input$database_type == 'MySQL'){
        dbConnect(dbDriver("MySQL"), user=input$user_id, password=input$password, dbname=input$database, host=input$server_name, port=as.numeric(input$port))
      }
      else if(input$database_type == 'SQLServer'){
        odbc::dbConnect( odbc(), .connection_string= 'DRIVER={ODBC Driver 13 for SQL Server};PORT=1433;SERVER=;DATABASE=;UID=;PWD=password123!')
      }
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
    #ToDo
    #not sure how best to render data table summary info here.
    DT::datatable(data.frame())
    #DT::datatable(input$data_summary_choose_table)
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
  
  observeEvent(input$test_database_login,{
    updateSelectInput(session,inputId = 'database_type', label = 'Please Select a Database Management System', choices = list('MySQL', 'SQLServer', 'SQLite', 'Postgres'), selected='MySQL')
    #selectInput('database_type', label = 'Please Select a Database Management System',choices = list('MySQL', 'SQLServer', 'SQLite', 'Postgres'), selected = 'MySQL')
    updateTextInput(session, 'server_name', label = 'Enter the server name (unless database is serverless):',value = 'mysql1.it.nuigalway.ie')
    #textInput('server_name', label = 'Enter the server name (unless database is serverless):', value = 'mysql1.it.nuigalway.ie')
    updateTextInput(session,'user_id',label = 'Enter your user id:', value = 'mydb2967sd')
    #textInput('user_id', label = 'Enter your user id:', value = 'mydb2967sd')
    updateTextInput(session,'password',label = 'Enter your password:', value = 'pu7xun')
    #passwordInput('password', label = 'Enter your password:',value = 'pu7xun')
    updateNumericInput(session,'port',label = 'Please enter the port number:', '3306')
    #numericInput('port', label = 'Please enter the port number:', value = 3306, min = 0, max = 64000)
    updateTextInput(session,'database',label = 'Please enter the database name', value='mydb2967')
    #textInput('database', label = 'Please enter the database name:', value = 'mydb2967')
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
  
  output$sample_test_report <- renderUI({
    input$rerun_sample_tests
    #run the sample tests and show the html output
    #first should check that odbc
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    
    progress$set(value = 0.30, message='Running test scripts')
    wd <- getwd()
    setwd(paste(wd, '/../Tests/SamplePythonDBTests',sep=''))
    #system2('rm', './reports/database_uploading_tests/.*.html')
    system2('C:/Users/13383861/Envs/test/Scripts/python.exe', 'TestSuite.py')
    reports <- lapply(list.files(paste(wd,'/reports/database_uploading_tests',sep='')), function(x) paste(paste(wd,'/reports/database_uploading_tests',sep=''), x, sep='/'))
    progress$set(value = 0.9, message='Rendering HTML')
    html <- paste(sapply(reports,includeHTML), collapse = '\n')
    print(html)
    setwd(wd)
    progress$set(value = 1, message='HTML rendered')
    return(HTML(html))
  })
  
})



