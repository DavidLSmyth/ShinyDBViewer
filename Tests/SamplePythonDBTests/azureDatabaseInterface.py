import re, logging, pyodbc

#ToDo:
#Catch pyodbc.ProgrammingError errors

class AzureDBInterface():
    '''a class to interact with MYSQL database on the azure cloud'''
    
    def __init__(self,server: str, user_name: str, password: str, database_name: str):
        #possibly define some constants for uploading types to database here
        driver= '{ODBC Driver 13 for SQL Server}'
        self.database_name=database_name
        #catch exception for no connection
        try:
            self.connection=pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1443;DATABASE='+database_name+';UID='+user_name+';PWD='+ password)
            self.cursor=self.connection.cursor()
            #self.__log.info('Successfully connected to {}'.format(database_name))
        except Exception as e:
            #self.__log.error('couldnt connect to database {} - have you configured your firewall settings? \n are you sure you have specified a valid database name?'.format(database_name))
            raise e

    @classmethod
    def default_login(cls):
        return cls('orrecolabs.database.windows.net',
                    'orrecoadmin@orrecolabs',
                    'password123!',
                    'orreco_labs')

    @classmethod
    def docker_login(cls):
        print('DONT FORGET TO RUN DOCKER_SETUP.PY')
        return cls('127.0.0.1',
                'sa',
                'password123!',
                'orreco_labs')

    def getTables(self):
        '''gets the tables in the azure account provided'''
        try:
            self.cursor.execute('''Select Table_name as "Table name"
                                    From Information_schema.Tables
                                    Where Table_type = 'BASE TABLE' and Objectproperty 
                                    (Object_id(Table_name), 'IsMsShipped') = 0''')
            table_names=[]
            for i in self.cursor:
                #table name returned in a tuple - get first element
                table_names.append(i[0])
            return table_names
        except Exception as e:
            #self.__log.error('couldnt query tables')
            raise e

                
    
        
    def createTable(self, sql_string):
        '''takes in a dictionary of column names, types and other details and creates an sql table in
        the database. Specification_dictionary takes form name:, column_name:[data_type, ],'''
        #this is not really different to runSQL currently
        try:
            #print("Creating table {}: ".format(re.findall('`(.*)` ',sql_tuple_string)[0]), end='')
            self.cursor.execute(sql_string)
        except Exception as e: 
            #self.__log.error('couldnt create the table according to the sql code: \n{}'.format(sql_string))
            raise e

    def removeDataFromTable(self,table_name):
        try:
            self.cursor.execute('''DELETE FROM {}'''.format(table_name))
            self.connection.commit()
        except Exception as e:
            print('couldnt drop data from {}'.format(table_name))
            raise e

    def dropTable(self, table_name):
        #verify=str(input("are you sure you want to drop {} (y/n)?".format(table_name)))
        #while verify not in ['y','n']:
        #    verify=str(input("are you sure you want to drop {} (y/n)?".format(table_name)))
        #if verify=='y':
        try:
            self.cursor.execute('DROP TABLE {}'.format(table_name))
            self.connection.commit()
        except Exception as e:
            print('Table probably has foreign key dependency - could not be dropped')
            raise e


    def runSQL(self, sql:str):
        try:
            self.cursor.execute(sql)
            self.connection.commit()
        except Exception as e:
            #self.__log.error('couldnt execute sql code: error code returned')
            raise e    

    def runSQL_and_fetch_one(self, sql:str):
        try:
            return self.cursor.execute(sql).fetchone()
        except Exception as e:
            #self.__log.error('couldnt execute sql code: error code returned')
            raise e 

    def getTableContents(self,table_name) -> list:
        '''returns the contents of a table in the form of a list'''
        try:
            self.cursor.execute('SELECT * FROM {};'.format(table_name))
            table_rows=[]
            for table_row in self.cursor:
                table_rows.append(table_row)
            return table_rows
        except Exception as e:
            #self.__log.error('couldnt locate table or some other error')
            raise e

    def getTableColumnsContents(self,table_name, column_names: list) -> dict:
        '''returns a dictionary with keys column name, value column values'''
        return_dict = {}
        try:
            for column_name in column_names:
                return_dict[column_name] = self.getTableColumnContents(table_name, column_name)
        except Exception as e: 
            raise e
        return return_dict


    def getTableColumnContents(self, table_name, column_name) -> list:
        try:
            self.cursor.execute('SELECT {} FROM {}'.format(column_name,table_name))
            return_list = [i[0] for i in self.cursor]
            return return_list
        except Exception as e:
            raise e


    def getTableColumnDetails(self,table_name:str):
        '''Returns the column name, and details to the user of all columns in the database table as a dictionary where
        each key has an ordered list as value representing the detail of the column name'''
        try:
            self.cursor.execute(''' SELECT c.name AS column_name  
                                        ,c.column_id  
                                        ,SCHEMA_NAME(t.schema_id) AS type_schema  
                                        ,t.name AS type_name  
                                        ,t.is_user_defined  
                                        ,t.is_assembly_type  
                                        ,c.max_length  
                                        ,c.precision  
                                        ,c.scale  
                                    FROM sys.columns AS c   
                                    JOIN sys.types AS t ON c.user_type_id=t.user_type_id  
                                    WHERE c.object_id = OBJECT_ID('{}')  
                                    ORDER BY c.column_id;'''.format(table_name))
            #could also return 
            details=['column_name','id','schema','datatype','user_defined','is_assembly_type','max_length','precision','scale']
            details_dict={detail:[] for detail in details}
            for column_detail in self.cursor:
                #print(column_detail)
                for index,detail in enumerate(column_detail):
                    details_dict[details[index]].append(detail)
            return details_dict
        except Exception as e:
            print('could not get column information - error returned')
            raise e



    def close(self):
        '''safely disconnects from the database'''
        self.cursor.close()
        self.connection.close()


#logging.basicConfig(datefmt='%Y/%m/%d %I:%M:%S %p',level=TRACE, filename='/Users/davidsmyth/Documents/AzureDBSetup/azureDBSetupgithub/PythonUploadToAzure/AzureInterfaceCode/azure_db_interface_gps_upload.log',format="%(levelname)s:%(name)s:%(funcName)s:%(message)s")




        