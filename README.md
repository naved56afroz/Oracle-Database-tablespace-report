# Oracle-Database-tablespace-report
Oracle Database Generic Reporting script

This is generic reporting shell script can utilized to generate various reports for multiple database with minimal effort. 
Architecture diagram and script has been attached where main program is customize to take inputs and run across multiple databases serially to generate a consolidated alert notification in html format.
 
I have tried to keep it as generic as possible.


-Main_Report.sh

         |- Identifier_Name_Mail_List.txt
	 
	  |- Set_Markup.sql
	  
	  |- Usage_report.sql
	  
	  |- Identifier_Name_db_List.txt
	  

I will try to scale out this script to generate report for various items such as archive generation, blocking and other performance metrics etc. which will be menu driven wherein, you can simply deploy the script and input options 1-n for desired reports.

Sample scripts attached for tablespace utilization with threshold 75%.

Usage :

Download and deploy the files in /home/oracle/scripts in central server or jump host. In case of alternate location you can edit input files accordingly and run the Report.sh Identifier_Name from cenrtal server.

You need to update the dblist with desired database sid , each in single line,and email list file with desired recipient list.


