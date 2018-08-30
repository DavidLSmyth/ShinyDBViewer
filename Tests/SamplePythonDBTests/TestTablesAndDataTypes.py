# database testing
# add players drills etc.

import sys
#sys.path.append('..')
#from AzureInterfaceCode.azureDatabaseInterface import AzureDBInterface
import unittest
import pymysql


class CustomAssertions:
	def assertListsEqual(self, list1, list2):
		if list1 != list2:
			raise AssertionError('{} \n{}\nLists differ according to the following elements : Unmatching: {} \nMissing: {}' .format(list1, list2,
				list((index, x[0],'!=',x[1]) if x[0]!=x[1] else 'ok' for index, x in enumerate(zip(list1, list2))),
				[list1[len(list2):] if len(list2)<len(list1) else list2[len(list1):]]
			))

	def assertListsElementsUnorderedMatch(self,list1, list2):
		if not (set(list1).issubset(list2) and set(list2).issubset(list1)):
			raise AssertionError('The elements in list1 do not match the elements in list 2: {}\n{}'.format(list1,list2))



class TestDBTablesAndDataTypes(unittest.TestCase, CustomAssertions):

	@classmethod
	def setUpClass(cls):
		cls.conn = pymysql.connect(host = 'mysql1.it.nuigalway.ie', user = 'mydb2967sd', password = 'pu7xun', db = 'mydb2967',charset = 'utf8mb4',cursorclass=pymysql.cursors.DictCursor)
		cls.cursor =  cls.conn.cursor()
		
		
	# Ensure that predefined tables are present
	def test_checkTables(self):
		print('check tables')
		self.cursor.execute('Show tables;')
		self.assertListsElementsUnorderedMatch(self.cursor.fetchone().values(), ['TestTable'])

	# Check columns are present in column tables
	def test_checkTestTableColumns(self):
		self.cursor.execute('SHOW columns from TestTable')
		res = self.cursor.fetchall()
		columns = {key:[d[key] for d in res] for key in res[0]}
		self.assertListsElementsUnorderedMatch(columns['Field'], ['TestTable_id', 'col1', 'col2', 'col3', 'col4'])


	# check columns have correct data types in tables
	def test_checkTestTableDataTypes(self):
		self.cursor.execute('SHOW columns from TestTable')
		res = self.cursor.fetchall()
		columns = {key:[d[key] for d in res] for key in res[0]}
		self.assertListsEqual(columns['Type'], ['int(11)','int(11)','int(11)','int(11)','int(11)'])

	@classmethod
	def tearDownClass(cls):
		cls.conn.close()


if __name__ == '__main__':
	unittest.main()
