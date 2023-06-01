# SSISDB_Cleanup

This project details how I manage my SQL Server Integration Services (SSISDB) Database.  This effort came out of a need to purge old log data out of the SSISDB database on a very busy SSISDB Database.  I use a TRY/CATCH exception block and explicit transactions to manage the deletes from the tables so that I wasn't affecting current SSIS processing and it also manages the Transaction Log file size quite well.   

NOTE:  Please use this code cautiously on your environment.  I encourage you to use Activity Monitor or SQL Profiler to monitor for excessive locking or blocking SQL.  Based on my extensive use of this process I have not experienced any significant locking or blocking but that could vary in your environment.

I have included some SQL queries in this solution that will help you track your Tables and Indexes involved in the process.

Files Included:
SSISDB_Database_Digram.png - ScreenShot of SSISDB Database Tables with the Foreign Key relationships

SSISDB_foreign_keys.sql - generates the Foreign Key sql statements needed to drop / create the Foreign Keys

SSISDB_drop_foreign_keys.sql - Foreign Keys that I drop while executing the pruning process to improve the performance.  The reason I do this is that many of the Foreign Keys in the SSISDB database use a CASCADE DELETE option which tends to be slow in performance.   Make sure to create the foreign keys once the process is completed.  

sp_SSISDB_prune_data.sql - Stored Procedure that executes the data pruning process

There are two Tables used by the sp_SSISDB_prune_data.sql.  These tables are created in this stored procedure and are re-created each time the process runs.  By default these tables will be created in the SSISDB Database.

Table: dbo.SSISDB_prune_data_error - captures any errors generated by the TRY/CATCH exception block

Table: dbo.SSIS_prune_data_log - logs the progress the stored procedure: sp_SSISDB_prune_data

SSISDB_create_foreign_keys.sql - Creates the Foreign Key Constraints dropped during the pruning process is completed

SSISDB_sp_updatestats.sql - updates the Statistics on the SSISDB database after the pruning process is completed

DBA_SSISDB_prune_data.sql - Creates a SQL Job Script to execute the above SQL in this order below.  
You will have to setup a Job Schedule and I recommend setting a Job Notification Email on Job Completion for SQL Job Monitoring.

Job Steps execute the SQL in the following order:
1. SSISDB_drop_foreign_keys.sql
2. sp_SSISDB_prune_data.sql
3. SSISDB_create_foreign_keys.sql
4. SSISDB_sp_updatestats.sql

SSISDB_table_purge_count.sql - Validates the counts of the Table and also validates that the Referential Integrity of the Foreign Key Constraints.

Invalid_Foreign_Keys.sql - this SQL validates the Foreign Keys in the SSISDB database.  
Just another way to validate that Referential Integrity has been maintained after the process has been completed.

table_rowcount.sql - gets the Table Row Counts and Data Space used by table.  
NOTE: Use this script to determine how many rows each table has and the size of each table.  You may find additional tables in the SSISDB Database that need to be adjust to this pruning process.

SSISDB_Index_Reorganize.sql - this SQL can be used to analyze the SSISDB Indexes involved in this process for additional validation.
