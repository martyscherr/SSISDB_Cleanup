USE [SSISDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_SSISDB_prune_data]
AS

/********************************************************************************************************************************
Stored Procedure: sp_SSISDB_prune_data
Author: Marty Scherr
Date: 04/26/2023
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
IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') IS NULL /* does not exist */
BEGIN /*  IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') */

CREATE TABLE dbo.SSISDB_prune_data_log
(
ID INT IDENTITY(1,1)
,MSG VARCHAR(200)
,ROW_COUNT INT DEFAULT 0
,LOGDATE DATETIME DEFAULT GETDATE()
);

END; /*  IF OBJECT_ID (N'dbo.SSISDB_prune_data_log', N'U') */

TRUNCATE TABLE dbo.operations_temp;

DECLARE @GETDATE DATETIME = GETDATE()-3
DECLARE @int INT = 0

BEGIN TRY	
 
 BEGIN TRANSACTION

  INSERT INTO dbo.operations_temp
  (
      operation_id
  )
  SELECT operation_id
	FROM internal.operations WITH (NOLOCK)
	WHERE created_time < @GETDATE;
 
 COMMIT TRANSACTION

	-- get row count
	SELECT @int = COUNT(1)
	FROM dbo.operations_temp WITH (NOLOCK)

  BEGIN TRANSACTION

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'inserting into dbo.operations_temp', @int

  COMMIT TRANSACTION

-- executable_statistics

  BEGIN TRANSACTION

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'deleting from internal.executable_statistics', @int

  COMMIT TRANSACTION

WHILE EXISTS
(
SELECT TOP (1) execution_id
FROM internal.executable_statistics WITH (NOLOCK)
WHERE execution_id IN
(
SELECT TOP (1) operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)
)
BEGIN -- WHILE

BEGIN TRANSACTION

DELETE TOP (1000) 
FROM internal.executable_statistics WITH (ROWLOCK)
WHERE execution_id IN
(
SELECT TOP (1) operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)

SELECT @int = @@ROWCOUNT

COMMIT TRANSACTION

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'deleting from internal.executable_statistics', @int

END -- WHILE

BEGIN TRANSACTION

  --get row count
  SELECT @int = COUNT(1)
  FROM internal.execution_parameter_values WITH (NOLOCK)
  WHERE execution_id IN 
  (
	SELECT operation_id 
	FROM dbo.operations_temp WITH (NOLOCK)
  )

  INSERT INTO dbo.SSISDB_prune_data_log
  (MSG
  ,ROW_COUNT
  )
  SELECT 'deleting from internal.executable_statistics', @int

COMMIT TRANSACTION

-- execution_parameter_values

  --get row count
  SELECT @int = COUNT(1)
  FROM internal.execution_parameter_values WITH (NOLOCK)
  WHERE execution_id IN 
  (
	SELECT operation_id 
	FROM dbo.operations_temp WITH (NOLOCK)
  )

   BEGIN TRANSACTION

    INSERT INTO dbo.SSISDB_prune_data_log
   (MSG
   ,ROW_COUNT
   )
   SELECT 'deleting from internal.execution_parameter_values', @int

   COMMIT TRANSACTION
   
WHILE EXISTS
(
SELECT TOP (1) execution_id 
FROM internal.execution_parameter_values WITH (NOLOCK)
WHERE execution_id IN 
(
SELECT TOP (1) operation_id 
FROM dbo.operations_temp WITH (NOLOCK)
)
)
BEGIN -- WHILE

BEGIN TRANSACTION

DELETE TOP(1000) FROM internal.execution_parameter_values	WITH (ROWLOCK)
WHERE execution_id IN 
(
SELECT TOP (1) o.operation_id 
FROM internal.operations o WITH (NOLOCK)
WHERE o.created_time < @GETDATE
)

SELECT @int = @@ROWCOUNT;

COMMIT TRANSACTION

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.executable_statistics', @int

COMMIT TRANSACTION	

END -- WHILE

-- event_message_context

-- get row count
SELECT @int = COUNT(1)
FROM internal.event_message_context WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_message_context', @int

