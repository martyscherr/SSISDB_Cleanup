
USE SSISDB
SELECT
DB_NAME() AS DbName,
file_id,
    name AS FileName, 
    type_desc,
    size/128.0 AS CurrentSizeMB,  
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
	,growth/128.0  AS FileGrowthMB
FROM sys.database_files
WHERE type IN (0,1)

DECLARE @GETDATE DATETIME =  GETDATE()-3

/*

SELECT * FROM dbo.SSISDB_prune_data_log
ORDER BY id DESC

*/

-- get max operation_id from internal.operations table
DECLARE @operation_id BIGINT

SELECT 'Check Table Record Counts based on Date Threshold';

SELECT @operation_id = MAX(operation_id)
FROM internal.operations WITH (NOLOCK)
WHERE  created_time < @GETDATE

SELECT 'executable_statistics', COUNT(1)
FROM internal.executable_statistics WITH (NOLOCK)
WHERE execution_id <= @operation_id;

SELECT 'execution_parameter_values', COUNT(1) 
FROM internal.execution_parameter_values WITH (NOLOCK)
WHERE execution_id <= @operation_id;

SELECT 'event_message_context', COUNT(1)
FROM internal.event_message_context WITH (NOLOCK)
WHERE operation_id <= @operation_id;

SELECT 'event_messages', COUNT(1)
FROM internal.event_messages WITH (NOLOCK)
WHERE operation_id <= @operation_id;

SELECT 'operation_permissions', COUNT(1)
FROM internal.operation_permissions WITH (NOLOCK)
WHERE OBJECT_ID <= @operation_id;

SELECT 'operations',COUNT(1)
FROM internal.operations WITH (NOLOCK)
WHERE operation_id <= @operation_id;

SELECT 'Check Table Record Counts based on Foreign Key Constraints';

SELECT 'executable_statistics', COUNT(1)
FROM internal.executable_statistics WITH (NOLOCK)
WHERE execution_id NOT IN
(SELECT operation_id
 FROM internal.operations WITH (NOLOCK)
)

SELECT 'execution_parameter_values', COUNT(1) 
FROM internal.execution_parameter_values WITH (NOLOCK)
WHERE execution_id NOT IN
(SELECT operation_id
 FROM internal.operations WITH (NOLOCK)
)

SELECT 'event_message_context', COUNT(1)
FROM internal.event_message_context WITH (NOLOCK)
WHERE operation_id NOT IN
(SELECT operation_id
 FROM internal.operations WITH (NOLOCK)
)
SELECT 'event_messages', COUNT(1)
FROM internal.event_messages WITH (NOLOCK)
WHERE operation_id NOT IN
(SELECT operation_id
 FROM internal.operations WITH (NOLOCK)
)

SELECT 'operation_permissions', COUNT(1)
FROM internal.operation_permissions WITH (NOLOCK)
WHERE OBJECT_ID NOT IN
(SELECT operation_id
 FROM internal.operations WITH (NOLOCK)
)
