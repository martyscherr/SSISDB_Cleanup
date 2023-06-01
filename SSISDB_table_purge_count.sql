
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

/*

dbcc opentran;

SELECT * FROM SSISDB.DBO.SSISDB_prune_data_log WITH (NOLOCK)
ORDER BY id DESC

*/

SELECT 'executable_statistics', COUNT(1)
FROM internal.executable_statistics WITH (NOLOCK)
WHERE execution_id IN
(
SELECT operation_id
FROM internal.operations o WITH (NOLOCK)
WHERE created_time < GETDATE()-3
)

SELECT 'execution_parameter_values', COUNT(1) 
FROM internal.execution_parameter_values WITH (NOLOCK)
WHERE execution_id IN 
(
SELECT o.operation_id FROM internal.operations o WITH (NOLOCK)
WHERE o.created_time < GETDATE()-3
)

SELECT 'event_message_context', COUNT(1)
FROM internal.event_message_context WITH (NOLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM internal.operations WITH (NOLOCK)
WHERE created_time < GETDATE()-3
)

SELECT 'event_messages', COUNT(1)
FROM internal.event_messages WITH (NOLOCK)
WHERE operation_id IN
(
SELECT operation_id
FROM internal.operations WITH (NOLOCK)
WHERE created_time < GETDATE()-3
)

SELECT 'operation_permissions', COUNT(1)
FROM internal.operation_permissions WITH (NOLOCK)
WHERE  IN
(
SELECT operation_id
FROM internal.operations WITH (NOLOCK)
WHERE created_time < GETDATE()-3
)