COMMIT TRANSACTION

WHILE EXISTS
(
SELECT TOP(1) operation_id
FROM internal.event_message_context WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)
) -- WHILE

BEGIN -- WHILE

BEGIN TRANSACTION

DELETE TOP(10000) 
FROM internal.event_message_context WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)

SELECT @int = @@ROWCOUNT;

COMMIT TRANSACTION

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_message_context', @int

COMMIT TRANSACTION

END -- WHILE

-- internal.event_messages

-- get row count
SELECT @int = COUNT(1) 
FROM internal.event_messages WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_messages', @int

COMMIT TRANSACTION

WHILE EXISTS
(
SELECT TOP (1) operation_id 
FROM internal.event_messages WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)
)

BEGIN -- WHILE

BEGIN TRANSACTION

DELETE TOP(1000) 
FROM internal.event_messages WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)

SET @int = @@ROWCOUNT;

COMMIT TRANSACTION

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT)
SELECT 'deleting from internal.event_messages', @int

COMMIT TRANSACTION

END -- WHILE

-- operation_messages

BEGIN TRANSACTION

-- get row count
SELECT @int = COUNT(1)
FROM internal.operation_messages WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operation_messages_temp
)

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_messages', @int

COMMIT TRANSACTION

WHILE EXISTS
(
SELECT TOP (1) operation_id 
FROM internal.operation_messages WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operation_messages_temp
)
)
BEGIN -- WHILE

BEGIN TRANSACTION

DELETE TOP (1000)
FROM internal.operation_messages WITH (ROWLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM dbo.operation_messages_temp
);

SET @int = @@ROWCOUNT;

COMMIT TRANSACTION

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_messages', @int

COMMIT TRANSACTION

END -- WHILE

BEGIN TRANSACTION

SET @int=0;
INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_permissions', @int

COMMIT TRANSACTION

-- operation_permissions

WHILE EXISTS
( 
SELECT TOP (1) object_id
FROM internal.operation_permissions WITH (NOLOCK)
WHERE object_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)
) 

BEGIN -- while

BEGIN TRANSACTION

DELETE TOP (100)
FROM internal.operation_permissions WITH (ROWLOCK)
WHERE object_id IN
(
SELECT operation_id
FROM dbo.operations_temp WITH (NOLOCK)
)

SELECT @INT = @@ROWCOUNT

COMMIT TRANSACTION

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_permissions', @int

COMMIT TRANSACTION

END -- while

BEGIN TRANSACTION

SELECT @int= 0;
INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operation_permissions', @int

COMMIT TRANSACTION

-- operations

SELECT @int= 0;

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operations', @int

COMMIT TRANSACTION

WHILE EXISTS
(
SELECT TOP 1 operation_id
FROM internal.operations WITH (NOLOCK)
WHERE created_time < @GETDATE
)
BEGIN -- WHILE

BEGIN TRANSACTION

DELETE TOP (100)
FROM internal.operations WITH (ROWLOCK)
WHERE created_time < @GETDATE

SELECT @int= @@ROWCOUNT;

COMMIT TRANSACTION

BEGIN TRANSACTION

INSERT INTO dbo.SSISDB_prune_data_log
(MSG
,ROW_COUNT
)
SELECT 'deleting from internal.operations', @int

COMMIT TRANSACTION

END -- WHILE

END TRY

BEGIN CATCH

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
	,@ErrorState = ERROR_STATE()
	,@ErrorSeverity = ERROR_STATE()
	,@ErrorLine = ERROR_LINE()
	,@ErrorProcedure = ERROR_PROCEDURE()
	,@ErrorMessage = ERROR_MESSAGE()
	,@ErrorDateTime = GETDATE();

	ROLLBACK TRANSACTION;

    INSERT INTO dbo.SSISDB_Error
    VALUES
  (@UserName,
   @ErrorNumber,
   @ErrorState,
   @ErrorSeverity,
   @ErrorLine,
   @ErrorProcedure,
   @ErrorMessage,
   @ErrorDateTime);
   
   RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH

