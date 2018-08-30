#ToDo: add summary row to bottom of summarise data frame which show the totals and averages for the data
library(shiny)
library(shinydashboard)
library(DT)
library(rhandsontable)

dashboard_head <- dashboardHeader(title = 'Database analyser')
dashboard_side <- dashboardSidebar(
  sidebarMenu(
    tags$link(rel = "stylesheet", type = "text/css", href = "main.css"),
    br(),
    #create name dict -> online-green offline-red
    htmlOutput('database_connection_indicator', inline=TRUE),
    br(),  
    menuItem('Connect To Database', tabName ='dbconnection'),
    menuItem('Summarise Data', tabName='data_summary'),
    menuItem('Run uploading tests', tabName = 'run_tests'),
    menuItem('Update table info', tabName = 'update_table_info'),
    menuItem('RunSQL', tabName = 'run_SQL'),
    div(style='text-align: center',actionButton('refresh_database_connection',label = 'Refresh database connection', icon = icon('refresh'))),
    div(style='text-align: center',actionButton('disconnect_from_db',label = 'Disconnect from database', icon = icon(''))),
    div(style='text-align: center',actionButton('reset_database_connections',label = 'Reset all database connctions', icon = icon('reset')))
    
  )
)
dashboard_body <- dashboardBody(
  tabItems(
    tabItem(tabName = 'dbconnection',
          br(),
          column(4),
          column(4, style = 'text-align: center',
             fluidRow(style = 'text-align: center',
                      #x=dbConnect(dbDriver("MySQL"), user="mydb2967sd", password="pu7xun", dbname="mydb2967", host="mysql1.it.nuigalway.ie", port=3306)
                      
                      selectInput('database_type', label = 'Please Select a Database Management System',choices = list('MySQL', 'SQLServer', 'SQLite', 'Postgres'), selected = 'MySQL')
             ),
              fluidRow(style = 'text-align: center',
                       #x=dbConnect(dbDriver("MySQL"), user="mydb2967sd", password="pu7xun", dbname="mydb2967", host="mysql1.it.nuigalway.ie", port=3306)
                       
                textInput('server_name', label = 'Enter the server name (unless database is serverless):')
                          #, value = 'mysql1.it.nuigalway.ie')
              ),
              fluidRow(
                textInput('user_id', label = 'Enter your user id:')
                          #value = 'mydb2967sd')
              ),
              fluidRow(
                passwordInput('password', label = 'Enter your password:')
                              #value = 'pu7xun')
              ),
              fluidRow(
                numericInput('port', label = 'Please enter the port number:', value = 3306, min = 0, max = 64000)
                #, value = 3306
              ),
              fluidRow(
                textInput('database', label = 'Please enter the database name:')
                #value = 'mydb2967')
              ),
             fluidRow(style = 'padding-right: 200px',
                      actionButton('test_database_login', label = 'Give me a test database!', width = '220px')
             ),
              fluidRow(style = 'padding-right: 200px',
                actionButton('database_login', label = 'Attempt Database Login', width = '220px')
              )
			  #textOutput('database_login_result')
            )
    ),
    tabItem(tabName ='data_summary',
            fluidRow(
              column(width=4,offset=4,
                selectInput('data_summary_choose_table', 'Choose a table to view', choices = list())
              )
            ),
            fluidRow(
              column(width=4,offset=5,
                HTML("Functionality Coming soon...")
              )
            ),
            fluidRow(
              column(width=12, offset = 0,
                     DT::dataTableOutput('table_summary')
              )
            )
    ),
    tabItem(tabName='run_tests',
            actionButton('rerun_tests',label = 'Run/Rerun tests',icon= icon('refresh')),
            actionButton('rerun_sample_tests', label = "Run/Rerun sample tests"),
            htmlOutput('test_report'),
            htmlOutput('sample_test_report')
            ),
    tabItem(tabName='update_table_info',
            fluidRow(
              column(width=4,offset=4,
                selectInput('update_table',label = 'Choose a table to update', choices = list())
              )
            ),
            fluidRow(
              box(width = 12,
              DT::dataTableOutput('table_output'))
            ),
            br(),
            hr(),
            fluidRow(style = 'text-align: center',
              DT::dataTableOutput('update_table_output'),
              rHandsontableOutput('update_table_updated_values'),
              actionButton('update_table_output_button', label = 'Update row')
            )
    ),
    tabItem(tabName='run_SQL', 
            fluidRow(
              column(3, offset = 3,
                textAreaInput('SQL', label = 'Enter your command', width = '500px', height = '250px')
              ),
              column(3,offset = 5,
                actionButton('run_SQL_query', label = 'Run', width = '150px')
              )
            ),
            br(),
            hr(),
            DT::dataTableOutput('SQL_result')
    )
  )
)

shinyUI(dashboardPage(
  dashboard_head,
  dashboard_side,
  dashboard_body, 
  skin = 'green',
  title = 'database analyser'
))

