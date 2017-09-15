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
    div(style='text-align: center',actionButton('refresh_database_connection',label = 'Refresh database', icon = icon('refresh')))
    
  )
)
dashboard_body <- dashboardBody(
  tabItems(
    tabItem(tabName = 'dbconnection',
          br(),
          column(4),
          column(4, style = 'text-align: center',
              fluidRow(style = 'text-align: center',
                textInput('server_name', label = 'Enter the server name:', value = 'davidsmyth.mysql.pythonanywhere-services.com')
              ),
              fluidRow(
                textInput('user_id', label = 'Enter your user id:', value = 'davidsmyth')
              ),
              fluidRow(
                passwordInput('password', label = 'Enter your password:',value = 'password123!')
              ),
              fluidRow(
                numericInput('port', label = 'Please enter the port number:', value = 3306, min = 0, max = 64000)
              ),
              fluidRow(
                textInput('database', label = 'Please enter the database name:', value = 'davidsmyth$TestDB')
              ),
              fluidRow(
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
              column(width=12, offset = 0,
                 DT::dataTableOutput('table_summary')
              )
            )
    ),
    tabItem(tabName='run_tests',
            actionButton('rerun_tests',label = 'Rerun tests',icon= icon('refresh')),
            htmlOutput('test_report')
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
            fluidRow(
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

