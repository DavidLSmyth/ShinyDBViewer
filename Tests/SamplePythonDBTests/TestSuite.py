import unittest
from HtmlTestRunner import HTMLTestRunner
from TestTablesAndDataTypes import TestDBTablesAndDataTypes

def main():
	DB_details_test = unittest.TestLoader().loadTestsFromTestCase(TestDBTablesAndDataTypes)
	test_suite = unittest.TestSuite([DB_details_test])
	runner = HTMLTestRunner(output='database_uploading_tests', template ='./test_runner_template.html', report_title='Database Test Report')
	runner.run(test_suite)
	
if __name__ == '__main__':
	main()