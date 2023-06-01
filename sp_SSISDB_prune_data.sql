USE [SSISDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.sp_SSISDB_prune_data','P') IS NOT NULL
BEGIN
  DROP PROCEDURE [dbo].[sp_SSISDB_prune_data];
END;

GO

CREATE PROCEDURE [dbo].[sp_SSISDB_prune_data]
(
  @GetDate DATETIME
)
AS

/********************************************************************************************************************************
Stored Procedure: sp_SSISDB_prune_data
Author: Marty Scherr
Date: 06/01/2023
Description:  Prunes data from the following SSIS Tables
Tables:
internal.executable_statistics
internal.execution_parameter_values
internal.executions
internal.event_message_context
internal.event_messages
internal.operation_messages
internal.operations

Logging:  logs to table dbo.SSISDB_prune_data_log progress of the deletes

NOTE: Please be cautious when using the code on your Production Servers.  You may have to adjust the amount of rows you delete 
in each of the steps below depending on the performance of your server.

********************************************************************************************************************************/

/* create SSISDB error and log table */

IF OBJECT_ID (N'dbo.SSISDB_prune_data_error', N'U') IS NOT NULL /* does not exist */
BEGIN /*  IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') */
	DROP TABLE dbo.SSISDB_prune_data_error;

	CREATE TABLE dbo.SSISDB_prune_data_error(
		UserName VARCHAR(100) NULL,
		ErrorNumber int NULL,
		ErrorSeverity int NULL,
		ErrorState int NULL,
		ErrorProcedure nvarchar(128) NULL,
		ErrorMessage nvarchar(4000) NULL,
		ErrorLine int NULL,
		ErrorDateTime datetime NULL
	) ON [PRIMARY];

END; /*  IF OBJECT_ID (N'dbo.SSISDB_prune_data_error', N'U') */


IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') IS NOT NULL /* does not exist */
BEGIN /*  IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') */
	DROP TABLE dbo.SSISDB_prune_data_log;

	CREATE TABLE dbo.SSISDB_prune_data_log
	(
	ID INT IDENTITY(1,1)
	,MSG VARCHAR(200)
	,ROW_COUNT INT DEFAULT 0
	,LOGDATE DATETIME DEFAULT GETDATE()
	) ON [PRIMARY];

END; /*  IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') */


DECLARE @int BIGINT = 0;
DECLARE @max_operation_id BIGINT = 0;

BEGIN TRY	
 
 -- get max operation_id from internal.operations based on date criteria

  SELECT @max_operation_id = MAX(operation_id)
	FROM internal.operations WITH (NOLOCK)
	WHERE created_time < @GETDATE;

	-- get row count
	SELECT @int = COUNT(1)
	FROM internal.executable_statistics WITH (NOLOCK)
	WHERE execution_id <= @max_operation_id;

-- executable_statistics

  BEGIN TRANSACTION;

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'deleting from internal.executable_statistics', @int;

  COMMIT TRANSACTION;

WHILE EXISTS
(
SELECT TOP (1) execution_id
FROM internal.executable_statistics WITH (NOLOCK)
WHERE execution_id <= @max_operation_id
)
BEGIN /* WHILE */

BEGIN TRANSACTION;

DELETE TOP (1000) 
FROM internal.executable_statistics WITH (ROWLOCK)
WHERE execution_id <= @max_operation_id;

SELECT @int = @@ROWCOUNT;

COMMIT TRANSACTION;

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'deleting from internal.executable_statistics', @int;

END; /* WHILE */

BEGIN TRANSACTION;

  --get row count
  SELECT @int = COUNT(1)
  FROM internal.execution_parameter_values WITH (NOLOCK)
  WHERE execution_id <= @max_operation_id;

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'deleting from internal.executable_statistics', @int;

COMMIT TRANSACTION;

-- execution_parameter_values

  --get row count
  SELECT @int = COUNT(1)
  FROM internal.execution_parameter_values WITH (NOLOCK)
  WHERE execution_id <= @max_operation_id;

   BEGIN TRANSACTION;

    INSERT INTO dbo.SSISDB_prune_data_log
   (MSG
   ,ROW_COUNT
   )
   SELECT 'deleting from internal.execution_parameter_values', @int;

   COMMIT TRANSACTION;
   
WHILE EXISTS
(
SELECT TOP (1) execution_id 
FROM internal.execution_parameter_values WITH (NOLOCK)
WHERE execution_id <= @max_operation_id
)
BEGIN /* WHILE */

BEGIN TRANSACTION;

DELETE TOP(1000) FROM internal.execution_parameter_values	WITH (ROWLOCK)
WHERE execution_id <= @max_operation_id;

SELECT @int = @@ROWCOUNT;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.executable_statistics', @int;

COMMIT TRANSACTION;

END; /* WHILE */

-- event_message_context

-- get row count
SELECT @int = COUNT(1)
FROM internal.event_message_context WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_message_context', @int;

COMMIT TRANSACTION;

WHILE EXISTS
(
SELECT TOP(1) operation_id
FROM internal.event_message_context WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id
)

BEGIN /* WHILE */

BEGIN TRANSACTION;

DELETE TOP(10000) 
FROM internal.event_message_context WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

SELECT @int = @@ROWCOUNT;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_message_context', @int

COMMIT TRANSACTION;

END /* WHILE */

-- internal.event_messages

-- get row count
SELECT @int = COUNT(1) 
FROM internal.event_messages WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_messages', @int;

COMMIT TRANSACTION;

WHILE EXISTS
(
SELECT TOP (1) operation_id 
FROM internal.event_messages WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id
)

BEGIN /* WHILE */

BEGIN TRANSACTION;

DELETE TOP(1000) 
FROM internal.event_messages WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

SET @int = @@ROWCOUNT;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_messages', @int;

COMMIT TRANSACTION;

END /* WHILE */

-- operation_messages

BEGIN TRANSACTION

-- get row count
SELECT @int = COUNT(1)
FROM internal.operation_messages WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_messages', @int;

COMMIT TRANSACTION;

WHILE EXISTS
(
SELECT TOP (1) operation_id 
FROM internal.operation_messages WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id
)
BEGIN /* WHILE */

BEGIN TRANSACTION;

DELETE TOP (1000)
FROM internal.operation_messages WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

SET @int = @@ROWCOUNT;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_messages', @int;

COMMIT TRANSACTION;

END /* WHILE */

BEGIN TRANSACTION;

SET @int=0;
INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_permissions', @int;

COMMIT TRANSACTION;

-- operation_permissions

WHILE EXISTS
( 
SELECT TOP (1) object_id
FROM internal.operation_permissions WITH (NOLOCK)
WHERE object_id <= @max_operation_id
) 

BEGIN /* WHILE */

BEGIN TRANSACTION;

DELETE TOP (100)
FROM internal.operation_permissions WITH (ROWLOCK)
WHERE object_id <= @max_operation_id;

SELECT @INT = @@ROWCOUNT;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_permissions', @int;

COMMIT TRANSACTION;

END /* WHILE */

BEGIN TRANSACTION;

SELECT @int= 0;
INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_permissions', @int;

COMMIT TRANSACTION;

-- operations

-- get row count
SELECT @int = COUNT(1)
FROM internal.operations WITH (NOLOCK)
WHERE operation_id <= @max_operation_id;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operations', @int;

COMMIT TRANSACTION

WHILE EXISTS
(
SELECT TOP 1 operation_id
FROM internal.operations WITH (NOLOCK)
WHERE operation_id <= @max_operation_id
)
BEGIN /* WHILE */

BEGIN TRANSACTION

DELETE TOP (100)
FROM internal.operations WITH (ROWLOCK)
WHERE operation_id <= @max_operation_id;

SELECT @int= @@ROWCOUNT;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operations', @int;

COMMIT TRANSACTION;

END; /* WHILE */

END TRY

BEGIN CATCH;

	DECLARE @ErrorID        INT
	DECLARE @UserName       VARCHAR(100)
	DECLARE	@ErrorNumber    INT
	DECLARE @ErrorState     INT
	DECLARE @ErrorSeverity  INT
	DECLARE @ErrorLine      INT
	DECLARE @ErrorProcedure VARCHAR(MAX)
	DECLARE @ErrorMessage   VARCHAR(MAX)
	DECLARE @ErrorDateTime  DATETIME

	SELECT
	@UserName = SUSER_NAME()
	,@ErrorNumber = ERROR_NUMBER()
	,@ErrorSeverity = ERROR_SEVERITY()
	,@ErrorState = ERROR_STATE()
	,@ErrorProcedure = ERROR_PROCEDURE()
	,@ErrorMessage = ERROR_MESSAGE()
	,@ErrorLine = ERROR_LINE()
	,@ErrorDateTime = GETDATE();

	ROLLBACK TRANSACTION;

    INSERT INTO dbo.SSISDB_prune_data_error
    VALUES
  (@UserName,
   @ErrorNumber,
   @ErrorSeverity,
   @ErrorState,
   @ErrorProcedure,
   @ErrorMessage,
   @ErrorLine,
   @ErrorDateTime);
   
   RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;

