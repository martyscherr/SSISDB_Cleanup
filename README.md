# SSISDB_Cleanup

This project details how I manage my SQL Server Integration Services (SSISDB) Database.  This effort came out of a need to purge old log data out of the SSISDB database on a very busy SSISDB Database.  I use a TRY/CATCH exception block and explicit transactions to manage the deletes from the tables so that I wasn't affecting current SSIS processing and also manages the Transaction Log file size.  

NOTE:  Please use this code cautiously on your environment.  I have included some SQL queries that will help you track your Tables and Indexes involved in the process.
